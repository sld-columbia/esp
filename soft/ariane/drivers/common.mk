
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARCH ?= riscv

CFLAGS ?= -O3
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc -L../../test
LIBS := -lm -lrt -ltest -lcontig

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

all: $(OBJS)

%.exe: %.c $(wildcard ../../test/*.c)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	$(RM) $(OBJS) *.o


.PHONY: all clean

