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

fpga-run-dpr: DPR_ENABLED = y
fpga-run-dpr: fpga-run

fpga-run-linux-dpr: DPR_ENABLED = y
fpga-run-linux-dpr: fpga-run-linux


fpga-run: esplink fpga-program soft
	@./esplink --reset
	@./esplink --brom -i prom.bin
	@./esplink --dram -i systest.bin
	@./esplink --reset

fpga-run-linux: esplink fpga-program soft
	@./esplink --reset
	@./esplink --brom -i prom.bin
	@./esplink --dram -i linux.bin
	@./esplink --reset

fpga-run-partial: DPR_ENABLED = y
fpga-run-partial: fpga-program

.PHONY: fpga-run fpga-run-linux fpga-program fpga-run-dpr fpga-run-linux-dpr
