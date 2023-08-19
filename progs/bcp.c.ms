.P1
.ps -1
.ti -1i
.B
.BX bcp.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

static void
usage(void)
{
	fprint(2, "usage: %s [-b bufsz] infile outfile\en", argv0);
	exits("usage");
}

void
main(int argc, char* argv[])
{
	char*	buf;
	long	nr, bufsz = 8*1024;
	int	infd, outfd;

	ARGBEGIN{
	case 'b':
		bufsz = atoi(EARGF(usage()));
		break;
	default:
		usage();
	}ARGEND;
	if (argc != 2)
		usage();
	buf = malloc(bufsz);
	if (buf == nil)
		sysfatal("no more memory");
	infd = open(argv[0], OREAD);
	if (infd < 0)
		sysfatal("%s: %s: %r", argv0, argv[0]);
	outfd = create(argv[1], OWRITE, 0664);
	if (outfd < 0)
		sysfatal("%s: %s: %r", argv0, argv[1]);
	for(;;){
		nr = read(infd, buf, bufsz);
		if (nr <= 0)
			break;
		write(outfd, buf, nr);
	}
	close(infd);
	close(outfd);
	exits(nil);
}
.ps +2
.P2
