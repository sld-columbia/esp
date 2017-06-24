### Supported technology libraries ###
ASICLIBS =
FPGALIBS = virtex7


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

PROFPGA_REQUIRED_VER = proFPGA-2016B
PROFPGA_CURRENT_VER = $(shell basename $(PROFPGA))
ifneq ("$(PROFPGA_REQUIRED_VER)", "$(PROFPGA_CURRENT_VER)")
$(error proFPGA tools version must be "$(PROFPGA_REQUIRED_VER)")
endif

endif

### Create FPGA part name ###
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
include $(ESP_ROOT)/constraints/$(BOARD)/Makefile.inc
DEVICE = $(PART)$(PACKAGE)-$(SPEED)
else ifneq ($(filter $(TECHLIB),$(ASICLIBS)),)
DEVICE = ASIC-$(TECHLIB)
else
$(error technology library not supported)
endif


### Include grlib configuration (remake may occur) ###
-include .grlib_config
-include .esp_config


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


### Modelsim common options ###

VCOMOPT  +=
VLOGOPT  +=
VSIMOPT  +=

# Include unisim verilog librayr
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VSIMOPT += -L secureip_ver -L unisims_ver
endif

# Xilinx MIG
ifndef CONFIG_MIG_7SERIES_MODEL
VSIMOPT  += -gUSE_MIG_INTERFACE_MODEL=false -gSIM_BYPASS_INIT_CAL=FAST -gSIMULATION=TRUE
VSIMOPT  += -t fs
else
VSIMOPT  += -gUSE_MIG_INTERFACE_MODEL=true -t ps
endif

ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VSIMOPT  += glbl
endif

# Xilinx SGMII
ifeq ($(CONFIG_GRETH_ENABLE),y)
VSIMOPT += -L gig_ethernet_pcs_pma_v16_1_0
endif

# Simulator switches
VSIMOPT += -novopt +notimingchecks

# Toplevel
VSIMOPT += $(SIMTOP)


### Common design files ###
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sld_devices.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/allacc.vhd
SLDGEN_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/genacc.vhd

TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/grlib_config.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/socmap.vhd
TOP_VHDL_RTL_PKGS += $(DESIGN_PATH)/sldgen/sldacc.vhd
TOP_VHDL_RTL_PKGS += $(ESP_ROOT)/socs/common/soctiles.vhd

TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/accelerators.vhd
TOP_VHDL_RTL_SRCS += $(wildcard $(DESIGN_PATH)/sldgen/noc_*.vhd)
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/sldgen/tile_acc.vhd
TOP_VHDL_RTL_SRCS += $(wildcard $(ESP_ROOT)/socs/common/tile_*.vhd)
TOP_VHDL_RTL_SRCS += $(ESP_ROOT)/socs/common/esp.vhd
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/$(TOP).vhd

TOP_VLOG_RTL_SRCS +=

TOP_VHDL_SIM_PKGS +=

TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/$(SIMTOP).vhd

TOP_VLOG_SIM_SRCS +=
