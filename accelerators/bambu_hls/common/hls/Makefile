# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

COMMON_PATH = $(ESP_ROOT)/accelerators/bambu_hls/common
COMMON_HLS_PATH = $(COMMON_PATH)/hls

include $(COMMON_PATH)/common.mk

# Bambu invocation. Override BAMBU to point at a specific binary; set BAMBU_ENV
# to a settings script to source first (e.g. a from-source install's settings.sh).
# The generated top module is named <accelerator>_core, so the C/C++ top function
# in ../src/<accelerator>.cpp must carry that name; the hand-written ESP socket
# wrappers in ../src/<accelerator>_basic_dma*/ instantiate it.
BAMBU ?= bambu
BAMBU_ENV ?=
BAMBU_TOP ?= $(TARGET_NAME)_core

# Target-aware synthesis: map the ESP technology library to a bambu device
# characterization and pass the accelerator clock. bambu Xilinx device syntax
# is "device,speedgrade,package". virtex7 maps to the characterized family
# sibling xc7vx690t (the VC707's xc7vx485t has no bambu characterization).
# Override BAMBU_DEVICE / BAMBU_CLOCK_PERIOD (ns) for other targets.
ifeq ($(TECH),virtex7)
BAMBU_DEVICE ?= xc7vx690t,-3,ffg1930
endif
BAMBU_CLOCK_PERIOD ?= 10

BAMBU_FLAGS ?= --compiler=I386_CLANG16 -O2 --experimental-setup=BAMBU \
               --generate-interface=INFER -lm \
               --device-name=$(BAMBU_DEVICE) --clock-period=$(BAMBU_CLOCK_PERIOD)
# Per-accelerator extra flags (optional): hw/hls/bambu_args.mk may set BAMBU_EXTRA_FLAGS
-include ../hls/bambu_args.mk

hls:
	@if test -z "$(BAMBU_DEVICE)"; then \
		echo "ERROR: no bambu device mapping for TECH=$(TECH); set BAMBU_DEVICE=<device,speedgrade,package>"; exit 1; fi
	@echo "bambu target: device=$(BAMBU_DEVICE) clock-period=$(BAMBU_CLOCK_PERIOD)ns (TECH=$(TECH))"
	@if test -n "$(BAMBU_ENV)"; then . $(BAMBU_ENV); fi; \
	command -v $(BAMBU) > /dev/null 2>&1 || \
		{ echo "ERROR: bambu binary '$(BAMBU)' not found: add bambu to PATH or set BAMBU (and BAMBU_ENV if it needs a settings script)"; exit 1; }; \
	$(BAMBU) $(BAMBU_FLAGS) $(BAMBU_EXTRA_FLAGS) --top-fname=$(BAMBU_TOP) ../src/$(TARGET_NAME).cpp

# Standalone verification, mirroring the catapult_hls flow targets. Both use
# the C++ testbench hw/tb/<accelerator>_tb.cpp (a main() that pre-fills the
# input streams, calls the top function and checks the outputs):
#   exe — native (behavioral) execution, no HLS involved
#   sim — RTL co-simulation: bambu --generate-tb compiles the same testbench
#         and drives the synthesized RTL through its DPI harness; the
#         testbench must print PASS on success (checked below). Requires the
#         chosen simulator (default VERILATOR) and a 32-bit libstdc++
#         (g++-multilib) for the co-simulation testbench binary.
BAMBU_TB ?= ../tb/$(TARGET_NAME)_tb.cpp
BAMBU_SIMULATOR ?= VERILATOR
BAMBU_CXX ?= g++

exe:
	@test -f $(BAMBU_TB) || \
		{ echo "ERROR: testbench $(BAMBU_TB) not found"; exit 1; }
	@if test -n "$(BAMBU_ENV)"; then . $(BAMBU_ENV); fi; \
	command -v $(BAMBU) > /dev/null 2>&1 || \
		{ echo "ERROR: bambu binary '$(BAMBU)' not found (provides hls_stream.h)"; exit 1; }; \
	BAMBU_INC=$$(dirname $$(command -v $(BAMBU)))/../include/panda; \
	$(BAMBU_CXX) -O2 -I$$BAMBU_INC $(BAMBU_TB) ../src/$(TARGET_NAME).cpp -o $(TARGET_NAME)_exe
	./$(TARGET_NAME)_exe

sim:
	@test -f $(BAMBU_TB) || \
		{ echo "ERROR: testbench $(BAMBU_TB) not found"; exit 1; }
	@if test -n "$(BAMBU_ENV)"; then . $(BAMBU_ENV); fi; \
	command -v $(BAMBU) > /dev/null 2>&1 || \
		{ echo "ERROR: bambu binary '$(BAMBU)' not found: add bambu to PATH or set BAMBU (and BAMBU_ENV if it needs a settings script)"; exit 1; }; \
	$(BAMBU) $(BAMBU_FLAGS) $(BAMBU_EXTRA_FLAGS) --top-fname=$(BAMBU_TOP) \
		--generate-tb=$(BAMBU_TB) --simulate --simulator=$(BAMBU_SIMULATOR) \
		../src/$(TARGET_NAME).cpp
	@tail -n 4 HLS_output/simulation/testbench.log
	@grep -q "PASS" HLS_output/simulation/testbench.log

# Memory init files are installed with an accelerator-specific prefix (and the
# references inside the generated core are rewritten to match): bambu names
# them array_<id>.mem, ids can collide across accelerators, and the ModelSim
# flow stages all installed .mem files into one shared working directory.
install:
	@mkdir -p $(RTL_OUT)
	@cp ../$(TARGET_NAME).xml $(RTL_OUT)/$(TARGET_NAME).xml
	@cp -r ../src/$(TARGET_NAME)_basic_dma* $(RTL_OUT)
	@sed 's/"array_/"$(TARGET_NAME)_array_/g' $(BAMBU_TOP).v > $(RTL_OUT)/$(BAMBU_TOP).v
	@cp panda_libtech.v $(RTL_OUT)
	@for m in array_*.mem; do \
		test -f "$$m" && cp "$$m" "$(RTL_OUT)/$(TARGET_NAME)_$$m"; \
	done; true

clean:
	@$(RM) HLS_output *.v *.mem bambu_results.xml transcript *.log $(TARGET_NAME)_exe

CLEAN: clean

distclean: clean
	@$(RM) $(RTL_OUT)

.PHONY: hls exe sim install clean CLEAN distclean
