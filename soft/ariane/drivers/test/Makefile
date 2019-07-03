
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARRCH ?= riscv

CFLAGS ?= -O3
CFLAGS += -fno-builtin-cos -fno-builtin-sin
CFLAGS += -Wall -Werror
CFLAGS += -I../include

OUT := libtest.a
OBJS := test.o le.o wami.o fft.o

all: $(OUT)

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(OUT): $(OBJS)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean:
	$(RM) *.o
	$(RM) $(OUT)

.PHONY: all clean
