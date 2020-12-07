# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

boards:
	$(QUIET_MKDIR)ln -s $(PROFPGA)/boards

profpga-prog-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --up

profpga-close-fpga: boards
	$(QUIET_RUN)profpga_run profpga.cfg --down

profpga-distclean:
	$(QUIET_CLEAN)$(RM) boards

.PHONY: profpga-distclean profpga-prog-fpga profpga-close-fpga

mmi64_regs.h: socmap.vhd

MMI64_DESP  = $(ESP_ROOT)/utils/mmi64/mmi64.c
MMI64_DESP += mmi64_regs.h

mmi64: $(MMI64_DESP)
ifeq ("$(PROFPGA)","")
	@echo "Path to proFPGA installation (\$PROFPGA) not set - terminating!"
else
	$(QUIET_CC)gcc -I ${PROFPGA}/include/ -I./ -fpic -rdynamic -o mmi64 \
		$(ESP_ROOT)/utils/mmi64/mmi64.c -Wl,--whole-archive ${PROFPGA}/lib/linux_x86_64/libprofpga.a \
		${PROFPGA}/lib/linux_x86_64/libmmi64.a \
		${PROFPGA}/lib/linux_x86_64/libconfig.a -Wl,--no-whole-archive -lpthread \
		-lrt -ldl
endif

mmi64-run: mmi64
	$(QUIET_RUN) ./$< mmi64.cfg

mmi64-clean:
	$(QUIET_CLEAN) $(RM) mmi64

mmi64-distclean: mmi64-clean
	$(QUIET_CLEAN) $(RM) *.rpt

.PHONY: mmi64-run mmi64-clean mmi64-distclean


### ESP Monitor targets ###
ESPMON_DEPS  = $(ESP_ROOT)/utils/espmon/espmonmain.ui
ESPMON_DEPS += $(ESP_ROOT)/utils/espmon/espmonmain.h  $(ESP_ROOT)/utils/espmon/mmi64_mon.h
ESPMON_DEPS += $(ESP_ROOT)/utils/espmon/espmonmain.cpp  $(ESP_ROOT)/utils/espmon/main.cpp  $(ESP_ROOT)/utils/espmon/mmi64_mon.cpp

mmi64_regs.h: esp-config

power.h: esp-config

espmon.mk: $(ESP_ROOT)/utils/espmon/espmon.pro
	@DESIGN_DIR=$(DESIGN_PATH) qmake -o $@ $<

espmon: $(ESPMON_DEPS) mmi64_regs.h power.h espmon.mk
	$(QUIET_MAKE)DESIGN_DIR=$(DESIGN_PATH) make --quiet -f espmon.mk

espmon-run: espmon boards
	$(QUIET_RUN)./$<

espmon-clean:
	$(QUIET_CLEAN)$(RM) 		\
		espmonmain.o		\
		main.o			\
		mmi64_mon.o		\
		moc_espmonmain.o	\
		espmon.mk		\
		moc_espmonmain.cpp	\
		ui_espmonmain.h		\
		moc_predefs.h		\
		.qmake.stash

espmon-distclean: espmon-clean
	$(QUIET_CLEAN)$(RM) 	\
		espmon 		\
		espmon*.rpt

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
