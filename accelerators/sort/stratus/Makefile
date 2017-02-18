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

-include Makefile.prj

# Memory wrappers
MEMGEN = $(ESP_ROOT)/utils/memgen/memgen.py
MEMTECH = $(ESP_ROOT)/tech/$(TECH)/mem
MEMGEN_OUT = $(ESP_ROOT)/tech/$(TECH)/memgen

memlib: ../memlist.txt
	@$(MEMGEN) $(MEMTECH) $< $(MEMGEN_OUT) | tee memgen.log
	@bdw_memgen ./memlib/*.bdm

Makefile.prj : memlib project.tcl ../../common/stratus/project.tcl
	@bdw_makegen

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

CLEAN: clean

# WARNING: this target will delete generated resources for HLS
distclean: clean
	@rm -rf cachelib

.PHONY: clean CLEAN distclean
