#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import soc as soclib
import socmap_gen as socgen
import NoCConfiguration as noclib 

from tkinter import *

def print_floorplan_constraints(fp, soc, esp_config):
  mem_num = 0
  mem_tiles = {}
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      mem_tiles[mem_num] = i
      mem_num += 1

  #4096 sets + 2 tiles
  if int((soc.llc_sets.get() * soc.llc_ways.get()) / (esp_config.nmem * 16)) == 2048:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X23Y0:SLICE_X206Y299}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y0:DSP48E2_X3Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X1Y0:RAMB18_X6Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X1Y0:RAMB36_X6Y59}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X209Y0:SLICE_X358Y299}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X5Y0:DSP48E2_X7Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X7Y0:RAMB18_X13Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X7Y0:RAMB36_X13Y59}\n")
  #2048 sets + 2 tiles or 4096 sets + 4 tiles
  elif int((soc.llc_sets.get() * soc.llc_ways.get()) / (esp_config.nmem * 16)) == 1024:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X34Y12:SLICE_X168Y310}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y6:DSP48E2_X2Y123}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X1Y6:RAMB18_X4Y123}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X1Y3:RAMB36_X4Y61}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X172Y11:SLICE_X336Y255}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X4Y6:DSP48E2_X7Y101}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X5Y6:RAMB18_X10Y101}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X5Y3:RAMB36_X10Y50}\n")
    if (esp_config.nmem == 4): 
      fp.write("create_pblock {pblock_mem_tile_2}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_2}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[2]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {SLICE_X34Y316:SLICE_X183Y602}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {DSP48E2_X0Y128:DSP48E2_X3Y239}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB18_X1Y128:RAMB18_X5Y239}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB36_X1Y64:RAMB36_X5Y119}\n")
      fp.write("create_pblock {pblock_mem_tile_3}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_3}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[3]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {SLICE_X176Y607:SLICE_X303Y822}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {DSP48E2_X4Y244:DSP48E2_X6Y327}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB18_X5Y244:RAMB18_X9Y327}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB36_X5Y122:RAMB36_X9Y163}\n")
      fp.write("create_pblock pblock_gen_mig.ddrc3\n")
      fp.write("add_cells_to_pblock [get_pblocks pblock_gen_mig.ddrc3] [get_cells -quiet [list gen_mig.ddrc3]]\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {SLICE_X263Y660:SLICE_X336Y839}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {DSP48E2_X6Y264:DSP48E2_X7Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB18_X9Y264:RAMB18_X10Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB36_X9Y132:RAMB36_X10Y167}\n")
#2048 sets + 4 tiles or 1024 sets + 2 tiles
  elif int((soc.llc_sets * soc.llc_ways) / (esp_config.nmem * 16)) == 512:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X20Y114:SLICE_X104Y298}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y46:DSP48E2_X1Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X1Y46:RAMB18_X3Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X1Y23:RAMB36_X3Y58}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X206Y299:SLICE_X303Y159}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X4Y64:DSP48E2_X6Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X6Y64:RAMB18_X9Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X6Y32:RAMB36_X9Y59}\n")
    if (esp_config.nmem == 4): 
      fp.write("create_pblock {pblock_mem_tile_2}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_2}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[2]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {SLICE_X21Y398:SLICE_X136Y578}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {DSP48E2_X0Y160:DSP48E2_X2Y229}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB18_X1Y160:RAMB18_X4Y229}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB36_X1Y80:RAMB36_X4Y114}\n")
      fp.write("create_pblock {pblock_mem_tile_3}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_3}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[3]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {SLICE_X211Y602:SLICE_X303Y791}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {DSP48E2_X5Y242:DSP48E2_X6Y315}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB18_X7Y242:RAMB18_X9Y315}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB36_X7Y121:RAMB36_X9Y157}\n")
      fp.write("create_pblock pblock_gen_mig.ddrc3\n")
      fp.write("add_cells_to_pblock [get_pblocks pblock_gen_mig.ddrc3] [get_cells -quiet [list gen_mig.ddrc3]]\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {SLICE_X263Y660:SLICE_X336Y839}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {DSP48E2_X6Y264:DSP48E2_X7Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB18_X9Y264:RAMB18_X10Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB36_X9Y132:RAMB36_X10Y167}\n")
  #1024 sets + 4 tiles or 512 sets + 2 tiles
  elif int((soc.llc_sets * soc.llc_ways) / (esp_config.nmem * 16)) == 256:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X31Y152:SLICE_X111Y298}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y62:DSP48E2_X1Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X1Y62:RAMB18_X3Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X1Y31:RAMB36_X3Y58}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X192Y166:SLICE_X296Y299}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X4Y68:DSP48E2_X5Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X6Y68:RAMB18_X8Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X6Y34:RAMB36_X8Y59}\n")
    if (esp_config.nmem == 4): 
      fp.write("create_pblock {pblock_mem_tile_2}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_2}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[2]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {SLICE_X33Y418:SLICE_X109Y559}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {DSP48E2_X0Y168:DSP48E2_X1Y223}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB18_X1Y168:RAMB18_X3Y223}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB36_X1Y84:RAMB36_X3Y111}\n")
      fp.write("create_pblock {pblock_mem_tile_3}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_3}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[3]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {SLICE_X193Y651:SLICE_X296Y788}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {DSP48E2_X4Y262:DSP48E2_X5Y313}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB18_X6Y262:RAMB18_X8Y313}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB36_X6Y131:RAMB36_X8Y156}\n")
  #512 or fewer sets + 4 tiles 
  elif esp_config.nmem == 4:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X36Y135:SLICE_X103Y297}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y54:DSP48E2_X1Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X2Y54:RAMB18_X3Y117}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X2Y27:RAMB36_X3Y58}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X212Y138:SLICE_X294Y299}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X5Y56:DSP48E2_X5Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X7Y56:RAMB18_X8Y119}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X7Y28:RAMB36_X8Y59}\n")
    fp.write("create_pblock {pblock_mem_tile_2}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_2}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[2]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {SLICE_X37Y419:SLICE_X110Y588}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {DSP48E2_X0Y168:DSP48E2_X1Y233}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB18_X2Y168:RAMB18_X3Y233}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB36_X2Y84:RAMB36_X3Y116}\n")
    fp.write("create_pblock {pblock_mem_tile_3}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_3}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[3]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {SLICE_X210Y642:SLICE_X293Y812}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {DSP48E2_X5Y258:DSP48E2_X5Y323}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB18_X7Y258:RAMB18_X8Y323}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB36_X7Y129:RAMB36_X8Y161}\n")
  
  fp.write("set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]\n")
  fp.write("set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]\n")
  fp.write("set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]\n")
  fp.write("connect_debug_port dbg_hub/clk [get_nets clk]\n")


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
 
  #  memory floorplanning for profpga-xcvu440
  if (soc.TECH == "virtexu") and esp_config.nmem > 1:
    fp = open('mem_tile_floorplanning.xdc', 'w')  
  
    print_floorplan_constraints(fp, soc, esp_config)
  
    fp.close()    
    print("Created floorplanning constraints for profgpa-xcvu440 into 'mem_tile_floorplanning.xdc'")


if __name__ == "__main__":
    main(sys.argv)


