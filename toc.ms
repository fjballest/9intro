.nr LT 13cm
.nr LL 13cm
.nr PO 2cm
.nr HM 2cm
.nr FM 2cm
.nr TM 2cm
.nr FL 13cm
.pl 24cm
.pl 24cm
.po 2cm
.ll 13cm
.ps +4
.ce 1
.B "Table of Contents"
.ps -4
.sp .1i
.RS

.RE
.LG
.ta 1i 4i 3i
.B "1.	Getting started	1
.RS
.ta 1i 4i 3i
.NS
.br
1.1.	What is an Operating System?	1
.br
1.2.	Entering the system	2
.br
1.3.	Leaving the system	5
.br
1.4.	Editing and running commands	5
.br
1.5.	Obtaining help	7
.br
1.6.	Using files	9
.br
1.7.	Directories	11
.br
1.8.	Files and data	14
.br
1.9.	Permissions	17
.br
1.10.	Writing a C program in Plan 9	19
.br
1.11.	The Operating System and your programs	20
.br
1.12.	Where are the files?	22
.br
1.13.	The Shell, commands, binaries, and system calls	23
.br
1.14.	The Operating System and the hardware	23

.RE
.LG
.ta 1i 4i 3i
.B "2.	Programs and Processes	25
.RS
.ta 1i 4i 3i
.NS
.br
2.1.	Processes	25
.br
2.2.	Loaded programs	26
.br
2.3.	Process birth and death	30
.br
2.4.	System call errors	34
.br
2.5.	Environment	36
.br
2.6.	Process names and states	38
.br
2.7.	Debugging	40
.br
2.8.	Everything is a file!	42

.RE
.LG
.ta 1i 4i 3i
.B "3.	Files	47
.RS
.ta 1i 4i 3i
.NS
.br
3.1.	Input/Output	47
.br
3.2.	Write games	51
.br
3.3.	Read games	55
.br
3.4.	Creating and removing files	56
.br
3.5.	Directory entries	58
.br
3.6.	Listing files in the shell	62
.br
3.7.	Buffered Input/Output	65

.RE
.LG
.ta 1i 4i 3i
.B "4.	Parent and Child	71
.RS
.ta 1i 4i 3i
.NS
.br
4.1.	Running a new program	71
.br
4.2.	Process creation	72
.br
4.3.	Shared or not?	75
.br
4.4.	Race conditions	78
.br
4.5.	Executing another program	78
.br
4.6.	Using both calls	80
.br
4.7.	Waiting for children	81
.br
4.8.	Interpreted programs	84

.RE
.LG
.ta 1i 4i 3i
.B "5.	Talking Processes	87
.RS
.ta 1i 4i 3i
.NS
.br
5.1.	Input/Output redirection	87
.br
5.2.	Conventions	91
.br
5.3.	Other redirections	92
.br
5.4.	Pipes	93
.br
5.5.	Using pipes	97
.br
5.6.	Notes and process groups	101
.br
5.7.	Reading, notes, and alarms	104
.br
5.8.	The file descriptor bulletin board	106
.br
5.9.	Delivering messages	108

.RE
.LG
.ta 1i 4i 3i
.B "6.	Networking	117
.RS
.ta 1i 4i 3i
.NS
.br
6.1.	Network connections	117
.br
6.2.	Names	120
.br
6.3.	Making calls	122
.br
6.4.	Providing services	125
.br
6.5.	System services	130
.br
6.6.	Distributed computing	130

.RE
.LG
.ta 1i 4i 3i
.B "7.	Resources and Names	133
.RS
.ta 1i 4i 3i
.NS
.br
7.1.	Resource fork	133
.br
7.2.	Protecting from notes	135
.br
7.3.	Environment in shell scripts	137
.br
7.4.	Independent children	138
.br
7.5.	Name spaces	138
.br
7.6.	Local name space tricks	143
.br
7.7.	Device files	145
.br
7.8.	Unions	147
.br
7.9.	Changing the name space	148
.br
7.10.	Using names	149
.br
7.11.	Sand-boxing	151
.br
7.12.	Distributed computing revisited	152

.RE
.LG
.ta 1i 4i 3i
.B "8.	Using the Shell	157
.RS
.ta 1i 4i 3i
.NS
.br
8.1.	Programs are tools	157
.br
8.2.	Lists	157
.br
8.3.	Simple things	160
.br
8.4.	Real programs	163
.br
8.5.	Conditions	167
.br
8.6.	Editing text	170
.br
8.7.	Moving files around	174

.RE
.LG
.ta 1i 4i 3i
.B "9.	More tools	177
.RS
.ta 1i 4i 3i
.NS
.br
9.1.	Regular expressions	177
.br
9.2.	Sorting and searching	181
.br
9.3.	Searching for changes	185
.br
9.4.	AWK	188
.br
9.5.	Processing data	194
.br
9.6.	File systems	198

.RE
.LG
.ta 1i 4i 3i
.B "10.	Concurrency	203
.RS
.ta 1i 4i 3i
.NS
.br
10.1.	Synchronization	203
.br
10.2.	Locks	206
.br
10.3.	Queueing locks	212
.br
10.4.	Rendezvous	219
.br
10.5.	Sleep and wakeup	221
.br
10.6.	Shared buffers	223
.br
10.7.	Other tools	228

.RE
.LG
.ta 1i 4i 3i
.B "11.	Threads and Channels	234
.RS
.ta 1i 4i 3i
.NS
.br
11.1.	Threads	234
.br
11.2.	Thread names	237
.br
11.3.	Channels	241
.br
11.4.	I/O in threaded programs	246
.br
11.5.	Many to one communication	250
.br
11.6.	Other calls	257

.RE
.LG
.ta 1i 4i 3i
.B "12.	User Input/Output	261
.RS
.ta 1i 4i 3i
.NS
.br
12.1.	Console input	261
.br
12.2.	Characters and runes	264
.br
12.3.	Mouse input	266
.br
12.4.	Devices for graphics	269
.br
12.5.	Graphics	271
.br
12.6.	A graphic slider	273
.br
12.7.	Keyboard input	280
.br
12.8.	Drawing text	284
.br
12.9.	The window system	286

.RE
.LG
.ta 1i 4i 3i
.B "13.	Building a File Server	291
.RS
.ta 1i 4i 3i
.NS
.br
13.1.	Disk storage	291
.br
13.2.	The file system protocol	294
.br
13.3.	Semaphores for Plan 9	300
.br
13.4.	Speaking 9P	301
.br
13.5.	9P requests	304
.br
13.6.	Semaphores	307
.br
13.7.	Semaphores as files	310
.br
13.8.	A program to make things	317
.br
13.9.	Debugging and testing	322

.RE
.LG
.ta 1i 4i 3i
.B "14.	Security	325
.RS
.ta 1i 4i 3i
.NS
.br
14.1.	Secure systems	325
.br
14.2.	The local machine	325
.br
14.3.	Distributed security and authentication	327
.br
14.4.	Authentication agents	330
.br
14.5.	Secure servers	335
.br
14.6.	Identity changes	338
.br
14.7.	Accounts and keys	341
.br
14.8.	What now?	342
.br
