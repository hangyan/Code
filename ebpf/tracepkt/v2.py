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
        char comm[TASK_COMM_LEN];
        char ifname[IFNAMSIZ];
};
BPF_PERF_OUTPUT(route_evt);

static inline int do_trace(void* ctx, struct sk_buff* skb)
{
    // Built event for userland
    struct route_evt_t evt = {};
    bpf_get_current_comm(evt.comm, TASK_COMM_LEN);

    // get device name
    struct net_device *dev;
    bpf_probe_read(&dev, sizeof(skb->dev), ((char*)skb) + offsetof(typeof(*skb), dev));
    bpf_probe_read(&evt.ifname, IFNAMSIZ, dev->name);

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
DEV_NAME_LEN = 32

class RouteEvt(ct.Structure):
    _fields_ = [
        ("comm",    ct.c_char * TASK_COMM_LEN),
        ("dev", ct.c_char * DEV_NAME_LEN),
    ]

def event_printer(cpu, data, size):
    # Decode event
    event = ct.cast(data, ct.POINTER(RouteEvt)).contents

    # Print event
    print("Just got a packet from %s, dev is: %s" % (event.comm, event.dev))

if __name__ == "__main__":
    b = BPF(text=bpf_text)
    b["route_evt"].open_perf_buffer(event_printer)

    while True:
        b.kprobe_poll()