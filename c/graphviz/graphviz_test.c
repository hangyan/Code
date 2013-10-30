/*
 * DESC: funtions to demonstrate the usage of graphviz
 * SETP: 
 *	1. gcc -g -finstrument-functions test.c /path/to/instrument.c -o test
 *	2. ./test (generate trace.txt)
 *	3. pvtrace test (generate graph.dot)
 *	4. dot -Tpng graph.dot -o graph.png 
 *
 * OTHERS:
 *	(1) generate functions calls for exists project
 *	    1. add instrument.c to the project
 *	    2. compile it 
 *	    3. change compile args: -g -finstrument-functions
 *	    4. change link args: add instrument.o
 *	    5. execute the program
 *	    6. pvtrace the execute file and trace.txt
 *	    7. use dot
 */


#include <stdio.h>
#include <stdlib.h>
 
void test1()
{
    printf("in test1.\n");
}
 
void test2()
{
    test1();
    printf("in test2.\n");
}
 
void test3()
{
    test1();
    test2();
     
    printf("in test3.\n");
}
 
int main(int argc, char *argv[])
{
    printf("Hello wolrd.\n");
     
    test1();
    test2();
    test3();
     
    return 0;
}
