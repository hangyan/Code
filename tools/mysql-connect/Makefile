cc=gcc
INCLUDES= -I/usr/include/mysql
LIBS=-lmysqlclient

all:client
main.o:main.c common.h
	$(CC) -c $(INCLUDES) main.c
common.o:common.c common.h
	$(CC) -c $(INCLUDES) common.c
client:main.o common.o
	$(CC) -o client main.o common.o $(LIBS)

clean:
	rm -f client main.o common.o
