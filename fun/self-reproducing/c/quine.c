#include <stdio.h>

char * f = "char*f=%c%s%c,q='%c',n='%cn',b='%c%c';%cmain(){printf(f,q,f,q,q,b,b,b,n,n);}%c",
  q = '"',
  n = '\n',
  b = '\\';

int main(int argc, char *argv[])
{
  printf(f,q,f,q,q,b,b,b,n,n);
  return 0;
}



