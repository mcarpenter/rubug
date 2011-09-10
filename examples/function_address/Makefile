
CC=gcc
RM=rm -f

.PHONY: all
all: function_address

fuzzbo: Makefile fuzzbo.c 
	$(CC) -o function_address function_address.c

.PHONY:clean
clean:
	$(RM) core function_address

