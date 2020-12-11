
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc

CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -O3
# uclibc does not have sinf()
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall
CFLAGS += -I../../include -I../linux
CFLAGS += -L$(BUILD_PATH)/../../contig_alloc -L$(BUILD_PATH)/../../test -L$(BUILD_PATH)/../../libesp

LDFLAGS += -lm -lrt -lpthread -lesp -ltest -lcontig

CC := gcc
LD := $(CROSS_COMPILE)$(LD)

OBJS := $(addprefix  $(BUILD_PATH)/, $(OBJS))
HEADERS := $(wildcard *.h)

all: $(OBJS)

$(BUILD_PATH)/%.exe: %.c $(HEADERS)
	CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS) $(MAKE) -C $(BUILD_PATH)/../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../test $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../libesp $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -rf $(BUILD_PATH)

.PHONY: all clean
