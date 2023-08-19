#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	i;

	i = 1;
	fork();
	i++;
	print("i=%d\n", i);
	exits(nil);
}
