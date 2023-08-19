.so tmacs
.BC 8 "Using the Shell
.BS 2 "Programs are tools
.LP
.ix tools
.ix "command
.ix "using [rc]
.ix "combining commands
.ix UNIX
In Plan 9, programs are tools that can be combined to perform very
complex tasks. In most other systems, the same applies, although it tends to
be a little more complex. The idea is inherited from UNIX,
each program is meant to perform a single task, and perform it well.
.PP
But that does not prevent you to combine existing programs to do
a wide variety of things. In general, when there is a new job to be done,
these are your options, listed from the easiest one to the hardest one:
.IP 1
Find a program that does the job. It is utterly important to look at the manual
before doing anything. In many cases, there will be a program that does what
we want to do. This also applies when programming in C, there are many functions
in the library that may greatly simplify your programs.
.IP 2
Combine some programs to achieve the desired effect. This is where the shell
gets relevance. The shell is the programming language you use to combine the
programs you have in a simple way. Knowing how to use it may relieve you from
your last resort.
.ix "programming language
.IP 3
The last resort is to write your own program for doing the task you are considering.
Although the libraries may prove invaluable as helpers, this requires much more
time, specially for debugging and testing.
.ix "debugging
.LP
To be able to use shell effectively, it helps to follow conventions that may be
useful for automating certain tasks by using simple shell programs. For example,
writing each C function using the style
.P1
void
func(...args...)
{
}
.P2
permits using this command line to find where function
.CW foo
is defined:
.P1
; grep -n  '^foo\e(' *.c
.P2
.LP
By convention, we declared functions by writing their names at the
beginning of a new line, immediately followed by the argument list. As a result,
we can ask
.CW grep
.ix [grep]
to search for lines that have a certain name at the beginning of line, followed by an
open parenthesis. And that helps to quickly locate where a function is defined.
.PP
The
shell is very good for processing text files, and even more if the data has certain
.ix "text files
.ix "processing data
regularities that you may exploit. The shell provides a full programming language where
commands are to be used as elementary statements, and data is handled in most cases
as plain text.
.PP
In this chapter we will see how to use
.CW rc
as a programming language, but no one is going to help
you if you don't help yourself in the first place. Machines love regular structures,
so it is better to try to do the same thing in the same way everywhere. If it can
be done in a way that can simplify your job, much better.
.PP
.ix "file interface
Plan 9 is a nice example of this is practice. Because all the resources are
accessed using the same interface (a file interface), all the programs that
know how to do particular things to files can be applied for all the resources in
the system. If many different interfaces were used instead, you would need
many different tools for doing the same operation to the many different
resources you find in the computer.
.PP
.ix XML
This explains the popularity of XML and other similar data representations,
which are attempts to provide a common interface for operating on many
different resources. But the idea is just the same.
.BS 2 "Lists
.LP
.ix "[rc] lists
.ix "shell variable
.ix "environment variable
.ix "shell program
The shell includes lists as its primary data structure, indeed its only data
structure. This data type is there to make it
easier for you to write shell programs. Because shell variables are
just environment variables, lists are stored as strings, the only value
a environment variable may have. This is the famous abc list:
.P1
; x=(a b c)
; echo $x
a b c
.P2
.LP
It is just syntax. It would be the same if we had typed any
of the following:
.P1
; x=(a (b c))
; echo $x
a b c
; x=(((a) (b)) (c))
; echo $x
a b c
.P2
.LP
It does not matter how you nest the same values using multiple
parenthesis. All of them will be the same, namely,
just
.CW "(a b c)" .
What is the actual value of the environment variable for
.CW x ?
We can see it.
.P1
; xd -c /env/x
0000000   a 00  b 00  c 00
0000006 
.P2
.LP
Just the three strings,
.CW a ,
.CW b ,
and
.CW c .
.CW Rc
follows the C convention for terminating a string, and separates all the
values in the list with a null byte. This happens even for environment variables
that are a list of a single word.
.P1
; x=3
; xd -c /env/x
0000000   3 00
0000002 
.P2
.LP
The implementation for the library function
.CW getenv
.ix [getenv]
.ix string
replaces the null bytes with spaces, and that is why a
.CW getenv
for an
.CW rc
list would return the words in the list separated by white space. This
is not harmful for C, as a 0 would be because 0 is used to terminate a string in C.
And it is what you expect after using the variable in the shell.
.PP
.ix "script argument
.ix [$*]
The variable holding the arguments for the shell interpreting a shell script
is also a list. The only difference is
that the shell initializes the environment variable for
.CW $*
automatically, with the list for the arguments supplied to it, most likely, by
giving the arguments to a shell script.
.PP
Given a variable, we can know its length. For
any variable, the shell defines another one to report its length. For example,
.ix "variable length
.P1
; x=hola
; echo $#x
1
; x=(a b c)
; echo $#x
3
.P2
.LP
The first variable was a list with just one word in it.
As a result, this is the way to print the number of arguments given to
a shell script,
.ix [$#*]
.P1
echo $#*
.P2
.LP
because that is the length of
.CW $* ,
which is a list with the arguments (stored as an environment variable).
.PP
To access the
.I n -th
element of a list, you can use
.CW $var(n) .
.ix "list indexing
However, to access the
.I n -th
argument in a shell script you are expected to use
.CW $n .
An example for our popular abc list follows:
.P1
; echo $x(2)
b
; echo $x(1)
a
.P2
.LP
Lists permit doing funny things. For example, there is a concatenation
operator that is best shown by example.
.ix "concatenation operator
.ix "list concatenation
.P1
; x=(a b c)
; y=(1 2 3)
echo $x^$y
a1 b2 c3
.P2
.LP
The
.CW ^
operator, used in this way, is useful to build
expressions by building separate parts (e.g, prefixes
and suffixes), and then combining them. For example, we could write
a script to adjust permissions that might set a variable
.CW ops
to decide if we should add or remove a permission, and then a variable
.CW perms
to list the involved permissions. Of course in this case it would be easier
to write the result by hand. But, if we want to generate each part separately, now we can:
.P1
; ops=(+ - +)
; perms=(r w x)
; echo $ops^$perms afile
+r -w +x afile
.P2
.LP
Note that concatenating two variables of length 1 (i.e., with a single word each) is a particular
case of what we have just seen. Because this is very common, the shell allows you to omit the
.CW ^ ,
which is how you would do the same thing when using a UNIX shell. In the example below,
concatenating both variables is
.I exactly
the same than it would have been writing
.CW a1
instead.
.P1
; x=a
; y=1
; echo $x^$y
a1
; echo $x$y
a1
;
.P2
.LP
A powerful use for this operator is concatenating a list with another one that has a single
element. It saves a lot of typing. Several examples follow. We use
.CW echo
in all of them to let you see the outcome.
.P1
; files=(stack run cp)
; echo $files^.c
stack.c run.c cp.c
; echo $files^.h
stack.h run.h cp.h
; rm $files^.8
; echo (8 5)^.out
8.out 5.out
; rm (8 5)^.out
.P2
.LP
Another example. These two lines are equivalent:
.P1
; cp (/source/dir /dest/dir)^/a/very/long/path
; cp /source/dir/a/very/long/path /dest/dir/a/very/long/path
.P2
.LP
And of course, we can use variables here:
.P1
; src=/source/dir
; dst=/dest/dir
; cp ($src $dst)^/a/very/long/path
.P2
.LP
Concatenation of lists that do not have the same number of elements and
do not distribute, because none of them has a single element, is illegal in
.CW rc .
Concatenation of an empty list is also forbidden, as a particular case of this
rule.
.ix "distributive concatenation
.P1
; ops=(+ - +)
; perms=(w x)
; echo $ops^$perms
rc: mismatched list lengths in concatenation
; x=()
; echo (a b c)^$x
rc: null list in concatenation
.P2
.LP
In some cases it is useful to use the value of a variable as a single string,
even if the variable contains a list with several strings. This can be done by
using a “\f(CW"\fP” before the variable name. Note that this may be used to
concatenate a variable that might be an empty list, because we translate
the variable contents to a single word, which happens to be empty.
.ix "empty list
.P1
; x=(a b c)
; echo $x^1
a1 b1 c1
; echo $"x^1
a b c1
; x=()
; echo (a b c)^$"x
a b c
;
.P2
.LP
There are two slightly different values that can be used to represent a null
variable. One is the empty string, and the other one is the empty list. Here they
are, in that order.
.ix "null list
.ix "null variable
.P1
; x=''
; y=()
; echo $x

; echo $y

; xd -c /env/x
0000000  00
0000001 
; xd -c /env/y
0000000 
0000000 
; echo $#x $#y
1 0
.P2
.LP
Both values yield a null string when used, yet they are different.
An empty string is a list with just the empty string. When expanded by
.CW getenv
in a C program, or by using
.CW $
in the shell, the result is the empty string. However, its length is 1
because the list has one (empty) string.
For an empty list, the length is zero. In general, it is common to use
the empty list as the nil value for environment variables.
.BS 2 "Simple things
.LP
.ix "shell script
.ix "[rc] script
We are now prepared to start doing useful things. To make a start,
we want to write a couple of shell scripts to convert from decimal to
hexadecimal and vice-versa. We should start most scripts with
.P1
rfork e
.P2
.ix "[rfork] command
.LP
to avoid modifying the set of environment variables in the calling shell. 
.PP
The first thing needed is a program to
perform arithmetic calculations. The shell knows
.I nothing
about numbers, not to mention arithmetic. The shell knows how
.ix "arithmetic expression
to combine commands together to do useful work. Therefore, we need
a program to do arithmetic if we want to do arithmetic with the shell. We may type
numbers, but for shell, they would be just strings. Lists of strings indeed. Let's
search for that program.
.ix [lookman]
.ix "manual search
.P1
; lookman arithmetic expression
man 1 2c # 2c(1)
man 1 awk # awk(1)
man 1 bc # bc(1)
man 1 hoc # hoc(1)
man 1 test # test(1)
man 8 prep # prep(8)
.P2
.LP
There are several programs shown in this list that we might use to do arithmetic.
In general,
.CW hoc
.ix "[hoc] option~[-e]
is a very powerful interactive floating point calculation language. It
is very useful to compute arbitrary expressions, either by supplying
them through its standard input or by using its
.CW -e
option, which accepts as an argument an expression to evaluate.
.P1
; hoc -e '2 + 2'
4
; echo 2 + 2 | hoc
4
.P2
.LP
Hoc can do very complex arithmetic. It is a full language, using a syntax
similar to that of C. It reads expressions, evaluates them, and
prints the results. The program includes predefined variables for famous
constants, with names
.CW E ,
.CW PI ,
.CW PHI ,
etc., and you can define your own, using the assignment. For example,
.P1
; hoc
!!r=3.2
!!PI * r^2
32.16990877276
\fBcontrol-d\fP
;
.P2
.LP
defines a value for the radius of a circle, and computes the value for its
area.
.PP
But to do the task we have at hand, it might be more appropriate
another calculation program, called
.CW bc .
.ix [bc]
.ix "arithmetic language
This is program is also a language for doing arithmetic. The syntax is
also similar to C, and it even allows to define functions (like Hoc). Like before,
this tool accepts expressions as the input. It evaluates them and prints
the results. The nice thing
about this program is that it has a simple way of changing the numeric
base used for input and output. Changing the value for the variable
.CW obase
.ix "output base"
changes the base used for output of numeric values. Changing
the value for the variable
.CW ibase
.ix "input base
does the same for the input. It seems to be just the tool.
Here is a session converting some decimal
numbers to hexadecimal.
.ix "hexadecimal
.P1
; bc
!!obase=16
!!10
a
!!20
14
!!16
10
.P2
.LP
To print a decimal value in hexadecimal, we can write
.CW obase=16
and the value as input for
.CW bc .
That would print the desired output. There are several
ways of doing this. In any case, we must send several
statements as input for
.CW bc .
One of them changes the output base, the other prints
the desired value. What we can do is to separate
both
.CW bc
statements with a “\f(CW;\fP”, and use
.CW echo
to send them to the standard input of
.CW bc .
.P1
; echo 'obase=16 ;  512' | bc
200
.P2
.LP
We had to quote the whole command line for
.ix quoting
.CW bc
because there are at least two characters with special meaning for
.CW rc ,
and
we want the string to be echoed verbatim.
This can be packaged in a shell script as follows, concatenating
.CW $1
to the rest of the command for
.CW bc .
.so progs/d2h.ms
.ix "[d2h] [rc]~script
.LP
Although we might have inserted a
.CW ^
before
.CW $1 ,
.CW rc
is kind enough to insert one for free for us. You will get used to this pretty
quickly.
We can now use the resulting script, after giving it execute permission.
.P1
; chmod +x d2h
; d2h 32
20
.P2
.LP
We might like to write each input line for
.CW bc
using a separate line in the script, to improve readability.
The compound
.CW bc
statement that we have used may become hard to read if we need to add more
things to it. It would be nice to be able to use a different
.CW echo
for each different command sent to
.CW bc ,
and we can do so. However, because the output for
.I both
echoes must be sent to the standard input of
.CW bc ,
we must group them. This is done in
.CW rc
by placing both
commands inside brackets.
We must still quote the first command for
.CW bc ,
because the equal sign is special for
.CW rc .
The resulting script can be used like the one above, but this one
is easier to read.
.ix pipe
.ix "compound command
.P1
#!/bin/rc
{	echo 'obase=16'
	echo $1
} | bc
.P2
.LP
Here, the shell executes the two
.CW echo es
but handles the two of them as it they were just one
command, regarding the redirection of standard output.
This grouping construct permits using several commands
wherever you may type a single command. For example,
.P1
; { sleep 3600 ; echo time to leave! } &
;
.P2
.LP
executes
.I both
.CW sleep
and
.CW echo
in the background. Each command will be executed
.ix background
one after another, as expected. The result is that in one
hour we will see a message in the console reminding
that we should be leaving.
.PP
How do we implemented a script, called
.CW h2d ,
to do the opposite conversion? That is, to convert from
hexadecimal to decimal.
We might do a similar thing.
.P1
#!/bin/rc
{	echo 'ibase=16'
	echo $1
} | bc
.P2
.LP
But this has problems!
.P1
; h2d abc
syntax error on line 1, teletype
syntax error on line 1, teletype
0
.P2
.LP
The problem is that
.CW bc
expects hexadecimal digits from
.CW A
to
.CW F
to be upper-case letters. Before sending the input to
.CW bc ,
we would better convert our numbers to upper-case, 
just in case. There is a program that may help.
.ix "case conversion
The program
.CW tr
.ix [tr]
(translate)
translates characters. It reads its input files (or standard input),
performs its simple translations, and writes the result to the output.
The program is very useful for doing simple
character transformations on the input, like replacing
certain characters with other ones, or removing them.
Some examples follow.
.P1
; echo x10+y20+z30 | tr x y
y10+y20+z30
; echo x10+y20+z30 | tr xy z
z10+z20+z30
; echo x10+y20+z30 | tr a-z A-Z
X10+Y20+Z30
; echo x10+y20+z30 | tr -d a-z
10+20+30
.P2
.LP
The first argument states which characters are to be translated,
the second argument specifies to which ones they must be translated.
As you can see, you can ask
.CW tr
to translate several different characters into a single one. When many
characters are the source or the target for the translation, and they are
contiguous, a range may be specified  by separating the initial and final
character with a dash.
Under flag
.CW -d ,
.ix "[tr] flag~[-d]
.CW tr
removes the characters from the input read, before copying the data to the
output. So, how could we translate a dash to other character? Simple.
.P1
; echo a-b-c | tr - X
aXbXc
.P2
.LP
This may be a problem we need to translate some other character, because
.CW tr
would get confused thinking that the character is an option.
.P1
; echo a-b-c | tr -a XA
tr: bad option
.P2
.LP
But this can be fixed reversing the order for characters in the argument.
.P1
; echo a-b-c | tr a- AX
AXbXc
.P2
.LP
Now we can get back to our
.CW h2d
tool, and modify it to supply just upper-case hexadecimal digits to
.CW bc .
.so progs/h2d.ms
.ix "[h2d] [rc]~script
.LP
The new
.CW h2d
version works as we could expect, even when we use lower-case hexadecimal digits.
.P1
; h2d abc
2748
.P2
.LP
Does it pay to write
.CW h2d
and
.CW d2h ?
Isn't it a lot more convenient for you to use your desktop
calculator?
For converting just one or two numbers, it might be. For
converting a dozen or more, for sure, it pays to write
the script. The nice thing about having one program to do
the work is that we can now use the shell to automate things, and let
the machine work for us.
.BS 2 "Real programs
.LP
Our programs
.CW h2d
and
.CW d2h
are useful, for a casual use. To use them as building blocks for doing
more complex things, more work is needed. Imagine you need to
declare an array in C, and initialize it, to use the array for translating
small integers to their hexadecimal representation.
.ix "code generation
.ix "C declaration
.ix "array initializer
.P1
char* d2h[] = {
	"0x00",
	"0x11",
	\fI ... \fP
	"0xff"
};
.P2
.LP
To obtain a printable string for a integer
.CW i
in the range 0-255 you can use just
.CW d2h[i] .
Would you write that declaration by hand? No. The machine can do the work.
What we need is a command that writes the first 256 values in hexadecimal, and
adjust the output text a little bit before copying it to your editor.
.PP
We could change
.CW d2h
to accept more than one argument and do its work for
.I all
the numbers given as argument. Calling
.CW d2h
with all the numbers from 0 to 255 would get us close to obtaining an initializer for the array.
But first things first. We need to iterate through all the command line arguments
in our script. Rc includes a
.CW for
construct that can be used for that. It takes a variable name and a list, and
executes the command in the body once for each word in the list. On each pass,
the variable takes the value of the corresponding word. This is an example, using
.CW x
as the variable and
.CW "(a b c)"
as the list.
.ix "[for] command
.ix "[rc] loop
.P1
; for (x in a b c)
;; echo $x
a
b
c
.P2
.LP
Note how the prompt changed after typing the
.CW for
line,
.CW rc
wanted more input: a command for the body. To use more than one
command in the body, we may use the brackets as before, to group them. First attempt:
.P1
; for (num in 10 20 30) {
;; echo 'obase=16'
;; echo $num
;; }
obase=16
10
obase=16
20
obase=16
30
;
.P2
.LP
It is useful to try the commands before using them, to see what really happens.
The
.CW for
loop gave three passes, as expected. Each time,
.CW $num
kept the value for the corresponding string in the list:
.CW 10 ,
.CW 20 ,
and
.CW 30 .
Remember, these are strings! The shell does not know they mean numbers to you.
Setting
.CW obase
in each pass seems to be a waste. We will do it just once, before iterating through the
numbers. The numbers are taken from the arguments given to the script, which are kept at
.CW $* .
.so progs/d2h2.ms
.LP
Now we have a better program. It can be used as follows.
.P1
; d2h 10 20 40
a
14
28
.P2
.LP
We still have the problem
of supplying the whole argument list, a total of 256 numbers. It happens that
another program,
.CW seq ,
.ix [seq]
.ix sequences
(sequences)
knows how to write numbers in sequence. It can do much more. It knows how to
print numbers obtained by iterating between two numbers, using a
certain step.
.P1
; seq 5	\fRfrom 1 to 5\fP
1
2
3
4
5
.P2
.P1
; seq 1 2 10	\fRfrom 1 to 10 step 2\fP
1
3
5
7
9
;
.P2
.LP
What we need is to be able to use the output of
.CW seq
as an argument list for
.CW d2h .
We can do so! Using the \f(CW`{\fP...\f(CW}\fP construct that we saw
.ix "command substitution
while discussing how to use pipes.
We can do
now what we wanted.
.P1
; d2h `{seq 0 255}
0
1
.I "...and many other numbers up to...
fd
fe
ff
.P2
.LP
That was nice. However, most programs that accept arguments,
work with their standard input when no argument is given. If we do
the same to
.CW d2h ,
we increase the opportunities to reuse it for other tasks. The idea
is simple, we must check if we have arguments.  If there are some,
we proceed as before. Otherwise, we can read the arguments using
.CW cat ,
and then proceed as before.
We need a way to decide what to do, and we need to be able
to compare things.
.CW Rc
provides both things.
.PP
The construction
.CW if
.ix "[if] command
.ix "conditional execution
.ix "exit status
takes a command as an argument (within parenthesis).
If the command's exit status is
all right (i.e., the empty string), the body is executed. Otherwise, 
the body is not executed. This is the classical
.I if-then ,
but using a command as the condition (which makes sense for a shell),
and one command (or a group of them) as a body.
.P1
; if (ls -d /tmp) echo /tmp is there!
/tmp
/tmp is there!
;
; if (ls -d /blah) echo blah is there
ls: /blah: '/blah' file does not exist
.P2
.LP
In the first case,
.CW rc
executed
.CW "ls -d /tmp" .
This command printed the first output line, and, because its
exit status was the empty string, it was taken as
.I true
regarding the condition for the
.CW if .
Therefore,
.CW echo
was executed and it printed the second line.
In the second case,
.CW "ls -d /blah"
failed, and
.CW ls
complained to its standard error. The body command for the
.CW if
was not executed.
.PP
It can be a burden to see the output for commands that we
use as conditions for
.CW if s,
and it may be wise to send the command output to
.CW /dev/null ,
.ix [/dev/null]
.ix "standard error redirection
including its standard error.
.P1
; if (ls -d /tmp >/dev/null >[2=1]) echo is there
is there
; if (ls -d /blah >/dev/null >[2=1]) echo is there
;
.P2
.LP
Once we know how to decide, how can we compare strings? The
.CW ~
.ix "compare operator
.ix "[~] command
.ix "string match
operator in
.CW rc
compares one string to other onesⁱ, and yields
an exit status meaning true, or success, when the compare succeeds, and
one meaning false otherwise.
.FS
ⁱ We will see how
.CW ~
is comparing a string to expressions, not just to strings.
.FE
.P1
; ~ 1 1
; echo $status

; ~ 1 2
; echo $status
no match
; if (~ 1 1) echo this works
this works
.P2
.LP
So, the plan is as follows.
If
.CW $#*
(the number of arguments for our script) is zero, we
must do something else. Otherwise, we must execute our
previous commands in the script. Before implementing it,
we are going to try just to do different things depending
on the number of arguments. But we need an else!
This is done by using the construct
.CW "if not"
.ix "[if] [not]"
.ix "conditional command
after an
.CW if .
If the command representing the condition for an
.CW if
fails, the following
.CW "if not"
executes its body.
.so progs/args.ms
.ix "[args] [rc]~script
.LP
And we can try it.
.P1
; args
no arguments
; args 1 2
got some arguments: 1 2
.P2
.ix "script arguments
.LP
Now we can combine all the pieces.
.so progs/d2h3.ms
.LP
We try our new script below. When using its standard input to read the numbers,
it uses the \f(CW`{\fP...\f(CW}\fP construct to execute
.CW cat ,
which reads all the input, and to place
the text read in the environment variable
.CW args .
This means that it will not print a single line of output until we have typed
all the numbers and used
.I control-d
to simulate an end of file.
.P1
; d2h3
!!20
!!30
\fBcontrol-d\fP
14
1e
; 
; d2h3 3 4
3
4
;
.P2
.LP
Our new command is ready for use, and it can be combined with
other commands, like in
.CW "seq 10|d2h" .
It would work as expected.
.PP
An early exercise in this book asked to use
.CW ip/ping
.ix [ping]
.ix [ip/ping]
.ix "internet probe
to probe for all addresses for machines in a local network. Addresses
were of the form
.CW 212.128.3.X
with
.CW X
going from 1 to 254. You now know how to do it fast!
.P1
; nums=`{seq 1 254}
; for (n in $nums) ip/ping 212.128.3.$n
.P2
.LP
Before this example, 
you might have been saying: Why should I bother to write several shell command lines to do
what I can do with a single loop in a C program? Now you may reconsider
the question.  The answer is that in
.CW rc
it is very easy to combine commands.  Doing it in C, that is a different business.
.PP
By the way. Use variables! They might save a lot of typing, not to talk
about making commands more simple to read. For instance, the next
commands may be better than what we just did.  If we have to use
.CW 212.128.3
again, which is likely if we are playing with that network, we might just
say
.CW $net .
.P1
; nums=`{seq 1 254}
; net=212.128.3.
; for (n in $nums) ip/ping $net^$n
.P2
.BS 2 "Conditions
.LP
.ix "condition
.ix "[rc] conditionals
Let's go back to commands used for expressing conditions in our shell
programs. The shell operator
.CW ~
uses expressions. They are the same expressions used
for globbing. The operator receives at least two arguments, maybe
.ix globbing
more. Only the first one is taken as a string. The remaining ones are considered
as expressions to be matched against the string. For example,
.ix "string match
this iterates over a set of files and prints a string suggesting what the file
might be, according to the file name.
.so progs/file.ms
.ix "[file] [rc]~script
.ix "[file] command
.LP
And here is one usage example.
.P1
; file x.c a.h b.gif z
x.c: C source code
a.h: C source code
b.gif: GIF image
.P2
.LP
Note that before executing the
.CW ~
command, the shell expanded the variables, and
.CW $file
was replaced with the corresponding argument on each pass of the loop.
Also, because the shell knows that
.CW ~
takes expressions, it is not necessary to quote them.
.CW Rc
does it for you.
.PP
The script can be improved. It would be nice to state that
.CW file
does not know what a file is if its name does not match any of the expressions
we have used. We could add this
.CW if
.ix negation
.ix "[!] command
as a final conditional inside the loop of the script.
.P1
	if (! ~ $file *.[ch] *.gif *.jpg)
		echo $file: who knows
.P2
.LP
The builtin command
.CW !
in
.CW rc
is used as a negation. It executes the command given as an argument. If
the command exit status meant ok, then
.CW !
fails. And vice-versa.
.PP
But that was a poor way of doing things.
There is a
.CW switch
.ix [switch]
.ix "multiway branch
.ix "conditional construct
construct in
.CW rc
that permits doing multiway branches, like the construct
of the same name in C. The one in
.CW rc
takes one string as the argument,
and executes the branch with a regular expression that matches the string.
Each branch is labeled with the word
.CW case
.ix [case]
followed by the expressions for the branch. This is an example that improves the
previous script.
.P1
#!/bin/rc
rfork e
for (file in $*) {
	switch($file){
	case *.c *.h
		echo $file: C source code
	case *.gif
		echo $file: GIF image
	case *.jpg
		echo $file: JPEG image
	case *
		echo $file: who knows
	}
}
.P2
.LP
As you can see, in a single
.CW case
you may use more than one expression, like you can with
.CW ~ .
As a matter of fact, this script is doing poorly what is better
done with a standard command that has the same name,
.CW file .
This command prints a string after inspecting each file whose name
is given as an argument. It reads each file to search for words or
patterns and makes an educated guess.
.ix pattern
.P1
; file ch7.ms ch8.ps src/hi.c
ch7.ms:   Ascii text
ch8.ps:   postscript
src/hi.c: c program
.P2
.LP
There is another command that was built just to test for things, to be used
as a condition for
.CW if
expressions in the shell. This program is
.CW test .
.ix [test]
For example, the option
.CW -e
.ix "[test] flag~[-d]
.ix "[test] flag~[-e]
can be used to check that a file does exist, and the option
.CW -d
checks that a file is a directory.
.P1
; test -e /LICENSE
; echo $status

; test -e /blah
; echo $status
test 52313: false
; if (test -d /tmp) echo yes
yes
; if (test -d /LICENSE) echo yes
;
.P2
.LP
.CW Rc
includes two conditional operators that remind of the
boolean operators in C. The first one is
.CW && ,
.ix "conditional pipe
.ix "[&&] command
.ix "command line
.ix "logical and
it represents an AND operation
and executes the command on its right only if the one on its left completed with
success. Only when both commands succeed, the operator does so.
For example, we can replace the
.CW switch
with the following code in our naive
.CW file
script.
.P1
~ $file *.[ch]	&& echo $file: C source code
~ $file *.gif	&& echo $file: GIF image
~ $file *.jpg	&& echo $file: JPEG image
.P2
.LP
Here, on each line,
.CW echo
is executed only if the previous command, i.e.,
.CW ~ ,
succeeds.
.PP
The other conditional is
.CW || .
.ix "[||] command
.ix "logical or
It represents an OR operation,
and executes the command on the right only if the one on the left
fails. It succeeds if any of the commands do. As an example, this checks for an
unknown file type in our simple script.
.P1
~ $file *.[ch] *.gif *.jpg || echo $file: who knows
.P2
.LP
The next command is equivalent to the previous one, but it would execute
.CW ~
three times and not just once.
.P1
~ $file *.[ch] || ~ $file *.gif || ~ $file *.jpg ||
	echo $file: who knows
.P2
.LP
As you can see, the command is harder to read besides being more complex. But
it works just fine as an example.
.PP
Many times you would want to execute a particular command when something
happens. For example, to send you an email when a print job completes, to alert
you when a new message is posted to a web discussion group, etc. We can
develop a tiny tool for the task. Let's call it
.CW when .
.ix "[when] [rc]~script
Our new tool can loop forever and check the
condition of interest from time to time. When the condition happens, it can
take an appropriate action.
.PP
To loop forever, we can use the
.CW while
construct. It executes the command used as the condition for the loop.
If the command succeeds, the
.CW while
continues looping. Let's try it.
.ix [sleep]
.P1
; while(sleep 1)
;; echo one more loop
one more loop
one more loop
one more loop
\fBDelete\fP
;
.P2
.LP
The command
.CW sleep
always succeeds! It is a lucky command. Now, how can we express the
condition we are watching for? And how do we express the action to execute
when the condition holds? It seems that supplying two commands for each
purpose is both general and simple to implement. The script
.CW when
is going to accept two arguments, a command to execute that must yield
success when the condition holds, and a command to perform the action.
For example,
.ix [mail]
.P1
; when 'changed http://indoecencias.blogspot.com' \e
;;  'mail -s ''new indoecencias'' nemo' &
;
.P2
.LP
sends a mail to
.CW nemo
when there are changes in
.CW http://indoecencias.blogspot.com ,
provided that
.CW changed
exits with null status when there are changes in the URL. Also,
.ix "[test] flag~[-older]
.P1
; when 'test /sys/src/9/pc/main.8 -older 4h' \e
;; 'cd /sys/src/9/pc ; mk clean' &
;
.P2
.LP
watches out for an object file
.CW main.8
older than 4 hours. When this happens, we assume that someone forgot
to clean up the directory
.CW /sys/src/9/pc
.ix "kernel compilation
after compiling a kernel, and we execute the command to do some clean up
and remove the object files generated by the compilation.
.PP
Nice, but, how do we do it? It is best to experiment first. First try.
.P1
; cond='test -e /tmp/file'
; cmd='echo file is there'
; 
; $cond && $cmd
test -e /tmp/file: '/bin/test -e ' file does not exist
.P2
.LP
The aim was to execute the command in
.CW $cond
and, when it succeeds,
the one in
.CW $cmd .
However, the shell understood that
.CW $cond
is a single word. This is perfectly reasonable, as we quoted the whole command.
We can use
.CW echo
to echo our variable within a \f(CW`{\fP...\f(CW}\fP construct, that will break
the string into words.
.ix "parsing
.ix "string split
.P1
; lcond=`{echo $cond}
; lcmd=`{echo $cmd}
; echo $#lcond
3
; echo $#lcmd
4
.P2
.LP
And we get back our commands, split into different words as in a regular command
line. Now we can try them.
.P1
; $lcond && $lcmd
; 	\fRThere was no file named /tmp/file\fP
.P2
.LP
And now?
.P1
; touch /tmp/file
; $lcond && $lcmd
file is there
.P2
.LP
We are now confident enough to write our new tool.
.so progs/when.ms
.ix "[when] [rc]~script
.LP
We placed braces around
.CW $cond
and
.CW $cmd
as a safety measure. To make it clear how we want to group commands in the
body of the
.CW while .
Also, after executing the action, the script exits. The condition held and it has
no need to continue checking for anything.
.BS 2 "Editing text
.LP
.ix "text editing
Before, we managed to generate a list of numbers for an array
initializer that we did
.I not
want to write by ourselves. But the output we obtained was not yet ready for
a cut-and-paste into our editor. We need to convert something like
.P1
1
2
.I "...
.P2
.LP
into something like
.P1
"0x1",
"0x2",
.I ...
.P2
.LP
that can be used for our purposes. There are many programs that operate
on text and know how to do complex things to it. In this section we are going
to explore them.
.PP
To achieve our purpose, we might convert each number into hexadecimal, and
store the resulting string in a variable. Later, it is just a matter of using
.CW echo
to print what we want, like follows.
.P1
; num=32
; hexnum=`{{ echo 'obase=16' ; echo $num } | bc}
; echo "0x^$hexnum^",
"0x20",
.P2
.LP
We used the \f(CW`{\fP...\f(CW}\fP construct execute
.CW "hexnum=" ...,
with the appropriate string on the right hand side of the equal sign. This string
was printed by the command
.P1
{ echo 'obase=16' ; echo $num } | bc
.P2
.ix [bc]
.LP
that we now know that prints
.CW 20 .
It is the same command we used in the
.CW d2h
script.
.PP
For you, the “\f(CW"\fP” character may be special. For the shell, it is just another
character. Therefore, the shell concatenated the  “\f(CW"0x\fP” with the
string from
.CW $hexnum
and the string “\f(CW",\fP”. That was the argument given to
.CW echo .
So, you probably know already how to write a few shell command lines to
generate the text for your array initializer.
.P1
; for (num in `{seq 0 255}) {
;; 	number=`{{ echo 'obase=16' ; echo $num } | bc}
;; 	echo "0x^$number^",
;; }
"0x0",
"0x1",
"0x2",
.I "...and many others follow.
.P2
.LP
.ix "efficiency
.ix "command line
Is the problem solved? Maybe. This is a very inefficient way of doing things.
For each number, we are executing a couple of processes to run
.CW echo
and then another process to run
.CW bc .
It takes time for processes to start. You know what
.CW fork
and
.CW exec
do. That must take time. Processes are cheap, but not free.
Wouldn't it be better to use a single
.CW bc
to do all the computation, and then adjust the output? For example,
this command, using our last version for
.CW d2h ,
produces the same output. The final
.CW sed
.ix [sed]
.ix "stream editor
.ix "replace string
command inserts some text at the beginning and at the end of each line,
to get the desired output.
.P1
; seq 1 255 | d2h | sed -e 's/^/"0x/' -e 's/$/",/'
"0x0",
"0x1",
"0x2",
.I "...and many others follow.
.P2
.LP
To see the difference between this command line, and the direct
.CW for
loop used above, we can use
.CW time
.ix "[time] command
.ix "performance measurement
to measure the time it takes to each one to complete. We placed
the command above using a
.CW for
into a
.CW /tmp/for
script, and
the last command used, using
.CW sed ,
at a script in
.CW /tmp/sed .
This is what happen.
.P1
; time /tmp/sed >/dev/null
0.34u 1.63s 5.22r 	 /tmp/sed
; time /tmp/for >/dev/null
3.64u 24.38s 74.30r 	 /tmp/for
.P2
.LP
The
.CW time
command uses the
.CW wait
.ix [wait]
system call to obtain the time for its child (the command we want to measure the time for).
It reports the time spent by the command while executing user code, the time it
spent while inside the kernel, executing system calls and the like, and the real
(elapsed) time until it completed. Our loop, starting several processes for each number
being processed, takes 74.3 seconds to generate the output we want! That is admittedly
a lot shorter than doing it by hand. However, the time needed to do the same
using
.CW sed
as a final processing step in the pipeline is just 5.22 seconds. Besides,
we had to type less. Do you think it pays?
.PP
The program
.CW sed
is a
.I "stream editor" .
It can be used to edit data as it flows through a pipeline. Sed reads
text from the input, applies the commands you give to edit that text, and
writes the result to the output. In most cases, this command is used to
perform simple tasks, like inserting, deleting, or replacing text. But it can
be used for more. As with most other programs, you may specify the input
for
.CW sed
by giving some file names as arguments, or you may let it work with the standard input
otherwise.
.PP
In general, editing commands are given as arguments to the
.ix "[sed] flag~[-e]
.CW -e
option, but if there is just one command, you may omit the
.CW -e .
For example, this prints the first 3 lines for a file.
.P1
; sed 3q /LICENSE
The Plan 9 software is provided under the terms of the
Lucent Public License, Version 1.02, reproduced below,
with the following notable exceptions:
;
.P2
.ix "file head
.LP
All sed commands have either none, one, or two
.I addresses
.ix "text address
and then the command itself. In the last example there was one
address,
.CW 3 ,
and one command,
.CW q .
The editor reads text, usually line by line. For each text read,
.CW sed
applies all the editing commands given, and copies the result to standard
output. If addresses are given for a command, the editor applies the command
to the text selected by those addresses.
.PP
A number is an address that corresponds
to a line number. The command
.CW q ,
quits. What happened in the example is that the editor read lines, and
printed them to the output, until the address
.CW 3
was matched. That was at line number 3. The command
.I quit
was applied, and the rest of the file was not printed. Therefore, the previous
command can
be used to print the first few lines for a file.
.PP
If we want to do the opposite, we may just
.I delete
some lines, from the one with address 1, to the one with address 3. As you can see
below,
both addresses are separated with a comma, and the command to apply follows.
Therefore,
.CW sed
searched for the text matching the address pair
.CW 1,3
.ix "address pair
(i.e., lines 1 to 3), printing each line as it was searching. Then it copied the text
selected to memory, and applied the
.CW d
.ix "delete text
command. These lines were deleted. Afterwards,
.CW sed
continued copying line by line to its memory, doing nothing to each one, and copying the
result to standard output.
.P1
.ps -2
; sed 1,3d /LICENSE

1. No right is granted to create derivative works of or
   to redistribute (other than with the Plan 9 Operating System)
.I "...more useful stuff for your lawyer...
.ps +2
.P2
.LP
Supplying just one command, with no address, applies the command to all
lines.
.P1
; sed d /LICENSE
; 
.P2
.LP
Was the
.CW /LICENSE
deleted? Of course not. This editor is a
.I stream
editor. It reads, applies commands to the text while in the editor's memory,
and outputs the resulting text.
.PP
.ix "print lines
How can we print the lines 3 to 5 from our input file? One strategy is to use
the
.CW sed
command to print the text selected,
.CW p ,
selecting lines 3 to 5. And also, we must ask
.CW sed
not to print lines by default after processing them, by giving the
.CW -n
.ix "[sed] flag~[-n]
flag.
.P1
; sed -n 3,5p /LICENSE
with the following notable exceptions:

1. No right is granted to create derivative works of or
.P2
.LP
The special address
.CW $
.ix "[$] address
.ix "EOF address
matches the end of the file. Therefore, this deletes from line 3 to
the end of the file.
.P1
; sed '3,$d' /LICENSE
The Plan 9 software is provided under the terms of the
Lucent Public License, Version 1.02, reproduced below,
.P2
.LP
What follows deletes lines between the one matching
.CW /granted/ ,
i.e., the first one that contains that word, and the end of the file. This
is like using
.CW 1,3d .
There are two addresses and a
.CW d
command. It is just that the two addresses are more complicated this time.
.P1
; sed '/granted/,$d' /LICENSE
The Plan 9 software is provided under the terms of the
Lucent Public License, Version 1.02, reproduced below,
with the following notable exceptions:

;
.P2
.LP
Another interesting command for
.CW sed
is
.CW r .
.ix "include file
This one reads the contents of a file, and writes them to the standard output
before proceeding with the rest of the input. For example, given these files,
.P1
; cat salutation
Today I feel
FEEL
So be warned
; cat how
Really in bad mood
;
.P2
.LP
we can use
.CW sed
to adjust the text in
.CW salutation
so that the line with
.CW FEEL
is replaced with the contents of the file
.CW how .
What we have to do is to give
.CW sed
an address that matches a line
with the text
.CW FEEL
in it. Then, we must use the
.CW d
command
to delete this line. And later we will have to insert in place
the contents of the other file.
.P1
; sed /FEEL/d <salutation
Today I feel
So be warned
.P2
.LP
The address
.CW /FEEL/
matches the string
.CW FEEL ,
and therefore selects that line.
For each match, the command
.CW d
removes its line. If there were more
than one line matching the address, all of such lines would have been deleted. In
general,
.CW sed
goes line by line, doing what you want.
.P1
; cat salutation  salutation | sed /FEEL/d
Today I feel
So be warned
Today I feel
So be warned
.P2
.LP
We also wanted to insert the text in
.CW how
in place, besides deleting the line with
.CW FEEL .
Therefore, we want to execute
.I two
commands when the address
.CW /FEEL/
matches in a line in the input. This can be done by using braces, but
.CW sed
.ix "compound [sed]~command
is picky regarding the format of its program, and we prefer to use several lines
for the
.CW sed
program. Fortunately, the shell knows how to quote it all.
.P1
; sed  -e '/FEEL/{
;; r how
;; d
;; }'<salutation
Today I feel
Really in bad mood
So be warned
.P2
.LP
In general, it is a good idea to quote complex expressions that are meant
not for shell, but for the command being executed. Otherwise, we might use
a character with special meaning for
.CW rc ,
and there could be surprises.
.PP
This type of editing can be used to prepare templates for certain files, for
example, for your web page, and then automatically adjust this template
to generate something else. You can see the page at
.CW http://lsub.org/who/nemo ,
which is generated using a similar technique to state whether Nemo is at
his office or not.
.PP
The most useful
.CW sed
command is yet to be seen. It replaces some text with another. Many people
who do not know how to use
.CW sed ,
.I know
at least how to use
.CW sed
just for doing this.
The command is
.CW s
(for
.I substitute ),
.ix "substitute string
and is followed by two strings. Both the command and the strings are
delimited using any character you please, usually a
.CW / .
For example,
.CW s/bad/good/
replaces the string
.CW bad
with
.CW good .
.P1
; echo Really in bad mood | sed 's/bad/good/'
Really in good mood
.P2
.LP
The quoting was unnecessary, but it does not hurt and it is good to
get used to quote arguments that may get special characters inside.
There are two things to see here. The command,
.CW s ,
applies to
.I all
lines of input, because no address was given. Also, as it is, it replaces
only the first appearance of
.CW bad
in the line. Most times you will add a final
.CW g ,
which is a flag that makes
.ix "global substitution
.CW s
substitute all occurrences (globally) and not just the first one.
.PP
This lists all files terminating in
.CW .h ,
and replaces that termination with
.CW .c ,
to generate a list of files that may contain the implementation for the
things declared in the header files.
.P1
; ls *.h
cook.h
gui.h
; ls *.h | sed 's/.h/.c/g'
cook.c
gui.c
.P2
.LP
You can now do more things, like renaming all the files terminated in
.CW .cc
.ix "file rename
to files terminated in
.CW .c ,
(in case you thought it twice and decided to use C instead of C++).
We make some attempts before writing the command that does it.
.P1
; echo foo.cc | sed 's/.cc/.c/g'
foo.c
; f=foo.cc
; nf=`{echo $f | sed 's/.cc/.c/g'}
; echo $nf
foo.c
; for (f in *.cc) {
;; nf=`{echo $f | sed 's/.cc/.c/g'}
;; mv $f $nf
;; }
;	\fIall of them renamed!\fP
.P2
.LP
At this point, it should be easy for you to understand the command we used
to generate the array initializer for hexadecimal numbers
.P1
	sed -e 's/^/"0x/' -e 's/$/",/'
.P2
.LP
It had two editing commands, therefore we had to use
.CW -e
for both ones. The first one replaced the start of a line with “\f(CW0x\fP”,
thus, it inserted this string at the beginning of line. The second inserted
“\f(CW",\fP” at the end of line.
.BS 2 "Moving files around
.LP
.ix "move files
.ix "directory copy
We want to copy all the files in a file tree to a single directory. Perhaps
we have one directory per music album, and some files with songs inside.
.P1
; du -a
1	./alanparsons/irobot.mp3
2	./alanparsons
1	./pausini/trateilmare.mp3
1	./pausini
1	./supertramp/logical.mp3
1	./supertramp
4	.
.P2
.LP
.ix "CD write
.ix [du]
.ix "disk usage
But we may want to burn a CD and we might need to keep the songs
in a single directory. This can be done by using
.CW cp
to copy each file of interest into another one at the target directory.
But file names may not include
.CW / ,
and we want to preserve the album name. We can use
.CW sed
to substitute the
.CW /
with another character, and then copy the files.
.P1
; for (f in */*.mp3) {
;; nf=`{echo $f | sed s,/,_,g}
;; echo cp $f /destdir/$nf
;; }
cp alanparsons/irobot.mp3 /destdir/alanparsons_irobot.mp3
cp pausini/trateilmare.mp3 /destdir/pausini_trateilmare.mp3
cp supertramp/logical.mp3 /destdir/supertramp_logical.mp3
;
.P2
.LP
Here, we used a comma as the delimiter for the
.CW sed
command, because we wanted to use the slash in the expression to be
replaced.
.PP
To copy the whole file tree to a different place, we cannot use
.CW cp .
Even doing the same thing that we did above, we would have to create the
directories to place the songs inside. That is a burden. A different strategy
is to create an
.B archive
for the source tree, and then extract the archive at the destination.
The command
.CW tar ,
.ix [tar]
.ix "tape archive
(tape archive)
was initially created to make tape archives. We no longer use tapes for
achieving things. But
.CW tar
remains a very useful command. A tape archive, also known as a tar-file,
is a single file that contains many other ones (including directories) bundled
inside.
.PP
What
.CW tar
does is to write to the beginning of the archive a table describing the
file names and permissions, and where in the archive their contents
start and terminate. This
.I header
is followed by the contents of the files themselves. The option
.CW -c
creates one archive with the named files.
.P1
; tar -c * >/tmp/music.tar
.P2
.LP
We can see the contents of the archive using the option
.CW t .
.P1
; tar -t </tmp/music.tar
alanparsons/
alanparsons/irobot.mp3
pausini/
pausini/trateilmare.mp3
supertramp/
supertramp/logical.mp3
.P2
.LP
Option
.CW -v ,
adds verbosity to the output, like in many other commands.
.ix "verbose output
.P1
.ps -1
; tar -tv </tmp/music.tar
d-rwxr-xr-x     0 Jul 21 00:02 2006 alanparsons/
--rw-r--r--    13 Jul 21 00:01 2006 alanparsons/irobot.mp3
d-rwxr-xr-x     0 Jul 21 00:02 2006 pausini/
--rw-r--r--    13 Jul 21 00:02 2006 pausini/trateilmare.mp3
d-rwxr-xr-x     0 Jul 21 00:02 2006 supertramp/
--rw-r--r--    13 Jul 21 00:02 2006 supertramp/logical.mp3
.ps +1
.P2
.LP
.ix "archive extraction
This lists the permissions and other file attributes. To extract the files in the
archive, we can use the option
.CW -x .
Here we add an
.CW v
as well
just to see what happens.
.P1
; cd otherdir
; tar xv </tmp/music.tar
alanparsons
alanparsons/irobot.mp3
pausini
pausini/trateilmare.mp3
supertramp
supertramp/logical.mp3
; lc
alanparsons	pausini		supertramp
.P2
.LP
The size of the archive is a little bit more than the size of the files
placed in it. That is to say that
.CW tar
does not compress anything. If you want to compress the contents
of an archive, so it occupies less space in the disk, you may use
.CW gzip .
.ix [gzip]
This is a program that uses a compression algorithm to exploit
regularities in the data to use more efficient representation techniques
for the same data.
.P1
; gzip music.tar
; ls -l music.*
--rw-r--r-- M 19 nemo nemo 10240 Jul 21 00:17 music.tar
--rw-r--r-- M 19 nemo nemo   304 Jul 21 00:22 music.tgz
.P2
.LP
The file
.CW music.tgz
was created by
.CW gzip .
In most cases,
.CW gzip
adds the extension
.CW .gz
.ix "compressed archive
for the compressed file name. But tradition says that compressed tar files
terminate in
.CW .tgz .
.PP
Before extracting or inspecting
the contents of a compressed archive, we must uncompress it. Below we
also use the option
.CW -f
for
.CW tar ,
that permits specifying the archive file as an argument. 
.P1
; tar -tf music.tgz
/386/bin/tar: partial block read from archive
; gunzip music.tgz
; tar -tf music.tar
alanparsons/
alanparsons/irobot.mp3
.I ...etc...
.P2
.LP
So, how can we copy an entire file tree from one place to another?
You now know how to use
.CW tar .
Here is how.
.P1
; @{cd /music ; tar -c *}  | @{ cd /otherdir ; tar x }
.P2
.LP
.ix "compound command
The output for the first compound command goes to the input of the second one.
The first one changes its directory to the source, and then creates an archive
sent to standard output. In the second one, we change to the destination
directory, and extract the archive read from standard input.
.PP
A new thing we have seen here is the expression
.CW @{ ...} ,
which is like
.CW { ...} ,
but executes the command block in a child shell. We need to do this because
each block must work at a different directory.
.SH
Problems
.IP 1
The file
.CW /lib/ndb/local
lists machines along with their IP addresses. Suppose all addresses are of
the form,
.CW 121.128.1.X .
Write a script to edit the file and change all the addresses to be of the form
.CW 212.123.2.X .
.IP 2
Write a script to generate a template for a
.CW /lib/ndb/local ,
for machines named
.CW alphaN ,
where
.CW N
must correspond to the last number in the machine address.
.IP 3
Write a script to locate in
.CW /sys/src
the programs using the system call
.CW pipe .
How many programs are using it? Do not do anything by hand.
.IP 4
In many programs, errors are declared as strings. Write a script that
takes an error message list and generates both an array containing the
message strings and an enumeration to refer to entries in the array.
.IP
.I Hint:
Define a common format for messages to simplify your task.
.IP 5
Write a script to copy just C source files below a given directory to
.CW $home/source/ .
How many source files do you have? Again, do not do anything by hand.
.IP 6
Write a better version for the
.CW file
script developed in this chapter. Use some of the commands you know
to inspect file contents to try to determine the type of file for each argument
of the script.
.ds CH
.bp
