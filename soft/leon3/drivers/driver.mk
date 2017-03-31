all: check Module.symvers
	make -C $(KSRC) M=`pwd`

Module.symvers:
	$(MAKE) -C $(ESP_CORE_PATH)
	cp $(ESP_CORE_PATH)/$@ .

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif
.PHONY: check

clean: check
	$(MAKE) -C $(KSRC) M=`pwd` clean

help: check
	$(MAKE) -C $(KSRC) M=`pwd` help
.PHONY: all clean help
