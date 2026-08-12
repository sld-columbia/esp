# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

QUARTUS_DIR ?= $(DESIGN_PATH)/quartus
QUARTUS_PROJECT ?= $(DESIGN)
QUARTUS_REVISION ?= $(QUARTUS_PROJECT)
QUARTUS_QPF ?= $(QUARTUS_PROJECT).qpf
QUARTUS_QSF ?= $(QUARTUS_REVISION).qsf
QUARTUS_QSYS ?= qsys_top.qsys
QUARTUS_TOP ?= ghrd_s10_top
QUARTUS_QSYS_FILES_TCL ?= $(ESP_ROOT)/utils/scripts/quartus/generated_files_qip.tcl

QUARTUS_CONSTRAINT_DIR ?= ../../../constraints/$(BOARD)
QUARTUS_CONSTRAINT_DIR_ABS = $(ESP_ROOT)/constraints/$(BOARD)
QUARTUS_PROJECT_TCL ?= project.tcl
QUARTUS_QSYS_TCL ?= qsys_top.tcl
QUARTUS_FPGA_DIR ?= ../fpga
QUARTUS_PROGRAM_SCRIPT ?= ../fpga/program_sof.sh
QUARTUS_HPS_BOOTLOADER ?= ../local/boot/u-boot-spl-dtb.hex

QUARTUS_OUTPUT_DIR ?= output_files
QUARTUS_SOF ?= $(QUARTUS_OUTPUT_DIR)/$(QUARTUS_REVISION).sof
QUARTUS_HPS_SOF ?= $(QUARTUS_OUTPUT_DIR)/$(QUARTUS_REVISION)_hps.sof
QUARTUS_RBF ?= $(QUARTUS_OUTPUT_DIR)/$(QUARTUS_REVISION)_hps.rbf
QUARTUS_JIC ?= $(QUARTUS_OUTPUT_DIR)/$(QUARTUS_REVISION)_hps.jic
QUARTUS_CPF_FLASH_DEVICE ?= MT25QU01G
QUARTUS_CPF_RBF_ARGS ?=
QUARTUS_CPF_JIC_ARGS ?= -o auto_create_rpd=on -o rpd_little_endian=off -o memory_map_file=on
QUARTUS_LOGS ?= $(LOGS)/quartus

QUARTUS_AUTO_SRCS_NAME ?= srcs_auto.tcl
QUARTUS_AUTO_SRCS ?= $(QUARTUS_DIR)/$(QUARTUS_AUTO_SRCS_NAME)
QUARTUS_LOGS_ABS = $(abspath $(QUARTUS_LOGS))
QUARTUS_QPF_PATH = $(QUARTUS_DIR)/$(QUARTUS_QPF)
QUARTUS_QSF_PATH = $(QUARTUS_DIR)/$(QUARTUS_QSF)
QUARTUS_QSYS_PATH = $(QUARTUS_DIR)/$(QUARTUS_QSYS)
QUARTUS_PROJECT_TCL_PATH = $(QUARTUS_CONSTRAINT_DIR_ABS)/$(QUARTUS_PROJECT_TCL)
QUARTUS_QSYS_TCL_PATH = $(QUARTUS_CONSTRAINT_DIR_ABS)/$(QUARTUS_QSYS_TCL)
QUARTUS_PROGRAM_SCRIPT_PATH = $(QUARTUS_DIR)/$(QUARTUS_PROGRAM_SCRIPT)
QUARTUS_HPS_BOOTLOADER_PATH = $(QUARTUS_DIR)/$(QUARTUS_HPS_BOOTLOADER)
QUARTUS_SOF_PATH = $(QUARTUS_DIR)/$(QUARTUS_SOF)
QUARTUS_HPS_SOF_PATH = $(QUARTUS_DIR)/$(QUARTUS_HPS_SOF)
QUARTUS_RBF_PATH = $(QUARTUS_DIR)/$(QUARTUS_RBF)
QUARTUS_JIC_PATH = $(QUARTUS_DIR)/$(QUARTUS_JIC)
QUARTUS_QSYS_GEN_DIR = $(if $(strip $(QUARTUS_QSYS)),$(QUARTUS_DIR)/$(basename $(QUARTUS_QSYS)))
QUARTUS_QSYS_NAME = $(basename $(notdir $(QUARTUS_QSYS)))
QUARTUS_QSYS_TOP_V_REL = $(if $(strip $(QUARTUS_QSYS)),$(basename $(QUARTUS_QSYS))/synth/$(QUARTUS_QSYS_NAME).v)
QUARTUS_QSYS_QIP_REL = $(if $(strip $(QUARTUS_QSYS)),$(basename $(QUARTUS_QSYS))/$(QUARTUS_QSYS_NAME).qip)
QUARTUS_QSYS_FILES_QIP = $(if $(strip $(QUARTUS_QSYS)),$(basename $(QUARTUS_QSYS))/$(QUARTUS_QSYS_NAME)_files.qip)
QUARTUS_QSYS_IP_GEN_DIR = $(if $(strip $(QUARTUS_QSYS)),$(QUARTUS_DIR)/ip/$(QUARTUS_QSYS_NAME))
QUARTUS_QSYS_ACCEPT_GENERATED_TOP ?= 0
QUARTUS_QSYS_PROJECT_MODE ?= qsys
PIPEFAIL_SHELL ?= bash

FPGA_HOST_IS_LOCAL = $(filter localhost 127.0.0.1 ::1,$(FPGA_HOST))
INTEL_JTAG_SERVER_PORT ?= 1309
INTEL_JTAG_SERVER_PASSWORD ?= esp
INTEL_JTAG_SERVER_ADDR = $(if $(findstring :,$(FPGA_HOST)),$(FPGA_HOST),$(FPGA_HOST):$(INTEL_JTAG_SERVER_PORT))

ifneq ($(filter $(TECHLIB),$(INTEL_FPGALIBS)),)

quartus-check-tools:
	@if ! command -v quartus_sh >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus_sh not found in PATH"; \
		false; \
	elif test -n "$(strip $(QUARTUS_QSYS))" && ! command -v qsys-generate >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: qsys-generate not found in PATH"; \
		false; \
	elif test -n "$(strip $(QUARTUS_QSYS))" && ! command -v qsys-script >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: qsys-script not found in PATH"; \
		false; \
	fi

quartus-check-gui-tools: quartus-check-tools
	@if ! command -v quartus >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus not found in PATH"; \
		false; \
	fi

quartus-check-cpf-tools:
	@if ! command -v quartus_cpf >/dev/null 2>&1; then \
		echo $(SPACES)"ERROR: quartus_cpf not found in PATH"; \
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

$(QUARTUS_DIR):
	$(QUIET_MKDIR)mkdir -p "$@"

$(QUARTUS_LOGS):
	$(QUIET_MKDIR)mkdir -p "$@"

quartus-project: quartus-check-tools quartus-srcs | $(QUARTUS_DIR) $(QUARTUS_LOGS)
	@test -n "$(strip $(QUARTUS_DEVICE))" || { echo $(SPACES)"ERROR: set QUARTUS_DEVICE before generating the Quartus project"; false; }
	@test -r "$(QUARTUS_PROJECT_TCL_PATH)" || { echo $(SPACES)"ERROR: Quartus project script not found: $(QUARTUS_PROJECT_TCL_PATH)"; false; }
	@test -r "$(QUARTUS_AUTO_SRCS)" || { echo $(SPACES)"ERROR: Quartus source list not found: $(QUARTUS_AUTO_SRCS)"; false; }
	@test -r "$(QUARTUS_DIR)/$(QUARTUS_FPGA_DIR)/$(QUARTUS_TOP).v" || { echo $(SPACES)"ERROR: Quartus top not found: $(QUARTUS_DIR)/$(QUARTUS_FPGA_DIR)/$(QUARTUS_TOP).v"; false; }
	$(QUIET_INFO)echo "generating Quartus project"
	@rm -f "$(QUARTUS_QPF_PATH)" "$(QUARTUS_QSF_PATH)"
	@cd "$(QUARTUS_DIR)" && \
		$(PIPEFAIL_SHELL) -o pipefail -c '{ \
			QUARTUS_QSYS_PROJECT_MODE="$(QUARTUS_QSYS_PROJECT_MODE)" \
			QUARTUS_QSYS_FILES_QIP="$(QUARTUS_QSYS_FILES_QIP)" \
			quartus_sh -t "$(QUARTUS_PROJECT_TCL_PATH)" \
				"$(QUARTUS_QPF)" \
				"$(QUARTUS_REVISION)" \
				"$(QUARTUS_DEVICE)" \
				"$(QUARTUS_TOP)" \
				"$(QUARTUS_CONSTRAINT_DIR)" \
				"$(QUARTUS_AUTO_SRCS_NAME)" \
				"$(QUARTUS_QSYS)" \
				"$(QUARTUS_FPGA_DIR)"; \
		} 2>&1 | tee "$$1"' _ "$(QUARTUS_LOGS_ABS)/quartus_project.log"

quartus-check-project: quartus-project
	@test -r "$(QUARTUS_QPF_PATH)" || { echo $(SPACES)"ERROR: Quartus project file not found: $(QUARTUS_QPF_PATH)"; false; }
	@test -r "$(QUARTUS_QSF_PATH)" || { echo $(SPACES)"ERROR: Quartus settings file not found: $(QUARTUS_QSF_PATH)"; false; }

quartus-qsys: quartus-check-tools quartus-project | $(QUARTUS_LOGS)
	$(QUIET_INFO)echo "generating Quartus Platform Designer system"
	@if test -n "$(strip $(QUARTUS_QSYS))"; then \
		test -r "$(QUARTUS_QSYS_TCL_PATH)" || { echo $(SPACES)"ERROR: Platform Designer script not found: $(QUARTUS_QSYS_TCL_PATH)"; false; }; \
		rm -f "$(QUARTUS_QSYS_PATH)"; \
		rm -rf "$(QUARTUS_QSYS_GEN_DIR)" "$(QUARTUS_QSYS_IP_GEN_DIR)"; \
		cd "$(QUARTUS_DIR)" && \
			$(PIPEFAIL_SHELL) -o pipefail -c '{ \
				run_status=0; \
				QUARTUS_QSYS_FILE="$(QUARTUS_QSYS)" \
				QUARTUS_DEVICE="$(QUARTUS_DEVICE)" \
				qsys-script --qpf="$(QUARTUS_QPF)" --script="$(QUARTUS_QSYS_TCL_PATH)" || run_status=$$?; \
				if test "$$run_status" = "0"; then \
					qsys_status=0; \
					qsys-generate --quartus-project="$(QUARTUS_QPF)" --rev="$(QUARTUS_REVISION)" --clear-output-directory "$(QUARTUS_QSYS)" --synthesis=VERILOG || qsys_status=$$?; \
					if test "$$qsys_status" -ne 0; then \
						if test "$(QUARTUS_QSYS_ACCEPT_GENERATED_TOP)" = "1" && test -r "$(QUARTUS_QSYS_TOP_V_REL)"; then \
							echo $(SPACES)"WARNING: qsys-generate exited $$qsys_status after generating $(QUARTUS_QSYS_TOP_V_REL); continuing"; \
						else \
							run_status=$$qsys_status; \
						fi; \
					fi; \
				fi; \
				if test "$$run_status" = "0" && test "$(QUARTUS_QSYS_PROJECT_MODE)" = "generated-files-qip"; then \
					test -r "$(QUARTUS_QSYS_FILES_TCL)" || { echo $(SPACES)"ERROR: generated QIP file-list script not found: $(QUARTUS_QSYS_FILES_TCL)"; run_status=1; }; \
					if test "$$run_status" = "0"; then \
						quartus_sh -t "$(QUARTUS_QSYS_FILES_TCL)" "$(QUARTUS_QSYS_FILES_QIP)" "$(QUARTUS_QSYS_QIP_REL)" "ip/$(QUARTUS_QSYS_NAME)" "$(QUARTUS_QPF)" "$(QUARTUS_REVISION)" || run_status=$$?; \
					fi; \
				fi; \
				exit $$run_status; \
			} 2>&1 | tee "$$1"' _ "$(QUARTUS_LOGS_ABS)/quartus_qsys.log"; \
	else \
		echo $(SPACES)"INFO: no Platform Designer .qsys target configured"; \
	fi

quartus-setup: quartus-project

quartus-compile: quartus-check-tools quartus-qsys | $(QUARTUS_LOGS)
	$(QUIET_INFO)echo "launching Quartus synthesis/implementation"
	@cd "$(QUARTUS_DIR)" && \
		$(PIPEFAIL_SHELL) -o pipefail -c '{ \
			run_status=0; \
			if ls *.stp >/dev/null 2>&1; then \
				command -v quartus_stp >/dev/null 2>&1 || { echo $(SPACES)"ERROR: quartus_stp not found in PATH"; run_status=1; }; \
				if test "$$run_status" = "0"; then \
					quartus_stp "$(QUARTUS_QPF)" -c "$(QUARTUS_REVISION)" || run_status=$$?; \
				fi; \
			fi; \
			if test "$$run_status" = "0"; then \
				quartus_sh --flow compile "$(QUARTUS_QPF)" -c "$(QUARTUS_REVISION)" || run_status=$$?; \
			fi; \
			exit $$run_status; \
		} 2>&1 | tee "$$1"' _ "$(QUARTUS_LOGS_ABS)/quartus_syn.log"

quartus-hps-sof: quartus-check-cpf-tools quartus-check-project
	@test -r "$(QUARTUS_SOF_PATH)" || { echo $(SPACES)"ERROR: SOF not found: $(QUARTUS_SOF_PATH). Run 'make quartus-syn' first."; false; }
	@test -r "$(QUARTUS_HPS_BOOTLOADER_PATH)" || { echo $(SPACES)"ERROR: HPS bootloader HEX not found: $(QUARTUS_HPS_BOOTLOADER_PATH)"; false; }
	$(QUIET_INFO)echo "embedding HPS bootloader in SOF"
	@mkdir -p "$(dir $(QUARTUS_HPS_SOF_PATH))"
	@cd "$(QUARTUS_DIR)" && quartus_cpf --bootloader="$(QUARTUS_HPS_BOOTLOADER)" "$(QUARTUS_SOF)" "$(QUARTUS_HPS_SOF)"

quartus-sof quartus-syn: quartus-compile
	@$(MAKE) -C "$(DESIGN_PATH)" quartus-hps-sof

quartus-gui: quartus-check-gui-tools quartus-project
	$(QUIET_RUN)
	@cd "$(QUARTUS_DIR)" && quartus "$(QUARTUS_QPF)" &

quartus-syn-gui: quartus-gui

quartus-rbf: quartus-sof
	$(QUIET_INFO)echo "generating Quartus raw binary file"
	@mkdir -p "$(dir $(QUARTUS_RBF_PATH))"
	@cd "$(QUARTUS_DIR)" && quartus_cpf --convert $(QUARTUS_CPF_RBF_ARGS) "$(QUARTUS_HPS_SOF)" "$(QUARTUS_RBF)"

quartus-jic: quartus-sof
	@test -n "$(strip $(QUARTUS_DEVICE))" || { echo $(SPACES)"ERROR: set QUARTUS_DEVICE before generating JIC output"; false; }
	$(QUIET_INFO)echo "generating Quartus JIC file"
	@mkdir -p "$(dir $(QUARTUS_JIC_PATH))"
	@cd "$(QUARTUS_DIR)" && quartus_cpf -c $(QUARTUS_CPF_JIC_ARGS) -d "$(QUARTUS_CPF_FLASH_DEVICE)" -s "$(QUARTUS_DEVICE)" "$(QUARTUS_HPS_SOF)" "$(QUARTUS_JIC)"

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
	@test -r "$(QUARTUS_PROGRAM_SCRIPT_PATH)" || { echo $(SPACES)"ERROR: programming script not found: $(QUARTUS_PROGRAM_SCRIPT_PATH)"; false; }
	@test -r "$(QUARTUS_HPS_SOF_PATH)" || { echo $(SPACES)"ERROR: HPS SOF not found: $(QUARTUS_HPS_SOF_PATH). Run 'make quartus-syn' first."; false; }
	@BOARD_CABLE="$(BOARD_CABLE)" \
		BOARD_CABLE_MATCH="$(BOARD_CABLE_MATCH)" \
		BOARD_DEVICE_INDEX="$(BOARD_DEVICE_INDEX)" \
		INTEL_ISSP_SERVICE_MATCH="$(INTEL_ISSP_SERVICE_MATCH)" \
		bash "$(QUARTUS_PROGRAM_SCRIPT_PATH)" "$(QUARTUS_HPS_SOF_PATH)"

quartus-clean:
	$(QUIET_CLEAN)rm -rf \
		$(QUARTUS_LOGS) \
		$(QUARTUS_DIR)/srcs_auto.tcl \
		$(QUARTUS_DIR)/db \
		$(QUARTUS_DIR)/incremental_db \
		$(QUARTUS_DIR)/greybox_tmp \
		$(QUARTUS_DIR)/output_files \
		$(QUARTUS_QSYS_GEN_DIR) \
		$(QUARTUS_DIR)/*.bak \
		$(QUARTUS_DIR)/*.cmp \
		$(QUARTUS_DIR)/*.done \
		$(QUARTUS_DIR)/*.jdi \
		$(QUARTUS_DIR)/*.pin \
		$(QUARTUS_DIR)/*.qws \
		$(QUARTUS_DIR)/*.rpt \
		$(QUARTUS_DIR)/*.smsg \
		$(QUARTUS_DIR)/*.summary

quartus-distclean:
	$(QUIET_CLEAN)rm -rf $(QUARTUS_DIR)

else

quartus-project quartus-syn quartus-sof quartus-setup quartus-gui quartus-syn-gui quartus-rbf quartus-jic quartus-jtag-list quartus-list-jtag quartus-program quartus-prog-fpga:
	@echo $(SPACES)"ERROR: Quartus targets are only available for Intel FPGA boards"
	@false

quartus-clean quartus-distclean:
	@:

endif

.PHONY: quartus-check-tools quartus-check-gui-tools quartus-check-cpf-tools quartus-check-program-tools quartus-project quartus-check-project quartus-qsys quartus-compile quartus-hps-sof quartus-syn quartus-sof quartus-setup quartus-gui quartus-syn-gui quartus-rbf quartus-jic quartus-jtag-list quartus-list-jtag quartus-program quartus-prog-fpga quartus-clean quartus-distclean
