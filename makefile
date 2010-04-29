CC=gcc
CFLAGS=-s -O3
TARGET=milton

all:
	$(CC) $(CFLAGS) -o $(TARGET) milton.c

install:
	install -m 755 $(TARGET) /usr/bin/
	install -m 644 milton.8 /usr/share/man/man8/

clean:
	rm milton
