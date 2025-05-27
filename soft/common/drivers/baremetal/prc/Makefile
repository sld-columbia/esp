
# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
CPU_SOFT_PATH := ../../../../$(CPU_ARCH)

INCDIR := -I$(DESIGN_PATH)
INCDIR += -I../include
INCDIR += -I../../common/include

CFLAGS := $(INCDIR)
CFLAGS += -Wall
CFLAGS += -Werror

ifeq ("$(CPU_ARCH)", "leon3")
CFLAGS += -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
OBJS_DEP :=
CROSS_COMPILE ?= sparc-elf-
else
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

# include libmonitors
OBJS_DEP += $(BUILD_PATH)/../monitors/libmonitors.o
LDFLAGS += $(BUILD_PATH)/../monitors/libmonitors.a
CFLAGS += -include ../../common/include/monitors.h

target: $(BUILD_PATH)/libprc.a

$(BUILD_PATH)/libprc.a: $(BUILD_PATH)/libprc.o $(OBJS_DEP)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

$(BUILD_PATH)/libprc.o: prc.c
	mkdir -p $(BUILD_PATH)/prc
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@ $(LDFLAGS)

clean:
	rm -rf $(BUILD_PATH)

.PHONY: target clean
