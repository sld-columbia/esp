##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
TECHLIB  = virtex7
BOARD    = xilinx-vc707-xc7vx485t
DESIGN   = esp-$(BOARD)
#LINUX_SMP = 1
LEON3_BASE_FREQ_MHZ ?= 50
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
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/sgmii_vc707.vhd
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= localhost
XIL_HW_SERVER_PORT ?= 3121


### Network configuration ###

# IP address or host name of the host connected to the FPGA
UART_IP ?=
UART_PORT ?=

# SSH IP address or host name of the ESP Linux instance or gateway
SSH_IP ?=
SSH_PORT ?= 22

# ESPLink IP address or gateway (DO NOT USE HOST NAME)
ESPLINK_IP ?=
ESPLINK_PORT ?= 46392

# MAC address for Linux if using IP address reservation (e.g. 00aabb33cc77)
# LINUX_MAC ?=


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile
