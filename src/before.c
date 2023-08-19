#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	fd;

	fd = create("afile", OWRITE, 0644);
	write(fd, "hello\n", 6);
	if (fork() == 0)
		write(fd, "child\n", 6);
	else
		write(fd, "dad\n", 4);
	close(fd);
	exits(nil);
}
