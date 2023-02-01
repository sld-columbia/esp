# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


### RTL files exclusions ###
GENUS_EXCLUDE_VLOG += $(ESP_ROOT)/rtl/cores/ariane/ariane/src/util/ex_trace_item.svh
GENUS_EXCLUDE_VLOG += $(ESP_ROOT)/rtl/cores/ariane/ariane/src/util/instr_trace_item.svh
GENUS_EXCLUDE_VLOG += $(ESP_ROOT)/rtl/cores/ariane/ariane/src/util/instr_tracer_if.sv
GENUS_EXCLUDE_VLOG += $(ESP_ROOT)/rtl/cores/ariane/ariane/src/util/instr_tracer.sv
GENUS_EXCLUDE_VLOG += $(ESP_ROOT)/rtl/cores/ibex/ibex/vendor/lowrisc_ip/ip/prim_xilinx/rtl/prim_xilinx_clock_gating.sv

GENUS_EXCLUDE_VHDL += $(ESP_ROOT)/rtl/sockets/monitor/monitor.vhd
GENUS_EXCLUDE_VHDL += $(DESIGN_PATH)/fpga_proxy_top.vhd


### Genus targets ###
GENUS_SVLOGOPT +=
GENUS_VLOG = read_hdl -language sv $(GENUS_VLOGOPT)
GENUS_VHDL = read_hdl -language vhdl

genus:
	$(QUIET_MKDIR)mkdir -p genus


genus/incdir.tcl: genus $(RTL_CFG_BUILD)/check_all_rtl_srcs.old
	$(QUIET_MAKE) \
	echo "set log_syn(hdl_search_path) \"$(INCDIR) $(BSG_INCDIR)\"" > $@

genus/srcs.tcl: genus $(RTL_CFG_BUILD)/check_all_rtl_srcs.old
	$(QUIET_MAKE) $(RM) $@
	@echo "### Compile VHDL packages ###" >> $@; \
	for vhd in $(VHDL_PKGS); do \
		rtl=$$vhd; \
		echo "$(GENUS_VHDL) $$rtl" >> $@; \
	done; \
	echo "### Compile VHDL source files ###" >> $@; \
	for rtl in $(VHDL_SRCS); do \
		if echo "$(GENUS_EXCLUDE_VHDL)" | grep -q $$rtl; then \
			echo "# skip $$rtl" >> $@; \
		else \
			[[ $$rtl =~ techmap/virtex  ]] || echo "$(GENUS_VHDL) $$rtl" >> $@; \
		fi; \
	done; \
	echo "### Compile Verilog source files ###" >> $@; \
	for rtl in $(VLOG_SRCS); do \
		if echo "$(GENUS_EXCLUDE_VLOG)" | grep -q $$rtl; then \
			echo "# skip $$rtl" >> $@; \
		else \
			[[ $$rtl =~ techmap/virtex  ]] || echo "$(GENUS_VLOG) $$rtl" >> $@; \
		fi; \
	done; \
	echo "### Compile BSG Verilog source files ###" >> $@; \
		echo "$(GENUS_VLOG) $(GENUS_BSG_VLOGOPT) $(BSG_VLOG_SRCS)" >> $@; \


genus/$(DESIGN): genus genus/srcs.tcl genus/incdir.tcl

genus-setup: check_all_rtl_srcs genus/$(DESIGN)


genus-clean:

genus-distclean: genus-clean
	$(QUIET_CLEAN)$(RM) \
		genus

#TODO rename genus/$(DESIGN) to actual Genus project name
.PHONY: genus-clean genus-distclean genus-setup genus/$(DESIGN)
