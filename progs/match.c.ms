.P1
.ps -1
.ti -1i
.B
.BX match.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <regexp.h>

void
main(int argc, char* argv[])
{
	Reprog*	prog;
	Resub	sub[16];
	char	buf[1024];
	int	nr, ismatch, i;

	if (argc != 2){
		fprint(2, "usage: %s regexp\en", argv[0]);
		exits("usage");
	}
	prog = regcomp(argv[1]);
	if (prog == nil)
		sysfatal("regexp '%s': %r", buf);
	for(;;){
		nr = read(0, buf, sizeof(buf)-1);
		if (nr <= 0)
			break;
		buf[nr] = 0;
		ismatch = regexec(prog, buf, sub, nelem(sub));
		if (!ismatch)
			print("no match\en");
		else {
			print("matched: '");
			write(1, sub[0].sp, sub[0].ep - sub[0].sp);
			print("'\en");
		}
	}
	exits(nil);
}
.ps +2
.P2
