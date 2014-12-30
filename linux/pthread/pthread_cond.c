/*                                                                      
 *  File:   pthread_cond.c                                             
 *  Author: Hang Yan                                                       
 *  Email:  yanhangyhy@gmail.com                                      
 *  Date:   07 Dec 2013                                               
 *  Desc:   demonstrate pthread_cond usage
 */ 

#include <stdio.h>

#include <pthread.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_cond_t cond;

int val = 0;

void* thread_zero_run(void* arg) {
    while(1) {
        pthread_mutex_lock(&mutex);

        while( val <= 2 ) {
            printf("thread_zero_run --> val:%d,wait for wake up\n",val);
            pthread_cond_wait(&cond,&mutex);
        }

        printf("thread_zero_run --> val:%d,zero it and unlock\n",val);
        val = 0;
        pthread_mutex_unlock(&mutex);
    }

    pthread_exit((void*)0);
}

void* thread_add_run(void* arg) {
    while(1) {
        pthread_mutex_lock(&mutex);
        ++val;
        pthread_mutex_unlock(&mutex);
        pthread_cond_signal(&cond);

        printf("after add val:%d and wake up one zero thread for check\n",
               val);
        sleep(1);
    }
    pthread_exit((void*)0);
}

int main(int argc,char* argv[]) {

    pthread_t t_add,t_zero;
    pthread_cond_init(&cond,NULL);

    if(pthread_create(&t_add,NULL,thread_add_run,NULL)) {
        return 0;
    }

    if(pthread_create(&t_zero,NULL,thread_zero_run,NULL)) {
        return 0;
    }

    pthread_join(t_add,NULL);
    pthread_join(t_zero,NULL);

    return 0;
}



