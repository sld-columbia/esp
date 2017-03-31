
CC := $(CROSS_COMPILE)gcc

CFLAGS ?= -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
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
