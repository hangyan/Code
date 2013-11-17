#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <strings.h>
#include <signal.h>
#include <string.h>

#define SERV_PORT 9877
#define LISTENQ 3
#define MAXLINE 10

void str_echo (int sockfd);

void sig_child(int signo)
{
    pid_t pid;
    int stat;
    pid=wait(&stat);
    printf("child %d terminated\n",pid);
    exit(0);
    
}


int main(int argc, char *argv[])
{
    int listenfd,connfd;
    pid_t childpid;
    socklen_t clilen;
    struct sockaddr_in cliaddr,servaddr;
    if((listenfd=socket(AF_INET,SOCK_STREAM,0))==-1)
    {
        perror("Socket create error!");
        exit(1);
    }
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family=AF_INET;
    servaddr.sin_addr.s_addr=htonl(INADDR_ANY);
    servaddr.sin_port=htons(SERV_PORT);
    printf("%d",listenfd);
    
    if(bind(listenfd,(struct sockaddr*)&servaddr,sizeof(servaddr))
       ==-1)
    {
        perror("Bind Error!");
        exit(1);
    }
    
    if(listen(listenfd,LISTENQ)==-1)
    {
        perror("Listen error!");
        exit(1);
    }

    signal(SIGCHLD,sig_child);
    
    for(;;)
    {
        clilen=sizeof(cliaddr);
        if((connfd=accept(listenfd,(struct sockaddr*)&cliaddr,&clilen))
           ==-1)
        {
            perror("Accept error!");
            exit(1);
        }
        if((childpid=fork())==0)
        {
            close(listenfd);
            str_echo(connfd);
            exit(0);
        }
        close(connfd);
    }
    
    return 0;
}

void str_echo(int sockfd)
{
    long arg1,arg2;
    
    ssize_t n;
    char line[MAXLINE];
    for(;;)
    {
       
        
        if((n=read(sockfd,line,MAXLINE))==0)
            return;
        printf("Receive from cli %d\n",n);
        if(sscanf(line,"%ld%ld",&arg1,&arg2)==2)
            snprintf(line,sizeof(line),"%ld\n",arg1+arg2);
        else
            snprintf(line,sizeof(line),"input error\n");
        
        n=strlen(line);
        n=write(sockfd,line,n);
        printf("Write back to cli %d\n",n);
        
    }
}
