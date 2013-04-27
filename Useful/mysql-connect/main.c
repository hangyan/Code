#include <stdio.h>
#include <stdlib.h>
#include <mysql.h>
#include "common.h"
#include <getopt.h>

#define def_host_name NULL
#define def_user_name NULL
#define def_password NULL
#define def_port_num NULL
#define def_socket_name NULL
#define def_db_name NULL


char* groups[]={"client",NULL};

struct option long_options[]=
    {
        {"host",required_argument,NULL,'h'},
        {"user",required_argument,NULL,'u'},
        {"password",optional_argument,NULL,'p'},
        {"port",required_argument,NULL,'P'},
        {"socket",required_argument,NULL,'S'},
        {0,0,0,0}
    };

MYSQL *conn;

        
int main(int argc, char *argv[])
{
    char* host_name=def_host_name;
    char* user_name=def_user_name;
    char* password=def_password;
    unsigned int port_num=def_port_num;
    char* socket_name=def_socket_name;
    char* db_name=def_db_name;
    
    char passbuf[100];
    int ask_password=0;

    int i;
    int c,option_index=0;
    
    my_init();
    
    while((c=getopt_long(argc,argv,"h:p::u:P:S:",long_options,
                      &option_index))!=EOF)
    {
        switch(c)
        {
        case 'h':
            host_name=optarg;
            break;
        case 'u':
            user_name=optarg;
            break;
        case 'p':
            if(!optarg)
                ask_password=1;
            else
            {
                (void)strncpy(passbuf,optarg,sizeof(passbuf)-1);
                passbuf[sizeof(passbuf)-1]='\0';
                password=passbuf;
                while(*optarg)
                    *optarg++=' ';    
            }
            break;
        case 'P':
            port_num=(unsigned int)atoi(optarg);
            break;
        case 'S':
            socket_name=optarg;
            break;
        }
    }

    argc-=optind;
    argv+=optind;
    if(argc>0)
    {
        db_name=argv[0];
        --argc;
        ++argv;
    }
    if(ask_password)
        password=get_tty_password(NULL);
    
    
    conn=do_connect(host_name,user_name,password,db_name,
                    port_num,socket_name,0);
    
    if(conn=NULL)
        exit(1);

    do_disconnect(conn);
    
    return 0;
}
