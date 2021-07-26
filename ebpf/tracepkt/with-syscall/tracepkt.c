#include <bcc/proto.h>
#include <uapi/linux/ip.h>
#include <uapi/linux/ipv6.h>
#include <uapi/linux/icmp.h>
#include <uapi/linux/icmpv6.h>
#include <net/inet_sock.h>
#include <linux/netfilter/x_tables.h>

#define ROUTE_EVT_IF 1
#define ROUTE_EVT_IPTABLE 2
#define FUNNAMESIZ 30

// Event structure
struct route_evt_t {
    /* Content flags */
    u64 flags;

    /* Routing information */
    char ifname[IFNAMSIZ];
    u64 netns;

    /* Packet type (IPv4 or IPv6) and address */
    u64 ip_version; // familiy (IPv4 or IPv6)
    u64 icmptype;
    u64 icmpid;     // In practice, this is the PID of the ping process (see "ident" field in https://github.com/iputils/iputils/blob/master/ping_common.c)
    u64 icmpseq;    // Sequence number
    u64 saddr[2];   // Source address. IPv4: store in saddr[0]
    u64 daddr[2];   // Dest   address. IPv4: store in daddr[0]

    /* Iptables trace */
    u64 hook;
    u64 verdict;
    char tablename[XT_TABLE_MAXNAMELEN];
    char funcname[FUNNAMESIZ];
};
BPF_PERF_OUTPUT(route_evt);

// Arg stash structure
struct ipt_do_table_args
{
    struct sk_buff *skb;
    const struct nf_hook_state *state;
    struct xt_table *table;
};
BPF_HASH(cur_ipt_do_table_args, u32, struct ipt_do_table_args);

#define MAC_HEADER_SIZE 14;
#define member_address(source_struct, source_member)            \
    ({                                                          \
        void* __ret;                                            \
        __ret = (void*) (((char*)source_struct) + offsetof(typeof(*source_struct), source_member)); \
        __ret;                                                  \
    }) 
#define member_read(destination, source_struct, source_member)  \
  do{                                                           \
    bpf_probe_read(                                             \
      destination,                                              \
      sizeof(source_struct->source_member),                     \
      member_address(source_struct, source_member)              \
    );                                                          \
  } while(0)

/**
  * Common tracepoint handler. Detect IPv4/IPv6 ICMP echo request and replies and
  * emit event with address, interface and namespace.
  */
static inline int do_trace_skb(struct route_evt_t *evt, void *ctx, struct sk_buff *skb)
{
    // Prepare event for userland
    evt->flags |= ROUTE_EVT_IF;

    // Compute MAC header address
    char* head;
    u16 mac_header;
    u16 network_header;

    member_read(&head,       skb, head);
    member_read(&mac_header, skb, mac_header);
    member_read(&network_header, skb, network_header);

    if(network_header == 0) {
        network_header = mac_header + MAC_HEADER_SIZE;
    }

    // Compute IP Header address
    char *ip_header_address = head + network_header;

    // Abstract IPv4 / IPv6
    u8 proto_icmp;
    u8 proto_icmp_echo_request;
    u8 proto_icmp_echo_reply;
    u8 icmp_offset_from_ip_header;
    u8 l4proto;

    // Load IP protocol version
    bpf_probe_read(&evt->ip_version, sizeof(u8), ip_header_address);
    evt->ip_version = evt->ip_version >> 4 & 0xf;

    // Filter IP packets
    if (evt->ip_version == 4) {
        // Load IP Header
        struct iphdr iphdr;
        bpf_probe_read(&iphdr, sizeof(iphdr), ip_header_address);

        // Load protocol and address
        icmp_offset_from_ip_header = iphdr.ihl * 4;
        l4proto      = iphdr.protocol;
        evt->saddr[0] = iphdr.saddr;
        evt->daddr[0] = iphdr.daddr;

        // Load constants
        proto_icmp = IPPROTO_ICMP;
        proto_icmp_echo_request = ICMP_ECHO;
        proto_icmp_echo_reply   = ICMP_ECHOREPLY;
    } else if (evt->ip_version == 6) {
        // Assume no option header --> fixed size header
        struct ipv6hdr* ipv6hdr = (struct ipv6hdr*)ip_header_address;
        icmp_offset_from_ip_header = sizeof(*ipv6hdr);

        // Load protocol and address
        bpf_probe_read(&l4proto,  sizeof(ipv6hdr->nexthdr),  (char*)ipv6hdr + offsetof(struct ipv6hdr, nexthdr));
        bpf_probe_read(evt->saddr, sizeof(ipv6hdr->saddr),   (char*)ipv6hdr + offsetof(struct ipv6hdr, saddr));
        bpf_probe_read(evt->daddr, sizeof(ipv6hdr->daddr),   (char*)ipv6hdr + offsetof(struct ipv6hdr, daddr));

        // Load constants
        proto_icmp = IPPROTO_ICMPV6;
        proto_icmp_echo_request = ICMPV6_ECHO_REQUEST;
        proto_icmp_echo_reply   = ICMPV6_ECHO_REPLY;
    } else {
        return -1;
    }

    // Filter ICMP packets
    if (l4proto != proto_icmp) {
        return -2;
    }

    // Compute ICMP header address and load ICMP header
    char* icmp_header_address = ip_header_address + icmp_offset_from_ip_header;
    struct icmphdr icmphdr;
    bpf_probe_read(&icmphdr, sizeof(icmphdr), icmp_header_address);

    // Filter ICMP echo request and echo reply
    if (icmphdr.type != proto_icmp_echo_request && icmphdr.type != proto_icmp_echo_reply) {
        return -3;
    }

    // Get ICMP info
    evt->icmptype = icmphdr.type;
    evt->icmpid   = icmphdr.un.echo.id;
    evt->icmpseq  = icmphdr.un.echo.sequence;

    // Fix endian
    evt->icmpid  = be16_to_cpu(evt->icmpid);
    evt->icmpseq = be16_to_cpu(evt->icmpseq);

    // Get device pointer, we'll need it to get the name and network namespace
    struct net_device *dev;
    member_read(&dev, skb, dev);

    // Load interface name
    bpf_probe_read(&evt->ifname, IFNAMSIZ, dev->name);

#ifdef CONFIG_NET_NS
    struct net* net;

    // Get netns id. The code below is equivalent to: evt->netns = dev->nd_net.net->ns.inum
    possible_net_t *skc_net = &dev->nd_net;
    member_read(&net, skc_net, net);
    struct ns_common* ns = member_address(net, ns);
    member_read(&evt->netns, ns, inum);
#endif

    return 0;
}

static inline int do_trace(void *ctx, struct sk_buff *skb, char *fnname)
{
    // Prepare event for userland
    struct route_evt_t evt = {};

    strcpy(evt.funcname,fnname);

    // Process packet
    int ret = do_trace_skb(&evt, ctx, skb);
    if (ret == 0 )
    {
    	// Send event
    	route_evt.perf_submit(ctx, &evt, sizeof(evt));
    }


    // Return
    return ret;
}

/**
 * Attach to Kernel Interface Tracepoints
 */

TRACEPOINT_PROBE(net, netif_rx)
{
    return do_trace(args, (struct sk_buff *)args->skbaddr,"net:netif_rx");
}

TRACEPOINT_PROBE(net, net_dev_queue)
{
    return do_trace(args, (struct sk_buff *)args->skbaddr,"net:net_dev_queue");
}

TRACEPOINT_PROBE(net, napi_gro_receive_entry)
{
    return do_trace(args, (struct sk_buff *)args->skbaddr,"net:napi_gro_receive_entry");
}

TRACEPOINT_PROBE(net, netif_receive_skb_entry)
{
    return do_trace(args, (struct sk_buff *)args->skbaddr,"net:netif_receive_skb_entry");
}

/**
 * Common iptables functions
 */

static inline int __ipt_do_table_in(struct pt_regs *ctx, struct sk_buff *skb, const struct nf_hook_state *state, struct xt_table *table)
{
    u32 pid = bpf_get_current_pid_tgid();

    // stash the arguments for use in retprobe
    struct ipt_do_table_args args = {
        .skb = skb,
        .state = state,
        .table = table,
    };
    cur_ipt_do_table_args.update(&pid, &args);
    return 0;
};

static inline int __ipt_do_table_out(struct pt_regs * ctx)
{
    // Load arguments
    u32 pid = bpf_get_current_pid_tgid();
    struct ipt_do_table_args *args;
    args = cur_ipt_do_table_args.lookup(&pid);
    if (args == 0)
    {
        return 0; // missed entry
    }
    cur_ipt_do_table_args.delete(&pid);

    // Prepare event for userland
    struct route_evt_t evt = {
        .flags = ROUTE_EVT_IPTABLE,
    };
    
    strcpy(evt.funcname,"ipt_do_table");
    // Load packet information
    struct sk_buff *skb = args->skb;
    int err = do_trace_skb(&evt, ctx, skb);
    if(err != 0)
    {
   	return 0;
    }

    // Store the hook
    const struct nf_hook_state *state = args->state;
    member_read(&evt.hook, state, hook);

    // Store the table name
    struct xt_table *table = args->table;
    member_read(&evt.tablename, table, name);

    // Store the verdict
    int ret = PT_REGS_RC(ctx);
    evt.verdict = ret;

    // Send event
    route_evt.perf_submit(ctx, &evt, sizeof(evt));

    return 0;
}

/**
 * Attach to Kernel iptables main function
 */

int kprobe__ipt_do_table(struct pt_regs *ctx, struct sk_buff *skb, const struct nf_hook_state *state, struct xt_table *table)
{
    return __ipt_do_table_in(ctx, skb, state, table);
};

int kretprobe__ipt_do_table(struct pt_regs *ctx)
{
    return __ipt_do_table_out(ctx);
}
int kprobe__ip6t_do_table(struct pt_regs *ctx, struct sk_buff *skb, const struct nf_hook_state *state, struct xt_table *table)
{
    return __ipt_do_table_in(ctx, skb, state, table);
};

int kretprobe__ip6t_do_table(struct pt_regs *ctx)
{
    return __ipt_do_table_out(ctx);
}
