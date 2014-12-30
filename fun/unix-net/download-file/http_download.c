#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <net/if.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAX_FILENAME_LENGTH 256
#define PATH_LENGTH 256
#define URL_LENGTH 256
#define BUFFER_SIZE 10*1024
#define MAX_RECV_SIZE 1440

//to print some debug information
#define HTTP_DEBUG 1

#ifdef HTTP_DEBUG
#  define D(x) x
#else
#  define D(x) 
#endif

char server_ip[URL_LENGTH+1];
char server_port[10];
char server_host[URL_LENGTH+1];
char buf_send[BUFFER_SIZE];
char buf_recv[BUFFER_SIZE];


int socket_connect(char* ip,char* port); 
int socket_send(int sockfd,char* send_buf,int len,int flags); 
int socket_receive(int sockfd,char* recv_buf,int len,int flags);
int http_get_ip_port(char* url,char* ip,char* port);
int http_get_file_name(char* url,char* file_name);
int http_get_file_path(char* url,char* path);
int head_to_get_file_size(char* url);
int http_get_content_length(char* recv_buf);
int http_get_file_size(int sockfd,char* path);
void head_to_get_file(char* path,char* range);
int http_get_file(int sockfd,char* path,int file_length,char* file_buf);

int http_download_file(char* url,char* save_path);





int socket_connect(char* ip,char* port)
{
    struct sockaddr_in addr;
    int sockfd;
    int len,result;
    
    len = sizeof(addr);
    if((sockfd = socket(AF_INET,SOCK_STREAM,0)) == -1)
    {
        perror("ERROR:Client socket create fail!\n");
        exit(EXIT_FAILURE);
    }

    //domain name ---> ip
    struct hostent* host;
    host = gethostbyname(ip);
    if ( host == NULL )
    {
        fprintf(stderr,"ERROR:failed to  get host ip\n");
        exit(EXIT_FAILURE);
        
    }
 
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr =
        inet_addr( (char*)inet_ntoa(*(struct in_addr*)(host->h_addr)) );
    addr.sin_port = htons(atoi(port));
    
    if( (result = connect(sockfd,(struct sockaddr*)&addr,len)) == -1)
    {
        perror("ERROR:connect failed!\n");
        exit(EXIT_FAILURE);
    }

    return sockfd;
        
}

int socket_send(int sockfd,char* send_buf,int len,int flags)
{
    int send_len = 0;
    int ret = -1;
    while ( send_len < len )
    {
        ret = send (sockfd,send_buf+send_len,len-send_len,flags);
        if ( -1 == ret )
        {
            perror ("ERROR:socket send data failed.\n");
            exit(EXIT_FAILURE);
        }
        else
            send_len += ret;
    }
    return 0;
}


int socket_recv(int sockfd,char* recv_buf,int len,int flags)
{
    int recv_len;
    if ((recv_len = recv(sockfd,recv_buf,len,flags)) < 0 )
    {
        perror("ERROR:socket receive data failed!\n");
        exit(EXIT_FAILURE);
    }

    return recv_len;
}



/*
  func:get ip and port from an url.
  ret: -1 error
        1 domain_name
        2 ip-port
 */
int http_get_ip_port(char* url,char* ip,char* port)
{
    char* p = NULL;
    int offset = 0;
    char domain_name[URL_LENGTH];

    p = strstr(url,"http://");
    if ( p == NULL )
        offset = 0;
    else
        offset = strlen("http://");
    p = strstr(url+offset,"/");
    if ( p == NULL )
    {
        printf ("ERROR: url \"%s\" format error\n",url);
        return -1;
    }
    else
    {
        memset(domain_name,0,sizeof(domain_name));
        memcpy(domain_name,url+offset,(p-url-offset));
        p = strstr(domain_name,":");
        if ( p == NULL )
        {
            strcpy(ip,domain_name);
            strcpy(port, "80");

            return 1;
            
        }
        else
        {
            strcpy(ip,domain_name);
            strcpy(port,p+1);
            return 2;
        }
    }
    
}


int http_get_file_name(char* url,char* file_name)
{
    int len;
    int i;
    len = strlen(url);
    for( i = len-1; i>0; i-- )
    {
        if(url[i] == '/')
            break;
    }
    
    if ( i == 0 )
    {
        printf("ERROR: url format error");
        return -1;
    }
    else
    {
        strcpy(file_name,url+i+1);
        

        D(printf("file name:\t%s\n",file_name));
        return 0;
    }
}

        
int http_get_file_path(char* url,char* path)
{
    char *p;
    p = strstr(url,"http://");
    if ( p == NULL )
    {
        p = strstr(url,"/");
        if ( p == NULL )
            return -1;
        else
        {
            strcpy(path,p);
            return 0;
        }
    }
    else
    {
        p = strstr(url+strlen("http://"),"/");
        if ( p == NULL )
            return -1;
        else
        {
            strcpy(path,p);
            return 0;
        }
    }
    
}

int head_to_get_file_size(char* url)
{
    memset(buf_send,0,sizeof(buf_send));
    sprintf(buf_send,"HEAD %s",url);

    // space at begining
    strcat(buf_send," HTTP/1.1\r\n");
    strcat(buf_send,"Host: ");
    strcat(buf_send,server_host);
    strcat(buf_send,"\r\nConnection: Keep-Alive\r\n\r\n");
    return 0;
}

int http_get_content_length(char* recv_buf)
{
    char *p1 = NULL;
    char *p2 = NULL;
    int http_body_len = 0;
    p1 = strstr(recv_buf,"Content-Length");
    if( p1 == NULL )
        return -1;
    else
    {
        p2 = p1 + strlen("Content-Length") + 2;
        //atoi will stop the convent when it find other non numbercharacters.
        http_body_len = atoi(p2);
        return http_body_len;
    }
}


int http_get_file_size(int sockfd,char* path)
{
    int ret = -1;
    char buf_recv_temp[BUFFER_SIZE+1];
    head_to_get_file_size(path);

    #ifdef HTTP_DEBUG
    printf("\nsend : \n%s \n",buf_send);
    #endif

    socket_send(sockfd,buf_send,strlen(buf_send),0);
    memset(buf_recv_temp,0,sizeof(buf_recv_temp));
    ret = socket_recv(sockfd, buf_recv_temp, sizeof(buf_recv_temp)-1, 0);

    
    D(printf("recv len = %d\n",ret));
    D(printf("recv = %s\n",buf_recv_temp));
    

    if( ret <= 0 )
    {
        perror("ERROR: failed to get file size");
        return -1;
    }

    ret = http_get_content_length(buf_recv_temp);
    if( ret <= 0 )
        return -1;
    else
        return ret;
    
}

void head_to_get_file(char* path,char* range)
{
    char buf[64];
    memset(buf_send,0,sizeof(buf_send));
    sprintf(buf_send,"GET %s",path);
    strcat(buf_send," HTTP/1.1\r\n");
    strcat(buf_send,"Host: ");
    strcat(buf_send,server_host);
    sprintf(buf,"\r\nRange: bytes=%s",range);
    strcat(buf_send,buf);
    strcat(buf_send,"\r\nKeep-Alive: 200");
    strcat(buf_send,"\r\nConnection: Keep-Alive\r\n\r\n");
}

int http_get_res_length(char* recv_buf)
{
    char* p = NULL;
    int http_body_len = 0;
    int http_head_len = 0;
    http_body_len = http_get_content_length(recv_buf);
    if ( http_body_len == -1 )
        return -1;
    p = strstr(recv_buf,"\r\n\r\n");
    if ( p == NULL )
        return -1;
    else
    {
        //check
        http_head_len = p-recv_buf+4;
        
        return http_body_len + http_head_len;
    }
}

        
int http_recv(int sockfd,char* buf_recv)
{
    int ret;
    int recv_len = 0;
    int download_len = 0;
    char buf_recv_temp[BUFFER_SIZE];
    int j = 0;
    
    memset(buf_recv_temp,0,sizeof(buf_recv_temp));
    while(1)
    {
        ret = socket_recv(sockfd,buf_recv_temp+recv_len,
                        sizeof(buf_recv_temp)-1,0);
        if ( ret <= 0 )
        {
            perror("ERROR:recvive file fail");
            return ret;
        }
        
        if ( recv_len == 0 )
        {

            D(printf("recvive length = %d\n",ret));
            D(printf("\nrecvive : \n%s \n\n",buf_recv_temp));


            download_len = http_get_res_length(buf_recv_temp);


            D(printf("download length = %d\n",download_len));

        }

        recv_len += ret;

        
        D(printf("total receive length = %d\n",recv_len));
        

        if ( download_len == recv_len )
            break;
    }

    memcpy(buf_recv,buf_recv_temp,download_len);
    return recv_len;
}


           
        
        
int http_get_file(int sockfd,char* path,int file_length,char* file_buf)
{
    int i,j,count;
    char range[64];
    int ret = 0;
    char* p = NULL;
    
    
    count = (file_length % MAX_RECV_SIZE) ?
        ( file_length / MAX_RECV_SIZE +1 ) : (file_length / MAX_RECV_SIZE);

    D(printf("File Size:%d Seg Count:%d\n",file_length,count));
    
    for ( i = 0; i < count; ++i )
    {
        
        D(printf("-------------Seg:%d\n",i));
        
        if( (i == (count-1)) && ( file_length % MAX_RECV_SIZE ) )
            sprintf(range,"%d-%d",i*MAX_RECV_SIZE,file_length-1);
        else
            sprintf(range,"%d-%d",i*MAX_RECV_SIZE,(i+1)*MAX_RECV_SIZE-1);

        head_to_get_file(path,range);

        D(printf("send : \n%s",buf_send));


        socket_send(sockfd,buf_send,strlen(buf_send),0);
        memset(buf_recv,0,sizeof(buf_recv));
        ret = http_recv(sockfd,buf_recv);
        if ( ret < 0 )
            break;

        //disconnect
        if ( ret == 0 )
        {
        }

        p = strstr(buf_recv,"\r\n\r\n");
        if ( p == NULL )
        {
            printf("ERROR: recv_buf not contain end flag!");
            break;
        }
        else
        {
            memcpy(file_buf+j*MAX_RECV_SIZE,p+4,MAX_RECV_SIZE);
            j++;
        }
    }

    if( i == count )
        return file_length;
    else
        return -1;
    
}


int save_file(char* file_buf,int file_length,char* filename)
{
    int fd;
    if ( (fd=open(filename,O_WRONLY|O_CREAT|O_APPEND,
                  S_IRUSR|S_IWUSR)) == -1 )
    {
        fprintf(stderr,"open %s error:%s\n",filename,
                strerror(errno));
        exit(EXIT_FAILURE);
    }

    if ( write(fd,file_buf,file_length) != file_length )
    {
        perror("ERROR:write to file failed!");
        exit(EXIT_FAILURE);
    }
    close(fd);
    return 0;
}

    
int http_download_file(char* url,char* save_path)
{
    int ret;
    int sockfd;
    int file_size;
    
    char file_name[MAX_FILENAME_LENGTH+1];
    char* file_buf;
    char save_file_path[MAX_FILENAME_LENGTH+1];
    char path[PATH_LENGTH+1];

    ret = http_get_ip_port(url,server_ip,server_port);
    if(ret == -1)
        return -1;
    else
        sprintf(server_host,"%s:%s",server_ip,server_port);


    D(printf("server host:\t%s\n",server_host));
    
    
    ret = http_get_file_name(url,file_name);
    if ( ret == -1 )
        return -1;
    
    ret = http_get_file_path(url,path);
    if ( ret == -1 )
        return -1;

    D(printf("request path:\t%s\n",path));


    sockfd = socket_connect(server_ip, server_port);
    
    file_size = http_get_file_size(sockfd,path);
    if ( file_size == -1 )
        return -1; 

    D(printf("http get file size:%d\n",file_size));
    
    file_buf = (char*) malloc (file_size*sizeof(char)*2);
    if(file_buf == NULL )
    {
        perror("ERROR:malloc file buffer failed");
        return -1;
    }
    else
        memset(file_buf,0,file_size*2);
    
    ret = http_get_file(sockfd,path,file_size,file_buf);
    
    close(sockfd);

    if ( ret < 0 )
    {
        free(file_buf);
        return -1;    
    }

    else
    {
        sprintf(save_file_path,"%s",file_name);
        save_file(file_buf,ret,save_file_path);
        free(file_buf);
    }
    
             
}


int main(int argc, char *argv[])
{
    if(argc != 2)
    {
        fprintf(stderr,"Please specify a url!\n");
        exit(EXIT_FAILURE);
    }

    http_download_file(argv[1],NULL);
    
    return 0;
}
