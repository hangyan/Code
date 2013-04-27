#include <stdio.h>
#include <mysql.h>
#include "common.h"

void print_error(MYSQL* conn,char* message)
{
    fprintf(stderr,"%s\n",message);
    if(conn!=NULL)
    {
        fprintf(stderr,"Error %u (%s)\n",
                mysql_errno(conn),mysql_error(conn));
    }
}

MYSQL* do_connect(char* host_name,char* user_name,
                  char* password,char* db_name,
                  unsigned int port_num,char* socket_name,
                  unsigned int flags)
{
    MYSQL* conn;
    conn=mysql_init(NULL);
    if(NULL==conn)
    {
        print_error(conn,"mysql_init() failed\n");
        return (NULL);
    }
#if defined(MYSQL_VERSION_ID)&&MYSQL_VERSION_ID>=3200 /*3.22 and up*/
    if(mysql_real_connect(conn,host_name,user_name,password,
                          db_name,port_num,socket_name,flags)
       ==NULL)
    {
        print_error(conn,"mysql_real_connect() failed\n");
        return(NULL);
    }
#else  /*pre-3.22*/
    if(mysql_real_connect(conn,host_name,user_name,password,
                          port_num,socket_name,flags)
       ==NULL)
    {
        print_error(conn,"mysql_real_connect() failed\n");
        return(NULL);
    }
    if(db_name!=NULL)
    {
        if(mysql_select_db(conn,db_name)!=0)
        {
            print_error(conn,"mysql_select_db() failed\n");
            mysql_close(conn);
            return(NULL);
        }
    }
    #endif
    return(conn);
}

                
void do_disconnect(MYSQL* conn)
{
    mysql_close(conn);
}

