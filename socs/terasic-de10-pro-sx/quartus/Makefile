################################################
#
# Makefile to Manage Quartus Prime Pro / QSys Design
#
# Copyright Intel (c) 2017
# All Rights Reserved
#
################################################

SHELL := /bin/bash

.SECONDEXPANSION:
.SUFFIXES:
.DELETE_ON_ERROR:

################################################
# Tools

CAT := cat
CD := cd
CHMOD := chmod
CP := cp -rf
DATE := date
ECHO := echo
FIND := find
GREP := grep
HEAD := head
MKDIR := mkdir -p
MV := mv
RM := rm -rf
SED := sed
TAR := tar
TOUCH := touch
WHICH := which

# Helpful Macros
SPACE := $(empty) $(empty)

# Convert upper case string to lower case string
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

ifndef COMSPEC
ifdef ComSpec
COMSPEC = $(ComSpec)
endif # ComSpec
endif # COMSPEC

ifdef COMSPEC # if Windows OS
IS_WINDOWS_HOST := 1
endif

ifeq ($(IS_WINDOWS_HOST),1)
ifneq ($(shell $(WHICH) cygwin1.dll 2>/dev/null),)
IS_CYGWIN_HOST := 1
endif
endif

ifneq ($(shell $(WHICH) quartus 2>/dev/null),)
HAVE_QUARTUS := 1
endif

ifeq ($(HAVE_QUARTUS),1)
HAVE_QSYS := 1
endif

################################################


################################################
#
# Family and Device
# QUARTUS_DEVICE to Board Revision Mapping

QUARTUS_DEVICE_FAMILY := Stratix\ 10
# For DE10_Pro Rev D, use:
QUARTUS_DEVICE := 1SX280HU2F50E1VG

################################################
.PHONY: default
default: help
################################################

################################################
.PHONY: all
all:

ifeq ($(HAVE_QUARTUS),1)
all: sof rbf jic
endif
################################################


################################################
# Target Stamping

ifeq ($(SOCEDS_DEST_ROOT),)
$(warning WARNING: SOCEDS_DEST_ROOT not set)
endif

SOCEDS_VERSION = $(if $(wildcard $(SOCEDS_DEST_ROOT)/version.txt),$(shell $(CAT) $(SOCEDS_DEST_ROOT)/version.txt 2>/dev/null | $(GREP) Version | $(HEAD) -n1 | $(SED) -e 's,^Version[: \t=]*\([0-9.]*\).*,\1,g' 2>/dev/null))

define get_stamp_dir
stamp$(if $(SOCEDS_VERSION),/$(SOCEDS_VERSION))
endef

define get_stamp_target
$(get_stamp_dir)$(if $1,/$1.stamp,$(error ERROR: Arg 1 missing to $0 function))
endef

define stamp_target
@$(MKDIR) $(@D)
@$(TOUCH) $@
endef

.PHONY: clean
clean:
	@$(ECHO) "Cleaning stamp files (which will trigger rebuild)"
	@$(RM) $(get_stamp_dir)
	@$(ECHO) " TIP: Use 'make scrub_clean' to get a deeper clean"
################################################


################################################
# Archiving & Cleaning your QuartusII/QSys Project

AR_TIMESTAMP := $(if $(SOCEDS_VERSION),$(subst .,_,$(SOCEDS_VERSION))_)$(subst $(SPACE),,$(shell $(DATE) +%m%d%Y_%k%M%S))

AR_DIR := tgz
AR_FILE := $(AR_DIR)/$(basename $(firstword $(wildcard *.qpf)))_$(AR_TIMESTAMP).tar.gz

SOFTWARE_DIR := software
BOOTLOADER_DIR := $(SOFTWARE_DIR)/u-boot

AR_REGEX += \
	Makefile ip *.txt ds5 software \
	altera_avalon* *.qpf *.qsf *.sdc *.v *.sv *.vhd *.qsys *.tcl *.terp *.stp *.mk \
	*.hex *.sed quartus.ini *.sof *.rbf *.sopcinfo */*.sopcinfo *.jdi output_files \
	hps_isw_handoff handoff.bin */*.svd */synthesis/*.svd */synth/*.svd *.dts *.dtb *.xml \
	patches

AR_FILTER_OUT += %_tb.qsys
################################################



################################################
# Build QuartusII/QSys Project
#

#############
# QSys
QSYS_FILE_TOP := qsys_top.qsys
QSYS_FILE_TOP ?= $(firstword $(wildcard *top*.qsys) $(wildcard ghrd*.qsys) $(wildcard *main*.qsys) $(wildcard *soc*.qsys) $(wildcard *.qsys))

OTHER_QSYS_FILES :=

QSYS_FILES += $(QSYS_FILE_TOP) $(OTHER_QSYS_FILES)

ifeq ($(QSYS_FILE_TOP),)
$(error ERROR: QSYS_FILE_TOP *.qsys file not set and could not be discovered)
endif

QSYS_DEPS += $(sort $(QSYS_FILES) $(filter-out pr_%.qsys,$(wildcard *.qsys)))

QSYS_BASE_TOP := $(basename $(QSYS_FILE_TOP))
QSYS_GEN_DIRS := $(foreach qsys_file,$(QSYS_FILES),$(dir $(qsys_file))$(notdir $(basename $(qsys_file))))

QSYS_QIP_FILES := $(foreach qsys_file,$(QSYS_FILES),$(dir $(qsys_file))$(notdir $(basename $(qsys_file)))/$(basename $(notdir $(qsys_file))).qip)

QSYS_SOPCINFO := $(QSYS_BASE_TOP)/$(QSYS_BASE_TOP).sopcinfo
QSYS_STAMP := $(foreach qsys_file,$(QSYS_FILES),$(call get_stamp_target,$(qsys_file).qsys_gen))

# Under cygwin, ensure TMP env variable is not a cygwin style path
# before calling qsys-generate
ifeq ($(IS_CYGWIN_HOST),1)
ifneq ($(shell $(WHICH) cygpath 2>/dev/null),)
SET_QSYS_GENERATE_ENV = TMP="$(shell cygpath -m "$(TMP)")"
endif
endif

.PHONY: qsys_compile
qsys_compile: $(QSYS_STAMP)

ifeq ($(HAVE_QSYS),1)
$(QSYS_SOPCINFO) $(QSYS_QIP_FILES): $(QSYS_STAMP)
	@if [ ! -f "$@" ]; then echo "ERROR: $@ not generated" && false; fi
	$(stamp_target)
endif

QSYS_ARGS += --quartus-project=$(QUARTUS_QPF)
QSYS_ARGS += --rev=$(QUARTUS_BASE_REVISION)
QSYS_GENERATE_ARGS = $(QSYS_ARGS)
QSYS_GENERATE_ARGS += --clear-output-directory

$(QSYS_STAMP): $(get_stamp_dir)/%.qsys_gen.stamp: % $(QSYS_DEPS)
	$(SET_QSYS_GENERATE_ENV) qsys-generate $(QSYS_GENERATE_ARGS) $< --upgrade-ip-cores
	$(SET_QSYS_GENERATE_ENV) qsys-script --qpf=none --script=update_sysid.tcl --system-file=$<
	$(SET_QSYS_GENERATE_ENV) qsys-generate $(QSYS_GENERATE_ARGS) $< --synthesis=VERILOG
	$(stamp_target)

HELP_TARGETS += qsys_edit

qsys_edit.HELP := Launch QSys GUI
ifneq ($(HAVE_QSYS),1)
qsys_edit.HELP := $(qsys_edit.HELP) (Install Quartus II Software to enable)
endif

.PHONY: qsys_edit
qsys_edit:
	qsys-edit $(QSYS_ARGS) $(QSYS_FILE_TOP) &

SCRUB_CLEAN_FILES += $(wildcard .qsys_edit)

ifeq ($(HAVE_QSYS),1)
SCRUB_CLEAN_FILES += $(QSYS_QIP_FILES) $(QSYS_SOPCINFO) $(QSYS_GEN_DIRS)
endif

#############
# Quartus II

QUARTUS_QPF := DE10_Pro_GHRD.qpf

ifeq ($(QUARTUS_QPF),)
$(error ERROR: QUARTUS_QPF *.qpf file not set and could not be discovered)
endif
QUARTUS_BASE := $(basename $(QUARTUS_QPF))
QUARTUS_HDL_SOURCE := $(wildcard *.v *.sv *.vhd)
QUARTUS_MISC_SOURCE := $(wildcard *.stp *.sdc)
QUARTUS_BASE_REVISION := $(QUARTUS_BASE)
QUARTUS_QSF := $(QUARTUS_BASE_REVISION).qsf

QUARTUS_DEPS += $(QUARTUS_QSF) $(QUARTUS_HDL_SOURCE) $(QUARTUS_MISC_SOURCE) $(QSYS_STAMP) $(QSYS_QIP_FILES)

QUARTUS_OUTPUT_DIR := output_files
QUARTUS_SOF := $(QUARTUS_OUTPUT_DIR)/$(QUARTUS_BASE).sof
QUARTUS_SOF_WITH_HPS := $(patsubst %.sof,%_hps.sof,$(QUARTUS_SOF))
QUARTUS_SOF_WITH_HPS_DEBUG := $(patsubst %.sof,%_hps_debug.sof,$(QUARTUS_SOF))
QUARTUS_RBF := $(patsubst %.sof,%.rbf,$(QUARTUS_SOF_WITH_HPS))
QUARTUS_STAMP := $(call get_stamp_target,quartus)

.PHONY: quartus_compile
quartus_compile: $(QUARTUS_STAMP)

.PHONY: prepare_esp_rtl
prepare_esp_rtl:
	$(MAKE) -C .. DESIGN_PATH=$(abspath ..) ESP_ROOT=$(abspath ../../..) quartus-srcs
	@test -r srcs_auto.tcl || { echo "ERROR: srcs_auto.tcl was not generated by 'make quartus-srcs'"; false; }

ifeq ($(HAVE_QUARTUS),1)
$(QUARTUS_SOF): $(QUARTUS_STAMP)
endif

$(QUARTUS_STAMP): prepare_esp_rtl $(QUARTUS_DEPS)
	quartus_sh -t setup.tcl
	quartus_stp $(QUARTUS_BASE) -c $(QUARTUS_BASE_REVISION)
	quartus_sh --flow compile $(QUARTUS_QPF) -c $(QUARTUS_BASE_REVISION)
	$(stamp_target)

HELP_TARGETS += quartus_edit
quartus_edit.HELP := Launch Quartus Prime GUI

ifneq ($(HAVE_QUARTUS),1)
quartus_edit.HELP := $(quartus_edit.HELP) (Install Quartus II Software to enable)
endif

.PHONY: quartus_setup
quartus_setup: prepare_esp_rtl
	quartus_sh -t setup.tcl

.PHONY: quartus_edit
quartus_edit: quartus_setup
	quartus $(QUARTUS_QPF) &

HELP_TARGETS += sof
sof.HELP := QSys generate & Quartus compile this design
ifneq ($(HAVE_QUARTUS),1)
sof.HELP := $(sof.HELP) (Install Quartus II Software to enable)
endif

BATCH_TARGETS += sof

.PHONY: sof
sof: $(QUARTUS_SOF) $(QUARTUS_SOF_WITH_HPS)

ifneq ($(IS_WINDOWS_HOST),1)
sof:  $(QUARTUS_SOF_WITH_HPS_DEBUG)
endif

#####################


#####################

ifeq ($(HAVE_QUARTUS),1)
QUARTUS_RBF_STAMP := $(call get_stamp_target,quartus_rbf)
$(QUARTUS_RBF_STAMP): $(QUARTUS_STAMP)
endif

.PHONY: rbf
rbf: $(QUARTUS_RBF)

$(QUARTUS_RBF): $(QUARTUS_RBF_STAMP)

$(QUARTUS_RBF_STAMP): $(QUARTUS_SOF_WITH_HPS)
	@$(MKDIR) $(dir $(QUARTUS_RBF))
	quartus_cpf --convert $(QUARTUS_CPF_ARGS) $(QUARTUS_SOF_WITH_HPS) $(QUARTUS_RBF)
	$(stamp_target)

$(QUARTUS_SOF_WITH_HPS): $(QUARTUS_SOF) $(QUARTUS_CPF_DEPS) software/u-boot/spl/u-boot-spl-dtb.hex
	@$(MKDIR) $(@D)
	quartus_cpf --bootloader=software/u-boot/spl/u-boot-spl-dtb.hex $< $@

QUARTUS_JIC := $(patsubst %.sof,%.jic,$(QUARTUS_SOF_WITH_HPS))

.PHONY: jic
jic: $(QUARTUS_JIC)

$(QUARTUS_JIC): $(QUARTUS_SOF_WITH_HPS)
	@$(MKDIR) $(@D)
	quartus_cpf -c -o auto_create_rpd=on -o rpd_little_endian=off -o memory_map_file=on -d MT25QU01G -s $(QUARTUS_DEVICE) $< $@


ifeq ($(HAVE_QUARTUS),1)
SCRUB_CLEAN_FILES += $(QUARTUS_SOF) $(QUARTUS_SOF_WITH_HPS) $(QUARTUS_SOF_WITH_HPS_DEBUG) $(QUARTUS_RBF) $(QUARTUS_JIC) $(QUARTUS_OUTPUT_DIR)
endif

################################################


################################################
# Quartus Programming
QUARTUS_PGM_STAMP := $(call get_stamp_target,quartus_pgm)

# Set BOARD_CABLE to an exact jtagconfig cable string when multiple boards are
# visible. BOARD_CABLE_MATCH may be a shorter identifying substring.
BOARD_CABLE ?=
BOARD_CABLE_MATCH ?=
INTEL_ISSP_SERVICE_MATCH ?=

# Default to 1 since this is the most common setting
BOARD_DEVICE_INDEX ?= 1


# issp_reset.tcl is required because of the issue described in CASE:487915
define quartus_pgm_sof
BOARD_CABLE="$(BOARD_CABLE)" BOARD_CABLE_MATCH="$(BOARD_CABLE_MATCH)" BOARD_DEVICE_INDEX="$(BOARD_DEVICE_INDEX)" INTEL_ISSP_SERVICE_MATCH="$(INTEL_ISSP_SERVICE_MATCH)" bash ./program_sof.sh "$1"
endef

.PHONY: pgm
pgm: $(QUARTUS_PGM_STAMP)

$(QUARTUS_PGM_STAMP): $(QUARTUS_SOF_WITH_HPS)
	$(call quartus_pgm_sof,$<)
	$(stamp_target)

HELP_TARGETS += program_fpga
program_fpga.HELP := Quartus program sof to your attached dev board

.PHONY: program_fpga
program_fpga:
	$(call quartus_pgm_sof,$(QUARTUS_SOF_WITH_HPS))
################################################


################################################
# Clean-up and Archive

AR_FILES += $(filter-out $(AR_FILTER_OUT),$(wildcard $(AR_REGEX)))

CLEAN_FILES += $(filter-out $(AR_DIR) $(AR_FILES),$(wildcard *))

HELP_TARGETS += tgz
tgz.HELP := Create a tarball with the barebones source files that comprise this design

.PHONY: tarball tgz
tarball tgz: $(AR_FILE)

$(AR_FILE):
	@$(MKDIR) $(@D)
	@$(if $(wildcard $(@D)/*.tar.gz),$(MKDIR) $(@D)/.archive;$(MV) $(@D)/*.tar.gz $(@D)/.archive)
	@$(ECHO) "Generating $@..."
	@$(TAR) -czf $@ $(AR_FILES)

SCRUB_CLEAN_FILES += $(CLEAN_FILES)

HELP_TARGETS += scrub_clean
scrub_clean.HELP := Restore design to its barebones state

.PHONY: scrub scrub_clean
scrub scrub_clean:
	$(if $(strip $(wildcard $(SCRUB_CLEAN_FILES))),$(RM) $(wildcard $(SCRUB_CLEAN_FILES)),@$(ECHO) "You're already as clean as it gets!")

.PHONY: tgz_scrub_clean
tgz_scrub_clean:
	$(FIND) $(SOFTWARE_DIR) \( -name '*.o' -o -name '.depend*' -o -name '*.d' -o -name '*.dep' \) -delete || true
	$(MAKE) tgz AR_FILE=$(AR_FILE)
	$(MAKE) -s scrub_clean
	$(TAR) -xzf $(AR_FILE)

################################################


################################################
# Running Batch Jobs
ifneq ($(BATCH_TARGETS),)

BATCH_DIR := $(if $(TMP),$(TMP)/)batch/$(AR_TIMESTAMP)

.PHONY: $(patsubst %,batch-%,$(BATCH_TARGETS))
$(patsubst %,batch-%,$(BATCH_TARGETS)): batch-%: $(AR_FILE)
	@$(RM) $(BATCH_DIR)
	@$(MKDIR) $(BATCH_DIR)
	$(CP) $< $(BATCH_DIR)
	$(CD) $(BATCH_DIR) && $(TAR) -xzf $(notdir $<) && $(CHMOD) -R 755 *
	$(MAKE) -C $(BATCH_DIR) $*

endif # BATCH_TARGETS != <empty>
################################################


################################################
# Help system

HELP_TARGETS += help
help.HELP := Displays this info (i.e. the available targets)

.PHONY: help
help: help-init help-targets help-fini

HELP_TARGETS_X := $(patsubst %,help-%,$(sort $(HELP_TARGETS)))
.PHONY: $(HELP_TARGETS_X)
help-targets: $(HELP_TARGETS_X)
$(HELP_TARGETS_X): help-%:
	@$(ECHO) "*********************"
	@$(ECHO) "* Target: $*"
	@$(ECHO) "*   $($*.HELP)"

.PHONY: help-init
help-init:
	@$(ECHO) "*****************************************"
	@$(ECHO) "*                                       *"
	@$(ECHO) "* Manage Quartus Prime / QSys Design    *"
	@$(ECHO) "*                                       *"
	@$(ECHO) "*     Copyright (c) 2017                *"
	@$(ECHO) "*     All Rights Reserved               *"
	@$(ECHO) "*                                       *"
	@$(ECHO) "*****************************************"
	@$(ECHO) ""

.PHONY: help-fini
help-fini:
	@$(ECHO) "*********************"

################################################
