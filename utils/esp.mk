# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ESP_DEFCONFIG ?= $(ESP_ROOT)/socs/defconfig/esp_$(BOARD)_defconfig

.esp_config:
	$(QUIET_CP)cp $(ESP_DEFCONFIG) $@

esp-defconfig: $(ESP_DEFCONFIG)
	$(QUIET_CP)cp $< .esp_config
	$(QUIET_MAKE)$(MAKE) esp-config

socmap.vhd: .esp_config grlib_config.vhd top.vhd Makefile
	$(QUIET_DIFF)echo "checking .esp_config..."
	@/usr/bin/diff .esp_config $(ESP_DEFCONFIG) -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for ESP"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".esp_config\" for ESP"; \
	fi
	@echo ""
	@echo "Generating ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator_batch.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK)

socmap.h: socmap.vhd

ESPLINK_SRCS = $(wildcard $(ESP_ROOT)/utils/esplink/src/*.c)
ESPLINK_HDRS = $(wildcard $(ESP_ROOT)/utils/esplink/src/*.h)
esplink: socmap.h $(ESPLINK_HDRS) $(ESPLINK_SRCS)
	$(QUIET_CC) gcc -O3 -Wall -Werror -fmax-errors=5 \
		-DESPLINK_IP=\"$(ESPLINK_IP)\" -DPORT=$(ESPLINK_PORT) \
		-I$(ESP_ROOT)/utils/esplink/src/ -I$(DESIGN_PATH) \
		$(ESPLINK_SRCS) -o $@

esp-config: socmap.vhd

esp-xconfig: grlib_config.vhd
	@echo ""
	@echo "Running interactive ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK)

esp-config-clean:
	$(QUIET_CLEAN)$(RM) \
		.esp_config.bak

ifneq ("$(CPU_ARCH)", "leon3")
riscv.dts: .esp_config grlib_config.vhd top.vhd
	$(QUIET_MAKE) $(MAKE) socmap.vhd

ARIANE_RV_PLIC_REGMAP_GEN = $(ARIANE)/src/rv_plic/rtl/gen_plic_addrmap.py

plic_regmap.sv: $(ARIANE_RV_PLIC_REGMAP_GEN) .esp_config
	$(QUIET_MAKE)$< -t $$(($(NCPU_TILE)*2)) > $@
endif

ifeq ("$(CPU_ARCH)", "leon3")
plic_regmap.sv:

endif

esp-config-distclean: esp-config-clean
	$(QUIET_CLEAN)$(RM)	\
		socmap.vhd	\
		esp_global.vhd	\
		.esp_config	\
		.soft_config	\
		riscv.dts	\
		plic_regmap.sv	\
		mmi64_regs.h	\
		power.h		\
		socmap.h	\
		cache_cfg.svh	\
		S64esp		\
		esplink


.PHONY: esplink esp-xconfig esp-defconfig esp-config-clean esp-config-distclean
