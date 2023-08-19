.so tmacs
.BC 9 "More tools
.BS 2 "Regular expressions
.LP
We have used
.CW sed
.ix [sed]
to replace one string with another. But, what happens here? 
.P1
; echo foo.xcc | sed 's/.cc/.c/g'
foo..c
; echo focca.x | sed 's/.cc/.c/g'
f.ca.x
.P2
.LP
We need to learn more.
.PP
.ix "text matching
In addresses of the form
.CW /text/
and in commands like
.CW s/text/other/ ,
the string
.CW text
is not a string for
.CW sed .
This happens to many other programs that search for things.
.ix "text search
For example, we have used
.CW grep
.ix [grep]
to print only lines containing a string. Well, the
.I string
given to grep, like in
.P1
; grep string file1 file2 ...
.P2
.LP
is
.I not
a string. It is a
.B "regular expression" .
A regular expression is a little language. It is very useful to master it, because
many commands employ regular expressions to let you do complex things
in an easy way.
.PP
The text in a regular expression represents many different strings. You have
already seen something similar. The
.CW *.c
in the shell, used for globbing, is very similar to a regular expression. Although
.ix globbing
it has a slightly different meaning. But you know that in the shell,
.CW *.c
\fBmatches\fP
with many different strings. In this case, those that are file names in the current
directory that happen to terminate with the characters “\f(CW.c\fP”. That is what
regular expressions, or
.I regexps ,
are for. They are used to select or match text, expressing the kind of text
to be selected in a simple way. They are a language on their own.
A regular expression, as known by
.CW sed ,
.CW grep ,
and many others,
is best defined recursively, as follows.
.IP •
Any single character
.I matches
the string consisting of that character. For example,
.CW a
matches
.CW a ,
but not
.CW b .
.IP •
A single dot, “\f(CW.\fP”, matches
.I any
single character. For example, “\f(CW.\fP” matches
.CW a
and
.CW b ,
but not
.CW ab .
.IP •
.ix "character set
A set of characters, specified by writing a string within brackets, like
.CW [abc123] ,
matches
.I any
character in the string. This example would match
.CW a ,
.CW b ,
or
.CW 3 ,
but not
.CW x .
A set of characters, but starting with
.CW ^ ,
matches any character
.I not
in the set. For example,
.CW [^abc123]
matches
.CW x ,
but not
.CW 1 ,
which is in the string that follows the
.CW ^ .
A range may be used, like in
.CW [a-z0-9] ,
which matches any single character that is a letter or a digit.
.ix "character range
.IP •
.ix "start~of text
.ix "end~of text
.ix "start~of line
.ix "end~of line
A single
.CW ^ ,
matches the start of the text. And a single
.CW $ ,
matches the end of the text. Depending on the program using the
regexp, the text may be a line or a file. For example, when using
.CW grep ,
.CW a
matches the character
.CW a
at
.I any
place. However,
.CW ^a
matches
.CW a
only when it is the first character in a line, and
.CW ^a$
also requires it to be the last character in the line.
.IP •
Two regular expressions concatenated match
any text matching the first regexp followed by any text
matching the second. This is more hard to say
than it is to understand. The expression
.CW abc
matches
.CW abc
because
.CW a
matches
.CW a ,
.CW b
matches
.CW b ,
and so on. The expression
.CW [a-z]x
matches any two characters where the first one matches
.CW [a-z] ,
and the second one is an
.CW x .
.IP •
Adding a
.CW *
after a regular expression, matches zero or any number of
strings that match the expression. For example,
.CW x*
matches the empty string, and also
.CW x ,
.CW xx ,
.CW xxx ,
etc. Beware,
.CW ab*
matches
.CW a ,
.CW ab ,
.CW abb ,
etc. But it does
.I not
match
.CW abab .
The
.CW *
applies to the preceding regexp, with is just
.CW b
in this case.
.IP •
Adding a
.CW +
after a regular expression, matches one or more
strings that match the previous regexp. It is like
.CW * ,
but there has to be at least one match. For example,
.CW x+
does not match the empty string, but it matches every other thing
matched by
.CW x* .
.IP •
.ix "optional string
Adding a
.CW ?
after a regular expression, matches either the empty string or
one string matching the expression. For example,
.CW x?
matches
.CW x
and the empty string. This is used to make parts optional.
.IP •
Different expressions may be surrounded by parenthesis, to alter
grouping. For example,
.CW (ab)+
matches
.CW ab ,
.CW abab ,
etc.
.IP •
Two expressions separated by
.CW |
match anything matched either by the first, or the second regexp. For example,
.CW ab|xy
matches
.CW ab ,
or
.CW xy .
.IP •
.ix backslash
.ix "escape character
A backslash removes the special meaning for any character used for
syntax. This is called a
.I escape
character.
For example,
.CW (
is not a well-formed regular expression, but
.CW \e(
is, and matches the string
.CW ( .
To use a backslash as a plain character, and not as a escape, use the
backslash to escape itself, like in
.CW \e\e .
.LP
That was a long list, but it is easy to learn regular expressions just by using
them. First, let's fix the ones we used in the last section. This is what happen to us.
.P1
; echo foo.xcc | sed 's/.cc/.c/g'
foo..c
; echo focca.x | sed 's/.cc/.c/g'
f.ca.x
.P2
.LP
But we wanted to replace
.CW .cc ,
and not
.I any
character and a
.CW cc .
Now we know that the first argument to the
.CW sed
command
.CW s ,
is a regular expression.
We can try to fix our problem.
.P1
; echo foo.xcc | sed 's/\e.cc/.c/g'
foo.xcc
; echo focca.x | sed 's/\e.cc/.c/g'
focca.x
.P2
.LP
It seems to work. The backslash removes the special meaning for the dot,
and makes it match just one dot. But this may still happen.
.P1
; echo foo.cc.x | sed 's/\e.cc/.c/g'
foo.c.x
.P2
.LP
And we wanted to replace only the extension for file names ending in
.CW .cc .
We can modify our expression to match
.CW .cc
only when immediately before the end of the line (which is the string being
matched here).
.P1
; echo foo.cc.x | sed 's/\e.cc$/.c/g'
foo.cc.x
; echo foo.x.cc | sed 's/\e.cc/.c/g'
foo.x.c
.P2
.LP
.ix "inner expression
.ix "sub-expression match
Sometimes, it is useful to be able to refer to text that matched part
of a regular expression. Suppose you want to replace the variable name
.CW text
with
.CW word
in a program.
You might try with
.CW s/text/word/g ,
but it would change other identifiers, which is not what you want.
.P1
; cat f.c
void
printtext(char* text)
{
	print("[%s]", text);
}
; sed 's/text/word/g' f.c
void
printword(char* word)
{
	print("[%s]", word);
}
.P2
.LP
The change is only to be done if
.CW word
is not surrounded by characters that may be part of an identifier in the
program. For simplicity, we will assume that these characters are just
.CW [a-z0-9_] .
We can do what follows.
.P1
; sed 's/([^a-z0-9_])text([^a-z0-9_])/\e1word\e2/g' f.c
void
printtext(char* word)
{
	print("[%s]", word);
}
.P2
.LP
.ix "identifier
The regular expression 
.CW [^a-z0-9_]text[^a-z0-9_]
means “any character that may not be part of an identifier”, then
.CW text ,
and then “any character that may not be part of an identifier”.
Because the substitution affects
.I all
the regular expression, we need to substitute the matched string with
another one that has
.CW word
instead of
.CW text ,
but keeping the characters matching
.CW [^a-z0-9_]
before and after the string
.CW text .
This can be done by surrounding in parentheses both
.CW [^a-z0-9_] .
Later, in the destination string, we may use
.CW \e1
to refer to the text matching the first regexp within parenthesis, and
.CW \e2
to refer to the second.
.PP
Because
.CW printtext
is not matched by
.CW [^a-z0-9_]text[^a-z0-9_] ,
it was untouched. However, “\f(CW␣text)\fP” was matched. In the destination string,
.CW \e1
was a white space,
because that is what matched the first parenthesized part. And
.CW \e2
was a right parenthesis, because that is what matched the second one.
As a result, we left those characters untouched, and used them as
.I context
to determine when to do the substitution.
.ix "match context
.PP
Regular expressions permit to clean up source files in an easy way.
In may cases, it makes no sense to keep white space at the end of lines.
This removes them.
.P1
; sed 's/[ \t]*$//'
.P2
.LP
We saw that a script
.CW t+
can be used to indent text in Acme.
Here it is.
.P1
; cat /bin/t+
#!/bin/rc
sed 's/^/\t/'
;
.P2
.LP
This other script removes one level of indentation.
.ix "text indent
.ix [t+]
.ix [t-]
.P1
; cat /bin/t-
#!/bin/rc
sed 's/^\t//'
;
.P2
.LP
How many mounts and binds are performed by the standard namespace?
How many others of your own did you add? The file
.CW /lib/namespace
.ix [/lib/namespace]
.ix "[namespace] file
is used to build an initial namespace for you. But this file has comments, on lines
starting with
.CW # ,
and may have empty lines.
The simplest thing would be to search just for what we want, and count the lines.
.P1
; sed 7q /lib/namespace
# root
mount -aC #s/boot /root $rootspec
bind -a $rootdir /
bind -c $rootdir/mnt /mnt

# kernel devices
bind #c /dev
; grep '^(bind|mount)' /lib/namespace
mount -aC #s/boot /root $rootspec
bind -a $rootdir /
bind -c $rootdir/mnt /mnt
.I ...
; grep '^(bind|mount)' /lib/namespace | wc -l
     41
; grep '^(bind|mount)' /proc/$pid/ns | wc -l
     72
.P2
.LP
We had 41 binds/mounts in the standard namespace, and the one used by
our shell (as reported by its
.CW ns
file) has 72 binds/mounts. It seems we added many ones in our profile.
.LP
There are many other useful uses of regular expressions, as you will be
able to see from here to the end of this book. In many cases, your C
programs can be made more flexible by accepting regular expressions
for certain parameters instead of mere strings. For example, an editor
might accept a regular expression that determines if the text is to be
shown using a
.CW "constant width font"
or a
.I "proportional width font" .
For file names matching, say
.CW .*\e.[ch] ,
it could use a constant width font.
.PP
It turns out that it is
.I trivial
to use regular expressions in a C program, by using the
.CW regexp
.ix [regexp]
library. The expression is
.I compiled
into a description more amenable to the machine, and the resulting
data structure (called a
.CW Reprog )
.ix [Reprog]
can be used for matching strings against the expression. This program
accepts a regular expression as a parameter, and then reads one line
at a time. For each such line, it reports if the string read matches the
regular expression or not.
.so progs/match.c.ms
.ix [match.c]
.LP
The call to
.CW regcomp
.ix [regcomp]
.ix "regular expression compiler"
.I compiles
the regular expression into
.CW prog .
Later,
.CW regexec
.I executes
the compiled regular expression to determine if it matches the string
just read in
.CW buf .
The parameter
.CW sub
points to an array of structures that keeps information about the match.
The whole string matching starts at the character pointed to by
.CW sub[0].sp
and terminates right before the one pointed to by
.CW sub[0].ep .
Other entries in the array report which substring matched the
first parenthesized expression in the regexp,
.CW sub[1] ,
which one matched the second one,
.CW sub[2] ,
etc. They are similar to
.CW \e1 ,
.CW \e2 ,
etc.
This is an example session with the program.
.P1
; 8.match '*.c'
regerror: missing operand for *	\fRThe * needs something on the left!\fP

; 8.match '\e.[123]'
!!x123
no match
!!.123
matched: '.1'
!!x.z
no match
!!x.3
matched: '.3'
.P2
.BS 2 "Sorting and searching
.LP
.ix sorting
.ix searching
One of the most useful task achieved with a few shell commands is inspecting
the system to find out things. In what follows we are going to learn how to do this,
using several assorted examples.
.PP
Running out of disk space? It is not likely, given the big disks we have today.
But anyway, which ones are the biggest files you have created at your home
directory?
.PP
The command
.CW du
(disk usage)
.ix [du]
.ix "disk usage
reports disk usage, measured in disk blocks. A disk block is usually 8 or 16 Kbytes,
depending on your file system. Although
.CW "du -a"
reports the size in blocks for each file, it is a burden to scan by yourself through the
whole list of files to search for the biggest one. The command
.CW sort
.ix [sort]
.ix "text sort
is used to sort lines of text, according to some criteria. We can ask
.CW sort
to sort the output of
.CW du
numerically (\f(CW-n\fP) in decreasing order (\f(CW-r\fP), with
biggest numbers first, and then use
.ix "[sort] flag~[-n]
.ix "[sort] flag~[-r]
.CW sed
to print just the first few lines. Those ones correspond to the biggest files, which
we are interested in.
.P1
; du -a bin | sort -nr | sed 15q
4211	bin
3085	bin/arm
864	bin/arm/enc
834	bin/386
333	bin/arm/madplay
320	bin/arm/madmix
319	bin/arm/deco
316	bin/386/minimad
316	bin/arm/minimad
280	bin/arm/mp3
266	bin/386/minisync
258	bin/rc
212	bin/arm/calc
181	bin/arm/mpg123
146	bin/386/r2bib
;
.P2
.LP
This includes directories as well, but point us quickly to files like
.CW bin/arm/enc
that seem to occupy 864 disk blocks!
.PP
But in any case, if the disk is filling up,
it is a good idea to locate the users that created files (or added data to them),
to alert them. The flag
.CW -m
for
.CW ls
lists the user name that last modified the file. We may collect user names for
all the files in the disk, and then notify them. We are going to play with commands
until we complete our task, using
.CW sed
to print just a few lines until we know how to process all the information.
The first step is to use the output
of
.CW du
as the initial data, the list of files. If we remove everything up to the file names,
we obtain a list of files to work with. 
.P1
; du -a bin | sed 's/.*	//' | sed 3q
bin/386/minimad
bin/386/minisync
bin/386/r2bib
.P2
.LP
Now we want to list the user who modified each file. We can change our data
to produce the commands that do that, and send them to a shell.
.P1
.ps -1
; du -a bin | sed 's/.*	//' | sed 's/^/ls -m /' | sed 3q
ls -m bin/386/minimad
ls -m bin/386/minisync
ls -m bin/386/r2bib
;
; du -a bin | sed 's/.*	//' | sed 's/^/ls -m /' | sed 3q | rc
[nemo] bin/386/minimad
[none] bin/386/minisync
[nemo] bin/386/r2bib
;
.ps +1
.P2
.LP
We still have to work a little bit more. And our command line is growing. Being
able to edit the text at any place in a Rio window does help, but it can be
convenient to define a
.B "shell function"
.ix [fn]
that encapsulates what we have done so far. A shell function is like a function
in any other language. The difference is that a shell function receives arguments
as any other command, in the command line. Besides, a shell function has
command lines in its body, which is not a surprise. Defining a function
for what we have done so far can save some typing in the near future.
Furthermore, the command we have just built, to list all the files within a given
directory, is useful by itself.
.P1
; fn lr {
;; du -a $1 | sed 's/.*	//' | sed 's/^/ls -m /' | rc
;; }
; 
.P2
.LP
This defined a function, named
.CW lr ,
.ix [lr]
that executes exactly the command line we developed.
In the function
.CW lr ,
we removed the
.CW "sed 3q"
because it is not reasonable for a function listing all files recursively to
stop after listing three of them. If we want to play, we can always add a
final
.CW sed
in a pipeline. Arguments given to the function are accessed like they would be
in a shell script. The difference is that the function is executed by the shell
where we call it, and not by a child shell. By the way, it is preferable to create
useful commands by creating in a shell, functions can not be edited as scripts, and
are not automatically shared among all shells like files are. Functions are handy to
make modular scripts.
.PP
.CW Rc
stores the function
definition using an
.ix "function definition
environment variable. Thus, most things said for environment variables apply for
functions as well (e.g., think about
.CW "rfork e" ).
.P1
; cat /env/'fn#lr'
fn lr {du -a $1|sed 's/.*	//'|sed 's/^/ls -m /'|rc}
;
.P2
.LP
The builtin function
.CW whatis
.ix [whatis]
is more appropriate to find out what a name is for
.CW rc .
It prints the value
associated to the name in a form that can be used as a command. For example,
here is of
.CW whatis
says about several names, known to us.
.P1
; whatis lr
fn lr {du -a $1|sed 's/.*	//'|sed 's/^/ls -m /'|rc}
; whatis cd
builtin cd
; whatis echo path
/bin/echo
path=(. /bin)
;
.P2
.LP
This is more convenient than looking through
.CW /bin ,
.CW /env ,
and the
.I rc (1)
manual page to see what a name is.
Let's try our new function.
.P1
; lr bin
[nemo] bin/386/minimad
[none] bin/386/minisync
[nemo] bin/386/r2bib
[nemo] bin/386/rc2bin
.I "...and many other lines of output..."
;
.P2
.LP
To obtain our list of users, we may remove everything but the user name.
.P1
; lr bin | sed 's/.([a-z0-9]+).*/\e1/' | sed 3q
nemo
none
nemo
;
.P2
.LP
And now, to get a list of users, we must drop duplicates. The program
.CW uniq
.ix [uniq]
.ix "remove duplicates
.ix "unique lines
knows how to do it, it reads lines and prints them,  lines showing up more than once
in the input are printed once. This program
needs an input with sorted lines. Therefore, we do what we just did, and sort
the lines and remove duplicate ones.
.P1
; lr bin | sed 's/.([a-z0-9]+).*/\e1/' | sort | uniq
esoriano
nemo
none
;
.P2
.LP
Note that we removed
.CW "sed 3q"
from the pipeline, because this command does what we wanted to do and
we want to process the whole file tree, and not just the first three ones.
It happens that
.CW sort
also knows how to remove duplicate lines, after sorting them. The flag
.CW -u
asks
.CW sort
.ix "[sort] flag~[-u]
to print a unique copy of each output line. We can optimize a little bit our command
to list file owners.
.P1
; lr bin  | sed 's/.([a-z0-9]+).*/\e1/' | sort -u
.P2
.LP
What if we want to list user names that own files at several file trees? Say,
.CW /n/fs1
and
.CW /n/fs2 .
We may have several file servers but might want to list file owners for all of them.
It takes time for
.CW lr
to scan an entire file tree, and it is desirable to process all trees in parallel. The
strategy may be to use several command lines like the one above, to produce
a sorted user list for each file tree. The combined user list can be obtained by
merging both lists, removing duplicates. This is depicted in figure [[!sort merge!]].
.LS
.PS
right
S: [
	down
	FS1: [ right ; box "lr /n/fs1" ; arrow right .2 ; box "sed" ; arrow right .2  ; box "sort" ]
	move
	FS2: [ right ; box "lr /n/fs2" ; arrow right .2  ; box "sed" ; arrow right .2  ; box "sort" ]
]
move
M: box "sort -mu" ; arrow ; box invis "sorted"
arrow from S.FS1.e to M.w+0,.1
arrow from S.FS2.e to M.w-0,.1
.PE
.LE F Obtaining a file owner list using sort to merge two lists for \f(CWfs1\fP and \f(CWfs2\fP
.PP
We define a function
.CW lrusers
.ix [lrusers]
.ix "non-linear pipe
to run each branch of the pipeline. This provides a compact way of executing it,
saves some typing, and improves readability. The output from the two pipelines
is merged using the flag
.CW -m
of
.CW sort ,
which merges two sorted files to produce a single list. The flag
.CW -u
(unique) must be added as well, because the same user could own files in both
file trees, and we want each name to be listed once.
.P1
; fn lrusers { lr $1 | sed 's/.([a-z0-9]+).*/\e1/' | sort }
; sort -mu <{lrusers /n/fs1} <{lrusers /n/fs2}
esoriano
nemo
none
paurea
;
.P2
.LP
For
.CW sort ,
each \f(CW<{\fP...\f(CW}\fP construct is just a file name (as we saw). This is a
simple way to let us use two pipes as the input for a single process.
.PP
To do something different,
we can revisit the first example in the last chapter, finding function definitions.
This script does just that, if we follow the style convention for declaring
functions that was shown at the beginning of this chapter. First, we try
to use
.CW grep
to print just the source line where the function
.CW cat
is defined in the file
.CW /sys/src/cmd/cat.c .
Our first try is this.
.P1
; grep cat /sys/src/cmd/cat.c
cat(int f, char *s)
	argv0 = "cat";
		cat(0, "<stdin>");
			cat(f, argv[i]);
.P2
.LP
Which is not too helpful. All the lines contain the string
.CW cat ,
but we want only the lines where
.CW cat
is at the beginning of line, followed by an open parenthesis. Second
attempt.
.P1
; grep '^cat\e(' /sys/src/cmd/cat.c
cat(int f, char *s)
.P2
.LP
At least, this prints just the line of interest to us. However, it is useful
to get the file name and line number before the text in the line. That
output can be used to point an editor to that particular file and line
number. Because
.CW grep
prints the file name when more than one file is given, we could use
.CW /dev/null
as a second file where to search for the line. It would not be there,
but it would make
.CW grep
print the file name. 
.P1
; grep  '^cat\e(' /sys/src/cmd/cat.c /dev/null
/sys/src/cmd/cat.c:cat(int f, char *s)
.P2
.LP
Giving the option
.CW -n
to
.CW grep
.ix "[grep] flag~[-n]
.ix "line number
makes it print the line number. Now we can really search for functions,
like we do next.
.P1
; grep -n '^cat\e(' /sys/src/cmd/*.c
/sys/src/cmd/cat.c:5: cat(int f, char *s)
.P2
.LP
And because this seems useful, we can package it as a shell script. It
accepts as arguments the names for functions to be located. The command
.CW grep
is used to search for such functions at all the source files in the current directory.
.P1
#!/bin/rc
rfork e
for (f in $*)
	grep -n '^'$f'\e('  *.[cCh]
.P2
.LP
How can we use
.CW grep
to search for
.CW -n ?
If we try,
.CW grep
would get confused, thinking that we are supplying an option. To avoid this,
the
.CW -e
option tells
.CW grep
.ix "[grep] flag~[-e]
that what follows is a regexp to search for.
.P1
; cat text
Hi there
How can we grep for -n?
Who knows!
; grep -n text
; grep -e -n text
how can we grep for -n?
.P2
.LP
This program has other useful options. For example, we may want to
locate lines in the file for a chapter of this book where we mention
figures. However, if the word
.CW figure
is in the middle of a sentence it would be all lower-case. When it is
starting a sentence, it would be capitalized. We must search both for
.CW Figure
and
.CW figure.
The flag
.CW -i
makes
.CW grep
.ix "case insensitive
.ix "[grep] flag~[-i]
become case-insensitive. All the text read is converted to lower-case
before matching the expression.
.P1
; grep -i figure ch1.ms
Each window shows a file or the output of commands.  Figure
figure are understood by acme itself. For commands
shown in the figure would be
.I "...and other matching lines
.P2
.LP
A popular searching task is determining if a file containing a mail message
is spam or not. Today, it would not work, because spammers employ heavy
.ix spam
armoring, and even send their text encoded in multiple images sent as HTML
mail. However, it was popular to see if a mail message contained certain
expressions, if it did, it was considered spam.
Because there will be many expressions, we may keep them in a file.
The option
.CW -f
for
.CW grep
.ix "[grep] flag~[-f]
takes as an argument a file containing all the expressions to search for.
.P1
; cat patterns
Make money fast!
Earn 10+ millions
(Take|use) viagra for a (better|best) life.
; if (grep -i -f patterns $mail ) echo $mail is spam
.P2
.ix "[patterns] file
.BS 2 "Searching for changes
.LP
.ix "file differences
.ix "file comparation
A different kind of search is looking for differences. There are
several tools that can be used to compare files. We saw
.CW cmp ,
.ix [cmp]
that compares two files. It
does not give much information, because it is meant to compare files that
are binary and not textual, and the program reports just which one is the first
byte that makes the files different. However, there is another tool,
.CW diff ,
.ix [diff]
that is more useful than
.CW cmp
when applied to text files. Many times,
.CW diff
is used just to compare two files to search for differences. For example, we can
compare the two files
.CW /bin/t+
and
.CW /tmp/t- ,
that look similar, to see how they differ. The tool reports what changed
in the first file to obtain the contents in the second one.
.P1
; diff /bin/t+ /bin/t-
2c2,3
< exec sed 's/^/	/'
---
> exec sed 's/^	//'
> 
.P2
.LP
The output shows the minimum set of differences between both files, here we see
just one. Each difference reported starts with a line like
.CW 2c2,3 ,
which explains which lines differ. This tool tries to show
a minimal set of differences, and it will try to aggregate runs of lines that change.
In this way, it can simply say that
several (contiguous) lines in the first file have changed and correspond to a different
set of lines in the second file. In this case, line 2 in the first file (\f(CWt+\fP)
has changed in favor of lines 2 and 3 in the second file. If we replace line 2 in
.CW t+
with lines 2 and 3 from
.CW t- ,
both files have be the same contents.
.PP
After the initial summary,
.CW diff
shows the relevant lines that differ in the first file, preceded by an initial
.CW <
sign to show that they come from the file on the left in the argument list, i.e.,
the first file. Finally, the lines that differ in this case for the second file are
shown. 
The line 3 is an extra
empty line, but for
.CW diff
that is a difference.
If we remove the last empty line in
.CW t- ,
this is what
.CW diff
says:
.P1
; diff /bin/t^(+ -)
2c2
< exec sed 's/^/	/'
---
> exec sed 's/^	//'
.P2
.LP
Let's improve the script. It does not accept arguments, and it would be better
to print a diagnostic and exit when arguments are given.
.so progs/tab.ms
.LP
This is what
.CW diff
says now.
.P1
; diff /bin/t+ tab
1a2,5
> if (! ~ $#* 0){
> 	echo usage: $0 >[1=2]
> 	exit usage
> }
;
.P2
.ix "script diagnostics
.LP
In this case, no line has to
.I change
in
.CW /bin/t+
to obtain the contents of
.CW tab .
However, we must
.I add
lines 2 to 5 from
.CW tab
after line 1 of
.CW /bin/t+ .
This is what
.CW 1a2,5
means.
Reversing the arguments of
.CW diff
produces this:
.P1
; diff tab /bin/t+
2,5d1
< if (! ~ $#* 0){
< 	echo usage: $0 >[1=2]
< 	exit usage
< }
.P2
.LP
Lines 2 to 5 of
.CW tab
must be deleted (they would be after line 1 of
.CW /bin/t+ ),
if we want
.CW tab
to have the same contents of
.CW /bin/t+ .
.PP
Usually, it is more convenient to run
.CW diff
supplying the option
.CW -n ,
.ix "[diff] flag~[-n]
which makes it print the file names along with the line numbers. This is
very useful to easily open any of the files being compared by addressing
the editor to the file and line number.
.P1
; diff -n /bin/t+ tab
/bin/t+:1 a tab:2,5
> if (! ~ $#* 0){
> 	echo usage: $0 >[1=2]
> 	exit usage
> }
.P2
.LP
Although some people prefer the
.CW -c
.ix "context [diff]
(context) flag, that makes it more clear what changed by printing a few lines
of context around the ones that changed.
.P1
; diff -n /bin/t+ tab
/bin/t+:1,2 - tab:1,6
  #!/bin/rc
+ if (! ~ $#* 0){
+ 	echo usage: $0 >[1=2]
+ 	exit usage
+ }
  exec sed 's/^/	/'
;
.P2
.LP
Searching for differences is not restricted to comparing just two files. In many cases
we want to compare two file trees, to see how they differ. For example, after installing
a new Plan 9 in a disk, and using it for some time, you might want to see if there are
changes that you made by mistake. Comparing the file tree in the disk with that used
as the source for the Plan 9 distribution would let you know if that is the case.
.PP
This tool,
.CW diff ,
can be used to compare two directories by giving their names. If works like
above, but compares all the files found in one directory with those in the other.
Of course, now it can be that a given file might be just at one directory, but not at
the other.
We are going to copy our whole
.CW $home/bin
to a temporary place to play with changes, instead of using the whole file system. 
.P1
; @{ cd ; tar c bin } | @{ cd /tmp ; tar x }
;
.P2
.LP
Now, we can change
.CW t+
in the temporary copy, by copying the
.CW tab
script we recently made. We will also add a few files to the new file tree and
remove a few other ones.
.P1
; cp tab /tmp/bin/rc/t+
; cp rcecho /tmp/bin/rc
; rm /tmp/bin/rc/^(d2h h2d)
;
.P2
.LP
So, what changed?
The option
.CW -r
asks
.CW diff
to go even further and compare two entire file trees, and not just two directories. It
descends when it finds a directory and recurs to continue the search for differences.
.P1
; diff -r ($home /tmp)^/bin
Only in /usr/nemo/bin/rc: d2h
Only in /usr/nemo/bin/rc: h2d
Only in /tmp/bin/rc: rcecho
diff /usr/nemo/bin/rc/t+ /tmp/bin/rc/t+
1a2,5
> if (! ~ $#* 0){
> 	echo usage: $0 >[1=2]
> 	exit usage
> }
;
.P2
.LP
The files
.CW d2h
and
.CW h2d
are only at
.CW $home/bin/rc ,
we removed them from the copied tree. The file
.CW rcecho
is only at
.CW /tmp/bin/rc
instead. We created it there. For
.CW diff ,
it would be the same if it existed at
.CW $home/bin/rc
and we removed
.CW rcecho
from there.
Also, there is a file that is different,
.CW t+ ,
as we could expect. Everything else remains the same.
.PP
It is now trivial to
answer questions like, which files have been added to our copy of the file tree?
.P1
; diff -r ($home /tmp)^/bin | grep '^Only in /tmp/bin'
Only in /tmp/bin/rc: rcecho
;
.P2
.LP
This is useful for security purposes. From time to time we might check that
a Plan 9 installation does not have files altered by malicious programs or by
user mistakes. If we process the output of
.CW diff ,
comparing the original file tree with the one that exists now,
we can generate the commands needed to restore the tree to its
original state. Here we do this to our little file tree. Files that are only in the new tree,
must be deleted to get back to our original tree.
.P1
.ps -2
; diff -r ($home /tmp)^/bin >/tmp/diffs
; grep '^Only in /tmp/' /tmp/diffs | sed -e 's|Only in|rm|' -e 's|: |/|'
rm /tmp/bin/rc/rcecho
.ps +2
.P2
.LP
Files that are only in the old tree have probably been deleted in the new tree,
assuming we did not create them in the old one. We must copy them again.
.P1
.ps -2
; d=/usr/nemo/bin
; grep '^Only in '^$d /tmp/diffs | 
;;  sed 's|Only in '^$d^'/(.+): ([^ ]+)|cp '^$d^'/\e1/\e2 /tmp/bin/\e1|'
cp /usr/nemo/bin/rc/d2h /tmp/bin/rc
cp /usr/nemo/bin/rc/h2d /tmp/bin/rc
.ps +2
.P2
.LP
In this command,
.CW \e1
is the path for the file, relative to the directory being compared, and
.CW \e2
is the file name. We have not used
.CW $home
to keep the command as clear as feasible. To complete our job, we must undo
any change to any file by coping files that differ.
.P1
; grep '^diff ' /tmp/diffs | sed 's/diff/cp/'
cp /usr/nemo/bin/rc/t+ /tmp/bin/rc/t+
.P2
.LP
All this can be packaged into a script, that we might call
.CW restore .
.so progs/restore.ms
.LP
And this is how we can use it.
.P1
; restore
rm /tmp/bin/rc/rcecho
cp /usr/nemo/bin/rc/d2h /tmp/bin/rc
cp /usr/nemo/bin/rc/h2d /tmp/bin/rc
cp /usr/nemo/bin/rc/t+ /tmp/bin/rc/t+
; restore|rc	\fR after having seen what this is going to do!\fP
.P2
.LP
We have a nice script, but pressing
.I Delete
while the script runs may leave an unwanted temporary file.
.ix "temporary file
.P1
; restore $home/bin /tmp/bin
\fBDelete\fP
; lc /tmp
.links				omail.11326.body
A1030.nemoacme			omail.2558.body
ch6.ms				restore.1425
;
.P2
.LP
To fix this
problem, we need to install a note handler like we did before in C. The shell
.ix "shell note~handler
.ix [sighup]
.ix [sigint]
.ix [sigalrm]
gives special treatment to functions with names
.CW sighup ,
.CW sigint ,
and 
.CW sigalrm .
A function
.CW sighup
is called by
.CW rc
when it receives a
.CW hangup
.ix "[hangup] note
note. The same happens for
.CW sigint
with respect to the
.CW interrupt
.ix "[interrupt] note
note and
.CW sigalrm
for the
.CW alarm
note. Adding this to our script makes it remove the temporary file
when the window is deleted or
.I Delete
is pressed.
.P1
fn sigint { rm $diffs }
fn sighup { rm $diffs }
.P2
.LP
This must be done after defining
.CW $diffs .
.BS 2 "AWK
.LP
.ix AWK
There is another tool is use extremely useful, which remains to be seen.
It is a programming language called
.I AWK .
Awk is meant to process text files consisting of records with multiple fields.
Most data in system and user databases, and much data generated by commands
looks like this. Consider the output of
.CW ps .
.P1
; ps | sed 5q
nemo   1    0:00   0:00     1392K Await    bns
nemo   2    1:09   0:00        0K Wakeme   genrandom
nemo   3    0:00   0:00        0K Wakeme   alarm
nemo   5    0:00   0:00        0K Wakeme   rxmitproc
nemo   6    0:00   0:00      268K Pread    factotum
.P2
.LP
We have multiple lines, which would be records for AWK.
All the lines we see contain different parts carrying different data, tabulated. In this
case, each different part in a line is delimited by white space. For AWK, each
part would be a field. This is our first AWK program. It prints the  user names for
owners of processes running in this system. Similar to what could be achieved
by using
.CW sed .
.P1
; ps | awk '{print $1}'
nemo
nemo
.I ...
; ps | sed 's/ .*//'
nemo
nemo
.I ...
.P2
.LP
The program for AWK was given as its only argument, quoted to escape it from
the shell.
AWK executed the program to process its standard input, because no file to process
was given as an argument. In this case, the program prints the first field for any
line. As you can see, AWK is very handy to cut columns of files for further processing.
There is a command in most UNIX machines named
.CW cut ,
that does precisely this, but using AWK suffices.
If we sort the set of user names and remove duplicates, we can know who is
using the machine.
.P1
; ps | awk '{print $1}' | sort -u
nemo
none
;
.P2
.LP
In general, an AWK program consists of a series of statements, of the form
.ix "AWK statement
.P1
.I "pattern \f(CW{\fP action \f(CW}\fP".
.P2
.LP
Each record is matched against the
.I pattern ,
and the
.I action
is executed for all records with a matching one. In our program, there was no
pattern. In this case, AWK executes the action for
.I all
the records. Actions are programmed using a syntax similar to C, using functions
that are either built into AWK or defined by the user. The most commonly used one
is
.CW print ,
which prints its arguments.
.PP
In AWK we have some predefined variables and we can define our own ones.
.ix "AWK variables
Variables can be strings, integers, floating point numbers, and arrays.  As a convenience,
AWK defines a new variable the first time you use it, i.e., when you initialize it.
.PP
The predefined variable
.CW $1
is a string with the text from the first field. Because the action where
.CW $1
appears is executed for a
record,
.CW $1
would be the first field of the record being processed. In our program, each time
.CW "print $1"
is executed for a line,
.CW $1
refers to the first field for that line. In the same way,
.CW $2
is the second field and so on. This is how we can list the names for the
processes in our system.
.P1
; ps | awk '{print $7}'
genrandom
alarm
rxmitproc
factotum
fossil
.I ...
.P2
.LP
It may be easier to use
.ix "line fields
AWK to cut fields than using sed, because splitting a line into fields is a natural thing
for the former. White space between different fields might be repeated to tabulate the data,
but AWK managed nicely to identify field number 7.
.PP
The predefined variable
.CW $0
represents the whole record. We can use it along with the variable
.CW NR ,
which holds an integer with the record number, to number the lines in a file.
.so progs/number.ms
.LP
We have used the AWK function
.CW printf ,
which works like the one in the C library. It provides more control for the output
format. Also, we pass the entire argument list to AWK, which would process the
files given as arguments or the standard input depending on how we call the
script.
.P1
; number number
   1 #!/bin/rc
   2 awk '{ printf("%4d %s\n", NR, $0); }' $*
;
.P2
.LP
In general, it is usual to wrap AWK programs using shell scripts. The input
for AWK may be processed by other shell commands, and the same might
happen to its output.
.PP
To operate on arbitrary records, you may specify a pattern for an action.
A pattern is a relational expression, a regular expression, or a combination of
both kinds od expressions. This example
uses
.CW NR
to print only records 3 to 5.
.ix "AWK pattern
.P1
; awk 'NR >= 3 && NR <=5 {print $0}' /LICENSE
with the following notable exceptions:

1. No right is granted to create derivative works of or
.P2
.LP
Here,
.CW "NR >=3 && NR <= 5"
is a relational expression. It does an
.I and
of two expressions. Only records with
.CW NR
between 3 and 5 match the pattern. As a result,
.CW print
is executed just for lines 3 through 5.
Because syntax is like in C, it is easy to get started. Just try.
Printing the entire record, i.e.,
.CW $0 ,
is so common, that
.CW print
prints that by default. This is equivalent to the previous command.
.P1
; awk 'NR >=3 && NR <= 5 {print}' /LICENSE
.P2
.LP
Even more, the default action is to print the entire record. This is also
equivalent to our command.
.P1
; awk 'NR >=3 && NR <= 5' /LICENSE
.P2
.LP
By the way, in this particular case, using
.CW sed
might have been more simple.
.P1
; sed -n 3,5p /LICENSE
with the following notable exceptions:

1. No right is granted to create derivative works of or
;
.P2
.LP
Still, AWK may be preferred if more complex processing is needed, because it provides
a full programming language. For example, this prints only even lines and stops at
line 6.
.P1
.ps -2
; awk 'NR%2 == 0 && NR <= 6' /LICENSE
Lucent Public License, Version 1.02, reproduced below,

   to redistribute (other than with the Plan 9 Operating System)
.ps +2
.P2
.LP
It is common to search for processes with a given name. We used grep for this task.
But in some cases, unwanted lines may get through
.P1
.ps -1
; ps | grep rio
nemo             39    0:04   0:16     1160K Rendez   rio
nemo            275    0:01   0:07     1160K Pread    rio
nemo           2602    0:00   0:00      248K Await    rioban
nemo            277    0:00   0:00     1160K Pread    rio
nemo           2607    0:00   0:00      248K Await    brio
nemo            280    0:00   0:00     1160K Pread    rio
.I ...
.ps +1
.P2
.LP
We could filter them out using a better
.CW grep
pattern.
.P1
.ps -1
; ps | grep 'rio$'
nemo             39    0:04   0:16     1160K Rendez   rio
nemo            275    0:01   0:07     1160K Pread    rio
nemo            277    0:00   0:00     1160K Pread    rio
nemo           2607    0:00   0:00      248K Await    brio
nemo            280    0:00   0:00     1160K Pread    rio
.I ...
; ps | grep ' rio$'
nemo             39    0:04   0:16     1160K Rendez   rio
nemo            275    0:01   0:07     1160K Pread    rio
nemo            277    0:00   0:00     1160K Pread    rio
nemo            280    0:00   0:00     1160K Pread    rio
.I ...
.ps +1
.P2
.LP
But AWK just knows how to split a line into fields.
.P1
.ps -1
; ps | awk '$7 ~ /^rio$/'
nemo             39    0:04   0:16     1160K Rendez   rio
nemo            275    0:01   0:07     1160K Pread    rio
nemo            277    0:00   0:00     1160K Pread    rio
nemo            280    0:00   0:00     1160K Pread    rio
.I ...
.ps +1
.P2
.LP
This AWK program uses a pattern that requires field number 7
to match the pattern
.CW /^rio$/ .
As you know, by default, the action is to print the matching record.
The operator
.CW ~
yields true when both arguments match. Any argument can be a regular
expression, enclosed between two slashes. The pattern we used required
.I all
of field number 7 to be just
.CW rio ,
because we used
.CW ^
and
.CW $
to require
.CW rio
to be right after the
.I start
of the field, and before the
.I end
of the field. As we said,
.CW ^
and
.CW $
mean the start of the text being matched and its end. Whether the
text is just a field, a line, or the entire file, it depends on the program using the
regexp.
.LP
It is easy now to list process pids for
.CW rio
that belong to user
.CW nemo .
.P1
; ps | awk '$7 ~ /^rio$/ && $1 ~ /^nemo$/ {print $2}'
39
275
277
280
.I ...
.P2
.LP
How do we kill broken processes? AWK may help.
.P1
.ps -1
; ps |awk '$6 ~ /Broken/ {printf("echo kill >/proc/%s/ctl\n", $2);}'
echo kill >/proc/1010/ctl
echo kill >/proc/2602/ctl
.ps +1
.P2
.LP
The 6th field must be
.CW Broken ,
.ix [Broken]
and to kill the process we can write
.CW kill
.ix [kill]
to the process control file. The 2nd field is the pid and can be used to
generate the file path. Note that in this case the expression matched against
the 6th field is just
.CW /Broken/ ,
which matches with any string containing
.CW Broken .
In this case, it suffices and we do not need to use
.CW ^
and
.CW $ .
.PP
Which one is the biggest process, in terms of memory consumption? The 6th
field from the output of
.CW ps
reports how much memory is using a process. We could use our known tools
to answer this question. The argument
.CW +4r
for
.CW sort
asks for a sort of lines but starting in the field 4 as the sort key. This is a lexical
sort, but it suffices. The
.ix "reverse sort
.CW r
means
.I reverse
sort, to get biggest processes first. And we can use
.CW sed
to print just the first line and only the memory usage.
.P1
.ps -1
; ps | sort +4r 
nemo           3899    0:01   0:00    11844K Pread    gs
nemo             18    0:00   0:00     9412K Sleep    fossil
.I "...and more fossils
nemo             33    0:00   0:00     1536K Sleep    bns
nemo             39    0:09   0:33     1276K Rendez   rio
nemo            278    0:00   0:00     1276K Rendez   rio
nemo            275    0:02   0:14     1276K Pread    rio
.I "...and many others.
; ps | sort +4r | sed 1q
nemo           3899    0:01   0:00    11844K Pread    gs
; ps | sort +4r | sed -e 's/.* ([0-9]+K).*/\1/' -e 1q
11844K
.ps +1
.P2
.LP
We exploited that the memory usage field terminates in an upper-case
.CW K ,
and is preceded by a white space. This is not perfect, but it works.
We can improve this by using AWK. This is more simple and works better.
.P1
; ps | sort +4r | sed 1q | awk '{print $5}'
11844K
.P2
.LP
The
.CW sed
can be removed if we ask AWK to exit after printing the 5th field for the first
record, because that is the biggest one.
.P1
; ps | sort +4r | awk '{print $5; exit}'
11844K
.P2
.LP
And we could get rid of
.CW sort
as well. We can define a variable in the AWK program to keep track of
the maximum memory usage, and output that value after all the records have
.ix "memory usage
been processed. But we need to learn more about AWK to achieve this.
.PP
To compute the maximum of a set of numbers, assuming one number per
input line, we may set a ridiculous low initial value for the maximum and update
its value as we see a bigger value. It is better to take the first value as the initial
maximum, but let's forget about it. We can use two special patterns,
.CW BEGIN ,
and
.CW END .
.ix "[BEGIN] pattern
.ix "[END] pattern
The former executes its action
.I before
processing any field from the input. The latter executes its action
.I after
processing all the input. Those are nice placeholders to put code that must
be executed initially or at the end. For example, this AWK program computes the
total sum and average for a list of numbers.
.P1
; seq 5000 | awk '
;; BEGIN { sum=0.0 }
;; { sum += $1 }
;; END { print sum, sum/NR }
;; '
12502500 2500.5
.P2
.LP
Remember that
.CW ;;
is printed by the shell, and not part of the AWK program. We have used
.CW seq
.ix [seq]
to print some numbers to test our script. And, as you can see, the syntax for actions
is similar to that of C. But note that a statement is also delimited by a newline or a closed
brace, and
we do not need to add semicolons to terminate them. What did this program do?
Before even processing the first line,
the action of
.CW BEGIN
was executed. This sets the variable
.CW sum
to
.CW 0.0 .
Because the value is a floating point number, the variable has that type. Then, field
after field, the action without a pattern was executed, updating
.CW sum .
At last, the action for
.CW END
printed the outcome. By dividing the number of records (i.e., of lines or numbers)
we compute the average.
.PP
As an aside,
it can be funny to note that there are many AWK programs with only an action
for
.CW BEGIN .
That is a trick played to exploit this language to evaluate complex expressions
from the shell. Another contender for hoc.
.P1
; awk 'BEGIN {print sqrt(2) * log(4.3)}'
2.06279
; awk 'BEGIN {PI=3.1415926; print PI * 3.7^2}'
43.0084
.P2
.LP
This program is closer to what we want to do to determine
which process is the biggest one. It computes the maximum of a list of numbers.
.ix "maximum
.P1
; seq 5000 | awk '
;; BEGIN { max=0 }
;; {	if (max < $1)
;; 		max=$1
;; }
;; END { print max }
;; '
5000	\fICorrect?\fP
.P2
.LP
This time, the action for all the records in the input updates
.CW max ,
to keep track of the biggest value. Because
.CW max
was first used in a context requiring an integer (assigned 0), it is integer. Let's try
now our real task.
.P1
; ps | awk '
;; BEGIN { max=0 }
;; {	if (max < $5)
;; 		max=$5
;; }
;; END { print max }
;; '
9412K	\fIWrong! because it should have said...\fP
; ps | sort +4r | awk '{print $5; exit}'
11844K
.P2
.LP
What happens is that
.CW 11844K
is not bigger than
.CW 9412K .
Not as a string.
.P1
; awk 'BEGIN { if ("11844K" > "9412K") print "bigger" }'
;
.P2
.LP
Watch out for this kind of mistake. It is common, as a side effect of AWK efforts
to simplify things for you, by trying to infer and declare variable types as you use
them.
We must force AWK to take the 5th field as a number, and not as a string.
.P1
; ps | awk '
;; BEGIN { max=0 }
;; {	mem= $5+0
;; 	if (max < mem)
;; 		max=mem
;; }
;; END { print max }
;; '
11844
.P2
.LP
Adding
.CW 0
to
.CW $5
forced the (string) value in
.CW $5
to be understood as a integer value. Therefore,
.CW mem
is now an integer with the numeric value from the 5th field. Where is the “\f(CWK\fP”?
When converting the string to an integer, AWK stopped when it found the “\f(CWK\fP”.
Therefore, this forced conversion has the nice side effect of getting rid of the final
letter after the memory size.
It seems simple to compute the average process (memory)
size, doesn't it? AWK lets you do many things, easily.
.ix "average process
.P1
; ps | awk '
;; BEGIN { tot=0}
;; { tot += $5+0 }
;; END { print tot, tot/NR }
;; '
319956 2499.66
.P2
.BS 2 "Processing data
.LP
.ix "data processing
.ix "student account
Each semester, we must open student accounts to let them use the machines.
This seems to be just the job for AWK and a few shell commands,
and that is the tool we use. We take the list for students in the weird format
that each semester the bureaucrats in the administration building invent just
to keep us entertained. This format may look like this list.
.so progs/list.ms
.ix "[list] AWK~script
.LP
We want to write a program, called
.CW list2usr
that takes this list as its input and helps to open the student accounts. But
before doing anything, we must get rid of empty lines and the comments nicely
placed after
.CW #
signs in the original file.
.P1
; awk '
;; /^#/	{ next }
;; /^$/	{ next }
;; 	{ print }
;; ' list
2341|Rodolfo Martínez|Operating Systems|B|ESCET
6542|Joe Black|Operating Systems|B|ESCET
23467|Luis Ibáñez|Operating Systems|B|ESCET
23341|Ricardo Martínez|Operating Systems|B|ESCET
7653|José Prieto|Computer Networks|A|ESCET
.P2
.LP
.ix "AWK program
There are several new things in this program. First, we have multiple patterns
for input lines, for the first time. The first pattern matches lines with an initial
.CW # ,
and the second matches empty lines. Both patterns are just a regular expression,
which is a shorthand for matching it against
.CW $0 .
This is equivalent to the first statement of our program.
.P1
$0 ~ /^#/	{ next }
.P2
.LP
Second, we have used
.CW next
to skip an input record. When a line matches a commentary line, AWK executes
.CW next .
This skips to the next input record, effectively throwing away the input line.
But look at this other program.
.P1
; awk '
;; 	{ print }
;; /^#/	{ next }
;; /^$/	{ next }
;; ' list
# List of students in the random format for this semester
# you only know the format when you see it.
.ix "[next] AWK~command
.ix "skip record
.I ...
.P2
.LP
It does
.I not
ignore comments nor empty lines. AWK executes the statements in the order you
.ix "ignore comment
wrote them. It reads one record after another and executes, in order,
all the statements
with a matching pattern. Lines with comments match the first and the third statement.
But it does not help to skip to the
.CW next
input record once you printed it.  The same happens to empty lines.
.ix "input record
.PP
Now that we know how to get rid of weird lines, we can proceed.
To create accounts for all students in the course in Operating Systems, group B,
we must first select lines for that course and group. This semester, fields are
delimited by a vertical bar, the course field is the 3rd, and the group field is the 4th.
This may help.
.P1
; awk '-F|' '
;; /^#/	{ next }
;; /^$/	{ next }
;; $3 ~ /Operating Systems/ && $4 ~ /B/	{ print $2 }
;; ' list
Rodolfo Martínez
Joe Black
Luis Ibáñez
Ricardo Martínez
;
.P2
.LP
We had to tell AWK how fields are delimited using
.ix "field delimiter
.ix "[awk] flag~[-F]
.CW -F| ,
quoting it from the shell. This option sets the characters used to delimit fields,
i.e., the field delimiter. Although it admits as an argument a regular expression, saying
just
.CW |
suffices for us now.
We also had to
match the 3rd and 4th fields against desired values, and print the student name
for matching records.
.PP
Our plan is a follows. We are going to assume that a program
.CW adduser
exists. If it does not, we can always create it for our own purposes. Furthermore,
we assume that we must give the desired user name and the full student name
as arguments to this program, like in
.P1
; adduser rmartinez Rodolfo Martínez
.P2
.LP
Because it is
not clear how to do all this, we experiment using the shell before placing all the
bits and pieces into our
.CW list2usr
shell script.
.ix [list2usr] [rc]~script
.PP
One way to invent a user name for each student
is to pick the initial for the first name, and add the last name.
We can use
.CW sed
for the job.
.P1
; name='Luis Ibáñez'
; echo $name |  sed 's/(.)[^ ]+[ ]+(.*)/\e1\e2/'
LIbáñez
; name='José Martínez'
; echo $name | sed 's/(.)[^ ]+[ ]+(.*)/\e1\e2/'
JMartínez
.P2
.LP
But the user name looks funny, we should translate to lower case and, to avoid
problems for this user name when used in UNIX, translate accented characters to
their ascii equivalents. Admittedly, this works only for spanish names, because other
names might use different non-ascii characters and we wouldn't be helping our UNIX
systems.
.P1
; echo LIbáñez | tr A-Z a-z | tr '[áéíóúñ]' '[aeioun]'
libanez
;
.P2
.LP
But the generated user name may be already taken by another user.
If that is the case, we might try to take the first name, and add the initial from
the last name.
If this user name is also already taken, we might try a few other
combinations, but we won't do it here.
.P1
; name='Luis Ibáñez'
; echo $name | sed 's/([^ ]+)[ ]+(.).*/\e1\e2/' |
;; tr A-Z a-z | tr '[áéíóúñ]' '[aeioun]'
luisi
.P2
.LP
How do we now if a user name is taken? That depends on the system where
the accounts are to be created. In general, there is a text file on the system that
lists user accounts. In Plan 9, the file
.CW /adm/users
lists users known to the file server machine. This is an example.
.P1
; sed 4q /adm/users
adm:adm:adm:elf,sys
aeverlet:aeverlet:aeverlet:
agomez:agomez:agomez:
albertop:albertop::
.P2
.LP
The second field is the user name, according to the manual page for our file
server program,
.I fossil (4).
.ix [fossil]
As a result, this is how we can know if a user name can be used for a new user.
.P1
.ps -1
; grep -s '^[^:]+:'^$user^':' /adm/users && echo $user exists 
nemo exists
; grep -s '^[^:]+:'^rjim^':' /adm/users && echo rjim exists 
.ps +1
.P2
.LP
The flag
.CW -s
asks
.CW grep
.ix "[grep] flag~[-s]
.ix "silent [grep]
to remain silent, and only report the appropriate exits status, which is what
we want.
In our little experiment, searching for
.CW $user
in the second field of
.CW /adm/users
succeeds, as it could be expected. On the contrary, there is no
.CW rjim
known to our file server. That could be a valid user name to add.
.PP
There is still a little bit of a problem. User names that we add can no longer
be used for new user names. What we can do is to maintain our own
.CW users
file, created initially by copying
.CW /adm/users ,
.ix [/adm/users]
and adding our own entry to this file each time we produce an output line
to add a new user name.
.PP
We have all the pieces. Before discussing this any further, let's show the resulting
script.
.so progs/list2usr.ms
.LP
We have defined several functions, instead of merging it all in a single, huge,
command line. The
.CW listusers
function is our starting point. It encapsulates nicely the AWK program to list
just the student names for our course and group. The script arguments are given
to the function, which passes them to AWK. The next couple of commands are our
translations to use only lower-case ascii characters for user names.
.PP
The functions
.CW uname1
and
.CW uname2
encapsulate our two methods for generating a user name. They receive the full
student name and print the proposed user name. But we may need to try both
if the first one yields an existing user name. What we do is to read one line
at a time the output from
.P1
listusers $* | tr A-Z a-z | tr '[áéíóúñ]' '[aeioun]'
.P2
.LP
using a
.CW while
loop and the
.CW read
command, which reads a single line from the input. Each line read is placed in
.CW $name ,
to be processed in the body of the
.CW while .
And now we can try to add a user using each method.
.PP
To try to add an account, we defined the function
.CW add .
It determines if the account exists as we saw. If it does, it sets
.CW status
to a non-null value, which is taken as a failure by the one calling the function.
Otherwise, it sets a null status after printing the command to add the account,
and adding a fake entry to our
.CW users
file. In the future, this user name will be considered to exist, even though it may not
be in the real
.CW /adm/users .
.PP
Finally, note how the script catches
.CW interrupt
and
.CW hangup
.ix "[interrupt] note
.ix "[hangup] note
.ix "[rc] note~handler
notes by defining two functions, to remove the temporary file for the user list. Note
also how we print a message when the program fails to determine a user name
for the new user. And this is it!
.P1
; list2usr list
adduser rmartinez rodolfo martinez
adduser jblack joe black
adduser libanez luis ibanez
adduser ricardom ricardo martinez
.P2
.LP
We admit that, depending on the number of students, it might be more trouble
to write this program than to open the accounts by hand. However, in
.I all
semesters to follow, we can prepare the student accounts amazingly fast!
And there is another thing to take into account. Humans make mistakes, programs
do not so as often. Using our new tool we are not likely to make mistakes by
adding an account with a duplicate user name.
.PP
After each semester, we must issue grades to students. Depending on the
course, there are several separate parts (e.g., problems in a exam) that
contribute to the total grade. We can reuse a lot from our script to prepare
a text file where we can write down grades.
.so progs/list2grades.ms
.ix "[list2grades] [rc]~script
.LP
Note how we integrated
.CW $nquestions
in the AWK program, by closing the quote for the program right before
it, and reopening it again.
This program produces this output.
.P1
; list2grades list
Name                   	Q-1	Q-2	Q-3	Total
Rodolfo Martínez        -	-	-	-
Joe Black         	-	-	-	-
Luis Ibáñez           	-	-	-	-
Ricardo Martínez       	-	-	-	-
.P2
.LP
We must just fill the blanks, with the grades. And of course, it does not pay
to compute the final (total) grade by hand. The resulting file may be processed
using AWK for doing anything you want. You might send the grades by email
to students, by keeping their user names within the list. You might convert this
into HTML and publish it via your web server, or any other thing you see fit.
Once the scripts are done after the first semesters, they can be used forever.
.PP
And what happens when the bureaucrats change the format for the input list?
You just have to tweak a little bit
.CW listusers ,
and it all will work. If this happens often, it might pay to put
.CW listusers
into a separate script so that you do not need to edit all the scripts using it.
.BS 2 "File systems
.LP
There are many other tools available. Perhaps surprisingly (or not?) they are just
file servers.
As we saw, a
.B "file server"
is just a process serving files. In Plan 9, a file server
serves a file tree
to provide some service. The tree is implemented by a particular
data organization, perhaps just kept in the memory of the file server process.
This data organization used to serve files is known as a
.B "file system" .
Before reading this book, you might think that a file system is just some way
to organize files in a disk. Now you know that it does not need to be the case.
In many cases, the program that understands (e.g., serves) a particular file system
is also called a file system, perhaps confusingly. But that is just to avoid saying
“the file server program that understands the file system...”
.PP
All device drivers, listed in section 3 of the manual, provide their interface through
the file tree they serve. Many device drivers correspond
to real, hardware, devices. Others provide a particular service, implemented with
just software. But in any case, as you saw before, it is a matter of knowing which
files provide the interface for the device of interest, and how to use them.
The same idea is applied for many other cases.
Many tools in Plan 9, listed in section 4
of the manual, adopt the form of a file server.
.PP
For example, various archive formats are understood by programs like
.CW fs/tarfs
.ix [tarfs]
(which understands tape archives with
.I tar (1)
format),
.CW fs/zipfs
.ix [zipfs]
(which understands ZIP files), etc.
Consider the tar file with music that we created some time ago,
.P1
; tar tf /tmp/music.tar
alanparsons/
alanparsons/irobot.mp3
alanparsons/whatgoesup.mp3
pausini/
pausini/trateilmare.mp3
supertramp/
supertramp/logical.mp3
.P2
.LP
We can use
.CW tarfs
to browse through the archive as if files were already extracted.
The program
.CW tarfs
reads the archive and provides a (read-only) file system that reflects the
contents in the archive. It mounts itself by default at
.CW /n/tapefs ,
but we may ask the program to mount itself at a different path using the
.CW -m
option.
.P1
; fs/tarfs -m /n/tar /tmp/music.tar
; ns | grep tar
mount -c '#|/data1' /n/tar 
.P2
.LP
The device
.CW #|
is the
.I pipe (3)
device. Pipes are created by mounting this device (this is what
.ix "pipe device
.ix "[#|] device~driver
.I pipe (2)
does). The file
.CW '#|/data1'
.ix "[#|/data1]
.ix "end~of pipe
is an end for a pipe, that was mounted by
.CW tar
at
.CW /n/tar .
At the other end of the pipe,
.CW tarfs
is speaking 9P, to supply the file tree for the archive that we have mounted.
.PP
The file tree at
.CW /n/tar
permits browsing the files in the archive, and doing anything with them
(other than writing or modifying the file tree).
.P1
; lc /n/tar
alanparsons	pausini		supertramp
; lc /n/tar/alanparsons
irobot.mp3	whatgoesup.mp3
; cp /n/tar/alanparsons/irobot.mp3 /tmp
;
.P2
.LP
The program terminates itself when its file tree is finally unmounted.
.P1
; ps | grep tarfs
nemo            769    0:00   0:00  88K Pread    tarfs
; unmount /n/tar
; ps | grep tarfs
;
.P2
.LP
The shell along with the many commands that operate on files represent
a useful toolbox to do things. Even more so if you consider the various file
servers that are included in the system.
.PP
Imagine that you have an audio CD and want to store its songs, in MP3 format,
at
.CW /n/music/album .
The program
.CW cdfs
.ix [cdfs]
.ix "CD file~system
provides a file tree to operate on CDROMs. After inserting an audio CD in the
CD reader, accessed through the file
.CW /dev/sdD0 ,
we can list its contents at
.CW /mnt/cd .
.P1
; cdfs -d /dev/sdD0
; lc /mnt/cd
a000	a002	a004	a006	a008	a010
a001	a003	a005	a007	a009	ctl
.P2
.LP
Here, files
.CW a000
to
.CW a010
correspond to
.I audio
tracks in the CD. We can convert each file to MP3 using a tool like
.CW mp3enc .
.ix "CD burn
.ix "audio CD
.P1
; !!for (track in /mnt/cd/a*) {
;;  mp3enc $track /n/music/album/$track.mp3
;; }
.I "...all tracks being encoded in MP3..."
.P2
.LP
It happens that
.CW cdfs
knows how to (re)write CDs. This example, taken from the
.I cdfs (4)
manual page, shows how to duplicate an audio CD.
.P1
.I "First, insert the source audio CD.
; cdfs -d /dev/sdD0
; mkdir /tmp/songs
; cp /mnt/cd/a* /tmp/songs
; unmount /mnt/cd
.I "Now, insert a blank CD.
; cdfs -d /dev/sdD0
; lc /mnt/cd
; ctl    wa     wd
; cp /tmp/songs/* /mnt/cd/wa	\fRto copy songs as audio tracks\fP
; rm /mnt/cd/wa			\fRto fixate the disk contents\fP
; unmount /mnt/cd
.P2
.LP
For a blank CD,
.ix "blank CD
.CW cdfs
presents two directories in its file tree:
.CW wa
and
.CW wd .
Files copied into
.CW wa
are burned as audio tracks. File copied into
.CW wd
are burned as data tracks. Removing either directory fixates the disk, closing
the disk table of contents.
.PP
If the disk is re-writable, and had some data in it, we could even get rid of
the previous contents by sweeping through the whole disk blanking it. It would
be as new (a little bit more thinner, admittedly).
.P1
; echo blank >/mnt/cd/ctl
.I "blanking in progress...
.P2
.LP
When you know that it will not be the
last time you will be doing something, writing a small shell script will save time
in the future. Copying a CD seems to be the case for a popular task.
.so progs/cdcopy.ms
.ix "CD copy
.ix "[cdcopy] [rc]~script
.PP
The script copies a lot of data at
.CW /tmp/songs.$pid .
Hitting
.I Delete ,
might leave those files there by mistake. One fix would be to define a
.CW sigint
function. However, 
provided that machines have plenty of memory, 
there is another file system that might help.
The program
.CW ramfs
.ix [ramfs]
.ix "ram file~system
supplies a read/write file system that is kept in-memory. It uses dynamic memory
to keep the data for the files created in its file tree.
.CW Ramfs
mounts itself by default at
.CW /tmp .
So, adding a line
.P1
ramfs -c
.P2
.LP
before using
.CW /tmp
in the script will ensure that no files are left by mistake in
.CW $home/tmp
(which is what is mounted at
.CW /tmp
by convention).
.PP
Like most other file servers listed in section 4 of the manual,
.CW ramfs
accepts flags
.CW -abc
to mount itself
.I after ,
.I before ,
and
allowing file
.I creation .
Two other popular options are
.CW -m
.I dir ,
to choose where to mount its file tree, and
.CW -s
.I srvfile ,
to ask
.CW ramfs
to post a file at
.CW /srv ,
for mounting it later.
Using these flags, we may able to compile programs in directories where we do not
have permission to write.
.P1
; ramfs -bc -m /sys/src/cmd
; cd /sys/src/cmd
; 8c -FVw cat.c
; 8l -o 8.cat cat.8
; lc 8.* cat.*
8.cat	cat.8	cat.c
; rm 8.cat cat.8
.P2
.LP
After mounting
.CW ramfs
with
.CW -bc
at
.CW /sys/src/cmd ,
new files created in this directory will be created in the file tree served by
.CW ramfs ,
and not in the real
.CW /sys/src/cmd .
The compiler and the loader will be able to create their output files, and we will
neither require permission to write in that directory, nor leave unwanted object
files there.
.PP
The important point here is not how to copy a CD, or how to use
.CW ramfs .
The important thing
is to note that there are many different
programs that allow you to use devices and to do things through a file interface.
.PP
When undertaking a particular task, it will prove to be useful to know which
file system tools are available. Browsing through the system manual, just to see
which things are available,
will prove to be an invaluable help, to save time, in the future.
.SH
Problems
.IP 1
Write a script that copies all the files at
.CW $home/www
terminated in
.CW .htm
to files terminated in
.CW .html .
.IP 2
Write a script that edits the HTML in those files to refer always to
.CW .html
files and not to
.CW .htm
files.
.IP 3
Write a script that checks that URLs in your web pages are not broken. Use
the
.CW hget
command to probe your links.
.IP 4
Write a script to replace duplicate empty lines with a single empty line.
.IP 5
Write a script to generate (empty) C function definitions from text containing
the function prototypes.
.IP 6
Do the opposite. Generate C function prototypes from function definitions.
.IP 7
Write a script to alert you by e-mail when there are new messages in a web
discussion group. The mail must contain a portion of the relevant text and
a link to jump to the relevant web page.
.IP 8
.I Hint:
The program
.CW htmlfmt
may be of help.
.IP 9
Improve the scripts resulting from answers to problems for the last chapter
using regular expressions.
.ds CH
.bp
 .
.bp
 
