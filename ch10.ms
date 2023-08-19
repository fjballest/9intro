.so tmacs
.BC 10 "Concurrency
.BS 2 "Synchronization
.LP
.ix synchronization 
.ix "concurrent programming
.ix [rfork]
.ix "shared memory
In the discussion of
.CW rfork
that we had time ago, we did not pay attention to what would happen when
a new process is created sharing the parent's memory. A call like
.P1
rfork(RFPROC|RFMEM)
.P2
.ix "[RFMEM] [rfork]~flag
.LP
is in effect creating a new flow of control within our program. This is not new, but
what may be new is the nasty effects that this might have if we are not careful
enough.
.PP
We warned you that, in general, when more than one process is sharing some
data, there may be race conditions. You could see how two processes
updating the same file could lead to very different contents in the file
after both processes complete, depending on when they did their updates
with respect to each other. Sharing memory is not different.
.PP
What happens is that the idea that you have
of sequential execution for your program in an
.I isolated
world is no longer true. We saw that when more than one process was trying to
update the same file, the resulting file contents might differ from one run to
another. It all depends on when did each process change the data.
And this is what we called a
.B "race condition" .
Consider this program.
.so progs/rincr.c.ms
.ix [rincr.c]
.ix "shared counter
.LP
It creates a child process, and each one of the processes increment a
counter twice. The counter is
.I shared ,
because the call to
.CW rfork
uses the
.CW RFMEM
flag, which causes all the data to be shared between parent and child.
Note that only
.CW cnt ,
which is a global, is shared. The local variable
.ix "global variable
.CW i
lives on the stack which is private, as it should be.
.PP
Executing the program yields this output.
.P1
; 8.rincr
cnt is 2
cnt is 4
;
.P2
.LP
We now declare an integer local variable,
.CW loc ,
and replace the body of the loop with this code, equivalent to what we were
doing.
.P1
loc = cnt;
loc++;
cnt = loc;
.P2
.LP
It turns out that this is how
.CW cnt++
is done, by copying the memory value into a temporary variable (kept at
a register), then incrementing the register, and finally updating the memory
location for the variable
with the incremented value. The result for this version of the program
remains the same.
.P1
; 8.rincr
cnt is 2
cnt is 4
;
.P2
.LP
But let's change a little bit more the program. Now we replace the body of the
loop with these statements.
.P1
loc = cnt;
sleep(1);
loc++;
cnt = loc;
.P2
.LP
The call to
.CW sleep
does not change the meaning of the program, i.e., what it does. However,
it
.I does
change the result!
.ix "meaning~of program
The call to
.CW sleep
exposed a race condition present in all the versions of the program.
.P1
; 8.rincr
cnt is 2
cnt is 2
.P2
.LP
.ix "process execution
.ix "scheduling
Both processes execute one instruction after another, but you do not know
when the operating system (or any external event) will move one process out
of the processor or move it back to it. The result is that we do not know how the two
sequences of instructions (one for each process), will be
.I merged
in time.
Despite having just one processor that executes only a sequence of instructions,
any merge
of instructions from the first and the second process is feasible. Such a merge
is usually called an
.B interleaving .
.PP
Perhaps one process
executes all of its statements, and then the second. This happen to the
.CW for
loop in all but the last version of the program. On the other hand, perhaps
one process executes some instructions, and then the other, and so on.
Figure [[!interleaving!]] shows the interleaving of statements that resulted
from our last modification to the program, along with the values for the two
local variables
.CW loc ,
and the global
.CW cnt .
The initial call to
.CW rfork
is not shown. The statements corresponding to the loop itself are not shown either.
.LS
.PS
.ps -2
arrowhead=7
boxht= .15
boxwid=.5
.CW
define block0 {[
	[ down
		box invis "loc = cnt" ljust
		box invis "sleep" ljust
	]
]}
define block {[
	[ down
		box invis "loc++" ljust
		box invis "cnt = loc" ljust
		box invis "loc = cnt" ljust
		box invis "sleep" ljust
	]
]}
define blockn {[
	[ down
		box invis "print" ljust
	]
]}

.\" vars(loc,cnt,loc)
define vars {[
	move .1
	[ right ; box $1 ; move 1 ; box $2 ; move 1 ; box $3]
	move .1
]}
down
[ right
	box invis "\fBParent\fP" ljust ; move 2.5 ;box invis "\fBChild\fP" ljust
]
vars("loc: ?", "cnt: 0", "loc: ?")
[ right
	block0(); move 2.5 ; box invis
]
vars("loc: 0", "cnt: 0", "loc: ?")
[ right
	box invis ; move 2.5 ; block0();
]
vars("loc: 0", "cnt: 0", "loc: 0")
[ right
	block(); move 2.5 ; box invis
]
vars("loc: 1", "cnt: 1", "loc: 0")
[ right
	box invis ; move 2.5 ; block();
]
vars("loc: 1", "cnt: 1", "loc: 1")
[ right
	block(); move 2.5 ; box invis
]
vars("loc: 2", "cnt: 2", "loc: 1")
[ right
	box invis ; move 2.5 ; block();
]
vars("loc: 2", "cnt: 2", "loc: 2")
[ right
	blockn() ; move 2.5 ; box invis
]
move .1
[ right
	box invis ; move 2.5 ; blockn();
]
reset
.R
.ps +2
.PE
.LE F One interleaving of statements for the two processes (last version of the program).
.PP
What you see is that something happens
.I while
one process is happily incrementing the variable, by copying the global counter
to its local, incrementing the local, and copying back the local to the shared counter,
While one process is performing its increment, the other process gets in the way.
In the sequence of statements
.P1
loc = cnt;
loc++;
cnt = loc;
.P2
.LP
we assume that right after the the first line,
.CW loc
has the value that is kept in the shared variable. We further assume that
when we execute the last line, the global variable
.CW cnt
has the value it had when we executed the first line.
.PP
That is no longer true. Because there is another process that might change
.CW cnt
while we are doing something else. The net effect in this case is that we lose
increments. The counter should end up with a value of 4. But it has the value
2 at the end.
The same would happen if the interleaving had been like follows.
.IP 1
Process 1: Consult the variable
.IP 2
Process 2: Consult the variable
.IP 3
Process 1: Increment
.IP 4
Process 2: Increment
.IP 5
Process 1: Update the variable
.IP 6
Process 2: Update the variable
.LP
This interleaving also loses increments. This is because of the race condition
resulting from using the
.I shared
.CW cnt
in two different processes without taking any precaution.
.PP
Why did our last program exhibit the race condition but others did not?
Because calling
.CW sleep
.ix [sleep]
.ix "blocked state
.ix "context switch
puts the process to sleep, in the blocked state, and the system is
.I very
likely to let the other process run while we sleep. We are forcing a context
switch at the place where we call
.CW sleep .
Nevertheless, the previous versions for the program are broken as well.
We do not know if the system is going to decide to switch from one process
to another in the middle of our loop. What happened is that in our case, the system
did not switch. It was not too probable to have a context switch right in the middle,
but it could happen.
.PP
Instructions are said to execute \fBatomically\fP,
.ix "atomic instruction
.ix "interrupt
because one instruction is not interrupted in the middle to do something else.
Interrupts happen at the end of instructions, but not in the middle. However,
even
.CW cnt++
is implemented using several instructions, along the lines of our late versions for
the program. This means that another process may get in the way, even in the middle
of something like
.CW cnt++ .
The same applies to
.CW if
conditions and to any other statement.
.PP
What we need is some way to
.B synchronize
multiple processes. That is, to arrange for multiple processes to agree regarding
when is a good time to do particular operations. In the rest of this chapter, and in
the following one, we are
going to explore some abstractions provided by Plan 9 that can
be used to synchronize processes. We are going to focus on synchronizing processes
that share memory. When they do not share memory, pipes are excellent
synchronization means, and you have already used them.
.BS 2 "Locks
.LP
.ix "lock
How do we solve the problem? The race condition happens because more than
one process may simultaneously use a shared resource, i.e. the global counter.
This is what breaks the assumption that
.CW cnt
does not change between lines (1) and (3) in
.P1
\fR(1)\fP	loc = cnt;
\fR(2)\fP	loc++;
\fR(3)\fP	cnt = loc;
.P2
.LP
Furthermore, the reason why more than one process may use
.CW cnt
simultaneously is because this block of code is not
.I atomic .
It is not a single instruction, which means that
in the middle of the block there may be a context switch, and the other process
may change
.CW cnt
or consult it while we are in the middle of a change.
.PP
On the contrary, the executions for the first two versions of our program behaved
.I "as if"
this block of code was atomic. It just happen that one process executed the
problematic code, and then the other. The code was executed without being
interrupted by the other process in the middle of the update for
.ix "concurrent updates
.ix "good luck
.CW cnt .
And the net effect is that the program worked! We now know that we were just lucky,
because there could have been a context switch in the middle. But the point is that
when the block of code behaves as an atomic instruction, there are no races, and
the program behaves nicely.
.LS
.PS
.ps -2
arrowhead=7
boxht= .15
boxwid=.5
.CW
define var {
	move .1
	[ right
		box invis  ; box $1  ;box invis 
	]
	move .1
}
right
[
	down
	[ right
		box invis "\fBParent\fP" ; move .5 ;box invis "\fBChild\fP"
	]
	var("cnt: 0")
	[ right
		box invis "cnt++"  ; move .5 ;box invis 
	]
	var("cnt: 1")
	[ right
		box invis  ; move .5 ;box invis "cnt++"
	]
	var("cnt: 2");
	move
	"\fB(a)\fP"
]
move .5
box wid .005 ht 2
move .5
[
	down
	[ right
		box invis "\fBParent\fP" ; move .5 ;box invis "\fBChild\fP"
	]
	var("cnt: 0")
	[ right
		box invis  ; move .5 ;box invis "cnt++"
	]
	var("cnt: 1")
	[ right
		box invis "cnt++"  ; move .5 ;box invis 
	]
	var("cnt: 2");
	move
	"\fB(b)\fP"
]
reset
.R
.ps +2
.PE
.LE F Incrementing a shared counter using an atomic increment operation. No races.
.PP
Why is this so? Consider our two processes trying to increment the global counter,
as shown in figure  [[!atomic increment!]].
Imagine also that
.CW cnt++
was a single instruction. One of the two processes is going to execute
.CW cnt++
before the other. It could happen what figure [[!atomic increment!]] (a) shows,
or what is shown in [[!atomic increment!]] (b). There is no other case.
As we are assuming that this is an atomic (non
divisible) instruction, the increment is performed correctly. There can be no
context switch in the middle. Now, when the other
process executes its
.CW cnt++ ,
it finds
.CW cnt
already incremented, and no increment is missed. There is no race. The only
two possibilities are those depicted in figure [[!atomic increment!]].
.PP
.ix "instruction order
Of course, we do not know the order in which increments are going to be made.
Perhaps the parent in our program does its two increments, and then the child,
or perhaps the other way around, or perhaps in some interleaved way. No matter
the order, the program will yield the expected result if the increments are
atomic, as we just discussed.
.PP
The code where we are using a shared resource, which poses problems when
not executed atomically, is called a
.B "critical region" .
It is just a  piece of code accessing a shared resource.
A context switch while executing within the critical region may be a problem. More precisely,
the problem is not having a context switch, but switching to any other process
that might also use or change the shared resource. For example, it does not matter
if while we are incrementing our counter, Acme runs for a while. Acme does not interfere
because we are not sharing our counter with it. This is the last program, with
the critical region shown inside a box.
.so progs/rincr2.c.ms
.ix "[rcinr.c]
.LP
Given our critical region,
If we could guarantee
that at most one process is executing inside it, there would be no race conditions.
The reason is that the region would appear to be atomic, at least with respect to
the processes trying to execute it. There could be any number of context switches
while executing the region, but no other process would be allowed to enter it until
the one executing it does leave the region. Thus, only one process would be using
the shared resource at a given time and that is why there would be no races.
.PP
Guaranteeing that no more than one process is executing code within the critical
region is called achieving
.B "mutual exclusion" ,
because one process executing within the region excludes any other one from
executing inside (when there is mutual exclusion).
.PP
How can we achieve mutual exclusion for our critical region?
The idea is that when a process is about to enter the critical region, it must wait
until it is sure that nobody else is executing code inside it. Only in that case it
may proceed. To achieve this we need new abstractions.
.PP
A
.B lock
is a boolean variable (or an integer used as a boolean) used to indicate if a
critical region is occupied or not. A process entering the critical region sets the
lock to true, and resets the lock to false only after leaving the region. To enter
the region, a process must either find the lock set to false or wait until it becomes
false, otherwise there would be more than one process executing within the
critical region and we would have race conditions.
.PP
.ix "resource lock
The intuition is that the lock is a variable that is used to
.I lock
a resource (the region). A process wanting to use the shared resource only does so
after locking it. After using the resource, the process unlocks it.
While the resource is locked, nobody else will be able to
lock it and use it.
.PP
Using locks, we could protect our critical region by declaring a
.CW Lock
.ix [Lock]
variable,
.CW cntlck ,
calling
.CW lock
.ix [lock]
on it (to set the lock) before entering the critical region, and calling
.CW unlock
.ix [unlock]
on it (to release the lock) after leaving the region. By initializing the variable
to zero, the lock is initially released (remember that globals are initialized to zero
by default).
.P1
; sig lock unlock
	void lock(Lock *l)
	void unlock(Lock *l)
.P2
.LP
The resulting program is shown next.
.so progs/lock.c.ms
.ix [lock.c]
.LP
Just to make it more clear, we can replace
.CW cnt++
with
.P1
loc = cnt;
sleep(1);
loc++;
cnt = loc;
.P2
.LP
and the program will in any case work as expected. Each process would loop and
do its two increments, without interference from the other process.
.PP
When our two processes try to execute the critical region, one of them is going to
execute
.CW lock(&cntlck)
first. That one wins and gains the lock. The region is now locked. When the second process
calls
.CW lock(&cntlck)
it finds the lock set, and waits inside the function
.CW lock
until the lock is released and can be set again. The net effect is that we
achieve mutual exclusion for our critical region.
.ix "mutual exclusion
.ix "critical region
.PP
Note that the output from the program may still be the same than that of our first
two versions, but those versions were incorrect. They are poltergeists, awaiting
for the worst time to happen. When you do not expect them to misbehave, they
would miss an increment, and the program with the race will fail in a mysterious way
that you would have to debug. That is not fun.
.PP
.PP
By the way, did we lie? We said that locks are boolean variables, but we declared
.CW cntlck
as a structure
.CW Lock .
This is how
.CW Lock
is defined in
.CW libc.h
.P1
typedef
struct Lock {
	int	val;
} Lock;
.P2
.LP
The lock is also a shared variable. It would not make sense
to give each process its own lock. The lock is used to
.B synchronize
both processes,
to make them agree upon when is it safe to do something. Therefore, it must
be shared. That means that if you write two C functions for implementing
.CW lock
and
.CW unlock ,
they would have race conditions!
.PP
The implementation for
.CW unlock
is simple, it sets
.CW Lock.val
to false. The implementation for
.CW lock
is more delicate. It is made in assembly language to use a single machine instruction
capable of consulting the lock and modifying it, all that within the same instruction.
That is reasonable. If we do not both consult the lock (to see if it is set) and update it within
an atomic instruction, there would be race conditions. There are several kinds of
.B test-and-set
instructions, that test a variable for a value but also modify it. A famous one is
precisely called
.CW TAS ,
.ix "[tas] instruction
or test and set.
.PP
Using
.CW TAS ,
here is a description of how to implement a
.CW lock
function.
.P1
loop:
	MOVL	\fIlock\fP, A0	\fIput address of lock in register A0\fP
	TAS	(A0)	\fItest-and-set word at memory address in A0\fP
	BNE	loop	\fIif the word was set, continue the loop\fP
	RTS		\fIreturn otherwise\fP
.P2
.LP
To emphasize it even more, the key point why this works at all is because
.CW TAS
is atomic. It puts a non-zero value at the address for the lock and sets the processor
flag to reflect if the previous value was not-zero or was zero.
.PP
In this loop, if a process is trying to set the lock and finds that it was set,
.CW TAS
will set an already set lock (store 1 in the lock that already was 1), and that operation
would be harmless. In this case,
.CW TAS
would report that the lock was set, and the process would be held in the loop
waiting for the lock to be released. On the other hand, if the process trying to
set the lock
executes
.CW TAS
while the lock was not set, this instruction will both set the lock and report that
it was clear. When more than one process call
.CW lock() ,
one of them is going to run
.CW TAS
first. That one wins.
.PP
To play with locks a little bit, we are going to implement a tiny program. This
program has two processes. One of them will always try to increment a counter.
The other, will be trying to decrement it. However, we do not allow the counter to
be negative. If the process decrementing the counter finds that the value is
zero, it will just try again later. Once per second, one of the processes prints
the counter value, to let us see what is happening.
.PP
In the program, we print in
.B boldface
statements that are part of a critical region. As you can see, any part of the
program where
.CW cnt
is used is a critical region. Furthermore, note that even
.CW print
is in the critical region if it is printing
.CW cnt ,
because we do not want
.CW cnt
to change in the middle of a print.
.so progs/cnt.c.ms
.ix [cnt.c]
.LP
Also, in the parent process, both the check for
.CW cnt>0
and the
.CW cnt--
must be part of the same critical region. Otherwise, the other process might
have changed
.CW cnt
between the
.CW if
and its body.
.PP
The idea is simple. If you want to be sure that no other process is even touching
the shared resource while you are doing something, you must provide
mutual exclusion for your critical region. As you see, one way is to use a
.CW Lock
along the shared resource, to lock it.
An example execution follows.
.P1
; !!8.cnt
cnt= 2043
cnt= 1
cnt= 1
cnt= 0
cnt= 4341
cnt= 1
cnt= 2808
cnt= 0
cnt= 1
cnt= 1400
cnt= 1
.P2
.LP
The value moves in bursts, up as the child manages to increment it, and
down when the parent manages to decrement it many times. The value
printed was
.CW 1
when the child finds a zero counter, increments it, and prints its value.
The value printed is zero when, after the parent increments the counter,
the child manages to decrement it before the parent prints its value.
.PP
It is very important to maintain critical regions as small as possible. If a process
keeps a resource locked most of the time, other processes will experience
many delays while trying to acquire the resource. Or even worse, if we are
not careful, it may be that a process is
.I never
able to acquire a lock it needs, because it always finds the resource locked.
Look at this variant of our last program, that we call
.CW cnt2 .
.ix [rfork]
.P1
	switch(rfork(RFPROC|RFMEM|RFNOWAIT)){
	case 0:
		last = time(nil);
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			cnt++;
			print("%d\en", cnt);
			unlock(&cntlck);
		}
	default:
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			if (cnt > 0)
				cnt--;
			print("%d\en", cnt);
			unlock(&cntlck);
		}
	}
.P2
.LP
Now look at this:
.P1
; 8.cnt2 | grep -v 0
	\fI and no number is ever shown!\fP
.P2
.LP
We asked
.CW grep
to print only lines that do
.I not
contain a
.CW 0 .
It seems that all lines in the output report a zero value for
.CW cnt .
Is it that the child process is not executing? We can use the debugger
to print the stack for the child.
.ix "process stack
.ix "stack dump
.P1
; ps | grep 8.cnt2
nemo       5153    0:00   0:01  28K Pwrite   8.cnt2
nemo       5155    0:00   0:00  28K Sleep    8.cnt2
.P2
.P1
; acid 5155
/proc/5155/text:386 plan 9 executable

/sys/lib/acid/port
/sys/lib/acid/386
acid: !!stk()
sleep()+0x7 /sys/src/libc/9syscall/sleep.s:5
lock(lk=0x702c)+0x47 /sys/src/libc/port/lock.c:16
main()+0x90 /usr/nemo/9intro/cnt2.c:19
_main+0x31 /sys/src/libc/386/main9.s:16
acid:
.P2
.LP
The child process is always trying to lock the resource, inside
.CW lock() !
What happens is that the parent is holding the lock almost at all times.
The parent only releases the lock for a very brief time, between the end
of an iteration and the beginning of the next iteration. Only if during this
time there is a context switch, and the child is allowed to run, will the child
be able to acquire the lock. But it seems that in our case the system always
decides to let the child run while the parent is holding the lock.
.PP
This is called
.B starvation .
A process may never be able to acquire a resource, and it will starve to death.
It can be understood that this may happen to our program, because only for
a very little fraction of time the lock is released by the parent. The most probable
thing is that once a process gets the lock, the other one will never be able to
acquire it.
.PP
Look at the stack trace shown above. Did you notice that
.CW lock
calls
.CW sleep ?
You know that the system gives some processor time to each process, in turns.
If the implementation for
.CW lock
was the one we presented before in assembly language, we would be wasting a lot
of processor time. Figure [[!spin lock!]] depicts the execution for our two processes,
assuming that
.CW lock
is implemented as we told before. In the figure, a solid line represents a process
that is running, in the processor. A dotted line represents a process that is
ready to run, but is not running in the processor. The figure shows how the system
gives some time to each process for running, in turns.
.LS
.PS 5i
.ps -1
define slot { line $1 above $3 right $2/100}
define rdy {slot("Rdy.", $1, dotted)}
define run {slot("Run.", $1)}
define blk {slot("Blk.", $1, dashed)}
down
P: [ right
	box invis  "Parent" ljust
	L: [ run(100) ]
	rdy(100)
	L2: run(100)
	rdy(100)
	L3: run(100)
	Lck: circle rad .05 fill  0 at L.w + 0.3,0
	Unl: circle rad .05 fill 7 at L.e - 0.25,0
	circle rad .05 fill 0 at L.e - 0.1,0
	circle rad .05 fill 7 at L2.e - 0.25, 0
	circle rad .05 fill 0 at L2.e -0.1,0
	circle rad .05 fill 7 at L3.e - 0.25, 0
	circle rad .05 fill 0 at L3.e -0.1,0

	spline <- from Lck.s down .5 then right .2
	"\f(CWlock\fP" ljust
	spline <- from Unl.s down .2 then right .2
	 "\f(CWunlock\fP" ljust
]
move .1
[ right
	box invis "Child" ljust
	rdy(100)
	R: run(100)
	rdy(100)
	R2: run(100)
	rdy(100)
	Lck: circle rad .05 fill 0 at R.w + 0.3,0
	box fill 0 wid 0.7 ht .05 with .w at last circle
	box fill 0 wid 1 ht .05 with .w at R2.w
	spline <- from Lck.s down .2 then right .2
	"calls \f(CWlock\fP, which spins around trying to acquire it." ljust
	
]
move .3
[
line right .5  "\fBTime\fP" above ; arrow right 5
]
.ps +1
.PE
.LE F Two processes using a shared resource protected by a spin lock.
.PP
Initially, the parent calls
.CW lock ,
and acquires the lock because it was initially released. Later, the parent
process releases the lock by a call to
.CW unlock ,
but it quickly calls
.CW lock
again, and re-acquires the lock.
Now it is the time for the child process to run. This poor process calls
.CW lock ,
but you know what happens. The routine cannot acquire the lock, which is held
by the parent process. Therefore, it waits in its loop calling
.CW TAS
to try to gain the lock. That is all this process would do while it is allowed to remain
running. The very thick line in the figure
represents the process executing this while, spinning
around desperately hoping for
.CW TAS
to succeed and obtain the lock. Because of this, this kind of lock is called a
.B "spin lock" .
.ix "busy waiting
.PP
One problem with this execution, as you already know, is that the child suffers
starvation, and is very likely to never acquire its lock. This can be solved by
trying to hold locks for the least time as feasible, unlike we are doing in our program.
The other problem that you may see is that the child is
.I wasting
processor time. When the child calls
.CW lock ,
and finds that the lock was held and it cannot acquire it, it is pointless to keep
on trying to acquire it. Unless the child leaves the processor, and the process
holding the lock is able to run, nobody is going to release the lock. Therefore,
it is much better to let other processes run instead of insisting. This may give
the one holding the lock a chance to release it. And that is better for us, because
we want to acquire it.
.PP
In the actual implementation of
.CW lock
in Plan 9,
when
.CW lock
finds that the lock is held and cannot be set, it calls
.CW sleep .
This moves the process out of the processor, while it is blocked during the sleep.
Hopefully, after sleeping a little bit, the lock will be already released. And, at the
very least, we will not be wasting processor time spinning around inside
.CW lock
without any hope of acquiring the lock before leaving the processor. Figure
[[!lock sleep!]] depicts the same scenario for our two processes, but showing
what happens when
.CW lock
calls
.CW sleep .
Compare it with the previous one.
.LS
.PS 5i
.ps -1
define slot { line $1 above $3 right $2/100}
define rdy {slot("Rdy.", $1, dotted)}
define run {slot("Run.", $1)}
define blk {slot("Blk.", $1, dashed)}
down
P: [ right
	box invis  "Parent" ljust
	L: [ run(100) ]
	rdy(30)
	L2: run(100)
	rdy(15)
	L3: run(100)
	Lck: circle rad .05 fill  0 at L.w + 0.3,0
	Unl: circle rad .05 fill 7 at L.e - 0.35,0
	circle rad .05 fill 0 at L.e - 0.25,0
	circle rad .05 fill 7 at L2.e - 0.35, 0
	circle rad .05 fill 0 at L2.e -0.25,0
	circle rad .05 fill 7 at L3.e - 0.35, 0
	circle rad .05 fill 0 at L3.e -0.25,0

	spline <- from Lck.s down .5 then right .2
	"\f(CWlock\fP" ljust
	spline <- from Unl.s down .2 then right .2
	 "\f(CWunlock\fP" ljust
]
move .1
[ right
	box invis "Child" ljust
	rdy(100)
	R: run(30)
	blk(50)
	rdy(50)
	B: box wid .1 ht .05 fill 0
	blk(30)
	rdy(70)
	Lck: circle rad .05 fill 0 at R.e
	spline <- from Lck.s down .5 then right .2
	"calls \f(CWlock\fP, which calls \f(CWsleep\fP this time" ljust
	spline <- from B.s down .2 then right .2
	"No luck. Calls \f(CWsleep\fP" ljust
	
]
move .3
[
line right .5  "\fBTime\fP" above ; arrow right 4
]
.ps +1
.PE
.LE F Same scenario, but using a lock that calls sleep to save processor time.
.PP
One last remark. Because of the call to
.CW sleep ,
Plan 9 locks are not real spin locks. They do not spin around in a while all the time.
As you now know, they call
.CW sleep(0) ,
just to abandon the processor and let others run if the lock was held. However,
because they are very similar, and loop around, many people refer to them as
spin locks.
.BS 2 "Queueing locks
.LP
How can avoid starvation in our program?
The code for both processes was very similar, and had a nice symmetry. However,
the execution was not fair. At least for the child process. There is a different kind
of lock (yet another abstraction) that may be of help.
.PP
A
.B "queueing lock"
is a lock like the ones we know. It works in a similar way. But unlike a spin lock,
a queueing lock uses a queue to assign the lock to processes that want to acquire it.
The data type for this lock is
.CW QLock ,
.ix [QLock]
and the functions for acquiring and releasing the lock are
.CW qlock
and
.CW qunlock .
.ix [qlock]
.ix [qunlock]
.P1
; sig qlock qunlock
	void qlock(QLock *l)
	void qunlock(QLock *l)
.P2
.LP
When a process calls
.CW qlock ,
it acquires the lock if the lock is released. However, if the lock is held and cannot
be acquired yet, the process is put in a queue of processes waiting for the lock.
When the lock is released, the first process waiting in queue for the lock is the one
that acquires it.
.PP
There is a
.I huge
difference between
.CW Locks
and
.CW QLocks
because of the queue used to wait for the lock. First, a process is not kept
spinning around waiting for a lock. It will be waiting, but blocked, sitting in the queue
of waiting processes. Second, the lock is assigned to processes in a very fair way.
The first process that entered the queue to wait for the lock would be the first to
acquire it after the lock is released. Because of both reasons, it is always a good idea
to use
.CW QLocks
instead of
.CW Locks .
The spin locks are meant for tiny critical regions with just a few instructions. For
example, the data structure used to implement a
.CW QLock
is protected by using a
.CW Lock .
Such spin lock is held just for a very short time, while updating the
.CW QLock
during a call to
.CW qlock
or
.CW qunlock .
.PP
Our (in)famous program follows, but using queueing locks this time.
.so progs/qcnt.c.ms
.ix [qcnt.c]
.LP
Note the huge difference in behavior. An execution for this program follows.
As you can see, this time, both processes take turns. This happens because
of the queue. The lock is assigned in a very fair way, and both processes get a
chance to do their job.
.P1
; 8.qcnt
0
0
1
0
1
0
.P2
.LP
.ix "airport panels
To do something more useful, we are going to implement a tool to update
ticker-tape panels at an airport. This program is going to read lines from
standard input. When a new message must be displayed at the airport panels,
the user is supposed to type the message in the keyboard and press return.
.PP
Once a new message has been read, all the panels must be updated to display
it instead of the old one.
Because updating a panel is a very slow operation, we do not want to use
a loop to update each one in turn. Instead, we create one process per panel,
as shown in figure [[!airport panels!]].
.LS
.PS
copy "/lib/pic/macros"
right
xterm(0.5)
arrow <- "read" above
circle "reader" "process"
arrow "update" above
M: box ht .2 "message"
arrow <- "poll" above
P: [ down
	reset
	A: [ right ; X: circle "panel" "process" ; arrow "write" above ; flatpanel(0.5) ]
	A: A.X
	reset
 	move
	[ right ; 	circle "panel" "process" ; arrow "write" above ; flatpanel(0.5) ]
	reset
	move
	B: [ right ; X: circle "panel" "process" ; arrow "write" above ; flatpanel(0.5) ]
	B: B.X
]
arrow <- from M.e + 0,.05 to P.A.sw
arrow <- from M.e - 0,.05 to P.B.nw
.PE
.LE F Process structure for the ticker-tape panels application for the airport.
.PP
.ix "version number
.ix "airport application
.ix "panel process
The parent process will be the one reading from the input. After reading a new
message, it will increment a
.I "version number"
for the message along with the message text itself. The panel processes will be
polling the version number, to see if their messages are out of date. If they are,
they will just write the new message to their respective panels, and record the
version for the message. This is our data structure.
.P1
.ps -1
typedef struct Msg Msg;
struct Msg {
	QLock	lck;	// to protect the other fields
	char*	text;	// for the message
	ulong	vers;	// for the message
};

Msg msg;
.ps +1
.P2
.LP
The code for the message reader is as follows. It works only when
reading from the terminal, because it is using just
.CW read
to read a line from the input. 
.ix "console reader
.ix "message reader
.P1
void
reader(void)
{
	char	buf[512];
	int	nr;

	for(;;){
		nr = read(0, buf, sizeof(buf)-1);
		if (nr <= 0)
			break;
		buf[nr] = 0;
		qlock(&msg.lck);
		free(msg.text);
		msg.text = strdup(buf);
		msg.vers++;
		qunlock(&msg.lck);
	}
	exiting = 1;
	exits(nil);
}
.P2
.LP
The critical region, updating the message text and its version, is protected by
the
.CW QLock
kept at
.CW msg.lck .
This lock is kept within
.CW msg
because it is used to protect it. If the program grows and there are more data
structures, there will be no doubt regarding what data structure is protecting
.CW msg.lck .
.PP
Each panel process will be running a
.CW panelproc
function, and receive a file descriptor that can be used to write a message
to the file representing the panel.
.P1
.ps -1
void
panelproc(int fd)
{
	ulong	lastvers = -1;

	do {
		qlock(&msg.lck);
		if(msg.text != nil && lastvers != msg.vers){
			write(fd, msg.text, strlen(msg.text));
			lastvers = msg.vers;
		}
		qunlock(&msg.lck);
		sleep(5 * 1000);
	} while(!exiting);
	fprint(2, "panel exiting\en");
	exits(nil);
}
.ps +1
.P2
.LP
The local
.CW lastvers
keeps the version for the message shown at the panel.
Basically,
.CW panelproc
loops and, once each 5 seconds, checks out if
.CW msg.vers
changed. If it did, the new text for the message is written to the panel.
The initial value for
.CW lastvers
is just a kludge to be sure that the message is updated the very first time (in
that case, there is no previous version).
Note how the critical region includes both the checks in the condition of the
.CW if
and the statements used to access
.CW msg
in the body.
.PP
Before discussing other details of this program, let's see how the whole
program
looks like.
.so progs/ticker.c.ms
.ix [ticker.c]
.LP
It creates one process per panel, and then executes the
.CW reader
code using the parent process. To test the program, we used the
standard output as the file descriptor to write to each one of the panels.
.PP
When a program is built using multiple processes, it is important to pay
attention to how the program is started and how is it going to terminate.
In general, it is best if the program works no matter the order
in which processes are started. Otherwise, initialization for the program
will be more delicate, and may fail mysteriously if you make a mistake regarding
the order in which processes are started. Furthermore, you do not know how
fast they are going to run. If you require certain order for the starting up of
processes, you must use a synchronization tool to guarantee that such order
is met.
.PP
.ix "process synchronization
For example, a
.CW panelproc
should not write a message to its panel
.I before
there is at least one message to print. All
.CW panelprocs
should be waiting, silently, until
.CW reader
has got the chance of reading the first message and updating the data
structure. The program does so by checking that
.CW "msg.text
is not
.CW nil
in
.CW panelproc
before even looking at the message. The
.CW msg.text
will be a null value until the reader initializes it for the first time.
As a result, if we start the panel processes after starting the reader,
the program will still work.
.PP
.ix "process termination
Termination is also a delicate thing. Now that there are multiple processes,
when the program terminates, all the processes should exit. How to achieve this
in a clean way, it depends on the problem being solved. In this case we decided
to use a global flag
.CW exiting .
No
.CW panelproc
will remain in its
.CW while
when
.CW exiting
is true. Therefore, all we have to do to terminate the program is to set
.CW exiting
to
.CW 1 ,
as we do in the reader after reaching the end of file. Later, as panel
processes awake from their sleep and check
.CW exiting ,
they will call
.CW exits
and terminate themselves.
.ix [exits]
.PP
This is an example execution for the program. Note how the panel
processes terminate
.I after
we have sent the end of file indication. 
.P1
; 8.ticker
!!Iberia arriving late for flight 666
Iberia arriving late for flight 666
Iberia arriving late for flight 666
!!Iberia arriving very late for flight 666
Iberia arriving very late for flight 666
Iberia arriving very late for flight 666
\fBcontrol-d\fP
;\ panel exiting
panel exiting
.P2
.LP
If you look at the program, you will notice that
after we have updated the message, the panel processes will acquire the
.CW msg.lck
in sequence as they write their panels, one
.I after
another.
If the data structure
.CW msg
is consulted a lot, the whole program will be very slow due to delays caused
by the use of a
.CW QLock
.ix [QLock]
.ix [qlock]
to protect the data. While a panel process is writing to the panel, no other
panel process will be able to even touch the message. We can improve things
a little bit by writing to the panel
.I outside
of the critical region. By doing so, other panel processes will be allowed to gain
the lock and consult the message as well.
.P1
.ps -1
void
panelproc(int fd)
{
	ulong	lastvers = -1;
	char*	text;

	do {
		text = nil;
		qlock(&msg.lck);
		if(msg.text != nil && lastvers != msg.vers){
			text = strdup(msg.text);
			lastvers = msg.vers;
		}
		qunlock(&msg.lck);
		if (text != nil){
			write(fd, text, strlen(text));
			free(text);
		}
		sleep(5 * 1000);
	} while(!exiting);
	fprint(2, "panel exiting\en");
	exits(nil);
}
.ps +1
.P2
.LP
Here, we moved the
.CW write
outside of the critical region. Because the panel itself (i.e., its file) is not
being shared in our program, we do not need to protect from races while
writing it. We created one process for each panel and that was nice.
.PP
But we can do much better. Are there races when multiple processes are
just
.I reading
a data structure? While nobody is changing anything, there are no races!
During a long time, all the panel processes will be polling
.CW msg ,
reading its memory, and the input process will be just blocked waiting
for a line. It would be nice to let all the panel processes to access the
data structure at the same time, in those periods when nobody is
modifying
.CW msg .
.PP
Plan 9 has
.B "read/write locks" .
.ix [WRLock]
A read/write lock, or
.CW RWLock ,
is similar to a queuing lock. However, it makes a distinction between
.I readers
and
.I writers
of the resource being protected by the lock. Multiple readers are admitted
to hold the very same
.CW RWLock ,
at the same time. However, only one writer can hold a
.CW RWLock ,
and in this case there can be no other reader or writer. This is also called a
.I multiple-reader
.I single-writer
lock.
.ix "multiple reader
.ix "single writer
.PP
Processes that want to acquire the lock for reading must use
.CW rlock
and
.CW runlock .
.ix [rlock]
.ix [runlock]
.P1
; sig rlock runlock
	void rlock(RWLock *l)
	void runlock(RWLock *l)
.P2
.LP
Processes that want to acquire the lock for writing must use
.CW wlock ,
and
.CW wunlock .
.ix [wlock]
.ix [wunlock]
.P1
; sig wlock wunlock
	void wlock(RWLock *l)
	void wunlock(RWLock *l)
.P2
.LP
The improved version for our program requires a change in the data structure,
that must use a
.CW RWLock
now.
.P1
struct Msg {
	RWLock	lck;	// multiple readers/one writer.
	char*	text;	// for the message
	ulong	vers;	// for the message
}
.P2
.LP
The new code for
.CW panelproc
must acquire a lock for reading, but is otherwise the same.
.P1
void
panelproc(int fd)
{
	\fI...as before...\fP
		rlock(&msg.lck);
		if(msg.text != nil && lastvers != msg.vers){
			text = strdup(msg.text);
			lastvers = msg.vers;
		}
		runlock(&msg.lck);
	\fI...as before...\fP
}
.P2
.LP
And the process writing to the data structure now requires a write lock.
.P1
void
reader(void)
{
	\fI...as before...\fP
		wlock(&msg.lck);
		free(msg.text);
		msg.text = strdup(buf);
		msg.vers++;
		wunlock(&msg.lck);
	\fI...as before...\fP
}
.P2
.LS
.PS
down
[ right
	box invis "Writer"
	line right 1 "resource" "locked"
	line right 3 dotted
]
[ right
	box invis "Reader 1"
	line right 1 dotted
	line right 1 "resource" "locked"
	line right 2 dotted
]
[ right
	box invis "Reader 2"
	line right 2 dotted
	line right 1 "resource" "locked"
	line right 1 dotted
]
[ right
	box invis "Reader 3"
	line right 3 dotted
	line right 1 "resource" "locked"
]
.PE
.LE F Multiple readers make turns to read when using a queuing lock.
.LP
If you want to
.I feel
the difference between the version using
.CW QLocks
and the one using
.CW RWLocks ,
try to increase the number of panels to 15, and make the
.CW panelprocs
take a little bit more time to read
.CW msg ,
for example, by using
.CW sleep
to make them hold the lock for some time. In the first time, messages will
slowly come out to the panels (or your standard output in this case).
If each process holds the lock for a second, the 15th process acquiring the lock
will have to wait at least 15 seconds. In the second
case, all of the pannels will be quickly updated. Furthermore, using the
.CW RWLock
keeps the resource locked for less time, because the readers are now allowed
to overlap.
.PP
This is shown in figures [[!readers queuing!]] and
[[!readers share lock!]]. Both figures assume that initially, the writer and all
the readers try to acquire the lock (the time advances to the right).
When using a queueing lock, look at what
happens to the readers. Compare with the next figure, which corresponds to
using a read/write lock. 
.LS
.PS
down
[ right
	box invis "Writer"
	line right 1 "resource" "locked"
	line right 3 dotted
]
[ right
	box invis "Reader 1"
	line right 1 dotted
	line right 1 "resource" "locked"
	line right 2 dotted
]
[ right
	box invis "Reader 2"
	line right 1.1 dotted
	line right 1 "resource" "locked"
	line right 1.9 dotted
]
[ right
	box invis "Reader 3"
	line right 1.2 dotted
	line right 1 "resource" "locked"
	line right 1.8 dotted
]
.PE
.LE F Multiple readers may share the lock at the same time using a read/write lock.
.PP
.ix "lock contention
When there is not much competition to acquire the lock, or when there are not
many readers, the difference may be unnoticed. However, locks heavily used
with many processes that just want to read the data, can make a difference between
both types of locks.
.BS 2 "Rendezvous
.PP
A primitive provided to synchronize several processes is
.CW rendezvous .
.ix [rendezvous]
.ix synchronization
It has this name because it allows two different processes to rendezvous, i.e.,
to meet, at a particular point in their execution. This is the interface.
.P1
; !!sig rendezvous
	void* rendezvous(void* tag, void* value)
.P2
.LP
When a process calls
.CW rendezvous
with a given
.CW tag ,
.ix "rendezvous tag
the process blocks until another process calls
.CW rendezvous
with the same
.CW tag .
Thus, the first process to arrive to the
.CW rendezvous
will block and wait for the second to arrive. At that point, the values
both processes gave as
.CW value
are exchanged. That is,
.CW rendezvous
for each process returns the
.CW value
passed to the call by the other process. See figure [[!rendezvous!]].
.LS
.PS
.ps -2
right
A: [ down
	"Process A"
	line .5
	box ht .2 invis "calls: \f(CWrendezvous(tag, \"hi\")\fP"
	line .5 dotted " Waiting..." ljust
	R: box ht .2 invis "call returns: \f(CW\"there\"\fP"
	line .3
	arrow .2 "\fB time\fP" ljust
]
move 1.5
B: [ down
	"Process B"
	line 1
	box ht .2 invis "calls: \f(CWrendezvous(tag, \"there\")\fP"
	R: box ht .2 invis "call returns: \f(CW\"hi\"\fP" ljust
	line .3
	arrow .2 "\fB time\fP" ljust
]
arrow <-> from A.R + .5,0 to B.R - .2,0 "rendezvous" above
.ps +2
.PE
.LE F Two processes doing a rendezvous.
.PP
The tag used for the
.CW rendezvous
represents the meeting-point where both processes want to rendezvous. The
ability to exchange values makes the primitive more powerful, and converts it
into a generic communication tool for use when synchronization is required.
In general, any two processes may rendezvous. It is not necessary for them to
share memory. Of course, the values supplied as
.CW tags
and
.CW values
cannot be used to point to shared variables when the processes are not sharing
memory, but that is the only limitation. The values are still exchanged even if
memory is not shared.
.PP
The following program creates a child process, which is supposed to run an HTTP
server. To execute nicely in the background, all the work is done by the child,
and not by the parent. This way, the user does not need to add an additional
.CW &
when starting the program from the shell. However, before doing the actual work,
the child must initialize its data structures and perhaps read some configuration
files. This is a problem, because initialization could fail. If it fails, we want the
parent process to
.CW exits
with a non-null status, to let the shell know that our program failed.
.PP
One way to overcome this problem is to make the parent process wait until
the child has been initialized. At that point, it is safe for the parent to call
.CW exits ,
and let the child do the work if everything went fine. This can be done using
.CW rendezvous
like follows.
.so progs/rendez.c.ms
.ix [rendez.c]
.LP
Note that each process calls
.CW rendezvous
.I once .
The parent calls it to rendezvous with the child, after it has initialized. The child
calls it to rendezvous with the parent, and report its initialization status.
As the tag, we used the address for
.CW main .
It does not really matter which tag we use, as long as it is the same address. Using
.CW &main
seemed like a good idea to make it explicit that we are doing a rendezvous just for
this function. As values, the child gave
.CW -1
(as a pointer, sic)
to report failure, or
.CW 0
(as a pointer) to report success. As we said,
.CW rendezvous
works although these processes are not sharing memory.
.PP
To test this program, we used an utterly complex implementation for HTTP
.P1
void
httpservice(void)
{
	sleep(50000);
}
.P2
.LP
That is the best we could do given the so many standards that are in use today
for the Web. Also, we tried the program with two implementations for
.CW httpinit ,
one returning
.CW 0
and another returning
.CW -1 ,
like this one.
.P1
int
httpinit(void)
{
	sleep(2000);
	return 0;
}
.P2
.LP
And this is an example execution for both versions of the program.
.P1
; 8.rendez
httpinit failed
; 8.rendez		\fRAfter two seconds we got another prompt.\fP
; ps | grep 8.rendez
nemo    7076    0:00   0:00   24K Sleep    8.rendez
.P2
.BS 2 "Sleep and wakeup
.PP
.ix polling
.ix sleep
.ix wakeup
Going back to our airport panels program, it is a resource waste to keep all
those
.CW panelprocs
polling just to check if there is a new message. Another abstraction, provided
by the functions
.CW rsleep ,
.CW rwakeup ,
and
.CW rwakeupall
.ix [rsleep]
.ix [rwakeup]
.ix [rwakeupall]
may be more appropriate. By the way, do not confuse this with the function
.CW sleep (2)
that puts the process to sleep for some time. It is totally different.
.PP
The idea is that a process that wants to use a resource, locks the resource.
The resource is protected by a lock,
and all operations made to the resource must keep the lock held. That is not new.
In our program, processes updating or consulting
.CW msg
must have
.CW msg
locked during these operations.
.PP
Now suppose that, during an operation (like consulting the message), the
process decides that it cannot proceed (e.g., because the message
is not new, and we only want new messages). Instead of releasing the lock
and trying again later, the process may call
.CW rsleep .
This puts the process to sleep unconditionally. The process goes to sleep
because it requires some condition to be true, and it finds out that the
condition does not hold and calls
.CW rsleep.
.PP
At a later time, another process may make the condition true (e.g.,
the message is updated). This other process calls
.CW rwakeup ,
to wake up one of the possibly many processes waiting for the condition to
hold.
.PP
The idea is that
.CW rsleep
is a temporary sleep waiting for a condition to hold. And it always happens in
the middle of an operation on the resource, after checking out if the
condition holds. This function releases
the lock before going to sleep, and re-acquires it after waking up. Therefore,
the process can nicely sleep inside its critical region, because the lock is
not held while sleeping. If the lock was kept held while sleeping, the process
would never wake up. To wake up, it requires another process to call
.CW rwakeup .
Now, a process can only call
.CW rwakeup
while holding the resource, i.e., while holding the lock. And to acquire the lock,
the sleeper had to release it before sleeping.
.PP
The behavior of
.CW rwakeup
is also appropriate with respect to the lock of the resource. This function wakes
up one of the sleepers, but the caller continues with the resource locked and
can complete whatever remains of its critical region. When this process completes
the operation and releases the lock, the awakened one may re-acquire it and continue.
.PP
.ix starvation
Re-acquiring the lock after waking up might lead to starvation, when there is
always some process coming fast to use the resource and acquiring the lock
even before the poor process that did wake up can acquire it again. To avoid this,
it is guaranteed that a process that is awakened will acquire the lock sooner than
any other newcomer. In few words, you do not have to worry about this.
.PP
A variant of
.CW rwakeup ,
called
.CW rwakeupall ,
wakes up
.I all
the processes sleeping waiting for the condition to hold. Although many processes
may be awakened, they will re-acquire the lock before returning from
.CW rsleep .
Therefore, only one process is using the resource at a time and we still have
mutual exclusion for the critical region.
.PP
The data structure
.CW Rendez
.ix [Rendez]
represents the rendezvous point where processes sleeping and processes
waking up meet. You can think of it as a data structure representing the condition
that makes one process go to sleep.
.P1
typedef
struct Rendez
{
	QLock	*l;
	\fI...\fP
} Rendez;
.P2
.LP
The field
.CW l
must point to the
.CW QLock
protecting the resource (used also to protect the
.CW Rendez ).
Using this abstraction, and its operations,
.P1
; sig rsleep rwakeup rwakeupall
	void rsleep(Rendez *r)
	int rwakeup(Rendez *r)
	int rwakeupall(Rendez *r)
.P2
.LP
we can reimplement our airport panels program. We start by redefining
our data structure and providing two operations for using it.
.P1
typedef struct Msg Msg;
struct Msg {
	QLock	lck;	// to protect the other fields
	Rendez	newmsg;	// to sleep waiting for a new message.
	char*	text;	// for the message
};
.P2
.P1
void	wmsg(Msg* m, char* newtext);
char*	rmsg(Msg* m);
.P2
.LP
The operation
.CW wmsg
writes a new the text for the message. The operation
.CW rmsg
reads a new text for the message. The idea is that a call to
.CW rmsg
will always sleep until the message changes. When
.CW wmsg
changes the message, it will wake up all the processes waiting for the
new message.
.PP
This is
.CW rmsg .
It locks the message, and goes to sleep waiting for the condition
(need a new message) to hold. After waking up, we still have the lock.
Of course, any other process could use the resource while we were sleeping,
but this is not a problem because all we wanted was to wait for a new message,
and now we have it. Thus, the function makes a copy of the new message, releases
the lock, and returns the new message to the caller.
.P1
char*
rmsg(Msg* m)
{
	char*	new;

	qlock(&m->lck);
	rsleep(&m->newmsg);
	new = strdup(m->text);
	qunlock(&m->lck);
	return new;
}
.P2
.LP
And this is
.CW wmsg .
It locks the resource, and updates the message. Before returning, it wakes up
anyone waiting for a new message.
.P1
void
wmsg(Msg* m, char* newtext)
{
	qlock(&m->lck);
	free(m->text);
	m->text = strdup(newtext);
	rwakeupall(&m->newmsg);
	qunlock(&m->lck);
}
.P2
.LP
Now things are simple for our program, the panel process  may just call
.CW rmsg
to obtain a new message. There is no need to bother with concurrency
issues here. The function
.CW rmsg
is our interface for the message, and it cares about it all.
.P1
void
panelproc(int fd)
{
	ulong	lastvers = -1;
	char*	text;

	while(!exiting){
		text = rmsg(&msg);
		write(fd, text, strlen(text));
		free(text);
	}
	fprint(2, "panel exiting\en");
	exits(nil);
}
.P2
In the same way, the reader process is also simplified. It calls
.CW wmsg
and forgets about concurrency as well.
.P1
void
reader(void)
{
	char	buf[512];
	int	nr;

	for(;;){
		nr = read(0, buf, sizeof(buf)-1);
		if (nr <= 0)
			break;
		buf[nr] = 0;
		wmsg(&msg, buf);
	}
	exiting = 1;
	exits(nil);
}
.P2
.LP
The rest of the program stays the same. However, this initialization is now
necessary, because the
.CW Rendez
needs a pointer to the lock.
.P1
msg.newmsg.l = &msg.lck;
.P2
.LP
If you try this program, you will notice a difference regarding its responsiveness.
There are no polls now, and no delays. As soon as a new message is updated,
the panels are updated as well. Because of the interface we provided, the
write for the panels is kept outside of the critical region. And because of dealing
with concurrency inside the resource operations, callers may be kept unaware of
it. That said, note that the program still must care about how to start and
terminate in a clean way.
.PP
It is very usual to handle concurrency in this way, by implementing operations
that lock the resource before they do anything else, and release the lock
before returning. A module implemented following this behavior is called a
.B monitor .
This name was used by 
some programming languages that provided syntax for this construct, without
requiring you to manually lock and unlock the resource on each operation.
The abstractions used to wait for conditions inside a monitor, similar to our
.CW Rendez ,
are called
.B "condition variables" ,
because those languages used this name for such time.
.BS 2 "Shared buffers
.PP
.ix "bounded buffer"
.ix "shared buffer
.ix "producer/consumer"
The bounded buffer is a classical problem, useful to learn a little bit of
concurrent programming, and also useful for the real life. The problem
states that there is a shared buffer (bounded in size). Some processes try to
put things into the buffer, and other processes try to get things out of the buffer.
The formers are called
.I producers ,
and the latter are called
.I consumers .
See figure [[!bounded buffer!]]
.LS
.PS
	circlerad=.3
P: [ 
	circlerad=.3
	down
	P1: circle "producer"
	move .2
	P2: circle "producer"
	move .2
	P3: circle "producer"
]
right
move .5
B: [ for i = 0 to 3 do { box wid .2 ht .2 fill  } ; for i = 0 to 8 do { box wid .2 ht .2 } ]
move .5
C: [ 
	circlerad=.3
	down
	C1: circle "consumer"
	move .2
	C2: circle "consumer"
]
arrow from P.P1 to B.nw chop
arrow from P.P2 to B.w chop
arrow from P.P3 to B.sw chop
arrow from B.e to C.C1 chop
arrow from B.e to C.C2 chop
reset
.PE
.LE F The bounded buffer problem.
.PP
The problem is synchronizing both producers and consumers. When a producer
wants to put something in the buffer, and the buffer is full, the producer must wait
until there is room in the buffer. In the same way, when a consumer wants to
take something from an empty buffer, it must wait until there is something to take.
This problem happens for many real life situations, whenever some kind of process
produces something that is to be consumed by other processes. The buffer kept
inside a pipe, together with the process(es) writing to the pipe, and the ones reading
from it, make up just the same problem.
.ix pipe
.PP
To solve this problem, we must declare our data structure for the buffer and
two operations for it,
.CW put ,
and
.CW get .
The buffer must be protected, and we are going to use a
.CW QLock
for that purpose (because we plan to use
.CW rsleep
and
.CW rwakeup ).
The operation
.CW put
will have to sleep when the buffer is full, and we need a
.CW Rendez
called
.CW isfull
to sleep because of that reason. The operation
.CW get
will go to sleep when the buffer is empty, which makes necessary another
.CW isempty
.CW Rendez .
.ix [qlock]
.ix [Rendez]
To store the messages we use an array to implement a queue. The array is
used in a circular way, with new messages added to the position pointed to by
.CW tl .
Messages are extracted from the head, pointed to by
.CW hd .
.P1
.ps -1
typedef struct Buffer Buffer;
struct Buffer {
	QLock	lck;
	char*	msgs[Nmsgs];	// messages in buffer
	int	hd;		// head of the queue
	int	tl;		// tail. First empty slot.
	int	nmsgs;		// number of messages.
	Rendez	isfull;		// wait for room
	Rendez	isempty;	// wait for item to get
};
.ps +1
.P2
.LP
This is our first operation,
.CW put .
.ix [put]
It checks that the buffer is full, and goes to sleep if that is the case.
If the buffer was not full, or after waking up because it is no longer full,
the message is added to the queue.
.P1
void
put(Buffer* b, char* msg)
{
	qlock(&b->lck);
	if (b->nmsgs == Nmsgs)
		rsleep(&b->isfull);
	b->msgs[b->tl] = strdup(msg);
	b->tl = ++b->tl % Nmsgs;
	b->nmsgs++;
	if (b->nmsgs == 1)
		rwakeup(&b->isempty);
	qunlock(&b->lck);
}
.P2
.LP
Note how this function calls
.CW rwakeup(&b->isempty)
when the buffer ceases to be empty. It could be that some processes were
sleeping trying to get something, because the buffer was empty. This function,
which changes that condition, is responsible for waking up one of such
processes. It wakes up just one, because there is only one thing to get
from the buffer. If there are more processes sleeping, trying to get, they
will be waken up as more messages are added by further calls to
.CW put
in the future.
.PP
The function
.CW get
.ix [get]
is the counterpart for
.CW put .
When there is no message to get, it sleeps at
.CW isempty .
Once we know for sure that there is at least one message to consume,
it is removed from the head of the queue and returned to the caller.
.P1
char*
get(Buffer* b)
{
	char*	msg;

	qlock(&b->lck);
	if (b->nmsgs == 0)
		rsleep(&b->isempty);
	msg = b->msgs[b->hd];
	b->hd = ++b->hd % Nmsgs;
	b->nmsgs--;
	if (b->nmsgs == Nmsgs - 1)
		rwakeup(&b->isfull);
	qunlock(&b->lck);
	return msg;
}
.P2
.LP
Note how
.CW get
is also responsible for awakening one process (that might be sleeping)
when the buffer is no longer full. Both functions are quite symmetric. One
puts items in the buffer (and requires empty slots), the other puts empty
slots in the buffer (and requires items).
.PP
The data structure is initialized by calling
.CW init .
.P1
void
init(Buffer *b)
{
	// release all locks, set everything to null values.
	memset(b, 0, sizeof(*b));
	// set the locks used by the Rendezes
	b->isempty.l = &b->lck;
	b->isfull.l = &b->lck;
}
.P2
.LP
To play with our implementation,
we are going to create two processes the produce messages
and two more process that consume them and print the consumed ones to
standard output. Also, to exercise the code when the buffer gets full, we
use a ridiculous low size.
.so progs/pc.c.ms
.ix [pc.c]
.LP
The producers receive a letter as their name, to produce messages like
.CW a0 ,
.CW a1 ,
etc., and
.CW b0 ,
.CW b1 ,
etc.
.ix "program termination
To terminate the program cleanly, each producer puts a final nil message.
When a consumer receives a nil message from the buffer, it terminates.
And this is the program output.
.P1
; 8.pc
a0 b0 a1 b1 a2 b2 a3 b3 a4 b4 ; 
.P2
.LP
As you can see, messages are inserted in a very fair way.
Changing a little bit
.CW put ,
and
.CW get ,
would let us know if the buffer is ever found to be full or empty. This is the change
for
.CW get .
.P1
char*
get(Buffer* b)
{
	\fI...as before...\fP
	if (b->nmsgs == 0){
		print("<empty>\en");
		rsleep(&b->isempty);
	}
	\fI...as before...\fP
}
.P2
.LP
The change for
.CW put
is done in a similar way, but printing
.CW <full>
instead. And this is what we find out.
.P1
; 8.pc
<empty> <empty> a0 b0 <full> <full>	\fInewline supplied by us\fP
a1 b1 <full> <full> a2 b2 <full> <full> a3 b3 a4 b4 ;
.P2
.LP
It seems that initially both consumers try to get messages out of the buffer,
and they find the buffer empty. Later, producers insert
.CW a0
and
.CW b0 ,
and consumers seem to be awaken and proceed. Because both consumers were
sleeping and the synchronization mechanism seems to be fair, we can assume that
.CW a0
is printed by the one consumer and
.CW b0
by the other. It seems that by this time both producers keep on inserting items
in the buffer until it gets full. Both go to sleep. And for the rest of the time it
looks like producers are faster and manage to fill the buffer, and consumers have
no further problems and will never find the buffer empty from now on.
.PP
In any case, the only thing we can say is that the code for dealing with a full
buffer (and an empty buffer) has been exercised a little bit. We can also affirm
that no process seems to remain waiting forever, at least for this run.
.P1
; ps | grep 8.pc
;
.P2
.LP
However, to see if the program is correct or not, the only tool you have is just
careful thinking about the program code. Playing with example scenarios, trying
hard to show that the program fails. There are some formal tools to verify if
an implementation for a concurrent program has certain properties or not, but
you may make mistakes when using such tools, and therefore, you are on your own
to write correct concurrent programs.
.BS 2 "Other tools
.LP
A popular synchronization tool, not provided by Plan 9, is a
.B semaphore .
.ix "semaphore tickets
.ix "semaphore value
A semaphore is an abstraction that corresponds to a box with tickets to use
a resource. The inventor of this abstraction made an analogy with train
semaphores, but we do not like trains.
.PP
The idea behind a semaphore is simple. To use a resource, you need a ticket.
The operation
.CW wait
.ix [wait]
waits until there is a ticket in the semaphore, and picks up one.
When you are no longer using the resource, you may put a ticket back into
the semaphore. The operation
.CW signal
.ix [signal]
puts a new ticket into the semaphore. Because of the analogy with train semaphores,
.CW wait
is also known as
.CW down
(to lower a barrier) and
.CW signal
is also known as
.CW up
(to move up a barrier). In general, you will find either
.CW up
and
.CW down
.ix [up]
.ix [down]
or
.CW signal
and
.CW wait
as operations.
.PP
Internally, a semaphore is codified using an integer to count the number of
tickets in the box represented by the semaphore. When processes call
.CW wait
and find no tickets in the semaphore,
.CW wait
guarantees that they are put into sleep. Furthermore, such processes will be
awakened (upon arrival of new tickets) in a fair way. An initial integer value may be
given to a semaphore, to represent the initial number of tickets in the box. This
could be the interface for this abstraction.
.P1
.ps -1
Sem*	newsem(int n);	// create a semaphore with n tickets
void	wait(Sem* s);	// acquire a ticket (may wait for it)
void	signal(Sem* s);	// add a ticket to the semaphore.
.ps +1
.P2
.LP
.ix "mutual exclusion
Mutual exclusion can be implemented using a semaphore with just one ticket.
Because there is only one ticket, only one process will be able to acquire it.
This should be done before entering the critical region, and the ticket must be
put back into the semaphore after exiting from the critical region. Such a semaphore
is usually called a
.CW mutex .
.ix mutex
This is an
example.
.P1
Sem* mutex = newsem(1);
.I ...
wait(mutex);
.I "critical region here"
signal(mutex);
.I ...
.P2
Also, because a
.CW wait
on an empty semaphore puts a process to sleep, a semaphore with no
tickets can be used to sleep processes. For example, this puts the process
executing this code to sleep, until another process calls
.CW signal(w);
.P1
Sem* w = newsem(0);
.I ...
wait(w);
.I ...
.P2
.LP
This tool can be used to synchronize two processes, to make one await until
the other executes certain code. Remember the HTTP server initialization example
shown before. We could use an empty semaphore, and make the parent call
.P1
wait(w)
.P2
to await for the initialization of the child. Then, the child could call
.P1
signal(w)
.P2
.LP
to awake the parent once it has initialized. However, this time, we cannot exchange
a value as we could using
.CW rendezvous .
.PP
.ix "bounded buffer
As a further example, we can implement our bounded-buffer program using
semaphores. The data type must have now one semaphore with just one ticket, to
achieve mutual exclusion for the buffer. And we need two extra semaphores.
Processes that want to put an item in the buffer require a hole where to put it.
Using a semaphore with initially
.CW Nmsgs
tickets, we can make the producer acquire its holds nicely. One ticket per hole.
When no more holes are available to put a message, the producer will sleep
upon a call to
.CW wait(sholes) .
In the same way, the consumer requires messages, and there will be zero messages
available, initially.
.P1
.ps -2
typedef struct Buffer Buffer;
struct Buffer {
	Sem*	mutex;		// for mutual exclusion
	char*	msgs[Nmsgs];	// messages in buffer
	int	hd;		// head of the queue
	int	tl;		// tail. First empty slot
	int	nmsgs;		// number of messages
	Sem*	smsgs;		// (0 tickets) acquire a msg
	Sem*	sholes;;	// (Nmsgs tickets) acquire a hole
};
.ps +2
.P2
.LP
The implementation for
.CW put
is similar to before. But there are some remarkable differences.
.P1
void
put(Buffer* b, char* msg)
{
	wait(b->sholes);
	wait(b->mutex);
	b->msgs[b->tl] = strdup(msg);
	b->tl = ++b->tl % Nmsgs;
	b->nmsgs++;
	signal(b->mutex);
	signal(b->smsgs);
}
.P2
.LP
.ix "producer/consumer
Before even trying to put anything in the buffer, the producer tries to get
a hole. To do so, it acquires a ticket from the semaphore representing the holes
available. If there are no tickets, the producer sleeps. Otherwise, there is a
hole guaranteed. Now, to put the message in the hole acquired, a semaphore
called
.CW mutex ,
with just one ticket
for providing mutual exclusion,  is used. Upon acquiring the only slot for
executing in the critical region, the producer adds the message to the buffer.
Also, once we have done our work, there is a new message in the buffer. A
new ticket is added to the semaphore representing tickets to maintain it
consistent with the reality.
.PP
The code for a consumer is equivalent.
.P1
char*
get(Buffer* b)
{
	char*	msg;

	wait(b->smsgs);
	wait(b->mutex);
	msg = b->msgs[b->hd];
	b->hd = ++b->hd % Nmsgs;
	b->nmsgs--;
	signal(b->mutex);
	signal(b->sholes);
	return msg;
}
.P2
.LP
Semaphores are to be handled with care. For example, changing the first two
lines above with
.P1
wait(b->mutex);
wait(b->smsgs);
.P2
.LP
is going to produce a
.I deadlock .
.ix deadlock
First, the consumer takes the mutex (ticket) for itself. If it happens now
that the buffer is empty, and
.CW smsgs
has no tickets, the consumer will block forever. Nobody would be able to wake
it up, because the producer will not be able to acquire the
.CW mutex
for itself. It is
.I very
dangerous to go to sleep with a lock held, and it is also very
dangerous to go to sleep with a mutex taken. Only a few times it might be the
right thing to do, and you must be sure that there is no deadlock produced as
a result.
.PP
Note that a semaphore is by no means similar to
.CW rsleep
and
.CW rwakeup .
Compare
.P1
rwakeup(r);
rsleep(r);
.P2
.LP
with
.P1
signal(s);
wait(s);
.P2
.LP
The former wakes up any sleeper at
.CW r ,
and then goes to sleep. Unconditionally.
The latter, adds a ticket to a semaphore. If nobody consumes it between
the two sentences, the call to
.CW wait
will
.I not
sleep.
Remember that a semaphore is used to model slots available for using a
particular resource. On the other hand, sleep/wakeup are more related to
conditions that must hold for you to proceed doing something.
.PP
We said that Plan 9 does not supply semaphores. But there is an easy
way to implement them. You need something to put tickets into. Something that
when wanting to get a ticket, blocks until there is one ticket available. And returns
any ticket available immediately otherwise. It seems that pipes fit right into the
job. This is our semaphore:
.P1
typedef struct Sem Sem;
struct Sem {
	int fd[2];
};
.P2
.LP
To create a semaphore, we create a pipe and put as many bytes in it as tickets
must be initially in the semaphore.
.P1
Sem*
newsem(int n)
{
	Sem*	s;

	s = malloc(sizeof(Sem));
	if (pipe(s->fd) < 0){
		free(s);
		return nil;
	}
	while(n-- > 0)
		write(s->fd[1], "x", 1);
	return s;
}
.P2
.LP
A
.CW signal
must just put a ticket in the semaphore.
.P1
void
signal(Sem* s)
{
	write(s->fd[1], "x", 1);
}
.P2
.LP
A
.CW wait
must acquire one ticket.
.P1
void
wait(Sem* s)
{
	char buf[1];

	read(s->fd[0], buf, 1);
}
.P2
.LP
We do not show it, but to destroy a semaphore it suffices to close the pipe
at both ends and release the memory for the data structure. Given the
implementation we made, the only limitation is that a semaphore may hold
no more tickets than bytes are provided by the buffering in the pipe. But
that seems like a reasonable amount of tickets for most purposes.
.PP
Another restriction to this implementation is that the semaphore must be
created by a common ancestor (e.g., the parent) of processes sharing it.
Unless such processes are sharing their file descriptor set.
.SH
Problems
.IP 1
Locate the synchronization construct in programming languages you use.
.IP 2
Do shell programs have race conditions?
.IP 3
Implement a concurrent program simulating a printer spooler. It must
have several processes. Some of them generate jobs for printing (spool
print jobs) and two other ones print jobs. Needless to say that the program
must not have race conditions.
.IP 4
Implement a semaphore using shared variables protected with (spin) 
locks. Would you use it? Why?
.IP 5
Assume you have monitors (invent the syntax). Implement a sempahore
using monitors.
.ds CH
.bp
 \c
.bp
 \c
