#!/usr/bin/env python3

# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import soc as soclib
import NoCConfiguration as noclib 

from tkinter import *

def main(argv):

  if len(sys.argv) != 4:
    sys.exit(1)

  root = Tk()
  DMA_WIDTH = int(sys.argv[1])
  TECH      = sys.argv[2]
  LINUX_MAC = sys.argv[3]
  
  fp = open('power.h', 'w')

  fp.write("#ifndef __POWER_H__\n")
  fp.write("#define __POWER_H__\n\n")

  soc = soclib.SoC_Config(DMA_WIDTH, TECH, LINUX_MAC)
  soc.noc = noclib.NoC()
  soc.read_config(False) 

  vf_points = soc.noc.vf_points

  fp.write("const int energy_weight[TILES_NUM][" + str(vf_points) + "] = {\n")
  tiles = [None for x in range(soc.noc.rows * soc.noc.cols)]
  for x in range(soc.noc.rows): 
    for y in range(soc.noc.cols): 
      t = y + x * soc.noc.cols
      tiles[t] = soc.noc.topology[x][y]
  for t in range(len(tiles)):
    if t > 0:
      fp.write(",\n")
    fp.write("\t{")
    first = True
    for vf in reversed(tiles[t].energy_values.vf_points):
      if first == False:
        fp.write(", ")
      first = False
      if tiles[t].clk_region.get() > 0:
        fp.write(str(vf.energy))
      else:
        fp.write(str(tiles[t].energy_values.vf_points[0].energy))
    fp.write("}")
  fp.write("\n};\n\n")
  
  fp.write("const int period[TILES_NUM][" + str(vf_points) + "] = {\n")
  for t in range(len(tiles)):
    if t > 0:
      fp.write(",\n")
    fp.write("\t{")
    first = True
    for vf in reversed(tiles[t].energy_values.vf_points):
      if first == False:
        fp.write(", ")
      first = False
      period = 0
      frequency = 0
      if tiles[t].clk_region.get() > 0:
        frequency = vf.frequency
      else:
        frequency = tiles[t].energy_values.vf_points[0].frequency
      if frequency > 0:
        period = float(1000.0/frequency)
      value = round(period, 2)
      fp.write(str(value))
    fp.write("}")
  fp.write("\n};\n\n")

  fp.write("#endif /*  __POWER_H__ */\n")

  fp.close()
  print("Created configuration into 'power.h'")

if __name__ == "__main__":
    main(sys.argv)

