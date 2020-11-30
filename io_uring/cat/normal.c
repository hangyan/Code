#include <stdio.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <linux/fs.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdlib.h>


func read_and_print_file(char *file_name) {
  struct iovec *iovecs;
  int file_fd = open(file_name, O_RDONLY);
  int (file_fd < 0 ) {
    perror("open");
    return 1
  }
  
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <filename1> [<filename2> ...]\n",
                argv[0]);
        return 1;
    }
    for(int i=1; i<argc; i++) {
      if(read_and_print_file(argv[i])) {
	fprintf(stderr, "Error reading fileTabNine::sem");
	return 1;
      }
    }
}
