# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


### Include paths ###
INCDIR += $(DESIGN_PATH)
INCDIR += $(THIRDPARTY_INCDIR)
INCDIR += $(ESP_ROOT)/rtl/caches/esp-caches/common/defs

## VHDL Packages
SIM_VHDL_PKGS += $(SOCKETGEN_VHDL_RTL_PKGS)
SIM_VHDL_PKGS += $(foreach f, $(shell strings $(FLISTS)/vhdl_pkgs.flist), $(ESP_ROOT)/rtl/$(f))
SIM_VHDL_PKGS += $(THIRDPARTY_VHDL_PKGS)
SIM_VHDL_PKGS += $(TOP_VHDL_RTL_PKGS) $(TOP_VHDL_SIM_PKGS)

VHDL_PKGS += $(SOCKETGEN_VHDL_RTL_PKGS)
VHDL_PKGS += $(foreach f, $(shell strings $(FLISTS)/vhdl_pkgs.flist), $(if $(findstring rtl/sim, $(f)),, $(ESP_ROOT)/rtl/$(f)))
VHDL_PKGS += $(THIRDPARTY_VHDL_PKGS)
VHDL_PKGS += $(TOP_VHDL_RTL_PKGS)

## VHDL Source
VHDL_SRCS += $(foreach f, $(shell strings $(FLISTS)/vhdl.flist), $(ESP_ROOT)/rtl/$(f))
VHDL_SRCS += $(foreach f, $(shell strings $(FLISTS)/cores_vhdl.flist), $(if $(findstring cores/$(CPU_ARCH), $(f)), $(ESP_ROOT)/rtl/$(f),))
VHDL_SRCS += $(foreach f, $(shell strings $(FLISTS)/techmap_vhdl.flist), $(if $(findstring techmap/$(TECHLIB), $(f)), $(ESP_ROOT)/rtl/$(f),))
VHDL_SRCS += $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.vhd" ))
VHDL_SRCS += $(THIRDPARTY_VHDL)
VHDL_SRCS += $(TOP_VHDL_RTL_SRCS)

SIM_VHDL_SRCS += $(VHDL_SRCS)
SIM_VHDL_SRCS += $(foreach f, $(shell strings $(FLISTS)/sim_vhdl.flist), $(ESP_ROOT)/rtl/$(f))
SIM_VHDL_SRCS += $(TOP_VHDL_SIM_SRCS)

## Verilog Source
RTL_TECH_FOLDERS = $(shell ls -d $(ESP_ROOT)/tech/$(TECHLIB)/*/)

VLOG_SRCS += $(foreach f, $(shell strings $(FLISTS)/vlog.flist), $(ESP_ROOT)/rtl/$(f))
VLOG_SRCS += $(foreach f, $(shell strings $(FLISTS)/cores_vlog.flist), $(if $(findstring cores/$(CPU_ARCH), $(f)), $(ESP_ROOT)/rtl/$(f),))
VLOG_SRCS += $(foreach f, $(shell strings $(FLISTS)/techmap_vlog.flist), $(if $(findstring techmap/$(TECHLIB), $(f)), $(ESP_ROOT)/rtl/$(f),))
VLOG_SRCS += $(foreach f, $(RTL_TECH_FOLDERS), $(shell (find $(f) -name "*.v")))
VLOG_SRCS += $(foreach f, $(RTL_TECH_FOLDERS), $(shell (find $(f) -name "*.sv")))
VLOG_SRCS += $(THIRDPARTY_VLOG) $(THIRDPARTY_SVLOG)
VLOG_SRCS += $(TOP_VLOG_RTL_SRCS)

SIM_VLOG_SRCS += $(VLOG_SRCS)
SIM_VLOG_SRCS += $(foreach f, $(shell strings $(FLISTS)/sim_vlog.flist), $(ESP_ROOT)/rtl/$(f))
SIM_VLOG_SRCS += $(shell (find $(ESP_ROOT)/rtl/sim/$(TECHLIB)/verilog/ -name "*.v" ))
SIM_VLOG_SRCS += $(shell (find $(ESP_ROOT)/rtl/sim/$(TECHLIB)/verilog/ -name "*.sv" ))
SIM_VLOG_SRCS += $(TOP_VLOG_SIM_SRCS)

## Vivado HLS generated files
IP_XCI_SRCS  = $(shell (find $(ESP_ROOT)/tech/$(TECHLIB) -name "*.xci" ))
DAT_SRCS = $(shell (find $(ESP_ROOT)/tech/$(TECHLIB)/ -name "*.dat" ))


### Check if files lists changed ###
ALL_SIM_SRCS  = $(SIM_VHDL_PKGS) $(SIM_VHDL_SRCS) $(SIM_VLOG_SRCS) $(IP_XCI_SRCS) $(DAT_SRCS)
ALL_RTL_SRCS  = $(VHDL_PKGS) $(VHDL_SRCS) $(VLOG_SRCS) $(IP_XCI_SRCS) $(DAT_SRCS)

check_all_srcs: grlib_config.vhd socmap.vhd socketgen plic_regmap.sv
	@echo $(ALL_SIM_SRCS) > $@.new; \
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

check_all_rtl_srcs: grlib_config.vhd socmap.vhd socketgen plic_regmap.sv
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
