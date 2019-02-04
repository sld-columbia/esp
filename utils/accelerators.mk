
ACCELERATORS_PATH		= $(ESP_ROOT)/accelerators
ACCELERATORS			= $(filter-out common, $(shell ls -d $(ACCELERATORS_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
ACCELERATORS-wdir		= $(addsuffix -wdir, $(ACCELERATORS))
ACCELERATORS-hls		= $(addsuffix -hls, $(ACCELERATORS))
ACCELERATORS-clean		= $(addsuffix -clean, $(ACCELERATORS))
ACCELERATORS-distclean		= $(addsuffix -distclean, $(ACCELERATORS))
ACCELERATORS-sim		= $(addsuffix -sim, $(ACCELERATORS))
ACCELERATORS-plot		= $(addsuffix -plot, $(ACCELERATORS))

CHISEL_PATH                     = $(ESP_ROOT)/chisel
CHISEL_ACC_PATH                 = $(CHISEL_PATH)/src/main/scala/esp/examples
CHISEL_ACCELERATORS             = $(shell ls $(CHISEL_ACC_PATH)/*.scala | awk -F/ '{print $$(NF)}' | sed 's/\.scala//g')
CHISEL_ACCELERATORS-clean	= $(addsuffix -clean, $(CHISEL_ACCELERATORS))
CHISEL_ACCELERATORS-distclean	= $(addsuffix -distclean, $(CHISEL_ACCELERATORS))

ACCELERATORS-driver		= $(addsuffix -driver, $(ACCELERATORS)) $(addsuffix -driver, $(CHISEL_ACCELERATORS))
ACCELERATORS-driver-clean	= $(addsuffix -driver-clean, $(ACCELERATORS)) $(addsuffix -driver-clean, $(CHISEL_ACCELERATORS))
ACCELERATORS-app		= $(addsuffix -app, $(ACCELERATORS)) $(addsuffix -app, $(CHISEL_ACCELERATORS))
ACCELERATORS-app-clean		= $(addsuffix -app-clean, $(ACCELERATORS)) $(addsuffix -app-clean, $(CHISEL_ACCELERATORS))
ACCELERATORS-barec		= $(addsuffix -barec, $(ACCELERATORS)) $(addsuffix -barec, $(CHISEL_ACCELERATORS))
ACCELERATORS-barec-clean	= $(addsuffix -barec-clean, $(ACCELERATORS)) $(addsuffix -barec-clean, $(CHISEL_ACCELERATORS))



print-available-accelerators:
	$(QUIET_INFO)echo "Available accelerators generated from HLS: $(ACCELERATORS)"
	$(QUIET_INFO)echo "Available accelerators generated from Chisel3: $(CHISEL_ACCELERATORS)"

sbt-run:
	$(QUIET_RUN)
	@cd $(CHISEL_PATH); sbt run;

$(CHISEL_ACCELERATORS):
	$(QUIET_BUILD)
	@if ! test -e $(CHISEL_PATH)/build/$@; then \
		$(MAKE) sbt-run; \
	fi;
	@cp -r $(CHISEL_PATH)/build/$@ $(ESP_ROOT)/tech/$(TECHLIB)/acc/$@; \
	if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$@/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi; \
	echo "$@" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log;

chisel-accelerators: $(CHISEL_ACCELERATORS)

$(CHISEL_ACCELERATORS-clean):
	$(QUIET_CLEAN)
	@cd $(CHISEL_PATH); $(RM) build/$(@:-clean=)

$(CHISEL_ACCELERATORS-distclean): %-distclean : %-clean
	$(QUIET_CLEAN)
	@$(RM) $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-distclean=);
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

chisel-accelerators-clean:
	$(QUIET_CLEAN)
	@cd $(CHISEL_PATH); sbt clean; $(RM) build

chisel-accelerators-distclean: chisel-accelerators-clean $(CHISEL_ACCELERATORS-distclean)

.PHONY: sbt-run chisel-accelerators chisel-accelerators-clean chisel-accelerators-distclean $(CHISEL_ACCELERATORS-clean) $(CHISEL_ACCELERATORS-distclean)

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
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(ACCELERATORS-sim): %-sim : %-wdir
	$(QUIET_RUN)ACCELERATOR=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-sim=)/hls-work-$(TECHLIB) sim_all | tee $(@:-sim=)_sim.log

$(ACCELERATORS-plot): %-plot : %-wdir
	$(QUIET_RUN)ACCELERATOR=$(@:-plot=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-plot=)/hls-work-$(TECHLIB) plot

$(ACCELERATORS-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-clean=)/hls-work-$(TECHLIB) clean
	@$(RM) $(@:-clean=)*.log

$(ACCELERATORS-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(ACCELERATORS_PATH)/$(@:-distclean=)/hls-work-$(TECHLIB) distclean
	@$(RM) $(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: print-available-accelerators $(ACCELERATORS-wdir) $(ACCELERATORS-hls) $(ACCELERATORS-sim) $(ACCELERATORS-plot) $(ACCELERATORS-clean) $(ACCELERATORS-distclean)

$(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log:
	touch $@

SLDGEN_DEPS  = $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log
SLDGEN_DEPS += $(ESP_ROOT)/utils/sldgen/sld_generate.py
SLDGEN_DEPS += $(wildcard $(ESP_ROOT)/utils/sldgen/templates/*.vhd)

sldgen: $(SLDGEN_DEPS)
	$(QUIET_MKDIR) $(RM) $@; mkdir -p $@
	$(QUIET_RUN)$(ESP_ROOT)/utils/sldgen/sld_generate.py $(NOC_WIDTH) $(ESP_ROOT)/tech/$(TECHLIB) $(ESP_ROOT)/utils/sldgen/templates ./sldgen
	@touch $@

sldgen-clean:

sldgen-distclean: sldgen-clean
	$(QUIET_CLEAN)$(RM) sldgen

accelerators: $(ACCELERATORS-hls)

accelerators-clean: $(ACCELERATORS-clean)

accelerators-distclean: $(ACCELERATORS-distclean)

.PHONY: sldgen-clean sldgen-distclean accelerators accelerators-clean accelerators-distclean

$(ACCELERATORS-driver): sysroot linux-build/vmlinux
	@if test -e $(DRIVERS)/$(@:-driver=)/linux/$(@:-driver=).c; then \
		echo '   ' MAKE $@; \
		ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build $(MAKE) ESP_CORE_PATH=$(ESP_CORE_PATH) -C $(DRIVERS)/$(@:-driver=)/linux; \
		if test -e $(DRIVERS)/$(@:-driver=)/linux/$(@:-driver=).ko; then \
			echo '   ' CP $@; cp $(DRIVERS)/$(@:-driver=)/linux/$(@:-driver=).ko sysroot/opt/drivers/; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACCELERATORS-driver-clean):
	$(QUIET_CLEAN)ARCH=sparc CROSS_COMPILE=sparc-leon3-linux- KSRC=$(PWD)/linux-build $(MAKE) ESP_CORE_PATH=$(ESP_CORE_PATH) -C $(DRIVERS)/$(@:-driver-clean=)/linux clean


$(ACCELERATORS-app): sysroot
	@if [ `ls -1 $(DRIVERS)/$(@:-app=)/app/*.c 2>/dev/null | wc -l ` -gt 0 ]; then \
		echo '   ' MAKE $@; \
		CROSS_COMPILE=sparc-leon3-linux- $(MAKE) -C $(DRIVERS)/$(@:-app=)/app; \
		if [ `ls -1 $(DRIVERS)/$(@:-app=)/app/*.exe 2>/dev/null | wc -l ` -gt 0 ]; then \
			echo '   ' CP $@; cp $(DRIVERS)/$(@:-app=)/app/*.exe sysroot/applications/test/; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACCELERATORS-app-clean):
	$(QUIET_CLEAN)CROSS_COMPILE=sparc-leon3-linux- $(MAKE) -C $(DRIVERS)/$(@:-app-clean=)/app clean

$(ACCELERATORS-barec): barec
	@if [ `ls -1 $(DRIVERS)/$(@:-barec=)/barec/*.c 2>/dev/null | wc -l ` -gt 0 ]; then \
		echo '   ' MAKE $@; \
		CROSS_COMPILE=sparc-elf- $(MAKE) -C $(DRIVERS)/$(@:-barec=)/barec; \
		if [ `ls -1 $(DRIVERS)/$(@:-barec=)/barec/*.exe 2>/dev/null | wc -l ` -gt 0 ]; then \
			echo '   ' CP $@; cp $(DRIVERS)/$(@:-barec=)/barec/*.exe barec; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACCELERATORS-barec-clean):
	$(QUIET_CLEAN)CROSS_COMPILE=sparc-elf- $(MAKE) -C $(DRIVERS)/$(@:-barec-clean=)/barec clean


.PHONY: $(ACCELERATORS-driver) $(ACCELERATORS-driver-clean) $(ACCELERATORS-app) $(ACCELERATORS-app-clean) $(ACCELERATORS-barec) $(ACCELERATORS-barec-clean)

accelerators-driver: $(ACCELERATORS-driver)

accelerators-driver-clean: $(ACCELERATORS-driver-clean)

accelerators-app: $(ACCELERATORS-app)

accelerators-app-clean: $(ACCELERATORS-app-clean)

accelerators-barec: $(ACCELERATORS-barec)

accelerators-barec-clean: $(ACCELERATORS-barec-clean)

.PHONY: accelerators-driver accelerators-driver-clean accelerators-app accelerators-app-clean accelerators-barec accelerators-barec-clean
