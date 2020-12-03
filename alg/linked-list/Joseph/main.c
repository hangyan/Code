// 算法科普：什么是约瑟夫环 https://www.cxyxiaowu.com/1159.html

#include <stdio.h>
#include <stdlib.h>

typedef struct node {
    int number;
    struct node *next;
} Node;

Node* CreateNode(int x) {
    Node *p;
    p = (Node*)malloc(sizeof(Node));
    p -> number = x;
    p -> next = NULL;
    return p;
}

Node* CreateJoseph(int n)
{
    Node *head, *p, *q;
    int i;
    for (i =1; i <=n ; i++) {
        p = CreateNode(i);
        if (i ==1)
            head =p;
        else
            q-> next = p;
            q = p;
    }
    q -> next = head;
    return head;
}

void RunJoseph(int n, int m) {
    Node *p, *q;
    p = CreateJoseph(n);
    int i;
    while(p ->next != p)
    {
        for(i=1; i<m-1; i++)
        {
            p = p->next;
        }
        q = p -> next;
        p -> next = q-> next;
        p = p->next;
        printf("%d--", q->number);
        free(q);
    }
    printf("最后剩下的： %dn", p->number);
}

int main()
{
    int n,m;
    scanf("%d %d",&n,&m);
    RunJoseph(n,m);
    return 0;
}