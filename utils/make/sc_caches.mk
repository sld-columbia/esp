# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

SCCS_PATH		= $(ESP_ROOT)/rtl/caches/esp-caches/systemc $(ESP_ROOT)/rtl/caches/spandex-caches
SCCS			= $(foreach p, $(SCCS_PATH), $(filter-out common utils, $(shell ls -d $(p)/*/ | awk -F/ '{print $$(NF-1)}')))
SCCS-wdir		= $(addsuffix -wdir, $(SCCS))
SCCS-hls		= $(addsuffix -hls, $(SCCS))
SCCS-clean		= $(addsuffix -clean, $(SCCS))
SCCS-distclean	= $(addsuffix -distclean, $(SCCS))
SCCS-sim		= $(addsuffix -sim, $(SCCS))

print-available-sccs:
	$(QUIET_INFO)echo "Available sccs: $(SCCS)"


define TARGET_SCCS_PATH_TMP =
	$(foreach p, $(SCCS_PATH), $(p)/$(filter $(1), $(shell ls -d $(p)/*/ | awk -F/ '{print $$(NF-1)}')))
endef


define TARGET_SCCS_PATH =
	$(filter-out , $(foreach p, $(call TARGET_SCCS_PATH_TMP, $(1)), $(if $(filter $(1), $(shell basename $(p))),$(p),)))
endef

$(SCCS-wdir): $(HLS_LOGS)
	$(QUIET_MKDIR)mkdir -p $(call TARGET_SCCS_PATH, $(@:-wdir=))/hls-work-$(TECHLIB)
	@cd $(call TARGET_SCCS_PATH, $(@:-wdir=))/hls-work-$(TECHLIB); \
	 if test ! -e project.tcl; then \
	 	ln -s ../stratus/project.tcl; \
	 fi; \
	 if test ! -e Makefile; then \
	 	ln -s ../stratus/Makefile; \
	 fi;

$(SCCS-hls): %-hls : %-wdir
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-hls=))/hls-work-$(TECHLIB) memlib | tee $(HLS_LOGS)/$(@:-hls=)_memgen.log
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-hls=))/hls-work-$(TECHLIB) hls_all | tee $(HLS_LOGS)/$(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/sccs/$(@:-hls=)"
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-hls=))/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log

$(SCCS-sim): %-sim : %-wdir
	$(QUIET_RUN)COMPONENT=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-sim=))/hls-work-$(TECHLIB) sim_all | tee $(HLS_LOGS)/$(@:-sim=)_sim.log

$(SCCS-clean): %-clean : %-wdir
	$(QUIET_CLEAN)COMPONENT=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-clean=))/hls-work-$(TECHLIB) clean
	@$(RM) $(HLS_LOGS)/$(@:-clean=)*.log

$(SCCS-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)COMPONENT=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(call TARGET_SCCS_PATH, $(@:-distclean=))/hls-work-$(TECHLIB) distclean
	@$(RM) $(HLS_LOGS)/$(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log; \
	fi;

.PHONY: print-available-sccs $(SCCS-wdir) $(SCCS-hls) $(SCCS-sim) $(SCCS-plot) $(SCCS-clean) $(SCCS-distclean)

$(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log:
	touch $@

sccs: $(ESP_ROOT)/tech/$(TECHLIB)/sccs/installed.log $(SCCS-hls)

sccs-clean: $(SCCS-clean)

sccs-distclean: $(SCCS-distclean)

.PHONY: sccs sccs-clean sccs-distclean
