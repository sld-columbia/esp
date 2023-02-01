# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
EXAMPLES_PATH = $(ESP_ROOT)/soft/common/apps/examples/
EXAMPLES_OUT_PATH = $(SOFT_BUILD)/apps/examples

EXAMPLES = $(filter-out common, $(shell ls -d $(EXAMPLES_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))

EXAMPLES_OUT_PATHS = $(addprefix  $(EXAMPLES_OUT_PATH)/, $(EXAMPLES))

$(EXAMPLES_OUT_PATHS):
	@$(QUIET_MKDIR) mkdir -p $@

define EXAMPLES_GEN

$(1):  $(EXAMPLES_OUT_PATH)/$(1)
	@ESP_ROOT=$(ESP_ROOT) CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_LINUX) BUILD_PATH=$(EXAMPLES_OUT_PATH)/$(1) BUILD_DRIVERS=$(SOFT_BUILD)/drivers DESIGN_PATH=$(DESIGN_PATH) $(MAKE) -C $(EXAMPLES_PATH)/$(1)

endef

$(foreach e, $(EXAMPLES), $(eval $(call EXAMPLES_GEN,$(e))))

examples: soft-build $(EXAMPLES) $(SOFT_BUILD)/sysroot
	$(QUIET_CP)cp -r $(EXAMPLES_OUT_PATH) $(SOFT_BUILD)/sysroot

examples-clean:
	$(QUIET_CLEAN) $(RM) $(EXAMPLES_OUT_PATH)


.PHONY: examples examples-clean $(EXAMPLES) examples-copy
