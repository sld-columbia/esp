#!/usr/bin/env python3

# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from collections import defaultdict

######
# User defined constants for third-party accelerators

THIRDPARTY_COMPATIBLE = dict()
THIRDPARTY_IRQ_TYPE = dict() # IRQ line types: 0 (edge-sensitive), 1
                             # (level-sensitive)

# NVDLA                             
THIRDPARTY_COMPATIBLE["nv_nvdla"] = "nv_small"
THIRDPARTY_IRQ_TYPE["nv_nvdla"]   = "1"

#
######
