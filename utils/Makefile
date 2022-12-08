# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

##########################
###    ESP Makefile    ###
##########################

### Set variables needed before including the other makefiles
SOFT              = $(ESP_ROOT)/soft/$(CPU_ARCH)
BOOTROM_PATH      = $(SOFT)/bootrom
LINUXSRC          = $(SOFT)/linux
DRIVERS           = $(ESP_ROOT)/soft/common/drivers
DRV_BARE          = $(DRIVERS)/baremetal
DRV_LINUX         = $(DRIVERS)/linux
CONTIG_ALLOC_PATH = $(DRV_LINUX)/contig_alloc
ESP_CORE_PATH     = $(DRV_LINUX)/esp
FLISTS            = $(ESP_ROOT)/utils/flist
SOFT_BUILD        = $(DESIGN_PATH)/soft-build/$(CPU_ARCH)
BUILD_DRIVERS     = $(SOFT_BUILD)/drivers
BAREMETAL_BIN     = $(SOFT_BUILD)/baremetal

CFG_BUILD       = socgen
GRLIB_CFG_BUILD = $(CFG_BUILD)/grlib
ESP_CFG_BUILD   = $(CFG_BUILD)/esp
RTL_CFG_BUILD   = $(CFG_BUILD)/flist
ESPMON_BUILD    = espmon

LOGS = logs
HLS_LOGS = $(LOGS)/hls
VIVADO_LOGS = $(LOGS)/vivado

### Quick help ###
include $(ESP_ROOT)/utils/make/help.mk


### Include common Makefile for desing configuration ###
include $(ESP_ROOT)/utils/make/design.mk


### NoC flit-width (not including head and tail bits)
ifneq ($(findstring ariane, $(CPU_ARCH)),)
NOC_WIDTH = 64
else
NOC_WIDTH = 32
endif


### Include targets to generate accelerators RTL with HLS ###
include $(ESP_ROOT)/utils/make/accelerators.mk


### Include targets to generate caches RTL with HLS ###
include $(ESP_ROOT)/utils/make/sc_caches.mk


### Include targets to compile example applications ###
include $(ESP_ROOT)/utils/make/examples.mk


### Board files ###
BOARD_FILES = $(wildcard $(ESP_ROOT)/constraints/$(BOARD)/*)


### Default test program ###
TEST_PROGRAM ?= $(SOFT_BUILD)/systest.exe


### GRLIB config targets ###
include $(ESP_ROOT)/utils/make/grlib.mk


ifeq ("$(CPU_ARCH)", "leon3")
### Leon3 Software targets ###
include $(ESP_ROOT)/utils/make/leon3.mk
endif

ifeq ("$(CPU_ARCH)", "ariane")
### Ariane Software targets ###
include $(ESP_ROOT)/utils/make/ariane.mk
endif

ifeq ("$(CPU_ARCH)", "ibex")
### Ibex Software targets ###
include $(ESP_ROOT)/utils/make/ibex.mk
endif

### Other architectures not integrated ###
ifneq ("$(CPU_ARCH)", "leon3")
ifneq ("$(CPU_ARCH)", "ariane")
ifneq ("$(CPU_ARCH)", "ibex")

ifneq ("$(CPU_ARCH)", "")
$(error Unsupported target processor: $(CPU_ARCH))
endif

endif
endif
endif


### SoC configuration for ESP ###
include $(ESP_ROOT)/utils/make/esp.mk


### Common software targets ###
include $(ESP_ROOT)/utils/make/soft_common.mk


### PROFPGA targets ###
include $(ESP_ROOT)/utils/make/profpga.mk


### Support for BSG DDR controller simulation on Modelsim and Genus synthesis
include $(ESP_ROOT)/utils/make/bsg.mk


### RTL ###
include $(ESP_ROOT)/utils/make/rtl.mk


# ### Vivado targets ###
include $(ESP_ROOT)/utils/make/vivado.mk
include $(ESP_ROOT)/utils/make/zynq.mk


### Modelsim targets ###
include $(ESP_ROOT)/utils/make/modelsim.mk

### Modelsim targets ###
include $(ESP_ROOT)/utils/make/questa.mk


# ### Xcelium targets ###
include $(ESP_ROOT)/utils/make/xmsim.mk


# ### Incisive targets ###
include $(ESP_ROOT)/utils/make/ncsim.mk


### Genus Targets
include $(ESP_ROOT)/utils/make/genus.mk


### FPGA Deploy targets ###
include $(ESP_ROOT)/utils/make/fpga.mk


### Utils ###
include $(ESP_ROOT)/utils/make/utils.mk


### Clean all ###
xilinx_lib-clean:
	$(QUIET_CLEAN)$(RM) \
		.cxl.mti_se.version \
		.cxl.modelsim.version \
		.cxl.ies.version \
		*.log \
		*.bak \
		*.jou \
		*backup* \

cache-distclean:
	$(QUIET_CLEAN)$(RM) \
		$(ESP_ROOT)/.cache/modelsim/ 	\
		$(ESP_ROOT)/.cache/xcelium/ 	\
		$(ESP_ROOT)/.cache/incisive/

.PHONY: xilinx_lib-clean cache-distclean


clean: 		soft-clean		\
		linux-clean		\
		xilinx_lib-clean 	\
		sim-clean		\
		qsim-clean		\
		ncsim-clean 		\
		xmsim-clean 		\
		esp-config-clean	\
		grlib-config-clean	\
		vivado-clean		\
		zynq-clean		\
		genus-clean		\
		socketgen-clean		\
		espmon-clean		\
		mmi64-clean		\
		soft-build-clean \
		jtag-clean

distclean:	check_srcs-distclean     	\
		xilinx_lib-clean 		\
		profpga-distclean		\
		soft-distclean 			\
		linux-distclean			\
		baremetal-distclean		\
		examples-clean			\
		sim-distclean			\
		qsim-distclean			\
		ncsim-distclean			\
		xmsim-distclean			\
		config-distclean		\
		vivado-distclean		\
		vivado-dpr-clean    \
		zynq-distclean			\
		genus-distclean			\
		socketgen-distclean		\
		espmon-distclean		\
		mmi64-distclean			\
		soft-build-distclean	\
		jtag-distclean
	$(QUIET_CLEAN)$(RM) $(LOGS)


.PHONY: clean distclean
