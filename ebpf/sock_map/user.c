// sockmap_user.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>
#include "bpf_load.h"
#include "bpf_util.h"

#define MAXSIZE	1024
char buf[MAXSIZE];
static int proxysd1, proxysd2;

static int sockmap_fd, proxymap_fd, bpf_prog_fd;
static int progs_fd[2];
static int key, val;
static unsigned short key16;
static int ctrl = 0;

static void int_handler(int a)
{
	close(proxysd1);
	close(proxysd2);
	exit(0);
}

// 可以通过发送HUP信号来打开和关闭sockmap offload功能
static void hup_handler(int a)
{
	if (ctrl == 1) {
		key = 0;
		bpf_map_update_elem(sockmap_fd, &key, &proxysd1, BPF_ANY);
		key = 1;
		bpf_map_update_elem(sockmap_fd, &key, &proxysd2, BPF_ANY);
		ctrl = 0;
	} else if (ctrl == 0){
		key = 0;
		bpf_map_delete_elem(sockmap_fd, &key);
		key = 1;
		bpf_map_delete_elem(sockmap_fd, &key);
		ctrl = 1;
	}
}

int main(int argc, char **argv)
{
	char filename[256];
	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
	struct bpf_object *obj;
	struct bpf_program *prog;
	struct bpf_prog_load_attr prog_load_attr = {
		.prog_type	= BPF_PROG_TYPE_SK_SKB,
	};

	int ret;
	struct sockaddr_in proxyaddr1, proxyaddr2;
	struct hostent *proxy1, *proxy2;
	unsigned short port1, port2;
	fd_set rset;
	int maxfd = 10;

	if (argc != 5) {
        printf("Usage: sockmap ip1 port1 ip2 port2!\n")
    	exit(1);
    }

	prog_load_attr.file = filename;

	signal(SIGINT, int_handler);
	signal(SIGHUP, hup_handler);

	// 这部分增加的代码引入了ebpf/sockmap逻辑, 完成了bpf的加载、attach
	bpf_prog_load_xattr(&prog_load_attr, &obj, &bpf_prog_fd);

	sockmap_fd = bpf_object__find_map_fd_by_name(obj, "sock_map");
	proxymap_fd = bpf_object__find_map_fd_by_name(obj, "proxy_map");

	prog = bpf_object__find_program_by_title(obj, "prog_parser");
	progs_fd[0] = bpf_program__fd(prog);
	bpf_prog_attach(progs_fd[0], sockmap_fd, BPF_SK_SKB_STREAM_PARSER, 0);

	prog = bpf_object__find_program_by_title(obj, "prog_verdict");
	progs_fd[1] = bpf_program__fd(prog);
	bpf_prog_attach(progs_fd[1], sockmap_fd, BPF_SK_SKB_STREAM_VERDICT, 0);


	proxysd1 = socket(AF_INET, SOCK_STREAM, 0);
	proxysd2 = socket(AF_INET, SOCK_STREAM, 0);

	proxy1 = gethostbyname(argv[1]);
	port1 = atoi(argv[2]);

	proxy2 = gethostbyname(argv[3]);
	port2 = atoi(argv[4]);

	bzero(&proxyaddr1, sizeof(struct sockaddr_in));
	proxyaddr1.sin_family = AF_INET;
	proxyaddr1.sin_port = htons(port1);
	proxyaddr1.sin_addr = *((struct in_addr *)proxy1->h_addr);

	bzero(&proxyaddr2, sizeof(struct sockaddr_in));
	proxyaddr2.sin_family = AF_INET;
	proxyaddr2.sin_port = htons(port2);
	proxyaddr2.sin_addr = *((struct in_addr *)proxy2->h_addr);

	connect(proxysd1, (struct sockaddr *)&proxyaddr1, sizeof(struct sockaddr));
	connect(proxysd2, (struct sockaddr *)&proxyaddr2, sizeof(struct sockaddr));
    
    // 将代理的socket添加到bpf映射sockmap中
	key = 0;
	bpf_map_update_elem(sockmap_fd, &key, &proxysd1, BPF_ANY);

	key = 1;
	bpf_map_update_elem(sockmap_fd, &key, &proxysd2, BPF_ANY);
	
    // 当数据包到达proxysd1的Socket接收队列，attach到BPF映射的钩子程序执行：取出__skb_buf元数据remote_port
    // 即数据包的源端口号8086, 并查询proxy_map，此端口号对应的socket在sockmap的索引值为1，即proxysd2，执行
    // bpf_sk_redirect_map将数据包转发到该socket的egress（不指定BPF_F_INGRESS Flag值）
	key16 = port1;
	val = 1;
	bpf_map_update_elem(proxymap_fd, &key16, &val, BPF_ANY);

	key16 = port2;
	val = 0;
	bpf_map_update_elem(proxymap_fd, &key16, &val, BPF_ANY);

	// 余下的proxy转发代码保持不变，这部分代码一旦开启了sockmap offload，将不会再被执行。
	while (1) {
		FD_SET(proxysd1, &rset);
		FD_SET(proxysd2, &rset);
		select(maxfd, &rset, NULL, NULL, NULL);
		memset(buf, 0, MAXSIZE);
		if (FD_ISSET(proxysd1, &rset)) {
			ret = recv(proxysd1, buf, MAXSIZE, 0);
			printf("%d --> %d proxy string:%s\n", proxysd1, proxysd2, buf);
			send(proxysd2, buf, ret, 0);
		}
		if (FD_ISSET(proxysd2, &rset)) {
			ret = recv(proxysd2, buf, MAXSIZE, 0);
			printf("%d --> %d proxy string:%s\n", proxysd2, proxysd1, buf);
			send(proxysd1, buf, ret, 0);
		}
	}

	return 0;
}
