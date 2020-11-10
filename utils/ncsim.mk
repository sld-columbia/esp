# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

NCCOM = ncvhdl -NOVITALCHECK -linedebug -v93 -nocopyright $(NCCOMOPT)
NCLOG = ncvlog -nocopyright -linedebug -sv $(NCLOGOPT)
NCELAB = ncelab -nowarn DLCPT -v93 -nocopyright -disable_sem2009 -nomxindr -timescale 10ps/10ps
NCUPDATE = ncupdate

$(ESP_ROOT)/.cache/incisive/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator ies -library all" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/incisive; \
	if ! vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; then \
		echo "$(SPACES)ERROR: Xilinx library compilation failed!"; rm -rf xilinx_lib cds.lib; exit 1; \
	fi;

incisive/cds.lib: $(ESP_ROOT)/.cache/incisive/xilinx_lib
	$(QUIET_MAKE)mkdir -p incisive
	@cp $(ESP_ROOT)/.cache/incisive/cds.lib $@

incisive/hdl.var: incisive/cds.lib
	@cp $(ESP_ROOT)/.cache/incisive/hdl.var $@

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
