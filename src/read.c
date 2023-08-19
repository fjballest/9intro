#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	char	buffer[1024];
	int	nr;

	nr = read(0, buffer, sizeof buffer);
	write(1, buffer, nr);
	exits(nil);
}
