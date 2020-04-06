#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from collections import defaultdict
import math


# Maximum number of AHB and APB slaves can also be increased, but Leon3 utility
# mklinuximg, GRLIB AMBA package and bare-metal probe constants must be updated.
# The related constants are defined in
# <mklinuximg>/include/ambapp.h
# <esp>/rtl/include/grlib/amba/amba.vhd
# <esp>/soft/leon3/include/esp_probe.h
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
# 20-(NAPBS-1) - Accelerators
NACC_MAX = NAPBS - 2 * NCPU_MAX - NMEM_MAX - 8


# Default device mapping
RST_ADDR = dict()
RST_ADDR["leon3"] = 0x0
RST_ADDR["ariane"] = 0x10000

# Boot ROM slave index (With Leon3 this exists in simulation only for now)
AHBROM_HINDEX = 0

# Memory-mapped registers slave index
AHB2APB_HINDEX = 1

# Memory-mapped registers base address (includes peripherals and accelerators)
AHB2APB_HADDR = dict()
AHB2APB_HADDR["leon3"] = 0x800
AHB2APB_HADDR["ariane"] = 0x600

# RISC-V CPU Local Interruptor index
RISCV_CLINT_HINDEX = 2

# Memory controller slave index
DDR_HINDEX = [4, 5, 6, 7]

# Main memory area (12 MSBs)
DDR_HADDR = dict()
DDR_HADDR["leon3"] = 0x400
DDR_HADDR["ariane"] = 0x800

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

# First I/O-bus index for accelerators
SLD_APB_PINDEX = 20

# I/O memory area offset for accelerators (address bits 19-8)
SLD_APB_ADDR = 0x100

# default mask for accelerators' registers base address (256 Bytes regions per accelerator)
SLD_APB_ADDR_MSK = 0xfff

# third-party APB address and mask
# Hard-coded to ensure reserved addresses cover all configuration registers
THIRDPARTY_APB_ADDR = dict()
THIRDPARTY_APB_ADDR_MSK = dict()
THIRDPARTY_APB_ADDR_SIZE = dict()
THIRDPARTY_MEM_RESERVED_ADDR = dict()
THIRDPARTY_MEM_RESERVED_SIZE = dict()

THIRDPARTY_APB_ADDR["nv_nvdla"] = 0x400
THIRDPARTY_APB_ADDR_MSK["nv_nvdla"] = 0xC00
THIRDPARTY_APB_ADDR_SIZE["nv_nvdla"] = 0x40000
THIRDPARTY_MEM_RESERVED_ADDR["nv_nvdla"] = 0xB0000000
THIRDPARTY_MEM_RESERVED_SIZE["nv_nvdla"] = 0x10000000


class acc_info:
  uppercase_name = ""
  lowercase_name = ""
  vendor = ""
  id = -1
  idx = -1
  irq = 5

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
  tech = "virtex7"
  cpu_arch = "leon3"
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
    self.tech = soc.TECH
    self.linux_mac = soc.LINUX_MAC
    self.cpu_arch = soc.CPU_ARCH.get()
    self.ncpu = soc.noc.get_cpu_num(soc)
    self.nmem = soc.noc.get_mem_num(soc)
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
    # Accelerator/DMA ID assigned dynamically to each accelerator tile
    acc_id = 0
    # Accelerator interrupt dynamically to each accelerator tile because RISC-V PLIC does not work properly with shared lines
    acc_irq = 3
    if self.cpu_arch == "ariane":
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
          acc.irq = acc_irq
          acc.idx = SLD_APB_PINDEX + acc_id
          acc.vendor = soc.noc.topology[x][y].vendor
          self.tiles[t].acc = acc
          self.accelerators.append(acc)
          acc_id = acc_id + 1
          if self.cpu_arch == "ariane":
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



