# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ifeq ("$(ESP_ROOT)","")
$(error ESP_ROOT not set)
endif

ASIC_PADGEN = $(ESP_ROOT)/tools/asicgen/asic_padgen.py
ASIC_PADGEN_OUT = ../$(DIRTECH_NAME)/pad_wrappers

ASIC_PADLOC = $(ESP_ROOT)/utils/scripts/asic/pad_vh_loc.py

ASIC_MEMGEN = $(ESP_ROOT)/tools/asicgen/asic_memgen.py
ASIC_MEMGEN_OUT = ../$(DIRTECH_NAME)/mem_wrappers

MEMGEN = $(ESP_ROOT)/tools/asicgen/asic_plmgen.py
MEMTECH = ../$(DIRTECH_NAME)/mem_wrappers
MEMGEN_OUT = $(ESP_ROOT)/tech/$(TECHLIB)/memgen/slm_gen

mem_wrapper:
	$(ASIC_MEMGEN) $(ASIC_MEMGEN_OUT) | tee $(ASIC_MEMGEN_OUT)/asic_memgen.log

pad_wrapper:
	$(ASIC_PADGEN) $(ASIC_PADGEN_OUT) | tee $(ASIC_PADGEN_OUT)/asic_padgen.log

pad_location:
	$(ASIC_PADLOC)

mem_slmgen: socgen/esp/slm_memgen.txt $(MEMGEN)
	@$(MEMGEN) $(MEMTECH) $< $(MEMGEN_OUT) | tee mem_slmgen.log

link_technology:
	TECH_DIR_PATH=$(realpath ../$DIRTECH_NAME)
	PROJ_DIR_PATH=$(realpath ../$PROJECT_NAME)
	cd $(ESP_ROOT)/rtl/sim/asic ; \
        rm verilog; \
	ln -s ../../../../$(DIRTECH_NAME)/verilog verilog ; \
        cd - ; \
	cd $(ESP_ROOT)/rtl/techmap/asic ; \
	rm mem ; \
	ln -s ../../../../$(DIRTECH_NAME)/mem_wrappers mem ; \
	rm pad ; \
	ln -s ../../../../$(DIRTECH_NAME)/pad_wrappers pad ; \
	cd -
