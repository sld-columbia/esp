# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARCH ?= riscv
else # ("$(CPU_ARCH)", "leon3")
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc
endif

CFLAGS ?= -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall -Werror
CFLAGS += -I../include -I../../common/include

OUT := $(BUILD_PATH)/libutils.a
HEADERS := $(wildcard ../include/utils/*.h) $(wildcard ../../common/include/utils/*.h)
SRCS := $(wildcard *.c) $(wildcard ../../common/utils/*.c)
OBJS := $(SRCS:../../common/utils/%=%)
OBJS := $(OBJS:.c=.o)
OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))

all: $(OUT)

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
