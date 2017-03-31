
CFLAGS := -Wall -Werror -O3 -I../include -L./

LIBCONTIG := libcontig.a

all: driver contig_alloc-test $(LIBCONTIG) contig_alloc-libtest

driver: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KSRC) M=`pwd`

contig_alloc-test: test.c
	$(CROSS_COMPILE)gcc $(CFLAGS) $^ -o $@
contig_alloc-libtest: libtest.c $(LIBCONTIG)
	$(CROSS_COMPILE)gcc $(CFLAGS) $< -o $@ -lcontig

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif
.PHONY: check

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(LIBCONTIG): lib.o
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean: clean-libcontig check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` clean

clean-libcontig:
	$(RM) *.o
	$(RM) $(LIBCONTIG)
	$(RM) contig_alloc-test
	$(RM) contig_alloc-libtest

help: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` help

.PHONY: all clean clean-libcontig help
