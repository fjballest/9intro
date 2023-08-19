.so tmacs
.BC 4 "Parent and Child
.BS 2 "Running a new program
.ix "program execution
.ix "process
.LP
In chapter 2 we inspected the process that is executing your code.
This process was created by Plan 9 in response to a request made
by the shell. Until now, we have created new processes only by asking
the shell to run new commands. In this chapter we explore how to create
.ix "command
new processes and execute new programs by ourselves.
.PP
You may think that the way to start a new process to run a program is
by executing a single system call (something like
.CW run("/bin/ls")
.ix "system call
for executing
.CW ls ).
That is not the case. There are two different system calls involved in the
process. One creates a new process, the other executes a new program.
.ix "process creation
.ix "program loading
There are several reasons for this:
.IP •
One reason is that you may want to
start a new process just to have an extra flow of control for doing something.
In this case, there would be no new program to execute. Thus, it makes sense
to be able to create a new process (e.g., a new flow of control) just for its
own sake.
.IP •
Another reason is that you may want to customize the environment for the
.ix "process environment
new process (e.g., adjust its file descriptors, change its working
directory, or any other thing)
.I before
it executes the new program. It is true that a
.CW run()
system call might include parameters to specify all things you may want to
customize. Such call would have countless parameters! It is far more simple
to let you use the programming language to customize
whatever you want in the process before it runs a new program.
.LP
Before going any further, this is a complete example using both system calls.
This program creates a new process by calling
.CW fork ,
.ix [fork]
and executes
.CW /bin/ls
in the new process by calling
.CW execl :
.ix [exec]
.ix [execl]
.so progs/runls.c.ms
.ix [runls.c]
.LP
The process running this program proceeds executing
.CW main ,
.ix [main]
and then calls
.CW fork .
At this point, a new process is created as an exact clone of
the one we had. Both processes continue execution returning
from
.CW fork .
For the original process (the
.B "parent process" ),
.CW fork
returns the pid for the new process. Because this is a positive
number, it enters the
.CW default
case. For the new process (the
.B "child process" ),
.CW fork
returns zero. So, the child process continues executing at
.CW "case 0" .
.ix "[fork] return~value
The child calls
.CW execl ,
which clears its memory and loads the program at
.CW /bin/ls
for execution.
.PP
We will now learn about each call at a time, to try to understand them well.
.BS 2 "Process creation
.ix "process creation
.LP
The system call
.CW fork
.ix [fork]
creates an exact
.I clone
of the calling process. What does this mean?
For this program
.so progs/onefork.c.ms
.ix [onefork.c]
.LP
This is the output
.P1
; !!8.onefork
one
fork
fork
.P2
.LP
The first
.CW print
was first executed. After that, we can see
.I twice
the text for the second
.CW print .
Indeed, it executed twice. When we asked the shell to run
.CW 8.onefork ,
it created a process to run our program. This process provides the flow
of control that, for us, starts at
.CW main
and proceeds until the call to
.CW exits .
.ix [exits]
.ix "process termination
Our process obeys the behavior we expect. It executes the first line, then
the next, and so on until it dies. At some point, this process makes a call to
.CW fork ,
and that creates
.I another
process that proceeds executing from
.CW fork
one line after another until it dies.
.LS
.PS 4i
.ps -4
arrowhead=7
boxht= .2
down
.\" proc(label,PC)
define proc {[
	P:	[ down
.			CW
			move .2
			boxwid=.2
			box invis "print(\"one\\en\");" ljust
			box invis "fork();" ljust
			box invis "print(\"fork\\en\");" ljust
			box invis "exits(nil);" ljust
.			R
		]
		box dashed wid 1.5 ht 1.2 with .nw at last [].nw
		box invis $1 with .sw at last box.nw
		x=.1+.2*$2
		PC: P.nw - 0,x
		arrow <- from PC left .4 "PC" above

]}

.\" Parent goes until fork...
B: [ right
	proc("Parent", 1) ; move ; box invis wid 1.9
]
move .1
[ right
	proc("Parent", 2) ; move ; box invis wid 1.9
]
move .1
C: [ right
	proc("Parent", 2); move ; proc("Child", 2);
]
move .1
[ right
	box invis wid 1.9 ; move ; proc("Child", 3);
]
move .1
[ right
	proc("Parent", 3) ; move ; box invis wid 1.9 
]
move .1
E: [ right
	proc("Parent", 4) ; move ; box invis wid 1.9 
]
move .1
CE: [ right
	box invis wid 1.9 ; move ; proc("Child", 4);
]
arrow  from B.nw + -.5,.0  to E.sw -.5,0 "Flow of control " rjust
arrow  from C.ne + .5,-.2  to CE.se +.5,0 " Child's flow" ljust
reset
.R
.ps +4
.PE
.LE F The call to fork creates a clone of the original process. Both proceed from there.
.PP
This can be seen in figure [[!fork clone!]]. The figure depicts the state for both processes
at different points in time. Time increases going down in the figure. The arrows in the
figure represent the program counter. Initially, only the parent
exists, it executes the instructions for the first
.CW print .
Later, the parent calls
.CW fork .
Later, during the system call, a
clone, i.e, the child, is created
as a copy of the original. This means that the memory of the child is a copy
.ix "process memory
of the memory of the parent. This memory includes the code, all the data, and the stack!
Because the child is a copy, it will return from the
.CW fork
call like the parent will; Its registers are also (almost) a copy. 
.ix "registers
.PP
From now on, we do
.I not
know in which order they will execute, and we do not know for how much time
one process will be executing each time it is given the processor. The figure
assumes that the child will execute now
.CW
print("fork\en")
.R
and then the parent will have enough time to complete its execution, and
the child will at last execute its remaining instructions. But we do not know. The system
may assign the processor in turns to these and other processes in any other way. Perhaps
the parent has time to complete right after calling
.CW fork
and before the child starts executing, or perhaps it will happen just the opposite.
.PP
The child executes \fBindependently\fP
.ix "independent execution
from the parent. For it, it does not matter what the parent does. For the parent,
it does not matter what the child does. That is the process abstraction. You get
a new, separate, stand-alone, flow of control together with everything it needs
to do its job.
.PP
To write your programs, did you have to think about what the shell program was doing?
You never did. You wrote your own program (executed by your own process) and
you forgot
.I completely
about other processes in the system. The same happens here. In Plan 9,
when a process has offspring, the child leaves the parent's house immediately.
.PP
Because the child is a copy, and all its memory is a copy of the parent's, variables
in the child start with the values they had by the time of the
.CW fork .
From there on, when you program, you must keep in mind that each variable you use
may have one value for the parent and another for the child. You just have to
.I fork
(hence the system call name)
the flow of control at the
.CW fork ,
.ix [fork]
and think separately from there on for each process. To check out that you really
understand
this, try to say what this program would print.
.so progs/intfork.c.ms
.ix [intfork.c]
.LP
The variable
.CW i
is initialized to
.CW 1
by the only process we have initially. After calling
.CW fork ,
each process (parent and child) increments
.I
it's own
.R
copy of the variable. The variable
.CW i
of the parent becomes
.CW 2 ,
and that of the child
becomes
.CW 2
as well. Finally, each process will print its variable, but we will always
get this output:
.P1
; 8.intfork
i=2
i=2
.P2
.LP
After calling
.CW fork ,
you may want to write an
.CW if
that makes the child do something different from the parent. If you could not
do this, they would be viruses, not processes.
.ix virus
Fortunately, it is simple. We have seen how
.CW fork
returns two times. Only the parent calls it, but it returns for the parent
(in the parent process) and for the child (in the child process). The return
value differs. This program
.so progs/child.c.ms
.ix [child.c]
.ix "child process
.LP
produces the following output
.P1
; 8.child
I am the child
I am the parent
.P2
.LP
To the parent,
.CW fork
returns the pid of the child, which we know is greater than zero. To the child,
.CW fork
always returns zero. Therefore, we can write different code to be executed in
the parent and the child after calling fork. Both processes have their own copy
for all the code, but they can follow different paths from there on.
.PP
When
.CW fork
fails, it returns
.CW -1 ,
and we should always check for errors. Of course when it fails there would
be no child. But otherwise,
both processes execute different code after
.CW fork .
In which order? We do not know. And we should not care! Did you care
if your shell executed its code before or after the code in your programs?
You forgot about the shell when writing your programs. Do the same here.
The program above might produce this output instead
.P1
; 8.child
I am the parent
I am the child
.P2
.LP
Let's have some fun. This is a runaway program. It creates a child and then dies.
.ix "runaway process
The child continues playing the same game. This is a nasty program because
it is very hard (or impossible) to kill. When you are prepared to kill it, the process
has gone and there is noone to kill. But there is another process taking its place!
.so progs/diehard.c.ms
.ix [diehard]
.LP
This version is even more nasty. It creates processes exponentially, which
might happen to you some day when you make a mistake calling fork. Once
the system cannot cope with more processes, there will be nothing you could
do but rebooting the machine. Try it as the last thing do you in one of your
sessions so that you could see what happens.
.so progs/rabbits.c.ms
.ix [rabbits.c]
.BS 2 "Shared or not?
.LP
Fork creates a clone process.
.ix [fork]
.ix "parent process
.ix "child process
.ix "file descriptor
Because the child is a clone, it has its own set of file descriptors. When
.CW fork
returns, the descriptors in the child are a copy of those in the parent. However,
that is the only thing copied.
.PP
Of course, the files referenced by the descriptors
are not copied. The Chan data structures that maintain the offset for the open
files are not copied either.
.ix [Chan]
Figure [[!file descriptors child!]] shows both a
parent and a child just after calling
.CW fork ,
showing file descriptors for both. This figure may correspond to the following
program.
.LS
.PS
right
boxht=.2
boxwid=1
[
	down
	circle rad .4 "Parent" "process"
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
	C: box wid 1.5 ht 2*boxht "\f(CWafile\fP" "\f(CWoffset: 6\fP"
	arrow -> from D.D1 right 1
	T: box wid 1.5 ht 2*boxht "\f(CW/dev/cons\fP" "\f(CWoffset: 3245\fP"
	spline -> from D.D0 right then to T.w + 0,.1
	spline -> from D.D2 right then to T.w+0,-.1 
]
Z:  last [].C.e
T: last [].T
move
Y: [
	down
	circle rad .4 "Child" "process"
	line -> down " File desc." ljust  " table" ljust
	D: [ down
	 	[ right
		 F: box   ; box invis wid .2  "0" ]
	D0: last [].F
		[ right
		 F: box   ; box invis wid .2  "1" ]
	D1: last [].F
		[ right
		 F: box   ; box invis wid .2  "2" ]
	D2: last [].F
		[ right
		 F: box   ; box invis wid .2  "3" ]
	D3: last [].F
		[ right
		box invis   "..." ; box invis wid .2   ]
		[ right
		 F: box   ; box invis wid .2  "n" ]
	]
	D3: D.D3
	D0: D.D0
	D1: D.D1
	D2: D.D2
]
arrow -> from Y.D3 to Z.e
spline -> from Y.D0  left .5 then to T.e +0,.1
spline -> from Y.D1 left .5 then to T.e
spline -> from Y.D2  left .5 then to T.e + 0,-.1
reset
.PE
.LE F The child has a copy of the file descriptors that the parent had.
.PP
.so progs/before.c.ms
.ix [before.c]
.LP
Initially, the parent had standard input, output, and error open. All of them
went to file
.CW /dev/cons .
Then, the parent opens (i.e., creates)
.CW afile ,
and file descriptor 3 is allocated.
It points to a (Chan) data structure that
maintains the offset (initially 0), and the reference to the actual file.
After writing 6 bytes, the offset becomes 6.
.PP
At this point,
.CW fork
creates the child as a clone. It has a copy of the parent's file descriptors, but
everything else is shared. Of course, if either process opens new files, their
.I offsets
would not be shared. For each open you get an all new file offset.
.ix "shared resource
What would be the contents for
.CW afile
after running this program?
.P1
; 8.before
; cat afile
hello
child
dad
;
.P2
.LP
Each process calls
.CW write .
.ix [write]
the child's write updates the file and advances the offset by 6. The next write
does the same. The order of
.CW child
and
.CW dad
may differ in the output, depending on which process executes first its
.CW write .
Both will be there.
.PP
Compare what happen before with the behavior for the next program.
The program is very similar. The parent tries to write
.CW dad
to a file, and the child tries to
write
.CW child .
According to our experience, the file should have both strings in it after the
execution.
.so progs/after.c.ms
.ix [after.c]
.LP
But this is what happens:
.P1
; rm afile
; touch afile
; 8.after
; cat afile
dad
d
; xd -c afile
0000000   d  a  d \en  d \en
0000006 
.P2
.LP
Why? Because each process had its own file descriptor for the file, that
now is not sharing anything with the other process. In the previous program,
the descriptors in both processes came from the same open: They were sharing
the offset. When the child wrote, it advanced the offset. The parent found the
offset advanced, and could write past the child's output.
.ix "shared offset
.PP
But now, the parent opens the file, and gets its own offset (starting at 0).
The child does the same and gets its own offset as well (also 0).
One of them writes, in this case the child wrote first. That advances its own
offset for the file. The other offset stays at 0. Therefore, both processes
overwrite the same part of the file.
.PP
It could be that the parent executes its
.CW write
before the child, in which case we would get this, which would be also an
overwrite:
.P1
; cat afile
child
.P2
.LP
There is one interesting thing to learn here. We have said that either
.CW write
(parent's and child's) can execute before the other one. Couldn't it be
that
.I part
of a
.CW write
is executed and then part of the other? In principle it could. But in this case,
it will never happen.
.PP
Plan 9 guarantees that a single
.CW write
.ix "atomic [write]
to a particular file is fully executed and not mixed with other writes to the
same file. This means that if there are two
.CW write
calls being made for the same file, one
.I must
execute before the other. For different files, they could execute simultaneously
(i.e., concurrently), but not for the same file in Plan 9.
.PP
When one operation is guaranteed to execute completely
without being interrupted, it is called
.B atomic .
The Plan 9
.CW write
system call is atomic at least for writes on the same file and when the
number of bytes is not large enough to force the system to do several
write operations to implement your system call. In our system this happens for writes of
at most 8Kbytes.
.BS 2 "Race conditions
.ix "race condition
.LP
What you just saw is very important. It is not to be forgotten, or you risk going
into a debugging Inferno. When multiple
processes work on the same data, extra care is to be taken. You saw how
the final value for
.CW afile
depends on which process is
.I faster ,
i.e.,
gets more processor time, and reaches a particular point in the code earlier
than another process. Because the final result depends on this race, its said
that the program has a
.B "race condition" .
.PP
You are entering a dangerous world. It is called
.B "concurrent programming" .
.ix "shared resource
The moment you use more than one process to write an application, you have
to think about race conditions and try to avoid them as much as you can.
The name
.I concurrent
is used because you do not know if all your processes execute really in parallel
(when there is more than one processor) or relying on the operating system
to multiplex a single processor among them. In fact, the problems would be
the same: Race conditions. Therefore, it is best to think
that they execute concurrently, try to avoid races,
and forget about what is really happening underneath.
.PP
Programs with race conditions are unpredictable. They should be avoided.
Doing so is a subject for a book or a course by itself. Indeed, there are many books
and courses on
.I "concurrent programming"
that deal with this topic. In this text, we will deal with this problem by trying to avoid it,
and showing a few mechanisms that can protect us from races.
.BS 2 "Executing another program
.LP
.ix "program execution
We know how to create a new process. Now it would be interesting to learn how
to run a new
.I program
using a process we have created. This is done with the
.CW exec
.ix [exec]
system call. This call receives two parameters, a file name that corresponds to the
executable file that we want to execute, and its argument list. The argument
list is an array of strings, with one string per argument.
.PP
If we know the argument list in advance (when we write the program), another
system call called
.CW execl
.ix [execl]
is more convenient. It does the same, but lets you write the arguments directly
as the function arguments, without having to declare and initialize an array. We
are going to use this call here.
.PP
This is our first example program
.so progs/execl.c.ms
.ix [execl.c]
.LP
When run, it produces the following output:
.P1
.ps -1
; 8.execl
running ls
d-rwxrwxr-x M 19 nemo nemo      0 Jul 11 18:11 /usr/nemo/bin
d-rwxrwxr-x M 19 nemo nemo      0 Jul 11 21:24 /usr/nemo/lib
d-rwxr-xr-x M 19 nemo nemo      0 Jul 11 21:13 /usr/nemo/tmp
.ps +1
.P2
.LP
The output is produced by the program found in
.CW /bin/ls .
Clearly, our program did not read a directory nor print any file information.
Furthermore, the output is the same printed by the next command:
.P1
.ps -1
; ls -l /usr/nemo
d-rwxrwxr-x M 19 nemo nemo      0 Jul 11 18:11 /usr/nemo/bin
d-rwxrwxr-x M 19 nemo nemo      0 Jul 11 21:24 /usr/nemo/lib
d-rwxr-xr-x M 19 nemo nemo      0 Jul 11 21:13 /usr/nemo/tmp
.ps +1
.P2
.LP
This is what the
.CW execl
call did. It loaded the program from
.CW /bin/ls
.ix "argument vector
.ix [argv]
into our process, and jumped to its main procedure supplying the arguments
“\f(CWls\fP”, “\f(CW-l\fP”, and “\f(CW/usr/nemo\fP”.
Remember that
.CW argv[0]
.ix "program name
.ix [argv0]
is the program name, by convention. The last parameter to the
.CW execl
call was
.CW nil
to let it know when to stop taking parameters from the parameter list.
.PP
There is an important thing that the output for our program does show. Indeed,
that it does
.I not
show. The
.CW print
we wrote after calling
.CW execl
is missing from the output! This makes sense if you think twice. Because
.CW execl
loads another program (e.g., that in
.CW /bin/ls )
into
.I our
process, our code is gone. If
.CW execl
.ix [execl]
works, the process no longer has our program. It has that of
.CW ls
instead. Also, our process no longer has our data, nor our stack. Initial
data and stack for
.CW ls
is  there instead. What a personality change!
.PP
Now consider the same program but replacing the call to
.CW execl
with this one:
.P1
execl("ls", "-l", "/usr/nemo", nil);
.P2
.LP
This is the output now when the program is run:
.P1
; 8.execl
running ls
exec failed: 'ls' file does not exist
.P2
.LP
This time, both calls to
.CW print
execute! Because
.CW execl
failed to do its work, it did not load any program into our process. Our mind
is still here, and the second printed message shows up. Why did
.CW execl
fail? We forgot to supply the file name as the first parameter. Therefore,
.CW execl
tried to access the file
.CW ./ls
to load a program from it. Because such file did not exist, the system call
could do nothing else but to return an error.
What value returns
.CW execl
when it fails? It does not matter. If it returns, it must be an error.
.ix "system call error
.PP
Now replace the call with the next one. What would happen?
.P1
execl("/bin/ls", "-l", "/usr/nemo", nil);
.P2
.LP
This is what happens:
.P1
; 8.execl
running ls
/usr/nemo/bin
/usr/nemo/lib
/usr/nemo/tmp
.P2
.LP
Clearly
.CW ls
did run in our process. Its output is there and our second print is not. However,
where is the long listing we requested? Nowhere. For
.CW ls,
.CW argv[0]
was
.CW -l
and
.CW argv[1]
was
.CW /usr/nemo .
We executed
.CW "ls /usr/nemo" .
Even worse, we told
.CW ls
that its name was
.CW -l .
.PP
Now that we have mastered
.CW execl ,
let's try doing one more thing. If we replace the call with this other one, what
happens?
.P1
execl("/bin/ls", "ls", "-l", "$home", nil);
.P2
.LP
The answer is obvious only when you think which program takes care of
understanding “\f(CW$home\fP”. It is the shell, and not
.ix [$home]
.ix "environment variable
.CW ls .
The shell replaces
.CW $home
with its value,
.CW /usr/nemo
in this case. It seems natural now that this is he output for the program:
.P1
; 8.execl
running ls
ls: $home: '$home' file does not exist
.P2
.LP
What we executed was the equivalent of the shell command line
.P1
; ls -l '$home'
.P2
.LP
which we know well now. Should we want to run the program for
.CW $home ,
we must take care of the environment variable by ourselves:
.P1
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	char*	home;

	print("running ls\en");
	home = getenv("home");
	execl("/bin/ls", "ls", "-l", home, nil);
	print("exec failed: %r\en");
}
.P2
.BS 2 "Using both calls
.LP
Most of the times you will not call
.CW exec
.ix [exec]
.ix [fork]
using the process that initially runs your program. Your program would be
gone. You combine both
.CW fork
and
.CW exec
to start a new process and run a program on it, as saw first in this chapter.
We are going to implement a function called
.CW run ,
which receives a command including its arguments and runs it at a separate
process. This is useful whenever you want to start an external program from
your own one.
.PP
The header for the function will be:
.P1
int run(char* file, char* argv[]);
.P2
.LP
and its parameters have the same meaning that those of
.CW exec :
The file to execute and the argument vector. This is the code.
.P1
int
run(char* cmd, char* argv[])
{
	switch(fork()){
	case -1:
		return -1;
	case 0:			// child
		exec(cmd, argv);
		sysfatal("exec: %r");
	default:			// parent
		return 0;
	}
}
.P2
.LP
The function creates a child process, unless
.CW fork
fails, in which case it reports the error by returning
.CW -1 .
The parent process
returns zero to indicate that it could fork.
The child calls
.CW exec
to run the new program. Should it fail, there is nothing we could
do but to terminate the execution of this process reporting the error.
Note that the child process should
.I never
return from the function. When a program calls
.CW run ,
only one flow of control performs the call, and you expect only
one flow of control coming out and returning from it. 
.PP
This  function has one problem. The command file might
not exist, or lack execution permission, but the program calling
.CW run
would never know. This can be a temporary fix, until we learn more in the
next section:
.P1
int
run(char* cmd, char* argv[])
{
	if (access(cmd, AEXEC) < 0)
		return -1;

	switch(fork()){
	case -1:
		return -1;
	case 0:		// child
		exec(cmd, argv);
		sysfatal("exec: %r");
	default:
		return 0;
	}
}
.P2
.LP
Before creating the child, we try to be sure that the file for the command
has access for executing it. The
.CW access
system call checks this when given the
.ix [access]
.ix "[AEXEC] access mode
.CW AEXEC
flag.
.PP
After calling
.CW access ,
and before doing the
.CW exec ,
things could change. So, there is a potential race condition here. It could
be that
.CW access
thinks that the command can be executed, and then something changes, and
.CW exec
fails!
What is really needed is a way to let the child process tell the parent
about what happen. The parent is only interested in knowing if the child
could actually perform its work, or not.
.BS 2 "Waiting for children
.ix "wait~for children
.LP
Did you notice that the shell awaits until one command terminates
before prompting for the next? How can it know that the process executing
the command has completed its execution? Also, if you create a process
for doing something, how can you know if it could do its job?
.PP
When a process dies, it always dies by a call to
.CW exits
(remember that there is one after returning from
.CW main ).
The string the process gives to
.CW exits
.ix [exits]
.ix "exit status
is its exit status. This was not new. The new point is that the parent
may wait until a child dies and obtain its exit status. The function
used to do this is
.CW wait :
.ix [wait]
.P1
; sig wait
	Waitmsg* wait(void)
.P2
.LP
where
.CW Waitmsg
.ix [Waitmsg]
is defined like follows.
.P1
typedef
struct Waitmsg
{
	int	pid;		/* of loved one */
	ulong	time[3];	/* of loved one & */
	char	*msg;	/*	descendants */
} Waitmsg;
.P2
.LP
A call to
.CW wait
blocks until one child dies. 
.ix "process time
At that point, it returns a wait message that contains information about the
child, including its pid, its status string, and the time it took for the child
to execute. 
If one child did already die, there is no need to
wait and this call returns immediately.
If there is no children to wait for, the function returns nil.
.PP
Now we can really fix the problem of our last program.
.P1
int
run(char* cmd, char* argv[])
{
	Waitmsg*	m;
	int	ret;

	switch(fork()){
	case -1:
		return -1;
	case 0:		// child
		exec(cmd, argv);
		sysfatal("exec: %r");
	default:
		m = wait();
		if (m->msg[0] == 0)
			ret = 0;
		else {
			werrstr(m->msg);
			ret = -1;
		}
		free(m);
		return ret;
	}
}
.P2
.LP
After calling
.CW fork ,
the parent goes through the default case and calls
.CW wait .
If by this time the child did complete its execution by calling
.CW exits ,
.CW wait
returns immediately
.CW Waitmsg
with information about the child. If the child is still running,
.CW wait
blocks until the child terminates. The data structure returned by
.CW wait
is allocated using
.CW malloc ,
and
the caller of
.CW wait
is responsible for releasing this memory.
.PP
Another detail is that the routine updates the process error string in the parent
.ix "error string
.ix [werrstr]
process when the child fails. That is where the caller program expects
to find out the diagnostic for a failed (system) call.
.PP
In this case we know that there is at least one child, and
.CW wait
cannot return nil. The convention in Plan 9 is that an empty string
in the exit message means “everything ok”. That is the information
returned by
.CW run .
The field
.CW m
in the
.CW Waitmsg
contains a copy of the child's exit message.
.PP
This code still has flaws. The program that calls
.CW run
might have created another child before calling
our function. In this case, it is not sure that
.CW wait
returns information about the child it created. This is a better version
of the same function.
.P1
int
run(char* cmd, char* argv[])
{
	Waitmsg*	m;
	int	ret;
	int	pid;

	pid = fork();
	switch(pid){
	case -1:
		return -1;
	case 0:		// child
		exec(cmd, argv);
		sysfatal("exec: %r");
.P2
.P1
	default:
		while(m = wait()){
			if (m->pid == pid){
				if (m->msg[0] == 0)
					ret = 0;
				else {
					werrstr(m->msg);
					ret = -1;
				}
				free(m);
				return ret;
			}
			free(m);
		}
	}
}
.P2
.LP
The routine, when executed by the parent process, makes sure
that the message comes from the right (death) child. Its manual
page should now include a warning stating clearly that this routine
waits for any child until the one it creates is waited for. Callers must
know this. Otherwise, what would happen to programs like this one?
.P1
.I "...
if (fork() == 0){
	 \fI... do something in this child ...\fP
} else {
	run(cmd, args);
	\fI...\fP
	m = wait();	// wait for our child
	\fI...\fP
	free(m);
}
.P2
.LP
The
.CW wait
in this code seems to be for the child created by the
.CW fork .
However, the call to
.CW run
would probably wait for the 2 children, and
.CW wait
is likely to return nil!
.PP
When a program is not interested in the exit message, it can
use
.CW waitpid
.ix [waitpid]
instead of
.CW wait .
This function returns just the pid of the death child. Both functions
are implemented using the real system call,
.CW await .
.ix [await]
But that does not really matter.
.PP
Although the shell waits by default until the process running a
command completes, before prompting for another line, it can be
convinced not to wait. Any command line with a final ampersand is not
.ix "background command
.ix [sleep]
waited for. Try this
.P1
; sleep 3	\fI ...no prompt for 3 seconds.\fP
;
.P2
.LP
and this
.P1
; sleep 3 &	\fI ...and we get a new prompt right away.\fP
;
.P2
.LP
This is used when we want to execute a command
\fBin the background\fP,
i.e., one that does not read from our terminal and does not make
the shell wait for it. We can start a command and forget it is still there.
The shell puts into
.CW $apid
.ix [apid]
the pid for the last process started in the background, to let you know
its pid for things like killing it.
.PP
Any output from the command will still go to the console, and may
disturb us. However, the shell arranges for the command to have its
standard input coming from
.CW /dev/null ,
.ix [/dev/null]
a file that always seems to be empty when read.
.PP
This can be double checked. The
.CW read
command reads a single line of text from its input, and then writes it
to its standard output.
.P1
; read
hello	\fIyou type this...\fP
hello	\fI...and it writes this.\fP
;
.P2
.LP
Look what happens here:
.P1
; read &
;
.P2
.ix "[read] command
.LP
The program did not print anything. Because it could not read anything from
its input.
.PP
Some programs may want to execute in the background, without making
the shell wait for them until terminated. For example, a program that opens
a new window in the window system should avoid blocking the shell until
the new window is closed. You want a new window, but you still want your
shell.
.PP
This effect can be achieved without using
.CW &
in the command line. The only thing needed is to perform the actual work
in a child process, and allow the parent process to die. Because the shell
waits for the parent process (its child), it will prompt for a new command
immediately after this process dies. The first program of this chapter is
an example (even though it makes not sense to do this just to run
.ix "command line
.CW ls ).
.BS 2 "Interpreted programs
.ix "interpreted program
.ix "script
.LP
An executable is a file that has the execute permission set. If it is
.ix "executable
.ix "binary
a binary file for the architecture we are running on, it is understandable
what happens. If it is a binary for another architecture, the kernel will
complain. This was executed using an Intel-based PC:
.P1
; 5c ls.c
; 5l ls.5
; ./5.out
 ./5.out: exec header invalid
.P2
.ix "[exec] header
.ix "5c
.ix "5l"
.ix "architecture
.LP
The header for the binary file has a constant, weird, number in it. It is placed
there by the loader and checked by the kernel, which is
doing its best to be sure that the binary corresponds to
the architecture executing it.
.PP
But there is another type of executable files. Interpreted programs. For
Plan 9, an interpreted program is any file starting with a text line that has
a format similar to
.P1
#!/bin/rc
.P2
.LP
It must start with
.CW #! ,
followed by the command that interprets the file. In the example above,
.ix "interpreter
the program interpreting the file is
.CW /bin/rc ,
i.e., the standard Plan 9 shell. You know what the shell does. It reads lines,
interprets them, and executes commands as a result. For the shell, it
does not matter if commands come from the console or from a file. Both things
are files actually!
.PP
This is an example of a program interpreted
by the shell, also known as a
.B "shell script" .
We can try it by storing the text in a file named
.CW hello
.ix "[hello]~[rc]~script
and executing it:
.P1
; cat hello
#!/bin/rc
echo hello there!
; chmod +x hello
; hello
hello there!
;
.P2
.LP
When Plan 9 tries to execute a file, and it finds that the two initial characters
are
.CW #! ,
it executes the interpreter as the new binary program for the process, and
.I not
the file whose name was given to
.CW exec .
The argument list given to
.CW exec
is altered a little bit by the kernel to include the script file name
as an argument.
As a result, executing
.CW hello
is actually equivalent to doing this
.P1
; rc hello
.P2
.LP
To say it explicitly, a shell script is always executed by a new shell. Commands
in the script are read by the child shell, and not by the original one. Look at this
.ix [cdtmp]~[rc]~script
.P1
; cat cdtmp
#!/bin/rc
cd /tmp
; pwd
/usr/nemo
; chmod +x cdtmp
; cdtmp
; pwd
/usr/nemo
.P2
.LP
Is Plan 9 disobeying? Of course not. We executed
.CW cdtmp .
But commands in the script are
.I not
executed by the shell we are using. A new shell was started to read
.ix "resource sharing
.ix "child process
and execute the commands in the file. That shell changed its
working directory to
.CW /tmp ,
and then died. The parent process (the shell we are using) remains
unaffected. This may confirm what we said
.P1
; cat cdtmp
#!/bin/rc
cd /tmp
pwd
; pwd
/usr/nemo
; cdtmp
/tmp
; pwd
/usr/nemo
.P2
.LP
This mechanism works for any program, and not just for the shell. For example,
.CW hoc
is a floating point calculator language. It can be used to evaluate arbitrary
floating point calculations. When given a file name,
.CW hoc
.ix [hoc]
.ix "arithmetic expression
.ix "calculator
interprets the expressions in the file and prints any result. Now we can make
an interpreted program that lets you know the output of 2+2:
.P1
; cat 2+2
#!/bin/hoc
2 + 2
; chmod +x 2+2
; 2+2
4
;
.P2
.LP
Amazing!
.PP
Because the shell can be used to write programs, it is a programming
language. It includes even a way to write comments. When the shell finds
.ix "shell comment
a
.CW #
character, it ignores it and the rest of the line. That is why the special format
for the first line of interpreted programs in Plan 9 starts with that character!
When the shell interprets the script, it reads the first line as well. However,
that line is a comment and, therefore, ignored.
.PP
Scripts have arguments, as any other executable program has. The shell
.ix "shell script
interpreting the script
stores the argument list in the environment variable named “\f(CW*\fP”.
This is
.CW echo
using
.CW echo :
.ix [rcecho]~[rc]~script
.so progs/rcecho.ms
.LP
And this is what it does
.P1
; rcecho hello world
hello world
.P2
.LP
As an additional convenience, within a shell script,
.CW $0
.ix "script arguments
is equivalent to
.CW argv[0]
in a C program,
.CW $1
to
.CW argv[1] ,
and so on.
.SH
Problems
.IP 1
Trace (by hand) the execution of this program. Double check by executing
it in the machine.
.P1
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	fork();
	fork();
	print("hi\en");
}
.P2
.IP 2
Compile and execute the first program shown in this chapter. Explain the
output.
.IP 3
Fix the program from the previous problem using
.I wait (2).
.IP 4
Implement your own version of the
.I time (1)
tool. This program runs a single command and reports
the time the command took to execute (elapsed time, time spent
executing user code, and time spent executing kernel code).
.IP 5
Implement a function
.P1
char* system(char* cmd);
.P2
.IP
That receives a command line as an argument and must execute
it in a child process like the Plan 9 shell would do. Think of a reasonable
return value for the function.
.IP
.I Hint:
Which program did we say that knows how to do this type of work?
.IP 6
Write a script that interprets another script, for example, by using
.CW rc .
Can you specify that a program interpreter is also an interpreted file? Explain.
.IP 7
How could you overcome the limitation expossed in the previous problem?
.ds CH
.bp
 \c
