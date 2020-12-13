CPU_SOFT_PATH := ../../../$(CPU_ARCH)

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
LDFLAGS += $(COMMON)/syscalls.c
LDFLAGS += $(RISCV_TESTS)/benchmarks/common/crt.S
LDFLAGS += -T $(RISCV_TESTS)/benchmarks/common/test.ld
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

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -I../../include
CFLAGS += -I$(DESIGN_PATH)
CFLAGS +=-std=gnu99
CFLAGS +=-O2
LDFLAGS += -lm
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)$(LD)

SRCS := $(wildcard *.c)
HEADERS := $(wildcard *.h)
OBJS := $(SRCS:.c=.exe)
OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))
BINS := $(OBJS:.exe=.bin)

all: $(OBJS) $(BINS)

$(BUILD_PATH)/fft_test.o: ../../test/fft_test.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_PATH)/%.exe: %.c $(wildcard ../../probe/*.c) $(BUILD_PATH)/fft_test.o $(HEADERS)
	CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../probe $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@ $< $(BUILD_PATH)/fft_test.o $(LDFLAGS) $(BUILD_PATH)/../../probe/libprobe.a

$(BUILD_PATH)/%.bin: $(BUILD_PATH)/%.exe
	$(CROSS_COMPILE)objcopy -O binary $(OBJCPFLAGS) $< $@

clean:
	rm -rf $(BUILD_PATH)
