
CFLAGS := -O2
EXTRA_CFLAGS += -Wall -Werror
CFLAGS += -I../include
CFLAGS += -I../../riscv-tests/env
CFLAGS += -I../../riscv-tests/benchmarks/common
CFLAGS += -I../../bootrom
CFLAGS += -I$(DESIGN_PATH)
CFLAGS += -mcmodel=medany
CFLAGS += -static
CFLAGS += -std=gnu99
CFLAGS += -ffast-math
CFLAGS += -fno-common
CFLAGS += -fno-builtin-printf
CFLAGS += -nostdlib
CFLAGS += -nostartfiles

LDFLAGS := -lm
LDFLAGS += -lgcc

CROSS_COMPILE ?= riscv64-unknown-elf-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

VPATH := ./

libprobe.a: syscalls.o probe.o uart.o fdt.o
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

%.o: %.c
	$(CROSS_COMPILE)gcc $(EXTRA_CFLAGS) $(CFLAGS) -c $^ -o $@

syscalls.o: syscalls.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

clean:
	$(RM) $(OBJS) *.o *.a

.PHONY: clean
