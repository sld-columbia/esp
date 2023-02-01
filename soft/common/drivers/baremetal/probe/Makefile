# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
CPU_SOFT_PATH := ../../../../$(CPU_ARCH)

ifeq ("$(CPU_ARCH)", "leon3")
CFLAGS := -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -L../probe
OBJS_DEP := 
CROSS_COMPILE ?= sparc-elf-
else
CFLAGS := -O2
CFLAGS += -I$(CPU_SOFT_PATH)/riscv-tests/env
CFLAGS += -I$(CPU_SOFT_PATH)/riscv-tests/benchmarks/common
CFLAGS += -I$(CPU_SOFT_PATH)/bootrom
CFLAGS += -I$(CPU_SOFT_PATH)/riscv-pk/machine
CFLAGS += -mcmodel=medany
CFLAGS += -static
CFLAGS += -std=gnu99
CFLAGS += -ffast-math
CFLAGS += -fno-common
CFLAGS += -fno-builtin-printf
CFLAGS += -nostdlib
CFLAGS += -nostartfiles
LDFLAGS += -lgcc

OBJS_DEP := syscalls.o uart.o fdt.o
OBJS_DEP := $(addprefix  $(BUILD_PATH)/, $(OBJS_DEP))
ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-elf-
else # ("$(CPU_ARCH)", "ibex")
CROSS_COMPILE ?= riscv32-unknown-elf-
endif
endif

CFLAGS += -I../include
CFLAGS += -I../../common/include
CFLAGS += -I$(DESIGN_PATH)
LDFLAGS := -lm
EXTRA_CFLAGS += -Wall -Werror
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

target: $(BUILD_PATH)/libprobe.a

$(BUILD_PATH)/probe.o: probe.c
	$(CROSS_COMPILE)gcc $(EXTRA_CFLAGS) $(CFLAGS) -c $^ -o $@

ifneq ("$(CPU_ARCH)", "leon3")
$(BUILD_PATH)/uart.o: $(CPU_SOFT_PATH)/bootrom/uart.c
	$(CROSS_COMPILE)gcc $(EXTRA_CFLAGS) $(CFLAGS) -c $^ -o $@

$(BUILD_PATH)/syscalls.o: $(CPU_SOFT_PATH)/common/syscalls.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(BUILD_PATH)/fdt.o: fdt.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@
endif

$(BUILD_PATH)/libprobe.a: $(BUILD_PATH)/probe.o $(OBJS_DEP)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean:
	rm -rf $(BUILD_PATH)

.PHONY: target clean
