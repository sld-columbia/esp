# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ifneq ($(findstring profpga, $(BOARD)),)
fpga-program: profpga-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5

fpga-program-emu: profpga-prog-fpga-emu
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
else
fpga-program: vivado-prog-fpga
	$(QUIET_INFO) echo "Waiting for DDR calibration..."
	@sleep 5
endif


fpga-run: esplink soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-linux: esplink soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-proxy: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-iolink: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/systest.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset

fpga-run-linux-proxy: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink --reset
	@./$(ESP_CFG_BUILD)/esplink --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink --reset

fpga-run-linux-iolink: esplink esplink-fpga-proxy soft
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --brom -i $(SOFT_BUILD)/prom.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --dram -i $(SOFT_BUILD)/linux.bin
	@./$(ESP_CFG_BUILD)/esplink-fpga-proxy --reset

fpga-run-jtag: esplink-fpga-proxy
	@python $(ESP_ROOT)/utils/scripts/jtag_test/jtag_esplink.py $(STIM_FILE)

.PHONY: fpga-run fpga-run-linux fpga-program fpga-run-proxy fpga-run-linux-proxy
