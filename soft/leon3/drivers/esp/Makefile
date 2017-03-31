
CFLAGS := -Wall -Werror -O3 -I../include -L.

CONTIG_ALLOC_PATH := ../contig_alloc

all: check Module.symvers
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd`

Module.symvers:
	$(MAKE) -C $(CONTIG_ALLOC_PATH)
	cp $(CONTIG_ALLOC_PATH)/$@ .

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif
ifeq ($(CONTIG_ALLOC_PATH),)
	$(error 'Path to contig_alloc in env variable CONTIG_ALLOC_PATH not found. Exiting')
endif

.PHONY: check

clean: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` clean

help: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` help

.PHONY: all clean help check
