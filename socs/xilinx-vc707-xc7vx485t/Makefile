##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(shell realpath ../../)
CPU_ARCH = leon3
TECHLIB  = virtex7
BOARD    = xilinx-vc707-xc7vx485t
DESIGN   = esp-$(BOARD)
LINUX_CONFIG = leon3_defconfig


### NoC flit-width (not including head and tail bits)
NOC_WIDTH = 32


### Design top level and testbench ###
TOP    = top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
# VHDL-93 is required by some GRLIB source files
VCOMOPT += -93

# GRLIB options

# Print CPU instructions to simulator console
# VSIMOPT += -gdisas=1
VSIMOPT +=


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/sgmii_vc707.vhd
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= espdev.cs.columbia.edu
XIL_HW_SERVER_PORT ?= 3129


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile

