#include <pthread.h>
#include <stdio.h>
int main(int argc, char *argv[])
{
    printf("current thread is %d,%u\n",pthread_self(),pthread_self());
    
    return 0;
}
