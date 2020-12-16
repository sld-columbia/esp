include ../driver.mk

CFLAGS := -Wall -Werror -O3 -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -L.

Module.symvers:
	$(MAKE) -C ../esp_cache ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS)
	$(MAKE) -C ../contig_alloc ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS)
	cat ../esp_cache/$@ > $@
	cat ../contig_alloc/$@ >> $@
