#ifndef COMMON_H
#define COMMON_H

void print_error(MYSQL*,char*);

MYSQL* do_connect(char* host_name,char* user_name,char* password,
                  char* db_name,unsigned int port_num,
                  char* socket_name,unsigned int flags);
void do_disconnect(MYSQL* conn);

#endif
