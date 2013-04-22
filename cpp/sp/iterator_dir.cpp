#include <iostream>
#include <string>
#include <vector>
#include "sutils.h"



struct ff_proc
{
    bool operator() (const char * file_name) const
    {
        std::string name=sp::pathname_to_name(file_name);
       
        std::string suff=name.substr(name.length()-4);
        std::cout<<suff<<std::endl;
        
        if(0 == suff.compare(".txt"))
            return true;
        else
            return false;
    }
};

    
        

int main(int argc, char *argv[])
{
    using namespace sp;

    
    std::vector<std::string> list;
    
    
    if(0 != get_file_list<std::vector<std::string> >(argv[1],list,0,true,ff_proc()))
        std::cerr<<"Input Directory or file error!"<<std::endl;
    
    int size=list.size();
   
    
    for(int i=0;i<size;i++)
    {
        //std::cout<<list[i]<<std::endl;
        
        if(0 != std::remove(list[i].c_str()))
            std::cerr<<"Error deleting file "<<list[i]<<std::endl;
        else
            
            std::cout<<"delete file "<<list[i]<<std::endl;
    }
    
    return 0;
}
