WFLAGS ?= -Wall -Wextra -Wmissing-prototypes -Wdiv-by-zero -Wbad-function-cast \
		  -Wcast-align -Wcast-qual -Wfloat-equal -Wmissing-declarations \
		  -Wnested-externs -Wno-unknown-pragmas -Wpointer-arith -Wredundant-decls \
		  -Wstrict-prototypes -Wswitch-enum -Wno-type-limits

CFLAGS ?= -O3 -march=native -fno-exceptions $(WFLAGS)

main.dylib: main.o
	$(CC) $< -shared -o $@

main: main.o
	$(CC) $< -o $@

main.o: main.c
	$(CC) -c $(CFLAGS) $< -o $@
