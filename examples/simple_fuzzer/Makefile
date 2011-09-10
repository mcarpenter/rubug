
CC=gcc
RM=rm -f

.PHONY: all
all: simple_fuzzer

simple_fuzzer: Makefile simple_fuzzer.c 
	$(CC) -o simple_fuzzer simple_fuzzer.c

.PHONY:clean
clean:
	$(RM) core simple_fuzzer

