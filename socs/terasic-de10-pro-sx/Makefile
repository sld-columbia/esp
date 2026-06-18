# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
TECHLIB  = stratix10
BOARD    = terasic-de10-pro-sx
DESIGN   = esp-$(BOARD)
SMP = 0
BASE_FREQ_MHZ ?= 50
LEON3_STACK ?= 0x5bfffff0
USE_OPENSBI ?= 1

### Design top level and testbench ###
TOP    = top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
VCOMOPT +=
VLOGOPT +=

XCOMOPT +=
XLOGOPT +=

VSIMOPT +=


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS +=
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=

QUARTUS_EXTRA_RTL_SRCS += $(DESIGN_PATH)/quartus/fan/I2C_Bus_Controller.v
QUARTUS_EXTRA_RTL_SRCS += $(DESIGN_PATH)/quartus/fan/I2C_Config.v
QUARTUS_EXTRA_RTL_SRCS += $(DESIGN_PATH)/quartus/fan/Fan_Control.v
QUARTUS_EXTRA_RTL_SRCS += $(DESIGN_PATH)/quartus/fan/de10_pro_fan_controller.v


### FPGA JTAG server ###
FPGA_HOST ?= localhost
INTEL_JTAG_SERVER_PORT ?= 1309
INTEL_JTAG_SERVER_PASSWORD ?= esp
BOARD_CABLE ?=
BOARD_CABLE_MATCH ?=


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

# DE10-Pro HPS Linux host used by the Intel fpga-run backend.
# INTEL_HPS_HOST may include a user, for example user@de10-hps.
# If no user is included, the default Terasic SD-card user is used.
INTEL_HPS_HOST ?=
INTEL_HPS_USER ?= terasic
INTEL_HPS_SSH_PORT ?= 22
INTEL_HPS_RUN_DIR ?= .
INTEL_HPS_SSH_RUN_OPTS ?= -tt
INTEL_HPS_SUDO ?= sudo
INTEL_HPS_PEEK ?= ./esp_peek
INTEL_HPS_LOADER ?= ./esp_load_bootrom_edcl
INTEL_HPS_LOADER_CPU ?= $(CPU_ARCH)
INTEL_HPS_WAKE_ADDR_ariane ?= 0x2060090384
INTEL_HPS_WAKE_ADDR_ibex ?= 0x2060090384
INTEL_HPS_WAKE_ADDR_leon3 ?= 0x2080090384
INTEL_HPS_WAKE_ADDR_AUTO = $(INTEL_HPS_WAKE_ADDR_$(INTEL_HPS_LOADER_CPU))
INTEL_HPS_WAKE_ADDR ?= $(if $(strip $(INTEL_HPS_WAKE_ADDR_AUTO)),$(INTEL_HPS_WAKE_ADDR_AUTO),0x2060090384)

# MAC address for Linux if using IP address reservation (e.g. 00aabb33cc77)
# LINUX_MAC ?=


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile
