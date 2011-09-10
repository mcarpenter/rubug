
#include <stdio.h>
#include <errno.h>

extern int errno;

int main(int argc, char *argv[]) {

    foo();

}

int foo() {

    return printf("errno: %i\n", errno);

}
