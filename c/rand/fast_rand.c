/*                                                                      
 *  File:   fast_rand.c                                             
 *  Author: Hang Yan                                                       
 *  Email:  yanhangyhy@gmail.com                                      
 *  Date:   07 Feb 2014                                               
 *  Desc:   
 */ 

#include <stdio.h>

typedef int u32;

#define RAND_CONST      33614

unsigned int random_val = 1234;

unsigned int _fastrand(u32 value)
{
    unsigned int result;
    
    __asm__ ("mull %%ebx\n\t"
             "addl %%edx, %%eax"
             :"=a"(result)
             :"a"(value), "b"(RAND_CONST)
        );
    
    return result;
    
}

unsigned int fastrand(u32 range)
{
    random_val = _fastrand(random_val);
    
    return random_val % range;
}





int main(int argc,char* argv[])
{
    //printf("%d\n",fastrand(100));
    printf("%d\n",(*(char*)(1000000000)));
    
}



