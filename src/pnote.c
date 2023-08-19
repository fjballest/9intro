#include <u.h>
#include <libc.h>

int
handler(void*, char* msg)
{
	print("note: %s\n", msg);
	return 0;
}

void
main(int, char*[])
{
	atnotify(handler, 1);
	sleep(3600 * 1000);	// one hour to play
	print("done (%r)\n");
	exits(nil);
}
