
CFLAGS ?= -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L../../contig_alloc -L../../test
CFLAGS += -I./inc
LIBS := -lm -lrt -lcontig -ltest

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS = change_detection.exe

SRCS := src/wami_gmm.c \
	src/wami_morpho.c

HDRS := inc/wami_gmm.h \
	inc/wami_morpho.h \
	inc/wami_params.h


all: $(OBJS)

%.exe: %.c $(SRCS)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(SRCS) $(LIBS)

clean:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc clean-libcontig
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test clean
	$(RM) $(OBJS) *.o

.PHONY: all clean
