
CROSS_COMPILE ?= sparc-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

CFLAGS ?= -O2
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
CFLAGS += -I../../include
LIBS := -lm -lrt

SRCS := $(wildcard *.c)

TARGETS = $(SRCS:.c=.exe)

.SUFFIXES: .c .exe

all: $(TARGETS)

%.exe: %.c
	$(CC) $(CFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f $(TARGETS)
	rm -f *.o *.lst


.PHONY: clean
