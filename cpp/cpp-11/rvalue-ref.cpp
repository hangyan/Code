#include <iostream>
#include <vector>
// 左值和右值引用区别
void process_value(int& i) {
	std::cout << "LValue processed: " << i << std::endl;
}

void process_value(int&& i) {
	std::cout << "RValue processed: " << i << std::endl;
}

void forward_value(int&& i) {
	process_value(i);
}

// 转移构造函数和转移赋值函数
class MyString {
private:
	char* _data;
	size_t _len;
	void _init_data(const char* s) {
		_data = new char[_len+1];
		memcpy(_data, s, _len);
		_data[_len] = '\0';
	}
public:
	MyString() {
		_data = NULL;
		_len = 0;
	}

	MyString(const char* p) {
		_len = strlen(p);
		_init_data(p);
	}

	MyString(const MyString& str) {
		_len = str._len;
		_init_data(str._data);
		std::cout << "Copy Constructor is called! source: " << str._data << std::endl;
	}

	MyString& operator=(const MyString& str) {
		if (this != &str) {
			_len = str._len;
			_init_data(str._data);
		}
		std::cout << "Copy Assignment is called! source: " << str._data << std::endl;
		return *this;
	}

	virtual ~MyString() {
		if(_data) free(_data);
	}

	MyString(MyString&& str) {
		std::cout << "Move Constructor is Called! source: " << str._data << std::endl;
		_len = str._len;
		_data = str._data;
		str._len = 0;
		str._data = NULL;
	}

	MyString& operator=(MyString&& str) {
		std::cout << "Move Assignment is called! source: " << str._data << std::endl;
		if(this != &str) {
			_len = str._len;
			_data = str._data;
			str._len = 0;
			str._data = NULL;
		}
		return *this;
	}
   
};


template <typename T>
void forward_value(const T& val) {
	process_value(val);
}

template <typename T>
void forward_value(T& val) {
	process_value(val);
}

template <typename T>
void forward_value(T&& val) {
	process_value(val);
}
		



int main() {
	int a = 0;
	process_value(a);
	process_value(1);
	forward_value(2);

	MyString b;
    b = MyString("hello");
	std::vector<MyString> vec;
	vec.push_back(MyString("World"));

	process_value(std::move(a));

	
}
	
