INCDIR  =
INCDIR += -I../include

CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc

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

