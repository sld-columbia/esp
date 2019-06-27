
include ../driver.mk

CONTIG_ALLOC_PATH := ../contig_alloc

CFLAGS := -Wall -Werror -O3 -I../include -L.

Module.symvers:
	$(MAKE) -C ../esp_cache ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	$(MAKE) -C $(CONTIG_ALLOC_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	cat ../esp_cache/$@ > $@
	cat $(CONTIG_ALLOC_PATH)/$@ >> $@
