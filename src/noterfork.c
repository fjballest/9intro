#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	i;

	rfork(RFNOTEG);
	for(i = 0; i < 5; i++){
		sleep(1000);
		print("%d ", i);
	}
	print("\n");
	exits(nil);
}
