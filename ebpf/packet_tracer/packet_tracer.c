#include <linux/byteorder/generic.h>
#include <linux/netdevice.h>
#include <linux/skbuff.h>
#include <net/sock.h>
#include <uapi/linux/icmp.h>
#include <uapi/linux/if.h>
#include <uapi/linux/in.h>
#include <uapi/linux/ip.h>
#include <uapi/linux/udp.h>

#define member_addr(src, mem)                                                  \
	(void *)((char *)src + offsetof(typeof(*src), mem))

#define member_read(dst, src, mem)                                             \
	bpf_probe_read(dst, sizeof(src->mem), member_addr(src, mem))

#define MAC_HEADER_SIZE 14

const u32 DHOST = 0xC0A80007; // 192.168.0.7
const u32 SHOST = 0xC0A80008; // 192.168.0.8
const u32 DIP = 0x0A000102;   // 10.0.1.2
const u32 SIP = 0x0A000104;   // 10.0.1.4
const u16 VXLAN_PORT = 4789;
const u16 UDP_PORT = 9999;

enum event_type {
	BR_FORWARD,
	BR_HANDLE_FRAME,
	DEV_QUEUE_XMIT,
	DO_SOFTIRQ,
	ENQUEUE_TO_BACKLOG,
	GRO_CELL_POLL,
	IP_LOCAL_OUT,
	IP_RCV,
	IP_SEND_SKB,
	IP_TUNNEL_XMIT,
	IXGBE_POLL,
	IXGBE_XMIT_FRAME,
	NAPI_POLL,
	NETIF_RECEIVE_SKB,
	NETIF_RX,
	NET_DEV_QUEUE,
	NET_DEV_START_XMIT,
	NET_DEV_XMIT,
	NET_DEV_XMIT_TIMEOUT,
	NET_RX_ACTION,
	NET_TX_ACTION,
	PROCESS_BACKLOG,
	RUN_KSOFTIRQD,
	RUN_KSOFTIRQD__RET,
	UDP_RCV,
	UDP_SEND_SKB,
	UDP_TUNNEL_XMIT_SKB,
	VETH_XMIT,
	VXLAN_RCV,
	VXLAN_XMIT,
};

struct data_t {
	u64 time;
	u8 event_id;
	char dev[IFNAMSIZ];
	char devtype[IFNAMSIZ];
	u32 namespace;
	u32 sip;
	u32 dip;
	u32 pktid;
};

BPF_PERF_OUTPUT(events);

static inline void get_dev_info(struct sk_buff *skb, struct data_t *data)
{
	struct net_device *nd;

	// fill the name
	member_read(&nd, skb, dev);
	bpf_probe_read_str(data->dev, IFNAMSIZ, nd->name);

	// fill the type
	struct device *dev = &(nd->dev);
	struct device_type *devtype;
	member_read(&devtype, dev, type);
	const char *type;
	member_read(&type, devtype, name);
	bpf_probe_read_str(data->devtype, IFNAMSIZ, type);

	// fill the namespace
	possible_net_t nd_net;
	struct ns_common ns;
	member_read(&nd_net, nd, nd_net);
	member_read(&ns, nd_net.net, ns);
	data->namespace = ns.inum;
}

static inline bool host_match(u32 sip, u32 dip)
{
	return (sip == SHOST && dip == DHOST);
}

static inline bool container_match(u32 sip, u32 dip)
{
	return (sip == SIP && dip == DIP);
}

static inline bool process_skb(struct sk_buff *skb, struct data_t *data)
{
	char *cursor;
	u16 mac_h_offset;
	u16 network_h_offset;
	struct iphdr iphdr;
	struct udphdr udphdr;

	// load dev info first
	get_dev_info(skb, data);

	// load ip header
	member_read(&cursor, skb, head);
	member_read(&mac_h_offset, skb, mac_header);
	member_read(&network_h_offset, skb, network_header);
	if (network_h_offset == 0)
		network_h_offset = mac_h_offset + MAC_HEADER_SIZE;
	cursor += network_h_offset;
	bpf_probe_read(&iphdr, sizeof(iphdr), cursor);
	if (iphdr.version != 4)
		return false;

	// fetch the ip addresses
	data->sip = ntohl(iphdr.saddr);
	data->dip = ntohl(iphdr.daddr);

	if (host_match(data->sip, data->dip)) {
		// underlay

		if (iphdr.protocol != IPPROTO_UDP)
			return false;
		cursor += (iphdr.ihl * 4);
		bpf_probe_read(&udphdr, sizeof(udphdr), cursor);
		if (ntohs(udphdr.dest) == UDP_PORT)
			goto get_packet_id;
		if (ntohs(udphdr.dest) != VXLAN_PORT)
			return false;

		// skip vxlan header and inner mac header
		cursor += (sizeof(udphdr) + 8 + 14);
		bpf_probe_read(&iphdr, sizeof(iphdr), cursor);
		if (iphdr.version != 4)
			return false;
		if (container_match(ntohl(iphdr.saddr), ntohl(iphdr.daddr)))
			goto overlay;
	}

	if (container_match(data->sip, data->dip)) {
overlay:
		// overlay
		if (iphdr.protocol != IPPROTO_UDP)
			return false;
		cursor += (iphdr.ihl * 4);
		bpf_probe_read(&udphdr, sizeof(udphdr), cursor);
		if (ntohs(udphdr.dest) != UDP_PORT)
			return false;
get_packet_id:
		// get pkt id
		cursor += sizeof(udphdr);
		bpf_probe_read(&(data->pktid), sizeof(data->pktid), cursor);
	} else {
		return false;
	}

	return true;
}

static inline int do_trace(void *ctx, struct sk_buff *skb, int event_id)
{
	// sampling
	/* if (bpf_get_prandom_u32() > (0xFFFFFFFFl >> 3)) // sampling */
	/* 	return 0; */

	struct data_t data = {
		.time = bpf_ktime_get_ns(),
		.event_id = event_id,
	};

	if ((skb == NULL) || (process_skb(skb, &data)))
		events.perf_submit(ctx, &data, sizeof data);

	return 0;
}

static inline int do_trace_poll(void *ctx, int quota, int event_id)
{
	// sampling
	/* if (bpf_get_prandom_u32() > (0xFFFFFFFFl >> 3)) // sampling */
	/* 	return 0; */

	struct data_t data = {
		.time = bpf_ktime_get_ns(),
		.event_id = event_id,
		.namespace = quota,
	};

	events.perf_submit(ctx, &data, sizeof data);

	return 0;
}

int kprobe__net_rx_action(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, NET_RX_ACTION);
}
int kprobe__net_tx_action(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, NET_TX_ACTION);
}
int kprobe__ixgbe_poll(struct pt_regs *ctx, void *napi, int quota)
{
	return do_trace_poll(ctx, quota, IXGBE_POLL);
}
int kprobe__process_backlog(struct pt_regs *ctx, void *napi, int quota)
{
	return do_trace_poll(ctx, quota, PROCESS_BACKLOG);
}
int kprobe__gro_cell_poll(struct pt_regs *ctx, void *napi, int quota)
{
	return do_trace_poll(ctx, quota, GRO_CELL_POLL);
}
int kprobe____do_softirq(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, DO_SOFTIRQ);
}
int kprobe__run_ksoftirqd(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, RUN_KSOFTIRQD);
}
int kretprobe__run_ksoftirqd(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, RUN_KSOFTIRQD__RET);
}
int kretprobe__enqueue_to_backlog(struct pt_regs *ctx)
{
	return do_trace(ctx, NULL, ENQUEUE_TO_BACKLOG);
}
int kprobe__br_handle_frame(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, BR_HANDLE_FRAME);
}
int kprobe__br_forward(struct pt_regs *ctx, void *to, struct sk_buff *skb)
{
	return do_trace(ctx, skb, BR_FORWARD);
}
int kprobe__vxlan_rcv(struct pt_regs *ctx, struct sock *sk, struct sk_buff *skb)
{
	return do_trace(ctx, skb, VXLAN_RCV);
}
int kprobe__ip_rcv(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, IP_RCV);
}
int kprobe__udp_rcv(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, UDP_RCV);
}
TRACEPOINT_PROBE(net, net_dev_queue)
{
	return do_trace(args, (struct sk_buff *)args->skbaddr, NET_DEV_QUEUE);
}
TRACEPOINT_PROBE(net, net_dev_xmit)
{
	return do_trace(args, (struct sk_buff *)args->skbaddr, NET_DEV_XMIT);
}
TRACEPOINT_PROBE(net, netif_receive_skb)
{
	return do_trace(args, (struct sk_buff *)args->skbaddr,
			NETIF_RECEIVE_SKB);
}
TRACEPOINT_PROBE(net, netif_rx)
{
	return do_trace(args, (struct sk_buff *)args->skbaddr, NETIF_RX);
}
/* for god knows whatever reason, we can't probe udp_send_skb
int kprobe__udp_send_skb(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, UDP_SEND_SKB);
}
*/
int kprobe__ip_send_skb(struct pt_regs *ctx, struct net *net,
			struct sk_buff *skb)
{
	return do_trace(ctx, skb, IP_SEND_SKB);
}
int kprobe____ip_local_out(struct pt_regs *ctx, struct net *net,
			   struct sock *sk, struct sk_buff *skb)
{
	return do_trace(ctx, skb, IP_LOCAL_OUT);
}
int kprobe____dev_queue_xmit(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, DEV_QUEUE_XMIT);
}
int kprobe__veth_xmit(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, VETH_XMIT);
}
int kprobe__vxlan_xmit(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, VXLAN_XMIT);
}
int kprobe__ixgbe_xmit_frame(struct pt_regs *ctx, struct sk_buff *skb)
{
	return do_trace(ctx, skb, IXGBE_XMIT_FRAME);
}
