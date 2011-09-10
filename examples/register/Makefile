
CC=gcc
RM=rm -f

.PHONY: all
all: register

fuzzbo: Makefile fuzzbo.c 
	$(CC) -o register register.c

.PHONY:clean
clean:
	$(RM) core register

