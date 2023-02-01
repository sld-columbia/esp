# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

STRATUSHLS_ACC_PATH      = $(ESP_ROOT)/accelerators/stratus_hls
STRATUSHLS_ACC           = $(filter-out common, $(shell ls -d $(STRATUSHLS_ACC_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
STRATUSHLS_ACC_PATHS     = $(addprefix $(STRATUSHLS_ACC_PATH)/, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-wdir      = $(addsuffix -wdir, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-hls       = $(addsuffix -hls, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-clean     = $(addsuffix -clean, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-distclean = $(addsuffix -distclean, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-sim       = $(addsuffix -sim, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-plot      = $(addsuffix -plot, $(STRATUSHLS_ACC))
STRATUSHLS_ACC-exe       = $(addsuffix -exe, $(STRATUSHLS_ACC))


VIVADOHLS_ACC_PATH      = $(ESP_ROOT)/accelerators/vivado_hls
VIVADOHLS_ACC           = $(filter-out common, $(shell ls -d $(VIVADOHLS_ACC_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
VIVADOHLS_ACC_PATHS     = $(addprefix $(VIVADOHLS_ACC_PATH)/, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-wdir      = $(addsuffix -wdir, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-hls       = $(addsuffix -hls, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-clean     = $(addsuffix -clean, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-distclean = $(addsuffix -distclean, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-sim       = $(addsuffix -sim, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-plot      = $(addsuffix -plot, $(VIVADOHLS_ACC))
VIVADOHLS_ACC-exe       = $(addsuffix -exe, $(VIVADOHLS_ACC))

CATAPULTHLS_ACC_PATH      = $(ESP_ROOT)/accelerators/catapult_hls
CATAPULTHLS_ACC           = $(filter-out common, $(shell ls -d $(CATAPULTHLS_ACC_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
CATAPULTHLS_ACC_PATHS     = $(addprefix $(CATAPULTHLS_ACC_PATH)/, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-wdir      = $(addsuffix -wdir, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-hls       = $(addsuffix -hls, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-clean     = $(addsuffix -clean, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-distclean = $(addsuffix -distclean, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-sim       = $(addsuffix -sim, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-plot      = $(addsuffix -plot, $(CATAPULTHLS_ACC))
CATAPULTHLS_ACC-exe       = $(addsuffix -exe, $(CATAPULTHLS_ACC))

HLS4ML_ACC_PATH      = $(ESP_ROOT)/accelerators/hls4ml
HLS4ML_ACC           = $(filter-out common, $(shell ls -d $(HLS4ML_ACC_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
HLS4ML_ACC_PATHS     = $(addprefix $(HLS4ML_ACC_PATH)/, $(HLS4ML_ACC))
HLS4ML_ACC-wdir      = $(addsuffix -wdir, $(HLS4ML_ACC))
HLS4ML_ACC-hls       = $(addsuffix -hls, $(HLS4ML_ACC))
HLS4ML_ACC-clean     = $(addsuffix -clean, $(HLS4ML_ACC))
HLS4ML_ACC-distclean = $(addsuffix -distclean, $(HLS4ML_ACC))
HLS4ML_ACC-sim       = $(addsuffix -sim, $(HLS4ML_ACC))
HLS4ML_ACC-plot      = $(addsuffix -plot, $(HLS4ML_ACC))
HLS4ML_ACC-exe       = $(addsuffix -exe, $(HLS4ML_ACC))

CHISEL_PATH          = $(ESP_ROOT)/accelerators/chisel/hw
CHISEL_ACC_PATH      = $(CHISEL_PATH)/src/main/scala/esp/examples
CHISEL_ACC           = $(shell ls $(CHISEL_ACC_PATH)/*.scala | awk -F/ '{print $$(NF)}' | sed 's/\.scala//g')
CHISEL_ACC_PATHS     = $(addprefix $(ESP_ROOT)/accelerators/chisel/, $(CHISEL_ACC))
CHISEL_ACC-clean     = $(addsuffix -clean, $(CHISEL_ACC))
CHISEL_ACC-distclean = $(addsuffix -distclean, $(CHISEL_ACC))

RTL_ACC_PATH      = $(ESP_ROOT)/accelerators/rtl
RTL_ACC           = $(filter-out common, $(shell ls -d $(RTL_ACC_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
RTL_ACC_PATHS     = $(addprefix $(RTL_ACC_PATH)/, $(RTL_ACC))
RTL_ACC-wdir      = $(addsuffix -wdir, $(RTL_ACC))
RTL_ACC-hls       = $(addsuffix -hls, $(RTL_ACC))
RTL_ACC-clean     = $(addsuffix -clean, $(RTL_ACC))
RTL_ACC-distclean = $(addsuffix -distclean, $(RTL_ACC))

THIRDPARTY_PATH = $(ESP_ROOT)/accelerators/third-party
ifdef CPU_ARCH
THIRDPARTY_ACC  = $(foreach acc, $(shell ls $(THIRDPARTY_PATH)), $(shell if grep -q $(CPU_ARCH) $(THIRDPARTY_PATH)/$(acc)/$(acc).hosts; then echo $(acc); fi))
else
THIRDPARTY_ACC  = ""
endif
THIRDPARTY_ACC-clean     = $(addsuffix -clean, $(THIRDPARTY_ACC))
THIRDPARTY_ACC-distclean = $(addsuffix -distclean, $(THIRDPARTY_ACC))

THIRDPARTY_VLOG       = $(foreach acc, $(THIRDPARTY_ACC), $(shell f=$(THIRDPARTY_PATH)/$(acc)/out; l=$$(readlink $$f); if test -e $(THIRDPARTY_PATH)/$(acc)/$$l; then echo $(THIRDPARTY_PATH)/$(acc)/$(acc)_wrapper.v; fi))
THIRDPARTY_VLOG      += $(foreach acc, $(THIRDPARTY_ACC), $(foreach rtl, $(shell strings $(THIRDPARTY_PATH)/$(acc)/$(acc).verilog),  $(shell f=$(THIRDPARTY_PATH)/$(acc)/out/$(rtl); if test -e $$f; then echo $$f; fi;)))
THIRDPARTY_INCDIR     = $(foreach acc, $(THIRDPARTY_ACC), $(shell if test -r $(THIRDPARTY_PATH)/$(acc)/vlog_incdir; then echo -n $(THIRDPARTY_PATH)/$(acc)/vlog_incdir; else echo -n ""; fi))
THIRDPARTY_SVLOG      = $(foreach acc, $(THIRDPARTY_ACC), $(foreach rtl, $(shell strings $(THIRDPARTY_PATH)/$(acc)/$(acc).sverilog), $(shell f=$(THIRDPARTY_PATH)/$(acc)/out/$(rtl); if test -e $$f; then echo $$f; fi;)))
THIRDPARTY_VHDL_PKGS  = $(foreach acc, $(THIRDPARTY_ACC), $(foreach rtl, $(shell strings $(THIRDPARTY_PATH)/$(acc)/$(acc).pkgs),     $(shell f=$(THIRDPARTY_PATH)/$(acc)/out/$(rtl); if test -e $$f; then echo $$f; fi;)))
THIRDPARTY_VHDL       = $(foreach acc, $(THIRDPARTY_ACC), $(foreach rtl, $(shell strings $(THIRDPARTY_PATH)/$(acc)/$(acc).vhdl),     $(shell f=$(THIRDPARTY_PATH)/$(acc)/out/$(rtl); if test -e $$f; then echo $$f; fi;)))

ACC_PATHS = $(STRATUSHLS_ACC_PATHS) $(VIVADOHLS_ACC_PATHS) $(CATAPULTHLS_ACC_PATHS) $(HLS4ML_ACC_PATHS) $(CHISEL_ACC_PATHS) $(RTL_ACC_PATHS)

ACC-driver       = $(addsuffix -driver, $(STRATUSHLS_ACC)) $(addsuffix -driver, $(VIVADOHLS_ACC)) $(addsuffix -driver, $(HLS4ML_ACC)) $(addsuffix -driver, $(CHISEL_ACC)) $(addsuffix -driver, $(CATAPULTHLS_ACC)) $(addsuffix -driver, $(RTL_ACC))
ACC-driver-clean = $(addsuffix -driver-clean, $(STRATUSHLS_ACC)) $(addsuffix -driver-clean, $(VIVADOHLS_ACC)) $(addsuffix -driver-clean, $(HLS4ML_ACC)) $(addsuffix -driver-clean, $(CHISEL_ACC)) $(addsuffix -driver-clean, $(CATAPULTHLS_ACC)) $(addsuffix -driver-clean, $(RTL_ACC))
ACC-app          = $(addsuffix -app, $(STRATUSHLS_ACC)) $(addsuffix -app, $(VIVADOHLS_ACC)) $(addsuffix -app, $(HLS4ML_ACC)) $(addsuffix -app, $(CHISEL_ACC)) $(addsuffix -app, $(CATAPULTHLS_ACC)) $(addsuffix -app, $(RTL_ACC)) 
ACC-app-clean    = $(addsuffix -app-clean, $(STRATUSHLS_ACC)) $(addsuffix -app-clean, $(VIVADOHLS_ACC)) $(addsuffix -app-clean, $(HLS4ML_ACC)) $(addsuffix -app-clean, $(CHISEL_ACC)) $(addsuffix -app-clean, $(CATAPULTHLS_ACC)) $(addsuffix -app-clean, $(RTL_ACC))
ACC-baremetal        = $(addsuffix -baremetal, $(STRATUSHLS_ACC)) $(addsuffix -baremetal, $(VIVADOHLS_ACC)) $(addsuffix -baremetal, $(HLS4ML_ACC)) $(addsuffix -baremetal, $(CHISEL_ACC)) $(addsuffix -baremetal, $(CATAPULTHLS_ACC)) $(addsuffix -baremetal, $(RTL_ACC))
ACC-baremetal-clean  = $(addsuffix -baremetal-clean, $(STRATUSHLS_ACC)) $(addsuffix -baremetal-clean, $(VIVADOHLS_ACC)) $(addsuffix -baremetal-clean, $(HLS4ML_ACC)) $(addsuffix -baremetal-clean, $(CHISEL_ACC)) $(addsuffix -baremetal-clean, $(CATAPULTHLS_ACC)) $(addsuffix -baremetal-clean, $(RTL_ACC))

THIRDPARTY_ACC_PRINT  = $(foreach acc, $(shell ls $(THIRDPARTY_PATH)), $(shell echo $(acc)))
print-available-acc:
	$(QUIET_INFO)echo "Available accelerators generated from Stratus HLS: $(STRATUSHLS_ACC)"
	$(QUIET_INFO)echo "Available accelerators generated from Catapult HLS: $(CATAPULTHLS_ACC)"
	$(QUIET_INFO)echo "Available accelerators generated from Vivado HLS: $(VIVADOHLS_ACC)"
	$(QUIET_INFO)echo "Available accelerators generated from hls4ml: $(HLS4ML_ACC)"
	$(QUIET_INFO)echo "Available accelerators generated from Chisel3: $(CHISEL_ACC)"
	$(QUIET_INFO)echo "Available accelerators generated from RTL: $(RTL_ACC)"
	$(QUIET_INFO)echo "Available third-party accelerators: $(THIRDPARTY_ACC_PRINT)"

### Chisel ###
sbt-run:
	$(QUIET_RUN)
	@cd $(CHISEL_PATH); sbt run;

$(CHISEL_ACC):
	$(QUIET_BUILD)
	@if ! test -e $(CHISEL_PATH)/build/$@; then \
		$(MAKE) sbt-run && rm -rf $(ESP_ROOT)/tech/$(TECHLIB)/acc/$@; \
	fi;
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$@/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi; \
	cp -r $(CHISEL_PATH)/build/$@ $(ESP_ROOT)/tech/$(TECHLIB)/acc/; \
	echo "$@" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log;

chisel-acc: $(CHISEL_ACC)

$(CHISEL_ACC-clean):
	$(QUIET_CLEAN)
	@cd $(CHISEL_PATH); $(RM) build/$(@:-clean=)

$(CHISEL_ACC-distclean): %-distclean : %-clean
	$(QUIET_CLEAN)
	@$(RM) $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-distclean=);
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

chisel-acc-clean:
	$(QUIET_CLEAN)
	@cd $(CHISEL_PATH); sbt clean; $(RM) build

chisel-acc-distclean: chisel-acc-clean $(CHISEL_ACC-distclean)

.PHONY: sbt-run chisel-acc chisel-acc-clean chisel-acc-distclean $(CHISEL_ACC) $(CHISEL_ACC-clean) $(CHISEL_ACC-distclean)


### Third-Party ###
$(THIRDPARTY_ACC): $(BAREMETAL_BIN)
	$(QUIET_BUILD)
	@cd $(THIRDPARTY_PATH)/$@; \
	if ! test -e $(THIRDPARTY_PATH)/$@/out; then \
		$(MAKE) TECH_TYPE=$(TECH_TYPE) CROSS_COMPILE_ELF=$(CROSS_COMPILE_ELF) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) ARCH=$(ARCH) KSRC=$(SOFT_BUILD)/linux-build hw; \
	fi;
	@cd $(THIRDPARTY_PATH)/$@; \
	$(MAKE) ESP_ROOT=$(ESP_ROOT) DESIGN_PATH=$(DESIGN_PATH)/$(ESP_CFG_BUILD) CPU_ARCH=$(CPU_ARCH) CROSS_COMPILE_ELF=$(CROSS_COMPILE_ELF) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) ARCH=$(ARCH) KSRC=$(SOFT_BUILD)/linux-build sw;
	@for f in $$(cat $(THIRDPARTY_PATH)/$@/$@.kmd); do \
		cp -r $(THIRDPARTY_PATH)/$@/sw/$$f $(SOFT_BUILD)/sysroot/opt/drivers/; \
	done;
	@mkdir -p $(SOFT_BUILD)/sysroot/root/$@
	@for f in $$(cat $(THIRDPARTY_PATH)/$@/$@.umd); do \
		cp -r $(THIRDPARTY_PATH)/$@/sw/$$f $(SOFT_BUILD)/sysroot/root/$@/; \
	done;
	@for f in $$(cat $(THIRDPARTY_PATH)/$@/$@.bc); do \
		cp -r $(THIRDPARTY_PATH)/$@/sw/$$f $(BAREMETAL_BIN); \
	done;


thirdparty-acc: $(THIRDPARTY_ACC)

$(THIRDPARTY_ACC-clean):
	$(QUIET_CLEAN)
	@cd $(THIRDPARTY_PATH)/$(@:-clean=); \
	$(MAKE) CROSS_COMPILE_ELF=$(CROSS_COMPILE_ELF) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) ARCH=$(ARCH) KSRC=$(SOFT_BUILD)/linux-build clean;

$(THIRDPARTY_ACC-distclean): %-distclean : %-clean
	$(QUIET_CLEAN)
	@cd $(THIRDPARTY_PATH)/$(@:-distclean=); \
	$(MAKE) CROSS_COMPILE_ELF=$(CROSS_COMPILE_ELF) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) ARCH=$(ARCH) KSRC=$(SOFT_BUILD)/linux-build distclean;

thirdparty-acc-clean: $(THIRDPARTY_ACC-clean)

thirdparty-acc-distclean: $(THIRDPARTY_ACC-distclean)

.PHONY: thirdparty-acc thirdparty-acc-clean thirdparty-acc-distclean $(THIRDPARTY_ACC) $(THIRDPARTY_ACC-clean) $(THIRDPARTY_ACC-distclean)

$(HLS_LOGS):
	$(QUIET_MKDIR)mkdir -p $(HLS_LOGS)

### Stratus HLS ###
$(STRATUSHLS_ACC-wdir): $(HLS_LOGS)
	$(QUIET_MKDIR)mkdir -p $(STRATUSHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB)
	@cd $(STRATUSHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
	if ! test -e project.tcl; then \
		cp ../hls/* .; \
		rm -f project.tcl; \
		rm -f Makefile; \
		ln -s ../hls/project.tcl; \
		ln -s ../hls/Makefile; \
	fi;

$(STRATUSHLS_ACC-hls): %-hls : %-wdir
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) memlib | tee $(HLS_LOGS)/$(@:-hls=)_memgen.log
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) hls_all | tee $(HLS_LOGS)/$(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(STRATUSHLS_ACC-sim): %-sim : %-wdir
	$(QUIET_RUN)ACCELERATOR=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-sim=)/hw/hls-work-$(TECHLIB) sim_all | tee $(HLS_LOGS)/$(@:-sim=)_sim.log

$(STRATUSHLS_ACC-plot): %-plot : %-wdir
	$(QUIET_RUN)ACCELERATOR=$(@:-plot=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-plot=)/hw/hls-work-$(TECHLIB) plot

$(STRATUSHLS_ACC-exe):
	$(QUIET_RUN) ACCELERATOR=$(@:-exe=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) DMA_WIDTH=$(NOC_WIDTH) RUN_ARGS="$(RUN_ARGS)" $(MAKE) -C $(STRATUSHLS_ACC_PATH)/$(@:-exe=)/hw/sim run

$(STRATUSHLS_ACC-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-clean=)/hw/hls-work-$(TECHLIB) clean
	@ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) DMA_WIDTH=$(NOC_WIDTH) $(MAKE) -C $(STRATUSHLS_ACC_PATH)/$(@:-clean=)/hw/sim clean
	@$(RM) $(HLS_LOGS)/$(@:-clean=)*.log

$(STRATUSHLS_ACC-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(STRATUSHLS_ACC_PATH)/$(@:-distclean=)/hw/hls-work-$(TECHLIB) distclean
	@$(RM) $(HLS_LOGS)/$(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: print-available-acc $(STRATUSHLS_ACC-wdir) $(STRATUSHLS_ACC-hls) $(STRATUSHLS_ACC-sim) $(STRATUSHLS_ACC-plot) $(STRATUSHLS_ACC-clean) $(STRATUSHLS_ACC-distclean)

acc: $(STRATUSHLS_ACC-hls)

acc-clean: $(STRATUSHLS_ACC-clean)

acc-distclean: $(STRATUSHLS_ACC-distclean)

.PHONY: acc acc-clean acc-distclean

### Vivado HLS ###
$(VIVADOHLS_ACC-wdir): $(HLS_LOGS)
	$(QUIET_MKDIR) if ! test -e $(VIVADOHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); then \
		mkdir -p $(VIVADOHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
		cd $(VIVADOHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
		cp ../hls/* .; \
		rm -f common.tcl; \
		rm -f custom.tcl; \
		rm -f directives.tcl; \
		rm -f Makefile; \
		ln -s ../hls/common.tcl; \
		ln -s ../hls/custom.tcl; \
		ln -s ../hls/directives.tcl; \
		ln -s ../hls/Makefile; \
	fi;

$(VIVADOHLS_ACC-hls): %-hls : %-wdir
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(VIVADOHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) hls | tee $(HLS_LOGS)/$(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(VIVADOHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(VIVADOHLS_ACC-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(VIVADOHLS_ACC_PATH)/$(@:-clean=)/hw/hls-work-$(TECHLIB) clean
	@$(RM) $(HLS_LOGS)/$(@:-clean=)*.log

$(VIVADOHLS_ACC-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(VIVADOHLS_ACC_PATH)/$(@:-distclean=)/hw/hls-work-$(TECHLIB) distclean
	@$(RM) $(HLS_LOGS)/$(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: $(VIVADOHLS_ACC-wdir) $(VIVADOHLS_ACC-hls) $(VIVADOHLS_ACC-sim) $(VIVADOHLS_ACC-clean) $(VIVADOHLS_ACC-distclean)

vivadohls_acc: $(VIVADOHLS_ACC-hls)

vivadohls_acc-clean: $(VIVADOHLS_ACC-clean)

vivadohls_acc-distclean: $(VIVADOHLS_ACC-distclean)

.PHONY: vivadohls_acc vivadohls_acc-clean vivadohls_acc-distclean

### hls4ml ###
$(HLS4ML_ACC-wdir): $(HLS_LOGS)
	$(QUIET_MKDIR)mkdir -p $(HLS4ML_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB)
	@cd $(HLS4ML_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
	if ! test -e project.tcl; then \
		cp ../hls/* .; \
		rm -f custom.tcl; \
		rm -f directives.tcl; \
		rm -f Makefile; \
		ln -s ../hls/custom.tcl; \
		ln -s ../hls/directives.tcl; \
		ln -s ../hls/Makefile; \
	fi;

$(HLS4ML_ACC-hls): %-hls : %-wdir
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(HLS4ML_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) hls | tee $(HLS_LOGS)/$(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(HLS4ML_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(HLS4ML_ACC-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(HLS4ML_ACC_PATH)/$(@:-clean=)/hw/hls-work-$(TECHLIB) clean
	@$(RM) $(HLS_LOGS)/$(@:-clean=)*.log

$(HLS4ML_ACC-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(HLS4ML_ACC_PATH)/$(@:-distclean=)/hw/hls-work-$(TECHLIB) distclean
	@$(RM) $(HLS_LOGS)/$(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: $(HLS4ML_ACC-wdir) $(HLS4ML_ACC-hls) $(HLS4ML_ACC-sim) $(HLS4ML_ACC-clean) $(HLS4ML_ACC-distclean)

hls4ml_acc: $(HLS4ML_ACC-hls)

hls4ml_acc-clean: $(HLS4ML_ACC-clean)

hls4ml_acc-distclean: $(HLS4ML_ACC-distclean)

.PHONY: hls4ml_acc hls4ml_acc-clean hls4ml_acc-distclean

### Catapult HLS ###
$(CATAPULTHLS_ACC-exe):
	$(QUIET_RUN) ACCELERATOR=$(@:-exe=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) DMA_WIDTH=$(DMA_WIDTH) RUN_ARGS="$(RUN_ARGS)" $(MAKE) -C $(CATAPULTHLS_ACC_PATH)/$(@:-exe=)/hw/sim run

$(CATAPULTHLS_ACC-wdir): $(HLS_LOGS)
	$(QUIET_MKDIR) if ! test -e $(CATAPULTHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); then \
		mkdir -p $(CATAPULTHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
		cd $(CATAPULTHLS_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
		ln -f -s ../hls/build_prj.tcl; \
		ln -f -s ../hls/build_prj_top.tcl; \
		ln -f -s ../hls/Makefile; \
		ln -f -s ../hls/rtl_sim.tcl; \
	fi;

$(CATAPULTHLS_ACC-hls): %-hls : %-wdir
	$(QUIET_INFO)echo "Running HLS for available implementations of $(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CATAPULTHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) hls | tee $(HLS_LOGS)/$(@:-hls=)_hls.log
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CATAPULTHLS_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(CATAPULTHLS_ACC-sim): %-sim : %-wdir
	$(QUIET_INFO)echo "Running RTL simulation for available implementations of $(@:-hls=)"
	$(QUIET_RUN)ACCELERATOR=$(@:-sim=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CATAPULTHLS_ACC_PATH)/$(@:-sim=)/hw/hls-work-$(TECHLIB) sim | tee $(HLS_LOGS)/$(@:-hls=)_hls.log

$(CATAPULTHLS_ACC-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CATAPULTHLS_ACC_PATH)/$(@:-clean=)/hw/hls-work-$(TECHLIB) clean
	@ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) DMA_WIDTH=$(NOC_WIDTH) $(MAKE) -C $(CATAPULTHLS_ACC_PATH)/$(@:-clean=)/hw/sim clean
	@$(RM) $(HLS_LOGS)/$(@:-clean=)*.log

$(CATAPULTHLS_ACC-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(CATAPULTHLS_ACC_PATH)/$(@:-distclean=)/hw/hls-work-$(TECHLIB) distclean
	@$(RM) $(HLS_LOGS)/$(@:-distclean=)*.log
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: $(CATAPULTHLS_ACC-wdir) $(CATAPULTHLS_ACC-hls) $(CATAPULTHLS_ACC-sim) $(CATAPULTHLS_ACC-clean) $(CATAPULTHLS_ACC-distclean)

catapulthls_acc: $(CATAPULTHLS_ACC-hls)

catapulthls_acc-clean: $(CATAPULTHLS_ACC-clean)

catapulthls_acc-distclean: $(CATAPULTHLS_ACC-distclean)

.PHONY: catapulthls_acc catapulthls_acc-clean catapulthls_acc-distclean

### RTL ###
$(RTL_ACC-wdir):
	$(QUIET_MKDIR)mkdir -p $(RTL_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB)
	@cd $(RTL_ACC_PATH)/$(@:-wdir=)/hw/hls-work-$(TECHLIB); \
	rm -f Makefile; \
	ln -s ../hls/Makefile

$(RTL_ACC-hls): %-hls : %-wdir
	$(QUIET_INFO)echo "Installing available implementations for $(@:-hls=) to $(ESP_ROOT)/tech/$(TECHLIB)/acc/$(@:-hls=)"
	$(QUIET_MAKE)ACCELERATOR=$(@:-hls=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(RTL_ACC_PATH)/$(@:-hls=)/hw/hls-work-$(TECHLIB) install
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-hls=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;
	@echo "$(@:-hls=)" >> $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log

$(RTL_ACC-clean): %-clean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-clean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(RTL_ACC_PATH)/$(@:-clean=)/hw/hls-work-$(TECHLIB) clean

$(RTL_ACC-distclean): %-distclean : %-wdir
	$(QUIET_CLEAN)ACCELERATOR=$(@:-distclean=) TECH=$(TECHLIB) ESP_ROOT=$(ESP_ROOT) make -C $(RTL_ACC_PATH)/$(@:-distclean=)/hw/hls-work-$(TECHLIB) distclean
	@if test -e $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; then \
		sed -i '/$(@:-distclean=)/d' $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log; \
	fi;

.PHONY: print-available-acc $(RTL_ACC-wdir) $(RTL_ACC-hls) $(RTL_ACC-clean) $(RTL_ACC-distclean)

rtl_acc: $(RTL_ACC-hls)

rtl_acc-clean: $(RTL_ACC-clean)

rtl_acc-distclean: $(RTL_ACC-distclean)

.PHONY: rtl_acc rtl_acc-clean rtl_acc-distclean

### Common ###
$(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log:
	touch $@

SOCKETGEN_DEPS  = $(ESP_ROOT)/tech/$(TECHLIB)/acc/installed.log
SOCKETGEN_DEPS += $(ESP_ROOT)/tools/socketgen/socketgen.py
SOCKETGEN_DEPS += $(wildcard $(ESP_ROOT)/tools/socketgen/templates/*.vhd)
SOCKETGEN_DEPS += $(ESP_CFG_BUILD)/socmap.vhd $(ESP_CFG_BUILD)/esp_global.vhd

### ESP Wrappers ###
socketgen: $(SOCKETGEN_DEPS)
	$(QUIET_MKDIR) $(RM) $@; mkdir -p $@
	$(QUIET_RUN)$(ESP_ROOT)/tools/socketgen/socketgen.py $(NOC_WIDTH) $(CPU_ARCH) $(ESP_ROOT)/tech/$(TECHLIB) $(ESP_ROOT)/accelerators/third-party $(ESP_ROOT)/tools/socketgen/templates ./socketgen
	@touch $@

socketgen-clean:

socketgen-distclean: socketgen-clean
	$(QUIET_CLEAN)$(RM) socketgen

.PHONY: socketgen-clean socketgen-distclean

## Device Drivers ##
$(ACC-driver): $(SOFT_BUILD)/sysroot $(SOFT_BUILD)/linux-build/vmlinux soft-build
	@BUILD_PATH=$(BUILD_DRIVERS)/$(@:-driver=)/linux/driver; \
	ACC_PATH=$(filter %/$(@:-driver=), $(ACC_PATHS)); \
	mkdir -p $$BUILD_PATH; \
	ln -sf $$ACC_PATH/sw/linux/driver/* $$BUILD_PATH; \
	if test -e $$BUILD_PATH/Makefile; then \
		echo '   ' MAKE $@; mkdir -p $(SOFT_BUILD)/sysroot/opt/drivers; \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) KSRC=$(SOFT_BUILD)/linux-build DRIVERS=$(DRV_LINUX) ACC_SW=$$ACC_PATH/sw $(MAKE) ESP_CORE_PATH=$(BUILD_DRIVERS)/esp DESIGN_PATH=$(DESIGN_PATH) -C $$BUILD_PATH; \
		if test -e $$BUILD_PATH/*.ko; then \
			echo '   ' CP $@; cp $$BUILD_PATH/*.ko $(SOFT_BUILD)/sysroot/opt/drivers/$(@:-driver=).ko; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACC-driver-clean):
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/$(@:-driver-clean=)/linux/driver

$(ACC-app): $(SOFT_BUILD)/sysroot soft-build
	@BUILD_PATH=$(BUILD_DRIVERS)/$(@:-app=)/linux/app; \
	ACC_PATH=$(filter %/$(@:-app=), $(ACC_PATHS)); \
	if [ `ls -1 $$ACC_PATH/sw/linux/app/*.c 2>/dev/null | wc -l ` -gt 0 ]; then \
		echo '   ' MAKE $@; \
		mkdir -p $(SOFT_BUILD)/sysroot/applications/test/; \
		mkdir -p $$BUILD_PATH; \
		CROSS_COMPILE=$(CROSS_COMPILE_LINUX) CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_LINUX) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$$BUILD_PATH $(MAKE) -C $$ACC_PATH/sw/linux/app; \
		if [ `ls -1 $$BUILD_PATH/*.exe 2>/dev/null | wc -l ` -gt 0 ]; then \
			if [ `ls -1 $$BUILD_PATH/*.exe 2>/dev/null | wc -l ` -eq 1 ]; then \
				echo '   ' CP $@; cp  $$BUILD_PATH/*.exe $(SOFT_BUILD)/sysroot/applications/test/$(@:-app=).exe ; \
			else \
				for f in $$BUILD_PATH/*.exe; do echo '   ' CP $@ $${f##*/}; cp $$f $(SOFT_BUILD)/sysroot/applications/test/$(@:-app=)_$${f##*/} ; done; \
			fi; \
			if [ `ls -1 $$ACC_PATH/sw/linux/app/*.so 2>/dev/null | wc -l ` -gt 0 ]; then \
				echo '   ' CP "shared libraries"; cp $$ACC_PATH/sw/linux/app/*.so $(SOFT_BUILD)/sysroot/lib/ ; \
			fi; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACC-app-clean):
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/$(@:-app-clean=)/linux/app

$(ACC-baremetal): $(BAREMETAL_BIN) soft-build $(ESP_CFG_BUILD)/socmap.vhd
	@BUILD_PATH=$(BUILD_DRIVERS)/$(@:-baremetal=)/baremetal; \
        ACC_PATH=$(filter %/$(@:-baremetal=), $(ACC_PATHS)); \
	if [ `ls -1 $$ACC_PATH/sw/baremetal/*.c 2>/dev/null | wc -l ` -gt 0 ]; then \
		echo '   ' MAKE $@; \
		mkdir -p $$BUILD_PATH; \
		CROSS_COMPILE=$(CROSS_COMPILE_ELF) CPU_ARCH=$(CPU_ARCH) DRIVERS=$(DRV_BARE) DESIGN_PATH=$(DESIGN_PATH)/$(ESP_CFG_BUILD) BUILD_PATH=$$BUILD_PATH $(MAKE) -C  $$ACC_PATH/sw/baremetal; \
		if [ `ls -1 $$BUILD_PATH/*.bin 2>/dev/null | wc -l ` -gt 0 ]; then \
			if [ `ls -1 $$BUILD_PATH/*.bin 2>/dev/null | wc -l ` -eq 1 ]; then \
				echo '   ' CP $@; cp $$BUILD_PATH/*.bin $(BAREMETAL_BIN)/$(@:-baremetal=).bin ; \
			else \
				for f in $$BUILD_PATH/*.bin; do echo '   ' CP $@ $${f##*/}; cp $$f $(BAREMETAL_BIN)/$(@:-baremetal=)_$${f##*/} ; done; \
			fi; \
		fi; \
		if [ `ls -1 $$BUILD_PATH/*.exe 2>/dev/null | wc -l ` -gt 0 ]; then \
			if [ `ls -1 $$BUILD_PATH/*.exe 2>/dev/null | wc -l ` -eq 1 ]; then \
				echo '   ' CP $@; cp $$BUILD_PATH/*.exe $(BAREMETAL_BIN)/$(@:-baremetal=).exe ; \
			else \
				for f in $$BUILD_PATH/*.exe; do echo '   ' CP $@ $${f##*/}; cp $$f $(BAREMETAL_BIN)/$(@:-baremetal=)_$${f##*/} ; done; \
			fi; \
		else \
			echo '   ' WARNING $@ compilation failed!; \
		fi; \
	else \
		echo '   ' WARNING $@ not found!; \
	fi;

$(ACC-baremetal-clean):
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/$(@:-baremetal-clean=)/baremetal

.PHONY: $(ACC-driver) $(ACC-driver-clean) $(ACC-app) $(ACC-app-clean) $(ACC-baremetal) $(ACC-baremetal-clean)

acc-driver: $(ACC-driver)

acc-driver-clean: $(ACC-driver-clean) contig-clean esp-clean esp-cache-clean

acc-app: $(ACC-app)

acc-app-clean: $(ACC-app-clean) test-clean libesp-clean

acc-baremetal: $(ACC-baremetal)

acc-baremetal-clean: $(ACC-baremetal-clean) probe-clean

esp-clean:
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/esp

esp-cache-clean:
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/esp_cache

contig-clean:
	$(QUIET_CLEAN)$(RM) $(BUILD_DRIVERS)/contig_alloc

probe-clean:
	$(QUIET_CLEAN) CROSS_COMPILE=$(CROSS_COMPILE_ELF) BUILD_PATH=$(BUILD_DRIVERS)/probe $(MAKE) -C $(DRV_BARE)/probe clean

test-clean:
	$(QUIET_CLEAN) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) BUILD_PATH=$(BUILD_DRIVERS)/test $(MAKE) -C $(DRV_LINUX)/test clean

libesp-clean:
	$(QUIET_CLEAN) CROSS_COMPILE=$(CROSS_COMPILE_LINUX) BUILD_PATH=$(BUILD_DRIVERS)/libesp $(MAKE) -C $(DRV_LINUX)/libesp clean

.PHONY: acc-driver acc-driver-clean acc-app acc-app-clean acc-baremetal acc -baremetal-clean probe-clean contig-clean esp-clean esp-cache-clean test-clean libesp-clean
