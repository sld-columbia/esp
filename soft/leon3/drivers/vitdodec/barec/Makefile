target: vitdodec.exe

include ../../common_bare.mk

vitdodec.exe: vitdodec.c $(wildcard ../../probe/*.c) do_decoding.o
	CROSS_COMPILE=$(CROSS_COMPILE) DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C ../../probe
	$(CC) -I./ $(CFLAGS) -o $@  $(LDFLAGS) $< do_decoding.o ../../probe/libprobe.a

do_decoding.o: do_decoding.c
	$(CC) $(CFLAGS) -c $<
