#include <stdlib.h>
#define SIZE 1024
static int (**hnew())[2] {
    return calloc(sizeof(int**), SIZE);
}
static void hdel(int (**e)[2]) {
    for (int i = 0; i < SIZE; i++) free(e[i]); free(e);
}
static int (**hget(int (**t)[2], int k))[2] {
    for (int h = k & (SIZE - 1); **t && ***t != k; h = ((h + 1) & (SIZE - 1)), t += h);
    return t;
}
static void hset(int (**t)[2], int k, int v) {
    for (int (**a)[2] = hget(t, k); !*a && (*a=malloc(sizeof(**t))); (**a)[0]=k,(**a)[1]=v);
}

// TEST DRIVER
#include <stdio.h>
int main() {
    int (**table)[2] = hnew();

    hset(table, 10, 20);
    hset(table, 20, 30);
    hset(table, 30, 40);

    int (**a)[2] = hget(table, 10);
    int (**b)[2] = hget(table, 20);
    int (**c)[2] = hget(table, 30);

    printf("%d:%d\n", (**a)[0], (**a)[1]);
    printf("%d:%d\n", (**b)[0], (**b)[1]);
    printf("%d:%d\n", (**c)[0], (**c)[1]);

    hdel(table);
}

