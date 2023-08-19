#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	fd, n;
	char	msg[] = "a new file\n";

	fd = create("afile", OWRITE, 0664);
	write(fd, msg, strlen(msg));
	close(fd);
	exits(nil);
}
