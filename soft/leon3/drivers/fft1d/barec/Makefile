
CFLAGS ?=
CFLAGS += -Wall
CFLAGS += -I../../include
CFLAGS += -L../../probe

LIBS := -lm -lprobe

CROSS_COMPILE ?= sparc-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS = fft1d.exe

all: $(OBJS)

%.exe: %.c
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../probe clean
	$(RM) $(OBJS) *.o

