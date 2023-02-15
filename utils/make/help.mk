# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


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
	@echo " make print-available-acc      	       : print a list of accelerators available for the HLS and Chisel flows."
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
	@echo " make acc                               : make <accelerator>-hls for all available accelerators."
	@echo " make acc-clean                         : make <accelerator>-clean for all available accelerators."
	@echo " make acc-distclean                     : make <accelerator>-distclean for all available accelerators."
	@echo " make chisel-acc                        : make <accelerator> for all available accelerators in Chisel."
	@echo " make chisel-acc-clean                  : make <accelerator>-clean for all available accelerators in Chisel."
	@echo " make chisel-acc-distclean              : make <accelerator>-distclean for all available accelerators in Chisel."
	@echo " make thirdparty-acc                    : make <accelerator> for all available third-party accelerators."
	@echo " make thirdparty-acc-clean              : make <accelerator>-clean for all available third-party accelerators."
	@echo " make thirdparty-acc-distclean          : make <accelerator>-distclean for all available third-party accelerators."
	@echo " make socketgen                         : generate RTL wrappers for scheduled acc; this"
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
	@echo
	@echo " make jtag-trace                       : run RTL simulation of ESP and generate traces for single-tile testing."
	@echo "                                         Traces are read by a dedicated per-tile JTAG interface that bypasses the NoC"
	@echo " make sim-jtag                         : run RTL simulation of one ESP tile using pregenerated traces. Target 'jtag-trace'"
	@echo "                                         must be manually launched prior to 'sim-jtag'. The target tile for the simulation"
	@echo "                                         defaults to tile 0, but can be overwritten by setting the environment variable"
	@echo "                                         JTAG_TEST_TILE to the number of the desired tile"
	@echo
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
	@echo " make baremetal-all                        : compile the bare-metal device drivers for available accelerators and"
	@echo "                                         for the digital-video interface (DVI). Executables (.exe) are placed to"
	@echo "                                         \"baremetal\" and can be used in simulation by setting TEST_PROGRAM"
	@echo " make linux                            : compile Linux, create root file-system and compile all ESP core drivers,"
	@echo "                                         drivers for accelerators, and test applications."
	@echo " make <accelerator>-baremetal              : compile the bare-metal device driver for the specified accelerator."
	@echo "                                         Executables (.exe) are placed to \"baremetal\" and can be used in simulation"
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


.PHONY: all help
