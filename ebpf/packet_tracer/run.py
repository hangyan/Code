#!/usr/bin/env python3

from bcc import BPF
from ipaddress import ip_address

event_map = [
    "BR_FORWARD",
    "BR_HANDLE_FRAME",
    "DEV_QUEUE_XMIT",
    "DO_SOFTIRQ",
    "ENQUEUE_TO_BACKLOG",
    "GRO_CELL_POLL",
    "IP_LOCAL_OUT",
    "IP_RCV",
    "IP_SEND_SKB",
    "IP_TUNNEL_XMIT",
    "IXGBE_POLL",
    "IXGBE_XMIT_FRAME",
    "NAPI_POLL",
    "NETIF_RECEIVE_SKB",
    "NETIF_RX",
    "NET_DEV_QUEUE",
    "NET_DEV_START_XMIT",
    "NET_DEV_XMIT",
    "NET_DEV_XMIT_TIMEOUT",
    "NET_RX_ACTION",
    "NET_TX_ACTION",
    "PROCESS_BACKLOG",
    "RUN_KSOFTIRQD",
    "RUN_KSOFTIRQD__RET",
    "UDP_RCV",
    "UDP_SEND_SKB",
    "UDP_TUNNEL_XMIT_SKB",
    "VETH_XMIT",
    "VXLAN_RCV",
    "VXLAN_XMIT",
]

start = 0


def print_event(cpu, data, size):
    global start

    event = B["events"].event(data)
    if start == 0:
        start = event.time

    time_s = float(event.time - start) / 1000.0

    if event.dev.decode():
        print("{:12.2f} {:<20} {:<16} {:<10} {:<15} {:<15} {:<10}".format(
            time_s, event_map[event.event_id].lower(),
            event.dev.decode(), event.namespace,
            ip_address(event.sip).exploded, ip_address(event.dip).exploded,
            event.pktid))
    elif event.namespace:
        print("{:12.2f} {:<20} {:<16} {:<10}".format(
            time_s, event_map[event.event_id].lower(), "", event.namespace))
    else:
        print("{:12.2f} {:<20}".format(
            time_s, event_map[event.event_id].lower()))


if __name__ == "__main__":
    B = BPF(src_file="packet_tracer.c")
    # B.attach_kprobe(event=B.get_syscall_fnname("clone"), fn_name="hello")
    B["events"].open_perf_buffer(print_event)

    # print the header
    print("{:>12} {:<20} {:<16} {:<10} {:<15} {:<15} {:<10}".format(
        "TIME(s)", "EVENT", "DEVICE", "NAMESPACE", "SRC", "DST", "PACKET ID"))
    print("{:>12} {:<20} {:<16} {:<10} {:<15} {:<15} {:<10}".format(
        "-------", "-----", "------", "---------", "---", "---", "---------"))

    while True:
        try:
            B.perf_buffer_poll()
        except KeyboardInterrupt:
            break
