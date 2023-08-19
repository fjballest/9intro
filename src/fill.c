#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	fd[2];
	char	buf[1024];
	int	nw;

	if (pipe(fd) < 0)
		sysfatal("can't create a pipe: %r");
	for(;;){
		nw = write(fd[0], buf, sizeof(buf));
		print("wrote %d bytes\n", nw);
	}
	exits(nil);
}
