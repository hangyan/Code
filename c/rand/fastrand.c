/*                                                                      
 *  File:   fastrand.c                                             
 *  Author: Hang Yan                                                       
 *  Email:  yanhangyhy@gmail.com                                      
 *  Date:   07 Feb 2014                                               
 *  Desc:   
 */ 

#include <stdio.h>
static unsigned int g_seed;


//Used to seed the generator.

inline void fast_srand( int seed )

{

    g_seed = seed;

}


//fastrand routine returns one integer, similar output value range as C lib.

inline int fastrand()

{

    g_seed = (214013*g_seed+2531011);

    return (g_seed>>16)&0x7FFF;

}



static unsigned long x=123456789, y=362436069, z=521288629;

unsigned long xorshf96(void) {          //period 2^96-1
    unsigned long t;
    x ^= x << 16;
    x ^= x >> 5;
    x ^= x << 1;

    t = x;
    x = y;
    y = z;
    z = t ^ x ^ y;

    return z;
}






int main(int argc,char* argv[])

{
    //printf("%d\n",fastrand(100));
    printf("%d\n",xorshf96());
}



