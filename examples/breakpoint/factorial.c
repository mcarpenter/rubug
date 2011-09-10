
#include <stdio.h>
#include <stdlib.h>

int fac(int);

int main(int argc, char *argv[]) {

    int n;
    int nfac;
    
    n = atoi(argv[1]);
    nfac = fac(n);
    printf("%i! = %i\n", n, nfac);
    return 0;

}

int fac(int n) {

    if(0 == n) return 1;
    return n * fac(n-1);

}
