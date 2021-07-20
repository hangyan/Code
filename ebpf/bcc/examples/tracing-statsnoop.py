from __future__ import print_function
from bcc import BPF
import argparse

# arguments
examples = """examples:
    ./statsnoop           # trace all stat() syscalls
    ./statsnoop -t        # include timestamps
    ./statsnoop -x        # only show failed stats
    ./statsnoop -p 181    # only trace PID 181
"""
parser = argparse.ArgumentParser(
    description="Trace stat() syscalls",
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=examples)
parser.add_argument("-t", "--timestamp", action="store_true",
    help="include timestamp on output")
parser.add_argument("-x", "--failed", action="store_true",
    help="only show failed stats")
parser.add_argument("-p", "--pid",
    help="trace this PID only")
parser.add_argument("--ebpf", action="store_true",
    help=argparse.SUPPRESS)
args = parser.parse_args()
debug = 0


bpf_text = """
#include <uapi/linux/ptrace.h>
#include <uapi/linux/limits.h>
#include <linux/sched.h>

struct val_t {
    const char *fname;
}

sturct data_t {
    u32 pid;
    u64 ts_ns;
    int ret;
    char comm[TASK_COMM_LEN];
    char fname[NAME_MAX];

}

BPF_HASH(infotmp, u32, struct val_t);
BPF_PERF_OUTPUT(events);

int syscall__entry(struct pt_regs *ctx, const char __user *filename) 
{
    struct val_t val = {};
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 pid = pid_tgid >> 32;
    u32ctid = (u32)pid_tgid;

    FILTER
    val.fname = filename;
    infotmp.update(&tid, &val)
    return 0;
}

int trace_return(struct pt_regs *ctx)
{
    u64 pid_tgid = bpf_get_current_pid_tgid();
    u32 tid = (u32)pid_tgid;
    sturct val_t *valp;
    
    valp = infotmp.lookup(&tid);
    if (valp == 0) {
        return 0;
    }

}



"""
