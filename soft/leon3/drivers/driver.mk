
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc

ESP_CORE_PATH ?= ../../esp

all: check Module.symvers
	make -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif
.PHONY: check

clean: check
	$(MAKE) -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) clean

help: check
	$(MAKE) -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) help
.PHONY: all clean help
