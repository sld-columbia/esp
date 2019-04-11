# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: MIT

### Supported technology libraries ###
ASICLIBS =
FPGALIBS = virtex7 virtexup


### Check for technology library definition ###
ifeq ("$(TECHLIB)","")
$(error technology library not specified)
endif

ifneq ($(findstring profpga, $(BOARD)),)

ifeq ("$(PROFPGA)","")
$(error proFPGA path not specified)
endif

ifeq ("$(XILINX_VIVADO)","")
$(error XILINX_VIVADO path not specified)
endif

PROFPGA_REQUIRED_VER = proFPGA-2016B
PROFPGA_CURRENT_VER = $(shell basename $(PROFPGA))
ifneq ("$(PROFPGA_REQUIRED_VER)", "$(PROFPGA_CURRENT_VER)")
$(error proFPGA tools version must be "$(PROFPGA_REQUIRED_VER)")
endif

endif

### Create FPGA part name ###
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
include $(ESP_ROOT)/constraints/$(BOARD)/Makefile.inc
DEVICE = $(PART)-$(PACKAGE)-$(SPEED)
else ifneq ($(filter $(TECHLIB),$(ASICLIBS)),)
DEVICE = ASIC-$(TECHLIB)
else
$(error technology library not supported)
endif


### Include grlib configuration (remake may occur) ###
-include .grlib_config
-include .esp_config


### Vivado constaints ###
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
XDC   = $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD).xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mig-pins.xdc $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mig-constraints.xdc
ifneq ($(findstring profpga, $(BOARD)),)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mmi64.xdc
endif
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-eth-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-dvi-pins.xdc
ifeq ($(CONFIG_GRETH_ENABLE),y)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-eth-constraints.xdc
endif
ifeq ($(CONFIG_SVGA_ENABLE),y)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-dvi-constraints.xdc
endif
ifeq ($(CONFIG_HAS_DVFS),y)
XDC  += $(ESP_ROOT)/constraints/esp-common/esp-plls.xdc
endif
endif


### Simnulation common options ###

VCOMOPT  +=
VLOGOPT  +=
VSIMOPT  +=
XMCOMOPT  +=
XMLOGOPT  +=
XMSIMOPT  += -input xmsim.in
NCCOMOPT  +=
NCLOGOPT  +=
NCSIMOPT  += -input ncsim.in


# Include unisim verilog librayr
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VSIMOPT += -L secureip_ver -L unisims_ver
endif

VSIMOPT += -t ps

ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
EXTRA_SIMTOP  = glbl
else
EXTRA_SIMTOP  =
endif

# Simulator switches
VSIMOPT += -novopt +notimingchecks

# Toplevel
VSIMOPT += $(SIMTOP) $(EXTRA_SIMTOP)
XMSIMOPT += $(SIMTOP)
NCSIMOPT += $(SIMTOP)

### Common design files ###
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/esp_global.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sld_devices.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/allacc.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/genacc.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/allcaches.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/gencaches.vhd

TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/grlib_config.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/socmap.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sldacc.vhd
TOP_VHDL_RTL_PKGS += $(ESP_ROOT)/socs/common/soctiles.vhd

TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/accelerators.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/caches.vhd
TOP_VHDL_RTL_SRCS += $(wildcard $(DESIGN_PATH)/sldgen/noc_*.vhd)
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/tile_acc.vhd
TOP_VHDL_RTL_SRCS += $(wildcard $(ESP_ROOT)/socs/common/tile_*.vhd)
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/esp.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/$(TOP).vhd

TOP_VLOG_RTL_SRCS +=

TOP_VHDL_SIM_PKGS +=

TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/$(SIMTOP).vhd

TOP_VLOG_SIM_SRCS +=
