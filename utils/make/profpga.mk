# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

boards:
	$(QUIET_MKDIR)ln -s $(PROFPGA)/boards

profpga-prog-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --up

profpga-prog-fpga-emu: boards
	$(QUIET_RUN)profpga_run profpga_emu.cfg --up

profpga-close-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --down

profpga-distclean:
	$(QUIET_CLEAN)$(RM) boards

.PHONY: profpga-distclean profpga-prog-fpga profpga-close-fpga

$(ESP_CFG_BUILD)/mmi64_regs.h: $(ESP_CFG_BUILD)/socmap.vhd

MMI64_DESP  = $(ESP_ROOT)/tools/mmi64/mmi64.c
MMI64_DESP += $(ESP_CFG_BUILD)/mmi64_regs.h

$(ESP_CFG_BUILD)/mmi64: $(MMI64_DESP)
ifeq ("$(PROFPGA)","")
	@echo "Path to proFPGA installation (\$PROFPGA) not set - terminating!"
else
	$(QUIET_CC) \
	cd $(ESP_CFG_BUILD); \
	gcc -I ${PROFPGA}/include/ -I./ -fpic -rdynamic -o mmi64 \
		$(ESP_ROOT)/tools/mmi64/mmi64.c -Wl,--whole-archive ${PROFPGA}/lib/linux_x86_64/libprofpga.a \
		${PROFPGA}/lib/linux_x86_64/libmmi64.a \
		${PROFPGA}/lib/linux_x86_64/libconfig.a -Wl,--no-whole-archive -lpthread \
		-lrt -ldl
endif

mmi64-run: $(ESP_CFG_BUILD)/mmi64
	$(QUIET_RUN) ./$< mmi64.cfg

mmi64-clean:
	$(QUIET_CLEAN) $(RM) $(ESP_CFG_BUILD)/mmi64

mmi64-distclean: mmi64-clean
	$(QUIET_CLEAN) $(RM) $(ESP_CFG_BUILD)/*.rpt

.PHONY: mmi64-run mmi64-clean mmi64-distclean


### ESP Monitor targets ###
ESPMON_DEPS  = $(ESP_ROOT)/tools/espmon/espmonmain.ui
ESPMON_DEPS += $(ESP_ROOT)/tools/espmon/espmonmain.h  $(ESP_ROOT)/tools/espmon/mmi64_mon.h
ESPMON_DEPS += $(ESP_ROOT)/tools/espmon/espmonmain.cpp  $(ESP_ROOT)/tools/espmon/main.cpp  $(ESP_ROOT)/tools/espmon/mmi64_mon.cpp

$(ESP_CFG_BUILD)/mmi64_regs.h: esp-config

$(ESP_CFG_BUILD)/power.h: esp-config

$(ESPMON_BUILD):
	$(QUIET_MKDIR)mkdir -p $(ESPMON_BUILD)

$(ESPMON_BUILD)/espmon.mk: $(ESP_ROOT)/tools/espmon/espmon.pro $(ESPMON_BUILD)
	@cd $(ESPMON_BUILD); \
	DESIGN_DIR=$(DESIGN_PATH) qmake -o espmon.mk $<

$(ESPMON_BUILD)/espmon: $(ESPMON_DEPS) $(ESP_CFG_BUILD)/mmi64_regs.h $(ESP_CFG_BUILD)/power.h $(ESPMON_BUILD)/espmon.mk
	$(QUIET_MAKE) \
	cd $(ESPMON_BUILD); \
	DESIGN_DIR=$(DESIGN_PATH)/$(ESPMON_BUILD) ESP_CFG_DIR=$(DESIGN_PATH)/$(ESP_CFG_BUILD) make --quiet -f espmon.mk

espmon-run: $(ESPMON_BUILD)/espmon boards
	$(QUIET_RUN) \
	cd $(ESPMON_BUILD); \
	./espmon

espmon-clean:
	$(QUIET_CLEAN)$(RM) 		\
		$(ESPMON_BUILD)/espmonmain.o		\
		$(ESPMON_BUILD)/main.o			\
		$(ESPMON_BUILD)/mmi64_mon.o		\
		$(ESPMON_BUILD)/moc_espmonmain.o	\
		$(ESPMON_BUILD)/espmon.mk		\
		$(ESPMON_BUILD)/moc_espmonmain.cpp	\
		$(ESPMON_BUILD)/ui_espmonmain.h		\
		$(ESPMON_BUILD)/moc_predefs.h		\
		$(ESPMON_BUILD)/.qmake.stash

espmon-distclean: espmon-clean
	$(QUIET_CLEAN)$(RM) $(ESPMON_BUILD)

.PHONY: espmon-clean espmon-distclean espmon-run


### Incdir and RTL

ifneq ($(findstring profpga, $(BOARD)),)
INCDIR += $(PROFPGA)/hdl/generic_hdl
INCDIR += $(PROFPGA)/hdl/mmi64
INCDIR += $(PROFPGA)/hdl/profpga_user
INCDIR += $(PROFPGA)/hdl/pd_muxdemux2

VHDL_PROFPGA    = $(shell strings $(FLISTS)/profpga_vhdl.flist)
VERILOG_PROFPGA = $(shell strings $(FLISTS)/profpga_vlog.flist)
endif
