.so tmacs
.BC 14 "Security
.BS 2 "Secure systems
.LP 
.ix "security
.ix "secure system
Security is a topic that would require a book on its own. Here we just show
the abstractions and services provided by Plan 9 to secure the computer system.
But in any case you should keep in mind that the only secure system is one
that is powered down (and also kept under a lock!). As long as the system can
perform tasks, there is a risk that some attacker convinces the system to do
something that it should not legitimately do.
.PP
.ix "stand-alone machine
.ix "laptop computer
In general, there is a tradeoff between security and convenience. For example,
a stand-alone Plan 9 machine like a laptop that is not connected to the network
does not ask for a password to let you use it. Thus, any person that gets the
laptop may power it up and use it. However,
you do not have to type a password
to use it, which is more convenient. If, on the contrary,
your laptop requires a password to be used, typing the password would be
an inconvenience. Nevertheless,
you might think that this makes the laptop more secure because
it requires to know a password just to use it.
.PP
.ix "malicious person
.ix "evil
.ix "password
By the way, this is not true because as long as a malicious person has your
laptop in his or her hands, the laptop will be broken into and the only question is
how much time and effort it will require to do so. So, using a password to protect
the laptop would be given a false feeling that the system is secure. Furthermore,
although it is common for laptops that might be used on its own, terminals in
Plan 9 are
.I not
.ix "local storage
supposed to have local storage nor any other local resource to protect! A Plan 9
terminal is just a machine to connect to the rest of services in the network.
.PP
What does
.I security
mean?
It depends. For example, the dump in the file server protects your files
from accidental removals or other errors. At least, it protects them in the sense
that you may still access a copy of the entire file tree, as it was yesterday, even
if you lose today's files. Furthermore, because old files kept in disk will never be
overwritten by the file server once they are in the dump, it is very unlikely that a
bug or a software problem will corrupt them. The dump, like other backup tools,
is preserving the
.B integrity
of your data (of your files). This is also part of the security provided by the computing
system. In any case, it is common to understand security in a computer as the
feature that prevents both
.ix "authorized access
.IP 1
unauthorized use of the system (e.g., running programs), and
.IP 2
unauthorized access to data in the system (e.g., reading or modifying files).
.LP
We will focus on security understood in this way, that is, as something to
determine who can do which operations to which objects in the system.
But keep in mind that security is a much wider subject.
.PP
We have already seen several abstractions that have to do with security, understood
this way. First, the persons who can perform actions on things in the computer system
are represented by
.B users .
.ix user
A user is represented in the system by a user name, as you saw. Users rely on
networked
.B machines
or systems to do things in the computing system. 
Machines execute programs. Indeed, the only way for a user to do something on a
machine is to execute a program (or to use one already running).
Protecting the system to permit using it only to
authorized users means just protecting machines so that only authorized users
may convince already
running processes to do things for them. Things like, for example,
running new programs and reading and writing files.
.ix "server process
.PP
In Plan 9, some of the machines are terminals for the users. Other machines
are CPU servers that accept connections from other machines to execute
commands on them. Also, you have one or more file servers, that are machines
whose solely purpose is providing files by running programs similar to the one we
developed in the previous chapter. 
Most (if not
all) the objects in the computer system are represented by files. Thus, the objects
that must be protected by the system are files. Protecting access to files means
deciding if a particular process (acting on behalf of a user) may or may not do
a particular operation on a file.
.BS 2 "The local machine
.LP
.ix "terminal
You know that there are many machines involved in your computing system. But
let's start by considering just the one you are using, or, in general, a single machine.
.PP
A user may execute
commands in a terminal, and use any of its devices,
by booting it and supplying a user name. Terminals are not supposed to keep
state (local storage) in Plan 9 and so there is no state to protect. Also, terminals
are not supposed to export their devices to the network, by listening to network
calls made to access them. This means that nobody should be able to access
a terminal, but for the user who brought it into operation.
Also,
a terminal
is a
.B "single-user
machine. It is not meant to be shared by more than one user. Computers are cheap
these days. 
.PP
How is your terminal secured? The local machine is protected merely
by identifying
the user who is using it.
.B Identification
is one of the things needed to secure a
system. Plan 9 must know who is trying to do something, before deciding if that action
is allowed or not. In Plan 9, the user who switched on the machine is 
called the machine
owner and allowed
.ix "machine owner
to do anything to the machine. This applies not just for terminals, but for any other
Plan 9 machine as well.
.PP
The console device,
.I cons (3),
provides several files that identify both
the machine and its owner. The file
.CW /dev/hostowner
names the user who owns the machine, and
.CW /dev/sysname
names the machine itself.
.P1
; !!cat /dev/hostowner
nemo; 
; cat /dev/sysname
nautilus; 
.P2
.LP
.ix [/dev/hostowner]
.ix [/dev/sysname]
It may be a surprise, but the machine name is irrelevant for security purposes.
Only the host owner is relevant. This terminal trusts that
the user who owns it is
.CW nemo ,
only because one user typed
.CW nemo
when asked for the user name during the booting of the machine. That is all that
matters for this machine. Initially,
Plan 9 created a boot process,
described in
.I boot (8).
Besides doing other things, it asked for a user name and wrote
.CW /dev/hostowner .
But note
that in our example it might happen that the user was not actually
.CW nemo !
For the local machine, it does not matter.
.PP
Deciding who is able to do what is called
.B authorization .
Authorization for the host owner is automatic. The kernel is programmed so that
the machine owner is authorized to do many things. For example, ownership
of console and other devices is given to the host owner.
.P1
.ps -2
; ps | sed 4q
nemo              1    0:00   0:00     1276K Await    bns
nemo              2    0:58   0:00        0K Wakeme   genrandom
nemo              3    0:00   0:00        0K Wakeme   alarm
nemo              5    0:00   0:00        0K Wakeme   rxmitproc
; ls -l '#c'
--rw-rw-r-- c 0 nemo nemo 24 May 23 17:44 '#c/bintime'
--rw-rw---- c 0 nemo nemo  0 May 23 17:44 '#c/cons'
---w--w---- c 0 nemo nemo  0 May 23 17:44 '#c/consctl'
--r--r--r-- c 0 nemo nemo 72 May 23 17:44 '#c/cputime'
--r--r--r-- c 0 nemo nemo  0 May 23 17:44 '#c/drivers'
.I ...
.ps +2
.P2
.LP
This can be double checked by changing the host owner, which is usually a bad idea.
.P1
; echo -n pepe >/dev/hostowner	\fRwe set a new host owner...\fP
; ls -l '#c'
--rw-rw-r-- c 0 pepe pepe 24 May 23 17:44 '#c/bintime'
--rw-rw---- c 0 pepe pepe  0 May 23 17:44 '#c/cons'
---w--w---- c 0 pepe pepe  0 May 23 17:44 '#c/consctl'
.I ...
; echo -n nemo >/dev/hostowner	\fR...and now restore the original one\fP
.P2
.LP
The host owner can do things like adjusting permissions
for files in
.CW /proc ,
which are owned by him. There is nothing that prevents this user from
adding permissions to post notes, for example, to kill processes.
.P1
; ls -l /proc/$pid/note
--rw-r----- p 0 nemo nemo   0 May 23 17:44 /proc/1235/note
; chmod a+w /proc/$pid/note
; ls -l /proc/$pid/note
--rw-rw--w- p 0 nemo nemo 0 May 23 17:44 /proc/1235/note
.P2
.LP
The truth is that users do not exist. For the system, processes are the ones
that may perform actions. There is no such thing as a human. For example,
the human using the window system is represented by the user name of the
process(es) implementing the window system. Therefore,
each process is entitled to a user, for identification purposes. 
In a
terminal, all the processes are usually entitled to the host owner. But how can
this happen?
.PP
.ix booting
.ix [boot]
What happens is that the initial process,
.CW boot
was initially running on the name of the user
.CW none ,
which represents an unknown user. 
After a user name was given to
.CW boot ,
while booting the terminal,
it wrote such user name to
.CW /dev/user
and, from there on, the boot process was running on
the name of
.CW nemo .
The file
.CW /dev/user
.ix [/dev/user]
.ix "user name
.ix "uid
provides the interface for obtaining and changing the user name for the
current process (for the one reading or writing the file).
The user name can only be set once, initially. From there on, the user name can only
be read but not changed. For example, the following happens when using the user name for our shell.
.P1
; cat /dev/user
nemo; 
; echo -n pepe >/dev/user
echo: write error: permission denied
.P2
.LP
Child processes inherit the user name from their parents. So, all the processes in
your terminal are very likely to be owned by you, because they all descend from the
boot process, that changed its ownership to your user name.
.PP
.ix kernel
It is important for you to notice that
.I only
the local machine trusts this.
You are perfectly free to change the kernel in your terminal to do weird things like changing
.CW /dev/user .
Other machines do not trust this information at all. As a result,
running a custom made kernel
just to break into the system would only break into the terminal running that
kernel, and not into other machines.
.PP
This does not happen on other systems. For example, UNIX was made when a
computing system was just a single machine. Networks came later and it was
considered very unlikely that a user could own a machine, attach it to the network,
and run a fake kernel just to break into the system. The result is that most UNIX
machines tend to trust the users responsible for the kernels at different machines
within the same organization. Needless to say that this is a severe security problem.
.BS 2 "Distributed security and authentication
.LP
We have seen that a terminal is secured just by not sharing it. It trusts whoever
boots it. This allows you to run processes in your terminal and use its devices.
However, the terminal needs files to do anything. For example, unless you have
a binary file you cannot execute a new program. There are some programs compiled
into the kernel, kept at
.CW /boot ,
.ix [/boot]
just to get in touch with the file server machine, but that does not suffice to let the
user do any useful work.
.PP
.ix "9P security
Files are provided by file server programs, like the ones we have seen before.
Each file server is responsible for securing its own files. Therefore, there is no
such thing as an account in Plan 9. Strictly speaking, each file server has a list
of user (and group) names known to it, and is responsible for deciding if a user at the other
end of a 9P connection is allowed to do something on a file or not.
.PP
Each file server has some mechanism to open accounts and authorize users. How to do
this is highly dependent on the particular file server used. For
example, each
.CW fossil
has a file
.CW /adm/users
that lists users known to it. Any user that wants to mount a particular
.CW fossil
file server must be listed in the
.CW /adm/users
file kept within that
.CW fossil .
My file server knows me because its administrator included
.CW nemo
in its users file.
.P1
; grep '^nemo' /adm/users
nemo:nemo:nemo:
.P2
.LP
In this case, the fossil administrator used the
.CW uname
and
.CW users
commands in the fossil console to create my user in that file server.
.P1
main: !!uname nemo nemo	\fRadd the user nemo\fP
main: !!users -w		\fRand update the /adm/users file in disk\fP
.P2
.ix "new user
.ix "account
.LP
But to use other file servers I need other accounts. One per file server.
For each file server program its manual page must provide some help regarding how
to let it know which user names exist.
.PP
Note that a user name in a file
server is only meaningful to that file server. Different file servers may have different
lists of users. Within a single organization, it is customary to have a central, main,
file server and to use its
.CW /adm/users
file to initialize the set of users for other secondary file servers also installed.
This is how users are
.I authorized
to use file servers.
.PP
Besides, a file server must also
.I identify
.ix identity
the user who is using it. This is done using
9P.
When a process mounts a file server in its name space, the user name is sent in the
.CW Tattach
.ix [Tattach]
request. As you know, the attach operation gives a handle, a fid, to the client
attaching to the file system.
This permits the file server to identify the user responsible for operations requested
on that fid. When new fids are obtained by walking the file tree, the file server
keeps track of which user is responsible for which fids.
.PP
.B "Access control" ,
that is,
.ix "permitted operation
deciding if a particular operation is to be allowed or not, is performed by the file
server when a user opens a file, walks a directory, and tries to modify its entries
(including creating and removing files). When a process calls
.CW open
on a file,
the system sends a
.CW Topen
.ix [Topen]
.ix "permission check
request to the file server providing the file. At this point, the file server takes the
user name responsible for the request and decides whether to grant access or not.
You know, from the first chapter, that this is done using per-file
.B "access control lists" ,
that determine which operations can be performed on which file.
Once a file has been open for a particular access mode (reading, writing, or
both), no further access control check is made. The file descriptor, (or the fid
for that matter) behaves like a
.I capability
(a key) that allows the holder to perform file operations consistent with the open
mode.
.PP
These are all the elements involved in securing access to files, but for an
important one. It is
necessary to determine if the user, as identified for a file server, is who he or she claims
to be. Users can lie! This operation is called
.B authentication .
Authenticating a user means just obtaining some proof that the user is indeed
the one identified by the user name. Most of the machinery
provided for security by Plan 9 is there just to authenticate users.
.ix "proof of~identity
.PP
.ix "shared secret
And here comes the problem. In general, the way a program has to convince
another of something is to have a secret also known to the other. For example,
when an account is open for a user in a Plan 9 environment, the user must go
near the console of a server machine and type a password, a secret. The same
secret is later typed by the same user at a terminal. Because the terminal and
the server machine share the same secret, the sever can determine that the user
is indeed who typed the password while opening the account. Well, indeed, the
server does not know if the password is also known by another user, but the
server assumes this would not happen.
.PP
Authentication is complex because it must work without trusting the network.
There are many different protocols consisting on messages exchanged in a
particular way to allow an end of a connection to authenticate the other end,
without permitting any evil process spying or intercepting network messages
to obtain unauthorized access. Once more, we do not cover this subject in this
book. The important point is that there are multiple authentication
protocols, and that there is an interface provided by the system for this purpose.
.PP
The
.CW mount
.ix [mount]
system call receives two file descriptors, and not just one (even though a file
descriptor for a connection to a file server is all we need to speak 9P with it).
.P1
.ps -2
; sig mount
	int mount(int fd, int afd, char *old, int flag, char *aname)
.ps +2
.P2
.LP
The
.CW fd
descriptor is the connection to the file server. The second one,
.CW afd ,
is called an
.I "authentication file descriptor" ,
.ix "authentication file
.ix [afd]
used to authenticate to the file server. Before calling
.CW mount ,
a process calls
.CW fauth
.ix [fauth]
to authenticate its user to a file server at the other end of a connection.
.P1
; sig fauth
	int fauth(int fd, char *aname)
.P2
.LP
For example, if the file descriptor 12 is connected to a file server,
.P1
afd = fauth(12, "main")
.P2
.LP
obtains an authentication file descriptor for authenticating our user to access
the file tree
.CW main
in the file server. This descriptor is obtained by our system using a
.CW Tauth
.ix [Tauth]
.ix [Rauth]
9P request.
And now comes the hard part. We must negotiate with the file server a particular
authentication protocol to use. Furthermore, we must exchange messages by
reading and writing
.CW afd
according to that protocol, to give proof of our identity to the file server. This is
complex and is never done by hand. Assuming we already made it,
.CW afd
can be given to
.CW mount ,
to prove that we have been already authenticated. For example, like in
.P1
mount(12, afd, "/n/remote", MREPL, "main");
.P2
.LP
In most cases, the library function
.CW amount
does this. So, it would have been the same to do just
.P1
amount(12, "/n/remote", MREPL, "main");
.P2
.LP
instead of calling
.CW fauth ,
.ix "authentication protocol
following an authentication protocol, and calling
.CW mount .
It is easier to let
.CW amount
take care of authentication by itself. In the next section we will show how
this could be.
.PP
For now, the important point is to note how authentication is performed by
exchanging messages between the two processes involved. In this case,
the file server and our client process. The authentication file descriptor obtained
above is just a channel where to speak an authentication protocol, using some sort of
shared secret to convince the other process, nothing else. It permits
keeping the authentication messages apart from 9P.
.PP
If there was only a single server, providing a secret to it for each user would
suffice to authenticate all users in the Plan 9 network. However, there can be
may ones. Furthermore, authentication is used not just to convince file servers.
It is also used to convince other servers providing different services, like
command execution. Instead of having to open an account with the user's secret
for each server, authentication is centralized in, so called,
.B "authentication servers" .
.PP
An authentication server is a machine that runs an authentication server process,
perhaps surprisingly. The idea behind an authentication server is simple. Authentication
is delegated to this server. Instead of sharing a secret, and trusting each other
because of the shared secret, both the client process and the server process trust a
third process, the authentication server. This means that both processes must share
a secret with the third trusted one.
.PP
No matter how many servers there are,
the client only needs one secret, for using the authentication server. Using it, the
client asks the authentication server for
.B tickets
to gain access to servers. Each ticket is a piece of data that is given to a client,
and can be used to convince the server that the client is indeed who it claims to be.
This can be done because the authentication server may use the secret it shares
with the server to encrypt some data in the ticket given to the client. When the client
sends the ticket to the server, the server may know that the ticket was issued by
someone knowing its own secret, i.e., by the authentication server.
.PP
The authentication server in Plan 9 is implemented by the program
.CW authsrv ,
described in
.I auth (8).
.ix [authsrv]
It runs on a machine called the authentication server, as you might guess. In many
cases, this machine may be the same used as the main file server, if it runs such
process as well.
.PP
Things are a little bit more complex, because a user might want to use servers
maintained by different organizations. It would not be reasonable to ask all Plan 9
file servers in the world to share a single authentication server. As a result, machines
are grouped into, so called,
.B "authentication domains" .
An authentication domain is just a name, representing
a group of machines that share an authentication server, i.e., that
are grouped together for authentication purposes. Each Plan 9 machine
belongs to an authentication domain, set by the machine boot process (usually
through the same protocol used to determine the machine's IP address, i.e., DHCP).
.PP
The file
.CW /dev/hostdomain ,
.ix [/dev/hostdomain]
.ix [hostdomain]
.ix [hostowner]
provided by the
.I cons (3)
device, keeps the authentication domain for the machine.
.P1
; cat /dev/hostdomain
dat.escet.urjc.es;
;
.P2
.LP
Regarding authentication, a user is identified not just by the user name (e.g., that in
.CW /dev/hostowner ),
but also by the associated authentication domain. A single user might have different
accounts, for using different servers, within different authentication domains. In many
cases, the same user name is used for all of them. However, a user might have
different user names for each different authentication domain.
.BS 2 "Authentication agents
.LP
In any case, we still have to answer some questions.
How does a client (or a sever) run the authentication protocol? How do
they speak with the authentication server? Where do they keep the secrets? Strictly
speaking, in Plan 9, neither process does any of these tasks!
All the authentication protocols are
implemented by a program called
.CW factotum .
.ix [factotum]
This program is what is known as an
.B "authentication agent" ,
i.e., a helper process to take care of authentication.
A factotum keeps the
secrets
for other processes, and is the only program that knows
how to perform the client or the server side of any
authentication protocol used in Plan 9.
.PP
Factotum keeps
.B keys .
A key is just a secret, along with some information about the secret itself (e.g.,
which protocol is the secret for, which user is the secret for, etc.)
Factotum is indeed a file system, started soon after the the machine boots,
which mounts itself at
.CW /mnt/factotum .
Its interface is provided through the files found there.
.P1
; lc /mnt/factotum
confirm	ctl	log	needkey	proto	rpc
.P2
.LP
The file
.CW ctl
is used to control the set of secrets kept by the factotum. Reading it, reports
the list of keys known (without reporting the actual secrets!)
.P1
.ps -2
; cat /mnt/factotum/ctl
key proto=p9sk1 dom=dat.escet.urjc.es user=nemo !password?
key proto=p9sk1 dom=outside.plan9.bell-labs.com user=nemo !password?
key proto=vnc dom=dat.escet.urjc.es server=aquamar !password?
key proto=pass dom=urjc.es server=orson service=ssh user=nemo !password?
key proto=rsa service=ssh size=1024 ek=10001 n=DE6D279E8B49C9B1F44B
9CA26114005BD2EB1B255A92F42D475B49D333FA4886990DDF17108
FE4237A2FD6E1CB2C040C1F5361F03352DAE67243B62CE2664663B
E0AE1F1933CDF935 !dk? !p? !q? !kp? !kq? !c2?
.ps +2
.P2
Each one of the lines above corresponds to a single key kept by this factotum process,
and starts with
.CW key .
.ix [key]
The last line is so large, that it required four output files in the terminal session reproduced
above.
.PP
The first line shown above corresponds
to the key used to authenticate to file servers using the
P9SK1 authentication protocol (Plan 9 Shared Key, 1st).
.ix [9PSK1]
.ix [9PANY]
.P1
key proto=p9sk1 dom=dat.escet.urjc.es user=nemo !password?
.P2
As you can see, a
key is a series of
.I attribute
and
.I value
pairs. In this key, the attribute
.CW proto
has as value
.CW p9sk1 .
The purpose of this attribute is to identify the protocol that uses this key.
Other attributes depend on the particular authentication protocol for the key. In
P9SK1 keys,
.CW dom
identifies the
.B "authentication domain"
for a key. This is just the name that identifies a set of machines, for organizative
purposes, that share an authentication server. The attribute
.CW user
identifies our user name within that domain. Note that we might have different
P9SK1 keys for different authentication domains, and might have different user
names for them. The attribute
.CW password
.ix password
has as its value a secret, that is not shown by factotum.
.PP
New keys can be added to factotum by writing them to the
.CW ctl
file, using the same syntax. The next command adds a key for using P9SK1, as
the user
.CW nemo ,
for the
.CW foo.com
authentication domain.
.P1
.ps -2
; echo 'key proto=p9sk1 dom=foo.com user=nemo !password=whoknows' \e
;; >/mnt/factotum/ctl
; grep foo.com /mnt/factotum/ctl
proto=p9sk1 dom=foo.com user=nemo !password?
;
.ps +2
.P2
.LP
The value for the attribute
.CW password
is the shared secret used to authenticate the user
.CW nemo ,
by using the authentication server for the
.CW foo.com
domain.
Because the attribute name
was prefixed with a
.CW !
sign,
.CW factotum
understands that it is an important secret, not to be shown while reading
.CW ctl .
In general, factotum does its best to avoid disclosing secrets. It keeps them for
itself, for use when speaking the authentication protocols involved. Look what
happens below.
.P1
.ps -2
; ps | grep factotum
nemo              6    0:00   0:00      268K Pread    factotum
; acid 6
/proc/6/text:386 plan 9 executable

<stdin>:1: (error) setproc: open /proc/6/mem: permission denied
/sys/lib/acid/port
/sys/lib/acid/386
no symbol information
acid:
.ps +2
.P2
.LP
.ix "debug protection
You cannot debug factotum! It protects its memory, to prevent any process from
reading its memory and obtaining the keys it maintains. This can be done to
any process by writing the
string
.CW private
.ix "private memory
to the process
.CW ctl
file.
That is what factotum did to itself to keep its memory
unreadable from outside. In the same way, factotum wrote
.CW noswap
.ix [noswap]
to its process control file, to ask Plan 9 not to swap its memory out to disk when running
out of physical memory.
.PP
It is now clear how to add keys to factotum, but how can a process authenticate?
A process can authenticate to another peer process
by relying messages between its factotum and the other peer. As
figure [[!relays messages authenticate!]] shows, during authentication, a client
process would simply behave as an intermediary between its factotum and
the server. When its factotum asks the process so send a message to the other
end, it does so. When it asks the process to receive a message from the other end,
and give it to it, the process obeys. In the same way, a server process relays
messages to and from its own factotum to authenticate clients.
.LS
.PS
right
circlerad=.35
F: circle "factotum"
arrow <-> 
C1: circle "client" "process"
arrow <-> right 1.2 "network" "connection"
circle "server" "process"
arrow <-> 
circle "factotum"
spline <-> from F.se down right .5 then right .5
circle "client" "process"
arrow <-> right 1.2 "network" "connection"
circle "server" "process"
reset
.PE
.LE F A process relays messages to and from its \f(CWfactotum\fP to authenticate.
.PP
The protocol is only understood by the factotum. So, if both the client and the server
have a factotum, it is both factotums the ones speaking the authentication protocol.
The only peculiarity is
that messages exchanged for authentication between both factotums
pass through the client and
the server processes, which behave just as relays. As the figure shows, different
servers might have different factotums. The same happens for clients. And of course,
more than one process may use the same factotum. Which factotum is used is determined
by which factotum is mounted at
.CW /mnt/factotum .
.PP
For example, executing a new
.CW factotum
mounts another factotum at
.CW /mnt/factotum ,
isolating the processes that from now on try to authenticate in our name space.
.P1
; auth/factotum
; cat /mnt/factotum/ctl
;			\fIThis one has no keys!\fP
.P2
.LP
There is another important thing to note. A process may use a
factotum even if the other peer does not. For example, the lower server shown in
the figure 14.1 does not use a factotum and is implementing the authentication protocol
on its own. As long as a process speaks properly
the necessary authentication protocol, it does not matter if it is the one
actually speaking, or just a relay for a factotum.
.PP
The
.I connection
kept between a process and its factotum during an authentication session is
provided by the
.CW /mnt/factotum/rpc
file. This file provides a distinct channel each time it is open. It is named
.CW rpc
.ix "[rpc] file
because the process performs RPCs to the factotum by writing requests
through this file (and reading replies from factotum),
to ask what it should do and rely messages.
.PP
The
.I auth (2)
.ix "[auth] library
library provides authentication tools that work along with factotum. Among
other things, it includes a function called
.CW auth_proxy
.ix [auth_proxy]
.ix relying
that takes care of authentication by relying messages between the
factotum reached through
.CW /mnt/factotum/ctl
and the other end of a connection. It returns a data structure with
some authentication information.
.P1
.ps -2
; sig auth_proxy
    AuthInfo* auth_proxy(int fd, AuthGetkey *getkey, char *fmt, ...);
.ps +2
.P2
.LP
To show how to use this function, the following program mounts a file server and performs
any authentication necessary to gain access to the server's file tree. The
.I auth
library provides
.CW amount
.ix [amount]
to do this. Instead of using it, the program implements its own version for
this function.
.so progs/amount.c.ms
.ix [amount.c]
.LP
The first argument for the program is a file used as a connection to
the server. The program opens it and calls its own
.CW authmount
function. This function returns the
.CW Authinfo
.ix [Authinfo]
.ix "authentication information
obtained by calling
.CW auth_proxy
using its last parameter, and our program prints some diagnostics about such
structure before calling
.CW auth_freeAI
.ix [auth_freeAI]
to release it.
.PP
The important part of this program is the implementation for
.CW authmount ,
similar to that of
.CW amount
but for returning the
.CW Authinfo
to the caller.
.P1
.ps -2
int
authmount(int fd, char *mntpt, int flags, char *aname, AuthInfo** aip)
{
	int afd, r;

	afd = fauth(fd, aname);
	if (afd < 0){
		*aip = nil;
		fprint(2, "fauth: %r\en");
		return mount(fd, afd, mntpt, flags, aname);
	}
.ps +2
.P2
.P1
.ps -2
	*aip = auth_proxy(afd, amount_getkey,
		"proto=p9any role=client");
	if (*aip == nil)
		return -1;
.ps +2
.P2
.P1
.ps -2
	r = mount(fd, afd, mntpt, flags, aname);
	close(afd);
	if (r < 0){
		auth_freeAI(*aip);
		*aip = nil;
	}
	return r;
}
.ps +2
.P2
.LP
The function is used by a client process to authenticate to a (file) server
process. First, the client process must obtain a connection to the server
and pass its descriptor in
.CW fd .
Before authentication takes place, the function calls
.CW fauth
to obtain a file descriptor that can be used to send and receive
messages for authenticating with the server, and keeps it in
.CW afd .
.ix [afd]
In general, clients may use the initial connection to a server
to authenticate. However, for a 9P file server, you know that a
separate (authentication) descriptor is required instead.
.PP
In any case, the point is that calling
.CW auth_proxy
with a descriptor to reach the server process,
.CW afd
in this case,
suffices to authenticate our user to the server.
.CW Auth_proxy
opens
.CW /mnt/factotum/ctl ,
and loops asking factotum what to do, by doing RPCs through this
.CW ctl
file. If factotum says so,
.CW auth_proxy
reads a message from the peer, by reading
.CW afd ,
and writes it to factotum (to the
.CW ctl
file). If factotum, instead, asks for a message to be sent to the peer,
.CW auth_proxy
takes the message from the
.CW ctl
file and writes it to
.CW afd .
.PP
.ix "role
Which protocol to speak, and which role to take in that protocol (client or
server), is determined by the last parameters given to
.CW auth_proxy .
Such parameters are similar to the arguments for
.CW print ,
to permit may different invocations depending on the program needs.
In our case, we gave just the format string
.P1
"proto=p9any role=client"
.P2
.LP
But passing more arguments in the style of
.CW print
can be done, for example, to specify the user for the key, like here:
.P1
char* user;
\fI...\fP
auth_proxy(afd, getkey, "proto=p9any role=client user=%s", user);
.P2
.LP
Such string is given to factotum, which matches it against the keys
it keeps. It is used as a template to select the key (and protocol)
to use. In this case, any key matching the
.CW p9any
protocol can be used, using the role of a client. The
.CW p9any
protocol is not exactly a protocol, but a way to say that we
do not care about which particular Plan 9 authentication protocol is used.
When this
.ix "meta-protocol
.I meta-protocol
is used, both the client and the server negotiate the actual authentication
protocol used, like for example, P9SK1.
.PP
Once
.CW auth_proxy
completes, it may have succeeded authenticating the user or not. If it does,
it returns an
.CW Authinfo
structure, which is a data structure that contains authentication information
returned from factotum.
.P1
typedef struct AuthInfo AuthInfo;
struct AuthInfo
{
	char	*cuid;		/* caller id */
	char	*suid;		/* server id */
	char	*cap;		/* capability */
	int	nsecret;	/* length of secret */
	uchar	*secret;	/* secret */
};
.P2
.LP
For example, this is what results from using
.CW 8.amount
to mount several file servers. First, we start a new
.CW ramfs ,
which does not require any authentication, and
mount it.
.P1
; ramfs -s ram
; 8.amount /srv/ram /n/ram ''
fauth: authentication not required
no auth information obtained
.P2
.LP
The call to
.CW fauth
(which sends a
.CW Tauth
request to the server) fails with the error
.CW "authentication not required" .
So, the function
.CW authmount
simply called
.CW mount
using
.CW -1
as
.CW afd ,
after printing a diagnostic for us to see. As a result, no
.CW AuthInfo
is obtained in this case.
.PP
Second, we use
.CW 8.amount
to mount our main file server,
wich does require authentication (the key for authenticating to the server
using P9SK1 was known to the factotum used).
.P1
; 8.amount /srv/tcp!whale!9fs /n/whale main/archive
client uid: nemo
server uid: nemo
.P2
.LP
In this case,
.CW auth_proxy
was called and could authenticate using
.CW factotum .
The
.CW AuthInfo
structure returned contains
.CW nemo
in its
.CW cuid
.ix "client uid
field (client uid). That is the actual user id we are using at our terminal.
It also contains
.CW nemo
in its
.CW suid
.ix "server uid
field (server uid). That is the user id as known to the server. In our case, both
user names were the same, but they could differ if I was given a different user
name for the account at
.CW whale .
.PP
In most cases, a client is only interested in knowing if it could authenticate or not.
Like in our example (and in
.CW amount ),
most clients would just call
.CW auth_freeAI ,
to release the
.CW AuthInfo
structure, after a successful authentication. For server programs, things may be
different. They might employ the information returned from factotum as we will
see later.
.PP
But what would happen when
.CW factotum
does not know the key needed to authenticate to the server?
In the call to
.CW auth_proxy ,
the function
.CW amount_getkey
.ix "key reading
.ix [amount_getkey]
was given as a parameter. This function is provided by the
.I auth (2)
library and is used to ask the user for a key when
factotum does not have the key needed for the protocol chosen. For example,
below we try to mount the file server
.CW whale ,
in the window where we started a new factotum, which starts with no keys.
.P1
; auth/factotum
; cat /mnt/factotum/ctl
;			\fIThis one has no keys!\fP
; 8.amount /srv/tcp!whale!9fs /n/whale main/archive

!Adding key: dom=dat.escet.urjc.es proto=p9sk1
user[nemo]: 	\fI we pressed return\fP
password: 	\fI we typed the password here\fP
!
client uid: nemo
server uid: nemo
.P2
.LP
Here,
.CW auth_proxy
called the function
.CW amount_getkey ,
given as a parameter, to ask for a key to mount
.CW whale .
At this point, the message starting
.ix "adding key
.CW "!Adding key" ...
was printed, and we were asked for a user name and password for the P9SK1
protocol within the
.CW dat.escet.urjc.es
authentication domain. That information
was given to factotum, to install a new key,
and authentication could proceed. After that, factotum has the new key for
use in any future authentication that requires it.
.P1
; cat /mnt/factotum/ctl
key proto=p9sk1 dom=dat.escet.urjc.es user=nemo !password?
.P2
.LP
We will never be prompted for
that key again as long as we use this factotum.
.BS 2 "Secure servers
.PP
.ix "handling authentication
.ix "secure server
Handling authentication in a server can be done in a similar way. In general,
the server calls
.CW auth_proxy
to relay messages between the client and
.CW factotum .
The only difference is that the role is now
.CW server ,
instead of
.CW client .
.PP
For 9P servers, the
.I 9p (2)
library provides helper routines that handle authentication. A 9P
server that implements authentication for its clients must create (fake)
authentication files in response to
.CW Tauth
.ix [Tauth]
requests. Such files exist only in the protocol, and not in the file tree served.
They are just a channel to exchange authentication messages by using
.CW read
and
.CW write
in the client.
.PP
To secure our
.CW semfs
file server (developed in a previous chapter), we first provide a key template
in the
.CW Srv
structure that defines the implementation for the server. The
function
.CW auth9p
provided by the library can be used as the implementation for the
.CW auth
operation in
.CW Srv .
It allocates authentication files, flagging them by setting
.CW QTAUTH
.ix [QTAUTH]
.ix "authentication file
in their
.CW Qid.types.
.P1
static Srv sfs=
{
	.auth	=	auth9p,
	.attach =	fsattach,
	.create	=	fscreate,
	.remove =	fsremove,
	.read	=	fsread,
	.write	=	fswrite,
	.walk1	=	fswalk1,
	.clone	=	fsclone,
	.stat	=	fsstat,
	.destroyfid=	freefid,
	.keyspec =	"proto=p9any role=server"
};
.P2
.LP
Because there are authentication files, the implementation of
.CW fsread
and
.CW fswrite
must behave differently when the file read/written is an authentication file.
In this case, the data must be relayed to factotum and not to a file served.
The new implementation for
.CW fsread
would be as follows.
.P1
static void
fsread(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;
	char	nl[2] = "\n";

	fid = r->fid;
	q = fid->qid;
	if (q.type&QTAUTH){
		authread(r);
		return;
	}
	\fI...everything else as before...\fP
}
.P2
.LP
It calls the helper function
.CW authread ,
.ix [authread]
.ix [auth9p]
provided by
.CW lib9p ,
to handle reads from authentication files (i.e., to obtain data from the underlying
factotum to be sent to the client).
In the same way,
.CW fswrite
must include
.P1
if (q.type&QTAUTH){
	authwrite(r);
	return;
}
.P2
.LP
to take a different course of action for writes to authentication files. The
library function
.CW authwrite
.ix [authwrite]
takes care of writes for such files.
.PP
Fids for authentication files keep state to talk to the underlying factotum. The
function
.CW authdestroy
.ix [authdestroy]
.ix [destroyfid]
must be called
for fids that refer to authentication files. This means that we must change the
function
.CW freefid ,
which we used to release the semaphore structure for a fid, to release
resources for authentication fids.
.P1
static void
freefid(Fid* fid)
{
	Sem*	s;

	if (fid->qid.type&QTAUTH)
		authdestroy(fid);
	else {
		s = fid->aux;
		fid->aux = nil;
		closesem(s);
	}
}
.P2
.LP
The purpose of the entire authentication process is to demonstrate in the
.CW Tattach
request that the user was who he/she claimed to be. So,
.CW fstattach
must be changed as well. The library function
.CW authattach
makes sure that the user is authenticated. When it returns
.CW -1 ,
to signal a failure,
it has already responded with an error to the caller, and the server should
not respond. Otherwise, the user has been authenticated.
.P1
static void
fsattach(Req* r)
{
	if (authattach(r) < 0)
		return;
	r->fid->qid = (Qid){0,0,QTDIR};
	r->ofcall.qid = r->fid->qid;
	respond(r, nil);
}
.P2
.LP
.ix "message dump
After compiling the new program into
.CW 8.asemfs ,
we can try it.
As you may remember,
.CW 8.asemfs
mounts itself at
.CW /mnt/sem
(the parent process spawns a child to speak 9P, and mounts it). Using the flag
.CW -D ,
we asked for a dump of 9P messages to see what happens.
First, we execute it while using a factotum that has no keys.
.P1
.ps -2
; 8.asemfs -D
<-11- Tversion tag 65535 msize 8216 version '9P2000'
-11-> Rversion tag 65535 msize 8216 version '9P2000'
<-11- Tauth tag 10 afid 485 uname nemo aname 
-11-> Rauth tag 10 qid (8000000000000001 0 A)
<-11- Tread tag 10 fid 485 offset 0 count 2048
-11-> Rerror tag 10 ename authrpc botch
<-11- Tattach tag 10 fid 487 afid 485 uname nemo aname 
-11-> Rerror tag 10 ename authrpc botch
<-11- Tclunk tag 10 fid 485
-11-> Rclunk tag 10
8.asemfs: mount /mnt/sem: authrpc botch
;
.ps +2
.P2
.LP
This time, the server replied to
.CW Tauth
with an
.CW Rauth
message, and not with an
.CW Rerror
to indicate that authentication was not required. Because of this, the
.CW amount
call made by the client (the parent process) calls
.CW auth_proxy
to authenticate the user to the server.
.PP
You may see how the poor client
tries to read the authentication fid (485), to obtain a message from the
server as part of the authentication protocol. It fails. The server's factotum
informed with an
.CW "authrpc botch"
error that it could not authenticate. This is not a surprise, because the factotum
for the server had no keys. The optimistic (but still poor) client tried to attach
to the server, anyway. The server refused this time, because the client was not
authenticated. Things are different when the server's factotum is equipped with
a key for P9SK1.
.P1
.ps -2
; 8.asemfs -D
<-11- Tversion tag 65535 msize 8216 version '9P2000'
-11-> Rversion tag 65535 msize 8216 version '9P2000'
<-11- Tauth tag 10 afid 465 uname nemo aname 
-11-> Rauth tag 10 qid (8000000000000001 0 A)
<-11- Tread tag 10 fid 465 offset 0 count 2048
-11-> Rread tag 10 count 24 '7039736b 31406461 ....'
<-11- Twrite tag 10 fid 465 offset 24 count 24 '7039736b 31206461 ...'
-11-> Rwrite tag 10 count 24
<-11- Twrite tag 10 fid 465 offset 48 count 8 '7501af21 166c2391'
-11-> Rwrite tag 10 count 8
<-11- Tread tag 10 fid 465 offset 56 count 141
-11-> Rread tag 10 count 141 '016e656d 6f000000 ....'
<-11- Twrite tag 10 fid 465 offset 197 count 85 'f63182df 120add32 ...'
-11-> Rwrite tag 10 count 85
<-11- Tread tag 10 fid 465 offset 282 count 13
-11-> Rread tag 10 count 13 '2be8ff3e d96f0f29 ...'
.ps +2
.P2
.P1
.ps -2
<-11- Tattach tag 10 fid 234 afid 465 uname nemo aname 
authenticate nemo/: ok
-11-> Rattach tag 10 qid (0000000000000000 0 d)
<-11- Tclunk tag 10 fid 465
-11-> Rclunk tag 10
.ps +2
.P2
.LP
In this output, you see how the client sends read and write requests, successfully,
to the authentication fid 465. Such operations obtain messages and send them
to the server's factotum, respectively. After a series of messages authenticate the
client using the P9SK1 protocol, the client sends a
.CW Tattach
request providing the authentication file (fid 465) as a proof of identity. The
server accepts the proof, and the client manages to attach to the server. At this point,
the authentication file is no longer useful and is clunked by the client (because its
.CW afid
was closed).
.PP
This was the idea. Both the client and the server managed to speak P9SK1
to authenticate without having a single clue about that authentication protocol.
They just arranged for their factotums to speak the protocol, on their behalf.
.BS 2 "Identity changes
.LP
At this point, despite our efforts, we could ask the question: is the server secure?
In this case,
.CW semfs
does not listen to requests in the network, and authenticates clients. That seems
secure enough. However, there is an important common sense rule in security, called
the
.B "least privilege principle" .
This rule says that a program should have no more rights than needed to perform
its job. The
.CW semfs
file server serves semaphores. But a bug in the program might make it access
files or do any other weird thing. Attackers might exploit this.
.PP
.ix sandboxing
What we can do is to put the server in a sandbox, and remove any privileges
that the user who starts it might have. This can be done by changing our user
to
.ix [none]
.CW none ,
which can always be done for a process by writing
.CW none
to
.CW /dev/user .
Also, we can rebuild the process name space from scratch, for the new user
name, using
.CW newns ,
provided by the
.I auth
library.
This function may be called to become the user
.CW none .
.P1
void
becomenone(void)
{
	int	fd;

	fd = open("#c/user", OWRITE);
	if (fd < 0)
		sysfatal("#c/user: %r");
	if (write(fd, "none", 4) < 0)
		sysfatal("can't become none");
	close(fd);
	newns("none", nil);
}
.P2
The second parameter to
.CW newns
.ix [newns]
names a namespace file, which is
.CW /lib/namespace
.ix [/lib/namespace]
.ix "new namespace
by default.
After modifying our
.CW asemfs
file server to call
.CW becomenone
early in
.CW fstattach ,
we can see the effect.
.P1
.ps -2
; 8.asemfs -s sem
; ps | grep asemfs
nemo           1410    0:00   0:00      204K Pread    8.asemfs
; mount -c /srv/sem /mnt/sem
; ps | grep asemfs
none           1410    0:00   0:00      240K Pread    8.asemfs
.ps +2
.P2
.LP
The first command started
.CW 8.asemfs ,
asking it to post at
.CW /srv/sem
a file descriptor to mount its file tree. As you can see, at this point the
process is owned by the user who started the server, i.e.,
.CW nemo .
The server may potentially access any resource this user could access.
However, after mounting it,
.CW ps
reports that the process is entitled to user
.CW none .
It no longer can access files using
.CW nemo
as its identity. This limits the damage the server can do, due to any bug.
Furthermore, reading
.CW /proc/1410/ns
would report that this process now has a clean namespace, built from the
scratch for the user
.CW none .
Any resource obtained by
.CW nemo ,
by mounting file servers into its namespace, is now unaccessible for this process.
.PP
We could go even further by calling
.CW rfork(RFNOMNT)
.ix "[RFNOMNT] [rfork]~flag
near the end of
.CW becomenone .
.ix "become [none]
This prevents the process from mounting any other resource into its namespace.
It will be confined for life, with almost no privilege.
.PP
In general, for a server, calling a function like
.CW becomenone
would be done early in
.CW main ,
before servicing requests from the network. In our case, we cannot
do this in the main function, because the process that has to belong to
.CW none
is the one implementing the file server. This process is started by
.CW threadpostmountsrv ,
and therefore we must arrange for such a process (and not the parent) to call
.CW becomenone .
We placed the call in
.CW fstattach ,
because the server is not likely to do any damage before a client can mount it.
.PP
Becoming the user
.CW none
was an identity change. In general, this is the only identity change made
by most programs.
In CPU servers it is usual for processes that listen for network requests, like
HTTP servers, to run as none.
.PP
Sometimes, it may be necessary to become a different user, and not just
.CW none .
Consider again CPU servers.
.ix "CPU server
Running on them, there are other server
processes that must execute commands
on behalf of a user. For example, the processes listening for remote command
execution requests must execute commands on behalf of a remote user.
.PP
There is one interesting thing to learn here. Executing new processes for a remote
user can be done perfectly by a server process without changing its user id. After
authenticating a client, a server may just spawn a child process to execute
a command for the remote user. But this works as long as the process for
the remote user does not try to use resources outside the CPU server. As soon
as it tries, for example, to mount a file server, it would need to authenticate and
identify itself using the client user id, and not the user id for the server that
provides remote execution in the CPU server. Of course, in practice, a process
for a remote user is very likely to access resources outside the CPU server and
therefore requires some means to change its user id.
.PP
And there is an even more interesting thing to see now. When you connect to
a CPU server to execute a command on it, the name space from your terminal
is exported to the server process that runs the command in the CPU server.
We saw this earlier. The name space is exported using the connection
to the CPU server, after authentication has been performed. As a result, the
process started for you in the CPU server does
.I not
require to change its ownership to use any of the files re-exported from your
terminal for it. Is has all of them in its name space. Of course, mounting something
while running in a CPU server is a different thing, and requires an identity change
as you now know.
.ix "identity change
.PP
Because speaking for others (as a result of changing the user identity) is
potentially very dangerous. The authentication server takes precautions to
allow only certain users to speak for others within its authentication domain.
The file
.CW /lib/ndb/auth
.ix [/lib/ndb/auth]
.ix "speak~for
lists which users may speak for which others. Usually, CPU servers are started by
fake users whose sole purpose is to boot such servers. Such users are usually
the only ones allowed to speak for other users, to prevent a user impersonating
as another.
.PP
A notable example of a tool that requires identity changes is
.CW auth/cron .
.ix [cron]
This command executes commands periodically, as mandated by each user, on a
CPU server chosen by each user. Each user has a file
.CW /cron/$user/cron
that lists periodic commands. For example, this is the
.CW cron
file for
.CW nemo .
.P1
.ps -1
; cat /cron/nemo/cron
#m h dm m dw host
0 0 * *  * whale chmod +t /mail/box/nemo/spam
0 0 * * * aquamar /usr/web/cursos/mkcursos
.ps +1
.P2
.LP
Each line describes a periodic job. It contains the times when to execute it,
using fields to select which minute, hour, day of month, month, and day of week.
In this case, both jobs are executed at midnight. The first job is to be executed
at the CPU server
.CW whale ,
and the second one is to be executed at the CPU server
.CW aquamar .
Each job is described by the command found last in each line.
.PP
The point is that for commands like
.CW cron
and
.CW cpu
to work, it is necessary to change the identity of the processes that
run in the CPU server on behalf of a user. As you know, initially, all processes
in the CPU server are entitled to the machine owner (but for perhaps a few
that decided to switch to the user
.CW none ).
However, some of these processes might want to change the user id.
.PP
This can be done by using the
.I cap (3)
.ix "capability device
device. This device provides
.B capabilities
to change ownership. A capability is just a key that allows a process to do something.
In this case, a capability may be used to convince the kernel to change the
user id for a process.
.PP
As you know, the host owner is very powerful within the local machine.
A process running on the name of the host owner may permit any other process
in the machine to change its user identity by means of the files
.CW /dev/caphash
and
.CW /dev/capuse
provided by
.I cap .
.PP
The idea is as follows. When a user authenticates to a server,
the factotum
for the server process, if running on the name of the host owner, may
help the server to change its identity to that of the user who authenticated.
After a successful authentication, the function
.CW auth_proxy
returns an
.CW AuthInfo
.ix [AuthInfo]
structure with authentication information for the user. This happens also for
a server process, when it uses
.CW auth_proxy
(i.e.,
.CW factotum )
to authenticate the client. Besides the
.CW cuid
and
.CW suid
fields, with the user ids for the client and the server, an
.CW AuthInfo
contains a
.CW cap
field with some data that is a capability for changing the user id to that of
the user authenticated.
.PP
What happens is that
.I cap (3)
trusts
.CW factotum ,
because it runs on the name of the host owner. Besides returning the
.CW AuthInfo
to the user,
.CW factotum
used the
.I cap
device to ask the kernel to allow any process holding the data in
.CW Authinfo.cap
to change its id to the user who authenticated. It did so by writing a hash
of the capability to
.CW /dev/caphash .
Later, our server process may write to
.CW /dev/capuse
the capability in
.CW Authinfo.cap ,
and change its identity.
.PP
The function
.CW auth_chuid ,
.ix [auth_chuid]
.ix "identity change
.ix "uid change
from the
.I auth
library, takes care of using the capability in
.CW AuthInfo
for changing the user id. Also, as an extra precaution, it builds a new name
space according to the name space file supplied, or
.CW /lib/namespace
if none is given. The following code might be used by a server program to
authenticate a client and then changing its user id to continue execution on the
user's name.
.P1
int	fd;	// file descriptor to the client process
AuthInfo*ai;
 \fI...\fP
ai = auth_proxy(fd, getkey, keyspec);
if (ai == nil)
	sysfatal("authentication failed");
auth_chuid(ai, nil);
auth_freeAI(ai);
.P2
.LP
This should be done by the process servicing the client. In some cases,
the process handling the client is the initial process for the server,
if the server is started by
.CW listen .
That is because this program spawns one server process for each client.
In other cases, this has to be done after creating a child process in the server
program just to serve a connection to a client.
.PP
One program that uses
.CW auth_chuid
is
.CW auth/login .
.ix [login]
It can be used to simulate a user login at a terminal. The program prompts
for a user name and a password, and then changes the user identity to that
of the new user, adjusting also the name space and the conventional environment
variables. We use it now to become the user
.CW elf .
.P1
; cat /mnt/factotum/ctl
key proto=p9sk1 dom=dat.escet.urjc.es user=nemo !password?
; auth/login elf
Password: 
% cat /mnt/factotum/ctl
key proto=p9sk1 dom=dat.escet.urjc.es user=elf !password?
% cat /dev/user
elf% 
% cat /dev/hostowner
nemo% 
\fBcontrol-d\fP
;
.P2
.LP
Initially, the factotum used contains just the key for
.CW nemo ,
to authenticate with Plan 9 servers in
.CW dat.escet.urjc.es .
After running
.CW auth/login ,
we obtain a new shell. This one is running with the user id
.CW elf ,
and not
.CW nemo .
As you see, the program started a new factotum for the new shell, which
was given a key for using Plan 9 servers as the user
.CW elf .
.PP
A program might do the same by calling the function
.CW auth_login ,
.ix [auth_login]
which does just this. It uses code like the following one.
.P1
/* authenticate */
ai = auth_userpasswd(user, pass);
if(ai == nil || ai->cap == nil)
	sysfatal("login incorrect");

/* change uid */
auth_chuid(ai, "/lib/namespace");
.P2
.LP
First, it calls the library function
.CW auth_userpasswd
to authenticate a user given its user name and its secret.
Then,
.CW auth_chuid
is used to become the new user.
.BS 2 "Accounts and keys
.LP
.ix account
.ix key
.ix authentication
We are near the end of the discussion about security tools provided by
the operating system, but we did not show how can the authentication
server know which users there are, and which secrets can be used to
authenticate them. Furthermore, we still need to know how the initial
password for a user is established, and how can a user change it.
.PP
Secrets, that is, keys, are not are maintained by the authentication server
process. Instead, another server keeps them. All the keys for users are
handled by a file server, called
.CW keyfs .
.PP
The keys and other information about the user accounts
are actually stored in the file
.CW /adm/keys ,
stored in the file server. To avoid disclosure of the keys, the file is encrypted
using the secret of the host owner in the authentication server machine.
The program
.CW keyfs
.ix [keyfs]
.ix [/adm/keys]
decrypts this file, and serves a file tree at
.CW /mnt/keys
that is the interface for authentication information used by other programs,
including the authentication server
.CW authsrv .
.ix [authsrv]
.ix "authentication server
.PP
For example, the directory
.CW /mnt/keys/nemo
contains information about the account for the user
.CW nemo .
In particular,
.CW /mnt/keys/nemo/key
is the key for such user. That is how the authentication server can
access the secret for
.ix secret
.CW nemo
to know if a remote user is indeed
.CW nemo
or not.
All the operations to create, remove, enable, and disable user
accounts are done through this file system. 
Creating another directory under
.CW /mnt/keys
would create another user entry in
.CW /adm/keys .
And so on.
.PP
In any case, it is not usual to use the file interface directly for
handing user accounts. Instead, commands listed in
.I auth (8)
provide a more convenient interface.
For example, a new user account is created using
.CW auth/changeuser , like in
.P1
; auth/changeuser nemo
.I ...
.P2
.ix [changeuser]
.ix "new account
.ix "new user
.LP
This command is executed in the authentication server. It prompts for
the secret for the new user (which should be only
known to that user, and therefore is typed by him or her), along with
some administrative information. For example, the program asks when
should the account expire, how can the user be reached by email, etc.
.PP
The account created is just a key along with a new user name, that will
be kept encrypted in
.CW /adm/keys .
But this does not allow the new user to use any file servers! Each file server
maintains its own list of users, as you saw. Accounts in the authentication
servers are just for authentication purposes.
.PP
Sometime later, a user might decide to change the secret used for
authentication. This is done with the
.CW passwd
.ix [passwd]
command, which talks directly to the authentication server to change
the secret for the user. This server updates the key using the
.CW /mnt/keys/$user/key
file for the user.
.PP
Because of what we said, you might think that it is necessary for an
administrator to come near each authentication server
to type the password for the host owner. Otherwise, how could
.CW keyfs
decrypt
.CW /adm/keys ?
And the same might apply to file servers and CPU servers. They need
the secret of the host owner to authenticate themselves.
.PP
This is not the case. CPU servers and file servers keep the authentication
domain, the user id of the host owner, and its secret in non-volatile RAM or
.ix NVRAM
.B nvram .
Here,
.I nvram
is just an abstraction, usually implemented using a partition called
.CW nvram
in the hard disk. When a server machine is installed, it is supplied with the
information needed to authenticate. The program
.CW auth/wrkey
.ix [wrkey]
prompts for such information and stores it in the
.CW nvram .
From that point on, the machine can boot unattended. This is very convenient,
specially when considering that CPU servers tend to reboot by themselves when
they loose the connection to the file server.
.PP
There is another place where keys are kept. The
.CW nvram
for the server machines would suffice, because each user knows the
relevant password and can perfectly type it to the
.CW factotum
used when needed. However, users tend to have so many keys these days
that it would be a burden for the user to have to type all of them whenever
they are needed.
.PP
The program
.CW secstore
.ix [secstore]
.ix "secure store"
provides, so called,
.B "single sign on"
to the system. A single sign on facility is one that allows a user to give just
one password (to sign on just once). After that, the user may just access
any of the services he is authorized to use without providing any other secret.
.PP
The
.CW secstore
is a highly secure file server (it uses strong encryption algorithms)
that may store files for each user. The storage used
by the
.CW secstore
is encrypted
.ix [factotum]
using the host owner key. Besides, to prevent the host owner from accessing
the secure files for a user, the files stored are encrypted with the user key
before sending them to the
.CW secstore .
.PP
The most popular use for
.CW secstore
is keeping a file with all the keys for a user, using the format expected by
.CW factotum .
When a user has an account in the
.CW secstore
file server,
.CW factotum
prompts the user for the secret used to access such store. Then, it
retrieves a file named
.CW factotum
from the secure store for the user that is supposed to contain all the user keys.
Because all the keys are now known to
.CW factotum ,
the user is no longer bothered to supply secrets.
.PP
.BS 2 "What now?
.LP
Before concluding, it seemed necessary to note that there are many
other tools for security in Plan 9, like in most other systems. Not to talk
about tools for cryptography, which are the building blocks for security
protocols and therefore, also available in the system.
.PP
For example, it is important in a distributed system to encrypt the connections
between processes running at different machines so that causal users
tapping on the network do not see the data exchanged in clear.
.PP
While using Plan 9, the commands provided by the system try to make
sure that the system remains secure. For example,
.CW passwd
may be run only on a terminal, to change the password. Running it on a
CPU server would mean that the characters might be sent in clear from the
terminal to the CPU server. These days, connections to CPU servers are
usually encrypted, but historically this was an issue and
.CW passwd
refused to run at a CPU server.
.PP
The
.CW AuthInfo
structure contains two fields,
.CW nsecret
and
.CW secret
with a shared secret provided from the authentication server to both the
client and the server. This shared secret could be used to encrypt and
secure the communication channel, before exchanging data between the
client and the server process. We did not show how to do this, but that
is why you have manual pages, which contain examples.
.PP
The
.I tls (3)
.ix TLS
devices provides transparent encryption for network connections.  It was
not discussed here. But it is important to exchange data with servers or clients
requiring TLS to secure their connections.
.PP
Libraries functions, like those described in
.I encrypt (2),
.ix encrypt
provide facilities to encrypt and decrypt data. These ones in particular use
the DES encryption algorithm.
.ix DES
.PP
You have come a long way. It is likely that you have found many different and
new concepts while reading this book. What remains is to practice, and use them.
Hopefully, now that you understand what an operating system is, and how its
abstractions, calls, and commands help you use the machine, you will not
be scared of reading the reference manual that is usually contained along with
each operating system. Good luck.
.ix "good~luck
.SH
Problems
.IP 1
Use Plan 9 to do things you know how to do with other systems.
.IP 2
Optimize answers to the previous question
.ds CH
.bp
 \c
.bp
 \c
