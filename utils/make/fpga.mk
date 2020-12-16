# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ifneq ($(findstring profpga, $(BOARD)),)
fpga-program: profpga-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
else
fpga-program: vivado-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
endif


fpga-run: esplink soft
	@./esplink --reset
	@./esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./esplink --dram -i $(SOFT_BUILD)/systest.bin
	@./esplink --reset

fpga-run-linux: esplink fpga-program soft
	@./esplink --reset
	@./esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./esplink --dram -i $(SOFT_BUILD)/linux.bin
	@./esplink --reset


.PHONY: fpga-run fpga-run-linux fpga-program
