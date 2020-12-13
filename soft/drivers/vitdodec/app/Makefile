
OBJS := vitdodec.exe

include ../../common.mk

vitdodec.exe: vitdodec.c do_decoding.o
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../test
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< do_decoding.o $(LDFLAGS)

do_decoding.o: do_decoding.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $<
