# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


INCDIR_INCISIVE = $(foreach dir, $(INCDIR), -INCDIR $(dir))

NCCOMOPT += -NOVITALCHECK
NCCOMOPT += -linedebug
NCCOMOPT += -v93
NCCOMOPT += -nocopyright

NCLOGOPT += -nocopyright
NCLOGOPT += -linedebug
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
NCLOGOPT += -DEFINE XILINX_FPGA
endif
NCLOGOPT += $(INCDIR_INCISIVE)

NCELABOPT += -nowarn DLCPT
NCELABOPT += -v93
NCELABOPT += -nocopyright
NCELABOPT += -disable_sem2009
NCELABOPT += -nomxindr
NCELABOPT += -timescale 10ps/10ps
NCELABOPT += -notimingchecks

NCSIMOPT += $(SIMTOP)
NCSIMOPT += -input ncsim.in

NCCOM     = ncvhdl $(NCCOMOPT)
NCLOG     = ncvlog -sv $(NCLOGOPT)
NCELAB    = ncelab $(NCELABOPT)
NCUPDATE  = ncupdate
NCSIM     = ncsim $(NCSIMOPT)


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

incisive/ncready: incisive/hdl.var $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	$(QUIET_MKDIR)mkdir -p incisive
	@echo $(SPACES)"WARNING: The source code for Ariane cannot be compiled with Incisive!!! If you need Ariane, please switch to Modelsim or Xcelium";
	@cd incisive; \
	if ! grep --quiet "DEFINE profpga" cds.lib; then \
		echo "DEFINE profpga $(DESIGN_PATH)/incisive/profpga" >> cds.lib; \
	fi; \
	if ! test -d profpga; then \
		mkdir -p profpga; \
	fi;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd incisive; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(NCCOM) -work profpga $$rtl"; \
		$(NCCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(NCLOG) -work profpga $$rtl"; \
		$(NCLOG) -work profpga $$rtl || exit; \
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
	for rtl in $(SIM_VHDL_PKGS); do \
		echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
		$(NCCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
	for rtl in $(SIM_VHDL_SRCS); do \
		echo $(SPACES)"$(NCCOM) -work work $$rtl"; \
		$(NCCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
	for rtl in $(SIM_VLOG_SRCS); do \
		echo $(SPACES)"$(NCLOG) $$rtl"; \
		$(NCLOG) -work work $$rtl || exit; \
	done; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec; \
	echo $(SPACES)"$(NCELAB) $(SIMTOP) $(EXTRA_SIMTOP)"; \
	$(NCELAB) $(SIMTOP) $(EXTRA_SIMTOP) && touch ncready;


incisive/ncsim.in:
	$(QUIET_BUILD)echo set severity_pack_assert_off {warning} > $@
	@echo set pack_assert_off { std_logic_arith numeric_std } >> $@
	@echo set intovf_severity_level {ignore} >> $@

ncsim-compile: socketgen check_all_srcs soft incisive/ncready incisive/ncsim.in
	@for dat in $(DAT_SRCS); do \
		cp $$dat incisive; \
	done; \
	$(QUIET_MAKE) \
	cd incisive; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec; \
	echo $(SPACES)"$(NCUPDATE) $(SIMTOP)"; \
	$(NCUPDATE) $(SIMTOP);

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
