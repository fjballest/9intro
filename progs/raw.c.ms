.P1
.ps -1
.ti -1i
.B
.BX raw.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
void
usage(void)
{
	fprint(2, "usage: %s [-r]\en", argv0);
	exits("usage");
}
void
main(int argc, char*argv[])
{
	char	buf[512];
	int	raw = 0;
	int	cfd = -1;
	int	nr;

	ARGBEGIN{
	case 'r':
		raw++;
		break;
	default:
		usage();
	}ARGEND;
	if (argc != 0)
		usage();
	if (raw){
		cfd = open("/dev/consctl", OWRITE);
		write(cfd, "rawon", 5);
	}
	for(;;) {
		nr = read(0, buf, sizeof(buf)-1);
		if (nr <= 0)
			break;
		buf[nr] = 0;
		print("[%s]\en", buf);
	}
	if (raw)
		close(cfd);
	exits(nil);
}
.ps +2
.P2
