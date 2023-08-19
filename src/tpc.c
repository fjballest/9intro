#include <u.h>
#include <libc.h>
#include <thread.h>
enum {Nmsgs = 4 };
Channel* bufc;

void
producer(void *arg)
{
	char*	id = arg;
	char*	msg;
	int	i;

	for (i = 0; i < 5 ; i++){
		msg = smprint("%s%d", id, i);
		send(bufc, &msg);
	}
	send(bufc, nil);
	threadexits(nil);
}

void
consumer(void*)
{
	char*	msg;
	do {
		recv(bufc, &msg);
		if (msg != nil){	// consume it
			print("%s ", msg);
			free(msg);
		}
	} while(msg != nil);
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	bufc = chancreate(sizeof(char*), Nmsgs);
	threadcreate(producer, "a", 8*1024);
	threadcreate(producer, "b", 8*1024);
	threadcreate(consumer, nil, 8*1024);
	consumer(nil);
}
