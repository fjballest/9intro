#include <u.h>
#include <libc.h>
#include <thread.h>
#include <draw.h>
#include <mouse.h>

void
threadmain(int , char*[])
{
	Mousectl*mctl;
	Mouse	m;

	fmtinstall('P', Pfmt);
	mctl = initmouse("/dev/mouse", nil);
	if (mctl == nil)
		sysfatal("initmouse: %r");
	while(recv(mctl->c, &m) >= 0){
		print("mouse pos=%P\tbuttons=%d\n", m.xy, m.buttons);
		if (m.buttons == 7)
			break;
	}
	closemouse(mctl);
	exits(nil);
}
