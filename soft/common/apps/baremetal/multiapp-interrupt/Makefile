# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
APPNAME := multiapp-interrupt
ifneq ($(filter $(CPU_ARCH),ariane cva6),)
include $(DRIVERS)/common_bare.mk
else
all:
	@echo "Skipping multiapp-interrupt: requires RV64 + PLIC (ariane/cva6)"
endif
