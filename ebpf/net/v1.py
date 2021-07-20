#!/usr/bin/env python
# coding: utf-8

from socket import inet_ntop
from bcc import BPF
import ctypes as ct



bpf_text = '''
#include <bcc/proto.h>
#include <linux/sched.h>
#include <net/inet_sock.h>

// Event structure
struct route_evt_t {
        char ifname[IFNAMSIZ];
        u64 netns;
        /* Packet type (IPv4 or IPv6) and address */
        u64 ip_version; // familiy (IPv4 or IPv6)
        u64 icmptype;
        u64 icmpid;     // In practice, this is the PID of the ping process (see "ident" field in https://github.com/iputils/iputils/blob/master/ping_common.c)
        u64 icmpseq;    // Sequence number
        u64 saddr[2];   // Source address. IPv4: store in saddr[0]
        u64 daddr[2];   // Dest   address. IPv4: store in daddr[0]

};
BPF_PERF_OUTPUT(route_evt);


#define member_read(destination, source_struct, source_member)                 \
  do{                                                                          \
    bpf_probe_read(                                                            \
      destination,                                                             \
      sizeof(source_struct->source_member),                                    \
      ((char*)source_struct) + offsetof(typeof(*source_struct), source_member) \
    );                                                                         \
  } while(0)

  #define member_address(source_struct, source_member) \
({                                                   \
  void* __ret;                                       \
  __ret = (void*) (((char*)source_struct) + offsetof(typeof(*source_struct), source_member)); \
  __ret;                                             \
})


static inline int do_trace(void* ctx, struct sk_buff* skb)
{
    // Built event for userland
    struct route_evt_t evt = {};

    struct net_device *dev;
    bpf_probe_read(&dev, sizeof(skb->dev), ((char*)skb) + offsetof(typeof(*skb), dev));
    // Load interface name
    bpf_probe_read(&evt.ifname, IFNAMSIZ, dev->name);

    struct net* net;
    possible_net_t *skc_net = &dev-> nd_net;
    member_read(&net, skc_net, net);
    struct ns_common* ns = member_address(net, ns);
    member_read(&evt.netns, ns, inum);


    // Compute MAC header address
    char* head;
    u16 mac_header;

    member_read(&head,       skb, head);
    member_read(&mac_header, skb, mac_header);

    // Compute IP Header address
    #define MAC_HEADER_SIZE 14;
    char* ip_header_address = head + mac_header + MAC_HEADER_SIZE;

    // Load IP protocol version
    u8 ip_version;
    bpf_probe_read(&ip_version, sizeof(u8), ip_header_address);
    ip_version = ip_version >> 4 & 0xf;

    // Filter IPv4 packets
    if (ip_version != 4) {
        return 0;
    }


    struct iphdr iphdr;
    bpf_probe_read(&iphdr, sizeof(iphdr), ip_header_address);
    u8 icmp_offset_from_ip_header = iphdr.ihl * 4;
    evt.saddr[0] = iphdr.saddr;
    evt.daddr[0] = iphdr.daddr;
    if (iphdr.protocol != IPPROTO_ICMP) {
        return 0;
    }

    char* icmp_header_address = ip_header_address + icmp_offset_from_ip_header;
    struct icmphdr icmphdr;
    bpf_probe_read(&icmphdr, sizeof(icmphdr), icmp_header_address);

    if (icmphdr.type != ICMP_ECHO && icmphdr.type != ICMP_ECHOREPLY) {
        return 0;
    }

    // Get ICMP info
    evt.icmptype = icmphdr.type;
    evt.icmpid   = icmphdr.un.echo.id;
    evt.icmpseq  = icmphdr.un.echo.sequence;

    // Fix endian
    evt.icmpid  = be16_to_cpu(evt.icmpid);
    evt.icmpseq = be16_to_cpu(evt.icmpseq);




    // Send event to userland
    route_evt.perf_submit(ctx, &evt, sizeof(evt));

    return 0;
}

/**
  * Attach to Kernel Tracepoints
  */

TRACEPOINT_PROBE(net, netif_rx) {
    return do_trace(args, (struct sk_buff*)args->skbaddr);
}

TRACEPOINT_PROBE(net, net_dev_queue) {
    return do_trace(args, (struct sk_buff*)args->skbaddr);
}

TRACEPOINT_PROBE(net, napi_gro_receive_entry) {
    return do_trace(args, (struct sk_buff*)args->skbaddr);
}

TRACEPOINT_PROBE(net, netif_receive_skb_entry) {
    return do_trace(args, (struct sk_buff*)args->skbaddr);
}
'''

TASK_COMM_LEN = 16 # linux/sched.h

class RouteEvt(ct.Structure):
    _fields_ = [
        ("comm",    ct.c_char * TASK_COMM_LEN),
        ("netns", ct.c_uint64),
    ]

def event_printer(cpu, data, size):
    # Decode event
    event = ct.cast(data, ct.POINTER(RouteEvt)).contents

    # Print event
    print("Just got a packet from [%12s] %s" % (event.netns, event.comm))

if __name__ == "__main__":
    b = BPF(text=bpf_text)
    b["route_evt"].open_perf_buffer(event_printer)

    while True:
        b.kprobe_poll()
