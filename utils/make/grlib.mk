# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Paths shortcuts ###
UTILS_GRLIB = $(ESP_ROOT)/soft/leon3/grlib
TKCONFIG   = $(ESP_ROOT)/utils/grlib_tkconfig

GRLIB_DEFCONFIG ?= $(ESP_ROOT)/socs/defconfig/grlib_$(BOARD)_defconfig

TKCONFIG_DEP   = $(TKCONFIG)/config.vhd
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.vhd)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.h)
TKCONFIG_DEP  += $(wildcard $(TKCONFIG)/in/*.in.help)
TKCONFIG_DEP  += grlib_config.in

.grlib_config:
	$(QUIET_CP)cp $(GRLIB_DEFCONFIG) $@

grlib-defconfig: $(GRLIB_DEFCONFIG)
	$(QUIET_CP)cp $< .grlib_config
	$(QUIET_MAKE)$(MAKE) grlib_config.vhd

.PHONY: grlib-defconfig

tkparse.o: $(TKCONFIG)/tkparse.c
	$(QUIET_CC)$(CC) -g -c $<

tkcond.o: $(TKCONFIG)/tkcond.c
	$(QUIET_CC)$(CC) -g -c $<

tkgen.o: $(TKCONFIG)/tkgen.c
	$(QUIET_CC)$(CC) -g -c $<

tkparse: tkparse.o tkcond.o tkgen.o
	$(QUIET_LINK)$(CC) -g tkparse.o tkcond.o tkgen.o -o $@

main.tk: tkparse grlib_config.in $(TKCONFIG_DEP)
	$(QUIET_BUILD) ./$< grlib_config.in $(TKCONFIG)/in > $@

lconfig.tk: main.tk $(TKCONFIG_DEP) grlib_config.in
	$(QUIET_BUILD)cat $(TKCONFIG)/header.tk $< $(TKCONFIG)/tail.tk > $@
	$(QUIET_CHMOD)chmod a+x lconfig.tk

grlib_config.vhd: lconfig.tk .grlib_config
	$(QUIET_DIFF)echo "checking .grlib_config..."
	@/usr/bin/diff .grlib_config $(GRLIB_DEFCONFIG) -q > /dev/null; \
	if test $$? = "0"; then \
		echo $(SPACES)"INFO Using default configuration file for GRLIB"; \
	else \
		echo $(SPACES)"INFO Using custom configuration found in \".grlib_config\" for GRLIB"; \
	fi
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@unset LD_LIBRARY_PATH ; \
	xvfb-run -a wish -f lconfig.tk -regen; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-xconfig: lconfig.tk
	$(QUIET_RUN)
	$(QUIET_INFO)echo "Creating grlib_config.vhd";
	@unset LD_LIBRARY_PATH ; \
	wish -f lconfig.tk; \
	if test $$? = "2" ; then \
	   cpp -P -I$$PWD $(TKCONFIG)/config.vhd > grlib_config.vhd; \
	   echo $(SPACES)"INFO grlib_config.vhd written"; \
	fi

grlib-config-clean:
	$(QUIET_CLEAN)$(RM)        \
		tkparse.o          \
		tkcond.o           \
		tkgen.o            \
		tkparse            \
		main.tk            \
		grlib_config.h     \
		grlib_config.help  \
		grlib_config.vhd.h \
		.grlib_config.old

grlib-config-distclean: grlib-config-clean
	$(QUIET_CLEAN)$(RM)      \
		lconfig.tk       \
		tkconfig.h       \
		grlib_config.vhd \
		.grlib_config

.PHONY: grlib-xconfig grlib-config-clean grlib-config-distclean
