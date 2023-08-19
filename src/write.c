#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	char	msg[] = "hello\n";
	int	l;

	l = strlen(msg);
	write(1, msg, l);
	exits(nil);
}
