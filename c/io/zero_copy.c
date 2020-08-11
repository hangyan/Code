#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/uio.h>

int main(int argc, char* argv[])
{
	const char buf1[] = "Hello ";
	const char buf2[] = "Wikipedia ";
	const char buf3[] = "Community!\n";

	struct iovec bufs[] = {
	{.iov_base = (void*)buf1, .iov_len = sizeof buf1 - 1 },
	{.iov_base = (void*)buf2, .iov_len = sizeof buf2 - 1 },
	{.iov_base = (void*)buf3, .iov_len = sizeof buf3 - 1 },
	};
	
	if (-1 == writev(STDOUT_FILENO, bufs, sizeof bufs / sizeof * bufs))
	{
		perror("writev()");
		exit(EXIT_FAILURE);
	}

	return 0;
}