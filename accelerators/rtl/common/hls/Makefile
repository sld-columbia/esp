# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

COMMON_PATH = $(ESP_ROOT)/accelerators/rtl/common
COMMON_HLS_PATH = $(COMMON_PATH)/hls

include $(COMMON_PATH)/common.mk

install: 
	@mkdir -p $(RTL_OUT)
ifneq ("$(ACCELERATOR)","")
	@NAME_SHORT=$(TARGET_NAME:_rtl=); \
	cp ../$$NAME_SHORT.xml $(RTL_OUT)/$(TARGET_NAME).xml;
endif
	@NAME_SHORT=$(TARGET_NAME:_rtl=); \
	cp -r ../src/* $(RTL_OUT)

# Clean out undesirable junk files from the project directory
# Uses the automatically created clean_all target from Makefile.prj
clean:

CLEAN: clean

distclean: clean
	@rm -rf $(RTL_OUT)

.PHONY: install clean CLEAN distclean
