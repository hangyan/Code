#include <aio.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <strings.h>
#include <errno.h>

int BUFSIZE = 1024;

int main() {

    int fd, ret;
    struct aiocb my_aiocb;

    fd = open("file.txt", O_RDONLY);
    if (fd < 0) perror("open");

    /* Zero out the aiocb structure (recommended) */
    bzero((char *) &my_aiocb, sizeof(struct aiocb));

    /* Allocate a data buffer for the aiocb request */
    my_aiocb.aio_buf = malloc(BUFSIZE + 1);
    if (!my_aiocb.aio_buf) perror("malloc");

    /* Initialize the necessary fields in the aiocb */
    my_aiocb.aio_fildes = fd;
    my_aiocb.aio_nbytes = BUFSIZE;
    my_aiocb.aio_offset = 0;

    ret = aio_read(&my_aiocb);
    if (ret < 0) perror("aio_read");

    while (aio_error(&my_aiocb) == EINPROGRESS) {
        printf("waiting...\n");
    }

    if ((ret = aio_return(&my_aiocb)) > 0) {
        printf("read done!");

    } else {
        printf("read error");
    }
}