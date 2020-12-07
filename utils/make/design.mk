# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Supported technology libraries ###
ASICLIBS = gf12
FPGALIBS = virtex7 virtexu virtexup


### Check for technology library definition ###
ifeq ("$(TECHLIB)","")
$(error technology library not specified)
endif

ifeq ("$(XILINX_VIVADO)","")
$(error XILINX_VIVADO path not specified)
endif

ifneq ($(findstring profpga, $(BOARD)),)

ifeq ("$(PROFPGA)","")
$(error proFPGA path not specified)
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


### Simulate BRAMs ###
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
EXTRA_SIMTOP  = glbl
else
EXTRA_SIMTOP  =
endif


### Include grlib and ESP configuration (remake may occur) ###
-include .grlib_config
-include .esp_config


### Toolchain
ifdef LINUX_SMP
LINUX_CONFIG = $(CPU_ARCH)_smp_defconfig
else
LINUX_CONFIG = $(CPU_ARCH)_defconfig
endif

ifeq ("$(CPU_ARCH)", "ariane")
ARCH=riscv
CROSS_COMPILE_ELF = riscv64-unknown-elf-
CROSS_COMPILE_LINUX = riscv64-unknown-linux-gnu-
endif

ifeq ("$(CPU_ARCH)", "ibex")
ARCH=riscv
CROSS_COMPILE_ELF = riscv32-unknown-elf-
endif

ifeq ("$(CPU_ARCH)", "leon3")
ARCH=sparc
CROSS_COMPILE_ELF = sparc-elf-
CROSS_COMPILE_LINUX = sparc-linux-
endif

# Random MAC address for Linux
LINUX_MAC ?= $(shell echo 0000$$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$$/\1\2\3\4/'))


### Common design files ###
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/esp_global.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sld_devices.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/allacc.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/genacc.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/allcaches.vhd

TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/grlib_config.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/socmap.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sldacc.vhd
TOP_VHDL_RTL_PKGS += $(ESP_ROOT)/rtl/tiles/tiles_pkg.vhd
TOP_VHDL_RTL_PKGS += $(EXTRA_TOP_VHDL_RTL_PKGS)

TOP_VHDL_SIM_PKGS +=

TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/accelerators.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/caches.vhd
TOP_VHDL_RTL_SRCS += $(wildcard $(DESIGN_PATH)/sldgen/noc_*.vhd)
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/tile_acc.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/$(TOP).vhd

TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/$(SIMTOP).vhd

TOP_VLOG_RTL_SRCS +=
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
TOP_VLOG_SIM_SRCS += $(XILINX_VIVADO)/data/verilog/src/glbl.v
endif

TOP_VLOG_SIM_SRCS +=
