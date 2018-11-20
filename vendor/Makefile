.PHONY: libhydrogen

# WFLAGS ?= -Wall -Wextra -Wmissing-prototypes -Wdiv-by-zero -Wbad-function-cast -Wcast-align -Wcast-qual -Wfloat-equal -Wmissing-declarations -Wnested-externs -Wno-unknown-pragmas -Wpointer-arith -Wredundant-decls -Wstrict-prototypes -Wswitch-enum -Wno-type-limits
# CFLAGS ?= -Os -march=native -fno-exceptions $(WFLAGS)
CFLAGS += -I ./libhydrogen
LDFLAGS ?= -Llibhydrogen -l hydrogen

demo: libhydrogen main.c
	$(CC) $(CFLAGS) -o demo.o main.c -c
	$(CC) $(LDFLAGS) -o demo demo.o
	rm demo.o

libhydrogen:
	$(MAKE) -C libhydrogen
