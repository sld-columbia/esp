TARGET=sparc-rtems
CC=$(TARGET)-gcc
OBJDUMP=$(TARGET)-objdump
CFLAGS  =
CFLAGS += -Os
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -pedantic

all: bdinit.o bdinit.dis

.PHONY: bdinit.o
bdinit.o: bdinit.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: bdinit.dis
bdinit.dis: bdinit.o
	$(OBJDUMP) -d $< > $@

clean:
	$(RM) bdinit.o
	$(RM) bdinit.dis

