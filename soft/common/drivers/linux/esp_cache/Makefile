# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
include ../driver.mk

CFLAGS := $(CFLAGS) -Wall -Werror -O3 -I$(DRIVERS)/include -I$(DRIVERS)/../common/include -L.

include ./Kbuild
ESPINCLUDE = $(EXTRA_CFLAGS)
export ESPINCLUDE

Module.symvers:

