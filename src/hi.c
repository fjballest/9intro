#include <u.h>
#include <libc.h>
 
void
main(int, char*argv[])
{
	/* Wrong! */
	print("hi ");
	print(argv[1]);
	exits(nil);
}
