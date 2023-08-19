.so tmacs
.TL
Preface
.PP
Using effectively the operating system is very important for anyone
working with computers. It can be the difference between performing
most tasks by hand, and asking the computer to perform them.
.tl '''
.PP
Traditionally, Operating Systems courses used UNIX to do this. However,
today there is no such thing as UNIX. Linux is a huge system, full of
inconsistencies, with programs that do multiple tasks and do not perform
them well. Linux manual pages just cannot be read.
.PP
These lecture notes use Plan 9 from Bell Labs to teach a first (practical!)
course on operating systems. The system is easy to use for programmers,
and is an excellent example of high-quality system design and software
development. Studying its code reveals how simplicity can be more effective
than contortions made by other systems.
.PP
The first Operating Systems course at Rey Juan Carlos University is focused
on practice. Because in theory, theory is like practice, but in practice it is not.
What is important is for you to use the system, and to learn to solve problems.
Theory will come later to fill the gaps and try to give more insight about what
a system does and how can it be used.
.PP
The whole text assumes that you have been already exposed to computer,
and used at least a computer running Windows. This is so common that it makes
no sense to drop this assumption. Furthermore, we assume that you already know
how to write programs. This is indeed the case for the lecture this text is written for.
One last assumption is that you attended a basic computer architecture course, and
you know at least basic concepts. There is a quick review appendix in case you need
to refresh your memory.
.PP
Throughout the text, the
.B boldface
font is used when a new concept is introduced. This will help you to make quick reviews
and to double check that you know the concepts. All important concepts are listed
in the index, at the end of the book. 
The
.CW "constant width"
teletype font is used to refer to machine data, including functions, programs, and
symbol names. In many cases, text in constant width font reproduces a session with
the system (e.g., typing some commands and showing their output). The text written
by the user (and not by the computer) is slightly
.CW \S'15'slanted\S'0' ,
but still in constant width. Note the difference with respect to the font
used for text written by a program, which is not
.CW slanted .
.I Italics
are used to emphasize things and to refer to the system manual, like in
.I intro (1).
Regarding numeric
values, we use the C notation to represent hexadecimal and octal numeric bases.
.bp 1
Unlike most other textbooks for operating systems courses, bibliographic
references are kept to the bare minimum. We cite a particular text when we
think that it may
be worth reading to continue learning about something said in this book. 
So, do not quickly dismiss references. We encourage you to read them, to learn
more. There are not so many ones. If you want to get a thorough set of references
for something discussed in the test, we suggest looking at a more classical operating
systems textbook, like for example [1].
.PP
It is important to note that this book is not a reference for using
an operating system nor a reference for Plan 9 from Bell Labs. The user's manual
that comes installed within the system is the proper reference to use. These
lecture notes just shows you how things work, by using them. Once you have gone
through the course, you are expected to search and use the user's manual as
a reference.
.PP
One final note of caution. This text is to be read with a computer side by side. The
only way to learn to use a system is by actually using it. Reading this without doing
so is meaningless.
.PP
I am grateful go to other colleagues who suffered or helped in one way or another
to write this book. First, authors of Plan 9 from Bell Labs made an awesome system,
worth describing for an Operating Systems Course. It cannot be overemphasized how
much help the authors of Plan 9 provide to anyone asking questions in the
.CW 9fans
list. For what is worth, I have to say that I am deeply grateful to
people like Rob Pike, Dave Presotto, Jim
McKie, Russ Cox, and many others. In particular, Russ Cox seems to be a program
listening for questions at
.CW 9fans ,
at least his response time suggests that.
I have learned a lot from you all (or I tried).
Other colleagues from Rey Juan Carlos University helped me as well.
Pedro de las Heras was eager to get new drafts for this manuscript.
Sergio Arévalo was an unlimited supply of
useful comments and fixes for improving this book, specially for using
it as a textbook. José Centeno was scared to hell after reading our initial description
of computer networks, and helped to reach a much better description.
.sp 1i
Francisco J. Ballesteros
.br
Laboratorio de Sistemas,
.br
Rey Juan Carlos University of Madrid
.br
Madrid, Spain
.br
2006
