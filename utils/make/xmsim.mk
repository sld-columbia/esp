# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


INCDIR_XCELIUM = $(foreach dir, $(INCDIR), -INCDIR $(dir))

XMCOMOPT += -NOVITALCHECK
XMCOMOPT += -linedebug
XMCOMOPT += -v93
XMCOMOPT += -nocopyright

XMLOGOPT += -nocopyright
XMLOGOPT += -linedebug
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
XMLOGOPT += -DEFINE XILINX_FPGA
endif
XMLOGOPT += $(INCDIR_XCELIUM)

XMELABOPT += -nowarn DLCPT
XMELABOPT += -v93
XMELABOPT += -nocopyright
XMELABOPT += -disable_sem2009
XMELABOPT += -nomxindr
XMELABOPT += -timescale 10ps/10ps
XMELABOPT += -notimingchecks

XMSIMOPT += $(SIMTOP)
XMSIMOPT += -input xmsim.in

XMCOM     = xmvhdl  $(XMCOMOPT)
XMLOG     = xmvlog -sv $(XMLOGOPT)
XMELAB    = xmelab $(XMELABOPT)
XMUPDATE  = xmupdate
XMSIM     = xmsim $(XMSIMOPT)


### Xilinx Simulation libs targets ###
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


### Compile simulation source files ###
xcelium/xmready: xcelium/hdl.var $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	$(QUIET_MKDIR)mkdir -p xcelium
	@cd xcelium; \
	if ! grep --quiet "DEFINE profpga" cds.lib; then \
		echo "DEFINE profpga $(DESIGN_PATH)/xcelium/profpga" >> cds.lib; \
	fi; \
	if ! test -d profpga; then \
		mkdir -p profpga; \
	fi;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd xcelium; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(XMCOM) -work profpga $$rtl"; \
		$(XMCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(XMLOG) -work profpga $$rtl"; \
		$(XMLOG) -work profpga $$rtl || exit; \
	done;
endif
	@cd xcelium; \
	if ! grep --quiet "DEFINE work" cds.lib; then \
		echo "DEFINE work $(DESIGN_PATH)/xcelium/work" >> cds.lib; \
	fi; \
	if ! test -e work; then \
		mkdir -p work; \
	fi; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for rtl in $(SIM_VHDL_PKGS); do \
		echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
		$(XMCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
	for rtl in $(SIM_VHDL_SRCS); do \
		echo $(SPACES)"$(XMCOM) -work work $$rtl"; \
		$(XMCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
	for rtl in $(SIM_VLOG_SRCS); do \
		echo $(SPACES)"$(XMLOG) -work work $$rtl"; \
		$(XMLOG) -work work $$rtl || exit; \
	done; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec; \
	echo $(SPACES)"$(XMELAB) $(SIMTOP) $(EXTRA_SIMTOP)"; \
	$(XMELAB) $(SIMTOP) $(EXTRA_SIMTOP) && touch xmready;


xcelium/xmsim.in:
	$(QUIET_BUILD)echo set severity_pack_assert_off {warning} > $@
	@echo set pack_assert_off { std_logic_arith numeric_std } >> $@
	@echo set intovf_severity_level {ignore} >> $@

xmsim-compile: socketgen check_all_srcs soft xcelium/xmready xcelium/xmsim.in
	$(QUIET_MAKE) \
	cd xcelium; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec; \
	echo $(SPACES)"$(XMUPDATE) $(SIMTOP)"; \
	$(XMUPDATE) $(SIMTOP);

xmsim: xmsim-compile
	@cd xcelium; \
	echo $(SPACES)"$(XMSIM)"; \
	$(XMSIM); \
	cd ../

xmsim-gui: xmsim-compile
	@cd xcelium; \
	echo $(SPACES)"$(XMSIM) -gui"; \
	$(XMSIM) -gui; \
	cd ../

xmsim-clean:
	$(QUIET_CLEAN)

xmsim-distclean: xmsim-clean
	$(QUIET_CLEAN) $(RM) xcelium INCA_libs xcelium.d

.PHONY: xmsim xmsim-gui xmsim-compile xmsim-clean xmsim-distclean

