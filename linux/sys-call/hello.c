#include <sys/syscall.h>

int main(int argc, char *argv[])
{
  syscall(SYS_write,1,"hello world\n",13);
  return 0;
}
