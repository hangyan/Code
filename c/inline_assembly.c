#include <stdio.h>
int main(int argc, char *argv[])
{
    int foo = 10, bar = 15;

    //add two numbers
    __asm__ __volatile__ ("addl %%ebx,%%eax"
                          :"=a" (foo)
                          : "a" (foo),"b"(bar)
                          );
    printf("foo+bar=%d\n",foo);
    

    //atomic addition
    // no clobber-list
    int my_int = 1;
    int my_var = 0;
    
    __asm__ __volatile__ (
                          " lock ;\n"
                          " addl %1,%0 ;\n"
                          : "=m" (my_var)
                          : "ir" (my_int), "m" (my_var)
                          :
                          );
    printf("%d\n",my_var);

    //decrement my_var by 1 and if it is 0,set cond
    //memory is in the clobber list 
    __asm__ __volatile__ ( "decl %0; sete %1"
                           : "=m" (my_var), "=q" (cond)
                           : "m" (my_var)
                           : "memory"
                           );
    

    // the bit at the position 'pos' of variable at ADDR
    // is set to 1
    __asm__ __volatile__ ( "btsl %1,%0"
                           : "=m" (ADDR)
                           : "Ir" (pos)
                           : "cc"
                           );
    return 0;
    
}

/*
  string copy
  source address :esi
  destinaton :edi
  
 */
static inline char* strcpy(char* dest,const char* src)
{
    int d0,d1,d2;
    __asm__ __volatile__ ( "1:\tlodsb\n\t"
                           "stosb\n\t"
                           "testb %%al,%%al\n\t"
                           "jne 1b"
                           : "=&S", "=&D" (d1), "=&a" (d2)
                           : "0" (src), "1" (dest)
                           : "memory");
    return dest;
    
}
