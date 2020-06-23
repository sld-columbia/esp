
RISCV_TESTS = ../../../riscv-tests
BOOTROM = ../../../bootrom
COMMON = ../../../common

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -I../../include
CFLAGS +=-I$(RISCV_TESTS)/env
CFLAGS +=-I$(RISCV_TESTS)/benchmarks/common
CFLAGS +=-I$(BOOTROM)
CFLAGS += -I$(DESIGN_PATH)
CFLAGS +=-mcmodel=medany
CFLAGS +=-static
CFLAGS +=-std=gnu99
CFLAGS +=-O2
CFLAGS +=-ffast-math
CFLAGS +=-fno-common
CFLAGS +=-fno-builtin-printf
CFLAGS +=-nostdlib
CFLAGS +=-nostartfiles

LDFLAGS += -lm
LDFLAGS += -lgcc
LDFLAGS += $(COMMON)/syscalls.c
LDFLAGS += $(RISCV_TESTS)/benchmarks/common/crt.S
LDFLAGS += -T $(RISCV_TESTS)/benchmarks/common/test.ld


CROSS_COMPILE ?= riscv64-unknown-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.exe)
BINS := $(OBJS:.exe=.bin)

all: $(OBJS) $(BINS)

fft_test.o: ../../test/fft_test.c
	$(CC) $(CFLAGS) -c $<

%.exe: %.c $(wildcard ../../probe/*.c) fft_test.o
	CROSS_COMPILE=$(CROSS_COMPILE) DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@  $(LDFLAGS) $< fft_test.o ../../probe/libprobe.a

%.bin: %.exe
	$(CROSS_COMPILE)objcopy -O binary $< $@

clean:
	$(RM) $(OBJS) $(BINS) *.o *.a

