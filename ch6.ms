.so tmacs
.BC 6 "Networking
.BS 2 "Network connections
.LP
.ix "network connection
Plan 9 is a distributed system. But even if it was as its ancestor, UNIX, a
.ix "distributed system
.ix "UNIX
centralized system that was designed just for one machine, it is very important
to be able to use the network to provide services for other machines and to use
.ix "computer network
.ix "network services
services from others. All the operating systems that are in use today provide
abstractions similar to the one whose interface is described here, to let you use
the network.
.PP
This chapter may be hard to understand if you have not
attended a computer networks course, but we try to do our best to explain
how to use the network in any case. All the programs you have used to
browse the Web, exchange electronic mail, etc. are implemented using
.ix mail
.ix web
interfaces that are similar to the ones described below (they use to be
more complex, though).
.PP
In general, things work as for any other service provided by the operating system.
First, the system provides some abstraction for using the network. As we will be
seeing, Plan 9 uses also the file abstraction as its primary interface for using
networks. Of course, files used to represent a network have a special meaning,
i.e., behave in a particular way, but they are still used like files. Other operating
systems use a whole bunch of extra system calls instead, to provide the
interface for their network abstraction. Nevertheless, the ideas, and the programmatic
interface that we will see, are very similar.
.PP
Upon such system-provided abstraction, library functions may provide a more convenient
.ix library
interface for the application programmer. And of course, in the end, there are many
programs already installed in the system that, using these libraries, provide some
services for the user.
.PP
A network in Plan 9 is a set of devices that provide the ability to talk with
.ix "network device
other machines using some physical medium (e.g, some type of wire or the air
for radio communication).
.PP
A network device in Plan 9 may be an actual piece of hardware, but it can also be
a piece of software used to speak some protocol. For example,
most likely, your PC includes an ethernet card. It uses an RJ45 connector to plug
.ix RJ45
.ix ethernet
your computer to an ethernet network (just some type of cabling and conventions).
The interface for the ethernet device in Plan 9 is just a file tree, most likely
found at
.ix "[/net] file~system
.ix [ether0]
.CW /net/ether0
.P1
; !!lc /net/ether0
0	1	2	addr	clone	ifstats	stats
.P2
.LP
Machines attached to the wire have addresses, used by the network hardware to
.ix "network address
identify different machines attached to the wire. Networks using wireless communication
are similar, but use the air as their “wire”. We can use the file interface provided by Plan 9
for our ethernet device to find out which one is its address:
.P1
; cat /net/ether0/addr
000c292839fc; 
.P2
.LP
As you imagine, this file is just an interface for using your ethernet device, in this
case, for asking for its address.
.PP
Once you have the hardware (e.g., the ethernet card) for exchanging messages
with other machines attached to the same medium (wiring or air),
your machine and exchange bytes with them. The problem remains of how to send messages
to any machine in the Internet, even if it is not attached to the same wire your machine is attached at.
One protocol very important to the Internet, IP (Internet
.ix "internet protocol
.ix IP
Protocol), is provided in Plan 9 by a device driver called IP.
This protocol is called a network protocol because it
gives an address to each machine in the Internet,
its IP-address, and it knows how to reach any machine, given its address. The interface for the IP
network in Plan 9 is similar to the one we saw
for Ethernet:
.P1
; lc /net/ipifc
0	1	clone	stats
.P2
.ix [/net/ipifc]
.LP
This is not yet enough for communicating with programs across the internet.
Using IP, you may talk to one machine (and IP cares about how to reach that
machine through the many different wires and machines you need to cross).
But you need to be able to talk to one
.I process .
.ix protocol
This is achieved by using another protocol, built upon the network protocol.
This kind of protocol gives
addresses for “mailboxes” within each machine, called
.I ports .
.ix "network port
Therefore, an address for
this protocol is a combination of a machine address (used to reach that
machine through the underlying network protocol) and a
.I port
number.
.ix "port number
.PP
In few words, the network protocol gives addresses for each machine and knows
how to exchange messages between machines. Today, you are going to use IP
as your network protocol. The transport protocol gives port numbers for
processes to use, and knows how to deliver messages to a particular port at
a particular machine. Think of the network address as the address for a building,
and the port number as the number for a mailbox in the building.
.PP
Some transport protocols provide an abstraction similar to the postal service.
.ix "transport protocol
They deliver individual messages that
may arrive out of order and may even get lost in the way. Each such message is
called a
.I datagram ,
.ix datagram
which is the abstraction provided by this kind of transport. In the Internet, the
datagram service is usually UDP. The IP device driver in Plan 9 provides an interface
.ix UDP
for using UDP, similar to the ones we saw for other protocols and network devices:
.P1
; lc /net/udp
0	1	clone	stats
.P2
.LP
Other transports use the ability to send individual messages to build a more
convenient abstraction for maintaining dialogs, similar to a pipe. This abstraction
is called a
.B connection .
.ix "network connection
.ix pipe
It is similar to a pipe, but differs from it in that it
can go from one port at one machine to another port at a different machine
in the network. This type of communication is similar to a phone call. Each end
has an address (a phone number), they must establish a connection
(dial a number, pickup the phone), then they can
speak to each other, and finally, they hangup. The analogy cannot be pushed too far,
for example, a connection may be established if both ends call each other, which would
not be feasible when making a phone call. But you get the idea. In the Internet, the most
popular protocol that provides connections is TCP, it provides them using IP as the
underlying transport protocol (hence the name TCP/IP for this suite of protocols).
The IP device driver
in Plan 9 provides the interface for using TCP. It has the now familiar file interface for using
a network in Plan 9:
.P1
; lc /net/tcp
0	11	14	17	2	22	stats
1	12	15	18	20	23	26
10	13	16	19	21	24	clone
.P2
.LP
Each network is represented in Plan 9 as a directory, that has at least one
.CW clone
.ix "[clone] file
file, and several other directories, called
.I line
.ix "line directory
directories. Opening the
.CW clone
file reserves a new connection, and creates a directory that represents the
interface for the new
.I line
used to establish a connection. Line directories are
named with a number, and kept within the directory for the network. For example,
.CW /net/tcp/14
is the interface for our TCP connection number 14. It doesn't need to be a fully
established connection, it may be in the process of getting established. But in any
case, the directory represents what can be a particular, individual, TCP connection.
The program that opens
.CW clone
may read this file to discover the number assigned to the line directory just created.
.PP
As shown in figure [[!network interface!]], for each connection Plan 9 provides at least a
.CW ctl
.ix "network [ctl]~file
file and a
.CW data
.ix "network [data] file
file. For example,
.P1
; lc /net/tcp/14
ctl	data	err	listen	local	remote	status
.P2
.LS
.PS 5i
circlerad=.15
define con {
[ down
	L: circle invis $1
	move
	[ right ; C: circle invis "ctl" ; move ; D: circle invis "data" ]
	arrow from L to last [].C chop
	arrow from L to last [].D chop
]
}

down
T: circle invis "/net/tcp" above
move
L: [
	right
	C: [ down
		C: circle invis "clone"
		move
		circle invis
	]
	L0: con("0") ; move ; L1: con("1") ; move ; L2: con("2")
	move ; "..." ; move ; Ln: con("n");
]
arrow from T to L.C.n chop
arrow from T to L.L0.n chop
arrow from T to L.L1.n chop
arrow from T to L.L2.n chop
arrow from T to L.Ln.n chop
.PE
.LE F The file interface for a network (protocol) in Plan 9. 
.LP
The file ctl can be used to perform control operations to the connection. For
example, to hangup (break) this connection, we can just
.ix "connection hangup
.P1
; echo hangup >/net/tcp/14
.P2
.LP
The
.CW data
file
is used to send and receive bytes through the connection. It can be used
very much like one end of a pipe. Writing to
the data file  delivers bytes through the connection that
are to be received at the other end.
Reading from the data file retrieves bytes sent
from the process writing at the other end. Just like a pipe.
Only that, if a transport provides datagrams,
each write to a
.CW data
file will send a different datagram, and it may arrive out of order or get lost.
.PP
There are more differences. An important one is that many transport protocols,
including TCP, do not respect message boundaries. This means that data sent
.ix "write boundaries
.ix "message delimiters
through a connection by several writes may be received at the other end by
a single read. If your program has to receive messages from a network connection,
it must know how much to read for each message. A single call to read may
return either part of a message or perhaps more than one message.
.PP
In the line directory for our TCP connection, the
.CW local
.ix "[local] file
file has the local address (including the port number) for the connection. This
identifies the local end of the
.I pipe .
The
.CW remote
.ix "[remote] file
file serves the same purpose for the other end of the connection.
.PP
A network address in Plan 9 is a string that specifies the network (e.g., the
.ix "network address
protocol) to use, the machine address, and the port number. For example,
.CW tcp!193.147.81.86!564
is a network address that says: Using the TCP protocol, the machine address
is 193.147.81.86, and the port number is 564. Fortunately, in most cases, we may
use names as well. For example, the address
.CW tcp!whale!9fs
.ix [whale]
is equivalent to the previous one, but uses the machine name,
.CW whale ,
and the service name,
.CW 9fs ,
.ix [9fs]
instead of the raw addresses understood by the network software.
Often, ports are used by programs to provide services to other programs in the
network. As a result, a port name is also known as a
.ix "service name
.B "service
name.
.PP
From the shell, it is very easy to create connections. The
.CW srv
.ix [srv]
program dials a network address and, once it has established a connection
to that address, posts a file descriptor for the connection at
.CW /srv .
.ix [/srv]
This descriptor comes from opening the
.CW data
file in the directory for the connection, but you may even forget this. Therefore,
.P1
; srv tcp!whale!9fs
post...
.P2
.LP
posts at
.CW /srv/tcp!whale!9fs
a file descriptor that corresponds to an open network connection from this
machine to the port named
.CW 9fs
at the machine known as
.CW whale ,
in the network speaking the protocol
.CW tcp .
.PP
To connect to the web server for LSUB, we may just
.P1
; srv tcp!lsub.org!http
post...
.P2
.LP
Here,
.CW tcp
is just a shorthand for
.CW /net/tcp ,
which is the real (file) name for such network in Plan 9.
Now we can see that
.ix HTTP
.CW /srv/tcp!lsub.org!http
is indeed a connection to the web server at
.CW lsub.org
by writing an HTTP request to this file and reading the server's reply.
.P1
.ps -2
; echo GET /index.html  >>/srv/tcp!lsub.org!http	\fIGet the main web page\fP
; cat /srv/tcp!lsub.org!http
<html>
<head>
<title> Laboratorio de Sistemas --- ls </title> 
<link rev="made" href="mailto:ls@plan9.escet.urjc.es">
</head> 
<body  BGCOLOR=white>
<h1>   ls --- Laboratorio de Sistemas [ubicuos] del GSyC  </h1>
.I "...and more output omitted here...
;
.ps +2
.P2
.LP
If we try to do the same again, it will not work, because the web server hangs up the
connection after attending a request:
.P1
; echo GET / >>/srv/tcp!lsub.org!http
; cat /srv/tcp!lsub.org!http
cat: error reading /srv/tcp!lsub.org!http: Hangup
; echo GET / >>/srv/tcp!lsub.org!http
echo: write error: Hangup
.P2
.LP
And, as you can see, it takes some time for our machine to notice. The first write
seemed to succeed. Our machine was trying to send the string
.CW GET ...
to the web server, but it couldn't really send it. The connection was closed and
declared as hung up. Any further attempt to use it will be futile. What remains is to
remove the file from
.CW /srv .
.P1
; rm /srv/tcp!lsub.org!http
.P2
.LP
There is a very popular command named
.CW telnet ,
that can be used to connect to servers in the Internet and talk to them. It uses
the, so called,
.I "telnet protocol" .
.ix [telnet]
.ix "telnet protocol
But in few words, it dials an address, and thereafter
it sends text from your console to the remote process at
the other end of the connection, and writes to your console the text received.
For example, this command connects to the e-mail server running at
.CW lsub.org ,
and we use our console to ask this server for help:
.P1
; telnet -r tcp!lsub.org!smtp
connected to tcp!lsub.org!smtp on /net/tcp/52
220 lsub.org SMTP
!!help
250 Read rfc821 and stop wasting my time
\fBDelete\fP
.P2
.LP
We gave the option
.CW -r
to
.CW telnet ,
.ix "[telnet] flag~[-r]
to ask it not to print
.I carriage-return
.ix "carriage return
characters (its protocol uses the same convention for new lines used by DOS).
When telnet connected to the address we gave, it printed a diagnostic message
to let us know, and entered a loop to send the text we type, and to print the text
it receives from the other end. Our mail server wrote a salutation through the
connection (the line starting \f(CW220\fP...), and then we typed
.CW help ,
which put our mail server into a bad mood. We interrupted this program
by hitting
.I Delete
in the terminal, and the connection was terminated when
.CW telnet
died. A somewhat abrupt termination.
.PP
It is interesting to open several windows, and connect from all of them to the
same address. Try it. Do you see how
.I each
.CW telnet
is using its own connection? Or, to put it another way, all the connections have
the
.I same
address for the other end of the connection, yet they are
.I different
connections.
.PP
To name a connection, it does not suffice to name the address for one of its ends.
You
.I must
give both addresses (for the two ends) to identify a connection. It is the four
identifiers local address, local port, remote address, and remote port, what
makes a connection unique.
.ix "network address
.ix "port number
.PP
It is very important to understand this clearly. For example, in our
.CW telnet
example, you cannot know which connection are you talking about just
by saying “The connection to  \f(CWtcp!lsub.org!smtp\fP”. There can be a
dozen of such connections, all different, that happen to reach that particular
address. They would differ in the addresses for their other extremes.
.BS 2 "Names
.LP
.ix 
Above, we have been using names for machines and services (ports). However, these
names must be translated into addresses that the network software could understand.
For example, the machine name
.CW whale
must be translated to an IP address like
.CW 193.147.81.86 .
The network protocol (IP in Internet) knows nothing about names. It knows about machine
.ix "network protocol
addresses. In the same way, the transport protocol TCP knows nothing about the
service with name
.CW http .
But it does know how to reach the port number
.CW 80 ,
which is the one that corresponds to the HTTP service.
.ix "name translation
.ix "service name
.PP
Translating names into addresses (including machine and service names) is done in a
different way for each kind of network. For example, the Internet has a name service known
as DNS
.ix DNS
(domain name service) that knows how to translate from a name like
.CW whale.lsub.org
into an IP address and vice-versa.
Besides, for some machines and services there may be names that exist only within a
particular organization.
Your local system administrator may have assigned names to machines that work only
from within your department or laboratory. In any case, all the information about names,
addresses, and how to reach the Internet DNS is kept in a (textual) database known as the
.I "network database" ,
.ix "network database
.ix [ndb]
or just
.CW ndb .
For example, this is the entry in our
.CW /lib/ndb/local
file for
.CW whale :
.P1
dom=whale.lsub.org ip=193.147.81.86 sys=whale
.P2
.LP
When we used
.CW whale
in the examples above, that name was translated into
.CW 193.147.81.86
and that was the address used. Also, this is the entry in our
.CW /lib/ndb/common
file for the service known as
.CW 9fs
when using the TCP protocol:
.P1
tcp=9fs port=564
.P2
.LP
When we used the service name
.ix [9fs]
.CW 9fs ,
this name was translated into the port number
.CW 564 ,
that was the port number used. As a result, the address
.CW tcp!whale!9fs
was translated into
.CW tcp!193.147.81.86!564
and this was used instead. Names are for humans, but (sadly) the actual network
software prefers to use addresses.
.PP
All this is encapsulated into a program that
does the translation by itself, relieving from the burden to all other programs.
This program is known as the
.I "connection server" ,
.ix "connection server
.ix [ndb/cs]
or
.CW cs .
We can query the connection server to know which address will indeed be used
when we write a particular network address. The program
.CW csquery
.ix [csquery]
.ix [ndb/csquery]
does this. It is collected at
.CW /bin/ndb
along with other programs that operate with the network data base.
.P1
; ndb/csquery
> tcp!whale!9fs
/net/tcp/clone 193.147.81.86!564
>
.P2
.LP
The “\f(CW>\fP” sign is the prompt from
.CW csquery ,
it suggests that we can type an address asking for its translation. As you can
see, the connection server replied by giving the path for the
.CW clone
file that can be used to create a new TCP connection,
and the address as understood by TCP that corresponds to the one we typed.
No one else has to care about which particular network, address, or port number
corresponds to a network address.
.PP
All the information regarding the connections in use at your machine can be
obtained by looking at the files below
.CW /net .
Nevertheless, the program
.CW netstat
.ix [netstat]
.ix "network status
provides a convenient way for obtaining statistics about what is happening
with the network. For example, this is what is happening now at my system:
.P1
.ps -2
; netstat
tcp  0    nemo       Listen       audio      0          ::
tcp  1               Established  5757       9fs        whale.lsub.org
tcp  2    nemo       Established  5765       ads        whale.lsub.org
tcp  3    nemo       Established  5759       9fs        whale.lsub.org
tcp  4    nemo       Listen       what       0          ::
tcp  5    nemo       Established  5761       ads        whale.lsub.org
tcp  6    nemo       Established  5766       ads        whale.lsub.org
tcp  7    nemo       Established  5763       9fs        whale.lsub.org
tcp  8    nemo       Listen       kbd        0          ::
.I "...many other lines of output for tcp...
udp  0    network    Closed       0          0          ::
udp  1    network    Closed       0          0          ::
.ps +2
.P2
.LP
Each line of output shows information for a particular line directory. For
example, the TCP connection number 1 (i.e., that in
.CW /net/tcp/1 )
is established. Therefore, it is probably being used to exchange data. The
local end for the connection is at port 5757, and the remote end for
the connection is the port for service
.CW 9fs
at the machine with name
.CW whale.lsub.org .
This is a connection used by the local machine to access the 9P file
server at
.CW whale .
It is being used to access our main file server from the terminal where
I executed
.CW netstat .
The states for a connection may depend on the particular protocol, and we
do not discuss them here.
.PP
In some cases, there may be problems to reach the name service for
the Internet (our DNS server), and it is very useful to call
.CW netstat
with the
.CW -n
.ix "[netstat] flag~[-n]
flag, which makes the program print just the addresses, without translating them
into (more readable) names. For example,
.P1
.ps -2
; netstat -n
tcp  0    nemo       Listen       11004      0          ::
tcp  1               Established  5757       564        193.147.71.86
tcp  2    nemo       Established  5765       11010      193.147.71.86
tcp  3    nemo       Established  5759       564        193.147.71.86
tcp  4    nemo       Listen       11003      0          ::
tcp  5    nemo       Established  5761       11010      193.147.71.86
.I "...many other lines of output
.ps +2
.P2
.LP
It is very instructive to compare the time it takes for this program to complete
with, and without using
.CW -n .
.PP
To add yet another tool to your network survival kit, the
.CW ip/ping
.ix [ping]
.ix [ip/ping]
.ix "network connection
program sends particular messages that behave like
probes to a machine (to an IP address, which is for a network
interface found at a machine, indeed), and prints one line for each probe
reporting what happen.  It is very useful because it lets you know
if a particular machine seems to be alive. If it replies to a probe, the machine
is alive, no doubt. If the machine does not reply to any of the probes, it might be
either dead, or disconnected from the network. Or perhaps, it is your machine the one
disconnected. If only some probes get replied, you are likely to have bad connectivity
(your network is losing too many packets). Here is an example.
.P1
; ip/ping lsub.org
sending 32 64 byte messages 1000 ms apart
0: rtt 152 µs, avg rtt 152 µs, ttl = 255
1: rtt 151 µs, avg rtt 151 µs, ttl = 255
2: rtt 149 µs, avg rtt 150 µs, ttl = 255
.I ...
.P2
.LP
In the output,
.CW rtt
is for
.I "round trip time" ,
.ix "round~trip time
.ix "RTT
the time for getting in touch and receiving the reply.
.BS 2 "Making calls
.LP
.ix "making calls 
For using the network from a C program, there is a simple library that 
provides a more convenient interface that the one provided by the
file system from the network device. For example, this is our simplified version
for
.CW srv .
It dials a given network address to establish a connection and posts a file descriptor
for the open connection at
.CW /srv .
.ix [srv.c]
.ix "dialing
.so progs/srv.c.ms
.LP
Using
.CW argv[1]
verbatim as the network address to dial, would make the program work only when
given a complete address. Including the network name and the service name. Like,
for example,
.P1
; 8.srv tcp!whale!9fs
.P2
.LP
Instead, the program calls
.CW netmkaddr
.ix "[netmkaddr]
.ix "address construction
which is a standard Plan 9 function that may take an address with just the machine
name, or perhaps the network name and the machine name. This function completes
the address using default values for the network and the service, and returns a
full address ready to use. We make
.CW tcp
the default value for the network (protocol) and
.CW 9fs
as the default value for the service name. Therefore, the program
admits any of the following, with the same effect that the previous invocation:
.P1
; 8.srv tcp!whale
; 8.srv whale
.P2
.LP
The actual work is done by
.CW dial .
.ix [dial]
This function dials the given address and returns an open file descriptor for
the connection's data file. A write to this descriptor sends bytes through the
connection, and a read can be used to receive bytes from it. The function
is used in the same way for both datagram protocols and connection-oriented
protocols. The connection will be open as long as the file descriptor returned
remains open.
.P1
.ps -1
; sig dial
	int dial(char *addr, char *local, char *dir, int *cfdp)
.ps +1
.P2
.LP
The parameter
.CW local
permits specifying the local address (for network protocols that allow doing
.ix "local address
so). In most cases, given
.CW nil
suffices, and the network will choose a suitable (unused) local port for the
connection. When
.CW dir
is not nil, it
is used by the function as a buffer to copy the path for the line directory representing
the connection. The buffer must be at least 40 bytes long. We changed the previous
program to do print the path for the line directory used for the connection:
.P1
fd = dial(addr, nil, dir, nil);
if (fd < 0)
	sysfatal("dial: %s: %r", addr);
print("dial: %s\n", dir);
.P2
.LP
And this is what it said:
.P1
; 8.srv tcp!whale!9fs
dial: /net/tcp/24
.P2
.LP
The last parameter for dial,
.CW cfdp
.ix "connection [ctl]~file
points to an integer which, when passing a non-nil value, can be used to
obtain an open file descriptor for the connection. In this case, the caller is
responsible for closing this descriptor when appropriate. This can be used
to write to the control file requests to tune properties for the connection, but
is usually unnecessary.
.PP
There is a lot of useful information that we may obtain about a connection
by calling
.CW getnetconninfo .
.ix [getnetconninfo]
.ix "network connection information
This function returns nothing that could not be obtained by reading files
from files in the line directory of the connection, but it is a very nice wrap
that makes things more convenient. In general, this is most useful in
servers, to obtain information to try to identify the other end of the
connection, (i.e., the client). However, because it is much easier to make
a call than it is to receive one, we prefer to show this functionality here instead.
.PP
Parameters for
.CW netconninfo
are the path for a line directory, and one of the descriptors for either a control
or a data file in the directory. When nil is given as a path, the function uses the
file descriptor to locate the directory, and read all the information to be returned
to the caller. The function allocates memory for a
.CW NetConnInfo
.ix [NetConnInfo]
structure, fills it with relevant data, and returns a pointer to it
.P1
typedef struct NetConnInfo NetConnInfo;
struct NetConnInfo
{
	char	*dir;		/* connection directory */
	char	*root;		/* network root */
	char	*spec;		/* binding spec */
	char	*lsys;		/* local system */
	char	*lserv;		/* local service */
	char	*rsys;		/* remote system */
	char	*rserv;		/* remote service */
	char	*laddr;		/* local address */
	char	*raddr;		/* remote address */
};
.P2
.LP
This structure must be released by a call to
.CW freenetconninfo
.ix [freenetconninfo]
once it is no longer necessary.
As an example, this program dials the address given as a parameter, and
prints all the information returned by
.CW getnetconninfo .
Its output for dialing
.CW tcp!whale!9fs
follows.
.ix [conninfo.c]
.so progs/conninfo.c.ms
.P1
; 8.out tcp!whale!9fs
dir:	/net/tcp/46
root:	/net
spec:	#I0
lsys:	212.128.4.124
lserv:	6672
rsys:	193.147.71.86
rserv:	564
laddr:	tcp!212.128.4.124!6672
raddr:	tcp!193.147.71.86!564
.P2
.LP
The line directory for this connection was
.CW /net/tcp/46 ,
which belongs to the network interface at
.CW /net .
This connection was using
.CW #I0 ,
which is the first IP interface for the machine.
The remaining output should be easy to understand, given the
declaration of the structure above, and the example output shown.
.BS 2 "Providing services
.LP
.ix "providing services
.ix "server
.ix client
We know how to connect to processes in the network that may be providing
a particular service. However, it remains to be seen how to provide a service.
In what follows, we are going to implement an echo server. A client for this
program would be
another process connecting to this service to obtain an
.I "echo service" .
This program provides the service (i.e., provides the echo) and is therefore
a
.I server .
The echo service, surprisingly enough, consists on doing echo of what a client
writes. When the echo program reads something, writes it back through the same
connection, like a proper echo.
.PP
The first thing needed is to
.B announce
.ix [announce]
.ix "port announce
the new service to the system. Think about it. To allow other processes to
.I connect
to our process, it needs a port for itself. This is like allocating a “mailbox” in the
“building” to be able to receive mail. The function
.CW announce
receives a network address and announces it as an existing place where others
may send messages. For example,
.P1
announce("tcp!alboran!echo", dir);
.P2
would allocate the TCP port for the service named
.CW echo
and the machine named
.CW alboran .
This makes sense only when executed in that machine, because the port being
created is an abstraction for getting in touch with a local process. To say it
in another way, the address given to announce must be a local address.
.ix "network port creation
It is a better idea to use
.P1
announce("tcp!*!echo", dir);
.P2
.LP
instead. The special machine name “\f(CW*\fP” refers to any local address for
our machine. This call reserves the port
.CW echo
for any interface used by our machine (not just for the one named
.CW alboran ).
Besides, this call to
.CW announce
now works when used at any machine, no matter its name.
.ix "service name"
.PP
This function returns an open file descriptor to the
.CW ctl
file of the line directory used to announce the port.
The second parameter is updated with the path for the directory.
Note that this line directory is an artifact which, although has the same interface,
is
.I not
a connection. It is used just to maintain the reservation for the port and to prepare
for receiving incoming calls. When the port obtained by a call to
.CW announce
is no longer necessary, we can close the file descriptor for the
.CW ctl
file that it returns, and the port will be released.
.PP
This program announces the port 9988, and sleeps forever to let us inspect what happen.
.so progs/ann.c.ms
.LP
We may now do this
.P1
; 8.ann &
; announced in /net/tcp/52	\fI We typed return here, to let you see\fP
; netstat | grep 9988
tcp  52   nemo       Listen       9988       0          ::
.P2
.LP
.ix [netstat]
According to
.CW netstat ,
the TCP port number 9988 is listening for incoming calls. Note how the path printed by
our program corresponds to the TCP line number 52.
.PP
Now let's try to run the program again, without killing the previous process.
.P1
; 8.out
announce: announce writing /net/tcp: address in use
.P2
It fails! Of course, there is another process already using the TCP port number 9988.
This new process cannot announce that port number again. It will be able to do so
only when nobody else is using it:
.P1
; kill 8.ann|rc
; 8.ann &
; announced in /net/tcp/52
.P2
.LP
Our program must now await for an incoming call, and accept it, before it could exchange
data with the process at the other end of the connection. To wait for the next call, you
may use
.CW listen .
.ix [listen]
This name is perhaps misleading because, as you could see, after
.CW announce ,
the TCP line is already listening for calls. Listen needs to know the line where it must
wait for the call, and therefore it receives the directory for a previous announce.
.PP
Now comes an important point, to leave the line listening while we are attending
a call, calls are attended at a
.I different
line than the one used to listen for them. This is like an automatic transfer of a
call to another phone line, to leave the original line undisturbed and ready for a next
call. So,
after
.CW listen
.ix "line directory
has received a call, it obtains a new line directory for the call and returns it. In particular,
it returns an open file descriptor for its
.CW ctl
file and its path.
.PP
We have modified our program to wait for a single call. This is the result.
.ix [listen.c]
.so progs/listen.c.ms
.LP
When we run it, it waits until a call is received:
.P1
; 8.listen
announced in /net/tcp/52 (cfd=10)
.P2
.LP
At this point, we can open a new window and run
.CW telnet
to connect to this address
.P1
; telnet tcp!$sysname!9988
connected to tcp!alboran!9988 on /net/tcp/46
.P2
.LP
.ix "call receiving
.ix "accept connection
which makes our program receive the call:
.P1
attending call in /net/tcp/54 (lfd=11)
.P2
.LP
You can see how there are two lines used. The line number 52
is still listening, and the call received is placed at line 54, where
we might accept it. By the way, the line number 46 is the other
end of the connection.
.PP
Now we can do something useful. If we accept the call by calling
.CW accept ,
.ix [accept]
this function will provide an open file descriptor for the
.CW data
file for the connection, and we can do our echo business.
.so progs/netecho.c.ms
.ix [netecho.c]
.ix "network echo server"
.LP
If we do as before, and use
.CW telnet
to connect to our server and ask for a nice echo, we get the
echo back. After quitting
.CW telnet ,
we can connect again to our server and it attends the new call.
.P1
; telnet -r tcp!$sysname!9988
connected to tcp!alboran!9988 on /net/tcp/46
!!Hi there!
Hi there!
\fBDelete\fP
; telnet -r tcp!$sysname!9988
connected to tcp!alboran!9988 on /net/tcp/54
!!Echo echo...
Echo echo...
\fBDelete\fP
;
.P2
.LP
And this is what our server said in its standard output:
.P1
; 8.netecho
announced tcp!*!9988 in /net/tcp/52
accepted call at /net/tcp/54
terminated call at /net/tcp/54
accepted call at /net/tcp/55
terminated call at /net/tcp/55
.P2
.LP
The program is very simple. To announce our port, wait
for call, and accept it, it has to call just
.CW announce ,
.CW listen ,
and
.CW accept .
At that point, you have an open file descriptor that may
be used as any other one. You just read and write as you
please. When the other end of the connection gets closed,
a reader receives an EOF indication in the conventional way.
This means that connections are used like any other file.
So, you already know how to use them.
.PP
Our program has one problem left to be addressed. When we connected
to it using
.CW telnet ,
there was only one client at a time. For this program, when one client is connected
and using the echo, nobody else is attended. Other processes
might connect, but they will be kept on hold waiting for this process
to call
.CW listen
and
.CW accept.
.ix [listen]
This is what is called a
.B "sequential server" ,
because it attends one client after another.
You can double check this by connecting from two
different windows. Only the first one will be echoing. The echo
for the second to arrive will not be done until you terminate the
first client.
.PP
A sensible thing to do would be to fork a new process for each
client that connects. The parent process may be kept listening,
.ix "client connection
.ix "listen
waiting for a new client. When one arrives, a child may be
spawned to serve it. This is called a
.B "concurrent server" ,
.ix "threaded server"
because it attends multiple clients concurrently.
The resulting code is shown below.
.PP
There are some things to note. An important one is that, as you know,
the child process has a copy of all the file descriptors open in the
parent, by the time of the fork. Also, the parent has the descriptor
open for the new call received after calling
.CW listen ,
even though it is going to be used just by the child process. We close
.CW lfd
in the parent, and
.CW cfd
in the child.
.PP
We might have left
.CW cfd
open in the child, because it would be closed when the child terminates
by calling
.CW exits ,
.ix "connection close
after having received an end of file indication for its connection. But in
any case, it should be clear that the descriptor is open in the child too.
.PP
Another important detail is that the child now calls
.CW exits
after attending its connection, because that was its only purpose in life.
Because this process has (initially) all the open file
descriptors that the parent had, it may be a disaster if the child somehow
terminates attending a client and goes back to call
.CW listen .
Well, it would be disaster because it is
.I not
what you expect when you write the program.
.so progs/cecho.c.ms
.ix [cecho.c]
.BS 2 "System services
.LP
You know that certain machines provide several services. For example,
the machine known as
.CW lsub.org
in the Internet is a Plan 9 system. The machine name is indeed
.CW aquamar ,
but it is registered in DNS as
.CW lsub.org .
This particular machine provides web, mail, and several other services,
including echo!
.P1
; telnet tcp!lsub.org!echo
!!Hi
Hi
\fBDelete\fP
;
.P2
.LP
How can it be? Before reading this book, you might think that the operating
system was arranging for this services to run at that machine. But now
you know that the operating system is doing nothing, but for supplying the
abstractions used to provide such services.
.PP
When this particular machine starts, Plan 9 executes an
.CW rc
.ix boot
script as part of the normal boot process. This script runs the program
.CW aux/listen ,
.ix [aux/listen]
.ix "machine services
.ix "network services
which listens for incoming connections and executes programs to
attend them. The machine provides services because certain programs
are started to attend incoming connections targeted to ports.
.PP
Following the modular design of the rest of the system,
.CW listen
does not even decide which ports are to be listened. This program
looks at the
.CW /rc/bin/service
.ix [/rc/bin/service]
directory, for files with names like
.CW tcp7 ,
.CW tcp25 ,
.ix "TCP echo service
.ix [tcp7]
and so on. Each file corresponds to a service provided by the machine,
and has a name that corresponds to the protocol and port number where
connections for the service may arrive.
.P1
; lc /rc/bin/service
il17007		tcp17007	tcp220		tcp9
il17009		tcp17009	tcp25		tcp993
il17010		tcp17010	tcp53		tcp995
tcp113		tcp17013	tcp565		telcodata
tcp143		tcp19		tcp7
.P2
.LP
For many services, there are conventions
for which ports to use for them in the Internet (you might call it a standard).
For example, TCP
port 7 corresponds to the echo service. And this is how it is implemented in Plan 9:
.P1
; cat /rc/bin/service/tcp7
#!/bin/rc
/bin/cat
;
.P2
.LP
Indeed, each one of the files in the
.CW service
directory is an executable program that implements a service. All that
.CW listen
has to do, is to listen for calls to the ports determined by the file names,
and execute the files to attend each incoming call. Listen arranges for the
standard input and output of the process attending a call to be redirected
to the connection itself. For a service, reading from standard input is reading
from the connection, and writing to standard output is
writing to the connection.
.PP
This is a nice example of how simple things can be. Listen is in charge
.ix "[listen] command
of listening and spawning processes for attending services. The directory
keeps the set of files that corresponds to services. We can use familiar
programs like
.CW lc
to list them! Each service is provided by a separate, independent program.
And everything fits together.
.PP
By the way, there is an important lesson to be learned here. It is much more
simple to use
.CW cat
to implement an echo server than it is to write our own program. If we do not
search the manual and try to see if what we are trying to do is already done,
we get a lot of extra work as a penitence for this sin.
.BS 2 "Distributed computing
.LP
.ix "distributed computing
The time has come to reveal another lie we told.
There are
.I three
kind of machines in a Plan 9 network, not just two. You already know about
terminals and file servers. There are also
.B "CPU servers" .
A CPU server is meant to let the user execute commands on it, in particular,
commands that make intensive use of the processor. Today, with the powerful
machines that we have available, most terminals can cope with anything you might
want to execute on them.
.PP
But CPU servers have found their way in this new world
and are still very useful for running the file server program (which used to be
a different kernel), executing periodic user tasks automatically, and providing
services like Web, mail, and the like.
.ix "mail server
.PP
A CPU server runs the same system software used in a terminal, however,
its kernel is compiled with the variable
.CW cpuserver
set to true, and it behaves slightly differently. The main difference is that
the
.CW boot
.ix [boot]
.ix "boot program
program executes the script
.CW /rc/bin/cpurc
instead of
.CW /rc/bin/termrc
.ix "[termrc]
.ix "machine start script
to initialize the system for operation. You may remember that one of the things
this script does is running
.CW aux/listen
to run several system services upon incoming calls from clients.
.PP
Other systems, most notably UNIX, start most existing system services
.ix UNIX
during the boot process, in a similar way. That is why you can
connect
to a UNIX machine to execute commands on it (e.g., using
.CW telnet
or
.CW ssh ),
but you cannot do the same to your Plan 9 terminal. If you want to
connect to your terminal to use a particular service, you must start that
service first (i.e., run
.CW listen
or its variant that listens just for one service,
.CW listen1 ).
.ix [listen1]
.PP
By the way, if you ever wondered what is the difference between the
different flavors of Windows running on a PC, it is the same. They compiled
the system with different parameters for “optimizing”
the system for different kinds of usage. Also,
they arranged for the system to start different services depending on the
kind of edition.
.PP
The
.CW cpu
.ix "[cpu] command
command makes a connection to a CPU server, using by default that named
by
.CW $cpu ,
.ix "[cpu] variable
as set by your system administrator. The connection is used to run a program
in the CPU server, which is
.CW rc
by default. The net effect is that you can connect to a shell at any CPU server,
and run commands on it. This is an example:
.P1
; echo $sysname
alboran
; cpu
cpu% !!echo $sysname
aquamar
\fBcontrol-d\fP
; echo $sysname
alboran
.P2
.LP
Your
.CW profile ,
executed each time you enter the system, changes the prompt for the shell to advise
you that it is not running at your terminal.
When an initial
shell is started for you at a machine (a CPU server, a terminal, etc.), it executes
your
.CW $home/lib/profile
file. Now, the process that started the shell for you defined a environment
variable to indicate which kind of session you are using. For terminals,
the variable
.CW service
.ix [service] variable
.ix profile
has
.CW terminal
as its value. However, on CPU servers this variable may have
.CW cpu
or
.CW rx
as its value, depending on how you connected to the CPU server.
Your profile may do different things (like adjusting the shell prompt), depending
on
.CW $terminal .
.PP
A more rudimentary alternative is provided, for those cases when you want to
execute just one command at another machine. It is called
.CW rx ,
.ix [rx]
.ix "remote command execution
and accepts a machine name and a command to run on it.
.P1
; rx aquamar 'echo $sysname'
aquamar
;
.P2
.LP
Note how we had to quote the whole command, which is to be executed verbatim
by the remote machine, 
.SH
Problems
.IP 1
Use
.CW /net
to see which networks are available at your terminal.
Determine the local address for your terminal for each one of the networks.
.IP 2
Repeat the second problem of chapter 1 for the terminals in your network.
Use
.CW /lib/ndb/local
to locate other terminals.
.IP 3
Start the echo server implemented in this chapter, and try to hangup its
connection using the shell.
.IP 4
Which processes are listening to the network in your terminal?
What do they do? (use the manual)
.IP 5
Which one is the IP address for
.CW google.com ?
Is the machine alive? Try to determine that in several different ways.
.IP 6
Implement a time of day service. It must return the local time to any client.
Use
.CW telnet
to test it.
.IP 7
Implement a client program for the server from the previous problem.
.IP 8
Print all the information you can determine for all clients connecting to your
time of day server.
.IP 9
Change your server so it could be started using
.CW aux/listen1 .
Test it.
.IP 10
Change your profile to adjust the shell prompt according to the machine
name. It must work both for terminals and connections to CPU servers.
.ds CH
.bp
