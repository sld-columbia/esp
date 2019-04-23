#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: MIT

###############################################################################
#
# ESP Wrapper Generator for Accelerators
#
###############################################################################

import sys

from tkinter import *
from tkinter import messagebox
from soc import *
from socmap_gen import *
from mmi64_gen import *
from power_gen import *

def print_usage():
  print("Usage                    : ./esp_creator.py <dma_width> <tech> <cpu_arch>")
  print("")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (currently supporting 32 bits only)")
  print("      <tech>             : Target technology (e.g. virtex7, virtexup, ...)")
  print("      <cpu_arch>         : Processor core: leon3, ariane)")
  print("")

if len(sys.argv) != 4:
    print_usage()
    sys.exit(1)

DMA_WIDTH = int(sys.argv[1])
TECH = sys.argv[2]
CPU_ARCH = sys.argv[3]

root = Tk()
soc = SoC_Config(DMA_WIDTH, TECH, CPU_ARCH)
soc.noc = NoC()
x = soc.read_config(False)
if x == -1:
  print("Configuration is not available")
  sys.exit(-1)

esp_config = soc_config(soc)
create_socmap(esp_config, soc)
create_power(soc)
create_mmi64_regs(soc)

