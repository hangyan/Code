# bpf-packet-tracer

A BPF program to trace the per-packet invocation of many important functions in the kernel network stack. Currently, it only traces UDP packets (which may be encapsulated by a VXLAN overlay).

To differentiate between different packets, the sender must set the first 32 bits of the UDP payload as the packet ID.

## Setup

Set proper values to the constants at the top of `packet_tracer.c` such as:

* `SHOST` (IP address of source host)
* `DHOST` (IP address of destination host)
* `SIP` (IP address of source overlay interface)
* `DIP` (IP address of destination overlay interface)
* `VXLAN_PORT` (default = standard = 4789)
* `UDP_PORT` (UDP port number)

## Run

```sh
sudo ./run.py
```

## Example output

```
     TIME(s) EVENT                DEVICE           NAMESPACE  SRC             DST             PACKET ID 
     ------- -----                ------           ---------  ---             ---             ---------
  8400969.39 do_softirq          
  8400981.13 net_rx_action       
  8400985.59 ixgbe_poll                            64        
  8401717.50 do_softirq          
  8401729.60 net_rx_action       
  8401734.22 ixgbe_poll                            64        
  8401820.52 do_softirq          
  8401824.76 net_rx_action       
  8401828.08 ixgbe_poll                            64        
  8403754.32 ip_send_skb         
  8403791.80 ip_local_out        
  8403831.27 dev_queue_xmit       eno1             4026532056 192.168.0.8     192.168.0.7     0         
  8403846.32 net_dev_queue        eno1             4026532056 192.168.0.8     192.168.0.7     0         
  8403864.75 ixgbe_xmit_frame     eno1             4026532056 192.168.0.8     192.168.0.7     0         
  8403879.72 net_dev_xmit         eno1             4026532056 192.168.0.8     192.168.0.7     0         
  8403898.77 ip_send_skb         
  8403924.68 ip_local_out        
  8403952.61 dev_queue_xmit       eno1             4026532056 192.168.0.8     192.168.0.7     1         
  8403965.26 net_dev_queue        eno1             4026532056 192.168.0.8     192.168.0.7     1         
  8403978.39 ixgbe_xmit_frame     eno1             4026532056 192.168.0.8     192.168.0.7     1         
  8403990.41 net_dev_xmit         eno1             4026532056 192.168.0.8     192.168.0.7     1         
  8404021.20 do_softirq          
  8404043.40 ip_send_skb         
  8404069.08 ip_local_out        
  8404096.65 dev_queue_xmit       eno1             4026532056 192.168.0.8     192.168.0.7     2         
  8404108.43 net_dev_queue        eno1             4026532056 192.168.0.8     192.168.0.7     2         
  8404121.53 ixgbe_xmit_frame     eno1             4026532056 192.168.0.8     192.168.0.7     2         
  8404134.03 net_dev_xmit         eno1             4026532056 192.168.0.8     192.168.0.7     2         
  8404150.55 ip_send_skb         
  8404176.51 ip_local_out        
  8404204.10 dev_queue_xmit       eno1             4026532056 192.168.0.8     192.168.0.7     3         
  8404215.48 net_dev_queue        eno1             4026532056 192.168.0.8     192.168.0.7     3         
  8404228.35 ixgbe_xmit_frame     eno1             4026532056 192.168.0.8     192.168.0.7     3         
  8404240.46 net_dev_xmit         eno1             4026532056 192.168.0.8     192.168.0.7     3         
  8404256.44 ip_send_skb         
  8404282.07 ip_local_out        
  8404309.07 dev_queue_xmit       eno1             4026532056 192.168.0.8     192.168.0.7     4         
  8404320.45 net_dev_queue        eno1             4026532056 192.168.0.8     192.168.0.7     4         
  8404333.16 ixgbe_xmit_frame     eno1             4026532056 192.168.0.8     192.168.0.7     4         
  8404345.53 net_dev_xmit         eno1             4026532056 192.168.0.8     192.168.0.7     4
  ...
```
