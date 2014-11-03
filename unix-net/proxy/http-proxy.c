#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <errno.h>
#include <libgen.h>
#include <netdb.h>
#include <resolv.h>
#include <signal.h>
#include <unistd.h>
#include <sys/wait.h>
#include <netinet/in.h>




#define DEFAULT_LOCAL_PORT 8080

#define MAX_HEADER_SIZE 8192

#if defined(OS_ANDROID)
#include <android/log.h>
#define  LOG(fmt...) __android_log_print(ANDROID_LOG_DEBUG,__FILE__,##fmt)
#else
#define LOG(fmt...) do { fprintf(stderr,"%s %s ",__DATE__,__TIME__);fprintf(stderr,##fmt);} while(0)
#endif 

char remote_host[128];
int local_port;
int remote_port;

char* header_buffer;

enum {
	FLG_NONE = 0, /* 正常数据流不进行编解码 */
	R_C_DEC = 1, /* 读取客户端数据仅进行解码 */
	W_S_ENC = 2 /* 发送到服务端进行编码 */
};
	

static int io_flag; /* 网络io的一些标志位 */

void get_info(char* output);
const char* get_work_mode();
	
int _main(int argc,char* argv[]);



void usage(void)
{
	printf("Usage:\n");
	printf(" -l <port number> specifyed local listen port\n");
	printf(" -h <remote server and port> specifyed next top server name\n");
	printf(" -d <remote server and port> run as deamon\n");
	printf(" -E encode data when forwarding data\n");
	printf(" -D decode data when receiving data\n");
	exit(8);
}

const char* get_work_mode()
{
    if(strlen(remote_host) == 0) {
        if(io_flag == FLG_NONE) {
            return "start as normal http proxy";
        } else if (io_flag == R_C_DEC) {
            return "start as remote forward proxy and do decode data when receive data";
        }
    } else {
        if (io_flag == FLG_NONE) {
            return "start as remote forward proxy";
        } else if (io_flag == W_S_ENC) {
            return "start as forwrd proxy and do encode data when send data";
        }
    }
    return "unkown";
}


void get_info(char* output)
{
	int pos = 0;
	char line_buffer[512];
	sprintf(line_buffer,"====== mproxy (v0.1) ========\n");
	int len = strlen(line_buffer);
	memcpy(output,line_buffer,len);
	pos += len;

	sprintf(line_buffer,"%s\n",get_work_mode());
	len = strlen(line_buffer);
	memcpy(output + pos,line_buffer,len);

	if(strlen(remote_host) > 0) {
		sprintf(line_buffer,"start server on %d and next hop is %s:%d\n",local_port,
				remote_host,remote_port);
	} else {
		sprintf(line_buffer,"start server on %d\n",local_port);
	}

	len = strlen(line_buffer);
	memcpy(output+pos,line_buffer,len);
	pos += len;

	output[pos] = '\0';
}

int create_server_socket(int port)
{
	int server_sock,optval;
	struct sockaddr_in server_addr;

	if((server_sock = socket(AF_INET,SOCK_STREAM,0)) < 0) {
		return SERVE_SOCKET_ERROR;
	}

	if(setsocketopt(server_opt,SOL_SOCKET,SO_REUSEADDR,&optval,sizeof(optval)) < 0) {
		return SERVER_SETSOCKOPT_ERROR;
	}

	memset(&server_addr,0,sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	server_addr.sin_addr.s_addr = INADDR_ANY;

	if(bind(server_sock,(struct sockaddr*)&server_addr,sizeof(server_addr)) != 0) {
		return SERVER_BIND_ERROR;
	}
	if (listen(server_sock,20) < 0) {
		return SERVER_LISTEN_ERROR;
	}

	return server_sock;
}

void sigchld_handler(int signal)
{
	while(waitpid(-1,NULL,WNOHANG) > 0);
}


int receive_data(int socket,char* buffer,int len)
{
	int n = recv(socket,buffer,len,0);
	if(io_flag == R_C_DEC && n > 0) {
		int i;
		for(i = 0; i < n; i++) {
			char c = buffer[i];
			buffer[i] = c-1;
		}
	}

	return n;
}

ssize_t readLine(int fd,void* buffer, size_t n)
{
	ssize_t numRead;
	size_t totRead;
	char* buf;
	char ch;

	if (n <= 0 || buffer == NULL) {
		errno = EINVAL;
		return -1;
	}

	buf = buffer;
	totRead = 0;
	for(;;) {
		numRead = receive_data(fd,&ch,1);
		if (numRead == -1) {
			if (errno == EINTR) {
				continue;
			} else {
				return -1;
			}
		} else if (numRead == 0) {
			if(totRead == 0) {
				return 0;
			} else {
				break;
			}
		} else {
			if (totRead < n -1) {
				totRead++;
				*buf++ = ch;
			}
			if (ch == '\n') {
				break;
			}
		}

		*buf = '\0';
		return totRead;
	}
}

void read_header(int fd,void* buffer)
{
	memset(header_buffer,0,MAX_HEADER_SIZE);
	char line_buffer[2048];
	char* base_ptr = header_buffer;
	for(;;) {
		memset(line_buffer,0,2048);

		int total_read = readLine(fd,line_buffer,2048);
		if(total_read <= 0) {
			return CLIENT_SOCKET_ERROR;
		}
		if(base_ptr + total_read - head_buffer <= MAX_HEADER_SIZE) {
			strncpy(base_ptr,line_buffer,total_read);
			base_ptr += total_read;
		} else {
			return HEADER_BUFFER_FULL;
		}

		// read empty line,http header end.
		if(strcmp(line_buffer,"\r\n") == 0 || strcmp(line_buffer,"\n") == 0) {
			break;
		}
 		
	}
	return 0;
}


void handle_client(int client_sock,struct sockaddr_in client_addr)
{
	int is_http_tunnel = 0;
	if(strlen(remote_host) == 0) {
#ifdef DEBUG
			LOG("============== handle new client ================\n");
			LOG(">>>Header:s\n",header_buffer);
#endif
	}

	if(read_header(client_sock,header_buffer) < 0) {
		LOG("Read Http header failed\n");
		return;
	} else {
		char* p = strstr(header_buffer,"CONNECT");
		if(p) {
			LOG("receive CONNECT request\n");
			is_http_tunnel = 1;
		}
		if(strstr(header_buffer,"GET /mproxy") > 0) {
			LOG(" ======= hand mproxy info request ======");
			hand_mproxy_info_req(client_sock,header_buffer);
			return;
		}
	}
}

void extract_server_path(const char* header,char* output）
{
	char* p = strstr(header,"GET /");
	if(p) {
		char* p1 = strstr(p+4,'');
		strncpy(output,p+4,(int)(p1-p-4));
	}
}

void hand_mproxy_info_req(int sock,char* header）
{
	char server_path[255];
	char response[8192];
	extract_server_path(header,server_path);

	LOG("server path : %s \n",server_path);
	char info_buf[1024];
	get_info(info_buf);
}

/* get runtime information */
void get_info(char* output)
{
	int pos = 0;
	char line_buffer[512];
	sprintf(line_buffer,"========= mproxy (v0.1) ==========\n");
	int len = strlen(line_buffer);
	
	

void server_loop()
{
	struct sockaddr_in client_addr;
	socklen_t addrlen = sizeof(client_addr);
	while(1) {
		client_sock = accept(server_sock,(struct sockaddr*)&client_addr,&addrlen);

		if(fork() == 0) {
			close(server_sock);
			handle_client(client_sock,client_addr);
			exit(0);
		}
		close(client_sock);
	}
}
		
void start_server(int deamon)
{
	header_buffer = (char*) malloc(MAX_HEADER_SIZE);

	signal(SIGHLD,sigchld_handler);

	if((server_sock = create_server_socket(local_port)) < 0) {
		LOG("Cannot run server on %d\n",local_port);
		exit(server_sock);
	}

	if(deamon) {
		pid_t pid;
		if((pid = fork()) == 0) {
			server_loop();
		} else if( pid > 0) {
			m_pid = pid;
			LOG("mproxy pid is : [%d] \n",pid);
			close(server_sock);
		} else {
			LOG("Cannot daemonize\n");
			exit(pid);
		}
	} else {
		server_loop();
	}
   		
}

		
	

int main(int argc,char *argv[])
{
	return _main(argc,argv);
}

int _main(int argc,char *argv[])
{
	local_port = DEFAULT_LOCAL_PORT;
	io_flag = FLG_NONE;
	int deamon = 0;

	char info_buf[2048];

	int i;
	for( i = 1; i < argc; i++) {
		if(argv[i][0] == '-' ) {
			if(argv[i][1] == 'h') {
				char* s = argv[++i];
				if (s && s[0] != '-') {
					char* p = strchr(s,':');
					if(p) {
						strncpy(remote_host,s,p-s);
						remote_port = atoi(++p);
					} else {
						strncpy(remote_host,s,128);
					}
				} else {
					usage();
				}
			} else if (argv[i][1] == 'l') {
				char *s = argv[++i];
				if (s) {
					local_port = atoi(s);
				} else {
					usage();
				}
			} else if (argv[i][1] == 'd') {
				deamon = 1;
			} else if (argv[i][1] == 'D') {
				io_flag = R_C_DEC;
			} else if (argv[i][1] == 'E') {
				io_flag = W_S_ENC;
			} else {
				usage();
			}
		} else {
			usage();
		}
						
	}

	get_info(info_buf);
	LOG("%s\n",info_buf);
	start_server(deamon);
	return 0;
}
