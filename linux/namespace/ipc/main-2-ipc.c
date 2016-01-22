#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>


#define STACK_SIZE (1024 * 1024)

// sync primitive
int checkpoint[2];


static char child_stack[STACK_SIZE];
char* const child_args[] = {
  "/bin/bash",
  NULL
};

int child_main(void* arg)
{
  char c;
  close(checkpoint[1]);
  read(checkoutpoint[0],&c,1);

  printf(" - World !\n");
  sethostname(" IN Namespace",12);
  execv(child_args[0],child_args);
  printf("Ooops\n");
  return 1;
}


int main()
{
  // init sync primitive
  pipe(checkpoint);

  printf(" - Hello ?\n");

  int child_pid = clone(child_main,child_stack + STACK_SIZE,
                        CLONE_NEWUTS | CLONE_NEWIPC | SIGCHLD, NULL);
  sleep(4);
  close(checkpoint[1]);

  waitpid(child_pid,NULL,0);
  return 0;
}
