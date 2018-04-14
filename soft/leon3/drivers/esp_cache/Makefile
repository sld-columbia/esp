
CFLAGS := -Wall -Werror -O3 -I../include -L.

all: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd`

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif

.PHONY: check

clean: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` clean

help: check
	ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C $(KSRC) M=`pwd` help

.PHONY: all clean help check
