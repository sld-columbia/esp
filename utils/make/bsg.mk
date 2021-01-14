# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

BSG_VLOG_OPT += -sv -svinputport=var
BSG_VLOG_OPT += -suppress 2902 -suppress 13169 -suppress 8386
BSG_VLOG_OPT += +incdir+$(ESP_ROOT)/rtl/peripherals/bsg/bsg_misc/
BSG_VLOG_OPT += +incdir+$(ESP_ROOT)/rtl/peripherals/bsg/bsg_clk_gen
BSG_VLOG_OPT += +incdir+$(ESP_ROOT)/rtl/peripherals/bsg/bsg_dmc
BSG_VLOG_OPT += +incdir+$(ESP_ROOT)/rtl/peripherals/bsg/testing/bsg_dmc/lpddr_verilog_model
BSG_VLOG_OPT += -mfcu
BSG_VLOG_OPT += -timescale=1ns/1ps
BSG_VLOG_OPT += +define+den2048Mb
BSG_VLOG_OPT += +define+sg5
BSG_VLOG_OPT += +define+x16
BSG_VLOG_OPT += +define+FULL_MEM

BSG_VLOG_SRCS += $(foreach f, $(shell strings $(FLISTS)/bsg_vlog.flist), $(ESP_ROOT)/rtl/$(f))

BSG_VLOG_SIM_SRCS  = $(BSG_VLOG_SRCS)
BSG_VLOG_SIM_SRCS += $(ESP_ROOT)/rtl/peripherals/bsg/testing/bsg_dmc/lpddr_verilog_model/mobile_ddr.v

BSG_VLOG = vlog -quiet $(BSG_VLOG_OPT)


bsg-sim-compile: modelsim/modelsim.ini
	@echo $(SPACES)"$(BSG_VLOG) -work work $(BSG_VLOG_SIM_SRCS)";
	@cd modelsim; $(BSG_VLOG) -work work $(BSG_VLOG_SIM_SRCS)


.PHONY: bsg-sim-compile
