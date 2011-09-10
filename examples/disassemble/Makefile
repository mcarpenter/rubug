
CC=gcc
RM=rm -f

.PHONY: all
all: disassemble

fuzzbo: Makefile fuzzbo.c 
	$(CC) -o disassemble disassemble.c

.PHONY:clean
clean:
	$(RM) core disassemble

