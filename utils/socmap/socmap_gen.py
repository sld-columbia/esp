#!/usr/bin/python3

from collections import defaultdict
import math

#constants
MCTRL_HINDEX = 0
AHB2APB_HINDEX = 1
DSU_HINDEX = 2
DDR0_HINDEX = 4
DDR1_HINDEX = 5
FB_HINDEX = 6
POWERCTRL_PINDEX = 4
L2_CACHE_PINDEX_FIRST = 6
L2_CACHE_PIRQ = 4
L3_CACHE_PINDEX = 5
L3_CACHE_PIRQ = 4
SLD_APB_ADDR_ADJ = 0x100
SLD_APB_ADDR_MSK = 0xfff
NCPU_MAX = 4
NMEM_MAX = 2
NFULL_COHERENT_MAX = 8
NLLC_COHERENT_MAX = 8
NTILE_MAX = 32
NAPBS = 32
NAHBS = 16

class acc_info:
  uppercase_name = ""
  lowercase_name = ""
  idx = 0
  irq = 3
  sg = False
  number = 0
  dvfs = 0 #number of clock region (0 is system region)

class tile_info:
  type = "empty"
  idx = 0
  x = 0
  y = 0
  cpuid = -1
  cid = -1
  did = -1
  clk_region = 0
  def __init__(self):
    return

def uint_to_bin(x, bits):
  b = ""
  z = 1 << (bits - 1)
  while z > 0:
    if x & z == z:
       b += "1"
    else:
       b += "0"
    z >>= 1
  return b

class soc_config:
  #components
  ncpu = 0
  nacc = 0
  nmem_ctrl = 0
  #interconnection
  ntiles = 0
  #peripherals

  acc_types = []
  acc_num = []

  accelerators = []
  tiles = []

  def __init__(self, soc):
    #components
    self.has_noc = True
    for x in range(soc.noc.rows):
      for y in range(soc.noc.cols):
        tile = soc.noc.topology[x][y]
        ip_type = tile.ip_type.get()
        if soc.IPs.PROCESSORS.count(ip_type):
          self.ncpu += 1
        elif soc.IPs.MEM.count(ip_type):
          self.nmem_ctrl += 1
        elif soc.IPs.ACCELERATORS.count(ip_type):
          self.nacc += 1
    self.ntiles = soc.noc.rows * soc.noc.cols
    self.accelerators = []
    self.tiles = [tile_info() for x in range(0, self.ntiles)]
    self.acc_types = soc.IPs.ACCELERATORS
    self.acc_num = [0 for x in range(0, len(self.acc_types))]
    self.acc_irq = defaultdict(lambda: 0)

    t = 0
    # CPU/CACHE ID assigned dynamically to CPUs
    cpuid = 0
    # CACHE ID assigned dynamically to fully-coherent accelerators
    acc_cid = 0
    # DMA ID assigned dynamically to LLC-coherent accelerators
    acc_did = 0
    acc_tile_idx = 0
    # 5 -> LLC; 6-6+ncpu->L2 then accelerators
    acc_idx = L2_CACHE_PINDEX_FIRST + soc.noc.get_cpu_num(soc) #first available line for accelerators
    acc_irq = 3
    for x in range(soc.noc.rows):
      for y in range(soc.noc.cols):
        selection = soc.noc.topology[x][y].ip_type.get()
        t = y + x * soc.noc.cols
        self.tiles[t].row = x
        self.tiles[t].col = y
        self.tiles[t].clk_region = soc.noc.topology[x][y].get_clk_region()
        self.tiles[t].design_point = soc.noc.topology[x][y].point.get()
        self.tiles[t].has_pll = soc.noc.topology[x][y].has_pll.get()
        self.tiles[t].has_clkbuf = soc.noc.topology[x][y].has_clkbuf.get()
        if selection == "cpu":
          self.tiles[t].type = "cpu"
          self.tiles[t].cpuid = cpuid
          self.tiles[t].cid = cpuid
          cpuid += 1
        if selection == "mem_dbg":
          self.tiles[t].type = "mem_dbg"
        if selection == "mem_lite":
          self.tiles[t].type = "mem_lite"
        if selection == "IO":
          self.tiles[t].type = "misc"
        if soc.IPs.ACCELERATORS.count(selection):
          self.tiles[t].type = "acc"
          self.tiles[t].idx = acc_tile_idx
          self.tiles[t].cid = soc.noc.get_cpu_num(soc) + acc_cid
          acc_cid += 1
          self.tiles[t].did = acc_did
          acc_did += 1
          for i in range(0, len(self.acc_types)):
            if self.acc_types[i] == selection:
              self.acc_num[i] += 1
          acc = acc_info()
          acc.lowercase_name = selection.lower()
          acc.uppercase_name = selection
          acc.idx = acc_idx
          self.acc_irq[selection] = acc_irq
          '''
          if self.acc_irq[selection] == 0:
          self.acc_irq[selection] = acc_irq
          acc_irq += 1
          if acc_irq > 7:
          acc_irq = 3
          acc.irq = self.acc_irq[selection]
          '''
          acc.number = acc_tile_idx
          acc_idx += 1
          acc_tile_idx += 1
          if acc_idx == 13:
            acc_idx = 16
          self.accelerators.append(acc)

def print_header(fp):
  fp.write("------------------------------------------------------------------------------\n")
  fp.write("--  This file is a configuration file for the ESP NoC-based architecture\n")
  fp.write("--  Copyright (C) 2014-2018, System Level Design (SLD) group @ Columbia University\n")
  fp.write("-----------------------------------------------------------------------------\n")
  fp.write("-- Entity:      socmap\n")
  fp.write("-- File:        socmap.vhd\n")
  fp.write("-- Author:      Paolo Mantovani - SLD @ Columbia University\n")
  fp.write("-- Author:      Christian Pilato - SLD @ Columbia University\n")
  fp.write("-- Description: System address mapping and NoC tiles configuration\n")
  fp.write("------------------------------------------------------------------------------\n")

def print_libs(fp):
  fp.write("library ieee;\n")
  fp.write("use ieee.std_logic_1164.all;\n")
  fp.write("use ieee.numeric_std.all;\n")

  fp.write("use work.stdlib.all;\n")
  fp.write("use work.grlib_config.all;\n")
  fp.write("use work.amba.all;\n")
  fp.write("use work.sld_devices.all;\n")
  fp.write("use work.devices.all;\n")
  fp.write("use work.leon3.all;\n")
  fp.write("use work.nocpackage.all;\n")
  fp.write("use work.cachepackage.all;\n")

def print_constants(fp, esp_config, soc):
  fp.write("  -- number of CPU tiles. Each has 1 processor\n")
  fp.write("  constant CFG_NCPU_TILE : integer := " + str(soc.noc.get_cpu_num(soc)) + ";\n")
  fp.write("  -- number of tiles with private caches (CPUs + Fully-coherent accelerators)\n")
  fp.write("  constant CFG_NL2 : integer := " + str(soc.noc.get_cpu_num(soc) + soc.noc.get_acc_num(soc)) + ";\n")
  fp.write("  -- number of acclerator tiles LLC-coherent accelerators\n")
  fp.write("  constant CFG_NLLC_COHERENT : integer := " + str(soc.noc.get_acc_num(soc)) + ";\n\n")

  # Cache memory enable
  fp.write("  -- Cache memory enable\n")
  fp.write("  constant CFG_L2_ENABLE   : integer := 1;\n")
  fp.write("  constant CFG_LLC_ENABLE  : integer := 1;\n\n")
  fp.write("  constant CFG_L2_SETS     : integer := " + str(soc.l2_sets.get()      ) +  ";\n")
  fp.write("  constant CFG_L2_WAYS     : integer := " + str(soc.l2_ways.get()      ) +  ";\n")
  fp.write("  constant CFG_LLC_SETS    : integer := " + str(soc.llc_sets.get()     ) +  ";\n")
  fp.write("  constant CFG_LLC_WAYS    : integer := " + str(soc.llc_ways.get()     ) +  ";\n")
  fp.write("  constant CFG_ACC_L2_SETS : integer := " + str(soc.acc_l2_sets.get()  ) +  ";\n")
  fp.write("  constant CFG_ACC_L2_WAYS : integer := " + str(soc.acc_l2_ways.get()  ) +  ";\n")

  fp.write("-- NoC settings\n")
  fp.write("  constant CFG_XLEN : integer := " + str(soc.noc.cols) + ";\n")
  fp.write("  constant CFG_YLEN : integer := " + str(soc.noc.rows) + ";\n")
  fp.write("  constant CFG_TILES_NUM : integer := CFG_XLEN * CFG_YLEN;\n")

  fp.write("-- Monitor settings\n")
  fp.write("  constant CFG_MON_DDR_EN : integer := " + str(soc.noc.monitor_ddr.get()) + ";\n")
  fp.write("  constant CFG_MON_NOC_INJECT_EN : integer := " + str(soc.noc.monitor_inj.get()) + ";\n")
  fp.write("  constant CFG_MON_NOC_QUEUES_EN : integer := " + str(soc.noc.monitor_routers.get()) + ";\n")
  fp.write("  constant CFG_MON_ACC_EN : integer := " + str(soc.noc.monitor_accelerators.get()) + ";\n")
  fp.write("  constant CFG_MON_DVFS_EN : integer := " + str(soc.noc.monitor_dvfs.get()) + ";\n")

  fp.write("-- Other settings\n")
  if soc.noc.has_dvfs() or soc.noc.get_mem_num(soc)[0] > 1:
    fp.write("  constant CFG_HAS_SYNC : integer := 2;\n")
  else:
    fp.write("  constant CFG_HAS_SYNC : integer := 0;\n")
  if soc.noc.has_dvfs():
    fp.write("  constant CFG_HAS_DVFS : integer := 1;\n")
  else:
    fp.write("  constant CFG_HAS_DVFS : integer := 0;\n")
  fp.write("\n")

  for x in range(0, len(esp_config.acc_types)):
    fp.write("-- SLD " + esp_config.acc_types[x] + "\n")
    acc_enable = 0
    if esp_config.acc_num[x] > 0:
      acc_enable = 1
    fp.write("  constant CFG_SLD_" + esp_config.acc_types[x] + "_ENABLE : integer := " + str(acc_enable) + ";\n")
    fp.write("  constant CFG_SLD_" + esp_config.acc_types[x] + "_NUM : integer := " + str(esp_config.acc_num[x]) + ";\n")
    fp.write("  constant CFG_SLD_" + esp_config.acc_types[x] + "_IRQ : integer := " + str(esp_config.acc_irq[esp_config.acc_types[x]]) + ";\n")
    fp.write("  constant CFG_SLD_" + esp_config.acc_types[x] + "_SG : integer := " + str(int(soc.HAS_SG)) + ";\n")

  fp.write("\n")
  fp.write("  constant CFG_SLD_L3_CACHE_IRQ : integer := " + str(L3_CACHE_PIRQ) + ";\n\n")
  fp.write("  constant CFG_SLD_L2_CACHE_IRQ : integer := " + str(L2_CACHE_PIRQ) + ";\n\n")

  fp.write("-- Memory controllers\n")
  if esp_config.nmem_ctrl == 2:
    fp.write("  constant CFG_MIG_DUAL : integer := 1;\n")
  else:
    fp.write("  constant CFG_MIG_DUAL : integer := 0;\n")
  fp.write("\n")

  fp.write("  constant maxahbm : integer := NAHBMST;\n")
  fp.write("  constant maxahbs : integer := NAHBSLV;\n")

  fp.write("  --pragma translate_off\n")
  fp.write("  type ahb_slv_in_type_vec is array (0 to CFG_NCPU_TILE-1) of ahb_slv_in_type;\n")
  fp.write("  type apb_slv_in_type_vec is array (0 to CFG_NCPU_TILE-1) of apb_slv_in_type;\n")
  fp.write("  --pragma translate_on\n\n")

  fp.write("  -- AHB Masters\n")
  fp.write("  -- MST 0 to CFG_NCPU_TILE (same for each cpu tile)\n")
  fp.write("  constant leon3_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3, 0, LEON3_VERSION, 0),\n")
  fp.write("    others => zero32);\n\n")

  if soc.HAS_JTAG == True:
    fp.write("  -- MST 1 (offchip)\n")
    fp.write("  constant JTAG_USEOLDCOM : integer := 1 - (1-tap_tck_gated(CFG_FABTECH))*(1);\n")
    fp.write("  constant JTAG_REREAD : integer := 1;\n")
    fp.write("  constant JTAG_REVISION : integer := 2 - (2-JTAG_REREAD)*JTAG_USEOLDCOM;\n")
    fp.write("  constant jtag_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBJTAG, 0, JTAG_REVISION, 0),\n")
    fp.write("    others => zero32);\n\n")

  if soc.HAS_ETH == True:
    fp.write("  -- MST 2 (offchip)\n")
    fp.write("  constant eth0_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 0),\n")
    fp.write("    others => zero32);\n\n")

  if soc.HAS_SGMII == True:
    fp.write("  constant CFG_SGMII : integer range 0 to 1 := 1;\n\n")
  else:
    fp.write("  constant CFG_SGMII : integer range 0 to 1 := 0;\n\n")

  if soc.HAS_SVGA == True:
    fp.write("  -- MST 3 (mis tile)\n")
    fp.write("  constant svga_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SVGACTRL, 0, 3, 1),\n")
    fp.write("    others => zero32);\n\n")

  fp.write("  -- AHB Slaves\n")
  fp.write("  -- SLV 0: 0x00000000 - 0x1FFFFFFF\n")
  fp.write("  --pragma translate_off\n")
  fp.write("  constant mctrl_hindex  : integer := " + str(MCTRL_HINDEX) + ";\n")
  fp.write("  constant romaddr   : integer := 16#000#;\n")
  fp.write("  constant rommask   : integer := 16#E00#;\n")
  fp.write("  constant ioaddr    : integer := 16#200#;\n")
  fp.write("  constant iomask    : integer := 0; --16#E00#;\n")
  fp.write("  constant ramaddr   : integer := 16#400#;\n")
  fp.write("  constant rammask   : integer := 0; --16#C00#;\n")
  fp.write("  constant mctrl_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, 1, 0),\n")
  fp.write("    4 => ahb_membar(romaddr, '1', '1', rommask),\n")
  fp.write("    5 => ahb_membar(ioaddr,  '0', '0', iomask),\n")
  fp.write("    6 => ahb_membar(ramaddr, '1', '1', rammask),\n")
  fp.write("    others => zero32);\n")
  fp.write("  --pragma translate_on\n\n")

  fp.write("  -- SLV 1: 0x80000000 - 0x8FFFFFFF\n")
  fp.write("  constant ahb2apb_hindex : integer := " + str(AHB2APB_HINDEX) + ";\n")
  fp.write("  constant ahb2apb_haddr : integer := CFG_APBADDR;\n")
  fp.write("  constant ahb2apb_hmask : integer := 16#F00#;\n")
  fp.write("  constant ahb2apb_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( 1, 6, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(CFG_APBADDR, '0', '0', ahb2apb_hmask),\n")
  fp.write("    others => zero32);\n\n")

  fp.write("  -- SLV 2: 0x90000000 - 0x9FFFFFFF\n")
  fp.write("  constant dsu_hindex : integer := " + str(DSU_HINDEX) + ";\n")
  fp.write("  constant dsu_haddr : integer := 16#900#;\n")
  fp.write("  constant dsu_hmask : integer := 16#F00#;\n")
  fp.write("  constant dsu_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3DSU, 0, 1, 0),\n")
  fp.write("    4 => ahb_membar(dsu_haddr, '0', '0', dsu_hmask),\n")
  fp.write("    others => zero32);\n\n")

  fp.write("  -- SLV 3: Reserved for JTAG/ETH to remote AHBS\n")
  fp.write("  constant dbg_remote_ahb_hindex : integer := 3;\n\n")

  if esp_config.nmem_ctrl == 1:
    fp.write("  -- SLV 4: 0x40000000 - 0x7FFFFFFF (1GB DDR supported)\n")
    fp.write("  constant ddr0_hindex : integer := " + str(DDR0_HINDEX) + ";\n")
    fp.write("  constant ddr0_haddr : integer := 16#400#;\n")
    fp.write("  constant ddr0_hmask : integer := 16#C00#;\n")
    fp.write("  constant mig70_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("    4 => ahb_membar(ddr0_haddr, '1', '1', ddr0_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  constant ddr1_hindex : integer := 0;\n")
    fp.write("  constant mig71_hconfig : ahb_config_type := hconfig_none;\n")
    fp.write("  constant ddr1_haddr : integer := 16#000#;\n")
    fp.write("  constant ddr1_hmask : integer := 16#000#;\n")
    fp.write("  constant cpu_tile_mig7_hconfig : ahb_config_type := hconfig_none;\n")
    fp.write("  --pragma translate_off\n")
    fp.write("  -- replace mig_7series with faster ahbram_sim\n")
    fp.write("  constant ahbram_sim_maccsz  : integer := AHBDW;\n")
    fp.write("  constant ahbram_sim_kbytes  : integer := 1000;\n")
    fp.write("  constant ahbram_sim_abits : integer := log2ext(ahbram_sim_kbytes) + 8 - ahbram_sim_maccsz/64;\n")
    fp.write("  constant ahbram_sim0_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBRAM, 0, ahbram_sim_abits+2+ahbram_sim_maccsz/64, 0),\n")
    fp.write("    4 => ahb_membar(ddr0_haddr, '1', '1', ddr0_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  constant ahbram_sim1_hconfig : ahb_config_type := hconfig_none;\n")
    fp.write("  --pragma translate_on\n\n")
  if esp_config.nmem_ctrl == 2:
    fp.write("  -- SLV 4: 0x40000000 - 0x7FFFFFFF (1GB DDR supported)\n")
    fp.write("  constant ddr0_hindex : integer := " + str(DDR0_HINDEX) + ";\n")
    fp.write("  constant ddr0_haddr : integer := 16#400#;\n")
    fp.write("  constant ddr0_hmask : integer := 16#E00#;\n")
    fp.write("  constant ddr_full_hmask : integer := 16#C00#;\n")
    fp.write("  constant cpu_tile_mig7_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("    4 => ahb_membar(ddr0_haddr, '1', '1', ddr_full_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  constant mig70_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("    4 => ahb_membar(ddr0_haddr, '1', '1', ddr0_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  constant ddr1_hindex : integer := " + str(DDR1_HINDEX) + ";\n")
    fp.write("  constant ddr1_haddr : integer := 16#600#;\n")
    fp.write("  constant ddr1_hmask : integer := 16#E00#;\n")
    fp.write("  constant mig71_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("    4 => ahb_membar(ddr1_haddr, '1', '1', ddr1_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  --pragma translate_off\n")
    fp.write("  -- replace mig_7series with faster ahbram_sim\n")
    fp.write("  constant ahbram_sim_maccsz  : integer := AHBDW;\n")
    fp.write("  constant ahbram_sim_kbytes  : integer := 1000;\n")
    fp.write("  constant ahbram_sim_abits : integer := log2ext(ahbram_sim_kbytes) + 8 - ahbram_sim_maccsz/64;\n")
    fp.write("  constant ahbram_sim0_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBRAM, 0, ahbram_sim_abits+2+ahbram_sim_maccsz/64, 0),\n")
    fp.write("    4 => ahb_membar(ddr0_haddr, '1', '1', ddr0_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  constant ahbram_sim1_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBRAM, 0, ahbram_sim_abits+2+ahbram_sim_maccsz/64, 0),\n")
    fp.write("    4 => ahb_membar(ddr1_haddr, '1', '1', ddr1_hmask),\n")
    fp.write("    others => zero32);\n")
    fp.write("  --pragma translate_on\n\n")

  fp.write("  -- SLV 6: 0xB0100000 - 0xB01FFFFF\n")
  fp.write("  constant fb_hindex : integer := " + str(FB_HINDEX) + ";\n")
  fp.write("  constant fb_hmask : integer := 16#FFF#;\n")
  fp.write("  constant fb_haddr : integer := CFG_SVGA_MEMORY_HADDR;\n")
  if soc.HAS_SVGA == True:
    fp.write("  constant fb_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_SLD, SLD_AHBRAM_DP, 0, 11, 0),\n")
    fp.write("    4 => ahb_membar(fb_haddr, '0', '0', fb_hmask),\n")
    fp.write("    others => zero32);\n\n")
  else:
    fp.write("  constant fb_hconfig : ahb_config_type := hconfig_none;\n\n")

  fp.write("  -- APB Slaves\n")
  fp.write("  -- APB 0: 0x80000000 - 0x800000FF\n")
  fp.write("  --pragma translate_off\n")
  fp.write("  constant mctrl_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, 1, 0),\n")
  fp.write("  1 => apb_iobar(0, 16#fff#));\n")
  fp.write("  --pragma translate_on\n\n")

  fp.write("  -- APB 1: 0x80000100 - 0x800001FF\n")
  fp.write("  -- irq 2\n")
  fp.write("  constant uart_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBUART, 0, 1, CFG_UART1_IRQ),\n")
  fp.write("  1 => apb_iobar(1, 16#fff#));\n\n")

  fp.write("  -- APB 2: 0x80000200 - 0x800002FF\n")
  fp.write("  -- irq 13 is reserved to wake CPUs\n")
  fp.write("  constant irqmp_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_IRQMP, 0, 3, 0),\n")
  fp.write("  1 => apb_iobar(2, 16#fff#));\n\n")

  fp.write("  -- APB 3: 0x80000300 - 0x800003FF\n")
  fp.write("  -- irq 8\n")
  fp.write("  constant gptimer_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_GPTIMER, 0, 1, CFG_GPT_IRQ),\n")
  fp.write("  1 => apb_iobar(3, 16#fff#));\n\n")

  if soc.HAS_SVGA == True:
    fp.write("  -- APB 13: 0x80000600 - 0x800006FF\n")
    fp.write("  constant svga_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SVGACTRL, 0, 0, 0),\n")
    fp.write("  1 => apb_iobar(16#006#, 16#fff#));\n\n")

  if soc.HAS_ETH == True:
    fp.write("  -- APB 14: 0x80080000 - 0x8008FFFF\n")
    fp.write("  -- irq 12\n")
    fp.write("  constant eth0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 12),\n")
    fp.write("  1 => apb_iobar(16#800#, 16#f00#));\n\n")
    fp.write("  -- APB 15: 0x80001000 - 0x80001FFF\n")
    fp.write("  -- irq 11\n")
    fp.write("  constant sgmii0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SGMII, 0, 1, 11),\n")
    fp.write("  1 => apb_iobar(16#010#, 16#ff0#));\n\n")

  fp.write("  -- APB " + str(POWERCTRL_PINDEX) + ": 0x80000" + str(POWERCTRL_PINDEX) + "00 - 0x80000" + str(POWERCTRL_PINDEX) + "FF\n")
  fp.write("  -- power management registers. This requires special handling, because there\n")
  fp.write("  -- is one set of registers to control power per each tile.\n")
  if soc.noc.has_dvfs():
    fp.write("  constant powerctrl_pindex : integer := " + str(POWERCTRL_PINDEX) + ";\n")
    fp.write("  constant powerctrl_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_POWERCTRL, 0, 0, 0),\n")
    fp.write("  1 => apb_iobar(" + str(POWERCTRL_PINDEX) + ", 16#fff#));\n\n")
  else:
    fp.write("  constant powerctrl_pindex : integer := " + str(POWERCTRL_PINDEX) + ";\n")
    fp.write("  constant powerctrl_pconfig : apb_config_type := pconfig_none;\n")

  fp.write("  -- APB " + str(L3_CACHE_PINDEX) + ": 0x80000" + str(L3_CACHE_PINDEX) + "00 - 0x80000" + str(L3_CACHE_PINDEX) + "FF\n")
  fp.write("  -- Last-level cache control registers (force flush and soft reset)\n")
  fp.write("  constant l3_cache_pindex : integer := " + str(L3_CACHE_PINDEX) + ";\n")
  fp.write("  constant l3_cache_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_L3_CACHE, 0, 0, CFG_SLD_L3_CACHE_IRQ),\n")
  fp.write("  1 => apb_iobar(" + str(L3_CACHE_PINDEX) + ", 16#fff#));\n\n")

  fp.write("  constant l2_cache_pindex : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      fp.write("    " + str(i) + " => " + str(L2_CACHE_PINDEX_FIRST + esp_config.tiles[i].cpuid) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant l2_cache_pconfig : apb_slv_pconfig_vector := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      idx = L2_CACHE_PINDEX_FIRST + esp_config.tiles[i].cpuid
      fp.write("    " + str(i) + " => (\n")
      fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_L2_CACHE, 0, 0, CFG_SLD_L2_CACHE_IRQ),\n")
      fp.write("      1 => apb_iobar(16#" + str(idx) + "#, 16#fff#)),\n")
  fp.write("    others => pconfig_none);\n\n")

  fp.write("  constant fixed_ahbso_hconfig : ahb_slv_hconfig_vector := (\n")
  fp.write("    --pragma translate_off\n")
  fp.write("    " + str(MCTRL_HINDEX) + " => mctrl_hconfig,\n")
  fp.write("    --pragma translate_on\n")
  fp.write("    " + str(AHB2APB_HINDEX) + " => ahb2apb_hconfig,\n")
  fp.write("    " + str(DSU_HINDEX) + " => dsu_hconfig,\n")
  fp.write("    " + str(DDR0_HINDEX) + " => mig70_hconfig,\n")
  fp.write("    " + str(DDR1_HINDEX) + " => mig71_hconfig,\n")
  fp.write("    " + str(FB_HINDEX) + " => fb_hconfig,\n")
  fp.write("    others => hconfig_none);\n\n")

  fp.write("  constant accelerators_num : integer := " + str(soc.noc.get_acc_num(soc)) + ";\n\n")
  for i in range(soc.noc.get_acc_num(soc)):
    acc = esp_config.accelerators[i]
    fp.write("  -- Accelerator " + str(acc.number) + "\n")
    address_hex = hex(int(SLD_APB_ADDR_ADJ) + acc.idx)
    address = str(address_hex).replace("0x", "")
    fp.write("  -- APB " + str(acc.idx) + ": 0x800" + str(address) + "00 - 0x800" + str(address) + "FF\n")
    fp.write("  -- irq " + str(acc.irq) + "\n")
    fp.write("  -- " + acc.uppercase_name + "\n")
    fp.write("  -- " + acc.lowercase_name + "_paddr   = 16#" + str(address) + "#;\n")
    fp.write("  -- " + acc.lowercase_name + "_pmask   = 16#" + str(hex(SLD_APB_ADDR_MSK)).replace("0x","") + "#;\n")
    fp.write("  -- " + acc.lowercase_name + "_hindex  = CFG_NCPU+CFG_AHB_JTAG+CFG_GRETH+" + str(acc.number) + ";\n")
    fp.write("\n")
  fp.write("\n")

  nacc_print = soc.noc.get_acc_num(soc)
  if nacc_print > 0:
    nacc_print -= 1
  fp.write("  type accelerators_number_array is array (0 to " + str(esp_config.ntiles - 1) + ") of integer range 0 to " + str(nacc_print) + ";\n")
  fp.write("  constant accelerators_tile2number : accelerators_number_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => " + str(acc.number) + ",\n")
  fp.write("    others => 0);\n\n")
  for i in range(0, esp_config.nacc):
    acc = esp_config.accelerators[i]
    address_hex = hex(int(SLD_APB_ADDR_ADJ) + acc.idx)
    address = str(address_hex).replace("0x", "")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.number) + "_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_" + acc.uppercase_name + ", 0, 0, CFG_SLD_" + acc.uppercase_name + "_IRQ),\n")
    fp.write("  1 => apb_iobar(16#" + address + "#, 16#" + str(hex(SLD_APB_ADDR_MSK)).replace("0x","") + "#));\n\n")

  fp.write("  constant fixed_apbo_pconfig : apb_slv_pconfig_vector := (\n")
  fp.write("    --pragma translate_off\n")
  fp.write("    0 => mctrl_pconfig,\n")
  fp.write("    --pragma translate_on\n")
  fp.write("    1 => uart_pconfig,\n")
  fp.write("    2 => irqmp_pconfig,\n")
  fp.write("    3 => gptimer_pconfig,\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      idx = L2_CACHE_PINDEX_FIRST + esp_config.tiles[i].cpuid
      fp.write("    " + str(idx) + " => l2_cache_pconfig(" + str(i) + "),\n")
  if soc.HAS_SVGA == True:
    fp.write("    13 => svga_pconfig,\n")
  if soc.HAS_ETH == True:
    fp.write("    14 => eth0_pconfig,\n")
    if soc.HAS_SGMII == True:
      fp.write("    15 => sgmii0_pconfig,\n")
  fp.write("    " + str(POWERCTRL_PINDEX) + " => powerctrl_pconfig,\n")
  fp.write("    " + str(L3_CACHE_PINDEX) + " => l3_cache_pconfig,\n")
  for i in range(0, esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("    " + str(acc.idx) + " => " + str(acc.lowercase_name) + "_" + str(acc.number) + "_pconfig,\n")
  fp.write("    others => pconfig_none);\n\n")

def print_tiles(fp, esp_config, soc):
  fp.write("  constant tile_x : yx_vec(0 to CFG_TILES_NUM-1) := (\n")
  for i in range(0, esp_config.ntiles):
    if i > 0:
       fp.write(",\n")
    fp.write("    " + str(i) + " => \"" + uint_to_bin(esp_config.tiles[i].col,3) + "\"")
  fp.write(");\n")

  fp.write("  constant tile_y : yx_vec(0 to CFG_TILES_NUM-1) := (\n")
  for i in range(0, esp_config.ntiles):
    if i > 0:
      fp.write(",\n")
    fp.write("    " + str(i) + " => \"" + uint_to_bin(esp_config.tiles[i].row,3) + "\"")
  fp.write(");\n")
  fp.write("\n")

  fp.write("  constant cpu_tile_id : cpu_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      fp.write("    " + str(esp_config.tiles[i].cpuid) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n")

  fp.write("  constant cpu_y : yx_vec(" + str(NCPU_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NCPU_MAX - 1):
    fp.write("   " + str(i) + " => tile_y(cpu_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NCPU_MAX - 1) + " => tile_y(cpu_tile_id(" + str(NCPU_MAX - 1) + ")));\n")

  fp.write("  constant cpu_x : yx_vec(" + str(NCPU_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NCPU_MAX - 1):
    fp.write("   " + str(i) + " => tile_x(cpu_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NCPU_MAX - 1) + " => tile_x(cpu_tile_id(" + str(NCPU_MAX - 1) + ")));\n\n")

  fp.write("  constant cache_tile_id : cache_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].cid != -1:
      fp.write("    " + str(esp_config.tiles[i].cid) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n")

  fp.write("  constant cache_y : yx_vec(" + str(NFULL_COHERENT_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NFULL_COHERENT_MAX - 1):
    fp.write("   " + str(i) + " => tile_y(cache_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NFULL_COHERENT_MAX - 1) + " => tile_y(cache_tile_id(" + str(NFULL_COHERENT_MAX - 1) + ")));\n")

  fp.write("  constant cache_x : yx_vec(" + str(NFULL_COHERENT_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NFULL_COHERENT_MAX - 1):
    fp.write("   " + str(i) + " => tile_x(cache_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NFULL_COHERENT_MAX - 1) + " => tile_x(cache_tile_id(" + str(NFULL_COHERENT_MAX - 1) + ")));\n\n")

  fp.write("  constant dma_tile_id : dma_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].did != -1:
      fp.write("    " + str(esp_config.tiles[i].did) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n")

  fp.write("  constant dma_y : yx_vec(" + str(NLLC_COHERENT_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NLLC_COHERENT_MAX - 1):
    fp.write("   " + str(i) + " => tile_y(dma_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NLLC_COHERENT_MAX - 1) + " => tile_y(dma_tile_id(" + str(NLLC_COHERENT_MAX - 1) + ")));\n")

  fp.write("  constant dma_x : yx_vec(" + str(NLLC_COHERENT_MAX - 1) + " downto 0) := (\n")
  for i in range(0, NLLC_COHERENT_MAX - 1):
    fp.write("   " + str(i) + " => tile_x(dma_tile_id(" + str(i) + ")),\n")
  fp.write("   " + str(NLLC_COHERENT_MAX - 1) + " => tile_x(dma_tile_id(" + str(NLLC_COHERENT_MAX - 1) + ")));\n\n")


  fp.write("  constant NMIG : integer := 1 + CFG_MIG_DUAL;\n")

  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "misc":
      fp.write("  constant io_tile_id : integer := " + str(i) + ";\n")

  fp.write("  constant tile_cpu_0 : tile_mem_info := (\n")
  fp.write("    x => tile_x(cpu_tile_id(0)),\n")
  fp.write("    y => tile_y(cpu_tile_id(0)),\n")
  fp.write("    haddr => 16#900#,\n")
  fp.write("    hmask => 16#F00#\n")
  fp.write("  );\n")

  fp.write("  constant tile_mem_0 : tile_mem_info := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "mem_dbg":
      fp.write("    x => tile_x(" + str(i) + "),\n")
      fp.write("    y => tile_y(" + str(i) + "),\n")
  fp.write("    haddr => 16#400#,\n")

  if esp_config.nmem_ctrl == 2:
    fp.write("    hmask => 16#E00#\n")
  if esp_config.nmem_ctrl == 1:
    fp.write("    hmask => 16#C00#\n")
  fp.write("  );\n")

  if esp_config.nmem_ctrl == 2:
    for i in range(0, esp_config.ntiles):
      if esp_config.tiles[i].type == "mem_lite":
        fp.write("  constant tile_mem_1 : tile_mem_info := (\n")
        fp.write("    x => tile_x(" + str(i) + "),\n")
        fp.write("    y => tile_y(" + str(i) + "),\n")
        fp.write("    haddr => 16#600#,\n")
        fp.write("    hmask => 16#E00#\n")
        fp.write("  );\n")
  if esp_config.nmem_ctrl == 1:
    fp.write("  constant tile_mem_1 : tile_mem_info := (\n")
    fp.write("    x => tile_x(0),\n")
    fp.write("    y => tile_y(0),\n")
    fp.write("    haddr => 16#000#,\n")
    fp.write("    hmask => 16#000#\n")
    fp.write("  );\n")

  if soc.HAS_SVGA == True:
    for i in range(0, esp_config.ntiles):
      if esp_config.tiles[i].type == "misc":
        fp.write("  constant tile_fb : tile_mem_info := (\n")
        fp.write("    x => tile_x(" + str(i) + "),\n")
        fp.write("    y => tile_y(" + str(i) + "),\n")
        fp.write("    haddr => fb_haddr,\n")
        fp.write("    hmask => fb_hmask\n")
        fp.write("  );\n")
  else:
        fp.write("  constant tile_fb : tile_mem_info := (\n")
        fp.write("    x => tile_x(0),\n")
        fp.write("    y => tile_y(0),\n")
        fp.write("    haddr => 16#000#,\n")
        fp.write("    hmask => 16#000#\n")
        fp.write("  );\n")

  fp.write("  constant tile_mem_list : tile_mem_info_vector := (\n")
  fp.write("    0 => tile_mem_0")
  idx = 1
  if esp_config.nmem_ctrl == 2:
    fp.write(",\n")
    fp.write("    " + str(idx) + " => tile_mem_1")
    idx += 1
  if soc.HAS_SVGA == True:
    fp.write(",\n")
    fp.write("    " + str(idx) + " => tile_fb")
  fp.write(",\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  fp.write("  constant jtag_target_list : tile_mem_info_vector := (\n")
  idx = 1
  if esp_config.nmem_ctrl == 2:
    fp.write("    " + str(idx) + " => tile_mem_1,\n")
    idx += 1
  if soc.HAS_SVGA == True:
    fp.write("    " + str(idx) + " => tile_fb,\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  fp.write("  type tile_type_array is array (0 to CFG_TILES_NUM-1) of integer;\n")
  fp.write("  constant tile_type : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    type = 0
    if esp_config.tiles[i].type == "cpu":
      type = 1
    if esp_config.tiles[i].type == "acc":
      type = 2
    if esp_config.tiles[i].type == "misc":
      type = 3
    if esp_config.tiles[i].type == "mem_dbg":
      type = 4
    if esp_config.tiles[i].type == "mem_lite":
      type = 5
    fp.write("    " + str(i) + " => " + str(type) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  type tile_hlscfg_array is array (0 to CFG_TILES_NUM-1) of hlscfg_t;\n")
  fp.write("  constant tile_design_point : tile_hlscfg_array := (\n")
  for i in range(0, esp_config.ntiles):
    if str(esp_config.tiles[i].design_point) != "":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => HLSCFG_" + acc.uppercase_name + "_" + esp_config.tiles[i].design_point.upper() + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant domains_num : integer := " + str(len(soc.noc.get_clk_regions()))+";\n\n")

  fp.write("  constant tile_has_dvfs : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    region = esp_config.tiles[i].clk_region
    has_dvfs = 0
    if region != 0:
      has_dvfs = 1
    fp.write("    " + str(i) + " => " + str(has_dvfs) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_has_pll : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_pll) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_domain : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    region = esp_config.tiles[i].clk_region
    fp.write("    " + str(i) + " => " + str(region) + ",\n")
  fp.write("    others => 0);\n\n")

  pll_tile = [0 for x in range(soc.noc.rows * soc.noc.cols)]
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].has_pll == 1:
      pll_tile[esp_config.tiles[i].clk_region] = i
  fp.write("  constant tile_domain_master : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(pll_tile[esp_config.tiles[i].clk_region]) + ",\n")
  fp.write("    others => 0);\n\n")

  regions = soc.noc.get_clk_regions()
  fp.write("  type domain_type_array is array (0 to " + str(len(regions)-1) + ") of integer;\n")
  fp.write("  constant domain_master_tile : domain_type_array := (\n")
  for i in range(len(regions)):
    if regions[i] != 0:
      fp.write("    " + str(regions[i]) + " => " + str(pll_tile[regions[i]]) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant extra_clk_buf : tile_type_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type != "acc":
      fp.write("    " + str(i) + " => 0,\n")
    else:
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_clkbuf) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  type tile_device_array is array (0 to CFG_TILES_NUM-1) of devid_t;\n")
  fp.write("  constant tile_device : tile_device_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
        acc = esp_config.accelerators[esp_config.tiles[i].idx]
        fp.write("    " + str(i) + " => SLD_" + acc.uppercase_name + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  type tile_idx_irq_array is array (0 to CFG_TILES_NUM-1) of integer;\n")
  fp.write("  constant tile_apb_idx : tile_idx_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => " + str(acc.idx) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_apb_paddr : tile_idx_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      address_hex = hex(int(SLD_APB_ADDR_ADJ) + acc.idx)
      address = str(address_hex).replace("0x", "")
      fp.write("    " + str(i) + " => 16#" + address + "#,\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_apb_pmask : tile_idx_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => 16#" + str(hex(SLD_APB_ADDR_MSK)).replace("0x","") + "#,\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_apb_irq : tile_idx_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => CFG_SLD_" + acc.uppercase_name + "_IRQ,\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_scatter_gather : tile_idx_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => CFG_SLD_" + acc.uppercase_name + "_SG,\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_cpu_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].cpuid) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_cache_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].cid) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_dma_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].did) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  type apb_tile_id_array is array (NAPBSLV-1 downto 0) of integer;\n")
  fp.write("  constant apb_tile_id : apb_tile_id_array := (\n")
  misc_id = 0
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "misc":
      misc_id = i
  for i in range(1, 4):
    fp.write("    " + str(i) + " => " + str(misc_id) + ",\n")
  if soc.HAS_SVGA:
    fp.write("    13 => " + str(misc_id) + ",\n")
  if soc.HAS_ETH:
    for i in range(0, esp_config.ntiles):
      if esp_config.tiles[i].type == "mem_dbg":
        fp.write("    14 => " + str(i) + ",\n")
  if soc.HAS_SGMII:
    for i in range(0, esp_config.ntiles):
      if esp_config.tiles[i].type == "mem_dbg":
        fp.write("    15 => " + str(i) + ",\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(acc.idx) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant apb_slv_y : yx_vec(NAPBSLV-1 downto 0) := (\n")
  for i in range(0, NAPBS-1):
    fp.write("    " + str(i) + " => tile_y(apb_tile_id(" + str(i) + ")),\n")
  fp.write("    " + str(NAPBS-1) + " => tile_y(apb_tile_id(" + str(NAPBS-1) + ")));\n")

  fp.write("  constant apb_slv_x : yx_vec(NAPBSLV-1 downto 0) := (\n")
  for i in range(0, NAPBS-1):
    fp.write("    " + str(i) + " => tile_x(apb_tile_id(" + str(i) + ")),\n")
  fp.write("    " + str(NAPBS-1) + " => tile_x(apb_tile_id(" + str(NAPBS-1) + ")));\n\n")

  fp.write("  constant ahb_slv_en : std_logic_vector(NAHBSLV-1 downto 0) := \"")
  i = NAHBS - 1
  while i >= 0:
    if i != AHB2APB_HINDEX and i != DSU_HINDEX and i != FB_HINDEX:
      fp.write("0")
    else:
      fp.write("1")
    i -= 1
  fp.write("\";\n\n")

  fp.write("  -- Set to '1' if CPU proxy must send the message on the NoC\n")
  fp.write("  constant remote_apb_slv_en : std_logic_vector(NAPBSLV-1 downto 0) := (\n")
  fp.write("    1 => to_std_logic(CFG_UART1_ENABLE),\n")
  fp.write("    2 => to_std_logic(CFG_IRQ3_ENABLE),\n")
  fp.write("    3 => to_std_logic(CFG_GPT_ENABLE),\n")
  fp.write("    " + str(L3_CACHE_PINDEX) + " => to_std_logic(CFG_LLC_ENABLE),\n")
  fp.write("    13 => to_std_logic(CFG_SVGA_ENABLE),\n")
  fp.write("    14 => to_std_logic(CFG_GRETH),\n")
  if soc.HAS_SGMII:
    fp.write("    15 => to_std_logic(CFG_GRETH),\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(acc.idx) + " => to_std_logic(CFG_SLD_" + acc.uppercase_name + "_ENABLE),\n")
  fp.write("    others => '0');\n\n")

  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("  constant " + acc.lowercase_name + "_"+ str(acc.number) + "_apb_mask : std_logic_vector(NAPBSLV - 1 downto 0) := (\n")
      fp.write("    " + str(acc.idx) + " => '1',\n")
      fp.write("    others => '0');\n")

  fp.write("  type apb_mask_vector is array (natural range <>) of std_logic_vector(NAPBSLV - 1 downto 0);\n")
  fp.write("  constant local_apb_mask : apb_mask_vector(CFG_TILES_NUM - 1 downto 0) := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.accelerators[esp_config.tiles[i].idx]
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.number) + "_apb_mask,\n")
  fp.write("    others => (others => '0'));\n\n")

def print_accelerators_constants(fp):
  print("Printing accelerator constants")

def create_socmap(esp_config, soc):
  fp = open('socmap.vhd', 'w')

  print_header(fp)
  print_libs(fp)

  fp.write("package socmap is\n\n")
  if esp_config.has_noc == True:
    print_constants(fp, esp_config, soc)
    print_tiles(fp, esp_config, soc)
  else:
    print_accelerators_constants(fp)

  fp.write("end socmap;\n")
  fp.close()
  print("Created configuration into 'socmap.vhd'")
