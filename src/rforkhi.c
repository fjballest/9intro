#include <u.h>
#include <libc.h>
 
void
main(int, char*argv[])
{
	print("hi\n");
	rfork(RFCFDG);
	print("there\n");
	exits(nil);
}
