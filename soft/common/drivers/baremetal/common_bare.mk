# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
CPU_SOFT_PATH := $(DRIVERS)/../../../$(CPU_ARCH)

ifeq ("$(CPU_ARCH)", "leon3")
CFLAGS += -Wall
CFLAGS += -L$(BUILD_PATH)/../../probe
LDFLAGS += -lprobe
OBJCPFLAGS := --change-addresses -0x40000000
CROSS_COMPILE ?= sparc-elf-
else
RISCV_TESTS = $(CPU_SOFT_PATH)/riscv-tests
BOOTROM = $(CPU_SOFT_PATH)/bootrom
COMMON = $(CPU_SOFT_PATH)/common
CFLAGS += -I$(RISCV_TESTS)/env
CFLAGS += -I$(RISCV_TESTS)/benchmarks/common
CFLAGS += -I$(BOOTROM)
CFLAGS += -I$(CPU_SOFT_PATH)/riscv-pk/machine
CFLAGS += -mcmodel=medany
CFLAGS += -static
CFLAGS += -ffast-math
CFLAGS += -fno-common
CFLAGS += -fno-builtin-printf
CFLAGS += -nostartfiles
LDFLAGS += -lgcc
LDFLAGS_RISCV = $(COMMON)/syscalls.c
LDFLAGS_RISCV += $(RISCV_TESTS)/benchmarks/common/crt.S
LDFLAGS_RISCV += -T $(RISCV_TESTS)/benchmarks/common/test.ld
OBJCPFLAGS :=
ifeq ("$(CPU_ARCH)", "ariane")
CFLAGS += -nostdlib
CROSS_COMPILE ?= riscv64-unknown-elf-
else # ("$(CPU_ARCH)", "ibex")
CFLAGS += -march=rv32imc -mabi=ilp32
CFLAGS += -mstrict-align
LDFLAGS += -march=rv32imc -mabi=ilp32
CROSS_COMPILE ?= riscv32-unknown-elf-
endif
endif

SRCS := $(wildcard *.c)
HEADERS := $(wildcard *.h) $(wildcard $(DRIVERS)/include/*.h)
HEADERS += $(wildcard $(DRIVERS)/../common/include/*.h) $(wildcard $(DESIGN_PATH)/*.h)
SRCS_PROBE := $(wildcard $(DRIVERS)/probe/*.c) 
ifeq ($(APPNAME),)
EXES := $(SRCS:.c=.exe)
EXES := $(addprefix  $(BUILD_PATH)/, $(EXES))
BINS := $(EXES:.exe=.bin)
else
SRCS := $(filter-out $(APPNAME).c, $(SRCS))
OBJS := $(SRCS:.c=.o)
OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))
SRC := $(APPNAME).c
EXE := $(BUILD_PATH)/$(APPNAME).exe
BIN := $(BUILD_PATH)/$(APPNAME).bin
endif
CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -I$(DESIGN_PATH)
CFLAGS +=-std=gnu99
CFLAGS +=-O2
CFLAGS += -L$(BUILD_PATH)/../../monitors
LDFLAGS += -lm
LDFLAGS += -lmonitors
LDFLAGS += $(BUILD_PATH)/../../probe/libprobe.a
LDFLAGS += $(BUILD_PATH)/../../monitors/libmonitors.a
LDFLAGS += $(BUILD_PATH)/../../utils/baremetal/libutils.a
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

all: $(OBJS) $(EXES) $(EXE) $(BINS) $(BIN)

ifneq ($(APPNAME),)
$(BUILD_PATH)/%.o: %.c $(HEADERS)
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../probe $(MAKE) -C $(DRIVERS)/probe
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../monitors MODE=BAREC \
			 $(MAKE) -B -C $(DRIVERS)/../common/monitors
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../utils/baremetal $(MAKE) -C $(DRIVERS)/utils
	$(CC) $(CFLAGS) -c $< -o $@ $(LDFLAGS)
endif

$(BUILD_PATH)/%.exe: %.c $(OBJS) $(SRCS_PROBE) $(HEADERS)
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../probe $(MAKE) -C $(DRIVERS)/probe
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../monitors MODE=BAREC \
			 $(MAKE) -B -C $(DRIVERS)/../common/monitors
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../utils/baremetal $(MAKE) -C $(DRIVERS)/utils
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS_RISCV) $(LDFLAGS) $(OBJS)

$(BUILD_PATH)/%.bin: $(BUILD_PATH)/%.exe
	$(CROSS_COMPILE)objcopy -O binary $(OBJCPFLAGS) $< $@

clean:
	rm -rf $(BUILD_PATH)
