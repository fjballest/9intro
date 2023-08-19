#include <u.h>
#include <libc.h>
void
main(int, char*[])
{
	print("process pid is %d. have fun.\n", getpid());
	sleep(3600*1000); // one hour to play
	exits(nil);
}
