#include "sutils.h"
#include <iostream>
#include <string>
#include <vector>
#include <openssl/md5.h>
#include <pthread.h>

const int DEFAULT_THREAD_NUM = 10;

unsigned char result[MD5_DIGEST_LENGTH];

#define FILE_PROCESS_ERROR  11
#define THREAD_CREATE_FAILE 12

struct Arg
{
    std::vector<std::string> file_names;    
};



void print_md5_sum(unsigned char* md)
{
    int i;
    
    for( i = 0; i < MD5_DIGEST_LENGTH; ++i )
    {
        printf( "%02x", md[i] );
    }
    std::cerr<<std::endl;
}


void* file_name_hash(void* arg)
{
    Arg* names_struct = (Arg*)arg;
    std::vector<std::string>  names = names_struct->file_names;
    
    unsigned char md5_result[MD5_DIGEST_LENGTH];
    for( auto it = names.begin(); it != names.end(); ++it)
    {
        MD5((unsigned char*)it->c_str(),it->length(),md5_result);
        std::cout<<(*it)<<std::endl;
        print_md5_sum(md5_result);
    }
    return NULL;
}



int main(int argc, char *argv[])
{
        
    std::vector<std::string> list;
    
    if(0 != sp::get_file_list<std::vector<std::string> >(argv[1],list,0,true))
    {
        std::cerr<<"Input Directory or file error!"<<std::endl;
        return FILE_PROCESS_ERROR;
    }
    
    
    int size = list.size();
    
    
    if( size < DEFAULT_THREAD_NUM )
    {
        for(auto it = list.begin(); it != list.end(); ++it)
        {
            (*it) = sp::pathname_to_name(it->c_str());
            std::cout<<(*it)<<"\t";
            
            MD5((unsigned char*)it->c_str(),it->length(),result);
            print_md5_sum(result);
            
        }
    }
    
    else
    {
        
        pthread_t threads[DEFAULT_THREAD_NUM];
        std::vector<std::string> values[DEFAULT_THREAD_NUM];
        
        int factor = size/DEFAULT_THREAD_NUM;
        int i,ret;
        
        std::string file_name;
        
        for( i = 0 ; i < size ; i++)
        {
            if( i/factor > DEFAULT_THREAD_NUM)
            {
                values[DEFAULT_THREAD_NUM].push_back(list[i]);
                continue;
            }
            file_name = sp::pathname_to_name(list[i].c_str());
            
            values[i/factor].push_back(file_name);
                     
        }

        for( i = 0; i < DEFAULT_THREAD_NUM; i++)
        {
            Arg new_arg = { values[i] } ;
            
            
            ret = pthread_create( &threads[i],NULL,file_name_hash,&new_arg);
            if( 0 != ret)
            {
                std::cout<<"Thread "<<i<<" create failed!"<<std::endl;
                return THREAD_CREATE_FAILE;
            }
            std::cout<<"Thread "<<i<<" start!"<<std::endl;
                    
        }

        for( i = 0; i < DEFAULT_THREAD_NUM; ++i)
        {
            pthread_join( threads[i], NULL );
        }
        
        
    }
    
    
    return 0;
}







