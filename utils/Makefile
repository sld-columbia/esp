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
	@echo " make print-available-accelerators  : print a list of accelerators available for HLS."
	@echo " make <accelerator>-hls             : run HLS for all configuration available for <accelerator>"
	@echo "                                      and generate corresponding RTL files."
	@echo " make <accelerator>-sim             : run all simulations defined for <accelerator> using the"
	@echo "                                      SystemC testbench; HLS may start if the RTL is out-of-date."
	@echo " make <accelerator>-plot            : run all simulations defined for <accelerator> and plot"
	@echo "                                      results on a latency vs area chard; HLS may start if the"
	@echo "                                      RTL is out-of-date."
	@echo " make <accelerator>-clean           : clean HLS working directory, but keep the generated RTL"
	@echo "                                      for <accelerator>; HLS cache is not deleted."
	@echo " make <accelerator>-distclean       : clean HLS working directory and remove the generated RTL"
	@echo "                                      for <accelerator>; HLS cache is not deleted."
	@echo " make accelerators                  : make <accelerator>-hls for all available accelerators."
	@echo " make accelerators-clean            : make <accelerator>-clean for all available accelerators."
	@echo " make accelerators-distclean        : make <accelerator>-distclean for all available accelerators."
	@echo " make sldgen                        : generate RTL wrappers for scheduled accelerators; this"
	@echo "                                      target is always called as a dependency before ESP"
	@echo "                                      simulaiton and synthesis."
	@echo
	@echo
	@echo " === SoC Flow ==="
	@echo
	@echo " make esp-defconfig                : read the default configuration for the current SoC folder"
	@echo "                                     and generate the corresponding SoC map."
	@echo " make esp-config                   : read the current configuration from .esp_config and"
	@echo "                                     generate the corresponding SoC map (may run as dependency)."
	@echo " make esp-xconig                   : open a GUI to configure and generate the SoC map."
	@echo " make sim                          : compile all source files and run an RTL simulation of ESP"
	@echo "                                     (requires Modelsim 10.5c)."
	@echo " make vivado-syn                   : generate a bitstream of ESP (requires Vivado 2016.3)."
	@echo " make vivado-prog-fpga             : load the generated bitstream to FPGA. This target requires"
	@echo "                                     the environment variable FPGA_HOST set to the network ip of"
	@echo "                                     the machine with FTDI or JTAG link to the FPGA. The FPGA_HOST"
	@echo "                                     must run the hw_server deamon from Vivado 2016.3. The variable"
	@echo "                                     XIL_HW_SERVER_PORT must be set to the port chosen for the"
	@echo "                                     hw_server communication."
	@echo " make profpga-prog-fpga            : load the generated bitstream to proFPGA system. The profpga.cfg"
	@echo "                                     configuration file in the current SoC folder must match the"
	@echo "                                     board setup, including network, USB, or PCIe link information."
	@echo " make profpga-close-fpga           : turn off the proFPGA system."
	@echo
	@echo " make espmon-run                   : open ESP monitor GUI interface (requires proFPGA system)"
	@echo
	@echo
	@echo " === Software Flow ==="
	@echo
	@echo " make soft                         : compile the bare-metal program systest.c. The target architecutre"
	@echo "                                     is selected based on the varialble CPU_ARCH."
	@echo " make barec-all                    : compile the bare-metal device drivers for available accelerators and"
	@echo "                                     for the digital-video interface (DVI). Executables (.exe) are placed to"
	@echo "                                     \"barec\" and can be used in simulation by replacing \"systest.c\""
	@echo " make linux                        : compile Linux, create root file-system and compile all ESP core drivers,"
	@echo "                                     drivers for accelerators, and test applications."
	@echo " make <accelerator>-barec          : compile the bare-metal device driver for the specified accelerator."
	@echo "                                     Executables (.exe) are placed to \"barec\" and can be used in simulation"
	@echo "                                     by replacing \"systest.c\""
	@echo " make <accelerator>-driver         : compile the Linux device driver for the specified accelerator. Drivers"
	@echo "                                     are placed to \"sysroot/opt/drivers\" and load automatically during OS boot"
	@echo " make <accelerator>-app            : compile the Linux test application for the specified accelerator."
	@echo "                                     Executables are placed to \"sysroot/applications/test\""
	@echo
	@echo
	@echo " === Cobham open-source IPs (GRLIB) ==="
	@echo
	@echo " make grlib-defconfig              : read the default configuration for grlib IPs."
	@echo " make grlib-config                 : read the configuration for grlib IPs from .grlib_config"
	@echo "                                     (may run as dependency)."
	@echo " make grlib-xconfig                : open grlib configuration GUI; useful when using the LEON-3"
	@echo "                                     embedded processor."
	@echo " make leon3-soft                   : compile the bare-metal program for LEON-3; The resulting"
	@echo "                                     executable is used for RTL simulation, but can also run on"
	@echo "                                     LEON-3 after loading the bistream to FPGA (requires LEON-3"
	@echo "                                     tool-chain and optionally grmon if running on FPGA)."
	@echo " make linux.dsu                    : package Linux image for LEON-3. This target is called by the"
	@echo "                                     generic \"linux\" target when the variable CPU_ARCH is set to"
	@echo "                                     leon3 (see \"make linux\")."
	@echo



### Include common Makefile for desing configuration ###
include $(ESP_ROOT)/utils/design.mk


### Set variables needed before including accelerators.mk
SOFT              = $(ESP_ROOT)/soft/$(CPU_ARCH)
LINUXSRC          = $(SOFT)/linux
DRIVERS           = $(SOFT)/drivers
CONTIG_ALLOC_PATH = $(DRIVERS)/contig_alloc
ESP_CORE_PATH     = $(DRIVERS)/esp


### Include targets to generate accelerators RTL with HLS ###
include $(ESP_ROOT)/utils/accelerators.mk


.PHONY: all help

### SoC configuration for ESP ###

.esp_config:
	$(QUIET_CP)cp ../defconfig/esp_$(BOARD)_defconfig $@

esp-defconfig: ../defconfig/esp_$(BOARD)_defconfig
	$(QUIET_CP)cp $< .esp_config
	$(QUIET_MAKE)$(MAKE) esp-config

socmap.vhd: .esp_config grlib_config.vhd
	$(QUIET_DIFF)echo "checking .esp_config..."
	@/usr/bin/diff .esp_config ../defconfig/esp_$(BOARD)_defconfig -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for ESP"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".esp_config\" for ESP"; \
	fi
	@echo ""
	@echo "Generating ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator_batch.py $(NOC_WIDTH)

esp-config: socmap.vhd

esp-xconfig: grlib_config.vhd
	@echo ""
	@echo "Running interactive ESP configuration..."
	@python3 $(ESP_ROOT)/utils/socmap/esp_creator.py $(NOC_WIDTH)

esp-config-clean:
	$(QUIET_CLEAN)$(RM) \
		.esp_config.bak

esp-config-distclean: esp-config-clean
	$(QUIET_CLEAN)$(RM)	\
		socmap.vhd	\
		.esp_config	\
		mmi64_regs.h	\
		power.h


.PHONY: esp-xconfig esp-defconfig esp-config-clean esp-config-distclean

### RTL simulator executables for Modelsim SE ###
VLIB = vlib
VCOM = vcom -quiet $(VCOMOPT)
VLOG = vlog -quiet $(VLOGOPT)

### Options for Vivado batch mode ###
VIVADO_BATCH_OPT = -mode batch -quiet -notrace

### proFPGA include paths ###
PROFPGA_INCDIR = $(PROFPGA)/hdl/generic_hdl $(PROFPGA)/hdl/mmi64 $(PROFPGA)/hdl/profpga_user
PROFPGA_INCDIR_MODELSIM = $(foreach dir, $(PROFPGA_INCDIR), +incdir+$(dir))

### Patsh shortcuts ###
UTILS_GRLIB = $(ESP_ROOT)/utils/grlib
TKCONFIG   = $(UTILS_GRLIB)/tkconfig

### Board files ###
BOARD_FILES = $(wildcard $(ESP_ROOT)/constraints/$(BOARD)/*)


ifeq ("$(CPU_ARCH)", "leon3")
### Leon3 Software targets ###
include $(UTILS_GRLIB)/leon3_sw.mk

soft: leon3-soft ahbrom.vhd

soft-clean: leon3-soft-clean ahbrom-clean

soft-distclean: leon3-soft-distclean ahbrom-distclean

.PHONY: leon3-soft-clean leon3-soft-distclean


### Leon3 prom ###

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
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- $(MAKE)  O=${PWD}/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)

linux-build/vmlinux: sysroot.cpio linux-build/.config
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- $(MAKE) -C linux-build

sysroot/opt/drivers-esp/contig_alloc.ko: linux-build/vmlinux $(wildcard $(CONTIG_ALLOC_PATH)/*.c) $(wildcard $(CONTIG_ALLOC_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build $(MAKE) -C $(CONTIG_ALLOC_PATH)
	$(QUIET_CP)cp $(CONTIG_ALLOC_PATH)/contig_alloc.ko $@

sysroot/opt/drivers-esp/esp.ko: linux-build/vmlinux $(wildcard $(ESP_CORE_PATH)/*.c) $(wildcard $(ESP_CORE_PATH)/*.h) $(wildcard $(DRIVERS)/include/*.h)
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build CONTIG_ALLOC_PATH=$(CONTIG_ALLOC_PATH) $(MAKE) -C $(ESP_CORE_PATH)
	$(QUIET_CP)cp $(ESP_CORE_PATH)/esp.ko $@

# This is a PHONY to guarantee sysroot is always updated when apps or drivers change
# Most targets won't actually do anything if their dependencies have not changed.
# Linux is compiled twice if necessary to ensure drivers are compiled against the most recent kernel
sysroot-update: linux-build/vmlinux
	@touch sysroot
	@$(MAKE) sysroot/opt/drivers-esp/contig_alloc.ko
	@$(MAKE) sysroot/opt/drivers-esp/esp.ko
	@CROSS_COMPILE=sparc-leon3-linux- $(MAKE) -C $(DRIVERS)/dvi/app
	@cp $(DRIVERS)/dvi/app/*.exe sysroot/applications/dvi
	@$(MAKE) accelerators-driver
	@$(MAKE) accelerators-app
	$(QUIET_MAKE)$(MAKE) linux-build/vmlinux


linux.dsu: sysroot-update
	$(QUIET_BUILD)mklinuximg linux-build/vmlinux $@

linux: linux.dsu

linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e linux-build; then \
		ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- $(MAKE) --quiet -C linux-build clean; \
	fi;

linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) linux-build linux.dsu
	@ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- $(MAKE) --quiet -C ${LINUXSRC} mrproper

sysroot-clean:
	$(QUIET_CLEAN)$(RM) sysroot.files sysroot.cpio
	@CROSS_COMPILE=sparc-leon3-linux- $(MAKE) --quiet -C $(DRIVERS)/dvi/app clean
	@if test -e linux-build; then \
		ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build CONTIG_ALLOC_PATH=$(CONTIG_ALLOC_PATH) $(MAKE) --quiet -C $(ESP_CORE_PATH) clean; \
		ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build $(MAKE) -C $(CONTIG_ALLOC_PATH) clean; \
		$(MAKE) --quiet accelerators-driver-clean; \
	fi;
	@$(MAKE) --quiet accelerators-app-clean

sysroot-distclean: sysroot-clean
	$(QUIET_CLEAN)$(RM) sysroot

else
### Other architectures if avalable ###

soft:

soft-clean:

soft-distclean:

linux:

linux-clean:

linux-distclean:

sysroot-update:

sysroot-clean:

sysroot-distclean:

endif

linux-build:
	$(QUIET_MKDIR)mkdir -p $@

.PHONY: soft soft-clean soft-distclean linux linux-clean linux-distclean

.PHONY: sysroot-update sysroot-clean sysroot-distclean

barec:
	$(QUIET_MKDIR)mkdir -p $@

barec-all: barec
	@mkdir -p barec/dvi
	@CROSS_COMPILE=sparc-elf- $(MAKE) -C $(DRIVERS)/dvi/barec
	@cp $(DRIVERS)/dvi/barec/*.exe barec/dvi
	@$(MAKE) accelerators-barec


barec-distclean:
	$(QUIET_CLEAN)$(RM) barec
	@CROSS_COMPILE=sparc-elf- $(MAKE) --quiet -C $(DRIVERS)/dvi/barec clean
	@$(MAKE) --quiet accelerators-barec-clean

.PHONY: barec-distclean barec-all


### GRLIB config targets ###

TKCONFIG_DEP   = $(TKCONFIG)/config.vhd
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.vhd)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.h)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.help)
TKCONFIG_DEP  += grlib_config.in

.grlib_config:
	$(QUIET_CP)cp ../defconfig/grlib_$(BOARD)_defconfig $@

grlib-defconfig: ../defconfig/grlib_$(BOARD)_defconfig
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
	@/usr/bin/diff .grlib_config ../defconfig/grlib_$(BOARD)_defconfig -q > /dev/null; \
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

VLOG_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.v" ))
VLOG_RTL_SRCS += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.v" ))

VHDL_SIM_PKGS  = $(shell (find $(ESP_ROOT)/sim/include -name "*.vhd" ))
VHDL_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.vhd" ))
VLOG_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.v" ))

VHDL_PKGS = $(VHDL_RTL_PKGS) $(VHDL_SIM_PKGS) $(TOP_VHDL_RTL_PKGS) $(TOP_VHDL_SIM_PKGS)
VHDL_SRCS = $(VHDL_RTL_SRCS) $(VHDL_SIM_SRCS) $(TOP_VHDL_RTL_SRCS) $(TOP_VHDL_SIM_SRCS)
VLOG_SRCS = $(VLOG_RTL_SRCS) $(VLOG_SIM_SRCS) $(TOP_VLOG_RTL_SRCS) $(TOP_VLOG_SIM_SRCS)

ALL_SRCS  = $(VHDL_PKGS) $(VHDL_SRCS) $(VLOG_SRCS)

VHDL_ALL_RTL = $(VHDL_RTL_PKGS) $(TOP_VHDL_RTL_PKGS)  $(VHDL_RTL_SRCS) $(TOP_VHDL_RTL_SRCS)
VLOG_ALL_RTL = $(VLOG_RTL_PKGS) $(TOP_VLOG_RTL_PKGS)  $(VLOG_RTL_SRCS) $(TOP_VLOG_RTL_SRCS)

ALL_RTL_SRCS  = $(VHDL_ALL_RTL) $(VLOG_ALL_RTL)

check_all_srcs: grlib_config.vhd socmap.vhd
	@echo $(ALL_SRCS) > $@.new; \
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

check_all_srcs-distclean:
	$(QUIET_CLEAN)rm -rf check_all_srcs.old

.PHONY: check_all_srcs check_all_srcs-distclean

check_all_rtl_srcs: grlib_config.vhd socmap.vhd
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

ifeq ("$(TECHLIB)", "virtex7")
modelsim/xilinx_lib: $(VIVADO)
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator modelsim -no_ip_compile" > $@/simlib.tcl; \
	cd modelsim; \
	vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; \
	lib_path=$$(cat modelsim.ini | grep secureip | cut -d " " -f 3); \
	sed -i "/secureip =/a secureip_ver = "$$lib_path"" modelsim.ini; \
	sed -i 's/; Show_source = 1/Show_source = 1/g' modelsim.ini; \
	sed -i 's/; Show_Warning3 = 0/Show_Warning3 = 0/g' modelsim.ini; \
	sed -i 's/; Show_Warning5 = 0/Show_Warning5 = 0/g' modelsim.ini; \
	sed -i 's/; StdArithNoWarnings = 1/StdArithNoWarnings = 1/g' modelsim.ini; \
	sed -i 's/; NumericStdNoWarnings = 1/NumericStdNoWarnings = 1/g' modelsim.ini; \
	sed -i 's/\(suppress = [0-9]\+\)/\1,1491/g' modelsim.ini; \
	cd ../;

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
		modelsim/xilinx_lib \

else
modelsim/xilinx_lib:

xilinx_lib-clean:

xilinx_lib-distclean:

endif

.PHONY: xilinx_lib-clean xilinx_lib-distclean

### Modelsim targets ###

modelsim/mig:
	$(QUIET_MKDIR)mkdir -p $@
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.xci; then \
		echo $(SPACES)"INFO generating MIG IP for simulation"; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.xci $@; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.prj $@; \
		echo "create_project -part $(DEVICE) dummy ." > $@/vivado.tcl; \
		if [ "$(PROTOBOARD)" != "" ]; then \
			echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@/vivado.tcl; \
		fi; \
		echo "read_ip mig.xci" >> $@/vivado.tcl; \
		echo "generate_target  all [get_files mig.xci] -force " >> $@/vivado.tcl; \
		cd $@; \
		vivado $(VIVADO_BATCH_OPT) -source vivado.tcl; \
		cd $(DESIGN_PATH); \
	else \
		echo $(SPACES)"WARNING: no MIG IP was found"; \
	fi;


ifeq ($(CONFIG_GRETH_ENABLE),y)
modelsim/sgmii:
	$(QUIET_MKDIR)mkdir -p $@
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci; then \
		echo $(SPACES)"INFO generating SGMII IP for simulation"; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.* $@; \
		echo "create_project -part $(DEVICE) dummy ." > $@/vivado.tcl; \
		if [ "$(PROTOBOARD)" != "" ]; then \
			echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@/vivado.tcl; \
		fi; \
		echo "read_ip sgmii.xci" >> $@/vivado.tcl; \
		echo "generate_target  all [get_files sgmii.xci] -force " >> $@/vivado.tcl; \
		cd $@; \
		vivado $(VIVADO_BATCH_OPT) -source vivado.tcl; \
		cd $(DESIGN_PATH); \
	else \
		echo $(SPACES)"WARNING: no SGMII IP was found"; \
	fi;
else
modelsim/sgmii:

endif

# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
modelsim/vsim.mk: modelsim/xilinx_lib check_all_srcs.old $(PKG_LIST)
	$(QUIET_MKDIR)mkdir -p modelsim
	@cd modelsim; \
	vlib -type directory profpga; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(VCOM) -work profpga $$rtl"; \
		$(VCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(VLOG) -work profpga +incdir+... $$rtl"; \
		$(VLOG) -work profpga $(PROFPGA_INCDIR_MODELSIM) $$rtl || exit; \
	done; \
	vlib -type directory work; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
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
			$(VLOG) $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile IPs simulation files ###"; \
	if test -r ./mig/mig.xci; then \
		echo $(SPACES)"$(VLOG) ./mig/mig/user_design/rtl/mig.v"; \
		$(VLOG) ./mig/mig/user_design/rtl/mig.v; \
		$(VLOG) ./mig/mig/user_design/rtl/*/*.v; \
	fi; \
	echo $(SPACES)"$(VLOG) $(VIVADO)/data/verilog/src/glbl.v"; \
	$(VLOG) $(VIVADO)/data/verilog/src/glbl.v; \
	if test -r ./sgmii/sgmii.xci; then \
		vlib -type directory gig_ethernet_pcs_pma_v16_0_0; \
		vmap gig_ethernet_pcs_pma_v16_0_0 gig_ethernet_pcs_pma_v16_0_0; \
		echo $(SPACES)"$(VCOM) ./sgmii/hdl/gig_ethernet_pcs_pma_v16_0_rfs.vhd"; \
		$(VCOM) -work gig_ethernet_pcs_pma_v16_0_0 ./sgmii/hdl/gig_ethernet_pcs_pma_v16_0_rfs.vhd; \
		$(VLOG) ./sgmii/synth/*.v; \
		$(VLOG) ./sgmii/synth/*/*.v ;\
        fi; \
	$(SPACING)vmap work work;\
	$(SPACING)vmap profpga profpga;\
	echo $(SPACES)"vmake > vsim.mk"; \
	vmake 2> /dev/null > vsim.mk; \
	ln -s ../prom.srec; \
	ln -s ../ram.srec; \
	cd ../;

sim-compile: sldgen check_all_srcs modelsim/mig modelsim/sgmii modelsim/vsim.mk soft
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

vivado/srcs.tcl: sldgen vivado check_all_rtl_srcs.old
	$(QUIET_INFO)echo "generating source list for Vivado"
	@$(RM) $@
	@for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo "read_vhdl -library profpga $$rtl" >> $@; \
	done;
	@for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo "read_verilog -library profpga $$rtl" >> $@; \
	done;
	@for rtl in $(SLDGEN_VHDL_RTL_PKGS); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(VHDL_ALL_RTL); do \
		echo "read_vhdl $$rtl" >> $@; \
	done; \
	for rtl in $(VLOG_ALL_RTL); do \
		echo "read_verilog $$rtl" >> $@; \
	done;


vivado/setup.tcl: vivado $(XDC) $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@echo "create_project $(DESIGN) -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
ifneq ($(findstring profpga, $(BOARD)),)
	@echo "set_property include_dirs {$(PROFPGA_INCDIR)} [get_filesets {sim_1 sources_1}]" >> $@
endif
	@echo "source ./srcs.tcl" >> $@
ifneq ("$(PROTOBOARD)","")
	@echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@
endif
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.xci; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.xci ./vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.prj ./vivado/mig; \
		echo "import_ip -files ./mig/mig.xci" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	else \
		echo $(SPACES)"WARNING: no MIG IP was found"; \
	fi;
ifeq ($(CONFIG_GRETH_ENABLE),y)
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.* ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "import_ip -files ./sgmii/sgmii.xci" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force " >> $@; \
	else \
		echo $(SPACES)"WARNING: no SGMII IP was found"; \
	fi;
endif
	@if test -r $(UTILS_GRLIB)/netlists/xilinx/$(TECHNOLOGY); then \
		echo "import_files $(UTILS_GRLIB)/netlists/xilinx/$(TECHNOLOGY)" >> $@; \
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
	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 360 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -to_step write_bitstream" >> $@
	@echo "wait_on_run -timeout 360 impl_1" >> $@

vivado/program.tcl: vivado
	$(QUIET_INFO)echo "generating programming script for $(PART)"
	@$(RM) $@
	@echo "set fpga_host [lindex \$$argv 0]" >> $@
	@echo "set port [lindex \$$argv 1]" >> $@
	@echo "set part [lindex \$$argv 2]" >> $@
	@echo "set bit [lindex \$$argv 3]" >> $@
	@echo "" >> $@
	@echo "open_hw" >> $@
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
		ui_espmonmain.h

espmon-distclean: espmon-clean
	$(QUIET_CLEAN)$(RM) 	\
		espmon 		\
		espmon*.rpt

.PHONY: espmon-clean espmon-distclean espmon-run



### Clean all ###
clean: 		soft-clean		\
		linux-clean		\
		xilinx_lib-clean 	\
		sim-clean		\
		esp-config-clean	\
		grlib-config-clean	\
		vivado-clean		\
		sldgen-clean		\
		espmon-clean

distclean:	check_all_srcs-distclean 	\
		check_all_rtl_srcs-distclean	\
		profpga-distclean		\
		soft-distclean 			\
		linux-distclean			\
		barec-distclean			\
		xilinx_lib-distclean 		\
		sim-distclean			\
		esp-config-distclean		\
		grlib-config-distclean		\
		vivado-distclean		\
		sldgen-distclean		\
		espmon-distclean


.PHONY: clean distclean
