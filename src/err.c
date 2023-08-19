#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	if (chdir("magic") < 0){
		sysfatal("chdir failed: %r\n");
	}
	/* ... do other things ... */
	exits(nil);
}
