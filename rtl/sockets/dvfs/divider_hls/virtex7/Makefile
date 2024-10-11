#*******************************************************************************
#
# Makefile - top-level project makefile
#
#*******************************************************************************

TECH=virtex7
ACCELERATOR=divider

ifeq ("$(XILINX_VIVADO)","")
$(error XILINX_VIVADO not set)
endif


# list subdirectories that contain memory libraries
# (must be in subdirectories of the current directory)
# MEMLIBS = ./memlib

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
# MEMORY_LIBRARY_DEPS = memlib/plm_block.bdm

Makefile.prj : $(MEMORY_LIBRARY_DEPS) project.tcl
	@bdw_makegen

# @bdw_memgen memlib/*.bdm

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
	@rm -rf *.csv
	@rm -rf .simvision
	@rm -rf .*check
	@rm -rf .*stratus*
	@rm -rf .*Xil*
	@rm -rf .*qws*
	@rm -rf ./memlib/c_parts/ ./memlib/memlib.bdl ./memlib/memlib.bdlb ./memlib/memlib.bdl.index ./memlib/v_rtl/

CLEAN: clean

distclean: clean

# WARNING: this target will delete generated resources for HLS
distclean-all: distclean
	@rm -rf cachelib

.PHONY: clean CLEAN distclean distclean-all
