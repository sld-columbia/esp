# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

include ../../../common/common.mk

HLS_TCL=common.tcl

all: hls

hls: 
	@vivado_hls -f $(HLS_TCL)

install:
	@mkdir -p $(RTL_OUT)
ifneq ("$(TARGET_NAME)","")
	@NAME_SHORT=$(TARGET_NAME:_vivado=); \
	cp ../$$NAME_SHORT.xml $(RTL_OUT)/$(TARGET_NAME).xml; \
	for prj in $(TARGET_NAME)_*; do \
		echo $$prj; \
		PRJ_NAME=$$prj; \
		mkdir -p $(RTL_OUT)/$$PRJ_NAME; \
		cp $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/hdl/verilog/* $(RTL_OUT)/$$PRJ_NAME; \
		if [ -e $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/hdl/ip ]; then \
			if [ -z $(ls -A $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/hdl/ip) ]; then \
				cp $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/hdl/ip/* $(RTL_OUT)/$$PRJ_NAME; \
			fi; \
		fi; \
		if [ -e $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/tmp.srcs/sources_1/ip ]; then \
			for dir in $$(ls $$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/tmp.srcs/sources_1/ip); do \
				indir=$$PRJ_NAME/$(TARGET_NAME)_acc/impl/ip/tmp.srcs/sources_1/ip/$$dir; \
				infile=$$indir/*.xci; \
				cp $$infile $(RTL_OUT)/$$PRJ_NAME; \
			done; \
		fi; \
	done
endif

# Clean out undesirable junk files from the project directory
# Uses the automatically created clean_all target from Makefile.prj
clean:
	@rm -rf $(TARGET_NAME) *.log
	@rm -f transcript vsim* *.wlf data.out
	@rm -f *~ *.bak *.BAK
	@rm -rf work debussy* vfast*
	@rm -f msg_help.html
	@rm -rf core
	@rm -rf core.*
	@rm -rf .stack.*
	@rm -rf *irun.history*
	@rm -rf *.pro *.pro.user
	@rm -rf *.log
	@rm -rf *.shm
	@rm -rf *.diag
	@rm -rf *.key
	@rm -rf *.csv
	@rm -rf .simvision
	@rm -rf .Xil
	@rm -rf .fail*

distclean: clean
	@rm -rf $(RTL_OUT)

.PHONY: install clean distclean

