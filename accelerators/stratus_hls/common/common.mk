# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Some pretty aliases ###

# Define V=1 for a more verbose compilation
ifndef V
	QUIET_AR            = @echo '   ' AR $@;
	QUIET_AS            = @echo '   ' AS $@;
	QUIET_BUILD         = @echo '   ' BUILD $@;
	QUIET_CHMOD         = @echo '   ' CHMOD $@;
	QUIET_CC            = @echo '   ' CC $@;
	QUIET_CXX           = @echo '   ' CXX $@;
	QUIET_OBJCP         = @echo '   ' OBJCP $@;
	QUIET_CHECKPATCH    = @echo '   ' CHECKPATCH $(subst .o,.c,$@);
	QUIET_CHECK         = @echo '   ' CHECK $(subst .o,.c,$@);
	QUIET_LINK          = @echo '   ' LINK $@;
	QUIET_CP            = @echo '   ' CP $@;
	QUIET_RM            = @echo '   ' RM $@;
	QUIET_MKDIR         = @echo '   ' MKDIR $@;
	QUIET_MAKE          = @echo '   ' MAKE $@;
	QUIET_INFO          = @echo -n '   ' INFO '';
	QUIET_DIFF          = @echo -n '   ' DIFF '';
	QUIET_RUN           = @echo '   ' RUN $@;
	QUIET_CLEAN         = @echo '   ' CLEAN $@;
endif
	SPACES              = "    "
	SPACING             = echo -n "    ";

RM  = rm -rf


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

# Memory wrappers
MEMGEN = $(ESP_ROOT)/tools/plmgen/plmgen.py
MEMTECH = $(ESP_ROOT)/rtl/techmap/$(TECH)/mem
MEMGEN_OUT = $(ESP_ROOT)/tech/$(TECH)/memgen/$(TARGET_NAME)

ifneq ("$(ACCELERATOR)","")
RTL_OUT = $(ESP_ROOT)/tech/$(TECH)/acc/$(ACCELERATOR)
else
RTL_OUT = $(ESP_ROOT)/tech/$(TECH)/sccs/$(COMPONENT)
endif
