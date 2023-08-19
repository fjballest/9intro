#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	pid;

	pid = getpid();
	print("my pid is %d\n", pid);
	exits(nil);
}
