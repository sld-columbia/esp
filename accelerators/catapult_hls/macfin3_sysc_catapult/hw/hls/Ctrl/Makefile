#Copyright (c) 2011-2025 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

CATAPULT_PRODUCT = ultra
export DMA_WIDTH = 64 #set to target DMA used when running the top level
export ACCELERATOR = DUMMY
export TECH_PATH = DUMMY
export MEMTECH_PATH = DUMMY
export ESP_ROOT = ../../../../../../
export TECH = virtex7
# ESP_ROOT = ../../../../../../
# include ../../../../common/common.mk

all: hls
.PHONY: all

hls:
	catapult -product $(CATAPULT_PRODUCT) -f ./build_prj_top.tcl &
.PHONY: hls

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
