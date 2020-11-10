# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

XMCOM = xmvhdl -NOVITALCHECK -linedebug -v93 -nocopyright $(XMCOMOPT)
XMLOG = xmvlog -nocopyright -linedebug -sv $(XMLOGOPT)
XMELAB = xmelab -nowarn DLCPT -v93 -nocopyright -disable_sem2009 -nomxindr -timescale 10ps/10ps
XMUPDATE = xmupdate

$(ESP_ROOT)/.cache/xcelium/xilinx_lib:
	$(QUIET_MKDIR)mkdir -p $@
	@echo "compile_simlib -directory xilinx_lib -simulator xcelium -library all" > $@/simlib.tcl; \
	cd $(ESP_ROOT)/.cache/xcelium; \
	if ! vivado $(VIVADO_BATCH_OPT) -source xilinx_lib/simlib.tcl; then \
		echo "$(SPACES)ERROR: Xilinx library compilation failed!"; rm -rf xilinx_lib cds.lib; exit 1; \
	fi;

xcelium/cds.lib: $(ESP_ROOT)/.cache/xcelium/xilinx_lib
	$(QUIET_MAKE)mkdir -p xcelium
	@cp $(ESP_ROOT)/.cache/xcelium/cds.lib $@

xcelium/hdl.var: xcelium/cds.lib
	@cp $(ESP_ROOT)/.cache/xcelium/hdl.var $@

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
		rtl=$$ver; \
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

