# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

VLIB = vlib
VCOM = vcom -quiet -93 $(VCOMOPT)
VLOG = vlog -quiet $(VLOGOPT)

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
		rtl=$$ver; \
		echo $(SPACES)"$(VLOG) $(ARIANE_VLOGOPT) $$rtl"; \
		$(VLOG) $(ARIANE_VLOGOPT) $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile Ibex source files ###"; \
	for ver in $(VERILOG_IBEX); do \
		rtl=$$ver; \
		echo $(SPACES)"$(VLOG) $(IBEX_VLOGOPT) $$rtl"; \
		$(VLOG) $(IBEX_VLOGOPT) $$rtl || exit; \
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



### JTAG trace-based simulation (Modelsim only)
JTAG_TEST_SCRIPTS_DIR = $(ESP_ROOT)/utils/scripts/jtag_test
JTAG_TEST_TILE ?= 0

jtag-trace: sim-compile
	$(QUIET_RUN)cd modelsim; \
	echo $(SPACES)"vsim $(VSIMOPT)" -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"; \
	vsim $(VSIMOPT) -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"; \
	cd ../

jtag-trace-pretty:
	$(QUIET_BUILD)cd modelsim; \
	$(JTAG_TEST_SCRIPTS_DIR)/jtag_test_format.sh

jtag-stim: jtag-trace-pretty
	$(QUIET_BUILD)cd modelsim; \
	$(JTAG_TEST_SCRIPTS_DIR)/jtag_test_stim.py $(JTAG_TEST_TILE)

sim-jtag: sim-compile jtag-stim
	$(QUIET_RUN)cd modelsim; \
	echo $(SPACES)"vsim $(VSIMOPT) -g JTAG_TRACE=$(JTAG_TEST_TILE)"; \
	vsim $(VSIMOPT) -g JTAG_TRACE=$(JTAG_TEST_TILE); \
	cd ../; \

.PHONY: jtag-trace jtag-trace-pretty jtag-stim
