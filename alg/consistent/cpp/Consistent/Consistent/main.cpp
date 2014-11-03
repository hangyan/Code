//
//  main.cpp
//  Consistent
//
//  Created by Hang Yan on 11/3/14.
//  Copyright (c) 2014 Hang Yan. All rights reserved.
//

#include <iostream>
#include <map>
#include <string>

#include "consistent.h"


struct SdbmHash
{
    size_t operator() (const char* str) const
    {
        size_t hash  = 0;
        int c;
        while ((c = *str++)) {
            hash = c + (hash << 6) + (hash << 16) - hash;
        }
        
        return hash;
    }
};


class CacheServer
{
public:
    typedef std::map<std::string, std::string> StringMap;
    
    void Put(const std::string& key, const std::string& value)
    {
        cache_[key] = value;
    }
    
    std::string Get(const std::string& key) const
    {
        std::string value;
        StringMap::const_iterator it = cache_.find(key);
        if (it != cache_.end()) {
            value = it->second;
        }
        return value;
    }
    
    void Remove(const std::string& key)
    {
        StringMap::iterator it = cache_.find(key);
        if (it != cache_.end()) {
            cache_.erase(it);
        }
    }
    
private:
    StringMap cache_;
};



int main(int argc, const char * argv[]) {
    
    typedef std::map<std::string,CacheServer> ServerMap;
    
    ServerMap servers;
    Consistent::HashRing<std::string, std::string, SdbmHash> ring(4, SdbmHash());
    
    servers["cache1.example.com"] = CacheServer();
    servers["cache2.example.com"] = CacheServer();
    servers["cache3.example.com"] = CacheServer();
    
    
    for (ServerMap::const_iterator it = servers.begin(); it != servers.end(); ++it) {
        std::cout << "Adding " << it->first << " with hash " << ring.AddNode(it->first) << std::endl;
    }
    
    const char* fruits[] = {"apple", "pear", "banana", "orange", "cherry", "apricot"};
    const char* colors[] = {"red", "green", "yellow", "orange", "black", "pink"};
    const unsigned int numfruits = sizeof(fruits) / sizeof(char*);
    
    for( unsigned int f = 0; f < numfruits; f++) {
        
        std::string host = ring.GetNode(fruits[f]);
        std::cout << "Storing " << fruits[f] << " on server " << host << std::endl;
        servers[host].Put(fruits[f],colors[f]);
    }
    
    for (unsigned int f = 0; f < numfruits; f++) {

        std::string host = ring.GetNode(fruits[f]);

        std::string color = servers[host].Get(fruits[f]);
        std::cout << "Found " << fruits[f] << " on server " << host << " (" << color << ")" << std::endl;
    }
    
    
    return 0;
}
