#!/usr/bin/env python3

# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from collections import defaultdict
import math
from thirdparty import *

# Maximum number of AHB and APB slaves can also be increased, but Leon3 utility
# mklinuximg, GRLIB AMBA package and bare-metal probe constants must be updated.
# The related constants are defined in
# <mklinuximg>/include/ambapp.h
# <esp>/rtl/include/grlib/amba/amba.vhd
# <esp>/soft/leon3/include/esp_probe.h
NAPBS = 128
NAHBS = 16
# Physical interrupt lines
IRQ_LINES = 32
# Maximum number of components is not an actual limitation in ESP
# We simply set some value consistently with RTL, but these limits
# can be increased by editing nocpackage accordingly.
# <esp>/rtl/include/sld/noc/nocpackage.vhd
NCPU_MAX = 4
NMEM_MAX = 4
NSLM_MAX = 16
# Caches are provisioning 4 bits for IDs and 16 bits for sharers
# This can be changed here:
# <esp>/systemc/common/caches/cache_consts.h
# <esp>/rtl/include/sld/caches/cachepackage.vhd
NFULL_COHERENT_MAX = 16
NLLC_COHERENT_MAX = 64
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
# 1 - UART
# 2 - Interrupt controller
# 3 - Timer
# 4 - ESPLink
# 5-8 - DVFS controller
# 9-12 - Processors' private cache controller (must change with NCPU_MAX)
# 13 - SVGA controller
# 14 - Ethernet MAC controller
# 15 - Ethernet SGMII PHY controller
# 16-19 - LLC cache controller (must change with NMEM_MAX)
# 20-83 - Distributed monitors (equal to the number of tiles NTILE_MAX)
# 84-(NAPBS-1) - Accelerators
# 127 - PRC
NACC_MAX = NAPBS - 2 * NCPU_MAX - NMEM_MAX - NTILE_MAX - 8


# Default device mapping
RST_ADDR = dict()
RST_ADDR["leon3"] = 0x0
RST_ADDR["ariane"] = 0x10000
RST_ADDR["ibex"] = 0x80

# Default start address for device tree
RODATA_ADDR = dict()
RODATA_ADDR["leon3"] = 0x0
RODATA_ADDR["ariane"] = 0x10400
RODATA_ADDR["ibex"] = 0x500

# Boot ROM slave index (With Leon3 this exists in simulation only for now)
AHBROM_HINDEX = 0

# Memory-mapped registers slave index
AHB2APB_HINDEX = 1

# Memory-mapped registers base address (includes peripherals and accelerators)
AHB2APB_HADDR = dict()
AHB2APB_HADDR["leon3"] = 0x800
AHB2APB_HADDR["ariane"] = 0x600
AHB2APB_HADDR["ibex"] = 0x600

# RISC-V CPU Local Interruptor index
RISCV_CLINT_HINDEX = 2

# Memory controller slave index
DDR_HINDEX = [4, 5, 6, 7]

# First shared-local memory slave index
SLM_HINDEX = 8

# Main memory area (12 MSBs)
DDR_HADDR = dict()
DDR_HADDR["leon3"] = 0x400
DDR_HADDR["ariane"] = 0x800
DDR_HADDR["ibex"] = 0x800

PBS_HADDR = dict()
PBS_HADDR["leon3"] = 0x500
PBS_HADDR["ariane"] = 0xA00

# SLM base address
SLM_HADDR = 0x040
SLMDDR_HADDR = 0xC00

# Main memory size (12 MSBs)
DDR_SIZE = 0x400

# Frame-buffer index
FB_HINDEX = 12

# CPU tile power manager I/O-bus slave index
DVFS_PINDEX = [5, 6, 7, 8]

# private cache physical interrupt line
L2_CACHE_PIRQ = 3

# Private cache I/O-bus slave indices (more indices can be reserved if necessary)
L2_CACHE_PINDEX = [9, 10, 11, 12]

# Last-level cache physical interrupt line
LLC_CACHE_PIRQ = 4

# Last-level cache I/O-bus slave indices (more indices can be reserved if necessary)
LLC_CACHE_PINDEX = [16, 17, 18, 19]

# ESP Tile CSRs APB indices
CSR_PINDEX = list(range(20, 20 + NTILE_MAX))

# I/O memory area offset for CSRs
CSR_APB_ADDR = 0x900
CSR_APB_ADDR_MSK = 0xffe

# First I/O-bus index for accelerators
SLD_APB_PINDEX = 20 + NTILE_MAX

# I/O memory area offset for accelerators (address bits 19-8)
SLD_APB_ADDR = 0x100

# default mask for accelerators' registers base address (256 Bytes regions per accelerator)
SLD_APB_ADDR_MSK = 0xfff

###########
# Constants for third-party accelerators

# third-party accelerators counter
THIRDPARTY_N = 0

# third-party APB address and mask
# If APB EXT ADDR SIZE is not zero, then APB mask will be applied to
# the extended address. Each device instance will reserve EXT SIZE
# bytes in the address space, even if a signle instance would take
# less. This is to simplify (hence speedup) APB decode.
# APB EXT ADDR most significant hex digit (i.e. digit 7) must be 0
THIRDPARTY_APB_ADDRESS          = 0x00000000
THIRDPARTY_APB_ADDRESS_SIZE     = 0x00040000
THIRDPARTY_APB_EXT_ADDRESS      = 0x00400000
THIRDPARTY_APB_EXT_ADDRESS_SIZE = 0x00100000

# Memory reserved for accelerators
ACC_MEM_RESERVED_START_ADDR = 0xA0200000
ACC_MEM_RESERVED_TOTAL_SIZE = 0x1FE00000
THIRDPARTY_MEM_RESERVED_ADDR = 0xB0000000
THIRDPARTY_MEM_RESERVED_SIZE = 0x10000000

# End of constants for third-party accelerators
###########

class acc_info:
  uppercase_name = ""
  lowercase_name = ""
  vendor = ""
  id = -1
  idx = -1
  irq = 6

class cache_info:
  id = -1
  idx = -1


class tile_info:
  type = "empty"
  x = 0
  y = 0
  cpu_id = -1
  mem_id = -1
  slm_id = -1
  slmddr_id = -1
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
  tech = "virtex7"
  cpu_arch = "leon3"
  #components
  ncpu = 0
  nacc = 0
  nmem = 0
  nslm = 0
  slm_kbytes = 0
  slm_tot_kbytes = 0
  slm_full_mask = 0
  nslmddr = 0
  slmddr_kbytes = 0
  slmddr_tot_kbytes = 0
  slmddr_full_mask = 0
  ntiles = 0
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
  # Number of third party accelerators
  nthirdparty = 0

  accelerators = []
  l2s = []
  llcs = []
  dvfs_ctrls = []
  tiles = []
  regions = []
  contig_alloc_ddr = []

  def __init__(self, soc):
    #components
    self.tech = soc.TECH
    self.linux_mac = soc.LINUX_MAC
    self.leon3_stack = soc.LEON3_STACK
    self.cpu_arch = soc.CPU_ARCH.get()
    self.ncpu = soc.noc.get_cpu_num(soc)
    self.nmem = soc.noc.get_mem_num(soc)
    self.nslm = soc.noc.get_slm_num(soc)
    self.slm_kbytes = soc.slm_kbytes.get()
    if self.nslm != 0:
      self.slm_tot_kbytes = self.slm_kbytes * self.nslm
    if self.slm_tot_kbytes > 1024:
      self.slm_full_mask = 0xfff & ~(int(self.slm_tot_kbytes / 1024) - 1)
    else:
      self.slm_full_mask = 0xfff
    self.nslmddr = soc.noc.get_slmddr_num(soc)
    self.slmddr_kbytes = 512 * 1024
    if self.nslmddr != 0:
      self.slmddr_tot_kbytes = self.slmddr_kbytes * self.nslmddr
    self.slmddr_full_mask = 0xfff & ~(int(self.slmddr_tot_kbytes / 1024) - 1)
    self.nacc = soc.noc.get_acc_num(soc)
    self.ntiles = soc.noc.rows * soc.noc.cols
    if soc.cache_en.get() == 0:
      self.coherence = False
    else:
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
    # SLM ID assigned dynamically to each shared-local memory tile
    slm_id = 0
    slmddr_id = 0
    # Accelerator/DMA ID assigned dynamically to each accelerator tile
    acc_id = 0
    # Accelerator interrupt dynamically to each accelerator tile because RISC-V PLIC does not work properly with shared lines
    acc_irq = 3
    if self.cpu_arch == "ariane" or self.cpu_arch == "ibex":
      acc_irq = 5

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
        self.tiles[t].has_ddr = soc.noc.topology[x][y].has_ddr.get()

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
        if selection == "slm" and self.tiles[t].has_ddr == 0:
          self.tiles[t].type = "slm"
          self.tiles[t].slm_id = slm_id
          slm_id = slm_id + 1
        if selection == "slm" and self.tiles[t].has_ddr != 0:
          self.tiles[t].type = "slmddr"
          self.tiles[t].slmddr_id = slmddr_id
          slmddr_id = slmddr_id + 1
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
          acc.irq = acc_irq
          acc.idx = SLD_APB_PINDEX + acc_id
          acc.vendor = soc.noc.topology[x][y].vendor
          if acc.vendor != "sld":
              self.nthirdparty += 1
          self.tiles[t].acc = acc
          self.accelerators.append(acc)
          acc_id = acc_id + 1
          if self.cpu_arch == "ariane" or self.cpu_arch == "ibex":
            acc_irq = acc_irq + 1
            # Skip interrupt lines reserved to Ethernet
            if acc_irq == 11:
              acc_irq = 13

          if self.coherence and (self.tiles[t].has_l2 == 1):
            l2 = cache_info()
            l2.id = acc_l2_id
            self.l2s.append(l2)
            self.tiles[t].l2 = l2
            self.nl2 = self.nl2 + 1
            acc_l2_id = acc_l2_id + 1


def print_header(fp, package):
  fp.write("-- Copyright (c) 2011-2022 Columbia University, System Level Design Group\n")
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
    fp.write("use work.gencomp.all;\n")
    fp.write("use work.amba.all;\n")
    fp.write("use work.sld_devices.all;\n")
    fp.write("use work.devices.all;\n")
    fp.write("use work.misc.all;\n")
    fp.write("use work.leon3.all;\n")
    fp.write("use work.nocpackage.all;\n")
    fp.write("use work.cachepackage.all;\n")
    fp.write("use work.allcaches.all;\n")

  fp.write("\n")

def print_global_constants(fp, soc):
  fp.write("  ------ Global architecture parameters\n")
  fp.write("  constant ARCH_BITS : integer := " + str(soc.DMA_WIDTH) + ";\n")
  fp.write("  constant GLOB_MAXIOSLV : integer := " + str(NAPBS) + ";\n")
  # Keep cache-line size constant to 128 bits for now. We don't want huge line buffers
  fp.write("  constant GLOB_WORD_OFFSET_BITS : integer := " + str(int(math.log2(128/soc.DMA_WIDTH))) + ";\n")
  fp.write("  constant GLOB_BYTE_OFFSET_BITS : integer := " + str(int(math.log2(soc.DMA_WIDTH/8))) +";\n")
  fp.write("  constant GLOB_OFFSET_BITS : integer := GLOB_WORD_OFFSET_BITS + GLOB_BYTE_OFFSET_BITS;\n")
  fp.write("  constant GLOB_ADDR_INCR : integer := " + str(int(soc.DMA_WIDTH/8)) +";\n")
  # TODO: Keep physical address to 32 bits for now to reduce tag size. This will increase to support more memory
  fp.write("  constant GLOB_PHYS_ADDR_BITS : integer := " + str(32) +";\n")
  fp.write("  type cpu_arch_type is (leon3, ariane, ibex);\n")
  fp.write("  constant GLOB_CPU_ARCH : cpu_arch_type := " + soc.CPU_ARCH.get() + ";\n")
  if soc.CPU_ARCH.get() == "ariane":
    fp.write("  constant GLOB_CPU_AXI : integer range 0 to 1 := 1;\n")
  else:
    fp.write("  constant GLOB_CPU_AXI : integer range 0 to 1 := 0;\n")
  if soc.CPU_ARCH.get() == "leon3":
    fp.write("  constant GLOB_CPU_RISCV : integer range 0 to 1 := 0;\n")
  else:
    fp.write("  constant GLOB_CPU_RISCV : integer range 0 to 1 := 1;\n")
  if soc.CPU_ARCH.get() == "ariane":
    fp.write("  constant GLOB_CPU_LLSC : integer range 0 to 1 := 1;\n")
  else:
    fp.write("  constant GLOB_CPU_LLSC : integer range 0 to 1 := 0;\n")
  fp.write("\n")
  # RTL caches
  if soc.cache_rtl.get() == 1:
    fp.write("  constant CFG_CACHE_RTL   : integer := 1;\n")
  else:
    fp.write("  constant CFG_CACHE_RTL   : integer := 0;\n\n")
  #prc config
  if soc.prc.get() == 1:
    fp.write("  constant CFG_PRC   : integer := 1;\n")
  else:
    fp.write("  constant CFG_PRC   : integer := 0;\n")
  if soc.cache_spandex.get() == 1:
    fp.write("  constant USE_SPANDEX     : integer := 1;\n")
  else:
    fp.write("  constant USE_SPANDEX     : integer := 0;\n")
  fp.write("\n")


def print_constants(fp, soc, esp_config):
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
  fp.write("  constant CFG_NSLM_TILE : integer := " + str(esp_config.nslm) + ";\n")
  fp.write("  constant CFG_NSLMDDR_TILE : integer := " + str(esp_config.nslmddr) + ";\n")
  fp.write("  constant CFG_NL2 : integer := " + str(esp_config.nl2) + ";\n")
  fp.write("  constant CFG_NLLC : integer := " + str(esp_config.nllc) + ";\n")
  fp.write("  constant CFG_NLLC_COHERENT : integer := " + str(esp_config.ncdma) + ";\n")
  fp.write("  constant CFG_SLM_KBYTES : integer := " + str(esp_config.slm_kbytes) + ";\n\n")
  fp.write("  constant CFG_SLMDDR_KBYTES : integer := " + str(esp_config.slmddr_kbytes) + ";\n\n")

  #
  fp.write("  ------ Local-port Synchronizers are always present)\n")
  fp.write("  constant CFG_HAS_SYNC : integer := 1;\n")
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
  fp.write("  ------ PRC interrupt line\n")
  fp.write("  constant CFG_PRC_IRQ : integer := 5;\n")


def print_mapping(fp, soc, esp_config):

  fp.write("  constant CFG_FABTECH : integer := " + soc.TECH  + ";\n\n")

  #
  fp.write("  ------ Maximum number of slaves on both HP bus and I/O-bus\n")
  fp.write("  constant maxahbm : integer := NAHBMST;\n")
  fp.write("  constant maxahbs : integer := NAHBSLV;\n\n")

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

  fp.write("\n")

  #
  fp.write("  ------ Plug&Play info on HP bus\n")

  #
  fp.write("  -- Leon3 CPU cores\n")
  fp.write("  constant leon3_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON3, 0, LEON3_VERSION, 0),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Ibex CPU cores\n")
  fp.write("  constant ibex_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_LOWRISC, LOWRISC_IBEX_SMALL, 0, 0, 0),\n")
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
  fp.write("  -- BOOT ROM HP slave\n")
  fp.write("  constant ahbrom_hindex  : integer := " + str(AHBROM_HINDEX) + ";\n")
  fp.write("  constant ahbrom_haddr   : integer := 16#000#;\n")
  fp.write("  constant ahbrom_hmask   : integer := 16#fff#;\n")
  fp.write("  constant ahbrom_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(ahbrom_haddr, '1', '1', ahbrom_hmask),\n")
  fp.write("    others => zero32);\n")

  
  fp.write("  -- AHB2APB bus bridge slave\n")
  fp.write("  constant CFG_APBADDR : integer := 16#" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "#;\n")
  fp.write("  constant ahb2apb_hindex : integer := " + str(AHB2APB_HINDEX) + ";\n")
  fp.write("  constant ahb2apb_haddr : integer := CFG_APBADDR;\n")
  fp.write("  constant ahb2apb_hmask : integer := 16#F00#;\n")
  fp.write("  constant ahb2apb_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( 1, 6, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(CFG_APBADDR, '0', '0', ahb2apb_hmask),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- RISC-V CLINT\n")
  fp.write("  constant clint_hindex  : integer := " + str(RISCV_CLINT_HINDEX) + ";\n")
  fp.write("  constant clint_haddr   : integer := 16#020#;\n")
  fp.write("  constant clint_hmask   : integer := 16#fff#;\n")
  fp.write("  constant clint_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_SIFIVE, SIFIVE_CLINT0, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(clint_haddr, '0', '0', clint_hmask),\n")
  fp.write("    others => zero32);\n\n")

  #
  fp.write("  -- Debug access points proxy index\n")
  fp.write("  constant dbg_remote_ahb_hindex : integer := 3;\n\n")

  #
  fp.write("  ----  Shared Local Memory\n")
  # Reserve 64MB (no need to check total size!)
  # If memory tiles are present: 0x04000000 - 0x08000000 
  # If no memory tile is present:
  #  - RISC-V   : 0x80000000 - 0x88000000
  #  - SPARC V8 : 0x40000000 - 0x48000000
  # Smaller alowed size for an SLM tile is 1 MB
  if esp_config.nmem == 0:
    # Use SLM in as main memory
    global SLM_HADDR
    SLM_HADDR = DDR_HADDR[esp_config.cpu_arch]
  offset = SLM_HADDR;
  mask = 0xfff
  if esp_config.slm_kbytes >= 1024:
    mask = 0xfff & ~(int(esp_config.slm_kbytes / 1024) - 1)
  # Use any available hindex
  hindex = SLM_HINDEX

  if esp_config.nslm == 0:
    fp.write("  constant slm_hindex : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slm_hindex : attribute_vector(0 to CFG_NSLM_TILE - 1) := (\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i) + " => " + str(hindex) + ",\n")
    hindex = hindex + 1;
    if hindex == 12:
      hindex = 13
  fp.write("    others => 0);\n")

  if esp_config.nslm == 0:
    fp.write("  constant slm_haddr : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slm_haddr : attribute_vector(0 to CFG_NSLM_TILE - 1) := (\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i) + " => 16#" + format(offset, '03X') + "#,\n")
    offset = offset + int(esp_config.slm_kbytes / 1024)
  fp.write("    others => 0);\n")

  if esp_config.nslm == 0:
    fp.write("  constant slm_hmask : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slm_hmask : attribute_vector(0 to CFG_NSLM_TILE - 1) := (\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i) + " => 16#" + format(mask, '03X') + "#,\n")
  fp.write("    others => 0);\n")

  fp.write("  constant slm_hconfig : ahb_slv_config_vector := (\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      0 => ahb_device_reg ( VENDOR_SLD, SLD_SLM, 0, 0, 0),\n")
    fp.write("      4 => ahb_membar(slm_haddr(" + str(i) + "), '0', '0', slm_hmask(" + str(i) + ")),\n")
    fp.write("      others => zero32),\n")
  fp.write("    others => hconfig_none);\n\n")

  fp.write("  -- CPU tiles don't need to know how the address space is split across shared\n")
  fp.write("  -- local memory tiles and each CPU should be able to address any region\n")
  fp.write("  -- transparently.\n")
  fp.write("  constant cpu_tile_slm_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_SLD, SLD_SLM, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(16#" + format(SLM_HADDR, '03X') + "#, '0', '0', 16#" + format(esp_config.slm_full_mask, '03X')  + "#),\n")
  fp.write("    others => zero32);\n\n")


  # SLM Tiles with off-chip DDR memory
  global SLMDDR_HADDR
  offset = SLMDDR_HADDR;
  mask = 0xfff
  mask = 0xfff & ~(int(esp_config.slmddr_kbytes / 1024) - 1)
  # Use any available hindex
  hindex = SLM_HINDEX + esp_config.nslm

  if esp_config.nslmddr == 0:
    fp.write("  constant slmddr_hindex : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slmddr_hindex : attribute_vector(0 to CFG_NSLMDDR_TILE - 1) := (\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(i) + " => " + str(hindex) + ",\n")
    hindex = hindex + 1;
    if hindex == 12:
      hindex = 13
  fp.write("    others => 0);\n")

  if esp_config.nslmddr == 0:
    fp.write("  constant slmddr_haddr : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slmddr_haddr : attribute_vector(0 to CFG_NSLMDDR_TILE - 1) := (\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(i) + " => 16#" + format(offset, '03X') + "#,\n")
    offset = offset + int(esp_config.slmddr_kbytes / 1024)
  fp.write("    others => 0);\n")

  if esp_config.nslmddr == 0:
    fp.write("  constant slmddr_hmask : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slmddr_hmask : attribute_vector(0 to CFG_NSLMDDR_TILE - 1) := (\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(i) + " => 16#" + format(mask, '03X') + "#,\n")
  fp.write("    others => 0);\n")

  fp.write("  constant slmddr_hconfig : ahb_slv_config_vector := (\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
    fp.write("      4 => ahb_membar(slmddr_haddr(" + str(i) + "), '0', '0', slmddr_hmask(" + str(i) + ")),\n")
    fp.write("      others => zero32),\n")
  fp.write("    others => hconfig_none);\n\n")

  fp.write("  -- CPU tiles don't need to know how the address space is split across shared\n")
  fp.write("  -- local memory tiles and each CPU should be able to address any region\n")
  fp.write("  -- transparently.\n")
  fp.write("  constant cpu_tile_slmddr_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(16#" + format(SLMDDR_HADDR, '03X') + "#, '0', '0', 16#" + format(esp_config.slmddr_full_mask, '03X')  + "#),\n")
  fp.write("    others => zero32);\n\n")


  #
  fp.write("  ----  Memory controllers\n")
  offset = DDR_HADDR[esp_config.cpu_arch];
  if esp_config.nmem > 0:
    size = int(DDR_SIZE / esp_config.nmem)
  else:
    size = DDR_SIZE
  mask = 0xfff & ~(size - 1)
  full_mask = 0xfff & ~(DDR_SIZE - 1)

  #
  fp.write("  -- CPU tiles don't need to know how the address space is split across memory tiles\n")
  fp.write("  -- and each CPU should be able to address any region transparently.\n")
  fp.write("  constant cpu_tile_mig7_hconfig : ahb_config_type := (\n")
  fp.write("    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),\n")
  fp.write("    4 => ahb_membar(16#" + format(DDR_HADDR[esp_config.cpu_arch], '03X') + "#, '1', '1', 16#" + format(full_mask, '03X')  + "#),\n")
  fp.write("    others => zero32);\n")

  #
  if esp_config.nmem == 0:
    ddr_vec_attribute_msb = "0"
  else:
    ddr_vec_attribute_msb = "CFG_NMEM_TILE - 1"

  fp.write("  -- Network interfaces and ESP proxies, instead, need to know how to route packets\n")
  fp.write("  constant ddr_hindex : attribute_vector(0 to " + ddr_vec_attribute_msb  + ") := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => " + str(DDR_HINDEX[i]) + ",\n")
  fp.write("    others => 0);\n")

  fp.write("  constant ddr_haddr : attribute_vector(0 to " + ddr_vec_attribute_msb  + ") := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => 16#" + format(offset, '03X') + "#,\n")
    offset = offset + size
  fp.write("    others => 0);\n")

  fp.write("  constant ddr_hmask : attribute_vector(0 to " + ddr_vec_attribute_msb  + ") := (\n")
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
  fp.write("    " + str(AHBROM_HINDEX) + " => ahbrom_hconfig,\n")
  fp.write("    " + str(AHB2APB_HINDEX) + " => ahb2apb_hconfig,\n")
  if esp_config.cpu_arch == "ariane" or esp_config.cpu_arch == "ibex":
    fp.write("    " + str(RISCV_CLINT_HINDEX) + " => clint_hconfig,\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(DDR_HINDEX[i]) + " => mig7_hconfig(" + str(i) + "),\n")
  for i in range(0, esp_config.nslm):
    index = SLM_HINDEX + i
    if index >= 12:
      index = index + 1
    fp.write("    " + str(index) + " => slm_hconfig(" + str(i) + "),\n")
  for i in range(0, esp_config.nslmddr):
    index = SLM_HINDEX + esp_config.nslm + i
    if index >= 12:
      index = index + 1
    fp.write("    " + str(index) + " => slmddr_hconfig(" + str(i) + "),\n")
  fp.write("    " + str(FB_HINDEX) + " => fb_hconfig,\n")
  fp.write("    others => hconfig_none);\n\n")

  #
  fp.write("  -- HP slaves index / memory map for CPU tile\n")
  fp.write("  -- CPUs need to see memory as a single address range\n")
  fp.write("  constant cpu_tile_fixed_ahbso_hconfig : ahb_slv_config_vector := (\n")
  fp.write("    " + str(AHBROM_HINDEX) + " => ahbrom_hconfig,\n")
  fp.write("    " + str(AHB2APB_HINDEX) + " => ahb2apb_hconfig,\n")
  if esp_config.cpu_arch == "ariane" or esp_config.cpu_arch == "ibex":
    fp.write("    " + str(RISCV_CLINT_HINDEX) + " => clint_hconfig,\n")
  if esp_config.nmem != 0:
    fp.write("    " + str(DDR_HINDEX[0]) + " => cpu_tile_mig7_hconfig,\n")
  fp.write("    " + str(SLM_HINDEX) + " => cpu_tile_slm_hconfig,\n")
  fp.write("    " + str(SLM_HINDEX + 1) + " => cpu_tile_slmddr_hconfig,\n")
  fp.write("    " + str(FB_HINDEX) + " => fb_hconfig,\n")
  fp.write("    others => hconfig_none);\n\n")

  #
  fp.write("  ------ Plug&Play info on I/O bus\n")

  #
  fp.write("  -- UART (GRLIB)\n")
  fp.write("  constant uart_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBUART, 0, 1, CFG_UART1_IRQ),\n")
  fp.write("  1 => apb_iobar(16#001#, 16#fff#),\n")
  fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- PRC \n") 
  fp.write("  constant prc_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg ( VENDOR_XIL, XILINX_PRC, 0, 1, CFG_PRC_IRQ),\n") #define device 
  fp.write("  1 => apb_iobar(16#0E4#, 16#fff#),\n")
  fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- Interrupt controller (Architecture-dependent)\n")
  fp.write("  -- RISC-V PLIC is using the extended APB address space\n")
  fp.write("  constant irqmp_pconfig : apb_config_type := (\n")
  if esp_config.cpu_arch == "leon3":
    fp.write("  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_IRQMP, 0, 3, 0),\n")
    fp.write("  1 => apb_iobar(16#002#, 16#fff#),\n")
    fp.write("  2 => (others => '0'));\n\n")
  elif esp_config.cpu_arch == "ariane" or esp_config.cpu_arch == "ibex":
    fp.write("  0 => ahb_device_reg ( VENDOR_SIFIVE, SIFIVE_PLIC0, 0, 3, 0),\n")
    fp.write("  1 => apb_iobar(16#000#, 16#000#),\n")
    fp.write("  2 => apb_iobar(16#0C0#, 16#FC0#));\n\n")

  #
  fp.write("  -- Timer (GRLIB)\n")
  fp.write("  constant gptimer_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_GPTIMER, 0, 1, CFG_GPT_IRQ),\n")
  fp.write("  1 => apb_iobar(16#003#, 16#fff#),\n")
  fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- Ibex Timer\n")
  fp.write("  constant ibex_timer_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_LOWRISC, LOWRISC_IBEX_TIMER, 0, 1, 0),\n")
  fp.write("  1 => apb_iobar(16#003#, 16#fff#),\n")
  fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- ESPLink\n")
  fp.write("  constant esplink_pconfig : apb_config_type := (\n")
  fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_ESPLINK, 0, 0, 0),\n")
  fp.write("  1 => apb_iobar(16#004#, 16#fff#),\n")
  fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- SVGA controler (GRLIB)\n")
  if esp_config.has_svga:
    fp.write("  constant svga_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SVGACTRL, 0, 0, 0),\n")
    fp.write("  1 => apb_iobar(16#006#, 16#fff#),\n")
    fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- Ethernet MAC (GRLIB)\n")
  if esp_config.has_eth:
    fp.write("  constant eth0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_ETHMAC, 0, 0, 12),\n")
    fp.write("  1 => apb_iobar(16#800#, 16#f00#),\n")
    fp.write("  2 => (others => '0'));\n\n")

    fp.write("  constant sgmii0_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_SGMII, 0, 1, 11),\n")
    fp.write("  1 => apb_iobar(16#010#, 16#ff0#),\n")
    fp.write("  2 => (others => '0'));\n\n")

  #
  fp.write("  -- CPU DVFS controller\n")
  fp.write("  -- Accelerators' power controllers are mapped to the upper half of their I/O\n")
  fp.write("  -- address space. In the future, each DVFS controller should be assigned to an independent\n")
  fp.write("  -- region of the address space, thus allowing discovery from the device tree.\n")

  fp.write("  constant cpu_dvfs_paddr : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
      fp.write("      1 => apb_iobar(16#" + format(0xD0 + dvfs.idx, '03X') + "#, 16#fff#),\n")
      fp.write("      2 => (others => '0')),\n")
  fp.write("    others => pconfig_none);\n\n")

  #
  fp.write("  -- L2\n")
  fp.write("  -- Accelerator's caches cannot be flushed/reset from I/O-bus\n")
  fp.write("  constant l2_cache_pconfig : apb_l2_pconfig_vector := (\n")
  for i in range(0, esp_config.nl2):
    l2 = esp_config.l2s[i]
    if l2.idx != -1:
      fp.write("    " + str(l2.id) + " => (\n")
      if soc.cache_spandex.get() == 1:
        fp.write("      0 => ahb_device_reg (VENDOR_UIUC, UIUC_SPANDEX_L2, 0, 0, CFG_SLD_L2_CACHE_IRQ),\n")
      else:
        fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_L2_CACHE, 0, 0, CFG_SLD_L2_CACHE_IRQ),\n")
      fp.write("      1 => apb_iobar(16#" + format(0xD0 + l2.idx, '03X') + "#, 16#fff#),\n")
      fp.write("      2 => (others => '0')),\n")
  fp.write("    others => pconfig_none);\n\n")

  #
  fp.write("  -- LLC\n")
  fp.write("  constant llc_cache_pconfig : apb_llc_pconfig_vector := (\n")
  for i in range(0, esp_config.nllc):
    llc = esp_config.llcs[i]
    fp.write("    " + str(i) + " => (\n")
    if soc.cache_spandex.get() == 1:
      fp.write("      0 => ahb_device_reg (VENDOR_UIUC, UIUC_SPANDEX_LLC, 0, 0, CFG_SLD_LLC_CACHE_IRQ),\n")
    else:
      fp.write("      0 => ahb_device_reg (VENDOR_SLD, SLD_LLC_CACHE, 0, 0, CFG_SLD_LLC_CACHE_IRQ),\n")
    fp.write("      1 => apb_iobar(16#" + format(0xD0 + llc.idx, '03X') + "#, 16#fff#),\n")
    fp.write("      2 => (others => '0')),\n")
  fp.write("    others => pconfig_none);\n\n")


  #
  fp.write("  -- ESP Tiles CSRs\n")
  csr_apb_size = (~CSR_APB_ADDR_MSK & 0xfff) + 1
  for i in range(0, esp_config.ntiles):
    address_str = format(CSR_APB_ADDR + i * csr_apb_size, "03X")
    msk_str = format(CSR_APB_ADDR_MSK, "03X")
    fp.write("  constant csr_t_" + str(i) + "_pindex : integer range 0 to NAPBSLV - 1 := " + str(CSR_PINDEX[i]) + ";\n")
    fp.write("  constant csr_t_" + str(i) + "_paddr : integer range 0 to 4095 := 16#" + address_str + "#;\n")
    fp.write("  constant csr_t_" + str(i) + "_pmask : integer range 0 to 4095 := 16#" + msk_str + "#;\n")
    fp.write("  constant csr_t_" + str(i) + "_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_TILE_CSR, 0, 0, 0),\n")
    fp.write("  1 => apb_iobar(16#" + address_str + "#, 16#" + msk_str  + "#),\n")
    fp.write("  2 => (others => '0'));\n\n")


  #
  fp.write("  -- Accelerators\n")
  fp.write("  constant accelerators_num : integer := " + str(esp_config.nacc) + ";\n\n")
  # Reset all THIRDPARTY accelerators counters
  THIRDPARTY_N = 0

  for i in range(esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("  -- Accelerator " + str(acc.id) + "\n")
    fp.write("  -- APB " + str(acc.idx) + "\n")
    fp.write("  -- " + acc.uppercase_name + "\n")

    if acc.vendor == "sld":
      address = SLD_APB_ADDR + acc.id
      address_ext = 0
      msk = SLD_APB_ADDR_MSK
      msk_ext = 0
      address_str = format(address, "03X")
      address_ext_str = format(address_ext, "03X")
    else:
      n = THIRDPARTY_N
      # Compute base address
      if THIRDPARTY_APB_EXT_ADDRESS == 0:
        # Use part of standard APB address space
        address = THIRDPARTY_APB_ADDRESS + n * THIRDPARTY_APB_ADDRESS_SIZE
        size = THIRDPARTY_APB_ADDRESS_SIZE
        address_ext = 0
        size_ext = 0
      else:
        # Use extended APB address space (large number of registers)
        address = 0
        size = 0
        address_ext = THIRDPARTY_APB_EXT_ADDRESS + n * THIRDPARTY_APB_EXT_ADDRESS_SIZE
        size_ext = THIRDPARTY_APB_EXT_ADDRESS_SIZE

      msk = 0xfff & ~((size >> 8) - 1)
      msk_ext = 0xfff & ~((size_ext >> 20) - 1)
      address_str = format(address >> 8, "03X")
      address_ext_str = format(address_ext >> 20, "03X")

      # Increment count
      THIRDPARTY_N = n + 1;

    msk_str = format(msk, "03X")
    msk_ext_str = format(msk_ext, "03X")

    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pindex : integer range 0 to NAPBSLV - 1 := " + str(acc.idx) + ";\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pirq : integer range 0 to NAHBIRQ - 1 := " + str(acc.irq) + ";\n")
    if acc.vendor == "sld":
      fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_irq_type : integer range 0 to 1 := " + "0" + ";\n")
    else:
      fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_irq_type : integer range 0 to 1 := " + THIRDPARTY_IRQ_TYPE[acc.lowercase_name] + ";\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_paddr : integer range 0 to 4095 := 16#" + str(address_str) + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pmask : integer range 0 to 4095 := 16#" + str(msk_str) + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_paddr_ext : integer range 0 to 4095 := 16#" + str(address_ext_str) + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pmask_ext : integer range 0 to 4095 := 16#" + str(msk_ext_str) + "#;\n")
    fp.write("  constant " + acc.lowercase_name + "_" + str(acc.id) + "_pconfig : apb_config_type := (\n")
    fp.write("  0 => ahb_device_reg (VENDOR_SLD, SLD_" + acc.uppercase_name + ", 0, 0, " + str(acc.irq) + "),\n")
    fp.write("  1 => apb_iobar(16#" + address_str + "#, 16#" + msk_str  + "#),\n")
    if address_ext == 0:
      fp.write("  2 => (others => '0'));\n\n")
    else:
      fp.write("  2 => apb_iobar(16#" + address_ext_str + "#, 16#" + msk_ext_str  + "#));\n\n")

  #
  fp.write("  -- I/O bus slaves index / memory map\n")
  fp.write("  constant fixed_apbo_pconfig : apb_slv_config_vector := (\n")
  fp.write("    1 => uart_pconfig,\n")
  fp.write("    2 => irqmp_pconfig,\n")
  if esp_config.cpu_arch == "ibex":
    fp.write("    3 => ibex_timer_pconfig,\n")
  else:
    fp.write("    3 => gptimer_pconfig,\n")
  fp.write("    4 => esplink_pconfig,\n")
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
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(CSR_PINDEX[i]) + " => csr_t_" + str(i) + "_pconfig,\n")
  for i in range(0, esp_config.nacc):
    acc = esp_config.accelerators[i]
    fp.write("    " + str(acc.idx) + " => " + str(acc.lowercase_name) + "_" + str(acc.id) + "_pconfig,\n")
  fp.write("   127 => prc_pconfig,\n")
  fp.write("    others => pconfig_none);\n\n")


  #
  fp.write("  ------ Cross reference arrays\n")

  #
  fp.write("  -- Get CPU ID from tile ID\n")
  fp.write("  constant tile_cpu_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.cpu_id != -1:
      fp.write("    " + str(i) + " => " + str(t.cpu_id) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID from CPU ID\n")
  fp.write("  constant cpu_tile_id : attribute_vector(0 to CFG_NCPU_TILE - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "cpu":
      fp.write("    " + str(esp_config.tiles[i].cpu_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get DVFS controller pindex from tile ID\n")
  fp.write("  constant cpu_dvfs_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "cpu" and t.has_pll != 0:
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].dvfs.idx) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get L2 cache ID from tile ID\n")
  fp.write("  constant tile_cache_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    l2 = esp_config.tiles[i].l2
    if l2.id != -1:
      fp.write("    " + str(i) + " => " + str(l2.id) + ",\n")
  fp.write("    others => 0);\n\n")

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
  fp.write("  constant l2_cache_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "cpu" and t.l2.idx != -1:
      fp.write("    " + str(i) + " => " + str(t.l2.idx) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Flag tiles that have a private cache\n")
  fp.write("  constant tile_has_l2 : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_l2) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get LLC ID from tile ID\n")
  fp.write("  constant tile_llc_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    llc = esp_config.tiles[i].llc
    if llc.id != -1:
      fp.write("    " + str(i) + " => " + str(llc.id) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID from LLC-split ID\n")
  fp.write("  constant llc_tile_id : attribute_vector(0 to " + ddr_vec_attribute_msb  + ") := (\n")
  for i in  range(0, esp_config.ntiles):
    llc = esp_config.tiles[i].llc
    if llc.id != -1:
      fp.write("    " + str(llc.id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get LLC pindex from tile ID\n")
  fp.write("  constant llc_cache_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "mem" and t.llc.idx != -1:
      fp.write("    " + str(i) + " => " + str(t.llc.idx) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID from shared-local memory ID ID\n")
  if esp_config.nslm == 0:
    fp.write("  constant slm_tile_id : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slm_tile_id : attribute_vector(0 to CFG_NSLM_TILE - 1) := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.slm_id != -1:
      fp.write("    " + str(t.slm_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get shared-local memory tile ID from tile ID\n")
  fp.write("  constant tile_slm_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.slm_id != -1:
      fp.write("    " + str(i) + " => " + str(t.slm_id) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID from shared-local memory with DDR ID ID\n")
  if esp_config.nslmddr == 0:
    fp.write("  constant slmddr_tile_id : attribute_vector(0 to 0) := (\n")
  else:
    fp.write("  constant slmddr_tile_id : attribute_vector(0 to CFG_NSLMDDR_TILE - 1) := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.slmddr_id != -1:
      fp.write("    " + str(t.slmddr_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get shared-local memory tile ID from tile ID\n")
  fp.write("  constant tile_slmddr_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.slmddr_id != -1:
      fp.write("    " + str(i) + " => " + str(t.slmddr_id) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get tile ID from memory ID\n")
  fp.write("  constant mem_tile_id : attribute_vector(0 to " + ddr_vec_attribute_msb  + ") := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      fp.write("    " + str(t.mem_id) + " => " + str(i) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get memory tile ID from tile ID\n")
  fp.write("  constant tile_mem_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      fp.write("    " + str(i) + " => " + str(t.mem_id) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get CSR pindex from tile ID\n")
  fp.write("  constant tile_csr_pindex : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(i) + " => " + str(CSR_PINDEX[i]) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get accelerator ID from tile ID\n")
  fp.write("  constant tile_acc_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.acc.id != -1:
      fp.write("    " + str(i) + " => " + str(t.acc.id) + ",\n")
  fp.write("    others => 0);\n\n")

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
  fp.write("  constant tile_dma_id : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
  fp.write("  constant tile_type : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
    if esp_config.tiles[i].type == "slm":
      type = 5
    if esp_config.tiles[i].type == "slmddr":
      type = 6
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

  fp.write("  constant tile_apb_paddr_ext : tile_addr_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_paddr_ext,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get I/O-bus address mask for accelerators from tile ID\n")
  fp.write("  constant tile_apb_pmask : tile_addr_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_pmask,\n")
  fp.write("    others => 0);\n\n")

  fp.write("  constant tile_apb_pmask_ext : tile_addr_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_pmask_ext,\n")
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
  fp.write("  -- Get IRQ line type for accelerators from tile ID\n")
  fp.write("  -- IRQ line types:\n")
  fp.write("  --     0 : edge-sensitive\n")
  fp.write("  --     1 : level-sensitive\n")
  fp.write("  constant tile_irq_type : tile_irq_array := (\n")
  for i in range(0, esp_config.ntiles):
    if esp_config.tiles[i].type == "acc":
      acc = esp_config.tiles[i].acc
      fp.write("    " + str(i) + " => " + acc.lowercase_name + "_" + str(acc.id) + "_irq_type,\n")
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
  fp.write("  constant tile_has_dvfs : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
  fp.write("  constant tile_has_pll : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
  if esp_config.has_dvfs:
    for i in range(0, esp_config.ntiles):
      fp.write("    " + str(i) + " => " + str(esp_config.tiles[i].has_pll) + ",\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  -- Get clock domain from tile ID\n")
  fp.write("  constant tile_domain : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
  fp.write("  constant tile_domain_master : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
  fp.write("  constant extra_clk_buf : attribute_vector(0 to CFG_TILES_NUM - 1) := (\n")
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
  # 20-83 - ESP Tile CSRs
  for i in range(0, esp_config.ntiles):
    fp.write("    " + str(CSR_PINDEX[i]) + " => " + str(i) + ",\n")
  # 20-(NAPBSLV - 1) - Accelerators
  for i in range(0, esp_config.ntiles):
    t =  esp_config.tiles[i]
    if t.type == "acc":
      acc_pindex = t.acc.idx
      fp.write("    " + str(acc_pindex) + " => " + str(i) + ",\n")
    # 16-19 - LLC cache controller (must change with NMEM_MAX)
    if t.type == "mem":
      if esp_config.coherence:
        llc_pindex = t.llc.idx
        fp.write("    " + str(llc_pindex) + " => " + str(i) + ",\n")
    # 5-8 - Processors' DVFS controller (must change with NCPU_MAX)
    # 9-12 - Processors' private cache controller (must change with NCPU_MAX)
    if t.type == "cpu":
      if t.has_pll != 0:
        fp.write("    " + str(t.dvfs.idx) + " => " + str(i) + ",\n")
      if esp_config.coherence:
        fp.write("    " + str(t.l2.idx) + " => " + str(i) + ",\n")
  if soc.prc.get() == 1:
    fp.write("    127 => io_tile_id,\n")
  fp.write("    others => 0);\n\n")

  #
  fp.write("  constant esp_init_sequence : attribute_vector(0 to CFG_TILES_NUM + CFG_NCPU_TILE - 1) := (\n")
  fp.write("    ")
  # Set tile_id to adjacent tiles starting from tile_io
  for i in list(range(esp_config.tiles[misc_id].row, -1, -1)) + list(range(esp_config.tiles[misc_id].row + 1, soc.noc.rows)):
    for j in list(range(esp_config.tiles[misc_id].col, -1, -1)) + list(range(esp_config.tiles[misc_id].col + 1, soc.noc.cols)):
      tile_id = i * soc.noc.cols + j
      if tile_id != misc_id:
        fp.write(", ")
      fp.write(str(tile_id))
  # Mark tile_id configuration valid for CPU tiles. Set CPU0 last.
  for i in range(esp_config.ntiles - 1, -1, -1):
    t =  esp_config.tiles[i]
    if t.type == "cpu":
      fp.write(", " + str(i))
  fp.write(");\n\n")

  fp.write("  constant esp_srst_sequence : attribute_vector(0 to CFG_NMEM_TILE + CFG_NCPU_TILE - 1) := (\n")
  fp.write("    ")
  # Send srs to MEM tiles (LLC) and to CPU tiles. Reset CPU0 last.
  first = True
  for i in range(esp_config.ntiles - 1, -1, -1):
    t =  esp_config.tiles[i]
    if t.type == "mem":
      if first:
        first = False
      else:
        fp.write(", ")
      fp.write(str(i))
  for i in range(esp_config.ntiles - 1, -1, -1):
    t =  esp_config.tiles[i]
    if t.type == "cpu":
      if first:
        first = False
        if esp_config.tiles[i].cpu_id == 0:
          fp.write("0 => ")
      else:
        fp.write(", ")
      fp.write(str(i))
  fp.write(");\n\n")


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
  fp.write("  constant cpu_y : yx_vec(0 to CFG_NCPU_TILE - 1) := (\n")
  for i in range(0, esp_config.ncpu):
    if i > 0:
      fp.write(",\n")
    fp.write("   " + str(i) + " => tile_y(cpu_tile_id(" + str(i) + "))")
  fp.write("  );\n")

  fp.write("  constant cpu_x : yx_vec(0 to CFG_NCPU_TILE - 1) := (\n")
  for i in range(0, esp_config.ncpu):
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
  fp.write("  -- SLM YX coordinates and tiles routing info\n")
  fp.write("  constant tile_slm_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1):= (\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      x => tile_x(slm_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(slm_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => slm_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => slm_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(esp_config.nslm + i) + " => (\n")
    fp.write("      x => tile_x(slmddr_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(slmddr_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => slmddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => slmddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  #
  fp.write("  -- LLC YX coordinates and memory tiles routing info\n")
  fp.write("  constant tile_mem_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1) := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      x => tile_x(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => ddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => ddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  fp.write("    others => tile_mem_info_none);\n\n")

  #
  fp.write("  -- Add the frame buffer and SLM tiles entries for accelerators' DMA.\n")
  fp.write("  -- NB: accelerators can only access the frame buffer and SLM if\n")
  fp.write("  -- non-coherent DMA is selected from software.\n")
  fp.write("  constant tile_acc_mem_list : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE) := (\n")
  for i in range(0, esp_config.nmem):
    fp.write("    " + str(i) + " => (\n")
    fp.write("      x => tile_x(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(mem_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => ddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => ddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  for i in range(0, esp_config.nslm):
    fp.write("    " + str(i + esp_config.nmem) + " => (\n")
    fp.write("      x => tile_x(slm_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(slm_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => slm_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => slm_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  for i in range(0, esp_config.nslmddr):
    fp.write("    " + str(i + esp_config.nmem + esp_config.nslm) + " => (\n")
    fp.write("      x => tile_x(slmddr_tile_id(" + str(i) + ")),\n")
    fp.write("      y => tile_y(slmddr_tile_id(" + str(i) + ")),\n")
    fp.write("      haddr => slmddr_haddr(" + str(i)  + "),\n")
    fp.write("      hmask => slmddr_hmask(" + str(i)  + ")\n")
    fp.write("    ),\n")
  if esp_config.has_svga:
    fp.write("    " + str(esp_config.nmem + esp_config.nslm + esp_config.nslmddr) + " => (\n")
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
  fp.write("  -- Note that all components appear as remote to CPU and I/O tiles even if\n")
  fp.write("  -- located in that tile. This is because local masters still have to go\n")
  fp.write("  -- through ESP proxies to address such devices (e.g. L2 cache and DVFS\n")
  fp.write("  -- controller in CPU tiles). This choice allows any master in the SoC to\n")
  fp.write("  -- access these slaves. For instance, when configuring DVFS, a single CPU\n")
  fp.write("  -- must be able to access all DVFS controllers from other CPUS; another\n")
  fp.write("  -- example is the synchronized flush of all private caches, which is\n")
  fp.write("  -- initiated by a single CPU\n")
  fp.write("  constant remote_apb_slv_mask_cpu : std_logic_vector(0 to NAPBSLV - 1) := (\n")
  fp.write("    1 => '1',\n")
  fp.write("    2 => '1',\n")
  fp.write("    3 => '1',\n")
  fp.write("    13 => to_std_logic(CFG_SVGA_ENABLE),\n")
  fp.write("    14 => to_std_logic(CFG_GRETH),\n")
  if esp_config.has_sgmii:
    fp.write("    15 => to_std_logic(CFG_GRETH),\n")
  for j in range(0, esp_config.ndvfs):
    dvfs = esp_config.dvfs_ctrls[j]
    if dvfs.id != -1:
      fp.write("    " + str(dvfs.idx) + " => '1',\n")
  for j in range(0, esp_config.nl2):
    l2 = esp_config.l2s[j]
    if l2.idx != -1:
      fp.write("    " + str(l2.idx) + " => '1',\n")
  for j in range(0, esp_config.nllc):
    llc = esp_config.llcs[j]
    if llc.idx != -1:
      fp.write("    " + str(llc.idx) + " => '1',\n")
  for j in range(0, esp_config.ntiles):
    fp.write("    " + str(CSR_PINDEX[j]) + " => '1',\n")
  for j in range(0, esp_config.nacc):
    acc = esp_config.accelerators[j]
    fp.write("    " + str(acc.idx) + " => '1',\n")
  #PRC apb_mask
  fp.write("    127 => to_std_logic(CFG_PRC),\n")
  fp.write("    others => '0');\n\n")


  fp.write("  constant remote_apb_slv_mask_misc : std_logic_vector(0 to NAPBSLV - 1) := (\n")
  for j in range(0, esp_config.ndvfs):
    dvfs = esp_config.dvfs_ctrls[j]
    if dvfs.id != -1:
      fp.write("    " + str(dvfs.idx) + " => '1',\n")
  for j in range(0, esp_config.nl2):
    l2 = esp_config.l2s[j]
    if l2.idx != -1:
      fp.write("    " + str(l2.idx) + " => '1',\n")
  for j in range(0, esp_config.nllc):
    llc = esp_config.llcs[j]
    if llc.idx != -1:
      fp.write("    " + str(llc.idx) + " => '1',\n")
  for j in range(0, esp_config.ntiles):
    if esp_config.tiles[j].type != "misc":
      fp.write("    " + str(CSR_PINDEX[j]) + " => '1',\n")
  for j in range(0, esp_config.nacc):
    acc = esp_config.accelerators[j]
    fp.write("    " + str(acc.idx) + " => '1',\n")
  fp.write("    others => '0');\n")

  #
  fp.write("  -- Flag bus slaves that are remote to each tile (request selects slv proxy)\n")
  fp.write("  constant remote_ahb_mask_misc : std_logic_vector(0 to NAHBSLV - 1) := (\n")
  for j in range(0, esp_config.nmem):
    fp.write("    " + str(DDR_HINDEX[j]) + " => '1',\n")
  for j in range(0, esp_config.nslm + esp_config.nslmddr):
    index = SLM_HINDEX + j
    if index >= 12:
      index = index + 1
    fp.write("    " + str(index) + " => '1',\n")
  fp.write("    others => '0');\n\n")

  fp.write("  constant remote_ahb_mask_cpu : std_logic_vector(0 to NAHBSLV - 1) := (\n")
  fp.write("    " + str(AHBROM_HINDEX) + "  => '1',\n")
  fp.write("    " + str(DDR_HINDEX[0]) + " => to_std_logic(CFG_L2_DISABLE),\n")
  fp.write("    " + str(FB_HINDEX) + "  => to_std_logic(CFG_SVGA_ENABLE),\n")
  fp.write("    others => '0');\n\n")

  fp.write("  constant slm_ahb_mask : std_logic_vector(0 to NAHBSLV - 1) := (\n")
  for j in range(0, esp_config.nslm + esp_config.nslmddr):
    index = SLM_HINDEX + j
    if index >= 12:
      index = index + 1
    fp.write("    " + str(index) + " => '1',\n")
  fp.write("    others => '0');\n\n")


def print_esplink_header(fp, esp_config, soc):

  # Get CPU base frequency
  with open("../../top.vhd") as top_fp:
    for line in top_fp:
      if line.find("constant CPU_FREQ : integer") != -1:
        line.strip();
        items = line.split()
        CPU_FREQ = 1000 * int(items[5].replace(";",""))
        top_fp.close()
        break

  fp.write("#ifndef __SOCMAP_H__\n")
  fp.write("#define __SOCMAP_H__\n")
  fp.write("\n")
  fp.write("#define EDCL_IP \"" + soc.IP_ADDR + "\"\n")
  fp.write("#define BASE_FREQ " + str(CPU_FREQ) + "\n")
  if soc.cache_spandex.get() == 1:
    fp.write("#define USE_SPANDEX\n")
  fp.write("#define BOOTROM_BASE_ADDR " + hex(RST_ADDR[esp_config.cpu_arch]) + "\n")
  fp.write("#define RODATA_START_ADDR " + hex(RODATA_ADDR[esp_config.cpu_arch]) + "\n")
  fp.write("#define DRAM_BASE_ADDR 0x" + format(DDR_HADDR[esp_config.cpu_arch], '03X') + "00000\n")
  fp.write("#define PBS_BASE_ADDR 0x" + format(PBS_HADDR[esp_config.cpu_arch], '03X') + "00000\n")
  if esp_config.nmem == 0:
    fp.write("#define OVERRIDE_DRAM_SIZE 0x" + format(esp_config.slm_tot_kbytes * 1024, '08X') + "\n")
  fp.write("#define ESPLINK_BASE_ADDR 0x" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "00400\n")
  fp.write("#define TARGET_BYTE_ORDER __ORDER_BIG_ENDIAN__\n")
  fp.write("\n")
  fp.write("#endif /* __SOCMAP_H__ */\n")

def print_soc_defines(fp, esp_config, soc):
  fp.write("#ifndef __SOC_DEFS_H__\n")
  fp.write("#define __SOC_DEFS_H__\n")
  fp.write("\n")
  fp.write("#define SOC_ROWS " + str(soc.noc.rows) + "\n");
  fp.write("#define SOC_COLS " + str(soc.noc.cols) + "\n");
  fp.write("#define SOC_NCPU " + str(esp_config.ncpu) + "\n");
  fp.write("#define SOC_NMEM " + str(esp_config.nmem) + "\n");
  fp.write("#define SOC_NDDR_CONTIG " + str(len(esp_config.contig_alloc_ddr)) +"\n")
  if esp_config.nacc > 0:
      fp.write("#define ACCS_PRESENT 1\n")
  fp.write("#define SOC_NACC " + str(esp_config.nacc) + "\n");

  if esp_config.cpu_arch == "leon3":
      fp.write("#define MONITOR_BASE_ADDR 0x80090000\n")
  else:
      fp.write("#define MONITOR_BASE_ADDR 0x60090000\n")
  fp.write("#define MONITOR_TILE_SIZE 0x200\n\n")

  fp.write("#endif /* __SOC_DEFS_H__ */\n")

def print_soc_locations(fp, esp_config, soc):
  fp.write("soc_loc_t cpu_locs[" + str(esp_config.ncpu) + "] = {")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "cpu":
        fp.write("{" + str(t.row) + "," + str(t.col) + "}")
        if not t.cpu_id == esp_config.ncpu - 1:
            fp.write(", ")
  fp.write("};\n\n")

  fp.write("soc_loc_t mem_locs[" + str(esp_config.nmem) + "] = {")
  for i in range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.type == "mem":
        fp.write("{" + str(t.row) + "," + str(t.col) + "}")
        if not t.mem_id == esp_config.nmem - 1:
            fp.write(", ")
  fp.write("};\n\n")

  #fp.write("soc_loc_t contig_alloc_locs[" + str(len(esp_config.contig_alloc_ddr)) + "] = {")
  #for i in range(0, esp_config.ntiles):
  #  t = esp_config.tiles[i]
  #  if t.type == "mem" and t.mem_id in esp_config.contig_alloc_ddr:
  #      fp.write("{" + str(t.row) + "," + str(t.col) + "}")
  #      if not t.mem_id == esp_config.nmem - 1:
  #          fp.write(", ")
  #fp.write("};\n\n")

  #fp.write("soc_loc_t io_loc = ")
  #for i in range(0, esp_config.ntiles):
  #  t = esp_config.tiles[i]
  #  if t.type == "misc":
  #      fp.write("{" + str(t.row) + "," + str(t.col) + "};")
  #      break
  #fp.write("\n\n")

  if esp_config.nacc > 0:
      acc_counts = {}
      fp.write("soc_loc_t acc_locs[" + str(esp_config.nacc) + "] = {")
      for i in range(0, esp_config.ntiles):
        t = esp_config.tiles[i]
        if t.type == "acc":
            if not t.acc.lowercase_name in acc_counts:
                acc_counts[t.acc.lowercase_name] = 0
            else:
                acc_counts[t.acc.lowercase_name] += 1

            fp.write("{" + str(t.row) + "," + str(t.col) + "}")
            if not t.acc.id == esp_config.nacc - 1:
                fp.write(", ")
      fp.write("};\n\n")
      fp.write("unsigned int acc_has_l2[" + str(esp_config.nacc) + "] = {")
      for i in range(0, esp_config.ntiles):
        t = esp_config.tiles[i]
        if t.type == "acc":
            if t.has_l2:
                fp.write("1")
            else:
                fp.write("0")
            if not t.acc.id == esp_config.nacc - 1:
                fp.write(", ")
      fp.write("};\n")

def print_devtree(fp, soc, esp_config):

  # Get CPU base frequency
  with open("../../top.vhd") as top_fp:
    for line in top_fp:
      if line.find("constant CPU_FREQ : integer") != -1:
        line.strip();
        items = line.split()
        CPU_FREQ = int(items[5].replace(";",""))
        top_fp.close()
        break


  fp.write("/dts-v1/;\n")
  fp.write("\n")
  fp.write("/ {\n")
  fp.write("  #address-cells = <2>;\n")
  fp.write("  #size-cells = <2>;\n")
  if esp_config.cpu_arch == "ariane":
    fp.write("  compatible = \"eth,ariane-bare-dev\";\n")
    fp.write("  model = \"eth,ariane-bare\";\n")
  elif esp_config.cpu_arch == "ibex":
    fp.write("  compatible = \"lowrisc,ibex\";\n")
    fp.write("  model = \"lowrisc,ibex-small\";\n")
  fp.write("  chosen {\n")
  fp.write("    stdout-path = \"/soc/uart@" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "00100:38400\";\n")
  fp.write("  };\n")
  fp.write("  cpus {\n")
  fp.write("    #address-cells = <1>;\n")
  fp.write("    #size-cells = <0>;\n")
  fp.write("    timebase-frequency = <" + str(int((CPU_FREQ * 1000) / 2)) + ">; // CPU_FREQ / 2\n")
  for i in range(esp_config.ncpu):
    fp.write("    CPU" + str(i) + ": cpu@" + str(i) + " {\n")
    fp.write("      clock-frequency = <" + str(CPU_FREQ) + "000>;\n")
    fp.write("      device_type = \"cpu\";\n")
    fp.write("      reg = <" + str(i) + ">;\n")
    fp.write("      status = \"okay\";\n")
    if esp_config.cpu_arch == "ariane":
      fp.write("      compatible = \"eth, ariane\", \"riscv\";\n")
      fp.write("      riscv,isa = \"rv64imafdc\";\n")
      fp.write("      mmu-type = \"riscv,sv39\";\n")
      fp.write("      tlb-split;\n")
    elif esp_config.cpu_arch == "ibex":
      fp.write("      compatible = \"lowrisc, ibex\", \"riscv\";\n")
      fp.write("      riscv,isa = \"rv32imc\";\n")
    fp.write("      // HLIC - hart local interrupt controller\n")
    fp.write("      CPU" + str(i) + "_intc: interrupt-controller {\n")
    fp.write("        #interrupt-cells = <1>;\n")
    fp.write("        interrupt-controller;\n")
    fp.write("        compatible = \"riscv,cpu-intc\";\n")
    fp.write("      };\n")
    fp.write("    };\n")
  fp.write("  };\n")
  fp.write("  memory@" + format(DDR_HADDR[esp_config.cpu_arch], '03x') + "00000 {\n")
  fp.write("    device_type = \"memory\";\n")
  # TODO: increase memory address space.
  if esp_config.nmem != 0:
    fp.write("    reg = <0x0 0x" + format(DDR_HADDR[esp_config.cpu_arch], '03x') + "00000 0x0 0x20000000>;\n")
  else:
    # Use SLM as main memory
    fp.write("    reg = <0x0 0x" + format(DDR_HADDR[esp_config.cpu_arch], '03x') + "00000 0x0 0x" + format(esp_config.slm_tot_kbytes * 1024, '08x') + ">;\n")
  fp.write("  };\n")

  # OS reserved memory regions
  if esp_config.nmem != 0:
    fp.write("  reserved-memory {\n")
    fp.write("    #address-cells = <2>;\n")
    fp.write("    #size-cells = <2>;\n")
    fp.write("    ranges;\n")
    fp.write("\n")
    fp.write("    greth_reserved: buffer@a0000000 {\n")
    fp.write("      compatible = \"shared-dma-pool\";\n")
    fp.write("      no-map;\n")
    fp.write("      reg = <0x0 0xa0000000 0x0 0x200000>;\n")
    fp.write("    };\n")

    # Add only one memory region for all third-party accelerator instances
    acc_mem_address = format(ACC_MEM_RESERVED_START_ADDR, "08x")
    acc_mem_size = format(ACC_MEM_RESERVED_TOTAL_SIZE, "08x")
    if esp_config.nacc > esp_config.nthirdparty:
      tp_mem_address = format(THIRDPARTY_MEM_RESERVED_ADDR, "08x")
      tp_mem_size = format(THIRDPARTY_MEM_RESERVED_SIZE, "08x")
    else:
      tp_mem_address = format(ACC_MEM_RESERVED_START_ADDR, "08x")
      tp_mem_size = format(ACC_MEM_RESERVED_TOTAL_SIZE, "08x")

    if esp_config.nthirdparty > 0:
      acc_mem_size = format(ACC_MEM_RESERVED_TOTAL_SIZE - THIRDPARTY_MEM_RESERVED_SIZE, "08x")

    if esp_config.nacc > esp_config.nthirdparty:
      fp.write("\n")
      fp.write("    accelerator_reserved: buffer@" + acc_mem_address + " {\n")
      fp.write("      compatible = \"shared-dma-pool\";\n")
      fp.write("      no-map;\n")
      fp.write("      reg = <0x0 0x" + acc_mem_address + " 0x0 0x" + acc_mem_size + ">;\n")
      fp.write("    };\n")
    if esp_config.nthirdparty > 0:
      fp.write("\n")
      fp.write("    thirdparty_reserved: buffer@" + tp_mem_address + " {\n")
      fp.write("      compatible = \"shared-dma-pool\";\n")
      fp.write("      no-map;\n")
      fp.write("      reg = <0x0 0x" + tp_mem_address + " 0x0 0x" + tp_mem_size + ">;\n")
      fp.write("    };\n")
    fp.write("  };\n")

  fp.write("  L26: soc {\n")
  fp.write("    #address-cells = <2>;\n")
  fp.write("    #size-cells = <2>;\n")
  if esp_config.cpu_arch == "ariane":
    fp.write("    compatible = \"eth,ariane-bare-soc\", \"simple-bus\";\n")
  elif esp_config.cpu_arch == "ibex":
    fp.write("    compatible = \"lowrisc,lowrisc-soc\", \"simple-bus\";\n")
  fp.write("    ranges;\n")
  # TODO: make clint/plic remote devices w/ remote AXI proxy and variable address to be passed over
  fp.write("    clint@2000000 {\n")
  fp.write("      compatible = \"riscv,clint0\";\n")
  fp.write("      interrupts-extended = <\n")
  for i in range(esp_config.ncpu):
    fp.write("                             &CPU" + str(i) + "_intc 3 &CPU" + str(i) + "_intc 7\n")
  fp.write("                            >;\n")
  fp.write("      reg = <0x0 0x2000000 0x0 0xc0000>;\n")
  fp.write("      reg-names = \"control\";\n")
  fp.write("    };\n")
  fp.write("    PLIC0: interrupt-controller@6c000000 {\n")
  fp.write("      #address-cells = <0>;\n")
  fp.write("      #interrupt-cells = <1>;\n")
  fp.write("      compatible = \"riscv,plic0\";\n")
  fp.write("      interrupt-controller;\n")
  fp.write("      interrupts-extended = <\n")
  for i in range(esp_config.ncpu):
    fp.write("                             &CPU" + str(i) + "_intc 11 &CPU" + str(i) + "_intc 9\n")
  fp.write("                            >;\n")
  fp.write("      reg = <0x0 0x6c000000 0x0 0x4000000>;\n")
  fp.write("      riscv,max-priority = <7>;\n")
  fp.write("      riscv,ndev = <16>;\n")
  fp.write("    };\n")
  # TODO add GPTIMER/Accelerators/Caches/SVGA/DVFS to devtree (and remove leon3 IRQ from socmap
  fp.write("    uart@" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "00100 {\n")
  fp.write("      compatible = \"gaisler,apbuart\";\n")
  fp.write("      reg = <0x0 0x" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "00100 0x0 0x100>;\n")
  fp.write("      freq = <" + str(CPU_FREQ) + "000>;\n")
  fp.write("      interrupt-parent = <&PLIC0>;\n")
  fp.write("      interrupts = <3>;\n")
  fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
  fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
  fp.write("    };\n")
  #PRC dts
  fp.write("    prc@" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "0E400 {\n")
  fp.write("      compatible = \"vendor_xilinx,xilinx_prc\";\n")                
  fp.write("      reg = <0x0 0x" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "0E400 0x0 0x100>;\n")                        
  fp.write("      interrupt-parent = <&PLIC0>;\n")                                                                                   
  fp.write("      interrupts = <5>;\n")
  fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")                                                         
  fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")                                                        
  fp.write("    };\n") 
  fp.write("    eth: greth@" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "80000 {\n")
  fp.write("      #address-cells = <1>;\n")
  fp.write("      #size-cells = <1>;\n")
  fp.write("      compatible = \"gaisler,ethmac\";\n")
  fp.write("      device_type = \"network\";\n")
  fp.write("      interrupt-parent = <&PLIC0>;\n")
  fp.write("      interrupts = <13 0>;\n")
  # Use randomly generated MAC address
  mac = " ".join(esp_config.linux_mac[i:i+2] for i in range(0, len(esp_config.linux_mac), 2))
  fp.write("      local-mac-address = [" + mac + "];\n")
  fp.write("      reg = <0x0 0x" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "80000 0x0 0x10000>;\n")
  fp.write("      phy-handle = <&phy0>;\n")
  fp.write("      phy-connection-type = \"sgmii\";\n")
  if esp_config.nmem != 0:
    fp.write("      memory-region = <&greth_reserved>;\n")
  fp.write("\n")
  fp.write("      phy0: mdio@60001000 {\n")
  fp.write("            #address-cells = <1>;\n")
  fp.write("            #size-cells = <0>;\n")
  fp.write("            compatible = \"gaisler,sgmii\";\n")
  fp.write("            reg = <0x0 0x" + format(AHB2APB_HADDR[esp_config.cpu_arch], '03x') + "01000 0x0 0x1000>;\n")
  fp.write("            interrupt-parent = <&PLIC0>;\n")
  fp.write("            interrupts = <12 0>;\n")
  fp.write("      };\n")
  fp.write("    };\n")

  # ESP L2 caches
  base = AHB2APB_HADDR[esp_config.cpu_arch] << 20
  for i in range(esp_config.nl2):
    l2 = esp_config.l2s[i]
    if l2.idx != -1:
      address = base + 0xD000 + (l2.idx << 8)
      address_str = format(address, "x")
      size_str = "100"
      fp.write("    l2cache" + str(l2.id) + "@" + address_str + " {\n")
      if soc.cache_spandex.get() == 1:
        fp.write("      compatible = \"uiuc,spandex_l2\";\n")
      else:
        fp.write("      compatible = \"sld,l2_cache\";\n")
      fp.write("      reg = <0x0 0x" + address_str + " 0x0 0x" + size_str + ">;\n")
      fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
      fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
      fp.write("    };\n")

  # ESP LLC caches
  base = AHB2APB_HADDR[esp_config.cpu_arch] << 20
  for i in range(esp_config.nllc):
    llc = esp_config.llcs[i]
    if llc.idx != -1:
      address = base + 0xD000 + (llc.idx << 8)
      address_str = format(address, "x")
      size_str = "100"
      fp.write("    llccache" + str(llc.id) + "@" + address_str + " {\n")
      if soc.cache_spandex.get() == 1:
        fp.write("      compatible = \"uiuc,spandex_llc\";\n")
      else:
        fp.write("      compatible = \"sld,llc_cache\";\n")
      fp.write("      reg = <0x0 0x" + address_str + " 0x0 0x" + size_str + ">;\n")
      fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
      fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
      fp.write("    };\n")

  # Reset all THIRDPARTY accelerators counters
  THIRDPARTY_N = 0
  
  for i in range(esp_config.nacc):
    acc = esp_config.accelerators[i]
    base = AHB2APB_HADDR[esp_config.cpu_arch] << 20
    if acc.vendor == "sld":
      address = base + ((SLD_APB_ADDR + acc.id) << 8)
      size = 0x100
    else:
      n = THIRDPARTY_N
      # Compute base address
      if THIRDPARTY_APB_EXT_ADDRESS == 0:
        # Use part of standard APB address space
        address = base + THIRDPARTY_APB_ADDRESS + n * THIRDPARTY_APB_ADDRESS_SIZE
        size = THIRDPARTY_APB_ADDRESS_SIZE
      else:
        # Use extended APB address space (large number of registers)
        address = base + THIRDPARTY_APB_EXT_ADDRESS + n * THIRDPARTY_APB_EXT_ADDRESS_SIZE
        size = THIRDPARTY_APB_EXT_ADDRESS_SIZE

      # Increment count
      THIRDPARTY_N = n + 1;

    address_str = format(address, "x")
    size_str = format(size, "x")

    fp.write("    " + acc.lowercase_name + "@" + address_str + " {\n")
    if acc.vendor == "sld":
      fp.write("      compatible = \"" + acc.vendor + "," + acc.lowercase_name + "\";\n")
    else:
      fp.write("      compatible = \"" + acc.vendor + "," + THIRDPARTY_COMPATIBLE[acc.lowercase_name] + "\";\n")
    fp.write("      reg = <0x0 0x" + address_str + " 0x0 0x" + size_str + ">;\n")
    fp.write("      interrupt-parent = <&PLIC0>;\n")
    fp.write("      interrupts = <" + str(acc.irq + 1) + ">;\n")
    fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
    fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
    if acc.vendor != "sld" and esp_config.nmem != 0:
      fp.write("      memory-region = <&thirdparty_reserved>;\n")
    fp.write("    };\n")
  fp.write("  };\n")
  fp.write("};\n")


def print_cache_config(fp, soc, esp_config):
  fp.write("`ifndef __CACHES_CFG_SVH__\n")
  fp.write("`define __CACHES_CFG_SVH__\n")
  fp.write("\n")
  addr_bits = 32
  byte_bits = 2
  word_bits = 2
  if soc.CPU_ARCH.get() == "ariane":
    addr_bits = 32
    byte_bits = 3
    word_bits = 1
    fp.write("`define LLSC\n")
  if soc.CPU_ARCH.get() == "leon3":
    fp.write("`define BIG_ENDIAN\n")
  else:
    fp.write("`define LITTLE_ENDIAN\n")

  fp.write("`define ADDR_BITS    " + str(addr_bits) + "\n")
  fp.write("`define BYTE_BITS    " + str(byte_bits) + "\n")
  fp.write("`define WORD_BITS    " + str(word_bits) + "\n")
  fp.write("`define L2_WAYS      " + str(soc.l2_ways.get()) + "\n")
  fp.write("`define L2_SETS      " + str(soc.l2_sets.get()) + "\n")
  fp.write("`define LLC_WAYS     " + str(soc.llc_ways.get()) + "\n")
  fp.write("`define LLC_SETS     " + str(int(soc.llc_sets.get())) + "\n")
  fp.write("\n")
  fp.write("`endif // __CACHES_CFG_SVH__\n")

def print_floorplan_constraints(fp, soc, esp_config):
  mem_num = 0
  mem_tiles = {}
  for i in  range(0, esp_config.ntiles):
    t = esp_config.tiles[i]
    if t.mem_id != -1:
      mem_tiles[mem_num] = i
      mem_num += 1

  #4096 sets + 2 tiles or 8192 sets + 4 tiles
  if int((soc.llc_sets.get() * soc.llc_ways.get()) / (esp_config.nmem * 16)) == 2048:
    fp.write("create_pblock {pblock_mem_tile_0}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_0}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[0]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {SLICE_X24Y91:SLICE_X152Y338}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {DSP48E2_X0Y38:DSP48E2_X2Y133}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB18_X1Y38:RAMB18_X4Y133}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_0}] -add {RAMB36_X1Y19:RAMB36_X4Y66}\n")
    fp.write("create_pblock {pblock_mem_tile_1}\n")
    fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_1}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[1]) + "].mem_tile.tile_mem_i}]]\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {SLICE_X168Y96:SLICE_X295Y339}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {DSP48E2_X3Y40:DSP48E2_X5Y135}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB18_X5Y40:RAMB18_X8Y135}\n")
    fp.write("resize_pblock [get_pblocks {pblock_mem_tile_1}] -add {RAMB36_X5Y20:RAMB36_X8Y67}\n")
  if (esp_config.nmem == 4): 
      fp.write("create_pblock {pblock_mem_tile_2}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_2}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[2]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {SLICE_X25Y350:SLICE_X153Y598}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {DSP48E2_X0Y140:DSP48E2_X2Y237}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB18_X1Y140:RAMB18_X4Y237}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_2}] -add {RAMB36_X1Y70:RAMB36_X4Y118}\n")
      fp.write("create_pblock {pblock_mem_tile_3}\n")
      fp.write("add_cells_to_pblock [get_pblocks {pblock_mem_tile_3}] [get_cells -quiet [list {esp_1/tiles_gen[" + str(mem_tiles[3]) + "].mem_tile.tile_mem_i}]]\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {SLICE_X169Y594:SLICE_X293Y836}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {DSP48E2_X3Y238:DSP48E2_X5Y333}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB18_X5Y238:RAMB18_X8Y333}\n")
      fp.write("resize_pblock [get_pblocks {pblock_mem_tile_3}] -add {RAMB36_X5Y119:RAMB36_X8Y166}\n")
      fp.write("create_pblock pblock_gen_mig.ddrc3\n")
      fp.write("add_cells_to_pblock [get_pblocks pblock_gen_mig.ddrc3] [get_cells -quiet [list gen_mig.ddrc3]]\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {SLICE_X263Y660:SLICE_X336Y839}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {DSP48E2_X6Y264:DSP48E2_X7Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB18_X9Y264:RAMB18_X10Y335}\n")
      fp.write("resize_pblock [get_pblocks pblock_gen_mig.ddrc3] -add {RAMB36_X9Y132:RAMB36_X10Y167}\n")
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
  elif int((soc.llc_sets.get() * soc.llc_ways.get()) / (esp_config.nmem * 16)) == 512:
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
  elif int((soc.llc_sets.get() * soc.llc_ways.get()) / (esp_config.nmem * 16)) == 256:
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

def print_load_script(fp, soc, esp_config):
  fp.write("cd /opt/drivers-esp\n")
  fp.write("insmod contig_alloc.ko ")
  nmem = esp_config.nmem
  ddr_size = int(str(DDR_SIZE)) * int(0x100000)
  if nmem > 0:
    size = int(ddr_size / nmem)
  sizes = []
  starts = []
  start = int(str(DDR_HADDR[soc.CPU_ARCH.get()])) * int(0x100000)
  nddr = 0
  line_size = int(0x10)

  end = start + ddr_size
  if soc.CPU_ARCH.get() == "ariane" or soc.CPU_ARCH.get() == "ibex":
    sp = int(0xa0200000) - line_size
    if esp_config.nthirdparty > 0:
        end = int(0xb0000000)
  else:
    sp = int(str(soc.LEON3_STACK), 16)

  addr = start
  for m in range(nmem):
    if addr >= (sp + line_size) and addr < end:
        starts.append(hex(addr))
        if addr + size <= end:
            sizes.append(hex(size))
        else:
            size.append(hex(end - addr))
        esp_config.contig_alloc_ddr.append(m)
        nddr += 1
    elif (addr + size) > (sp + line_size) and addr < end:
        starts.append(hex(sp + line_size))
        if addr + size <= end:
            sizes.append(hex((addr + size) - (sp + line_size)))
        else:
            sizes.append(hex(end - (sp + line_size)))
        esp_config.contig_alloc_ddr.append(m)
        nddr += 1
    addr += size

  fp.write("nddr=" + str(nddr) + " ")
  fp.write("start=")
  for i in range(nddr):
    fp.write(starts[i])
    if i != nddr - 1:
        fp.write(",")
            
  fp.write(" size=")
  for i in range(nddr):
    fp.write(sizes[i])
    if i != nddr - 1:
        fp.write(",")
    
  fp.write(" chunk_log=20\n")
  fp.write("insmod esp_cache.ko\n")
  fp.write("insmod esp_private_cache.ko\n")
  fp.write("insmod esp.ko")
  fp.write(" line_bytes=16")
  fp.write(" l2_sets=" + str(soc.l2_sets.get()))
  fp.write(" l2_ways=" + str(soc.l2_ways.get()))
  fp.write(" llc_sets=" + str(soc.llc_sets.get()))
  fp.write(" llc_ways=" + str(soc.llc_ways.get()))
  fp.write(" llc_banks=" + str(nmem))
  fp.write(" rtl_cache=" + str(soc.cache_rtl.get()))

def create_socmap(esp_config, soc):

  # Globals
  fp = open('esp_global.vhd', 'w')

  print_header(fp, "esp_global")
  print_libs(fp, True)

  fp.write("package esp_global is\n\n")
  print_global_constants(fp, soc)
  print_constants(fp, soc, esp_config)

  fp.write("end esp_global;\n")
  fp.close()

  print("Created global constants definition into 'esp_global.vhd'")

  # SoC map
  fp = open('socmap.vhd', 'w')

  print_header(fp, "socmap")
  print_libs(fp, False)

  fp.write("package socmap is\n\n")
  print_mapping(fp, soc, esp_config)
  print_tiles(fp, esp_config)

  fp.write("end socmap;\n")
  fp.close()

  print("Created configuration into 'socmap.vhd'")

  # ESPLink header
  fp = open('esplink.h', 'w')

  print_esplink_header(fp, esp_config, soc)

  fp.close()

  print("Created ESPLink header into 'esplink.h'")

  if esp_config.nmem != 0:
    fp = open('S64esp', 'w')

    print_load_script(fp, soc, esp_config)

    fp.close()

    print("Created kernel module load script into 'S64esp'")

  # socmap defines
  fp = open('soc_defs.h', 'w')

  print_soc_defines(fp, esp_config, soc)

  fp.close()

  print("Created soc defines into 'soc_defs.h'")

  # soc tile locations
  fp = open('soc_locs.h', 'w')

  print_soc_locations(fp, esp_config, soc)

  fp.close()

  print("Created soc locations into 'soc_locs.h'")


  # Device tree
  if esp_config.cpu_arch == "ariane" or esp_config.cpu_arch == "ibex":

    fp = open('riscv.dts', 'w')

    print_devtree(fp, soc, esp_config)

    fp.close()

    print("Created device-tree into 'riscv.dts'")

  # RTL Caches configuration
  fp = open('cache_cfg.svh', 'w')

  print_cache_config(fp, soc, esp_config)

  fp.close()

  print("Created RTL caches configuration into 'cache_cfg.svh'")

  #memory floorplanning for profpga-xcvu440
  if (soc.TECH == "virtexu") and esp_config.nmem > 1:
    fp = open('mem_tile_floorplanning.xdc', 'w')

    print_floorplan_constraints(fp, soc, esp_config)

    fp.close()

    print("Created floorplanning constraints for profgpa-xcvu440 into 'mem_tile_floorplanning.xdc'")
