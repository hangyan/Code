#include <iostream>
#include <memory>
#include <string>

class Greeter 
{
public:
    template <class T>
    Greeter(T data) : self_(std::make_shared<Model<T>>(data)) 



class English 
{
public:
    void greet(const std::string &name) 
    {
        std::cout << "Good day" << name << ".How are you?\n";
    }
};


class French 
{
public:
    void greet(const std::string &name) const 
    {
        std::cout << "Bonjour " << name << ". Comment ca va?\n";
    }
};






void greet_tom(const Greetr &g) 
{
    g.greet("Tom");
}



int main() 
{
    greet_tom(English{});
    greet_tom(French{});
}

    
