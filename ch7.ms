.so tmacs
.BC 7 "Resources and Names
.BS 2 "Resource fork
.LP
.ix "resource sharing
.ix "file name
.ix "resource fork
In chapter 4 we used
.CW fork
.ix [fork]
.ix "process creation
to create new processes. We said that
.CW fork
was a system call. We lied. It is not a venial lie, like when saying
that
.CW getenv
.ix [getenv]
is a system call (because it is a library function). It is a terrible lie,
because Plan 9 processes are not just clones.  Now it is time to tell the truth.
.PP
A Plan 9 process is mostly what you imagine because of what we have said
so far. It is a flow of control known by the kernel, which creates the illusion
of having a dedicated processor to run it. Each process has certain resources
that are abstractions provided by Plan 9 to let it perform its job. We have
seen many of such resources: Memory, environment variables, file descriptors, and
.ix "process resource"
.ix "environment variable
.ix "environment process group
.ix "file descriptor process group
.ix "note process group
note groups.
.PP
When we discussed
.CW fork ,
we said that a child process is a
.I copy
of the parent process. Therefore, it seemed that all resources for the
parent were copied to build a (child) clone. 
Because
.CW fork
is so hard to understand the first time you use it, we decided to lie.
.PP
But
the truth is that to create a Plan 9 process you do not have to copy all the
resources from the parent process. You may specify which resources are
to be copied, which ones are to be
.ix "parent process
.ix "child process
.I shared
with the parent, and which ones are to be brand
.I new
(and empty) just for the child.
.PP
The system call doing this is
.CW rfork ,
and
.CW fork
is equivalent to a call to
.CW rfork
.ix [rfork]
asking for a copy of the parent's file descriptor table, a new flow of control,
and a copy of the parent's memory. On the other hand,
environment variables, and the note
group are shared with the parent.
.PP
This is the complete list of resources for a process, which can be controlled using
.CW rfork :
.IP •
The \fBflow of control\fP
.ix "control flow" .
There is not much we can do about it, but to ask for new one.
Each one is called a
.I process .
.IP •
The
.B "file descriptor table" .
Also known as the file descriptor group. You can ask for a copy, or
for sharing with the child when creating a process, or for a new table with
all descriptors closed.
.IP •
.B "Environment variables" .
Also known as the environment group. Like before, You can ask for a copy, or
for sharing with the child when creating a process, or for a new set of
environment variables with no variable defined on it.
.IP •
The
.B "name space" .
Utterly important, and central to Plan 9. We have been ignoring this until
now. This is the resource that maps file names to files. We study it in this
chapter.
.IP •
The
.B "working directory
and the
.B "root directory" ,
.ix slash
used to walk the file tree for relative and absolute paths.
.ix path
.ix "file tree
.IP •
The \fBmemory segments\fP.
.ix "virtual memory segment
You can ask for sharing the data with the child, when creating a process,
or to make a copy for the child. The text, or code,  is always shared. It is
read-only, and it would be a waste to copy memory that is going to remain
the same. The stack is
.I never
shared, because each process has its own flow of control and needs its
own stack.
.IP •
The
.B "note group" .
You can ask for sharing it with the child, when creating a process, or to
obtain your own group to be isolated from others.
.IP •
The
.B "rendezvous group" .
.ix [rendezvous]
A resource used to make groups of processes that can use the
.CW rendezvous
system call to coordinate among them. This is yet to be seen.
.LP
Besides the requests mentioned above, there are several other things
that
.CW rfork
can do, that we will be seeing in this chapter along with them.
.PP
Before proceeding, we are going to do a
.CW fork ,
but in a slightly different way:
.so progs/rforkls.c.ms
.ix [rforkls.c]
.LP
This program is like the one we saw,
.CW runls ,
which did run
.CW ls
in a child process. This time it is using the actual system call,
.CW rfork .
This call receives a set of flags, packaged into its single parameter using
a bit-or. All the flags for
.CW rfork
have names that start with “\f(CWRF\fP”.
The most important one here is
.CW RFPROC .
.ix "[RFPROC] [rfork]~flag
It asks for a new process, i.e., a new flow of control.
.ix "new process
.ix "control flow
.PP
When you do
.I not
specify
.CW RFPROC ,
the operations you request with other flags are done to your own process,
and not to the child. When you do specify it, the other flags refer to the child.
.PP
The default behavior of
.CW rfork
is to make a copy of the memory for the child, and to share most other things
with the parent. To do exactly a
.CW fork ,
we must ask for a copy of the file descriptor table including the
.CW RFFDG
.ix "file descriptor group
.ix "[RFFDG] [rfork]~flag
(RFork File Descriptor Group). But for the memory, which is duplicated
by default, other resources are shared by default. When you give the flag
for a resource to
.CW rfork ,
you are asking for a copy. When you use a slightly different flag, that has a
.CW C
in it (for “clean”), you are asking for a brand new, clean, resource.
Because of what we said, you can imagine that
.CW RFREND
.ix "[RFFDG] [rfork]~flag
.ix "rendezvous group
is asking for a another rendezvous group, but this does not really matter by now.
.PP
Running this program executes
.CW ls ,
as expected.
.P1
; 8.rforkls
rforkls.c
rforkls.8
8.rforkls
;
.P2
.LP
But let's change the call to rfork with this other one
.P1
rfork(RFCFDG|RFREND|RFPROC)
.P2
.LP
and try again
.P1
; 8.rforkls
;
.P2
.LP
.I Nothing !
.PP
The explanation is that
.CW RFCFDG
provided a
.I clean
file descriptor table (or group) to the child process. Because standard output
was not open in the child,
.CW ls
could not print its output. Furthermore, because its standard error was
closed as well, it could not even complain about it.
.PP
Now we are going to do the same, to our own process. 
.so progs/rforkhi.c.ms
.LP
This produces this output
.P1
; !!8.rforkhi
; hi
;
.P2
.LP
The second message was not shown. The
.CW RFCFDG
flag to
.CW rfork
asks for a
.I clean
file descriptor set (group). This works like in the previous program, but this time
we did not specify
.CW RFPROC
and therefore, the request was applied to our own process.
.BS 2 "Protecting from notes
.LP
The note group is shared by default when doing a
.ix "note group
.CW fork ,
because no flag is specified regarding this resource. This means that when we
run our program in a window, pressing
.I Delete
.ix [Delete]
in the window will kill our process. The window system posts an
.CW interrupt
.ix "[interrupt] note
note to the note group of the shell in the window, and our process is a child
of the shell, sharing its note group.
.PP
This may be an inconvenience. Suppose we are implementing a web server, that
is meant to be always running. This program is meant to run in the background,
because it does not need a console to read commands. The user is expected
to run our server as in
.P1
; httpd &
;
.P2
.LP
to be able to type more commands in the shell. However, if the user now hits
.I Delete
to stop another program, the web server is killed as well. This can be avoided by
.ix "[RFNOTEG] [rfork]~flag
calling
.P1
rfork(RFNOTEG);
.P2
.LP
in the program for
.CW httpd .
This puts the process in a new note group. We are no longer affected by notes
to the group of the shell that runs in our window. To try this, run this program
commenting out the call to
.CW rfork ,
and hit
.I Delete .
.so progs/noterfork.c.ms
.ix [noterfork.c]
.LP
The program gets killed.
.P1
; 8.noterfork
0 1 2 \fBDelete\fP
;
.P2
.LP
With the call in place, the program happily ignores us until it completes.
.P1
; 8.noterfork
0 1 2 \fBDelete\fP 3 4 5
;
.P2
.LP
Imagine this program is our
.CW httpd
server. If the user forgets to type the ampersand, it will block the shell forever
(it is waiting for the child to die). The only way to kill it is to open a new window and
.ix [wait]
kill manually the process by writing to its
.CW ctl
file, as we saw before. To be nicer, our program could fork a child and let
its original process die. The shell prompt would be right back. Because we still
want to protect from notes, we must get a new note group as well.
.PP
The program, shown next, produces the same output, and convinces the shell that it
should read another line immediately after we start.
.P1
; 8.noterfork
; 0 1 2 \fBDelete\fP
; 3 4 5
.P2
.LP
Because the shell is reading a command line, when we type
.I Delete ,
it understands that we want to interrupt what we typed and prints
another prompt, but our fake
.CW httpd
program is still alive. The
.CW RFNOTEG
flag applies to our child process, because we said
.CW RFPROC
as well.
.so progs/httpd.c.ms
.BS 2 "Environment in shell scripts
.LP
.ix "environment variable
.ix "shell script
.ix "resource sharing
Environment variables are shared by default. This means that if we change
any environment variable, our parent and other sibling process sharing the
environment variables will
be able to see our change.
.PP
Shell scripts are executed by a child shell process,
.ix "subshell
.ix "child process
and this applies to them as well. when you define a variable in a shell script,
the change remains in the environment variable table after the script has died.
For example, this script copies some source and documentation files to several
directories for a project. It defines the
.CW projectdir
environment variable.
.so progs/copy.ms
.ix "[copy] [rc]~script
.LP
Look what happens:
.P1
; copy
; lc /env/projectdir
projectdir
.P2
.LP
After executing
.CW copy ,
the environment variable is not yet known to our shell. The reason is that the
shell caches environment variables. Starting a new shell shows that indeed, the
variable
.CW projectdir
is in our environment. This is also seen by listing
.CW /env .
.ix [/env]
The file representing the variable is defined there.
.P1
; echo $projectdir

; rc
; echo $projectdir
/sys/src/planb
.P2
.LP
How can we avoid polluting the set of environment variables for the parent shell?
By asking in the script for our own
.I copy
of the parent process' environment. This, in a C program, would be done calling
.CW rfork(RFENVG) .
.ix "[RFENVG] [rfork]~flag
.ix "environment group
In the shell, we can run the command
.P1
rfork e
.P2
.LP
that achieves the same effect. The command is a builtin, understood and executed
.ix "[rfork] command
.ix "builtin command
by
.CW rc
itself. it is very sensible to start most scripts doing this:
.P1
#!/bin/rc
rfork ne
.I ...
.P2
.LP
This creates a copy of the environment variables table (\f(CWe\fP) and the
name space (\f(CWn\fP) for the process executing the request. Because it is a copy,
any change does not affect the parent. When the shell interpreting the script dies,
the copy is discarded.
.BS 2 "Independent children
.LP
.ix "independent child process
.ix "process termination
All the programs we have done, that create a child process and do not wait for it,
are wrong. They did not fail, but they were not too nice to Plan 9.
.PP
When a child process dies, Plan 9 must maintain its exit message until the parent
process waits for it. However, if the parent process is never going to wait for the
child, Plan 9 does not know for how long to keep the message. Sooner or later
the message will be disposed of, e.g., after the parent dies.
.PP
But if we are not going
to wait, it is best to tell Plan 9 that the child is disassociated from the parent. When the
child dies, it will leave no message because no one is going to wait for it. This is
achieved by specifying the flag
.CW RFNOWAIT
.ix "[RFNOWAIT] [rfork]~flag
.ix "dissociated child
along with
.CW RFPROC
when the new, dissociated, child is being created. For example, this is the
correct version for our
.CW child
program that used
.CW fork
to create a child process.
.P1
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(rfork(RFFDG|RFREND|RFPROC|RFNOWAIT)){
	case -1:
		sysfatal("fork failed\n");
	case 0:
		print("I am the child\n");
		break;
	default:
		print("I am the parent\n");
	}
	exits(nil);
}
.P2
.LP
The flags
.CW RFFDG|RFREND|RFPROC
are equivalent to calling
.CW fork ,
.ix [fork]
but this time we say
.CW RFNOWAIT
as well.
.BS 2 "Name spaces
.LP
.ix "name resolution
.ix "path
.ix "walk
.ix "file tree
.ix "name space
.ix "file name
In Plan 9, we use file names like
.CW /usr/nemo .
A name is just a string. It is a sequence of characters. However, because it
is a file name, we give some meaning to the string. For example, the name
.CW /usr/nemo
means:
.IP 1
Start at the file named
.CW / ,
which is also known as the root directory.
.IP 2
Walk down the file tree to the file with name
.CW usr ,
.IP 3
Walk down again to the file named
.CW nemo .
You have arrived.
.LP
This name specifies a path to walk through the tree of files to reach a
particular file of interest, as shown in figure [[!tree walk!]].
What is a file? Something that you can
.CW open ,
.CW read ,
.CW write ,
.ix [open]
etc. As long as the file implements these operations, both you and Plan 9
are happy with it.
.LS
.PS
.ps +2
circlerad=.2
movewid=.2
arrowhead=.7
.CW
down
S: circle invis "\fB/\fP"
move
L: [ right
	A: circle invis  "386"
	move
	X: circle invis "arm"
	move
	B: circle invis  "\fBusr\fP"
	move
	Y: circle invis "n"
	move
	C: circle invis  "tmp"
]
move
U: [ right
	A: circle invis  "\fBnemo\fP"
	move
	B: circle invis  "glenda"
	move
	C: circle invis  "mero"
]
line from S to L.A chop
line from S to L.B chop
line from S to L.X chop
line from S to L.Y chop
arrow from S+.005,.005 to L+.005,.005 chop
line from S to L.C chop
line from L.B to U.A chop
arrow from L.B+.005,.005 to U.A+.005,.005 chop
line from L.B to U.B chop
line from L.B to U.C chop
.R
.ps -2
reset
.PE
.LE F A file name is a path to walk in the tree of files.
.PP
.ix [/]
But how can “\f(CW/\fP”, which is just a name, refer to a file? Where does it
come from? And why can a name like
.CW /dev/cons
refer to different files at different windows? The answers come from the
abstraction used to provide names for files, the
.B "name space" .
In this case, names are for files, and we will not be saying this explicitly. It
should be clear by the context.
.PP
A name space is just a set of names that you can use (all the file paths that
you might ever use in your file tree). Somewhat confusingly, the abstraction
that provides a name space is also called a name space. To add more
confusion, this is also called a
.B "name service" .
.PP
The name space takes a name, i.e., a string, and translates this name into
something that can be used as a file in Plan 9. This translation is called
\fBresolving a name\fP.
.ix "name resolution
.ix "walk
.ix [Chan]
.ix kernel
It takes a name and yields a Chan, the data structure used to represent a file
within the Plan 9 kernel. Thus, you might say that resolving a name takes
a string and yields a file.
The translation is done by walking through
the file tree as shown above.
.PP
Because Plan 9 is a distributed system, your kernel does not have any
data structure to implement files. This may be a surprise, because in Plan 9
.I "everything is a file" ,
or at least looks like a file.
But Plan 9 does not provide the files itself. Files are provided
by other programs that may be running far away in the network, at different
machines. These programs are called \fBfile servers\fP.
.ix "file server
.ix "file tree
.PP
File servers implement and maintain file trees, and you may talk to them across the
network, to walk their trees and use their files. But you cannot even touch nor
see the files, they are kept inside a file server program, far away.
What you can do is to talk to the file server program to ask it to do whatever you
may want to do to the files it keeps.
The protocol used to talk (i.e., the language spoken) is called 9P. The section
.ix 9P
.ix "file system protocol
5 of the system manual documents this protocol. Any program speaking 9P can
be used as a file server for Plan 9.
.PP
The conversation between Plan 9 and a file server is made through a
.I "network connection" .
.ix "network connection
If you have not attended to a computer networks course, you can imagine it is
a phone call, with Plan 9 at one end, and the file server at the other. In the last
chapter we saw how to establish network connections, i.e., how to make calls.
This makes a network connection to the program we use as our file server:
.P1
.ps -1
; srv tcp!whale!9fs
post...
; ls -l /srv/tcp!whale!9fs
--rw-rw-rw- s 0 nemo nemo 0 May 23 17:44 /srv/tcp!localhost!9988
;
.ps +1
.P2
.LP
The program
.CW srv
.ix [srv]
.ix "file descriptor post
dialed the address
.CW tcp!whale!9fs
and, after establishing a connection, posted the file descriptor for the connection
at
.CW /srv/tcp!whale!9fs .
This file (descriptor) has a file server program that speaks 9P at the other end
of the connection.
.PP
However, to access files in the file server, we must be able to see those
files in our file tree, i.e., in our name space. Otherwise we would not be able
to write paths leading to such files. We can do it. The Plan 9
.CW mount
.ix [mount]
.ix "file system mount
.ix "mount table
system call modifies the name space and instructs it to
.I jump
to a new file when you reach a given file. The shell command
.CW mount
does the same.
.LS
.PS 5.3i
circlerad=.25
movewid=.2
arrowhead=.7
.CW
down
S: circle invis "\fB/\fP"
move
L: [ right
	A: circle invis  "386"
	move
	X: circle invis "arm"
	move
	B: circle invis  "usr"
	move
	C: circle invis  "tmp"
	move
	Y: circle invis  "\fBn\fP"
]
move
U: [ right
	circle invis
	move
	A: circle invis  "nemo"
	move
	B: circle invis  "glenda"
	move
	C: circle invis  "mero"
	move .5
	W: circle invis  "\fBwhale\fP"
]
line from S to L.A chop
line from S to L.B chop
line from S to L.X chop
line from S to L.Y chop
arrow from S+.005,.005 to L.Y+.005,.005 chop
line from S to L.C chop
line from L.B to U.A chop
line from L.B to U.B chop
line from L.B to U.C chop
line from L.Y to U.W chop
arrow from L.Y+.005,.005 to U.W+.005,.005 chop
move from U.W.e right 1.5
R: circle invis "\fB/\fP"
down
move
K: [ right
	A: circle invis  "386"
	move
	X: circle invis "arm"
	move
	B: circle invis  "usr"
	move
	C: circle invis  "..."
]
line from R to K.A chop
line from R to K.X chop
line from R to K.B chop
line from R to K.C chop
B1: box dashed at U.W
B2: box dashed at R
arrow dashed from B1.e to B2.w
line dashed from B1.e+0,.005 to B2.w+0,.005 "mount" above
.R
reset
.PE
.LE F The file tree reached through \f(CWtcp!whale!9fs\fP is mounted at \f(CW/n/whale\fP.
.PP
This may seem confusing at first, but it is quite simple.
.ix walk
For example, we may change our name
space so that when we walk through our file tree, and reach the directory
.CW /n/whale ,
we continue our walk,
.I not
at
.CW /n/whale ,
but at the root directory of the file server reached through
.CW /srv/tcp!whale!9fs .
For example,
.P1
; lc /n/whale
; mount -c /srv/tcp!whale!9fs /n/whale
; lc /n/whale
386		acme	cron	mnt	tmp
LICENSE		adm	dist	n	usr
LICENSE.afpl	alpha	lib	power
LICENSE.gpl	arm	lp	rc
NOTICE		cfg	mail	sys
.P2
.LP
Before executing
.CW mount ,
the directory
.CW /n/whale
was empty. After executing it, the original directory is still empty, but our
name space is instructed to jump to the root directory of file server at
.CW /srv/tcp!whale!9fs ,
whenever we reach
.CW /n/whale .
Therefore,
.CW lc
is not really listing
.CW /n/whale ,
but the root for our file server. The nice thing is that
.CW lc
is happy, because the name space keeps it unaware of where the files
might be.
Figure [[!mounted tree!]] shows how
.CW lc
walked the file tree, and makes it clear why it listed the root directory
in the file server. The dashed boxes and the arrow represent the mount we made.
.PP
The data structure that implements the name space is called the
.B "mount table" .
It is a table that maintains entries saying: Go from this file to this other file.
This is what we just saw. After calling
.CW mount
in our example, our mount table contains a new entry represented in the
figure [[!new entry in mount table!]].
The source for the translation is called the
.B "mount point" ,
the destination for the translation is called the
.B "mounted file" .
.LS
.PS
.ps -2
boxwid=1.5
boxht=.4
right
box "Chan for" "\f(CW/n/whale\fP"
arrow right 1.5
box "Chan for \f(CW/\fP" "at tcp!whale!9fs"
reset
.ps +2
.PE
.LE F New entry in mount table after mounting \f(CWtcp!whale!9fs\fP at \f(CW/n/whale\fP.
.PP
Do not get confused by the Chans. For your Plan 9 kernel, a Chan is just a file.
.ix [Chan]
It is the data structure used to speak 9P with a file server regarding a particular
file. Therefore, the figure might as well say “File for \f(CW/n/whale\fP”.
.PP
Each time the name space walks one step in the file tree to resolve a name, the
mount table is checked out to see if walking should continue at a different file,
as happen to
.CW /n/whale .
If there is no such entry, the walk continues through the file tree,  as expected.
.PP
As a convenience, the program
.CW srv
can mount a 9P file server, besides dialing its address and posting the connection file
descriptor at
.CW /srv .
The following command line dials
.CW tcp!whale!9fs ,
like before, but it also mounts that connection at
.CW /n/whale ,
like we did. The file created at
.CW /srv
is named by the second parameter.
.P1
; srv tcp!whale!9fs whale /n/whale
post...
; lc /srv/whale
whale
;
.P2
.LP
By convention, there is a script called
.CW /bin/9fs ,
.ix "[9fs] [rc]~script
that accepts as an argument the file system to mount. It is customized for
each local Plan 9 installation. Therefore, looking into it is a good way of
finding out which file servers you have around. This command achieves
the same effect of the previous command line, when used at URJC:
.P1
; 9fs whale
post...
;
.P2
.LP
We have
.I added
new files to our file tree, by mounting a remote file tree from a 9P file server
into a directory that we already had. The mechanism used was a translation
going from one file to another.
When we have two files in our file tree, the same mechanism can be applied
to translate from one to another. That is, we can ask our name space to
jump to a file
.I "already in our tree
when we reach another that we also have in the tree. A mount
for two files already in the tree is called a
.B binding .
.PP
The system call (and the shell command) used to do a bind is
.CW bind .
.ix [bind]
For example,
.P1
; bind -c /n/whale /n/other
.P2
installs a new entry in the mount table that says: When you reach
.CW /n/other ,
continue at
.CW /n/whale .
But note, the names used are interpreted using the name space! Therefore,
.CW /n/whale
is not the old (empty) directory it used to be. It now refers to the root of the
file server at whale. And so, listing
.CW /n/other
yields the list for the root directory of our file server.
.P1
; lc /n/other
386		acme	cron	mnt	tmp
LICENSE		adm	dist	n	usr
LICENSE.afpl	alpha	lib	power
LICENSE.gpl	arm	lp	rc
NOTICE		cfg	mail	sys
.P2
.LP
Because our mount table includes now the entries shown in figure [[!mount table bind!]].
.LS
.PS
.ps -2
boxwid=1.5
boxht=.4
down
[
	right
	box "Chan for" "\f(CW/n/whale\fP"
	arrow right 1.5
	box "Chan for \f(CW/\fP" "at tcp!whale!9fs"
]
move
[
	right
	box "Chan for" "\f(CW/n/other\fP"
	arrow right 1.5
	box "Chan for \f(CW/\fP" "at tcp!whale!9fs"
]

reset
.ps +2
.PE
.LE F Entries in the mount table after the bind  from \f(CW/n/other\fP to \f(CW/n/whale\fP. 
.PP
How can we know how our name space looks like? Or, how can we know
which entries are installed in our mount table? The name space is a resource,
like file descriptors, and environment variables. Each process may have its
own name space (as controlled by
.CW rfork ),
although the custom is that processes in the same window share their
name spaces.
.PP
The file
.CW ns
.ix "process [ns] file
.ix "[/proc] file system
.ix "[#p] device driver
in the directory in
.CW /proc
for a process,  lists the mount table used by that process.
Each entry is listed using a text line
similar to the command used to install the entry. To obtain the entries we have installed,
we can use
.CW grep ,
.ix [grep]
to print lines in our
.CW ns
file that contain the string
.CW whale :
.P1
; echo $pid
843
; grep whale /proc/843/ns
mount -c #s/tcp!whale!9fs /n/whale 
mount -c #s/tcp!whale!9fs /n/other 
.P2
.LP
Because lines at
.CW /proc/$pid/ns
are not yet ready for use as shell commands, there is a command called
.CW ns
(name space)
.ix [ns]
that massages them a little bit to make them prettier and ready for use.
Using
.CW ns
is also more convenient
because you do not need to type so much:
.P1
; ns | grep whale
mount -c '#s/tcp!whale!9fs' /n/whale 
mount -c '#s/tcp!whale!9fs' /n/other 
.P2
.LP
The effect of a mount (or a bind) can be undone with another system call, called
.CW unmount ,
.ix [unmount]
or using the shell command of the same name:
.P1
; unmount /n/whale
; lc /n/whale
; grep whale /proc/843/ns
mount -c #s/tcp!whale!9fs /n/other 
;
.P2
After executing
.CW unmount ,
the name space no longer jumps to the root of the file server at
.CW whale
when reaching
.CW /n/whale ,
because the entry in the mount table for
.CW /n/whale
has been removed. What would happen now to
.CW /n/other ?
.P1
; lc /n/other
386		acme	cron	mnt	tmp
LICENSE		adm	dist	n	usr
LICENSE.afpl	alpha	lib	power
LICENSE.gpl	arm	lp	rc
NOTICE		cfg	mail	sys
.P2
.LP
Nothing! It remains as before. We removed the entry for
.CW /n/whale ,
but we did not say anything regarding the bind for
.CW /n/other .
This is simple to understand if you think that your name space, i.e., your
mount table, is just a set of translations from one file to another file. Here,
.CW /n/other
leads to the file that had the name
.CW /n/whale .
This file was the root of our file server, and not the empty directory. To undo
the mount for this directory, we know what to do:
.P1
; unmount /n/other
; lc /n/other
;
.P2
.LP
In some cases, a single file server may provide more than one file tree.
For example, the file system program used in Plan 9,
.CW fossil ,
.ix [fossil]
.ix "file server program
.ix "file system snapshot
.ix "file system dump
.ix "archive
makes a snapshot of the entire file tree each day, at 5am, and archives it
for the posterity. It archives only the changes with respect to the last archive,
but provides the illusion that the whole tree was archived as it was that day.
.PP
Above, we mounted the
.I active
file tree provided by the
.CW fossil
file server running at
.CW whale .
But we can mount the archive instead. This can be done supplying an optional
argument for
.CW mount ,
.ix "attach specifier
.ix "mount specifier
that specifies the name of the file tree that you want to mount. When you do not
name a particular file tree served from the file server, its
.I main
.ix [main/active]
file tree is mounted. For fossil, the name of the main file tree is
.CW main/active .
This command mounts the archive (also known as the
.I dump )
for our main file server, and not the active file tree (i.e., that of today):
.P1
; mount /srv/tcp!whale!9fs /n/dump main/archive
; lc /n/dump
2001	2002	2003	2004	2005	2006
; ls /n/dump/2004
0101
0102
0103
0104
.I  "... and may more directories. One per day, until...
1230
1231
;
.P2
.LP
This is very useful. You may copy files you had years ago, you may compare
them to those you have today, and you may even used them! The following
commands change your
name space to use the C library you were using on May 4th, 2006:
.P1
.ps -1
; bind /n/dump/2006/0504/386/lib/libc.a /386/lib/libc.a
; bind /n/dump/2006/0504/sys/include/libc.h /sys/include/libc.h
.ps +1
.P2
.LP
Remember what
.CW bind
.ix [bind]
does. When your compiler and linker try to use
.CW libc.a ,
and
.CW libc.h ,
the name space jumps to those archived in the dump. If you suspect that
a program is failing because of a recent bug in the C library, you can check that out
by compiling your program using the library you had time ago, and running it again
to see if it works this time.
.PP
The script
.CW 9fs
.ix "[9fs] [rc]~script
also knows how to mount the dump. So, we could have said
.P1
.ps -1
; 9fs dump
; bind /n/dump/2006/0504/386/lib/libc.a /386/lib/libc.a
; bind /n/dump/2006/0504/sys/include/libc.h /sys/include/libc.h
.ps +1
.P2
.LP
instead of mounting the dump using
.CW srv
and
.CW mount .
.BS 2 "Local name space tricks
.LP
.ix "[Local]
.ix [acme]
You must always take into account that name spaces, i.e., mount tables,
are
.I per-process
in Plan 9. Most processes in the same window share the same name space (i.e.,
their mount table), and a
.CW mount ,
.CW bind ,
or
.CW unmount
done at a window will not in general be noticed at other ones. However,
.I any
process may have its own name space. This catches many users that have not
been using Plan 9 for some time, when they try to change the namespace using
Acme.
.PP
Figure [[!bind acme!]] shows a window running Acme. Using this acme, we executed
.P1
mkdir /tmp/dir ; bind /usr/nemo /tmp/dir
.P2
.LS
.BP acmebind.ps 3i
.LE F Executing a bind on Acme does not seem to work. What is happening?
.LP
(by selecting the text and then doing a click on it with the mouse button-2). Later,
we asked Acme to open
.CW /tmp/dir ,
using the mouse button-3. It was empty! What a surprise! Our home directory was
not empty, and after performing the
.CW bind ,
it seems that
.CW /tmp/dir
was not bound to our home directory. Is Acme broken?
.PP
Acme is behaving perfectly fine. When we used the mouse button 2 to execute the
command line, it created a child process to execute the command. The child process
prepared to execute the command and called
.CW rfork
with flags
.CW RFNAMEG|RFENVG|RFFDG|RFNOTEG .
Acme is just trying to isolate the child process. The flag
.CW RFNAMEG
caused the child process to obtain its own
.I copy
.ix [rfork]
of the name space used by Acme. As a result, any change performed to the name
space by the command you executed is unnoticed by Acme. The command starts,
changes its own name space, and dies.
.PP
To change this behavior, and ask Acme not to execute the child in its own
name space, you must use Acme's built-in command
.CW Local .
If a command is prefixed by
.CW Local ,
Acme understands that it must execute the command sharing its namespace with
the child process that will run the command. In this case, the child process will just
call
.CW rfork(RFFDG|RFNOTEG) ,
but it will share the namespace and environment variables with its parent (i.e., with
Acme). Figure [[!share name space acme!]] shows another attempt to change the name
space in Acme. The command executed this time was
.P1
Local mkdir /tmp/dir ; bind /usr/nemo /tmp/dir
.P2
.LP
and Acme executed
.P1
mkdir /tmp/dir ; bind /usr/nemo /tmp/dir
.P2
within its own name space. Note that
.CW Local
refers to the whole text executed as a command line, and not just to the first
command. This time, opening
.CW /tmp/dir
after the
.CW bind
shows the expected directory contents.
.LS
.BP acmebind2.ps 3i
.LE F Commands executed with \f(CWLocal\fP share their name space with Acme.
.PP
A related surprise may come from using the
.CW plumber ,
.ix [plumber]
.ix plumbing
.ix window
when you change the name space after starting it. The plumber has its own
name space, the one used by the shell that executed your
.CW $home/lib/profile ,
in case it was started from that file.
When the window system starts, it takes that name space as well. However,
the window system puts each window (process) in its own name space.
.PP
If there are three different windows running
Acme,
and you plumb a file name, the file will be open by all the Acmes running. This
is simple to understand, because all the editors are sharing the files at
.CW /mnt/plumb .
When you plumb a file name, the plumber sends the message to all editors
reading from the
.CW edit
port, as we saw.
.PP
But let's change the name space in a window, for example,
by executing
.P1
; 9fs whale
.P2
.LP
to mount at
.CW /n/whale
the file server named
.CW whale .
Here comes the surprise. When we try to plumb
.CW /n/whale/NOTICE ,
this is what we get.
.P1
; plumb /n/whale/NOTICE
; echo $status
plumb 1499: error
.P2
.LP
The plumber was unable to locate
.CW /n/whale/NOTICE .
After we mounted
.CW whale
on
.CW /n/whale !
.PP
But reconsider what happen. The shell running in the window is the one that
mounted
.CW /n/whale ,
the plumber is running using its own name space, far before our window was
brought to life. Therefore, the plumber does
.I not
have anything mounted at
.CW /n/whale .
It is our shell the one that has something mounted on it.
.PP
To change the name space for the plumber, a nice trick is used. The
.CW plumbing
.ix [plumbing]
file (containing the rules to customize plumbing) usually has one specific rule for
messages starting with the string
.CW Local .
This rule asks the plumber to execute the text after
.CW Local
in a shell started by the plumber. For example, we could do this:
.P1
; plumb 'Local 9fs whale'
; plumb /n/whale/NOTICE
; echo $status

;
.P2
.LP
The first command plumbs
.CW "Local 9fs whale" ,
which makes the plumber execute
.CW "9fs whale"
in a shell. Now, this shell is sharing the name space with the plumber. Thus,
the command plumbed
.I changes
the name space for the plumber. Afterwards, if we plumb
.CW /n/whale/NOTICE
the plumber will see that file and there will be no problem.
.PP
Is the problem solved? Maybe. After an editor is running at a different window,
receives the plumb message for
.CW /n/whale/NOTICE ,
it will not be able to open this file, because its name space is also different.
In general, this is not a problem at all, provided that you understand how you
are using your name spaces.
.PP
Another consequence of the per-process name spaces and the plumbing tool
is that you can isolate an editor regarding plumbing. Just do this:
.P1
; plumber
; acme
.P2
.LP
and the Acme will have its own set of plumbing files. Those files are supplied by
the plumber that you just started, which are different from the ones in use before
executing these commands.
.BS 2 "Device files
.LP
If you understood the discussion in the last section, this is a legitimate question:
How could my name space get anything mounted in the first place? To do a
mount, you must have a file where to do the mount. That is, you need a mount point.
.ix "mount point"
.ix "[#/] device driver
.ix "root device
.ix [/]
Initially, your machine is not even connected to the file server and you have just
what is inside your machine. You must have something that you could mount as
.CW /
in the first place.
.PP
Besides, you must be able to use your devices to reach the file server. This includes
.ix "device driver
.ix "file system
at least the network, and maybe the disk if you have your files stored locally in a
laptop. In Plan 9, the interface for using devices is a file tree provided by each
device driver (Remember, a device driver is just the program that drives your device,
and is usually linked inside the kernel).
That is to say that Plan 9
.I "device drivers are tiny file servers
that are
linked to the system.
.PP
You need to use the files provided by your drivers, which are their interface, if you
want to
use the devices. You want to use them to reach your file server across the network.
So, you have to mount these device file trees. And we are where we started.
.PP
The answer to this chicken-and-the-egg problem is a new kind of name that
we have silently omitted until now. You have absolute paths that start walking at
.CW / ,
you have relative paths that start walking at your current directory, and you also have
\fBdevice paths\fP
.ix "device path
.ix "[#] file names
that start walking at the root of the file tree of a device.
.PP
A device path starts with a hash “\f(CW#\fP” sign and a character (a rune in unicode)
that is unique for each device. The file
.CW /dev/drivers
.ix [/dev/drivers]
lists your device drivers, along with their paths:
.P1
; cat /dev/drivers
#/ root
#c cons
#P arch
#e env
#| pipe
#p proc
#M mnt
#s srv
.I "... others omitted
.P2
.LP
For example, the path
.CW #e
.ix "[#e] device driver
corresponds to the root directory of the file tree provided by the device
that keeps the environment variables.
Listing
.CW #e
(quoted, because the
.CW #
is special for the shell) gets the same file list than listing
.CW /env .
That is because
.CW #e
is bound at
.CW /env
by convention.
.P1
; lc /env
 '*'		cpu		init		planb
0		cputype		location	plumbsrv
.I "...and many others.
; lc '#e'
 '*'		cpu		init		planb
0		cputype		location	plumbsrv
.I "...and many others.
.P2
.LP
We have also seen that files at
.CW /proc
represent the processes in the system. Those files are provided by the
.I proc
device. To list the files for the process running the shell, we can
.ix "[#p] device driver
.P1
.ps -1
; lc /proc/$pid
args	fd	kregs	note	notepg	proc	regs
ctl	fpregs	mem	noteid	ns	profile	segment
.I "...and others.
.ps +1
.P2
.LP
But we can also
.P1
.ps -1
; lc '#p'/$pid
args	fd	kregs	note	notepg	proc	regs
ctl	fpregs	mem	noteid	ns	profile	segment
.I "...and others.
.ps +1
.P2
.LP
When a device path is used, the file tree for the device is automatically
mounted by the kernel. You might not even have where to mount it! The
rest of the name is resolved from there. Thus, device file names are always
available, even if you have no entries in your name space.
.PP
Where does
.CW /
come from? It comes from
.CW #/ ,
that is a tiny file tree that provides mount points to let you mount files
from other places. The device is called the
.CW root
device and includes the few programs necessary to reach your file server.
.P1
; lc '#/'
bin	dev	fd	net	proc	srv
boot	env	mnt	net.alt	root
.P2
.LP
This directory is bound to
.CW / ,
a few other mounts and binds made, and now you have your tree. The programs
needed to do this are also in there:
.P1
; lc '#//boot'
boot	factotum	fossil	ipconfig
.P2
.BS 2 "Unions
.LP
.ix "union mount
The mounts (and binds) we made so far have the effect of
.I replacing
the mount point file with the mounted file. This is what a mount table entry
does. However, you can also add a mounted file to the mount point. To see
how this works in a controlled way, let's create a few files.
.P1
; mkdir adir other
; touch adir/a adir/b adir/c
; touch other/a other/x other/y
; lc adir
a	b	c
.P2
.LP
If we bind
.CW other
into
.CW adir ,
we know what happens. From now on,
.CW adir
refers to
.CW other .
.P1
; bind other adir
; lc adir
a	x	y
.P2
.LP
After undoing the effect of the bind, to leave
.CW adir
undisturbed, we do another bind. But this time, we bind
.CW other
into
.CW adir
.I after
what it previously had, by using the
.CW -a
flag for
.CW bind .
.ix "[bind] flag~[-a]
.ix "[bind] flag~[-b]
And this is what we get:
.P1
; bind -a other adir
; lc adir
a	a	b	c	x	y
.P2
.LP
You can see how the file that used to be
.CW adir
now leads to a
.B union
of both the old
.CW adir
and
.CW other .
Its contents appear to be the union of the contents for both
directories. Because there are two files named
.CW a ,
one at the old
.CW adir
and another at
.CW other ,
we see that file name twice. Furthermore, look what happens here:
.P1
; rm adir/b
; lc adir
a	a	c	x	y
; rm adir/y
; lc adir
a	a	c	x
; lc other
a	x
.P2
.LP
Removing
.CW adir/b
removed the
.CW b
file from the original
.CW adir .
And removing the file
.CW adir/y
removed the file
.CW y ,
and of course the file is no longer at
.CW other
either. Let's continue the game:
.P1
; echo hola >other/a
; cat other/a
hola
; cat adir/a
;
.P2
.LP
We modify the file
.CW a
in
.CW other ,
and write something on it. Reading
.CW other/a
yields the expected result. However,
.CW adir/a
is still an empty file. Because we bound
.CW other
.I after ,
using the
.CW -a
flag for
.CW bind ,
the name
.CW a
is found in the old
.CW adir ,
which is
before the file with the same name in
.CW other .
Therefore, although we see twice
.CW a ,
we can only use the one that is first found.
.P1
; rm adir/a
; lc adir
a	c	x
; lc other
a	x
.P2
.LP
Removing
.CW adir/a
removes the file
.CW a
from the original
.CW adir .
But there is another file at
.CW other
named
.CW a ,
and we still see that name.
Because we bound
.CW other
into
.CW adir ,
.I after
what it previously had, the
.CW remove
system call finds first the name
.CW adir/a
at the old
.CW adir ,
and that is the one removed.
.PP
What happens to our name space?
How can it be what we saw above? The answer is that
you can bind (or mount) more than one file for the
.ix "mount point
same mount point. The mount table entry added by the bind
we made in this section is shown in figure [[!union mount entry!]].
.LS
.PS
.ps -2
boxwid=1
boxht=.4
[
	right
	box "Chan for" "\f(CWadir\fP"
	arrow right 1
	box "Chan for" "\f(CWadir\fP"
	arrow right 1
	box "Chan for" "\f(CWother\fP"
]
reset
.ps +2
.PE
.LE F A union mount. The mount entry after \f(CWbind -a other adir\fP. 
.PP
This entry has a mount point,
.CW adir .
When that file is reached, the name space jumps and continues walking
at the mounted file. However, here we have
.I two
mounted files for this entry. When we bound
.CW other
after what was initially at
.CW adir ,
Plan 9 added
.CW adir
as a file mounted here, and then
.CW other
was linked after as another mounted file. This can be seen if you use
.CW ns
to look for entries referring to
.CW adir :
.P1
; ns | grep adir
bind  /tmp/adir /tmp/adir 
bind -a /tmp/other /tmp/adir 
.P2
.LP
When a mount entry is a union, and has several mounted files,
the name space tries each one in order,
until one works for the name being resolved. When reading the directory,
.I all
of the feasible targets are read. Note that unions only make sense when
the files are directories.
By the way, to mount or bind
.I before
the previous contents of a union, use the flag
.CW -b
for either program.
.PP
Unions can be confusing, and
when you create files you want to be sure about where in the union
are you creating your files. To help, the flag
.CW -c
.ix "[bind] flag~[-c]
can be supplied to either
.CW bind
or
.CW mount
to allow you to create files in the file tree being mounted. If you do not supply
this flag,
you are not allowed to create files in there. When trying to create a file in
a union, the first file in the union mounted with
.CW -c
is the one used.
.BS 2 "Changing the name space
.LP
To adjust the name space in a C program, two system calls are available. They
are similar to the shell commands used above, which just call these functions
according to their command line arguments
.P1
.ps -2
; sig bind mount
	int bind(char *name, char *old, int flag)
	int mount(int fd, int afd, char *old, int flag, char *aname)
.ps +2
.P2
.LP
.ix [mount]
.ix [bind]
.ix "name space
The system call used by the
.CW mount
command we saw above is
.CW mount .
It takes a file descriptor,
.CW fd ,
used to reach the file server to mount. It must be open for reading and writing,
because a 9P conversation will go through it. The descriptor is usually a pipe or
a network connection, and must have a 9P speaker at the other end of the pipe.
To be on the safe side, Plan 9 closes
.CW fd
for your process after the mount has been done. This prevents you from reading
and writing that descriptor, which would disrupt the 9P conversation between Plan 9
and the file server.
.PP
After the call,
the
.CW old
file has the file server reached through
.CW fd
mounted on it.
The parameter
.CW aname
.ix [aname]
.ix "mount specifier
corresponds to the optional argument for the
.CW mount
command that names a particular file tree to be mounted. To mount
the server's main file free, supply an empty (not null!) string.
.PP
The options given to the shell command
.CW mount
are specified here using a bit-or of flags. You may use one of the
integer constants
.ix "[MREPL] mount~flag
.ix "[MBEFORE] mount~flag
.ix "[MAFTER] mount~flag
.ix "[MCREATE] mount~flag
.CW MREPL ,
.CW MBEFORE ,
and
.CW MAFTER .
Using
.CW MREPL
asks for
.I replacing
the old file (the mount point) with the new file tree. Using instead
.CW MBEFORE
asks
.CW mount
to mount the new file tree
.I before
the previous contents for the old file (equivalent to
.CW -b
in the shell command). Using
.CW MAFTER
instead asks for mounting the file tree
.I after
the old one (like giving a
.CW -a
to the shell command).
To allow creation of files in the mounted tree, do a bit-or of the
integer constant
.CW MCREATE
with any other flag.
.PP
This program mounts the main file tree of our file server at
.CW /n/whale ,
and the archive at
.CW /n/dump .
.so progs/whale.c.ms
.LP
Because the dump cannot be modified, we do not use
.CW MCREATE
for it, it would make no sense to try to create files in the (read-only) archive.
Running this program is equivalent to executing
.P1
; mount -c /srv/tcp!whale!9fs /n/whale
; mount /srv/tcp!whale!9fs /n/dump main/archive
.P2
.LP
As you could see, the program calls
.CW amount
.ix [amount]
.ix "authentication mount
and not
.CW mount .
The function
.CW amount
is similar to
.CW mount ,
but takes care of
.I authentication ,
i.e.,
convincing the file server that we are who we say we are. This is necessary or
the file server would not allow attaching to its file tree with the access rights
granted to our user name. After
.CW amount
convinces the file server, it calls
.CW mount
supplying an
.I "authentication file descriptor"
as the value for the
.CW mount
parameter
.CW afd .
.ix "authentication file descriptor
The other parameters for
.CW mount
are just those we gave to
.CW amount .
.PP
The other system call,
.CW bind ,
is used in the same way. Its flags are the same used for mount. However, unlike
mount, it receives a file
.CW name
instead of a file descriptor. As you could expect after having using the shell
command
.CW bind .
.BS 2 "Using names
.LP
We have seen that the shell has an environment variable,
.CW path ,
.ix "[path] variable
to determine where to search for commands. There are several interesting
things to note about this. First, there are only two directories where to search.
.P1
; echo $path
 .  /bin
;
.P2
.LP
This is really amazing if you compare this with the list of directories in the PATH
in other systems, which tends to be much larger.
For example, this is the variable used in a UNIX system we have
around:
.P1
$ echo $PATH
/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/opt/bin:.
$
.P2
.LP
In UNIX, the
.CW PATH
variable has the same name in upper-case, and directories
are separated by colons instead of space.
.PP
Also, how do you get at
.CW /bin
only those binaries for the architecture you are using?
.ix [/bin]
.ix "binary file
.PP
After your machine
has completed its boot process, and mounted the file server, it runs a program
called
.CW init .
This program initializes a new namespace for your terminal and runs
.CW /bin/rc
within such namespace, 
to execute commands in
.CW /rc/bin/termrc ,
.ix [termrc]
that start system services necessary for using the system.
The namespace is initialized by a call to
the function
.CW newns ,
.ix [newns]
.ix "new name space
.P1
; sig newns
	int newns(char *user, char *nsfile);
.P2
which reads a description for an entire namespace from a file,
.CW nsfile ,
and builds a new namespace for a given
.CW user
that matches such description. This is is an excerpt from the file
.CW /lib/namespace ,
which is the
.CW nsfile
used by default:
.P1
.SM
# root
mount -aC #s/boot /root $rootspec
bind -a /root /

# kernel devices
bind #c /dev
bind #d /fd
bind -c #e /env
bind #p /proc
bind -c #s /srv
.I "...several other binds...

# standard bin
bind /$cputype/bin /bin
bind -a /rc/bin /bin

# User mounts
bind -c /usr/$user/tmp /tmp
bind -bc /usr/$user/bin/$cputype /bin
bind -bc /usr/$user/bin/rc /bin
cd /usr/$user
.NS
.P2
.LP
As you can see, a namespace file for use with
.CW newns
contains lines similar to shell commands used to adjust the namespace, that
are like the ones in
.CW /proc/*/ns
files.
The file
.CW #s/boot
is a connection to the file server used to boot the machine. This is what
you find at
.CW /srv/boot ,
after the line
.P1
bind -c #s /srv
.P2
.LP
in the namespace file has been processed. Ignoring some details, you can
see how this file server is mounted at
.ix [/root]
.CW /root ,
and then this directory is added to
.CW / .
Both directories come from your root device,
.CW #/ ,
which is always available. 
The dance around
.CW /root
and
.CW /
.I adds
the root of the file server to those files already in
.CW /root .
.PP
The next few lines bind device driver file trees at conventional places.
For example,
.ix "console device
.ix "[#c] device driver
.CW #c
is the
.I cons
driver, which is bound at
.CW /dev
and provides files like
.CW /dev/null ,
.CW /dev/time ,
.ix [/dev/null]
.ix [/dev/time]
and other common files for the machine.
Also,
.CW #d
.ix "[#d] device driver
.ix "[/fd] file system
provides the file interface for your file descriptors, and is bound at
.CW /fd
as expected.
The same is done for other drivers.
.PP
Now look at the sections marked as
.I "standard bin" ,
and
.I "user mounts" .
They answer our question regarding
.CW /bin .
.PP
The program
.CW init
.ix [init]
.ix booting
defined several environment variables. For example,
.CW $user
holds your user name,
.CW $sysname
your machine name, and
.CW $home
your home directory. It also defined another variable,
.CW $cputype ,
which holds the name for the architecture it was compiled for. That is,
for the architecture you are using now! Therefore,
.ix [$user]
.ix [$sysname]
.ix [$home]
.ix [$cputype]
.ix "user name
.ix "system name
.ix "home directory
.ix "CPU type
.P1
bind /$cputype/bin /bin
bind -a /rc/bin /bin
.P2
.LP
binds
.CW /386/bin
into
.CW /bin ,
.ix 386
.ix "union
on a PC. All the binaries compiled for a 386 are now available at their
conventional place,
.CW /bin .
Besides, portable Rc scripts found at
.CW /rc/bin ,
which can be interpreted by
.CW rc
at any architecture, are added
to
.CW /bin ,
after the binaries just bound. You have now a complete
.CW /bin ,
all set for using. It that was not enough, the lines
.P1
bind -bc /usr/$user/bin/$cputype /bin
bind -bc /usr/$user/bin/rc /bin
.P2
.LP
add your own binaries and Rc scripts, that are stored at
.CW bin/386
(in this case) and
.CW bin/rc
in your home directory.
.PP
If you want to add, or remove, more binaries at
.CW /bin ,
you can just use
.CW bind ,
to customize
.CW /bin
as you please. There is no need for a longer
.CW $path ,
because
.CW /bin
may have just what you want. And you always know where your
binaries are, i.e., just look at
.CW /bin .
.PP
Another detail that you see is that the directory
.CW /tmp
is indeed
.CW /usr/$user/tmp .
You have your own directory for temporary files, although all programs
create them at
.CW /tmp ,
by convention. Even if the file system is being shared by multiple users,
each user has its own
.CW /tmp ,
to avoid disturbing others, and to avoid being disturbed.
.PP
We are going to continue showing how to use the name space to do a
variety of things. Nevertheless, if you want
to read a nice introduction to using name spaces for doing things, refer to
[.use name spaces.].
.BS 2 "Sand-boxing
.LP
.ix "sandboxing
Being able to customize the name space for a particular process is a very
powerful tool. For example, the window system does a
.P1
rfork(RFNAMEG)
.P2
to make a duplicate of the namespace it runs in, for each window (actually,
for each shell that is started for a new window). The shell script
.ix "[window] command
.P1
; window
.P2
.LP
creates a new Rio window, with a new shell on it. This shell is provided with its own copy
of the namespace, customized to use the console, mouse, and screen just for that
window. These are the commands:
.P1
rfork ne
mount /srv/rio.nemo.39 /mnt/wsys
bind -b /mnt/wsys /dev
.P2
.LP
.ix "window system
.ix "[rio] file system
Mounting the file server for the window system creates a new window, and
binding its file tree at
.CW /dev
replaces the files that represent the console. All the programs are unaware of this.
.PP
Many other things can be done. To freeze the time in your system, just provide
a file interface that never changes:
.P1
; cp /dev/time /dev/bintime /tmp/
; bind /tmp/time /dev/time
; bind /tmp/bintime /dev/bintime
.P2
.LP
One interesting use of namespaces is in creating sandboxes for processes to run.
A
.B sandbox
is a container of some kind that isolates a process to prevent it from doing any
damage, like when you do a sand box in the beach to contain the water.
This program creates a sandbox to run some code inside. It uses
.CW newns
to build a whole new namespace according to a file given as a parameter.
Because of the call to
.CW rfork(RFNOMNT)
.ix "no~attach
.ix "[RFNOMNT] [rfork]~flag
that follows, the process will not be allowed to mount any other file tree. It may
access just those files that are in the namespace described in the file. That is
a very nice sand box.
.ix [box.c]
.so progs/box.c.ms
.LP
The call to
.CW getuser
.ix [getuser]
returns a string with the user name. We have already seen all other calls
used in this program. The program can be used like in
.P1
; 8.box sandbox /bin/rc
.P2
.LP
Where
.CW sandbox
is a file similar to
.CW /lib/namespace ,
.ix [/lib/namespace]
.ix "standard name~space
but with mounts and binds appropriate for a sandbox.
.BS 2 "Distributed computing revisited
.LP
.ix "distributed computing
.ix "remote execution
.ix "import
.ix "remote file~system
.ix "CPU server
In the last chapter, we learned about CPU servers and connected to one
of them to execute commands. But there is one interesting thing about that
kind of connection. Indeed, you have already seen it, but perhaps it went unnoticed.
This thing may become more visible if you connect to a cpu server and execute
.CW rio .
The result is shown in figure [[!rio cpu!]].
.LS
.BP cpurio.ps
.LE F Rio run in a Rio window. The inner rio runs at a CPU server, not at your terminal.
.P1
; cpu
cpu% !!rio
.I "...and you get a whole window system in your window!
.P2
.LP
You just started the window system, but it is running at the CPU server, and not
at your terminal. However, it is using your mouse, your keyboard, and your screen
to do its job! Not exactly, indeed, it is using the virtual mouse, keyboard, and screen
provided by the Rio in your terminal for the window you used to connect to the
CPU server. Is it magic?
.PP
The answer may come if you take a look at the name space used by a shell
obtained by connecting to a CPU server. This shell has a namespace that has
at
.ix [/mnt/term]
.ix "terminal file~system
.CW /mnt/term
the whole namespace you had available in the window where you did run
.CW cpu .
.ix [cpu]
Furthermore, some of the files at
.CW /mnt/term/dev
were bound to
.CW /dev .
.ix [/dev]
Therefore, many of the devices used by the shell (or any other process) in the CPU server
do not come from the CPU server itself. They come from your terminal!
.PP
The namespace at your terminal includes files like
.CW /dev/cons ,
.CW /dev/draw ,
and
.CW /dev/mouse .
.ix [/dev/mouse]
.ix [/dev/draw]
This name space was initialized by
a process that called
.CW newns
using
.CW /lib/namespace ,
as we saw in another example before, and then perhaps you customized
it further by doing mounts or
binds in your profile. The same happens for the shell started for you in the CPU server.
It gets a namespace initialized by a call to
.CW newns ,
and perhaps by your profile.
However, the program initializing a namespace for you in the CPU server
mounted at
.CW /mnt/term
the name space exported from your terminal, and made a few binds to
adjust
.CW /dev
to use your terminal's devices instead.
.PP
This includes the files we mentioned above
that are the interface for your console, for drawing graphics, and for using
the mouse. At least, they are within your terminal's window. At a different window, you know
that rio provides different files that represent the interface for the console, graphics,
and mouse for that other window.
.PP
Now the question remains. How can a namespace be exported?
Change the question. How can a namespace be imported? To import
anything into your namespace, you must mount a 9P file server. Therefore,
if your namespace is exported using a file server, it can be imported.
It turns out that there is a program for doing just that. Well, there are two.
.PP
The real work is done by
.CW exportfs .
.ix [exportfs]
.ix "file~system export
This program uses the venerable calls
.CW open ,
.CW close ,
.CW read ,
.CW write ,
etc. to access your namespace, and exports it by speaking 9P through a network
connection, like any other file server. When a 9P client of
.CW exportfs
asks this program to return the result of reading a file, it reads the file
and replies. When a 9P client asks
.CW exportfs
to write into a file, by sending a 9P write request to it, the program uses the
.CW write
system call to write to the file. The effect is that for anyone mounting the file
tree provided by
.CW exportfs ,
that file tree is exactly the same than the one in effect in the namespace where
.CW exportfs
runs.
.PP
The second program
that can be used to export a namespace,
.ix [srvfs]
.ix [/srv]
.CW srvfs ,
is just a convenience
wrapper, that calls
.CW exportfs
in a way that is simpler to use from the shell. It receives the name for
a file to be created at
.CW /srv ,
that when mounted, grants access to the file tree rooted at the directory given
as the second argument.
.PP
To see that
.CW srvfs ,
i.e.,
.CW exportfs ,
is indeed exporting a namespace, we can rearrange a little bit
our namespace, export a part of it, and see how after mounting it
we gain access to the rearranged file tree that we see, and not the real one from the
file server.
.P1
; mkdir /tmp/exported /tmp/exported/doc /tmp/exported/src
; bind $home/doc /tmp/exported/doc
; bind $home/src /tmp/exported/src
; 
; srvfs x /tmp/exported
; 
; mount -c /srv/x /n/imported
; lc /n/imported
doc	src
; lc /n/imported/src
9		gs		misc
UGrad		lang		os
bbug		limbo		prj
chem		mem		sh
.P2
.LP
A nice example of a use for this program can be found
in the
.I srvfs (4)
manual page.
.P1
; cpu
cpu% !!srvfs procs /mnt/term/proc
cpu%
.P2
.ix "remote debugging
This posts at
.CW /srv/procs ,
in the CPU server,
a file descriptor that can be used to mount the file tree seen at
.CW /mnt/term/proc
in the namespace where
.CW srvfs
is executed. That is, the
.CW /proc
file tree at the terminal used to run the
.CW cpu
command.
Therefore, mounting
.CW /srv/procs
in the CPU server
permits obtaining access to the
.CW /proc
interface for the user's terminal.
.P1
cpu% !!mount -c /srv/proc /n/procs
cpu% !!lc /n/procs
1	20	257	30	33	367	662
10	21	259	300	330	37	663
11	213	26	305	334	38	669
111	214	260	306	335	387	674
12	22	265	310	34	389	676
13	23	266	311	346	39	677
;
.P2
.LP
Remember, because almost every resource looks like a file, you can
now export whatever resource you may want.
.PP
Indeed, we do not even need to use
.CW cpu
to connect to the CPU server to mount the exported
.CW /proc ,
we can
.I import
the directory
.CW /srv
from the CPU server, and mount it at our terminal:
.P1
; import $cpu /srv /n/cpusrv
; mount -c /n/cpusrv/proc /n/procs
.P2
.LP
The program
.CW import
is the counterpart of
.CW exportfs .
It imports a part of a remote namespace into our namespace.
What it does is to connect to the remote system, and start an
.CW exportfs
there, to export file tree of interest. And then, it mounts the now
exported file tree in our namespace.
.PP
For example, the file name
.CW #S
.ix "storage device driver
.ix "[#S] device driver
.ix [sdC0]
is the root directory for the storage device driver. This driver provides
one directory per hard disk, which contains one file per partition in the disk.
It doesn't really matter how a disk interface looks like, or how a disk is managed
in Plan 9. What matters is that this is the way to get access to the disks in your
system, for example, to format them. My terminal has two hard disks and a DVD reader.
.P1
; lc '#S'
sdC0	sdC1	sdD0	sdctl
.P2
.LP
They are named
.CW sdC0 ,
.CW sdC1 ,
and
.CW sdD0. Because
.CW #S
is usually added to
.CW /dev
using
.CW bind ,
some of these files are likely to show up in your
.CW /dev .
.PP
If you want to format a hard disk found at a remote
machine, you may do so from your terminal. Imagine the disk is at your CPU
server, you might do what follows.
.P1
; import $cpu '#S' /n/cpudisks
; lc /n/cpudisks
sdC0	sdC1	sdD0	sdD1 sdctl
;
.P2
.LP
If you do not have a floppy reader unit at your terminals (which is the
common case today for laptops), there is no need to worry.
You can import
.CW #f ,
the root directory for the floppy disk driver, from another machine. And then
use the script
.CW a: ,
which mounts the DOS formatted floppy of your terminal at
.CW /n/a .
.P1
; import -bc barracuda '#f' /dev
; a:
; cp afile /n/a/afile.txt
; unmount /n/a
.P2
.LP
As you could see,
.CW import
admits the same familiar options for
.CW mount
and
.CW bind ,
to mount the imported tree before, after, or replacing part of your namespace.
.PP
.ix "firewall
This applies to the the serial port, the audio card, and any other resource that any
other machine might have,  provided it is represented as a file. As a final example,
firewalls are machines that are connected to two different networks, one protected
network for local use, and the internet. In many cases, connecting directly to
the internet from the local network is forbidden, to create a firewall for viruses and
malicious programs. Nevertheless, if the firewall network for connecting to the
Internet is
.CW /net.alt ,
at the firewall machine, this grants your machine direct connection to the internet
as well (at the price of some danger).
.P1
; import -c firewall /net.alt /net
.P2
.SH
Problems
.IP 1
Add the line
.P1
rfork(RFNAMEG);
.P2
.IP
to the program
.CW whale ,
before doing the calls to
.CW amount ,
and see what happens when you execute it. Explain.
.IP 2
Enumerate the file servers available at your local Plan 9 site.
.IP 3
Print down the name space used by the plumber in your session.
.IP 4
Reproduce your name space at a different machine.
.IP 5
Make your system believe that it has an extra CD unit installed. Use it.
.IP 6
Put any server you have implemented in a sand-box. Try to break it.
.ds CH
.bp
 \c
.bp
 \c