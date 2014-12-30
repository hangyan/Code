#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <strings.h>
#include <arpa/inet.h>
#include <string.h>

#define SERV_PORT 9877
#define MAXLINE 10
    

void str_cli(FILE* fp,int sockfd);

int main(int argc, char *argv[])
{
    int sockfd;
    struct sockaddr_in servaddr;
    
    if(argc!=2)
    {
        fprintf(stderr,"Need Ip Adress!\n");
        exit(1);
    }
    
    if((sockfd=socket(AF_INET,SOCK_STREAM,0))==-1)
    {
        perror("Client Socket create error!");
        exit(1);
    }
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family=AF_INET;
    servaddr.sin_port=htons(SERV_PORT);

    inet_pton(AF_INET,argv[1],&servaddr.sin_addr);
    if(connect(sockfd,(struct sockaddr*)&servaddr,sizeof(servaddr))==-1)
    {
        perror("Client Connect Error!\n");
        exit(1);
    }
    str_cli(stdin,sockfd);
    return 0;
}

void str_cli(FILE* fp,int sockfd)
{
    
    char sendline[MAXLINE];
    char recvline[MAXLINE];
    int nw;
    int nr;
    
    while(fgets(sendline,MAXLINE,fp)!=NULL)
    {
        nw=write(sockfd,sendline,strlen(sendline));
        printf("Cli Send %d\n",nw);
        
        if((nr=read(sockfd,recvline,MAXLINE))==-1)
        {
            fprintf(stderr,"Server terminated prematurely!\n");
            exit(1);
        }
        printf("Recevive from serv %d\n",nr);
        
        fputs(recvline,stdout); 
    }
}

