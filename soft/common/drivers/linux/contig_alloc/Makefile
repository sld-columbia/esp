# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
CFLAGS := -Wall -Werror -O3 -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -L./
LIBCONTIG := libcontig.a

target: driver $(LIBCONTIG) contig_alloc-libtest

include ../driver.mk

driver: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) make -C $(KSRC) M=`pwd`

contig_alloc-libtest: libtest.c $(LIBCONTIG)
	$(CROSS_COMPILE)gcc $(CFLAGS) $< -o $@ -lcontig

%.o: %.c
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $^ -o $@

$(LIBCONTIG): lib.o
	$(CROSS_COMPILE)ar r $@ $^
	$(CROSS_COMPILE)ranlib $@

clean-libcontig: clean
	$(RM) *.o
	$(RM) $(LIBCONTIG)
	$(RM) contig_alloc-libtest

.PHONY: target clean clean-libcontig
