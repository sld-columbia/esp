# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)

ifneq ("$(shell basename $(PWD))", "esp_asic_generic")
ESP_ROOT = $(realpath ../esp)
include $(ESP_ROOT)/tools/asicgen/asic_defs.sh
else
ESP_ROOT = $(realpath ../../)
DIRTECH_NAME = inferred
endif

TECHLIB  = $(DIRTECH_NAME)
TECH_TYPE = asic
FPGA_TECHLIB = virtex7
BOARD    = profpga-xc7v2000t-esp_asic_generic
DESIGN   = $(BOARD)
SMP = 0
BASE_FREQ_MHZ ?= 50
LEON3_STACK ?= 0x5bfffff0
USE_OPENSBI ?= 0

OVR_TECHLIB ?=
ifneq ("$(OVR_TECHLIB)", "")
TECHLIB = $(OVR_TECHLIB)
TECH_TYPE = fpga
endif

### Chip-specific configuration ###
GRLIB_DEFCONFIG = $(DESIGN_PATH)/grlib_defconfig
ESP_DEFCONFIG = $(DESIGN_PATH)/esp_defconfig


### Design top level and testbench ###
CHIP_TOP = ESP_ASIC_TOP
TOP = fpga_proxy_top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
ifneq ("$(OVR_TECHLIB)", "")
VCOMOPT +=
VLOGOPT +=
XMLOGOPT +=
NCLOGOPT +=
else ifeq ($(TECHLIB),inferred)
VCOMOPT +=
VLOGOPT +=
XMLOGOPT +=
NCLOGOPT +=
else
VCOMOPT +=
VLOGOPT += +define+ASIC
XMLOGOPT += -DEFINE ASIC
NCLOGOPT += -DEFINE ASIC
endif

# Add Unisim libraries to simulate FPGA proxy
VSIMOPT += -L secureip_ver -L unisims_ver


# SIMULATION moved to testbench generic
VSIMOPT += -g SIMULATION=true


# Genus flags
GENUS_VLOGOPT += -define ASIC


### Additional design files ###
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/fpga_proxy_top.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/pads_loc.vhd
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/top.vhd
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

### DCO model selection for ModelSim RTL simulation ###
# Structural timing simulation is preferred when the core DCO sources and its
# SDF are present.  LPDDR and delay-line sources are optional because the
# generated ASIC top does not elaborate them for normal tiles.  The behavioral
# fallback reuses the inferred DCO model and is enabled only in the simulator
# compile; synthesis sources remain unchanged.
DCO_SIM_MODEL ?= auto
DCO_SDF ?= $(ESP_ROOT)/rtl/techmap/asic/dco/DCO_tt.sdf
DCO_SIM_MODELS := auto behavioral structural
DCO_BEHAVIORAL_SIM_SRC := $(ESP_ROOT)/rtl/sockets/dvfs/behav_dco.v
DCO_STRUCTURAL_CORE_SIM_SRCS := \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DCO_common.v \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DCO.v
DCO_STRUCTURAL_SIM_SRCS := \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DCO_common.v \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DELAY_CELL.v \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DCO_LPDDR.v \
	$(ESP_ROOT)/rtl/techmap/asic/dco/DCO.v
DCO_EXISTING_STRUCTURAL_SIM_SRCS := $(foreach src,$(DCO_STRUCTURAL_SIM_SRCS),$(if $(wildcard $(src)),$(src)))
DCO_MISSING_STRUCTURAL_CORE_SIM_SRCS := $(foreach src,$(DCO_STRUCTURAL_CORE_SIM_SRCS),$(if $(wildcard $(src)),,$(src)))
DCO_MODELSIM_GOALS := sim sim-gui sim-compile modelsim/vsim.mk
DCO_MODELSIM_REQUESTED := $(filter $(DCO_MODELSIM_GOALS),$(MAKECMDGOALS))

ifeq ($(filter $(DCO_SIM_MODEL),$(DCO_SIM_MODELS)),)
ifneq ($(DCO_MODELSIM_REQUESTED),)
$(error Invalid DCO_SIM_MODEL '$(DCO_SIM_MODEL)'; expected one of: $(DCO_SIM_MODELS))
endif
endif

ifneq (,$(strip $(OVR_TECHLIB)))
DCO_SIM_MODEL_RESOLVED := bypass
else ifeq ($(DCO_SIM_MODEL),auto)
ifeq (,$(strip $(DCO_MISSING_STRUCTURAL_CORE_SIM_SRCS)))
ifneq (,$(wildcard $(DCO_SDF)))
DCO_SIM_MODEL_RESOLVED := structural
else
DCO_SIM_MODEL_RESOLVED := behavioral
endif
else
DCO_SIM_MODEL_RESOLVED := behavioral
endif
else
DCO_SIM_MODEL_RESOLVED := $(DCO_SIM_MODEL)
endif

ifeq ($(DCO_SIM_MODEL_RESOLVED),structural)
ifneq ($(DCO_MODELSIM_REQUESTED),)
ifneq (,$(strip $(DCO_MISSING_STRUCTURAL_CORE_SIM_SRCS)))
$(error Structural DCO simulation is missing core source files: $(DCO_MISSING_STRUCTURAL_CORE_SIM_SRCS))
endif
ifeq (,$(wildcard $(DCO_SDF)))
$(error Structural DCO simulation requires DCO_SDF: $(DCO_SDF))
endif
endif
SIM_VLOG_SRCS := $(filter-out $(DCO_STRUCTURAL_SIM_SRCS),$(SIM_VLOG_SRCS))
SIM_VLOG_SRCS += $(DCO_EXISTING_STRUCTURAL_SIM_SRCS)
else ifeq ($(DCO_SIM_MODEL_RESOLVED),behavioral)
SIM_VLOG_SRCS := $(filter-out $(DCO_STRUCTURAL_SIM_SRCS),$(SIM_VLOG_SRCS))
SIM_VLOG_SRCS += $(DCO_BEHAVIORAL_SIM_SRC)
VLOGOPT += +define+ASIC_DCO_BEHAV_FALLBACK
endif

# A mode change must rebuild the ModelSim work library.  Otherwise a compiled
# structural DCO can remain in work and shadow the behavioral compatibility
# wrapper (or vice versa).
DCO_SIM_MODEL_STAMP := modelsim/.dco_sim_model_$(DCO_SIM_MODEL_RESOLVED)
$(DCO_SIM_MODEL_STAMP):
	@mkdir -p modelsim
	@rm -f modelsim/.dco_sim_model_auto modelsim/.dco_sim_model_behavioral \
		modelsim/.dco_sim_model_structural modelsim/.dco_sim_model_bypass
	@touch $@

modelsim/vsim.mk: $(DCO_SIM_MODEL_STAMP)

export DCO_SIM_MODEL_RESOLVED
export DCO_SDF

### Uncomment this part when running ASIC flow
# exist := $(wildcard ../esp_eda/esp/make/asicrun.mk)
# ifneq ($(strip $(exist)),)
#   include ../esp_eda/esp/make/tools.mk
#   include ../esp_eda/esp/make/asicrun.mk
# endif

# Force socmap.vhd regeneration w/ FPGA emulation target technology
ifneq ("$(OVR_TECHLIB)", "")
.PHONY: socmap.vhd
endif
