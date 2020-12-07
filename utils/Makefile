# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

##########################
###    ESP Makefile    ###
##########################

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


### Set variables needed before including accelerators.mk
SOFT              = $(ESP_ROOT)/soft/$(CPU_ARCH)
BOOTROM_PATH      = $(SOFT)/bootrom
LINUXSRC          = $(SOFT)/linux
DRIVERS           = $(SOFT)/drivers
CONTIG_ALLOC_PATH = $(DRIVERS)/contig_alloc
ESP_CORE_PATH     = $(DRIVERS)/esp
FLISTS            = $(ESP_ROOT)/utils/flist


### Include targets to generate accelerators RTL with HLS ###
include $(ESP_ROOT)/utils/make/accelerators.mk


### Include targets to generate caches RTL with HLS ###
include $(ESP_ROOT)/utils/make/sc_components.mk


### Include targets to compile example applications ###
include $(ESP_ROOT)/utils/make/examples.mk


### Paths shortcuts ###
UTILS_GRLIB = $(ESP_ROOT)/utils/grlib
TKCONFIG   = $(UTILS_GRLIB)/tkconfig


### Board files ###
BOARD_FILES = $(wildcard $(ESP_ROOT)/constraints/$(BOARD)/*)


### Default test program ###
TEST_PROGRAM ?= systest.exe


ifeq ("$(CPU_ARCH)", "leon3")
### Leon3 Software targets ###
include $(UTILS_GRLIB)/leon3_sw.mk
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

soft:

soft-clean:

soft-distclean:

linux:

linux-clean:

linux-distclean:

barec-all:

barec-distclean:

endif
endif
endif


### SoC configuration for ESP ###
include $(ESP_ROOT)/utils/make/esp.mk


### Common software targets ###
include $(ESP_ROOT)/utils/make/soft_common.mk


### GRLIB config targets ###
include $(ESP_ROOT)/utils/make/grlib.mk


### PROFPGA targets ###
include $(ESP_ROOT)/utils/make/profpga.mk


### RTL ###
include $(ESP_ROOT)/utils/make/rtl.mk


# ### Vivado targets ###
include $(ESP_ROOT)/utils/make/vivado.mk
include $(ESP_ROOT)/utils/make/zynq.mk


### Modelsim targets ###
include $(ESP_ROOT)/utils/make/modelsim.mk


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
		ncsim-clean 		\
		xmsim-clean 		\
		esp-config-clean	\
		grlib-config-clean	\
		vivado-clean		\
		zynq-clean		\
		genus-clean		\
		sldgen-clean		\
		espmon-clean		\
		mmi64-clean

distclean:	check_all_srcs-distclean 	\
		check_all_rtl_srcs-distclean	\
		xilinx_lib-clean 		\
		profpga-distclean		\
		soft-distclean 			\
		linux-distclean			\
		barec-distclean			\
		examples-clean			\
		sim-distclean			\
		ncsim-distclean			\
		xmsim-distclean			\
		esp-config-distclean		\
		grlib-config-distclean		\
		vivado-distclean		\
		zynq-distclean			\
		genus-distclean			\
		sldgen-distclean		\
		espmon-distclean		\
		mmi64-distclean
	$(QUIET_CLEAN)$(RM) *.log


.PHONY: clean distclean
