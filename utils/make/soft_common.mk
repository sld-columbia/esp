# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


### Software build folder ###
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
$(SOFT_BUILD)/sysroot/opt/drivers-esp/contig_alloc.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRIVERS) KSRC=$(SOFT_BUILD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/contig_alloc
	$(QUIET_CP)cp $(BUILD_DRIVERS)/contig_alloc/contig_alloc.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.c) $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRIVERS) KSRC=$(SOFT_BUILD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/esp_cache
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_cache.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_private_cache.ko: $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_private_cache.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRIVERS) KSRC=$(SOFT_BUILD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: $(SOFT_BUILD)/linux-build/vmlinux socmap.vhd soft-build
	@touch $(SOFT_BUILD)/sysroot
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_private_cache.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp.ko
	@mkdir -p $(BUILD_DRIVERS)/dvi/linux/app
	@CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRIVERS) BUILD_PATH=$(BUILD_DRIVERS)/dvi/linux/app $(MAKE) -C $(DRIVERS)/dvi/linux/app
	@mkdir -p $(SOFT_BUILD)/sysroot/applications/dvi; cp $(BUILD_DRIVERS)/dvi/linux/app/*.exe $(SOFT_BUILD)/sysroot/applications/dvi
	@$(MAKE) acc-driver
	@$(MAKE) acc-app
	@touch $(SOFT_BUILD)/sysroot
	@chmod a+x S64esp; cp S64esp $(SOFT_BUILD)/sysroot/etc/init.d/
	$(QUIET_MAKE)$(MAKE) $(SOFT_BUILD)/linux-build/vmlinux

sysroot-clean:
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/sysroot.files $(SOFT_BUILD)/sysroot.cpio
	@$(MAKE) --quiet -C $(DRIVERS)/dvi/linux/app BUILD_PATH=$(BUILD_DRIVERS)/dvi/linux/app clean DRIVERS=$(DRIVERS)
	@if test -e $(SOFT_BUILD)/linux-build; then \
		$(MAKE) --quiet acc-driver-clean; \
	fi;
	@$(MAKE) --quiet acc-app-clean

sysroot-distclean: sysroot-clean
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/sysroot


### Linux ###

$(SOFT_BUILD)/linux-build:
	$(QUIET_MKDIR)mkdir -p $@


### Bare-metal ###

$(BAREMETAL_BIN):
	$(QUIET_MKDIR)mkdir -p $@

baremetal-all: soft-build socmap.vhd
	@mkdir -p $(BAREMETAL_BIN)/dvi
	@mkdir -p $(BUILD_DRIVERS)/dvi/baremetal
	@CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH) DRIVERS=$(DRIVERS) BUILD_PATH=$(BUILD_DRIVERS)/dvi/baremetal $(MAKE) -C $(DRIVERS)/dvi/baremetal
	@cp $(BUILD_DRIVERS)/dvi/baremetal/*.bin $(BAREMETAL_BIN)/dvi
	@$(MAKE) acc-baremetal

baremetal-distclean:
	$(QUIET_CLEAN)$(RM) $(BAREMETAL_BIN)
	@DRIVERS=$(DRIVERS) CPU_ARCH=$(CPU_ARCH) BUILD_PATH=$(BUILD_DRIVERS)/dvi/baremetal $(MAKE) --quiet -C $(DRIVERS)/dvi/baremetal clean
	@$(MAKE) --quiet acc-baremetal-clean



.PHONY: soft-build soft-build-clean soft-build-distclean
.PHONY: soft soft-clean soft-distclean
.PHONY: linux linux-clean linux-distclean
.PHONY: sysroot-update sysroot-clean sysroot-distclean
.PHONY: baremetal-distclean baremetal-all
# The following PHONY guarantees that we execute the program set by TEST_PROGRAM
.PHONY: $(SOFT_BUILD)/systest.bin $(SOFT_BUILD)/ram.srec
