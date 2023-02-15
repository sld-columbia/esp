#!/usr/bin/env python3

# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from soc import *
from NoCConfiguration import *

def create_mmi64_regs(soc):
  fp = open('mmi64_regs.h', 'w')

  fp.write("#ifndef __MMI64_REGS_H__\n")
  fp.write("#define __MMI64_REGS_H__\n\n")

  num_nocs = 2
  num_acc = soc.noc.get_acc_num(soc)
  num_tiles = soc.noc.rows * soc.noc.cols
  num_cpu = soc.noc.get_cpu_num(soc)

  vf_points = soc.noc.vf_points
  directions = 5
  mem_mon_regs = 8
  acc_mon_regs = 5
  cache_mon_regs = 2

  num_l2 = num_cpu + num_acc
  num_llc = soc.noc.get_mem_num(soc)

  fp.write("#define DDRS_NUM " + str(soc.noc.get_mem_num(soc)) + "\n")
  fp.write("#define MEMS_NUM " + str(num_llc) + "\n")
  fp.write("#define NOCS_NUM " + str(num_nocs) + "\n")
  fp.write("#define TILES_NUM " + str(num_tiles) + "\n")
  fp.write("#define XLEN " + str(soc.noc.cols) + "\n")
  fp.write("#define YLEN " + str(soc.noc.rows) + "\n")
  fp.write("#define ACCS_NUM " + str(num_acc) + "\n")
  fp.write("#define VF_OP_POINTS " + str(vf_points) + "\n")
  fp.write("#define DIRECTIONS " + str(directions) + "\n")
  fp.write("#define L2S_NUM " + str(num_l2) + "\n")
  fp.write("#define LLCS_NUM " + str(num_llc) + "\n")

  ddr_offset = 0
  mem_offset = 0
  inj_offset = 0
  routers_offset = 0
  accelerators_offset = 0
  dvfs_offset = 0
  l2_offset = 0
  llc_offset = 0
  if soc.noc.monitor_ddr.get() == 1:
    fp.write("#define DDR_offset 0\n")
  ddr_offset = soc.noc.get_mem_num(soc) * soc.noc.monitor_ddr.get()
  if soc.noc.monitor_mem.get() == 1:
    fp.write("#define MEM_offset " + str(ddr_offset) + "\n")
  mem_offset = ddr_offset + ((num_llc-1) * mem_mon_regs + mem_mon_regs) * soc.noc.monitor_mem.get()
  if soc.noc.monitor_inj.get() == 1:
    fp.write("#define NOC_INJECT_offset " + str(mem_offset) + "\n")
  inj_offset = mem_offset + (((num_nocs-1) * num_tiles) + num_tiles) * soc.noc.monitor_inj.get()
  if soc.noc.monitor_routers.get() == 1:
    fp.write("#define NOC_QUEUES_offset " + str(inj_offset) + "\n")
  routers_offset = inj_offset + ((num_nocs-1) * num_tiles * directions + ((num_tiles-1) * directions) + directions) * soc.noc.monitor_routers.get()
  if soc.noc.monitor_accelerators.get() == 1:
    fp.write("#define ACC_offset " + str(routers_offset) + "\n")
  accelerators_offset = routers_offset + ((num_acc-1) * acc_mon_regs + acc_mon_regs) * soc.noc.monitor_accelerators.get()
  if soc.noc.monitor_l2.get() == 1:
    fp.write("#define L2_offset " + str(accelerators_offset) + "\n")
  l2_offset = accelerators_offset + ((num_l2-1) * cache_mon_regs + cache_mon_regs) * soc.noc.monitor_l2.get()
  if soc.noc.monitor_llc.get() == 1:
    fp.write("#define LLC_offset " + str(l2_offset) + "\n")
  llc_offset = l2_offset + ((num_llc-1) * cache_mon_regs + cache_mon_regs) * soc.noc.monitor_llc.get()
  if soc.noc.monitor_dvfs.get() == 1:
    fp.write("#define DVFS_offset " + str(llc_offset) + "\n")
  dvfs_offset = llc_offset + ((num_tiles-1) * vf_points + vf_points) * soc.noc.monitor_dvfs.get()

  fp.write("#define MONITOR_REG_COUNT " + str(dvfs_offset) + "\n")
  fp.write("#define MONITOR_RESET_offset " + str(dvfs_offset) + "\n")
  fp.write("#define MONITOR_WINDOW_SIZE_offset " + str(dvfs_offset+1) + "\n")
  fp.write("#define MONITOR_WINDOW_LO_offset " + str(dvfs_offset+2) + "\n")
  fp.write("#define MONITOR_WINDOW_HI_offset " + str(dvfs_offset+3) + "\n")
  fp.write("#define TOTAL_REG_COUNT " + str(dvfs_offset+4) + "\n\n")

  fp.write("struct local_yx {\n")
  fp.write("unsigned y;\n")
  fp.write("unsigned x;\n")
  fp.write("};\n\n")

  fp.write("enum tile_type {\n")
  fp.write("empty_tile,\n")
  fp.write("cpu_tile,\n")
  fp.write("accelerator_tile,\n")
  fp.write("misc_tile,\n")
  fp.write("memory_tile,\n")
  fp.write("};\n\n")

  fp.write("struct tile_info {\n")
  fp.write("unsigned id;\n")
  fp.write("int type;\n")
  fp.write("struct local_yx position;\n")
  fp.write("char *name;\n")
  fp.write("int has_pll; /* this tile's PLL drives all tiles in the domain */\n")
  fp.write("int domain; /* if 0 then no DVFS */\n")
  fp.write("int domain_master; /* ID of the tile where the PLL for this domain is located */\n")
  fp.write("};\n\n")

  fp.write("const struct tile_info tiles[TILES_NUM] = {\n")
  tiles = [None for x in range(soc.noc.rows * soc.noc.cols)]
  pll_tile = [0 for x in range(soc.noc.rows * soc.noc.cols)]
  for x in range(soc.noc.rows):
    for y in range(soc.noc.cols):
      t = y + x * soc.noc.cols
      tiles[t] = soc.noc.topology[x][y]
      if tiles[t].has_pll.get() == 1:
        pll_tile[tiles[t].clk_region.get()] = t
  for x in range(len(tiles)):
    if x > 0:
      fp.write(",\n")
    fp.write("\t{" + str(x) + ", ")
    selection = tiles[x].ip_type.get()
    tile_type = 0
    if soc.IPs.PROCESSORS.count(selection):
      tile_type = 1
    elif soc.IPs.MEM.count(selection):
      tile_type = 4
    elif soc.IPs.ACCELERATORS.count(selection):
      tile_type = 2
    elif soc.IPs.MISC.count(selection):
      tile_type = 3
    fp.write(str(tile_type) + ", ")
    fp.write("{" + str(tiles[x].row) + ", " + str(tiles[x].col) + "}, ")
    fp.write("\"" + selection + "\", ")
    fp.write(str(tiles[x].has_pll.get()) + ", ")
    fp.write(str(tiles[x].clk_region.get()) + ", ")
    if tiles[x].clk_region.get() > 0:
      fp.write(str(pll_tile[tiles[x].clk_region.get()]))
    else:
      fp.write(str(0))
    fp.write(" }")
  fp.write("\n};\n\n")

  fp.write("#endif /*  __MMI64_REGS_H__ */\n")

  fp.close()
  print("Created configuration into 'mmi64_regs.h'")
