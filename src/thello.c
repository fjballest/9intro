#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	fd;

	fd = open("afile", OWRITE|OTRUNC);
	write(fd, "hello\n", 6);
	close(fd);
	exits(nil);
}
