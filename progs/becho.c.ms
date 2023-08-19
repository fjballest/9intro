.P1
.ps -1
.ti -1i
.B
.BX becho.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
usage(void)
{
	fprint(2, "usage: %s [-nv] [-d delims] args\en", argv0);
	exits("usage");
}
void
main(int argc, char* argv[])
{
	int	nflag = 0;
	int	vflag = 0;
	char*	d = "[]";
	int	i;

	ARGBEGIN{
	case 'v':
		vflag = 1;
		break;
	case 'n':
		nflag = 1;
		break;
	case 'd':
		d = ARGF();
		if (d == nil || strlen(d) < 2)
			usage();
		break;
.ps +2
.P2
.P1
.ps -2
.vs .15i
	default:
		usage();
	}ARGEND;
	
	for (i = 0; i < argc; i++)
		if (vflag)
			print("%c%s%c ", d[0], argv[i], d[1]);
		else
			print("%s ", argv[i]);
	if (!nflag)
		print("\en");
	exits(nil);
}
.ps +2
.P2
