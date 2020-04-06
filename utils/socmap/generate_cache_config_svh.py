#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import soc as soclib
import socmap_gen as socgen
import NoCConfiguration as noclib 

from tkinter import *

def print_cache_config(fp, soc, esp_config):
  fp.write("`ifndef __CACHES_CFG_SVH__\n")
  fp.write("`define __CACHES_CFG_SVH__\n")
  fp.write("\n")
  addr_bits = 32
  byte_bits = 2
  word_bits = 2
  if soc.CPU_ARCH == "ariane":
    addr_bits = 32
    byte_bits = 3
    word_bits = 1
    fp.write("`define LITTLE_ENDIAN\n")
  else: 
    fp.write("`define BIG_ENDIAN\n")

  fp.write("`define ADDR_BITS    " + str(addr_bits) + "\n")
  fp.write("`define BYTE_BITS    " + str(byte_bits) + "\n")
  fp.write("`define WORD_BITS    " + str(word_bits) + "\n")
  fp.write("`define L2_WAYS      " + str(soc.l2_ways) + "\n")
  fp.write("`define L2_SETS      " + str(soc.l2_sets) + "\n")
  fp.write("`define LLC_WAYS     " + str(soc.llc_ways) + "\n")
  fp.write("`define LLC_SETS     " + str(int(soc.llc_sets.get() / esp_config.nmem)) + "\n")
  fp.write("\n")
  fp.write("`endif // __CACHES_CFG_SVH__\n")

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

  esp_config = socgen.soc_config(soc)
 
  # RTL Caches configuration
  fp = open('cache_cfg.svh', 'w')

  print_cache_config(fp, soc, esp_config)

  fp.close()
  
  print("Created RTL caches configuration into 'cache_cfg.svh'")


if __name__ == "__main__":
    main(sys.argv)

