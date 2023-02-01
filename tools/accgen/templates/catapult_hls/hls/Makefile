#Copyright (c) 2011-2023 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

CATAPULT_PRODUCT = ultra

include ../../../common/common.mk

all: hls
.PHONY: all

hls:
	catapult -product $(CATAPULT_PRODUCT) -shell -f ./build_prj_top.tcl &
.PHONY: hls

sim:
	catapult -product $(CATAPULT_PRODUCT) -shell -f ./rtl_sim.tcl &


SHELL = /bin/bash
install:
	@mkdir -p $(RTL_OUT)
ifneq ("$(TARGET_NAME)","")
	@NAME_SHORT=$(TARGET_NAME:_catapult=); \
	cp ../$$NAME_SHORT.xml $(RTL_OUT)/$(TARGET_NAME).xml; \
	for prj in $(TARGET_NAME)_*; do \
		if [[ $$prj == *".ccs"* ]]; then \
			continue; \
		fi; \
		PRJ_NAME=$$prj; \
		indir=$$prj/$(TARGET_NAME).v1; \
		infile=$$indir/concat_$(TARGET_NAME).v; \
		outdir=$(RTL_OUT)/$$PRJ_NAME; \
		outfile=$(RTL_OUT)/$$PRJ_NAME/$$PRJ_NAME.v; \
		mkdir -p $$outdir; \
		cp $$infile $$outfile; \
		sed -i "s/module $(TARGET_NAME)/module $$PRJ_NAME/g" $$outfile; \
		sed -i "s/Design Unit:    $(TARGET_NAME)/Design Unit:    $$PRJ_NAME/g" $$outfile; \
	done
endif
.PHONY: install

clean:
	rm -rf $(TARGET_NAME)*
	rm -rf catapult_cache*
	rm -f catapult.pinfo
	rm -f log_dir_data.txt
	rm -f log_dir_names.txt
	rm -f trace.vcd
	rm -f transcript
	rm -f catapult.log
	rm -f vsim_stacktrace.vstf
	rm -f design_checker_constraints.tcl
	rm -f design_checker_pre_build.tcl
.PHONY: clean

distclean: clean
	@rm -rf $(RTL_OUT)
.PHONY: distclean
