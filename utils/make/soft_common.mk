# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


### Software build folder ###
soft-build:
	@mkdir -p $(BUILD_DRIVERS)/contig_alloc
	@mkdir -p $(BUILD_DRIVERS)/esp
	@mkdir -p $(BUILD_DRIVERS)/esp_cache
	@mkdir -p $(BUILD_DRIVERS)/libesp
	@mkdir -p $(BUILD_DRIVERS)/monitors
	@mkdir -p $(BUILD_DRIVERS)/probe
	@mkdir -p $(BUILD_DRIVERS)/test
	@mkdir -p $(BUILD_DRIVERS)/utils/baremetal
	@mkdir -p $(BUILD_DRIVERS)/utils/linux
	@ln -sf $(DRV_LINUX)/contig_alloc/* $(BUILD_DRIVERS)/contig_alloc
	@ln -sf $(DRV_LINUX)/esp/* $(BUILD_DRIVERS)/esp
	@ln -sf $(DRV_LINUX)/esp_cache/* $(BUILD_DRIVERS)/esp_cache
	@ln -sf $(DRV_LINUX)/driver.mk $(BUILD_DRIVERS)

soft-build-clean:

soft-build-distclean: soft-build-clean
	$(QUIET_CLEAN)$(RM) soft-build


### Sysroot ###
$(SOFT_BUILD)/sysroot/opt/drivers-esp/contig_alloc.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRV_LINUX)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRV_LINUX) KSRC=$(SOFT_BUILD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/contig_alloc
	$(QUIET_CP)cp $(BUILD_DRIVERS)/contig_alloc/contig_alloc.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.c) $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.h) $(wildcard $(DRV_LINUX)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRV_LINUX) KSRC=$(SOFT_BUILD)/linux-build $(MAKE) -C $(BUILD_DRIVERS)/esp_cache
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_cache.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_private_cache.ko: $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp_cache/esp_private_cache.ko $@

$(SOFT_BUILD)/sysroot/opt/drivers-esp/esp.ko: $(SOFT_BUILD)/linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRV_LINUX)/include/*.h)
	@mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) DRIVERS=$(DRV_LINUX) KSRC=$(SOFT_BUILD)/linux-build DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C $(BUILD_DRIVERS)/esp
	$(QUIET_CP)cp $(BUILD_DRIVERS)/esp/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: $(SOFT_BUILD)/linux-build/vmlinux $(ESP_CFG_BUILD)/socmap.vhd soft-build
	@touch $(SOFT_BUILD)/sysroot
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_cache.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp_private_cache.ko
	@$(MAKE) $(SOFT_BUILD)/sysroot/opt/drivers-esp/esp.ko
	@mkdir -p $(BUILD_DRIVERS)/dvi/linux/app
	@CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_LINUX) BUILD_PATH=$(BUILD_DRIVERS)/dvi/linux/app DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C $(DRV_LINUX)/dvi/app
	@mkdir -p $(SOFT_BUILD)/sysroot/applications/dvi; cp $(BUILD_DRIVERS)/dvi/linux/app/*.exe $(SOFT_BUILD)/sysroot/applications/dvi
	@$(MAKE) acc-driver
	@$(MAKE) acc-app
	@touch $(SOFT_BUILD)/sysroot
	@chmod a+x $(ESP_CFG_BUILD)/S64esp; cp $(ESP_CFG_BUILD)/S64esp $(SOFT_BUILD)/sysroot/etc/init.d/
	$(QUIET_MAKE)$(MAKE) $(SOFT_BUILD)/linux-build/vmlinux

sysroot-clean:
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/sysroot.files $(SOFT_BUILD)/sysroot.cpio
	@$(MAKE) --quiet -C $(DRV_LINUX)/dvi/app BUILD_PATH=$(BUILD_DRIVERS)/dvi/linux/app clean DRIVERS=$(DRV_LINUX)
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


BAREMETAL_APPS_PATH      = $(ESP_ROOT)/soft/common/apps/baremetal
BAREMETAL_APPS           = $(filter-out include, $(shell ls -d $(BAREMETAL_APPS_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
BAREMETAL_APPS_PATHS     = $(addprefix $(BAREMETAL_APPS_PATH)/, $(BAREMETAL_APPS))
BAREMETAL_APPS-baremetal = $(addsuffix -baremetal, $(BAREMETAL_APPS))
BAREMETAL_APPS-baremetal-clean = $(addsuffix -baremetal-clean, $(BAREMETAL_APPS))

$(BAREMETAL_APPS-baremetal): $(BAREMETAL_BIN) soft-build $(ESP_CFG_BUILD)/socmap.vhd
	@BUILD_PATH=$(BUILD_DRIVERS)/$(@:-baremetal=)/baremetal; \
        BAREMETAL_APPS_PATH=$(filter %/$(@:-baremetal=), $(BAREMETAL_APPS_PATHS)); \
	if [ `ls -1 $$BAREMETAL_APPS_PATH/*.c 2>/dev/null | wc -l ` -gt 0 ]; then \
		echo '   ' MAKE $@; \
		mkdir -p $$BUILD_PATH; \
		CROSS_COMPILE=$(CROSS_COMPILE_ELF) CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_BARE) DESIGN_PATH=$(DESIGN_PATH)/$(ESP_CFG_BUILD) BUILD_PATH=$$BUILD_PATH $(MAKE) -C  $$BAREMETAL_APPS_PATH; \
		if [ `ls -1 $$BUILD_PATH/*.bin 2>/dev/null | wc -l ` -gt 0 ]; then \
			echo '   ' CP $@; cp $$BUILD_PATH/*.bin $(BAREMETAL_BIN)/$(@:-baremetal=).bin; \
		fi; \
		if [ `ls -1 $$BUILD_PATH/*.exe 2>/dev/null | wc -l ` -gt 0 ]; then \
			echo '   ' CP $@; cp $$BUILD_PATH/*.exe $(BAREMETAL_BIN)/$(@:-baremetal=).exe; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(BAREMETAL_APPS-baremetal-clean):
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/$(@:-baremetal-clean=)/baremetal

apps-baremetal: $(BAREMETAL_APPS-baremetal)

apps-baremetal-clean: $(BAREMETAL_APPS-baremetal-clean) probe-clean

baremetal-all: soft-build $(ESP_CFG_BUILD)/socmap.vhd
	@mkdir -p $(BAREMETAL_BIN)/dvi
	@mkdir -p $(BUILD_DRIVERS)/dvi/baremetal
	@CPU_ARCH=$(CPU_ARCH) DESIGN_PATH=$(DESIGN_PATH)/$(ESP_CFG_BUILD) DRIVERS=$(DRV_BARE) BUILD_PATH=$(BUILD_DRIVERS)/dvi/baremetal DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C $(DRV_BARE)/dvi
	@cp $(BUILD_DRIVERS)/dvi/baremetal/*.bin $(BAREMETAL_BIN)/dvi
	@$(MAKE) acc-baremetal
	@$(MAKE) apps-baremetal

baremetal-distclean:
	$(QUIET_CLEAN)$(RM) $(BAREMETAL_BIN)
	@DRIVERS=$(DRV_BARE) CPU_ARCH=$(CPU_ARCH) BUILD_PATH=$(BUILD_DRIVERS)/dvi/baremetal $(MAKE) --quiet -C $(DRV_BARE)/dvi clean
	@$(MAKE) --quiet acc-baremetal-clean



.PHONY: soft-build soft-build-clean soft-build-distclean
.PHONY: soft soft-clean soft-distclean
.PHONY: linux linux-clean linux-distclean
.PHONY: sysroot-update sysroot-clean sysroot-distclean
.PHONY: baremetal-distclean baremetal-all
# The following PHONY guarantees that we execute the program set by TEST_PROGRAM
.PHONY: $(SOFT_BUILD)/systest.bin $(SOFT_BUILD)/ram.srec
