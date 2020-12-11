
CFLAGS += $(EXTRA_CFLAGS)
CFLAGS += -Wall
CFLAGS += -I../../include
CFLAGS += -L$(BUILD_PATH)/../../probe
CFLAGS += -I$(DESIGN_PATH)
CFLAGS +=-std=gnu99
CFLAGS +=-O2

LIBS := -lm -lprobe

CROSS_COMPILE ?= sparc-elf-
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
	CROSS_COMPILE=$(CROSS_COMPILE) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../probe $(MAKE) -C ../../probe
	$(CC) $(CFLAGS) -o $@ $< $(BUILD_PATH)/fft_test.o $(LIBS)

$(BUILD_PATH)/%.bin: $(BUILD_PATH)/%.exe
	$(CROSS_COMPILE)objcopy -O binary --change-addresses -0x40000000 $< $@

clean:
	rm -rf $(BUILD_PATH)
