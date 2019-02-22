
CFLAGS ?= -O3

# uclibc does not have sinf()
CFLAGS += -Wall -Werror
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc
LIBS := -lm -lrt -lcontig

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS := synth.exe

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc clean-libcontig
	$(RM) $(OBJS) *.o


.PHONY: all clean
