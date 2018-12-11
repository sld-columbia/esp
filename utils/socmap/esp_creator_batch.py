#!/usr/bin/env python3

###############################################################################
#
# ESP Wrapper Generator for Accelerators
#
# Copyright (c) 2014-2017, Columbia University
#
# @authors: Christian Pilato <pilato@cs.columbia.edu>
#           Paolo Mantovani <paolo@cs.columbia.edu>
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
  print("Usage                    : ./esp_creator.py <dma_width>")
  print("")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (currently supporting 32 bits only)")
  print("")

if len(sys.argv) != 2:
    print_usage()
    sys.exit(1)

DMA_WIDTH = int(sys.argv[1])

root = Tk()
soc = SoC_Config(DMA_WIDTH)
soc.noc = NoC()
x = soc.read_config(False)
if x == -1:
  print("Configuration is not available")
  sys.exit(-1)

esp_config = soc_config(soc)
create_socmap(esp_config, soc)
create_power(soc)
create_mmi64_regs(soc)

