#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import math
import soc as soclib
import socmap_gen as socgen
import NoCConfiguration as noclib 

from tkinter import *

def print_header(fp, package):
  fp.write("-- Copyright (c) 2011-2019 Columbia University, System Level Design Group\n")
  fp.write("-- SPDX-License-Identifier: Apache-2.0\n\n")

  fp.write("------------------------------------------------------------------------------\n")
  fp.write("--  This file is a configuration file for the ESP NoC-based architecture\n")
  fp.write("-----------------------------------------------------------------------------\n")
  fp.write("-- Package:     " + package + "\n")
  fp.write("-- File:        " + package + ".vhd\n")
  fp.write("-- Author:      Paolo Mantovani - SLD @ Columbia University\n")
  fp.write("-- Author:      Christian Pilato - SLD @ Columbia University\n")
  fp.write("-- Description: System address mapping and NoC tiles configuration\n")
  fp.write("------------------------------------------------------------------------------\n\n")

def print_libs(fp, std_only):
  fp.write("library ieee;\n")
  fp.write("use ieee.std_logic_1164.all;\n")
  fp.write("use ieee.numeric_std.all;\n")

  if not std_only:
    fp.write("use work.esp_global.all;\n")
    fp.write("use work.stdlib.all;\n")
    fp.write("use work.grlib_config.all;\n")
    fp.write("use work.amba.all;\n")
    fp.write("use work.sld_devices.all;\n")
    fp.write("use work.devices.all;\n")
    fp.write("use work.leon3.all;\n")
    fp.write("use work.nocpackage.all;\n")
    fp.write("use work.allcaches.all;\n")
    fp.write("use work.cachepackage.all;\n")

def print_global_constants(fp, soc):
  fp.write("  ------ Global architecture parameters\n")
  fp.write("  constant ARCH_BITS : integer := " + str(soc.DMA_WIDTH) + ";\n")
  fp.write("  constant GLOB_MEM_MAX_NUM : integer := " + str(socgen.NMEM_MAX) + ";\n")
  fp.write("  constant GLOB_CPU_MAX_NUM : integer := " + str(socgen.NCPU_MAX) + ";\n")
  fp.write("  constant GLOB_MAXIOSLV : integer := " + str(socgen.NAPBS) + ";\n")
  fp.write("  constant GLOB_TILES_MAX_NUM : integer := " + str(socgen.NTILE_MAX) + ";\n")
  # Keep cache-line size constant to 128 bits for now. We don't want huge line buffers
  fp.write("  constant GLOB_WORD_OFFSET_BITS : integer := " + str(int(math.log2(128/soc.DMA_WIDTH))) + ";\n")
  fp.write("  constant GLOB_BYTE_OFFSET_BITS : integer := " + str(int(math.log2(soc.DMA_WIDTH/8))) +";\n")
  fp.write("  constant GLOB_OFFSET_BITS : integer := GLOB_WORD_OFFSET_BITS + GLOB_BYTE_OFFSET_BITS;\n")
  fp.write("  constant GLOB_ADDR_INCR : integer := " + str(int(soc.DMA_WIDTH/8)) +";\n")
  # TODO: Keep physical address to 32 bits for now to reduce tag size. This will increase to support more memory
  fp.write("  constant GLOB_PHYS_ADDR_BITS : integer := " + str(32) +";\n")
  fp.write("  type cpu_arch_type is (leon3, ariane);\n")
  fp.write("  constant GLOB_CPU_ARCH : cpu_arch_type := " + soc.CPU_ARCH.get() + ";\n")
  if soc.CPU_ARCH == "leon3":
    fp.write("  constant GLOB_CPU_AXI : integer range 0 to 1 := 0;\n")
  else:
    fp.write("  constant GLOB_CPU_AXI : integer range 0 to 1 := 1;\n")
  fp.write("\n")
  # RTL caches
  if soc.cache_rtl == 1:
    fp.write("  constant CFG_CACHE_RTL   : integer := 1;\n")
  else:
    fp.write("  constant CFG_CACHE_RTL   : integer := 0;\n")

def main(argv):

  if len(sys.argv) != 4:
    sys.exit(1)

  root = Tk()
  DMA_WIDTH = int(sys.argv[1])
  TECH      = sys.argv[2]
  LINUX_MAC = sys.argv[3]
 
  soc = soclib.SoC_Config(DMA_WIDTH, TECH, LINUX_MAC)
  soc.noc = noclib.NoC()
  soc.read_config(False)

  fp = open('esp_global.vhd', 'w')

  print_header(fp, "esp_global")
  print_libs(fp, True)

  fp.write("package esp_global is\n\n")
  print_global_constants(fp, soc)

  fp.write("end esp_global;\n")
  fp.close()

  print("Created global constants definition into 'esp_global.vhd'")

if __name__ == "__main__":
    main(sys.argv)

