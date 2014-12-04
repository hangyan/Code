#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>

/*
  fork:
  子进程继承了父进程的全局变量和局部变量，子进程中，最后全局变量globVar和局部
  变量var均递增3，分别是8和4，而父进程均递增5，结果是10和6，
  这证明了子进程有自己独立的地址空间。不管是全局变量还是局部变量，
  子进程和父进程对它们的修改互不影响。

  vfork:
  vfork()创建了子进程后，父进程中globVar和var都递增了8，
  因为vfork()的子进程共享父进程的地址空间，子进程修改变量对父进程是可见的。
 */

int globVar = 5;
int main(void)
{
  pid_t pid;
  int var = 1, i;
  printf("fork is differeent with vfork \n");
  //pid = fork();
  pid = vfork();
  
  switch(pid)
	{
	case 0:
	  i = 3;
	  while(i-- > 0) {
		printf("Child process is running \n");
		globVar++;
		var++;
		sleep(1);
	  }
	
	  printf("Child's globvar = %d, var = %d\n",globVar,var);
	  break;
	case -1:
	  perror("Process creatoin failed\n");
	  exit(0);
	default:
	  i = 5;
	  while(i-- > 0) {
		printf("Parent process is running\n");
		globVar++;
		var++;
		sleep(1);
	  }
	  printf("Parent's globVar = %d,var = %d\n", globVar,var);
	  exit(0);
	
	}
  exit(0);
}

/*
  区别:
  fork()创建了子进程之后，父子进程的执行顺序是不确定的。
  vfork()创建子进程之后，子进程先运行，这是因为vfork()是保证子进程先运行的，
  在子进程调用exit或exec之前父进程是阻塞的状态。
 */
