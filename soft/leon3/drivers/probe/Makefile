

CFLAGS := -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall -Werror
CFLAGS += -I../include

target: libprobe.a

include ../common_bare.mk

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

libprobe.a: probe.o
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@


.PHONY: target
