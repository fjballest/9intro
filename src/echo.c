#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	i;

	for (i = 0; i < argc; i++)
		print("%d: %s\n ", i, argv[i]);
	exits(nil);
}
