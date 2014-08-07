/*
  Author : Hang Yan
  Date   : 2014-08-07
  Desc   : 互斥锁实现,Peterson算法
           算法使用两个控制变量flag与turn.
           其中flag[n]的值为真, 表示ID号为n的进程希望进入该临界区.
           标量turn保存有权访问共享资源的进程的ID号.
 */




#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
#include<time.h>
#include<stdint.h>


int flag[2];
int victim;
int sharedCounter=0;

void lock(int me)
{
    int other;
    other = 1-me;
    flag[me] = 1;
    victim = me;
    while(flag[other]==1 && victim == me)
    {
    }
}

void unlock(int me)
{
    flag[me] = 0;
}

void *peterson(void *ptr)
{
    int tId,i;
    tId = (int ) (intptr_t) ptr;
    for(i=0;i<200;i++)
    {
        lock(tId);
        sharedCounter++;
        printf("Thread [%d] : Counter [%d]\n",tId,sharedCounter);
        sleep(1);
        unlock(tId);
    }
}

int main()
{
    int i;
    for(i=0;i<2;i++)
    {
        flag[i] = 0;
    }
    pthread_t t[2];
    for(i=0;i<2;i++)
    {
        pthread_create(&t[i],NULL,peterson,(void *) (intptr_t) i);
    }

    for(i=0;i<2;i++)
    {
        pthread_join(t[i],NULL);
    }
    printf("shared Counter:%d\n",sharedCounter);
    return 0;
}




        
    
