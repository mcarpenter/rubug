
EXAMPLES=breakpoint disassemble function_address register simple_fuzzer

.PHONY: all
all:
	for ex in $(EXAMPLES) ; do $(MAKE) -C $$ex ; done

.PHONY:clean
clean:
	for ex in $(EXAMPLES) ; do $(MAKE) -C $$ex clean ; done

