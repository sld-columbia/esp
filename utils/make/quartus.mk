# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

QUARTUS_DIR ?= $(DESIGN_PATH)/quartus
QUARTUS_MAKE_VARS = ESP_ROOT=$(ESP_ROOT) DESIGN_PATH=$(DESIGN_PATH)

FPGA_HOST_IS_LOCAL = $(filter localhost 127.0.0.1 ::1,$(FPGA_HOST))
INTEL_JTAG_SERVER_PORT ?= 1309
INTEL_JTAG_SERVER_PASSWORD ?= esp
INTEL_JTAG_SERVER_ADDR = $(if $(findstring :,$(FPGA_HOST)),$(FPGA_HOST),$(FPGA_HOST):$(INTEL_JTAG_SERVER_PORT))

ifneq ($(filter $(TECHLIB),$(INTEL_FPGALIBS)),)

quartus-check-tools:
	@if ! command -v quartus_sh >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus_sh not found in PATH"; \
		false; \
	fi

quartus-check-gui-tools: quartus-check-tools
	@if ! command -v quartus >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus not found in PATH"; \
		false; \
	fi

quartus-check-program-tools:
	@if ! command -v quartus_pgm >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus_pgm not found in PATH"; \
		false; \
	elif ! command -v jtagconfig >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: jtagconfig not found in PATH"; \
		false; \
	elif ! command -v system-console >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: system-console not found in PATH"; \
		false; \
	fi

quartus-syn: quartus-check-tools quartus-srcs
	$(QUIET_INFO)echo "launching Quartus synthesis/implementation"
	@$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) sof

quartus-setup: quartus-check-tools quartus-srcs
	$(QUIET_INFO)echo "refreshing Quartus project source assignments"
	@$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) quartus_setup

quartus-gui: quartus-check-gui-tools quartus-srcs
	$(QUIET_RUN)
	@$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) quartus_edit

quartus-syn-gui: quartus-gui

define quartus_add_jtag_server
	@if test -n "$(strip $(FPGA_HOST))" && \
	    { test -z "$(strip $(FPGA_HOST_IS_LOCAL))" || test "$(strip $(INTEL_JTAG_SERVER_PORT))" != "1309"; }; then \
		echo $(SPACES)"INFO Connecting to remote Intel JTAG server $(INTEL_JTAG_SERVER_ADDR)"; \
		jtagconfig --addserver "$(INTEL_JTAG_SERVER_ADDR)" "$(INTEL_JTAG_SERVER_PASSWORD)"; \
	fi
endef

quartus-jtag-list quartus-list-jtag: quartus-check-program-tools
	$(QUIET_RUN)
	$(call quartus_add_jtag_server)
	@jtagconfig

quartus-program quartus-prog-fpga: quartus-check-program-tools
	$(QUIET_RUN)
	$(call quartus_add_jtag_server)
	@$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) program_fpga

quartus-clean:
	$(QUIET_CLEAN)$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) clean

quartus-distclean:
	$(QUIET_CLEAN)$(MAKE) -C $(QUARTUS_DIR) $(QUARTUS_MAKE_VARS) scrub_clean

else

quartus-syn quartus-setup quartus-gui quartus-syn-gui quartus-jtag-list quartus-list-jtag quartus-program quartus-prog-fpga:
	@echo $(SPACES)"ERROR: Quartus targets are only available for Intel FPGA boards"
	@false

quartus-clean quartus-distclean:
	@:

endif

.PHONY: quartus-check-tools quartus-check-gui-tools quartus-check-program-tools quartus-syn quartus-setup quartus-gui quartus-syn-gui quartus-jtag-list quartus-list-jtag quartus-program quartus-prog-fpga quartus-clean quartus-distclean
