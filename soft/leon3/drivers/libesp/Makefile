
INCDIR  =
INCDIR += -I../include
INCDIR += -I../dummy/linux

CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc

CFLAGS ?=
CFLAGS += $(INCDIR)
CFLAGS += -O3
CFLAGS += -Wall
CFLAGS += -Werror

OUT := libesp.a
OBJS := libesp.o

all: $(OUT)

.SUFFIX: .c .o

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(OUT): $(OBJS)
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean:
	$(RM) *.o
	$(RM) $(OUT)


.PHONY: all clean

