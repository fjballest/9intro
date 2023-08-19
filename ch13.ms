.so tmacs
.BC 13 "Building a File Server
.BS 2 "Disk storage
.LP
.ix "disk storage
.ix "file server
.ix "file~server program
The file server we are going to build will not be using a disk to provide
file storage, it will provide a rather different service. But before building
our new file server, it may be instructive to look a little bit to what would be
needed to actually store files on a disk.
.ix "disk file
.PP
There are many file servers involved in disk storage, not just one.
To store files on disk, you need a disk. Like all other devices, disks are files
in Plan 9. This may be a surprise, as disks are also used to store files.
The device
.I sd (3)
.ix "storage device
.ix disk
.ix "[#S] device driver
provides storage devices. This is a list of files served by the device driver.
.P1
; lc '#S'
sdC0	sdC1	sdD0	sdctl
.P2
.LP
Each such file (but for
.CW sdctl )
is a directory that represents a disk, or perhaps a CD or DVD reader or
writer. The file name for each device is similar to
.CW sdC0 ,
where the
.CW C0
names the particular hardware device. In this case, it is the first disk
(\f(CW0\fP) in the first controller board (\f(CWC\fP).
The tree from
.CW #S
is bound at
.CW /dev ,
so that
.CW /dev/sdC0
is the conventional name for
.CW #S/sdC0 .
.PP
Each directory for a disk contains several files.
At the terminal we are using now,
.CW sdD0
is a CD reader. These are the files used as its
interface. 
.P1
; lc /dev/sdD0
ctl	data	raw
.P2
.LP
Reading the control file reports some information about the device,
.P1
; cat /dev/sdD0/ctl
inquiry NECVMWarVMware IDE CDR101.00
config 85C4 capabilities 0F00 dma 00550004 dmactl 00550004
part data 0 54656
.P2
.LP
The line starting with
.CW inquiry
.ix [inquiry]
.ix "disk description
describes the disk.
It seems to be a CD reader (\f(CWCDR\fP) plugged to an IDE controller board. Here,
.CW NECVMWarVMware
is the vendor name for the disk, which is funny for this one.
.PP
The line starting with
.CW config
describes some capabilities for the device.
It seems that the device knows how to do DMA, to transfer bytes
.ix DMA
from the disk to the memory of the machine without direct intervention from the
processor. We know this because the number right after
.CW dmactl
.ix [dma]
.ix "setting~up DMA
is not zero. We can use the
.CW ctl
file to ask the device driver not to use DMA for this device
.P1
.ps -2
; echo dma off >/dev/sdD0/ctl
; grep dma /dev/sdD0/ctl
config 85C4 capabilities 0F00 dma 00550004 dmactl 00000000
.ps +2
.P2
.LP
And this time we see
.CW 00000000
and not
.CW 00550004
as the value for the attribute
.CW dmactl .
It does not really matter what this is, but it matters that it is zero, meaning that
there would be no further DMA for this disk. This can slow down the system, and
it is better to enable it again.
.P1
.ps -2
; echo dma on >/dev/sdD0/ctl
; grep dma /dev/sdD0/ctl
config 85C4 capabilities 0F00 dma 00550004 dmactl 00550004
.ps +2
.P2
.LP
.ix partition
Lines starting with
.CW part ,
read from the
.CW ctl
file, deserve further explanation.
.PP
The abstraction provided by the hardware for a disk is usually an array of sectors.
Each sector is typically an array of 512 bytes. The disk knows how to read from
disk into memory a given sector, and how to write it.
.PP
The last line read from the
.CW ctl
file describes a part of the disk, that goes from sector number 0 to sector number
54656.  Such part has the name
.CW data ,
and represents the actual data on the disk. Did you notice that there is a file
.CW /dev/sdD0/data ?
That is the abstraction for using this disk in Plan 9. This file
.I is
.ix disk sector
the data in the disk. Reading the first 512
bytes from this file would be reading the first sector from the disk's data.
To read or write a particular sector, any program can use
.CW seek
.ix [seek]
to set the file position at the appropriate offset, and then call
.CW read
or
.CW write .
The device driver would understand that the program wants to read or write
from the disk, and would do just that.
.PP
In case you wonder, the file
.CW raw
is used to execute commands understood by the device that have a very
low-level of abstraction, as a back-door to provide raw access to the device,
without the cooking provided by the abstraction.
.PP
Disks may contain multiple parts, named
.B partitions .
A partition is just a contiguous portion of the disk kept separate for
administrative purposes. For example, most machines with Windows come
preinstalled with two partitions in your hard disk. 
One of them corresponds to
.ix "drive unit
the
.CW C:
unit, and contains system files. The other corresponds to the
.CW D:
unit, and contains user files. Both ones are just partitions in the hard disk.
.PP
Reading the
.CW ctl
file for a disk reports all the list of partitions, with their names, start sector, and
end sector. This is the one for our hard disk. 
.P1
.ps -1
; cat /dev/sdC0/ctl
inquiry VMware Virtual IDE Hard Drive           
config 427A capabilities 2F00 dma 00550004
	dmactl 00550004 rwm 16 rwmctl 0
geometry 16777216 512 17475 15 63
part data 0 16777216
part plan9 63 16771860
part 9fat 63 204863
part fs 204863 13626132
part swap 13626132 14674708
part cache 14674708 16771860
.ps +1
.P2
.LP
Although we might have listed them, perhaps just to see the file sizes.
.P1
.ps -2
; ls -l /dev/sdC0
--rw-r----- S 0 nemo nemo  104857600 May 23 17:44 /dev/sdC0/9fat
--rw-r----- S 0 nemo nemo 1073741824 May 23 17:44 /dev/sdC0/cache
--rw-r----- S 0 nemo nemo          0 May 23 17:44 /dev/sdC0/ctl
--rw-r----- S 0 nemo nemo 8589934592 May 23 17:44 /dev/sdC0/data
--rw-r----- S 0 nemo nemo 6871689728 May 23 17:44 /dev/sdC0/fs
--rw-r----- S 0 nemo nemo 8587160064 May 23 17:44 /dev/sdC0/plan9
-lrw------- S 0 nemo nemo          0 May 23 17:44 /dev/sdC0/raw
--rw-r----- S 0 nemo nemo  536870912 May 23 17:44 /dev/sdC0/swap
.ps +2
.P2
.LP
For each file representing a partition, the file size reports the partition size
(in bytes), as could be expected.
This disk has just 8 Gbytes of data (8589934592 bytes). That would be the
.CW data
file. Some partitions have been made for this disk, to name different
parts of it and use them separatedly. For example, there is a
.CW 9fat
.ix "[9fat] partition
partition going from sector 63 (included) to sector 204863 (not included). And then a
.CW fs
.ix "[fs] partition
partition, going from sector 204863 to sector 13626132. And several other ones.
.PP
For us,
.CW /dev/sdC0/9fat
is just a like a little disk (that is what a partition is for), only that it lives inside
.CW /dev/sdC0/data .
Also,
.CW /dev/sdC0/fs
is another little disk, also living inside
.CW /dev/sdC0/data .
Indeed, both
.CW 9fat
and
.CW fs
live inside a partition named
.CW plan9 ,
.ix "[plan9] partition
as you may see by looking where these partitions start and end.
.PP
The convention in Plan 9 is to make a partition, named
.CW plan9 ,
in the disk. This partition is known to other operating systems, because it is
declared using a partition table (kept in the disk) following a particular
convention that most systems follow. Within this partition, Plan 9 maintains
its own partitions, by declaring them in another table known to the storage
device driver (kept in disk, of course). This is done so because many disks
are only able to support 4 (so called) primary partitions.
.PP
How can we create a partition? By filling an entry in the partition name to
declare it, including the information about where does it start and where does
it end. The command
.CW fdisk
can be used to modify the partition table for the whole disk. The command
.CW prep
can be used to modify the one used by Plan 9 (kept within the the Plan 9 partition
in the disk).
.PP
In any case, we can add a partition to our disk
by writing a control command to the disk's
.CW ctl
file. For example, this creates a partition named
.CW check
on the
.CW sdC1
disk.
.ix "adding partitions
.ix "deleting partitions
.P1
; echo part check 63 2001 >/dev/sdC1/ctl
; grep check /dev/sdC1/ctl
part check 63 2001
.P2
.LP
To remove it, we may write a
.CW delpart
command to the disk's control file.
.P1
; echo delpart check >/dev/sdC1/ctl
.P2
.LP
In general, it is wiser to use the programs
.CW fdisk
.ix [fdisk]
and
.CW prep
.ix [prep]
to create partitions, because they update the tables besides informing the storage
device about the new partitions. We are going to create some partition for a new
disk. As you may see, we tell
.CW fdisk
that the disk to use is
.CW /dev/sdC1/data .
That is just a file. For
.CW fdisk ,
that would be the disk.
.P1
.ps -1
; disk/fdisk /dev/sdC1/data
cylinder = 8225280 bytes
   empty    0 522    (522 cylinders, 3.99 GB) 
>>>
.ps +1
.P2
.LP
After running
.CW fdisk ,
it prints the list of partitions found. None so far. The
.CW >>>
is the prompt from
.CW fdisk ,
where we can type commands to handle the disk. The command
.CW a ,
adds a new partition.
.P1
>>> !!a p1
start cylinder: !!0
end [0..522] !!522
.P2
.LP
We added a partition called
.CW p1
occupying the entire disk. Following the convention used for IDE disks on PCs,
the table may name up to 4 primary partitions. The name
.CW p1
identifies this partition as the primary partition number 1.
.PP
Now, we can print the new table, write
it to disk after being sure, and quit from this program.
.P1
>>> !!p
 '  p1    0 522 (522 cylinders, 3.99 GB) PLAN9
>>> !!w
>>> !!q
.P2
.LP
And this is what we can see now.
.P1
.ps -2
; cat /dev/sdC1/ctl
inquiry VMware Virtual IDE Hard Drive           
config 427A capabilities 2F00 dma 00550004 dmactl 00550004 rwm 16 rwmctl 0
geometry 8388608 512 8322 16 63
part data 0 8388608
part plan9 63 8385930
; lc /dev/sdC1
ctl	data	plan9	raw
.ps +2
.P2
.LP
There is a new partition, a new file at
.CW /dev/sdC1 .
Its name is
.CW plan9
because
.CW fdisk
declared the partition to be one for use with Plan 9 (writing a particular integer
value in the partition entry that identifies the type for the partition).
.PP
Within this partition (known to any other system sharing the same machine), we
can create several Plan 9 partitions using
.CW prep .
.P1
.ps -1
; disk/prep -a 9fat -a fs /dev/sdC1/plan9
no plan9 partition table found
9fat 204800
fs 8181067
 ' 9fat      0 204800     (204800 sectors, 100.00 MB)
 ' fs   204800 8385867    (8181067 sectors, 3.90 GB)
>>>
.ps +1
.P2
.LP
Note how
.CW prep
uses
.CW /dev/sdC1/plan9
as its disk! It is just a file. We asked
.ix "automatic partitioning
.ix "disk partitioning
.CW prep
to automatically choose appropriate sizes and locations for partitions
named
.CW 9fat
and
.CW fs
within
.CW /dev/sdC1/plan9 .
It printed the proposed table before prompting for more commands.
And finally, we can write this partition table to disk and quit.
.P1
>>> !!w
>>> !!q
.P2
.LP
That before seeing the effect.
.P1
; lc /dev/sdC1
9fat	ctl	data	fs	plan9	raw
.P2
.LP
At this point we have two partitions named
.CW fs
and
.CW 9fat
.ix "stand-alone installation
.ix "local disk
that can be used for example to install a stand-alone Plan 9 on them
(one that may run without using an external file server). Both programs,
.CW fdisk
and
.CW prep
used the file given as an argument to access the disk. That file was the disk.
They informed the storage device about the new partitions by writing control
commands to the disk
.CW ctl
file. At last, we can use the files supplied at
.CW #S
to use our new partitions.
.PP
But how can we create files in our partition? We need a program that
knows how to store files on disk, using a particular data structure to keep
them stored, access them, and update them. This is what a file server is.
But this time, files served by this program would be actual files in a disk.
.PP
There are several programs that can be used for this task.
The standard file server for Plan 9 is
.CW fossil .
.ix [fossil]
This program is used by the (central) file server machine to serve files to
terminals. Another, more ancient program is
.CW kfs .
.ix [kfs]
We are going to use this one.
.P1
; disk/kfs -f /dev/sdC1/fs
File system main inconsistent
Would you like to ream it (y/n)?
.P2
.LP
This command started
.CW kfs
(a file server program) using
.CW /dev/sdC1/fs
as the disk (partition) where to keep files. For
.CW kfs ,
it does not matter what
.CW fs
is. It is just a file.
Upon starting,
.CW kfs
noticed that there was none of its data structures stored in
.CW fs .
It understood that there was an inconsistent (corrupt) data structure
stored in the disk, and asks us to reinitialize it. We will let it do it.
.P1
Would you like to ream it (y/n)? !!y
kfs: reaming the file system using 1024 byte blocks
.P2
.LP
.ix "disk initialization
Now
.CW kfs
is initializing the data in
.CW fs ,
as it pleases to store a file tree in there. After finishing with disk
initialization, the partition contains the kfs data structures. It is said
that the partition has been
.B formatted
for
.CW kfs ,
or that it has a
.I kfs
format.
.PP
At last, we can mount the (empty) file tree served by
.CW kfs .
When we create files in the new mounted directory,
.CW kfs
will use
.CW write
on
.CW /dev/sdC1/fs
to keep them stored in that partition. Indeed, it will be the storage
device the one that will update the disk, upon calls to
.CW write
for one of its files.
.P1
; mount -c /srv/kfs /n/kfs
; touch /n/kfs/anewfile
;
.P2
.LP
All other file systems (stored in disk) work along the same lines. All other
systems include programs that understand how to use the disk (like the
storage device) and how to store files in it (like
.CW kfs ).
As you see, each program is just using an abstraction provided by yet
another program. Even inside the disk hardware you may find programs
that provide the abstraction of a contiguous array of disk sectors.
.BS 2 "The file system protocol
.LP
.ix 9P
.ix "file~system protocol
So far, we have seen two interfaces for using Plan 9, system calls and
the shell. There is another interface: the 9P  file system protocol. Plan 9
provides all the abstractions needed to use the machine, including processes,
virtual address spaces, devices, etc. However, many abstractions are
provided by external file servers, and not by the system itself.
.PP
The protocol spoken between Plan 9 and any external file server is called 9P,
and is documented in the section 5 of the manual. For example,
.I intro (5)
summarizes the protocol and provides a good introduction to it.
.PP
A word of caution. If you ever have
to implement a file server, you should read the whole section 5 of the manual
before doing so. It describes all the messages in the protocol, what they do,
and how a file server should behave. Here we are interested just in describing
how the protocol works, and how it relates to the system calls made to
Plan 9. The description here is far from being complete, but you have the manual.
.PP
As a user, you might probably ignore which particular protocol is spoken by
your system. Windows speaks CIFS, Linux speaks NFS, and Plan 9 speaks 9P.
In general, you do not have to care. However, this is a good time to take a look
into 9P for two different reasons. First, it might give you more insight regarding
how the system works and how to use it more effectively. Second, looking into
9P is an
excellent excuse to learn how to develop a file server program, using what we
learned so far.
.PP
Looking back at figure [[!remote procedure call!]] will let you see the elements involved.
Processes using Plan 9 make system calls, including
.CW open ,
.CW close ,
.CW read ,
and
.CW write .
Plan 9 implements such system calls by speaking 9P with the file server involved.
In the figure, steps 3 and 4 correspond to 9P messages exchanged to implement
.CW write .
The last element involved is the file server process, which handles the messages
sent by Plan 9 to do the file operations requested by Plan 9.
.PP
All the 9P dialog between Plan 9 and a file server is based on remote procedure
calls. Plan 9 sends a request to the server and receives a reply from it. The file
server is called a
.B server
.ix "9P server
.ix "9P request
because it accepts requests (represented by messages), and it handles each
request before
sending a reply back (also represented by a message). In the same way, the
program making requests (Plan 9 in this case) is called a
.B client
because of a similar reason.
Each request and reply is just a particular data structure,
sent as an array of bytes
through a network connection, a pipe, or any other communication means.
.PP
Before discussing 9P any further, let's take a look at an example. The command
.CW ramfs ,
.ix [ramfs]
as many other file servers, prints the 9P dialog when called with the flag
.CW -D .
Any 9P message received by
.CW ramfs ,
carrying a request, is printed and then processed. Any 9P message sent back
as a reply from
.CW ramfs
is printed as well. Of course,
.CW ramfs
does not print in the console the actual messages as exchanged through the
network. Instead, it prints the relevant data carried by each message in a format
that could be understood by a human.
.ix "[9P] messages
.P1
; ramfs -D -s ram
postfd /srv/ram
postfd successful
;
.P2
.LP
Using
.CW -s
we asked
.CW ramfs
to post at
.CW /srv/ram
the end of a pipe that we can mount to access the files it provides. This is what
happens when we mount its file tree.
.P1
; !!mount -c /srv/ram /n/ram
<-12- Tversion tag 65535 msize 8216 version '9P2000'
-12-> Rversion tag 65535 msize 8216 version '9P2000'
<-12- Tauth tag 16 afid 435 uname nemo aname 
-12-> Rerror tag 16 ename auth no required
<-12- Tattach tag 16 fid 435 afid -1 uname nemo aname 
-12-> Rattach tag 16 qid (0000000000000000 0 d)
;
.P2
.LP
The
.CW mount
command makes a
.CW mount
system call.
To perform the
.CW mount
system call, Plan 9 sent three different requests to this
.CW ramfs
file server. The file server printed the messages (and handled the requests
and sent the replies) before Plan 9 could complete the
.CW mount
call.
.PP
.CW Ramfs
prints a line for each 9P message exchanged.  The first
field of each line shows if it is a message received from Plan 9 (the arrow points to
the left) or sent by the server (the arrow points to the right). The former ones
are requests, and the latter ones are replies. The file descriptor
used to receive (or send) the message is the number printed in the middle of each
arrow. In this case,
.CW ramfs
is attending an end of a pipe, open in file descriptor 12. The other
end of the pipe was posted at
.ix "file~descriptor post
.ix [/srv/ram]
.CW /srv/ram ,
which is the file we used in
.CW mount .
.PP
The second field printed for each 9P message shows the
.B "message type" .
A message is just a data structure. Different messages for different requests
and replies mean different things, and have different data fields. The type of
a message is identified by a number. However,
.CW ramfs
printed a string with the name of the type, instead of the number.
In our case, three different requests were sent by Plan 9,
.CW Tversion ,
.CW Tauth ,
and
.CW Tattach .
The file server replied with three different replies,
.CW Rversion ,
.CW Rerror ,
and
.CW Rattach .
.ix [Tversion]
.ix [Tattach]
.ix attach
.ix [Rversion]
.ix [Rattach]
All 9P requests have names that start with
.CW T ,
for transaction. The replies for each request have the name of the request, but
starting with
.CW R
instead. Thus,
.CW Tversion
is a
.I version
request, and
.CW Rversion
is a
.I version
reply.
.PP
Following the message type, the names and contents of most important fields
for each message are printed as well. For example, the
.CW tag
field of the
.CW Tversion
message had
.CW 65535
as its value.
As you can see, all the messages have a
.CW tag
field, besides a type field. The protocol dictates that each reply must carry
the same number in the
.CW tag
that was used by its corresponding request. This is useful to have multiple
outstanding (not yet replied) requests through the same connection.
.B Tags
.ix "message tag
let
the client know which reply corresponds to each request. Because of this,
a tag used in a request cannot be used again until its reply has been received.
.PP
Before anything else, Plan 9 sent a
.CW Tversion
message to
.CW ramfs ,
which replied by sending an
.CW Rversion
message back. This message is used to agree on a particular version of the
protocol to speak. The request carries the version proposed by Plan 9. The
reply carries the version proposed by the server. The string
.CW 9P2000 ,
.ix [9P2000]
sent by Plan 9 (and acknowledged by
.CW ramfs )
identifies the version in this case. For the rest of the conversation, both programs
agreed to use messages as defined in the 9P2000 version of the 9P protocol.
.PP
Furthermore, this message is also used to agree on a maximum message size
for the 9P conversation that follows. In our case,
they agreed on using 8 Kbytes as the maximum size for a message (the value of
the
.CW msize
.ix "message size
fields in
.CW Tversion
and
.CW Rversion ).
This is useful to let both
parties know how big their buffers should be for holding data being exchanged.
.PP
The second request sent by Plan 9 was
.CW Tauth .
This has to do with security, which is discussed later. The purpose of the message
is to convince the file server that the user mounting the file tree is who he says he is.
In this case,
.CW ramfs
is credulous and does not need any proof to let Plan 9 use it, so it replies with an
diagnostic message that states that there is no need for authentication. This is the
.CW Rerror
.ix [Rerror]
message that you see.  When a request cannot be processed or causes some error,
the file server does not send its corresponding reply message back. Instead, it sends an
.CW Rerror
message to the client that both indicates the failure and explains its cause. The
explanation is just an string, sent in the
.CW ename
field.
The error was
.CW "auth not required"
in this case.
.PP
The first two requests were just establishing a 9P conversation between both
parties. The third one,
.CW Tattach ,
was the one used by Plan 9 to mount the file tree:
.P1
<-12- Tattach tag 16 fid 435 afid -1 uname nemo aname 
-12-> Rattach tag 16 qid (0000000000000000 0 d)
.P2
.LP
The attach request lets Plan 9 obtain a reference to the root of the file tree
from the server. The field
.CW uname
tells the file server which user is attaching to the tree. The field
.CW aname
tells to which file tree in the server we are attaching. It corresponds to the last
(optional) argument for
.CW mount .
In this case, the empty string is the conventional name for the main file server's tree.
.PP
How can Plan 9 obtain a reference to a file in the server?
References are
pointers, which point into memory, and cannot cross the network!
Numbers, called
.ix "file identifier
.ix "9P file
.B fids
(or file identifiers) are used to do that. The point is that
both Plan 9 and the file server may agree that
a particular fid number identifies a particular file in the server.
.PP
As figure [[!attach fid!]] and the attach messages above show, Plan 9 sent
a fid number in
.CW Tattach .
It was 435. Which number it was, it does not matter. It is just a number proposed
as a fid (i.e., a file identifier, or a file reference) by Plan 9 to the file server.
After the server accepts the attach request, and replies with
.CW Rattach ,
both Plan 9 and the server agree that the fid proposed will now be a reference to
the root of the file tree mounted. So, from now on, the fid 435 can be used in
other 9P requests to mean
.CW /
within the file server.
.ix "file~server root~directory
.LS
.PS 4.3i
.ps -1
circlerad=.2
arrowhead=.7
right
K: box "Chan for" "\f(CW/n/ram\fP"
arrow right .5
C: box wid 1 "Chan for" "fid 435"
move 1.5
T: [
	down
	S: circle invis "\fB/\fP"
	move .2
	L: [ right
		A: circle invis  "x"
		move .1
		X: circle invis "y"
		move .1
		Y: circle invis "z"
	]
	line from S to L.A chop
	line from S to L.X chop
	line from S to L.Y chop
]
up
circle rad .9 at T
box invis ht .1 "\fBRamfs\fP"
arrow  dotted from C.e right to T.S.w "fid 435"
down
box wid 2.5 ht 1.3 with .nw at K.nw - .1,-.3
box invis "\fBPlan 9\fP"
box invis ht .12 "Mount table entry" ljust with .sw at K.nw
.ps +1
.PE
.LE F After an attach Plan 9 has a fid number that refers to the file server's \f(CW/\fP file.
.PP
The figure depicts the scenario after completing the
.CW mount
.ix "file~server mount
system call that issued the attach request. There is a new entry in the name space
where we mounted the file server. The new entry in the mount table says that whenever
we reach the file
.CW /n/ram ,
while resolving a file name, we should continue at the root for the file server instead.
As we saw earlier, a Chan
.ix [Chan]
is the data structure used in Plan 9 to refer to a file in a particular server. The Chan
identifies the file server that contains the file, and also includes a fid number. The
fid is used when speaking 9P with the file server containing the file, to identify the file.
.PP
Fids let the 9P client refer to a file in a request made to the server. But another kind
of file identifier is needed. Consider the mount table entry shown in the figure.
It says, “when you get to a file that is
.CW /n/ram ,
you must continue at [ ... ]”.
How can Plan 9 know that it has reached the file
.CW /n/ram ?
To know if that happens, Plan 9 must check if the Chan (i.e., the file) it is working with
refers to the file
.CW /n/ram .
Plan 9 needs to be able to compare two Chans for equality, that is, to determine if
they refer to the same file.
.PP
To help with this, 
other type of
file identifiers, called
.ix "file Qid
.B qids ,
.ix "unique identifier
unequivocally identify files within a file server.
All 9P file servers promise that each file will be assigned an
unique number, called its qid. Furthermore, a qid used for a file will not be used
for any other file even after the file is removed. So, two files with the same qid
within the same file server are the same file. Otherwise, files are different.
.PP
Each
Chan contains the qid for the file it refers to. In our 9P dialog, the
.CW Rattach
message sent a
.CW qid
back to the client, and Plan 9 knows which qid corresponds to the
.CW /
of our
.CW ramfs
file tree.
If you look back to see the
.CW Dir
.ix [Dir]
data structure returned by
.CW dirstat ,
.ix [dirstat]
.ix "directory entry
with attributes for a file,
you will see that one of the fields is a
.CW Qid .
.PP
We said that a qid is a number. But a qid is indeed a tiny
structure that contains three numbers.
.P1
typedef
struct Qid
{
	uvlong	path;
	ulong	vers;
	uchar	type;
} Qid;
.P2
.LP
The
.CW path
field is the actual value for the qid, the unique number for the file within its
file server. Beware, this is not a string with a file name, but it identifies a file
in the file server and that is the reason for calling it
.CW path .
The
.CW vers
field is a number that represents the version for the file. It is incremented by
the file server whenever the file is updated. This is useful to let Plan 9 know if
a cached file is up to date or not. It is also useful to let applications know if
a file has changed or not. The field
.CW type
contains bits that are set to indicate the type for a file, including these ones:
.P1
.ps -2
#define QTDIR    0x80	/* type bit for directories */
#define QTAPPEND 0x40	/* type bit for append only files */
#define QTEXCL   0x20	/* type bit for exclusive use files */
.ps +2
.P2
.ix [QTDIR]
.ix [QTAPPEND]
.ix [QTEXCL]
.ix "Qid [type]
.ix "Qid [path]
.ix "Qid "vers"
.ix "file version
.LP
For example, the
.CW QTDIR
bit is set in
.CW Qid.type
for directories, unset for other files. The
.CW QTAPPEND
bit is set for append-only files. The
.CW QTEXCL
bit is set for files with the exclusive use permission set (files that can be open
by at most one process at the same time).
Looking back to the
.CW Rattach
message sent by
.CW ramfs ,
its root directory has a qid whose
.CW path
was
.CW 0000000000000000 ,
i.e.,
.CW 0 .
Its version was
.CW 0 ,
and it had the
.CW QTDIR
bit set (printed as a
.CW d ).
.PP
In the figure [[!attach fid!]] we assumed that the file tree served by
.CW ramfs
had three files in its root directory. Before continuing, we are going to create
three such empty files using this command:
.P1
; touch /n/ram/^(x y z)
.I "...9P dialog omitted...
;
.P2
.LP
What would now happen if we write the string
.CW hello
to
.CW /n/ram/x ?
We can use
.CW echo
to do it. The shell will open
.CW /n/ram/x
for writing, and
.CW echo
will write its argument to the file. This is the 9P conversation spoken
between Plan 9 and
.CW ramfs
as a result.
.P1
; echo -n hola >/n/ram/x
<-12- Twalk tag 14 fid 435 newfid 476 nwname 1 0:x 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000000 1 ) 
<-12- Topen tag 14 fid 476 mode 17
-12-> Ropen tag 14 qid (0000000000000000 1 ) iounit 0 
<-12- Twrite tag 14 fid 476 offset 0 count 4 'hola'
-12-> Rwrite tag 14 count 4
<-12- Tclunk tag 14 fid 476
-12-> Rclunk tag 14
.P2
.LP
.ix [Twalk]
.ix [Rwalk]
.ix walk
.ix [Topen]
.ix [Ropen]
.ix [Twrite]
.ix [Rwrite]
.ix [Tclunk]
.ix [Rclunk]
First, Plan 9 took the name
.CW /n/ram/x
and tried to open it for writing. It walked the file tree using the name space,
as we learned before. After reaching
.CW /n/ram ,
it knows it has to continue the walk at the root for our file server. So, Plan 9
must walk to the file
.CW /x
of the file server. That is what
.CW Twalk
is for.
.PP
The first 9P request,
.CW Twalk ,
is used to walk the file tree in
.CW ramfs .
It starts walking from the file with fid 435. That is the root of the tree. The walk
message contains a single step, walking to
.CW x ,
relative to wherever fid 435 points to. The field
.CW nwname
.ix [nwname]
.ix [wname]
contains how many steps, or names,
to walk. Just one in this case. The field
.CW wname
in the message is an array with that number of names. This array was printed
in the right part of the line for the message. It had a single component,
.CW wname[0] ,
containing the name
.CW x .
If the file exists, and there is no problem in walking to it,
both Plan 9 and the file server agree that the fid number in
.CW newfid
.ix "new fid
(476 in this case) refers to the resulting file after the walk. The reply message,
.CW Rwalk ,
mentions the qids for the files visited during the walk. After this message, things
stand as shown in figure [[!fids after walking!]].
.LS
.PS 4.3i
.ps -1
circlerad=.2
arrowhead=.7
right
C: box wid 2.5 ht 1.3 with .nw at K.nw - .1,-.3 "Plan 9"
move 1.5
T: [
	down
	S: circle invis "\fB/\fP"
	move .2
	L: [ right
		A: circle invis  "x"
		move .1
		X: circle invis "y"
		move .1
		Y: circle invis "z"
	]
	X: L.A
	line from S to L.A chop
	line from S to L.X chop
	line from S to L.Y chop
]
up
circle rad .9 at T
box invis ht .1 "\fBRamfs\fP"
X: circle invis at C
arrow  dotted from X to T.S "fid 435" chop
arrow  dotted from X  to T.X "fid 476" chop
.ps +1
.PE
.LE F Fids after walking to the file \f(CWx\fP in the file server.
.PP
After the walk, Plan 9 sent a
.CW Topen
request to open the file. Actually, to prepare the fid for doing further
reads and writes on it. The message mentions which fid to open,
476
in this case, or
.CW /x
within the file server. It also mentions which mode to use. The mode corresponds
to the flags given to
.I open (2),
or to
.I create (2).
.ix [create]
The reply informs about the qid for the file just open.
Both requests,
.CW Twalk
and
.CW Topen
are the result of the system call made from the shell to create the file.
.PP
Now its time for
.CW echo
to write to the file. To implement the
.CW write
system call, Plan 9 sent a
.CW Twrite
9P request. It mentions to which fid to write (which must be open), at which
offset to write, how many bytes, and the bytes to write.
The reply,
.CW Rwrite ,
indicates how many bytes were written.
.PP
The last request,
.CW Tclunk ,
releases a fid. It was sent when the file was closed, after
.CW echo
exited and its standard output was closed.
.PP
The dialog for reading a file would be similar. Of course, the open mode
would differ, and
.CW Tread
will be used instead of
.CW Twrite .
Look this for example.
.P1
; cat /n/ram/x
<-12- Twalk tag 14 fid 435 newfid 486 nwname 1 0:x 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000000 2 ) 
<-12- Topen tag 14 fid 486 mode 0
-12-> Ropen tag 14 qid (0000000000000000 2 ) iounit 0 
<-12- Tread tag 14 fid 486 offset 0 count 8192
-12-> Rread tag 14 count 4 'hola'
hola<-12- Tread tag 14 fid 486 offset 4 count 8192
-12-> Rread tag 14 count 0 ''
<-12- Tclunk tag 14 fid 486
-12-> Rclunk tag 14
.P2
.LP
The program
.CW cat
opens
.CW /n/ram/x .
It all works like before. 
The
.CW Twalk
request manages to get a new fid, 486, referring to file
.CW /x
within the file server. However, the following
.CW Topen
opens the file just for reading (mode is zero).
Now,
.CW cat
calls
.CW read ,
to read a chunk of bytes from the file. It asked for reading 8192 bytes.
The reply,
.CW Rread ,
sent only 4 bytes as a result. At this point, the system call
.CW read
terminated and
.CW cat
printed what it could read, the file contents. The program had to call
.CW read
again, and this time there was nothing else to read (the number of bytes
in
.CW Rread
is zero). So,
.CW cat
closed the file.
.PP
A file can be created by sending a
.CW Tcreate
request to a file server. This is the 9P dialog for creating the directory
.CW /n/ram/a .
.P1
; mkdir /n/ram/a
<-12- Twalk tag 14 fid 435 newfid 458 nwname 1 0:a 
-12-> Rerror tag 14 ename file not found
<-12- Twalk tag 14 fid 435 newfid 474 nwname 1 0:a 
-12-> Rerror tag 14 ename file not found
<-12- Twalk tag 14 fid 435 newfid 474 nwname 0 
-12-> Rwalk tag 14 nwqid 0 
<-12- Tcreate tag 14 fid 474 name a perm d-rwxr-xr-x
-12-> Rcreate tag 14 qid (0000000000000003 0 d) iounit 0 
<-12- Tclunk tag 14 fid 474
-12-> Rclunk tag 14
.P2
.LP
Plan 9 tried to access
.CW /n/ram/a
several times, to see if it existed. It could be
.CW mkdir ,
calling
.CW access ,
or Plan 9 itself. It does not really matter. What matters is that the file
server replied with
.CW Rerror ,
stating that there was an error:
.CW "file not found" .
Then, a last
.CW Twalk
was issued to obtain a new fid referring to the directory where the file is being
created. In this case, the fid 474 was obtained to refer to the root directory
in the file server. At last
.CW Tcreate
asks to create a file with the name indicated in the
.CW name
field, i.e.,
.CW a .
After the call, the fid in the message refers to the newly created file, and
it is open. Because we are creating a directory, the bit
.CW DMDIR
.ix [DMDIR]
.ix "directory creation
would be set in the
.CW perm
field, along with other file permissions. This is similar to what we did when
using
.I create (2).
.PP
There are several other messages.
Removing a file issues a
.CW Tremove
message.
The
.CW Tremove
request is similar to
.CW Tclunk .
However, it also removes the file identified by the fid.
.CW Tstat
obtains the attributes for a file.
.CW Twstat
updates them.
.ix [Tstat]
.ix [Twstat]
.P1
; rm /n/ram/y
<-12- Twalk tag 14 fid 435 newfid 491 nwname 1 0:y 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000001 0 ) 
<-12- Tremove tag 14 fid 491
-12-> Rremove tag 14
.P2
.P1
; ls -l /n/ram/z
<-12- Twalk tag 14 fid 435 newfid 458 nwname 1 0:z 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000002 0 ) 
<-12- Tstat tag 14 fid 458
-12-> Rstat tag 14  stat 'z' 'nemo' 'nemo' 'nemo'
	q (0000000000000002 0 ) m 0644
	at 1156033726 mt 1156033726 l 0 t 0 d 0
<-12- Tclunk tag 14 fid 458
-12-> Rclunk tag 14
--rw-r--r-- M 125 nemo nemo 0 Aug 20 01:28 /n/ram/z
.P2
.P1
; chmod -w /n/ram/z
<-12- Twalk tag 14 fid 435 newfid 458 nwname 1 0:z 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000002 0 ) 
<-12- Tstat tag 14 fid 458
-12-> Rstat tag 14  stat 'z' 'nemo' 'nemo' 'nemo'
	q (0000000000000002 0 ) m 0644
	at 1156033726 mt 1156033726 l 0 t 0 d 0
<-12- Tclunk tag 14 fid 458
-12-> Rclunk tag 14
<-12- Twalk tag 14 fid 435 newfid 458 nwname 1 0:z 
-12-> Rwalk tag 14 nwqid 1 0:(0000000000000002 0 ) 
<-12- Twstat tag 14 fid 458 stat '' '' '' ''
	q (ffffffffffffffff 4294967295 dalA) m 0444
	at -1 mt -1 l -1 t 65535 d -1
-12-> Rwstat tag 14
<-12- Tclunk tag 14 fid 458
-12-> Rclunk tag 14
.P2
.LP
At this point, we know enough of 9P and what a file server does to start building
a new file server.
.BS 2 "Semaphores for Plan 9
.LP
.ix "semaphore
.ix "semaphore file~system
For most tasks, it would be probably better to use channels, from the thread library, instead
of using semaphores. Semaphores are a synchronization abstraction prone to
errors. But assuming that we need semaphores due to some reason, it may be
useful to write a file server to provide them.
Before, we used pipes to implement semaphores. This is reasonable and
works well within a single machine. But what if you want to use semaphores
to synchronize processes that run at different machines? Also, using a byte of
buffering in the pipe for each ticket in the semaphore looks like wasting resources.
.PP
We are going to implement a program,
.CW semfs ,
.ix [semfs]
that provides semaphores as if they were files. It will export a single (flat)
directory. Each file in the directory represents a semaphore. And we have to
think of an interface for using a semaphore by means of file operations. It
could be as follows.
.IP •
Creating a file in our file server creates a semaphore, with no tickets inside. That is,
its initial value is zero.
.IP •
To put tickets in a semaphore, a process may write into its file a string
stating how many tickets to add to the semaphore. We prefer to write the
string
.CW 3
instead of the binary number
.CW 3
because strings are portable (all machines store them in the same way).
.IP •
To get a ticket from a semaphore, a process may read from its file. Each read
would have to await until there is a ticket to get, and it will return some uninteresting
data once a ticket is available.
.LP
Before implementing anything, we want to be sure that the interface could be
used. We can use some
.I "wishful thinking"
.ix "wishful thinking
and assume that it has been already implemented.
And now we can try to use it, just to see if we can. For example, we can start
by providing a C interface for using the semaphores. The function
.CW newsem
can create a semaphore and give it an initial number of tickets.
.P1
int
newsem(char* sem, int val)
{
	int	fd;

	fd = create(sem, OWRITE, 0664);
	if (fd < 0)
		return -1;
	print(fd, "%d", val);
	close(fd);
	return 0;
}
.P2
.LP
Removing a semaphore is easy, we can use
.CW remove .
To do
.CW ups
and
.CW downs
we can use the following functions.
.P1
int
up(char* sem)
{
	int	fd;

	fd = open(sem, OWRITE);
	if (fd < 0)
		return -1;
	write(fd, "1", 1);
	close(fd);
	return 0;
}
.P2
.P1
int
down(char* sem)
{
	char	buf[1];
	int	fd;

	fd = open(sem, OREAD);
	if (fd < 0)
		return -1;
	read(fd, buf, 1);
	return 0;
}
.P2
.LP
The interface seems to be convenient, because we can even use the shell
to initialize and list our semaphores. An invented session could be as follows,
provided that
.CW semfs
has been mounted at
.CW /mnt/sem .
.ix [/mnt/sem]
.P1
; echo 1 >/mnt/sem/mutex	\fRcreate a sem for mutual exclusion\fP
; touch /mnt/sem/items		\fRcreate a sem with 0 tickets\fP
; ls /mnt/sem			\fRlist semaphores\fP
mutex     items
;
.P2
.BS 2 "Speaking 9P
.LP
It is quite easy to build a file server that speaks 9P using the
.I 9p (2)
library, known also as
.CW lib9p .
.ix [lib9p]
.ix "9P library
It provides most of the machinery needed to maintain the data structures
necessary for a file server, and many of the common functions found in most
file servers.
.PP
The main data structure provided by
.CW lib9p
is
.CW Srv .
.ix [Srv]
The task of a 9P file server is to serve 9P requests. For each 9P message
received, it must execute a function to perform the actions requested by the
message, and reply with an appropriate message to the client. This is what
.CW Srv
represents, the implementation of a file server.
.CW Srv
is a structure that contains pointers to functions to implement each 9P
message. This is an excerpt of its declaration.
.P1
typedef struct Srv Srv;
struct Srv {
	void		(*attach)(Req*);
	void		(*auth)(Req*);
	void		(*open)(Req*);
	void		(*create)(Req*);
	void		(*read)(Req*);
	void		(*write)(Req*);
	void		(*remove)(Req*);
	void		(*stat)(Req*);
	void		(*wstat)(Req*);
	void		(*walk)(Req*);
	void		(*flush)(Req*);
	char*		(*clone)(Fid*, Fid*);
	char*		(*walk1)(Fid*, char*, Qid*);
	int		infd;	// T-messages fd
	int		outfd;	// R-messages fd
	void*		aux;	// for you to use
	\fI...\fP
};
.P2
.LP
A file server program initializes a
.CW Srv
structure with pointers to appropriate implementations. Then, it calls a
function from
.CW lib9p
that takes care of almost everything else. For example,
.CW postmountsrv
takes a server implementation (i.e., a
.CW Srv
structure), a name for a file to be posted at
.CW /srv ,
and a path for a mount point (as well as flags for mount).
.P1
.ps -1
; sig postmountsrv
   void postmountsrv(Srv *s, char *name, char *mtpt, int flag)
.ps +1
.P2
.ix [postmountsrv]
.LP
This function creates a separate process to run the server, as implemented by
.CW Srv .
It creates a pipe and puts the server process in a loop, reading 9P
requests from one end of the pipe and calling the corresponding function in
.CW Srv
for each request. See figure [[!9P server process!]]. The other end of the pipe is posted at
.CW /srv ,
using the
.CW name
given as an argument. At this point, the file in
.CW /srv
can be mounted to reach the file server. Furthermore,
.CW postmountsrv
mounts the file server at the directory given in
.CW mtpt ,
using
.CW flag
as flags for
.CW mount .
So,
.CW postmountsrv
provides all the main-loop logic for a file server, and makes it available to
other processes. It is optional to give
.CW name ,
and
.CW mtpt .
Passing nil as either value makes
.CW postmountsrv
not to post or not to mount the file server respectively.
.LS
.PS 4.2i
.ps -2
boxht=.2
circlerad=.4
circle invis "client" "(Plan 9)"
arrow <-> "9P" above
P: box "pipe"
arrow right 1 "\f(CWTread\fP" above
C:[
	box ht .4  "server" "loop"
	arrow 1 "call to" "\f(CWsrv.read\fP"
	S: [	down
		box invis "\fBSrv\fP"
		box "attach"
		box "auth"
		R: box "read"
		box "write"
		box "..."
		box "walk"
	]
	arrow from S.R.w + .1,0 down .55 left 
	B: box ht .4 "read" "function"
]
down
circle rad 1.4 at C
box invis "(child) server process"
arrow from C.B.w to P.e - 0,.05 "\f(CWRread\fP" below rjust
.ps +2
.PE
.LE F A 9P server process created by a call to \f(CWpostmountsrv\fP.
.PP
.ix "server process
One thing to note is that the process created by
.CW postmountsrv
will not share its name space with the parent process (the one calling
.CW postmountsrv ).
It could not be otherwise. If it was, a process would have to reply to 9P
requests for the file tree it is using. This would lead to deadlocks. For
example, opening
a file would make the process wait for Plan 9 to speak 9P with the server,
that would wait until the server handles 9P requests, and the server would
be waiting for the open to complete. The flag
.CW RFNAMEG ,
.CW RFFDG ,
and
.CW RFMEM
are given to
.CW rfork
by
.CW postmountsrv .
.ix "shared memory
This means that the child process shares memory with the parent process, but does
.I not
share the name space nor the file descriptors with the parent.
.PP
Things work as shown in figure [[!9P server process!]]. The child process created
by
.CW postmountsrv
executes the main server loop. This loop, implemented by the
.CW srv
function from
.CW lib9p ,
keeps on reading 9P messages from the pipe. When it reads a
.CW Tread
message, it calls the function
.CW Srv.read
to process the request. The function is expected to perform the read and then
reply to the client, by sending perhaps an
.CW Rread
back to the client. In the same way,
.CW Twrite
messages are processed by
.CW Srv.write ,
and so on.
.PP
.ix "server loop
The main server loop function,
.CW srv
may be used directly when
.CW postmountsrv
does not do exactly what we want. It reads messages from
.CW Srv.infd ,
and sends replies to
.CW Srv.outfd .
These descriptors usually refer to the pipe created by
.CW postmountsrv ,
but that does not have to be the case.
.PP
Not all functions in
.CW Srv
have to be implemented. In many cases, leaving a nil function pointer for a 9P
request in
.CW Srv
provides a reasonable default. For example,
If files cannot be written, the pointer
.CW Srv.write
may be set to nil, and the main loop will respond with an appropriate
.CW Rerror
reply upon write attempts. The details about which functions must be provided,
which ones do not have to be, and what should such functions do, are described in the
.CW 9p (2)
manual page. In any case, if a function is provided for a message, it is responsible for
responding.
.PP
As an additional help, because
.CW walk
may be complicated to implement, two functions that are building blocks for
.CW walk
may be implemented instead of
.CW walk .
This functions are
.CW walk1
and
.CW clone .
.PP
.ix "9P message~handler
At this point, we can start to implement
.CW semfs .
To handle 9P messages,
we must implement several functions and place pointers to them in a
.CW Srv
structure. 
All the functions correspond with 9P requests, but for
.CW fswalk1
and
.CW fsclone ,
used by the library to implement
.CW walk ,
and for
.CW freefid ,
which will be addressed later.
Given this structure, it is simple to construct a file server by using
.CW postmountsrv ,
or its version for programs using the thread library,
.CW threadpostmountsrv .
.ix [threadpostmountsrv]
.PP
.P1
.ps -1
.ti -1i
.B
.BX semfs.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <auth.h>	// required by lib9p
#include <thread.h>
#include <fcall.h>	// required by lib9p
#include <9p.h>		// definitions for lib9p
#include "sem.h"	// our own definitions
.ps +2
.P2
.P1
.ps -2
.vs .15i
static void fsattach(Req* r) { ... }
static void fscreate(Req* r) { ... }
static void fsread(Req* r){ ... }
static void fswrite(Req* r){ ... }
static char* fswalk1(Fid* fid, char* name, Qid* qid){ ... }
static char* sclone(Fid* fid, Fid* newfid){ ... }
static void fsstat(Req* r){ ... }
static void fsremove(Req* r){ ... }
static void freefid(Fid* fid){ ... }
.ps +2
.P2
.P1
.ps -2
.vs .15i
static Srv sfs=
{
	.attach	=	fsattach,
	.create	=	fscreate,
	.remove	=	fsremove,
	.read	=	fsread,
	.write	=	fswrite,
	.walk1	=	fswalk1,
	.clone	=	fsclone,
	.stat	=	fsstat,
	.destroyfid=	freefid,
};
.ps +2
.P2
.P1
.ps -2
.vs .15i
void
usage(void)
{
	fprint(2, "usage: %s [-D] [-s srv] [-m mnt]\en", argv0);
	threadexitsall("usage");
}
.ps +2
.P2
.P1
.ps -2
.vs .15i
void
threadmain(int argc, char **argv)
{
	char*	mnt;
	char*	srv;

	srv = nil;
	mnt = "/mnt/sem";
	ARGBEGIN{
	case 'D':
		chatty9p++;
		break;
	case 's':
		srv = EARGF(usage());
		break;
	case 'm':
		mnt = EARGF(usage());
		break;
	default:
		usage();
	}ARGEND;

	if(argc!= 0)
		usage();
	threadpostmountsrv(&sfs, srv, mnt, MREPL|MCREATE);
	threadexits(nil);
}
.ps +2
.P2
.LP
The call to
.CW threadpostmountsrv
starts a process (containing a single thread) to serve 9P requests, and
dispatches to functions linked at
.CW sfs ,
which handles the different requests. This program mounts itself (i.e., the
file tree served by the child process) at
.CW /mnt/sem ,
but accepts the conventional option
.CW -m
to specify a different mount point. In the same way, the option
.CW -s
can be used to specify a file in
.CW /srv
where to post a pipe to mount the file server. To aid the debugging process,
the flag
.CW -D
increments the global flag
.CW chatty9p ,
.ix [chatty9p]
.ix "file~server debugging
defined by
.CW lib9p .
When this global is non-zero, the library prints 9P messages as they are
exchanged with the client. Like we saw for
.CW ramfs .
.BS 2 "9P requests
.PP
.ix "9P implementation
The first function we are going to implement is
.CW fsattach .
This particular function
handles
.CW Tattach
messages. Its implementation introduces several important data structures
provided and used by
.CW lib9p .
.P1
static void
fsattach(Req* r)
{
	r->fid->qid = (Qid){0,0,QTDIR};
	r->ofcall.qid = r->fid->qid;
	respond(r, nil);
}
.P2
.LP
Like all other functions for 9P messages,
.CW fsattach
receives a pointer to a
.CW Req ,
.ix [Req]
.ix "9P request
a C structure representing a 9P request. Its definition may be found at
.CW /sys/include/9p.h ,
and includes the following fields:
.P1
typedef struct Req Req;
struct Req
{
	ulong	tag;
	Fcall	ifcall;
	Fcall	ofcall;
	Fid*	fid;
	Dir	d;
	void*	aux;
	Srv*	srv;
	\fI...\fP
};
.P2
.LP
The
.CW tag
field is the tag for the request. It is must be the same in the
.CW T-
message and in the
.CW R-
message used to respond. The actual message that was received (as
a request)
from the client is kept at
.CW ifcall .
.ix [ifcall]
This structure contains the message unpacked as a C structure, reflecting
the actual message received as an array of bytes from the connection to the client.
The purpose of the function is to handle the request as found in
.CW Req.ifcall ,
and then fill up a response message. The response message is actually
.CW Req.ofcall .
This field contains a structure similar to that of
.CW Req.ifcall ,
but this one is for the response message instead of being for the request message.
.PP
The function
.CW respond
.ix [respond]
(see in
.CW fsattach
above)
builds a response message by looking into
.CW Req.ofcall
.ix [ofcall]
and packing the message in an array of bytes, which is then sent back to the client.
It does so if the second argument is
.CW nil .
Otherwise, the second argument is taken as an error string, and
.CW respond
responds with an
.CW Rerror
message instead. In our
.CW fsattach
implementation, we never respond with errors and accept any request.
After the request has been responded
.CW respond
releases the
.CW Req
data structure. A request should never be used again after responding to it.
As you can see in our function, there is no need to fill all fields in the response. The
library
takes care of many of them, including setting the tag and the type in the reply to
correspond to those in the request. So, for
.CW fsattach ,
we only had to fill up the qid sent in the reply.
.PP
The data structure
.CW Fcall ,
.ix [Fcall]
defined in
.CW /sys/include/fcall.h ,
is used in Plan 9 to represent a 9P message. It is used both for
.CW Req.ifcall
and
.CW Req.ofcall .
The meaning of its fields is exactly the meaning of the fields in the 9P
message represented by the
.CW Fcall ,
as described in the section 5 of the manual.
.P1
.ps -2
.vs .15i
typedef
struct	Fcall
{
   uchar   type;
   u32int   fid;
   ushort   tag;
   union {
      struct {
      	u32int	msize;		/* Tversion, Rversion */
      	char	*version;		/* Tversion, Rversion */
      };
      struct {
      	ushort	oldtag;		/* Tflush */
      };
.ps +2
.P2
.P1
.ps -2
.vs .15i
      struct {
      	char	*ename;		/* Rerror */
      };
      struct {
      	Qid	qid;		/* Rattach, Ropen, Rcreate */
      	u32int	iounit;		/* Ropen, Rcreate */
      };
      struct {
      	Qid	aqid;		/* Rauth */
      };
.ps +2
.P2
.P1
.ps -2
.vs .15i
      struct {
      	u32int	afid;		/* Tauth, Tattach */
      	char	*uname;		/* Tauth, Tattach */
      	char	*aname;		/* Tauth, Tattach */
      };
      struct {
      	u32int	perm;		/* Tcreate */ 
      	char	*name;		/* Tcreate */
      	uchar	mode;		/* Tcreate, Topen */
      };
.ps +2
.P2
.P1
.ps -2
.vs .15i
      struct {
      	u32int	newfid;		/* Twalk */
      	ushort	nwname;		/* Twalk */
      	char	*wname[MAXWELEM];	/* Twalk */
      };
      struct {
      	ushort	nwqid;		/* Rwalk */
      	Qid	wqid[MAXWELEM];	/* Rwalk */
      };
.ps +2
.P2
.P1
.ps -2
.vs .15i
      struct {
      	vlong	offset;		/* Tread, Twrite */
      	u32int	count;		/* Tread, Twrite, Rread */
      	char	*data;		/* Twrite, Rread */
      };
      struct {
      	ushort	nstat;		/* Twstat, Rstat */
      	uchar	*stat;		/* Twstat, Rstat */
      };
   };
} Fcall;
.ps +2
.P2
.PP
Most 9P requests refer to a particular fid, which is a number that represents
a particular file in use by the client. Thus, a
.CW Req
contains a pointer to a
.CW Fid
.ix [Fid]
data structure that represents a fid, maintained by
.CW lib9p .
The library keeps a table for fids in use, and a
.CW Fid
data structure for each one. When the protocol dictates that a new fid is allocated,
the library creates a
.CW Fid
and updates the table. The library also releases fids when they are no longer in use.
A
.CW Fid
looks like follows.
.P1
typedef struct Fid Fid;
struct Fid
{
	ulong	fid;
	char	omode;	/* -1 = not open */
	Qid	qid;
	void*	aux;
	\fI...\fP
};
.P2
.LP
It contains the fid number, the open mode for the fid (or
.CW -1
if it is not open),
and
the qid for the file referenced by the fid.
.PP
The purpose of
.CW fsattach
is to let clients attach to our tree, by making the fid refer to our root directory
and replying with an
.CW Rattach
message informing of its qid. The library helps in mapping fids to qids, because
it handles all the
.CW Fid
structures and keeps their qids in each
.CW Fid.qid .
But the file server must still map different qids to different files.
.PP
In
.CW semfs ,
there is a flat (root) directory that may contain files representing semaphores.
The qid for the directory must have
.CW QTDIR
set in its
.CW type
field. Having just one directory, we may use
.CW Qid.type
to see if a qid refers to the root or to any other file in our tree. The
.CW path
field for the qid (i.e., the actual qid number) may be just zero, as the version field.
Therefore, this is what
.CW fsattach
does.
.P1
r->fid->qid = (Qid){0,0,QTDIR};
r->ofcall.qid = r->fid->qid;
.P2
.LP
The fid represented by
.CW r->fid
(the one mentioned by the
.CW Tattach )
.ix attach
now refers to the root directory of our tree. The response message carries
the qid back to the client. That is all we had to do.
.PP
We still must invent a scheme for assigning qids to files representing semaphores.
A simple way is to keep all the semaphores in a single array, and use the array
index as the
.CW Qid.path
for each file. Given a qid, we would know if it is the directory or a file. Should it be
a file,
.CW Qid.path
would be the unique index for each semaphore in the array.
.BS 2 "Semaphores
.LP
What is a semaphore? For our server, it is just an instance of a
.CW Sem
.ix [Sem]
data structure.
We can place in
.CW sem.h
its declaration and
all the definitions needed to use the implementation for semaphores, that we may
keep at
.CW sem.c .
The file
.CW semfs.c
is kept just with the implementation for the different file server requests.
.PP
The structure
.CW Sem
needs to keep the number of tickets.
Also, we need to record the name for the file representing the semaphore and
its index in the array (used to build its qid).
.PP
When a
.I down
.ix up
.ix down
is made on a semaphore with no tickets, we must hold the operation until there
is one ticket available. In our case, when a
.CW Tread
request is received for a semaphore that has no tickets, we must hold the request
until there is one ticket and we can reply. Therefore, the semaphore needs to
maintain a list of requests to be replied when tickets arrive. For now, this is all we
need. The resulting data structure is as follows (Ignore the field
.CW Ref
by now).
.P1
.ps -1
.ti -1i
.B
.BX sem.h
.ps +1
.CW
.vs .2i
typedef struct Sem Sem;
typedef struct QReq QReq;
struct Sem {
	Ref;
	int	id;	// index in array; qid.path
	char*	name;	// of file
	int	tickets;
	QReq*	reqs;	// reads (i.e., downs) pending
};
.P2
.P1
struct QReq {
	QReq*	next;	// in pending request list
	Req*	r;	// the request pending
};
extern Sem*	sems[Nsems];
.P2
.LP
Before proceeding, we are going to complete the
implementation for the semaphore abstraction by implementing its operations.
We need to create semaphores. The function
.CW newsem
does that.
.PP
The
.CW Sem
structure is initialized to contain no tickets. The
.CW id
field keeps the index in the array, and the name for the file representing the
semaphore is kept as well.
.P1
.ps -1
.ti -1i
.B
.BX sem.c
.ps +1
.CW
.vs .2i
.I "..."
Sem*	sems[Nsems];

Sem*
newsem(char* name)
{
	int	i;

	for (i = 0; i < Nsems; i++)
		if (sems[i] == nil)
			break;
	if (i == Nsems)
		return nil;
	sems[i] = emalloc9p(sizeof(Sem));
	memset(sems[i], 0, sizeof(Sem));
	sems[i]->ref = 2;
	sems[i]->id = i;
	sems[i]->name = estrdup9p(name);
	return sems[i];
}
.P2
.LP
The function locates a free entry in
.CW sems ;
to keep the new semaphore. When a semaphore is no longed needed,
and is released, we will deallocate it and set its entry to nil in the array. So,
the function sweeps the array from the beginning, looking for the first available
entry.
.PP
All the semaphores will be kept in the array
.CW sems ,
.ix "Qid conventions
indexed by their qids. This violates a little bit the convention that a qid number
is never reused for a different file. A semaphore using an array entry that was
used before by an old semaphore (now removed) is going to have the same qid used by
the old one. This may cause problems if binds are done to semaphore files, and also
if any client caches semaphores. In our case, we prefer to ignore this problem.
To fix it, the file server can keep a global counter to assign qid numbers to semaphores,
and increment the counter each time a new semaphore is created. Nevertheless, the
implementation shown here suffices for our purposes.
.PP
Instead of using
.CW malloc ,
we must use
.CW emalloc9p .
The 9P library provides implementations for
.CW emalloc9p ,
.CW erealloc9p ,
and
.CW estrdup9p
.ix "emalloc9p
.ix "erealloc9p
.ix "[lib9p] memory~allocation
that mimic the ones with a similar name in the C library. These implementations
take an appropriate action when there is no more memory, and guarantee that
they will always return new memory. The appropriate action is simply aborting the
entire program, but you may implement your own versions for these functions if
something better is needed.
.PP
Perhaps surprisingly, there is
.I no
function to free a semaphore. The point is that we can only free a
.CW Sem
when we know that no data structure in our program is using it. But when
does that happen? Requests mention fids, that may refer to
.CW Sem
data structures. If a user wants to remove a file representing a semaphore,
we can only do so when no references remain to that semaphore. Calling
.CW free
on a semaphore while there might be requests and/or fids pointing to it would be a disaster.
.PP
The solution is to do
.B "reference counting" .
Each semaphore contains one integer, which is called a reference counter.
For each reference that points to a
.CW Sem
we count one reference using the counter. New references made to the
semaphore increment the counter.
When a reference is gone, we decrement the reference counter. Only when
the counter gets down to zero it is safe to release the data structure.
This technique is used in many different places by operating systems, to
release file descriptors when no process is using them, to remove files when
nobody is using them, to destroy windows when no process is using them, etc.
.PP
In general, releasing data structures or other resources when they are no longer
needed is called
.B "garbage collection" .
Reference counting is a form of garbage collection that may be used for any
data structures that do not form cycles. If there are cycles, there may be circular
lists not referenced from outside, that would never be deallocated by reference
counting because there
is at least one reference for each node (from the previous node in the cycle).
.PP
The thread library provides reference counters, protected by locks.
They can be used safely even when multiple processes are incrementing and
decrementing the counters, which by the way, is not the case here.
.ix [Ref]
.ix [incref]
.ix [decref]
A
.CW Ref
structure is a reference counter, containing a
.CW ref
field with the counter and a lock. The function
.CW incref
increments the counter (using the lock to protect from possible races). The
function
.CW decref
decrements the counter and returns the new value for it.
.PP
As you could see,
.CW newsem
sets
.CW sems[i]->ref
to
.CW 2 ,
because it is returning one reference and also storing another
reference in the array of semaphores. Both references must go away before
releasing the semaphore. To release one reference, the function
.CW closesem
can be called.
.P1
void
closesem(Sem* s)
{
	if (s != nil && decref(s) == 0){
		assert(s->reqs == nil);
		assert(sems[s->id] == s);
		sems[s->id] = nil;
		free(s->name);
		free(s);
	}
}
.P2
.LP
It decrements the reference counter for
.CW s ,
but releases the data structure only when no other references exist, i.e.,
only when
.CW decref
reports that
.CW s->ref
is zero after discounting one reference. To allow calls to
.CW closesem
with nil pointers, a check for
.CW s!=nil
was added as well.
.PP
Let's proceed with other operations for our data type.
To add tickets we can simply handle
.CW Sem.tickets
as we please. To remove tickets we can do the same. The only operations
that remain to be provided are those handling the list of pending requests
in the semaphore. They are simply implementing a queue of requests using
.CW Sem.reqs .
This function enqueues a new pending request in the semaphore, adding it to the
tail of the queue.
.ix queue
.P1
void
queuereq(Sem* s, Req* r)
{
	QReq*	q;
	QReq**	l;

	q = emalloc9p(sizeof(QReq));
	q->r = r;
	q->next = nil;
	for (l = &s->reqs; *l != nil; l = &(*l)->next)
		;
	*l = q;
}
.P2
.LP
The next one returns the first request in the queue, and removes it
from the head.
.P1
Req*
dequeuereq(Sem* s)
{
	QReq*	q;
	Req*	r;

	if (s->reqs == nil)
		return nil;
	q = s->reqs;
	s->reqs = q->next;
	r = q->r;
	free(q);
	return r;
}
.P2
.LP
Because we might change this part of the implementation in the future, we
add a function to check if there is any queued request, so that nobody would need
to touch
.CW Sem.reqs .
.P1
int
queuedreqs(Sem* s)
{
	return s->reqs != nil;
}
.P2
.BS 2 "Semaphores as files
.LP
We have all the tools needed to complete our file server.
The following function
serves
.CW Tcreate
.ix [Tcreate]
requests, which create semaphores. To do so, it allocates a new
.CW Sem
data structure by calling
.CW newsem .
.P1
static void
fscreate(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;

	fid = r->fid;
	q = fid->qid;
	if (!(q.type&QTDIR)){
		respond(r, "not a directory");
		return;
	}
	s = newsem(r->ifcall.name);
	fid->qid = (Qid){s->id, 0, 0};
	fid->aux = s;
	fid->omode = r->ifcall.mode;
	incref(s);
	r->ofcall.qid = fid->qid;
	respond(r, nil);
}
.P2
.LP
In a
.CW Tcreate ,
the fid in the request (represented by
.CW r->fid )
should point to a directory. The server is expected to create a file with the name
specified in the request
(which is
.CW r->ifcall.name
here) within that directory. Also, after the
.CW Tcreate ,
the fid must point to the newly created file and
must be open according to the mode specified in the request. This is what the function
does.
.PP
If the qid is not for the directory (the
.CW QTDIR
.ix [QTDIR]
bit is not set in its qid), an
.CW Rerror
message is sent back to the client, instead of creating the file. This is achieved by
calling
.CW respond
with a non-null string as the error string.
Otherwise, we create a
.CW Sem
data structure by calling
.CW newsem .
The qid in the
.CW fid
and the response,
.CW r->ofcall ,
is also updated to refer to the new file.
.PP
To make things simpler for us, we place a pointer to the
.CW Sem
implied by the qid in the
.CW Fid.aux
field of each fid. All of
.CW Fid ,
.CW Req ,
and
.CW Srv
data structures contain an
.CW aux
field that can be used by your programs to keep a pointer to any data
of interest for your file server. In our case,
.CW fid->aux
will always point to the
.CW Sem
structure for the file referenced by the fid. We do so
for all fids referring to semaphore files.
.PP
The
.CW fsclone
.ix "fid clone
routine is called by the library when a new fid is created as a clone of
an existing one, as part of the implementation for the
.CW Twalk
message (that creates new fids by cloning old ones).
The implementation updates the
.CW aux
.ix "user data
field for the new fid and the reference counter for the semaphore involved
(which is now pointed to by a new fid). The function might return a non-null string
to signal errors, but this implementation will never fail.
.P1
static char*
fsclone(Fid* fid, Fid* newfid)
{
	Sem*	s;

	s = fid->aux;
	if (s != nil)
		incref(s);
	newfid->aux = s;
	return nil;
}
.P2
.LP
The library uses reference counting to know when a
.CW Fid
is no longer used (e.g., because of a
.CW Tclunk
that removed the last reference to a fid).
When a fid is released
the library calls
.CW Srv.destroyfid ,
.ix [destroyfid]
which we initialized to point to
.CW freefid .
This function releases one reference to the semaphore
for the fid. If this was the last one pointing to the
semaphore, it will be released. Note that there will always be one reference from
the array of semaphores, as long as the file has not been removed.
.P1
static void
freefid(Fid* fid)
{
	Sem*	s;

	s = fid->aux;
	fid->aux = nil;
	closesem(s);
}
.P2
.LP
Removing of files is done by
.CW fsremove ,
.ix "file remove
which releases the reference from the array as well as the one from the fid.
.P1
static void
fsremove(Req* r)
{
	Req*	q;
	Sem*	s;

	s = r->fid->aux;
	while(r = dequeuereq(s))
		respond(q, "file has been removed");
	closesem(s);
	r->fid->aux = nil;
	closesem(s);	// release reference from sems[]
	respond(r, nil);
}
.P2
.LP
Before actually removing anything, all the poor requests waiting for future
tickets are responded, with an error message that reports that the semaphore
was removed.
.PP
One word about reference counting before continuing. A semaphore may point
to requests, that point to fids, that may point to the semaphore. So, at first sight,
we have a data structure with cycles and we should not use reference counting
to release it. However, upon a
.CW Tremove ,
.ix [Tremove]
all the requests in the semaphore are released. From this point, the semaphore
will not create any cycle in the data structure, and reference counting may be
safely used.
.PP
The 9P message
.CW Tread
is handled by
.CW fsread .
This function implements reading from a fid (i.e., a file). But note that
the root directory may be
one of the files read by the client, e.g., to list its contents. This is very different
from reading for a semaphore file, and the function must take a different course of
action if
.CW QTDIR
is set in the qid for the file being read.
.P1
static void
fsread(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;
	char	nl[2] = "\en";
	fid = r->fid;
	q = fid->qid;
	if (q.type&QTDIR){
		dirread9p(r, getdirent, nil);
		respond(r, nil);
		return;
	}
.P2
.P1
	s = fid->aux;
	if (s->tickets > 0){
		s->tickets--;
		readstr(r, nl);
		respond(r, nil);
	} else
		queuereq(s, r);
}
.P2
We defer the discussion of reading from the root directory until later.
Reading from a semaphore file means obtaining a ticket from the semaphore.
The semaphore is pointed to by
.CW fid->aux .
So, it all depends on the value of
.CW s->tickets .
When there is one ticket to satisfy the request (i.e., to do a
.I down
in the semaphore), we decrement
.CW s->tickets ,
to give one ticket to the process reading. When there are no tickets, the request
.CW r
is queued in the semaphore by a call to
.CW queuereq .
Not responding until we have one ticket means blocking a
.I down
until it obtains its ticket.
.PP
But a read must return some bytes from the file (maybe none). What do we read
when we obtain a ticket? To permit using the command
.CW read
to obtain tickets using the shell, we return a newline character for each ticket
read. For the
.CW read
command,
a new line terminates the line it should read. For us, reading once from the
semaphore means obtaining one ticket. Both concepts match if we read an
empty line.
.PP
The data supposedly contained in the file, read by a
.CW Tread
request
is contained in the string
.CW nl .
Just an empty line. To satisfy a
.CW Tread ,
the program must look at
.CW r->ifcall.offset
and
.CW r->ifcall.count ,
which contains the offset in the file where to start reading and the number of
bytes to return at most. Then, the program must update
.CW r->ofcall.count
and
.CW r->ofcall.data
to reply later with an
.CW Rread
.ix "read processing
containing the number of bytes in the
message and the bytes themselves. In our case, we could ignore the offset
and do it as follows.
.P1
r->ofcall.count = r->ifcall.count;
if (r->ofcall.count > 1)
	r->ofcall.count = 1;
memmove(r->ofcall.data, "\en", r->ofcall.count);
respond(r, nil);
.P2
.LP
We read one byte at most, the new line. And then we respond with the
.CW Rread
message.
.PP
If we did not ignore the offset in the request, further reads from the file (at
offsets bigger than zero) would always return zero bytes, and not a new line.
But in any case, reading from a semaphore file still would have the semantics
of blocking until a ticket is obtained, and then returning something (perhaps just
nothing).
Nevertheless, we have been assuming that processes using our file system
will open the file for a semaphore before each operation, and then close it
after doing it. The C interface that we designed for using our semaphore file
system did it this way.
.PP
In the implementation for
.CW fsread ,
the function did not update the response message by itself. Instead, it calls
.CW readstr ,
.ix [readstr]
.ix [readbuf]
which is a helper function from
.CW lib9p
that fills an
.CW Rread
reply assuming that file contents are those in the string given as a
parameter (in this case, the contents of
.CW nl ).
The function updates
.CW r->ofcall.count
and
.CW r->ofcall.data ,
taking care of the offset, the string size, and the maximum number of bytes
requested.
After calling
.CW readstr ,
the only thing pending is calling
.CW respond
to reply to the client.
By the way, another helper called
.CW readbuf
is similar to
.CW readstr ,
but reads from an arbitrary array of bytes, and not just from a string.
Calling
.CW readstr
is similar to calling
.P1
readbuf(r, str, strlen(str));
.P2
.LP
in any case.
.PP
That was the implementation for a
.I down .
The implementation for an
.I up
is contained in the function that handles
.CW Twrite
messages.
Our convention was that a write with a number (printed as a string)
would add so many tickets to the semaphore.
.P1
static void
fswrite(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;
	char	str[10];
	Req*	qr;
	char	nl[2] = "\en";
.P2
.P1
	fid = r->fid;
	q = fid->qid;
	if (q.type&QTDIR){
		respond(r, "permission denied");
		return;
	}
.P2
.P1
	if (r->ifcall.count > sizeof(str) - 1){
		respond(r, "string too large");
		return;
	}
.P2
.P1
	memmove(str, r->ifcall.data, r->ifcall.count);
	str[r->ifcall.count] = 0;
	s = fid->aux;
	s->tickets += atoi(str);
.P2
.P1
	while(s->tickets > 0 && queuedreqs(s)){
		qr = dequeuereq(s);
		qr->ofcall.count = 1;
		s->tickets--;
		readstr(qr, nl);
		respond(qr, nil);
	}
	respond(r, nil);
}
.P2
.LP
.ix "write processing
Writing to directories is not permitted and the function checks that
.CW QTDIR
is not set in the qid for the file being written. When writing to a file, the
function takes the bytes written from
.CW r->ifcall.data ,
and moves the bytes in there
to a buffer,
.CW str .
The number of bytes sent in the write request is reported by
.CW r->ifcall.count .
The offset for the write, kept at
.CW r->ifcall.offset ,
is ignored.
.PP
We had to move the bytes to
.CW str
to terminate the string written with a final null byte, so we could use
.CW atoi
to convert the string to a number, and add so many tickets to
.CW s->tickets .
It might seem simpler to write an integer directly, but then we could not
use
.CW echo
to update semaphores, and we would have to agree on the endianness for
the integers written to the file. It is simpler in this way.
.PP
Once the semaphore has been updated, the implementation still has to
complete any pending
.I down
that may proceed due to the new tickets added. The last
.CW while
does just that. While there are tickets and pending requests, we reply
to each one of such requests with an empty line, like
.CW fsread
did when tickets were available.
.PP
.ix "directory reads
That is all we had to do. We still
have to show reading from the file that is the root directory. The code used by
.CW fsread
to handle such requests was as follows.
.P1
if (q.type&QTDIR){
	dirread9p(r, getdirent, nil);
	respond(r, nil);
	return;
}
.P2
.LP
Reading from a directory must return an integral number of directory entries,
formatted as an array of bytes, neutral to all architectures, so that reading from
a directory would return meaningful data no matter the architecture of the machine
used by the file server and the one used as a client. Attending such reads can be
a burden. The function
.CW dirread9p ,
provided by the library, is a helper routine that fills
.CW r->ofcall.data
and
.CW r->ofcall.count
to read correctly from a directory.
.PP
But how can
.CW dirread9p
know which entries are kept in the directory? That is, how can it know what
bytes should be read?
A function, called here
.CW getdirent ,
.ix [dirread9p]
and called
.CW dirgen
by the
.I 9p (2)
manual page, is given as an argument to
.CW dirread9p .
.PP
What happens is that
.CW dirread9p
calls
.CW getdirent
to obtain the first entry in the directory, then the second, then the third, etc.
until it has enough entries to fill the
.CW Rread
message in
.CW r->ofcall .
The parameter
.CW n
of
.CW getdirent
shows which file is the one whose directory entry should be copied into
.CW *d
by
the function.
Each call to
.CW getdirent
(to a
.CW dirgen
function) must fill a
.CW Dir
structure for the
.I n -th
file in the directory, and return zero. Or it must return
.CW -1
to signal that there is no
.I n -th
file in the directory.
Another common convention is that an index of
.CW -1
given to a
.CW dirgen
.ix [dirgen]
refers to the directory itself, and not to any of its entries. Although we do not
depend on that, we follow it as well.
This is the implementation for
.CW getdirent .
.P1
static int
getdirent(int n, Dir* d, void*)
{
	d->atime= time(nil);
	d->mtime= d->atime;
	d->uid = estrdup9p(getuser());
	d->gid = estrdup9p(d->uid);
	d->muid= estrdup9p(d->uid);
	if (n == -1){
		d->qid = (Qid){0, 0, QTDIR};
		d->mode = 0775;
		d->name = estrdup9p("/");
		d->length = 0;
	} else if (n >= 0 && n < nsems && sems[n] != nil){
		d->qid = (Qid){n, 0, 0};
		d->mode = 0664;
		d->name = estrdup9p(sems[n]->name);
		d->length = sems[n]->tickets;
	} else
		return -1;
	return 0;
}
.P2
.LP
.ix "access time
.ix "modification time
We pretend that the access time and last modification time for the file
is just now. Regarding the owner (and group and last modifier user) for the
file we use the username of the owner of our process. That is reasonable.
.PP
Now things differ depending on which entry is requested by the caller to
.CW getdirent .
If
.CW n
is
.CW -1 ,
we assume that
.CW d
must be filled with a directory entry for the directory itself. In this case, we
update the qid, permissions, file name, and length to be those of our root
directory. Note that conventionally directories have a length of zero. Note also
how strings kept by the directory entry must be allocated using
.CW estrdup9p ,
or maybe using
.CW emalloc9p .
.PP
If
.CW n
is a valid identifier (index) for a semaphore, we update
the qid, permissions, file name, and length in
.CW d .
Otherwise we return
.CW -1
to signal that there is no such file.
Note how
.CW d->qid.path
is the index for the semaphore. Also, we report as the file size the number
of tickets in the semaphore. In this way,
.CW ls
can be used to see if a semaphore has any available tickets in it.
.PP
The last parameter in
.CW getdirent
corresponds to the last parameter we gave to
.CW dirread9p .
This function passes such argument verbatim to each call of
.CW getdirent .
It can be used to pass the data structure for the directory being iterated through
calls to
.CW getdirent .
In our case, we have a single directory and do not use the
auxiliary
argument.
.PP
.ix "stat processing
Having implemented
.CW getdirent
makes it quite easy to implement
.CW fsstat ,
to serve
.CW Tstat
requests. The function
.CW fsstat
must fill
.CW r->d
with the directory entry for the file involved. Later,
.CW respond
will fill up an appropriate
.CW Rstat
message by packing a directory entry using the network format for
it (similar to directory entries traveling in
.CW Rread
messages for directories).
.P1
static void
fsstat(Req* r)
{
	Fid*	fid;
	Qid	q;
	
	fid = r->fid;
	q = fid->qid;
	if (q.type&QTDIR)
		getdirent(-1, &r->d, nil);
	else
		getdirent(q.path, &r->d, nil);
	respond(r, nil);
}
.P2
.LP
When the file for
.CW Tstat
is the directory, we call
.CW getdirent
to fill
.CW r->d
with the entry for the file number
.CW -1 ,
i.e., for the directory itself. Once
.CW getdirent
did its job, we only have to call
.CW respond .
.PP
We are now close to completing our file server. We must still implement
the function
.CW fswalk1 ,
used by the library (along with
.CW fsclone )
to implement
.CW walk .
This function receives a fid, a file name and a qid. It should walk to
the file
.CW name
from the one pointed to by
.CW fid .
For example, if
.CW fid
refers to the root directory, and
.CW name
is
.CW mutex ,
.ix mutex
the function should leave the fid pointing to
.CW /mutex .
If later, the function is called with the same fid but the name is
.CW .. ,
the function should leave the fid pointing to
.CW / .
Walking to
.CW ..
from
.CW /
leaves the fid unchanged. The convention is that
.CW /..
is just
.CW / .
Like it happens with
.CW fsclone ,
the function must return a nil string when it could do its job, or a string
describing the error when it failed. Besides, both
.CW fid->qid
and
.CW *qid
must be updated with the qid for the new file after the walk. Furthermore, because
we keep a pointer to a
.CW Sem
in the
.CW fid->aux
field, the function must update such field to point to the right place after the walk.
.P1
.ps -2
.vs .15i
static char*
fswalk1(Fid* fid, char* name, Qid* qid)
{
	Qid	q;
	int	i;
	Sem*	s;

	q = fid->qid;
	s = fid->aux;
.ps +2
.P2
.P1
.ps -2
.vs .15i
	if (!(q.type&QTDIR)){
		if (!strcmp(name, "..")){
			fid->qid = (Qid){0,0,QTDIR};
			*qid = fid->qid;
			closesem(s);
			fid->aux = nil;
			return nil;
		}
	} else {
.ps +2
.P2
.P1
.ps -2
.vs .15i
		for (i = 0; i < nsems; i++)
			if (sems[i] && !strcmp(name, sems[i]->name)){
				fid->qid = (Qid){i, 0, 0};
				incref(sems[i]);
				closesem(fid->aux);
				fid->aux = sems[i];
				*qid = fid->qid;
				return nil;
			}
	}
	return "no such file";
}
.ps +2
.P2
.LP
Walking to the root directory releases any reference to the
.CW Sem
that might be pointed to by
.CW fid->aux .
.ix "walk processing
Walking to a file adds a new reference to the semaphore for the file.
But otherwise, the function should be simple to understand.
.PP
And this completes the implementation for our semaphore file server.
After compiling it,
we can now use it like follows.
.P1
; 8.semfs -s sem -m /mnt/sem
; echo 1 >/mnt/sem/mutex
; echo 3 >/mnt/sem/other
.P2
.P1
; ls -l /mnt/sem
--rw-rw-r-- M 174 nemo nemo 1 Aug 23 00:16 /mnt/sem/mutex
--rw-rw-r-- M 174 nemo nemo 3 Aug 23 00:16 /mnt/sem/other
.P2
.P1
; read </mnt/sem/other

; ls -l /mnt/sem/other
--rw-rw-r-- M 174 nemo nemo 2 Aug 23 00:16 /mnt/sem/other
.P2
.P1
; read </mnt/sem/other

; read </mnt/sem/other

; read </mnt/sem/other
	\fIThis blocks until a ticket is added. And then....\fP
;
.P2
.LP
The program we built uses a single process to handle all 9P requests.
Nevertheless, we decided to show how to use the thread library together
with
.CW lib9p .
If we decide to change the program to do something else, that requires
multiple threads or processes, it is easy to do so. Once again, it is important
to note that by processing all the requests in a single process, there is no
race condition. All the data structures for the semaphores are free of races, as
long as they are touched only from a single process.
.PP
For example, if this program
is ever changed to listen for 9P clients in the network, it might create a new process
to handle each connection. That process may just forward 9P requests through
channels to a per-client thread that handles the client requests. Once again,
there would be no races because of the non-preemption for threads.
.PP
There are several other tools for building file servers in Plan 9. Most notably,
there is a implementation of file trees, understood by
.CW lib9p .
File servers that only want to take care of reading and writing to their files
may create a file tree and place a pointer to it in the
.CW Srv
structure. After doing so, most of the calls that work on the file tree would
be supplied by the library. In general, only reading and writing to the files
must be implemented (besides creation and removal of files). We do not discuss
this here, but the program
.CW /sys/src/cmd/ramfs.c
is an excellent example of how to use this facility.
.BS 2 "A program to make things
.LP
For all the previous programs, compiling them by hand could suffice. For our file server
program,
it is likely that we will have to go through the compile-test-debug cycle multiple times.
Instead of compiling and linking it by hand, we are going to use a tool that knows
how to build things.
.PP
The program
.CW mk
.ix [mk]
.ix [make]
.ix UNIX
is similar to the UNIX program
.CW make .
Its only purpose is to build things once you tell it how to build them. The instructions
for building our
.I products
must be detailed in a file called
.CW mkfile ,
read by
.CW mk
to learn how to build things.
.PP
We placed the source code, along with an initial version for our
.CW mkfile ,
.ix [mkfile]
.ix "building things
in a directory for our file server program.
.P1
; lc
mkfile	sem.c	sem.h	semfs.c
; cat mkfile
8.semfs: semfs.8 sem.8
	8l -o 8.semfs semfs.8 sem.8

semfs.8: semfs.c sem.h
	8c -FVw semfs.c

sem.8: sem.c sem.h
	8c -FVw sem.c
;
.P2
.LP
Now, running
.CW mk
in this directory has the following effect.
.P1
; mk
8c -FVw semfs.c
8c -FVw sem.c
8l -o 8.semfs semfs.8 sem.8
;
.P2
.LP
The
.CW mkfile
contains
.I rules ,
.ix "[mk] rules
that describe how to build one file provided you have other ones. For example,
this was one rule:
.P1
8.semfs: semfs.8 sem.8
	8l -o 8.semfs semfs.8 sem.8
.P2
.LP
It says that we can build
.CW 8.semfs
if we have both
.CW semfs.8
and
.CW sem.8 .
The way to build
.CW 8.semfs
according to this rule is to execute the command
.P1
	8l -o 8.semfs semfs.8 sem.8
.P2
.LP
All the rules have this format. There is a
.I target
.ix "[mk] targets
to build, followed by a
.CW :
sign and a list of
.I dependencies
.ix "file dependencies
(that is, things that our target depends on).
The target and the list of dependencies must be in the same line. If a line
gets too long, the backslash character,
.CW \e ,
can be used to continue writing on the next line as if it was a single one.
A rule says that
provided that we have the files
listed in the dependencies list, the target can be built. It is also said that
the target depends on the files listed after the
.CW :
sign.
Following this line, sometimes called the
.I header
of the rule, 
a rule contains one or more lines starting with a tabulator character. Such
lines are executed as shell commands to build the target. These lines are
sometimes called the
.I body
for the rule.
.PP
When we executed
.CW mk ,
it understood that we wanted to build the first target mentioned in the
.CW mkfile .
That was
.CW 8.semfs .
So,
.CW mk
checked out to see if it had
.CW semfs.8
and
.CW sem.8
(the dependencies for
.CW 8.semfs ).
Neither file was there! What could
.CW mk
do?
Simple. The program searched the
.CW mkfile
to see if, for each dependency,
any other rule described to to build it. That was the case. There is a rule for
building
.CW sem.8 ,
and one for building
.CW semfs.8 .
.PP
So,
.CW mk
tried to build
.CW semfs.8 ,
using its rule.
The rule says that given
.CW semfs.c
and
.CW sem.h ,
.CW semfs.8
can be built.
.P1
semfs.8: semfs.c sem.h
	8c -FVw semfs.c
.P2
.LP
Both
.CW semfs.c
and
.CW sem.h
are there, and
.CW mk
can proceed to build
.CW semfs.8 .
How? By
executing the command in the body of the rule.
This command runs
.CW 8c
and compiles
.CW semfs.c .
.PP
Note one thing. The body of the rule does
.I not
use the file
.CW sem.h .
We know that the object file
.CW semfs.8
comes from code both in
.CW semfs.c
and
.CW sem.h .
But
.CW mk
does not! You see the same invariant all the times. Programs usually know
nothing about things. They just do what they are supposed to do, but there is
no magic way of telling
.CW mk
which files really depend on others, and why the commands in the body can be
used to build the target.
.PP
In the same way,
.CW mk
uses the rule for the target
.CW sem.8 ,
to build this file. This is the last dependency needed for building
.CW 8.semfs .
.P1
sem.8: sem.c sem.h
	8c -FVw sem.c
.P2
After executing the body, and compiling
.CW sem.c ,
both dependencies exist, and
.CW mk
can proceed to build, finally,
.CW 8.semfs .
How? You already know. It
runs the command in the body of the rule for
.CW 8.semfs .
This command uses
.CW 8l
to build a binary program from the object files.
.PP
.CW Mk
chains rules in this way, recursively, trying to build the target. A target may
be given as an argument. If none is given,
.CW mk
tries to build the first target mentioned. 
.PP
Suppose we now run
.CW mk
again. This is what happens.
.P1
; mk
mk: '8.semfs' is up to date
;
.P2
.LP
No rule was executed. The program
.CW mk
assumes that a target built from some other files, if newer than
the other files, is already up to date and does not need to be built.
Because we did not modify any file, the file
.CW 8.semfs
is newer than
.CW semfs.8
and
.CW sem.8 .
This means that
.CW 8.semfs
is up to date with respect to its dependencies. Before checking this out,
.CW mk
checks if the dependencies themselves are up to date.
The file
.CW semfs.8
is newer than its dependencies, which means that it is up to date as well.
The same happens to
.CW sem.8 .
In few words, the target given to
.CW mk
is up to date and there is nothing to make.
.PP
Suppose now that we edit
.CW sem.c ,
which we can simulate by touching the file (updating its modification time).
Things change.
.P1
; touch sem.c
; mk
8c -FVw sem.c
8l -o 8.semfs semfs.8 sem.8
;
.P2
.LP
The file
.CW sem.8 ,
needed because
.CW 8.semfs
depends on it, is not up to date. One of the files it depends on,
.CW sem.c ,
is newer than
.CW sem.8 .
This means that the target
.CW sem.8
is old, with respect to
.CW sem.c ,
and must be rebuilt to be up to date. Thus,
.CW mk
runs the body of its rule and compiles the file again.
.PP
The other dependency for the main target,
.CW semfs.8 ,
is still up to date. However,
because
.CW sem.8
is now newer than
.CW 8.semfs ,
this file is out of date, and the body for its rule is executed.
In few words,
.CW mk
executes only what is strictly needed to obtain an up to date target. If nothing
has to be done, it does nothing. Of course
.CW mk
only knows what the
.CW mkfile
says, you should not expect
.CW mk
to know C or any other programming language. It does not know anything about
your source code.
.PP
What if we want to compile
.CW semfs
for an ARM, and not for a PC. We must use
.ix [5c]
.CW 5c
and
.CW 5l
instead of
.CW 8c
and
.CW 8l .
Adjusting the
.CW mkfile
for each architecture we want to compile for is a burden at least. It is better to use
.I variables .
.PP
An
.CW mkfile
.ix "[mk] variables
may declare variables, using the same syntax used in the shell. Environment
variables are created for each variable you define in the
.CW mkfile .
Also, you may use environment variables already defined. That is to say that
.CW mk
uses environment variables in very much the same way the shell uses it.
The next
.CW mkfile
improves our previous one.
.P1
.ps -1
.ti -1i
.B
.BX mkfile
.ps +1
.CW
.vs .2i
CC=8c
LD=8l
O=8

$O.semfs: semfs.$O sem.$O
	$LD -o $O.semfs semfs.$O sem.$O

semfs.$O: semfs.c sem.h
	$CC -FVw semfs.c

sem.$O: sem.c sem.h
	$CC -FVw sem.c
.P2
.LP
The
.CW mkfile
defines a
.CW CC
variable to name the C compiler, an
.CW LD
variable to name the loader, and an
.CW O
.ix [$CC]
.ix [$LD]
.ix [$O]
variable to name the character used to name object files for the architecture.
The behavior of
.CW mk
when using this
.CW mkfile
is exactly like before. However, we can now change the definitions for
.CW CC ,
.CW LD ,
and
.CW O
as follows
.P1
CC=5c
LD=5l
O=5
.P2
.LP
Running
.CW mk
again will compile for an ARM.
.P1
; mk
5c -FVw semfs.c
5c -FVw sem.c
5l -o 5.semfs semfs.5 sem.5
;
.P2
.LP
As another example, we can prepare for adding more source files in the future,
and declare a variable to list the object files used to build our program. The
resulting
.CW mkfile
is equivalent to our previous one, like in all the examples that follow.
.P1
.ps -1
.ti -1i
.B
.BX mkfile
.ps +1
.CW
.vs .2i
CC=8c
LD=8l
O=8

OFILES=semfs.$O sem.$O

$O.semfs: $OFILES
	$LD -o $O.semfs $OFILES
.I "...other rules..."
.P2
.LP
There are several variables defined by
.CW mk ,
to help us to write rules. For example,
.CW $target
is the target being built, for each rule. Also,
.CW $prereq
.ix [$target]
.ix [$prereq]
.ix "[mk] predefined~variables
are the dependencies (prerequisites) for the rule. So, we could do this.
.P1
.ps -1
.ti -1i
.B
.BX mkfile
.ps +1
.CW
.vs .2i
CC=8c
LD=8l
O=8

OFILES=semfs.$O sem.$O

$O.semfs: $OFILES
	$LD -o $target $prereq
.I "...other rules..."
.P2
.LP
Using these variables, all the rules we are using for compiling a source
file look very similar. Indeed, we can write just a single rule to compile any
source file. It would look as follows
.P1
%.$O: %.c sem.h
	$CC -FVw $stem.c
.P2
.LP
This rule is called a
.I meta-rule .
It defines many rules, one for each thing that matches the
.CW %
character. In our case, it would be like defining a rule for
.CW semfs.$O
and
another for
.CW sem.$O .
.ix "meta-rule
.ix "implicit rule
The rule says that
.I anything
(the
.CW % )
terminated in
.CW $O
can be built from the corresponding file, but terminated in
.CW .c .
The command in the body of the rule uses the variable
.CW $stem ,
.ix [$stem]
which is defined by
.CW mk
to contain the string matching the
.CW %
in each case.
.PP
All this lets you write very compact
.CW mkfiles ,
for compiling your programs. But there is even more help. We can include
files in the
.CW mkfile ,
by using a
.CW <
character. And we can use variables to determine which files to include!
Look at the following file.
.P1
.ps -1
.ti -1i
.B
.BX mkfile
.ps +1
.CW
.vs .2i
</$objtype/mkfile
OFILES=semfs.$O sem.$O

$O.semfs: $OFILES
	$LD -o $target $prereq

%.$O: %.c sem.h
	$CC -FVw $stem.c
.P2
.LP
It includes
.CW /386/mkfile
when
.CW $objtype
is
.CW 386 .
That is our case. The file
.CW /386/mkfile
defines
.CW $CC ,
.CW $LD ,
and other variables to compile for that architecture.
Now, changing the value of
.CW objtype
changes all the tools used to compile, because we would be
including definitions for the new architecture. For example,
.P1
; objtype=arm mk
5c -FVw sem.c
5l -o 5.semfs semfs.5 sem.5
;
.P2
.LP
This way, it is very easy to cross-compile. And that was not all. There are
several
.CW mkfiles
that can be included to define appropriate targets for compiling a single
program and for compiling multiple ones (one per source file). What follows
is once more our
.CW mkfile .
.P1
.ps -1
.ti -1i
.B
.BX mkfile
.ps +1
.CW
.vs .2i
</$objtype/mkfile

OFILES=semfs.$O sem.$O
HFILES=sem.h
TARG=$O.semfs
BIN=$home/bin/$objtype

</sys/src/cmd/mkone
.P2
.LP
The file
.CW mkone
.ix [$objtype]
.ix [mkone]
defines targets for building our program. It assumes that the variable
.CW OFILES
lists the object files that are part of the program. Also, it assumes that
the variable
.CW HFILES
lists the headers (which are dependencies for all the objects). Each object
is assumed to come from a C file with the same name (but different extension).
The variable
.CW BIN
names the directory where to copy the resulting target to install it, and the
variable
.CW TARG
.ix [OFILES]
.ix [HFILES]
.ix [BIN]
.ix [TARG]
names the target to be built.
Now we can do much more than just compiling our program, there are
several useful targets defined by
.CW mkone .
.P1
; mk
8c -FVw semfs.c
8c -FVw sem.c
8l  -o 8.out semfs.8 sem.8
; mk install
cp 8.out /usr/nemo/bin/386/8.semfs
; mk clean
rm -f *.[578qv] [578qv].out y.tab.?
rm -f y.debug y.output 8.semfs $CLEANFILES
.P2
.LP
As before, changing
.CW $objtype
changes the target we would be compiling for.
.PP
It might seem confusing that
.CW install
and
.CW clean
were used as targets. They are not files. That point is that targets do not need
to be files. A target may be a virtual thing, invented by you, just to ask
.CW mk
to do something. For example, this might be the rule for
.CW install .
.ix "[mk] install
.P1
install:V: $O.semfs
	cp $O.semfs $BIN
.P2
The rule is declared as a
.I virtual
target, using the
.CW :V:
in the header for the rule. This means that
.CW mk
will consider
.CW install
to be something that is not a file and is never up to date. Each time we
build the target
.CW install ,
.CW mk
would execute the body for the rule. That is how
.CW mkone
could define targets for doing other things.
.PP
One final advice. This tool can be used to build anything, and not just binaries.
For example, the following is an excerpt of the
.CW mkfile
used to build a PDF file for this book.
.P1
CHAPTERS=`{echo ch?.ms ch??.ms}
PROGRAMS=`{echo src/*.ms}
.I ...
%.ps:%.ms
	eval `{doctype $stem.ms} | lp -d stdout > $stem.ps
.P2
.LP
We defined variables to contain the source files for chapters (named
.CW ch*.ms ),
and for formatted text for programs. These were used by rules not shown here,
but you can still see how the shell can be combined with
.CW mk
to yield a very powerful tool. The
.I meta-rule
that follows, describes how to compile the source for chapters (or any other
document formatted using
.I troff )
to obtain a postscript file.
.PP
The program
.CW doctype
prints the shell commands needed to compile a
.I troff
.ix [troff]
document, and the
.CW eval
shell built-in executes the string given as an argument as if it was typed, to evaluate
environment variables or other artifacts printed by
.CW doctype .
.ix [doctype]
Again, this is just an example. If it seems confusing, experiment with the building
blocks that you have just seen. Try to use them separately, and try to combine them
to do things. That is what Plan 9 (and UNIX!) is about.
.PP
There are several other features, described in the
.I mk (1)
manual page, that we omit. What has been said is enough to let you use this tool.
For a full description, [.maintaining files mk.] is a good paper to read.
.BS 2 "Debugging and testing
.PP
.ix "debugging
.ix "testing
Having executed our program a couple of times is not enough to say that
.CW semfs
is reliable enough to be used. At the very least, it should be used for some time
besides being tested. Also, some tools available in Plan 9 may help to detect
common problems. Reading a book that addresses this topic may also help
[.practice programming.].
.PP
To test the program, we might think on some tests to try to force it to the limit
and see if it crashes. Which tests to perform heavily depend on the program being
tested. In any case, the shell can help us to test this program.
.PP
The idea is to try to use our program and then check if it behaved correctly. To
do this, we can see if the files served behave as they should. At least, we could
do this for some simple things. For example,
if the file system is correct, it must at least allow us to create semaphores
and to remove them. So, executing
.P1
; 8.semfs
; for (i in `{seq 1 100}) { echo 1 >/mnt/sem/$i }
.P2
.LP
should always leave
.CW /mnt/sem
with the same files. One hundred of semaphore files with names
.CW 1 ,
.CW 2 ,
etc., up to
.CW 100 .
This means that executing
.P1
; for (i in `{seq 1 100}) { echo 1 >/mnt/sem/$i }
; ls /mnt/sem
.P2
should always produce the same output, if the program is correct. In the same way,
if semaphores behave correctly, the following will not block, and the size for
the semaphore file after the loop should be zero. Thus, the following is also
a program that should always produce the same output if the file system is correct.
.P1
; echo 4 >/mnt/sem/mutex
; for (i in `{seq 1 4}) { read </mnt/sem/mutex }
; if (test -s /mnt/sem/mutex)
;; 	echo not zero sized
;
.P2
.LP
.ix "program checking
For all these checks we can think of how to perform them in a way that they always
produce the same output (as long as the program is correct). The first time we
run a check, we check the output by hand and determine if it seems correct. If that
is the case, we may record the output for later. For example, suppose the first
check above is contained in the script
.CW chk100.rc  ,
and the last check is contained in the script
.CW chkdowns.rc  .
We could proceed as follows.
.P1
; 8.semfs
; chk100.rc >chk100.rc.out
.I "..inspect chk1.out to see if it looks ok, and proceed...."
; chkdowns.rc >chkdowns.rc.out
.I "...do the same for this new check...
.P2
.LP
Now, if we make a change to the program and want to check a little bit if
we broke something, we can use the shell to run our tests again, and compare
their output with previous runs. This is called
.B "regression testing" .
That is, testing one program by looking at the output of previous versions for the
same program.
.P1
; for (chk in chk*.rc) {
;;	cmp <{$chk} $chk.out || echo check $chk failed
;;	}
.P2
.LP
This loop could perhaps be included in a rule for the target
.CW check
in our
.CW mkfile ,
.ix [mkfile]
so that typing
.P1
; mk check
.P2
suffices.
.PP
What we said does not teach how to test a program, nor tries to. We tried
to show how to combine the shell and other tools to help you in testing
your programs. That is part of development and Plan 9 helps a lot in that
respect.
.PP
There are many other things that you could check about your program.
For example, listing
.CW /proc/$pid/fd
for the program should perhaps show the same number of file descriptors for
the same cases. That would let you know if a change you make leaks any file
descriptor (by leaving it open). The same could be done by looking into memory
usage and alerting about huge increases of memory.
.PP
There are other tools to help you optimize your programs, including
a profiler that reports where the program spends time, and several tools for
drawing graphics and charts to let you see if changes improve or not the time
spent by the program (or the memory) for different usages. All of them are
described in the manual. Describing them here would require many more space,
and there are good books that focus just on that topic.
.PP
To conclude with this notes about how to check your program once it has
been executed a couple of times, we must mention the
.CW leak
.ix "memory leak
.ix "[leak]
.ix "[malloc]
.ix "[acid]
tool. This tool helps a lot to find memory leaks, a very common type of
error while programming. A memory leak is simply memory that you have
allocated (using
.CW malloc
or a routine that calls
.CW malloc)
but not released.
This tool uses the debugger (with some help from the library implementing
dynamic memory) to detect any such leak. For example,
.P1
; leak -s page
leak -s 1868 1916 1917 1918
.P2
tries to find memory leaks for the process running
.CW page .
.ix [page]
The program prints a command that can be executed to scan the
different processes for that program for memory leaks. Executing such
command looks like follows:
.P1
; leak -s page|rc
;
.P2
.LP
There was no output, which meant that there seems to be no memory leaks.
However, doing the same for a program called
.CW omero ,
reported some memory leaks.
.P1
; leak -s omero|rc
src(0x0000dd77); // 7
src(0x000206a8); // 3
src(0x000213bc); // 3
src(0x00027e68); // 3
src(0x00027fe7); // 2
src(0x00002666); // 1
src(0x0000c6ff); // 1
.P2
.LP
Each line can be used as a command for the debugger to find the line where
the memory (leaked) was allocated. Using
.P1
; src -s 0x0000dd77 omero
.P2
would point our editor to the offending source line that leaked 7 times some
memory, as reported by the first line in the output of
.CW leak .
Once we know where the memory
was allocated, we may be able to discover which call to
.CW free
is missing, and fix the program.
.SH
Problems
.IP 1
Convert the printer spooler program from a previous problem into a file server.
.ds CH
.bp
 .
.bp
 
