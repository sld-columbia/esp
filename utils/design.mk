# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Supported technology libraries ###
ASICLIBS =
FPGALIBS = virtex7 virtexu virtexup


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

PROFPGA_REQUIRED_VER = proFPGA-2019A-SP4
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

ifdef LINUX_SMP
LINUX_CONFIG = $(CPU_ARCH)_smp_defconfig
else
LINUX_CONFIG = $(CPU_ARCH)_defconfig
endif

ifeq ("$(CPU_ARCH)", "ariane")
ARCH=riscv
CROSS_COMPILE_ELF = riscv64-unknown-elf-
CROSS_COMPILE_LINUX = riscv64-unknown-linux-gnu-
else
ARCH=sparc
CROSS_COMPILE_ELF = sparc-elf-
CROSS_COMPILE_LINUX = sparc-leon3-linux-
endif

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
VLOGOPT  += -suppress 2275
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

VSIMOPT += -uvmcontrol=disable -suppress 3009,2685,2718 -t ps

ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
EXTRA_SIMTOP  = glbl
else
EXTRA_SIMTOP  =
endif

# Compiler flags
ARIANE_VLOGOPT  =
ARIANE_VLOGOPT += -incr
ARIANE_VLOGOPT += -64
ARIANE_VLOGOPT += -nologo
ARIANE_VLOGOPT += -suppress 13262
ARIANE_VLOGOPT += -suppress 2286
ARIANE_VLOGOPT += -permissive
ARIANE_VLOGOPT += +define+WT_DCACHE
ARIANE_VLOGOPT += -pedanticerrors
ARIANE_VLOGOPT += -sv
ARIANE_VLOGOPT += +incdir+${ARIANE}/src/common_cells/include
ARIANE_VLOGOPT += -suppress 2583

# Simulator switches
ifeq ("$(CPU_ARCH)", "ariane")
VSIMOPT += +UVM_NO_RELNOTES -64 +permissive-off
VSIMOPT += -voptargs="+acc"
else
VSIMOPT += -novopt
endif
VSIMOPT += +notimingchecks
VSIMOPT += -suppress 3812
VSIMOPT += -suppress 2697
VSIMOPT += -suppress 8617
VSIMOPT += -suppress 151
VSIMOPT += -suppress 143
VSIMOPT += +notimingchecks

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
# SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/gencaches.vhd

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
