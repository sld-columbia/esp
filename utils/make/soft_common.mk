# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Software build folder ###

SOFT_BUILD = $(DESIGN_PATH)/soft-build
BUILD_DRIVERS = $(SOFT_BUILD)/drivers

soft-build:
	@mkdir -p $(BUILD_DRIVERS)/contig_alloc
	@mkdir -p $(BUILD_DRIVERS)/esp
	@mkdir -p $(BUILD_DRIVERS)/esp_cache
	@mkdir -p $(BUILD_DRIVERS)/libesp
	@mkdir -p $(BUILD_DRIVERS)/probe
	@mkdir -p $(BUILD_DRIVERS)/test
	@ln -sf $(DRIVERS)/contig_alloc/* $(BUILD_DRIVERS)/contig_alloc
	@ln -sf $(DRIVERS)/esp/* $(BUILD_DRIVERS)/esp
	@ln -sf $(DRIVERS)/esp_cache/* $(BUILD_DRIVERS)/esp_cache
	@ln -sf $(DRIVERS)/driver.mk $(BUILD_DRIVERS)

soft-build-clean:

soft-build-distclean: soft-build-clean
	$(QUIET_CLEAN)$(RM) soft-build

### Sysroot ###

sysroot/opt/drivers-esp/contig_alloc.ko: linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/contig_alloc
	$(QUIET_CP)cp $(BUILD_DRIVERS)/contig_alloc/contig_alloc.ko $@

sysroot/opt/drivers-esp/esp_cache.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.c) $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/esp_cache
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_cache.ko $@

sysroot/opt/drivers-esp/esp_private_cache.ko: sysroot/opt/drivers-esp/esp_cache.ko
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_private_cache.ko $@

sysroot/opt/drivers-esp/esp.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: linux-build/vmlinux socmap.vhd soft-build
	@touch sysroot
	@$(MAKE) sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_private_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp.ko
	@$(MAKE) -C $(DRIVERS)/dvi/app
	@mkdir -p sysroot/applications/dvi; cp $(BUILD_DRIVERS)/dvi/app/*.exe sysroot/applications/dvi
	@$(MAKE) accelerators-driver
	@$(MAKE) accelerators-app
	@touch sysroot
	@chmod a+x S64esp; cp S64esp sysroot/etc/init.d/
	$(QUIET_MAKE)$(MAKE) linux-build/vmlinux

sysroot-clean:
	$(QUIET_CLEAN)$(RM) sysroot.files sysroot.cpio
	@$(MAKE) --quiet -C $(DRIVERS)/dvi/app clean
	@if test -e linux-build; then \
		$(MAKE) --quiet accelerators-driver-clean; \
	fi;
	@$(MAKE) --quiet accelerators-app-clean

sysroot-distclean: sysroot-clean
	$(QUIET_CLEAN)$(RM) sysroot


### Linux ###

linux-build:
	$(QUIET_MKDIR)mkdir -p $@


### Bare-metal ###

barec:
	$(QUIET_MKDIR)mkdir -p $@

barec-all: soft-build
	@mkdir -p barec/dvi
	@mkdir -p $(BUILD_DRIVERS)/dvi/barec
	@CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_DRIVERS)/dvi/barec $(MAKE) -C $(DRIVERS)/dvi/barec
	@cp $(BUILD_DRIVERS)/dvi/barec/*.bin barec/dvi
	@$(MAKE) accelerators-barec

barec-distclean:
	$(QUIET_CLEAN)$(RM) barec
	@DRIVERS=$(DRIVERS) CPU_ARCH=$(CPU_ARCH) BUILD_PATH=$(BUILD_DRIVERS)/dvi/barec $(MAKE) --quiet -C $(DRIVERS)/dvi/barec clean
	@$(MAKE) --quiet accelerators-barec-clean



.PHONY: soft-build soft-build-clean soft-build-distclean
.PHONY: soft soft-clean soft-distclean
.PHONY: linux linux-clean linux-distclean
.PHONY: sysroot-update sysroot-clean sysroot-distclean
.PHONY: barec-distclean barec-all
# The following PHONY guarantees that we execute the program set by TEST_PROGRAM
.PHONY: systest.bin ram.srec
