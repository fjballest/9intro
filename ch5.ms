.so tmacs
.BC 5 "Talking Processes
.BS 2 "Input/Output redirection
.LP
.ix "I/O redirection
.ix "file descriptor redirection 
Most commands we have executed so far write their output to the
console, because their standard output file descriptor is usually
leading to the console.
.PP
In some cases, it may be useful to \fBredirect\fP
the output for a command to store the data produced in a file.
For example, to record the date for an important moment, we can
execute
.CW date
.ix [date]
and store its output in a file, for posterity.
The shell knows how to do this:
.P1
; !!date > rememberthis
;
.P2
.LP
This command line means: Execute the command
.CW date
as usual, but send its output to
.CW rememberthis .
The obedient Plan 9 shell makes the arrangements
to get the output for the command sent to file, and not
to the console. As a result,
.CW date
did now write anything in the console. But it did write.
Its output is here instead.
.ix "output redirection
.P1
; cat rememberthis
Thu Jul 13 12:10:38 MDT 2006
.P2
.LP
This can be done to any command, as you may expect. When the shell finds a
“\f(CW>\fP” in a command line, it takes the next word as the name of a file
where to send the output for the command.
.ix "command line
This is a poor's man editor. We use
.CW cat
to read what we write in the terminal, and write it into a file.
.P1
; cat >/tmp/note
must leave at 8
\fBcontrol-d\fP
; cat /tmp/note
must leave at 8
.P2
.LP
The  “\f(CW>\fP” character is an operator, and has a special meaning. To
use it just as a character, it must be quoted. We already knew, but
just as a reminder:
.P1
; echo '>' > file
; cat file
>
;
.P2
.LP
Another example. If our machine seems
to be heavily loaded, we may want
to conserve the list of running processes, to inspect it later. That is simple:
.P1
; ps > processlist
;
.P2
.ix [ps]
.ix "machine load
.ix "process list
.LP
Now that we have the list of processes stored in a file, we can take our time
to inspect what is happening to the machine. For example, we may use
.CW cat
to print the list. It reads the file and prints all the bytes read to the standard output.
.P1
.ps -1
; cat processlist
nemo              1    0:00   0:00     2308K Await    bns
nemo              2    5:03   0:00        0K Wakeme   genrand
nemo              3    0:00   0:00        0K Wakeme   alarm
nemo              4    0:00   0:00        0K Wakeme   rxmit
.I "... other lines omitted ...
.ps +2
.P2
.LP
We can count how many processes there were in the system by
the time we stored the list. To do so, we can count the lines in the file
.CW processlist ,
because we know there is one line in that file per process. The program
.CW wc
(word count)
.ix [wc]
.ix "word count
counts lines, words, and characters in a file, and prints what it finds.
.P1
; wc processlist
   147    1029    8795 processlist
;
.P2
.LP
The file
.CW processlist
has 147 lines, 1929 words, and 8795 characters in it. This means that
we had 147 processes in the machine at that time. Because we are
only interested in the number of lines, we might have used the option
.CW -l
to
.CW wc ,
as said in
.I wc (1),
to ask just for the number of lines:
.P1
; wc -l processlist
    147 processlist
;
.P2
.LP
As  we said before,
most commands that accept a file name as an argument,
work with their standard input when no file name is given. And
.ix "standard input
.CW wc
is not an exception. For example,
.P1
; wc
when I see it, I believe it
\fBcontrol-d\fP
      1       7      28
;
.P2
.LP
counts the lines, words, and characters that we type until
pressing a
.I control-d .
.ix "control-d
.PP
The shell is able to redirect the standard input for a command, and not
just its output. The syntax is similar to a redirection for output, but using
“\f(CW<\fP” instead of “\f(CW>\fP”. To remember, imagine the bytes entering through the
wide part of the symbol, going out through the little hole in the other end. We can now
do this
.P1
; cat < rememberthis
Thu Jul 13 12:10:38 MDT 2006
.P2
.LP
and it would have the same effect that doing this
.P1
; cat rememberthis
Thu Jul 13 12:10:38 MDT 2006
.P2
.LP
Both commands produce the same output, but they are very different. In the
first case, the shell makes the arrangements so that the standard input for
.CW cat
comes from
.I rememberthis
and not from the console. The
.CW cat
program has no arguments (other than
.CW argv[0] )
and therefore starts reading from its standard input. But
.CW cat
does not even know the name of the file it is reading!
In the second case, the shell is not doing anything to the standard input for
.CW cat .
The program itself has to open the file, and read from it.
.PP
For those rare cases when there is a command that requires a file name as
its input, and you still want to run the command to work on its standard input,
Plan 9
provides files named
.CW /fd/0 ,
.CW /fd/1 ,
.ix "[/fd] file system
.ix "file descriptor
etc. These are not real files, but other interface to use your file descriptors. For
example, this is another way of running
.CW cat
to copy its standard input:
.P1
; cat /fd/0
.I "...and cat reads what you type.
.P2
.LP
and this is achieves the same effect:
.P1
; cp /fd/0 /fd/1
.I "...and cp copies what you type back to the console
.P2
.LP
In the last chapter, we did see that a command line executed in the background,
i.e., terminated with “\f(CW&\fP”, is not allowed to read from the console. What
happens is that the shell redirects the command's standard input to
.ix "background command
.CW /dev/null ,
the file that seems to be always empty. You can achieve a similar effect doing
this.
.P1
; cat </dev/null
;
.P2
.LP
Therefore, the input redirection here is redundant:
.ix "input redirection
.P1
; cat </dev/null &
;
.P2
.LP
How can the shell redirect the standard input/output for a command? Think about
it. The program
.CW cat
reads from file descriptor 0, when given no arguments. That is the convention for
standard input. For output,
.CW cat
writes at file descriptor 1. If the shell manages to get the file descriptor 1 for
.CW cat
open for writing into
.CW rememberthis ,
the bytes written by cat will go into
.CW rememberthis .
And of course
.CW cat
would know nothing about where does its standard output go. They are written
into an open file descriptor that must lead to some file. Also, if the shell manages
to get the file descriptor 0 for
.CW cat
open for reading from
.CW /dev/null ,
cat would be reading from
.CW /dev/null .
.PP
Input/output redirection must be done in the process that is going to
execute the command. Otherwise, the shell would loose its own
standard input or output. It must be done before doing the
.CW exec
for the new command. It would not make sense to do it after,
because there would be no I/O redirection, and because when
.CW exec
works, your program is gone!
.PP
Consider this program
.so progs/iredir.c.ms
.ix [iredir.c]
.LP
and its output.
.P1
; 8.iredir
Copyright © 2002 Lucent Technologies Inc.
All Rights Reserved
.P2
.LP
We supplied no argument to
.CW cat
in the call to
.CW execl .
.ix [execl]
Therefore,
.CW cat
was reading from standard input. However, because of the two previous
.ix "standard input
calls, file descriptor 0 was open to read
.CW /NOTICE .
The program
.CW cat
reads from there, and writes a copy to its output.
.PP
This is a real kludge. We do
.I not
know that
.CW open
is going to return 0 as the newly open file descriptor for
.CW /NOTICE .
At the very least, the program should check that this is
the case, and abort its execution otherwise:
.ix [assert]
.P1
fd = open("/NOTICE", OREAD);
assert(fd == 0);
.P2
.LP
At least, if
.CW fd
is not zero,
.CW assert
receives
.I false
(i.e., 0) as a parameter and prints the file and line number
before calling
.CW abort .
.PP
The system call
.CW dup
.ix [dup]
.ix "duplicate file descriptor
receives a file descriptor and duplicates it into another.
This is what we need. The code
.P1
fd = open("/NOTICE", OREAD);
dup(fd, 0);
close(fd);
.P2
opens
.CW /NOTICE
for reading, then
.I duplicates
the descriptor just open into file descriptor 0. After the call,
file descriptor 0 leads to the same place
.CW fd
was leading to. It refers to the same file and shares the same offset. This is shown
in figure [[!duplicating descriptor!]], which assumes that
.CW fd
was 3 (As you can see, both descriptors refer now to the same Chan). At this point,
the descriptor
whose number is in
.CW fd
is no longer necessary, and can be closed. The program in
.CW cat
is only going to read from
.CW 0 .
It does not even know that we have other file descriptors open.
.LS
.PS 5i
.ps -2
right
boxht=.2
boxwid=1
B: [
	down
	circle rad .4 "Child" "process"
	line -> down " File descriptor" ljust  " table" ljust
	D: [ down
	 	[ right
		box invis wid .2  "0" ; F: box   ]
	D0: last [].F
		[ right
		box invis wid .2  "1" ; F: box   ]
	D1: last [].F
		[ right
		box invis wid .2  "2" ; F: box   ]
	D2: last [].F
		[ right
		box invis wid .2  "3" ;  F: box    ]
	D3: last [].F
		[ right
		box invis wid .2   ;  box invis   "..."]
		[ right
		box invis wid .2  "n" ; F: box   ]
	]
	arrow -> from D.D3 down .5 right 1
	C: box wid 1.5 ht 2*boxht "\f(CW/NOTICE OREAD\fP" "\f(CWoffset: 0\fP"
	arrow -> from D.D1 right 1
	T: box wid 1.5 ht 2*boxht "\f(CW/dev/cons ORDWR\fP" "\f(CWoffset: 3245\fP"
	spline -> from D.D0 right then to T.w + 0,.1
	spline -> from D.D2 right then to T.w+0,-.1 
]
move
A: [
	down
	circle rad .4 "Child" "process"
	line -> down " File descriptor" ljust  " table" ljust
	D: [ down
	 	[ right
		box invis wid .2  "0" ; F: box   ]
	D0: last [].F
		[ right
		box invis wid .2  "1" ; F: box   ]
	D1: last [].F
		[ right
		box invis wid .2  "2" ; F: box   ]
	D2: last [].F
		[ right
		box invis wid .2  "3" ;  F: box   ]
	D3: last [].F
		[ right
		box invis wid .2   ;  box invis   "..."]
		[ right
		box invis wid .2  "n" ; F: box   ]
	]
	arrow  from D.D3 down .5 right 1
	C: box wid 1.5 ht 2*boxht "\f(CW/NOTICE OREAD\fP" "\f(CWoffset: 0\fP"
	arrow -> from D.D1 right 1
	T: box wid 1.5 ht 2*boxht "\f(CW/dev/cons ORDWR\fP" "\f(CWoffset: 3245\fP"
	spline -> from D.D0 right .7 then down .8 then to C.w + 0,.1
	spline -> from D.D2 right then to T.w+0,-.1 
]
box invis "Before \f(CWdup(3, 0)\fP" at B.s - 0,.5
box invis "After \f(CWdup(3, 0)\fP" at A.s - 0,.5
reset
.ps +2
.PE
.LE F File descriptors before and after duplicating descriptor 3 into descriptor 0.
.PP
This is the correct implementation for the program shown before.
Its output remains the same, but the previous program could fail (Note
that in this section we are not checking for errors, to keep the programs' purposes
clearer to see).
.P1
void
main(int, char*[])
{
	int	fd;

	switch(fork()){
	case -1:
		sysfatal("fork failed");
	case 0:
		fd = open("/NOTICE", OREAD);
		dup(fd, 0);
		close(fd);
		execl("/bin/cat", "cat", nil);
		sysfatal("exec: %r");
	default:
		waitpid();
	}
	exits(nil);
}
.P2
.LP
There are some pitfalls that you are likely to experience by accident in the future.
One of them is redirecting standard input to a file descriptor open for writing.
That is a violation of the convention that file descriptor 0 is open for reading. For
.ix [create]
.ix [dup]
example, this code makes such mistake:
.P1
fd = create("outfile", OWRITE, 0664);	// WRONG!
dup(fd, 0);
close(fd);
.P2
.LP
Using this code in the previous program puts
.CW cat
in trouble. A
.CW write
call for a descriptor open just for reading is never going
to work:
.P1
; 8.iredir
cat: error reading <stdin>: inappropriate use of fd
;
.P2
.LP
Output redirections made by the shell use
.CW create
to open the output file, because most of the times
.ix "standard output redirection
.ix "truncate
the file would not exist. When the file exists, it is
truncated by the call and nothing bad happens:
.P1
fd = create("outfile", OWRITE, 0664);
dup(fd, 1);
close(fd);
.P2
.LP
A common mistake is redirecting both input and output to the same
file in a command line, like we show here:
.P1
; cat <processlist >processlist
;
.P2
.LP
When the shell redirects the output,
.CW create
truncates the file! There is nothing there for
.CW cat
to read, and your data is gone. If you ever
want to do a similar thing, it must be done in
two steps
.P1
; cat <processlist >/tmp/temp
; cp /tmp/temp processlist
; rm /tmp/temp
.P2
.BS 2 "Conventions
.LP
Why does standard error exist? Now you can know. Consider what happens when
.ix "standard error
we redirect the output for a program and it has a problem:
.P1
; lc /usr/nemos >/tmp/list
ls: /usr/nemos: '/usr/nemos' file does not exist
; cat /tmp/list
.P2
.LP
Clearly, the diagnostic printed by
.ix diagnostic message
.CW lc
is not the output data we expect. If the program had written this message
to its standard output, the diagnostic message would be lost between the data.
Two bad things would happen: We would be unaware of the failure of the command,
and the command output would be mixed with weird diagnostic messages that
might be a problem if another program has to process such output.
.PP
In the beginning, God created the Heaven and the Earth [ ... ], and God said,
.ix God
Let there be Light, and there was Light. Yes, you are still reading the same operating
systems book. This citation seemed appropriate because of the question, How did
my process get its standard input, output, and error? and, How can it be that
the three of them go to
.CW /dev/cons ?
.ix [/dev/cons]
.PP
The answer is simple. Child processes
.I inherit
.ix inheritance
a copy of the parent's file descriptors. In the beginning, Plan 9 created the first
process that executes in the system. This process had no file descriptor open, initially.
At that point, this code was executed:
.P1
open("/dev/cons", OREAD);
open("/dev/cons", OWRITE);
open("/dev/cons", OWRITE);
.P2
.LP
Later, all the descendents had their descriptors 0, 1, and 2 open and referring to
.CW /dev/cons .
This code would do the same.
.P1
open("/dev/cons", OREAD);
open("/dev/cons", OWRITE);
dup(1, 2);
.P2
.BS 2 "Other redirections
.LP
Output can be redirected to a file appending to its contents. In this
case, the shell
seeks to the end of the file used for output before executing the command.
To redirect output appending, use “\f(CW>>\fP” instead of use “\f(CW>\fP”.
.ix "append redirection
.P1
; echo hello >/tmp/note
; echo there >>/tmp/note
; echo and there >>/tmp/note
; cat /tmp/note
hello
there
and there
; echo again >/tmp/note
; cat /tmp/note
again
.P2
.LP
The code executed by the shell to redirect the output appending
is similar to this one,
.P1
fd = open("outfile", OWRITE);
if (fd < 0)
	fd = create("outfile", OWRITE, 0664);
seek(fd, 0, 2);
dup(fd, 1);
close(fd);
.P2
.LP
which creates the output file only when it does not exist. If the program
used
.CW create ,
.ix [create]
it would truncate the file to a zero-length. If it used just
.CW open ,
the output redirection would not work when file does not exist. Also,
the call to
.CW seek
is utterly important, to actually append to the file.
.PP
File descriptors other than 0 and 1 can be redirected from the shell.
You must write the descriptor number between square brackets after
the operator. For example, this discards any error message from the command
by sending its standard error to
.CW /dev/null .
.P1
; lc *.c >[2] /dev/null
open.c	seek.c
;
.P2
.LP
This file is another invention of the system, like most other files in
.CW /dev .
.ix device files
When you write into it, it seems that the write was done. However, the
system did not write anything anywhere. That is why this file is used
to throw away data sent to a file.
.PP
The shell can do more things regarding I/O redirection. The “\f(CW<>\fP”
operator redirects both standard input and output to the file whose name
follows. However, it opens the file just once for both reading and writing.
For example, this leaves
.ix "input~and~output redirection
.CW file
empty:
.P1
; echo hola>file
; cat <file >file
;
.P2
.LP
But this does not:
.P1
; echo hola >file
; cat <> file
hola
;
.P2
.LP
More useful is being able to redirect one file descriptor to another one.
Errors are to be written to standard error, but
.CW echo
writes to standard output. To report an error from a shell script, this
can be done
.P1
; echo something bad happen >[1=2]
.P2
.ix "[dup] in~[rc]
.LP
which is equivalent to a
.CW dup(1,2)
in a C program.
.PP
Redirections are applied left to right, and these two commands do different
things:
.P1
; ls /blah >/dev/null >[2=1]
; ls /blah >[2=1] >/dev/null
ls: /blah: '/blah' file does not exist
;
.P2
.LP
The first one redirects its output to
.CW /dev/null ,
which throws away all the output, and then sends
.ix "output discard
its standard error to the same place. Throwing it away as well.
The second one send its standard error to where standard output
is going (the console), and then throws away the output by sending it
to
.CW /dev/null .
.BS 2 "Pipes
.LP
.ix pipe
There is a whole plethora of programs in Plan 9 that read some data,
perform some operation on it, and write some output. We already saw
some. Many tasks can be achieved by combining these programs, without
.ix "compound command
having to write an entire new program in C or other language.
.PP
For example, this book is typeset using
.I troff (1),
.ix [troff]
.ix typesetting
and the input text is kept at files named
.CW ch1.ms ,
.CW ch2.ms ,
and so on, each one with the text for one chapter.
A rough estimate of the book size would be to count
the number of words for all the files containing troff input for chapters. We can
use a program to count words. Option
.CW -w
for
.CW wc
.ix [wc]
.ix "word count
does just that:
.P1
; wc -w ch*.ms
  12189 ch1.ms
   9252 ch2.ms
   8153 ch3.ms
   6470 ch4.ms
   3163 ch5.ms
     61 ch6.ms
    592 chXX.ms
  39880  total
.P2
.LP
This gives a good break-down of the number of words in each file, and also
of the total (as of today, when we are writing this). However, to obtain just the
total we can give a single file to
.CW wc
.ix "[wc] flag~[-w]
.P1
; cat ch*.ms >/tmp/all.ms
; wc -w /tmp/all.ms
  39880 /tmp/all.ms
.P2
.LP
If we suspect that we use the word
.I file
too many times in the book, and what to check that out, we can count the number
of lines that contain that word as an estimate. The program
.CW grep
.ix [grep]
.ix "word search
writes to its output only those lines that contain a given word. We can run
.P1
; grep file </tmp/all.ms >/tmp/lineswithfile
;
.P2
to generate a file
.CW lineswithfile
that contains only the lines that mention
.CW file ,
and then use
.CW wc
on that file
.P1
; wc -w /tmp/lineswithfile
   7355 /tmp/lineswithfile
.P2
.LP
This is inconvenient. We have to type a lot, and require temporary files
just to use the output of one program as the input for another.
There is a better way:
.P1
; cat ch*.ms | wc -w
  39880
.P2
executes both
.CW cat
and
.CW wc .
The standard output for
.CW cat
is conveyed by the “\f(CW|\fP” into the standard input for
.CW wc .
We get the output we wanted in a simple way. This is how we count
just the lines using the word file:
.ix pipe
.P1
; cat ch*.ms | grep file | wc -l
   7355
;
.P2
.LP
Here, the output of
.CW cat
was conveyed to
.CW grep ,
whose output was conveyed to
.CW wc .
A small command line performed a quite complex task. By the way,
because
.CW grep
accepts as arguments the names for its input files, a more compact
command could be used:
.P1
; grep file ch*ms | wc -l
   7355
;
.P2
.LP
The
.I conveyer
represented by the vertical bar is called a
.CW pipe .
Its function is the same. Think of input as bytes flowing into a
command, for processing, and output as bytes flowing out the
command. If you have a pipe, you can plumb one output to one
input. But you
.I must
use a pipe. Otherwise, bytes would pour on the floor!
.PP
Before, we have used
.CW ps
.ix [ps]
to lists processes. Usually, there are many lines printed by
the command,
but we can be interested in a particular one. There is no need to
scroll down the terminal and search through many lines just
to find the information for a broken process:
.P1
; ps | grep Broken
nemo           1633    0:00   0:00       24K Broken   8.out
;
.P2
.ix [Broken]
.LP
The output of
.CW ps
is sent into the pipe. It flows through it and becomes the input
for
.CW grep ,
which writes just those lines that contain the string
.CW Broken .
.PP
To get rid of this broken process, we can execute
.CW broke .
.ix [broke]
.ix "kill broken process
This program
.I prints
a command to kill the broken processes, but does not kill them
itself (killing is too dangerous and
.CW broke
does not want to take responsibility for your actions):
.P1
; broke
echo kill>/proc/1633/ctl # 8.out
;
.P2
.LP
But to
.I execute
this command, we must use it as input for the shell. Now we can.
.ix "[rc] in~pipes
.P1
; broke |rc
; ps | grep Broken
;
.P2
.LP
Figure [[!pipe input output connect!]] shows what happens when
you execute
.CW broke|rc
The file descriptor 1 for
.CW broke
gets sent to the input of the pipe. The output from the pipe is used
as source for
file descriptor 0 in
.CW rc
Therefore,
.CW rc
reads from its standard input what
.CW broke
writes on its output.
In the
figure, processes are represented by circles. Arrows going out from circles
are file descriptors open for writing. The descriptor number is the value or
variable printed in the arrow. Arrows pointing into circles are file descriptors
open for reading. Of course, the process represented by the circle is the one
who reads. Pipes and files do not read, they are not alive!
.LS
.PS
right
arrow right "0" above
circlerad=.4
circle "\f(CWbroke\fP"
arrow right  "1" rjust above
box wid 1 ht .2 "pipe"
arrow right  "0" ljust above
circle "\f(CWrc\fP"
arrow right "1" above
reset
.PE
.LE F Using a pipe to connect the output of \f(CWbroke\fP to the input of \f(CWrc\fP.
.PP
The pipe is an artifact provided by Plan 9 to let you interconnect processes.
.ix "process communication
It looks like two files connected to each other. What you write into one of them,
is what will be read from the the other. That is why in the figure, the input for
one process goes into one end of the pipe, and the output for the other process
may go to the
.I other
end of the pipe.
.PP
To create a pipe in a C program, you can use the
.CW pipe
system call. It returns
.I two
descriptors, one for each end of the pipe. Both descriptors are stored
at the integer array passed as a parameter to the function.
.P1
int	fd[2];

pipe(fd);
// fd[0] has the fd for one end
// fd[1] has the fd for the other.
.P2
.ix [pipe]
.LP
This program is trivial, but it helps in understanding pipes. It writes
some text to one end of the pipe, and reads it back from the other end.
To see the outcome, it prints what it did read to its standard output.
.so progs/pipe.c.ms
.ix [pipe.c]
.LP
This is the output
.P1
; 8.pipe
Hello!
;
.P2
.LP
Because standard output is file descriptor 1, and standard input is file descriptor 0,
the tradition is to read from
.CW fd[0]
and write into
.CW fd[1] ,
as the program does. Pipes are bi-directional in Plan 9, and doing it the other
.ix "bidirectional pipe
way around works as well. It is said that Plan 9 pipes are
.B full-duplex .
.PP
Let's try now something slightly different. If we replace the single write in the
program with two ones, like
.P1
write(fd[1], "Hello!\en", 7);
write(fd[1], "there\en", 6);
.P2
.LP
this is what the program prints now.
.P1
; 8.pipe
Hello!
;
.P2
.LP
the same! Plan 9 pipes preserve
.B "write boundaries"
.ix "message delimiters"
(known also as
.I "message delimiters" ).
That is to say that for each read from a pipe, you will get data
from a single write made to the pipe. This is very convenient when
you use the pipe to speak a dialog between two programs, because
different messages in the speech do not get mixed. But beware, UNIX
does not do the same. This is the output from the same program in a
.ix UNIX
UNIX system:
.P1
$ !!pipe
Hello!
there
$
.P2
.LP
In Plan 9, we need a second read to obtain the data sent through the
pipe by the second write.
.PP
The pipe has some buffering (usually, a few Kbytes), and that is where the
.ix pipe buffering
bytes written by the program were kept until they were read from the pipe.
Plan 9 takes care of those cases when data is written to the pipe faster than
it is read from the pipe. If the buffer in the pipe gets full (the pipe is full of bytes), Plan 9
will make the writer process wait until some data is read and there is room
in the pipe for more bytes. The same happens when data is read faster than
written. If the pipe is empty, a read operation on it will wait until there is
something to read.
.PP
You can see this. This program fills a pipe. It keeps on writing into the pipe
until Plan 9 puts the process in the blocked state (because the pipe is full).
.ix [fill.c]
.so progs/fill.c.ms
.LP
This is the output. The pipe in my system can hold up to 30 Kbytes.
.P1
; 8.fill
wrote 1024 bytes
wrote 1024 bytes
wrote 1024 bytes
.I "... 29 lines including these two ones...
wrote 1024 bytes
.I "... and it blocks forever
.P2
.LP
And this is what
.CW ps
says for the process:
.P1
; ps | grep 8.fill
nemo  2473    0:00   0:00 24K Pwrite  8.fill
.P2
.LP
.ix [Pwrite]
It is trying to write, but will never do.
.PP
In the shell examples shown above, it is clear that the process reading
from the pipe gets an end of file (i.e., a read of 0 bytes) after all data
.ix "end of~file
has gone through the pipe. Otherwise, the commands on the right of
a pipe would never terminate. This is the rule: When no process can
write to one end of the pipe, and there is nothing inside the pipe,
reading from the other end yields 0 bytes. Note that when the pipe is
empty, but a process can write to one end, reading from the other end
would block.
.PP
This is easy to check using our single-process program. If we do this
.P1
close(fd[1]);
nr = read(fd[0], buf, sizeof(buf));
.P2
.LP
the value of
.CW nr
becomes zero, and
.CW read
does not block. However, removing the
.CW close
line makes the program block forever.
.ix "blocked process
.PP
Writing to a pipe when no one is going to read what we write is a
nonsense. Plan 9 kills any process doing such thing. For example
executing this program
.ix "broken pipe
.so progs/brokenpipe.c.ms
.LP
yields
.P1
; 8.brokenpipe
; echo $status
8.out 2861: sys: write on closed pipe pc=0x00002b43
.P2
.ix "closed pipe
.BS 2 "Using pipes
.LP
One useful thing would be to be able to send from a C program
an arbitrary string as the standard input for a command. This can
be used for many things. For example, the
.CW mail
.ix [mail]
program is used to send electronic mail from the command line.
The body of the message is read from standard input, and the
subject and destination address can be supplied in the command line.
This is an example using the shell.
.P1
; mail -s 'do you want a coffee?' mero@lsub.org

!!Hi,
!!If you want a coffee, let's meet down at 5pm.
!!see u.
\fBcontrol-d\fP
.P2
.LP
To do something similar from a C program, we must create a child process
to execute
.CW mail
on it. Besides, we need a pipe to redirect to it the standard input for
.CW mail
and write what we want from the other end of the pipe.
.ix "pipe~to child~process
.PP
This seems a general tool. We are likely to want to execute many different
commands in this way. Therefore, we try to write a function as general as
possible for doing this job. It accepts a string containing a shell command line as a
parameter, and executes it in a child process. It returns a
file descriptor to write to a pipe that leads to the standard input of this process.
.ix [pipeto.c]
.so progs/pipeto.c.ms
.LP
To see a complete example, where this function is used,
the
.CW main
function uses
.CW pipeto
to send several messages to the input of a process running
.CW "grep warning" .
Messages are sent by writing the the file descriptor returned from
.CW pipeto .
When nothing more has to be sent, the file descriptor is closed. The
child process will receive an end-of-file indication as soon as it consumes
what may still be going through the pipe. This is the output for the program.
.P1
; 8.pipeto
;\ warning: the world is over
warning: it was not true
.P2
.LP
.ix "wait~for child~process
Because the parent process finishes before the child is still processing
the input that comes from the pipe, the shell prompt gets printed
almost immediately. If this is a problem, the parent must wait for the child
.I after
writing all the data to the pipe. Otherwise, the
.CW waitpid
.ix [waitpid]
call
would block waiting for the child to die, and the child would block waiting
for the end of file indication (because the parent has the pipe open for writing).
.PP
Figure [[!pipe to command!]]
shows the processes involved, all their descriptors, and the pipe. We use the
same conventions used for the last figure, which we will follow from now on.
.LS
.PS
.R
right
circlerad=.4
arrow right .5 "\f(CW0\fP" above
C: circle "Parent" "Process"
arrow right .5 "\f(CW1\fP" above
arrow from C up .5 right 1.4 "\f(CW2\fP" above chop .5
spline -> from C.se down .5 right .5 "\f(CWfd\fP" then right .5
box wid .5 ht .2 "pipe"
arrow right .5 "\f(CW0\fP" above
G: circle "\f(CWgrep\fP"
arrow right .5 "\f(CW1\fP" above
arrow from G up .5 right 1.4 "\f(CW2\fP" above chop .5
.PE
.LE F A process using a pipe to send input to a command.
.PP
.PP
All the interesting things happen in the function
.CW pipeto .
.ix [pipeto]
It executes the Plan 9 shell, supplying the command line as the argument
for option
.CW -c ,
.ix "[rc] flag~[-c]
this asks
.CW rc
to execute the argument as a command, and not to read commands from
standard input.
.PP
First,
.I before
creating the child process, the parent process makes a pipe. It is very
.ix "pipe creation
important to understand that the pipe
.I must
be created before we call
.CW fork .
.ix [fork]
Both processes must share the pipe. If the pipe is created after
forking, in the child process, the parent process does not have the descriptor
to write to the pipe. If it is created by the parent, after calling
.CW fork ,
the child will not have the descriptor to read from the pipe.
.PP
Even if both processes
create a pipe, after the child creation, there are two different pipes. Each process
can use only its own pipe, but they cannot talk.  It does not matter if the numbers
returned from
.CW pipe
for the two descriptors are the same (or not) for both processes: They are different
descriptors because each process made its own call to
.CW pipe.
Therefore, pipes
are created always by a common ancestor of the processes communicating
through the pipe.
.PP
Another important detail is that all the descriptors are closed (by all processes)
.ix [close]
as soon as they are no longer useful. The child is going to call
.CW execl ,
.ix [execl]
and the new program will read from its standard input. Thus, the child must
close both pipe descriptors after redirecting its standard input to the end for
reading from the pipe. The parent process is going to write to the pipe, but
it is not going to read. It closes the end for reading from the pipe.
Not doing so risks leaving open the pipe for writing, and in this case the reader
process would never get its end of file indication.
.PP
Why does the child redirect its standard input to the pipe and not the parent?
We wrote the code for the parent. We know that it has
.CW fd[1]
open for writing, and can just use that descriptor for writing. On the other hand,
the child does
.I not
know! After the child executes
.CW grep ,
how can grep possibly know that it should use a file descriptor other than zero for
reading?
.PP
The following example is a counterpart to what we made. This function creates
a child process that is used to execute a command. However, this time, we return
the output produced by the command. For example, calling
.P1
nr = cmdoutput("wc *.c", buf, sizeof buf);
.P2
will fill in
.CW buf
a string taken from what
.CW "wc *.c"
prints to its standard output. This is not the best interface for the task, because
we do not know how much the command will print, but it is useful nevertheless.
The caller must take the precaution of supplying a buffer large enough. The number
of bytes read is the result from the function. This is its code:
.P1
.ps -2
.vs .15i
long
cmdoutput(char* cmd, char*buf, long len)
{
	int	fd;
	long	tot;

	if (pipe(fd) < 0)
		return -1;	// failed to create a pipe
	switch(fork()){
	case -1:
		return -1;
	case 0:
		close(fd[0]);
		dup(fd[1], 1);
		close(fd[1]);
		execl("/bin/rc", "-c", cmd, nil);
		sysfatal("exec");
	default:
		close(fd[1]);
		for(tot = 0; len - tot > 1; tot += nr){
			nr = read(fd[0], buf+tot, len - tot);
			if (nr <= 0)
				break;
		}
		close(fd[0]);
		waitpid();
		buf[tot] = 0;	// terminate string
		return tot;
	}
}
.ps +2
.P2
.LP
In this function, we wait for the child to complete before returning, but
after having read all the data from the pipe. It is a serious mistake to
wait for the child before having read all its output. If the output does not
fit into the pipe, the child will block as soon as the pipe is full. It will be
waiting forever, because the parent is not going to read until
.CW waitpid
.ix [waitpid]
completes, and this call is not going to complete until the child dies.
.PP
This is called a
.B deadlock .
One process is waiting for another to do something, and that requires
the former to do another thing, which cannot be done because it is
waiting. You know when you have a deadlock because the processes
involved
.I freeze .
.ix "frozen process
Deadlocks must be avoided. We avoided one here simply by doing
the things in a sensible order, and waiting for the child after we have read
all its output.
.PP
What we have seen is very useful. Many programs do precisely this, or other
similar things. 
The editor Acme admits commands to be applied to a portion of text
.ix "[acme] pipe command
selected by the user. For example, using the button-2 in Acme to run
the command
.CW |t+
asks Acme to execute the program
.CW t+
with the selected text as the input for
.CW t+ ,
and to replace that text with the output from the command. Of course, Acme
uses pipes to send text to the input of
.CW t+
and to read its output.
The command
.CW t+
is a shell script used to indent text by inserting a tab character at the start of each line.
.ix [t+]
.PP
The shell is also a heavy user of pipes, as you might expect. Rc includes
several interesting constructs that are implemented along the lines of what we saw before.
.PP
When Rc finds a command inside \f(CW`{\fP...\f(CW}\fP, it executes
the command, and
.ix "command substitution
.I substitutes
the whole \f(CW`{\fP...\f(CW}\fP text with the output printed by the command.
.ix "command line"
We did something alike in the C program when reading the output for a
command using a pipe. This time, Rc will do it for us, and relieve us from
typing something that can be generated using a program. This is an example.
.P1
; date
Fri Jul 21 16:36:37 MDT 2006
; today=`{date}
; echo $today
Fri Jul 21 16:36:50 MDT 2006
.P2
.LP
Another example, using a command that writes numbers in sequence, follows.
.ix [seq]
.P1
; seq 1 5
1
2
3
4
5
; echo `{seq 1 5}
1 2 3 4 5
;
.P2
.LP
As you can see, the second command was equivalent to this one:
.P1
; echo 1 2 3 4 5
.P2
.LP
The shell executed
.CW "seq 1 5" ,
and then did read the text printed by this command through its standard output
(using a pipe). Once all the
command output was read, Rc replaced the
whole \f(CW`{\fP...\f(CW}\fP construct with the text just read. The resulting line
was the one executed, instead of the one that we originally typed. Because
a newline character terminates a command, the shell replaced each
.CW \en
in the command output with a space. That is why executing
.CW seq
directly yields 5 lines of output, but using it with \f(CW`{\fP...\f(CW}\fP
produces just one line of output.
.PP
A related expression provided by the shell is \f(CW<{\fP...\f(CW}\fP.
Like before, Rc executes the command within the brackets, when it finds
.ix "here file
this construct in a command line. The output of the command is sent through
a pipe, and the whole \f(CW<{\fP...\f(CW}\fP is replaced by a file name that
represents the other end of the pipe (pipes are also files!, as we will see in a following
chapter).
.PP
There are several interesting uses for \f(CW<{\fP...\f(CW}\fP, one of them is to be able
to give a file name for the input file for a command, but still use as input another
command that writes to its standard output.
.P1
; wc <{seq 1 5} /LICENSE
      5       5      10 /fd/13	\fIThis is the pipe!\fP
    261    1887   13006 /LICENSE
    266    1892   13016 total
;
.P2
.LP
But, perhaps, the most amazing use for this construct is to build non-linear pipelines.
That is, to use the output of
.I several
commands as input for another one. For the latter, the output of the former ones
would be just a couple of file names. An interesting example is comparing the output
of two commands. The shell command
.CW cmp
.ix [cmp]
.ix "file compare
compares two files, and informs us whether they have the same contents or not.
.P1
; cp /LICENSE /tmp/l
; cmp /LICENSE /tmp/l
; cmp /LICENSE /NOTICE
/LICENSE /NOTICE differ: char 1
.P2
.LP
Therefore, if you want to execute two commands and compare what they write to their
standard output, you can now use
.CW cmp
as well.
.ix "non-linear pipe
.P1
; cmp <{seq 1 3} <{echo 1 ; echo 2 ; echo 3}
; cmp <{seq 1 3} <{echo 1 2 3}
/fd/14 /fd/13 differ: char 2
;
.P2
.LP
You will get used to \f(CW`{\fP...\f(CW}\fP and \f(CW<{\fP...\f(CW}\fP after using them
in the couple of chapters that discuss programming in Rc.
.BS 2 "Notes and process groups
.LP
.ix "notes
.ix "process group
Pipes are a
.B "synchronous communication
mechanism. A process using a pipe must call
.CW read
or
.CW write
.ix pipe
to receive or send data through the pipe, and communication happens
only when the process makes these calls. Sometimes, the world is not
so nice and we need an
.B "asynchronous communication
mechanism. For example, if a process gets out
of control and you want to stop it, you may want to post a note
saying “interrupt” to the process. The process is not reading from
anywhere to obtain the message you want to send, but you still
can send the message at any moment. The message will interrupt
.ix "interrupt
the normal execution of the process, so this mechanism is to be
used with care.
.PP
.ix "note post
Posting notes can be dangerous, when the process is not paying
attention to the note posted it is killed by the system.
.PP
This is our first example, we are going to use the window system to
interrupt a process. When
.CW cat
is given no arguments, it reads from the console. It will be doing so
unless you type a
.I control-d
to ask the window to signal a (fake) end of file. This time, we are
not going to do so. Run this command and press
.I Delete .
.P1
; cat
	\fIcat waits reading... \fP
\fBDelete\fP	\fI...until you press delete,\fP
;	\fIand cat is gone!\fP.
.P2
.LP
What happen to
.CW cat ?
Let's ask the shell:
.P1
; echo $status
cat 735: interrupt
;
.P2
.LP
According to the shell,
.CW cat
died because of
.I interrupt .
.PP
.ix "window system
.ix "console
.ix focus
When you type characters, the window system reads them from the
real console. Depending on which window has the
.I focus ,
i.e. on which one did you click last, it sends the characters to the
corresponding window. If the window system reads a
.I Delete
key, it understands that you want to interrupt the process in the window
that has the focus, and it posts a note with the text
.CW interrupt
.ix "[interrupt] note
for all the processes sharing the window. The shell is paying attention
(and ignoring) the note, therefore it remains unaffected. However,
.CW cat
is not paying attention to it, and gets killed in action.
.PP
Let's do it by hand. We need a victim.
.P1
; sleep 3600 &
;
.P2
.LP
And this one gives us one hour to play with it. The process is alive and well:
.P1
; ps | grep sleep
nemo           1157    0:00   0:00        8K Sleep    sleep
; echo $apid
1157
.P2
.LP
.ix [apid]
We check that it is our process, looking at
.CW $apid .
No tricks here. To post a note to a process, the note text is written to a file
in
.CW /proc
.ix "[/proc] file system
that provides the interface to post notes to it. Remember that this file
is just an interface for the process, and not a real file. For this process,
the file would be
.ix "process [note] file
.CW /proc/1157/note .
To do exactly the same that the window system is doing, we want to
post the note to
.I all
processes sharing its window. Writing the note to
.CW /proc/1157/notepg
.ix "process [notepg] file
.ix "process interrupt
does this:
.P1
; echo interrupt >/proc/1157/notepg
; ps | grep 1157
;
.P2
.LP
It is gone! 
.PP
The file is called
.CW notepg
because it refers to a
.B "process group" .
Processes belong to groups only for administrative reasons. For example,
.I Delete
should affect all the processes active in a window. Otherwise, you would
not be able to interrupt a command line with more than one process, like
a pipeline.
.PP
Usually, there is a process group per window, and
it is used to deal with all the programs on the window at once.
When a window is deleted using the mouse, you expect the programs
running on it to die. The window system posts a
.CW hangup
.ix "[hangup] note
note when the window is deleted. The note is posted
to all the processes in the window, i.e., to the process group of the shell
running in the window. We can also try this.
.P1
; echo hangup >/proc/$pid/notepg
	\fIAnd the window is gone!\fP
.P2
This required
having an abstraction, i.e., a mechanism, to be able to group those processes
and post a note just for them. The process group is this abstraction.
.PP
By the way, notes are the mechanism used by the system to signal exceptional
.ix exception
conditions, like dividing by zero. Notes posted by the system start with
.CW suicide: ,
and put the process into the broken state, for debugging.
.PP
Processes can use
.CW atnotify
.ix [atnotify]
.ix "note handler
to register a notification handler that listens for notes. The function receives
a note handler as a parameter, and installs the handler if the second
parameter is true, or removes the handler otherwise.
.P1
; sig atnotify
	int atnotify(int (*f)(void*, char*), int in)
.P2
.LP
The handler is a function that receives a pointer to the process registers
as they were when it noted the note. This is usually ignored. The second
parameter is more interesting, it is a string with the text from the note.
When the note is recognized by the handler, it must return true, to indicate that
the note was attended. Otherwise, it must return false. This is required because
there can be many handlers installed for a process, e.g., one for each type
of note. When a note is posted, each handler is called until one returns true.
If no handler does so, the note is not attended, and the process is killed.
.PP
This program may provide some insight about notes. It registers a handler
that prints the note received and pretends that it was not attended (returning
zero).
.so progs/pnote.c.ms
.LP
If we run the program, and press
.I Delete
while it is running, this is what happens:
.P1
; 8.pnote
	\fIthe program runs until we press Delete. And then, ...\fP
\fBDelete\fP
note: interrupt
; echo $status
8.pnote 1543: interrupt
;
.P2
.LP
The program is killed, because it did not handle the note. When we pressed
.I Delete ,
.ix "process kill
the program was executing whatever code it had to execute. In this case,
it was blocked waiting inside
.CW sleep
for time to pass by. The note caused the system call to be interrupted, and
the process
.I jumped
to execute its handler where it printed its message. Because no handler recognized
the note, the process was killed.
.PP
Notes are asynchronous, and
.ix "asynchronous communication
this means that the handler for a note may run at any time, when it pleases
Plan 9 to instruct your process to stop what it was doing and jump into the
note handler. This is similar to the model used for
.I interrupts ,
which is quite different from the
.I process
model: One single continuous flow of control, easy to understand.
.PP
We are now going to modify the handler to return true, and not zero. This is
what the new program does.
.P1
; 8.pnote
	\fIthe program runs until we press Delete. And then, ...\fP
\fBDelete\fP
note: interrupt
done (interrupted)
; echo $status

;
.P2
.LP
The program was executing the
.CW sleep
.ix [sleep]
system call, it was blocked waiting for time to pass. After hitting
.I Delete ,
.ix [Delete]
a note was posted. The natural flow of control for the process was
interrupted, and it jumped to execute the note handler. It prints the
text for the note,
.I interrupt ,
and returns true. The note was recognized and Plan 9 is happy with that. The
process is not killed. Instead, it continues where it was. Well, mostly.
.PP
The process
did not wait for one hour! Because of the note, the system call was interrupted.
It returns an error to report that. But it returns. The program is still running
at the same point it was when the note was posted. We printed the error string
reported from
.CW sleep
to see that it is
.CW interrupted .
.PP
In general, notes are not to be used in your programs. In other systems,
they are used to remove temporary files if a program is interrupted. In Plan 9,
there is a better way for doing this. Any file that you open with the
.CW ORCLOSE
.ix "[ORCLOSE] open~flag
flag, for example,
.P1
fd = open("/tmp/tempfile", ORDWR|ORCLOSE);
.P2
is automatically removed by the system when the file descriptor is closed. If
your program dies because of a note, the descriptor is closed as part of the
natural dying process. At that point, the file is removed. Using notes it could
be done by installing a note handler like this one
.P1
int cleanup(void*, char* msg)
{
	if (strcmp(msg, "interrupt") == 0)
		remove("/tmp/tempfile");
	return 0;
}
.P2
.ix "[interrupt] note
.ix "note handler
.LP
But this is an
.I horrible
idea. Notes can happen at any time, behind your back. You are executing
your nice single flow of control, and there are functions as nasty as the
pop-ups in other window systems, that run at unexpected times and may
cause your program to fail.
.PP
When are notes posted by Plan 9? The kernel is not a magic program.
It can post a note only when it executes. Besides, for simplicity, a note
is handled from within the process that receives it. A write into the
.CW note
.ix "process [note] file
or the
.CW notepg
.ix "process [notepg] file
file records that the target process(es) has a note posted. Sooner or later,
the target process will be allowed to run (if only to process the pending note),
At that point, when returning from the kernel
back to the user's code, is when the note is processed.
.PP
If the process receiving the note was performing a system call that does not
block, the system call is allowed to complete and the note is posted while
returning from the call. On the other hand, if the process was performing a
.I slow
system call, and was blocked trying to read, or write, or any other thing,
the system call is interrupted, as we saw before.
.BS 2 "Reading, notes, and alarms
.ix "robust file read
.LP
You know how to read from a file. To read
.I n
bytes from a file the program must call
.CW read
until all the
.I n
bytes are read, because
.CW read
.ix [read]
may return less bytes than requested. This is so common, that a library
function
.CW readn
.ix [readn]
exists that keeps on calling read until all the
.I n
bytes have been read.
However, This function may return less bytes than requested, because of a note.
Of course this would happen only if the process is attending the note, because
it would be killed otherwise, and what
.CW readn
does would not matter at all.
.PP
To actually read
.I n
bytes even when receiving notes, we can use this alternate function:
.P1
.ps -2
.vs .15i
long
robustreadn(int fd, char* buf, long n)
{
	long	nr, tot;
	char	err[128];

	for (tot = 0; tot < n; tot += nr){
		nr = read(fd, buf+tot, n-tot);
		if (nr == 0)
			break;
		if (nr < 0){
			rerrstr(err, sizeof(err));
			if (strcmp(err, "interrupted") == 0)
				nr = 0; // retry
			else
				break;
		}
	}
	return tot;	
}
.ps +2
.P2
.ix [robustreadn]
.LP
It requires the process to install a handler for the
.CW interrupted
note, or the process will be killed.
.PP
Surprisingly enough, there are times when the problem is not that
.CW read
is interrupted, but, on the contrary, the problem is that it is not interrupted.
For example, a process may need to read a message sent from anywhere else
in the network. This is achieved by calling
.CW read
on a file that is used to
.I connect
the process with the one that is supposed to send it a message. Similar to a
pipe, but crossing the network. There is a problem in this case. If the other (remote)
process hangs, because of a bug or any other reason, it may never send its message.
The poor process that is reading will be blocked awaiting, forever, for the message
to arrive.
.PP
To recover from this circumstance, it is usual to employ a
.B timeout .
.ix "process alarm
.ix [alarm]
A timeout is an alarm timer used to be sure that there is a limit in the amount of
time that we wait for some operation to complete. In this case, it seems reasonable
to use a timeout of 30 seconds. That is an incredibly long time for a computer, even
when considering the delays involved in crossing the network to send or receive a
message.
.PP
Plan 9 provides an alarm timer for each process. The timer is started by calling
.CW alarm ,
giving as a parameter the number of milliseconds that must pass before the timer
expires.
.P1
; sig alarm
	long alarm(unsigned long millisecs)
.P2
.LP
There is
.I no
guarantee that the timer will last for exactly that time. It might take a little bit
more if the system is busy doing any other thing. However, real soon after
the specified number of milliseconds, an
.CW alarm
note will be posted for the process that did call
.CW alarm .
And you know what happens, when the note is posted, any system call that
kept the process awaiting (e.g.,
.CW read )
will be interrupted. The following program reads a line from the terminal,
and prints it to the standard output. However, it will wait at most 30 seconds
for a line to be typed.
.so progs/alarm.c.ms
.ix [alarm.c]
.LP
Right before calling
.CW read ,
the program installs an alarm timer of 30 seconds. That much time later, it will
post the
.CW alarm
note. If we type something and
.CW read
completes before that time, the program calls
.CW alarm(0)
.ix "alarm cancel
to cancel the timer. Otherwise, the timer expires and
.CW read
is interrupted.
.P1
; 8.alarm
type something: !!Hi there
Hi there
; 8.alarm
type something: timed out	\fIWe did not type anything for 30secs\fP
;
.P2
.LP
.ix timer
In general, timers are to be used with caution. They make programs unpredictable.
For example, it could happen that right after we typed our line the timer expires.
This could happen at
.I any
time, not necessarily while we are waiting in
.CW read ,
but perhaps when we are in our way to cancel the timer. At least,
it is wise to give plenty
of time for a timeout, to make things more predictable, and it is even better
not to use it unless it is absolutely necessary.
.BS 2 "The file descriptor bulletin board
.LP
.ix registry
.ix "file descriptor board
.ix "[/srv] file~system
.ix "[#s] device~driver
Sometimes, processes need to talk through a pipe, but they
do not have an appropriate ancestor where to create the pipe. This
happens when, after a process has been created, a newcomer wants
to talk to that process.
.PP
The program that implements the file system,
.CW fossil ,
.ix [fossil]
.ix "file server
.ix boot
is a perfect example. It is started (in the file server machine)  during
the boot process. Once started, programs may use files by talking to
the file server using the network.
.PP
But there is a problem. The file system, see
.I fossil (4),
has to be able to accept commands from a human operator, to carry out administration
tasks. For
.CW fossil ,
a simple way is to create a pipe and attend one end of the pipe, reading commands
and writing replies (pipes are bi-directional).
Any process used by a human at the other end of the pipe
may talk to the file system, to administer it.
Here is an example of a conversation between a human
and the file system:
.ix "fossil console
.P1
main: fsys
	main
main: sync
	main sync: wrote 0 blocks
main: who
	console      
	/srv/boot     nemo
	/srv/fossil   nemo
	/srv/vfossil  nemo
	/srv/fboot    nemo
.P2
.LP
When we wrote
.CW fsys ,
fossil replied with the list of file systems. When we typed
.CW sync ,
fossil
.I synchronized
its changes with disk (any change to a file that was not yet copied to the
disk, was copied immediately). When we typed
.CW who ,
the file system wrote the list of users using the file system.
.PP
How can we reach the pipe used to talk to
.CW fossil ?
The directory
.CW /srv
.ix [/srv]
is special. It is a file descriptor bulletin board. A process can
.I post
.ix "file descriptor post
a file descriptor into this bulletin board by creating a file
on it. For example, in my system,
.CW /srv/fscons
is a file that corresponds to the end of the pipe used to talk to fossil.
.PP
The idea is not complex, once you realize that files in Plan 9 are not
real files, most of the times. The file
.CW /srv/fscons
is not a file, it looks like, but it is just a file interface for a file descriptor
that
.CW fossil
has open.
Because
.CW /srv/fscons
.I looks
like a file, you can open it and gain access to the file descriptor. And you
do not require a common ancestor with fossil!
.PP
For example, this, when executed in the file server, asks
.CW fossil
to write any pending change to the disk.
.P1
; echo sync >>/srv/fscons
.P2
.LP
.LP
When the shell opens
.CW /srv/fscons ,
it is not opening yet another file. It is obtaining a file descriptor that is
similar to the one posted into
.CW /srv/fscons
by
.CW fossil .
The result is the same of calling
.CW dup
to duplicate the descriptor kept inside
.ix [dup]
.CW /srv/fscons ,
however, you cannot call
.CW dup .
You do not have the file descriptor to duplicate, because it belongs to another
process.
.PP
This program is an example of how to use this bulletin board. It creates
one pipe and reads text from it, printing a copy to standard output, so we
could see what is read. The other end of the pipe is posted at
.CW /srv/echo ,
.ix "echo server
for us to use.
.ix [srvecho.c]
.so progs/srvecho.c.ms
.LP
The
.CW create
.ix [create]
call for
.CW /srv/echo
creates a file where the program can post a file descriptor. The way to
do the post is by writing the file descriptor number into the file, and closing it.
The created file at
.CW /srv
is just an artifact. What matters is that now there is another way to get to the
descriptor in
.CW fd[1] .
Because the program does not use that descriptor itself, it closes it. Note that
the pipe end is
.ix pipe
.ix "file server
.I not
closed at this point. The descriptor kept inside
.CW /srv/echo
is also leading to that end of the pipe, which therefore remains open.
From now on, the program reads from the other end of the pipe to do the echo.
.P1
; 8.srvecho &
; lc /srv
boot		echo		plumb.nemo.264	slashmnt
cs_net		fscons		slashdevs	vol
; echo hi there! >>/srv/echo
hi there!
; ps | grep 8.srvecho
nemo   2553  0:00 0:00  24K Pread  8.srvecho
.P2
.LP
If we remove the file
.CW /srv/echo ,
and no process has the file descriptor open for that end of the pipe, our
program would receive an end of file indication at the other end of the pipe, and
terminate.
.P1
; rm /srv/echo
exiting
; 
.P2
.LP
Files in
.CW /srv
are just file descriptors. They only difference is that they are
published in a bulletin board for anyone
to see. How is this done? In a simple way, each file for
.CW /srv
.ix [Chan]
contains a reference to the Chan of the descriptor posted in it. Figure
[[!posted descriptor!]] shows the elements involved in the session we have
just seen.
.LS
.PS 5i
.ps -2
right
boxht=.2
boxwid=1
B: [
	down
	circle rad .4 "Echo" "process"
	line -> down " File descriptor" ljust  " table" ljust
	D: [ down
	 	[ right
		box invis wid .2  "0" ; F: box   ]
	D0: last [].F
		[ right
		box invis wid .2  "1" ; F: box   ]
	D1: last [].F
		[ right
		box invis wid .2  "2" ; F: box   ]
	D2: last [].F
		[ right
		box invis wid .2  "3" ;  F: box    ]
	D3: last [].F
		[ right
		box invis wid .2   ;  box invis   "..."]
		[ right
		box invis wid .2  "n" ; F: box   ]
	]
	spline -> from D.D3 right then down 1 then right 
	C: box wid 1.5 ht 2*boxht "file: pipe \f(CW ORDWR\fP" "\f(CWoffset: 0\fP"
	arrow
	box "pipe"
	spline <- right then up .5 left .5 then up .5
	C: box wid 1.5 ht 2*boxht "file: pipe \f(CW ORDWR\fP" "\f(CWoffset: 0\fP"
	arrow <-
	circle rad .5 "File" "\f(CW/srv/echo\fP"
]
.PE
.LE F A file descriptor posted at \f(CW/srv/echo\fP used to talk to a process through a pipe.
.BS 2 "Delivering messages
.LP
Presenting every resource as a file may be an inconvenience when programs need
to act after some success happens. For example, the program
.CW faces
.ix [faces]
.ix [mail]
(see figure [[!faces!]])
shows a small face image for each email received by the user, displaying an image
that describes the sender for each mail. When a mail arrives,
.CW faces
must show a new face to alert the user of the new incoming mail.
In this case, usually, the program must check out the files
of interest to see if the thing of interest happen. This is called
.B polling ,
and the thing of interest is called an
.B event .
.LS
.BP faces.ps 1.5i
.LE F The program \f(CWfaces\fP shows small faces for persons that sent email to us.
.PP
Polling has the problem of consuming resources each time a poll is made to check
.ix "busy waiting
.ix efficiency
out if an interesting event happen. Most of the times, nothing happens and the
poll is a waste. Therefore, it would be very
inefficient to be all the time polling for an event and, as a result, programs that poll
usually call
.CW sleep
.ix [sleep]
between each two polls. The following two programs wait until the file given
as a parameter changes, and then print a message to let us know. The first one
performs a continuous poll for the file, and the second one makes one poll each 5 seconds.
.so progs/poll.c.ms
.ix [poll.c]
.so progs/pollb.c.ms
.ix [pollb.c]
.LP
It is interesting to see how loaded is the system while executing each program.
The
.B "system load"
is a parameter that represents how busy the system is, and it is usually
indicative of how much work the system is doing.
The load is measured by determining which percentage of the time the system is running
a process and which percentage of the time the system is not.
In a typical system, most of the time there is just nothing to do.
Most processes will be blocked waiting for
something to happen (e.g., inside a
.CW read
waiting for the data to arrive). However, from time to time, there will be some processes
with a high demand of CPU time, like for example, a compiler  trying to compile a program,
and the system load will increase because there's now some process that is often
.ix "CPU time
.ix "[Ready]
.ix "[Running]
.ix "process state
ready to run, or
running.
.PP
We can use the
.CW stats
.ix [stats]
.ix "system statistics
tool to display the system load.
This tool shows a graphic depicting the system load and other statistics. For example,
both figures [[!intensive polling!]]
and [[!sleeps between polls!]] show a window
running
.CW stats .
Figure [[!intensive polling!]] shows the system load for our first experiment regarding
polling. It is hard to see in a book, but the graph displayed by
.CW stats
is always scrolling from right to left as time goes by. Around the middle of the graph
it can be seen how the load increased sharply, and went to a situation where almost
always there was something to do. The system started to be heavily loaded. 
This was the result of executing the following.
.P1
; 8.poll poll.c
	\fI"...and the machine got very busy until we hit Delete\fP
\fBDelete\fP
;
.P2
.LS
.BP statspoll2.ps 1.3i
.LE F A window running \f(CWstats\fP while the intensive polling program increased the load.
.LP
The process
.CW 8.poll
was
.I always
polling for a change on its file. Therefore, there was always something to do.
.ix polling
Despite being run on a very fast machine,
.CW 8.poll
never ceased to poll. When the system decided that
.CW 8.poll
got enough processor time, and switched to execute any other process,
our polling process ceased to poll for a tiny fraction of time. Later on, it will
be put again in the processor and consume all the time given to it by the system.
When all processes are blocked waiting for something to happen,
.CW 8.poll
is still very likely to be ready to run. As a result, the system load is at its maximum.
Later, we pressed
.I delete
and killed
.CW 8.poll ,
and the system load came back to a more reasonable value.
.PP
Note that a high load does
.I not
mean that the system is unresponsive, i.e., that it cannot cope with any more work
to do. It just means that there is always something to do. Of course, given the
sufficient amount of things to do, the system will become unresponsive because
no process will be given enough processor time to complete soon enough. But
that does not need to be the case if the load is high.
.LS
.BP statspoll.ps 1.3i
.LE F The system load is not altered if the program sleeps between polls.
.PP
Compare what you saw with the load while executing our second version for
the polling program, which calls
.CW sleep
to perform one poll each 5 seconds. The window running
.CW stats
while we executed this program is shown in figure [[!sleeps between polls!]].
This program behaved nicely and did not alter much the system load. Most of the
time it was sleeping waiting for the time for its next poll. As an aside, it is
interesting to say that Plan 9 typically
exhibits a much lower system load than both figures show. The system used to capture
both images is a derivative of Plan 9, called Plan B, which uses polling for many things.
When there are many processes polling, the load naturally increases even if the
processes sleep between polls.
.PP
The
.CW sleep
.ix [sleep]
used by programs that poll introduces another problem: delays.
If the event does occurs and the polling program is
sleeping, it will not take an appropriate action until the
.CW sleep
completes. And this is a delay. If the process waiting for the event produces, as
a result, another event, the delay of any other process polling for the later event
is added to the chain.
.PP
The consequence of what we have discussed so far
is that most operating systems provide an abstraction to deliver events and
.ix event
to wait for them. The abstraction is usually called an
.B "event channel" ,
and is used to convey events from the ones that produce them to the ones that
await for them.
.PP
An event is a particular data structure, that contains the information about
the success it represents. This means that events can be used as a
communication means between the processes that produce them and the ones
that consume them.
.PP
In Plan 9, there is a service called
.B plumbing
.ix [plumber]
.ix "plumb message
.ix pipe
that provides a message delivery service. The name of the program is
.CW plumber
because it is meant to do the plumbing to convey data from message
producers to consumers. In effect, it provides a nice event delivery service.
The plumber is built upon the assumption that once you look at a particular
piece of data it is clear what to do with it. For example, if a message looks like
.CW http://lsub.org/ ...
then it is clear that it should probably be delivered to a web browser. If a message
looks like
.CW pnote.c:15 ,
then it is likely that it should be delivered to an editor, to open that file and show
the line after the colon.
.PP
Like many other programs, the plumber is used through a file interface. The files
that make up the interface for the plumber are usually available at
.ix "[/mnt/plumb] file system
.CW /mnt/plumb.
.P1
; lc /mnt/plumb
edit		msntalk		rules		showmail
exec		msword		seemail		song
image		none		send		voice
man		postscript	sendmail	www
.P2
.LP
Each one of these files (but for
.CW rules
.ix "plumber [rules]
and
.CW send )
.ix "plumber [send]
.ix "plumber port
is called a
.B port ,
and can be used to dispatch messages to applications reading from them.
The
.CW send
file is used to send a message to the plumber, which will choose an
appropriate port for it and then deliver the message to any process reading
from it.
.LS
.PS 5i
.ps -1
circlerad=.4
.R
right
S: [	down
	circle "sender" "process"
	arrow
	P: box "\f(CWsend\fP"
]
move
[	down
	circle "editor"
	arrow <-
	box "\f(CWedit\fP"
]
move
W: [	down
	circle "web" "browser"
	arrow <-
	P: box "\f(CWwww\fP"
]
move
[	down
	[ right; I1: circle "image" "viewer" ; move ; I2: circle "image" "viewer" ]
	move
	box "\f(CWimage\fP"
	arrow <- from last [].I1.se to last box.n
	arrow <- from last [].I2.sw to last box.n
]
spline from S.P.s down then right
line right 1.4  "\f(CWhttp://lsub.org/\fP"  "message delivered by the plumber" 
spline -> right 1 then to W.P.s
reset
.ps +1
.PE
.LE F The plumber provides ports, used to deliver messages to applications.
.PP
For example,  figure [[!plumber ports!]] shows what would happen when
a process writes to the
.CW send
port a message carrying the data \f(CWhttp://lsub.org/\fP. Because the data looks like
something for a
.CW www
port, the plumber delivers the message to any process reading from that port.
If more than one process is reading from the port (as shown in the figure for
images), the message is delivered to
.ix "message delivering
.I all
of them.
.PP
Even if you didn't notice, you have been using the plumber a lot. Every time you click
.ix "[acme] plumbing
.ix "mouse button-3
with the mouse button-3 at something in Acme, the editor sends a message to the
plumber with the text where you did click. Most of the times, the plumber
determines that the message is for processes reading the port
.CW edit ,
.ix "[edit] plumb~port
i.e., editors. Thus, the message is conveyed back to Acme in many cases.
You may try it by hand. If you have an Acme running and you execute
.P1
; plumb /NOTICE
;
.P2
.LP
on a shell, the file
.CW /NOTICE
will show up in your editor. The plumber even knows that if there's no editor
reading from the
.CW edit
port, an editor should be started. You can try by executing again the
.CW plumb
command above, but this time, while no editor is running.
.PP
How does the plumber know what to do? The file
.CW $home/lib/plumbing
is read by the plumber when it starts (usually from your
.CW $home/lib/profile
.ix [profile]
.ix [plumbing]
while entering the system). This file has rules that instruct the plumber
to which port should each message be sent according to the message data.
Furthermore, the file may instruct the plumber to start a particular application
(e.g., an editor) when no one is listening at a given port. After the plumber
has been started, its rules can be updated by copying whatever rules are
necessary to the
.CW /mnt/plumb/rules
file.
.PP
It is still too early for us to inspect this file, because it uses
.I "regular expressions" ,
.ix "regular expression
that are yet to be discussed. However, it is useful to know that by default
certain messages are processed in a particular way:
.IP •
Files with particular formats, like MS Word files, are delivered usually to
the program
.CW page ,
.ix [page]
.ix "document viewer
.ix "MS~Word viewer
.ix "PostScript viewer
which converts them to postscript and shows their contents on a window.
.IP •
Most other files go to the editor. Optionally, there may be a
.CW :
followed by an
.ix "file address
.I address
after the file name, to instruct the editor to go to a particular piece of text
in the file. For example,
.CW /NOTICE:2
would make an editor show line 2 of
.CW /NOTICE .
There are other types of addresses, besides line numbers.
A very useful one is of the form
.CW /text .
That is, some text after a
.CW / ,
like in
.CW /NOTICE:/cent .
This causes the editor to
.ix "text search
.I search
for the text (for
.CW cent
in this case). The text that you type is actually a regular expression, and not
just a string. This is a more powerful mechanism to search for things, that
will be seen in a later chapter.
.IP •
Mail addresses get a new window running the
.CW mail
program.
.IP •
A file name ending in
.CW .h
is looked for at
.CW /sys/include ,
.ix [/sys/include]
and then passed to the editor. For example, a plumb of
.CW libc.h
would open
.CW /sys/include/libc.h
.IP •
A name for a manual page, like
.CW ls(1)
.ix "manual page
causes the editor to display the formatted manual page. Very convenient when
using acme. Type the manual page, and click with the button-3 on it.
.LP
We went this far, but we still do not know what a plumber message is.
A plumber message does not only carry data. Along with the data, there is some
metadata that supplies additional information about the data. Thus, each message
has a set of attributes and their values, besides the data.
.ix "plumb message attributes
Some
attributes are always present in a message (although their values might be empty).
Other attributes are used by programs using a particular kind of message, and
there can be any number of them. You may also invent any attribute that you need
if you use plumber messages for a particular thing. These are the standard
attributes for a message:
.IP
.B src
A string that names the source for the message, usually a program name.
.IP
.B dst
A string that names the destination port for the message. If it is not supplied,
the plumber tries to choose using the
.CW rules
file.
.IP
.B wdir
The working directory used by a process that is sending a message carrying a
file name. This is necessary to let the receipt of the message determine to which
file the message refers to. Note that a file name may be a relative path, and you
need to know with respect which (current working) directory it is relative to.
.IP
.B type
A string describing the type of data. Most of the times the type is just
.CW text ,
which is later, perhaps, interpreted as a file name or as the name for a manual
page.
.IP
.B ndata
Number of bytes in the data for the message.
.LP
How can you use the plumber? From the shell, the
.CW plumb
.ix "[plumb] command
.ix "[plumb] library
program lets you send messages, as you saw. From a C program, there is
a library called
.I plumb (2)
that provides an interface for using the plumber. The following program
listens for plumb messages sent to the
.CW edit
port, and prints the file name for each such message.
.so progs/edits.c.ms
.ix [edits.c]
.LP
The function
.CW plumbopen
.ix [plumbopen]
.ix "plumb~port open
opens the plumb port given as its first parameter (using the open mode indicated
by the second one). It returns an open file descriptor where we can read or write
plumb messages. In this case, we open the
.CW edit
port. The function opens
.CW /mnt/plumb/edit
if we do not supply a path for the file name. To receive a message, the program calls
.CW plumbrecv ,
.ix [plumbrecv]
.ix "plumb message receive
which blocks reading from the port until the plumber supplies the data from the message.
This function may have to read several times, until an entire message has been read.
It returns a pointer to the message read, which has this data structure:
.ix [Plumbattr]
.ix [Plumbmsg]
.ix "plumb message attribute
.P1
typedef struct Plumbattr Plumbattr;
typedef struct Plumbmsg Plumbmsg;

struct Plumbmsg
{
	char		*src;
	char		*dst;
	char		*wdir;
	char		*type;
	Plumbattr	*attr;	// list of attributes
	int		ndata;
	char		*data;
};

struct Plumbattr
{
	char		*name;
	char		*value;
	Plumbattr	*next;
};
.P2
.LP
The program looks in the attribute list for the message, pointed to by the
.CW attr
field, for an attribute named
.CW addr ,
which is the address following the file name in the plumbed message.
To do so, it calls
.CW plumblookup ,
giving the
.CW attr
list and the name of the desired attribute. The working directory for the message,
the data, and the address attribute's value are printed next. At last, the
message data structure is deallocated by a call to
.CW plumbfree .
.PP
We can deliver messages to
our program by doing clicks on Acme, with the mouse button 3, and
also by running
.CW plumb
from the shell like we do below.
.ix [plumb]
.P1
; plumb /NOTICE:2
; plumb edits.c
; plumb /sys/doc/9/9.ps
; plumb edits.c:/main
;
.P2
.LP
The corresponding output for our program, which we did run at a different window,
follows. Note how the message for
.CW 9.ps
was not sent to the
.CW edit
port, and therefore is not received by our program. It was sent to a different
program,
.CW page ,
to display the postscript file.
.P1
.ps -2
; 8.edits
msg: wdir='/usr/nemo/9intro' data='/NOTICE' addr='2'
msg: wdir='/usr/nemo/9intro' data='/usr/nemo/9intro/edits.c' addr=''
msg: wdir='/usr/nemo/9intro' data='/usr/nemo/9intro/edits.c' addr='/main'
.ps +2
.P2
.LP
One last question. Which format is used to actually write and read messages
from the file that is the plumb port? Is it a esoteric format? No. It is simply a set
of lines with the source application, destination port, working directory, message
type, message attributes, and number of bytes of data, followed by the indicated
number of bytes carrying the data. This is easy to see by using
.CW cat
to read from the edit port while executing the same
.CW plumb
commands used above.
.P1
; cat /mnt/plumb/edit
plumb
edit
/usr/nemo/9intro
text
addr=2
7
/NOTICE		\fINew line supplied by us\fP
plumb
edit
/usr/nemo/9intro
text
addr=
24
/usr/nemo/9intro/edits.c		\fINew line supplied by us\fP
plumb
edit
/usr/nemo/9intro
text
addr=/main
24
/usr/nemo/9intro/edits.c		\fINew line supplied by us\fP
\fBDelete\fP
;
.P2
.LP
Sending a plumb message is very simple, given the helper routines in
.I plumb (2).
The routine
.CW plumbsend
.ix [plumbsend]
sends a message as described by a
.CW Plumbmsg
structure. The routine
.CW plumbsendtext
.ix [plumbsendtext]
is a even more simple version, for those cases when the message is just a
text string.
.P1
.ps -2
; sig plumbsend plumbsendtext
	int plumbsend(int fd, Plumbmsg *m)
	int plumbsendtext(int , char *, char *, char *, char *)
.ps +2
.P2
.LP
For example, this would send a message with the text
.CW /NOTICE .
.P1
.ps -2
	int	fd;

	fd = plumbopen("send", OWRITE);
	if (fd < 0)
		sysfatal("open: %r");
	if (plumbsendtext(fd, argv0, nil, nil, "/NOTICE") < 0)
		sysfatal("send: %r");
.ps +2
.P2
.LP
A similar effect can be achieved by initializing and sending a
.CW Plumbmsg
as follows.
.P1
.ps -2
	Plumbmsg m;
	int	fd;

	fd = plumbopen("send", OWRITE);
	if (fd < 0)
		sysfatal("open: %r");
	m.src = m.dst = m.wdir = nil;
	m.type = "text";
	m.attr = nil;
	m.data = "/NOTICE";
	m.ndata = strlen(m.data);
	if (plumbsend(fd, &m) < 0)
		sysfatal("send: %r");
.ps +2
.P2
.SH
Problems
.IP 1
What would this command do?
.P1
cp /fd/1 /fd/0
.P2
.IP 2
Why do you think that the code to initialize standard input, output, and
error in the first process differs from this?
.P1
open("/dev/cons, ORDWR);
dup(0, 1);
dup(0, 2);
.P2
.IP 3
The code
.P1
fd = open("/NOTICE", OREAD);
dup(fd, 0);
close(fd);
.P2
.IP
may fail and leave standard input closed. When does this happen?
Why do you think this code was used for a program that redirected
standard input to
.CW /notice ?
.IP 4
Show that a process that reads from an empty pipe gets blocked and
will never run. Which state is reported by
.CW ps
for such process?
.IP 5
Modify the code for the
.CW srvecho
program to perform the echo through the pipe, and not to the
console. Use the program
.I con (1)
to connect to the pipe through
.CW /srv/echo
and test that it works.
.ds CH
.bp
 \c
