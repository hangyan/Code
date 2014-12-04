#include <stdio.h>

int hanming_int(int a, int b)
{
	int dist = 0;
	int val = a ^ b;

	while(val) {
		++dist;
		val &= val - 1;
	}
	return dist;
}


int hanming(char* a, char* b)
{
	int dist = 0;

	while (*a && *b) {
		dist += (*a != *b) ? 1 : 0;
		a++;
		b++;
	}

	return dist;
}

int main()
{
	char* a = "hhee";
	char* b = "hehe";
	printf("%d\n",hanming(a,b));
	printf("%d\n",hanming_int(10,11));
	return 0;
}


