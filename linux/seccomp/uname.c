#include <linux/seccomp.h>
#include <linux/filter.h>
#include <linux/audit.h>
#include <sys/ptrace.h>
#include <sys/prctl.h>

#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/utsname.h>
#include <errno.h>
#include <unistd.h>
#include <sys/syscall.h>

static void sandbox(void)
{
    struct sock_filter filter[] = {
        /* seccomp(2) says we should always check the arch */
        /* as syscalls may have different numbers on different architectures */
        /* see https://fedora.juszkiewicz.com.pl/syscalls.html */
        /* for simplicity we only allow x86_64 */
        BPF_STMT(BPF_LD | BPF_W | BPF_ABS, (offsetof(struct seccomp_data, arch))),
        /* if not x86_64, tell the kernel to kill the process */
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AUDIT_ARCH_X86_64, 0, 4),
        /* get the actual syscall number */
        BPF_STMT(BPF_LD | BPF_W | BPF_ABS, (offsetof(struct seccomp_data, nr))),
        /* if "uname", tell the kernel to return EPERM, otherwise just allow */
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_uname, 0, 1),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ERRNO | (EPERM & SECCOMP_RET_DATA)),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL),
    };

    struct sock_fprog prog = {
        .len = (unsigned short)(sizeof(filter) / sizeof(filter[0])),
        .filter = filter,
    };

    /* see seccomp(2) on why this is needed */
    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
        perror("PR_SET_NO_NEW_PRIVS failed");
        exit(1);
    };

    /* glibc does not have a wrapper for seccomp(2) */
    /* invoke it via the generic syscall wrapper */
    if (syscall(SYS_seccomp, SECCOMP_SET_MODE_FILTER, 0, &prog)) {
        perror("seccomp failed");
        exit(1);
    };
}

int main(void)
{
    struct utsname name;

    sandbox();

    if (uname(&name)) {
        perror("uname failed");
        return 1;
    }

    printf("My OS is %s!\n", name.sysname);
    return 0;
}
