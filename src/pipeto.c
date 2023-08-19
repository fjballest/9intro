#include <u.h>
#include <libc.h>

int
pipeto(char* cmd)
{
	int	fd[2];

	pipe(fd);
	switch(fork()){
	case -1:
		return -1;
	case 0:
		close(fd[1]);
		dup(fd[0], 0);
		close(fd[0]);
		execl("/bin/rc", "rc", "-c", cmd, nil);
		sysfatal("execl");
	default:
		close(fd[0]);
		return fd[1];
	}
}

void
main(int, char*[])
{
	int	fd, i;
	char*	msgs[] = {
		"warning: the world is over\n",
		"spam: earn money real fast!\n",
		"warning: it was not true\n" };

	fd = pipeto("grep warning");
	if (fd < 0)
		sysfatal("pipeto: %r");
	for (i = 0; i < nelem(msgs); i++)
		write(fd, msgs[i], strlen(msgs[i]));
	close(fd);
	exits(nil);
}
