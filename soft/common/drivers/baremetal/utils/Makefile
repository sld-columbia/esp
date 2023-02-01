# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
CPU_SOFT_PATH := ../../../../$(CPU_ARCH)

CFLAGS ?= -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall -Werror
CFLAGS += -I../include
CFLAGS += -I../../common/include

ifeq ("$(CPU_ARCH)", "leon3")
OBJS_DEP := 
CROSS_COMPILE ?= sparc-elf-
else
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

#CC := $(CROSS_COMPILE)gcc
#LD := $(CROSS_COMPILE)$(LD)

OUT := $(BUILD_PATH)/libutils.a
HEADERS := $(wildcard ../include/utils/*.h) $(wildcard ../../common/include/utils/*.h)
SRCS := $(wildcard *.c) $(wildcard ../../common/utils/*.c)
OBJS := $(SRCS:../../common/utils/%=%)
OBJS := $(OBJS:.c=.o)
OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))

target: $(OUT)

$(BUILD_PATH)/%.o: %.c $(HEADERS)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(BUILD_PATH)/%.o: ../../common/utils/%.c $(HEADERS)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(OUT): $(OBJS)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean:
	rm -rf  $(BUILD_PATH)

.PHONY: all clean
