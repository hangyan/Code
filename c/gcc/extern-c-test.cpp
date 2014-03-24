#include <iostream>
using namespace std;

int func1(int);

extern "C" 
{
    int func2(int);
    
}


int main(int argc, char *argv[])
{
    
    return 0;
}


int func1(int a) 
{
    return 1;
}

int func2(int b)
{
    return 2;
}
