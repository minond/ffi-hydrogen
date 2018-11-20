WFLAGS ?= -Wall -Wextra -Wmissing-prototypes -Wdiv-by-zero -Wbad-function-cast -Wcast-align -Wcast-qual -Wfloat-equal -Wmissing-declarations -Wnested-externs -Wno-unknown-pragmas -Wpointer-arith -Wredundant-decls -Wstrict-prototypes -Wswitch-enum -Wno-type-limits
CFLAGS ?= -Os -march=native -fno-exceptions $(WFLAGS)
CFLAGS += -I ./libhydrogen -I ./stringencoders/src
LDFLAGS ?=

demo: main.c
	$(CC) $(CFLAGS) -O3 -o demo.o main.c -c
	$(CC) $(LDFLAGS) -o demo demo.o
	rm demo.o
