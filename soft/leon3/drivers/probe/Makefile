CFLAGS := -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall -Werror
CFLAGS += -I../include

target: $(BUILD_PATH)/libprobe.a

include ../common_bare.mk

$(BUILD_PATH)/%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(BUILD_PATH)/libprobe.a: $(BUILD_PATH)/probe.o
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@


.PHONY: target
