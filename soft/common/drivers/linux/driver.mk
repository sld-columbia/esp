# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
ifneq ($(filter cva6 ariane,$(CPU_ARCH)),)
CROSS_COMPILE ?= riscv64-unknown-linux-gnu-
ARCH ?= riscv
else # ("$(CPU_ARCH)", "leon3")
CROSS_COMPILE ?= sparc-linux-
ARCH ?= sparc
endif

ESP_CORE_PATH ?= $(DRIVERS)/esp
EXTRA_SYMBOLS := $(abspath $(ESP_CORE_PATH)/Module.symvers)
IS_ESP := $(filter esp,$(notdir $(CURDIR)))

all: check Module.symvers
	@if [ -n "$(IS_ESP)" ]; then \
		make -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) DESIGN_PATH=$(DESIGN_PATH); \
	else \
		make -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) DESIGN_PATH=$(DESIGN_PATH) KBUILD_EXTRA_SYMBOLS="$(EXTRA_SYMBOLS) $(KBUILD_EXTRA_SYMBOLS)"; \
	fi

check:
ifeq ($(KSRC),)
	$(error 'Path to kernel in env variable KSRC not found. Exiting')
endif
.PHONY: check

clean: check
	rm -rf $(ESP_CORE_PATH)

help: check
	$(MAKE) -C $(KSRC) M=`pwd` CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) help

.PHONY: all clean help
