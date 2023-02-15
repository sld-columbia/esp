# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
INCDIR := -I../include -I../../common/include
CFLAGS ?=
CFLAGS += -Wall
CFLAGS += -Werror
CFLAGS += -D$(MODE)

ifeq ("$(MODE)", "LINUX")
INCDIR += -I$(DESIGN_PATH)/socgen/esp
ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
else # ("$(CPU_ARCH)", "leon3")
CROSS_COMPILE ?= sparc-linux-
endif

CFLAGS += -O3
else # ("$(MODE)", "BAREC")
CPU_SOFT_PATH := ../../../../$(CPU_ARCH)
INCDIR += -I$(DESIGN_PATH)

ifeq ("$(CPU_ARCH)", "leon3")
CFLAGS += -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -L../probe
CROSS_COMPILE ?= sparc-elf-
else #("$(CPU_ARCH), "ariane")
CFLAGS += -O2
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

ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-elf-
else # ("$(CPU_ARCH)", "ibex")
CROSS_COMPILE ?= riscv32-unknown-elf-
endif

endif
endif

CFLAGS += $(INCDIR)

OUT := $(BUILD_PATH)/libmonitors.a
OBJS := $(BUILD_PATH)/libmonitors.o

all: $(OUT)

.SUFFIX: .c .o

$(BUILD_PATH)/%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(OUT): $(OBJS)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean:
	rm -rf $(BUILD_PATH)

.PHONY: all clean
