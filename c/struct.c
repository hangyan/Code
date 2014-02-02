/* Last modified Time-stamp: <Ye Wenbin 2007-12-30 16:29:58>
 * @(#)struct.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct foo1 {  
    char *p;  
    char c;  
    long x;  
};

struct foo7 {
    struct foo7 *p;
    short x;
    char c;
    char d;
};  



int main(int argc, char *argv[])
{

    printf("[foo1]:%d\n",sizeof(struct foo1));
    printf("[foo7]:%d\n",sizeof(struct foo7));
    
    return 0;
}
