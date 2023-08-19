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
	while(line = Brdline(&bin, '\n')){
		len = Blinelen(&bin);
		Bwrite(&bout, line, len);
	}
	Bterm(&bin);
	Bterm(&bout);
	exits(nil);
}
