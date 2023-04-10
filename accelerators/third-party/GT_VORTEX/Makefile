
IP := $(shell basename $$PWD)

OUT_PATH := $(PWD)/out

IP_PATH := $(PWD)/ip

SW_PATH := $(PWD)/sw

ifndef IP_PATH
$(error variable IP_PATH for $(IP) is not defined)
endif

all: sw hw

#sw: umd kmd
sw: umd

hw: rtl

clean: rtl-clean umd-clean kmd-clean

distclean: clean

.PHONY: all sw hw clean distclean

## RTL ##
rtl:
	@cd $(IP_PATH); \
	$(MAKE) all;

rtl-clean:
	@rm -rf $$(readlink $(PWD)/out)

.PHONY: rtl rtl-clean

## User-space application and libraries ##
umd:
	@cd $(SW_PATH)/driver/esp; \
	$(MAKE) CC=$(CROSS_COMPILE) SOFT_BUILD=$(SOFT_BUILD) DRIVERS=$(DRIVERS)/linux all; \
	cd $(SW_PATH)/driver/stub; \
	$(MAKE) CXX=$(CROSS_COMPILE)g++ all; \
	cd $(SW_PATH)/tests; \
	$(MAKE) CXX=$(CROSS_COMPILE)g++ regression; \
	#$(MAKE) CXX=$(CROSS_COMPILE)g++ opencl

umd-clean:
	@cd $(SW_PATH)/umd; \
	 $(MAKE) clean

.PHONY: umd umd-clean


## Device drivers ##
#kmd:
#	@cd sw/kmd; \
#	$(MAKE) KDIR=$(KSRC) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

#kmd-clean:
#	@cd sw/kmd; \
#	$(MAKE) KDIR=$(KSRC) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

.PHONY: kmd kmd-clean
