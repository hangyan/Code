// c++11

#include <iostream>

int count () {
  return 0;
}

template<typename T, typename... Args>
int count(T n, Args... args) {
  return 1 + count(args...);
}

double sum() {
  return 0.0;
}

template<typename T, typename... Args>
double sum(T n, Args... args) {
  return n + sum(args...);
}

template<typename T, typename... Args>
double average(T n, Args... args) {
  return (n + sum(args...)) / (1 + count(args...));
}


int main(int argc, char *argv[])
{
  std::cout << average(100,300,400,200) << std::endl;
  return 0;
}




