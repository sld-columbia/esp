# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

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
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-c $< -o $@

main.o: $(BOOTROM_PATH)/main.c socmap.h
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

uart.o: $(BOOTROM_PATH)/uart.c socmap.h
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

prom.exe: startup.o uart.o main.o $(BOOTROM_PATH)/linker.lds
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-march=rv32imc -mabi=ilp32 \
		-mstrict-align \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-nodefaultlibs -nostartfiles \
		-T$(BOOTROM_PATH)/linker.lds \
		startup.o uart.o main.o -lgcc\
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
RISCV_CFLAGS += -nostartfiles
RISCV_CFLAGS +=	-march=rv32imc -mabi=ilp32
RISCV_CFLAGS +=	-mstrict-align

systest.exe: systest.c uart.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc $(RISCV_CFLAGS) \
	$(SOFT)/common/syscalls.c \
	$(RISCV_TESTS)/benchmarks/common/crt.S  \
	-T $(RISCV_TESTS)/benchmarks/common/test.ld -o $@ \
	-I$(DESIGN_PATH) \
	uart.o -lm -lgcc $<

systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O binary $< $@

ram.srec: $(TEST_PROGRAM)
	$(QUIET_OBJCP) riscv64-unknown-elf-objcopy -O srec --gap-fill 0 $< $@



.PHONY: ahbrom-clean ahbrom-distclean

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
