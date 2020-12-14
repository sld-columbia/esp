MDDR_APB        = 0x70001000
SERDES_APB      = 0x70004000

SHAREDIR        = ../shared
MICROSEMIDIR    = ../microsemi
GENTOOL         = $(MICROSEMIDIR)/genregtable.tcl
BDINIT          = $(MICROSEMIDIR)/bdinit.S

HOST=sparc-gaisler-elf-
CC=$(HOST)gcc
CFLAGS  =
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -pedantic
CFLAGS += -I.
ADDRFLAGS  =
ADDRFLAGS += -DMDDR_APB=$(MDDR_APB)
ADDRFLAGS += -DSERDES_APB=$(SERDES_APB)

.PHONY: bdinit.o
bdinit.o: $(BDINIT) mddr_init.inc serdes_init.inc
	$(CC) -Os $(CFLAGS) $(ADDRFLAGS) -c $(BDINIT) -o $@

mddr_init.inc: mddr_init.reg
	$(GENTOOL) < $< > $@

serdes_init.inc: serdes_init.reg
	$(GENTOOL) < $< > $@

clean:
	$(RM) bdinit.o
	$(RM) mddr_init.inc
	$(RM) serdes_init.inc

