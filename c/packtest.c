#include <stdio.h>
#include <stdbool.h>

struct foo1 {
    char *p;
    char c;
    long x;
};

struct foo2 {
    char c;      /* 1 byte */
    char pad[7]; /* 7 bytes */
    char *p;     /* 8 bytes */
    long x;      /* 8 bytes */
};

struct foo3 {
    char *p;     /* 8 bytes */
    char c;      /* 1 byte */
};

struct foo4 {
    short s;     /* 2 bytes */
    char c;      /* 1 byte */
};

struct foo5 { 
    short s;
    char c;
    int flip:1;
    int nybble:4;
    int septet:7;
};

struct foo6 {
    char c;
    struct foo6_inner {
        char *p;
        short x;
    } inner;
};

struct foo7 {
    char c;
    struct foo7 *p;
    short x;
};

struct foo8 {
    struct foo8 *p;
    short x;
    char c;
};

struct foo9 {
    struct foo7_inner {
        char *p;
        short x;
    } inner;
    char c;
};

main(int argc, char *argv)
{
    printf("sizeof(char *)        = %zu\n", sizeof(char *));
    printf("sizeof(long)          = %zu\n", sizeof(long));
    printf("sizeof(int)           = %zu\n", sizeof(int));
    printf("sizeof(short)         = %zu\n", sizeof(short));
    printf("sizeof(char)          = %zu\n", sizeof(char));
    printf("sizeof(float)         = %zu\n", sizeof(float));
    printf("sizeof(double)        = %zu\n", sizeof(double));
    printf("sizeof(struct foo1)   = %zu\n", sizeof(struct foo1));
    printf("sizeof(struct foo2)   = %zu\n", sizeof(struct foo2));
    printf("sizeof(struct foo3)   = %zu\n", sizeof(struct foo3));
    printf("sizeof(struct foo4)   = %zu\n", sizeof(struct foo4));
    printf("sizeof(struct foo5)   = %zu\n", sizeof(struct foo5));
    printf("sizeof(struct foo6)   = %zu\n", sizeof(struct foo6));
    printf("sizeof(struct foo7)   = %zu\n", sizeof(struct foo7));
    printf("sizeof(struct foo8)   = %zu\n", sizeof(struct foo8));
    printf("sizeof(struct foo9)   = %zu\n", sizeof(struct foo9));
} 
