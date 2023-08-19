.P1
.ps -1
.ti -1i
.B
.BX aecho.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	nflag = 0;
	int	vflag = 0;
	int	i;

	ARGBEGIN{
	case 'v':
		vflag = 1;
		break;
	case 'n':
		nflag = 1;
		break;
	default:
		fprint(2, "usage: %s [-nv] args\en", argv0);
		exits("usage");
	}ARGEND;
	
	for (i = 0; i < argc; i++)
		if (vflag)
			print("[%s] ", argv[i]);
		else
			print("%s ", argv[i]);
	if (!nflag)
		print("\en");
	exits(nil);
}
.ps +2
.P2
