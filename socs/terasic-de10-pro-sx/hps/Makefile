# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

HOST_ARCH := $(shell uname -m 2>/dev/null || echo unknown)
HPS_CC_DEFAULT := gcc

ifeq ($(origin HPS_CC),undefined)
ifneq ($(origin CC),default)
HPS_CC := $(CC)
else
HPS_CC := $(HPS_CC_DEFAULT)
endif
endif

HPS_ALLOW_HOST_CC ?= 0
CFLAGS ?= -O2 -Wall -Wextra -std=c11
CPPFLAGS ?= -D_FILE_OFFSET_BITS=64
LDFLAGS ?=
LDLIBS ?=

TOOLS = esp_load_bootrom_edcl esp_peek

all: $(TOOLS)

$(TOOLS): check-compiler

check-compiler:
	@command -v "$(HPS_CC)" >/dev/null 2>&1 || { \
		echo "ERROR: HPS compiler not found: $(HPS_CC)"; \
		echo "       Build on the HPS with gcc, or set HPS_CC=<compiler>."; \
		false; \
	}
	@if test "$(HOST_ARCH)" != "aarch64" && test "$(HPS_ALLOW_HOST_CC)" != "1"; then \
		echo "ERROR: refusing to build HPS tools on $(HOST_ARCH)."; \
		echo "       Build these utilities directly on the DE10-Pro HPS Linux system."; \
		echo "       Set HPS_ALLOW_HOST_CC=1 only for unsupported manual experiments."; \
		false; \
	fi

esp_load_bootrom_edcl: esp_load_bootrom_edcl.c
	$(HPS_CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

esp_peek: esp_peek.c
	$(HPS_CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

clean:
	$(RM) $(TOOLS)

.PHONY: all check-compiler clean
