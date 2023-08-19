#include <u.h>
#include <libc.h>
void
main(int, char*[])
{
	// just like rabbits...
	while(fork())
		;
	exits(nil);
}
