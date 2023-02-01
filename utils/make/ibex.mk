# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


IBEX ?= $(ESP_ROOT)/rtl/cores/ibex/ibex

RISCV_TESTS = $(SOFT)/riscv-tests
RISCV_PK = $(SOFT)/riscv-pk

soft: $(SOFT_BUILD)/prom.srec $(SOFT_BUILD)/ram.srec $(SOFT_BUILD)/prom.bin $(SOFT_BUILD)/systest.bin

soft-clean:
	$(QUIET_CLEAN)$(RM) 			\
		$(SOFT_BUILD)/prom.srec 	\
		$(SOFT_BUILD)/ram.srec		\
		$(SOFT_BUILD)/prom.exe		\
		$(SOFT_BUILD)/systest.exe	\
		$(SOFT_BUILD)/prom.bin		\
		$(SOFT_BUILD)/riscv.dtb		\
		$(SOFT_BUILD)/startup.o		\
		$(SOFT_BUILD)/main.o		\
		$(SOFT_BUILD)/uart.o		\
		$(SOFT_BUILD)/systest.bin

soft-distclean: soft-clean

$(SOFT_BUILD)/riscv.dtb: $(ESP_CFG_BUILD)/riscv.dts $(ESP_CFG_BUILD)/socmap.vhd
	$(QUIET_BUILD) mkdir -p $(SOFT_BUILD)
	$(QUIET_BUILD) dtc -I dts $< -O dtb -o $@

$(SOFT_BUILD)/startup.o: $(BOOTROM_PATH)/startup.S $(SOFT_BUILD)/riscv.dtb
	$(QUIET_BUILD) mkdir -p $(SOFT_BUILD)
	$(QUIET_CC)cd $(SOFT_BUILD);  $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-I$(BOOTROM_PATH) \
		-c $< -o $@

$(SOFT_BUILD)/main.o: $(BOOTROM_PATH)/main.c $(ESP_CFG_BUILD)/esplink.h
	$(QUIET_BUILD) mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-c $< -o $@

$(SOFT_BUILD)/uart.o: $(BOOTROM_PATH)/uart.c $(ESP_CFG_BUILD)/esplink.h
	$(QUIET_BUILD) mkdir -p $(SOFT_BUILD)
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-c $< -o $@

$(SOFT_BUILD)/prom.exe: $(SOFT_BUILD)/startup.o $(SOFT_BUILD)/uart.o $(SOFT_BUILD)/main.o $(BOOTROM_PATH)/linker.lds
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
		-nodefaultlibs -nostartfiles \
		-T$(BOOTROM_PATH)/linker.lds \
		$(SOFT_BUILD)/startup.o $(SOFT_BUILD)/uart.o $(SOFT_BUILD)/main.o -lgcc\
		-o $@

$(SOFT_BUILD)/prom.srec: $(SOFT_BUILD)/prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

$(SOFT_BUILD)/prom.bin: $(SOFT_BUILD)/prom.exe
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
RISCV_CFLAGS += -nostartfiles
RISCV_CFLAGS +=	-march=rv32imc -mabi=ilp32
RISCV_CFLAGS +=	-mstrict-align

$(SOFT_BUILD)/systest.exe: systest.c $(SOFT_BUILD)/uart.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc $(RISCV_CFLAGS) \
	$(SOFT)/common/syscalls.c \
	$(RISCV_TESTS)/benchmarks/common/crt.S  \
	-T $(RISCV_TESTS)/benchmarks/common/test.ld -o $@ \
	-I$(DESIGN_PATH)/$(ESP_CFG_BUILD) \
	$(SOFT_BUILD)/uart.o -lm -lgcc $<

$(SOFT_BUILD)/systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O binary $< $@

$(SOFT_BUILD)/ram.srec: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O srec --gap-fill 0 $< $@


sysroot:

sysroot.files:

sysroot.cpio:

linux-build/.config:

linux-build/vmlinux:

pk-build:

pk-build/bbl:

linux.bin:

linux:

linux-clean:

linux-distclean:


### Flags

## Modelsim
VLOGOPT +=
VLOGOPT += -incr
VLOGOPT += -64
VLOGOPT += -nologo
VLOGOPT += -suppress 13262
VLOGOPT += -suppress 2286
VLOGOPT += -permissive
VLOGOPT += +define+WT_DCACHE
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
# use Xilinx-based primitives for FPGA
VLOGOPT += +define+PRIM_DEFAULT_IMPL=prim_pkg::ImplXilinx
endif
VLOGOPT += -pedanticerrors
VLOGOPT += -suppress 2583
VLOGOPT += -suppress 13314

## Xcelium
XMLOGOPT +=
XMLOGOPT += -UNCLOCKEDSVA


### Incdir and RTL
ifeq ("$(CPU_ARCH)", "ibex")
INCDIR  += $(IBEX)/vendor/lowrisc_ip/ip/prim/rtl
VERILOG_IBEX += $(foreach f, $(shell strings $(FLISTS)/ibex_vlog.flist), $(IBEX)/$(f))
VERILOG_IBEX += $(DESIGN_PATH)/$(ESP_CFG_BUILD)/plic_regmap.sv
THIRDPARTY_VLOG += $(VERILOG_IBEX)
endif
