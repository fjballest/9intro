.so tmacs
.BC 12 "User Input/Output
.BS 2 "Console input
.LP
.ix "user I/O
In chapter 7 we saw that
.CW #c
.ix "[#c] device driver
.ix "console device
is the root of the file tree exported by the
.I cons (3)
driver. It is conventionally bound at
.CW /dev ,
.ix [/dev]
and provides the familiar
.CW /dev/cons
.ix [/dev/cons]
file. Reading
.CW #c/cons
obtains input from the console keyboard. Writing to
.CW #c/cons
writes characters in the console screen.
.PP
.ix [rio]
.ix "window system
When \f(CWrio\fP, the window system, is running, it reads
.CW #c/cons
to obtain the characters you type. Writing them in the screen is a different story
that we will tell later. Reading and writing
.CW #c/cons
while running the window system is not a good idea. If more than one program is
reading this file, the characters typed will go to either program. In the following
experiment, we ask
.CW cat
to read
.CW #c/cons ,
storing what it could read into
.CW /tmp/out ,
so you could see what happens.
.P1
; cat '#c/cons' >/tmp/out
!!hlo		\fRWe typed "hello"\fP
\fBDelete\fP		!!\fRTo restore things to a normal behavior\fP
; cat /tmp/out
el;
.P2
.ix "simultaneous read
.LP
Despite typing
.CW "hello" ,
\f(CWrio\fP could only read
.CW "hlo" .
The other characters were read by
.CW cat .
.CW rio
expects to keep the real
.CW #c/cons
for itself, because it multiplexes this file nicely, providing a virtual version of it
on each window's
.CW /dev/cons .
.PP
A write to
.CW #c/cons
is also processed by the
.I cons
device, even when \f(CWrio\fP is running. As a result, it prints in the screen behind
\f(CWrio\fP's back. This command
.P1
; echo 'where will this go?' > '#c/cons'
.P2
.LP
.ix [#c/cons]
will produce an ugly message printed in the screen, which might look like
the one shown in figure [[!write console rio!]]. In a very few occasions, the kernel
itself may write a message for you in the console. The same would happen. Programs
started prior to running \f(CWrio\fP, that might also issue some diagnostics, would produce
the same effect. All of them are writing to the console output device.
.LS
.BP conswrite.ps
.LE F A write to the actual console may write to the screen even when rio is running.
.PP
.ix "console write
Writing some more things in the real console may cause a scroll, and the images
in the screen will scroll along with the text. Poor \f(CWrio\fP, it will never know that the
screen is messed up. To prevent this from happening, the file
.CW #c/kprint
.ix [/dev/kprint]
may be used. If a process has
.CW #c/kprint
open for reading, the kernel will not print in the screen whatever is written at
.CW #c/cons .
Instead, all that text is used to satisfy reads for
.CW #c/kprint .
For example, executing
.CW cat
on this file, prior to doing the
.CW echo
above, produces this effect:
.P1
; cat /dev/kprint
where will this go?
.P2
.LP
All text sent to the console will now go to that window.
For the record, it might help to print also
.CW /dev/kmesg ,
.ix [/dev/kmesg]
which records all the messages printed in the console so far, before reading
.CW kprint .
.P1
; cat /dev/kmesg /dev/kprint
Plan 9
E820: 00000000 0009f800 memory
E820: 0009f800 000a0000 reserved
.I "..."
where will this go?
.P2
.LP
When we implemented programs to read from the console, it gave us a line at a
time. We could even
.I edit
the line before hitting return. However, this time, using
.CW cat
to read
.CW #c/cons
returned characters, as we typed them. What is going on?
.ix "console read
.PP
Usually, the console device driver reads characters from the keyboard's hardware, and
\fBcooks\fP
.ix "cooked mode
what you type a little bit, before supplying such characters to any process reading
.CW /dev/cons .
This is the cooking recipe used by the console:
.IP •
A
.I backspace ,
.ix backspace
removes the previous character read from the keyboard.
.IP •
A
.I control-u
.ix "control-u
removes all the characters read from the keyboard, thus it cancels the current
input line.
.IP •
A
.I newline
.ix newline
terminates the cooking from the current line, which is made available to the
application reading from the console.
.IP •
The
.I compose
.ix compose
(usually
.I Alt )
key, followed by a few other keys, produces a character that is a function
of the other keys. This is used to type characters not usually found in the
keyboard, like α and Ж.
.IP •
Any other character stands for itself, and is queued to be cooked along with
the rest of the line.
.LP
The virtual version for
.CW /dev/cons
provided by the window system gives also a special meaning to a few other
characters, most notably:
.IP •
.I Delete
.ix [Delete]
posts an
.I interrupt
note to the process group associated to the window.
.IP •
.ix "arrow keys
Arrow keys ↑ and ↓ scroll backward and forward.
.IP •
Arrow keys → and ← move the text insertion point to the right and to the left.
.IP •
The
.ix [Escape]
.I Escape
key puts the window in a, so called,
.I hold
.ix "hold mode
mode. All the text typed while in hold mode is not supplied to any application
reading from
.CW /dev/cons .
Therefore, you can freely edit multiple lines of text. When
.I Escape
.ix "escape key
is preseed again, and the window leaves hold mode, the text is given to any
process reading from
.CW /dev/cons .
.LP
This is called the console's
.B "cooked mode" .
When it is enabled, lines can be edited as dictated by the rules stated above. This is
also called a
.I "line discipline" .
.ix "line discipline
But the console can be also put in a, so called,
.B "raw mode" .
In raw mode, the console does not cook the characters at all. It gives them to
the process reading from the console, as they arrive from the keyboard.
.PP
The file
.CW /dev/consctl
can be used to activate and de-activate the raw mode.
A write of the string
.CW rawon
.ix [rawon]
into such file puts the console in raw mode, until the file is closed or the string
.CW rawoff
.ix [rawoff]
is written.
The next program echoes what it can read from the console. But it
puts the console in raw mode when called with
.CW -r .
.so progs/raw.c.ms
.ix [raw.c]
.LP
This is what happens when we run it using the console's cooked mode and its
raw mode.
.P1
; 8.raw
!!hi
[hi
]
\fBDelete\fP
;
.P2
.P1
; 8.raw -r
[h]
[i]
[	\fI the program reads "\en"\fP
]
[␣]	\fI the program reads "Del"\fP
[␣]	\fI If we type "Esc", the program reads "Esc"\fP
.P2
.LP
There are some things to note. First, in cooked mode we can see the
characters we type as we type them. We could type
.CW hi ,
and its characters were echoed to the screen by the console. The program
.CW 8.raw
did not read anything as we typed them. Not yet. However, in raw mode,
the console does
.I not
.ix "character echo
.ix "console echo
echo back to the screen what we type. It assumes that the program reading
in raw mode does want to do it all by itself, and echo is suppressed.
.PP
Another effect of raw mode is that the program reads one character at a time,
as we type them. In cooked mode, only when we type a newline the program will
get its input.
.PP
A final and interesting difference is that we
.I cannot
.ix "program interrupt
interrupt the program pressing
.I Delete .
In fact, if
.CW /dev/cons
was
.CW #c/cons ,
it would know nothing about
.I Delete .
This key is an invention of the cooked mode in consoles provided for windows by
the window system. In raw mode, \f(CWrio\fP decides not to do anything special with this
key, and the application can read it as any other key.
.PP
Using the hold mode (provided by rio's consoles in cooked mode) this is what happens.
.P1
; 8.out
\fBEscape\fP
!!hi	\fRhold mode is active...\fP
!!there	\fRwe can edit this until...\fP
\fBEscape\fP
[hi
]
[there
]
.P2
.LP
The behavior is like in cooked mode (one line at a time), but we could type and
edit while in hold mode.
.PP
To answer our pending question. The program
.CW cat ,
that we used to experiment with reading
.CW #c/cons ,
got characters and not lines because rio keeps the system console in raw mode.
The file
.CW #c/cons
returns characters as we type them. These characters are processed by \f(CWrio\fP,
which uses them to supply a virtual console for the window were you are typing.
.ix "virtual console
Again, the virtual console for this window has both cooked and raw modes.
In shell windows, that operate in cooked mode,
the window cooks the characters before giving lines to programs
reading them. When acme is run in a window, it puts its (virtual) console device
in raw mode, to do the editing by itself.
.BS 2 "Characters and runes
.LP
.ix "rune
.ix "text representation
.ix "text symbol
.ix "ASCII
But that was not all about the console. The console, like most other devices
using text, and like all Plan 9 programs using text, does
.I not
use characters. This may be a surprise, but think about “characters”
like ☺, α, and Ж. For languages like English or Spanish, all text is made up
with characters, that might be letters, numbers, and other symbols. Spanish
has also accented letters like á and ñ. And this is just the start of the problem.
Other languages use symbols to represent concepts, or what would be words or
lexemes, for a spanish person.
When computers were used for english text, the standard ASCII for codifying
characters as bytes was enough. Today, it is not. There are many symbols and
one byte is not enough.
.PP
Plan 9 uses
.B Unicode ,
which is a standard for representing symbols used for
text writing. Indeed, Plan 9 was the first system to use Unicode.
The symbols used to write text are not called characters, but \fBrunes\fP.
Each rune is represented in Plan 9 as a 16-bit (two bytes) number. Most
programs processing text are expected to use runes to do their job. The data type
.CW Rune
is defined in
.CW libc.h ,
as a short integer.
.PP
However,
using a stream of 16-bit numbers to exchange text between different programs
would be a nightmare because it would break all the programs written to use
just ASCII, which uses a single byte for each character. Furthermore, many C programs
use strings codified as a sequence of bytes terminated by a final null byte. Sending
a stream of 16-bit runes to such programs will make them fail.
.PP
To maintain compatibility with the huge amount of software that existed when
Unicode was invented, a encoding was designed to transform an array of runes
into a byte stream that could be backward compatible with ASCII. This encoding is
called
.B UTF-8 ,
(Universal character set Transformation Format, 8 bits)
or just UTF (for short).
UTF-8 was
invented by Ken Thompson (apparently in a dinner's table, shared with Rob Pike).
.ix "Ken Thompson
.ix "Rob Pike
Runes like ☺, α, and Ж do not use a single byte when codified in UTF. A rune
may use up to three bytes in Plan 9's UTF.
.PP
A program reading text, reads a UTF byte stream, that is
exactly the same used by ASCII when the text contains characters present in
7-bit ASCII (most characters but for accentuated letters and other special symbols).
After having read some text, if it is to be processed as such, the program converts
the UTF representation into Unicode. Then it is processed. Afterwards, to output
some text as a result, the program is expected to convert the text from Unicode
back into UTF, before sending it to the output stream. Files that keep text
used as input (or coming as output) for programs, are also maintained in UTF.
.PP
The file
.CW /dev/cons
does not provide characters when read. It provides runes. In many cases, a rune
may fit in a single byte. In other cases, it will not. The console keyboard driver knows how
to compose multiple keys to type runes not in the keyboard. The whole set of rules
is described in
.I keyboard (6).
.ix keyboard
Many runes may be generated by using the
.I compose
key, usually
.I Alt ,
and a couple of keys that remind the rune generated. For example, typing
.I Alt
.CW -
.CW >
will produce →.
.I Alt
.CW <
.CW -
will produce ←.
.I Alt
.CW s
.CW o
leads to ⁰ ,
and
.I Alt
.CW s
.CW a
leads to ª.
.ix "greek letter
Greek letters can be generated by typing
.I Alt
.CW *
and their roman counterparts. Thus,
.I Alt
.CW *
.CW m
leads to μ.
The file
.CW /lib/keyboard
lists many runes that can be composed using several other keys in this way.
.PP
In general,
any Unicode rune may be also generated by typing
.I Alt
.CW X
.I nnnn ,
where
.I nnnn
is the code in Unicode for the rune. So,
.I Alt
.CW X
.CW 00fe
leads to þ.
The file
.CW /lib/unicode
lists unicode runes along with their codes.
.ix "unicode code
.PP
Programs that
read and write data without assuming that it is text, may still operate
one byte at a time, if they want. Or many at a time.
However, programs reading text and looking
into it, should use the functions in
.I rune (2),
or they would misbehave for non-english text.
The
functions in the C library described in
.I rune (2)
provide conversion from UTF to runes and vice-versa. Among others, we have these ones.
.P1
; sig runetochar chartorune
	int runetochar(char *s, Rune *r)
	int chartorune(Rune *r, char *s)
.P2
.ix [runetochar]
.ix [chartorune]
.ix [Rune]
.LP
Now we can read
“characters” properly from the console, for the first time. The next program
converts what it reads to uppercase.
.so progs/rune.c.ms
.ix [rune.c]
.LP
It processes one rune at a time. The function
.CW chartorune
extracts a rune from the byte string pointed to by
.CW s ,
and places it at
.CW &r .
The number of bytes occupied by the rune in UTF (that is, in the string at
.CW s ),
is the return value from the function. The function
.CW runetochar
does the opposite conversion, and returns also the number of bytes used. It is
guaranteed that a rune will not occupy more than
.CW UTFmax
.ix [UTFmax]
bytes (3 bytes in Plan 9). Other convenience routines, like
.CW toupperrune ,
.ix [toupperrune]
replace the traditional ones for characters.
Our program works perfectly with runes that do not fit in ASCII.
.P1
; 8.out
!!I feel ☺ today.
I FEEL ☺ TODAY.
.P2
.LP
An equivalent program, but unaware of unicode, would fail. Using this loop to do
the conversion instead of the Rune routines
.ix "rune conversion
.P1
for (i = 0; i < nr; i++)
	buf[i] = toupper(buf[i]);
.P2
.LP
produces this result for this input.
.P1
!!España includes Espuña.
ESPAñA INCLUDES ESPUñA.
.P2
.LP
The letter
.CW ñ
was not properly capitalized into
.CW Ñ .
It could have been worse. We could have processed part of a rune, because
runes may span several bytes. For example, translating to uppercase by
.P1
buf[i] = buf[i] + 'A' - 'a'
.P2
.LP
will lead to a surprise (besides being wrong anyway).
.BS 2 "Mouse input
.LP
.ix "mouse input
Another popular input device is the mouse. The mouse interface is provided by
the mouse driver through a few
files in
.CW #m .
.ix "[#m] device driver
.ix "mouse device
.P1
; lc '#m'
cursor		mouse		mousectl
;
.P2
.LP
This name is usually bound along with other devices at
.CW /dev .
The file
.CW mousectl
.ix [/dev/mouse]
.ix [/dev/mousectl]
is used to write strings to configure and adjust mouse settings. For example,
.P1
; echo accelerated >/dev/mousectl
.P2
.LP
turns on mouse acceleration (a quick move in one direction will move the mouse
fast in that direction, many more pixels than implied by the actual movement).
On the other hand,
.P1
; echo linear >/dev/mousectl
.P2
.LP
disables mouse acceleration. There are several other messages. Depending on
the hardware for the mouse, some control requests may be ignored (if they
do not make sense for a particular mouse).
.PP
When the window system is running, \f(CWrio\fP is the one that reads and writes these
files. As with
.CW /dev/cons ,
\f(CWrio\fP provides its own (multiplexed) version for these files, on each window.
Reading
.CW #m/mouse
yields mouse events. However, this file may not be opened more than once at the
same time.
.ix "exclusive open
.P1
; cat '#m/mouse'
cat: can't open #m/mouse: '#m/mouse'
	device or object already in use
.P2
.LP
Since \f(CWrio\fP has open
.CW #m/mouse ,
.ix "mouse event
to read mouse events, nobody else will be able to open it until \f(CWrio\fP terminates and
the file is closed. This is a safety measure to synchronize multiple programs trying to use this
device at the same time. In any case, the multiplexed version of the mouse,
.CW /dev/mouse ,
provided by \f(CWrio\fP for each window is for us to read.
.P1
.ps -1
; cat /dev/mouse
m        670          66           0     2257710 m        676         
 68           0     2257730 m        677          74           
0     2257750 m        680          77           0     2257770
.ps +1
.P2
.LP
This file will never seem to terminate. No end of file indication for it. Indeed,
.CW /dev/mouse
.ix stream
is a stream of mouse events. Each read will block until the mouse produces
an event (it is moved or a button is pressed or released). At that point,
.CW /dev/mouse
returns 49 bytes. There is an initial letter
.CW m
followed by four numbers: the x and y coordinates for the mouse, a number
stating which buttons are pressed, and a time stamp.
.PP
.ix "time stamp
The time stamp is handy
when a program wants to detect double and triple clicks. In Plan 9, the mouse might even
be attached to a different machine. The time for the clicks that matters is that
of the machine with the mouse, when the mouse events were received from the
hardware by the mouse driver. The time as seen by the program reading the mouse
might differ a little bit (there may be delays between different mouse events
introduced because our program moved out of the processor, or because the system went
busy, etc.).
.PP
Mouse coordinates
.ix "mouse coordinate
.ix "pixel
.ix "picture element
.ix "screen
.ix "screen size
correspond to the position of the pointer in the screen. The screen is a matrix
of pixels. A typical screen size is 1024x768 (1024 pixels wide, on the
.I x
axis, and
768 pixels of height, on the
.I y
axis). Other popular screen sizes are 1280x1024 or
1600x1200. The origin is coordinate (0,0), at the upper left corner of the screen.
Thus, for a 1024x768 screen, the bottom right corner would be (1023,767).
There are
increasing values for
.I x
as you move to the right, and increasing
.I y
values as you move
down.
.PP
The first mouse event reported by
.CW cat
was for the coordinate (670,66). That is, the tip of the arrow used as a cursor
was pointing at the pixel number 670 on the x axis (counting from 0)
and number 66 on the y axis. 
The mouse was then moved a little bit down-right, and the next coordinate reported
by
.CW cat
was (676,68).
.PP
.ix "mouse position
Following the two numbers reporting the pointer position, there is a number
that lets you know the state for mouse buttons (always zero in the example
above). To experiment with this, we
are going to write a small program that reads the mouse and prints
one mouse event per line, which is easier to read. Before looking at the source
for the program, this is an example run.
.P1
; 8.mouse
mouse pos=[896 189]	buttons=0	\fIwe move the mouse...\fP
mouse pos=[895 190]	buttons=0
mouse pos=[894 190]	buttons=0
.I ...
.P2
.P1
mouse pos=[887 191]	buttons=1	\fIbutton-1 down\fP
mouse pos=[887 191]	buttons=3	\fIbutton-2 down\fP
mouse pos=[887 191]	buttons=1	\fIbutton-2 up\fP
mouse pos=[887 191]	buttons=0	\fIbutton-1 up\fP
.I ...
.P2
.P1
mouse pos=[887 191]	buttons=0
mouse pos=[887 191]	buttons=1	\fIbutton-1 down\fP
mouse pos=[887 191]	buttons=3	\fIbutton-2 down\fP
mouse pos=[887 191]	buttons=7	\fIbutton-3 down\fP
;
.P2
.LP
.ix "mouse button-1
.ix "mouse button2
.ix "mouse button2
As you could see, each button is codified as a single bit in the number. Button-1
is the bit 0, button-2 is the bit 1, button-3 is the bit 2, and so on. A click for button
one will yield
.CW 1
while it is down, and
.CW 0
when released. A click for button 3 will yield
.CW 4
(i.e.,
.CW 100
in binary)
when it is down and
.CW 0
when released. Our program exits when all the three buttons are down, that is,
when the number is
.CW 7
(i.e.,
.CW 111
in binary).
.PP
Instead of reading
.CW /dev/mouse
by itself, the program uses the
.I mouse (2)
.ix "mouse library
library. This library provides a mouse interface for threaded programs. Programs
using the mouse are likely to do several things concurrently (attend the keyboard,
do something for their user interface, etc.). Therefore, it is natural to write a
threaded program when the application requires a graphical user interface.
.so progs/mouse.c.ms
.LP
The program must include
.CW mouse.h ,
which contains the definitions for the library, along with
.CW draw.h ,
which defines some data types used by the library.
The function
.CW initmouse
.ix [initmouse]
.ix "mouse initialization
initializes the mouse interface provided by the library. It creates a process to
read the file given as an argument and obtain mouse events.
.P1
; sig initmouse
	Mousectl *initmouse(char *file, Image *i)
.P2
The return value
is a pointer to a
.CW Mousectl
structure:
.ix [Mousectl]
.P1
typedef struct Mousectl Mousectl;
struct Mousectl
{
	Channel	*c;		/* chan(Mouse) */
	Channel	*resizec;	/* chan(int)[2] */
	\fI...\fP
};
.P2
.ix "mouse event channel"
that contains a channel,
.CW Mousectl.c ,
where mouse events are sent by the process reading the mouse. Therefore, to
obtain mouse events all we have to do is to call
.CW recv
on this channel. Each mouse event is codified as a
.CW Mouse
.ix [Mouse]
structure, containing the buttons, the coordinates, and the time stamp for the
mouse (as read from the mouse file).
.P1
typedef struct Mouse Mouse;
struct	Mouse
{
	int	buttons;	/* bit array: LMR=124 */
	Point	xy;
	ulong	msec;
};
.P2
.LP
Thus, the call
.P1
recv(mctl->c, &m)
.P2
.ix [recv]
.LP
is the one reading mouse events in the program. The program prints the
coordinates, kept at
.CW Mouse.xy ,
and the buttons, kept at
.CW Mouse.buttons .
Using coordinates is so common that
.CW draw.h
defines a
.CW Point ,
.ix [Point]
along with some functions to operate on points.
.P1
typedef struct Point Point;
struct	Point
{
	int	x;
	int	y;
};
.P2
.LP
So, the
.I x
coordinate for the mouse event stored at
.CW m
would be
.CW m.xy.x ,
and the
.CW y
coordinate would be
.CW m.xy.y .
.PP
To print
.CW Points ,
the function
.CW Pfmt ,
.ix [Pfmt]
.ix "[%P] format"
declared by
.CW draw.h ,
can be installed as a format function for the
.CW print
function family. The call
.P1
fmtinstall('P', Pfmt);
.P2
instructs
.CW print
to use
.CW Pftmt
to print any argument that corresponds to a
.CW %P
in its format string. This is very convenient for printing coordinates. By the way,
there are many other format functions defined in the standard library. And you
may define your own ones. It is all explained in
.I fmtinstall (2),
.ix [fmtinstall]
.ix "format install
which details the support for user-defined print formats.
.PP
Finally, the function
.CW closemouse
.ix [closemouse]
closes the mouse file and releases any resource related to the
.CW Mousectl
structure (most notably, its memory, the channel, and the process reading the mouse).
.PP
The rest of the mouse interface (not used by this program) will be deferred until we see something
about graphics.
.BS 2 "Devices for graphics
.LP
.ix "graphic devices
The whole idea behind graphic terminals is quite simple. A portion of memory
is used to keep the image(s) to be shown at the terminal. The hardware device
that updates the monitor image by reading this memory is called a graphics card.
But things are not so simple anymore.
.PP
.ix VGA
.ix monitor
Ultimately, graphics are supported by extremely complex hardware devices like
VGA cards (Video Graphic Arrays).
Such devices use system memory (and/or memory attached directly
to the graphics card) to store images to be shown at the monitor. It turns out
that monitors are also very complex these days. You only have to consider that
graphic cards and monitors speak together using particular protocols through the
video cable that goes from the card to the monitor
.PP
Games and other popular applications demanding graphics have lead to graphic
cards that know by themselves how to do many 2D and 3D graphics operations.
Sometimes, this is called
.B "hardware acceleration"
for video and graphics operations.
.PP
Fortunately, all this is hidden behind the device driver for the video card used in
your terminal. The
.I vga (3)
.ix "vga device
.ix "[#v] device driver
device is in charge for dealing with the VGA card in your PC. Its file interface is
available at
.CW #v .
.P1
; lc '#v'
vgabios		vgactl		vgaovl		vgaovlctl
.P2
.LP
.ix [vgactl]
.ix BIOS
.ix ROM
The most interesting file is
.CW vgactl ,
which is the interface for configuring the card for a proper operation. Other
files provide access to extra features, like overlaid images, and for the software
kept in ROM in the PC (called BIOS, for Basic Input/Output System, but not basic)
that is useful to deal with the card.
.PP
.ix "text mode
Initially, while the system is booting, the graphics card operates in an ancient
text-only setting. It uses some memory to display a matrix of characters
in the screen, usually of 80 columns and 24 rows, or 80x24. But the hardware
can do much more. It knows how to display graphics. When the card operates to
show graphics, it can be adjusted to show a particular number of pixels. We saw
a little bit of this when describing the coordinates used by the mouse.
.PP
.ix "graphics mode
Most graphic cards can show 640x480 pixels, 1024x768 pixels, 1280x1024 pixels, and
perhaps even more. For each pixel, the number of colors that the card can show
is determined by the number of bits used to encode a value for the pixel. Using 8
bits per pixel leads to at most 256 colors. Therefore, a particular screen size
would not just be 1024x768, but rather 1024x768x8 or perhaps 1024x768x24.
.PP
Each one of these different configurations is usually called a
graphics \fBmode\fP.
So, the configuration for the VGA size 1280x1024x24 is also known as the
1280x1024x24 mode.
Because the size of the actual screen is fixed, the number of pixels determines the size
of each pixel in the screen. Thus, different modes are also referred to as different
.I resolutions .
.ix "screen resolution
.PP
Changing the mode in the VGA card can be very complex. An auxiliary program,
.CW aux/vga
.ix [aux/vga]
.ix [vga]
is in charge of adjusting the vga configuration.
You will use the file interface provided by the
.I vga
device driver just to adjust a few parameters, and not for doing other complex
things. For that, you have
.CW aux/vga .
For example,
.P1
aux/vga -l text
.P2
.LP
puts the machine back into text mode, as it was during boot. In the same way,
.P1
aux/vga -l 1024x768x8
.P2
.LP
loads the mode for 1024x768x8. On the other hand,
if our graphics card is not properly handled by
our device driver, we may disable hardware acceleration by using the interface
at
.CW #v
instead of
.CW aux/vga .
.P1
; echo hwaccel off >/dev/vgactl
.P2
.ix "hardware acceleration
.LP
Also, writing
.CW blank
to
.CW vgactl
.ix "screen blank
will blank the screen, until we move the mouse. And
.P1
; echo blanktime 30 >/dev/vgactl
.P2
.LP
will make the screen blank after 30 minutes of (mouse) inactivity.
.PP
The size used by
.CW aux/vga
to set the mode for the graphics card is kept in the environment variable
.CW vgasize .
The type of monitor is kept in the environment variable
.CW monitor .
.ix [$monitor]
.P1
; echo $vgasize
1280x800x24
; echo $monitor
cinema
.P2
.LP
Both are the primary parameters used by
.CW aux/vga
to set the VGA mode. This happens during the system startup, and you will
probably not be concerned about this, but in any case,
.CW $vgasize
.ix [$vgasize]
is a useful bit of information to write scripts that depend on the screen resolution.
.PP
In any case, reading
.CW vgactl
provides most of the configuration parameters for the graphics card that you
might want to use.
.P1
; cat /dev/vgactl
type vmware
size 1280x800x32 x8r8g8b8
blank time 30 idle 0 state on
hwaccel on
hwblank off
panning off
addr p 0xfa000000 v 0xe0000000 size 0xa8c000
.P2
.LP
The interface provided by the kernel for using graphics is not that of
.I vga .
That is a particular control interface for a particular kind of graphics card.
Graphics are provided by the
.I draw (3)
device driver. The
.I draw
.ix "draw device
device relies on the facilities provided by the graphics card
attached to the system, and provides the primary system interface to graphics.
.PP
.ix "draw connection
Draw maintains
.I connections
between processes using graphics, and the graphics device itself. Of course,
connections to the draw device are represented as files, similar to what happen
with network connections. Its file tree is available at
.CW #i ,
.ix "[#i] device driver
.ix [/dev/draw]
but is also bound at
.CW /dev .
.P1
; lc /dev/draw
1	2	42	new
; lc /dev/draw/1
colormap	ctl	data	refresh
.P2
.LP
Here, directories
.CW 1 ,
.CW 2 ,
and 
.CW 42
are the interface for three different connections maintained as of this moment
in my terminal. The directory for a connection (besides other files) has a
.CW ctl
and a
.CW data
.ix "[ctl] file
.ix "[data] file
.ix "line directory
file, like we saw with network line directories. Opening the file
.CW /dev/draw/new
establishes a new connection. So, a process that wants to use graphics must
open
.CW /dev/draw/new ,
and then write to the
.CW data
file for its connection messages that encode the graphic operations to be
performed.
.PP
The draw device provides the
.I Image
.ix image
abstraction, along with operations to allocate, deallocate, and draw on it.
All the graphics operations are performed by this device. Programs using graphics
talk directly to the device, by establishing connections to it, and asking it to
perform operations on images. Instead of using the device interface directly,
most programs use the
.I draw (3)
library, as shown next.
.BS 2 "Graphics
.LP
.ix "graphics
Graphics are provided through the file interface for the draw device. This happens
both when using the console (before the window system runs) and after running
the window system. When run in the console, a graphics program will use the entire
screen as its window, when run within the window system, it will use just the window.
That is the only difference regarding graphics, which is why you can execute
\f(CWrio\fP in a window, as we did some time ago when connecting to a CPU server.
.PP
The following program draws the entire
.B screen
in black for 10 seconds. Like many other programs, it uses the
functions from the draw library, as described in
.I graphics (2),
and
.I draw (2),
instead of speaking to the draw device by itself.
.so progs/black.c.ms
.ix [black.c]
.LP
The program calls
.CW initdraw
.ix [initdraw]
.ix "graphics initialization
to
establish a connection to the draw device. This function initializes
some global variables, including
.CW screen ,
and
.CW display ,
.ix [screen]
.ix [display]
that are used later in the program.
.P1
.ps -1
; sig initdraw
   int initdraw(void (*errf)(Display*, char*),
	char *font, char *label)
.ps +1
.P2
.LP
.ix [errfun]
.ix font
.ix [/dev/label]
.ix "window label
The first parameter points to a function called by the library upon errors. Passing
a nil pointer means that the draw library will use its own, which prints a diagnostic
message and terminates the program. Usually, that is all you will want to do.
The second parameter states which font to use for drawing text. Again, passing
a nil value means that the library will use a reasonable default. The last parameter
is simply a textual label for the window, which we define to be the program name.
The function writes the text in
.CW label
to the file
.CW /dev/label ,
to let \f(CWrio\fP know how the window is named, in case it is hidden.
.PP
The
.CW display
variable points to a
.CW Display
.ix [Display]
structure that represents the connection to the draw device. It maintains all the
information necessary to speak with the device, for drawing. In particular, it
keeps the file descriptor for the
.CW /dev/draw/\fIn\fP/data
file, that is, for the connection to the device. 
Calling
.CW closedisplay(display)
.ix [closedisplay]
as the program does after 10 seconds, closes the connection and releases any
graphic resources associated to it.
.PP
Another useful global variable, also initialized by
.CW initdraw ,
is
.CW screen .
This variable points to a structure representing the screen (i.e., the memory)
where you may draw and use graphics.
When running in the console,
.CW screen
corresponds to the entire screen. When running inside a \f(CWrio\fP window,
.CW screen
corresponds to the part of the screen used by the window.  In what
follows, we will always speak about
.I "the window"
used by the program. But it should be clear that such “window” may be
the entire screen if no window system is running.
.PP
To which data type does
.CW screen
point to? Where can you draw things on? It turns out that
the screen is an image, the data abstraction provided by
.I draw (3).
It represents a piece of memory used as an image by the graphics card. It is
just a rectangular picture.
.ix "drawing graphics
A program may draw by changing bits in the image for its screen. Most of
things a program uses for drawing are also images. For example, colors
are images (with pixels in the appropriate color), to write text in the screen
a program draws images for the appropriate characters, a window is
essentially an image (that a program will use as its screen), the entire
screen (also called the display) is an image as well.
The data type
.CW Image ,
.ix [Image]
is defined in
.CW draw.h .
.P1
.ps -2
typedef struct Image Image;
struct Image
{
    Display	*display;	/* display; connection to draw(3) */
    int		id;	/* id of draw(3) Image */
    Rectangle	r;	/* rectangle for the image */
    Rectangle 	clipr;	/* clipping rectangle */
    int		depth;	/* number of bits per pixel */
    ulong		chan;	/* how to encode colors */
    int		repl;	/* flag: replicated to tile clipr */
    Screen	*screen;	/* or nil if not a window */
};
.ps +2
.P2
.LP
Together,
.CW display
and
.CW id
identify an image as the one named
.I id
in the draw device at the other end of the connection represented by the
.I display .
.PP
An interesting piece of information in this structure is
.CW Image.r ,
It describes the rectangle in the entire screen used by the image. Thus,
.ix "[screen] rectangle
.CW screen->r
describes the (rectangular) area used in the screen by our window. Like
coordinates (or
.CW Points ),
rectangles are a popular data type when doing graphics. The draw library
defines the appropriate data type.
.ix [Rectangle]
.P1
typedef struct Rectangle Rectangle;
struct Rectangle
{
	Point	min;
	Point	max;
};
.P2
.LP
A rectangle is defined by two points (the upper left corner and the bottom right one).
Choosing (0,0) as the origin simplifies arithmetic operations for points. In
accordance with this, the convention is that a rectangle
.I includes
its
.CW min
point (upper left corner) but does
.I not
include its
.CW max
point (bottom right corner). The point with biggest coordinates inside a rectangle would
be (\f(CWmax.x\fP-1,\f(CWmax.y\fP-1).
.ix "window coordinates
.PP
We are close to understanding the line
.P1
	draw(screen, screen->r, display->black, nil, ZP);
.P2
.LP
that calls the function
.CW draw
.ix [draw]
.ix [mask]
.P1
.ps -2
; sig draw
   void draw(Image *dst, Rectangle r, Image *src, Image *mask, Point p)
.ps +2
.P2
.LP
You might think that after understanding how to use this function, there might be
many other ones that will be hard to understand. That is not the case. The
function
.CW draw
is the only thing you need for drawing. There are other routines as a convenience
to draw particular things, but all of them use just
.CW draw .
.PP
Basically,
.CW draw
takes a image as the source and draws it (over) on a destination image. That is,
each pixel (\fIi\fP, \fIj\fP) in the source is copied to the pixel (\fIi\fP, \fIj\fP) in the
destination. Here,
.CW screen
was the destination image, and
.CW display->black
.ix [black]
was the source image.
.is "source image
.PP
The source image represents the color
black, because it is an image with all its pixels in that color.
Although we could draw the entire
screen by copying black pixels from
.CW display->black ,
this image is not that large. Images that have their
.CW repl
field set to true are used as
.I tiles .
.ix "tiling
The implementation for
.CW draw
tiles the image as many times as necessary to fill the rectangle where it is to be
drawn. So,
.CW display->black
might have just one black pixel. Only that before copying any pixel from it,
.CW draw
replicated it to obtain an image of the appropriate size.
.PP
The second parameter is the rectangle where to confine the drawing
of the source in the target. This is called a
.B clip
rectangle, because no drawing occurs outside it.
The program used
.CW screen->r ,
and so it draws in the screen
the whole rectangle used by
.CW screen .
Drawing in a target image will not draw outside that image. Thus, the drawing
is confined to the intersection of the target image's rectangle and the rectangle
given to
.CW draw .
In this case, we draw in the intersection of
.CW screen->r
(the target's rectangle)
and
.CW screen->r
(the parameter for draw). That is, of course, just
.CW screen->r .
.PP
The image for the screen uses real screen coordinates. In other
cases, you may have images that do not use screen coordinates. To draw one of
these images you must
.I translate
the coordinates for the source so that they match the area in the target where you
want to draw. The last parameter for
.CW draw
is a point that indicates which translation to do. Passing the point (0,0), which is
defined as
.CW ZP
.ix [ZP]
.ix "screen origin
in
.CW draw.h ,
.ix "coordinate translation
.ix "image copy
performs no translation: each pixel (\fIi\fP, \fIj\fP) in the source is
copied to the pixel (\fIi\fP, \fIj\fP) in the
destination. Passing other point will ask
.CW draw
to translate the source image (coordinates) so that the given point is aligned
with the top-left corner of the rectangle where to draw.
.PP
The
.CW mask
.ix [mask]
parameter allows an image to be used as a mask. This is useful to draw things
like cursors and the like. In most cases you may use nil, and not a mask.
We do not discuss this parameter here,
the
.I draw (2)
manual page has all the details.
.PP
One thing that remains to be discussed about our program is the call to
.CW flushimage .
.ix "flushimage
.ix "draw~operation flush
Writing to the draw device for each single operation performed by the draw
library would be very costly. To improve efficiency, the library includes buffering
for writes to the draw device's files. This is similar to what we saw regarding
buffered input/output. Only that in this case, draw is always doing
buffered output. As a result, if you draw, it many happen that your operations
are still sitting in the buffer, and the actual device may not have received them.
A call to
.P1
flushimage(display ,1)
.P2
flushes the buffer for the display. The last parameter is usually set to true, to
indicate to the driver that it must update the actual screen (in case it also
maintains another buffer for it).
.PP
If you remove this line from the program, it will draw, but the window will remain
white (because the operation will not take effect).
Fortunately, you will not need to worry about this in many cases, because the
functions for drawing graphics and text call
.CW flushimage
on their own. Nevertheless, you may have to do it by yourself if you use
.CW draw .
.BS 2 "A graphic slider
.LP
.ix "graphic slider
We want to implement a small graphical application, to let the user adjust
a value between 0% and 100%. This is a graphical slider, that can be run in
a window. The program will print to its standard output the value corresponding
to the position of the slider as set by the user using the mouse or the keyboard.
.PP
.ix "window resize
The real display does not have that problem, but windows can be resized. 
The window system supplies its own menus and mouse language to let the user
resize, move, and even hide and show windows. For our program, this means
that the screen might change!
.PP
.CW Rio
assumes that a program using graphics is also reading from the mouse.
And note that the mouse is the virtual mouse file \f(CWrio\fP provides for
the window!
Upon a resize, \f(CWrio\fP delivers a weird mouse event to the program
reading
.CW /dev/mouse .
This event does not start with the character
.CW m ,
it starts with the character
.CW r ,
to alert of the resize.
After the program is alerted, it should update the image it is using as its
.CW screen
(that is, as the window).  The program can do so because the file
.CW /dev/winname
.ix [/dev/winname]
.ix "window name
contains the name for the image to be used as a window, and this can be used
to lookup the appropriate image for the window using its name.
.PP
The function
.CW getwindow
.ix [getwindow]
.ix "acquiring window
updates the
.CW screen
variable, after locating the image to be used as the new window.
As a curiosity, the window system draws a border for the window in the image
for the
.CW screen .
However, your program is unaware of this because
.CW getwindow
adjusts
.CW screen
to refer to the portion of the image inside the border.
.PP
But how do we know of resize events from the mouse? Simple. Look back
to see the fields for a
.CW Mousectl
structure,
which we obtained before by calling
.CW initmouse .
You will notice that besides the channel
.CW Mouse.c ,
used to report mouse events, it contains a channel
.CW Mouse.resizec .
.ix "window resize
.ix "resize event
Resize events are sent through this channel. The receipt of an integer
value from this channel means that the window was resized and that the
program must call
.CW getwindow
to reestablish its
.CW screen
for the new window.
.PP
The following program draws the entire window in black, like before. However,
this program re-acquires its window when it is resized. It creates a separate
thread to attend the mouse, and another one to process resizes of the window,
removing all that processing from the rest of the
program. In this case, it may be considered an overkill. In more complex
programs, placing separate processing in separate threads will simplify things.
After starting the thread for attending the mouse, and the one attending
resizes, the program calls the function
.CW blank
.ix [blank]
that draws the entire window in black.
.so progs/resize.c.ms
.ix [resize.c]
.LP
Try running the program
.CW 8.black
and using the arrow keys to scroll up/down the window. It scrolls!
.CW Rio
thinks
that nobody is using graphics in the window. That does not happen to
.CW 8.resize ,
which keeps the mouse file open.
.PP
The implementation for
.CW blank
is taken from our previous program. It draws the entire window image in black and
flushes the draw operations to the actual device.
.P1
void
blank(void)
{
	draw(screen, screen->r, display->black, nil, ZP);
	flushimage(display, 1);
}
.P2
.LP
.ix "mouse event processing
Mouse processing for our program is simple. Any button click terminates the program.
But users expect the action to happen during the button release, and not
during the previous press. Therefore,
.CW mousethread
.ix [mousethread]
loops receiving mouse events. When a button is pressed, the function reads more
events until no button is pressed. At that point,
.CW closedisplay
terminates the connection to the display,
.CW closemouse
.ix [closemouse]
closes the mouse device, and the program exits.
.P1
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
.P2
.LP
Note how by placing mouse processing in its own thread, the programming language
can be used to program the behavior of the mouse almost like when describing it
in natural language.
.PP
The new and interesting part in this program is the code for the thread reading
resize events.
.ix "resize event
.ix [resizethread]
.P1
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
.P2
.LP
After receiving a resize event, through
.CW mctl->resizec ,
the program calls
.CW getwindow
on the display, which updates
.CW screen .
Afterwards, it blanks the image for the new window.
The second parameter to
.CW getwindow
has to do with window overlapping. It identifies the method used to refresh the
window contents after being hidden. When two windows overlap, someone must
maintain a copy of what is hidden behind the window at the top. This
.I backup
is called
.B "backing store" .
.CW Rio
provides backing store for windows, and the constant
.CW Refnone
.ix [Refnone]
asks for no further backup (i.e., no refresh method).
.PP
We now want this program to draw a slider, like those of figure [[!slider!]].
The slider draws in yellow a bar representing the value set by the slider, and fills
the rest of the window with the same background color used by \f(CWrio\fP. Using the
mouse, it can be adjusted to the left (the one above in the figure) and to the right
(the one below in the figure). When the slider is at the left, it represents a value of 0
(or 0% of a value set by the slider). When it is at the right, it represents a value of 100.
.LS
.BP slider.ps 2.3i
.LE F Two example windows for the slider application. One at 30%, another at 84%.
.PP
Maintaining the slider is a separate part of the processing done by the program,
which uses
a different thread for that purpose. We will call it
.CW sliderthread .
The existing code also requires changes. First,
.CW threadmain
.ix [threadname]
.ix channel
must create now a channel to
send new values for the slider to the slider thread, and must create the thread itself. Also,
we must get rid of the call to
.CW blank()
in
.CW threadmain .
This program does not blank its window.
Since we decided that
.CW sliderthread
is in charge of the slider,
.CW threadmain
will no longer draw anything. Instead, it may
send a value to the slider, to adjust it to a reasonable initial value (and draw it).
.P1
.ps -1
.ti -1i
.B
.BX slider.c
.ps +1
.CW
.vs .2i
.I "...Initially, all the code as before, but for the changes explained in the text...
Channel*sliderc;
.I "..."
void
threadmain(int, char*argv[])
{
	\fI...all code here as before...\fP
	sliderc = chancreate(sizeof(ulong), 0);
	threadcreate(sliderthread, sliderc, 8*1024);
	sendul(sliderc, 50);
	threadexits(nil);
}
.P2
.LP
The application must redraw the window when the resize thread receives a
resize event. To do so,
.CW resizethread
will no longer call
.CW blank .
Instead, it asks the slider thread to redraw the slider on the new window
(as if the value had changed). Because only values between 0 and 100 are
meaningful to the slider, we can adopt
the convention that when the slider receives any number not in the range
[0,100], it simply redraws for its current value. So, we replace
.P1
	blank();
.P2
.LP
in
.CW resizethread
with
.P1
.ps -1
	sendul(sliderc, ~0);	// A value not in 0..100
.ps +1
.P2
.LP
This is the code for the new thread. It will be blocked most of the time, waiting
for a value to arrive through
.CW sliderc .
Upon receiving a value, the slider value kept in
.CW val
is updated if the value is in range. Otherwise, the value is discarded. In any case,
the slider is drawn and its value printed in the output. That is the utility of the
program, to generate a value adjusted by the user using the slider. As an optimization,
we do not draw the slider if the value received through the channel is the current
value for the slider.
The code for
drawing the slider will be encapsulated in
.CW drawslider ,
to keep the function readable.
.ix "slider drawing
.P1
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
.P2
.LP
Note how different parts of the program can be kept simple, and without race
conditions. This thread is the only one in charge of the value for the slider.
Each other thread is also in charge of other type of
processing, using its own data. Communication
between threads happens through channels, which at the same time synchronizes
them and allows them to exchange data.
.PP
To draw the slider, we must draw three elements: A yellow rectangle for the part set,
a grey rectangle for the unset part, and a black thick line to further mark them apart.
After defining rectangles
.CW set ,
.CW unset ,
and
.CW mark ,
for each element, we can draw the slider as follows.
.P1
	draw(screen, setrect, setcol, nil, ZP);
	draw(screen, unsetrect, unsetcol, nil, ZP);
	draw(screen, markrect, display->black, nil, ZP);
.P2
.LP
Provided that
.CW setcol
.ix color
is an image for the color of the set part, and
.CW unsetcol
is an image for the color of the unset part.
An image for the black color was available, but we also needed two other colors.
.PP
The function
.CW allocimage
can be used to allocate a new image. We are going to use it to build two new images
for the yellow and the grey colors used for the set and the unset parts. We declare
both images as globals, along with
.CW sliderc ,
.P1
Channel*sliderc;
Image*	setcol;
Image*	unsetcol;
.P2
.LP
and add these two lines to
.CW threadmain ,
right after the call to
.CW initdraw .
.P1
setcol = allocimage(display, Rect(0,0,1,1),
	screen->chan, 1, DYellow);
unsetcol = allocimage(display, Rect(0,0,1,1),
	screen->chan, 1, 0x777777FF);
.P2
.LP
A call to
.CW allocimage
.ix [allocimage]
.ix "image allocation
allocates a new image, associated to the
.CW Display
.ix [Display]
given as an argument.
.P1
.ps -2
; sig allocimage
   Image *allocimage(Display *d, Rectangle r,
		ulong chan, int repl, int col)
.ps +2
.P2
.LP
When the display is closed (and the connection to
.I draw
is closed as a result), the images are deallocated. Note that the images are kept
inside the draw device. The function talks to the device, to allocate the images,
and initializes a couple of data structures to describe the images (you might call
them
.I "image descriptors" ).
.ix "image descriptor
.PP
The second argument
for
.CW allocimage
is the rectangle occupied by the image. In this case, we use a rectangle with
points (0,0) and (1,1) as its
.CW min
and
.CW max
points. 
If you remember the convention that the minimum point is included in the rectangle,
but the maximum point is not (it just marks the limit), you will notice that
both images have just one pixel. That is, the point with coordinates (0,0).
For declaring a literal (i.e., a constant) for a
.CW Rectangle
data type, we used
.CW Rect ,
which returns a
.CW Rectangle
given the four integer values for both coordinates of both extreme points. Another
function, useful to obtain a
.CW Rectangle
from two
.CW Point
values, is
.CW Rpt .
.P1
; sig Rect Rpt
	Rectangle Rect(int x0, int y0, int x1, int y1)
	Rectangle Rpt(Point p, Point q)
.P2
.LP
By the way, the function
.CW Pt
.ix [Pt]
.ix [Rect]
.ix [Rpt]
does the same for a
.CW Point .
Indeed,
.CW ZP
is defined as
.CW Pt(0,0) .
.P1
; sig Pt
	Point Pt(int x, int y)
.P2
.LP
Images for colors need just one pixel, because we ask
.CW allocimage
to set the
.CW repl
.ix "replicated image
.ix "[repl]
flag for both images. This is done passing true as a value for its
.CW repl
parameter. Remember that when this flag is set,
.CW draw
tiles the image as many times as needed to fill the area being drawn.
.PP
Two arguments for
.CW allocimage
remain to be described, but we will not provide much detail about them. The argument
.CW chan
is an integer value that indicates how the color will be codified for the pixels. There
are several possible ways to codify colors, but we use that employed by the screen
image. So, we used
.CW screen->chan
.ix "image chan
as an argument. The last parameter is the value that states which one is the code
for the color. Given both
.CW chan
and the number for the color,
.CW allocimage
can specify to the draw device which color is going to use the pixels in the new image.
.PP
In our program, we used the constant
.CW DYellow
.ix [DYellow]
for the color of the set part, and the number
.CW 0x777777FF
for the unset part. This number codifies a color by giving values for red, blue,
and green. We borrowed the constant by looking at the source code for \f(CWrio\fP, to use
exactly its background color.
.PP
At last, this is
.CW drawslider .
.P1
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
	flushimage(display, 1);
}
.P2
.LP
If the value represented by the slider is
.I val ,
in the range [0,100],
and our window is 
.I Dx
.ix [Dx]
.ix "rectangle width
pixels wide, then, the offset for the
.I x
coordinate in the window that corresponds to
.I val
is defined by
.EQ
	x = Dx times val over 100
.EN
.LP
A zero value would be a zero offset. A 100 value would mean a
.I Dx
offset. The function
.CW Dx
returns the width of a rectangle
(there is also a
.CW Dy
.ix [Dy]
.ix "rectangle height
function that returns its height). So,
.P1
	dx = Dx(screen->r) * val / 100;
.P2
.LP
computes the offset along the
.I x
axis that corresponds to the value for the slider.
Once we know
.CW dx ,
defining the rectangle for
.CW setrect
is straightforward. We take initially the rectangle for the window
and change the
.CW max.x
coordinate to cut the rectangle at the offset
.CW dx
in the window. The
.CW markrect
is initialized in the same way, but occupies just the next two pixels on the
.I x
axis, past
.CW setrect .
The rectangle
.CW unsetrect
goes from that point to the end of the
.I x
axis.
.ix axis
.PP
What remains to be done is to change
.CW mousethread
to let the user adjust the slider using the mouse.
.ix "mouse button-1
.ix "click
The idea is that holding down the button 1 and moving it will change the
slider to the point under the mouse.
.P1
.ps -1
void
mousethread(void* arg)
{
	Mousectl*mctl = arg;
	Mouse	m;
	int	dx, val;
.ps +1
.P2
.P1
.ps -1
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
.ps +1
.P2
.LP
Executing the program, moving the slider, and pressing
.I Delete
to kill it, leads to this output.
.P1
; 8.slider > /tmp/values
\fBDelete\fP
; cat /tmp/values
50
32
30
.I ...
.P2
.LP
Usually, the output for the program will be the input for an application requiring
a user adjustable value. For example, the following uses the slider to adjust
the volume level for the sound card in the terminal.
.P1
; 8.out | while(v=`{read}) echo audio out $v >>/dev/volume
.I "Changing the slider changes the volume level...
.P2
.BS 2 "Keyboard input
.LP
.ix "keyboard input
Using
.I Delete
to terminate the program is rather unpolite. The program might understand
a few keyboard commands. Typing
.CW q
might terminate the slider. Typing two decimal digits might set the slider to
the corresponding value. The library
.I keyboard (2)
.ix "keyboard library
is similar to
.I mouse (2),
but provides keyboard input instead of mouse input. Using it may fix another
problem that we had with the slider. The program kept the console
in cooked mode. Typing characters in the slider window will make the console
device (provided by \f(CWrio\fP) echo them. That was ugly.
.PP
To process the keyboard, one character at a time, hence putting the console
in raw mode, the main function may call
.CW initkeyboard .
.ix [initkeyboard]
.ix "keyboard initialization
.P1
; sig initkeyboard
	Keyboardctl *initkeyboard(char *file)
.P2
.LP
This function opens the console file given as an argument, and creates
a process that reads characters from it. The console is put in raw mode by
assuming that if the file is named
.CW /a/cons/file ,
there will be another file named
.CW /a/cons/filectl
that accepts a
.CW rawon
.ix [rawon]
command. So, giving
.CW /dev/cons
as an argument will mean that
.CW rawon
is written to
.CW /dev/consctl
(and the file is kept open).
.PP
The function returns a pointer to a 
.CW Keyboardctl
.ix [Keyboardctl]
structure, similar to a
.CW Mousectl .
It contains a channel where the I/O process sends runes (not characters!)
as they are received.
.P1
typedef struct 	Keyboardctl Keyboardctl;
struct	Keyboardctl
{
	Channel	*c;	/* chan(Rune)[20] */
	\fI...\fP
};
.P2
.LP
Like we did for the mouse, to process the keyboard input, we will change
.CW threadmain
to call
.CW initkeyboard
and to create a separate thread for processing keyboard input. This is the
resulting code for the program, omitting the various functions that we have
seen, and a couple of other ones that are shown later.
.so progs/slider.c.ms
.ix [slider.c]
.LP
The function
.CW keyboardthread
.ix [keyboardthread]
is executed on its own thread. It receives runes
from
.CW kctl.c
and processes them without paying much attention to the rest
of the program.
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
		case Kesc:
		case 'q':
			terminate();
			break;
.ps +2
.P2
.P1
.ps -2
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
.LP
The constants
.CW Kdel
and
.CW Kesc
are defined in
.CW keyboard.h
with the codes for the
.I Delete
and the
.I Escape
runes. We terminate the program when either key is pressed, or when a
.CW q
is typed. Otherwise, if the rune received from
.CW kctl->c
is a digit, we try to obtain another digit to build a slider value and send it
through
.CW sliderc .
.PP
To terminate the program, we must now call
.CW closekeyboard ,
.ix [closekeyboard]
which releases the
.CW Keyboardctl
structure and puts the console back in cooked mode. So, both control
structures were kept as globals in this version for the program. The next function
does all the final cleanup.
.P1
void
terminate(void)
{
	closekeyboard(kctl);
	closemouse(mctl);
	closedisplay(display);
	threadexitsall(nil);
}
.P2
.BS 2 "Drawing text
.LP
.ix "drawing text
With all the examples above it should be clear how to use the abstractions
for using the devices related to graphical user interfaces. Looking through the
manual pages to locate functions (and other abstractions) not described here
should not be hard after going this far.
.PP
Nevertheless, it is instructive to see how programs can write text. For example,
the implementation for the console in \f(CWrio\fP writes text. Both because the echo and
because of writes to the
.CW /dev/cons
file. But can this be on a graphic terminal?
.PP
There are many convenience functions in
.I draw (2)
.ix "drawing functions
to draw lines, polygons, arcs, etc. One of them is
.CW string ,
.ix [string]
.ix "draw string
which can be used to
.I draw
a string. Note: not to
.I write
a string.
.P1
.ps -2
; sig string
   Point string(Image *dst, Point p,
	Image *src, Point sp, Font *f, char *s)
.ps +2
.P2
.LP
Suppose that we want to modify the slider program to write the slider value using
text, near the left border of the slider window. This could be done by adding a line
to
.CW sliderthread ,
similar to this one
.P1
string(screen, pos, display->black, ZP, font, "68");
.P2
.LP
This draws the characters in the string
.CW "68"
on the image
.CW screen
(the destination image). The point
.CW pos
is the pixel where drawing starts. Each character is a small rectangular image.
The image for the first character has its top-left corner placed
at
.CW pos ,
and other characters follow to the right. The source image is
.I not
the image for the characters. The source image is the one for the black
color in this example. Character images are used as masks, so that black pixels
are drawn where each character shape determines that there has to be a pixel
drawn. To say it in another way, the source image is the one providing the pixels
for the drawing (e.g., the color). Characters decide just which pixels to draw.
The point given as
.CW ZP
is used to translate the image used as a source, like when calling
.CW draw .
Here, drawing characters in a solid color,
.CW ZP
.ix [ZP]
works just fine.
.PP
But where are the images for the characters? Even if they are used as masks,
there has to be images for them. Which images to use is determined by the
.CW Font
.ix [Font]
parameter.
.PP
A
.B font
is just a series of pictures (or other graphical descriptions) for runes or characters.
There are many fonts, and each one includes a lot of images for characters.
Images for font runes are kept in files under
.CW /lib/font .
Many files there include images just for a certain contiguous range of runes
(e.g., letters, numbers, symbols, etc.)
Other files, conventionally with names ending in
.CW .font ,
describe which ones of the former files are used by a font for certain ranges of unicode
values.
.PP
The
.I draw
library provides a data type representing a font, called
.CW Font .
It includes functions like
.P1
          Font* openfont(Display *d, char *file)
.P2
.ix [openfont]
.ix "font file
.LP
that reads a font description from the file given as an argument and
returns a pointer to a
.CW Font
that may be used to employ that font.
.PP
To use a loaded font, it suffices to give it as an argument to functions like
.CW string .
We used
.CW font ,
which is a global for the font used by default. To see which font you are using by default,
you may see which file name is in the
.CW $font
.ix [$font]
environment variable.
.P1
; echo $font
/lib/font/bit/VeraMono/VeraMono.12.font
.P2
.LP
That variable is used to locate the font you want to use. The window system supplies a
reasonable default otherwise.
.PP
The following function, that may be called from
.CW sliderthread ,
draws the slider value (given as a parameter) in the window.
.P1
.ps -1
void
writeval(int val)
{
	Point	sz, pos;
	char	str[5];	// "0%" to "100%"
	seprint(str, str+5, "%d%%", val);
	sz = stringsize(font, str);
	if (sz.x > Dx(screen->r)/2 || sz.y > Dy(screen->r))
		return;
	pos = screen->r.min;
	pos.x += 10;
	pos.y +=  (Dy(screen->r)- sz.y) / 2;
	string(screen, pos, display->black, ZP, font, str);
}
.ps +1
.P2
.LP
It prints the integer value as a string, in
.CW str .
adding a
.CW %
sign after the number.
The window could be so small (or perhaps the font so big) that there could be
not enough space to draw the text. The function
.CW stringsize
.ix [stringsize]
returns the size for a string in the given font. We use it to know how much
screen space will the string need. To avoid making our window too bizarre,
.CW writeval
does not draw anything when the window is not as tall as the
height for the string, that is, when
.CW "sz.y > Dy(screen->r)" .
Also, the string is not shown either when it needs more than the half of the
width available in the window.
.BS 2 "The window system
.LP
.ix "window system
.ix [rio]
.ix terminal
.ix console
A
.B window
is an abstraction provided by the window system,
.CW rio
in this case.
It mimics the behavior of a graphic terminal, including its own mouse and
keyboard input, and both text and graphics output.
.PP
In other systems, the abstraction used for windows differs from the one used for
the entire console. Programs must be aware of the window system, and use its
programming interface to create, destroy, and operate windows. 
.PP
Instead, the model used in Plan 9 is that each application uses the console,
understood as the terminal devices used to talk to the user, including
the draw device and the mouse. In this way, applications
may be kept unaware of where are they actually running (the console or a window).
Running the window system in a window is also a natural consequence of this.
.PP
.ix "console multiplexing
Nevertheless, it may be useful to know how to use the window system from a program.
Like other services, the window system is also a file server. You already know that
its primary task is to multiplex the files for the underlying console and mouse to provide
virtual ones, one per window. Such files are the interface for using the window, like
the real ones are the interface for using the real console.
.PP
Each time the
.CW rio
.ix "[rio] file~system
.ix "window creation
.ix "attach specifier
file system is mounted, it creates a new window. The attach specifier (the optional
file tree name given to mount) must be
.CW new ,
possibly followed by some flags for the newly created window.
.CW Rio
posts at a file in
.CW /srv
.ix [/srv]
a file descriptor that can be used to mount it. The name for this file is kept at
the environment variable
.CW $wsys .
.ix [$wsys]
Therefore, these commands create a new window. 
.P1
; echo $wsys
/srv/rio.nemo.557
; mount $wsys /n/rio new
.P2
.LP
After doing this, the screen might look like the one shown in figure [[!mounting rio!]],
where the empty window is the one that has just been created. Which files are
provided by \f(CWrio\fP? We are going to use the window were we executed the previous
commands to experiment at little bit.
.LS
.BP newwindow.ps
.LE F Mounting rio creates a new window. In this one, no shell is running.
.P1
; lc /n/rio
cons	kbdin	screen	wctl	winid
consctl	label	snarf	wdir	winname
cursor	mouse	text	window	wsys
.P2
.LP
We see
.CW cons ,
.CW consctl ,
.CW cursor ,
and
.ix [/dev/cons]
.ix [/dev/consctl]
.ix [/dev/cursor]
.ix [/dev/mouse]
.CW mouse ,
among others. They are virtual versions for the ones that were mounted at
.CW /dev
prior to running rio. The convention in Plan 9 is to mount the window system files
at
.CW /mnt/wsys ,
.ix [/mnt/wsys]
and not at
.CW /n/rio .
We use
.CW /n/rio
just to make it clear that these files come from the file tree that we have mounted.
In your system, you may browse
.CW /mnt/wsys
and you will see a file tree with same aspect.
.PP
Binding
.CW /n/rio
(before other files) at
.CW /dev 
will make any new process in our window to use not this window, but the new
one that we have created. So, these commands
.P1
; bind -b /n/rio /dev
; stats
.P2
.LP
cause
.CW stats
.ix [stats]
.ix "alternate window
.ix "new window
to use the new window instead of the one we had, like shown in figure
[[!Binding new window!]]. For
.CW stats ,
using the screen, mouse, and keyboard is just a matter of opening files at
.CW /dev .
It does not really care about where do the files come from. Regarding
.CW /dev/draw ,
that device multiplexes by its own means among multiple processes (each one
keeps a separate connection to the device, as we saw). The other files
are provided by \f(CWrio\fP.
.LS
.BP statswindow.ps
.LE F Binding the files for the new window at \f(CW/dev\fP makes \f(CWstats\fP use it.
.PP
Hitting
.I Delete
in the new window will not kill
.CW stats .
The window system does not know where to post the
.I interrupt
.ix "[interrupt] note
note for that window. To interrupt the program, we must hit
.I Delete
.ix [Delete]
in the old window, where the command was running. This can be fixed.
Unmounting the files for the new \f(CWrio\fP window will destroy it (nobody would be using
it). 
.P1
; unmount /n/rio /dev
; unmount /n/rio	\fRand the window goes away\fP
.P2
.LP
And now we mount \f(CWrio\fP again (creating another window). This time, we use the
option
.CW -pid
within the attach specifier to let \f(CWrio\fP know that notes for this window should go
the process group for the process with pid
.CW $pid .
.ix "window pid
That is, to our shell. Afterwards, we start
.CW stats
like before.
.P1
; mount $wsys /n/rio 'new -pid '$pid
; bind -b /n/rio /dev
; stats	\fRIt uses the new window\fP
; 	\fRUntil hitting \fP\fBDelete\fP\fR in that window\fP
.P2
.LP
This time, hitting
.I Delete
in either window will stop
.CW stats .
The new window has been instructed to post the note to the note process group
of our shell. It will do so. Our old window, of course, does the same.
.PP
In almost all the cases, the
.CW window
command (a script) is used to create new windows. It creates a new window
like we have done. Most of its arguments are given to \f(CWrio\fP to let it know where
to place the window and which pid to use to deliver notes.
.CW Window
.ix [window]
accepts as an argument the command to run in the new window, which is
.CW /bin/rc
by default. For example,
.P1
; window -r 0 0 90 100 stats
.P2
.LP
creates a new window in the rectangle going from the point (0,0) to the point
(90,100). It will run
.CW stats .
There is a C library,
.I window (2),
.ix "[window] library
that provides a C interface for creating windows (among other things related
to windows). The window system and the graphics library may use it,
but it is not likely you
will ever need to use it from your programs. Your programs are expected to
use their “console”, whatever that might be.
.PP
Going back to the files served by \f(CWrio\fP,
the files
.CW winid
and
.CW winname
.ix [/dev/winid]
.ix [/dev/winname]
contain strings that identify the window used. You can see them for the new
window at
.CW /n/rio .
And because of the (customary) bind of these files at
.CW /dev ,
you will always see them at
.CW /dev/winid
and
.CW /dev/winname .
In what follows, we will use file names at
.CW /dev ,
but it should be clear that they are provided by \f(CWrio\fP.
.P1
; cat /dev/winid
          3 ; 	\fInewline supplied by us\fP
; cat /dev/winname
window.3.3;  ; 	\fInewline supplied by us\fP
.P2
.LP
The window id, kept at
.CW winid ,
is a number that identifies the window. The directory
.CW /dev/wsys
.ix [/dev/wsys]
contains one directory per window, named after its identifier.
In our case, \f(CWrio\fP is running just
two windows. 
.P1
; lc /dev/wsys
1	3
; lc /dev/wsys/3
cons	kbdin	screen	wctl	winid
consctl	label	snarf	wdir	winname
cursor	mouse	text	window	wsys
.P2
.LP
Each window directory contains all the files we are accustomed to expect for
using the console and related devices. For each window,
.CW rio
makes its files
also available in its root directory, so that a bind of the
.CW rio
file system at
.CW /dev
will leave the appropriate files in
.CW /dev ,
and not just in
.CW /dev/wsys/3
or a similar directory.
.PP
The file
.CW winname
contains the name for the image in the draw device that is used as the screen
for the window. The draw device may keep names for images, and the window
system relies on this to coordinate with programs using windows. Rio creates
the image for each window, and gives a name to it that is kept also in
.CW winname .
The function
.CW getwindow ,
.ix [getwindow]
.ix [screen]
called by
.CW initdraw ,
uses this name to locate the image used for the window. That is how your
graphic programs know which images are to be used as their
.CW screens .
.PP
The file
.CW label
.ix [/dev/label]
.ix "window label
contains a text string for labeling the window. That is, the file
.CW /dev/label
for the current window, or
.CW /dev/wsys/3/label
for the window with identifier 3,
contain strings to let us know which program is using which window.
.P1
; cat /dev/label
rc 839; 
; cat /dev/wsys/3/label
stats; 
.P2
.LP
A convenience script,
.CW wloc ,
lists all the windows along with their labels.
.P1
; wloc
window -r 125 32 576 315 rc 839 # /dev/wsys/1
window -r 69 6 381 174 stats # /dev/wsys/3
;
.P2
.LP
Basically, it lists
.CW /dev/wsys
to see which windows exist, and reads
.CW /dev/label
for each one, to describe it. The following command would do something
similar.
.P1
; for (w in /dev/wsys/*)
;; echo window `{cat $w/label}
window rc 839
window stats
.P2
.LP
Other useful files are
.CW /dev/screen ,
.CW /dev/window ,
and
.CW /dev/text .
.ix "/dev/text
.ix "window text
They are provided for each window. The first one is an image for the entire
screen. It can be used to take a snapshot for it. The second one is the same,
but only for the window image. The last one contains all the text shown in the window
(although it is read-only). For example, this can be used to see the first three lines
in the current window.
.P1
; sed 3q /dev/text
;\ echo $wsys
/srv/rio.nemo.832
;\ mount $wsys /n/rio new
; 
.P2
.LP
Note that we only typed the first one.  The next command prints all the
.CW mount
commands that we executed in our window, assuming the prompt is the one
used in this book.
.P1
; grep '^; mount' /dev/text
;\ mount $wsys /n/rio new
.P2
.LP
In the same way, this executes the first
.CW mount
command that we executed in our window
.P1
; grep '^; mount' /dev/text | sed 1q | rc
.P2
.LP
Each window provides a control interface, through its
.CW wctl
.ix "[rio] menu
file. Many of the operations that can be performed by the user, using the
mouse and the menus provided by \f(CWrio\fP, can be performed through this file as well.
.PP
Windows may be hidden, to put them apart without occupying screen space
while they are not necessary by the moment. The
.I Hide
command from button-3 menu in \f(CWrio\fP hides a window. While hidden, the window label
is shown in that menu, and selecting it shows the window again. The next command
line
hides the window for 3 seconds using its control file.
.P1
; echo hide >/dev/wctl ; sleep 3 ; echo unhide >/dev/wctl
.I "hidden for 3 seconds... and back again!
;
.P2
.LP
.ix "window hide
We typed the three commands in the same line because after
.P1
; echo hide >/dev/wctl
.P2
.LP
the window would no longer be visible to accept input. This remains of the
.B "input focus" .
The window where you did click last is the one receiving keyboard input and mouse
input. The place where the window system sends input events is also known as the
.I focus
because you seem to be focusing on that window. Manually, focus can be changed
by using the mouse to click on a different window. From a program, the
.CW wctl
file can be used.
.P1
; echo current >/dev/wsys/3/ctl
.P2
.LP
Sets the focus to window
.CW 3 .
It is also said that window
.CW 3
becomes the
.I current
.ix "current window
window, hence the control command name. By the way, most of the control
operations done to a
.CW wctl
file make its window current. Only the
.CW top
and
.CW bottom
.ix "top window
.ix "bottom window
commands do not affect the focus.
.PP
.ix "window overlap
Windows may overlap. The window system maintains a stack of windows. Those
down in the stack are in the back, and may be obscured by windows more close
to the top of the stack (which are up front).
You
may reclaim a window to the top of the stack to make it fully visible. With the mouse,
a click on the window suffices. From a program, you can move it to the top easily.
.P1
; echo top >/dev/wsys/3/ctl
.P2
.LP
And also to the back, something that you cannot do directly using the mouse.
.P1
; echo bottom >/dev/wsys/3/ctl
.P2
.LP
By now, you know that windows may scroll down automatically or not, depending
on their scroll status, as selected by the
.ix "scroll mode
.I Scroll
and
.I Noscroll
options from their button-2 menu. This is how to do it through the control file,
this time, for window
.CW 3 .
.P1
; echo scroll >/dev/wsys/3/wctl	\fRputs the window  3 in scroll mode\fP
; echo noscroll >/dev/wsys/3/wctl
;
.P2
.LP
There are several other control commands described in the
.I rio (4)
manual page, including some that might seem to be available only when
using the mouse to perform them manually. The next command resizes a window
to be just 100 pixels wide.
.ix "window resize
.P1
; echo 'resize -dx 100' >/dev/wctl	\fRmake it 100 pixels wide\fP
.P2
.LP
It is not important to remember all the commands accepted, but it is to know
that they can be used to automate things that would have to be done manually
otherwise. Tired of manually adjusting a window, after running acme, to use most
available screen space? Just write a shell script for the task.
.PP
The first thing to be
done by the script is to determine how much space is available at our terminal.
This was recorded in
.CW $vgasize .
.ix [$vgasize]
.ix "screen size
Later, we can define variables for the width and height (in pixels) that we might use.
.P1
; echo $vgasize
1280x800x24
; wid=`{echo $vgasize | sed 's/x.*//'}
; echo $wid
1280
; ht=`{echo $vgasize | sed 's/.*x(.*)x.*/\1/'}
; echo $ht
800
.P2
.LP
Because most of the times we want some space to use \f(CWrio\fP (e.g., to recall
its menus), we may save 90 pixels from the height. To keep an horizontal
row with 90 pixels of height just for other \f(CWrio\fP windows and menus.
.P1
; ht=`{echo $ht - 90 | hoc}
; echo $ht
710
.P2
.LP
.ix "automatic layout
.ix "screen layout
And now, we can resize the window, placing it in the rectangle computed for our
screen.
.P1
echo resize -r 0 0 $wid $ht >/dev/wctl
.P2
.LP
The arguments for the
.CW move
and
.CW resize
commands (understood by the
.CW wctl
file) are similar to those of the
.CW window
command.
.PP
If in the future you find yourself multiple times carefully adjusting windows to
a particular layout that is easy to compute, you know what to do.
.SH
Problems
.IP 1
Record mouse events and try to reproduce them later.
.IP 2
Use the window system to provide virtual desktops. You do not need to implement
anything to answer this problem.
.IP 3
Write a program that implements console cooked mode by itself.
It must write to standard output one line at a time, but it must use raw mode.
.IP 4
Write a program that draws the pixels under the mouse while a button
is pressed.
.IP 5
Make the program draw text when a key is pressed. The text to draw is
the character typed and the position would be the last position given by
the mouse
.IP 6
There is an alternate library, called
.CW event
that provides event-driven mouse and keyboard processing. Implement
the previous programs using this library. Compare.
.IP 7
The
.CW /dev/kbmap
file provides keyboard maps. Look through the manual and try to change the map.
Locate one defining several keyboard keys as mouse buttons.
.ds CH
.bp
 \c

