# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Paths shortcuts ###
UTILS_GRLIB = $(ESP_ROOT)/soft/leon3/grlib
TKCONFIG   = $(ESP_ROOT)/utils/grlib_tkconfig

GRLIB_DEFCONFIG ?= $(ESP_ROOT)/socs/defconfig/grlib_defconfig

TKCONFIG_DEP   = $(TKCONFIG)/config.vhd
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.vhd)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.h)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.help)
TKCONFIG_DEP  += $(TKCONFIG)/grlib_config.in

$(GRLIB_CFG_BUILD)/.grlib_config:
	$(QUIET_MKDIR)mkdir -p $(GRLIB_CFG_BUILD)
	$(QUIET_CP)cp $(GRLIB_DEFCONFIG) $@

grlib-defconfig: $(GRLIB_DEFCONFIG)
	$(QUIET_CP)cp $< $(GRLIB_CFG_BUILD)/.grlib_config
	$(QUIET_MAKE) \
	cd $(GRLIB_CFG_BUILD); \
	$(MAKE) grlib_config.vhd

.PHONY: grlib-defconfig

$(GRLIB_CFG_BUILD)/tkparse.o: $(TKCONFIG)/tkparse.c
	$(QUIET_CC)$(CC) -g -c $< -o $@

$(GRLIB_CFG_BUILD)/tkcond.o: $(TKCONFIG)/tkcond.c
	$(QUIET_CC)$(CC) -g -c $< -o $@

$(GRLIB_CFG_BUILD)/tkgen.o: $(TKCONFIG)/tkgen.c
	$(QUIET_CC)$(CC) -g -c $< -o $@

$(GRLIB_CFG_BUILD)/tkparse: $(GRLIB_CFG_BUILD)/tkparse.o $(GRLIB_CFG_BUILD)/tkcond.o $(GRLIB_CFG_BUILD)/tkgen.o
	$(QUIET_LINK)$(CC) -g $(GRLIB_CFG_BUILD)/tkparse.o $(GRLIB_CFG_BUILD)/tkcond.o $(GRLIB_CFG_BUILD)/tkgen.o -o $@

$(GRLIB_CFG_BUILD)/main.tk: $(GRLIB_CFG_BUILD)/tkparse $(TKCONFIG)/grlib_config.in $(TKCONFIG_DEP)
	$(QUIET_BUILD) \
	cd $(GRLIB_CFG_BUILD); \
	./tkparse $(TKCONFIG)/grlib_config.in $(TKCONFIG)/in > main.tk

$(GRLIB_CFG_BUILD)/lconfig.tk: $(GRLIB_CFG_BUILD)/main.tk $(TKCONFIG_DEP) $(TKCONFIG)/grlib_config.in
	$(QUIET_BUILD)cat $(TKCONFIG)/header.tk $< $(TKCONFIG)/tail.tk > $@
	$(QUIET_CHMOD)chmod a+x $(GRLIB_CFG_BUILD)/lconfig.tk

$(GRLIB_CFG_BUILD)/grlib_config.vhd: $(GRLIB_CFG_BUILD)/.grlib_config $(GRLIB_CFG_BUILD)/lconfig.tk
	$(QUIET_DIFF)echo "checking .grlib_config..."
	@cd $(GRLIB_CFG_BUILD); \
	/usr/bin/diff .grlib_config $(GRLIB_DEFCONFIG) -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for GRLIB"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".grlib_config\" for GRLIB"; \
	fi
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@cd $(GRLIB_CFG_BUILD); \
	unset LD_LIBRARY_PATH ; \
	xvfb-run -a wish -f lconfig.tk -regen; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-xconfig: $(GRLIB_CFG_BUILD)/lconfig.tk
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@cd $(GRLIB_CFG_BUILD); \
	unset LD_LIBRARY_PATH ; \
	wish -f lconfig.tk; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-config-clean:
	$(QUIET_CLEAN) $(RM)       \
		$(GRLIB_CFG_BUILD)/tkparse.o          \
		$(GRLIB_CFG_BUILD)/tkcond.o           \
		$(GRLIB_CFG_BUILD)/tkgen.o            \
		$(GRLIB_CFG_BUILD)/tkparse            \
		$(GRLIB_CFG_BUILD)/main.tk            \
		$(GRLIB_CFG_BUILD)/grlib_config.h     \
		$(GRLIB_CFG_BUILD)/grlib_config.help  \
		$(GRLIB_CFG_BUILD)/grlib_config.vhd.h \
		$(GRLIB_CFG_BUILD)/.grlib_config.old

grlib-config-distclean: grlib-config-clean
	$(QUIET_CLEAN)$(RM) $(GRLIB_CFG_BUILD)

.PHONY: grlib-xconfig grlib-config-clean grlib-config-distclean
