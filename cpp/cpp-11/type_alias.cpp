#include <string>
#include <ios>
#include <type_traits>

// type alias,same as typedef
using flags = std::ios_base::fmtflags;
flags f1 = std::ios_base::dec; // 10 进制标示

// same as typedef
using func = void (*) (int,int);
void example(int, int) {}
func fn = example;


template<class T> using ptr = T*;
ptr<int> x;


//可以少写一个模板参数
template <class CharT> using mystring =
  std::basic_string<CharT, std::char_traits<CharT>>;
mystring<char> str;

//暴露成员类型名
template <typename T>
struct Container {
  using value_tpye = T;
};

template<typename Container>
void fn2(const Container& c)
{
  typename Container::value_tpye n;
}


template <typename T> using Invoke =
  typename T::type;

template <typename Condition> using EnableIf =
  Invoke<std::enable_if<Condition::value>>;

template<typename T,typename = EnableIf<std::is_polymorphic<T>>>
  int fpoly_only(T t) { return 1;}

struct S { virtual ~S() { }};


int main(int argc, char *argv[])
{
  Container<int> c;

  fn2(c);
  S s;
  fpoly_only(s);
  
  
  return 0;
}
