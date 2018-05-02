
CFLAGS ?= -O3
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc -L../../test
CFLAGS += -I./inc
LIBS := -lm -lrt -lcontig -ltest

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS := debayer.exe

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< ./src/wami_debayer.c $(LIBS)

clean:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc clean-libcontig
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test clean
	$(RM) $(OBJS) *.o

.PHONY: all clean
