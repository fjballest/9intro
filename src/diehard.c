#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	while(fork() == 0)
		;	// catch me!
	exits(nil);
}
