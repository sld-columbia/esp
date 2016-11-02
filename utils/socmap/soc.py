#!/usr/bin/python3

from tkinter import *
from tkinter import messagebox
import os.path

from BusConfiguration import *
from NoCConfiguration import *

class Components():

  EMPTY = [
  "empty",
  ]
  PROCESSORS = [
  "cpu",
  ]
  MISC = [
  "IO",
  ]
  MEM = [
  "mem_dbg",
  "mem_lite",
  ]
  ACCELERATORS = [
  ]

  def __init__(self):
    with open("../common/tile_acc.vhd") as fp:
      for line in fp:
        if line.find("if device") != -1:
           line = line[line.find("SLD_")+4:]
           line = line[:line.find("generate")]
           line = line.strip()
           self.ACCELERATORS.append(line)

#board configuration
class SoC_Config():
  HAS_FPU = "0"
  HAS_JTAG = False
  HAS_ETH = False
  HAS_SG = False
  HAS_SGMII = True
  HAS_SVGA = False
  IP_ADDR = ""
  IPs = Components()
  
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
    line = fp.readline()
    if line.find("HAS_SG") != -1:
      self.transfers.set(1)
      self.HAS_SG = True
    else:
      self.transfers.set(0)

    line = fp.readline()
    if line.find("HAS_BUS") != -1:
      self.interconnection_type.set(0)
      line = fp.readline().replace("\n","")
      for x in range(0, int(line)):
        line = fp.readline().replace("\n","")
        tokens = line.split(' ')
        if len(tokens) > 1:
          self.bus.list_accelerators.append(tokens[1])
 
    if line.find("HAS_NOC") != -1:
      self.interconnection_type.set(1)
      self.noc.create_topology(self.noc.top, int(fp.readline().replace("\n","")), int(fp.readline().replace("\n","")))
      self.noc.monitor_ddr.set(int(fp.readline().replace("\n","")))
      self.noc.monitor_inj.set(int(fp.readline().replace("\n","")))
      self.noc.monitor_routers.set(int(fp.readline().replace("\n","")))
      self.noc.monitor_accelerators.set(int(fp.readline().replace("\n","")))
      self.noc.monitor_dvfs.set(int(fp.readline().replace("\n","")))
      for y in range(0, self.noc.rows):
        for x in range(0, self.noc.cols):
          line = fp.readline().replace("\n","")
          tile = self.noc.topology[y][x]
          tokens = line.split(' ')
          if len(tokens) > 1:
            tile.ip_type.set(tokens[1])
            tile.clk_region.set(int(tokens[3]))
            tile.has_pll.set(int(tokens[4]))
            tile.has_clkbuf.set(int(tokens[5]))
      self.noc.vf_points = int(fp.readline().replace("\n",""))
      for y in range(0, self.noc.rows):
        for x in range(0, self.noc.cols):
          line = fp.readline().replace("\n","")
          tile = self.noc.topology[y][x]
          if len(line) == 0:
            return
          tokens = line.split(' ')
          tile.create_characterization(self, self.noc.vf_points)
          if tile.ip_type.get() == tokens[0]:
            for vf in range(self.noc.vf_points):
              tile.energy_values.vf_points[vf].voltage = float(tokens[1 + vf * 3])
              tile.energy_values.vf_points[vf].frequency = float(tokens[1 + vf * 3 + 1])
              tile.energy_values.vf_points[vf].energy = float(tokens[1 + vf * 3 + 2])
    return 0
          
  def write_config(self):
    print("Writing backup configuration: \".esp_config.bak\"")
    fp = open('.esp_config.bak', 'w')
    if self.transfers.get() == 1:
      fp.write("HAS_SG\n")
    elif self.transfers.get() == 0:
      fp.write("HAS_BP\n")
    else:
      fp.write("(unknown)")
    if self.interconnection_type.get() == 0:
      fp.write("HAS_BUS\n")
      fp.write(str(len(self.bus.list_accelerators)) + "\n")
      for x in self.bus.list_accelerators:
        fp.write("acc " + x + "\n")
    if self.interconnection_type.get() == 1:
      fp.write("HAS_NOC\n")
      fp.write(str(self.noc.rows) + "\n")
      fp.write(str(self.noc.cols) + "\n")
      fp.write(str(self.noc.monitor_ddr.get()) + "\n")
      fp.write(str(self.noc.monitor_inj.get()) + "\n")
      fp.write(str(self.noc.monitor_routers.get()) + "\n")
      fp.write(str(self.noc.monitor_accelerators.get()) + "\n")
      fp.write(str(self.noc.monitor_dvfs.get()) + "\n")
      i = 0
      for y in range(0, self.noc.rows):
        for x in range(0, self.noc.cols):
          tile = self.noc.topology[y][x]
          selection = tile.ip_type.get()
          if self.IPs.PROCESSORS.count(selection):
            fp.write("cpu")
          elif self.IPs.MISC.count(selection):
            fp.write("misc")
          elif self.IPs.MEM.count(selection):
            if selection == "mem_dbg":
              fp.write("mem_dbg")
            else:
              fp.write("mem_lite")
          elif self.IPs.ACCELERATORS.count(selection):
            fp.write("acc")
          else:
            fp.write("empty")
          fp.write(" " + selection)
          fp.write(" " + str(i))
          try:
            clk_region = tile.clk_region.get()
            fp.write(" " + str(clk_region))
          except:
            fp.write(" " + str(0))
          fp.write(" " + str(tile.has_pll.get()))
          fp.write(" " + str(tile.has_clkbuf.get()))
          fp.write("\n")
          i += 1
      fp.write(str(self.noc.vf_points) + "\n")
      for y in range(self.noc.rows):
        for x in range(self.noc.cols):
          tile = self.noc.topology[y][x]
          selection = tile.ip_type.get()
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

  def __init__(self):
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
    #post process configuration
    self.set_IP()
    #0 = Bus ; 1 = NoC
    self.interconnection_type = IntVar()
    #0 = Bigphysical area ; 1 = Scatter/Gather
    self.transfers = IntVar()

