.so tmacs
.BC 3 Files
.BS 2 "Input/Output
.ix "I/O
.LP
It is important to know how to use files. In Plan 9, this is even more important.
The abstractions provided by Plan 9 can be used through a file
interface. If you know how to use the file interface, you also know
how to use the interface for most of the abstractions that Plan 9 provides.
.PP
You already
know a lot about files. In the past, we have been using
.CW print
to write messages. And, before this course, you used the library of
your programming language to open, read, write, and close files.
We are going to learn now how to do the same, but using the
interface provided by the operating system. This is what your programming
language library uses to do its job regarding input/output.
.PP
Consider
.CW print ,
it is a convenience routine to
print formatted messages. It writes to a file, by calling
.ix "formatted output
.CW write .
.ix [write]
Look at this program:
.so progs/write.c.ms
.ix [write.c]
.LP
This is what it does. It does the same that
.CW print
would do given the same string.
.P1
; 8.write
hello
.P2
.LP
The function
.CW write
writes bytes into a file. Isn't it a surprise? To find out the declaration
for this function, we can use
.CW sig ⁱ.
.ix [sig]
.FS
ⁱ Remember that this program looks at the source of the manual pages, in section 2, to find
a function with the given name in any SYNOPSIS section of any manual
page. Very convenient to get a quick reminder of  which arguments receives
a system function, and what does it return.
.FE
.P1
; sig write
	long write(int fd, void *buf, long nbytes)
.P2
.LP
The
bytes written to the file come from
.CW buf ,
which was
.CW msg
in our example program. The number of bytes to write is specified by the
third parameter,
.CW nbytes ,
which was the length of the string in
.CW msg .
And the file were to write was specified by
the first parameter, which was just
.CW 1
for us.
.PP
Files have names, as we learned. We can use a full path, absolute or relative,
to name a file. Files being used by a particular process have “names” as well.
The names are called \fBfile descriptors\fP
.ix "file descriptor
.ix "file descriptor table
and are small integers. You know from your programming courses
that to read/write a file you
must open it. Once open, you may read and write it until the file is closed.
To identify an open file you use a small integer, its file descriptor. This integer
is used by the operating system as an index in a table of open files for
your process, to know which file to use for reading or writing. See figure
[[!standard file descriptors!]].
.LS
.PS
right
reset
boxht=.2
boxwid=1
circle rad .4 "Process"
spline -> right 1 then down "File descriptor" "table" 
D: [ down
 	[ right
	box invis  "0" ; F: box   ]
D0: last [].F
	[ right
	box invis  "1" ; F: box   ]
D1: last [].F
	[ right
	box invis  "2" ; F: box   ]
D2: last [].F
	[ right
	box invis  "3" ;  box invis   "..."]
	[ right
	box invis  "n" ; F: box   ]
]
spline -> from D.D0 right 1 then up then right ; box "Standard" "input" ht boxht*2
arrow from D.D1 right 1 then right ; box "Standard" "output" ht boxht*2
spline -> from D.D2 right 1 then down then right ; box "Standard" "error" ht boxht*2
reset
.PE
.LE F File descriptors point to files used for standard input, standard output, and standard error.
.PP
All processes have three files open right from the start,
by convention, even if they do not open a single file. 
These open files have the file descriptors  0, 1, and 2. As you could see,
file descriptor 1 is used for data output and is called
.B "standard output" ,
File descriptor 0 is used for data input and is called
.B "standard input" ,
File descriptor 2 is used for diagnostic (messages) output and is called
.B "standard error" .
.PP
To read an open file, you may call
.CW read .
.ix [read]
Here is the function declaration:
.P1
; sig read
	long read(int fd, void *buf, long nbytes)
.P2
.LP
It reads bytes from file descriptor
.CW fd
a maximum of
.CW nbytes
bytes and places the bytes read at the address pointed to by
.CW buf .
The number of bytes read is the value returned. Read does not guarantee that
we would get as many bytes as we want, it reads what it can and lets us know.
This program reads some
bytes
from standard input and later writes them to standard output.
.so progs/read.c.ms
.ix [read.c]
.LP
And here is how it works:
.P1
; 8.read
from stdin, to stdout!	\fI If you type this \fP
from stdin, to stdout!	\fI the program writes this\fP
.P2
.LP
When you run the program it calls
.CW read ,
which awaits until there is something to read. When you type a line and press return,
the window gives the characters you typed to the program. They are
stored by
.CW read
at
.CW buffer ,
and the number of bytes that it could read is returned and stored at
.CW nr .
Later, the program uses
.CW write
to write so many bytes into standard output, echoing what we wrote.
.PP
Many of the Plan 9 programs that accept file names as arguments work
with their standard input when given no arguments. Try running
.CW cat .
.P1
; cat
.I "...it waits until you type something
.P2
.LP
It reads what you type and writes a copy to its standard output
.ix [cat]
.P1
; cat
from stdin, to stdout!	\fI If you type this \fP
from stdin, to stdout!	\fI cat writes this\fP
and again
and again
\fBcontrol-d\fP
;
.P2
.LP
until reaching the end of the file. The end of file for a keyboard? There is
no such thing, but you can pretend there is. When you type a
.I control-d
by pressing the
.CW d
key while holding down
.I Control ,
.ix "control-d"
the program reading from the terminal gets an end of file.
.PP
Which file is standard input? And output? Most of the times, standard input,
standard output, and standard error go to
.CW /dev/cons .
.ix console
.ix "standard input
.ix "standard output
.ix "standard error
This file represents the
.I console
for your program. Like many other files in Plan 9, this is not a real (disk) file.
It is the interface to use the device that is known as the console, which
corresponds to your terminal. When
you read this file, you obtain the text you type in the keyboard. When you write
this file, the text is printed in the screen.
.PP
When used within the window system,
.CW /dev/cons
.ix [/dev/cons]
.ix "window
corresponds to a fake console invented just for your window. The window system
takes the real console for itself, and provides each window with a virtual console,
that can be accessed via the file
.CW /dev/cons
within each window. We can rewrite the previous program, but opening this
file ourselves.
.so progs/read2.c.ms
.ix [read.c]
.LP
This program behaves exactly like the previous one. You are invited to try.
To open a file, you must call
.CW open
.ix [open]
.ix "file name
.ix path
.ix "open mode
specifying the file name (or its path) and what do you want to do with the
open file. The integer constant
.CW ORDWR
. ix "[ORDWR] open~mode
means to open the file for both reading and writing.
This function returns a new
file descriptor to let you call
.CW read
.ix [read]
or
.CW write
.ix [write]
for the newly open file. The descriptor is a small integer that we store into
.CW fd ,
to use it later with
.CW read
and
.CW write .
Figure [[!descriptors opening!]] shows the file descriptors for the process running
this program after the call to
.CW open .
It assumes that the file descriptor for the new open file was 3.
.LS
.PS
right
boxwid=1
boxht=.2
circlerad=.5
circle  "Process"
spline -> right 1 then down "File descriptor" "table" 
D: [ down
 	[ right
	box invis  "0" ; F: box   ]
D0: last [].F
	[ right
	box invis  "1" ; F: box   ]
D1: last [].F
	[ right
	box invis  "2" ; F: box   ]
D2: last [].F
	[ right
	box invis  "3" ;  F: box    ]
DN: last [].F
	[ right
	box invis   ;  box invis   "..."]
	[ right
	box invis  "n" ; F: box   ]
]
move right 2 ; C: box "\f(CW/dev/cons\fP"
CC: circle invis  at C
spline -> from D.D1 right 1 then to CC chop
spline -> from D.D0 right 1 then to CC  chop
spline -> from D.D2 right 1 then   to CC  chop
spline -> from D.DN right 1 then   to CC  chop
reset
.PE
.LE F File descriptors for the program after opening \f(CW/dev/cons\fP.
.PP
When the file is no longer useful for the program, it can be closed. This
is achieved by calling
.CW close ,
.ix [close]
which releases the file descriptor.
In our program, we could have open
.CW /dev/cons
several times, one for reading and one for writing
.P1
infd = open("/dev/cons", OREAD);
outfd = open("/dev/cons", OWRITE);
.P2
.LP
using the integer constants
.CW OREAD
and
.CW OWRITE ,
.ix "[OREAD] open~mode
.ix "[OWRITE] open~mode
that specify that the file is to be open only for reading or writing. But it
seemed better to open the file just once.
.PP
The file interface provided for each process in Plan 9 has a file that provides
the list of open file descriptors for the process. For example, to know which file
descriptors are open in the shell we are using we can do this.
.ix "process [fd] file
.ix "file descriptor
.ix [$pid]
.P1
.ps -2
; cat /proc/$pid/fd
/usr/nemo
  0 r  M   94 (0000000000000001     0 00)  8192       18 /dev/cons
  1 w  M   94 (0000000000000001     0 00)  8192        2 /dev/cons
  2 w  M   94 (0000000000000001     0 00)  8192        2 /dev/cons
  3 r  c    0 (0000000000000002     0 00)     0        0 /dev/cons
  4 w  c    0 (0000000000000002     0 00)     0        0 /dev/cons
  5 w  c    0 (0000000000000002     0 00)     0        0 /dev/cons
  6 rw |    0 (0000000000000241     0 00) 65536       38 #|/data
  7 rw |    0 (0000000000000242     0 00) 65536 81320369 #|/data1
  8 rw |    0 (0000000000000281     0 00) 65536        0 #|/data
  9 rw |    0 (0000000000000282     0 00) 65536        0 #|/data1
 10 r  M   10 (00003b49000035b0 13745 00)  8168      512 /rc/lib/rcmain
 11 r  M   94 (0000000000000001     0 00)  8192       18 /dev/cons
;
.ps +2
.P2
.LP
The first line reports the current working directory for the process.
.ix "current directory
Each other line reports a file descriptor open by the process. Its number is listed on
the left.
As you could see, our shell has descriptors 0, 1, and 2 open (among others).
All these descriptors refer to the file
.CW /dev/cons ,
whose name is listed on the right for each descriptor. Another interesting information
is that the descriptor 0 is open just for reading (\f(CWOREAD\fP), because there is an
.ix "[OREAD] open~mode
.CW r
listed right after the descriptor number. And as you can see, both standard output
and error are open just for writing (\f(CWOWRITE\fP), because there is a
.CW w
.ix "[OWRITE] open~mode
printed after the descriptor number.
The
.CW /proc/$pid/fd
file is a useful information to track bugs related to file descriptor problems.
Which descriptors has the typical process open? If you are skeptic, this program
might help.
.so progs/sleep.c.ms
.ix [sleep.c]
.ix [sleep]
.LP
It prints its PID, and hangs around for one hour. After running this program
.P1
; 8.sleep
process pid is 1413. have fun.
.I "...and it hangs around for one hour."
.P2
.LP
we can use another window to inspect the file descriptors for the process.
.P1
.ps -2
; cat /proc/1413/fd
/usr/nemo/9intro
  0 r  M   94 (0000000000000001 0 00)  8192       87 /dev/cons
  1 w  M   94 (0000000000000001 0 00)  8192      936 /dev/cons
  2 w  M   94 (0000000000000001 0 00)  8192      936 /dev/cons
  3 r  c    0 (0000000000000002 0 00)     0        0 /dev/cons
  4 w  c    0 (0000000000000002 0 00)     0        0 /dev/cons
  5 w  c    0 (0000000000000002 0 00)     0        0 /dev/cons
  6 rw |    0 (0000000000000241 0 00) 65536       38 #|/data
  7 rw |    0 (0000000000000242 0 00) 65536 85044698 #|/data1
  8 rw |    0 (0000000000000281 0 00) 65536        0 #|/data
  9 rw |    0 (0000000000000282 0 00) 65536        0 #|/data1
.ps +2
.P2
.LP
Your process has descriptors 0, 1, and 2 open, as they should be. However,
it seems that there are many other ones open as well. That is why you cannot
assume that the first file you open in your program is going to obtain the
file descriptor number 3. It might already be open. You better be aware.
.PP
There is one legitimate question still pending. After we
open a file, how does
.CW read
know from where in the file it should read? The function knows how many
bytes we would like to read at most. But its parameters tell nothing
about the
.I offset
in the file where to start reading. And the same question applies to
.CW write
as well.
.PP
The answer comes from
.CW open ,
Each time you open a file, the system keeps track of
a
.B "file offset"
for that open file,
to know the offset in the file where to start working at the next
.CW read
or
.CW write .
Initially, this file offset is zero.
When you write, the offset is advanced the number of bytes you write.
When you read, the offset is also advanced the number of bytes you read.
Therefore, a series of writes would store bytes
.I sequentially ,
.ix "sequential access
one write at a time, each one right after the previous one. And the same happens
while reading.
.PP
The offset for a file descriptor can be changed using the
.CW seek
.ix [seek]
system call. Its second parameter can be 0, 1, or 2 to let you change the
offset to an absolute position, to a relative one counting from the old value, and
to a relative one counting from the size of the file. For example, this sets the offset in
.CW fd
to be 10:
.P1
seek(fd, 10, 0);
.P2
.LP
This advances the offset 5 bytes ahead:
.P1
seek(fd, 5, 1);
.P2
.LP
And this moves the offset to the end of the file:
.P1
seek(fd, 0, 2);
.P2
.LP
We did not use the return value from
.CW seek ,
but it is useful to know that it returns the new offset for the file descriptor.
.ix offset
.BS 2 "Write games
.LP
This program is a variant of the first one in this chapter, but writes
the salutation to a regular file, and not to the console
.so progs/fhello.c.ms
.ix [fhello.c]
.LP
We can create a file to play with by copying
.CW /NOTICE
.ix [/NOTICE]
to
.CW afile ,
and then run this program to see what happens.
.P1
; cp /NOTICE afile
; 8.fhello
.P2
.LP
This is what was at
.CW /NOTICE :
.P1
; cat /NOTICE
Copyright © 2002 Lucent Technologies Inc.
All Rights Reserved
;
.P2
.LP
and this is what is in
.CW afile :
.P1
; cat afile
hello
ght © 2002 Lucent Technologies Inc.
All Rights Reserved
.P2
.LP
At first sight, it seems that something weird happen. The file has one
.ix "new line
extra line. However, part of the original text has been lost. These two
things seem contradictory but they are not. Using
.CW xd
may reveal what happen:
.P1
; xd -c afile
0000000   h  e  l  l  o \en  g  h  t    c2 a9     2  0  0
0000010   2     L  u  c  e  n  t     T  e  c  h  n  o  l
0000020   o  g  i  e  s     I  n  c  . \en  A  l  l     R
0000030   i  g  h  t  s     R  e  s  e  r  v  e  d \en
000003f 
; xd -c /NOTICE
0000000   C  o  p  y  r  i  g  h  t    c2 a9     2  0  0
0000010   2     L  u  c  e  n  t     T  e  c  h  n  o  l
0000020   o  g  i  e  s     I  n  c  . \en  A  l  l     R
0000030   i  g  h  t  s     R  e  s  e  r  v  e  d \en
000003f 
.P2
.LP
Our program opened
.CW afile ,
which was a copy of
.CW /NOTICE ,
and then it wrote “\f(CWhello\en\fP”. After the call to
.CW open ,
.ix [open]
the file offset for the new open file was set zero. This means that
.CW write
.ix [write]
wrote 6 bytes into
.CW afile
starting at offset 0. The first six bytes in the file, which
contained “\f(CWCopyri\fP”, have been overwritten by our
program.
But
.CW write
did just what it was expected to do. Write 6 bytes
into the file starting at the file offset (0). Nothing more,
nothing less. It does not truncate the file (it shouldn't!). It
does not
.I insert .
It just writes.
.PP
If we change the program above, adding a second call to
.CW write ,
so that it executes this code
.P1
write(fd, "hello\en");
write(fd, "there\en");
.P2
.LP
we can see what is inside
.CW afile
after running the program.
.P1
; cat afile
hello
there
 2002 Lucent Technologies Inc.
All Rights Reserved
.P2
.P1
; xd -c afile
0000000   h  e  l  l  o \en  t  h  e  r  e \en     2  0  0
0000010   2     L  u  c  e  n  t     T  e  c  h  n  o  l
0000020   o  g  i  e  s     I  n  c  . \en  A  l  l     R
0000030   i  g  h  t  s     R  e  s  e  r  v  e  d \en
000003f 
.P2
.ix [xd]
.LP
After the first call to
.CW write ,
the file offset was 6. Therefore, the second write happen
.ix "file offset
starting at offset 6 in the file. And it wrote six more bytes.
Once more, it did just its job, write bytes. The file length
is the same. The number of lines changed because the
number of newline characters in the file changed. The console
advances one line each time it encounters a newline, but
it is just a single byte.
.PP
Figure [[!file offset!]] shows the elements involved in writing this file, after
the first call to
.CW write ,
and before the second call. The file descriptor, which we assume was 3, points
to a data structure containing information about the open file. This data
structure keeps the file offset, to be used for the following
.CW read
or
.CW write
operation, and record what the file was open for, e.g.,
.CW OWRITE .
.ix "[OWRITE] open~mode
Plan 9 calls this data structure a
.CW Chan
(Channel),
.ix [Chan]
and there is one per file in use in the system. Besides the offset and the open
mode, it contains all the information needed to let the kernel reach the file
server and perform operations on the file. Indeed, a Chan is just something used by
Plan 9 to speak to a server regarding a file. This may require doing remote
.ix 9P
.ix "file server
.ix "channel
procedure calls across the network, but that is up to your kernel, and you can
forget it.
.LS
.PS
.CW
down
boxwid=.2
boxht=.2
circle rad .4 "\fRProcess\fP"
line -> down " \fRFile descriptor\fP" ljust  " \fRtable\fP" ljust
D: [ down
 	[ right
	box invis  "0" ; F: box wid 1  ]
D0: last [].F
	[ right
	box invis  "1" ; F: box wid 1  ]
D1: last [].F
	[ right
	box invis  "2" ; F: box wid 1  ]
D2: last [].F
	[ right
	box invis  "3" ;  F: box  wid 1  ]
D3: last [].F
	[ right
	box invis   ;  box invis wid 1  "..."]
	[ right
	box invis  "n" ; F: box wid 1  ]
]
arrow -> from D.D3 right 1
C: box wid 1.5 ht 3*boxht
down
X: [ down
	O: box  invis   "offset: 6" ljust
	    box  invis   "mode: OWRITE " ljust
	F: box  invis   "file: " ljust
] with .nw at C.nw
line invis from X.F.e right .5
A: [ spline ->  right then down then left then down ] with .nw at last line.e
H: [ right
.R
	box   "h"
	box   "e"
	box   "l"
	box   "l"
	box   "o"
	box   "\en"
S:	box wid .6  "..."
.R
] with .nw at A.sw
box invis wid .75 "afile"
line invis from X.O.e right 1; spline ->   right then right then to H.S.nw dotted
box invis  "\fRChan\fP" with .sw at C.nw
.R
reset
.PE
.LE F The file offset for next operations is kept separate from the file descriptor.
.PP
We can use
.CW seek
.ix [seek]
to write at a particular offset in the file. For example, the following
code writes starting at
offset 10 into our original version of
.CW afile .
.P1
int	fd;

fd = open("afile", OWRITE);
seek(fd, 10, 0);
write(fd, "hello\en", 6);
close(fd);
.P2
.LP
The contents of
.CW afile
have six bytes changed, as it could be expected.
.ix [xd]
.P1
; xd -c afile
0000000   C  o  p  y  r  i  g  h  t     h  e  l  l  o \en
0000010   2     L  u  c  e  n  t     T  e  c  h  n  o  l
0000020   o  g  i  e  s     I  n  c  . \en  A  l  l     R
0000030   i  g  h  t  s     R  e  s  e  r  v  e  d \en
000003f 
.P2
.LP
How can we write new contents into
.CW afile ,
getting rid of anything that could be in the file before we write? Simply by
specifying to
.CW open
that we want to
.B truncate
the file besides opening it. To do so, we can do a bit-or of the desired open mode
and
.CW OTRUNC ,
.ix "[OTRUNC] open~mode
a flag that requests file truncation. This program does so, and writes a new string into
our file. 
.so progs/thello.c.ms
.ix [thello.c]
.LP
After running this program,
.CW afile
contains just the 6 bytes we wrote:
.P1
; 8.thello
; cat afile
hello
;
.P2
.LP
The call to
.CW open ,
caused the file
.CW afile
to be truncated. If was empty, open for writing on it, and the offset for
the next file operation was zero. Then,
.CW write
wrote 6 bytes, at offset zero. At last, we closed the file.
.PP
What would the following program do to our new version of
.CW afile ?
.so progs/seekhello.c.ms
.ix [seek]
.ix [seekhello.c]
.LP
All system calls are very obedient. They do just what they are asked to do.
The call to
.CW seek
changes the file offset to 32. Therefore,
.CW write
must write six bytes at offset 32. This is the output for
.CW ls
and
.CW xd
on the new file after running this program:
.P1
; 8.seekhello
; ls -l afile
--r--r--r-- M 19 nemo nemo 38 Jul  9 18:14 afile
; xd -c afile
0000000   h  e  l  l  o \en 00 00 00 00 00 00 00 00 00 00
0000010  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0000020   t  h  e  r  e \en
0000026 
.P2
.LP
The size is 38 bytes. That is the offset before
.CW write ,
.ix [write]
32, plus the six bytes we wrote. In the contents you see how all the
bytes that we did not write were set to zero by Plan 9. And we know a new
thing: The size of a file corresponds to the highest file offset ever written on it.
.PP
A variant of this program can be used to create files of a given size. To create a
1 Gigabyte file you do not need to write that many bytes. A single write suffices
with just one byte. Of course, that write must be performed at an offset of
1 Gigabyte (minus 1 byte).
.PP
Creating large files in this way is different from writing all the zeroes yourself.
First, it takes less time to create the file, because you make just a couple of
system calls. Second, it can be that your new file does
.I not
consume all its space in the disk until you really use it. Because Plan 9 knows
.ix "disk space
the new size of the file, and it knows you never did write most of it, it can just record
the new size and allocate disk space only for the things you really wrote. Reading
other parts of the file yield just zeroes. There is no need to store all those zero bytes
in the disk.
.PP
This kind of file (i.e., one created using
.CW seek
and
.CW write ),
is called a
.B "file with holes".
The name comes from considering that the file has “holes” on it, where
you did never write anything. Of course, the holes are not really stored in a disk.
It is funny to be able to store files for a total amount of bytes that exceeds the
disk capacity, but now you know that this can happen.
.PP
To append some data to a file, we can use
.CW seek
to set the offset at the end of the file before calling write, like in
.P1
fd = open("afile", OWRITE);
seek(fd, 0, 2);	// move to the end
write(fd, bytes, nbytes);
.P2
.LP
For some files, like log files used to append diagnostic messages, or mail folders,
used to append mail messages, writing should always happen at the end of
the file. In this case, it is more appropriate to use an
.B "append only"
permission bit supported by the Plan 9 file server:
.ix [chmod]
.ix "[chmod] flag~[+a]
.P1
.ps -1
; chmod +a /sys/log/diagnostics
; ls -l /sys/log/diagnostics
a-rw-r--r-- M 19 nemo nemo 0 Jul 10 01:11 /sys/log/diagnostics
.ps +1
.P2
.LP
This guarantees that any write will happen at the end of existing data,
no matter what the offset is. Doing a
.CW seek
in all programs using this file might not suffice. If there are multiple machines
writing to this file, each machine would keep its own offset for the file. Therefore,
there is some risk of overwriting some data in the file. However,
using the
.CW +a
permission bit fixes this problem once and for all.
.BS 2 "Read games
.LP
To read a file it does not suffice to call
.CW read
once. This point may be missed when using this function for the first few times.
The problem is that
.CW read
does no guarantee that all the bytes in the file could be read in the first call.
For example, early in this chapter we did read from the console. Before typing
a line, there is no way for
.CW read
to obtain its characters. The result in that when reading from the console our
program did read one line at a time. If we change the program to read from
a file on a disk, it will probably read as much as it fits in the buffer we supply for
reading.
.PP
Usually, we are supposed to call
.CW read
until there is nothing more to read. That happens when the number of bytes
read is zero. For example, this program reads the whole file
.CW /NOTICE ,
and prints what it can read each time. The program is unrealistic, because usually
you should employ a much larger read buffer. Memory is cheap these days.
.so progs/nread.c.ms
.ix [nread.c]
.LP
Although we did not check out error conditions in most of the programs in this
chapter. This program does so. When
.CW open
fails ,
it returns
.CW -1 .
The program issues a diagnostic and terminates if that is the case.
Also,
after calling
.CW read ,
it does not just check for
.CW "nr == 0" ,
which means that there is nothing more to read. Instead, it checks for
.CW "nr <= 0" ,
because
.CW read
returns
.CW -1
when it fails.
The call to
.CW write
might fail as well. It returns the number of bytes that could be written, and it
is considered an error when this number differs from the one you specified.
.BS 2 "Creating and removing files
.LP
The
.CW create
.ix [create]
.ix "file creation
system call creates one file. It is very similar to
.CW open .
.ix [open]
After creating the file, it returns an open file descriptor for the new file,
using the specified mode. It accepts the same parameters used for open,
plus an extra one used to specify permissions for the new file encoded as
a single integer.
.PP
This program creates its own version of
.CW afile ,
without placing on us the burden of creating it. It does not check errors,
because it is just an example.
.so progs/create.c.ms
.ix [create.c]
.LP
To test it, we remove our previous version for
.CW afile ,
run this program, and ask
.CW ls
and
.CW cat
to print information about the file and its contents.
.P1
; rm afile
; ls afile
ls: afile: 'afile' file does not exist
; 8.create
; ls -l afile
--rw-r--r-- M 19 nemo nemo 11 Jul  9 18:39 afile
; cat afile
a new file
.P2
.LP
In fact, there was no need to remove
.CW afile
before running the program. If the file being created exists,
.CW create
.ix "truncate
truncates it. If it does not exist, the file is created. In either case,
we obtain a new file descriptor for the file.
.PP
Directories can be created by doing a bit-or of the integer constant
.ix "directory creation
.ix [DMDIR]
.CW DMDIR
with the rest of the permissions given to
.CW create .
This sets a bit (called DMDIR) in the integer used to specify permissions, and
the system creates a directory instead of a file.
.P1
fd = create("adir", OREAD, DMDIR|0775);
.P2
.LP
You cannot write into directories.
That would be dangerous. Instead, when you create and remove files within
the directory, Plan 9 updates the contents of the directory file for you. If you
modify the previous program to try to create a directory, you must remove
the line calling
.CW write .
But you should still close the file descriptor.
.PP
Removing a file is simple. The system call
.CW remove
.ix [remove]
.ix "file deletion
removes the named file. This program is similar to
.CW rm .
.ix [rm]
.so progs/rm.c.ms
.ix [rm.c]
.LP
It can be used like the standard
.I rm (1)
tool, to get rid of multiple files. When
.CW remove
fails it alerts the user of the problem.
.P1
; 8.rm rm.8 x.c afile
8.rm:  'x.c' file does not exist
.P2
.LP
Like other calls,
.CW remove
returns
.CW -1
.ix "system call error
when it fails. In this case we print the program name (\f(CWargv[0]\fP)
and the error string. That suffices to let the user know what happen and
.ix "error string
take any appropriate action. Note how the program iterates through command
line arguments starting at 1. Otherwise, it would remove itself!
.PP
A directory that is not empty, and contains other files, cannot be removed using
.ix "empty directory
.CW remove .
To remove it, you must remove its contents first. Plan 9 could remove the whole
file tree rooted at the directory, but it would be utterly dangerous. Think about
.CW "rm /" .
The system command
.CW rm
accepts option
.CW -r
.ix "[rm] flag~[-r]
to recursively descend the named file and remove it and all of its contents. It must
be used with extreme caution. When a file is removed, it is gone. There is nothing
you can do to bring it back to life. Plan 9 does not have a
.I wastebasket .
.ix wastebasket
If you are not sure about removing a file, just don't do it. Or move it to
.CW /tmp
or to some other place where it does not gets in your way.
.PP
Now that we can create and remove files, it is interesting to see if a file does exist.
This could be done by opening the file just to see if we can. However, it is more
appropriate to use a system call intended just to check if we can access a file.
It is called, perhaps surprisingly,
.CW access .
.ix [access]
.ix "checking~for access
For example, this code excerpt aborts the execution of its program when
the file name in
.CW fname
does not exist:
.P1
if (access(fname, AEXIST) < 0)
	sysfatal("%s does not exist", fname);
.P2
.LP
.ix "[AEXIST] access~mode
The second parameter is an integer constant that indicates what do you want
.CW access
to check the file for. For example,
.CW AWRITE
.ix "[AWRITE] access~mode
checks that you could open the file for writing,
.CW AREAD
.ix "[AREAD] access~mode
does the same for reading, and
.CW AEXEC
.ix "[AEXEC] access~mode
does the same for executing it.
.BS 2 "Directory entries
.LP
Files have data. There are many examples above using
.CW cat
and
.CW xd
to retrieve the data stored in a file. Besides, files have
.B metadata ,
i.e., data about the data. File metadata is simply what the system
needs to know about the file to be able to implement it. File metadata
includes the file name, the file size, the time for the last modification to the file,
the time for the
last access to the file, and other attributes for the file. Thus, file
metadata is also known as
.B "file attributes" .
.PP
Plan 9 stores attributes for a file in the directory that contains the file. Thus, the
data structure that contains file metadata is known as a
.B "directory entry" .
A directory
contains just a sequence of entries, each one providing the attributes for a file
contained in it. Let's see this in action:
.P1
; lc
; cat .
;
.P2
.LP
An empty directory is an empty file.
.P1
; touch onefile
; xd -c .
0000000   B 00  M 00 13 00 00 00 00 00 00 00 00 bf a1 01
0000010  00 00 00 00 00 a4 01 00 00 \er  I b1  D \er  I b1
0000020   D 00 00 00 00 00 00 00 00 07 00  o  n  e  f  i
0000030   l  e 04 00  n  e  m  o 04 00  n  e  m  o 04 00
0000040   n  e  m  o
0000044 
.P2
.LP
After creating
.CW onefile
in this empty directory, we see a whole bunch of bytes in the
directory. Nothing that we could understand by looking at them,
although you can see how there are several strings, including
.CW nemo
and
.CW onefile
within the data kept in the directory.
.PP
For each file in the directory, there is an entry in the directory to describe
the file.
The format
is independent of the architecture used, which means that the format
.ix "architecture independent
.ix "network format
is the same no matter the machine that stored the file. Because the machine
using the directory (e.g., your terminal) may differ from the machine keeping
the file (e.g., your file server), this is important. Each machine could use a
different format to encode integers, strings, and other data types.
.PP
We can double-check our belief by creating
a second file in our directory. After doing so, the directory has twice the size:
.P1
; touch another
; xd -c .
0000000   B 00  M 00 13 00 00 00 00 00 00 00 00 c0 a1 01
0000010  00 00 00 00 00 a4 01 00 00  !  I b1  D  !  I b1
0000020   D 00 00 00 00 00 00 00 00 07 00  a  n  o  t  h
0000030   e  r 04 00  n  e  m  o 04 00  n  e  m  o 04 00
0000040   n  e  m  o  B 00  M 00 13 00 00 00 00 00 00 00
0000050  00 bf a1 01 00 00 00 00 00 a4 01 00 00 \er  I b1
0000060   D \er  I b1  D 00 00 00 00 00 00 00 00 07 00  o
0000070   n  e  f  i  l  e 04 00  n  e  m  o 04 00  n  e
0000080   m  o 04 00  n  e  m  o
0000088 
.P2
.LP
When programming in C, there are convenience functions that convert this
portable (but not amenable) data structure into a C structure. The C
data type declared in
.CW libc.h
.ix [libc.h]
.ix "C library
that describes a directory entry is as follows:
.P1
typedef
struct Dir {
	/* system-modified data */
	ushort	type;	/* server type */
	uint	dev;	/* server subtype */
	/* file data */
	Qid	qid;	/* unique id from server */
	ulong	mode;	/* permissions */
	ulong	atime;	/* last read time */
	ulong	mtime;	/* last write time */
	vlong	length;	/* file length */
	char	*name;	/* last element of path */
	char	*uid;	/* owner name */
	char	*gid;	/* group name */
	char	*muid;	/* last modifier name */
} Dir;
.P2
.ix [Dir]
.LP
From the shell, we can use
.CW ls
.ix [ls]
to obtain most of this information. For example,
.P1
; ls -lm onefile
[nemo] --rw-r--r-- M 19 nemo nemo 0 Jul  9 19:24 onefile
.P2
.IP •
The file name is
.CW onefile .
The field
.CW name
.ix "file name
within the directory entry is a string with the name. Just with the name. An
absolute path to refer
to this file would include all the names from that of the root directory down to
the file; each component separated by a slash. But the file name is just
.CW onefile .
.IP •
The times for the last access and for the last modification of the file (this one
printed by
.CW ls )
are kept at
.CW atime
.ix "file access time
and
.CW mtime
.ix [mtime]
.ix "file modification time
respectively. These dates are codified in seconds since the epoch, as we saw for
.CW /dev/time .
.ix [/dev/time]
.IP •
The length for the file is zero. This is stored at field
.CW length
.ix "file length
in the directory entry.
The file is owned by user
.CW nemo
.ix "file owner
.ix "file group
.ix "permissions
and belongs to the group
.CW nemo .
These values are stored as string, using the fields
.CW uid
.ix [uid]
.ix "user id
(user id)
and
.CW gid
.ix [gid]
.ix "group id
(group id)
respectively.
.IP •
The field
.CW mode
.ix "file mode
records the file permissions, also known as the mode (that is why
.CW chmod
.ix [chmod]
has that name, for “change mode”).
Permissions are encoded in a single integer, as we saw. For
.ix "octal permissions
this file mode would be
.CW 0644 .
.IP •
The file was last modified by user
.CW nemo ,
and this value is encoded as a string in the directory entry, using field
.CW muid
(modification user id).
.ix "modification user id
.IP •
The fields
.CW type ,
.CW dev ,
and
.CW qid
.ix QID
identify the file. They deserve a separate explanation on their own that we defer
by now.
.LP
To obtain the directory entry for a file, i.e., its attributes, we can use
.CW dirstat .
.ix [dirstat]
This function uses the actual system call,
.CW stat ,
.ix [stat]
to read the data, and 
returns a
.CW Dir
.ix [Dir]
structure that is more convenient to use in C programs. This structure is stored
in dynamic memory allocated with
.CW malloc
.ix [malloc]
by
.CW dirstat ,
and the caller is responsible for calling
.CW free
.ix [free]
on it.
.PP
The following program gives some information about
.CW /NOTICE ,
nothing that
.CW ls
could not do, and produces this output when run:
.P1
; 8.stat
file name: NOTICE
file mode: 0444
file size: 63 bytes
;
.P2
.so progs/stat.c.ms
.ix [stat.c]
.ix [stat]
.LP
Note that the program called
.CW free
only once, for the whole
.CW Dir .
.ix [Dir]
The strings pointed to by fields in the structure are stored along with the
structure itself in the same
.CW malloc -allocated
memory. Calling
.CW free
once suffices.
.PP
An alternative to using this function is using
.CW dirfstat ,
.ix [dirfstat]
which receives a file descriptor instead of a file name. This function calls
.CW fstat ,
.ix [fstat]
which is another system call similar to
.CW stat
.ix [stat]
(but receiving a file descriptor instead of a file name).
Which one to use depends on what do you have at hand, a name, or a
file descriptor.
.PP
Because directories contain directory entries, reading from a directory
is very similar to what we have just done. The function
.CW read
.ix "directory read
can be used to read directories as well as files. The only difference is that
the system will read only an integral number of directory entries. If one more
entry does not fit in the buffer you supply to
.CW read ,
it will have to wait until you read again.
.PP
The entries are stored in the directory
in a portable, machine independent, and not amenable, format. Therefore,
instead of using
.CW read ,
it is more convenient to use
.CW dirread .
.ix [dirread]
This function calls
.CW read
to read the data stored in the directory. But before returning to the caller, it
.I unpacks
.ix "network format
them into a, more convenient,
array of
.CW Dir
structures.
.PP
As an example, the next program lists the current directory, using
.CW dirread
to obtain the entries in it.
.PP
Running the program yields the following output. As you can see, the directory
was being used to keep a few C programs and compile them.
.P1
; 8.lsdot
8.lsdot
create.8
create.c
lsdot.8
lsdot.c
;
.P2
.so progs/lsdot.c.ms
.ix [lsdot.c]
.LP
The array of directory entries is returned from
.CW dirread
using a pointer parameter passed by reference
(We know, C passes all parameters by value; The function receives a pointer
to the pointer). Such array is allocated by
.CW dirread
using
.CW malloc ,
like before. Therefore, the caller must call
.CW free
(once) to release this memory.
The number of entries in the array is the return value for the function.
Like
.CW read
would do, when there are no more entries to be read, the function returns zero.
.PP
Sometimes it is useful to change file attributes. For example,
changing the length to zero may truncate the file. A rename within the
same directory can be achieved by changing the name in the directory entry.
Permissions can be changed by updating the mode in the directory entry.
Some of the attributes cannot be updated. For example, it is illegal to change
the modification type, or any of the
.CW type ,
.CW dev ,
and
.CW qid
fields.
.PP
The function
.CW dirwstat
.ix [dirwstat]
is the counterpart of
.CW dirstat .
.ix [dirstat]
It works in a similar way, but instead of reading the attributes, it updates them.
New values for the update are taken from a
.CW Dir
structure given as a parameter. However, the function ignores any field set
to a null value, to allow you to change just one attribute, or a few ones.
Beware that zero is not a null value for some of the fields, because it would
be a perfectly legal value for them. The function
.CW nulldir
is to be used to null all of the fields  in a given
.CW Dir .
.PP
Here is an example. The next program is similar to
.CW chgrp (1),
change group,
.ix [chgrp]
and can be used to change the group for a file. The
.CW main
function iterates through the file name(s) and calls a
.CW chgrp
function to do the actual work for each file.
.so progs/chgrp.c.ms
.ix [chgrp.c]
.LP
The interesting part is the implementation of the
.CW chgrp
function. It is quite simple.
Internally,
.CW dirwstat
.I packs
the structure into the portable format, and calls
.CW wstat
.ix [wstat]
(the actual system call). As a remark, there is also a
.CW dirfwstat
.ix [dirfwstat]
variant, that receives a file descriptor instead of a file name. It is the
counterpart of
.CW dirfstat
and uses the
.CW fwstat
.ix [fwstat]
system call.
Other attributes in the directory entry can be updated as done above
for the group id.
.LP
The resulting program can be used like the real
.I chgrp (1)
.P1
; 8.chgrp planb chgrp.c chgrp.8
; ls -l chgrp.c chgrp.8
--rw-r--r-- M 19 nemo planb 1182 Jul 10 12:09 chgrp.8
--rw-r--r-- M 19 nemo planb  377 Jul 10 12:08 chgrp.c
;
.P2
.BS 2 "Listing files in the shell
.LP
It may be a surprise to find out that there is now a section
with this title. You know all about listing files. It is a matter
of using
.CW ls
.ix [ls]
.ix [lc]
.ix "file list
.ix "directory list
and other related tools. Well, there is something else. The
shell on its own knows how to list files, to help you type names.
Look at this session:
.P1
; cd $home
; lc
bin	lib	tmp
; echo *
bin lib tmp
.P2
.LP
First, we used
.CW lc
to list our home. Later, we used just the shell. It is clear that
.CW echo
is simply echoing its arguments. It knows nothing about listing files.
Therefore, the shell had to supply
.CW bin ,
.CW lib ,
and
.CW tmp ,
as the arguments for
.CW echo
(instead of supplying the “\f(CW*\fP”).
It could be either the shell or echo the one responsible for this behavior.
There is no magic, and no other
program was involved on this command line.
.PP
The shell gives special meaning to certain characters (we already saw
two: “\f(CW$\fP”, and “\f(CW'\fP”). One of them is “\f(CW*\fP”. When the
a command line contains a word that is “\f(CW*\fP”, it is replaced with
the names for all the files in the current directory. Indeed, “\f(CW*\fP”
works for all directories:
.P1
; lc bin
386	rc
; echo bin/*
bin/386 bin/rc
;
.P2
.LP
.ix [echo]
.ix "shell variable
.ix "environment variable
.ix "variable expansion
In this case, the shell replaced
.CW bin/*
with two names before running echo:
.CW bin/386
and
.CW bin/rc .
This is called
.B globbing ,
and it works as follows.
When the shell reads a command line, it looks for
.B "file name patterns" .
A pattern is an expression that describes file names. It can be just a file name, but
useful patterns can include special characters like “\f(CW*\fP”.
The shell replaces the pattern
with all file names
.B matching
the pattern.
.PP
For example,
.CW *
.ix "[*] pattern
matches with any sequence of characters not containing “\f(CW/\fP”.
Therefore, in this directory
.P1
; lc
bin	book	lib	tmp
.P2
.LP
the pattern
.CW *
matches with
.CW bin ,
.CW book ,
.CW lib ,
and
.CW tmp :
.P1
; echo *
bin book lib tmp
.P2
.LP
The pattern
.CW b*
matches with any file name that has an initial “\f(CWb\fP” followed by  “\f(CW*\fP”,
i.e, followed by anything. This means
.P1
; echo b*
bin book
.P2
.LP
The pattern
.CW *i*
matches with anything, then an
.CW i ,
and then anything:
.P1
; echo *i*
bin lib
.P2
.LP
Another example
.P1
; echo *b*
bin book lib
.P2
.LP
showing that the part of the name matched by
.CW *
can be also an empty string! Patterns like this one mean
.I "the file name has a
.CW b
.I "in it" .
.PP
Patterns may appear within path names, to match against
.ix "file name
different levels in the file tree. For example, we might want to
search for the file containing
.CW ls ,
and this would be a brute force approach:
.P1
; ls /ls
ls: /ls: '/ls' file does not exist
.P2
.LP
Not there. Let's try one level down
.P1
; ls /*/ls
/bin/ls
.P2
.LP
Found! But let's assume it was not there either.
.ix "file searching
.P1
; ls /*/*/ls
.P2
.LP
It might be at
.CW /usr/bin/ls .
Not in a Plan 9 system, but we did not know. Each
.CW *
in the pattern
.CW /*/*/ls
matches with any file name. Therefore, this patterns
means
.I "any file named
.CW ls ,
.I "inside any directory, which is inside any directory that
.I "is found at
.CW / .
.PP
This mechanism is very powerful. For example, this directory
contains a lot of source and object files. We can use a pattern
to remove just the object files.
.P1
; lc
8.out	echo.c	err.c		open.c
echo.8	err.8	open.8		sleep.c
; rm *.8
.P2
.LP
The shell replaced the pattern
.CW *.8
with any file name terminated with
.CW .8 .
.ix [rm]
Therefore,
.CW rm
received as arguments all the names for object files.
.P1
; lc
8.out	echo.c	err.c	open.c	sleep.c
.P2
.LP
Patterns may contain a “\f(CW?\fP”, which matches a single character.
.ix "[?] pattern
For example, we know that the linkers generate output files named
.CW 8.out ,
.CW 5.out ,
etc. This removes any temporary binary that we might have in the
directory:
.P1
; rm ?.out
.P2
.LP
Any file name containing a single character, and then
.CW .out ,
matches this pattern. The shell replaces the pattern with appropriate file names, and
then executes the command line. If no file name matches the pattern, the pattern itself
is untouched by the shell and used as the command argument. After the previous command,
if we try again
.P1
; rm ?.out
rm: ?.out: '?.out' file does not exist
.P2
.LP
Another expression that may be used in a pattern is a series of characters between
square brackets. It matches any single character within the brackets. For example,
.ix "character range pattern
instead of using
.CW ?.out
we might have used
.CW [58].out
in the command line above. The only file names matching this expression are
.CW 5.out
and
.CW 8.out ,
which were the names we meant.
.PP
Another example. This lists any C source file
(any string followed by a single dot, and then either a
.CW c
or an
.CW h ).
.P1
; lc *.[ch]
.P2
As a shorthand, consecutive letters or numbers within the brackets may be
abbreviated by using a
.CW -
between just the first and the last ones. An example is
.CW [0-9] ,
which matches again any single digit.
.PP
The directory
.ix "file dump
.ix "file archive
.ix [/n/dump]
.CW /n/dump
keeps a file tree that uses names reflecting dates, to keep a copy
of files in the system for each date. For example,
.CW /n/dump/2002/0217
is the path for the dump (copy) made in February 17th, 2002.
The command below uses a pattern to list directories
for dumps  made the 17th of any month not after June, in a
year beyond 2000, but ending in 2 (i.e.,
just 2002 as of today).
.P1
; ls /n/dump/2*2/0[1-6]17
/n/dump/2002/0117
/n/dump/2002/0217
/n/dump/2002/0317
/n/dump/2002/0417
/n/dump/2002/0517
/n/dump/2002/0617
.P2
.LP
In general, you concoct patterns to match on file names that may
be of interest for you. The shell knows nothing about the meaning of
the file names. However, you can exploit patterns in file names using
file name patterns. Confusing?
.PP
To ask the shell not to touch a single character in a word that might
be otherwise considered a pattern, the word must be quoted. For example,
.ix "quoting
.P1
; lc
bin	lib	tmp
; touch '*'
; echo *
* bin lib tmp
.P2
.LP
Because the
.CW *
for
.CW touch
was quoted, the shell took it verbatim. It was not interpreted as a pattern. However,
in the next command line it was used unquoted and taken as a pattern.
Removing the funny file we just created is left as an exercise. But be careful. Remember
what
.ix [rm]
.P1
; rm *
.P2
would do!
.BS 2 "Buffered Input/Output
.ix "buffered I/O
.LP
The interface provided by
.CW open ,
.CW close ,
.CW read ,
and
.CW write
.ix [open]
.ix [close]
.ix [read]
.ix [write]
suffices many times to do the task at hand. Also, in many cases, it is just the
more convenient interface for doing I/O to files. For example,
.CW cat
.ix [cat]
must just write what it reads. It is just fine to use
.CW read
and
.CW write
for implementing such a tool.
But, what if our program had to read one byte at a time? or one line at a time?
We can experiment using the program below. It is a simple
.CW cp ,
.ix [cp]
.ix "file copy
that copies one file into another, but using the size for the buffer that we supply
as a parameter.
.so progs/bcp.c.ms
.ix [bcp.c]
.LP
We are going to test our new program using a file created just for this test.
To create the file, we use
.CW dd .
This is a tool that is useful to copy bytes in a controlled way from one place to
another (its name stands for
.I "device to device" ).
Using this command
.ix "device to~device
.ix [dd]
.P1
; dd -if /dev/zero -of /tmp/sfile -bs 1024 -count 1024
1024+0 records in
1024+0 records out
; ls -l /tmp/sfile
--rw-r--r-- M 19 nemo nemo 1048576 Jul 29 16:20 /tmp/sfile
.P2
.LP
we create a file with 1 Mbyte of bytes, all of them zero. The option
.ix "file creation
.CW -if
lets you specify the input file for
.CW dd ,
i.e.,
where to read bytes from. In this case, we used
.CW /dev/zero ,
which a (fake!) file that seems to be an unlimited sequence of zeroes. Reading it
would just return as many zeroes as bytes you tried to read, and it would never
give an end of file indication. The option
.CW -of
lets you specify which file to use as the output. In this case, we created the file
.CW /tmp/sfile ,
which we are going to use for our experiment.
.PP
This tool,
.CW dd ,
reads from the input
.ix "file block
file one block of bytes after another, and writes each block read to the output file.
A block is also known as a
.I record ,
as the output from the program shows. In our case, we used
.CW -bs
(block size) to ask
.CW dd
to read blocks of 1024 bytes. We asked
.CW dd
to copy just 1024 blocks, using its
.CW -count
option.
The result is that
.CW /tmp/sfile
has 1024 blocks of 1024 bytes each (therefore 1 Mbyte) copied from
.CW /dev/zero .
.ix [/dev/zero]
.PP
We are using a relic that comes from ancient times!
Times when tapes and even more weird
.ix tape
artifacts were very common. Many of such devices required programs to read (or
write) one record at a time. Using
.CW dd
was very convenient to duplicate one tape onto another and similar things. Because
it was not common to read or write partial records, the diagnostics printed by
.CW dd
show how many entire records were read (\f(CW1024\fP here), and how many
bytes were read from a last but partial record (\f(CW+0\fP in our case). And the
same for writing.
Today, it is very common to see always \f(CW+0\fP for both the data read in, and
the data written out.
By the way, for our little experiment we could have used just
.CW dd ,
instead of writing our own dumb version for it, but it seemed more appropriate
to let you read the code to review file I/O once more.
.PP
So, what would happen when we copy our file using our default buffer size of 8Kbytes?
.ix buffer
.ix [time]
.ix "performance
.P1
; time 8.bcp /tmp/sfile /tmp/dfile
0.01u 0.01s 0.40r 	 8.bcp /tmp/sfile /tmp/dfile
.P2
.LP
Using the command
.CW time ,
to measure the time it takes for a command to run, we see that using a 8Kbyte
buffer it takes 0.4 seconds of real time (\f(CW0.40r\fP) to copy a 1Mbyte file.
As an aside,
.CW time
reports also that
.CW 8.bcp
spent 0.01 seconds executing its own code (\f(CW0.01u\fP)
and 0.01 seconds executing inside the
operating system (\f(CW0.01s\fP),
.ix "user time
.ix "system time
.ix "elapsed time
e.g., doing system calls. The remaining 0.38 seconds, until the total of 0.4 seconds,
the system was doing something else (perhaps executing other programs or waiting
for the disk to read or write).
.PP
What would happen reading one byte at a time? (and writing it, of course).
.P1
; time 8.bcp -b 1 /tmp/sfile /tmp/dfile
9.01u 56.48s 755.31r 	 8.bcp -b 1 /tmp/sfile /tmp/dfile
.P2
.LP
Our program is
.I "amazingly slow" !
It took 755.31 seconds to complete. That is 12.6 minutes, which is an eon for a
computer.
But it is the same program, we did not change anything. Just this time, we read one
byte at a time and then wrote that byte to the output file. Before, we did the same
but for a more reasonable buffer size.
.PP
Let's continue the experiment. What would
happen if our program reads one line at a time? The source file does not have lines,
but we can pretend that all lines have 80 characters of one byte each.
.P1
; time 8.bcp -b 80 /tmp/sfile /tmp/dfile
0.11u 0.74s 10.38r 	 8.bcp -b 80 /tmp/sfile /tmp/dfile
.P2
.LP
Things improved, but nevertheless we still need 10.38 seconds just to copy 1 Mbyte.
What happens is that making a system call is not so cheap, at least it seems
very expensive when compared to making a procedure call. For a few calls, it
does not matter at all. However, in this experiment it does. Using a buffer of just
one byte means making 2,097,152 system calls! (1,048,576 to read bytes and
1,048,576 to write them). Using an 8Kbyte buffer requires just 128 calls (.e.,
1,048,576 / 8,192).
You can compare for yourself. In the intermediate experiment, reading one line at
a time, it meant 26,214 system calls. Not as many as 2,097,152, but still a lot.
.PP
How to overcome this difficulty when we really need to write an algorithm that
reads/writes a few bytes at a time? The answer, as you probably know, is just
to use buffering. It does not matter if your algorithm reads one byte at a time.
It does matter if you are making a system call for each byte you read.
.PP
The
.I bio (2)
.ix [bio]
.ix "buffered I/O
library in Plan 9 provides buffered input/output. This is an abstraction that,
although not provided by the underlying Plan 9, is so common that you really
must know how it works. The idea is that your program creates a Bio buffer
for reading or writing, called a
.CW Biobuf .
.ix [Biobuf]
You program reads from the
.CW Biobuf ,
by calling a library function, and the library will call
.CW read
.ix [read]
only to refill the buffer each time you exhaust its contents. This is our (in)famous
program, but this time we use Bio.
.so progs/biocp.c.ms
.ix [biocp.c]
.LP
The first change you notice is that to use Bio the header
.CW bio.h
.ix [bio.h]
must be included. The data structure representing the Bio buffer is a
.CW Biobuf .
The program obtains two ones, one for reading the input file and one for
writing the output file. The function
.CW Bopen
.ix [Bopen]
is similar to
.CW open ,
but returns a pointer to a
.CW Biobuf
instead of returning a file descriptor.
.P1
; sig Bopen
	Biobuf* Bopen(char *file, int mode)
.P2
.LP
Of course,
.CW Bopen
.I must
call
.CW open
to open a new file. But the descriptor returned by the underlying call to
.CW open
is kept inside the
.CW Biobuf ,
because only routines from
.I bio (2)
should use that descriptor. You are supposed to read and write from the
.CW Biobuf .
.PP
To read from
.CW bin ,
our input buffer, the program calls
.CW Bread .
This function is exactly like
.CW read ,
but reads bytes from the buffer when it can, without calling
.CW read .
Therefore,
.CW Bread
does not receive a file descriptor as its first parameter, it receives a pointer to
the
.CW Biobuf
used for reading.
.P1
; sig Bread
	long Bread(Biobufhdr *bp, void *addr, long nbytes)
.P2
.LP
The actual system call,
.CW read ,
is used by
.CW Bread
.ix [read]
.ix [Bread]
only when there are no more bytes to be read from the buffer, e.g., because
you already read it all.
.PP
To write bytes to a
.CW BIobuf ,
the program uses
.CW Bwrite .
.ix [Bwrite]
This is to
.CW write
what
.CW Bread
is to
.CW read .
.P1
; sig Bwrite
	long Bwrite(Biobufhdr *bp, void *addr, long nbytes)
.P2
.LP
The call to
.CW Bterm
.ix [Bterm]
releases a
.CW Biobuf ,
.ix "[Biobuf] termination
including the memory for the data structure. This closes the file descriptor used
to reach the file, after writing any pending byte still sitting in the buffer.
.P1
; sig Bterm
	int Bterm(Biobufhdr *bp)
.P2
.LP
As you can see, both
.CW Bterm
and
.CW Bflush
.ix [Bflush]
.ix "[Biobuf] flushing
return an integer. That is how they report errors. They can fail because it can
be that the file cannot really be written (e.g., because the disk is full), but you will
only know when you try to write the file, which does not necessarily happen in
.CW Bwrite .
.PP
How will our new program behave, now that it uses buffered input/output? Let's try it.
.P1
; time 8.biocp /tmp/sfile /tmp/dfile
0.00u 0.03s 0.38r 	 8.bcp /tmp/sfile /tmp/dfile
; time 8.biocp -b 1 /tmp/sfile /tmp/dfile
0.00u 0.13s 0.31r 	 8.bcp -b 1 /tmp/sfile /tmp/dfile
; time 8.biocp -b 80 /tmp/sfile /tmp/dfile
0.00u 0.02s 0.20r 	 8.bcp -b 80 /tmp/sfile /tmp/dfile
.P2
.LP
Always the same!. Well, not exactly the same because there is always some
uncertainty in every measurement. In this case, give or take  2/10th of a second.
But in any case, reading one byte at a time is far from taking 12.6 minutes.
Bio took care of using a reasonable buffer size, and calling
.CW read
only when necessary, as we did by ourselves when using 8Kbyte buffers.
.PP
One word of caution. After calling
.CW write ,
it is very likely that our bytes are already in the file, because there is probably
no buffering between your program and the actual file. However, after a
call to
.CW Bwrite
it is almost for sure that your bytes are
.I not
in the file. They will be sitting in the
.CW Biobuf ,
waiting for more bytes to be written, until a moment when it seems reasonable
for a Bio routine to do the actual call to
.CW write .
This can happen either when you fill the buffer, or when you call
.CW Bterm ,
which terminates the buffering. If you really want to flush your buffer, i.e., to
send all the bytes in it to the file, you may call
.CW Bflush .
.P1
; sig Bflush
	int Bflush(Biobufhdr *bp)
.P2
.LP
To play with this, and see a couple of other tools provided by Bio, we are going
to reimplement our little
.CW cat
program but using Bio this time.
.so progs/biocat.c.ms
.ix [cat]
.ix [biocat.c]
.LP
This program uses two
.CW Biobufs ,
like the previous one. However, we now want one for reading from standard input,
and another to write to standard output. Because we already have file descriptors
0 and 1 open, it is not necessary to call
.CW Bopen .
The function
.CW Binit
.ix [Binit]
.ix "[Biobuf] file descriptor
initializes a
.CW Biobuf
for an already open file descriptor.
.P1
; sig Binit
	int Binit(Biobuf *bp, int fd, int mode)
.P2
.LP
You must declare your own
.CW Biobuf .
Note that this time
.CW bin
and
.CW bout
are
.I not
pointers, they are the actual
.CW Biobufs
used.
Once we have our
.CW bin
and
.CW bout
buffers, we might use any other Bio function on them, like before. The call to
.CW Bterm
terminates the buffering, and flushes any pending data to the underlying file. However,
because Bio did not open the file descriptor for the buffer, it will not close it either.
.PP
Unlike the previous program, this one reads one line at a time, because we plan
to use it with the console. The function
.CW Brdline
.ix [Brdline]
.ix "read line
reads bytes from the buffer until the end-of-line delimiter specified by its second
parameter.
.P1
; sig Brdline
	void* Brdline(Biobufhdr *bp, int delim)
.P2
.LP
We used
.CW '\en' ,
which is the end of line character in Plan 9. The function returns a pointer to the
bytes read, or zero if no more data could be read. Each time the program reads
a line, it writes the line to its standard output through
.CW bout .
The
.CW line
returned by
.CW Brdline
is not a C string. There is not a final null byte after the line. We could have
used
.CW Brdstr ,
.ix [Brdstr]
.ix "string read
which returns the line read in dynamic memory (allocated with
.CW malloc ),
and terminates the line with a final null byte. But we did not. Thus, how many
bytes must we write to standard output? The function
.CW Blinelen
.ix [Blinelen]
.ix "line length
returns the number of bytes in the last line read with
.CW Brdline .
.P1
; sig Blinelen
	int Blinelen(Biobufhdr *bp)
.P2
.LP
And that explains the body of the
.CW while
in our program. Let's now play with our cat.
.P1
; 8.biocat
!!one little
!!cat was walking.
\fBcontrol-d\fP
one little
cat was walking.
;
.P2
.LP
No line was written to standard output until we typed
.I control-d .
The program did call
.CW Bwrite ,
but this function kept the bytes in the buffer. When
.CW Brdline
returned an EOF indication, the call to
.CW Bterm
terminated the output buffer and its contents were written to the underlying
file. If we modify this program to add a call to
.P1
Bflush(&bout);
.P2
after the one to
.CW Bwrite ,
this is what happens.
.P1
; 8.biocat
!!Another little cat
Another little cat
!!did follow
did follow
\fBcontrol-d\fP
;
.P2
.LP
The call to
.CW Bflush
flushes the buffer. Of course, it is now a waste to use
.ix "buffer flushing
.CW bout
at all. If we are flushing the buffer after each write, we could have used just
.CW write ,
and forget about
.CW bout .
.SH
Problems
.IP 1
Use the debugger,
.CW acid ,
to see that a program reading from standard input in a window
is indeed waiting inside
.CW read
while the system is waiting for you to type a line in the window.
.IP
.I Hint :
Use
.CW ps
to find out which process is running your program.
.IP 2
Implement the
.I cat (1)
utility without looking at the source code for the one in your system.
.IP 3
Compare your program from the
previous problem with the one in the system. Locate the one in the system using a
command. Discuss the differences between both programs.
.IP 4
Implement a version of
.I chmod (1)
that accepts an octal number representing a new set of permissions, and
one or more files. The program is to be used like in
.P1
; 8.out 0775 file1 file2 file3
.P2
.IP 5
Implement your own program for doing a long listing like
.P1
; ls -l
.P2
.IP
would do.
.IP 6
Write a program that prints all the files contained in a directory (hierarchy) along
with the total number of bytes consumed by each file. If a file is a directory, its
reported size must include that of the files found inside. Compare with
.I du (1).
.ds CH
.bp
\c