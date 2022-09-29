
IP := $(shell basename $$PWD)

OUT_PATH := $(PWD)/out

IP_PATH := $(PWD)/ip

SW_PATH := $(PWD)/sw

ifndef IP_PATH
$(error variable IP_PATH for $(IP) is not defined)
endif

all: sw hw

sw: umd kmd

hw: vmod
	@cp config/NV_NVDLA_$(TECH_TYPE).verilog NV_NVDLA.verilog

clean: vmod-clean umd-clean kmd-clean

distclean: clean

.PHONY: all sw hw clean distclean

## RTL ##
vmod:
	@cp config/tree.make $(IP_PATH);
	@cd $(IP_PATH); \
	./tools/bin/tmake -build vmod;

vmod-clean:
	@rm -rf $$(readlink $(PWD)/out)

.PHONY: vmod vmod-clean

## User-space application and libraries ##
umd:
	@cd $(SW_PATH)/umd; \
	$(MAKE) TOOLCHAIN_PREFIX=$(CROSS_COMPILE) TOP=$(SW_PATH)/umd runtime

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
