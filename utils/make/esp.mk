# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ESP_DEFCONFIG ?= $(ESP_ROOT)/socs/defconfig/esp_$(BOARD)_defconfig

EMU_FREQ = $(BASE_FREQ_MHZ)
ifneq ("$(OVR_TECHLIB)", "")
EMU_TECH = $(OVR_TECHLIB)
else
EMU_TECH = "none"
endif

$(ESP_CFG_BUILD):
	$(QUIET_MKDIR)mkdir -p $(ESP_CFG_BUILD)

$(ESP_CFG_BUILD)/.esp_config:
	$(QUIET_MKDIR)mkdir -p $(ESP_CFG_BUILD)
	$(QUIET_CP)cp $(ESP_DEFCONFIG) $@

esp-defconfig: $(ESP_DEFCONFIG) $(ESP_CFG_BUILD)
	$(QUIET_CP) \
	cd $(ESP_CFG_BUILD); \
	cp $< .esp_config
	$(QUIET_MAKE)$(MAKE) esp-config

$(ESP_CFG_BUILD)/socmap.vhd: $(ESP_CFG_BUILD)/.esp_config $(GRLIB_CFG_BUILD)/grlib_config.vhd top.vhd Makefile
	$(QUIET_DIFF)echo "checking .esp_config..."
	@cd $(ESP_CFG_BUILD); \
	/usr/bin/diff .esp_config $(ESP_DEFCONFIG) -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for ESP"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".esp_config\" for ESP"; \
	fi; \
	echo ""; \
	echo "Generating ESP configuration..."; \
	LD_LIBRARY_PATH="" xvfb-run -a python3 $(ESP_ROOT)/tools/socgen/esp_creator_batch.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK) $(BOARD) $(EMU_TECH) $(EMU_FREQ)

$(ESP_CFG_BUILD)/esplink.h: $(ESP_CFG_BUILD)/socmap.vhd

ESPLINK_SRCS = $(wildcard $(ESP_ROOT)/tools/esplink/src/*.c)
ESPLINK_HDRS = $(wildcard $(ESP_ROOT)/tools/esplink/src/*.h)
esplink: $(ESP_CFG_BUILD)/esplink.h $(ESPLINK_HDRS) $(ESPLINK_SRCS)
	$(QUIET_CC) \
	cd $(ESP_CFG_BUILD); \
	gcc -O3 -Wall -Werror -fmax-errors=5 \
		-DESPLINK_IP=\"$(ESPLINK_IP)\" -DPORT=$(ESPLINK_PORT) \
		-I$(ESP_ROOT)/tools/esplink/src/ -I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		$(ESPLINK_SRCS) -o $@

esplink-fpga-proxy: $(ESP_CFG_BUILD)/socmap.h $(ESPLINK_HDRS) $(ESPLINK_SRCS)
	$(QUIET_CC) \
	cd $(ESP_CFG_BUILD); \
	gcc -O3 -Wall -Werror -fmax-errors=5 \
		-DESPLINK_IP=\"$(FPGA_PROXY_IP)\" -DPORT=$(FPGA_PROXY_PORT) \
		-I$(ESP_ROOT)/tools/esplink/src/ -I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		$(ESPLINK_SRCS) -o $@

esp-config: $(ESP_CFG_BUILD)/socmap.vhd

esp-xconfig: $(ESP_CFG_BUILD) $(GRLIB_CFG_BUILD)/grlib_config.vhd
	@echo ""
	@echo "Running interactive ESP configuration..."
	@cd $(ESP_CFG_BUILD); \
	LD_LIBRARY_PATH="" python3 $(ESP_ROOT)/tools/socgen/esp_creator.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK) $(BOARD) $(EMU_TECH) $(EMU_FREQ)

esp-config-clean:
	$(QUIET_CLEAN)$(RM) \
		$(ESP_CFG_BUILD)/.esp_config.bak

ifneq ("$(CPU_ARCH)", "leon3")
$(ESP_CFG_BUILD)/riscv.dts: $(ESP_CFG_BUILD)/.esp_config $(GRLIB_CFG_BUILD)/grlib_config.vhd top.vhd
	$(QUIET_MAKE)$(MAKE) $(ESP_CFG_BUILD)/socmap.vhd

ARIANE_RV_PLIC_REGMAP_GEN = $(ESP_ROOT)/rtl/cores/ariane/ariane/src/rv_plic/rtl/gen_plic_addrmap.py

$(ESP_CFG_BUILD)/plic_regmap.sv: $(ARIANE_RV_PLIC_REGMAP_GEN) $(ESP_CFG_BUILD)/.esp_config
	$(QUIET_MAKE)$< -t $$(($(NCPU_TILE)*2)) > $@
endif

ifeq ("$(CPU_ARCH)", "leon3")
$(ESP_CFG_BUILD)/plic_regmap.sv:

endif

esp-config-distclean:
	$(QUIET_CLEAN)$(RM) $(ESP_CFG_BUILD)

config-distclean:
	$(QUIET_CLEAN)$(RM) $(CFG_BUILD)

.PHONY: esplink esp-xconfig esp-defconfig esp-config-clean esp-config-distclean config-distclean
