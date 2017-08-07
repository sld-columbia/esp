
CACHES_PATH		= $(ESP_ROOT)/systemc/caches
CACHES			= $(filter-out common, $(shell ls -d $(CACHES_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
CACHES-wdir		= $(addsuffix -wdir, $(CACHES))
CACHES-hls		= $(addsuffix -hls, $(CACHES))
CACHES-clean		= $(addsuffix -clean, $(CACHES))
CACHES-distclean	= $(addsuffix -distclean, $(CACHES))
CACHES-sim		= $(addsuffix -sim, $(CACHES))

print-available-caches:
	$(QUIET_INFO)echo "Available caches: $(CACHES)"


$(CACHES-wdir):
	$(QUIET_MKDIR)mkdir -p $(CACHES_PATH)/$(@:-wdir=)/hls-work-$(TECHLIB)
	@cd $(CACHES_PATH)/$(@:-wdir=)/hls-work-$(TECHLIB); \
	if test ! -e project.tcl; then \
		ln -s ../stratus/project.tcl; \
	fi; \
	if test ! -e Makefile; then \
		ln -s ../stratus/Makefile; \
	fi;

$(CACHES-hls): %-hls : %-wdir
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) memlib | tee $(@:-hls=)_memgen.log
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) hls_all | tee $(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/caches/$(@:-hls=)"
	$(QUIET_MAKE)COMPONENT=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-hls=)/hls-work-$(TECHLIB) install
	@sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/caches/installed.log
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/caches/installed.log

$(CACHES-sim): %-sim : %-wdir
	$(QUIET_RUN)COMPONENT=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-sim=)/hls-work-$(TECHLIB) sim_all | tee $(@:-sim=)_sim.log

$(CACHES-clean): %-clean : %-wdir
	$(QUIET_CLEAN)COMPONENT=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-clean=)/hls-work-$(TECHLIB) clean
	@$(RM) $(@:-clean=)*.log

$(CACHES-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)COMPONENT=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CACHES_PATH)/$(@:-distclean=)/hls-work-$(TECHLIB) distclean
	@$(RM) $(@:-distclean=)*.log
	@sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/caches/installed.log

.PHONY: print-available-caches $(CACHES-wdir) $(CACHES-hls) $(CACHES-sim) $(CACHES-plot) $(CACHES-clean) $(CACHES-distclean)

$(ESP_ROOT)/tech/$(TECHLIB)/caches/installed.log:
	touch $@

caches: $(ESP_ROOT)/tech/$(TECHLIB)/caches/installed.log $(CACHES-hls)

caches-clean: $(CACHES-clean)

caches-distclean: $(CACHES-distclean)

.PHONY: caches caches-clean caches-distclean
