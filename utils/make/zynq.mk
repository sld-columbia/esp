# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### ZYNQ Targets

ZYNQ = $(ESP_ROOT)/utils/zynq
ZYNQ_BOARD = $(shell echo $(BOARD) | cut -d "-" -f 2)

check-bitstream:
	@if ! test -e vivado/$(DESIGN).runs/impl_1/$(TOP).bit; then \
		echo $(SPACES)"ERROR: bistream not found; run 'make vivado-syn'"; \
		exit 1; \
	fi;

zynq-sdk: check-bitstream
	ZYNQ_ROOT=$(ZYNQ) BOARD=$(ZYNQ_BOARD) TOP=$(TOP) DESIGN=$(DESIGN) OUT=$(DESIGN_PATH)/zynq VIVADO_BUILD=$(DESIGN_PATH)/vivado $(MAKE) -C $(ZYNQ) sdk

zynq-u-boot:
	ZYNQ_ROOT=$(ZYNQ) BOARD=$(ZYNQ_BOARD) TOP=$(TOP) DESIGN=$(DESIGN) OUT=$(DESIGN_PATH)/zynq VIVADO_BUILD=$(DESIGN_PATH)/vivado $(MAKE) -C $(ZYNQ) u-boot

zynq-linux:
	ZYNQ_ROOT=$(ZYNQ) BOARD=$(ZYNQ_BOARD) TOP=$(TOP) DESIGN=$(DESIGN) OUT=$(DESIGN_PATH)/zynq VIVADO_BUILD=$(DESIGN_PATH)/vivado $(MAKE) -C $(ZYNQ) linux

zynq: check-bitstream
	ZYNQ_ROOT=$(ZYNQ) BOARD=$(ZYNQ_BOARD) TOP=$(TOP) DESIGN=$(DESIGN) OUT=$(DESIGN_PATH)/zynq VIVADO_BUILD=$(DESIGN_PATH)/vivado $(MAKE) -C $(ZYNQ) sd-card


zynq-jtag-boot: check-bitstream
	$(QUIET_RUN)
	@xsct $(ZYNQ)/scripts/xsct_jtagboot_zynqmp.tcl $(FPGA_HOST) $(XIL_HW_SERVER_PORT) $(DESIGN_PATH)/zynq/$(ZYNQ_BOARD)/images $(DESIGN_PATH)/zynq/$(ZYNQ_BOARD)/sdk vivado/$(DESIGN).runs/impl_1/$(TOP).bit

zynq-clean:


zynq-distclean: zynq-clean
	$(QUIET_CLEAN) $(RM) zynq



.PHONY: check-bitstream zynq-clean zynq-distclean zynq-sdk zynq-u-boot zynq-linux zynq zynq-jtag-boot
