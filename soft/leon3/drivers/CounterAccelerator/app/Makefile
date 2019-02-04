
CFLAGS ?= -O3

# uclibc does not have sinf()
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc -L../../test
LIBS := -lm -lrt -ltest -lcontig

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS := CounterAccelerator.exe

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc clean-libcontig
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test clean
	$(RM) $(OBJS) *.o


.PHONY: all clean
