#include <vector>
#include <iostream>
using namespace std;


class MyKlass {
public:
	MyKlass(int ii_, float ff_) {}
private:
	int a;
};

int main()
{
	std::vector<MyKlass> v;
	v.push_back(MyKlass(2, 3.14f));
	v.emplace_back(2, 3.14f);

	std::
}
	
