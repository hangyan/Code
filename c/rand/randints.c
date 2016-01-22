#include <stdio.h>
#include <stdlib.h>
#include <errno.h>


int main(int argc,const char *argv[])
{
  unsigned int i = 0, n = 0;
  unsigned int seed = 0x16372789;
  long int r = 0;
  int is_binary = 0;

  if (argc < 2) {
    fprintf(stderr,"Usage: %s [-b] <number of ints> [random seed]\n,argv[0]");
    fprintf(stderr,"with -b option output will be binrary\n");
    return EXIT_FAILURE;
  }

  if (argc > 2) {
    if (!strncmp(argv[1], "-b" , 3)) {
      is_binary = 1;
      argv++;
      argc--;
    }
  }

  errno = 0;
  n = strtol(argv[1],NULL,0);
  if (errno) {
    perror("strtol");
    return EXIT_FAILURE;
  }

  if (argc == 3) {
    errno = 0;
    seed = strtol(argv[2], NULL, 0);
    if (errno) {
      perror("strtol");
      return EXIT_FAILURE;
    }
  }

  if (is_binary) {
    freopen(NULL,"wb",stdout);
  }

  srandom(seed);
  while(n--) {
    r = random();
    if (is_binary)
      fwrite(&r,sizeof(int),1,stdout);
    else
      printf("%d\n",r);
  }

  return 0;
}
