# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ifneq ($(findstring profpga, $(BOARD)),)
fpga-program: profpga-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5

fpga-program-emu: profpga-prog-fpga-emu
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
else ifneq ($(filter $(TECHLIB),$(INTEL_FPGALIBS)),)
fpga-program: quartus-prog-fpga
	$(QUIET_INFO) echo "Waiting for HPS/FPGA bridge initialization..."
	@sleep 5
else
fpga-program: vivado-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
endif


ifneq ($(filter $(TECHLIB),$(INTEL_FPGALIBS)),)

INTEL_HPS_HOST ?= $(HPS_HOST)
ifeq ($(strip $(INTEL_HPS_HOST)),)
INTEL_HPS_HOST := $(HPS_HOST)
endif
INTEL_HPS_USER ?= terasic
INTEL_HPS_SSH_PORT ?= 22
INTEL_HPS_RUN_DIR ?= .
INTEL_HPS_SSH_OPTS ?= -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
INTEL_HPS_SSH_RUN_OPTS ?= -tt
INTEL_HPS_SSH_TARGET = $(if $(strip $(INTEL_HPS_HOST)),$(if $(findstring @,$(INTEL_HPS_HOST)),$(INTEL_HPS_HOST),$(if $(strip $(INTEL_HPS_USER)),$(INTEL_HPS_USER)@$(INTEL_HPS_HOST),$(INTEL_HPS_HOST))))
INTEL_HPS_SSH = ssh -q $(INTEL_HPS_SSH_OPTS) -p $(INTEL_HPS_SSH_PORT) $(INTEL_HPS_SSH_TARGET)
INTEL_HPS_SSH_RUN = ssh -q $(INTEL_HPS_SSH_OPTS) $(INTEL_HPS_SSH_RUN_OPTS) -p $(INTEL_HPS_SSH_PORT) $(INTEL_HPS_SSH_TARGET)
INTEL_HPS_SCP = scp -q $(INTEL_HPS_SSH_OPTS) -P $(INTEL_HPS_SSH_PORT)
INTEL_HPS_SUDO ?= sudo
INTEL_HPS_PEEK ?= ./esp_peek
INTEL_HPS_LOADER ?= ./esp_load_bootrom_edcl
INTEL_HPS_LOADER_CPU ?= $(CPU_ARCH)
INTEL_HPS_LOADER_OPTS ?= --cpu $(INTEL_HPS_LOADER_CPU)
INTEL_HPS_WAKE_ADDR_ariane ?= 0x2060090384
INTEL_HPS_WAKE_ADDR_ibex ?= 0x2060090384
INTEL_HPS_WAKE_ADDR_leon3 ?= 0x2080090384
INTEL_HPS_WAKE_ADDR_AUTO = $(INTEL_HPS_WAKE_ADDR_$(INTEL_HPS_LOADER_CPU))
INTEL_HPS_WAKE_ADDR ?= $(if $(strip $(INTEL_HPS_WAKE_ADDR_AUTO)),$(INTEL_HPS_WAKE_ADDR_AUTO),0x2060090384)

define intel_hps_run_payload
	@if ! command -v ssh >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: ssh not found in PATH"; \
		false; \
	fi
	@if ! command -v scp >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: scp not found in PATH"; \
		false; \
	fi
	@test -n "$(INTEL_HPS_HOST)" || { echo $(SPACES)"ERROR: set INTEL_HPS_HOST or HPS_HOST to the DE10-Pro SX HPS Linux host"; false; }
	@test -r $(SOFT_BUILD)/prom.bin || { echo $(SPACES)"ERROR: bootrom not found: $(SOFT_BUILD)/prom.bin. Run 'make soft' first."; false; }
	@test -r $1 || { echo $(SPACES)"ERROR: payload not found: $1"; false; }
	@$(INTEL_HPS_SSH) "mkdir -p $(INTEL_HPS_RUN_DIR)"
	@$(INTEL_HPS_SCP) $(SOFT_BUILD)/prom.bin $1 $(INTEL_HPS_SSH_TARGET):$(INTEL_HPS_RUN_DIR)/
	@$(INTEL_HPS_SSH_RUN) "cd $(INTEL_HPS_RUN_DIR) && $(INTEL_HPS_SUDO) $(INTEL_HPS_PEEK) $(INTEL_HPS_WAKE_ADDR) >/dev/null && $(INTEL_HPS_SUDO) $(INTEL_HPS_PEEK) $(INTEL_HPS_WAKE_ADDR) >/dev/null && $(INTEL_HPS_SUDO) $(INTEL_HPS_LOADER) prom.bin $(INTEL_HPS_LOADER_OPTS) --dram-image $(notdir $1)"
endef

fpga-run: soft
	$(call intel_hps_run_payload,$(SOFT_BUILD)/systest.bin)

fpga-run-linux: soft
	$(call intel_hps_run_payload,$(SOFT_BUILD)/linux.bin)

fpga-run-proxy fpga-run-iolink fpga-run-linux-proxy fpga-run-linux-iolink fpga-run-jtag:
	@echo $(SPACES)"ERROR: $@ is not supported by the Intel HPS loader backend"
	@false

else

fpga-run: esplink soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-linux: esplink soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-proxy: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-iolink: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset

fpga-run-linux-proxy: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-linux-iolink: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset

fpga-run-jtag: esplink-fpga-proxy
	@python $(ESP_ROOT)/utils/scripts/jtag_test/jtag_esplink.py $(STIM_FILE)

endif

.PHONY: fpga-run fpga-run-linux fpga-program fpga-run-proxy fpga-run-linux-proxy
