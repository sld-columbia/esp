##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
CPU_ARCH = leon3
TECHLIB  = virtex7
BOARD    = profpga-xc7v2000t
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
#VSIMOPT += -gdisas=1
ifneq ($(findstring ariane, $(CPU_ARCH)),)
VSIMOPT += +UVM_NO_RELNOTES -64 +permissive-off
else
VSIMOPT +=
endif


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/svga2tfp410.vhd
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= espdev.cs.columbia.edu
XIL_HW_SERVER_PORT ?= 3129


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile
