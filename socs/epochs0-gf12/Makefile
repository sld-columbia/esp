##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
TECHLIB  = gf12
FPGA_TECHLIB = virtex7
BOARD    = profpga-xc7v2000t-epochs0-gf12
DESIGN   = $(BOARD)
SMP = 0
BASE_FREQ_MHZ ?= 50
LEON3_STACK ?= 0x5bfffff0
USE_OPENSBI ?= 1

OVR_TECHLIB ?=
ifneq ("$(OVR_TECHLIB)", "")
TECHLIB = $(OVR_TECHLIB)
endif

### Chip-specific configuration ####
ESP_DEFCONFIG = $(DESIGN_PATH)/esp_epochs0_defconfig


### Design top level and testbench ###
CHIP_TOP = EPOCHS0_TOP
TOP = fpga_proxy_top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
ifneq ("$(OVR_TECHLIB)", "")
VCOMOPT +=
VLOGOPT +=
XMLOGOPT +=
NCLOGOPT +=
else
VCOMOPT +=
VLOGOPT += +define+ASIC
VLOGOPT += +define+GF12
XMLOGOPT += -DEFINE ASIC
XMLOGOPT += -DEFINE GF12
NCLOGOPT += -DEFINE ASIC
NCLOGOPT += -DEFINE GF12
endif

# Add Unisim libraries to simulate FPGA proxy
VSIMOPT += -L secureip_ver -L unisims_ver


# SIMULATION moved to testbench generic
VSIMOPT += -g SIMULATION=true


# Genus flags
GENUS_VLOGOPT += -define ASIC
GENUS_VLOGOPT += -define GF12


### Additional design files ###
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/pads_loc.vhd
TOP_VHDL_RTL_SRCS +=
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/top.vhd
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= localhost
XIL_HW_SERVER_PORT ?= 3121


# IP address or host name of the host connected to the FPGA
UART_IP ?=
UART_PORT ?=

# SSH IP address or host name of the ESP Linux instance or gateway
SSH_IP ?=
SSH_PORT ?= 22

# ESPLink IP address or gateway (DO NOT USE HOST NAME)
ESPLINK_IP ?=
ESPLINK_PORT ?= 46392

FPGA_PROXY_IP ?=
FPGA_PROXY_PORT ?= 46392
# MAC address for Linux if using IP address reservation (e.g. 00aabb33cc77)
# LINUX_MAC ?=


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile

# Force socmap.vhd regeneration w/ FPGA emulation target technology
ifneq ("$(OVR_TECHLIB)", "")
.PHONY: socmap.vhd
endif
