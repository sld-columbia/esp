# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


ARIANE ?= $(ESP_ROOT)/rtl/cores/ariane/ariane

RISCV_TESTS = $(SOFT)/riscv-tests
RISCV_PK = $(SOFT)/riscv-pk

soft: prom.srec ram.srec prom.bin systest.bin

soft-clean:
	$(QUIET_CLEAN)$(RM) 	\
		prom.srec 	\
		ram.srec	\
		prom.exe	\
		systest.exe	\
		prom.bin	\
		riscv.dtb	\
		startup.o	\
		main.o		\
		uart.o		\
		systest.bin

soft-distclean: soft-clean ahbrom-distclean

riscv.dtb: riscv.dts socmap.vhd
	$(QUIET_BUILD) dtc -I dts $< -O dtb -o $@

startup.o: $(BOOTROM_PATH)/startup.S riscv.dtb
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-c $< -o $@

main.o: $(BOOTROM_PATH)/main.c socmap.h
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

uart.o: $(BOOTROM_PATH)/uart.c socmap.h
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

prom.exe: startup.o uart.o main.o $(BOOTROM_PATH)/linker.lds
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-nostdlib -nodefaultlibs -nostartfiles \
		-T$(BOOTROM_PATH)/linker.lds \
		startup.o uart.o main.o \
		-o $@

prom.srec: prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

prom.bin: prom.exe
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary $< $@


ahbrom: $(UTILS_GRLIB)/ahbrom.c
	$(QUIET_CC)$(CC) $< -o $@

ahbrom.vhd: prom.bin ahbrom
	$(QUIET_BUILD)./ahbrom $< $@

ahbrom-clean:
	$(QUIET_CLEAN)$(RM) ahbrom

ahbrom-distclean: ahbrom-clean
	$(QUIET_CLEAN)$(RM) ahbrom.vhd


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

systest.exe: systest.c uart.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc $(RISCV_CFLAGS) \
	$(SOFT)/common/syscalls.c \
	$(RISCV_TESTS)/benchmarks/common/crt.S  \
	-T $(RISCV_TESTS)/benchmarks/common/test.ld -o $@ \
	-I$(DESIGN_PATH) \
	uart.o $<

systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O binary $< $@

ram.srec: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O srec --gap-fill 0 $< $@



.PHONY: ahbrom-clean ahbrom-distclean

sysroot:
	$(QUIET_CP)cp -r $(SOFT)/sysroot .

sysroot.files: sysroot
	$(QUIET_MAKE)$(MAKE) -C ${LINUXSRC}/usr gen_init_cpio
	$(QUIET_INFO)echo "Generating root file-system list..."
	@sh ${LINUXSRC}/usr/gen_initramfs_list.sh -u `id -u` -g `id -g` $< \
	    | sed -e 's/^file \(\/bin\/busybox .*\) 755 0 0/file \1 4755 0 0/' \
	    > $@;
	@echo "nod /dev/console 622 0 0 c 5 1" >> $@
	@touch $@


sysroot.cpio: sysroot.files
	$(QUIET_BUILD)${LINUXSRC}/usr/gen_init_cpio $< > $@


linux-build/.config: $(LINUXSRC)/arch/$(ARCH)/configs/$(LINUX_CONFIG)
	@$(MAKE) linux-build
	$(QUIET_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE)  O=${PWD}/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)


linux-build/vmlinux: sysroot.cpio linux-build/.config
	$(QUIET_MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) -C linux-build


pk-build:
	$(QUIET_MKDIR)mkdir -p $@


pk-build/bbl: pk-build sysroot-update
	$(QUIET_CHECK) cd pk-build; \
		if ! test -e Makefile; then \
			$(RISCV_PK)/configure \
				--host=riscv64-unknown-elf \
				CC=$(CROSS_COMPILE_ELF)gcc \
				OBJDUMP=riscv64-unknown-elf-objdump \
				--with-payload=../linux-build/vmlinux; \
		fi;
	$(QUIET_MAKE) $(MAKE) -C pk-build


linux.bin: pk-build/bbl
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -S -O binary --change-addresses -0x80000000 $< $@


linux: linux.bin prom.bin


linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e linux-build; then \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) --quiet -C linux-build clean; \
	fi;


linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) linux-build pk-build linux.bin


### Flags

## Genus
GENUS_VLOGOPT += -define WT_DCACHE=1

## Modelsim
VLOGOPT +=
VLOGOPT += -incr
VLOGOPT += -64
VLOGOPT += -nologo
VLOGOPT += -suppress 13262
VLOGOPT += -suppress 2286
VLOGOPT += -permissive
VLOGOPT += +define+WT_DCACHE
VLOGOPT += -pedanticerrors
VLOGOPT += -suppress 2583
ifeq ("$(CPU_ARCH)", "ariane")
VSIMOPT += +UVM_NO_RELNOTES -64 +permissive-off
VSIMOPT += -voptargs="+acc"
else
VSIMOPT += -novopt
endif

## Xcelium
XMLOGOPT +=
# Define verilator env because Xcelium do not support SVAs and UVM in Ariane
XMLOGOPT += -DEFINE VERILATOR
XMLOGOPT += -UNCLOCKEDSVA
XMLOGOPT += -DEFINE WT_DCACHE=1


### Incdir and RTL

ifeq ("$(CPU_ARCH)", "ariane")
INCDIR += $(ARIANE)/src/common_cells/include
VERILOG_ARIANE += $(foreach f, $(shell strings $(FLISTS)/ariane_vlog.flist), $(ARIANE)/$(f))
VERILOG_ARIANE += $(DESIGN_PATH)/plic_regmap.sv
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VERILOG_ARIANE += $(foreach f, $(shell strings $(FLISTS)/ariane_fpga_vlog.flist), $(ARIANE)/$(f))
endif
THIRDPARTY_VLOG += $(VERILOG_ARIANE)
endif

