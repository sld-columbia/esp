#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: MIT

from collections import defaultdict
import math

# Maximum number of AHB and APB slaves can also be increased, but the
# Leon3 utility mklinuximg and GRLIB AMBA package must be patched accordingly
# The related constants are defined in
# <mklinuximg>/include/ambapp.h
# <esp>/rtl/include/grlib/amba/amba.vhd
NAPBS = 32
NAHBS = 16
# Physical interrupt lines
IRQ_LINES = 32
# Maximum number of components is not an actual limitation in ESP
# We simply set some value consistently with RTL, but these limits
# can be increased by editing nocpackage accordingly.
# <esp>/rtl/include/sld/noc/nocpackage.vhd
NCPU_MAX = 4
NMEM_MAX = 4
# Caches are provisioning 4 bits for IDs and 16 bits for sharers
# This can be changed here:
# <esp>/systemc/common/caches/cache_consts.h
# <esp>/rtl/include/sld/caches/cachepackage.vhd
NFULL_COHERENT_MAX = 16
NLLC_COHERENT_MAX = 16
# The NoC routers are using 3 bits for both Y and X coordinates.
# The 34-bits header can host up to 5 bits if necessary.
# <esp>/rtl/[include|src]/sld/noc/*.vhd
NTILE_MAX = 64
# The number of accelerators depends on how many I/O devices can be addressed.
# This can be changed by updating the constant NAPBS as explained above, as well
# as the corresponding constant in
# <esp>/rtl/include/sld/noc/nocpackage.vhd
# The following indices  are reserved:
# 0 - BOOT ROM memory controller
# 1 - I/O bus bridge
# 2 - Interrupt controller
# 3 - Timer
# 4 - Reserved
# 5-8 - DVFS controller
# 9-12 - Processors' private cache controller (must change with NCPU_MAX)
# 13 - SVGA controller
# 14 - Ethernet MAC controller
# 15 - Ethernet SGMII PHY controller
# 16-19 - LLC cache controller (must change with NMEM_MAX)
# 20-(NAPBS-1) - Accelerators
NACC_MAX = NAPBS - 2 * NCPU_MAX - NMEM_MAX - 8


# Default device mapping

# Boot ROM slave index (With Leon3 this exists in simulation only for now)
MCTRL_HINDEX = 0

# Memory-mapped registers base address (includes peripherals and accelerators)
AHB2APB_HINDEX = 1

# Leon-3 debug unit slave index
DSU_HINDEX = 2

# Memory controller slave index
DDR_HINDEX = [4, 5, 6, 7]

# Main memory area (12 MSBs)
DDR_HADDR = 0x400

# Main memory size (12 MSBs)
DDR_SIZE = 0x400

# Frame-buffer index
FB_HINDEX = 12

# CPU tile power manager I/O-bus slave index
DVFS_PINDEX = [5, 6, 7, 8]

# private cache physical interrupt line
L2_CACHE_PIRQ = 4

# Private cache I/O-bus slave indices (more indices can be reserved if necessary)
L2_CACHE_PINDEX = [9, 10, 11, 12]

# Last-level cache physical interrupt line
LLC_CACHE_PIRQ = 4

# Last-level cache I/O-bus slave indices (more indices can be reserved if necessary)
LLC_CACHE_PINDEX = [16, 17, 18, 19]

# First I/O-bus index for accelerators
SLD_APB_PINDEX = 20

# I/O memory area offset for accelerators (address bits 19-8)
SLD_APB_ADDR = 0x100

# default mask for accelerators' registers base address (256 Bytes regions per accelerator)
SLD_APB_ADDR_MSK = 0xfff


class acc_info:
  uppercase_name = ""
  lowercase_name = ""
  id = -1
  idx = -1
  irq = 3

class cache_info:
  id = -1
  idx = -1


class tile_info:
  type = "empty"
  x = 0
  y = 0
  cpu_id = -1
  mem_id = -1
  l2 = cache_info()
  llc = cache_info()
  dvfs = cache_info()
  acc = acc_info()
  clk_region = 0
  has_l2 = 0
  design_point = 0
  has_pll = 0
  has_clkbuf = 0

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
  nmem = 0
  ntiles = 0
  # TODO: allow users to disable caches from ESP generator GUI.
  coherence = True
  has_dvfs = False
  ndomain = 1
  has_svga = False
  has_eth = False
  has_sgmii = False
  has_jtag = False
  # Numer of CPU DVFS controller (== number of CPU tiles w/ PLL)
  ndvfs = 0
  # Number of private caches (== number of CPUs + accelerators w/ L2 iff coherence)
  nl2 = 0
  # Number of LLC split (== number of memory tiles iff coherence)
  nllc = 0
  # Number of coherent-DMA devices (== number of accelerators + Ethernet iff coherence)
  ncdma = 0

  accelerators = []
  l2s = []
  llcs = []
  dvfs_ctrls = []
  tiles = []
  regions = []

  def __init__(self, soc):
    #components
    self.ncpu = soc.noc.get_cpu_num(soc)
    self.nmem = soc.noc.get_mem_num(soc)
    self.nacc = soc.noc.get_acc_num(soc)
    self.ntiles = soc.noc.rows * soc.noc.cols
    self.coherence = True
    self.has_dvfs = soc.noc.has_dvfs()
    if self.has_dvfs:
      self.regions = soc.noc.get_clk_regions()
      self.ndomain = len(self.regions)
    else:
      self.regions = []
      self.ndomain = 1
    self.has_svga = soc.HAS_SVGA
    self.has_eth = soc.HAS_ETH
    self.has_sgmii = soc.HAS_SGMII
    self.has_jtag = soc.HAS_JTAG
    if self.coherence:
      self.ncdma = self.nacc + 1
      self.nllc = self.nmem
    else:
      self.ncdma = 0
      self.nllc = 0
    self.accelerators = []
    self.l2s = []
    self.llcs = []
    self.tiles = [tile_info() for x in range(0, self.ntiles)]

    t = 0
    # CPU/CACHE ID assigned dynamically to CPUs
    cpu_id = 0
    # CPU DVFS controller ID
    cpu_dvfs_id = 0
    # CACHE ID assigned dynamically to fully-coherent accelerators
    acc_l2_id = self.ncpu
    # LLC ID assigned dynamically to each memory tile
    llc_id = 0
    # MEM ID assigned dynamically to each memory tile
    mem_id = 0
    # Accelerator/DMA ID assigned dynamically to each accelerator tile
    acc_id = 0

    for x in range(soc.noc.rows):
      for y in range(soc.noc.cols):
        # Get type of tile
        selection = soc.noc.topology[x][y].ip_type.get()
        # Compute tile ID based on YX coordinates
        t = y + x * soc.noc.cols

        self.tiles[t].row = x
        self.tiles[t].col = y
        self.tiles[t].clk_region = soc.noc.topology[x][y].get_clk_region()
        self.tiles[t].design_point = soc.noc.topology[x][y].point.get()
        self.tiles[t].has_pll = soc.noc.topology[x][y].has_pll.get()
        self.tiles[t].has_clkbuf = soc.noc.topology[x][y].has_clkbuf.get()
        self.tiles[t].has_l2 = soc.noc.topology[x][y].has_l2.get()

        # Assign IDs
        if selection == "cpu":
          self.tiles[t].type = "cpu"
          self.tiles[t].cpu_id = cpu_id
          if self.coherence:
            l2 = cache_info()
            l2.id = cpu_id
            l2.idx = L2_CACHE_PINDEX[cpu_id]
            self.l2s.append(l2)
            self.tiles[t].l2 = l2
            self.nl2 = self.nl2 + 1
          if self.tiles[t].has_pll != 0:
            dvfs_ctrl = cache_info()
            dvfs_ctrl.id = cpu_dvfs_id
            dvfs_ctrl.idx = DVFS_PINDEX[cpu_dvfs_id]
            self.dvfs_ctrls.append(dvfs_ctrl)
            self.tiles[t].dvfs = dvfs_ctrl
            self.ndvfs = self.ndvfs + 1
            cpu_dvfs_id = cpu_dvfs_id + 1
          cpu_id = cpu_id + 1
        if selection == "mem":
          self.tiles[t].type = "mem"
          self.tiles[t].mem_id = mem_id
          mem_id = mem_id + 1
          if self.coherence:
            llc = cache_info()
            llc.id = llc_id;
            llc.idx = LLC_CACHE_PINDEX[llc_id]
            self.llcs.append(llc)
            self.tiles[t].llc = llc
            llc_id = llc_id + 1
        if selection == "IO":
          self.tiles[t].type = "misc"
        if soc.IPs.ACCELERATORS.count(selection):
          self.tiles[t].type = "acc"
          acc = acc_info()
          acc.uppercase_name = selection
          acc.lowercase_name = selection.lower()
          acc.id = acc_id
          acc.idx = SLD_APB_PINDEX + acc_id
          self.tiles[t].acc = acc
          self.accelerators.append(acc)
          acc_id = acc_id + 1

          if self.coherence and (self.tiles[t].has_l2 == 1):
            l2 = cache_info()
            l2.id = acc_l2_id
            self.l2s.append(l2)
            self.tiles[t].l2 = l2
            self.nl2 = self.nl2 + 1
            acc_l2_id = acc_l2_id + 1


def print_header(fp, package):
  fp.write("-- Copyright (c) 2011-2019 Columbia University, System Level Design Group\n")
  fp.write("-- SPDX-License-Identifier: MIT\n\n")

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
    fp.write("use work.cachepackage.all;\n")

def print_global_constants(fp, soc):
  fp.write("  ------ Global architecture parameters\n")
  fp.write("  constant ARCH_BITS : integer := " + str(soc.DMA_WIDTH) + ";\n")
  fp.write("  constant GLOB_MEM_MAX_NUM : integer := " + str(NMEM_MAX) + ";\n")
  fp.write("  constant GLOB_CPU_MAX_NUM : integer := " + str(NCPU_MAX) + ";\n")
  fp.write("  constant GLOB_TILES_MAX_NUM : integer := " + str(NTILE_MAX) + ";\n")
  # Keep cache-line size constant to 128 bits for now. We don't want huge line buffers
  fp.write("  constant GLOB_WORD_OFFSET_BITS : integer := " + str(int(math.log(128/soc.DMA_WIDTH, 2))) + ";\n")
  fp.write("  constant GLOB_BYTE_OFFSET_BITS : integer := " + str(int(math.log(soc.DMA_WIDTH/8, 2))) +";\n")
  # TODO: Keep physical address to 32 bits for now to reduce tag size. This will increase to support more memory
  fp.write("  constant GLOB_PHYS_ADDR_BITS : integer := " + str(32) +";\n")
  fp.write("\n")

def print_constants(fp, soc):
  fp.write("  ------ NoC parameters\n")
  fp.write("  constant CFG_XLEN : integer := " + str(soc.noc.cols) + ";\n")
  fp.write("  constant CFG_YLEN : integer := " + str(soc.noc.rows) + ";\n")
  fp.write("  constant CFG_TILES_NUM : integer := CFG_XLEN * CFG_YLEN;\n")

  fp.write("  ------ DMA memory allocation (contiguous buffer or scatter/gather\n")
  fp.write("  constant CFG_SCATTER_GATHER : integer range 0 to 1 := " + str(soc.transfers.get()) + ";\n")

  fp.write("  constant CFG_L2_SETS     : integer := " + str(soc.l2_sets.get()      ) +  ";\n")
  fp.write("  constant CFG_L2_WAYS     : integer := " + str(soc.l2_ways.get()      ) +  ";\n")
  fp.write("  constant CFG_LLC_SETS    : integer := " + str(soc.llc_sets.get()     ) +  ";\n")
  fp.write("  constant CFG_LLC_WAYS    : integer := " + str(soc.llc_ways.get()     ) +  ";\n")
  fp.write("  constant CFG_ACC_L2_SETS : integer := " + str(soc.acc_l2_sets.get()  ) +  ";\n")
  fp.write("  constant CFG_ACC_L2_WAYS : integer := " + str(soc.acc_l2_ways.get()  ) +  ";\n")

  fp.write("  ------ Monitors enable (requires proFPGA MMI64)\n")
  fp.write("  constant CFG_MON_DDR_EN : integer := " + str(soc.noc.monitor_ddr.get()) + ";\n")
  fp.write("  constant CFG_MON_MEM_EN : integer := " + str(soc.noc.monitor_mem.get()) + ";\n")
  fp.write("  constant CFG_MON_NOC_INJECT_EN : integer := " + str(soc.noc.monitor_inj.get()) + ";\n")
  fp.write("  constant CFG_MON_NOC_QUEUES_EN : integer := " + str(soc.noc.monitor_routers.get()) + ";\n")
  fp.write("  constant CFG_MON_ACC_EN : integer := " + str(soc.noc.monitor_accelerators.get()) + ";\n")
  fp.write("  constant CFG_MON_L2_EN : integer := " + str(soc.noc.monitor_l2.get()) + ";\n")
  fp.write("  constant CFG_MON_LLC_EN : integer := " + str(soc.noc.monitor_llc.get()) + ";\n")
  fp.write("  constant CFG_MON_DVFS_EN : integer := " + str(soc.noc.monitor_dvfs.get()) + ";\n\n")


def print_mapping(fp, esp_config):

  fp.write("  ------ Coherence enabled\n")
  if esp_config.coherence:
    fp.write("  constant CFG_L2_ENABLE   : integer := 1;\n")
    fp.write("  constant CFG_L2_DISABLE  : integer := 0;\n")
    fp.write("  constant CFG_LLC_ENABLE  : integer := 1;\n\n")
  else:
    fp.write("  constant CFG_L2_ENABLE   : integer := 0;\n")
    fp.write("  constant CFG_L2_DISABLE  : integer := 1;\n")
    fp.write("  constant CFG_LLC_ENABLE  : integer := 0;\n\n")

  #
  fp.write("  ------ Number of components\n")
  fp.write("  constant CFG_NCPU_TILE : integer := " + str(esp_config.ncpu) + ";\n")
  fp.write("  constant CFG_NMEM_TILE : integer := " + str(esp_config.nmem) + ";\n")
  fp.write("  constant CFG_NL2 : integer := " + str(esp_config.nl2) + ";\n")
  fp.write("  constant CFG_NLLC : integer := " + str(esp_config.nllc) + ";\n")
  fp.write("  constant CFG_NLLC_COHERENT : integer := " + str(esp_config.ncdma) + ";\n\n")

  #
  fp.write("  ------ Local-port Synchronizers iff more than 1 clock region (implied by > 1 memory tiles)\n")
  if esp_config.has_dvfs or esp_config.nmem > 1:
    fp.write("  constant CFG_HAS_SYNC : integer := 1;\n")
  else:
    fp.write("  constant CFG_HAS_SYNC : integer := 0;\n")
  if esp_config.has_dvfs:
    fp.write("  constant CFG_HAS_DVFS : integer := 1;\n")
  else:
    fp.write("  constant CFG_HAS_DVFS : integer := 0;\n")
  fp.write("\n")

  #
  fp.write("  ------ Caches interrupt line\n")
  fp.write("  constant CFG_SLD_LLC_CACHE_IRQ : integer := " + str(LLC_CACHE_PIRQ) + ";\n\n")
  fp.write("  constant CFG_SLD_L2_CACHE_IRQ : integer := " + str(L2_CACHE_PIRQ) + ";\n\n")

  #
  fp.write("  ------ Maximum number of slaves on both HP bus and I/O-bus\n")
  fp.write("  constant maxahbm : integer := NAHBMST;\n")
  fp.write("  constant maxahbs : integer := NAHBSLV;\n")

  #
  fp.write("  ------ Helper data types\n")
  fp.write("  -- slave interace type for BOOT ROM (simulation only for now)\n")
  fp.write("  --pragma translate_off\n")
  fp.write("  type ahb_slv_in_type_vec is array (0 to CFG_NCPU_TILE-1) of ahb_slv_in_type;\n")
  fp.write("  type apb_slv_in_type_vec is array (0 to CFG_NCPU_TILE-1) of apb_slv_in_type;\n")
  fp.write("  --pragma translate_on\n\n")

  #
  fp.write("  -- Arrays of Plug&Play info\n")
  fp.write("  subtype apb_l2_pconfig_vector is apb_config_vector_type(0 to CFG_NL2-1);\n")
  fp.write("  subtype apb_llc_pconfig_vector is apb_config_vector_type(0 to CFG_NLLC-1);\n")

  #
  fp.write("  -- Array of design-point or implementation IDs\n")
  fp.write("  type tile_hlscfg_array is array (0 to CFG_TILES_NUM - 1) of hlscfg_t;\n")

  #
  fp.write("  -- Array of attributes for clock regions\n")
  fp.write("  type domain_type_array is array (0 to " + str(esp_config.ndomain - 1) + ") of integer;\n")

  #
  fp.write("  -- Array of device IDs\n")
  fp.write("  type tile_device_array is array (0 to CFG_TILES_NUM - 1) of devid_t;\n")

  #
  fp.write("  -- Array of I/O-bus indices\n")
  fp.write("  type tile_idx_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to NAPBSLV - 1;\n")

  #
  fp.write("  -- Array of attributes for I/O-bus slave devices\n")
  fp.write("  type apb_attribute_array is array (0 to NAPBSLV - 1) of integer;\n")

  #
  fp.write("  -- Array of IRQ line numbers\n")
  fp.write("  type tile_irq_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to NAHBIRQ - 1;\n")

  #
  fp.write("  -- Array of 12-bit addresses\n")
  fp.write("  type tile_addr_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to 4095;\n")

  #
  fp.write("  -- Array of flags\n")
  fp.write("  type tile_flag_array is array (0 to CFG_TILES_NUM - 1) of integer range 0 to 1;\n")

  #
  fp.write("  -- Array for I/O-bus peripherals enable\n")
  fp.write("  type tile_apb_enable_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(0 to NAPBSLV - 1);\n")

  #
  fp.write("  -- Array for bus peripherals enable\n")
  fp.write("  type tile_ahb_enable_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(0 to NAHBSLV - 1);\n")

  fp.write("\n")

  #
  fp.write("  ------ Plug&Play info on HP bus\n")

  #
  fp.write("  -- Leon3 CPU cores\n")
  fp.write("  constant leon3_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3, 0, LEON3_VERSION, 0),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- JTAG master interface, acting as debug access point\n")
  if esp_config.has_jtag:
    fp.write("  constant JTAG_USEOLDCOM : integer := 0;\n")
    fp.write("  constant JTAG_REREAD : integer := 1;\n")
    fp.write("  constant JTAG_REVISION : integer := 2 - (2-JTAG_REREAD)*JTAG_USEOLDCOM;\n")
    fp.write("  constant jtag_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBJTAG, 0, JTAG_REVISION, 0),\n")
    fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Ethernet master interface, acting as debug access point\n")
  if esp_config.has_eth:
    fp.write("  constant eth0_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 0),\n")
    fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Enable SGMII controller iff needed\n")
  if esp_config.has_sgmii:
    fp.write("  constant CFG_SGMII : integer range 0 to 1 := 1;\n\n")
  else:
    fp.write("  constant CFG_SGMII : integer range 0 to 1 := 0;\n\n")

  #
  fp.write("  -- SVGA controller, acting as master on a dedicated bus connecte to the frame buffer\n")
  if esp_config.has_svga:
    fp.write("  constant svga_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SVGACTRL, 0, 3, 1),\n")
    fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- BOOT ROM HP slave (simulation only for now)\n")
  fp.write("  --pragma translate_off\n")
  fp.write("  constant mctrl_hindex  : integer := " + str(MCTRL_HINDEX) + ";\n")
  fp.write("  constant mctrl_haddr   : integer := 16#000#;\n")
  fp.write("  constant mctrl_hmask   : integer := 16#C00#;\n")
  fp.write("  constant romaddr   : integer := 16#000#;\n")
  fp.write("  constant rommask   : integer := 16#E00#;\n")
  fp.write("  constant ioaddr    : integer := 16#200#;\n")
  fp.write("  constant iomask    : integer := 0; --16#E00#;\n")
  # Not using SDRAM controller; removing from address map
  # fp.write("  constant ramaddr   : integer := 16#400#;\n")
  # fp.write("  constant rammask   : integer := 0; --16#C00#;\n")
  fp.write("  constant mctrl_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, 1, 0),\n")
  fp.write("    4 => ahb_membar(romaddr, '1', '1', rommask),\n")
  fp.write("    5 => ahb_membar(ioaddr,  '0', '0', iomask),\n")
  # fp.write("    6 => ahb_membar(ramaddr, '1', '1', rammask),\n")
  fp.write("    others => zero32);\n")
  fp.write("  --pragma translate_on\n\n")

  #
  fp.write("  -- AHB2APB bus bridge slave\n")
  fp.write("  constant ahb2apb_hindex : integer := " + str(AHB2APB_HINDEX) + ";\n")
  fp.write("  constant ahb2apb_haddr : integer := CFG_APBADDR;\n")
  fp.write("  constant ahb2apb_hmask : integer := 16#F00#;\n")
  fp.write("  constant ahb2apb_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( 1, 6, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(CFG_APBADDR, '0', '0', ahb2apb_hmask),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Leon3 debug unit\n")
  fp.write("  constant dsu_hindex : integer := " + str(DSU_HINDEX) + ";\n")
  fp.write("  constant dsu_haddr : integer := 16#900#;\n")
  fp.write("  constant dsu_hmask : integer := 16#F00#;\n")
  fp.write("  constant dsu_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3DSU, 0, 1, 0),\n")
  fp.write("    4 => ahb_membar(dsu_haddr, '0', '0', dsu_hmask),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Debbug access points proxy index\n")
  fp.write("  constant dbg_remote_ahb_hindex : integer := 3;\n\n")

  #
  fp.write("  ----  Memory controllers\n")
  offset = DDR_HADDR;
  size = int(DDR_SIZE / esp_config.nmem)
  mask = 0xfff & ~(size - 1)
  full_mask = 0xfff & ~(DDR_SIZE - 1)

  #
  fp.write("  -- CPU tiles don't need to know how the address space is split across memory tiles\n")
  fp.write("  -- and each CPU should be able to address any region transparently.\n")
  fp.write("  constant cpu_tile_mig7_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(16#" + format(DDR_HADDR, '03X') + "#, '1', '1', 16#" + format(full_mask, '03X')  + "#),\n")
  fp.write("    others => zero32);\n")

  #
  fp.write("  -- Network interfaces and ESP proxies, instead, need to know how to route packets\n")
  fp.write("  constant ddr_hindex : mem_attribute_array := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => " + str(DDR_HINDEX[i]) + ",\n")
  fp.write("    others => 0);\n")

  fp.write("  constant ddr_haddr : mem_attribute_array := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => 16#" + format(offset, '03X') + "#,\n")
    offset = offset + size
  fp.write("    others => 0);\n")

  fp.write("  constant ddr_hmask : mem_attribute_array := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => 16#" + format(mask, '03X') + "#,\n")
  fp.write("    others => 0);\n")

  #
  fp.write("  -- Create a list of memory controllers info based on the number of memory tiles\n")
  fp.write("  -- We use the MIG interface from GRLIB, which has a device entry for the 7SERIES\n")
  fp.write("  -- Xilinx FPGAs only, however, we provide a patched version of the IP for the\n")
  fp.write("  -- UltraScale(+) FPGAs. The patched intercace shared the same device ID with the\n")
  fp.write("  -- 7SERIES MIG.\n")
  fp.write("  constant mig7_hconfig : ahb_slv_config_vector := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("      4 => ahb_membar(ddr_haddr(" + str(i) + "), '1', '1', ddr_hmask(" + str(i) + ")),\n")
    fp.write("      others => zero32),\n")
  fp.write("    others => hconfig_none);\n")

  #
  fp.write("  -- On-chip frame buffer (GRLIB)\n")
  fp.write("  constant fb_hindex : integer := " + str(FB_HINDEX) + ";\n")
  fp.write("  constant fb_hmask : integer := 16#FFF#;\n")
  fp.write("  constant fb_haddr : integer := CFG_SVGA_MEMORY_HADDR;\n")
  if esp_config.has_svga:
    fp.write("  constant fb_hconfig : ahb_config_type := (\n")
    fp.write("    0 => ahb_device_reg ( VENDOR_SLD, SLD_AHBRAM_DP, 0, 11, 0),\n")
    fp.write("    4 => ahb_membar(fb_haddr, '0', '0', fb_hmask),\n")
    fp.write("    others => zero32);\n\n")
  else:
    fp.write("  constant fb_hconfig : ahb_config_type := hconfig_none;\n\n")

  #
  fp.write("  -- HP slaves index / memory map\n")
  fp.write("  constant fixed_ahbso_hconfig : ahb_slv_config_vector := (\n")
  fp.write("    --pragma translate_off\n")
  fp.write("    " + str(MCTRL_HINDEX) + " => mctrl_hconfig,\n")
  fp.write("    --pragma translate_on\n")
  fp.write("    " + str(AHB2APB_HINDEX) + " => ahb2apb_hconfig,\n")
  fp.write("    " + str(DSU_HINDEX) + " => dsu_hconfig,\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(DDR_HINDEX[i]) + " => mig7_hconfig(" + str(i) + "),\n")
  fp.write("    " + str(FB_HINDEX) + " => fb_hconfig,\n")
  fp.write("    others => hconfig_none);\n\n")

  #
  fp.write("  -- HP slaves index / memory map for CPU tile\n")
  fp.write("  -- CPUs need to see memory as a single address range\n")
  fp.write("  constant cpu_tile_fixed_ahbso_hconfig : ahb_slv_config_vector := (\n")
  fp.write("    --pragma translate_off\n")
  fp.write("    " + str(MCTRL_HINDEX) + " => mctrl_hconfig,\n")
  fp.write("    --pragma translate_on\n")
  fp.write("    " + str(AHB2APB_HINDEX) + " => ahb2apb_hconfig,\n")
  fp.write("    " + str(DSU_HINDEX) + " => dsu_hconfig,\n")
  fp.write("    " + str(DDR_HINDEX[0]) + " => cpu_tile_mig7_hconfig,\n")
  fp.write("    " + str(FB_HINDEX) + " => fb_hconfig,\n")
  fp.write("    others => hconfig_none);\n\n")

  #
  fp.write("  ------ Plug&Play info on I/O bus\n")

  #
  fp.write("  -- BOOT ROM controller (simulation only for now) (GRLIB)\n")
  fp.write("  --pragma translate_off\n")
  fp.write("  constant mctrl_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_ESA, ESA_MCTRL, 0, 1, 0),\n")
  fp.write("  1 => apb_iobar(16#000#, 16#fff#));\n")
  fp.write("  --pragma translate_on\n\n")

  #
  fp.write("  -- UART (GRLIB)\n")
  fp.write("  constant uart_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBUART, 0, 1, CFG_UART1_IRQ),\n")
  fp.write("  1 => apb_iobar(16#001#, 16#fff#));\n\n")

  #
  fp.write("  -- Interrupt controller (Architecture-dependent)\n")
  fp.write("  constant irqmp_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_IRQMP, 0, 3, 0),\n")
  fp.write("  1 => apb_iobar(16#002#, 16#fff#));\n\n")

  #
  fp.write("  -- Timer (GRLIB)\n")
  fp.write("  constant gptimer_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_GPTIMER, 0, 1, CFG_GPT_IRQ),\n")
  fp.write("  1 => apb_iobar(16#003#, 16#fff#));\n\n")

  #
  fp.write("  -- SVGA controler (GRLIB)\n")
  if esp_config.has_svga:
    fp.write("  constant svga_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SVGACTRL, 0, 0, 0),\n")
    fp.write("  1 => apb_iobar(16#006#, 16#fff#));\n\n")

  #
  fp.write("  -- Ethernet MAC (GRLIB)\n")
  if esp_config.has_eth:
    fp.write("  constant eth0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 12),\n")
    fp.write("  1 => apb_iobar(16#800#, 16#f00#));\n\n")

    fp.write("  constant sgmii0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SGMII, 0, 1, 11),\n")
    fp.write("  1 => apb_iobar(16#010#, 16#ff0#));\n\n")

  #
  fp.write("  -- CPU DVFS controller\n")
  fp.write("  -- Accelerators' power controllers are mapped to the upper half of their I/O\n")
  fp.write("  -- address space. In the future, each DVFS controller should be assigned to an independent\n")
  fp.write("  -- region of the address space, thus allowing discovery from the device tree.\n")

  fp.write("  constant cpu_dvfs_paddr : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    dvfs = esp_config.tiles[i].dvfs
    if dvfs.id != -1:
      fp.write("    " + str(i) + " => 16#" + format(0xD0 + dvfs.idx, '03X') + "#,\n")
  fp.write("    others => 0);\n")

  fp.write("  constant cpu_dvfs_pmask : integer := 16#fff#;\n")

  fp.write("  constant cpu_dvfs_pconfig : apb_config_vector_type(0 to " + str(esp_config.ntiles - 1) + ") := (\n")
  for i in range(0, esp_config.ntiles):
    dvfs = esp_config.tiles[i].dvfs
    if dvfs.id != -1:
      fp.write("    " + str(dvfs.id) + " => (\n")
      fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_POWERCTRL, 0, 0, 0),\n")
      fp.write("      1 => apb_iobar(16#" + format(0xD0 + dvfs.idx, '03X') + "#, 16#fff#)),\n")
  fp.write("    others => pconfig_none);\n\n")

  #
  fp.write("  -- L2\n")
  fp.write("  -- Accelerator's caches cannot be flushed/reset from I/O-bus\n")
  fp.write("  constant l2_cache_pconfig : apb_l2_pconfig_vector := (\n")
  for i in range(0, esp_config.nl2):
    l2 = esp_config.l2s[i]
    if l2.idx != -1:
      fp.write("    " + str(l2.id) + " => (\n")
      fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_L2_CACHE, 0, 0, CFG_SLD_L2_CACHE_IRQ),\n")
      fp.write("      1 => apb_iobar(16#" + format(0xD0 + l2.idx, '03X') + "#, 16#fff#)),\n")
  fp.write("    others => pconfig_none);\n\n")

  #
  fp.write("  -- LLC\n")
  fp.write("  constant llc_cache_pconfig : apb_llc_pconfig_vector := (\n")
  for i in range(0, esp_config.nllc):
    llc = esp_config.llcs[i]
    fp.write("    " + str(i) + " => (\n")
    fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_LLC_CACHE, 0, 0, CFG_SLD_LLC_CACHE_IRQ),\n")
    fp.write("      1 => apb_iobar(16#" + format(0xD0 + llc.idx, '03X') + "#, 16#fff#)),\n")
  fp.write("    others => pconfig_none);\n\n")

  #
  fp.write("  -- Accelerators\n")
  fp.write("  constant accelerators_num : integer := " + str(esp_config.nacc) + ";\n\n")
  for i in range(esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("  -- Accelerator " + str(acc.id) + "\n")
    address = format(SLD_APB_ADDR + acc.idx, "03X")
    fp.write("  -- APB " + str(acc.idx) + ": 0x800" + address + "00 - 0x800" + str(address) + "FF\n")
    fp.write("  -- " + acc.uppercase_name + "\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pindex : integer range 0 to NAPBSLV - 1 := " + str(acc.idx) + ";\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pirq : integer range 0 to NAHBIRQ - 1 := " + str(acc.irq) + ";\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_paddr : integer range 0 to 4095 := 16#" + str(address) + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pmask : integer range 0 to 4095 := 16#" + format(SLD_APB_ADDR_MSK, "03X") + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_" + acc.uppercase_name + ", 0, 0, " + str(acc.irq) + "),\n")
    fp.write("  1 => apb_iobar(16#" + address + "#, 16#" + format(SLD_APB_ADDR_MSK, "03X")  + "#));\n\n")

  #
  fp.write("  -- I/O bus slaves index / memory map\n")
  fp.write("  constant fixed_apbo_pconfig : apb_slv_config_vector := (\n")
  fp.write("    --pragma translate_off\n")
  fp.write("    0 => mctrl_pconfig,\n")
  fp.write("    --pragma translate_on\n")
  fp.write("    1 => uart_pconfig,\n")
  fp.write("    2 => irqmp_pconfig,\n")
  fp.write("    3 => gptimer_pconfig,\n")
  for i in range(0, esp_config.ndvfs):
    dvfs = esp_config.dvfs_ctrls[i]
    fp.write("    " + str(dvfs.idx) + " => cpu_dvfs_pconfig(" + str(i) + "),\n")
  for i in range(0, esp_config.nl2):
    l2 = esp_config.l2s[i]
    if l2.idx != -1:
      fp.write("    " + str(l2.idx) + " => l2_cache_pconfig(" + str(l2.id) + "),\n")
  for i in range(0, esp_config.nllc):
    llc = esp_config.llcs[i]
    fp.write("    " + str(llc.idx) + " => llc_cache_pconfig(" + str(i) + "),\n")
  if esp_config.has_svga:
    fp.write("    13 => svga_pconfig,\n")
  if esp_config.has_eth:
    fp.write("    14 => eth0_pconfig,\n")
    if esp_config.has_sgmii:
      fp.write("    15 => sgmii0_pconfig,\n")
  for i in range(0, esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("    " + str(acc.idx) + " => " + str(acc.lowercase_name) + "_" + str(acc.id) + "_pconfig,\n")
  fp.write("    others => pconfig_none);\n\n")


  #
  fp.write("  ------ Cross reference arrays\n")

  #
  fp.write("  -- Get CPU ID from tile ID\n")
  fp.write("  constant tile_cpu_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].cpu_id) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get tile ID from CPU ID\n")
  fp.write("  constant cpu_tile_id : cpu_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      fp.write("    " + str(esp_config.tiles[i].cpu_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get DVFS controller pindex from tile ID\n")
  fp.write("  constant cpu_dvfs_pindex : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "cpu" and t.has_pll != 0:
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].dvfs.idx) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get L2 cache ID from tile ID\n")
  fp.write("  constant tile_cache_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    l2 = esp_config.tiles[i].l2
    if l2.id != -1:
      fp.write("    " + str(i) + " => " + str(l2.id) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get tile ID from L2 cache ID\n")
  fp.write("  constant cache_tile_id : cache_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    l2 = esp_config.tiles[i].l2
    if l2.id != -1:
      fp.write("    " + str(l2.id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get L2 pindex from tile ID\n")
  fp.write("  constant l2_cache_pindex : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].l2.idx) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Flag tiles that have a private cache\n")
  fp.write("  constant tile_has_l2 : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_l2) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get LLC ID from tile ID\n")
  fp.write("  constant tile_llc_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    llc = esp_config.tiles[i].llc
    if llc.id != -1:
      fp.write("    " + str(i) + " => " + str(llc.id) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get tile ID from LLC-split ID\n")
  fp.write("  constant llc_tile_id : mem_attribute_array := (\n")
  for i in  range(0, esp_config.ntiles):
    llc = esp_config.tiles[i].llc
    if llc.id != -1:
      fp.write("    " + str(llc.id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get LLC pindex from tile ID\n")
  fp.write("  constant llc_cache_pindex : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "mem":
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].llc.idx) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get tile ID from memory ID\n")
  fp.write("  constant mem_tile_id : mem_attribute_array := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      fp.write("    " + str(t.mem_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get memory tile ID from tile ID\n")
  fp.write("  constant tile_mem_id : tile_attribute_array := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      fp.write("    " + str(i) + " => " + str(t.mem_id) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get accelerator ID from tile ID\n")
  fp.write("  constant tile_acc_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].acc.id) + ",\n")
  fp.write("    others => -1);\n\n")

  #
  fp.write("  -- Get miscellaneous tile ID\n")
  misc_id = 0
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "misc":
      misc_id = i
  fp.write("  constant io_tile_id : integer := " + str(misc_id) + ";\n\n")

  #
  fp.write("  -- DMA ID corresponds to accelerator ID for accelerators and nacc for Ethernet\n")
  fp.write("  -- Ethernet must be coherent to avoid flushing private caches every time the\n")
  fp.write("  -- DMA buffer is accessed, but the IP from GRLIB is not coherent. We leverage\n")
  fp.write("  -- LLC-coherent DMA w/ recalls to have Etherent work transparently.\n")

  fp.write("  -- Get DMA ID from tile ID\n")
  fp.write("  constant tile_dma_id : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    acc = esp_config.tiles[i].acc
    if acc.id != -1:
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].acc.id) + ",\n")
  fp.write("    io_tile_id => " + str(esp_config.nacc) + ",\n")
  fp.write("    others => -1);\n\n")


  fp.write("  -- Get tile ID from DMA ID (used for LLC-coherent DMA)\n")
  fp.write("  constant dma_tile_id : dma_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    acc = esp_config.tiles[i].acc
    if acc.id != -1:
      fp.write("    " + str(acc.id) + " => " + str(i) + ",\n")
  fp.write("    " + str(esp_config.nacc) + " => io_tile_id,\n")
  fp.write("    others => 0);\n\n")


  #
  fp.write("  -- Get type of tile from tile ID\n")
  fp.write("  constant tile_type : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    type = 0
    if esp_config.tiles[i].type == "cpu":
      type = 1
    if esp_config.tiles[i].type == "acc":
      type = 2
    if esp_config.tiles[i].type == "misc":
      type = 3
    if esp_config.tiles[i].type == "mem":
      type = 4
    fp.write("    " + str(i) + " => " + str(type) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get accelerator's implementation (hlscfg or generic design point) from tile ID\n")
  fp.write("  constant tile_design_point : tile_hlscfg_array := (\n")
  for i in range(0, esp_config.ntiles):
    tile = esp_config.tiles[i]
    if tile.type == "acc":
      if str(tile.design_point) != "":
        fp.write("    " + str(i) + " => HLSCFG_" + tile.acc.uppercase_name + "_" + tile.design_point.upper() + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get accelerator device ID (device tree) from tile ID\n")
  fp.write("  constant tile_device : tile_device_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      fp.write("    " + str(i) + " => SLD_" + esp_config.tiles[i].acc.uppercase_name + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get I/O-bus index line for accelerators from tile ID\n")
  fp.write("  constant tile_apb_idx : tile_idx_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_pindex,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get I/O-bus address for accelerators from tile ID\n")
  fp.write("  constant tile_apb_paddr : tile_addr_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_paddr,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get I/O-bus address mask for accelerators from tile ID\n")
  fp.write("  constant tile_apb_pmask : tile_addr_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_pmask,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get IRQ line for accelerators from tile ID\n")
  fp.write("  constant tile_apb_irq : tile_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_pirq,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get DMA memory allocation from tile ID (this parameter must be the same for every accelerator)\n")
  fp.write("  constant tile_scatter_gather : tile_flag_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      fp.write("    " + str(i) + " => CFG_SCATTER_GATHER,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get number of clock regions (1 if has_dvfs is false)\n")
  fp.write("  constant domains_num : integer := " + str(esp_config.ndomain)+";\n\n")

  #
  fp.write("  -- Flag tiles that belong to a DVFS domain\n")
  fp.write("  constant tile_has_dvfs : tile_attribute_array := (\n")
  if esp_config.has_dvfs:
    for i in range(0, esp_config.ntiles):
      region = esp_config.tiles[i].clk_region
      has_dvfs = 0
      if region != 0:
        has_dvfs = 1
      fp.write("    " + str(i) + " => " + str(has_dvfs) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Flag tiles that are master of a DVFS domain (have a local PLL)\n")
  fp.write("  constant tile_has_pll : tile_attribute_array := (\n")
  if esp_config.has_dvfs:
    for i in range(0, esp_config.ntiles):
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_pll) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get clock domain from tile ID\n")
  fp.write("  constant tile_domain : tile_attribute_array := (\n")
  if esp_config.has_dvfs:
    for i in range(0, esp_config.ntiles):
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].clk_region) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID of the DVFS domain masters for each clock region (these tiles control the corresponding domain)\n")
  pll_tile = [0 for x in range(esp_config.ntiles)]
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].has_pll == 1:
      pll_tile[esp_config.tiles[i].clk_region] = i

  #
  fp.write("  -- Get tile ID of the DVFS domain master from the tile clock region\n")
  fp.write("  constant tile_domain_master : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(pll_tile[esp_config.tiles[i].clk_region]) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID of the DVFS domain master from the clock region ID\n")
  fp.write("  constant domain_master_tile : domain_type_array := (\n")
  if esp_config.has_dvfs:
    for i in range(0, esp_config.ndomain):
      region = esp_config.regions[i]
      if region != 0:
        fp.write("    " + str(region) + " => " + str(pll_tile[region]) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Flag domain master tiles w/ additional clock buffer (these are a limited resource on the FPGA)\n")
  fp.write("  constant extra_clk_buf : tile_attribute_array := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_clkbuf) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  ---- Get tile ID from I/O-bus index (index 4 is the local DVFS controller to each CPU tile)\n")
  fp.write("  constant apb_tile_id : apb_attribute_array := (\n")
  # 0 - BOOT ROM memory controller
  # 1 - I/O bus bridge
  # 2 - Interrupt controller
  # 3 - Timer
  for i in range(0, 4):
    fp.write("    " + str(i) + " => io_tile_id,\n")
  # 13 - SVGA controller
  if esp_config.has_svga:
    fp.write("    13 => io_tile_id,\n")
  # 14 - Ethernet MAC controller
  # 15 - Ethernet SGMII PHY controller
  if esp_config.has_eth:
    fp.write("    14 => io_tile_id,\n")
    if esp_config.has_sgmii:
      fp.write("    15 => io_tile_id,\n")
  # 20-(NAPBSLV - 1) - Accelerators
  for i in range(0, esp_config.ntiles):
    t =  esp_config.tiles[i]
    if t.type == "acc":
      acc_pindex = t.acc.idx
      fp.write("    " + str(acc_pindex) + " => " + str(i) + ",\n")
    # 16-19 - LLC cache controller (must change with NMEM_MAX)
    if t.type == "mem":
      llc_pindex = t.llc.idx
      fp.write("    " + str(llc_pindex) + " => " + str(i) + ",\n")
    # 5-8 - Processors' DVFS controller (must change with NCPU_MAX)
    # 9-12 - Processors' private cache controller (must change with NCPU_MAX)
    if t.type == "cpu":
      if t.has_pll != 0:
        fp.write("    " + str(t.dvfs.idx) + " => " + str(i) + ",\n")
      if esp_config.coherence:
        fp.write("    " + str(t.l2.idx) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")



def print_tiles(fp, esp_config):
  #
  fp.write("  -- Tiles YX coordinates\n")
  fp.write("  constant tile_x : yx_vec(0 to " + str(esp_config.ntiles - 1) + ") := (\n")
  for i in range(0, esp_config.ntiles):
    if i > 0:
       fp.write(",\n")
    fp.write("    " + str(i) + " => \"" + uint_to_bin(esp_config.tiles[i].col, 3) + "\"")
  fp.write("  );\n")

  fp.write("  constant tile_y : yx_vec(0 to " + str(esp_config.ntiles - 1) + ") := (\n")
  for i in range(0, esp_config.ntiles):
    if i > 0:
      fp.write(",\n")
    fp.write("    " + str(i) + " => \"" + uint_to_bin(esp_config.tiles[i].row, 3) + "\"")
  fp.write("  );\n\n")

  #
  fp.write("  -- CPU YX coordinates\n")
  fp.write("  constant cpu_y : yx_vec(0 to " + str(NCPU_MAX - 1) + ") := (\n")
  for i in range(0, NCPU_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_y(cpu_tile_id(" + str(i) + "))")
  fp.write("  );\n")

  fp.write("  constant cpu_x : yx_vec(0 to " + str(NCPU_MAX - 1) + ") := (\n")
  for i in range(0, NCPU_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_x(cpu_tile_id(" + str(i) + "))")
  fp.write("  );\n\n")


  #
  fp.write("  -- L2 YX coordinates\n")
  fp.write("  constant cache_y : yx_vec(0 to " + str(NFULL_COHERENT_MAX - 1) + ") := (\n")
  for i in range(0, NFULL_COHERENT_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_y(cache_tile_id(" + str(i) + "))")
  fp.write("  );\n")

  fp.write("  constant cache_x : yx_vec(0 to " + str(NFULL_COHERENT_MAX - 1) + ") := (\n")
  for i in range(0, NFULL_COHERENT_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_x(cache_tile_id(" + str(i) + "))")
  fp.write("  );\n\n")

  #
  fp.write("  -- DMA initiators YX coordinates\n")
  fp.write("  constant dma_y : yx_vec(0 to " + str(NLLC_COHERENT_MAX - 1) + ") := (\n")
  for i in range(0, NLLC_COHERENT_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_y(dma_tile_id(" + str(i) + "))")
  fp.write("  );\n")

  fp.write("  constant dma_x : yx_vec(0 to " + str(NLLC_COHERENT_MAX - 1) + ") := (\n")
  for i in range(0, NLLC_COHERENT_MAX):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_x(dma_tile_id(" + str(i) + "))")
  fp.write("  );\n\n")

  #
  fp.write("  -- LLC YX coordinates and memory tiles routing info\n")
  fp.write("  constant tile_mem_list : tile_mem_info_vector(0 to MEM_MAX_NUM - 1) := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      x => tile_x(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => ddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => ddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  #
  fp.write("  -- Add the frame buffer entry for accelerators' DMA.\n")
  fp.write("  -- NB: accelerators can only access the frame buffer if.\n")
  fp.write("  -- non-coherent DMA is selected from software.\n")
  fp.write("  constant tile_acc_mem_list : tile_mem_info_vector(0 to MEM_MAX_NUM) := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      x => tile_x(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => ddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => ddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  if esp_config.has_svga:
    fp.write("    " + str(esp_config.nmem) + " => (\n")
    fp.write("      x => tile_x(io_tile_id),\n")
    fp.write("      y => tile_y(io_tile_id),\n")
    fp.write("      haddr => fb_haddr,\n")
    fp.write("      hmask => fb_hmask\n")
    fp.write("    ),\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  #
  fp.write("  -- I/O-bus devices routing info\n")
  fp.write("  constant apb_slv_y : yx_vec(0 to NAPBSLV - 1) := (\n")
  for i in range(0, NAPBS):
    if i > 0:
      fp.write(",\n")
    fp.write("    " + str(i) + " => tile_y(apb_tile_id(" + str(i) + "))")
  fp.write("  );\n")

  fp.write("  constant apb_slv_x : yx_vec(0 to NAPBSLV - 1) := (\n")
  for i in range(0, NAPBS):
    if i > 0:
      fp.write(",\n")
    fp.write("    " + str(i) + " => tile_x(apb_tile_id(" + str(i) + "))")
  fp.write("  );\n\n")

  #
  fp.write("  -- Flag I/O-bus slaves that are remote\n")
  fp.write("  -- Note that some components can be remote to a tile even if they are\n")
  fp.write("  -- located in that tile. This is because local masters still have to go\n")
  fp.write("  -- through ESP proxies to address such devices (e.g. L2 cache and DVFS\n")
  fp.write("  -- controller in CPU tiles). This choice allows any master in the SoC to\n")
  fp.write("  -- access these slaves. For instance, when configuring DVFS, a single CPU\n")
  fp.write("  -- must be able to access all DVFS controllers from other CPUS; another\n")
  fp.write("  -- example is the synchronized flush of all private caches, which is\n")
  fp.write("  -- initiated by a single CPU\n")
  fp.write("  constant remote_apb_slv_mask : tile_apb_enable_array := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "cpu" or t.type == "misc":
      fp.write("    " + str(i) + " => (\n")
    if t.type == "cpu":
      fp.write("      --pragma translate_off\n")
      fp.write("      0 => '1',\n")
      fp.write("      --pragma translate_on\n")
      fp.write("      1 => to_std_logic(CFG_UART1_ENABLE),\n")
      fp.write("      2 => to_std_logic(CFG_IRQ3_ENABLE),\n")
      fp.write("      3 => to_std_logic(CFG_GPT_ENABLE),\n")
      fp.write("      13 => to_std_logic(CFG_SVGA_ENABLE),\n")
      fp.write("      14 => to_std_logic(CFG_GRETH),\n")
      if esp_config.has_sgmii:
        fp.write("      15 => to_std_logic(CFG_GRETH),\n")
    if t.type == "cpu" or t.type == "misc":
      for j in range(0, esp_config.ndvfs):
        dvfs = esp_config.dvfs_ctrls[j]
        if dvfs.id != -1:
          fp.write("      " + str(dvfs.idx) + " => '1',\n")
      for j in range(0, esp_config.nl2):
        l2 = esp_config.l2s[j]
        if l2.idx != -1:
          fp.write("      " + str(l2.idx) + " => '1',\n")
      for j in range(0, esp_config.nllc):
        llc = esp_config.llcs[j]
        if llc.idx != -1:
          fp.write("      " + str(llc.idx) + " => '1',\n")
      for j in range(0, esp_config.nacc):
        acc = esp_config.accelerators[j]
        fp.write("      " + str(acc.idx) + " => '1',\n")
      fp.write("      others => '0'),\n")
  fp.write("    others => (others => '0'));\n\n")

  #
  fp.write("  -- Flag I/O-bus slaves that are local to each tile\n")
  for i in range(0, esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("  constant " + acc.lowercase_name + "_"+ str(acc.id) + "_apb_mask : std_logic_vector(0 to NAPBSLV - 1) := (\n")
    fp.write("    " + str(acc.idx) + " => '1',\n")
    fp.write("    others => '0');\n")

  fp.write("  constant local_apb_mask : tile_apb_enable_array := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "acc":
      acc = t.acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_apb_mask,\n")
    if t.type == "misc":
      fp.write("    " + str(i) + " => (\n")
      fp.write("      --pragma translate_off\n")
      fp.write("      0  => '1',\n") # MCTRL
      fp.write("      --pragma translate_on\n")
      fp.write("      1  => '1',\n") # UART
      fp.write("      2  => '1',\n") # IRQ
      fp.write("      3  => '1',\n") # TIMER
      fp.write("      13 => to_std_logic(CFG_SVGA_ENABLE),\n"),
      fp.write("      14 => to_std_logic(CFG_GRETH),\n")
      fp.write("      15 => to_std_logic(CFG_SGMII * CFG_GRETH),\n")
      fp.write("      others => '0'),\n")
    if t.type == "mem":
      fp.write("    " + str(i) + " => (\n")
      if esp_config.coherence:
        fp.write("      " + str(t.llc.idx) + " => '1',\n")
      fp.write("      others => '0'),\n")
    if t.type == "cpu":
      fp.write("    " + str(i) + " => (\n")
      if t.has_pll != 0:
        fp.write("      " + str(t.dvfs.idx) + " => '1',\n")
      if t.has_l2 != 0:
        fp.write("      " + str(t.l2.idx) + " => '1',\n")
      fp.write("      others => '0'),\n")
  fp.write("    others => (others => '0'));\n\n")

  #
  fp.write("  -- Flag bus slaves that are local to each tile (either device or proxy)\n")
  fp.write("  constant local_ahb_mask : tile_ahb_enable_array := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "misc":
      fp.write("    " + str(i) + " => (\n")
      fp.write("      --pragma translate_off\n")
      fp.write("      " + str(MCTRL_HINDEX) + "  => '1',\n")
      fp.write("      --pragma translate_on\n")
      fp.write("      " + str(AHB2APB_HINDEX) + "  => '1',\n")
      fp.write("      " + str(DSU_HINDEX) + " => '1',\n")
      fp.write("      " + str(FB_HINDEX) + "  => to_std_logic(CFG_SVGA_ENABLE),\n")
      fp.write("      others => '0'),\n")
    if t.type == "cpu":
      fp.write("    " + str(i) + " => (\n")
      fp.write("      " + str(AHB2APB_HINDEX) + "  => '1',\n")
      fp.write("      " + str(DDR_HINDEX[0]) + " => to_std_logic(CFG_L2_ENABLE),\n")
      fp.write("      others => '0'),\n")
    if t.type == "mem":
      fp.write("    " + str(i) + " => (\n")
      fp.write("      " + str(DDR_HINDEX[t.mem_id]) + " => '1',\n")
      fp.write("      others => '0'),\n")
  fp.write("    others => (others => '0'));\n\n")

  #
  fp.write("  -- Flag bus slaves that are remote to each tile (request selects slv proxy)\n")
  fp.write("  constant remote_ahb_mask : tile_ahb_enable_array := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "misc":
      fp.write("    " + str(i) + " => (\n")
      for j in range(0, esp_config.nmem):
        fp.write("      " + str(DDR_HINDEX[j]) + " => '1',\n")
      fp.write("      others => '0'),\n")
    if t.type == "cpu":
      fp.write("    " + str(i) + " => (\n")
      fp.write("      --pragma translate_off\n")
      fp.write("      " + str(MCTRL_HINDEX) + "  => '1',\n")
      fp.write("      --pragma translate_on\n")
      fp.write("      " + str(DSU_HINDEX) + " => '1',\n")
      fp.write("      " + str(DDR_HINDEX[0]) + " => to_std_logic(CFG_L2_DISABLE),\n")
      fp.write("      " + str(FB_HINDEX) + "  => to_std_logic(CFG_SVGA_ENABLE),\n")
      fp.write("      others => '0'),\n")
  fp.write("    others => (others => '0'));\n\n")


def create_socmap(esp_config, soc):
  fp = open('esp_global.vhd', 'w')

  print_header(fp, "esp_global")
  print_libs(fp, True)

  fp.write("package esp_global is\n\n")
  print_global_constants(fp, soc)

  fp.write("end esp_global;\n")
  fp.close()

  print("Created global constants definition into 'esp_global.vhd'")


  fp = open('socmap.vhd', 'w')

  print_header(fp, "socmap")
  print_libs(fp, False)

  fp.write("package socmap is\n\n")
  print_constants(fp, soc)
  print_mapping(fp, esp_config)
  print_tiles(fp, esp_config)

  fp.write("end socmap;\n")
  fp.close()


  print("Created configuration into 'socmap.vhd'")
