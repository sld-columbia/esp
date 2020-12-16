EXAMPLES_PATH = $(ESP_ROOT)/soft/common/apps/examples/
EXAMPLES_OUT_PATH = $(SOFT_BUILD)/apps/examples

EXAMPLES = $(filter-out common, $(shell ls -d $(EXAMPLES_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))

EXAMPLES_OUT_PATHS = $(addprefix  $(EXAMPLES_OUT_PATH)/, $(EXAMPLES))

$(EXAMPLES_OUT_PATHS):
	@$(QUIET_MKDIR) mkdir -p $@

define EXAMPLES_GEN

$(1):  $(EXAMPLES_OUT_PATH)/$(1)
	@CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_LINUX) BUILD_PATH=$(EXAMPLES_OUT_PATH)/$(1) BUILD_DRIVERS=$(SOFT_BUILD)/drivers $(MAKE) -C $(EXAMPLES_PATH)/$(1)

endef

$(foreach e, $(EXAMPLES), $(eval $(call EXAMPLES_GEN,$(e))))

examples: soft-build $(EXAMPLES) $(SOFT_BUILD)/sysroot
	$(QUIET_CP)cp -r $(EXAMPLES_OUT_PATH) $(SOFT_BUILD)/sysroot

examples-clean:
	$(QUIET_CLEAN) $(RM) $(EXAMPLES_OUT_PATH)


.PHONY: examples examples-clean $(EXAMPLES) examples-copy
