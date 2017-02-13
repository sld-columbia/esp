#*******************************************************************************
#
# Makefile - top-level project makefile
#
#*******************************************************************************
# list subdirectories that contain memory libraries
# (must be in subdirectories of the current directory)
MEMLIBS =

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

Makefile.prj : project.tcl ../../common/stratus/project.tcl
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

CLEAN: clean
