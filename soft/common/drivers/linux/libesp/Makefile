# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
INCDIR = -I../include -I../../common/include

ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARCH ?= riscv
else # ("$(CPU_ARCH)", "leon3")
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc
endif

CFLAGS ?=
CFLAGS += $(INCDIR)
CFLAGS += -O3
CFLAGS += -Wall
CFLAGS += -Werror

OUT := $(BUILD_PATH)/libesp.a
OBJS := $(BUILD_PATH)/libesp.o

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
