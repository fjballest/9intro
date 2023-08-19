#include <u.h>
#include <libc.h>
#include <plumb.h>

void
main(int , char* [])
{
	int	fd;
	Plumbmsg*m;
	char*	addr;

	fd = plumbopen("edit", OREAD);
	if (fd < 0)
		sysfatal("edit port: %r");
	while(m = plumbrecv(fd)){
		addr = plumblookup(m->attr, "addr");
		if (addr == nil)
			addr = "none";
		print("msg: wdir='%s' data='", m->wdir);
		write(1, m->data, m->ndata);
		print("' addr='%s'\n", addr);
		plumbfree(m);
	}
	fprint(2, "plumbrecv: %r");
	close(fd);
	exits(nil);
}
