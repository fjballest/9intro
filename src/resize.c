#include <u.h>
#include <libc.h>
#include <thread.h>
#include <draw.h>
#include <mouse.h>

void
blank(void)
{
	draw(screen, screen->r, display->black, nil, ZP);
	flushimage(display, 1);
}

void
resizethread(void* arg)
{
	Mousectl*mctl = arg;
	for(;;){
		recvul(mctl->resizec);
		if (getwindow(display, Refnone) < 0)
			sysfatal("getwindow: %r");
		blank();
	}
}

void
mousethread(void* arg)
{
	Mousectl*mctl = arg;
	Mouse	m;
	for(;;){
		recv(mctl->c, &m);
		if(m.buttons){
			do {
				recv(mctl->c, &m);
			} while(m.buttons);
			closedisplay(display);
			closemouse(mctl);
			threadexitsall(nil);
		}
	}
}

void
threadmain(int, char*argv[])
{
	Mousectl*mctl;
	Mouse	m;

	mctl = initmouse("/dev/mouse", nil);
	if (mctl == nil)
		sysfatal("initmouse: %r");
	if(initdraw(nil, nil, argv[0]) < 0)
		sysfatal("initdraw: %r");
	threadcreate(resizethread, mctl, 8*1024);
	threadcreate(mousethread, mctl, 8*1024);
	blank();
	threadexits(nil);
}
