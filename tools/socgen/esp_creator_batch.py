#!/usr/bin/env python3

# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

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
  print("Usage                    : ./esp_creator_batch.py <arch_bits> <tech_type> <tech> <linux_mac> <leon3_stack> <fpga_board> <emu_tech> <emu_freq>")
  print("")
  print("")
  print("      <arch_bits>        : Word size for CPU architecture (32 for Leon3/Ibex, 64 for Ariane)")
  print("      <tech_type>        : Technology type (fpga or asic)")
  print("      <tech>             : Target technology (e.g. virtex7, virtexu, virtexup, ...)")
  print("      <linux_mac>        : MAC Address for Linux network interface")
  print("      <leon3_stack>      : Stack Pointer for LEON3")
  print("      <fpga_board>       : Target FPGA board")
  print("      <emu_tech>         : Target technology override for FPGA emulation of ASIC design")
  print("      <emu_freq>         : Ethernet MDC scaler override for FPGA emulation of ASIC design")
  print("")

if len(sys.argv) != 9:
    print_usage()
    sys.exit(1)

ARCH_BITS = int(sys.argv[1])
TECH_TYPE = sys.argv[2]
TECH = sys.argv[3]
LINUX_MAC = sys.argv[4]
LEON3_STACK = sys.argv[5]
FPGA_BOARD = sys.argv[6]
EMU_TECH = sys.argv[7]
EMU_FREQ = sys.argv[8]

root = Tk()
soc = SoC_Config(ARCH_BITS, TECH_TYPE, TECH, LINUX_MAC, LEON3_STACK, FPGA_BOARD, EMU_TECH, EMU_FREQ, False)

esp_config = soc_config(soc)
create_socmap(esp_config, soc)
create_power(soc)
create_mmi64_regs(soc)
