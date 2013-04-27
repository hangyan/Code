#include <iostream>
#include <fstream>
#include <map>:
#include <string>

using namespace std;

void word_trip(string& word,char c)
{
    unsigned found = word.find(c);
    while( found != string::npos )
    {
        word.erase(found,1);
        found = word.find(c);
    }
    
}

const char TRIP_CHARS[]={'\n','\t','.','"',','};

int main(int argc, char *argv[])
{
    
    ifstream input_file;
    input_file.open("sample",istream::in);
    string word;

    map<string,int> kvs;

    map<string,int>::iterator it;
    
    while(std::getline(input_file,word,' '))
    {
        if( word.empty() )
            continue;
        int i;
        
        for (const char& c : TRIP_CHARS)
              word_trip(word,c);
        
            
        it = kvs.find(word);
        
        if(kvs.end() == it)
        {
            kvs.insert(pair<string,int>(word,1));
        }
        else
        {
            kvs[word]++;
        }
        
            
    }

    multimap<int,string> mt_kvs;
    
    for( auto kv : kvs )
        mt_kvs.insert(pair<int,string>(kv.second,kv.first));
   
    for( auto pair : mt_kvs)
        cout<<pair.first<<'\t'<<pair.second<<endl;
    
   
    input_file.close();
    
    return 0;
}
