
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -O3
# uclibc does not have sinf()
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc -L../../test -L../../libesp

LDFLAGS += -lm -lrt -lpthread -lesp -ltest -lcontig

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	$(RM) $(OBJS) *.o $(TARGET)


.PHONY: all clean

