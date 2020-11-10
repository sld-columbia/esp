# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


### Include paths ###
ifneq ($(findstring profpga, $(BOARD)),)
PROFPGA_INCDIR = $(PROFPGA)/hdl/generic_hdl $(PROFPGA)/hdl/mmi64 $(PROFPGA)/hdl/profpga_user $(PROFPGA)/hdl/pd_muxdemux2
else
PROFPGA_INCDIR =
endif

ESP_CACHES_INCDIR = $(ESP_ROOT)/rtl/src/sld/caches/esp-caches/common/defs $(DESIGN_PATH)

INCDIR_MODELSIM = $(foreach dir, $(PROFPGA_INCDIR) $(ESP_CACHES_INCDIR), +incdir+$(dir))
INCDIR_XCELIUM = $(foreach dir, $(PROFPGA_INCDIR) $(ESP_CACHES_INCDIR), -INCDIR $(dir))
INCDIR_INCISIVE = $(INCDIR_XCELIUM)


### Desing source files ###
ifneq ($(findstring profpga, $(BOARD)),)
VHDL_PROFPGA = $(shell strings $(ESP_ROOT)/utils/profpga_vhd.txt)
VERILOG_PROFPGA = $(shell strings $(ESP_ROOT)/utils/profpga_verilog.txt)
else
VHDL_PROFPGA =
VERILOG_PROFPGA =
endif

VERILOG_ARIANE += $(foreach f, $(shell strings $(ESP_ROOT)/utils/ariane_verilog.txt), $(ARIANE)/$(f))
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VERILOG_ARIANE += $(foreach f, $(shell strings $(ESP_ROOT)/utils/ariane_verilog_fpga.txt), $(ARIANE)/$(f))
endif
ifeq ("$(CPU_ARCH)", "ariane")
VERILOG_ARIANE += $(DESIGN_PATH)/plic_regmap.sv
endif

PKG_LIST  = $(shell (find $(ESP_ROOT)/rtl -name "*.txt" ))
PKG_LIST += $(shell (find $(ESP_ROOT)/sim -name "*.txt" ))

RTL_LIBS += $(foreach lib, $(shell (cat $(ESP_ROOT)/rtl/libs.txt)), $(lib))
SIM_LIBS += $(foreach lib, $(shell (cat $(ESP_ROOT)/sim/libs.txt)), $(lib))

VHDL_RTL_PKGS  = $(shell (find $(ESP_ROOT)/rtl/include -name "*.vhd" ))
ifneq ($(findstring profpga, $(BOARD)),)
VHDL_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.vhd" ))
else
VHDL_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.vhd" | grep -v "sld/sldcommon/monitor.vhd"))
endif
VHDL_RTL_SRCS  += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.vhd" ))


VLOG_RTL_SRCS      = $(shell (find $(ESP_ROOT)/rtl/src -name "*.v" ))
VLOG_RTL_SRCS     += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.v" ))

RTL_TECH_FOLDERS   = $(filter-out $(ESP_ROOT)/tech/$(TECHLIB)/verilog/, $(shell ls -d $(ESP_ROOT)/tech/$(TECHLIB)/*/))
VLOG_SYN_RTL_SRCS  = $(shell (find $(ESP_ROOT)/rtl/src -name "*.v" ))
VLOG_SYN_RTL_SRCS += $(foreach f, $(RTL_TECH_FOLDERS), $(shell (find $(f) -name "*.v")))

SVLOG_RTL_SRCS   = $(shell (find $(ESP_ROOT)/rtl/src -name "*.sv" ))
SVLOG_RTL_SRCS  += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.sv" ))

IP_XCI_SRCS  = $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.xci" ))

VHDL_SIM_PKGS  = $(shell (find $(ESP_ROOT)/sim/include -name "*.vhd" ))
VHDL_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.vhd" ))
VLOG_SIM_SRCS  = $(shell (find $(ESP_ROOT)/sim/src -name "*.v" ))

VHDL_PKGS = $(THIRDPARTY_VHDL_PKGS) $(VHDL_RTL_PKGS) $(VHDL_SIM_PKGS) $(TOP_VHDL_RTL_PKGS) $(TOP_VHDL_SIM_PKGS)
VHDL_SRCS = $(THIRDPARTY_VHDL) $(VHDL_RTL_SRCS) $(VHDL_SIM_SRCS) $(TOP_VHDL_RTL_SRCS) $(TOP_VHDL_SIM_SRCS)
VLOG_SRCS = $(THIRDPARTY_VLOG) $(VLOG_RTL_SRCS) $(VLOG_SIM_SRCS) $(TOP_VLOG_RTL_SRCS) $(TOP_VLOG_SIM_SRCS)
SVLOG_SRCS = $(THIRDPARTY_SVLOG) $(SVLOG_RTL_SRCS)

VHDL_SYN_PKGS = $(THIRDPARTY_VHDL_PKGS) $(VHDL_RTL_PKGS) $(TOP_VHDL_RTL_PKGS)
VHDL_SYN_SRCS = $(THIRDPARTY_VHDL) $(VHDL_RTL_SRCS) $(TOP_VHDL_RTL_SRCS)
VLOG_SYN_SRCS = $(THIRDPARTY_VLOG) $(VLOG_SYN_RTL_SRCS) $(TOP_VLOG_RTL_SRCS)
SVLOG_SYN_SRCS = $(THIRDPARTY_SVLOG) $(SVLOG_RTL_SRCS)


DAT_SRCS = $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.dat" ))

ALL_SRCS  = $(VHDL_PKGS) $(VHDL_SRCS) $(VLOG_SRCS) $(SVLOG_SRCS) $(DAT_SRCS)

VHDL_ALL_RTL = $(THIRDPARTY_VHDL_PKGS) $(VHDL_RTL_PKGS) $(TOP_VHDL_RTL_PKGS) $(THIRDPARTY_VHDL) $(VHDL_RTL_SRCS) $(TOP_VHDL_RTL_SRCS)
VLOG_ALL_RTL = $(THIRDPARTY_VLOG) $(VLOG_RTL_SRCS) $(TOP_VLOG_RTL_SRCS)
SVLOG_ALL_RTL = $(THIRDPARTY_SVLOG) $(SVLOG_SRCS)

ALL_RTL_SRCS  = $(VHDL_ALL_RTL) $(VLOG_ALL_RTL) $(SVLOG_ALL_RTL) $(DAT_SRCS)

check_all_srcs: grlib_config.vhd socmap.vhd sldgen plic_regmap.sv
	@echo $(ALL_SRCS) > $@.new; \
	if test -f $@.old; then \
		/usr/bin/diff -q $@.old $@.new > /dev/null; \
		if [ $$? -eq 0 ]; then \
			rm $@.new; \
		else \
			rm -rf modelsim/work; \
			rm -rf modelsim/vsim.mk; \
			mv $@.new $@.old; \
		fi; \
	else \
		rm -rf modelsim/work; \
		rm -rf modelsim/vsim.mk; \
		mv $@.new $@.old; \
	fi;

check_all_srcs-distclean:
	$(QUIET_CLEAN)rm -rf check_all_srcs.old

.PHONY: check_all_srcs check_all_srcs-distclean

check_all_rtl_srcs: grlib_config.vhd socmap.vhd sldgen plic_regmap.sv
	@echo $(ALL_RTL_SRCS) > $@.new; \
	if test -f $@.old; then \
		/usr/bin/diff -q $@.old $@.new > /dev/null; \
		if [ $$? -eq 0 ]; then \
			rm $@.new; \
		else \
			mv $@.new $@.old; \
		fi; \
	else \
		mv $@.new $@.old; \
	fi;

check_all_rtl_srcs-distclean:
	$(QUIET_CLEAN)rm -rf check_all_rtl_srcs.old

.PHONY: check_all_rtl_srcs check_all_rtl_srcs-distclean
