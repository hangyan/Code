#include <iostream>
using namespace std;

template <typename T,  int  MAX>
class CQueue
{
    T a[MAX];
    int front;
    int end;
    int max_size;
    bool is_full;
    
    
public:
    CQueue();
    T del();
    void insert(T);
    void display();
    int capacity()
    {
        return max_size;
        
    }
    
    int length()
    {
        if ( is_full = true )
            return capacity();
        if ( front <= end )
            return end-front;
        else
            return capacity() - ( front - end );
        
    }
    
    
};


template <typename T,int MAX>
CQueue<T,MAX>::CQueue()
{
    front = end = 0;
    
    is_full = false;
    
    max_size = MAX;
}


template <typename T,  int MAX>
void CQueue<T,MAX>::insert(T val)
{
    if ( is_full == true )
        cout<<"Circular Queue is Full"<<endl;
    else
    {
        a[end] = val;   
        if ( end == MAX-1 )
            end = 0;
        else
            end++;
    }
    
    if ( front == end )
        is_full = true;
            
}


template <typename T,   int MAX>
T CQueue<T,MAX> ::del()
{
    T ret;
    
    if ( front == end && is_full == false )
        cout<<"Circular Queue is Empty"<<endl;
        
    else
    {
        ret = a[front];
       
        if ( front == MAX-1 )
            front = 0;
        else
            front++;
        is_full = false;
        
    }
    return ret;
    
}


template <typename T,  int MAX>

void CQueue<T,MAX>::display()
{
    int i;
    if ( front == end && is_full == false )
        cout<<"Circule Queue is Empty!"<<endl;
    else
    {
        if ( end < front)
        {
            for ( i = front; i <= MAX-1; ++i)
                cout<<a[i]<<" ";
            for( i = 0; i < end; i++)
                cout<<a[i]<<" ";
        }
        else
        {
            for ( i = front ; i <  end; ++i)
                cout<<a[i]<<" ";
        }
        cout<<endl;
    }
}





    
int main(int argc, char *argv[])
{

   

    
    CQueue<int,10> cq;
    cq.insert(10);
    cq.insert(5);
    cq.insert(8);
    cq.insert(100);
    cq.display();
    
    cq.del();
    
    cq.display();
    
    return 0;
}
