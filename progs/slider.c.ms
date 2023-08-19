.P1
.ps -1
.ti -1i
.B
.BX slider.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <thread.h>
#include <draw.h>
#include <mouse.h>
#include <keyboard.h>

Channel*sliderc;
Image*setcol;
Image*unsetcol;
Keyboardctl*kctl;
Mousectl*mctl;

void
terminate(void)
{
	closekeyboard(kctl);
	closemouse(mctl);
	closedisplay(display);
	threadexitsall(nil);
}

.ps +2
.P2
.P1
.ps -2
void
keyboardthread(void* a)
{
	Keyboardctl*kctl = a;
	Rune	r,rr;
	int	nval;
	for(;;){
		recv(kctl->c, &r);
		switch(r){
		case Kdel:
		case 'q':
		case Kesc:
			terminate();
			break;
		default:
			if (utfrune("0123456789", r) != nil){
			    recv(kctl->c, &rr);
			    if (utfrune("0123456789", rr) != nil){
			    	nval = (r-'0')*10 + (rr-'0');
			    	sendul(sliderc, nval);
			    }
			}
		}
	}
}

.ps +2
.P2
.P1
.ps -2
void
writeval(int val)
{
	Point	sz, pos;
	char	str[5];	// "0%" to "100%"
	seprint(str, str+5, "%d%%", val);
	sz = stringsize(font, str);
	if (sz.x > Dx(screen->r)/2 || sz.y > Dx(screen->r))
		return;
	pos = screen->r.min;
	pos.x += 10;
	pos.y +=  (Dy(screen->r)- sz.y) / 2;
	string(screen, pos, display->black, ZP, font, str);
}

.ps +2
.P2
.P1
.ps -2
void
drawslider(int val)
{
	Rectangle setrect, unsetrect, markrect;
	int	dx;

	dx = Dx(screen->r) * val / 100;
	setrect = unsetrect = markrect = screen->r;
	setrect.max.x = setrect.min.x + dx;
	markrect.min.x = setrect.max.x;
	markrect.max.x = setrect.max.x + 2;
	unsetrect.min.x = markrect.max.x;
	draw(screen, setrect, setcol, nil, ZP);
	draw(screen, unsetrect, unsetcol, nil, ZP);
	draw(screen, markrect, display->black, nil, ZP);
	writeval(val);
	flushimage(display, 1);
}

.ps +2
.P2
.P1
.ps -2
void
sliderthread(void*)
{
	uint	val, nval;
	val = ~0;
	for(;;){
		nval = recvul(sliderc);
		if (nval >= 0 && nval <= 100){
			if (nval == val)
				continue;
			val = nval;
		}
		drawslider(val);
		print("%d\en", val);
	}		
}

.ps +2
.P2
.P1
.ps -2
void
resizethread(void* arg)
{
	Mousectl*mctl = arg;
	for(;;){
		recvul(mctl->resizec);
		if (getwindow(display, Refnone) < 0)
			sysfatal("getwindow: %r");
		sendul(sliderc, ~0);
	}
}

.ps +2
.P2
.P1
.ps -2
void
mousethread(void* arg)
{
	Mousectl*mctl = arg;
	Mouse	m;
	int	dx, val;
	for(;;){
		recv(mctl->c, &m);
		if(m.buttons == 1){
			do {
				dx = m.xy.x - screen->r.min.x;
				val = dx * 100 / Dx(screen->r);
				sendul(sliderc, val);
				recv(mctl->c, &m);
			} while(m.buttons == 1);
		}
	}
}

.ps +2
.P2
.P1
.ps -2
void
threadmain(int, char*argv[])
{
	Mouse	m;

	mctl = initmouse("/dev/mouse", nil);
	if (mctl == nil)
		sysfatal("initmouse: %r");
	kctl = initkeyboard("/dev/cons");
	if (kctl == nil)
		sysfatal("initkeyboard: %r");
	if(initdraw(nil, nil, argv[0]) < 0)
		sysfatal("initdraw: %r");
	setcol = allocimage(display, Rect(0,0,1,1),
		screen->chan, 1, DYellow);
	unsetcol = allocimage(display, Rect(0,0,1,1),
		screen->chan, 1, 0x777777FF);
	sliderc = chancreate(sizeof(ulong), 0);
	threadcreate(resizethread, mctl, 8*1024);
	threadcreate(mousethread, mctl, 8*1024);
	threadcreate(keyboardthread, kctl, 8*1024);
	threadcreate(sliderthread, sliderc, 8*1024);
	sendul(sliderc, 50);
	threadexits(nil);
}
.ps +2
.P2
