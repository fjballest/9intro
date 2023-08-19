.so tmacs
.BC 1 "Getting started
.BS 2 "What is an Operating System?
.LP
The
.B "operating system
is the software that lets you use the computer.
What this means depends on the user's perspective. For example, for
my mother, the operating system would include not just Windows, but most
programs in the computer as well. For a programmer, many applications are
not considered part of the system. However, he would consider compilers,
libraries, and other programming tools as part of it. For a systems programmer,
the software considered part of the system might be even more constrained. We
will get back to this later.
.ix libraries
.PP
This book aims to teach you how to effectively use the system (in many cases, we say just
“system” to refer to the operating system). This means
using the functions it provides, and the programs and languages that come
with it to let the machine do the job. The difference between ignoring how to
ask the system to do things and knowing how to do it,
is  the difference between requiring
hours or days to accomplish many tasks and being able to do it in minutes.
You have to make your choice.
If you want to read a textbook that describes the theory and abstract concepts
related to operating systems, you may refer to [.operating systems minix.].
.PP
So, what is an operating system? It is just
.I "a set of programs that lets you use the computer" .
The point is that hardware is complex and is far from the concepts
you use as a programmer. There are many different
types of processors, hardware devices for Input/Output (I/O),
and other artifacts. If you had to write software
to drive all the ones you want to use, you would not have time to write your own
application software. The concept is therefore similar to a software library. Indeed, operating
systems begun as libraries used by people to write programs for a machine.
.PP
When you power up the computer, the operating system program is loaded into
memory. This program is called the
.B kernel .
Once initialized, the system program is prepared to run user programs and permits
them use the hardware by calling into it. From this point on, you can think about
the system as a library. There are three main benefits that justify using an operating
system:
.IP 1
You don't have to write the operating system software yourself, you can reuse it.
.IP 2
You can forget about details related to how the hardware works, because this
.I library
provides more abstract data types to package services provided by the hardware.
.IP 3
You can forget about how to manage and share the hardware among
different programs in the same computer, because this
.I library
has been implemented for use with multiple programs simultaneously.
.LP
Most of the programs you wrote in the past used disks, displays,
keyboards, and other devices. You did not have to write the software to drive
these devices, which is nice. This argument is so strong that nothing more should
have to be said to convince you. It is true that most programmers underestimate
the effort made by others and overestimate what they can do by themselves. But
surely you would not apply this to all the software necessary to let you use the
hardware.
.PP
Abstract data types are also a convenience to write software.
For example, you wrote programs using
.I files .
However, your hard disk knows
.I nothing
about files. Your hard disk knows how to store blocks of bytes. Even more,
it only knows about blocks of the same size. However, you prefer to use
.I names
for a piece of persistent data in your disk, that you imagine as contiguous storage
nicely packaged in a
.I file .
The operating system invents the
.CW file
data type, and provides you with operations to handle objects of this type.
Even the file's
.I name
is an invention of the system.
.PP
This is so important, that even the “hardware” does this. Consider the disk.
The interface used by the operating system to access the disk is usually
a set of registers that permits transferring blocks of bytes from the disk to main
memory and vice-versa. The system thinks that blocks are contiguous storage
identified by an index, and therefore, it thinks that the disk is an array of
blocks. However, this is far from being the truth. Running in the circuitry of
a hard disk there is a plethora of software inventing this lie. These days,
nobody (but for those working for the disk manufacturer) knows really what
happens inside your disk. Many of them use complex geometries to achieve
better performance. Most disks have also memory used to cache entire tracks.
What old textbooks say about disks is no longer true. However, the
operating system still works because it is using its familiar disk abstraction.
.ix abstraction
.ix "abstract data types
.PP
Using abstract data types instead of the raw hardware has another benefit:
portability. If the hardware changes, but the data type you use remains the
same, your program would still work. Did your programs using files still work
when used on a different disk?
.PP
Note that the hardware may change either because you replace it with more modern
one, or because you move your program to a different computer.
Because both hardware and systems
are made with
.B backward-compatibility
in mind, which means that they try hard to work for programs written for previous
versions of the hardware or the system. Thus, it might even be unnecessary
to recompile your program if the basic architecture remains the same. For
instance, your Windows binaries would probably work in any PC you might find
with this system. When they do not work, it is probably not because of the
hardware, but due to other reasons (a missing library in the system or a bug).
.PP
This is the reason why operating systems are sometimes called (at least
in textbooks) a
.B "virtual machine" .
.ix abstraction
They provide a machine that does not exist, physically,
hence it is virtual. The virtual machine
provides files, processes, network connections, windows, and other artifacts
unknown to the bare hardware.
.PP
With powerful computers like the ones we have today, most machines are
capable of executing multiple programs simultaneously. The system makes
it easy to keep these programs running, unaware of the underlying complexity
resulting from sharing the machine among them.
.PP
Did you notice that it was
natural for you to write and execute a program as if the computer was all
for itself? However, I would say that at least an editor, a web browser, and
perhaps a music player were executing at the same time. The system
decides which parts of the machine, and at which times, are to be used
by each program. That is, the system
.I multiplexes
the machine among different applications.
The abstractions it provides try to isolate one executing
program from another, so that you can write programs without having to
consider all the things that happen inside your computer while they run.
.PP
Deciding which resources are used by which running programs, and administering them
is called, not surprisingly,
.I "resource management" .
Therefore the operating system is also a
.B "resource manager" .
It assigns
resources to programs, and multiplexes resources among programs.
.PP
Some resources
must be
.I "multiplexed on space" ,
.ix "resource multiplexing
i.e. different parts of the resource are given to different programs. For example,
memory. Different programs use different parts of your computer's memory.
However, other resources cannot be used by several programs at the same time.
Think on the processor. It has a set of registers, but a compiled program is free
to use any of them. What the system does is to assign the whole resource for
a limited amount of time to a program, and then to another one in turn. In this case,
the resource is
.I "multiplexed on time" .
Because
machines are so fast, you get the illusion that all the programs work nicely as
if the resource was always theirs.
.PP
People make mistakes, and programs have bugs. A bug in a program
may bring the whole system down if the operating system does not take
countermeasures. However, the system is not God, and magic does not
.ix magic
exist (or does it?). Most systems use hardware facilities to protect executing
programs, and files, from accidents.
.PP
For example, one of the first things that
the system does is to protect itself. The memory used to keep the system program
is marked as
.I privileged
.ix "privileged mode
and made untouchable by non-privileged software. The privilege-level is
determined by a bit in the processor and some information given to the hardware.
The system runs with this bit set, but your programs do not. This means that
the system can read the memory used by your program, but not the other way around.
Also, each program can read and write only its own memory (assigned to it by
the system). This means that a misleading pointer in a buggy program would
not affect other programs. Did you notice that when your programs crash the
other programs seem to remain unaffected? Can you say why?
.PP
To summarize, the operating system is just some software that provides
convenient abstractions to write programs without dealing with the underlying
hardware by ourselves. To do so, it has to manage the different resources to
assign them to different programs and to protect ones from others. In any case,
the operating system is just a set of programs, nothing else.
.BS 2 "Entering the system
.ix "entering the~system
.LP
In this course you will be using Plan 9 from Bell Labs. There is a nice
paper that describes the entire system in a few pages [.plan9.].
All the programs shown in this book are written for this
operating system.
Before proceeding, you need to know how to enter the system, edit files and run
commands. This will be necessary for the rest of this book. One word of caution,
if you know UNIX, Plan 9 is not UNIX, you should forget what you assume about
UNIX while using this system.
.ix UNIX
.PP
In a Plan 9 system, you use a
.B terminal
to perform your tasks.
The terminal is a machine that
lets you execute commands by using the screen, mouse, and keyboard as
input/output devices.
See figure [[!terminal window system files!]].
A
.B command
is simply some text you type to ask for something.
.ix command
Most likely, you will be using a PC as your terminal.
The
.B "window system" ,
the program that implements and draws the windows you see
in the screen, runs at your terminal. The commands you
execute, which are also programs, run at your terminal.
Editing happens at your terminal. However,
none of the files you are using are stored at your terminal. Your terminal's disk
is not used at all. In fact, the machine might be diskless!
.LS
.PS
.ps -2
copy "/lib/pic/macros"
down
T1: [	down
	B: xterm(0.5);
	box invis "Command execution," "Window system, ..."
]
line <-> dotted from T1.B.e down .7 right 1.5 "network"
L : line <-> dotted left down .7 left 1.5 "network"
T2: [	down
	B: xterm(0.5);
	box invis "Command execution," "Window system, ..."
]
[
	down
	B: tower(0.5)
	move .2
	box invis "Files," "Accounts, ..."
] with .w at L.e
.ps +2
.PE
.LE F You terminal provides you with a window system. Your files are not there.
.LP
There is one reason for doing this. Because your terminal does not keep state
(i.e., data in your files), it can be replaced at will. If you move to a different terminal
and start a session there, you will see the very same environment you saw at the
old terminal. Because terminals do not keep state, they are called
.B stateless .
Another compelling reason is that the whole system is a lot easier to administer.
For example, none of the terminals at the university had to be installed or customized
to be used with Plan 9. There is nothing to install because there is no state to keep
within the terminal, remember?
.PP
Your files are kept at another machine, called the
.B "file server" .
The reason for this name is that the machine
.I serves
(i.e., provides) files to other machines in the network. In general, in a network of
computers (or programs) a server is a program that provides any kind of service (e.g.,
file storage). Other programs order the server to perform operations on its files, for example,
to store new files or retrieve data. These programs placing orders on the server are
called
.B clients .
In general, a client sends a message to a server asking it to perform a certain task, and
the server replies back to the client with the result for the operation.
.PP
To use Plan 9, you must switch on your terminal. Depending on the local installation, you
may have to select PXE as the boot device (PXE is a facility that lets the computer
.ix PXE
.ix booting
load the system from the network). But perhaps the terminal hardware has been
configured to boot right from the network and you can save this step. Once the Plan 9
operating system program (you know, the
.I kernel )
has been loaded into memory, the screen looks similar to this:
.PP
.P1
.ps -1
PBS...
Plan 9
cpu0: 1806MHz GenuineIntel P6 (cpuid: AX 0x06D8 DX 0xFE9FBBF)
ELCR: 0E20
#l0: AMD79C970: 10Mbps port 0x1080 irq 10: 000c292839fc
#l1: AMD79C970: 10Mbps port 0x1400 irq 9: 000c29283906
#U/usb0: uhci: port 0x1060 irq 9
512M memory: 206M kernel data, 305M user, 930M swap
root is from (local, tcp)[tcp]: 
.ps +1
.P2
.LP
There are various messages that show some information about your terminal,
including how much memory you have. Then, Plan 9 asks you where do you
want to take your files from. To do so, it writes a
.B prompt ,
i.e., some text to let you know that a program is waiting for you to type something.
In this prompt, you can see
.CW tcp
between square brackets. That is the default value used if you hit return without
further typing.
Replying
.CW tcp
to this prompt means to use the TCP network protocol
to reach the files kept in the machine that provides them
to your terminal (called, the file server).
Usually, you just have to hit return at this stage. This leads to
another prompt, asking you to introduce your user name.
.PP
You may obtain a user name
.ix "user name
by asking the administrator of the Plan 9 system to provide one for you (along with
a password that you will have to specify). This is called opening an
.B account .
In this example we
will type
.CW nemo
as the user name. What follows is the dialog with the machine to enter the system.
.P1
.ps -1
user[none]: !!nemo
time...version...
!Adding key: dom=dat.escet.urjc.es proto=p9sk1
user[nemo]: \fBReturn\fP
password: \fItype your password here and press return\fP
!
.ps +1
.P2
.LP
This dialog shows all conventions used in this book. Text written by the computer
(the system, a program, ...) is in 
constant width font, like in
.CW user[none] .
Text you type is in a slightly slanted variant of the same font, like in
.CW \S'15'nemo\S'0' .
When the text you type is a special key not shown in the screen, we use
boldface, like in
.B Return .
Any comment we make is in italics, like in
.I "type your password" .
Now we can go back to how do we enter the system.
.PP
At the
.CW user
prompt, you told your terminal who you are. Your terminal trusts you. Therefore,
there is no need to give it a password. At this point you have an open account at
your terminal!
.ix "open account
This is to say that you now have a program running on your name in the computer.
By the way, entering the system is also called
.B "logging into"
.ix login
the system. Leaving the system is called usually
.B "loging out" .
.ix logout
.PP
However,
the file server needs some proof  to get convinced that you are who you say you are.
That is
why you will get immediately two more prompts: one to ask your user name at the
file server, and one to ask for your secret password for that account.
Usually, the user name for your account in the file server is also that used in
the terminal, so you may just hit return and type your password when prompted.
.PP
If you come from UNIX, be aware not to type your password immediately after you
typed your user name for the first time. That would be the file server user name,
and not the password. All your password would be in the clear in the screen for
anyone to read.
.PP
You are in! If this is the first time you enter a Plan 9 system you have now the
prompt of a system
.I shell
(after several error messages). A
.B shell
is a program that lets you execute
commands in the computer. In Windows, the window system itself is the system
shell. There is another shell in Windows, if you execute
.CW "Run command"
in the start menu
you get a line of text where you can type commands. That is a
.B "command line" .
.PP
At this point in your Plan 9 session, you can also type commands to the shell that
is running for you. The shell is a program,
.CW rc
.ix [rc]
in this case, that writes a prompt, reads a command (text) line, executes it, waits
for the command to complete, and then repeats the whole thing. 
.PP
The shell prompt may be
.CW term% ,
or perhaps just a semicolon (which is the prompt we use in this book). Because you
never entered the system, and because your files are yours, nobody created a few
files necessary to automatically start the window system when you enter the system.
This is why you got some error messages complaining about some missing files. The
only file created for you was a folder (we use the name
.ix directory
.I directory )
where you can save your files. That directory is your
.B "home directory" .
.LS
.BP rio.ps
.LE F Your terminal after entering rio. Isn't it a clean window system?
.PP
Proceeding is simple. If you execute
.P1
; /sys/lib/newuser
.P2
.LP
the
.CW newuser
.ix [newuser]
program will create
a few files for you and start
.CW rio ,
.ix [rio]
the Plan 9 window system. To run this command, type
.CW /sys/lib/newuser
and press return. All the commands are executed that way, you type them at the
shell prompt and
press return.
.PP
Running
.CW newuser
is only necessary the first time you enter the system. Once executed, this
program creates for you a
.CW profile
.ix [profile]
file that is executed when you enter the system, and starts
.CW rio
for you. The profile for the user
.CW nemo
is kept in the file
.CW /usr/nemo/lib/profile .
Users are encouraged to edit their profiles to add any command they want to
execute upon entering the system, to customize the environment for their needs.
To
let you check if things went right, figure [[!clean window system!]] shows your screen once rio started.
.BS 2 "Leaving the system
.ix "leaving the~system
.LP
To leave your terminal you have all you need. Press the terminal power button
.ix "loging out
.ix logout
(don't look at the window system for it) and switch it off. Because the files
are kept in the file server, any file you changed is already kept safe in the file server.
Your terminal has nothing to save. You can switch it
off at any time.
.BS 2 "Editing and running commands
.ix editing
.ix "executing commands
.LP
The window system is a program that can be used to create windows. Initially, each window
runs the Plan 9 shell, another program called
.CW rc .
To create a window you must press the right mouse button (button-3) and
hold it. A menu appears and you can move the mouse (without releasing the
.ix "window system
.ix "[rio] menu
.ix "mouse button
button) to select a particular command. You can select
.CW New
(see figure [[!rio menu button-3!]]) by releasing the mouse on top of that command.
.PP
Because
.CW rio
is now expecting one argument, the pointer is not shown as
an arrow after executing
.CW New ,
.ix "[rio] commands
.ix [New]
.ix "new window"
it is shown as a cross. The argument
.CW rio
requires is the rectangle where
to show the window. To provide it, you press button-3, then sweep a
rectangle in the screen (e.g., from the upper left corner to the bottom right one),
and then release button-3. Now you have your shell.
The other
.CW rio
commands are similar. They let you resize, move, delete, and hide
.ix [Resize]
.ix [Move]
.ix [Delete]
.ix [Hide]
any window. All of them require that you identify which window is to be involved. That
is done by a single button-3 click on the window. Some of them (e.g.,
.CW Resize )
require that you provide an additional rectangle (e.g., the new one to be used
after the resize). This is done as we did before.
.LS
.BP new.ps
.LE F The rio menu for mouse button-3.
.LP
The window system uses the real display, keyboard, and mouse, to provide
multiple (virtual) ones. A command running at a window thinks that it has the
real display, keyboard, and mouse. That is far from being the truth! The window
system is the one providing a fake set of display, keyboard, and mouse to programs
running in that window. You see that a window system is simply a program that
.I multiplexes
the real user I/O devices to permit multiple programs to have their own virtual ones.
.PP
It will not happen in a while, but in the near future we will be typing many
commands in a window. As commands write text in the window, it may fill up and
reach the last (bottom)  line in the window. At this point, the
window will not scroll down to show more
text unless you type the down arrow key, ↓,
in the window. The up arrow key, ↑, can be used to scroll up the window.
You can edit all the text in the window. However, commands may be typed only
at the end. You can always use
the mouse to click near the end and type new commands if you
changed. The
.I Delete
key can be used to stop a command, should you want to do so. 
.PP
To edit files, and also to run commands and most other things (hence its name),
we use
.CW acme ,
a user interface for programmers developed by Rob Pike.
.ix "Rob Pike
.ix [acme]
When you run acme in your new window it would look like shown in figure [[!acme edit!]].
Just type the command name,
.ix [acme]
in the new window (which has a shell accepting commands) and press return.
.LS
.ps -4
.BP acme.ps
.ps +4
.LE F Acme: used to edit, browse system files, and run commands.
.PP
As you can see, acme displays a set of windows using two columns initially. Acme is
indeed a window system!
.ix file editor
Each window in acme shows a file, a folder, or the output of commands.  In the figure,
there is a single window showing the directory (remember, this is the name we use for folders)
.CW /usr/nemo .
For
.I Nemo ,
that is the
.I "home directory" .
As you can see, the horizontal text line above each window is called the
.I "tag line"
for the window. 
In the figure, the tag line for the window
showing
.CW /usr/nemo
contains the following text:
.P1
/usr/nemo Del Snarf Get | Look
.P2
.LP
Each tag line contains on the left
the name of the file or directory shown. Some other words follow, which represent
commands (buttons!). For example, our tag line shows the commands
.CW Del ,
.CW Snarf ,
.CW Get ,
and
.CW Look .
.PP
Within acme, the mouse left mouse
button (button-1) can be used to select a portion of text, or to
change the insertion point (the tiny vertical bars) where text is to be inserted.
All the text shown can be edited. If we click before
.CW Look
with the left button, do not move the mouse, and type
.CW Could ,
the tag line would now contain:
.P1
/usr/nemo Del Snarf Get | Could Look
.P2
.LP
The button-1 can be also used to drag a window and move it somewhere else, to
adjust its position. This is done by dragging the tiny square shown near the left of
the tag line for the window. Resizing a window is done in the same way, but a single click
with the middle button (button-2) in the square can maximize a window if you need more
space. The shaded boxes near the top-left corner of each column can be used in the
same way, to rearrange the layout for entire columns.
.PP
The middle button (button-2) is used in acme to execute commands. Those shown in the
.ix "acme commands
figure are understood by acme itself. For example, a click with the button-2 on
.CW Del
in our tag line would execute
.CW Del
(an acme command), and delete the window. Any text shown by acme can be used
as a command. For commands acme does not implement,
Plan 9 is asked to execute them.
.PP
Some commands understood by acme are
.CW Del ,
.ix [Del]
to delete the window,
.CW Snarf ,
.ix [Snarf]
to copy the selected text to the clipboard,
.CW Get ,
.ix [Get]
to reread the file shown (and discard your edits), and
.CW Put ,
.ix [Put]
to store your edits back to the file. Another useful command
is
.ix [Exit]
.CW Exit ,
to exit from acme.
For example, to create a new file with some text in it:
.IP 1
Execute
.CW Get
with a button-2 click on that word. You get a new window (that has no file name).
.IP 2
Give a name to the file. Just click (button-1) near the left of the tag line for the new
.ix tag line
window and type the file name where it belongs.
The file name typed on the left of the tag line is used
for acme to identify which file the window is for.
For example, we could type
.CW /usr/nemo/newfile
(you would replace
.CW nemo
with your own user name). 
.IP 3
Point to the body of the window and type what you want.
.IP 4
Execute
.CW Put
in that window. The file (whose name is shown in the tag line) is saved.
.LP
You may notice that the window for
.CW /usr/nemo
is not showing the new file. Acme only does what you command, no more, no
less. You may reload that window using
.CW Get
and the new file should appear.
.PP
The right button (button-3)
is used to look for things. A click with the button on a file name would open
that file in the editor. A click on a word would look for it (i.e., search for it) in
the text shown in the window.
.PP
Keyboard input in acme goes to the window where the pointer is pointing at.
To type at a tag line, you must place the pointer on it.
To type at the body of a
window, you must point to it. This is called “point to
type”. Note that in rio things are different. Input goes to the window where you
did click last. This is called “click to type”.
.ix "point to~type
.ix "click to~type
.PP
Although you can use acme to execute commands, we will be using a
rio window for that in this book, to make it clear when you are executing
commands and to emphasize that doing so has nothing to do with acme.
.PP
But to try it at least once, type
.CW date
.ix [date]
anywhere in acme (e.g., in a tag line, or in the window showing your home
directory. Then execute it (again, by a click with button-2 on it). You will see
how the output of
.CW date
is shown in a new window. The new window will be called
.CW /usr/nemo+Errors .
Acmes creates windows with names terminated in
.CW +Errors
to
display output for commands executed at the directory whose name precedes
the
.CW +Errors .
In this case, to display output for commands executed at
.CW /usr/nemo .
If you do not know what “at”
means in the last sentences, don't worry. Forget about it for a while.
.PP
There is a good description of
.CW Acme
in [.acme.], although perhaps a little bit too detailed for us at this moment.
It may be helpful to read it ignoring what you cannot understand, and get back
to it later as we learn more things.
.BS 2 "Obtaining help
.ix help
.LP
Most systems include their manual on-line, for users to consult. Plan 9 is not
an exception. The Plan 9 manual is available in several forms. From the web,
you can consult
.ix manual
.CW http://plan9.bell-labs.com/sys/man
for a web version of the manual. At Rey Juan Carlos University, we suggest you
use
.CW http://plan9.lsub.org/sys/man
instead, which is our local copy.
.PP
And there is even more help available in the system! The directory
.CW /sys/doc ,
also available at
.CW http://plan9.bell-labs.com/sys/doc ,
contains a copy of most of the papers relevant for the system. We will mention several
of them in this book. And now you know where to find them.
.PP
The manual is divided in sections. Each manual page belongs to a particular
section depending on its topic. For us, it suffices to know that section 1
is for commands, section 8 is for commands not commonly used by users
(i.e., they are intended to administer the system),  and section 2 is for C
functions and libraries. To refer to a manual page,
we use the name of the page followed by the section between parenthesis, as in
.I acme (1).
This page refers to a command, because the section is 1, and the name for the
page (i.e., the name of the command) is
.CW acme .
.PP
From the shell, you can use the
.CW man
.ix [man]
command to access the system manual.
If you don't know how to use it, here is how you can learn to do it.
.P1
; man man
.P2
.LP
Asks the manual to give its own manual page.
.P1
.ps -2
; man man
     MAN(1)                Plan 9 — 4th edition                 MAN(1)

     NAME
          man, lookman, sig - print or find pages of this manual

     SYNOPSIS
          man [ -bnpPStw ] [ section ... ] title ...

          lookman key ...

          sig function ...

     DESCRIPTION
          Man locates and prints pages of this manual named title in
          the specified sections. Title is given in lower case.  Each
         ....
.ps +2
.P2
.LP
As you can see, you can give to
.CW man
the name of the program or library function you are interested in. It displays
a page with useful information. If you are doing this in the shell, you can use
the down arrow key,  “↓”, to page down the output.
To read a manual page found at a particular section, you can type the section
number and the page name after the
.CW man
command, like in
.P1
; man 1 ls
.P2
.LP
If you look at the manual page shown above, you can see several sections.
The
.I synopsis
section of a manual page is a brief indication on how to use the program (or
how to call the function if the page is for a C library). This is useful once you know
what the program does, to avoid re-reading the page again. In
the synopsis for commands, words following the command name are
arguments.
.ix "command argument
The words between
square brackets are optional. They are called options.
.ix "command option
Any option starting with “\f(CW-\fP” represents individual
characters that may be given as
.I flags
.ix "command flag
to change the program behavior. So, in our last example,
.CW 1
and
.CW ls
are
.I options
for
.CW man ,
corresponding to
.I section
and
.I title
in the synopsis of
.I man (1).
.PP
The
.I description
section explains all you need to know to use the program (or the C functions).
It is suggested to
read the manual page for commands the first time you use them. Even if
someone told you how to use the command. This will always help in the future, when
you may need to use the same program in a slightly different way. The same
happens for C functions.
.PP
The
.I source
section tells you where to find the source code for programs and libraries. It
will be of great value for you to read as much source as you can from this system.
Programming is an art, and the authors of this system dominate that art well.
The best way for you to quickly become an artist yourself is to study the works
of the best ones. This is a good opportunity.
.PP
From time to time you will imagine that there must be a system command to do
something, or a library function. To search for it, you may use
.CW lookman ,
.ix [lookman]
as the portion of
.I man (1)
reproduced before shows. Using
.CW lookman
is to the manual what using search engines (e.g.,
Google) is to the Web. You don't know how to use
the manual if you don't know how to search it well.
.PP
Another command that comes with the manual is
.CW sig .
.ix [sig]
It displays the
.I signature ,
i.e., the prototype for a C function documented in section 2 of the manual.
That is very useful to get a quick reminder of  which arguments receives
a system function, and what does it return. For example,
.P1
; sig chdir
	int chdir(char *dirname)
.P2
.LP
When a new command or function appears in this book, it may be of help
for you to take a look at its manual page. For example,
.I intro (1)
is a kind introduction to Plan 9. The manual page
.I rio (1)
describes how to use the window system. The meaning of all the commands in
.CW rio
menus can be found there. In the same way,
.I acme (1)
describes how to use
.CW acme ,
and
.I rc (1)
describes the shell,
.CW rc .
.PP
If some portions of the manual pages seem hard to understand, you might
ignore them for the time being. This may happen for some time while you
learn more about the system, and about operating systems in general.
After completing this course, you should have no problem to understand anything
said in a manual page. Just ignore the obscure parts and try to learn from the
parts you understand. You can always get back to a manual page once you
have the concepts needed to understand what it says.
.BS 2 "Using files
.ix "using files
.LP
Before proceeding to write programs and use the system, it is useful for you
to know how to use the shell to see which files you created, search for them,
rename, and remove them, etc.
.PP
When you open a window,
.CW rio
starts a shell on it. You can type commands
to it, as you already know. For example, to execute
.CW date
.ix [date]
from the shell we can simple type the command name and press return:
.P1
; date
Sat Jul  8 01:13:54 MDT 2006
.P2
.LP
In what follows, we do not remind you to press return after typing a command.
.ix "typing~a command
Now we will use the shell in a window to
play a bit with files. You can list files using
.CW ls :
.ix [ls]
.P1
; ls
bin
lib
tmp
;
.P2
.LP
There is another command, 
.CW lc
(list in columns),
that arranges the output in multiple columns, but is otherwise the same:
.P1
; lc
bin	lib	tmp
;
.P2
.LP
If you want to type several commands in the same line, you can do so by
.ix "compound command
separating them with a semicolon. The only “\f(CW;\fP” we typed here
is the one between
.CW date
and
.CW lc .
The other ones are the shell prompt:
.P1
; date ; lc
Sat Jul  8 01:18:54 MDT 2006
bin	lib	tmp
;
.P2
.LP
Another convenience is that if a command is getting too long, we can type
a backslash and then continue in the next line. When the shell sees the
backslash character, it ignores the start of a new line and pretends that you
typed a space instead of pressing return.
.P1
; date ; \e
;; 	date ; \e
;; 	date
Sat Jul  8 01:19:54 MDT 2006
Sat Jul  8 01:19:54 MDT 2006
Sat Jul  8 01:19:54 MDT 2006
;
.P2
.LP
The double semicolon that we get after typing the backslash and pressing return
is printed by the shell, to prompt for the continuation of the previous line (prompts
might differ in your system).
By the way,
backslash,
.CW \e ,
is called an
.B "escape character"
because it can be used to escape from the special meaning that other
characters have (e.g., to escape from the character that starts a new line).
.PP
We can create a file by using acme, as you know. To create an empty file,
we can use
.CW touch ,
.ix [touch]
and then
.CW lc
to see our outcome.
.P1
; touch hello
; lc
bin	hello	lib	tmp
;
.P2
.LP
The
.CW lc
command was not necessary, of course. But that lets you see the outcome of
executing
.CW touch .
In the following examples, we will be doing the same to show what happens after
executing other commands.
.PP
Here, we gave an
.B argument
to the
.CW touch
command:
.CW hello .
Like functions in C, commands accept arguments to give “parameters” to
them. Command arguments are just strings.
When you type a command line, the shell breaks it into words separated by
white space (spaces and tabs). The first word identifies the command, and
the following ones are the arguments.
.ix "command argument
.PP
We can ask
.CW ls
to give a lot of information about
.CW hello .
But first, lets list just that file.
As you see,
.CW ls
lists the files you give as arguments. Only if you don't supply a file name, all files
are listed.
.P1
; ls hello
hello
;
.P2
.LP
We can see the size of the file we created giving an
.B option
to
.CW ls .
An option is an argument that is used to change the default behavior of
the command. Some options specify certain
.B flags
to adjust what the command does. Options that specify
flags always start with a dash sign, “\f(CW-\fP”.
The option
.CW -s
.ix "[ls] flag~[-s]
.ix "file size
of
.CW ls
can be used to print the size along with the file name:
.P1
; ls -s hello
0 hello
;
.P2
.LP
.CW Touch
created an empty file, therefore its size is zero.
.PP
You will be creating files using acme. Nevertheless, you may want to copy
an important file so that you don't loose it by accidents. We can use
.CW cp
to copy files:
.ix "file copy
.ix [cp]
.P1
; cp hello goodbye
; lc
bin	goodbye	hello	lib	tmp
;
.P2
.LP
We can now get rid of
.CW hello
and remove it, to clean things up.
.ix "file remove"
.ix [rm]
.P1
; rm hello
; lc
bin	goodbye	lib	tmp
;
.P2
.LP
Many commands that accept a file name as an argument also
accept multiple ones.
In this case, they do what they know how to do to all the files given:
.P1
; lc
bin	goodbye	lib	tmp
; touch mary had a little lamb
; lc
a	goodbye	lamb	little	tmp
bin	had	lib	mary
; rm little mary had a lamb
; lc
bin	goodbye	lib	tmp
.P2
.LP
Was
.CW rm
very smart? No. For
.CW rm ,
the names you gave in the command line were just names for files to be removed.
It did just that.
.PP
A related command lets you rename a file. For example, we can rename
.CW goodbye
to
.CW hello
again by using
.CW mv
(move):
.P1
; mv goodbye GoodBye
; lc
GoodBye	bin	lib	tmp
;
.P2
.LP
Let's remove the new file.
.P1
; rm goodbye
rm: goodbye: 'goodbye' file does not exist
.P2
.LP
What? we can see it! What happens is that file names are case sensitive. This
means that
.CW GoodBye ,
.CW goodbye ,
and
.CW GOODBYE
are entirely different names. Because
.CW rm
could not find the file to be removed, it printed a message to tell you. We should
have said
.P1
; rm GoodBye
; lc
bin	lib	tmp
.P2
.LP
In general, when a command can do its job, it prints nothing. If it completes
and does not complaint by printing a diagnostic message, then we know that
.ix "command diagnostic
it could do its job.
.PP
Some times, we may want to remove a file and ignore any errors. For example,
we might want to be sure that there is no file named
.CW goodbye ,
and would not want to see complaints from
.CW rm
when the file does not exist (and therefore cannot be removed). Flag
.CW -f
.ix "[rm] flag~[-f]
for
.CW rm
achieves this effect.
.P1
; rm goodbye
rm: goodbye: 'goodbye' file does not exist
; rm -f goodbye
.P2
.LP
Both command lines achieve the same effect. Only that the second one is
silent.
.BS 2 "Directories
.LP
As it happens in Windows and most other systems, Plan 9 has
.I folders .
But it uses the more venerable name
.B directory
.ix directory
.ix "file name
for that concept. A directory keeps several files together, so that you can
group them. Two files in two different directories are two different files. This seems
natural. It doesn't matter if the files have the same name. If they are at
different directories, they are different.
.LS
.PS
circlerad=.2
movewid=.2
.CW
down
S: circle invis "/"
move
L: [ right
	A: circle invis  "386"
	move
	B: circle invis  "usr"
	move
	C: circle invis  "tmp"
]
move
U: [ right
	A: circle invis  "nemo"
	move
	B: circle invis  "glenda"
	move
	C: circle invis  "mero"
]
line from S to L.A chop
line from S to L.B chop
line from S to L.C chop
line from L.B to U.A chop
line from L.B to U.B chop
line from L.B to U.C chop
line from U.A.s down
F: [ right
	A: circle invis  "bin"
	move
	B: circle invis  "lib"
	move
	C: circle invis  "tmp"
]
line from U.A to F.A chop
line from U.A to F.C chop
.R
reset circlerad, movewid
.PE
.LE F Some files that user Nemo can find in the system.
.LP
Directories may contain other directories. Therefore, files are arranged in a tree.
.ix "file tree
Indeed, directories are also files. A directory is a file that
contains  information about which files are
bounded together in it, but that's a file anyway. This means that the file tree has
only files. Of course, many of them would be directories, and might contain other
files.
.PP
Figure [[!files user nemo!]] shows a part of the file tree in the system, relevant for user Nemo. You
see now that the files
.CW bin ,
.CW lib ,
and
.CW tmp
files that we saw in some of the examples above are kept within a directory called
.CW nemo .
To identify a file, you name the files in the path from the root of the tree (called
.B slash )
to the file itself, separating each name with a slash,
.CW / ,
character. This is called a
.B path .
For example, the path for the file
.CW lib
shown in the figure would be
.CW /usr/nemo/lib .
Note how
.CW /tmp
and
.CW /usr/nemo/tmp
are different files, depite using the name
.CW tmp
in both cases.
.PP
The first directory at the top of the tree, the one which contains everything else,
is called the
.B "root directory"
(guess why?). It is named with a single slash,
.CW / .
.P1
; ls /
386
usr
tmp
.I "...other files omitted...
;
.P2
.LP
That is the only file whose name may have a slash
on it. If we allowed using the slash within a file name, the system would get
confused, because it would not know if the slash is part of a name, or is
separating different file names in a path.
.PP
Typing paths all the time, for each file we use, would be a burden. To make things
easier for you,
each program executing in the system has a directory associated to it. It is said that
the
program is working in that directory. Such directory
is called the
.B "current directory"
for the program, or the
.I working
directory for the program.
.PP
When a
program uses file names that are paths not starting with
.CW / ,
these paths are walked in the tree relative to its current directory.
For example, the shell we have been using in the previous examples had
.CW /usr/nemo
as its current directory. Therefore, all file names we used were relative to
.CW /usr/nemo .
This means that when we used
.CW goodbye ,
we were actually referring to the file
.CW /usr/nemo/goodbye .
Such paths are called
.B "relative paths" .
By the way, paths starting with a slash, i.e., from the root directory, are called
.B "absolute paths" .
.PP
Another important directory is
.CW /usr/nemo ,
it is called the
.I home
.ix "home directory
directory for the user Nemo. The reason for this name is that Nemo's files are kept within
that directory, and because the shell started by the system when Nemo logs in
(the one that usually runs the window system), is using that directory initially as its current
directory. That is the reason why all the (shells running at) windows we open in
.CW rio
have
.CW /usr/nemo
as their initial current directory. What follows is a simple way to know which users have
accounts in the system:
.P1
; lc /usr
esoriano	glenda	nemo	mero	paurea
;
.P2
.LP
There is an special file name for the current directory, a single dot: “\f(CW.\fP".
.ix "dot directory
Therefore, we can do two things to list the current directory in a shell
.P1
; lc
bin	lib	tmp
; lc .
bin	lib	tmp
;
.P2
.LP
Note the dot given as the file to list to the second command. When
.CW ls
or
.CW lc
are not given a directory name to list, they list the current directory. Therefore, both
commands print the same output. Another special name is “\f(CW..\fP”, called
dot-dot. It
.ix "dot-dot directory
refers the parent directory. That is, it walks up one element in the file tree. For example,
.CW /usr/nemo/..
is
.CW /usr ,
and
.CW /usr/nemo/../..
is simply
.CW / .
.PP
To change the current directory in the shell, we can use the
.CW cd
.ix [cd]
.ix "change current directory
(change dir) command. If we give no argument to
.CW cd ,
it changes to our home directory. To know our current working directory, the
command
.CW pwd
(print working directory)
.ix [pwd]
.ix "print current directory
can be used. Let's move around and see where we are:
.P1
; cd
; pwd
/usr/nemo
; cd / ; pwd
/
; cd usr/nemo/lib ; pwd
/usr/nemo/lib
; cd ../.. ; pwd
/usr
.P2
.LP
This command does nothing. Can you say why?
.P1
; cd .
;
.P2
.LP
Now we know which one is the current working directory for commands we
execute. But,
which one would be the working directory for a command executed using
.CW acme ?
It depends. When you execute a command in
.CW acme ,
its working directory is set to be that shown in the window (or containing the
file shown in the window). So, the command we executed time ago in
the
.CW acme
window for
.CW /usr/nemo
had
.CW /usr/nemo
as its working directory. If we execute a command in the window for a file
.CW /usr/nemo/newfile ,
its working directory would be also
.CW /usr/nemo .
.LP
Directories can be created with
.CW mkdir
(make directory),
.ix [mkdir]
and because they are files, they can be also removed with
.CW rm .
.ix [rm]
Although,
because it may be dangerous,
.CW rm
refuses to remove a directory that is not empty.
.P1
; cd
; mkdir dir
; lc
bin	dir	lib	tmp
; rm dir
; lc
bin	lib	tmp
;
.P2
.LP
The command
.CW mv ,
.ix [mv]
that we saw before, can move files from one directory to another. Hence its name.
When the source and destination files are within the same directory,
.CW mv
simply renames the file (i.e., changes the name for the file in the directory).
.ix "file rename
.ix "file move
.P1
; touch a
; lc
a	bin	lib	tmp
; mkdir dir
; lc
a	bin	dir	lib	tmp
; mv a dir/b
; lc
bin	dir	lib	tmp
; lc dir
b
;
.P2
.LP
Now we have a problem,
.CW ls
can be used to list a lot of information about a file. For example, flag
.CW -m
.ix "[ls] flag~[-m]
.ix "file who~last~modified
asks
.CW ls
to print the name of the user who last modified a file, along with the file name.
Suppose we want to know who was the last user who created or removed a file
at
.CW dir .
We might do this, but the output is not what we could perhaps expect:
.P1
; ls -m dir
[nemo] dir/b
;
.P2
.LP
The output refers to file
.CW b ,
and not to
.CW dir ,
which was the file we were interested in. The problem is that
.CW ls ,
when given a directory name, lists its contents. Option
.CW -d
.ix "[ls] flag~[-d]
asks
.CW ls
not to list the contents, but the precise file we named:
.P1
; ls -md dir
[nemo] dir
.P2
.LP
Like other commands,
.CW cp
.ix [cp]
works with more than one file at a time. It
accepts more than one (source) file name to copy to the destination file name.
In this case it is clear that the destination must be a directory, because it would
make no sense to copy multiple files to a single one. This copies the two
files named to the current directory:
.P1
; cp /LICENSE /NOTICE .
; lc
LICENSE	NOTICE	bin	dir	lib	tmp
.P2
.BS 2 "Files and data
.ix data
.LP
Like in most other systems,
in Plan 9, files contain bytes. Plan 9 does not know (nor cares) about
.ix "file content
what is in a file. It just provides the means to let you create, remove, read,
and write files. If you store a notice in a file, it is you who knows that it is a notice.
For Plan 9, that is just bytes. We can use
.CW cat
(catenate)
.ix [cat]
.ix "file display
to display what is in a file:
.P1
; cat /NOTICE
Copyright © 2002 Lucent Technologies Inc.
All Rights Reserved
;
.P2
.LP
This program reads the files you name and prints their contents. Of course, if
you name just one, it prints just its content. If you
.CW cat
a very long file in a Plan 9 terminal, beware that you might have to press the down
arrow key in your keyboard to let the terminal scroll down.
.PP
What is stored at
.CW /NOTICE ?
We can see a dump of the bytes kept within that file using the program
.CW xd
.ix [xd]
.ix "file hexadecimal dump
(hexadecimal dump). This program reads a file and writes its contents so that
it is easy for us to read. Option
.CW -b
asks
.CW xd
to print the contents as a series of bytes:
.P1
; xd -b /NOTICE
0000000  43 6f 70 79 72 69 67 68 74 20 c2 a9 20 32 30 30
0000010  32 20 4c 75 63 65 6e 74 20 54 65 63 68 6e 6f 6c
0000020  6f 67 69 65 73 20 49 6e 63 2e 0a 41 6c 6c 20 52
0000030  69 67 68 74 73 20 52 65 73 65 72 76 65 64 0a
000003f 
;
.P2
.LP
The first column in the program output shows the 
offset (the position)
.ix offset
in the file where the bytes printed on the right can be found. This offset is
in hexadecimal (we write hexadecimal numbers starting with
.I 0x ,
as done in C). For example, the byte at position 0x10, which is the byte at position
16 (decimal) has the value 0x32. This is the 17th byte! The first byte is at position zero,
which makes arithmetic simpler when dealing with offsets.
.PP
So, why does
.CW cat
display text? It's all numbers.
The program
.CW cat
reads bytes, and writes them to its output. Its output is the terminal in this case,
and the terminal assumes that everything it shows is just text. The text is represented
using a binary codification known as UTF-8. This format encodes
.ix UTF8
.ix rune
.I runes
(i.e, characters, kanjis, and other glyphs) as a sequence of bytes.
For most of the characters we
use, UTF-8 uses exactly the same format used by ASCII (another
standard that codifies each character using a
single byte). The program implementing the terminal (the window) decodes UTF-8
to obtain the runes to display, and renders them on the screen.
.PP
We can ask
.CW xd
to do the same for the file contents. Adding option
.CW -c ,
the program prints the character for each byte when feasible:
.P1
; xd -b -c /NOTICE
0000000  43 6f 70 79 72 69 67 68 74 20 c2 a9 20 32 30 30
      0   C  o  p  y  r  i  g  h  t    c2 a9     2  0  0
0000010  32 20 4c 75 63 65 6e 74 20 54 65 63 68 6e 6f 6c
     10   2     L  u  c  e  n  t     T  e  c  h  n  o  l
0000020  6f 67 69 65 73 20 49 6e 63 2e 0a 41 6c 6c 20 52
     20   o  g  i  e  s     I  n  c  . \en  A  l  l     R
0000030  69 67 68 74 73 20 52 65 73 65 72 76 65 64 0a
     30   i  g  h  t  s     R  e  s  e  r  v  e  d \en
000003f 
.P2
.LP
Here we see how the value 0x43 represents the character “C”.
If you look after the text
.CW Copyright ,
you see 0xc2 0xa9, which is the UTF-8 representation for the “©” sign. This
program does not know and all it can do is print the byte values.
.PP
Another interesting thing is shown near the end of each line in the file. After the text
in the first line, we see a “\f(CW\en\fP”. That is a byte with value 0x0a.
The same happens at the end of the second
line (the last line in the file). The syntax “\f(CW\en\fP”
is used to represent
.ix "new-line character
.I control
characters, i.e., characters not to be printed as text. The character
.CW \en
is just a 0x0a
byte stored in the file, but
.CW xd
printed it as
.CW \en
to let us recognize it. This syntax is understood by many programs, like for
example the C compiler, which admits it to embed control characters in strings
(like in \f(CW"hello\en"\fP).
.PP
Control characters have
.ix "control character
meaning for many programs. That is way they
.I seem
to do things (but of course they do not!). For example, “\f(CW\en\fP” is the
.I "new-line
character. It can be generated using the keyboard by pressing the
.I Return
key. When printed, it causes the current line to terminate and the
following text will be printed starting at the left of the next line.
.PP
If you compare the output of
.CW xd
and the output of
.CW cat
you will see how each one of the two lines in
.CW /NOTICE
terminates with an
.I "end of line
character that is precisely
.CW \en .
That is the convention in Plan 9 (and UNIX). The new line character terminates a line
.ix UNIX
only because programs in Plan 9 (and UNIX) follow the convention that lines terminate
with a
.CW \en
character. The terminal shows a new line when it finds a
.CW \en ,
programs that read files a line at a time decide that they get a line when a
.CW \en
character is found, etc. It is just a convention.
.PP
Windows (and its predecessor MSDOS)
use a different format to
encode text lines, and terminates each line with two characters: “\f(CW\er\en\fP”
(or
.I carriage-return ,
.ix "carriage-return character
and
.I new-line ).
This comes from the times when computers used a tele-typewriter (tty) machine for
console output. The former character,
.CW \er ,
makes the carriage in the typewriter
return to its left position. We have to admit, there are no
typewriters anymore. But the character
.CW \er
makes the following text appear on the left of the line. The
.CW \en
character advances the carriage (sic) to the
next line. That is why
.CW \en
is also known as the
.I line-feed
character.
.ix "line-feed character
A consequence is that if you display in Plan 9 a Windows text file, you will
see one little control character at the end of each line:
.P1
; cat windowstext
This is one line␣
and this is another␣
;
.P2
.LP
That is the
.CW \er .
Going the other way around, and displaying in Windows
a text typed in Plan 9, may produce this output
.P1
This is one line
                and this is another
.P2
.LP
because Windows misses the carriage-return character.
.PP
Now that we can see the actual contents of a file, there is another interesting
thing to note. There is no EOF (end of file) character! Such thing is an invention
.ix EOF
.ix "end of~file
of some programming languages. For Plan 9, the file terminates right after the last
byte that has been stored on it.
.PP
Another interesting control character is the
.I tabulator ,
generated pressing the
.I Tab
key in the keyboard.
It is used in text files to cause editors and terminals to advance the
text following the tabulator character to the next
.I tab-stop .
On typewriters (sorry once more), the carriage could be quickly advanced
to particular columns (called tab-stops) by hitting a
.I Tab
.ix [Tab]
key. This control character achieves the same effect. Of course, there is no
carriage any more and
.I Tab
advances to, say, the next column that is a multiple of 8 (column 8, 16, etc.). This
value is called the
.I tab-width .
.ix "tab wdith" .
The file
.CW scores
contains several tabs.
.P1
; cat scores
Real Madrid	1
Barcelona	0
; xd -c scores
0000000   R  e  a  l     M  a  d  r  i  d \et  1 \en  B  a
0000010   r  c  e  l  o  n  a \et  0 \en
000001a 
.P2
.LP
Note how in the output for
.CW cat ,
the terminal tabulates the scores to form a column after the names. The number
.CW 0
is shown right below the number
.CW 1 .
However, the output from
.CW xd
reveals that there are no spaces after
.CW Madrid
and 
.CW Barcelona .
Following each name, there is a single
.CW \et
character, which is the notation for
.I Tab .
In general,
.CW \et
is used to tabulate data and to indent source code. The appearance of the
output text depends on the tab width used by the editor or the terminal
(which was 8 characters in our case). The net effect is that it is a bad idea to
mix spaces and tabs to indent code or tabulate data. Depending on the editor,
a single tab may displace the following text 8, 4, 2, or any other number of
characters (it depends on where the editor considers the tab stop to be).
.PP
The point is that characters like
.CW \en ,
.CW \er ,
and
.CW \et
are control characters, with special meaning, just because there are programs
that use them to represent actions and not to represent literal text. Table
[[!control characters!]] shows some usual control characters and their meaning.
.LS
.TS
center box;
cfB cfB cfB cfB
_ _ _ _
l lfCW lfI l.
Byte value	Character	Keyboard	Description
04		control-d	end of transmission (EOT)
08	\eb	Backspace	remove previous character
09	\et	Tab	horizontal tabulation
0a	\en	Return	line feed
0d	\er		carriage return
1b		Esc	escape
.TE
.LE T Some control characters understood by most systems and programs.
.PP
The table shows the usual escape syntax (a backslash and a character) used by
most programs to represent control characters (including the C compiler), and how
to generate the characters using the keyboard. Not all the control characters are
shown and not all the cells in the table contain information. We included just what
you should know to avoid discomfort while using the system.
.PP
To summarize,
.ix "data meaning~of
files contain just data that has no meaning per-se. Only programs and users
give meaning to data. This is what you could see here.
.BS 2 "Permissions
.LP
Each file in Plan 9 can be secured to provide some privacy and restrict what
.ix privacy
.ix "file permissions
people can do with the file. The security mechanism to control access to files
is called an
.B "access control list" .
This is like the list given to security guards to let them know who are allowed
to get into a party and what are they allowed to do inside.
In this case, the system  is the security guard, and it
keeps an access control list (or ACL) for each file. To be more precise, the program
that keeps the files, i.e., the file server, keeps an ACL for each file.
.PP
The  ACL for a file describes if the file can be read, can be written, and can be executed.
Who can be allowed by the ACL to do such things? The file server keeps a list
of user names. You had to give your user name to log into the system and access
your files in the file server.
Depending on your user name, you may be allowed or not to read, write, and
execute a particular file. It depends on what the file's ACL says.
.PP
Because it would be
too inconvenient to list these permissions for all the users in the ACL for each file,
a more compact representation is used. Each file belongs to a user, the one who
created it. And each user is entitled to a
.ix "file ownership
.B group
of users. The ACL lists read, write, and execute permissions for the owner of the file,
for any other user in the group of users, and for the rest of the world. That is just
nine permissions instead of a potentially very long list.
.PP
In the file server, each user account can be used as a group. This means that
.ix account
your user name is also a group name. The group that contains just you as the
only member. This is the output of
.CW ls
when called to print long listing for a file. It list permissions and ownership for the file:
.P1
; cd
; ls -l lib/profile
--rwxrwxr-x M 19 nemo nemo 1024 May 30 16:31 lib/profile
;
.P2
.LP
You see a user name listed twice. The first name is the owner for
the file. It is
.CW nemo
in this case. The second name is the user group for the file, which is also
.CW nemo
in this case. This group contains a single user,
.CW nemo .
.PP
The initial “\f(CW-\fP” printed by
.CW ls
indicates that the file is a not a directory.
For directories, a “\f(CWd\fP” would be printed instead. The following characters
show the ACL for the file, i.e., its permissions.
.PP
There are three groups of
.CW rwx
permissions, each one determining if the file can be read (\f(CWr\fP),
written (\f(CWw\fP) and executed (\f(CWx\fP). The first
.CW rwx
group refers to the owner
of the file. For example, if \f(CWr\fP is set on it, the owner of the file can read the file.
As you see for
.CW lib/profile ,
.CW nemo
(its owner) can read, write, and execute this file.
.PP
The second
.CW rwx
group determines permissions applied to any other user who belongs to the group
for the file. In this case the group is also
.CW nemo ,
which contains just this user. The last
.CW rwx
group sets permissions applied to any other user. For example,
.CW esoriano
can read and execute this file, but he cannot write it. The permissions for him
(not the owner, and not in the group) are
.CW r-x ,
which mean this.
.PP
Because it does not makes sense to grant the owner of a file less permissions
than to others, the file owner has a particular permission if it is enabled for
the owner, the group, or for the others. The same applies for members of the
group. They have permission when either
permissions for the group or permissions for others
grant access.
.PP
In general, read permission means permission to
.I access
the file to consult its contents. Write permission means permission to modify the
file. This includes not just writing the file, but also truncating it. Execute permission
means the right to ask a Plan 9 kernel to execute the file. Any file with execution
.ix "executable file
permission is an executable file in Plan 9.
.PP
For directories, the meaning of the permissions is different. For a directory, read
.ix "directory permissions
permission means permission to
.I list
the directory. Because the directory has to be read to list its contents. Write
permission means permission to
.I create
and
.I remove
files in the directory. These operations require writing the directory contents.
Execute permission means the right to enter, i.e., to
.CW cd
into it.
.PP
When there is a project involving several users, it is convenient to create a directory
for the files of the project and to create a group of users for that project. All files
created in that directory will be entitled to the group of users that the directory
is entitled to. For example, this directory keeps documents for a project called
.I "Plan B" :
.P1
; ls -ld docs
d-rwxrwxr-x M 19 nemo planb 0 Jul  9 21:28 docs
.P2
.LP
If we create a file in that directory, permissions get reasonable:
.P1
; cd docs
; touch memo
; ls -l memo
--rw-rw-r-- M 19 nemo planb 0 Jul  9 21:30 memo
.P2
.LP
The group for the new file is
.CW planb ,
because the group for the directory was that one. The file has write permission
for users in the group because that was the case for the directory.
.PP
To modify permissions, the
.CW chmod
(change mode)
.ix [chmod]
.ix "change permissions
command can be used. Its first argument grants or revocates permissions. The
following arguments are files where to perform this permission change. For example,
to grant execution permission for file
.CW program ,
you may execute
.P1
; chmod +x program
.P2
.LP
To remove write permission for an important file that is not to be overwritten, you may
.P1
; chmod -w file
.P2
.LP
The
.CW +
sign grants permission. The
.CW -
sign removes it. The characters following this sign indicate which permissions to
grant or remove. For example,
.CW +rx
grants both read and execution permissions.
.PP
If you want to change the permissions just for the owner, or just for the group, or
just for anyone else, you may specify this before the
.CW +
or
.CW -
sign. For example,
.P1
; chmod g+r docs
.P2
.LP
grants read permission to users in the group. Permissions for the owner and for
the rest of the world remain unaffected. In the same way
.CW u+r
would grant read permission for the owner, and
.CW o+r
would do the same for others.
.PP
In some cases, for example, in C programs, you are going to have to use an
integer to indicate file permissions. There are three permissions repeated three
times, once for the user, once for the group, and once for others. This is codified
as nine bits. Using a number in octal base, which has three bits for each digit,
it is very simple to write a number for a given permission set.
.PP
For example, consider the ACL
.CW rwxr-xr-x .
That is three bits for the user, three for the group, and three for others. A bit is
set to grant permission and clear to deny it. For the user, the bits would be 111,
for the group, they would be 101, and for the others they would also be 101.
.PP
You know that 111 (binary) is 7 decimal. It is the same in octal. You also know that
101 (binary) is 5 decimal. It is the same in octal. Therefore, an integer value representing
this ACL would be 0755 (octal). We use the same format used by C to write
.ix "octal mode
.ix "permissions in~octal
octal numbers, by writing an initial 0 before the number. Figure [[!octal permissions!]]
depicts the process. Thus, the command
.P1
; chmod 755 afile
.P2
.LP
would leave
.CW afile
with
.CW rwxr-xr-x
permissions.
.LS
.PS
boxwid=.2
boxht=.2
down
.CW
[ right
	[ down; box invis   "r" ; arrow down ]
	[  down; box invis   "w" ; arrow down ]
	[  down; box invis   "x" ; arrow down ]
	box invis  
	[  down; box invis   "r" ; arrow down ]
	[  down; box invis   "-" ; arrow down ]
	[  down; box invis   "x" ; arrow down ]
	box invis  
	[  down; box invis   "r" ; arrow down ]
	[  down; box invis   "-" ; arrow down ]
	[  down; box invis   "x" ; arrow down ]
]
.R
move .1
B: [ right
   U: [
	[ down; box invis   "1"  ]
	[  down; box invis   "1"  ]
	[  down; box invis   "1" ]
     ]
	box invis  
  G: [
	[  down; box invis   "1" ]
	[  down; box invis   "0"  ]
	[  down; box invis   "1"  ]
    ]
	box invis  
 O: [
	[  down; box invis   "1"  ]
	[  down; box invis   "0" ]
	[  down; box invis   "1"  ]
    ]
]
move .1
arrow from B.U.s down ; box invis   "7"
arrow from B.G.s down ; box invis   "5"
arrow from B.O.s  down ; box invis   "5"
reset boxwid, boxht
.PE
.LE F Specifying permissions as integers using octal numbers.
.BS 2 "Writing a C program in Plan 9
.ix "C program
.LP
Consider the traditional “take me to your leader!” programⁱ, that we show here.
We typed it into a file named
.CW take.c .
.ix [take.c]
.ix "C program
.ix "C language
When we show a program that is stored in a particular file, the file name
is shown in a little box before the file contents.
.FS
ⁱ Because we talk about Plan 9, this program is more appropriate than the
one you are thinking on. If you don't know why, you did not use Internet to
discover why this system has this name.
.FE
.so progs/take.c.ms
.LP
This program is just text stored in a file. To execute it, we must compile it
.ix "compiler
.ix "library
and then link the program with whatever libraries are necessary (in this case,
the C library). There is one command for each task:
.P1
; 8c take.c	# compile it
; 8l take.8	# link the resulting object
;
.P2
.ix [8c]
.ix [8l]
.ix Intel
.LP
As you see, the shell
ignores text following the
.CW #
sign. That is the line-comment character for
.ix "shell comment~character
.CW rc .
That is usual in most shells found in other systems, like UNIX.
.ix UNIX
The C compiler for Intel architectures is
.CW 8c
(80x86 compiler)
and
.CW 8l
is the linker (In Plan9,
.CW 8l
is called a
.I loader ,
.ix loader
because it prepares the way for loading the resulting program into memory).
Object files generated by
.CW 8c
use the extension
.CW .8 ,
to make it clear that the object is for an Intel (it reminds of 8086). The binary file
produced by linking the object file(s) and the libraries implied
.ix "binary file
.ix [8.out]
is named
.CW 8.out ,
when using
.CW 8l .
This binary has execute permission and can be executed.
.PP
In Plan 9 there are many C compilers. One for each architecture where
.ix cross-compiler
the system runs. And, as it could be expected, each compiler has been compiled
for all the architectures where the system runs.
For example, for the Arm, the compiler is
.CW 5c
and the linker
.CW 5l .
.ix [5c]
.ix [5l]
.ix arm
We have these programs available for all the architectures (e.g., PCs, and Arms).
To compile for one architecture you only have to use the compiler that generates
code for it. But you can compile from any other architecture because the compiler
itself is available for all of them.
.PP
For the Arm, the files generated by the compiler and the linker would be
.CW take.5
and
.CW 5.out .
This makes it easy to compile a single program for execution at different
platforms in the same directory. We still know which file is for which architecture.
Now you may have the pleasure of executing your first hand-made Plan 9 program
.P1
; 8.out
take me to your leader!
;
.P2
.LP
The Plan 9 C dialect is not ANSI (nor ISO) C. It is a variant implemented by Ken
Thompson. One of the authors of UNIX. It has a few differences with respect to
.ix "Ken Thompson
the C language you can use in other system. You already noticed some. Most
programs include just two files,
.CW u.h ,
which contains machine and system definitions, and
.CW libc.h ,
.ix [u.h]
.ix [libc.h]
.ix "standard includes
.ix "header files
which contains most of the things you will need. The header files include
a hint for the linker that is included in the object file. For example, this is
the first line in the file
.CW libc.h :
.P1
#pragma	lib	"libc.a"
.P2
.LP
The linker uses this
.ix [pragma]
to automatically link against the libraries with headers included by your programs.
There is no need to supply a long list of library names in the command line for
.CW 8l !.
.PP
There are several flags that may be given to the compiler to make it more
.ix "compiler flags
strict regarding the source code. It is very sensible to use them always. The
.I 8c (1)
manual page details them, and we hope you just take them as a custom:
.P1
; 8c -FVw take.c
.P2
.LP
The binary file generated by
.CW 8l
is
.CW 8.out ,
by default. But it may be more convenient to give a better name to this file.
This can be done with the
.CW -o
.ix "[8l] flag~[-o]
option for the linker. If we use a file name like
.CW take ,
the file should be kept at a directory where it is clear
which architecture it has been compiled for. For example, for PCs, binaries are
kept at
.CW /386/bin
or at
.CW /usr/nemo/bin/386
for the user
.CW nemo .
This is what is done when the program is
.I installed
for people to use. People enjoy typing just the program name.
.PP
But otherwise, it is a custom to generate a binary file with a
name that states clearly the architecture it requires. Think that you may be
compiling a program today while using a PC as a terminal. Tomorrow morning
you might be doing the same on an Alpha. You wouldn't like to get confused.
.PP
The tradition to name the binary file  is to use the name
.CW 8.out
if the directory contains the source code for just one program, or a name like
.CW 8.take
if there are multiple programs that can be compiled in the same directory. This is
our case.
.PP
In this text we will always compile for the same architecture, an Intel PC,
unless said otherwise, and generate the binary in the directory where we
are working. For example, for our little program, this would be the command used
to generate its binary:
.P1
; 8l -o 8.take take.8
.P2
.LP
For the first few programs, we will explicitly say how we compiled them. Later,
we start assuming that you remember that the binary for a file named
.CW take.c
was compiled and linked using
.P1
; 8c -FVw take.c
; 8l -o 8.take take.8
;
.P2
.LP
and the resulting executable is at
.CW 8.take .
.PP
There is an excellent paper for learning how to use the Plan 9 C compiler
[.how use plan 9 compiler.]. It is a good thing to read if you want to learn more details
not described here about how to use the compiler.
.BS 2 "The Operating System and your programs
.LP
So far so good. But, what is the actual relation between the system and your
programs? How can you understand what happens? You will see that things
are simpler than you did image. But let's revisit what happens to your
program after you write it,  before bringing the operating system in the play.
We can use some commands to do this. By now, ignore what you cannot understand.
.P1
; ls -l take.c take.8 8.take
--rwxr-xr-x M 19 nemo nemo 36280 Jul  2 18:46 8.take
--rw-r--r-- M 19 nemo nemo   388 Jul  2 18:46 take.8
--rw-r--r-- M 19 nemo nemo   110 Jul  2 18:46 take.c
.P2
.LP
The command
.CW ls
tells us that
.CW take.c
has 110 bytes in it. That is the text of our program. After
.ix "program text
.CW 8c
compiled it, the resulting object file
.ix "object file
.CW take.8
has just 388 bytes in it. The contents are machine instructions for our
program plus initial values for our variables (e.g., the string printed) and
some other information. If we take this object file, and give it to
.CW 8l
to link it against the C library and produce the binary file
.ix "binary file
.CW 8.take ,
we get a file with 36.280 bytes on it.
.PP
Let's try to gather more information about these files. The command
.CW nm
(name list)
.ix [nm]
displays the names of
.I symbols
.ix "program symbols
(i.e., procedure names, variables) that are contained or required by our
object and executable files.
.P1
; nm take.8
         U exits
         T main
         U print
; nm 8.take
            ... more output...
            1131 T exits
            1020 T main
            118d T print
            ... more output...
; 
.P2
.LP
It seems that
.CW take.8
contains a procedure
called
.CW main .
We call text to binary program code, and
.CW nm
prints a
.CW T
before names for symbols that are text and are contained in the object file.
Besides, our object file requires at least two other procedures,
.CW exits ,
.ix [exits]
and
.CW print
.ix [print]
to build a complete binary program. We know this because
.CW nm
prints
.CW U
(undefined, but required) before names for required things.
.ix "undefined symbol
.PP
If we look at the output for the executable file, you will notice that
the three procedures are in there. Furthermore, they now have addresses!
The code for
.CW exits
is at address 1131 (hexadecimal), and so on.
The code that is now linked to our object file comes from the C library.
It was included because we included the library's header
.CW libc.h
in our program and called some functions found in that library. The linker,
.CW 8l ,
knew where to find that code.
.PP
But there is more code that is used by our program and is not contained
in the binary file. When our program calls
.CW print ,
.ix "library function"
this function will write bytes to the output (e.g., the window). But the procedure
that knows how to write is not in our program, nor is in the C library. This procedure
is within the operating system kernel. A procedure provided by the system is
known as a
.B "system call" ,
calling such procedure is known as making a system call.
.LS
.PS 
.CW
down
.ps -2
U: [ right; P: box wid 3.5 ht .75 ; move .25 ; Q: box wid 1.5 ht .75 "main() { ...}" ]
move .4
K: box wid 5.25 ht .7 "write() { ...}"
C: [
right
box invis wid 1.2 ht .5 "main() { ...} " 
arrow right 1 "\fRprocedure\fP" "\fRcall\fP"
F: box invis wid 1.3 ht .5  "print() { ...} "
] at U.P
.R
arrow from C.F.s down .5 "system call" ljust
box invis ht .3 "Your program" with .sw at U.P.nw
box invis ht .3 "Other program" with .sw at U.Q.nw
box invis ht .3 "System kernel" with .sw at K.nw
.ps +2
.PE
.LE F System calls, user programs, and the system kernel.
.PP
Figure [[!system calls!]]  depicts two different programs, e.g., the one you executed before
and another one, and the system kernel. Those programs are executing, not
just files sitting on a disk. Your program contains
.I all
the code it needs to execute, including portions of the C library. Your
.CW main
procedure calls
.CW print ,
with a local procedure call. The code for print was taken from the C library and
linked into your program by
.CW 8l .
To perform its job,
.CW print
calls another procedure,
.CW write ,
.ix [write]
that is contained within the operating system kernel. That is a system call. As you
can see in the figure, the other program might perform its own system calls as well.
.PP
In general, you don't mind if a particular function is a system call or is defined in
the standard system library (the C library). Many functions that are part of the
interface of the system are not actual system calls (i.e., are not implemented
within the kernel), but library functions. For example, the manual page for
.I read (2)
gives multiple functions that can be used to read and write a file. However, only one, or
maybe a few, are actual system calls. The others are implemented within the C
library in terms of the real system call(s). Going from one version of the system
to another, we may find that an old system call is now a library function, and
vice-versa. What matters is that the function is part of the programmer's
interface for a system provided
abstraction. Indeed, in what follows, we may refer to functions within the C library
as system calls. Be warned. In any case, the entire section 2 of the manual
describes the functions available.
.PP
As a remark, programmer's interfaces are usually called APIs, for
Application Programmer's Interface.
.BS 2 "Where are the files?
.LP
If you remember, we said that your files are not kept in the machine you use to
execute Plan 9 commands and programs. Plan 9 calls the machine you use, a
.I terminal ,
.ix terminal
and the machine where the files are kept, a
.I "file server" .
.ix "file server
The Plan 9 that runs at your terminal lets you use the files that you have
available at other places in the network, and there can be many of them. For
simplicity, we assume that all your files are stored at a single machine behaving
as the file server.
.PP
How does this work? What we said about how a program performs a system call to
the kernel, to write into a file, is still true. But there was something missing in the
description we made in the last section.  To do the write you requested, your Plan 9
kernel is likely to need to talk to another machine. Most probably, your terminal does
.I not
have the file, and must get in touch with the file server to ask him to write the file.
.PP
Figure [[!remote procedure call!]] shows the steps involved for doing the same
.CW print
shown in the last section. This time, it shows how the file server comes into play, and
it shows only your program. Other programs running at your terminal would follow
a similar path.
.LS
.PS 4.5cm
.CW
.ps -3
down
boxht=.75
boxwid=2.6
U: box wid boxwid*6/7
move .5
T: box 
F: box  wid 1.5 at T.e + 2.5,0
Prog: [ right
	M: box  invis wid .2 ht .6   "main(){" rjust  "...   "  rjust "}     " rjust
	move .8
	P:  box  invis wid .2 ht .6  "print(){" ljust "...    " ljust  "}      " ljust 
	line -> from M.e + 0,.05 to P.w + 0,.05 "\fR1. call\fP" above
	line <- from M.e - 0,.05 to P.w - 0,.05 "\fR6. return\fP" below
] at U
Call: [
	box  invis wid 1 ht .6   "write(){" ljust  "...   "  ljust "}     " ljust
] with .w at T
line -> from Prog.P.s +.05,0 to Call.n +.05,0 "\fR 2. system call\fP" ljust
line <- from  Prog.P.s - .05,0 to Call.n - .05,0 "\fR5. return \fP" rjust
Wr: [
	box  invis wid .2 ht .6   "write(){" ljust  "...   "  ljust "}     " ljust
] with .w at F.w + .2,0
line  -> dotted from  Call.e +0,0.05 to Wr.w +0,0.05 "\fR 3. message: write!\fP" above
line  <- dotted from  Call.e -0,0.05 to Wr.w -0,0.05 "\fR 4. message: done!\fP" below
box invis wid 1 ht .2 "\fBYour program\fP" with .sw at U.nw
box invis wid 1 ht .2 "\fBYour terminal's kernel\fP" with .sw at T.nw
box invis wid 1 ht .2 "\fBFile server\fP" with .sw at F.nw
.ps +3
.PE
.LE F Your system kernel makes a remote procedure call to write a file in the file server.
.IP 1
Your program makes a
.I "procedure call" ,
to the function
.CW print
in the C library.
.IP 2
The function makes a
.I "system call"
to the kernel in your machine. This is similar to a procedure call, but calls a procedure
that is implemented by your kernel and shared among all the programs in your terminal.
Because the kernel protects itself to prevent your program from calling arbitrary
.ix "privileged mode
.ix kernel
.ix "software interrupt
procedures in the kernel, a software interrupt is the mechanism used to perform this call.
This is called a
.B trap ,
and is mostly irrelevant for you now.
.IP 3
The code for the
.CW write
function (the system call) in the kernel, must send a message through the network to
the machine that keeps the file, to the file server. This message contains a request
to perform the write operation and all the information needed to perform it, e.g.,
all the values and data you supplied as parameters for the write.
.IP 4
The remote machine, the file server, performs the operation and replies sending a
message through the network back to your terminal. The message reports if the
operation was completed or not, and contains any output result for the operation
performed, e.g., the number of bytes that could be written into the file.
.IP 5
Your kernel does some bookkeeping and returns to your system call
the result of the operation (as reported by the other machine).
.IP 6
The library function returns to your program when everything was printed.
.LP
Steps 3 and 4 are called a
.B "remote procedure call" .
This is not as complex as it sounds, but it is not a procedure call either. A remote
procedure call is a call made by one program to another that is at a different
place in the network. Because your processor cannot call procedures kept
at different machines, what the system does is to send a message with a request
to do something, and to receive a reply back with any result of interest.
.BS 2 "The Shell, commands, binaries, and system calls
.ix shell
.ix "command interpreter
.ix "command
.ix "command line
.ix "binary file
.ix "system call
.LP
It is important to know how these elements come into play. As you know, the
operating system provides the implementation of several functions, known
as system calls. These functions provide the interface for the abstract data
types invented by the system, to make it easier to use the computer.
.PP
In general, the only way to use the system is to write a program that makes
system calls. However, there are many programs already compiled in your system,
ready to run. To provide you some mean to run them, another program is provided:
the shell. When you type a command name at the shell prompt, the shell searches
for a file with the same name located at a directory that, by convention, keeps
the executable files for the system. If the shell finds such file, it asks the system to
execute it.
.LS
.PS
.ps -2
down
[
right
xterm(0.5)
spline <-> dotted right  then down .5 then right .1 then up .5 then right "read" "command line" 
circle rad .3 "shell"
spline -> dotted right  then down .5 then right .1 then up .5 then right  "execute" "/bin/ls"
circle rad .3  "ls"
]
move -.1
box wid 5 "system kernel"
.ps +2
.PE
.LE F Executing commands.
.PP
Figure [[!executing commands!]] shows what happens when you type
.CW ls
at the shell prompt.
First, the shell reads your command line. It looks for a file named
.CW /bin/ls ,
and because there is such file, the shell executes it. To read the command
line, and to execute the corresponding file for the command you typed,
the shell uses system calls. Only the operating system knows what it means
to “read” and to “execute” a file. Remember, the hardware knows nothing about
that! 
.PP
The consequence of your command request is that the program contained in
.CW /bin/ls
is loaded into memory by the operating system and gets executed as a
new program. Note that if you create a new executable file, you have created
a new command. All you have to do to run it is to give its (file) name to the shell.
.PP
When you run a window system, things are similar. The only difference is that
.ix "window system
the window system must read input from both the mouse and the keyboard and
writes at a graphics terminal instead of at a text display. Of course, when
the window system creates (i.e., “invents”) a new window, it has to ask the
system to run a shell on it.
.BS 2 "The Operating System and the hardware
.ix hardware
.LP
As you can imagine now, most of the time, the operating system is not even
executing. Usually, it is your code the one running in the processor. At least, until
the point in time when your program makes a system call. At that point, the
operating system code takes control (because its code starts executing) and
performs your request.
.ix "program execution
.PP
However, the hardware may also require attention from the operating system.
As you know from computer architecture courses, this is done by means of
hardware interrupts. When data arrives from the network, or you hit a keyboard key,
.ix "hardware interrupt
.ix "hardware device
the hardware device interrupts the processor. What happens later
is that the interrupt handler runs after the hardware saves the processor state.
.PP
The interrupt handlers are kept within the operating system kernel. The kernel
contains the code used to operate each particular device. That is called a
.B "device driver" .
Device drivers use I/O instructions to operate the devices, and the devices interrupt
the processor to request the attention of their drivers. Thus, while your program
is executing, a device might interrupt the processor. The hardware saves some
state (registers mostly) and the operating system starts executing to attend
the interrupt. Many times, when the interrupt has been serviced, the operating
system will return from the interruption and your code would be running again.
.PP
You can think that the kernel is a library but not just for your programs, also for
things needed to operate the hardware. You make system calls to ask the
system to do things. The hardware issues interrupts for that purpose. And most 
of the time, the system is idle sitting in memory, until some one makes a call.
.SH
Problems
.IP 1
Open a system shell, execute
.CW ip/ping
to determine if all of the machines at the network 213.128.4.0
are alive or not. To do this, you have to run these 254 commands:
.P1
; ip/ping -n 1 213.128.4.1
; ip/ping -n 1 213.128.4.2
  ...
; ip/ping -n 1 213.128.4.254
.P2
.IP
The option
.CW -n
with argument
.CW 1
tells ping to send just one probe and not 64, which would be its default.
.IP 2
Do the same using this shell command line:
.P1
 ; for (m in `{seq 1 254}) { ip/ping 213.128.4.$m }
.P2
.IP
This line is not black magic. You are quite capable of doing things like this,
provided you pass this course.
.IP 3
Start the system shell in all the operating systems where you have accounts. If
you know of a machine running an unknown system where you do not have an account,
ask for one and try to complete this exercise there as well.
.IP 4
Does your TV set remote control have its own operating system?
Why does your mobile phone include an operating system? Where is the
shell in your phone?
.IP 5
Explain this:
.P1
; lc .
bin	lib	tmp
; ls.
ls.: '/bin/ls.' file does not exist
.P2
.IP 6
How many users do exist in your Plan 9 system?
.IP 7
What happens if you do this in your home directory? Explain why.
.P1
; touch a
; mv a a
.P2
.IP 8
What would happen when you run this? Try it and explain.
.P1
; mkdir dir
; touch dir/a dir/b
; rm dir
; mv dir /tmp
.P2
.IP 9
And what if you do this? Try it and explain.
.P1
; mkdir dir dir/b
; cd dir/b
; rm ../b
; pwd
.P2
.ds CH
.bp 
 
