#include <u.h>
#include <libc.h>
void
usage(void)
{
	fprint(2, "usage: %s [-r]\n", argv0);
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
		print("[%s]\n", buf);
	}
	if (raw)
		close(cfd);
	exits(nil);
}
