##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
CPU_ARCH = leon3
TECHLIB  = virtexup
BOARD    = xilinx-vcu118-xcvu9p
DESIGN   = esp-$(BOARD)
LINUX_CONFIG = leon3_smp_defconfig


### Design top level and testbench ###
TOP    = top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
# VHDL-93 is required by some GRLIB source files
VCOMOPT += -93
VLOGOPT +=

XCOMOPT +=
XLOGOPT +=

# GRLIB options

# Print CPU instructions to simulator console
# VSIMOPT += -gdisas=1
ifneq ($(findstring ariane, $(CPU_ARCH)),)
VSIMOPT += +UVM_NO_RELNOTES -64 +permissive-off
else
VSIMOPT +=
endif


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/sgmii_vcu118_clock_reset.vhd $(ESP_ROOT)/socs/common/sgmii_vcu118.vhd
TOP_VLOG_RTL_SRCS += $(ESP_ROOT)/socs/common/sgmii_vcu118_reset_sync.v
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=

### Xilinx Vivado hw_server ###
FPGA_HOST ?= goliah.cs.columbia.edu
XIL_HW_SERVER_PORT ?= 3124


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile

