from __future__ import print_function
from bcc import BPF
from time import sleep

b = BPF(text="""
#include <uapi/linux/ptrace.h>
#include <linux/blkdev.h>

BPF_HISTOGRAM(dist);
BPF_HISTOGRAM(dist_linear);

int kprobe__blk_account_io_done(struct pt_regs *ctx, struct request *req)
{
    dist.increment(bpf_log2l(req->__data_len / 1024));
    dist_linear.increment(req->__data_len/1024);
    return 0;
}

""")


# header
print("Tracing... Hit Ctrl-C to end.")

# trace until Ctrl-C
try:
	sleep(99999999)
except KeyboardInterrupt:
	print()


# output
print("log2 histogram")
print("~~~~~~~~~~~~~~")
b["dist"].print_log2_hist("kbytes")

print("\nlinear histogram")
print("~~~~~~~~~~~~~~~~")
b["dist_linear"].print_linear_hist("kbytes")