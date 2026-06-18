# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -std=c11
CPPFLAGS ?= -D_FILE_OFFSET_BITS=64

TOOLS = esp_load_bootrom_edcl esp_peek

all: $(TOOLS)

esp_load_bootrom_edcl: esp_load_bootrom_edcl.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o $@

esp_peek: esp_peek.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o $@

clean:
	$(RM) $(TOOLS)

.PHONY: all clean
