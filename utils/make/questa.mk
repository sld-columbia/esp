# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

QCOMOPT = $(VCOMOPT)
QLOGOPT = $(VLOGOPT)
QSIMOPT = $(VSIMOPT)

QLIB = vlib
QCOM = vcom -quiet -93 $(QCOMOPT)
QLOG = vlog -sv -quiet $(QLOGOPT)
QSIM = vsim $(QSIMOPT)

### Xilinx Simulation libs targets ###
$(ESP_ROOT)/.cache/questa/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator questa -library all" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/questa; \
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

questa/modelsim.ini: $(ESP_ROOT)/.cache/questa/xilinx_lib
	$(QUIET_MAKE)mkdir -p questa
	@cp $(ESP_ROOT)/.cache/questa/modelsim.ini $@


### Compile simulation source files ###
# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
questa/vsim.mk: questa/modelsim.ini $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	@cd questa; \
	if ! test -e profpga; then \
		vlib -type directory profpga; \
		$(SPACING)vmap profpga profpga; \
	fi;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd questa; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(QCOM) -work profpga $$rtl"; \
		$(QCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(QLOG) -work profpga"; \
		$(QLOG) -work profpga $$rtl || exit; \
	done;
endif
	@cd questa; \
	if ! test -e work; then \
		vlib -type directory work; \
		$(SPACING)vmap work work; \
	fi; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for rtl in $(SIM_VHDL_PKGS); do \
		echo $(SPACES)"$(QCOM) -work work $$rtl"; \
		$(QCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(SIM_VHDL_SRCS); do \
			echo $(SPACES)"$(QCOM) -work work $$rtl"; \
			$(QCOM) -work work $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(SIM_VLOG_SRCS); do \
			echo $(SPACES)"$(QLOG) -work work $$rtl"; \
			$(QLOG) -work work $$rtl || exit; \
		done;
	@cd questa; \
	echo $(SPACES)"vmake > vsim.mk"; \
	vmake 2> /dev/null > vsim.mk; \
	if ! test -e prom.srec; then \
		ln -s $(SOFT_BUILD)/prom.srec; \
	fi; \
	if ! test -e ram.srec; then \
		ln -s $(SOFT_BUILD)/ram.srec; \
	fi; \
	cd ../;

qsim-compile: socketgen check_all_srcs questa/vsim.mk soft
	@for dat in $(DAT_SRCS); do \
		cp $$dat questa; \
	done;
	$(QUIET_MAKE)make -C questa -f vsim.mk

qsim: qsim-compile
	@cd questa; \
	echo $(SPACES)"vsim -c $(QSIMOPT)"; \
	vsim -c $(QSIMOPT); \
	cd ../

qsim-gui: qsim-compile
	@cd questa; \
	echo $(SPACES)"$(QSIM)"; \
	$(QSIM); \
	cd ../

qsim-clean:
	$(QUIET_CLEAN)rm -rf transcript *.wlf

qsim-distclean: qsim-clean
	$(QUIET_CLEAN)rm -rf questa

.PHONY: qsim qsim-gui qsim-compile qsim-clean qsim-distclean
