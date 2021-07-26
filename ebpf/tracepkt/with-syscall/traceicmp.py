#!/usr/bin/env python
# coding: utf-8

import sys
from socket import inet_ntop, AF_INET, AF_INET6
from bcc import BPF
import ctypes as ct
import subprocess
from struct import pack

IFNAMSIZ = 16 # uapi/linux/if.h
XT_TABLE_MAXNAMELEN = 32 # uapi/linux/netfilter/x_tables.h

FUNNAMESIZ = 30

# uapi/linux/netfilter.h
NF_VERDICT_NAME = [
    'DROP',
    'ACCEPT',
    'STOLEN',
    'QUEUE',
    'REPEAT',
    'STOP',
]

# uapi/linux/netfilter.h
# net/ipv4/netfilter/ip_tables.c
HOOKNAMES = [
    "PREROUTING",
    "INPUT",
    "FORWARD",
    "OUTPUT",
    "POSTROUTING",
]

ROUTE_EVT_IF = 1
ROUTE_EVT_IPTABLE = 2

class TestEvt(ct.Structure):
    _fields_ = [
        # Content flags
        ("flags",   ct.c_ulonglong),

        # Routing information
        ("ifname",  ct.c_char * IFNAMSIZ),
        ("netns",   ct.c_ulonglong),

        # Packet type (IPv4 or IPv6) and address
        ("ip_version",  ct.c_ulonglong),
        ("icmptype",    ct.c_ulonglong),
        ("icmpid",      ct.c_ulonglong),
        ("icmpseq",     ct.c_ulonglong),
        ("saddr",       ct.c_ulonglong * 2),
        ("daddr",       ct.c_ulonglong * 2),

        # Iptables trace
        ("hook",        ct.c_ulonglong),
        ("verdict",     ct.c_ulonglong),
        ("tablename",   ct.c_char * XT_TABLE_MAXNAMELEN),
        ("funcname",  ct.c_char * FUNNAMESIZ),
    ]


def _get(l, index, default):
    '''
    Get element at index in l or return the default
    '''
    if index < len(l):
        return l[index]
    return default

def event_printer(cpu, data, size):
    # Decode event
    event = ct.cast(data, ct.POINTER(TestEvt)).contents

    # Make sure this is an interface event
    if event.flags & ROUTE_EVT_IF != ROUTE_EVT_IF:
        return


    # Decode address
    if event.ip_version == 4:
        saddr = inet_ntop(AF_INET, pack("=I", event.saddr[0]))
        daddr = inet_ntop(AF_INET, pack("=I", event.daddr[0]))
    elif event.ip_version == 6:
        saddr = inet_ntop(AF_INET6, event.saddr)
        daddr = inet_ntop(AF_INET6, event.daddr)
    else:
        return

    # Decode direction
    if event.icmptype in [8, 128]:
        direction = "request"
    elif event.icmptype in [0, 129]:
        direction = "reply"
    else:
        return

    # Decode flow
    flow = "%s -> %s" % (saddr, daddr)

    # Optionally decode iptables events
    iptables = ""
    if event.flags & ROUTE_EVT_IPTABLE == ROUTE_EVT_IPTABLE:
        verdict = _get(NF_VERDICT_NAME, event.verdict, "~UNK~")
        hook = _get(HOOKNAMES, event.hook, "~UNK~")
        iptables = " %7s.%-12s:%s" % (event.tablename, hook, verdict)

    # Print event
    print "%-30s [%12s] %16s %7s %-34s%-30s" % (event.funcname,event.netns, event.ifname, direction, flow, iptables)

if __name__ == "__main__":
    # Build probe and open event buffer
    b = BPF(src_file='tracepkt.c')
    b["route_evt"].open_perf_buffer(event_printer)

    print "%-30s %14s %16s %7s %-34s %-30s" % ("TRACEPOINT",'NETWORK NS', 'INTERFACE', 'TYPE', 'ADDRESSES', 'IPTABLES')
    # Listen for event until the ping process has exited
    while True:
        b.kprobe_poll()
