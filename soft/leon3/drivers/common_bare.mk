
CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -Wall
CFLAGS += -I../../include
CFLAGS += -L../../probe

LIBS := -lm -lprobe

CROSS_COMPILE ?= sparc-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.exe)
BINS := $(OBJS:.exe=.bin)

all: $(OBJS) $(BINS)

fft_test.o: ../../test/fft_test.c
	$(CC) $(CFLAGS) -c $<

%.exe: %.c $(wildcard ../../probe/*.c) fft_test.o
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@ $< fft_test.o $(LIBS)

%.bin: %.exe
	$(CROSS_COMPILE)objcopy -O binary --change-addresses -0x40000000 $< $@

clean:
	$(RM) $(OBJS) $(BINS) *.o *.a

