#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void plus(int a,int b)
{
	int c = a + b;
	printf("the plus result = %d\n",c);
}

int main(int argc,char** argv)
{
	int a = 9;
	int b = 18;
	plus(a,b);

	return 0;
}
