.so tmacs
.BC 11 "Threads and Channels
.BS 2 "Threads
.PP
Processes are independent flows of control known to Plan 9. The kernel creates
them, it terminates them, and it
decides when to move one process out of the processor and when to put
a process back on it. Because of the unpredictability of context switches
between processes, they must synchronize using locks, rendezvous, sleep/wakeup, or
any other means if they want to share memory without race conditions.
.PP
.ix "thread library
But there is an alternative. The
.I thread (2)
library provides an abstraction similar to a process, called a
.B thread .
.ix "control flow
.ix "process
A thread is just a flow of control within a process. In the same way that
Plan 9 multiplexes the flow of control of a single processor among multiple processes, the
thread library multiplexes the flow of control of a single process among multiple
threads.
.LS
.PS 5i
down
A: [ right
	box invis "Process 1:"
	move .1
	P1: [down
	T1: [ right
		Q0: line .5 "Thread 1" above
		line .5 dashed
		Q2: line .5 "run" above
		line .3 dashed "rdy." above
	]
	move .3
	T2: [ right
		line .5 dashed "Thread 2" below
		Q1: line .5
		line .5 dashed "ready" below
		Q3: line .3 "run "below
	]
	arrow dotted from T1.Q0.e to T2.Q1.w
	arrow dotted from T2.Q1.e to T1.Q2.w
	arrow dotted from T1.Q2.e to T2.Q3.w
	Q1: T2.Q3.e
	]
	line 2 dashed "ready" above
	Q1: P1.Q1
	PX: [ down
	[ right
		line .5 dashed "ready" above
		"..." ljust
	]
	move .3
	X: [ right
		Q2: line .5 "run" below
		"..." ljust
	]
	Q2: X.Q2.w
	]
	Q2: PX.Q2
]
move
B: [right
	box invis "Process 2:"
	move .1
	line 2 dashed "ready" above
	Q2: line 1.7 "run" above
	line .6 dashed "ready" above
	"..." ljust
]
arrow dotted from A.Q1 to B.Q2.w "context switch" ljust
arrow dotted from B.Q2.e to A.Q2
.PE
.LE F Threads are flows of control implemented by a process.
.PP
.ix "scheduling
.ix "context switch
.ix "[Ready]
Figure [[!threads flows!]] shows an example. If there are two processes,
Plan 9 may put process 1 to run at the processor for some time. During this
time, process 2 would be ready to run. After the time passes, there is a context
switch and Plan 9 puts process 2 to run and leaves process 1 as ready to run.
In this figure, the process 1 has two threads in it. Each thread thinks that it is
a single, independent, flow of control (like all processes think).
However, both threads are
sharing the time in the processor that was given to process 1.
Looking at the process 1 in the figure shows that,
while this process is running, the time is used to execute two different flows of control,
one for each thread.
.PP
.ix kernel
For Plan 9, there are no threads. The kernel puts process 1 to run and what process
1 does with the processor is up to it. Therefore, when the process 1 is moved out
of the processor in the context switch, both threads cease running. In fact, it is
the single flow of control for process 1 which ceased running.
.PP
Why should you ever want to use threads?
Unlike for processes, that are moved out of the processor when the system pleases, a
thread may
.I not
be moved out of the processor (preempted) unless you call functions of the thread library
to synchronize with other threads. What does this mean? There will be no context
switch between threads unless you allow it. There will be no races! You are free
to touch any shared data structure as you please, and nobody would interrupt in
the middle of a critical operation, provoking a race.
.PP
.ix "shared counter
This is the same program used as an example in the beginning of the last chapter.
It increments a shared counter using two different flows of control. This time,
we use two threads to increment the counter. As any other program using the
thread library, it includes
.CW thread.h ,
that contains the definitions for thread data types and functions. Also, note that
the program does
.I not
have a
.CW main
function. That function is provided by the thread library. It creates a single
thread within the process that starts executing the function
.CW threadmain .
This is the function that you are expected to provide as your entry point.
.so progs/tincr.c.ms
.ix [tincr.c]
.LP
The program calls
.CW threadcreate
.ix [threadcreate]
to create a new thread (the second in this process!) that starts executing the
function
.CW incrthread .
After this call, there are two independent flows of control. One is executing
.CW threadmain ,
.ix [threadmain]
after the call to
.CW threadcreate .
The other is starting to execute
.CW incrthread .
The second parameter given to
.CW threadcreate
is passed by the library as the only argument for the main procedure for the thread.
Because
.CW incrthread
does not require any argument, we pass a
.CW nil
pointer.
The third argument to
.CW threadcreate
.ix "thread stack
.ix "process stack
is the thread's stack size. The stack for a thread is allocated as a byte array in
the data segment, like other dynamic variables, it lives in the heap (within the
data segment).
.PP
It is interesting to see that threads call
.CW threadexits
.ix "[threadexits]
to terminate, instead of calling
.CW exits .
.ix [exits]
Calling
.CW exits
would terminate the entire process (the only flow of control provided by Plan 9).
When all the threads in the process have terminated their main functions, or
called
.CW threadexits ,
the thread library will call
.CW exits
to terminate the entire process. The exit status for the whole process is that
given as a parameter to the last thread to exit, which is a reasonable behavior.
By the way, there is a more radical function for exiting that
terminates
.I all
the threads in the process, it is called
.CW threadexitsall
.ix [threadexitsall]
and is used in the same way.
.PP
And is this is what we get for using threads instead of processes. The program will
always produce this output (although the order of
.CW prints
may vary)
.P1
; !!8.tincr
cnt is 2
cnt is 4
.P2
.LP
And there are no races! When a thread starts executing, it will continue executing
until it calls
.CW threadexits .
We did not call any function of the thread library, and there is no magic. There is
no way the thread could suffer a context switch in a bad moment. The program is
safe, although it does not use even a single lock.
Of course, if a thread loops for a long time without giving other threads the
chance of running, the poor other threads will wait a very long time until they
run. But this is seldom the case.
.PP
What if we modify the program as we did with the one with processes? You may think
that using a
.CW sleep
may lead to a context switch, and expose a possible race condition. Although this is
not the case, let's try it.
.so progs/tincr2.c.ms
.ix [trinc.c]
.LP
Executions for this program yield the same result we expect.
.P1
; 8.tincr2
cnt is 2
cnt is 4
.P2
.LP
No race was exposed. Indeed, no thread was ever moved out of the processor
by the call to
.CW sleep .
If the first thread was executing
.CW incrthread ,
the call to sleep moved the whole process out of the processor, as shown in figure
[[!thread moves out!]]. When later, the process
was put back into the running state, the first thread was still the one running.
Remember, the underlying Plan 9 kernel knows
.I nothing
about threads. The call to
.CW sleep
.ix [sleep]
puts the
process to sleep. Of course, the thread went to sleep as a result, like
.I all
other threads in the process. But in any case, you did not call any function from
the thread library, and there was
.I no
.ix "thread switch
.ix "context switch
context switch between threads. For the thread library, it seems that the first
thread is still executing in very much the same way that if you never called
.CW sleep .
.LS
.PS 4i
.ps -1
arrowhead=7
down
A: [ right
	box invis "Our process:" rjust
	move .1
	P1: [down
	T1: [ right
		line .5 "1st thread" above ; line .5
	]
	move .3
	T2: [ right
		line .5 dashed "2nd thread" above ; line .5 dashed "ready" above
	]
	]
	Q1: P1.T1.e
	line .2 dotted "sleep" above ljust
	line 1.3 "ready" above
	P1: [down
	T1: [ right
		line .5 "run" above
		"..." ljust
	]
	move .3
	T2: [ right
		line .5 dashed "ready" above
		"..." ljust
	]
	]
	Q2: P1.T1.w
]
move
B: [right
	box invis "Another process:" rjust
	move .1
	line 1.1 dashed "ready" above
	Q2: line 1.3 "run" above
	line .6 dashed "ready" above
	"..." ljust
]
arrow dotted from A.Q1 to B.Q2.w "context switch because of \f(CWsleep\fP"
arrow dotted from B.Q2.e to A.Q2
.ps +1
.PE
.LE F A call to \f(CWsleep\fP from a thread moves the entire process out of the processor.
.PP
Only when the first thread calls
.CW threadexits ,
the second thread gets a chance to run. The thread library releases the resources
for the exiting thread, and switches to the other thread in the process (that was
ready to run). This thread runs to completion, like its sibling, and after calling
.CW threadexits ,
the whole process is terminated by the thread library (by a call to
.CW exits ),
because there are no more threads in this process.
.PP
How can a thread abandon voluntarily the processor? E.g., to favor other threads.
The function
.CW yield
.ix "[yield]
in the thread library makes a context switch between threads. Any other thread
ready to run will be put to execute. Of course, if no more threads are ready to run
.CW yield
will return immediately to the calling thread. Therefore, this change to
.CW incrthread
.I creates
a bug in our program.
.P1
for (i = 0; i < 2; i++){
	loc = cnt;
	loc++;
	yield();
	cnt = loc;
}
.P2
.LP
The call to
.CW yield
.I forces
a context switch at the worst moment. But note that, unlike when using processes,
this time you
.I "had to"
ask for the context switch.
.BS 2 "Thread names
.PP
.ix "thread name"
Like processes, threads have identifiers. The thread library assigns a unique
integer to each thread, known as its
.B "thread id" .
Do not confuse the thread id with the PID for the process where the thread is running.
The former is known by the thread library, and unknown to the underlying Plan 9.
The next program creates several threads, that print their own ids. The call to
.CW threadid
.ix [threadid]
.ix "thread identifier
returns the identifier of the thread that calls the function.
.PP
The function
.CW threadcreate
returns the identifier for the thread it created, and the program prints this value
as well, to let you see how things match. In general,
.CW threadid
is used when a thread wants to know its own identifier. However, to know the ids
for some threads created, it suffices to record the return values when
.CW threadcreate
is called. The program prints the PID along with the thread ids, to let you clearly
see the difference.
.so progs/tid.c.ms
.ix [tid.c]
.ix [PID]
.LP
This is the output from the program.
.P1
; 8.tid
thread id= 1	pid=3904
	created thread 2
	created thread 3
thread id= 2	pid=3904
thread id= 3	pid=3904
.P2
.LP
What would happen if we implement
.CW cnt
from the last chapter, but
using threads? This program used two flow of controls. One was kept incrementing
a counter. The other one tried always to decrement the counter, but not below zero.
The next program creates two threads. One runs this function.
.P1
void
incr(void* arg)
{
	int*	cp = arg;

	threadsetname("incrthread");
	for(;;){
		*cp = *cp + 1;
		print("cnt %d\en", *cp);
	}
	threadexits(nil);
}
.P2
.LP
The other runs this instead.
.P1
void
decr(void* arg)
{
	int*	cp = arg;

	threadsetname("decrthread");
	for(;;){
		if (*cp > 0)
			*cp = *cp - 1;
		print("cnt %d\en", *cp);
	}
	threadexits(nil);
}
.P2
.LP
This time, we pass an an argument for both threads a pointer to the shared
counter.
.ix "thread argument
.so progs/tcnt.c.ms
.ix [tcnt.c]
.LP
.ix starvation
One of the threads will never run!. It will starve.
When we executed the program, the thread
incrementing the counter was the lucky one. It started running, and because it
does not call any synchronization function from the thread library, it will
.I never
leave the processor in favor of the other thread.
.P1
; 8.tcnt
cnt 1
cnt 2
cnt 3
cnt 4
cnt 5
cnt 6
.I "...and so on ad nauseum."
.P2
.LP
.ix debugger
.ix [acid]
We can double check by using the debugger. First, let's locate the process that is running our program.
.P1
; ps   | grep 8.tcnt
nemo  4546    0:00   0:00      120K Pwrite   8.tcnt
.P2
.LP
.ix "thread debugging
Now we can
run
.CW acid
on the process 4546.
.P1
; acid -l thread 4546
/proc/4546/text:386 plan 9 executable

/sys/lib/acid/port
/sys/lib/acid/thread
/sys/lib/acid/386
acid:
.P2
.LP
The option
.CW "-l thread"
loads functions into acid for debugging threaded programs. For example, the function
.CW threads
lists the threads in the process.
.P1
.ps -1
acid: !!threads()
p=(Proc)0x169b8    pid 4546  Running
  t=(Thread)0x19a68    Running    tcnt.c:14 incr [incrthread]
  t=(Thread)0x1bb28    Ready      ?file?:0 {}
acid:
.ps +1
.P2
.LP
.ix "[acid] [threads] function
There are two threads. Reasonable, because the main thread called
.CW threadexits
by this time. Both threads are listed (a line each) after one line describing the
process where the threads run. This process has pid
.CW 4546 ,
as we knew, and is running.
The lucky running thread is executing at line 14 of
.CW tcnt.c ,
in the function named
.CW incr .
The debugger does even show a name for the thread:
.CW incrthread .
That is what the calls to
.CW threadsetname
.ix [threadsetname]
in our program were for. This function assigns a (string) name to the calling
thread, for debugging. This string can be also obtained using
.CW threadgetname ,
.ix [threadgetname]
for example, to print diagnostics with the name of the thread issuing them.
.PP
The second thread is ready to run, but it did not even touch the processor. In fact,
it did not have time to initialize some of its data, and the debugger gets confused
regarding which file, line number, and thread name correspond to the second thread.
.PP
We are going to modify the program a little bit, by calling
.CW yield
on each thread to let the other run. For example, this is the new
.CW incrthread .
The other one is changed in a similar way.
.P1
void
incr(void* arg)
{
	int*	cp = arg;

	threadsetname("incrthread");
	for(;;){
		*cp = *cp + 1;
		print("cnt %d\en", *cp);
		yield();
	}
	threadexits(nil);
}
.P2
.LP
This is what results from the change. Each thread yields to the other one, and
both onces execute making turns. There will always be one pass in the
.CW for
and then a context switch, forced by
.CW yield .
.P1
; 8.tcnt
cnt 1
cnt 0
cnt 1
.I ...
.P2
.LP
Another debugger function defined when called with
.CW "-l thread
knows how to print the stacks for all threads in the process. Now that both
threads had a chance to run, you can see how the debugger clearly identifies
one thread as
.CW incrthread ,
and the other one as
.CW decrthread .
.P1
.ps -2
; ps | grep 8.tcnt
nemo           4571    0:00   0:00      120K Pwrite   8.tcnt
; acid -l thread 4571
/proc/4571/text:386 plan 9 executable

/sys/lib/acid/port
/sys/lib/acid/thread
/sys/lib/acid/386
acid: !!stacks()
p=(Proc)0x169b8    pid 4571  Running
 t=(Thread)0x19a68    Ready      /usr/nemo/tcnt.c:15 incr [incrthread]
    yield()+0x5 /sys/src/libthread/sched.c:186
    incr(arg=0xd010)+0x39 /usr/nemo/tcnt.c:15
    launcher386(arg=0xd010,f=0x1020)+0x10 /sys/src/libthread/386.c:10
    0xfefefefe ?file?:0

 t=(Thread)0x1bb28    Running    /usr/nemo/tcnt.c:30 decr [decrthread]
    pwrite()+0x7 /sys/src/libc/9syscall/pwrite.s:5
    \fI...\fP
    print(fmt=0x1136a)+0x24 /sys/src/libc/fmt/print.c:13
    decr(arg=0xd010)+0x3b /usr/nemo/tcnt.c:30
    launcher386(arg=0xd010,f=0x105f)+0x10 /sys/src/libthread/386.c:10
    0xfefefefe ?file?:0
.ps +2
.P2
.LP
This is a very useful tool to debug programs using the thread library. It makes debugging
as easy as when using processes. The debugger reports that
.CW incrthread
was executing
.CW yield ,
and
.CW decrthread
was executing its call to
.CW print ,
.ix "thread stack dump
by the time the stack dump was made. Note how the process was running, but
only one of the threads is running. The other one is ready to run, because it did
yield.
.BS 2 "Channels
.LP
Synchronizing several processes was very easy when we used pipes. While
programming, we could forget all about race conditions. Each process was making
its job, using its own data, and both processes could still work together to do
something useful.
.PP
Fortunately, there is an abstraction provided by the thread library that is very
similar. It is called a
.B channel .
.ix "communication channel
.ix "process communication
A channel is an unidirectional communication artifact. One thread can send
data through one end of the channel, and another thread may receive data
at the other end. Because channels are meant to send data of a particular type,
a channel delivers messages of a given size, decided when the channel is created.
This is not a restriction. If data of different sizes must be sent through a channel,
you can always send a pointer to it.
.PP
To create a channel, call
.CW chancreate
.P1
; sig chancreate
	Channel* chancreate(int elsize, int nel)
.P2
.LP
and specify with the first argument the size for the data type being sent through it.
The second parameter specifies how many messages may be buffered inside the
channel (i.e., the buffer size for the channel). To send and receive messages,
the functions
.CW send
.ix [send]
and
.CW recv
.ix [recv]
provide the primary interface.
.P1
; sig send recv
	int send(Channel *c, void *v)
	int recv(Channel *c, void *v)
.P2
.LP
Before any further discussion, let's see an example. In the previous chapter we
implemented a program for the bounded-buffer problem. This is another solution
to the same problem, using threads and channels.
.so progs/tpc.c.ms
.LP
The channel is created to send messages with the size of a
.CW char* ,
and with enough buffering for
.CW Nmsgs
messages. Thus, the channel is our bounded buffer.
.ix [chancreate]
.P1
bufc = chancreate(sizeof(char*), Nmsgs);
.P2
.LP
The program will never destroy the channel, ever.
Should we want to destroy it, we might call
.ix [chanfree]
.P1
chanfree(bufc);
.P2
.LP
But that can only be done when the channel is no longer needed, after the last
consumer completes its job.
The consumer calls
.P1
recv(bufc, &msg);
.P2
to receive a message from the channel. Once a message is received,
the message is stored by
.CW recv
at the address given as the second argument. That is,
.CW recv
receives a
.CW char*
and stores it at
.CW &msg .
After having received the message, the consumer prints it and tries to receive
another one.
.PP
The producer, on the other hand, concocts a message and calls
.P1
send(bufc, &msg);
.P2
.LP
This call sends through the channel the message pointed to by
.CW &msg ,
with the size of a
.CW char* .
That is,
.CW send
sends the (pointer) value in
.CW msg
through the channel.
.PP
.ix "channel buffering
If producers start first and put messages in the channel, they will block as soon
as the buffering in the channel fills up (similar to what would happen in a pipe).
If the consumers start first and try to get messages from the channel, they will
block if the buffer in the channel has no messages. This is the behavior of
.CW send
and
.CW recv
when the channel has some buffering.
.PP
It may be illustrative for you to compare this program with
.CW pc.c ,
the version without using channels that we made in the last chapter. Both programs
achieve the same effect. This one does
.I not
use even a single lock, nor sleep/wakeup. It does not have any race either. Each
thread uses its own data, like when you connect multiple processes using pipes.
Race conditions are dealt with by avoiding them in a natural way.
.PP
.ix "ping-pong
The next program does a ping-pong
between two threads. Each one sends an integer value to the other, which increments
the number before sending it back to the former (see figure [[!ping pong threads!]]).
The program uses channels with no buffering.
.so progs/pong.c.ms
.ix [pong.c]
.LP
Each channel is created to send messages with the size of an
.CW int ,
and with no buffering.
.ix "unbuffered channel
.P1
pingc = chancreate(sizeof(int), 0);
pongc = chancreate(sizeof(int), 0);
.P2
.LP
The
.CW ping
thread calls
.P1
recv(pingc, &msg);
.P2
to receive a message from the channel
.CW pingc .
The message is stored by
.CW recv
at the address given as the second argument. That is,
.CW recv
receives an integer and stores it at
.CW &msg .
Once the integer has arrived,
.CW ping
increments it and calls
.P1
send(pongc, &msg);
.P2
.LP
to send through
.CW pongc
the message pointed to by
.CW &msg .
That is, to send the integer
.CW msg
(because the channel was created to send messages with the size of a integer).
.PP
Initially, both threads would block at
.CW recv ,
because nobody is sending anything yet. To kick off the ping-pong, the main
thread sends an initial zero to the
.CW pingc
channel. See figure [[!ping pong!]].
.LS
.PS
circlerad=.4
circle "ping"
[ down
  [ right ; arrow ; box wid 1 ht .2 "pongc" ; arrow ]
  move .1
  P: [ right ; arrow <-  ; C: box wid 1 ht .2 "pingc" ; arrow <- ]
  C: P.C.e
]
circle "pong"
spline <- from last [].C - 0,.05 right  then down then right;
line "\f(CW0\fP" below
circle "main"
.PE
.LE F A ping pong with threads and channels.
.PP
The output from the program is a nice ping pong. Note that context
switches between threads happen when we call
.CW send
and
.CW recv .
Any synchronization function from the thread library is likely to produce
a context switch.
.P1
; 8.out
1
	2
3
	4
.I ...
.P2
.LP
A channel with no buffering is producing a rendezvous between the thread
sending and the one receiving. A
.CW recv
from such a channel will block, until there is something to receive. Because the
channel has no buffering, there can be
.I nothing
to receive until another thread calls
.CW send
for the same channel. In the same way, a
.CW send
to a channel with no buffering is going to block if nobody is receiving on it.
It will block until another thread calls
.CW recv
and the message can be sent.
.PP
.ix "thread synchronization
We could exploit this in our program to synchronize more tightly both threads
and use just one channel. This is useful to better understand how channels can
be used, but (perhaps arguably) it leads to a more obscure, yet compact, program.
.PP
Suppose that initially
.CW ping
sends a message to
.CW pong
and
.CW pong
receives it.
The former calls
.CW send
and
the later calls
.CW recv.
If
.CW ping
calls
.CW send
first, it
is going to block until
.CW pong
calls
.CW recv
on the channel (which had no buffering). And vice-versa.
.PP
Now comes the point.
When
.CW ping
completes its
.CW send
it is for sure that
.CW pong
has completed its
.CW recv .
Or we could say that when
.CW pong
completes its
.CW recv
it is certain that
.CW ping
completed its
.CW send.
Therefore, the same channel can be used again to send a number back. This
time,
.CW pong
calls
.CW send
and
.CW ping
calls
.CW recv .
.ix rendezvous
Again, both calls will rendezvous, the first call made will block and wait for the other.
There is no doubt regarding which
.CW recv
is going to receive for which
.CW send.
So, the code would work along these lines.
.P1
ping() {
\fR(1)\fP	send(c, &msg);	// \fIsends to \fP\fR(3)\fP
\fR(2)\fP	recv(c, &msg);	// \fIreceives from \fP\fR(4)\fP
}
pong() {
\fR(3)\fP	recv(c, &msg);	// \fIreceives from \fP\fR(1)\fP
\fR(4)\fP	send(c, &msg);	// \fIsends to \fP\fR(2)\fP
}
.P2
.LP
But both threads look fairly similar. In fact, considering their loops, they
look the same. Receive something, increment it, send it back. Only that
while one is receiving the other one is sending. Therefore, we could use the
same code for both threads, like the next program does.
.so progs/pong2.c.ms
.LP
Initially, both threads (now running
.CW pingpongthread )
will block at
.CW recv .
They are ready for their match. When the main thread sends an initial zero
through the only channel, the thread that called
.CW recv
first will be the one receiving the message. Which one does receive it? We
do not care. If both players run the same code, why should we care?
.PP
At this point things work as discussed above. The thread that received the initial
zero is now after its
.CW recv ,
preparing to send
.CW 1
to the other. The other thread is still waiting inside
.CW recv .
The
.CW send
from the former will deliver the number to the later. And both calls will meet
in time because of the lack of buffering in the channel. Later, the very same
channel will be free to send another number back.
.PP
The program uses
.CW sendul
and
.CW recvul ,
instead of
.CW send
and
.CW recv .
.ix [sendul]
.ix [recvul]
These functions are convenience routines that send and receive an
unsigned integer
value. They are very convenient when the channel is used to send integers.
There are other similar functions, called
.CW sendp
and
.CW recvp
that send and receive pointers instead.
.ix [sendp]
.ix [recvp]
.P1
; sig sendul recvul sendp recvp
	int sendul(Channel *c, ulong v)
	ulong recvul(Channel *c)
	int sendp(Channel *c, void *v)
	void* recvp(Channel *c)
.P2
.LP
They are exactly like
.CW send
and
.CW recv
for messages of the size of integers and messages of the size of pointers,
respectively.
.BS 2 "I/O in threaded programs
.LP
.ix "thread I/O
Performing I/O from a thread that shares the process with other threads
is usually a bad idea. It is not harmful to call
.CW print
and other I/O functions for debugging and similar purposes. But it may be harmful
to the program to
read from the console or to read from or write to a network connection.
.PP
.ix "airport application
.ix "airport panels
Consider the airport panels application from the last chapter.
We are going to make an implementation using threads.
The application must convey a message typed at a console to the multiple
panels in the airport. This implies several different activities:
.IP 1
Reading messages from the console.
.IP 2
Broadcasting each new message to all the panels.
.IP 3
Updating each panel
.LP
Using the thread library, we can program the application in a very modular way.
Each activity may be performed by a different thread, without even thinking on what
the other threads would do. To make all the threads work together, we can use
channels.
.PP
For example, a
.CW consread
thread may be in charge of reading one line at a time from the console, and send
each new message read through a channel to a
.CW bcast
thread.
.ix broadcast
.P1
void
consreadthread(void*)
{
	Biobuf	bin;
	char*	ln;

	threadsetname("consread");
	Binit(&bin, 0, OREAD);
	while (ln = Brdstr(&bin, '\en', 0))
		sendp(bcastc, ln);
	sendp(bcastc, nil);
	Bterm(&bin);
	threadexits(nil);
}
.P2
.LP
The code can now be almost as simple as the definition for the thread's task.
We have used
.CW Brdstr
.ix [Brdstr]
.ix "buffered I/O
from
.I bio (2)
to read a line at a time from standard input. Unline
.CW Brdline ,
.ix [Brdline]
this function returns a C string allocated with
.CW malloc
that contains the line read. The final argument
.CW 0
asks
.CW Brdstr
not to remove the trailing
.CW \en
in the string, which is just what we need. To make things terminate cleanly,
upon EOF from standard input, we send a nil message as an indication to exit.
.PP
Another thread,
.CW bcast ,
will be only concerned about broadcasting messages to panels. When it
receives a new message, it sends one copy of the message to each panel. To do this,
the program may use an array of channels,
.CW panelc ,
with one channel per panel.
.P1
.ps -1
void
bcastthread(void*)
{
	char*	msg;
	int	i;

	threadsetname("bcast");
	do {
		msg = recvp(bcastc);
		for (i = 0; i < Npanels; i++)
			if (msg != nil)
				sendp(panelc[i], strdup(msg));
			else
				sendp(panelc[i], nil);
		free(msg);
	} while(msg != nil);
	threadexits(nil);
}
.ps +1
.P2
.LP
.ix "program termination
The nil message meaning exiting is also broadcasted, to indicate to all panels
that the program is terminating.
.PP
A
.CW panel
thread (one for each panel) can simply read new messages from the panel's channel
and update a panel. It needs to know which channel to read messages from,
and which panel to write to. A structure is declared to pass such information
as an argument.
.P1
typedef struct PArg PArg;
struct PArg {
	Channel* c;	// to get new messages from
	int	fd;	// to the panel's file.
};
.P2
.LP
Using it, this can be its implementation. Like before, a nil message is an indication
to exit.
.P1
void
panelthread(void* a)
{
	PArg*	arg = a;
	char*	msg;

	threadsetname("panel");
	while(msg = recvp(arg->c)){
		write(arg->fd, msg, strlen(msg));
		free(msg);
	}
	threadexits(nil);
}
.P2
.LP
All threads were simple to implement, and the structure for the program follows
easily from the problem being solved. We did not have to worry about races since
each thread is only using its own data.
.PP
There is one problem, though. If a thread calls
.CW Brdstr ,
to read from the console, it is going to block all the threads. It blocks the entire
process. The same happens while updating the slow panels using a
.CW write
to their files. This problem is easy to solve. Instead of creating a thread
to run
.CW consreadthread ,
and one more thread to run each
.CW panelthread
function, we can create processes. The function
.CW proccreate
.ix [proccreate]
.ix "process creation
creates a new process (using
.CW rfork )
with a single thread in it. Otherwise, it works like
.CW threadcreate .
.ix [threadcreate]
.P1
.ps -1
; sig proccreate
  int proccreate(void (*fn)(void*), void *arg, uint stack)
.ps +1
.P2
.LP
The processes created using this function share the data segment among them.
Internally,
.CW proccreate
calls
.ix [rfork]
.CW rfork(RFPROC|RFMEM|RFNOWAIT) ,
because the thread library keeps its data structures in the data segment, which
must be shared. In a few cases, you may want to supply a few extra flags to
.CW rfork ,
when creating a process. The call
.CW procrfork
is like
.CW proccreate ,
but accepts a final
.CW flags
argument that is or-ed to the ones shown above.
.P1
.ps -1
; sig procrfork
  int procrfork(void (*fn)(void*), void *arg, uint stack, int rforkflag)
.ps +1
.P2
.LP
But beware, the thread library uses
.CW rendezvous
in its implementation. Supplying a
.CW RFREND
.ix [RFREND]
flag to
.CW procrfork
will break the program.
Using
.CW proccreate ,
we can make our program without blocking all the threads while doing I/O.
.so progs/tticker.c.ms
.LP
.ix "process structure
The process structure is shown in figure [[!process structure threads airport!]],
which represents each separate process with a dashed box and each thread with a circle.
This time, we ended with a single thread within each process. But usually, a
central process has multiple threads to do the actual work, and there are some other
processes created just for doing I/O without blocking all the threads.
.LS
.PS 5i
.ps -2
.CW
circlerad=.35
C: circle "consread" 
arrow
box wid 1 ht .2 "bcastc"
arrow
B: circle "bcast" 
arrow
X: [ down
	P0: [ right
	box wid 1 ht .2 "panelc[0]"
	arrow
	C0: circle "panel" 
	]
	C0: P0.C0
box invis "..."
	P1: [ right
	box wid 1 ht .2 "panelc[i]"
	arrow
	C1: circle "panel" 
	]
	C1: P1.C1
box invis "..."
	P2: [ right
	box wid 1 ht .2 "panelc[n]"
	arrow
	C2: circle "panel" 
	]
	C2: P2.C2
]
arrow from B.ne to X.P0.w
arrow from B.se to X.P2.w
box dashed wid .9 ht .9 at C
box dashed wid .9 ht .9 at B
box dashed wid .9 ht .9 at X.C0
box dashed wid .9 ht .9 at X.C1
box dashed wid .9 ht .9 at X.C2
.R
.ps +2
.PE
.LE F Process structure for the airport panels program, using threads.
.PP
There is another benefit that arises from using threads that communicate
through channels. This time, we do not need to optimize our program to maintain
the
.CW write
for updating the panel outside of the critical region, to permit all panels to be updated
simultaneously. All panels are updated simultaneously in a natural way, because each
one uses its own process and does not lock any shared data structure. There are
locks in this program, but they are hidden deep under the implementation of
.CW send
and
.CW recv .
.BS 2 "Many to one communication
.PP
.ix "multiway communication
The program that we built is nice. But it would be nicer to display in the panels,
along with each message, the current time and the temperature outside of
the airport building. For example, if the operator types the message
.P1
AA flight 847 delayed
.P2
.LP
we would like panels to show the message
.P1
AA flight 847 delayed (17:45 32ºC)
.P2
.LP
We could modify the code for the
.CW panel
thread to do it. But it would not be very appropriate. A panel thread is expected to write
messages to a panel, and to write them verbatim. The same happens to other
threads in this program. They do a very precise job and are modular building blocks
for building a program.
Instead, it seems better to put another thread between
.CW consread
and
.CW bcast ,
to decorate messages with the time and the temperature. We call this new thread
.CW decorator .
.PP
There is still the problem of updating the panels when either the time changes
(the minute, indeed) or the temperature changes. It would not be reasonable to
display just the time and temperature for the moment when the operator typed
the message shown.
.PP
As a result, the new
.CW decorator
thread must have three different inputs. It receives messages, but it must also
receive time and temperature updates. That leaves us with
the problem of how do we generate the two additional input streams. To follow
our modular design, two new threads will be in charge of providing them. The
resulting process design is that shown in figure [[!enhanced airport application!]].
And the code of the whole program may look like this.
.LS
.PS 5i
.ps -4
.CW
circlerad=.35
I: [ down
	I0: [ right
	C: circle "timer" 
	arrow .3
	box wid .5 ht .2 "timerc"
	]
	move .3
	I1: [ right
	C: circle "consread" 
	arrow .3
	box wid .5 ht .2 "consc"
	]
	move .3
	I2: [ right
	C: circle "temp" 
	arrow .3
	box wid .5 ht .2 "tempc"
	]
	box dashed wid .9 ht .9 at I0.C
	box dashed wid .9 ht .9 at I1.C
	box dashed wid .9 ht .9 at I2.C
]
I0: I.I0
I2: I.I2
arrow
D: circle "decorator"
arrow .3
MP: box wid .7 ht .2 "bcastc"
arrow .3
B: circle "bcast" 
arrow
X: [ down
	P0: [ right
	box  ht .2 "panelc[0]"
	arrow .3
	C0: circle "panel" 
	]
	C0: P0.C0
box invis "..."
	P1: [ right
	box  ht .2 "panelc[i]"
	arrow .3
	C1: circle "panel" 
	]
	C1: P1.C1
box invis "..."
	P2: [ right
	box  ht .2 "panelc[n]"
	arrow .3
	C2: circle "panel" 
	]
	C2: P2.C2
]
arrow from I0.e to D.nw
arrow from I2.e to D.sw
arrow from B.ne to X.P0.w
arrow from B.se to X.P2.w
box dashed wid 3 ht 1 at MP
box dashed wid .9 ht .9 at X.C0
box dashed wid .9 ht .9 at X.C1
box dashed wid .9 ht .9 at X.C2
.R
.ps +4
.PE
.LE F Process structure for the enhanced airport application.
.so progs/etticker.c.ms
.ix [etticker.c]
.LP
Sending time updates is simple. A
.CW timer
.ix "timer thread
thread can send a message each minute, with a string representing the time
to be shown in the panels. It receives as a parameter the channel where to send
events to.
.P1
.ps -1
void
timerthread(void* a)
{
	Channel* c = a;
	ulong	now;
	Tm*	tm;
	char	msg[10];
	for(;;){
		now = time(nil);
		tm = localtime(now);
		snprint(msg, 10, "%d:%d",tm->hour, tm->min);
		sendp(c, strdup(msg));
		sleep(60 * 1000);
	}
}
.ps +1
.P2
.LP
The function
.CW localtime
.ix [localtime]
.ix "time~of~day
was used to break down the clock obtained by the call to
.CW time
.ix [time]
into seconds, minutes, hours, and so on. This thread does not generate a very
precise clock. It sends the time once per minute, but it could send it when there
is only one second left for the next minute. In any case, this part of the program
can be refined and programmed independently of the rest of the application.
.PP
To read the temperature, we need a temperature metering device. We assume that
the file
.CW /dev/temp
gives the current temperature as a string each time when read.
To implement the thread
.CW temp ,
we measure the temperature once per minute. However, the thread only sends
a temperature update when the temperature changes (and the first time it is
measured). Once more, the channel where to send the updates is given as
a parameter.
.P1
void
tempthread(void* a)
{
	Channel* c = a;
	char	temp[10];
	char	last[10];
	int	fd, nr;

	last[0] = 0;
	fd = open("/dev/temp", OREAD);
	if (fd < 0)
		sysfatal("/dev/temp: %r");
	for(;;){
		nr = read(fd, temp, sizeof(temp) - 1);
		if (nr <= 0)
			sysfatal("can't read temp");
		temp[nr] = 0;
		if (strcmp(last, temp) != 0){
			strcpy(last, temp);
			sendp(c, strdup(temp));
		}
		sleep(60 * 1000);
	}
}
.P2
.LP
What remains to be done is to implement the
.CW decorator
thread. This thread must receive alternatively from one of three
channels,
.CW timerc ,
.CW tempc ,
or
.CW consc .
When it receives a new message from either channel, it must concoct a new
message including up to date information from the three inputs, and deliver
the new message through
.CW bcastc
to update all the panels. Because we do not know in which order we are going
to receive inputs, we cannot use
.CW recvp .
The function
.CW alt
implements many-to-one communication. It takes a set of channel operations
(sends or receives) and blocks until one of the operations may proceed. At
that point, the operation is executed and
.CW alt
returns informing of which one of the channel operations was done. Before
discussing it, it is easier to see the
.CW decorator
thread as an example.
.P1
.ps -1
void
decoratorthread(void*)
{
	char*	lcons, *ltimer, * ltemp;
	char*	consmsg, *timermsg, *tempmsg;
	char*	msg;
	Alt	alts[] = {
		{ timerc,&timermsg, CHANRCV },
		{ consc, &consmsg, CHANRCV },
		{ tempc, &tempmsg, CHANRCV },
		{ nil,   nil, CHANEND } };

	lcons = strdup("");
	ltimer = strdup("");
	ltemp = strdup("");
.ps +1
.P2
.P1
.ps -1
	for(;;){
		msg = nil;
		switch(alt(alts)){
		case 0:	// operation in alts[0] made
			chanprint(bcastc, "%s (%s %s)\en",
				lcons, timermsg, ltemp);
			free(ltimer);
			ltimer = timermsg;
			break;
		case 1:	// operation in alts[1] made
			if (msg == nil)
				threadexitsall("terminated");
			chanprint(bcastc, "%s (%s %s)\en",
				consmsg, ltimer, ltemp);
			free(lcons);
			lcons = consmsg;
			break;
		case 2:	// operation in alts[2] made
			chanprint(bcastc, "%s (%s %s)\en",
				lcons, ltimer, tempmsg);
			free(ltemp);
			ltemp = tempmsg;
			break;
		}
	}
}
.ps +1
.P2
.LP
The call to
.CW alts
.ix [Alt]
.ix [alts]
.ix "alternative channel operation
.ix "simultaneous channel operation
receives an array of four
.CW Alt
structures. The first three ones are the channel operations we are interested
in. The fourth entry terminates the
.CW alts
array, so that
.CW alt
could know where the array ends. When the thread calls
.CW alt ,
it blocks. And it remains blocked until
.I any
of the three channel operations represented by
.CW Alt
entries in the array may be performed.
.PP
For example, if right before calling
.CW alt
the timer thread sent an update,
.CW alt
will immediately return, reporting that a receive from
.CW timerc
was made. In this case,
.CW alt
returns zero, which is the index in the
.CW alts
array for the operation performed. That is how we know which operation was made,
its index in the array is the return value from
.CW alt .
.PP
Each
.CW Alt
entry in the array is initialized with the channel where the operation is to be performed,
a constant that can be
.CW CHANRCV
or
.CW CHANSEND
.ix [CHANRCV]
.ix [CHANSEND]
.ix [CHANEND]
to indicate that we want to receive or send in that channel, and a pointer to the
message for the operation. The constant
.CW CHANEND
is used as the operation to mark the end of the array, as seen above. To say
it in another way, the call to
.CW alt
above is similar to doing
.I "any of"
the following
.P1
recv(timerc, &timermsg);
recv(consc, &consmsg);
recv(tempc, &tempmsg);
.P2
.LP
But
.CW alt
works without requiring a precise order on those operations. That is a good
thing, because we do not know in which order we are going to receive updates.
We do not know which particular channel operation is going to be
picked up by
.CW alt
if more than one can be performed. But we know that
.CW alt
is fair. Adding a loop around
.CW alt
guarantees that all the channel operations that may be performed will be
performed without starvation for any channel.
.PP
Now that
.CW alt
is not a mystery, we should mention some things done by the
.CW decorator
thread. This thread uses
.CW chanprint
.ix [chanprint]
.ix "channel [print]
to send messages to the
.CW bcast channel.
A call to
.CW chanprint
is similar to calling
.CW smprint
.ix [smprint]
(to print the arguments in a string allocated in dynamic memory), and then sending
the resulting string through the channel. This function is very convenient in many
cases.
.PP
At any time, the operator might send an end-of-file indication, typing
.I control-d .
When the
.CW decorator
thread receives a nil message (sent by
.CW consthread
upon EOF), it calls
.CW threadexitsall .
This function terminates all the processes and threads of the program, terminating it.
.BS 2 "Other calls
.LP
In general, it is safe to use whatever functions from the C library (or from any other one)
in a program using the thread library. We have done so through this chapter.
Function libraries try not to use global variables, and when they do, they
try to protect from races so that you could call them from a concurrent program.
In other systems, things are not so nice and you should look into the manual
pages for warnings regarding multi-threaded programs. For example, many UNIX
manual pages have notes stating that functions are
.I MT-Safe ,
.ix MT-Safe
.ix UNIX
i.e., safe for use in multithreaded programs. That is, in programs with multiple threads.
.PP
Even in Plan 9, some other functions and system calls are not to be used when
using the thread library. In general, this happens whenever a function deals with
the flow of control for the process. A threaded program has multiple flows of control,
and it would make no sense to operate on the underlying flow of control of the process
used to implement the various threads.
.PP
We have seen that
.CW threadexits
must be used instead of
.CW exits ,
because of the obvious reason. This case was clear. A less clear one may be
.CW proccreate ,
which we used
instead of calling
.CW rfork
or
.CW fork .
The thread library knows about the processes it creates. It tries hard to supply
the same interface for both threads and processes, so that all its operations work
in the same way for both entities. Indeed,
.CW proccreate
creates a single thread in a new process. Thus, you might say that all operations
from the library work just on threads. In any case, using
.CW rfork
to operate on the resources for your process is safe. For example, to make a copy
of environment variables, put the process in a new note group, etc.
.PP
In a similar way,
.CW procexec
.ix [procexec]
.ix "program execution
.ix [procexecl]
(or
.CW procexecl )
should be used instead of
.CW exec
(or
.CW execl ).
A call to
.CW exec
would replace the program for the process, making void all the threads that
might be running on it. But a call to
.CW procexec
works nicely when using processes and threads. Of course, it only makes
sense to call
.CW procexec
when there is a single thread in the process making the call. Otherwise, what would
happen to the other threads? Their code and data would be gone!
.PP
In most cases, there is no need to call
.CW wait
.ix [wait]
to wait for other processes. The processes you create can synchronize with the
rest of your program using channels, if you need to convey a completion status
or something else. That is not the case when using
.CW procexec .
The program executed by
.CW procexec
knows nothing about your program. Therefore, a substitute for
.CW wait
is appropriate for this case. The function
.CW threadwaitchan
.ix [threadwaitchan]
.ix "[Waitmsg] channel
returns a channel that can be used to receive
.CW Waitmsgs
for processes what we used to execute other programs.
.PP
The following program is a complete example regarding how to execute an
external program and wait for it.
.so progs/texec.c.ms
.ix [texec.c]
.LP
The initial thread reads a file name and executes it. The actual work is done
by
.CW proccreate ,
which creates the process to execute the file, and by
.CW procexecl ,
which executes the new program in the calling process.
.PP
The first parameter for
.CW procexecl
may be either nil or point to a channel of unsigned integers. In the later case,
the pid for the process used to execute the command is sent through the channel.
This is useful for more than to obtain the pid for the process running the external command.
It is guaranteed that the arguments supplied to
.CW procexec
will not be used after sending the pid. In our case,
.CW ln
is in the stack of the initial thread. After receiving the pid, we could terminate
.CW threadmain ,
which deallocates
.CW ln .
However, before receiving the pid, the arguments for
.CW procexec
must still exist, and cannot be deallocated yet.
.PP
The program calls
.CW threadwaitchan
to obtain a channel for notifying the termination of the external program. Receiving from
this channel yields the
.CW Waitmsg
that
.CW wait
would return for a program not using threads.
.PP
This is an example run.
.P1
; 8.texec
cmd? /bin/date
started new proc pid=1436
Sat Aug  5 19:51:05 MDT 2006
terminated pid=1436 sts=
; 8.texec
cmd? date
procexecl: 'date' file does not exist
;
.P2
.PP
To conclude, handling of notes is similar in threaded programs than in other ones. Only that
.CW threadnotify
.ix [threadnotify]
.ix "notes
must be used instead of
.CW atnotify .
.ix [atnotify]
But the interface is otherwise the same.
.SH
Problems
.IP 1
Implement a concurrent program simulating a printer spooler. It must
have several processes. Some of them generate jobs for printing (spool
print jobs) and two other ones print jobs. Needless to say that the program
must not have race conditions. You must use threads and channels as the
building blocks for the program.
.IP 2
One way to determine if a number is prime is to filter all natural numbers to
remove numbers that are not prime. Using different thread for filtering numbers
that divide candidate numbers, write a program to write prime numbers.
.IP 3
There are different cars trying to cross a bridge. There are cars on both sides
of the bridge. Simulate this scenario using threads and channels. Avoid
accidents.
.IP 4
The dining philosophers problem is a very famous one in concurrent programming.
There are philosophers who loop forever trying to think, and then to eat. All of
them are seated around a round table, with a single chopstick between each two
philosophers. To eat, a philosopher needs both the chopstick on the left and
the one on the right. Write a program to simulate this scenario using threads
for the different philosophers.
.IP 5
Avoid starvation in the previous problem.
.ds CH
.bp
 .
.bp
