# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

QCOMOPT = $(VCOMOPT)
QLOGOPT = $(VLOGOPT)
QSIMOPT = $(VSIMOPT)

SIM_LIBDIR ?= $(abspath $(RTL_CFG_BUILD)/sim_libs)

ACC_TECH_ROOT := $(ESP_ROOT)/tech/$(TECHLIB)/acc
ACC_TECH_PRESENT := $(filter-out common,$(filter $(notdir $(wildcard $(ACC_TECH_ROOT)/*)),$(RTL_ACC)))
THIRDPARTY_LIBS = $(THIRDPARTY_ACC)
ACC_LIBS := $(THIRDPARTY_LIBS)
ACC_LIB_OPT := $(foreach lib,$(ACC_LIBS),-L $(lib))
THIRDPARTY_SIM_VHDL_PKGS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VHDL_PKGS))
THIRDPARTY_SIM_VHDL_SRCS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VHDL_SRCS))
THIRDPARTY_SIM_VLOG_SRCS := $(filter $(THIRDPARTY_PATH)/%,$(SIM_VLOG_SRCS))

ifneq ($(THIRDPARTY_LIBS),)
SIM_VHDL_PKGS := $(filter-out $(THIRDPARTY_SIM_VHDL_PKGS),$(SIM_VHDL_PKGS))
SIM_VHDL_SRCS := $(filter-out $(THIRDPARTY_SIM_VHDL_SRCS),$(SIM_VHDL_SRCS))
SIM_VLOG_SRCS := $(filter-out $(THIRDPARTY_SIM_VLOG_SRCS),$(SIM_VLOG_SRCS))
endif

QSIMOPT += -L work $(ACC_LIB_OPT)

QLIB = vlib
QCOM = vcom -quiet -93 $(QCOMOPT)
QLOG = vlog -sv -quiet $(QLOGOPT)
QSIM = vsim $(QSIMOPT)

define DEFINE_QUESTA_THIRDPARTY
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
$(foreach acc,$(THIRDPARTY_LIBS),$(eval $(call DEFINE_QUESTA_THIRDPARTY,$(acc))))

QUESTA_THIRDPARTY_LIB_TARGETS := $(foreach acc,$(THIRDPARTY_LIBS),questa-thirdparty-$(acc))

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

$(SIM_LIBDIR):
	$(QUIET_MKDIR)mkdir -p $@

questa-libs: questa/modelsim.ini $(SIM_LIBDIR)
	@cd questa; \
	for lib in $(ACC_LIBS); do \
		if test -n "$$lib"; then \
			if ! test -e $(SIM_LIBDIR)/$$lib; then \
				vlib -type directory $(SIM_LIBDIR)/$$lib; \
			fi; \
			vmap $$lib $(SIM_LIBDIR)/$$lib; \
		fi; \
	done

define QUESTA_THIRDPARTY_LIB_RULE
questa-thirdparty-$(1): questa-libs $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST)
	cd questa; \
	if ! test -e $(SIM_LIBDIR)/$$(TP_$(1)_LIB); then \
		vlib -type directory $(SIM_LIBDIR)/$$(TP_$(1)_LIB); \
	fi; \
	vmap $$(TP_$(1)_LIB) $(SIM_LIBDIR)/$$(TP_$(1)_LIB); \
	\
	for vhdf in "$$(TP_$(1)_VHDL_PKGS)" "$$(TP_$(1)_VHDL_SRCS)"; do \
		if test -f "$$$$vhdf"; then \
			awk -v base="$$(TP_$(1)_SRC)/out/" 'function trim(s){sub(/^[ \t]+/,"",s); sub(/[ \t]+$$$$/,"",s); return s} {line=$$$$0; gsub(/\r/,"",line); line=trim(line); if(line=="" || line ~ /^#/ || line ~ /^\/\// || line ~ /^--/) next; if(line ~ /^\//) print line; else print base line}' "$$$$vhdf" | while read rtl; do \
				echo $(SPACES)"$(QCOM) -work $$(TP_$(1)_LIB) $$$$rtl"; \
				$(QCOM) -work $$(TP_$(1)_LIB) $$$$rtl || exit 1; \
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
$(foreach acc,$(THIRDPARTY_LIBS),$(eval $(call QUESTA_THIRDPARTY_LIB_RULE,$(acc))))


### Compile simulation source files ###
# Note that vmake fails to find unisim.vcomponents, however produces the correct
# makefile for future compilation and all components are properly bound in simulation.
# Please keep 2> /dev/null until the bug is fixed with a newer Modelsim release.
questa/vsim.mk: questa/modelsim.ini $(RTL_CFG_BUILD)/check_all_srcs.old $(PKG_LIST) questa-libs $(QUESTA_THIRDPARTY_LIB_TARGETS)
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

.PHONY: qsim qsim-gui qsim-compile qsim-clean qsim-distclean questa-libs $(QUESTA_THIRDPARTY_LIB_TARGETS)
