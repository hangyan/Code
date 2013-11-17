#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char *argv[])
{
    while(1)
    {
        printf("请输入域名:");
        char strURL[255];
        gets(strURL);
        /*
         struct hostent
        char* h_name 地址的正式名称
        char** h_aliases 地址的预备名称的指针
        int h_addtype 地址类型.通常为AF_INET
        int h_length 地址的比特长度
        char** h_addr_list主机网络地址指针，网络字节序
        h_addr->h_addr_list中的第一地址*/
        struct hostent *h=NULL;
        h=gethostbyname(strURL);
        if(h==NULL)
            return -1;
        //sturct in_addr->unsigned long s_addr;
        //h_addr_list是4字节网络字节序的in_addr，只是使用char*来表示

        
        /*不转换时输出乱码
          printf("\nIP Adress:%s\n",
           h->h_addr);*/
        
        printf("\n[%s]的IP地址是:[%s]\n",
              strURL,inet_ntoa(*((struct in_addr*)h->h_addr)));
    }
    
    return 0;
}
