
CFLAGS ?=
CFLAGS += -Wall
CFLAGS += -I../../include
CFLAGS += -L../../probe

LIBS := -lm -lprobe

CROSS_COMPILE ?= sparc-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.exe)

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	$(RM) $(OBJS) *.o *.a

