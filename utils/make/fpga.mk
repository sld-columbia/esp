# Copyright (c) 2011-2021 Columbia University, System Level Design Group
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

fpga-reconf: esplink soft
	@./$(ESP_CFG_BUILD)/esplink --pbs -i $(ESP_ROOT)/socs/$(BOARD)/partial.bin

fpga-reset:
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-sw: esplink soft 
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run: esplink fpga-program soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --pbs -i $(ESP_ROOT)/socs/$(BOARD)/partial.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-linux: esplink fpga-program soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-partial: DPR_ENABLED = y
fpga-run-partial: fpga-program

.PHONY: fpga-run fpga-run-linux fpga-program
