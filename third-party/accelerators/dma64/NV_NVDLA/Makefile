
IP := $(shell basename $$PWD)

OUT_PATH := $(PWD)/out

IP_PATH := $(PWD)/ip

SW_PATH := $(PWD)/sw

ifndef IP_PATH
$(error variable IP_PATH for $(IP) is not defined)
endif

all: vmod umd kmd

clean: vmod-clean umd-clean kmd-clean

distclean: clean

.PHONY: all clean distclean

## RTL ##
vmod:
	@if ! test -e $(IP_PATH)/tree.make; then \
		cp config/tree.make $(IP_PATH); \
	fi;
	@cd $(IP_PATH); \
	./tools/bin/tmake -build vmod;

vmod-clean:
	@rm -rf $$(readlink $(PWD)/out)

.PHONY: vmod vmod-clean

## User-space application and libraries ##
umd:
	@cd $(SW_PATH)/umd; \
	$(MAKE) TOOLCHAIN_PREFIX=$(CROSS_COMPILE) TOP=$(SW_PATH)/umd

umd-clean:
	@cd $(SW_PATH)/umd; \
	 $(MAKE) clean

.PHONY: umd umd-clean


## Device drivers ##
kmd:
	@cd sw/kmd; \
	$(MAKE) KDIR=$(KSRC) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)

kmd-clean:
	@cd sw/kmd; \
	$(MAKE) KDIR=$(KSRC) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

.PHONY: kmd kmd-clean
