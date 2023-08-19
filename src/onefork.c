#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	print("one\n");
	fork();
	print("fork\n");
	exits(nil);
}
