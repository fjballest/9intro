.P1
.ps -1
.ti -1i
.B
.BX biocat.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <bio.h>

void
main(int , char* [])
{
	Biobuf	bin;
	Biobuf	bout;
	char*	line;
	int	len;

	Binit(&bin, 0, OREAD);
	Binit(&bout,1, OWRITE);
	while(line = Brdline(&bin, '\en')){
		len = Blinelen(&bin);
		Bwrite(&bout, line, len);
	}
	Bterm(&bin);
	Bterm(&bout);
	exits(nil);
}
.ps +2
.P2
