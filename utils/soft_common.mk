# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

sysroot/opt/drivers-esp/contig_alloc.ko: linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(CONTIG_ALLOC_PATH)
	$(QUIET_CP)cp $(CONTIG_ALLOC_PATH)/contig_alloc.ko $@

sysroot/opt/drivers-esp/esp_cache.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.c) $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(ESP_CORE_PATH)/../esp_cache
	$(QUIET_CP)cp $(ESP_CORE_PATH)/../esp_cache/esp_cache.ko $@

sysroot/opt/drivers-esp/esp_private_cache.ko: sysroot/opt/drivers-esp/esp_cache.ko
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_CP)cp $(ESP_CORE_PATH)/../esp_cache/esp_private_cache.ko $@

sysroot/opt/drivers-esp/esp.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build CONTIG_ALLOC_PATH=$(CONTIG_ALLOC_PATH) $(MAKE) -C $(ESP_CORE_PATH)
	$(QUIET_CP)cp $(ESP_CORE_PATH)/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: linux-build/vmlinux socmap.vhd
	@touch sysroot
	@$(MAKE) sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_private_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp.ko
	@$(MAKE) -C $(DRIVERS)/dvi/app
	@mkdir -p sysroot/applications/dvi; cp $(DRIVERS)/dvi/app/*.exe sysroot/applications/dvi
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


linux-build:
	$(QUIET_MKDIR)mkdir -p $@

.PHONY: soft soft-clean soft-distclean linux linux-clean linux-distclean

.PHONY: sysroot-update sysroot-clean sysroot-distclean

# The following PHONY guarantees that we execute the program set by TEST_PROGRAM
.PHONY: systest.bin ram.srec

barec:
	$(QUIET_MKDIR)mkdir -p $@

.PHONY: barec-distclean barec-all
