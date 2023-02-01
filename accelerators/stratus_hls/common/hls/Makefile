# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

COMMON_PATH = $(ESP_ROOT)/accelerators/stratus_hls/common
COMMON_HLS_PATH = $(COMMON_PATH)/hls

include $(COMMON_PATH)/common.mk

# list subdirectories that contain memory libraries
# (must be in subdirectories of the current directory)
MEMLIBS = ./memlib

# list subdirectories that contain interface libraries
# (must be in subdirectories of the current directory)
IFLIBS =

# Uncomment this line to use the Insight debugger
BDW_DEBUG = 1


saySimPassed:
	@bdw_sim_pass

# Disable timing checks
BDW_VLOGSIM_ARGS = -NOTIMINGCHECKS -UNBUFFERED

memlib: ../memlist.txt $(MEMGEN)
	@$(MEMGEN) $(MEMTECH) $< $(MEMGEN_OUT) | tee memgen.log
	@count=`ls -1 memlib/*.bdm 2>/dev/null | wc -l`; \
	if [ $$count != 0 ]; then \
		bdw_memgen ./memlib/*.bdm; \
	fi;

Makefile.prj: memlib project.tcl $(COMMON_HLS_PATH)/project.tcl
	@bdw_makegen

-include Makefile.prj

install: Makefile.prj hls_all
	@mkdir -p $(RTL_OUT)
ifneq ("$(ACCELERATOR)","")
	@NAME_SHORT=$(TARGET_NAME:_stratus=); \
	cp ../$$NAME_SHORT.xml $(RTL_OUT)/$(TARGET_NAME).xml;
endif
	@NAME_SHORT=$(TARGET_NAME:_stratus=); \
	for dir in $$(ls bdw_work/modules/$$NAME_SHORT); do \
		indir=bdw_work/modules/$$NAME_SHORT/$$dir; \
		infile=$$indir/$$NAME_SHORT\_rtl.v; \
		if test -e $$infile; then \
			cfg=$${dir,,}; \
			outdir=$(RTL_OUT)/$(TARGET_NAME)_$$cfg; \
			outfile=$$outdir/$(TARGET_NAME)_$$cfg.v; \
			mkdir -p $$outdir; \
			if [ $$infile -nt $$outfile ]; then \
				cp $$infile $$outfile; \
				rtl_parts=$$(rm -rf tmp-vsim; vlib tmp-vsim; vlog -work tmp-vsim -quiet $$infile; vsim -quiet -do "quit -f" -c tmp-vsim.$$NAME_SHORT > log 2> /dev/null; cat log | grep Error | grep "not defined" | cut -f 6 -d " " | sed "s/'//g" | uniq; rm -rf tmp-vsim log); \
				for p in $$rtl_parts; do \
					pfile=$$indir/v_rtl/$$p\.v; \
					if test -e $$pfile; then \
						cp $$pfile $$outdir; \
					fi; \
				done; \
				sed -i "s/module $$NAME_SHORT/module $(TARGET_NAME)_$$cfg/g" $$outfile; \
			fi; \
		fi; \
	done

nimbus.csv: Makefile.prj sim_all
	@bdw_shell $(COMMON_HLS_PATH)/nimbus.tcl
	@sed -i 's/_/\\_/g' $@

plot: nimbus.csv
	@octave -qf $(COMMON_HLS_PATH)/plot_results_octave.m $<

# Clean out undesirable junk files from the project directory
# Uses the automatically created clean_all target from Makefile.prj
clean: clean_all clean_libs
	@rm -f transcript vsim* *.wlf data.out
	@rm -f *~ *.bak *.BAK
	@rm -rf work debussy* vfast*
	@rm -f Makefile.prj
	@rm -f msg_help.html
	@rm -rf core
	@rm -rf core.*
	@rm -rf .stack.*
	@rm -rf *irun.history*
	@rm -rf *.pro *.pro.user
	@rm -rf INCA_libs
	@rm -rf *.log
	@rm -rf *.shm
	@rm -rf *.diag
	@rm -rf *.key
	@rm -rf memlib
	@rm -rf *.csv
	@rm -rf .simvision
	@rm -rf .Xil
	@rm -rf .fail*

CLEAN: clean

distclean: clean
	@rm -rf $(MEMGEN_OUT)
	@rm -rf $(RTL_OUT)

# WARNING: this target will delete generated resources for HLS
distclean-all: distclean
	@rm -rf cachelib

.PHONY: install plot  clean CLEAN distclean distclean-all
