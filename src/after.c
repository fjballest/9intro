#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	fd;

	if (fork() == 0){
		fd = open("afile", OWRITE);
		write(fd, "child\n", 6);
	} else {
		fd = open("afile", OWRITE);
		write(fd, "dad\n", 4);
	}
	close(fd);
	exits(nil);
}
