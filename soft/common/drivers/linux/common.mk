ifeq ("$(CPU_ARCH)", "ariane")
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARCH ?= riscv
else # ifeq ("$(CPU_ARCH)", "leon3")
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc
# uclibc does not have sinf()
CFLAGS += -fno-builtin-cos -fno-builtin-sin
endif

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -O3
CFLAGS += -Wall
CFLAGS += -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -I../include
CFLAGS += -L$(BUILD_PATH)/../../../contig_alloc -L$(BUILD_PATH)/../../../test
CFLAGS += -L$(BUILD_PATH)/../../../libesp -L$(BUILD_PATH)/../../../utils/linux

LDFLAGS += -lm -lrt -lpthread -lesp -ltest -lcontig -lutils

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))
HEADERS := $(wildcard *.h)

all: $(OBJS)

$(BUILD_PATH)/%.exe: %.c $(HEADERS)
	CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS) $(MAKE) -C $(BUILD_PATH)/../../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../test $(MAKE) -C $(DRIVERS)/test
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../libesp $(MAKE) -C $(DRIVERS)/libesp
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../utils/linux $(MAKE) -C $(DRIVERS)/utils
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -rf $(BUILD_PATH)

.PHONY: all clean
