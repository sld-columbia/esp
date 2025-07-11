#Copyright (c) 2011-2025 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

CATAPULT_PRODUCT = ultra
export DMA_WIDTH = 64 #set to target DMA used when running the top level
export ACCELERATOR = DUMMY
export TECH_PATH = DUMMY
export MEMTECH_PATH = DUMMY
export ESP_ROOT = ../../../../../../
export TECH = virtex7

all: hls
.PHONY: all

hls:
	catapult -product $(CATAPULT_PRODUCT) -shell -f ./build_prj_top.tcl &
.PHONY: hls

clean:
	rm -rf $(TARGET_NAME)*
	rm -rf catapult_cache*
	rm -f catapult.pinfo
	rm -f trace.vcd
	rm -f transcript
	rm -f catapult.log
	rm -f vsim_stacktrace.vstf
.PHONY: clean

distclean: clean
	@rm -rf $(RTL_OUT)
.PHONY: distclean
