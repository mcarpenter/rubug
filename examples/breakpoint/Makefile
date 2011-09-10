
CC=gcc
RM=rm -f

.PHONY: all
all: factorial

factorial: Makefile factorial.c
	$(CC) -o factorial factorial.c

.PHONY:clean
clean:
	$(RM) core factorial

