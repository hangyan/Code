#include <iostream>
#include <thread>
#include <queue>
#include <ctime>
#include <cstdlib>
#include <mutex>
#include <unistd.h>

using  namespace std;

const int MAX_SIZE = 1000;

queue<int> origin_num_queue;
queue<int> result_num_queue;

mutex queue_mutex;



void produce()
{

    while(1)
    {
        sleep(1);
        
        queue_mutex.lock();
        
        if ( origin_num_queue.size() < MAX_SIZE )
        {
            origin_num_queue.push(rand()%1000);
        }
        
        if ( result_num_queue.size() > 0 )
        {
        
            cout<<"Get result:"<<result_num_queue.front()<<endl;
            result_num_queue.pop();
                    
        }
        queue_mutex.unlock();
        
    }    
        
}

void consume()
{
    int temp;
   
    
    while(1)
    {
        sleep(1);
        
        queue_mutex.lock();
        if ( origin_num_queue.size() > 0
             && result_num_queue.size() < MAX_SIZE )
        {
            temp = origin_num_queue.front();
            
            cout<<"Get origin num:"<<temp<<endl;
            origin_num_queue.pop();
            result_num_queue.push(temp*temp);
            
        }
        queue_mutex.unlock();
        
    }
    
}


    
int main(int argc, char *argv[])
{
    srand(time(NULL));

    thread tp(produce);
    thread tc(consume);
    tp.join();
    tc.join();
    

    
    
        
    return 0;
}

