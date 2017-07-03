#*******************************************************************************
#
# Makefile - top-level project makefile
#
#*******************************************************************************
ifeq ("$(ESP_ROOT)","")
$(error ESP_ROOT not set)
endif

ifeq ("$(TECH)","")
$(error target technology TECH is not specified)
endif

ifeq ("$(ACCELERATOR)","")
# ACCELERATOR is not set
ifeq ("$(COMPONENT)","")
$(error Either COMPONENT or ACCELERATOR must be set)
endif

else
# ACCELERATOR is set
ifneq ("$(COMPONENT)","")
$(error Either COMPONENT or ACCELERATOR must be set)
endif

endif


ifneq ("$(ACCELERATOR)","")
TARGET_NAME = $(ACCELERATOR)
else
TARGET_NAME = $(COMPONENT)
endif

# list subdirectories that contain memory libraries
# (must be in subdirectories of the current directory)
MEMLIBS = ./memlib

# list subdirectories that contain interface libraries
# (must be in subdirectories of the current directory)
IFLIBS =

# Uncomment this line to use the Insight debugger
BDW_DEBUG = 1


saySimPassed:
	@bdw_sim_pass

# Disable timing checks
BDW_VLOGSIM_ARGS = -NOTIMINGCHECKS


# Memory wrappers
MEMGEN = $(ESP_ROOT)/utils/memgen/memgen.py
MEMTECH = $(ESP_ROOT)/tech/$(TECH)/mem
MEMGEN_OUT = $(ESP_ROOT)/tech/$(TECH)/memgen/$(TARGET_NAME)

ifneq ("$(ACCELERATOR)","")
RTL_OUT = $(ESP_ROOT)/tech/$(TECH)/acc/$(ACCELERATOR)
else
RTL_OUT = $(ESP_ROOT)/tech/$(TECH)/caches/$(COMPONENT)
endif

memlib: ../memlist.txt
	@$(MEMGEN) $(MEMTECH) $< $(MEMGEN_OUT) | tee memgen.log
	@count=`ls -1 memlib/*.bdm 2>/dev/null | wc -l`; \
	if [ $count != 0 ]; then \
		bdw_memgen ./memlib/*.bdm; \
	fi;

Makefile.prj: memlib project.tcl $(ESP_ROOT)/accelerators/common/stratus/project.tcl
	@bdw_makegen

-include Makefile.prj

install: Makefile.prj hls_all
	@mkdir -p $(RTL_OUT)
ifneq ("$(ACCELERATOR)","")
	@cp ../$(ACCELERATOR).xml $(RTL_OUT)
endif
	@for dir in $$(ls bdw_work/modules/$(TARGET_NAME)); do \
		if test -e bdw_work/modules/$(TARGET_NAME)/$$dir/$(TARGET_NAME)_rtl.v; then \
			cfg=$${dir,,}; \
			cp bdw_work/modules/$(TARGET_NAME)/$$dir/$(TARGET_NAME)_rtl.v $(RTL_OUT)/$(TARGET_NAME)_$$cfg\.v; \
			sed -i "s/module $(TARGET_NAME)/module $(TARGET_NAME)_$$cfg/g" $(RTL_OUT)/$(TARGET_NAME)_$$cfg.v; \
		fi; \
	done

nimbus.csv: Makefile.prj sim_all
	@bdw_shell ../../common/stratus/nimbus.tcl
	@sed -i 's/_/\\_/g' $@

plot: nimbus.csv
	@octave -qf ../../common/stratus/plot_results_octave.m $<

# Clean out undesirable junk files from the project directory
# Uses the automatically created clean_all target from Makefile.prj
clean: clean_all clean_libs
	@rm -f transcript vsim* *.wlf data.out
	@rm -f *~ *.bak *.BAK
	@rm -rf work debussy* vfast*
	@rm -f Makefile.prj
	@rm -f msg_help.html
	@rm -rf core
	@rm -rf core.*
	@rm -rf .stack.*
	@rm -rf *irun.history*
	@rm -rf *.pro *.pro.user
	@rm -rf INCA_libs
	@rm -rf *.log
	@rm -rf *.shm
	@rm -rf *.diag
	@rm -rf *.key
	@rm -rf memlib
	@rm -rf *.csv
	@rm -rf .simvision
	@rm -rf .Xil
	@rm -rf .fail*

CLEAN: clean

distclean: clean
	@rm -rf $(MEMGEN_OUT)
	@rm -rf $(RTL_OUT)

# WARNING: this target will delete generated resources for HLS
distclean-all: distclean
	@rm -rf cachelib

.PHONY: install plot  clean CLEAN distclean distclean-all
