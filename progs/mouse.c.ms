.P1
.ps -1
.ti -1i
.B
.BX mouse.c
.ps +1
.CW
.ps -2
.vs .15i
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
		print("mouse pos=%P\etbuttons=%d\en", m.xy, m.buttons);
		if (m.buttons == 7)
			break;
	}
	closemouse(mctl);
	exits(nil);
}
.ps +2
.P2
