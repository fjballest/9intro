#include <u.h>
#include <libc.h>
#include <draw.h>

void
main(int, char*argv[])
{
	Rectangle rect;
	Image*	 black;

	fmtinstall('R', Rfmt);
	if(initdraw(nil, nil, argv[0]) < 0)
		sysfatal("initdraw: %r");
	rect = screen->r;
	black = display->black;
	draw(screen, rect, black, nil, Pt(rect.min.x+20,rect.min.x+20));
	flushimage(display, 1);
	sleep(5 * 1000);
	closedisplay(display);
	print("rectangle was %R\n", rect);
	exits(nil);
}
