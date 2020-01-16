##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
TECHLIB  = virtexu
BOARD    = profpga-xcvu440
DESIGN   = esp-$(BOARD)
# LINUX_SMP = 1
LEON3_BASE_FREQ_MHZ ?= 78
LEON3_STACK ?= 0x5bfffff0


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

VSIMOPT +=


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/svga2tfp410.vhd
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= localhost
XIL_HW_SERVER_PORT ?= 3121


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile
