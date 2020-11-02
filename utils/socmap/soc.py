#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from tkinter import *
from tkinter import messagebox
import os.path
import glob
import sys

from NoCConfiguration import *

def get_immediate_subdirectories(a_dir):
  return [name for name in os.listdir(a_dir)
        if os.path.isdir(os.path.join(a_dir, name))]

class Components():

  def __init__(self, TECH, DMA_WIDTH):
    self.EMPTY = [
      "empty",
    ]
    self.PROCESSORS = [
      "cpu",
    ]
    self.MISC = [
      "IO",
    ]
    self.MEM = [
      "mem",
    ]
    self.SLM = [
      "slm",
    ]
    self.ACCELERATORS = [
    ]

    self.POINTS = {}
    self.VENDOR = {}

    tech_dir = TECH
    ESP_ROOT = os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + "/../../")
    acc_dir = ESP_ROOT + "/tech/" + tech_dir + "/acc"
    dirs = get_immediate_subdirectories(acc_dir)
    dirs = sorted(dirs, key=str.upper)
    for acc in dirs:
      self.POINTS[acc.upper()] = []
      self.VENDOR[acc.upper()] = "sld"
      acc_dp = get_immediate_subdirectories(acc_dir + '/' + acc)
      for dp_str in acc_dp:
        dp = dp_str.replace(acc + "_", "")
        dp_info = dp.split("_")
        skip = False
        for item in dp_info:
          if re.match(r'dma[1-9]+', item, re.M|re.I):
            dp_dma_width = int(item.replace("dma", ""))
            if dp_dma_width != DMA_WIDTH:
              skip = True
              break;
        if skip:
          continue
        self.POINTS[acc.upper()].append(dp)
      if len(self.POINTS[acc.upper()]) != 0:
        self.ACCELERATORS.append(acc.upper())

    acc_dir = ESP_ROOT + "/third-party/accelerators/dma" + str(DMA_WIDTH)
    dirs = get_immediate_subdirectories(acc_dir)
    dirs = sorted(dirs, key=str.upper)
    for acc in dirs:
      self.POINTS[acc.upper()] = []
      with open(acc_dir + "/" + acc + "/vendor") as f:
        vendor = f.readline().strip()
      self.VENDOR[acc.upper()] = vendor
      dp = ""
      self.POINTS[acc.upper()].append(dp)
      self.ACCELERATORS.append(acc.upper())

#board configuration
class SoC_Config():
  HAS_FPU = "0"
  HAS_JTAG = False
  HAS_ETH = False
  HAS_SG = False
  HAS_SGMII = True
  HAS_SVGA = False
  IP_ADDR = ""
  TECH = "virtex7"
  DMA_WIDTH = 32

  def changed(self, *args): 
    if self.cache_impl.get() == "SystemVerilog":
      self.acc_l2_ways.set(self.l2_ways.get())
      self.acc_l2_sets.set(self.l2_sets.get())
      self.cache_rtl.set(1)
    else:
      self.cache_rtl.set(0)
  
  def update_list_of_ips(self):
    self.list_of_ips = tuple(self.IPs.EMPTY) + tuple(self.IPs.PROCESSORS) + tuple(self.IPs.MISC) + tuple(self.IPs.MEM) + tuple(self.IPs.SLM) + tuple(self.IPs.ACCELERATORS)

  def read_config(self, temporary):
    filename = ".esp_config"
    warning = False
    if temporary == True:
      filename = ".esp_config.bak"
      warning = True
      if os.path.isfile(filename) == False:
        filename = ".esp_config"
        warning = False
        if os.path.isfile(filename) == False:
          return -1
    if os.path.isfile(filename) == False:
      print("Configuration file is not available")
      return -1
    if warning:
      first = True
      if os.path.isfile(".esp_config") == True:
        orig = open(".esp_config", 'r')
        with open(".esp_config.bak") as bak:
          for line_bak in bak:
            line_orig = orig.readline()
            if line_bak != line_orig:
              if first:
                print("WARNING: temporary configuration. Modifications are not reported into 'socmap.vhd' yet")
                first = False
              print("SAVED: " + line_orig.replace("\n","") + " -- TEMP: " + line_bak.replace("\n",""))
    fp = open(filename, 'r')
    # CPU architecture
    line = fp.readline()
    item = line.split()
    self.CPU_ARCH.set(item[2])
    # CPU count (skip this info while rebuilding SoC config)
    line = fp.readline()
    # Scatter-gather
    line = fp.readline()
    if line.find("CONFIG_HAS_SG = y") != -1:
      self.transfers.set(1)
      self.HAS_SG = True
    else:
      self.transfers.set(0)
    # Topology
    line = fp.readline()
    item = line.split()
    rows = int(item[2])
    line = fp.readline()
    item = line.split()
    cols = int(item[2])
    self.noc.create_topology(self.noc.top, rows, cols)
    # CONFIG_CPU_CACHES = L2_SETS L2_WAYS LLC_SETS LLC_WAYS
    line = fp.readline()
    if line.find("CONFIG_CACHE_EN = y") != -1:
      self.cache_en.set(1)
    else:
      self.cache_en.set(0)
    line = fp.readline()
    if line.find("CONFIG_CACHE_RTL = y") != -1:
      self.cache_rtl.set(1)
      self.cache_impl.set("SystemVerilog")
    else:
      self.cache_rtl.set(0)
      self.cache_impl.set("SystemC + HLS")
    line = fp.readline()
    item = line.split()
    self.l2_sets.set(int(item[2]))
    self.l2_ways.set(int(item[3]))
    self.llc_sets.set(int(item[4]))
    self.llc_ways.set(int(item[5]))
    # CONFIG_ACC_CACHES = ACC_L2_SETS ACC_L2_WAYS
    line = fp.readline()
    item = line.split()
    self.acc_l2_sets.set(int(item[2]))
    self.acc_l2_ways.set(int(item[3]))
    # CONFIG_SLM_MBYTES
    line = fp.readline()
    item = line.split()
    self.slm_mbytes.set(int(item[2]))
    # Monitors
    line = fp.readline()
    if line.find("CONFIG_MON_DDR = y") != -1:
        self.noc.monitor_ddr.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_MEM = y") != -1:
        self.noc.monitor_mem.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_INJ = y") != -1:
        self.noc.monitor_inj.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_ROUTERS = y") != -1:
        self.noc.monitor_routers.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_ACCELERATORS = y") != -1:
        self.noc.monitor_accelerators.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_L2 = y") != -1:
        self.noc.monitor_l2.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_LLC = y") != -1:
        self.noc.monitor_llc.set(1)
    line = fp.readline()
    if line.find("CONFIG_MON_DVFS = y") != -1:
        self.noc.monitor_dvfs.set(1)
    # Tiles configuration
    for y in range(0, self.noc.rows):
      for x in range(0, self.noc.cols):
        line = fp.readline().replace("\n","")
        tile = self.noc.topology[y][x]
        tokens = line.split(' ')
        if len(tokens) > 1:
          tile.ip_type.set(tokens[4])
          tile.clk_region.set(int(tokens[5]))
          tile.has_pll.set(int(tokens[6]))
          tile.has_clkbuf.set(int(tokens[7]))
          if tokens[3] == "cpu" and self.cache_en.get() == 1:
            tile.has_l2.set(1)
          if tokens[3] == "acc":
            tile.point.set(tokens[8])
            tile.has_l2.set(tokens[9])
            tile.vendor = tokens[10]
    # DVFS (skip whether it has it or not; we know that already)
    line = fp.readline()
    line = fp.readline()
    item = line.split();
    vf_points = int(item[2])
    self.noc.vf_points = vf_points
    # Power annotation
    for y in range(0, self.noc.rows):
      for x in range(0, self.noc.cols):
        line = fp.readline().replace("\n","")
        tile = self.noc.topology[y][x]
        if len(line) == 0:
          return
        tokens = line.split(' ')
        tile.create_characterization(self, self.noc.vf_points)
        if tile.ip_type.get() == tokens[2]:
          for vf in range(self.noc.vf_points):
            tile.energy_values.vf_points[vf].voltage = float(tokens[3 + vf * 3])
            tile.energy_values.vf_points[vf].frequency = float(tokens[3 + vf * 3 + 1])
            tile.energy_values.vf_points[vf].energy = float(tokens[3 + vf * 3 + 2])
    return 0

  def write_config(self):
    print("Writing backup configuration: \".esp_config.bak\"")
    fp = open('.esp_config.bak', 'w')
    has_dvfs = False;
    fp.write("CPU_ARCH = " + self.CPU_ARCH.get() + "\n")
    fp.write("NCPU_TILE = " + str(self.noc.get_cpu_num(self)) + "\n")
    if self.transfers.get() == 1:
      fp.write("CONFIG_HAS_SG = y\n")
    else:
      fp.write("#CONFIG_HAS_SG is not set\n")
    fp.write("CONFIG_NOC_ROWS = " + str(self.noc.rows) + "\n")
    fp.write("CONFIG_NOC_COLS = " + str(self.noc.cols) + "\n")
    if self.cache_en.get() == 1:
      fp.write("CONFIG_CACHE_EN = y\n")
    else:
      fp.write("#CONFIG_CACHE_EN is not set\n")
    if self.cache_rtl.get() == 1:
      fp.write("CONFIG_CACHE_RTL = y\n")
    else:
      fp.write("#CONFIG_CACHE_RTL is not set\n")
    fp.write("CONFIG_CPU_CACHES = " + str(self.l2_sets.get()) + " " + str(self.l2_ways.get()) + " " + str(self.llc_sets.get()) + " " + str(self.llc_ways.get()) + "\n")
    fp.write("CONFIG_ACC_CACHES = " + str(self.acc_l2_sets.get()) + " " + str(self.acc_l2_ways.get()) + "\n")
    fp.write("CONFIG_SLM_MBYTES = " + str(self.slm_mbytes.get()) + "\n")
    if self.noc.monitor_ddr.get() == 1:
      fp.write("CONFIG_MON_DDR = y\n")
    else:
      fp.write("#CONFIG_MON_DDR is not set\n")
    if self.noc.monitor_mem.get() == 1:
      fp.write("CONFIG_MON_MEM = y\n")
    else:
      fp.write("#CONFIG_MON_MEM is not set\n")
    if self.noc.monitor_inj.get() == 1:
      fp.write("CONFIG_MON_INJ = y\n")
    else:
      fp.write("#CONFIG_MON_INJ is not set\n")
    if self.noc.monitor_routers.get() == 1:
      fp.write("CONFIG_MON_ROUTERS = y\n")
    else:
      fp.write("#CONFIG_MON_ROUTERS is not set\n")
    if self.noc.monitor_accelerators.get() == 1:
      fp.write("CONFIG_MON_ACCELERATORS = y\n")
    else:
      fp.write("#CONFIG_MON_ACCELERATORS is not set\n")
    if self.noc.monitor_l2.get() == 1:
      fp.write("CONFIG_MON_L2 = y\n")
    else:
      fp.write("#CONFIG_MON_L2 is not set\n")
    if self.noc.monitor_llc.get() == 1:
      fp.write("CONFIG_MON_LLC = y\n")
    else:
      fp.write("#CONFIG_MON_LLC is not set\n")
    if self.noc.monitor_dvfs.get() == 1:
      fp.write("CONFIG_MON_DVFS = y\n")
    else:
      fp.write("#CONFIG_MON_DVFS is not set\n")
    i = 0
    for y in range(0, self.noc.rows):
      for x in range(0, self.noc.cols):
        tile = self.noc.topology[y][x]
        selection = tile.ip_type.get()
        is_accelerator = False
        fp.write("TILE_" + str(y) + "_" + str(x) + " = ")
		# Tile number
        fp.write(str(i) + " ")
		# Tile type
        if self.IPs.PROCESSORS.count(selection):
          fp.write("cpu")
        elif self.IPs.MISC.count(selection):
          fp.write("misc")
        elif self.IPs.MEM.count(selection):
          fp.write("mem")
        elif self.IPs.SLM.count(selection):
          fp.write("slm")
        elif self.IPs.ACCELERATORS.count(selection):
          is_accelerator = True
          fp.write("acc")
        else:
          fp.write("empty")
		# Selected accelerator or tile type repeated
        fp.write(" " + selection)
		# Clock region info
        try:
          clk_region = tile.clk_region.get()
          fp.write(" " + str(clk_region))
          if clk_region != 0:
            has_dvfs = True;
        except:
          fp.write(" " + str(0))
        fp.write(" " + str(tile.has_pll.get()))
        fp.write(" " + str(tile.has_clkbuf.get()))
        if is_accelerator:
          fp.write(" " + str(tile.point.get()))
          fp.write(" " + str(tile.has_l2.get()))
          fp.write(" " + str(tile.vendor))
        fp.write("\n")
        i += 1
    if has_dvfs:
      fp.write("CONFIG_HAS_DVFS = y\n")
    else:
      fp.write("#CONFIG_HAS_DVFS is not set\n")
    fp.write("CONFIG_VF_POINTS = " + str(self.noc.vf_points) + "\n")
    for y in range(self.noc.rows):
      for x in range(self.noc.cols):
        tile = self.noc.topology[y][x]
        selection = tile.ip_type.get()
        fp.write("POWER_" + str(y) + "_" + str(x) + " = ")
        fp.write(selection + " ")
        if self.IPs.ACCELERATORS.count(selection) == 0:
          for vf in range(self.noc.vf_points):
            fp.write(str(0) + " " + str(0) + " " + str(0) + " ")
          fp.write("\n")
        else:
          for vf in range(self.noc.vf_points):
            fp.write(str(tile.energy_values.vf_points[vf].voltage) + " " + str(tile.energy_values.vf_points[vf].frequency) + " " + str(tile.energy_values.vf_points[vf].energy) + " ")
          fp.write("\n")

  def check_cfg(self, line, token, end):
    line = line[line.find(token)+len(token):]
    line = line[:line.find(end)]
    line = line.strip()
    return line

  def set_IP(self):
    self.IP_ADDR = str(int('0x' + self.IPM[:2], 16)) + "." + str(int('0x' + self.IPM[2:], 16)) + "." + str(int('0x' + self.IPL[:2], 16)) + "." + str(int('0x' + self.IPL[2:], 16))

  def __init__(self, DMA_WIDTH, TECH, LINUX_MAC, LEON3_STACK):
    self.DMA_WIDTH = DMA_WIDTH
    self.TECH = TECH
    self.LINUX_MAC = LINUX_MAC
    self.LEON3_STACK = LEON3_STACK
    #define whether SGMII has to be used or not: it is not used for PROFPGA boards
    with open("Makefile") as fp:
      for line in fp:
        if line.find("BOARD") != -1 and line.find("profpga") != -1:
          self.HAS_SGMII = False
    IPM = ""
    IPL = ""
    #determine other parameters
    with open("grlib_config.vhd") as fp:
      for line in fp:
        #check target technology
        if line.find("CFG_FABTECH : integer") != -1:
          self.TECH = self.check_cfg(line, "integer := ", ";")
        #check if the CPU is configured to used the CPU
        if line.find("CFG_FPU : integer") != -1:
          self.HAS_FPU = self.check_cfg(line, "integer := ", " ")
        #check if the SoC uses JTAG
        if line.find("CFG_AHB_JTAG") != -1:
          self.HAS_JTAG = int(self.check_cfg(line, "integer := ", ";"))
        #check if the SoC uses ETH
        if line.find("CFG_GRETH ") != -1:
          self.HAS_ETH = int(self.check_cfg(line, "integer := ", ";"))
        #check if the SoC has ethernet
        if line.find("CFG_ETH_IPM") != -1:
          self.IPM = self.check_cfg(line, "16#", "#")
        if line.find("CFG_ETH_IPL") != -1:
          self.IPL = self.check_cfg(line, "16#", "#")
        #check if the SoC uses SVGA
        if line.find("CFG_SVGA_ENABLE ") != -1:
          self.HAS_SVGA = int(self.check_cfg(line, "integer := ", ";"))
    self.IPs = Components(self.TECH, self.DMA_WIDTH)
    #post process configuration
    self.set_IP()
    #0 = Bigphysical area ; 1 = Scatter/Gather
    self.transfers = IntVar()
    self.l2_sets = IntVar()
    self.l2_ways = IntVar()
    self.llc_sets = IntVar()
    self.llc_ways = IntVar()
    self.acc_l2_sets = IntVar()
    self.acc_l2_ways = IntVar()
    self.slm_mbytes = IntVar()
    # CPU architecture
    self.CPU_ARCH = StringVar()
    self.cache_en = IntVar()
    self.cache_rtl = IntVar()
    self.cache_impl = StringVar()
    self.update_list_of_ips()

