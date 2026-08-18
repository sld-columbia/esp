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

QUARTUS_TOP ?= ghrd_s10_top
QUARTUS_HPS_BOOTLOADER ?= ../local/boot/u-boot-spl-dtb.hex
QUARTUS_EXTRA_RTL_SRCS += $(wildcard $(DESIGN_PATH)/fpga/fan/*.v)

DTC ?= dtc
HPS_DTS ?= hps/devicetree/socfpga_stratix10_de10_pro.dts
HPS_DTB ?= local/boot/socfpga_stratix10_de10_pro.dtb

HPS_BOOT_SCRIPT ?= $(ESP_ROOT)/utils/scripts/hps/build_boot_artifacts.sh
HPS_BOOT_WORK ?= $(DESIGN_PATH)/local/hps-boot
HPS_BOOT_OUT ?= $(DESIGN_PATH)/local/boot
HPS_BOOT_ITB ?= $(HPS_BOOT_OUT)/u-boot.itb
HPS_BOOT_SPL_HEX ?= $(HPS_BOOT_OUT)/u-boot-spl-dtb.hex
HPS_BOOT_MANIFEST ?= $(HPS_BOOT_OUT)/hps-boot-artifacts.txt
HPS_BOOT_UBOOT_REPO ?= https://github.com/altera-fpga/u-boot-socfpga.git
HPS_BOOT_UBOOT_REF ?= rel_socfpga_v2021.01_21.10.01_pr
HPS_BOOT_UBOOT_DEFCONFIG ?= socfpga_stratix10_atf_defconfig
HPS_BOOT_UBOOT_OVERLAY ?= $(DESIGN_PATH)/hps/boot/u-boot-overlay
HPS_BOOT_ATF_REPO ?= https://github.com/altera-fpga/arm-trusted-firmware.git
HPS_BOOT_ATF_REF ?= rel_socfpga_v2.4.1_21.10.01_pr
HPS_BOOT_ATF_PLAT ?= stratix10
HPS_TOOLCHAIN_SCRIPT ?= $(ESP_ROOT)/utils/toolchain/build_aarch64_toolchain.sh
HPS_TOOLCHAIN_DIR ?= $(DESIGN_PATH)/local/toolchain/aarch64-linux-gnu
HPS_TOOLCHAIN_NATIVE_PREFIX ?= $(HPS_TOOLCHAIN_DIR)/buildroot-output/host/bin/aarch64-buildroot-linux-gnu-
HPS_TOOLCHAIN_ALIAS_PREFIX ?= $(HPS_TOOLCHAIN_DIR)/bin/aarch64-linux-gnu-
HPS_TOOLCHAIN_PREFIX ?= $(if $(wildcard $(HPS_TOOLCHAIN_NATIVE_PREFIX)gcc),$(HPS_TOOLCHAIN_NATIVE_PREFIX),$(HPS_TOOLCHAIN_ALIAS_PREFIX))
HPS_TOOLCHAIN_BUILDROOT_REF ?= 2025.02.15
HPS_TOOLCHAIN_JOBS ?=
HPS_BOOT_CROSS_COMPILE ?= $(if $(strip $(CROSS_COMPILE)),$(CROSS_COMPILE),$(if $(wildcard $(HPS_TOOLCHAIN_PREFIX)gcc),$(HPS_TOOLCHAIN_PREFIX),aarch64-linux-gnu-))
HPS_BOOT_JOBS ?=
HPS_BOOT_OFFLINE ?= 0


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


### HPS boot device tree ###

local/boot:
	$(QUIET_MKDIR)mkdir -p $@

$(HPS_DTB): $(HPS_DTS) | local/boot
	@command -v $(DTC) >/dev/null 2>&1 || { echo $(SPACES)"ERROR: dtc not found in PATH"; false; }
	@$(RM) "$@"
	$(QUIET_BUILD)$(DTC) -I dts -O dtb -o $@ $<

hps-dtb: $(HPS_DTB)

hps-dtb-rebuild: | local/boot
	@$(RM) "$(HPS_DTB)"
	@$(MAKE) --no-print-directory hps-dtb

hps-boot: | local/boot
	@test -x "$(HPS_BOOT_SCRIPT)" || { echo $(SPACES)"ERROR: HPS boot script not found or not executable: $(HPS_BOOT_SCRIPT)"; false; }
	@test -d "$(HPS_BOOT_UBOOT_OVERLAY)" || { echo $(SPACES)"ERROR: HPS U-Boot overlay not found: $(HPS_BOOT_UBOOT_OVERLAY)"; false; }
	$(QUIET_INFO)echo "building HPS U-Boot FIT and SPL HEX"
	@$(RM) "$(HPS_BOOT_ITB)" "$(HPS_BOOT_SPL_HEX)" "$(HPS_BOOT_MANIFEST)"
	@HPS_BOOT_BOARD="$(BOARD)" \
	HPS_BOOT_WORK="$(HPS_BOOT_WORK)" \
	HPS_BOOT_OUT="$(HPS_BOOT_OUT)" \
	HPS_BOOT_UBOOT_REPO="$(HPS_BOOT_UBOOT_REPO)" \
	HPS_BOOT_UBOOT_REF="$(HPS_BOOT_UBOOT_REF)" \
	HPS_BOOT_UBOOT_DEFCONFIG="$(HPS_BOOT_UBOOT_DEFCONFIG)" \
	HPS_BOOT_UBOOT_OVERLAY="$(HPS_BOOT_UBOOT_OVERLAY)" \
	HPS_BOOT_ATF_REPO="$(HPS_BOOT_ATF_REPO)" \
	HPS_BOOT_ATF_REF="$(HPS_BOOT_ATF_REF)" \
	HPS_BOOT_ATF_PLAT="$(HPS_BOOT_ATF_PLAT)" \
	HPS_BOOT_CROSS_COMPILE="$(HPS_BOOT_CROSS_COMPILE)" \
	HPS_BOOT_JOBS="$(HPS_BOOT_JOBS)" \
	HPS_BOOT_OFFLINE="$(HPS_BOOT_OFFLINE)" \
	CROSS_COMPILE="$(HPS_BOOT_CROSS_COMPILE)" \
	"$(HPS_BOOT_SCRIPT)"
	@test -s "$(HPS_BOOT_ITB)" || { echo $(SPACES)"ERROR: HPS U-Boot FIT was not generated: $(HPS_BOOT_ITB)"; false; }
	@test -s "$(HPS_BOOT_SPL_HEX)" || { echo $(SPACES)"ERROR: HPS SPL HEX was not generated: $(HPS_BOOT_SPL_HEX)"; false; }

hps HPS: hps-dtb-rebuild hps-boot

hps-toolchain:
	@test -x "$(HPS_TOOLCHAIN_SCRIPT)" || { echo $(SPACES)"ERROR: HPS toolchain script not found or not executable: $(HPS_TOOLCHAIN_SCRIPT)"; false; }
	$(QUIET_INFO)echo "building local AArch64 Linux cross compiler"
	@AARCH64_TARGET_DIR="$(HPS_TOOLCHAIN_DIR)" \
	AARCH64_BUILDROOT_REF="$(HPS_TOOLCHAIN_BUILDROOT_REF)" \
	AARCH64_BUILD_JOBS="$(HPS_TOOLCHAIN_JOBS)" \
	"$(HPS_TOOLCHAIN_SCRIPT)"

hps-dtb-clean:
	$(QUIET_CLEAN)$(RM) "$(HPS_DTB)"

hps-boot-clean:
	$(QUIET_CLEAN)$(RM) -r "$(HPS_BOOT_WORK)"
	$(QUIET_CLEAN)$(RM) "$(HPS_BOOT_ITB)" "$(HPS_BOOT_SPL_HEX)" "$(HPS_BOOT_MANIFEST)"

hps-toolchain-clean:
	$(QUIET_CLEAN)$(RM) -r "$(HPS_TOOLCHAIN_DIR)"

hps-clean: hps-dtb-clean hps-boot-clean

.PHONY: hps HPS hps-clean hps-boot hps-boot-clean hps-dtb hps-dtb-clean hps-dtb-rebuild hps-toolchain hps-toolchain-clean

# MAC address for Linux if using IP address reservation (e.g. 00aabb33cc77)
# LINUX_MAC ?=


### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile
