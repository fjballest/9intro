#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	print("running ls\n");
	execl("/bin/ls", "ls", "-l", "/usr/nemo", nil);
	print("exec failed: %r\n");
}
