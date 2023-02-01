# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


INCDIR_MODELSIM = $(foreach dir, $(INCDIR), +incdir+$(dir))

VCOMOPT +=
VCOMOPT += -suppress vcom-1491
VLOGOPT += -suppress 2275
VLOGOPT += -suppress 2583
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VLOGOPT += +define+XILINX_FPGA
endif
VLOGOPT += $(INCDIR_MODELSIM)

VSIMOPT += -suppress 3812
VSIMOPT += -suppress 2697
VSIMOPT += -suppress 8617
VSIMOPT += -suppress 151
VSIMOPT += -suppress 143
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VSIMOPT += -L secureip_ver -L unisims_ver
endif
VSIMOPT += -uvmcontrol=disable -suppress 3009,2685,2718 -t fs
VSIMOPT += +notimingchecks
VSIMOPT += $(SIMTOP) $(EXTRA_SIMTOP)

VLIB = vlib
VCOM = vcom -quiet -93 $(VCOMOPT)
VLOG = vlog -sv -quiet $(VLOGOPT)
VSIM = VSIMOPT='$(VSIMOPT)' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT)


### Xilinx Simulation libs targets ###
$(ESP_ROOT)/.cache/modelsim/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator modelsim -library all" > $@/simlib.tcl; \
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


### Compile simulation source files ###
# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
modelsim/vsim.mk: modelsim/modelsim.ini $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	@cd modelsim; \
	if ! test -e profpga; then \
		vlib -type directory profpga; \
		$(SPACING)vmap profpga profpga; \
	fi;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd modelsim; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(VCOM) -work profpga $$rtl"; \
		$(VCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(VLOG) -work profpga"; \
		$(VLOG) -work profpga $$rtl || exit; \
	done;
endif
	@cd modelsim; \
	if ! test -e work; then \
		vlib -type directory work; \
		$(SPACING)vmap work work; \
	fi; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for rtl in $(SIM_VHDL_PKGS); do \
		echo $(SPACES)"$(VCOM) -work work $$rtl"; \
		$(VCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(SIM_VHDL_SRCS); do \
			echo $(SPACES)"$(VCOM) -work work $$rtl"; \
			$(VCOM) -work work $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(SIM_VLOG_SRCS); do \
			echo $(SPACES)"$(VLOG) -work work $$rtl"; \
			$(VLOG) -work work $$rtl || exit; \
		done;
	@echo $(SPACES)"### Compile BSG Verilog source files ###";
	@$(MAKE) bsg-sim-compile
	@cd modelsim; \
	echo $(SPACES)"vmake > vsim.mk"; \
	vmake 2> /dev/null > vsim.mk; \
	cd ../;

sim-compile: socketgen check_all_srcs modelsim/vsim.mk soft
	@for dat in $(DAT_SRCS); do \
		cp $$dat modelsim; \
	done;
	$(QUIET_MAKE)make -C modelsim -f vsim.mk
	@cd modelsim; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec;

sim: sim-compile
	$(QUIET_RUN)cd modelsim; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		$(VSIM) -c -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM) -c; \
	fi;

sim-gui: sim-compile
	$(QUIET_RUN)cd modelsim; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		$(VSIM) -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM); \
	fi;

sim-clean:
	$(QUIET_CLEAN)rm -rf transcript *.wlf

sim-distclean: sim-clean
	$(QUIET_CLEAN)rm -rf modelsim

.PHONY: sim sim-gui sim-compile sim-clean sim-distclean



### JTAG trace-based simulation (Modelsim only)
JTAG_TEST_SCRIPTS_DIR = $(ESP_ROOT)/utils/scripts/jtag_test
JTAG_TEST_TILE ?= 0

jtag-trace: sim-compile
	$(QUIET_RUN)cd modelsim; \
	mkdir -p jtag; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		VSIMOPT='$(VSIMOPT) -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT) -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM) -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"; \
	fi; \
	cd jtag; \
	$(JTAG_TEST_SCRIPTS_DIR)/jtag_test_format.sh; \
	LD_LIBRARY_PATH="" $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_stim.py $(JTAG_TEST_TILE)

sim-jtag: sim-compile
	$(QUIET_RUN)if test -e $(DESIGN_PATH)/modelsim/jtag/stim.txt; then \
	cd modelsim; \
		if test -e $(DESIGN_PATH)/vsim.tcl; then \
			VSIMOPT='$(VSIMOPT) -g JTAG_TRACE=$(JTAG_TEST_TILE)' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT) -do "do $(DESIGN_PATH)/vsim.tcl"; \
		else \
			$(VSIM) -g JTAG_TRACE=$(JTAG_TEST_TILE); \
		fi; \
	else \
		echo "Run make jtag-trace to generate stimulus file"; \
	fi;

jtag-clean:
	$(QUIET_CLEAN)$(RM) \
		modelsim/jtag/stim*_*.txt \
		modelsim/jtag/*.lst

jtag-distclean: jtag-clean
	$(QUIET_CLEAN)$(RM) modelsim/jtag

.PHONY: jtag-trace jtag-trace-pretty jtag-stim jtag-clean jtag-distclean
