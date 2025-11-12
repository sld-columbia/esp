# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
include ../driver.mk

CFLAGS := -Wall -Werror -O3 -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -L.

include ./Kbuild
ESPINCLUDE = $(EXTRA_CFLAGS)
export ESPINCLUDE

Module.symvers:
	$(MAKE) -C ../esp_cache ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS)
	$(MAKE) -C ../contig_alloc ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS)
	cat ../esp_cache/$@ > $@
	cat ../contig_alloc/$@ >> $@
	$(info Saving $@ to $@.bak)
	cp $@ $@.bak
