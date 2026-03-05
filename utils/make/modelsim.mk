# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0


INCDIR_MODELSIM = $(foreach dir, $(INCDIR), +incdir+$(dir))

VCOMOPT +=
VCOMOPT += -suppress vcom-1491
VLOGOPT += -suppress 2275
VLOGOPT += -suppress 2583
VLOGOPT += -suppress 2892
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VLOGOPT += +define+XILINX_FPGA
endif
VLOGOPT += $(INCDIR_MODELSIM)

VSIMOPT += -suppress 3812
VSIMOPT += -suppress 2697
VSIMOPT += -suppress 8617
VSIMOPT += -suppress 151
VSIMOPT += -suppress 143
VSIMOPT += -suppress 8386
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
VSIMOPT += -L secureip_ver -L unisims_ver
endif
VSIMOPT += -uvmcontrol=disable -suppress 3009,2685,2718 -t fs
VSIMOPT += +notimingchecks
VSIMOPT += $(SIMTOP) $(EXTRA_SIMTOP)

SIM_LIBDIR ?= $(abspath $(RTL_CFG_BUILD)/sim_libs)

ACC_TECH_ROOT := $(ESP_ROOT)/tech/$(TECHLIB)/acc
ACC_TECH_PRESENT := $(filter-out common,$(filter $(notdir $(wildcard $(ACC_TECH_ROOT)/*)),$(RTL_ACC)))
THIRDPARTY_LIBS = $(THIRDPARTY_ACC)
ACC_LIBS := $(ACC_TECH_PRESENT) $(THIRDPARTY_LIBS)
ACC_LIB_OPT := $(foreach lib,$(ACC_LIBS),-L $(lib))
THIRDPARTY_SIM_VHDL_PKGS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VHDL_PKGS))
THIRDPARTY_SIM_VHDL_SRCS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VHDL_SRCS))
THIRDPARTY_SIM_VLOG_SRCS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VLOG_SRCS))

SIM_VHDL_PKGS_ALL := $(SIM_VHDL_PKGS)
SIM_VHDL_SRCS_ALL := $(SIM_VHDL_SRCS)
SIM_VLOG_SRCS_ALL := $(SIM_VLOG_SRCS)
ifneq ($(ACC_TECH_PRESENT)$(THIRDPARTY_LIBS),)
SIM_VHDL_PKGS := $(filter-out $(THIRDPARTY_SIM_VHDL_PKGS),$(SIM_VHDL_PKGS))
SIM_VHDL_SRCS := $(filter-out $(THIRDPARTY_SIM_VHDL_SRCS),$(SIM_VHDL_SRCS))
SIM_VLOG_SRCS := $(filter-out $(foreach acc,$(ACC_TECH_PRESENT),$(ACC_TECH_ROOT)/$(acc)/%) $(THIRDPARTY_SIM_VLOG_SRCS),$(SIM_VLOG_SRCS))
endif

VLIB = vlib
VCOM = vcom -quiet -93 $(VCOMOPT)
VLOG = vlog -sv -quiet $(VLOGOPT)
VSIM = VSIMOPT='$(VSIMOPT)' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT)

VSIMOPT += -L work $(ACC_LIB_OPT)

define DEFINE_MODELSIM_ACC
ACC_$(1)_NAME := $(1)
ACC_$(1)_LIB := $(1)
ACC_$(1)_SRC_BASE := $(ESP_ROOT)/accelerators/rtl/$(1)
ACC_$(1)_TECH_DIR := $(ACC_TECH_ROOT)/$(1)
ACC_$(1)_VENDOR_PKG_DIR := $$(ACC_$(1)_SRC_BASE)/vlog_incdir
ACC_$(1)_FILELIST_SV = $$(ACC_$(1)_SRC_BASE)/$(1).sverilog
ACC_$(1)_FILELIST_V = $$(ACC_$(1)_SRC_BASE)/$(1).verilog
ACC_$(1)_TECH_FILELIST_SV = $$(ACC_$(1)_TECH_DIR)/$(1).sverilog
ACC_$(1)_TECH_FILELIST_V = $$(ACC_$(1)_TECH_DIR)/$(1).verilog
endef
$(foreach acc,$(ACC_TECH_PRESENT),$(eval $(call DEFINE_MODELSIM_ACC,$(acc))))

define DEFINE_MODELSIM_THIRDPARTY
TP_$(1)_NAME := $(1)
TP_$(1)_LIB := $(1)
TP_$(1)_SRC := $(ESP_ROOT)/accelerators/third-party/$(1)
TP_$(1)_VHDL_PKGS := $$(TP_$(1)_SRC)/$(1).pkgs
TP_$(1)_VHDL_SRCS := $$(TP_$(1)_SRC)/$(1).vhdl
TP_$(1)_FILELIST_SV := $$(TP_$(1)_SRC)/$(1).sverilog
TP_$(1)_FILELIST_V := $$(TP_$(1)_SRC)/$(1).verilog
TP_$(1)_WRAPPER := $$(TP_$(1)_SRC)/$(1)_wrapper.v
TP_$(1)_INCDIR := $$(TP_$(1)_SRC)/vlog_incdir
endef
$(foreach acc,$(THIRDPARTY_LIBS),$(eval $(call DEFINE_MODELSIM_THIRDPARTY,$(acc))))

MODELSIM_ACC_LIB_TARGETS := $(foreach acc,$(ACC_TECH_PRESENT),modelsim-accel-$(acc))
MODELSIM_THIRDPARTY_LIB_TARGETS := $(foreach acc,$(THIRDPARTY_LIBS),modelsim-thirdparty-$(acc))

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

$(SIM_LIBDIR):
	$(QUIET_MKDIR)mkdir -p $@

modelsim-libs: modelsim/modelsim.ini $(SIM_LIBDIR)
	@cd modelsim; \
	for lib in $(ACC_LIBS); do \
		if test -n "$$lib"; then \
			if ! test -e $(SIM_LIBDIR)/$$lib; then \
				vlib -type directory $(SIM_LIBDIR)/$$lib; \
			fi; \
			vmap $$lib $(SIM_LIBDIR)/$$lib; \
		fi; \
	done

define MODELSIM_ACC_LIB_RULE
modelsim-accel-$(1): modelsim-libs $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	cd modelsim; \
	if ! test -e $(SIM_LIBDIR)/$$(ACC_$(1)_LIB); then \
		vlib -type directory $(SIM_LIBDIR)/$$(ACC_$(1)_LIB); \
	fi; \
	vmap $$(ACC_$(1)_LIB) $(SIM_LIBDIR)/$$(ACC_$(1)_LIB); \
	\
	rm -f $$(ACC_$(1)_LIB).rtl.f; \
	for opt in $(ACC_MODELSIM_DEFS) $(ACC_MODELSIM_VLOGOPT); do \
		echo "$$$$opt" >> $$(ACC_$(1)_LIB).rtl.f; \
	done; \
	if test -d "$$(ACC_$(1)_VENDOR_PKG_DIR)"; then \
		find -L "$$(ACC_$(1)_VENDOR_PKG_DIR)" -type d | sort | while read dir; do \
			echo "+incdir+$$$$dir" >> $$(ACC_$(1)_LIB).rtl.f; \
		done; \
		find -L "$$(ACC_$(1)_VENDOR_PKG_DIR)" -type f -name "*.sv" >> $$(ACC_$(1)_LIB).rtl.f; \
	fi; \
	if test -f "$$(ACC_$(1)_FILELIST_SV)"; then \
		awk -v base="$$(ACC_$(1)_SRC_BASE)/vendor/" 'BEGIN{FS=" "} /^[[:space:]]*$$$$/ || /^[[:space:]]*#/{print;next} /^[[:space:]]*\+incdir\+/{sub(/^[[:space:]]*\+incdir\+/,"");if(/^\//)print "+incdir+" $$$$0;else print "+incdir+" base $$$$0;next} /^[[:space:]]*\//{sub(/^[[:space:]]*/,"");print;next} {sub(/^[[:space:]]*/,"");print base $$$$0}' "$$(ACC_$(1)_FILELIST_SV)" >> $$(ACC_$(1)_LIB).rtl.f; \
	fi; \
	if test -f "$$(ACC_$(1)_FILELIST_V)"; then \
		awk -v base="$$(ACC_$(1)_SRC_BASE)/vendor/" 'BEGIN{FS=" "} /^[[:space:]]*$$$$/ || /^[[:space:]]*#/{print;next} /^[[:space:]]*\+incdir\+/{sub(/^[[:space:]]*\+incdir\+/,"");if(/^\//)print "+incdir+" $$$$0;else print "+incdir+" base $$$$0;next} /^[[:space:]]*\//{sub(/^[[:space:]]*/,"");print;next} {sub(/^[[:space:]]*/,"");print base $$$$0}' "$$(ACC_$(1)_FILELIST_V)" >> $$(ACC_$(1)_LIB).rtl.f; \
	fi; \
	if test -d "$$(ACC_$(1)_TECH_DIR)"; then \
		find -L "$$(ACC_$(1)_TECH_DIR)" -type f \( -name "*.sv" -o -name "*.v" \) | sort >> $$(ACC_$(1)_LIB).rtl.f; \
	fi; \
	\
	if test -s $$(ACC_$(1)_LIB).rtl.f; then \
		echo $(SPACES)"vlog -sv -quiet $(filter-out +incdir+%,$(VLOGOPT)) -work $$(ACC_$(1)_LIB) -f $$(ACC_$(1)_LIB).rtl.f"; \
		vlog -sv -quiet $(filter-out +incdir+%,$(VLOGOPT)) -work $$(ACC_$(1)_LIB) -f $$(ACC_$(1)_LIB).rtl.f || exit 1; \
	fi
endef
$(foreach acc,$(ACC_TECH_PRESENT),$(eval $(call MODELSIM_ACC_LIB_RULE,$(acc))))

define MODELSIM_THIRDPARTY_LIB_RULE
modelsim-thirdparty-$(1): modelsim-libs $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	cd modelsim; \
	if ! test -e $(SIM_LIBDIR)/$$(TP_$(1)_LIB); then \
		vlib -type directory $(SIM_LIBDIR)/$$(TP_$(1)_LIB); \
	fi; \
	vmap $$(TP_$(1)_LIB) $(SIM_LIBDIR)/$$(TP_$(1)_LIB); \
	\
	for vhdf in "$$(TP_$(1)_VHDL_PKGS)" "$$(TP_$(1)_VHDL_SRCS)"; do \
		if test -f "$$$$vhdf"; then \
			awk -v base="$$(TP_$(1)_SRC)/out/" 'function trim(s){sub(/^[ \t]+/,"",s); sub(/[ \t]+$$$$/,"",s); return s} {line=$$$$0; gsub(/\r/,"",line); line=trim(line); if(line=="" || line ~ /^#/ || line ~ /^\/\// || line ~ /^--/) next; if(line ~ /^\//) print line; else print base line}' "$$$$vhdf" | while read rtl; do \
				echo $(SPACES)"$(VCOM) -work $$(TP_$(1)_LIB) $$$$rtl"; \
				$(VCOM) -work $$(TP_$(1)_LIB) $$$$rtl || exit 1; \
			done; \
		fi; \
	done; \
	\
	rm -f $$(TP_$(1)_LIB).rtl.f; \
	if test -f "$$(TP_$(1)_WRAPPER)"; then \
		echo "$$(TP_$(1)_WRAPPER)" >> $$(TP_$(1)_LIB).rtl.f; \
	fi; \
	if test -d "$$(TP_$(1)_INCDIR)"; then \
		find -L "$$(TP_$(1)_INCDIR)" -type d | sort | while read dir; do \
			echo "+incdir+$$$$dir" >> $$(TP_$(1)_LIB).rtl.f; \
		done; \
	fi; \
	if test -f "$$(TP_$(1)_FILELIST_SV)"; then \
		awk -v base="$$(TP_$(1)_SRC)/out/" 'function trim(s){sub(/^[ \t]+/,"",s); sub(/[ \t]+$$$$/,"",s); return s} {line=$$$$0; gsub(/\r/,"",line); line=trim(line); if(line=="" || line ~ /^#/ || line ~ /^\/\// || line ~ /^--/) next; if(line ~ /^[+]incdir[+]/){sub(/^[+]incdir[+]/,"",line); n=split(line,a,/[+]/); for(i=1;i<=n;i++){if(a[i]=="") continue; if(a[i] ~ /^\//) print "+incdir+" a[i]; else print "+incdir+" base a[i];} next} if(line ~ /^\//){print line; next} print base line}' "$$(TP_$(1)_FILELIST_SV)" >> $$(TP_$(1)_LIB).rtl.f; \
	fi; \
	if test -f "$$(TP_$(1)_FILELIST_V)"; then \
		awk -v base="$$(TP_$(1)_SRC)/out/" 'function trim(s){sub(/^[ \t]+/,"",s); sub(/[ \t]+$$$$/,"",s); return s} {line=$$$$0; gsub(/\r/,"",line); line=trim(line); if(line=="" || line ~ /^#/ || line ~ /^\/\// || line ~ /^--/) next; if(line ~ /^[+]incdir[+]/){sub(/^[+]incdir[+]/,"",line); n=split(line,a,/[+]/); for(i=1;i<=n;i++){if(a[i]=="") continue; if(a[i] ~ /^\//) print "+incdir+" a[i]; else print "+incdir+" base a[i];} next} if(line ~ /^\//){print line; next} print base line}' "$$(TP_$(1)_FILELIST_V)" >> $$(TP_$(1)_LIB).rtl.f; \
	fi; \
	\
	if test -s $$(TP_$(1)_LIB).rtl.f; then \
		echo $(SPACES)"vlog -sv -quiet $(filter-out +incdir+%,$(VLOGOPT)) -work $$(TP_$(1)_LIB) -f $$(TP_$(1)_LIB).rtl.f"; \
		vlog -sv -quiet $(filter-out +incdir+%,$(VLOGOPT)) -work $$(TP_$(1)_LIB) -f $$(TP_$(1)_LIB).rtl.f || exit 1; \
	fi
endef
$(foreach acc,$(THIRDPARTY_LIBS),$(eval $(call MODELSIM_THIRDPARTY_LIB_RULE,$(acc))))

modelsim/modelsim.ini: $(ESP_ROOT)/.cache/modelsim/xilinx_lib
	$(QUIET_MAKE)mkdir -p modelsim
	@cp $(ESP_ROOT)/.cache/modelsim/modelsim.ini $@


### Compile simulation source files ###
# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
modelsim/vsim.mk: modelsim/modelsim.ini $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST) modelsim-libs $(MODELSIM_ACC_LIB_TARGETS) $(MODELSIM_THIRDPARTY_LIB_TARGETS)
	@cd modelsim; \
	if ! test -e profpga; then \
		vlib -type directory profpga; \
		$(SPACING)vmap profpga profpga; \
	fi;
ifneq ($(findstring profpga, $(BOARD)),)
	@cd modelsim; \
	echo $(SPACES)"### Compile proFPGA source files ###"; \
	for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo $(SPACES)"$(VCOM) -work profpga $$rtl"; \
		$(VCOM) -work profpga $$rtl || exit; \
	done; \
	for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo $(SPACES)"$(VLOG) -work profpga"; \
		$(VLOG) -work profpga $$rtl || exit; \
	done;
endif
	@cd modelsim; \
	if ! test -e work; then \
		vlib -type directory work; \
		$(SPACING)vmap work work; \
	fi; \
	echo $(SPACES)"### Compile VHDL packages ###"; \
	for rtl in $(SIM_VHDL_PKGS); do \
		echo $(SPACES)"$(VCOM) -work work $$rtl"; \
		$(VCOM) -work work $$rtl || exit; \
	done; \
	echo $(SPACES)"### Compile VHDL source files ###"; \
		for rtl in $(SIM_VHDL_SRCS); do \
			echo $(SPACES)"$(VCOM) -work work $$rtl"; \
			$(VCOM) -work work $$rtl || exit; \
		done; \
	echo $(SPACES)"### Compile Verilog source files ###"; \
		for rtl in $(SIM_VLOG_SRCS); do \
			echo $(SPACES)"$(VLOG) -work work $$rtl"; \
			$(VLOG) -work work $$rtl || exit; \
		done;
ifneq ("$(wildcard $(ESP_ROOT)/rtl/peripherals/bsg/.git)", "")
	@echo $(SPACES)"### Compile BSG Verilog source files ###";
	@$(MAKE) bsg-sim-compile
endif
	@cd modelsim; \
	echo $(SPACES)"vmake > vsim.mk"; \
	vmake 2> /dev/null > vsim.mk; \
	cd ../;

sim-compile: socketgen check_all_srcs modelsim/vsim.mk soft iolink-txt-files
	@for dat in $(DAT_SRCS); do \
		cp $$dat modelsim; \
	done;
	$(QUIET_MAKE)make -C modelsim -f vsim.mk
	@cd modelsim; \
	rm -f prom.srec ram.srec; \
	ln -s $(SOFT_BUILD)/prom.srec; \
	ln -s $(SOFT_BUILD)/ram.srec;

sim: sim-compile
	$(QUIET_RUN)cd modelsim; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		$(VSIM) -c -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM) -c; \
	fi;

sim-gui: sim-compile
	$(QUIET_RUN)cd modelsim; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		$(VSIM) -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM); \
	fi;

sim-clean:
	$(QUIET_CLEAN)rm -rf transcript *.wlf

sim-distclean: sim-clean
	$(QUIET_CLEAN)rm -rf modelsim

.PHONY: sim sim-gui sim-compile sim-clean sim-distclean modelsim-libs $(MODELSIM_ACC_LIB_TARGETS) $(MODELSIM_THIRDPARTY_LIB_TARGETS)



### JTAG trace-based simulation (Modelsim only)
JTAG_TEST_SCRIPTS_DIR = $(ESP_ROOT)/utils/scripts/jtag_test
JTAG_TEST_TILE ?= 0

jtag-trace: sim-compile
	$(QUIET_RUN)cd modelsim; \
	mkdir -p jtag; \
	if test -e $(DESIGN_PATH)/vsim.tcl; then \
		VSIMOPT='$(VSIMOPT) -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT) -do "do $(DESIGN_PATH)/vsim.tcl"; \
	else \
		$(VSIM) -do "do $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_gettrace.tcl"; \
	fi; \
	cd jtag; \
	$(JTAG_TEST_SCRIPTS_DIR)/jtag_test_format.sh; \
	LD_LIBRARY_PATH="" $(JTAG_TEST_SCRIPTS_DIR)/jtag_test_stim.py $(JTAG_TEST_TILE)

sim-jtag: sim-compile
	$(QUIET_RUN)if test -e $(DESIGN_PATH)/modelsim/jtag/stim.txt; then \
	cd modelsim; \
		if test -e $(DESIGN_PATH)/vsim.tcl; then \
			VSIMOPT='$(VSIMOPT) -g JTAG_TRACE=$(JTAG_TEST_TILE)' TECHLIB=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) vsim $(VSIMOPT) -do "do $(DESIGN_PATH)/vsim.tcl"; \
		else \
			$(VSIM) -g JTAG_TRACE=$(JTAG_TEST_TILE); \
		fi; \
	else \
		echo "Run make jtag-trace to generate stimulus file"; \
	fi;

jtag-clean:
	$(QUIET_CLEAN)$(RM) \
		modelsim/jtag/stim*_*.txt \
		modelsim/jtag/*.lst

jtag-distclean: jtag-clean
	$(QUIET_CLEAN)$(RM) modelsim/jtag

.PHONY: jtag-trace jtag-trace-pretty jtag-stim jtag-clean jtag-distclean
