# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

##########################
###    ESP Makefile    ###
##########################


### Some pretty aliases ###

# Define V=1 for a more verbose compilation
ifndef V
	QUIET_AR            = @echo '   ' AR $@;
	QUIET_AS            = @echo '   ' AS $@;
	QUIET_BUILD         = @echo '   ' BUILD $@;
	QUIET_CHMOD         = @echo '   ' CHMOD $@;
	QUIET_CC            = @echo '   ' CC $@;
	QUIET_CXX           = @echo '   ' CXX $@;
	QUIET_OBJCP         = @echo '   ' OBJCP $@;
	QUIET_CHECKPATCH    = @echo '   ' CHECKPATCH $(subst .o,.c,$@);
	QUIET_CHECK         = @echo '   ' CHECK $(subst .o,.c,$@);
	QUIET_LINK          = @echo '   ' LINK $@;
	QUIET_CP            = @echo '   ' CP $@;
	QUIET_RM            = @echo '   ' RM $@;
	QUIET_MKDIR         = @echo '   ' MKDIR $@;
	QUIET_MAKE          = @echo '   ' MAKE $@;
	QUIET_INFO          = @echo -n '   ' INFO '';
	QUIET_DIFF          = @echo -n '   ' DIFF '';
	QUIET_RUN           = @echo '   ' RUN $@;
	QUIET_CLEAN         = @echo '   ' CLEAN $@;
endif
	SPACES              = "    "
	SPACING             = echo -n "    ";

CC  = LD_LIBRARY="" /usr/bin/gcc
LD  = LD_LIBRARY="" /usr/bin/ld
RM  = rm -rf


### Common targets ###

help:
	@echo
	@echo " ========================="
	@echo " ==== ::ESP Targets:: ===="
	@echo " ========================="
	@echo
	@echo " === Accelerators Flow ==="
	@echo
	@echo " make print-available-accelerators      : print a list of accelerators available for the HLS and Chisel flows."
	@echo " make <accelerator>-hls                 : run HLS for all configurations available for <accelerator>"
	@echo "                                          and generate corresponding RTL files."
	@echo " make <accelerator>                     : run SBT on all available configurations for <accelerator> or the custom"
	@echo "                                          Makefile of <accelerator> for Chisel or third-party ips respectively."
	@echo "                                          and generate corresponding RTL files."
	@echo " make <accelerator>-sim                 : run all simulations defined for <accelerator> using the"
	@echo "                                          SystemC testbench; HLS may start if the RTL is out-of-date."
	@echo " make <accelerator>-exe                 : run plain SystemC execution w/o HLS tool environment. This is only"
	@echo "                                          available for accelerators designed in SystemC and it still requires"
	@echo "                                          access to some of the libraries from the HLS tool vendor."
	@echo " make <accelerator>-plot                : run all simulations defined for <accelerator> and plot"
	@echo "                                          results on a latency vs area chard; HLS may start if the"
	@echo "                                          RTL is out-of-date."
	@echo " make <accelerator>-clean               : clean HLS working directory, or the SBT build folder, but keep"
	@echo "                                          the generated RTL for <accelerator>; HLS cache is not deleted."
	@echo " make <accelerator>-distclean           : clean HLS working directory, or the SBT build folder, and remove"
	@echo "                                          the generated RTL for <accelerator>; HLS cache is not deleted."
	@echo " make accelerators                      : make <accelerator>-hls for all available accelerators."
	@echo " make accelerators-clean                : make <accelerator>-clean for all available accelerators."
	@echo " make accelerators-distclean            : make <accelerator>-distclean for all available accelerators."
	@echo " make chisel-accelerators               : make <accelerator> for all available accelerators in Chisel."
	@echo " make chisel-accelerators-clean         : make <accelerator>-clean for all available accelerators in Chisel."
	@echo " make chisel-accelerators-distclean     : make <accelerator>-distclean for all available accelerators in Chisel."
	@echo " make thirdparty-accelerators           : make <accelerator> for all available third-party accelerators."
	@echo " make thirdparty-accelerators-clean     : make <accelerator>-clean for all available third-party accelerators."
	@echo " make thirdparty-accelerators-distclean : make <accelerator>-distclean for all available third-party accelerators."
	@echo " make sldgen                            : generate RTL wrappers for scheduled accelerators; this"
	@echo "                                          target is always called as a dependency before ESP"
	@echo "                                          simulaiton and synthesis."
	@echo
	@echo
	@echo " === SoC Flow ==="
	@echo
	@echo " make esp-defconfig                    : read the default configuration for the current SoC folder"
	@echo "                                         and generate the corresponding SoC map."
	@echo " make esp-config                       : read the current configuration from .esp_config and"
	@echo "                                         generate the corresponding SoC map (may run as dependency)."
	@echo " make esp-xconfig                      : open a GUI to configure and generate the SoC map."
	@echo " make sim                              : compile all source files and run an RTL simulation of ESP"
	@echo " make sim-gui                          : compile all source files and run an RTL simulation of ESP"
	@echo "                                         with graphic user interface"
	@echo " make vivado-syn                       : generate a bitstream of ESP (requires Vivado 2018.2)."
	@echo " make vivado-update                    : run synthesis and implemenation without touching the current Vivado project setup"
	@echo " make vivado-prog-fpga                 : load the generated bitstream to FPGA. This target requires"
	@echo "                                         the environment variable FPGA_HOST set to the network ip of"
	@echo "                                         the machine with FTDI or JTAG link to the FPGA. The FPGA_HOST"
	@echo "                                         must run the hw_server deamon from Vivado 2018.2. The variable"
	@echo "                                         XIL_HW_SERVER_PORT must be set to the port chosen for the"
	@echo "                                         hw_server communication."
	@echo " make profpga-prog-fpga                : load the generated bitstream to proFPGA system. The profpga.cfg"
	@echo "                                         configuration file in the current SoC folder must match the"
	@echo "                                         board setup, including network, USB, or PCIe link information."
	@echo " make profpga-close-fpga               : turn off the proFPGA system."
	@echo
	@echo " make espmon-run                       : open ESP monitor GUI interface (requires proFPGA system)"
	@echo
	@echo " make fpga-run                         : Run bare-metal program TEST_PROGRAM (default is systest.exe) on FPGA"
	@echo "                                         Use targets \"make vivado-syn\" and \"make soft\" first"
	@echo " make fpga-run-linux                   : Run Linux on FPGA"
	@echo "                                         Use targets \"make vivado-syn\", \"make soft\" and \"make linux\" first"
	@echo
	@echo
	@echo " === Software Flow ==="
	@echo
	@echo " make soft                             : compile the bare-metal program TEST_PROGRAM (default is systest.exe)."
	@echo "                                         The target architecutre is selected based on the varialble CPU_ARCH."
	@echo " make barec-all                        : compile the bare-metal device drivers for available accelerators and"
	@echo "                                         for the digital-video interface (DVI). Executables (.exe) are placed to"
	@echo "                                         \"barec\" and can be used in simulation by setting TEST_PROGRAM"
	@echo " make linux                            : compile Linux, create root file-system and compile all ESP core drivers,"
	@echo "                                         drivers for accelerators, and test applications."
	@echo " make <accelerator>-barec              : compile the bare-metal device driver for the specified accelerator."
	@echo "                                         Executables (.exe) are placed to \"barec\" and can be used in simulation"
	@echo "                                         by setting TEST_PROGRAM"
	@echo " make <accelerator>-driver             : compile the Linux device driver for the specified accelerator. Drivers"
	@echo "                                         are placed to \"sysroot/opt/drivers\" and load automatically during OS boot"
	@echo " make <accelerator>-app                : compile the Linux test application for the specified accelerator."
	@echo "                                         Executables are placed to \"sysroot/applications/test\""
	@echo
	@echo
	@echo " === Cobham open-source IPs (GRLIB) ==="
	@echo
	@echo " make grlib-defconfig                  : read the default configuration for grlib IPs."
	@echo " make grlib-config                     : read the configuration for grlib IPs from .grlib_config"
	@echo "                                         (may run as dependency)."
	@echo " make grlib-xconfig                    : open grlib configuration GUI; useful when using the LEON-3"
	@echo "                                         embedded processor."
	@echo " make leon3-soft                       : compile the bare-metal program for LEON-3; The resulting"
	@echo "                                         executable is used for RTL simulation, but can also run on"
	@echo "                                         LEON-3 after loading the bistream to FPGA (requires LEON-3"
	@echo "                                         tool-chain and optionally grmon if running on FPGA)."
	@echo " make linux.dsu                        : package Linux image for LEON-3. This target is called by the"
	@echo "                                         generic \"linux\" target when the variable CPU_ARCH is set to"
	@echo "                                         leon3 (see \"make linux\")."
	@echo
	@echo
	@echo " === utilities ==="
	@echo
	@echo " make [x]uart                          : open a UART console for remote FPGA; UART_IP and UART_PORT must be defined"
	@echo " make ssh                              : log into the ESP instance after booting Linux; SSH_IP and SSH_PORT must be defined"
	@echo "                                         and the default password for root is openesp."
	@echo



### Include common Makefile for desing configuration ###
include $(ESP_ROOT)/utils/design.mk


### NoC flit-width (not including head and tail bits)
ifneq ($(findstring ariane, $(CPU_ARCH)),)
NOC_WIDTH = 64
else
NOC_WIDTH = 32
endif


### Set variables needed before including accelerators.mk
SOFT              = $(ESP_ROOT)/soft/$(CPU_ARCH)
BOOTROM_PATH      = $(SOFT)/bootrom
LINUXSRC          = $(SOFT)/linux
DRIVERS           = $(SOFT)/drivers
CONTIG_ALLOC_PATH = $(DRIVERS)/contig_alloc
ESP_CORE_PATH     = $(DRIVERS)/esp


### Include targets to generate accelerators RTL with HLS ###
include $(ESP_ROOT)/utils/accelerators.mk

### Include targets to generate caches RTL with HLS ###
include $(ESP_ROOT)/utils/sc_components.mk

### Include targets to compile example applications ###
include $(ESP_ROOT)/utils/examples.mk

.PHONY: all help

### SoC configuration for ESP ###

.esp_config:
	$(QUIET_CP)cp $(ESP_ROOT)/socs/defconfig/esp_$(BOARD)_defconfig $@

esp-defconfig: $(ESP_ROOT)/socs/defconfig/esp_$(BOARD)_defconfig
	$(QUIET_CP)cp $< .esp_config
	$(QUIET_MAKE)$(MAKE) esp-config

socmap.vhd: .esp_config grlib_config.vhd top.vhd Makefile
	$(QUIET_DIFF)echo "checking .esp_config..."
	@/usr/bin/diff .esp_config $(ESP_ROOT)/socs/defconfig/esp_$(BOARD)_defconfig -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for ESP"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".esp_config\" for ESP"; \
	fi
	@echo ""
	@echo "Generating ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator_batch.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK)

socmap.h: socmap.vhd

ESPLINK_SRCS = $(wildcard $(ESP_ROOT)/utils/esplink/src/*.c)
ESPLINK_HDRS = $(wildcard $(ESP_ROOT)/utils/esplink/src/*.h)
esplink: socmap.h $(ESPLINK_HDRS) $(ESPLINK_SRCS)
	$(QUIET_CC) gcc -O3 -Wall -Werror -fmax-errors=5 \
		-DESPLINK_IP=\"$(ESPLINK_IP)\" -DPORT=$(ESPLINK_PORT) \
		-I$(ESP_ROOT)/utils/esplink/src/ -I$(DESIGN_PATH) \
		$(ESPLINK_SRCS) -o $@

esp-config: socmap.vhd

esp-xconfig: grlib_config.vhd
	@echo ""
	@echo "Running interactive ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator.py $(NOC_WIDTH) $(TECHLIB) $(LINUX_MAC) $(LEON3_STACK)

esp-config-clean:
	$(QUIET_CLEAN)$(RM) \
		.esp_config.bak

ifeq ("$(CPU_ARCH)", "ariane")
ariane.dts: .esp_config grlib_config.vhd top.vhd
	$(QUIET_MAKE) $(MAKE) socmap.vhd
endif

esp-config-distclean: esp-config-clean
	$(QUIET_CLEAN)$(RM)	\
		socmap.vhd	\
		esp_global.vhd	\
		.esp_config	\
		.soft_config	\
		ariane.dts	\
		mmi64_regs.h	\
		power.h		\
		socmap.h	\
		cache_cfg.svh	\
		S64esp		\
		esplink


.PHONY: esplink esp-xconfig esp-defconfig esp-config-clean esp-config-distclean

### RTL simulator executables ###
VLIB = vlib
VCOM = vcom -quiet $(VCOMOPT)
VLOG = vlog -quiet $(VLOGOPT)

XMCOM = xmvhdl -NOVITALCHECK -linedebug -v93 -nocopyright $(XMCOMOPT)
XMLOG = xmvlog -nocopyright -linedebug -sv $(XMLOGOPT)
XMELAB = xmelab -nowarn DLCPT -v93 -nocopyright -disable_sem2009 -nomxindr -timescale 10ps/10ps
XMUPDATE = xmupdate

NCCOM = ncvhdl -NOVITALCHECK -linedebug -v93 -nocopyright $(NCCOMOPT)
NCLOG = ncvlog -nocopyright -linedebug -sv $(NCLOGOPT)
NCELAB = ncelab -nowarn DLCPT -v93 -nocopyright -disable_sem2009 -nomxindr -timescale 10ps/10ps
NCUPDATE = ncupdate

### Options for Vivado batch mode ###
VIVADO_BATCH_OPT = -mode batch -quiet -notrace

### proFPGA include paths ###
ifneq ($(findstring profpga, $(BOARD)),)
PROFPGA_INCDIR = $(PROFPGA)/hdl/generic_hdl $(PROFPGA)/hdl/mmi64 $(PROFPGA)/hdl/profpga_user $(PROFPGA)/hdl/pd_muxdemux2
else
PROFPGA_INCDIR =
endif

### RTL caches include paths ###
ESP_CACHES_INCDIR = $(ESP_ROOT)/rtl/src/sld/caches/esp-caches/common/defs $(DESIGN_PATH)

INCDIR_MODELSIM = $(foreach dir, $(PROFPGA_INCDIR) $(ESP_CACHES_INCDIR), +incdir+$(dir))
INCDIR_XCELIUM = $(foreach dir, $(PROFPGA_INCDIR) $(ESP_CACHES_INCDIR), -INCDIR $(dir))
INCDIR_INCISIVE = $(INCDIR_XCELIUM)

### Patsh shortcuts ###
UTILS_GRLIB = $(ESP_ROOT)/utils/grlib
TKCONFIG   = $(UTILS_GRLIB)/tkconfig

### Board files ###
BOARD_FILES = $(wildcard $(ESP_ROOT)/constraints/$(BOARD)/*)

### Default test program ###
TEST_PROGRAM ?= systest.exe


ifeq ("$(CPU_ARCH)", "leon3")
### Leon3 Software targets ###
include $(UTILS_GRLIB)/leon3_sw.mk

soft: leon3-soft prom.srec ram.srec prom.bin systest.bin

systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

soft-clean: leon3-soft-clean ahbrom-clean
	@$(RM)			\
	prom.out		\
	xdump.s			\
	mkprom2			\
	lib			\
	linkprom		\
	linkbch			\
	linkpromerc32		\
	linkpromecos		\
	linkpromflash		\
	linkpromerc32flash	\
	linkpromecosflash	\
	dummy.exe


soft-distclean: leon3-soft-distclean ahbrom-distclean
	@$(RM) 		\
	prom.bin	\
	systest.bin

.PHONY: leon3-soft-clean leon3-soft-distclean


### Leon3 prom ###

prom.o: $(BOOTROM_PATH)/prom.S $(BOOTROM_PATH)/prom.h
	$(QUIET_AS) $(CROSS_COMPILE_ELF)gcc -c -I$(BOOTROM_PATH) $<

prom.exe: prom.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-nostdlib \
		-Tlinkprom -N \
		-nostartfiles \
		-o $@ $<

prom.srec: prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

dummy.exe: $(UTILS_GRLIB)/mkprom2/dummy.c
	$(QUIET_MAKE) $(CROSS_COMPILE_ELF)gcc $< -o $@

mkprom2: $(wildcard $(UTILS_GRLIB)/mkprom2/*.S) $(wildcard $(UTILS_GRLIB)/mkprom2/*.c) $(wildcard $(UTILS_GRLIB)/mkprom2/*.h)
	$(QUIET_MAKE) $(MAKE) --quiet -C $(UTILS_GRLIB)/mkprom2 PREFIX=$(DESIGN_PATH)

prom.out: dummy.exe mkprom2
	./mkprom2 -leon3 -freq $(LEON3_BASE_FREQ_MHZ) -nomsg -baud 38343 -stack $(LEON3_STACK) dummy.exe

prom.bin: prom.out
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

ahbrom: $(UTILS_GRLIB)/ahbrom.c
	$(QUIET_CC)$(CC) $< -o $@

ahbrom.bin: prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE)objcopy -O binary $< $@

ahbrom.vhd: ahbrom.bin ahbrom
	$(QUIET_BUILD)./ahbrom $< $@

ahbrom-clean:
	$(QUIET_CLEAN)$(RM) ahbrom ahbrom.bin

ahbrom-distclean: ahbrom-clean
	$(QUIET_CLEAN)$(RM) ahbrom.vhd

.PHONY: ahbrom-clean ahbrom-distclean


### Leon3 Linux ###

sysroot:
	$(QUIET_CP)cp -r $(ESP_ROOT)/soft/leon3/sysroot .

sysroot.files: sysroot
	$(QUIET_MAKE)$(MAKE) -C ${LINUXSRC}/usr gen_init_cpio
	$(QUIET_INFO)echo "Generating root file-system list..."
	@sh ${LINUXSRC}/scripts/gen_initramfs_list.sh -u `id -u` -g `id -g` $< \
	    | sed -e 's/^file \(\/bin\/busybox .*\) 755 0 0/file \1 4755 0 0/' \
	    > $@;
	@echo  "dir /dev 755 0 0" >> $@
	@echo "dir /proc 755 0 0" >> $@
	@echo "dir /sys 755 0 0" >> $@
	@echo "dir /tmp 755 0 0" >> $@
	@echo "dir /var 755 0 0" >> $@
	@echo "dir /root 700 0 0" >> $@
	@echo "nod /dev/null 666 0 0 c 1 3" >> $@
	@echo "nod /dev/tty1 600 0 0 c 4 1" >> $@
	@echo "nod /dev/ttyS0 600 0 0 c 4 64" >> $@
	@echo "nod /dev/tty 666 0 0 c 5 0" >> $@
	@echo "nod /dev/console 600 0 0 c 5 1" >> $@
	@touch $@

sysroot.cpio: sysroot.files
	$(QUIET_BUILD)${LINUXSRC}/usr/gen_init_cpio $< > $@


linux-build/.config: $(LINUXSRC)/arch/sparc/configs/$(LINUX_CONFIG)
	@$(MAKE) linux-build
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE)  O=${PWD}/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)

linux-build/vmlinux: sysroot.cpio linux-build/.config
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) -C linux-build

linux.dsu: sysroot-update
	$(QUIET_BUILD)mklinuximg -ethmac $(LINUX_MAC) linux-build/vmlinux $@

linux.bin: linux.dsu
	$(QUIET_OBJCP) $(CROSS_COMPILE_LINUX)objcopy -S -O binary --change-addresses -0x40000000 $< $@

linux: linux.bin

linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e linux-build; then \
		ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) --quiet -C linux-build clean; \
	fi;

linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) linux-build linux.dsu linux.bin

barec-all: barec
	@mkdir -p barec/dvi
	@$(MAKE) -C $(DRIVERS)/dvi/barec
	@cp $(DRIVERS)/dvi/barec/*.exe barec/dvi
	@$(MAKE) accelerators-barec


barec-distclean:
	$(QUIET_CLEAN)$(RM) barec
	@CROSS_COMPILE=sparc-elf- $(MAKE) --quiet -C $(DRIVERS)/dvi/barec clean
	@$(MAKE) --quiet accelerators-barec-clean

else ifeq ("$(CPU_ARCH)", "ariane")

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
		ariane.dtb	\
		startup.o	\
		main.o		\
		uart.o		\
		systest.bin

soft-distclean: soft-clean ahbrom-distclean

ariane.dtb: ariane.dts socmap.vhd
	$(QUIET_BUILD) dtc -I dts $< -O dtb -o $@

startup.o: $(BOOTROM_PATH)/startup.S ariane.dtb
	$(QUIET_CC) riscv64-unknown-elf-gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-c $< -o $@

main.o: $(BOOTROM_PATH)/main.c socmap.h
	$(QUIET_CC) riscv64-unknown-elf-gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

uart.o: $(BOOTROM_PATH)/uart.c socmap.h
	$(QUIET_CC) riscv64-unknown-elf-gcc \
		-Os \
		-Wall -Werror \
		-mcmodel=medany -mexplicit-relocs \
		-I$(BOOTROM_PATH) \
		-I$(DESIGN_PATH) \
		-c $< -o $@

prom.exe: startup.o uart.o main.o $(BOOTROM_PATH)/linker.lds
	$(QUIET_CC) riscv64-unknown-elf-gcc \
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
	$(QUIET_CC) riscv64-unknown-elf-gcc $(RISCV_CFLAGS) \
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
				CC=riscv64-unknown-elf-gcc \
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


barec-all:
	@mkdir -p barec/dvi
	@$(MAKE) -C $(DRIVERS)/dvi/barec
	@cp $(DRIVERS)/dvi/barec/*.bin barec/dvi
	@$(MAKE) accelerators-barec


barec-distclean:
	$(QUIET_CLEAN)$(RM) barec
	@$(MAKE) --quiet -C $(DRIVERS)/dvi/barec clean
	@$(MAKE) --quiet accelerators-barec-clean


else
### Other architectures if avalable ###

soft:

soft-clean:

soft-distclean:

linux:

linux-clean:

linux-distclean:

barec-all:

barec-distclean:

endif


sysroot/opt/drivers-esp/contig_alloc.ko: linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(CONTIG_ALLOC_PATH)
	$(QUIET_CP)cp $(CONTIG_ALLOC_PATH)/contig_alloc.ko $@

sysroot/opt/drivers-esp/esp_cache.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.c) $(wildcard $(ESP_CORE_PATH)/../esp_cache/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build $(MAKE) -C $(ESP_CORE_PATH)/../esp_cache
	$(QUIET_CP)cp $(ESP_CORE_PATH)/../esp_cache/esp_cache.ko $@

sysroot/opt/drivers-esp/esp_private_cache.ko: sysroot/opt/drivers-esp/esp_cache.ko
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_CP)cp $(ESP_CORE_PATH)/../esp_cache/esp_private_cache.ko $@

sysroot/opt/drivers-esp/esp.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	@mkdir -p sysroot/opt/drivers-esp
	$(QUIET_MAKE)ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(PWD)/linux-build CONTIG_ALLOC_PATH=$(CONTIG_ALLOC_PATH) $(MAKE) -C $(ESP_CORE_PATH)
	$(QUIET_CP)cp $(ESP_CORE_PATH)/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: linux-build/vmlinux socmap.vhd
	@touch sysroot
	@$(MAKE) sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp_private_cache.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp.ko
	@$(MAKE) -C $(DRIVERS)/dvi/app
	@mkdir -p sysroot/applications/dvi; cp $(DRIVERS)/dvi/app/*.exe sysroot/applications/dvi
	@$(MAKE) accelerators-driver
	@$(MAKE) accelerators-app
	@touch sysroot
	@chmod a+x S64esp; cp S64esp sysroot/etc/init.d/
	$(QUIET_MAKE)$(MAKE) linux-build/vmlinux

sysroot-clean:
	$(QUIET_CLEAN)$(RM) sysroot.files sysroot.cpio
	@$(MAKE) --quiet -C $(DRIVERS)/dvi/app clean
	@if test -e linux-build; then \
		$(MAKE) --quiet accelerators-driver-clean; \
	fi;
	@$(MAKE) --quiet accelerators-app-clean

sysroot-distclean: sysroot-clean
	$(QUIET_CLEAN)$(RM) sysroot


linux-build:
	$(QUIET_MKDIR)mkdir -p $@

.PHONY: soft soft-clean soft-distclean linux linux-clean linux-distclean

.PHONY: sysroot-update sysroot-clean sysroot-distclean

# The following PHONY guarantees that we execute the program set by TEST_PROGRAM
.PHONY: systest.bin ram.srec

barec:
	$(QUIET_MKDIR)mkdir -p $@

.PHONY: barec-distclean barec-all


### GRLIB config targets ###

TKCONFIG_DEP   = $(TKCONFIG)/config.vhd
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.vhd)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.h)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.help)
TKCONFIG_DEP  += grlib_config.in

.grlib_config:
	$(QUIET_CP)cp $(ESP_ROOT)/socs/defconfig/grlib_$(BOARD)_defconfig $@

grlib-defconfig: $(ESP_ROOT)/socs/defconfig/grlib_$(BOARD)_defconfig
	$(QUIET_CP)cp $< .grlib_config
	$(QUIET_MAKE)$(MAKE) grlib_config.vhd

.PHONY: grlib-defconfig

tkparse.o: $(TKCONFIG)/tkparse.c
	$(QUIET_CC)$(CC) -g -c $<

tkcond.o: $(TKCONFIG)/tkcond.c
	$(QUIET_CC)$(CC) -g -c $<

tkgen.o: $(TKCONFIG)/tkgen.c
	$(QUIET_CC)$(CC) -g -c $<

tkparse: tkparse.o tkcond.o tkgen.o
	$(QUIET_LINK)$(CC) -g tkparse.o tkcond.o tkgen.o -o $@

main.tk: tkparse grlib_config.in $(TKCONFIG_DEP)
	$(QUIET_BUILD) ./$< grlib_config.in $(TKCONFIG)/in > $@

lconfig.tk: main.tk $(TKCONFIG_DEP) grlib_config.in
	$(QUIET_BUILD)cat $(TKCONFIG)/header.tk $< $(TKCONFIG)/tail.tk > $@
	$(QUIET_CHMOD)chmod a+x lconfig.tk

grlib_config.vhd: lconfig.tk .grlib_config
	$(QUIET_DIFF)echo "checking .grlib_config..."
	@/usr/bin/diff .grlib_config $(ESP_ROOT)/socs/defconfig/grlib_$(BOARD)_defconfig -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for GRLIB"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".grlib_config\" for GRLIB"; \
	fi
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@unset LD_LIBRARY_PATH ; \
	wish -f lconfig.tk -regen; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-xconfig: lconfig.tk
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@unset LD_LIBRARY_PATH ; \
	wish -f lconfig.tk; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-config-clean:
	$(QUIET_CLEAN)$(RM)        \
		tkparse.o          \
		tkcond.o           \
		tkgen.o            \
		tkparse            \
		main.tk            \
		grlib_config.h     \
		grlib_config.help  \
		grlib_config.vhd.h \
		.grlib_config.old

grlib-config-distclean: grlib-config-clean
	$(QUIET_CLEAN)$(RM)      \
		lconfig.tk       \
		tkconfig.h       \
		grlib_config.vhd \
		.grlib_config

.PHONY: grlib-xconfig grlib-config-clean grlib-config-distclean


### Desing source files ###
ifneq ($(findstring profpga, $(BOARD)),)
VHDL_PROFPGA = $(shell strings $(ESP_ROOT)/utils/profpga_vhd.txt)
VERILOG_PROFPGA = $(shell strings $(ESP_ROOT)/utils/profpga_verilog.txt)
else
VHDL_PROFPGA =
VERILOG_PROFPGA =
endif

ARIANE ?= $(ESP_ROOT)/third-party/ariane
VERILOG_ARIANE += $(shell strings $(ESP_ROOT)/utils/ariane_verilog.txt)

PKG_LIST  = $(shell (find $(ESP_ROOT)/rtl -name "*.txt" ))
PKG_LIST += $(shell (find $(ESP_ROOT)/sim -name "*.txt" ))

RTL_LIBS += $(foreach lib, $(shell (cat $(ESP_ROOT)/rtl/libs.txt)), $(lib))
SIM_LIBS += $(foreach lib, $(shell (cat $(ESP_ROOT)/sim/libs.txt)), $(lib))

VHDL_RTL_PKGS  = $(shell (find $(ESP_ROOT)/rtl/include -name "*.vhd" ))
ifneq ($(findstring profpga, $(BOARD)),)
VHDL_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.vhd" ))
else
VHDL_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.vhd" | grep -v "sld/sldcommon/monitor.vhd"))
endif
VHDL_RTL_SRCS  += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.vhd" ))

VLOG_RTL_SRCS   = $(shell (find $(ESP_ROOT)/rtl/src -name "*.v" ))
VLOG_RTL_SRCS  += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.v" ))

SVLOG_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.sv" ))

VHDL_SIM_PKGS  = $(shell (find $(ESP_ROOT)/sim/include -name "*.vhd" ))
VHDL_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.vhd" ))
VLOG_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.v" ))

VHDL_PKGS = $(THIRDPARTY_VHDL_PKGS) $(VHDL_RTL_PKGS) $(VHDL_SIM_PKGS) $(TOP_VHDL_RTL_PKGS) $(TOP_VHDL_SIM_PKGS)
VHDL_SRCS = $(THIRDPARTY_VHDL) $(VHDL_RTL_SRCS) $(VHDL_SIM_SRCS) $(TOP_VHDL_RTL_SRCS) $(TOP_VHDL_SIM_SRCS)
VLOG_SRCS = $(THIRDPARTY_VLOG) $(VLOG_RTL_SRCS) $(VLOG_SIM_SRCS) $(TOP_VLOG_RTL_SRCS) $(TOP_VLOG_SIM_SRCS)
SVLOG_SRCS = $(THIRDPARTY_SVLOG) $(SVLOG_RTL_SRCS)

DAT_SRCS = $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.dat" ))

ALL_SRCS  = $(VHDL_PKGS) $(VHDL_SRCS) $(VLOG_SRCS) $(SVLOG_SRCS) $(DAT_SRCS)

VHDL_ALL_RTL = $(THIRDPARTY_VHDL_PKGS) $(VHDL_RTL_PKGS) $(TOP_VHDL_RTL_PKGS) $(THIRDPARTY_VHDL) $(VHDL_RTL_SRCS) $(TOP_VHDL_RTL_SRCS)
VLOG_ALL_RTL = $(THIRDPARTY_VLOG) $(VLOG_RTL_SRCS) $(TOP_VLOG_RTL_SRCS)
SVLOG_ALL_RTL = $(THIRDPARTY_SVLOG) $(SVLOG_SRCS)

ALL_RTL_SRCS  = $(VHDL_ALL_RTL) $(VLOG_ALL_RTL) $(SVLOG_ALL_RTL) $(DAT_SRCS)

check_all_srcs: grlib_config.vhd socmap.vhd sldgen
	@echo $(ALL_SRCS) > $@.new; \
	if test -f $@.old; then \
		/usr/bin/diff -q $@.old $@.new > /dev/null; \
		if [ $$? -eq 0 ]; then \
			rm $@.new; \
		else \
			rm -rf modelsim/work; \
			rm -rf modelsim/vsim.mk; \
			mv $@.new $@.old; \
		fi; \
	else \
		rm -rf modelsim/work; \
		rm -rf modelsim/vsim.mk; \
		mv $@.new $@.old; \
	fi;

check_all_srcs-distclean:
	$(QUIET_CLEAN)rm -rf check_all_srcs.old

.PHONY: check_all_srcs check_all_srcs-distclean

check_all_rtl_srcs: grlib_config.vhd socmap.vhd sldgen
	@echo $(ALL_RTL_SRCS) > $@.new; \
	if test -f $@.old; then \
		/usr/bin/diff -q $@.old $@.new > /dev/null; \
		if [ $$? -eq 0 ]; then \
			rm $@.new; \
		else \
			mv $@.new $@.old; \
		fi; \
	else \
		mv $@.new $@.old; \
	fi;

check_all_rtl_srcs-distclean:
	$(QUIET_CLEAN)rm -rf check_all_rtl_srcs.old

.PHONY: check_all_rtl_srcs check_all_rtl_srcs-distclean


### Xilinx Simulation libs targets ###

$(ESP_ROOT)/.cache/modelsim/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator modelsim -library unisim -no_ip_compile" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/modelsim; \
	if ! vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; then \
		echo "$(SPACES)ERROR: Xilinx library compilation failed!"; rm -rf xilinx_lib modelsim.ini; exit 1; \
	fi; \
	lib_path=$$(cat modelsim.ini | grep secureip | cut -d " " -f 3); \
	sed -i "/secureip =/a secureip_ver = "$$lib_path"" modelsim.ini; \
	sed -i 's/; Show_source = 1/Show_source = 1/g' modelsim.ini; \
	sed -i 's/; Show_Warning3 = 0/Show_Warning3 = 0/g' modelsim.ini; \
	sed -i 's/; Show_Warning5 = 0/Show_Warning5 = 0/g' modelsim.ini; \
	sed -i 's/; StdArithNoWarnings = 1/StdArithNoWarnings = 1/g' modelsim.ini; \
	sed -i 's/; NumericStdNoWarnings = 1/NumericStdNoWarnings = 1/g' modelsim.ini; \
	sed -i 's/VoptFlow = 1/VoptFlow = 0/g' modelsim.ini; \
	sed -i '/suppress = [0-9]\+/d' modelsim.ini; \
	sed -i '/\[msg_system\]/a suppress = 8780,8891,1491,12110\nwarning = 8891' modelsim.ini; \
	cd ../;

modelsim/modelsim.ini: $(ESP_ROOT)/.cache/modelsim/xilinx_lib
	$(QUIET_MAKE)mkdir -p modelsim
	@cp $(ESP_ROOT)/.cache/modelsim/modelsim.ini $@


$(ESP_ROOT)/.cache/xcelium/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator xcelium -library unisim -no_ip_compile" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/xcelium; \
	if ! vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; then \
		echo "$(SPACES)ERROR: Xilinx library compilation failed!"; rm -rf xilinx_lib cds.lib; exit 1; \
	fi;

xcelium/cds.lib: $(ESP_ROOT)/.cache/xcelium/xilinx_lib
	$(QUIET_MAKE)mkdir -p xcelium
	@cp $(ESP_ROOT)/.cache/xcelium/cds.lib $@

xcelium/hdl.var: xcelium/cds.lib
	@cp $(ESP_ROOT)/.cache/xcelium/hdl.var $@


$(ESP_ROOT)/.cache/incisive/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator ies -library unisim -no_ip_compile" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/incisive; \
	if ! vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; then \
		echo "$(SPACES)ERROR: Xilinx library compilation failed!"; rm -rf xilinx_lib cds.lib; exit 1; \
	fi;

incisive/cds.lib: $(ESP_ROOT)/.cache/incisive/xilinx_lib
	$(QUIET_MAKE)mkdir -p incisive
	@cp $(ESP_ROOT)/.cache/incisive/cds.lib $@

incisive/hdl.var: incisive/cds.lib
	@cp $(ESP_ROOT)/.cache/incisive/hdl.var $@



xilinx_lib-clean:
	$(QUIET_CLEAN)$(RM) \
		.cxl.mti_se.version \
		.cxl.modelsim.version \
		.cxl.ies.version \
		*.log \
		*.bak \
		*.jou \
		*backup* \

xilinx_lib-distclean: xilinx_lib-clean
	$(QUIET_CLEAN)$(RM) \
		$(ESP_ROOT)/.cache/modelsim/ 	\
		$(ESP_ROOT)/.cache/xcelium/ 	\
		$(ESP_ROOT)/.cache/incisive/

.PHONY: xilinx_lib-clean xilinx_lib-distclean


### Xcelium targets ###

xcelium/xmready: xcelium/hdl.var check_all_srcs.old $(PKG_LIST)
	$(QUIET_MKDIR)mkdir -p xcelium
ifneq ($(findstring profpga, $(BOARD)),)
	@cd xcelium; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	if ! grep --quiet "DEFINE profpga" cds.lib; then \
		echo "DEFINE profpga $(DESIGN_PATH)/xcelium/profpga" >> cds.lib; \
	fi; \
	if ! test -d profpga; then \
		mkdir -p profpga; \
	fi; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(XMCOM) -work profpga $$rtl"; \
		$(XMCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(XMLOG) -work profpga -INCDIR ... $$rtl"; \
		$(XMLOG) -work profpga $(INCDIR_XCELIUM) $$rtl || exit; \
	done;
endif
	@cd xcelium; \
	if ! grep --quiet "DEFINE work" cds.lib; then \
		echo "DEFINE work $(DESIGN_PATH)/xcelium/work" >> cds.lib; \
	fi; \
	if ! test -e work; then \
		mkdir -p work; \
	fi; \
	echo $(SPACES)"### Compile Ariane source files ###"; \
	rtl=$(ESP_ROOT)/socs/common/ariane_soc_pkg.sv; \
	echo $(SPACES)"$(XMLOG) -work work $(ARIANE_XMLOGOPT) $$rtl"; \
	$(XMLOG) -work work $(ARIANE_XMLOGOPT) $$rtl || exit; \
	for ver in $(VERILOG_ARIANE); do \
		rtl=$(ARIANE)/$$ver; \
		echo $(SPACES)"$(XMLOG) -work work $(ARIANE_XMLOGOPT) $$rtl"; \
		$(XMLOG) -work work $(ARIANE_XMLOGOPT) $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for vhd in $(SLDGEN_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
		$(XMCOM) -work work $$rtl || exit; \
	done; \
	for lib in $$(cat $(ESP_ROOT)/rtl/include/libs.txt); do \
		for dir in $$(cat $(ESP_ROOT)/rtl/include/$$lib/dirs.txt); do \
			for vhd in $$(cat $(ESP_ROOT)/rtl/include/$$lib/$$dir/pkgs.txt); do \
				rtl=$(ESP_ROOT)/rtl/include/$$lib/$$dir/$$vhd; \
				echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
				$(XMCOM) -work work $$rtl || exit; \
			done; \
			if test -d $(ESP_ROOT)/sim/include/$$lib/$$dir/; then \
				for vhd in $$(cat $(ESP_ROOT)/sim/include/$$lib/$$dir/pkgs.txt); do \
					rtl=$(ESP_ROOT)/sim/include/$$lib/$$dir/$$vhd; \
					echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
					$(XMCOM) -work work $$rtl || exit; \
				done; \
			fi; \
		done; \
	done; \
	for vhd in $(TOP_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
		$(XMCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(VHDL_SRCS); do \
			echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
			$(XMCOM) -work work $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(VLOG_SRCS); do \
			echo $(SPACES)"$(XMLOG) $$rtl"; \
			$(XMLOG) -work work $(THIRDPARTY_INCDIR_XCELIUM) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile SystemVerilog source files ###"; \
		for rtl in $(SVLOG_SRCS); do \
			echo $(SPACES)"$(XMLOG) -SV $$rtl"; \
			$(XMLOG) -SV -work work $(INCDIR_XCELIUM) $(THIRDPARTY_INCDIR_XCELIUM) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile IPs simulation files ###"; \
	echo $(SPACES)"$(XMLOG) -work work $(XILINX_VIVADO)/data/verilog/src/glbl.v"; \
	$(XMLOG) -work work $(XILINX_VIVADO)/data/verilog/src/glbl.v; \
	if ! test -e prom.srec; then \
		ln -s ../prom.srec; \
	fi; \
	if ! test -e ram.srec; then \
		ln -s ../ram.srec; \
	fi; \
	echo $(SPACES)"$(XMELAB) $(SIMTOP) $(EXTRA_SIMTOP)"; \
	$(XMELAB) $(SIMTOP) $(EXTRA_SIMTOP) && touch xmready; \
	cd ../;


xcelium/xmsim.in:
	$(QUIET_BUILD)echo set severity_pack_assert_off {warning} > $@
	@echo set pack_assert_off { std_logic_arith numeric_std } >> $@
	@echo set intovf_severity_level {ignore} >> $@

xmsim-compile: sldgen check_all_srcs soft xcelium/xmready xcelium/xmsim.in
	$(QUIET_MAKE) \
	cd xcelium; \
	echo $(SPACES)"$(XMUPDATE) $(SIMOPT)"; \
	$(XMUPDATE) $(SIMTOP); \
	cd ../;

xmsim: xmsim-compile
	@cd xcelium; \
	echo $(SPACES)"xmsim $(XMSIMOPT)"; \
	xmsim $(XMSIMOPT); \
	cd ../

xmsim-gui: xmsim-compile
	@cd xcelium; \
	echo $(SPACES)"xmsim -gui $(XMSIMOPT)"; \
	xmsim -gui $(XMSIMOPT); \
	cd ../

xmsim-clean:
	$(QUIET_CLEAN)

xmsim-distclean: xmsim-clean
	$(QUIET_CLEAN) $(RM) xcelium INCA_libs xcelium.d

.PHONY: xmsim xmsim-gui xmsim-compile xmsim-clean xmsim-distclean


### Incisive targets ###

incisive/ncready: incisive/hdl.var check_all_srcs.old $(PKG_LIST)
	$(QUIET_MKDIR)mkdir -p incisive
	@echo $(SPACES)"WARNING: The source code for Ariane cannot be compiled with Incisive!!! If you need Ariane, please switch to Modelsim or Xcelium";
ifneq ($(findstring profpga, $(BOARD)),)
	@cd incisive; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	if ! grep --quiet "DEFINE profpga" cds.lib; then \
		echo "DEFINE profpga $(DESIGN_PATH)/incisive/profpga" >> cds.lib; \
	fi; \
	if ! test -d profpga; then \
		mkdir -p profpga; \
	fi; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(NCCOM) -work profpga $$rtl"; \
		$(NCCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(NCLOG) -work profpga -INCDIR ... $$rtl"; \
		$(NCLOG) -work profpga $(INCDIR_INCISIVE) $$rtl || exit; \
	done;
endif
	@cd incisive; \
	if ! grep --quiet "DEFINE work" cds.lib; then \
		echo "DEFINE work $(DESIGN_PATH)/incisive/work" >> cds.lib; \
	fi; \
	if ! test -e work; then \
		mkdir -p work; \
	fi; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for vhd in $(SLDGEN_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
		$(NCCOM) -work work $$rtl || exit; \
	done; \
	for lib in $$(cat $(ESP_ROOT)/rtl/include/libs.txt); do \
		for dir in $$(cat $(ESP_ROOT)/rtl/include/$$lib/dirs.txt); do \
			for vhd in $$(cat $(ESP_ROOT)/rtl/include/$$lib/$$dir/pkgs.txt); do \
				rtl=$(ESP_ROOT)/rtl/include/$$lib/$$dir/$$vhd; \
				echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
				$(NCCOM) -work work $$rtl || exit; \
			done; \
			if test -d $(ESP_ROOT)/sim/include/$$lib/$$dir/; then \
				for vhd in $$(cat $(ESP_ROOT)/sim/include/$$lib/$$dir/pkgs.txt); do \
					rtl=$(ESP_ROOT)/sim/include/$$lib/$$dir/$$vhd; \
					echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
					$(NCCOM) -work work $$rtl || exit; \
				done; \
			fi; \
		done; \
	done; \
	for vhd in $(TOP_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
		$(NCCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(VHDL_SRCS); do \
			echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
			$(NCCOM) -work work $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(VLOG_SRCS); do \
			echo $(SPACES)"$(NCLOG) $$rtl"; \
			$(NCLOG) -work work $(THIRDPARTY_INCDIR_INCISIVE) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile SystemVerilog source files ###"; \
		for rtl in $(SVLOG_SRCS); do \
			echo $$rtl | grep --quiet "ariane"; \
			res=$$?; \
			if [ $$res == 0 ]; then \
				echo $(SPACES)"### Skip Ariane source files ###"; \
			else \
				echo $(SPACES)"$(NCLOG) -SV $$rtl"; \
				$(NCLOG) -SV -work work $(INCDIR_INCISIVE) $(THIRDPARTY_INCDIR_INCISIVE) $$rtl || exit; \
			fi; \
		done; \
	echo $(SPACES)"### Compile IPs simulation files ###"; \
	echo $(SPACES)"$(NCLOG) -work work $(XILINX_VIVADO)/data/verilog/src/glbl.v"; \
	$(NCLOG) -work work $(XILINX_VIVADO)/data/verilog/src/glbl.v; \
	if ! test -e prom.srec; then \
		ln -s ../prom.srec; \
	fi; \
	if ! test -e ram.srec; then \
		ln -s ../ram.srec; \
	fi; \
	echo $(SPACES)"$(NCELAB) $(SIMTOP) $(EXTRA_SIMTOP)"; \
	$(NCELAB) $(SIMTOP) $(EXTRA_SIMTOP) && touch ncready; \
	cd ../;


incisive/ncsim.in:
	$(QUIET_BUILD)echo set severity_pack_assert_off {warning} > $@
	@echo set pack_assert_off { std_logic_arith numeric_std } >> $@
	@echo set intovf_severity_level {ignore} >> $@

ncsim-compile: sldgen check_all_srcs soft incisive/ncready incisive/ncsim.in
	@for dat in $(DAT_SRCS); do \
		cp $$dat incisive; \
	done; \
	$(QUIET_MAKE) \
	cd incisive; \
	echo $(SPACES)"$(NCUPDATE) $(SIMTOP)"; \
	$(NCUPDATE) $(SIMTOP); \
	cd ../;

ncsim: ncsim-compile
	@cd incisive; \
	echo $(SPACES)"ncsim $(NCSIMOPT)"; \
	ncsim $(NCSIMOPT); \
	cd ../

ncsim-gui: ncsim-compile
	@cd incisive; \
	echo $(SPACES)"ncsim -gui $(NCSIMOPT)"; \
	ncsim -gui $(NCSIMOPT); \
	cd ../

ncsim-clean:
	$(QUIET_CLEAN)

ncsim-distclean: ncsim-clean
	$(QUIET_CLEAN) $(RM) incisive

.PHONY: ncsim ncsim-gui ncsim-compile ncsim-clean ncsim-distclean



### Modelsim targets ###

# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
modelsim/vsim.mk: modelsim/modelsim.ini check_all_srcs.old $(PKG_LIST)
ifneq ($(findstring profpga, $(BOARD)),)
	@cd modelsim; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	if ! test -e profpga; then \
		vlib -type directory profpga; \
	fi; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(VCOM) -work profpga $$rtl"; \
		$(VCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(VLOG) -work profpga +incdir+... $$rtl"; \
		$(VLOG) -work profpga $(INCDIR_MODELSIM) $$rtl || exit; \
	done;
endif
	@cd modelsim; \
	if ! test -e work; then \
		vlib -type directory work; \
	fi; \
	echo $(SPACES)"### Compile Ariane source files ###"; \
	rtl=$(ESP_ROOT)/socs/common/ariane_soc_pkg.sv; \
	echo $(SPACES)"$(VLOG) $(ARIANE_VLOGOPT) $$rtl"; \
	$(VLOG) $(ARIANE_VLOGOPT) $$rtl || exit; \
	for ver in $(VERILOG_ARIANE); do \
		rtl=$(ARIANE)/$$ver; \
		echo $(SPACES)"$(VLOG) $(ARIANE_VLOGOPT) $$rtl"; \
		$(VLOG) $(ARIANE_VLOGOPT) $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for rtl in $(THIRDPARTY_VHDL_PKGS); do \
		echo $(SPACES)"$(VCOM) -work work $$rtl"; \
		$(VCOM) -work work $$rtl || exit; \
	done; \
	for vhd in $(SLDGEN_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(VCOM) $$rtl"; \
		$(VCOM) $$rtl || exit; \
	done; \
	for lib in $$(cat $(ESP_ROOT)/rtl/include/libs.txt); do \
		for dir in $$(cat $(ESP_ROOT)/rtl/include/$$lib/dirs.txt); do \
			for vhd in $$(cat $(ESP_ROOT)/rtl/include/$$lib/$$dir/pkgs.txt); do \
				rtl=$(ESP_ROOT)/rtl/include/$$lib/$$dir/$$vhd; \
				echo $(SPACES)"$(VCOM) $$rtl"; \
				$(VCOM) $$rtl || exit; \
			done; \
			if test -d $(ESP_ROOT)/sim/include/$$lib/$$dir/; then \
				for vhd in $$(cat $(ESP_ROOT)/sim/include/$$lib/$$dir/pkgs.txt); do \
					rtl=$(ESP_ROOT)/sim/include/$$lib/$$dir/$$vhd; \
					echo $(SPACES)"$(VCOM) $$rtl"; \
					$(VCOM) $$rtl || exit; \
				done; \
			fi; \
		done; \
	done; \
	for vhd in $(TOP_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo $(SPACES)"$(VCOM) $$rtl"; \
		$(VCOM) $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(VHDL_SRCS); do \
			echo $(SPACES)"$(VCOM) $$rtl"; \
			$(VCOM) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(VLOG_SRCS); do \
			echo $(SPACES)"$(VLOG) $$rtl"; \
			$(VLOG) $(THIRDPARTY_INCDIR_MODELSIM) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile SystemVerilog source files ###"; \
		for rtl in $(SVLOG_SRCS); do \
			echo $(SPACES)"$(VLOG) -sv $$rtl"; \
			$(VLOG) -sv  $(INCDIR_MODELSIM) $(THIRDPARTY_INCDIR_MODELSIM) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile IPs simulation files ###"; \
	echo $(SPACES)"$(VLOG) $(XILINX_VIVADO)/data/verilog/src/glbl.v"; \
	$(VLOG) $(XILINX_VIVADO)/data/verilog/src/glbl.v; \
	$(SPACING)vmap work work;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd modelsim; \
	$(SPACING)vmap profpga profpga;
endif
	@cd modelsim; \
	echo $(SPACES)"vmake > vsim.mk"; \
	vmake 2> /dev/null > vsim.mk; \
	if ! test -e prom.srec; then \
		ln -s ../prom.srec; \
	fi; \
	if ! test -e ram.srec; then \
		ln -s ../ram.srec; \
	fi; \
	cd ../;

sim-compile: sldgen check_all_srcs modelsim/vsim.mk soft
	@for dat in $(DAT_SRCS); do \
		cp $$dat modelsim; \
	done;
	$(QUIET_MAKE)make -C modelsim -f vsim.mk

sim: sim-compile
	@cd modelsim; \
	echo $(SPACES)"vsim -c $(VSIMOPT)"; \
	vsim -c $(VSIMOPT); \
	cd ../

sim-gui: sim-compile
	@cd modelsim; \
	echo $(SPACES)"vsim $(VSIMOPT)"; \
	vsim $(VSIMOPT); \
	cd ../

sim-clean:
	$(QUIET_CLEAN)rm -rf transcript *.wlf

sim-distclean: sim-clean
	$(QUIET_CLEAN)rm -rf modelsim

.PHONY: sim sim-gui sim-compile sim-clean sim-distclean



### Vivado targets ###

vivado:
	$(QUIET_MKDIR)mkdir -p vivado

vivado/srcs.tcl: vivado check_all_rtl_srcs.old
	$(QUIET_INFO)echo "generating source list for Vivado"
	@$(RM) $@
ifneq ($(findstring profpga, $(BOARD)),)
	@for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo "read_vhdl -library profpga $$rtl" >> $@; \
	done;
	@for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo "read_verilog -library profpga $$rtl" >> $@; \
	done;
endif
	@rtl=$(ESP_ROOT)/socs/common/ariane_soc_pkg.sv; \
	echo "read_verilog -sv $$rtl" >> $@;
	@for ver in $(VERILOG_ARIANE); do \
		rtl=$(ARIANE)/$$ver; \
		echo "read_verilog -sv $$rtl" >> $@; \
	done;
	@for rtl in $(SLDGEN_VHDL_RTL_PKGS); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(VHDL_ALL_RTL); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(VLOG_ALL_RTL); do \
		echo "read_verilog $$rtl" >> $@; \
	done;
	@for rtl in $(SVLOG_ALL_RTL); do \
		echo "read_verilog -sv $$rtl" >> $@; \
	done;
	@for dat in $(DAT_SRCS); do \
		echo "add_files $$dat" >> $@; \
	done;


vivado/setup.tcl: vivado $(XDC) $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@echo "create_project $(DESIGN) -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
ifneq ($(findstring profpga, $(BOARD)),)
	@echo "set_property include_dirs {$(ESP_CACHES_INCDIR) $(PROFPGA_INCDIR) $(THIRDPARTY_INCDIR) $(ARIANE)/src/common_cells/include} [get_filesets {sim_1 sources_1}]" >> $@
else
	@echo "set_property include_dirs {$(ESP_CACHES_INCDIR) $(THIRDPARTY_INCDIR) $(ARIANE)/src/common_cells/include} [get_filesets {sim_1 sources_1}]" >> $@
endif
	@echo "set_property verilog_define {WT_DCACHE=1} [get_filesets {sim_1 sources_1}]" >> $@
	@echo "source ./srcs.tcl" >> $@
ifneq ("$(PROTOBOARD)","")
	@echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@
endif
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.xci; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.xci ./vivado/mig; \
		if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.prj; then \
			cp $(ESP_ROOT)/constraints/$(BOARD)/mig.prj ./vivado/mig; \
		fi; \
		echo "import_ip -files ./mig/mig.xci" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.tcl; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.tcl ./vivado/mig; \
		if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.csv; then \
			cp $(ESP_ROOT)/constraints/$(BOARD)/mig.csv ./vivado/mig; \
		fi; \
		echo "source ./mig/mig.tcl" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	else \
		echo $(SPACES)"WARNING: no MIG IP was found"; \
	fi;
ifeq ($(CONFIG_GRETH_ENABLE),y)
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "import_ip -files ./sgmii/sgmii.xci" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force " >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "source ./sgmii/sgmii.tcl" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force " >> $@; \
	else \
		echo $(SPACES)"WARNING: no SGMII IP was found"; \
	fi;
endif
	@if test -r $(UTILS_GRLIB)/netlists/$(TECHLIB); then \
		echo "import_files $(UTILS_GRLIB)/netlists/$(TECHLIB)" >> $@; \
	fi;
	@if test -r $(DESIGN_PATH)/mem_tile_floorplanning.xdc; then \
		echo "read_xdc  $(DESIGN_PATH)/mem_tile_floorplanning.xdc" >> $@; \
	    echo "set_property used_in_synthesis true [get_files $(DESIGN_PATH)/mem_tile_floorplanning.xdc]" >> $@; \
	    echo "set_property used_in_implementation true [get_files $(DESIGN_PATH)/mem_tile_floorplanning.xdc]" >> $@; \
	echo "set_property strategy Congestion_SpreadLogic_high [get_runs impl_1]" >> $@; \
	fi;
	@for i in $(XDC); do \
	  echo "read_xdc $$i" >> $@; \
	  echo "set_property used_in_synthesis true [get_files $$i]" >> $@; \
	  echo "set_property used_in_implementation true [get_files $$i]" >> $@; \
	done;
	@echo "set_property top $(TOP) [current_fileset]" >> $@

vivado/syn.tcl: vivado
	$(QUIET_INFO)echo "generating synthesis script for Vivado"
	@$(RM) $@
	@echo "open_project $(DESIGN).xpr" > $@
	@echo "update_ip_catalog" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "reset_run impl_1" >> $@
	@echo "reset_run synth_1" >> $@
#	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1 -jobs 12" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 360 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs 12" >> $@
	@echo "wait_on_run -timeout 360 impl_1" >> $@
	@echo "launch_runs impl_1 -to_step write_bitstream" >> $@
	@echo "wait_on_run -timeout 60 impl_1" >> $@

vivado/program.tcl: vivado
	$(QUIET_INFO)echo "generating programming script for $(PART)"
	@$(RM) $@
	@echo "set fpga_host [lindex \$$argv 0]" >> $@
	@echo "set port [lindex \$$argv 1]" >> $@
	@echo "set part [lindex \$$argv 2]" >> $@
	@echo "set bit [lindex \$$argv 3]" >> $@
	@echo "" >> $@
	@echo "open_hw_manager" >> $@
	@echo "connect_hw_server -url \$$fpga_host:\$$port" >> $@
	@echo "puts \"Connected to \$$fpga_host\"" >> $@
	@echo "puts \"Searching for \$$part...\"" >> $@
	@echo "" >> $@
	@echo "foreach cable [get_hw_targets ] {" >> $@
	@echo "    open_hw_target \$$cable" >> $@
	@echo "    set dev [get_hw_devices]" >> $@
	@echo "    if [string match -nocase \"\$$part*\" \$$dev] {" >> $@
	@echo "	puts \"Programming \$$part ...\"" >> $@
	@echo "	set_property PROGRAM.FILE \$$bit \$$dev" >> $@
	@echo "	program_hw_devices \$$dev" >> $@
	@echo "	close_hw_target" >> $@
	@echo "	disconnect_hw_server" >> $@
	@echo "	close_hw" >> $@
	@echo "	exit" >> $@
	@echo "    }" >> $@
	@echo "    close_hw_target" >> $@
	@echo "}" >> $@
	@echo "" >> $@
	@echo "disconnect_hw_server" >> $@
	@echo "close_hw" >> $@
	@echo "error \"ERROR: \$$part not found at host \$$fpga_host\"" >> $@


vivado/$(DESIGN): vivado vivado/srcs.tcl vivado/setup.tcl vivado/syn.tcl
	$(QUIET_INFO)echo "launching Vivado setup script"
	@cd vivado; \
	if test -r $(DESIGN).xpr; then \
		echo -n $(SPACES)"WARNING: overwrite existing Vivado project \"$(DESIGN)\"? [y|n]"; \
		while true; do \
			read -p " " yn; \
			case $$yn in \
				[Yy] ) \
					$(RM) $(DESIGN); \
					vivado $(VIVADO_BATCH_OPT) -source setup.tcl | tee ../vivado_setup.log; \
					break;; \
				[Nn] ) \
					echo $(SPACES)"INFO aborting $@"; \
					break;; \
				* ) echo -n $(SPACES)"INFO Please answer yes or no [y|n].";; \
			esac; \
		done; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source setup.tcl | tee ../vivado_setup.log; \
	fi; \
	cd ../;

vivado-setup: check_all_rtl_srcs vivado/$(DESIGN)

vivado-gui: vivado-setup
	$(QUIET_RUN)
	@cd vivado; \
	vivado $(DESIGN).xpr; \
	cd ../;

vivado-syn: vivado-setup
	$(QUIET_INFO)echo "launching Vivado implementation script"
	@cd vivado; \
	vivado $(VIVADO_BATCH_OPT) -source syn.tcl | tee ../vivado_syn.log; \
	cd ../;
	@bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		rm -rf $(TOP).bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
	fi; \

vivado-update: vivado vivado/syn.tcl
	$(QUIET_INFO)echo "Updating implementaiton with Vivado"
	@cd vivado; \
	if ! test -r $(DESIGN).xpr; then \
		echo -n $(SPACES)"Error: Vivado project \"$(DESIGN)\" does not exist. Please run 'make vivado-syn' first"; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source syn.tcl | tee ../vivado_syn.log; \
		cd ../; \
		bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
		if test -r $$bit; then \
			rm -rf $(TOP).bit; \
			ln -s $$bit; \
		else \
			echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
		fi; \
	fi;

vivado-prog-fpga: vivado/program.tcl
	@cd vivado; \
	bit=$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		vivado $(VIVADO_BATCH_OPT) -source program.tcl -tclargs $(FPGA_HOST) $(XIL_HW_SERVER_PORT) $(PART) $$bit; \
	else \
		echo $(SPACES)"ERROR: bistream not found; please run target vivado-syn first"; \
	fi; \
	cd ../;

vivado-clean:
	$(QUIET_CLEAN)$(RM) \
		vivado_*.log

vivado-distclean: vivado-clean
	$(QUIET_CLEAN)$(RM) \
		vivado	\
		mem_tile_floorplanning.xdc \
		*.bit

.PHONY: vivado-clean vivado-distclean vivado-syn vivado-prog-fpga vivado/$(DESIGN) vivado-setup vivado-gui


### PROFPGA targets ###

boards:
	$(QUIET_MKDIR)ln -s $(PROFPGA)/boards

profpga-prog-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --up

profpga-close-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --down

profpga-distclean:
	$(QUIET_CLEAN)$(RM) boards

.PHONY: profpga-distclean profpga-prog-fpga profpga-close-fpga

mmi64_regs.h: socmap.vhd

MMI64_DESP  = $(ESP_ROOT)/utils/mmi64/mmi64.c
MMI64_DESP += mmi64_regs.h

mmi64: $(MMI64_DESP)
ifeq ("$(PROFPGA)","")
	@echo "Path to proFPGA installation (\$PROFPGA) not set - terminating!"
else
	$(QUIET_CC)gcc -I ${PROFPGA}/include/ -I./ -fpic -rdynamic -o mmi64 \
		$(ESP_ROOT)/utils/mmi64/mmi64.c -Wl,--whole-archive ${PROFPGA}/lib/linux_x86_64/libprofpga.a \
		${PROFPGA}/lib/linux_x86_64/libmmi64.a \
		${PROFPGA}/lib/linux_x86_64/libconfig.a -Wl,--no-whole-archive -lpthread \
		-lrt -ldl
endif

mmi64-run: mmi64
	$(QUIET_RUN) ./$< mmi64.cfg

mmi64-clean:
	$(QUIET_CLEAN) $(RM) mmi64

mmi64-distclean: mmi64-clean
	$(QUIET_CLEAN) $(RM) *.rpt

.PHONY: mmi64-run mmi64-clean mmi64-distclean

### ESP Monitor targets ###

ESPMON_DEPS  = $(ESP_ROOT)/utils/espmon/espmonmain.ui
ESPMON_DEPS += $(ESP_ROOT)/utils/espmon/espmonmain.h  $(ESP_ROOT)/utils/espmon/mmi64_mon.h
ESPMON_DEPS += $(ESP_ROOT)/utils/espmon/espmonmain.cpp  $(ESP_ROOT)/utils/espmon/main.cpp  $(ESP_ROOT)/utils/espmon/mmi64_mon.cpp

mmi64_regs.h: esp-config

power.h: esp-config

espmon.mk: $(ESP_ROOT)/utils/espmon/espmon.pro
	@DESIGN_DIR=$(DESIGN_PATH) qmake -o $@ $<

espmon: $(ESPMON_DEPS) mmi64_regs.h power.h espmon.mk
	$(QUIET_MAKE)DESIGN_DIR=$(DESIGN_PATH) make --quiet -f espmon.mk

espmon-run: espmon boards
	$(QUIET_RUN)./$<

espmon-clean:
	$(QUIET_CLEAN)$(RM) 		\
		espmonmain.o		\
		main.o			\
		mmi64_mon.o		\
		moc_espmonmain.o	\
		espmon.mk		\
		moc_espmonmain.cpp	\
		ui_espmonmain.h		\
		moc_predefs.h		\
		.qmake.stash

espmon-distclean: espmon-clean
	$(QUIET_CLEAN)$(RM) 	\
		espmon 		\
		espmon*.rpt

.PHONY: espmon-clean espmon-distclean espmon-run


### FPGA Deploy targets ###

ifneq ($(findstring profpga, $(BOARD)),)
fpga-program: profpga-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
else
fpga-program: vivado-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
endif


fpga-run: esplink soft
	@./esplink --reset
	@./esplink --brom -i prom.bin
	@./esplink --dram -i systest.bin
	@./esplink --reset

fpga-run-linux: esplink fpga-program soft
	@./esplink --reset
	@./esplink --brom -i prom.bin
	@./esplink --dram -i linux.bin
	@./esplink --reset


.PHONY: fpga-run fpga-run-linux fpga-program


### Clean all ###
clean: 		soft-clean		\
		linux-clean		\
		xilinx_lib-clean 	\
		sim-clean		\
		ncsim-clean 		\
		xmsim-clean 		\
		esp-config-clean	\
		grlib-config-clean	\
		vivado-clean		\
		sldgen-clean		\
		espmon-clean		\
		mmi64-clean

distclean:	check_all_srcs-distclean 	\
		check_all_rtl_srcs-distclean	\
		profpga-distclean		\
		soft-distclean 			\
		linux-distclean			\
		barec-distclean			\
		examples-clean			\
		sim-distclean			\
		ncsim-distclean			\
		xmsim-distclean			\
		esp-config-distclean		\
		grlib-config-distclean		\
		vivado-distclean		\
		sldgen-distclean		\
		espmon-distclean		\
		mmi64-distclean
	$(QUIET_CLEAN)$(RM) *.log


.PHONY: clean distclean


### Utils ###

ifneq ($(UART_IP),)
ifeq ($(UART_PORT),)
$(error Please define both UART_IP and UART_PORT or neither)
endif

ttyV0:
	@socat pty,link=ttyV0,waitslave,mode=777 tcp:$(UART_IP):$(UART_PORT) &
	@sleep 1

uart: ttyV0
	@VIRTUAL_DEVICE=$$(readlink ttyV0); minicom -p $$VIRTUAL_DEVICE;

ifneq ($(DISPLAY),)
xuart: ttyV0
	@VIRTUAL_DEVICE=$$(readlink ttyV0); (xterm -e "minicom -p $$VIRTUAL_DEVICE" &);
else
xuart:
	$(MAKE) uart
endif

else
uart:
	@echo "*** UART_IP and UART_PORT are not defined. Open a serial console manually on the target UART device ***"
	@echo "*** If the FPGA board is connected to your computer, connect to the corresponding '/dev/ttyUSBx' device ***"

xuart: uart
endif


ifneq ($(SSH_IP),)

ifeq ($(SSH_PORT),)
SSH_PORT = 22
endif

ssh:
	@ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $(SSH_PORT) root@$(SSH_IP)

else

ssh:
	@echo "*** SSH_IP and SSH_PORT are not defined. Look for the IP addressed leased to the ESP instance at the end of the boot process ***"
	@echo "*** If you are on the same network as the FPGA boar, the default SSH_PORT is 22 ***"

endif

.PHONY: uart xuart ssh
