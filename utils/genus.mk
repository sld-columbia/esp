# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

GENUS_VLOG = read_hdl -language v2001
GENUS_SVLOG = read_hdl -language sv
GENUS_VHDL = read_hdl -language vhdl

genus:
	$(QUIET_MKDIR)mkdir -p genus


genus/incdir.tcl: genus
	$(QUIET_MAKE) \
	echo "set log_syn(hdl_search_path) \"$(THIRDPARTY_INCDIR) $(ESP_CACHES_INCDIR) ${ARIANE}/src/common_cells/include\"" > $@

genus/srcs.tcl: genus check_all_rtl_srcs.old
	$(QUIET_MAKE)echo "### Compile Ariane source files ###" > $@; \
	rtl=$(ESP_ROOT)/socs/common/ariane_soc_pkg.sv; \
	echo "$(GENUS_SVLOG) $(GENUS_ARIANE_VLOGOPT) $$rtl" >> $@; \
	for ver in $(VERILOG_ARIANE); do \
		rtl=$$ver; \
		[[ $$rtl =~ .+trace  ]] || echo "$(GENUS_SVLOG) $(GENUS_ARIANE_VLOGOPT) $$rtl" >> $@; \
	done; \
	echo "### Compile VHDL packages ###" >> $@; \
	for rtl in $(THIRDPARTY_VHDL_PKGS); do \
		echo "$(GENUS_VHDL) $$rtl" >> $@; \
	done; \
	for vhd in $(SLDGEN_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo "$(GENUS_VHDL) $$rtl" >> $@; \
	done; \
	for lib in $$(cat $(ESP_ROOT)/rtl/include/libs.txt); do \
		for dir in $$(cat $(ESP_ROOT)/rtl/include/$$lib/dirs.txt); do \
			for vhd in $$(cat $(ESP_ROOT)/rtl/include/$$lib/$$dir/pkgs.txt); do \
				rtl=$(ESP_ROOT)/rtl/include/$$lib/$$dir/$$vhd; \
				echo "$(GENUS_VHDL) $$rtl" >> $@; \
			done; \
		done; \
	done; \
	for vhd in $(TOP_VHDL_RTL_PKGS); do \
		rtl=$$vhd; \
		echo "$(GENUS_VHDL) $$rtl" >> $@; \
	done; \
	echo "### Compile VHDL source files ###" >> $@; \
		for rtl in $(VHDL_SYN_SRCS); do \
			[[ $$rtl =~ techmap/unisim  ]] || [[ $$rtl =~ fpga_proxy_top.vhd  ]] || echo "$(GENUS_VHDL) $$rtl" >> $@; \
		done; \
	echo "### Compile Verilog source files ###" >> $@; \
		for rtl in $(VLOG_SYN_SRCS); do \
			[[ $$rtl =~ techmap/unisim  ]] || echo "$(GENUS_VLOG) $$rtl" >> $@; \
		done; \
	echo "### Compile SystemVerilog source files ###" >> $@; \
		for rtl in $(SVLOG_SYN_SRCS); do \
			echo "$(GENUS_SVLOG) $(GENUS_SVLOGOPT) $$rtl" >> $@; \
		done; \

genus/$(DESIGN): genus genus/srcs.tcl genus/incdir.tcl

genus-setup: check_all_rtl_srcs genus/$(DESIGN)


genus-clean:

genus-distclean: genus-clean
	$(QUIET_CLEAN)$(RM) \
		genus

#TODO rename genus/$(DESIGN) to actual Genus project name
.PHONY: genus-clean genus-distclean genus-setup genus/$(DESIGN)
