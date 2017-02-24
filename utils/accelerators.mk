
ACCELERATORS_PATH      = $(ESP_ROOT)/accelerators
ACCELERATORS           = $(filter-out common, $(shell ls -d $(ACCELERATORS_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
ACCELERATORS-wdir      = $(addsuffix -wdir, $(ACCELERATORS))
ACCELERATORS-hls       = $(addsuffix -hls, $(ACCELERATORS))
ACCELERATORS-clean     = $(addsuffix -clean, $(ACCELERATORS))
ACCELERATORS-distclean = $(addsuffix -distclean, $(ACCELERATORS))
ACCELERATORS-sim       = $(addsuffix -sim, $(ACCELERATORS))
ACCELERATORS-plot      = $(addsuffix -plot, $(ACCELERATORS))


print-available-accelerators:
	$(QUIET_INFO)echo "Available accelerators: $(ACCELERATORS)"


$(ACCELERATORS-wdir):
	$(QUIET_MKDIR)mkdir -p $(ACCELERATORS_PATH)/$(@:-wdir=)/hls-work-$(TECHLIB)
	@cd $(ACCELERATORS_PATH)/$(@:-wdir=)/hls-work-$(TECHLIB); \
	if test ! -e project.tcl; then \
		ln -s ../stratus/project.tcl; \
	fi; \
	if test ! -e Makefile; then \
		ln -s ../stratus/Makefile; \
	fi;

$(ACCELERATORS-hls): %-hls : %-wdir
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) memlib | tee $(@:-hls=)_memgen.log
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) hls_all | tee $(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) install
	@sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(ACCELERATORS-sim): %-sim : %-wdir
	@$(QUIET_RUN)ACCELERATOR=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-sim=)/hls-work-$(TECHLIB) sim_all | tee $(@:-sim=)_sim.log

$(ACCELERATORS-plot): %-plot : %-wdir
	@$(QUIET_RUN)ACCELERATOR=$(@:-plot=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-plot=)/hls-work-$(TECHLIB) plot

$(ACCELERATORS-clean): %-clean : %-wdir
	@$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-clean=)/hls-work-$(TECHLIB) clean
	@$(RM) $(@:-clean=)*.log

$(ACCELERATORS-distclean): %-distclean : %-wdir
	@$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-distclean=)/hls-work-$(TECHLIB) distclean
	@$(RM) $(@:-distclean=)*.log
	@sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

.PHONY: print-available-accelerators $(ACCELERATORS-wdir) $(ACCELERATORS-hls) $(ACCELERATORS-sim) $(ACCELERATORS-plot) $(ACCELERATORS-clean) $(ACCELERATORS-distclean)

SLDGEN_DEPS  = $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log
SLDGEN_DEPS += $(ESP_ROOT)/utils/sldgen/sld_generate.py
SLDGEN_DEPS += $(wildcard $(ESP_ROOT)/utils/sldgen/templates/*.vhd)

sldgen: $(SLDGEN_DEPS)
	$(QUIET_MKDIR)mkdir -p sldgen
	$(QUIET_RUN)$(ESP_ROOT)/utils/sldgen/sld_generate.py $(NOC_WIDTH) $(ESP_ROOT)/tech/$(TECHLIB)/acc $(ESP_ROOT)/utils/sldgen/templates ./sldgen
	@touch $@

sldgen-clean:

sldgen-distclean: sldgen-clean
	$(QUIET_CLEAN)$(RM) sldgen

accelerators: $(ACCELERATORS-hls)

accelerators-clean: $(ACCELERATORS-clean)

accelerators-distclean: $(ACCELERATORS-distclean)

.PHONY: sldgen-clean sldgen-distclean accelerators accelerators-clean accelerators-distclean
