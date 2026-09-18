# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


CVA6 ?= $(ESP_ROOT)/rtl/cores/cva6/cva6

RISCV_TESTS = $(SOFT)/riscv-tests
RISCV_PK = $(SOFT)/riscv-pk
OPENSBI = $(SOFT)/opensbi

INITRAMFS_LIST_SCRIPT = $(LINUXSRC)/usr/gen_initramfs_list.sh
INITRAMFS_ARCHIVE_SCRIPT = $(LINUXSRC)/usr/gen_initramfs.sh

soft: $(SOFT_BUILD)/prom.srec $(SOFT_BUILD)/ram.srec $(SOFT_BUILD)/prom.bin $(SOFT_BUILD)/systest.bin $(SOFT_BUILD)/ram.vhx

soft-clean:
	$(QUIET_CLEAN)$(RM)		 	\
		$(SOFT_BUILD)/prom.srec 	\
		$(SOFT_BUILD)/ram.srec		\
		$(SOFT_BUILD)/prom.exe		\
		$(SOFT_BUILD)/systest.exe	\
		$(SOFT_BUILD)/prom.bin		\
		$(SOFT_BUILD)/riscv.dtb		\
		$(SOFT_BUILD)/startup.o		\
		$(SOFT_BUILD)/main.o		\
		$(SOFT_BUILD)/uart.o		\
		$(SOFT_BUILD)/systest.bin	\
		$(SOFT_BUILD)/ram.vhx8

soft-distclean: soft-clean

$(SOFT_BUILD)/riscv.dtb: $(ESP_CFG_BUILD)/riscv.dts $(ESP_CFG_BUILD)/socmap.vhd
	$(QUIET_BUILD) mkdir -p $(SOFT_BUILD)
	@dtc -I dts $< -O dtb -o $@

$(SOFT_BUILD)/startup.o: $(BOOTROM_PATH)/startup.S $(SOFT_BUILD)/riscv.dtb
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) cd $(SOFT_BUILD); $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) -DSMP=$(SMP)\
		-c $< -o startup.o

$(SOFT_BUILD)/main.o: $(BOOTROM_PATH)/main.c $(ESP_CFG_BUILD)/esplink.h
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-c $< -o $@

$(SOFT_BUILD)/uart.o: $(BOOTROM_PATH)/uart.c $(ESP_CFG_BUILD)/esplink.h
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-c $< -o $@

$(SOFT_BUILD)/prom.exe: $(SOFT_BUILD)/startup.o $(SOFT_BUILD)/uart.o $(SOFT_BUILD)/main.o $(BOOTROM_PATH)/linker.lds
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-nostdlib -nodefaultlibs -nostartfiles \
		-T$(BOOTROM_PATH)/linker.lds \
		$(SOFT_BUILD)/startup.o $(SOFT_BUILD)/uart.o $(SOFT_BUILD)/main.o \
		-o $@

$(SOFT_BUILD)/prom.srec: $(SOFT_BUILD)/prom.exe
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

$(SOFT_BUILD)/prom.bin: $(SOFT_BUILD)/prom.exe
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary $< $@


RISCV_CFLAGS  = -I$(RISCV_TESTS)/env
RISCV_CFLAGS += -I$(RISCV_TESTS)/benchmarks/common
RISCV_CFLAGS += -I$(BOOTROM_PATH)
RISCV_CFLAGS += -mcmodel=medany
RISCV_CFLAGS += -static
RISCV_CFLAGS += -std=gnu99
RISCV_CFLAGS += -O2
RISCV_CFLAGS += -ffast-math
RISCV_CFLAGS += -fno-common
RISCV_CFLAGS += -fno-builtin-printf
RISCV_CFLAGS += -nostdlib
RISCV_CFLAGS += -nostartfiles -lm -lgcc

$(SOFT_BUILD)/systest.exe: systest.c $(SOFT_BUILD)/uart.o
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc $(RISCV_CFLAGS) \
	$(SOFT)/common/syscalls.c \
	$(RISCV_TESTS)/benchmarks/common/crt.S  \
	-T $(RISCV_TESTS)/benchmarks/common/test.ld -o $@ \
	-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
	$(SOFT_BUILD)/uart.o $<

$(SOFT_BUILD)/systest.bin: $(TEST_PROGRAM)
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O binary $< $@

$(SOFT_BUILD)/ram.srec: $(TEST_PROGRAM)
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O srec --gap-fill 0 $< $@
	@if [ -n "$(SIM_DATA_FILES)" ]; then\
		python3 $(ESP_ROOT)/utils/scripts/srec/modify_srec.py $@ $(SIM_DATA_FILES) $(START_ADDRS);\
	fi

$(SOFT_BUILD)/ram.vhx: $(SOFT_BUILD)/systest.bin $(SOFT_BUILD)/vhx.bin

$(SOFT_BUILD)/vhx.bin: $(TEST_PROGRAM)
	python3 $(ESP_ROOT)/utils/scripts/file_handling/bin2txt_vhx.py 64 cva6

$(SOFT_BUILD)/sysroot:
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CP)cp -r $(SOFT)/sysroot $(SOFT_BUILD)
	@if [ -f $(SOFT_BUILD)/sysroot/bin/busybox ]; then chmod 4755 $(SOFT_BUILD)/sysroot/bin/busybox; fi

$(SOFT_BUILD)/sysroot.files: $(SOFT_BUILD)/sysroot
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_MAKE)$(MAKE) -C ${LINUXSRC}/usr gen_init_cpio
	$(QUIET_INFO)echo "Generating root file-system list..."
	@if [ -x "$(INITRAMFS_LIST_SCRIPT)" ]; then \
		sh "$(INITRAMFS_LIST_SCRIPT)" -u `id -u` -g `id -g` $< \
		    | sed -e 's/^file \(\/bin\/busybox .*\) 755 0 0/file \1 4755 0 0/' \
		    > $@; \
	elif [ -x "$(INITRAMFS_ARCHIVE_SCRIPT)" ]; then \
		: > $@; \
	else \
		echo "ERROR: initramfs generator not found under ${LINUXSRC}/usr"; \
		exit 1; \
	fi
	@echo "nod /dev/console 622 0 0 c 5 1" >> $@
	@touch $@


$(SOFT_BUILD)/sysroot.cpio: $(SOFT_BUILD)/sysroot.files
	@if [ -x "$(INITRAMFS_LIST_SCRIPT)" ]; then \
		${LINUXSRC}/usr/gen_init_cpio $< > $@; \
	elif [ -x "$(INITRAMFS_ARCHIVE_SCRIPT)" ]; then \
		cd ${LINUXSRC}; sh usr/gen_initramfs.sh -u `id -u` -g `id -g` -o $@ $(SOFT_BUILD)/sysroot $<; \
	else \
		echo "ERROR: initramfs generator not found under ${LINUXSRC}/usr"; \
		exit 1; \
	fi


# Patch the kernel source tree before any build step touches it.
# Idempotent: each rule short-circuits if the change is already in place.
# Currently applies:
#   - linux-dtc-fcommon.patch: forces -fcommon for the in-tree dtc on
#     GCC >= 10 (Ubuntu 22.04+, RHEL 9+), where -fno-common is the default
#     and breaks the older lex/yacc-generated host objects.
.PHONY: linux-patches
linux-patches:
	@if grep -q -- '-fcommon' $(LINUXSRC)/scripts/dtc/Makefile; then :; \
	else \
		echo "  PATCH    linux-dtc-fcommon-cva6.patch"; \
		patch -p1 -s -d $(LINUXSRC) -i $(ESP_ROOT)/utils/toolchain/patches/linux-dtc-fcommon-cva6.patch; \
	fi

$(SOFT_BUILD)/linux-build/.config: $(LINUXSRC)/arch/$(ARCH)/configs/$(LINUX_CONFIG) | linux-patches
	@$(MAKE) $(SOFT_BUILD)/linux-build
	$(QUIET_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE)  O=$(SOFT_BUILD)/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)


$(SOFT_BUILD)/linux-build/vmlinux: $(SOFT_BUILD)/sysroot.cpio $(SOFT_BUILD)/linux-build/.config
	$(QUIET_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) -C $(SOFT_BUILD)/linux-build


$(SOFT_BUILD)/pk-build:
	$(QUIET_MKDIR)mkdir -p $@


$(SOFT_BUILD)/pk-build/bbl: $(SOFT_BUILD)/pk-build sysroot-update
	$(QUIET_CHECK) cd $(SOFT_BUILD)/pk-build; \
		if ! test -e Makefile; then \
			$(RISCV_PK)/configure \
				--host=riscv64-unknown-elf \
				CC=$(CROSS_COMPILE_ELF)gcc \
				OBJDUMP=riscv64-unknown-elf-objdump \
				--with-payload=../linux-build/vmlinux; \
		fi;
	$(QUIET_MAKE) $(MAKE) -C $(SOFT_BUILD)/pk-build

$(SOFT_BUILD)/opensbi-build:
	$(QUIET_MKDIR)mkdir -p $@

$(SOFT_BUILD)/opensbi-build/platform/esp-fpga/firmware/fw_payload.bin: $(SOFT_BUILD)/opensbi-build sysroot-update
	$(QUIET_MAKE) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) BASE_FREQ=$(BASE_FREQ_MHZ) \
	NCPU_TILE=$(NCPU_TILE) \
	$(MAKE) -C $(OPENSBI) PLATFORM=esp-fpga \
			FW_PAYLOAD_PATH=$(SOFT_BUILD)/linux-build/arch/riscv/boot/Image O=$<

ifeq ("$(USE_OPENSBI)", "1")
$(SOFT_BUILD)/linux.bin: $(SOFT_BUILD)/opensbi-build/platform/esp-fpga/firmware/fw_payload.bin
	$(QUIET_CP) cp $< $@
else
$(SOFT_BUILD)/linux.bin: $(SOFT_BUILD)/pk-build/bbl
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -S -O binary --change-addresses -0x80000000 $< $@
endif

linux: $(SOFT_BUILD)/linux.bin $(SOFT_BUILD)/prom.bin


linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e $(SOFT_BUILD)/linux-build; then \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) --quiet -C $(SOFT_BUILD)/linux-build clean; \
	fi;


linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/linux-build $(SOFT_BUILD)/pk-build $(SOFT_BUILD)/linux.bin


### Flags

## Genus
GENUS_VLOGOPT += -define WT_DCACHE=1
GENUS_VLOGOPT += -define ESP_CVA6

## Modelsim
VLOGOPT +=
VLOGOPT += -incr
VLOGOPT += -nologo
VLOGOPT += -suppress 13262
VLOGOPT += -suppress 2286
VLOGOPT += -permissive
VLOGOPT += +define+WT_DCACHE
VLOGOPT += +define+ESP_CVA6
VLOGOPT += -pedanticerrors
VLOGOPT += -suppress 2583
ifeq ("$(CPU_ARCH)", "cva6")
VSIMOPT += +UVM_NO_RELNOTES +permissive-off
VSIMOPT += -voptargs="+acc"
else
VSIMOPT += -novopt
endif

## Xcelium
XMLOGOPT +=
# Define verilator env because Xcelium do not support SVAs and UVM in CVA6
XMLOGOPT += -DEFINE VERILATOR
XMLOGOPT += -UNCLOCKEDSVA
XMLOGOPT += -DEFINE WT_DCACHE=1
XMLOGOPT += -DEFINE ESP_CVA6

# target takes one of the following cva6 hardware configuration:
# cv64a6_imafdc_sv39, cv32a6_imac_sv0, cv32a6_imac_sv32, cv32a6_imafc_sv32, cv32a6_ima_sv32_fpga
# Changing the default target to cv32a60x for Step1 verification
target     ?= cv64a6_imafdc_sv39
ifeq ($(target), cv64a6_imafdc_sv39)
	XLEN ?= 64
else
	XLEN ?= 32
endif
ifndef TARGET_CFG
	export TARGET_CFG = $(target)
endif


### Incdir and RTL

ifeq ("$(CPU_ARCH)", "cva6")
INCDIR += $(CVA6)/core/include/
INCDIR += $(CVA6)/vendor/pulp-platform/common_cells/include/
INCDIR += $(CVA6)/vendor/pulp-platform/common_cells/src/
INCDIR += $(CVA6)/vendor/pulp-platform/axi/include/
INCDIR += $(CVA6)/common/local/util/
# VHDL_SRCS += $(foreach f, $(shell strings $(FLISTS)/cva6_vhdl.flist), $(ESP_ROOT)/rtl/$(f))
VERILOG_CVA6 += $(foreach f, $(shell strings $(FLISTS)/cva6_vlog.flist), $(CVA6)/$(f))
VERILOG_CVA6 += $(DESIGN_PATH)/$(ESP_CFG_BUILD)/plic_regmap.sv
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VERILOG_CVA6 += $(foreach f, $(shell strings $(FLISTS)/cva6_fpga_vlog.flist), $(CVA6)/$(f))
endif
THIRDPARTY_VLOG += $(VERILOG_CVA6)
endif
