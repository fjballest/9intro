#include <u.h>
#include <libc.h>

void
usage(void)
{
	fprint(2, "usage: %s [-nv] [-d delims] args\n", argv0);
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
	default:
		usage();
	}ARGEND;
	
	for (i = 0; i < argc; i++)
		if (vflag)
			print("%c%s%c ", d[0], argv[i], d[1]);
		else
			print("%s ", argv[i]);
	if (!nflag)
		print("\n");
	exits(nil);
}
