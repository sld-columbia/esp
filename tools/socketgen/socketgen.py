#!/usr/bin/env python3

# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

###############################################################################
#
# ESP Wrapper Generator for Accelerators
#
###############################################################################

import shutil
import os
import xml.etree.ElementTree
import glob
import sys
import re
import math

def get_immediate_subdirectories(a_dir):
  return [name for name in os.listdir(a_dir)
        if os.path.isdir(os.path.join(a_dir, name))]

def print_usage():
  print("Usage                    : ./socketgen.py <dma_width> <cpu_arch> <rtl_path> <template_path> <out_path>")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (32, 64)")
  print("")
  print("      <cpu_arch>         : Target processor (ariane, ibex, leon3)")
  print("")
  print("      <rtl_path>         : Path to accelerators' RTL for the target technology")
  print("")
  print("      <template_path>    : Path to file templates")
  print("")
  print("      <out_path>         : Output path")
  print("")

#
### Data structures #
#

class Parameter():
  def __init__(self):
    self.name = ""
    self.desc = ""
    self.size = 0
    self.reg = 0
    self.readonly = False
    self.value = 0

  def __str__(self):
    return "            " + self.name + ", " + self.desc + ", " + str(self.size) + "bits, register " + str(self.reg) + ", def. value " + str(self.value) + "\n"

class Implementation():
  def __init__(self):
    self.name = ""
    self.dma_width = 0
    self.datatype = ""

  def __str__(self):
    return self.name

class Accelerator():
  def __init__(self):
    self.name = ""
    self.hlscfg = []
    self.desc = ""
    self.data = 0
    self.device_id = ""
    self.hls_tool = ""
    self.param = []

  def __str__(self):
    params = "\n          {\n"
    for i in range(0, len(self.param)):
      params = params + str(self.param[i])
    params = params + "          }"
    cfgs = "["
    for i in range(0, len(self.hlscfg) - 1):
      cfgs = cfgs + str(self.hlscfg[i]) + " | "
    cfgs = cfgs + str(self.hlscfg[len(self.hlscfg) - 1])
    cfgs = cfgs + "]"
    return "          " + self.name + "_" + cfgs + ": " + self.desc + ", " + str(self.data) + "MB, ID " + self.device_id + str(params)

class AxiAccelerator():
  def __init__(self):
    self.name = ""
    self.desc = ""
    self.device_id = ""
    self.clocks = [ ]
    self.resets = [ ]
    self.interrupt = ""
    self.axi_prefix = ""
    self.apb_prefix = ""
    self.addr_widh = 32
    self.id_width = 8
    self.user_width = 0

  def __str__(self):
    return "          " + self.name + ": " + self.desc + ", ID " + self.device_id

class Component():
  def __init__(self):
    self.name = ""
    self.hlscfg = []

  def __str__(self):
    cfgs = "["
    for i in range(0, len(self.hlscfg) - 1):
      cfgs = cfgs + str(self.hlscfg[i]) + " | "
    cfgs = cfgs + str(self.hlscfg[len(self.hlscfg) - 1])
    cfgs = cfgs + "]"
    return "          " + self.name + "_" + cfgs

#
### Globals (updated based on DMA_WIDTH)
#
bits_per_line = 128
words_per_line = 4
phys_addr_bits = 32
word_offset_bits = 2
byte_offset_bits = 2
offset_bits = 4
little_endian = 1


#
### VHDL writer ###
#

def gen_device_id(accelerator_list, axi_accelerator_list, template_dir, out_dir):
  f = open(out_dir + '/sld_devices.vhd', 'w')
  with open(template_dir + '/sld_devices.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<hlscfg>>") >= 0:
        conf_id = 1
        for acc in accelerator_list:
          for cfg in acc.hlscfg:
            f.write("  constant HLSCFG_" + acc.name.upper() + "_" + cfg.name.upper() + " " + ": hlscfg_t := " + str(conf_id) + ";\n")
            conf_id = conf_id + 1
      elif tline.find("-- <<devid>>") >= 0:
        for acc in accelerator_list + axi_accelerator_list:
          f.write("  constant SLD_" + acc.name.upper() + " " + ": devid_t := 16#" + acc.device_id + "#;\n")
      elif tline.find("-- <<ddesc>>") >= 0:
        for acc in accelerator_list + axi_accelerator_list:
          desc = acc.desc
          if len(acc.desc) < 31:
            desc = acc.desc + (31 - len(acc.desc))*" "
          elif len(acc.desc) > 31:
            desc = acc.desc[0:30]
          f.write("    SLD_" + acc.name.upper() + " " + "=> \"" + desc + "\",\n")
      else:
        f.write(tline)


def write_axi_acc_interface(f, acc, dma_width):
  for clk in acc.clocks:
    f.write("  " + clk + " : in std_logic;\n")
  for rst in acc.resets:
    f.write("  " + rst + " : in std_logic;\n")
  f.write("  " + acc.apb_prefix + "psel : in std_ulogic;\n")
  f.write("  " + acc.apb_prefix + "penable : in std_ulogic;\n")
  f.write("  " + acc.apb_prefix + "paddr : in std_logic_vector(31 downto 0);\n")
  f.write("  " + acc.apb_prefix + "pwrite : in std_ulogic;\n")
  f.write("  " + acc.apb_prefix + "pwdata : in std_logic_vector(31 downto 0);\n")
  f.write("  " + acc.apb_prefix + "prdata : out std_Logic_vector(31 downto 0);\n")
  f.write("  " + acc.apb_prefix + "pready : out std_logic;\n")
  f.write("  " + acc.apb_prefix + "pslverr : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "awid : out std_logic_vector(" + str(acc.id_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awaddr : out std_logic_vector(" + str(acc.addr_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awlen : out std_logic_vector(7 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awsize : out std_logic_vector(2 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awburst : out std_logic_vector(1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awlock : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "awcache : out std_logic_vector(3 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awprot : out std_logic_vector(2 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awvalid : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "awqos : out std_logic_vector(3 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awatop : out std_logic_vector(5 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awregion : out std_logic_vector(3 downto 0);\n")
  if acc.user_width != "0":
    f.write("  " + acc.axi_prefix + "awuser : out std_logic_vector(" + str(acc.user_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "awready : in std_logic;\n")
  f.write("  " + acc.axi_prefix + "wdata : out std_logic_vector (" + str(dma_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "wstrb : out std_logic_vector (" + str(dma_width) + "/8 - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "wlast : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "wvalid : out std_logic;\n")
  if acc.user_width != "0":
    f.write("  " + acc.axi_prefix + "wuser : out std_logic_vector(" + str(acc.user_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "wready : in std_logic;\n")
  f.write("  " + acc.axi_prefix + "arid  : out std_logic_vector (" + str(acc.id_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "araddr : out std_logic_vector (" + str(acc.addr_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arlen : out std_logic_vector (7 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arsize : out std_logic_vector (2 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arburst : out std_logic_vector (1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arlock : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "arcache : out std_logic_vector (3 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arprot : out std_logic_vector (2 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arvalid : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "arqos : out std_logic_vector (3 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arregion : out std_logic_vector(3 downto 0);\n")
  if acc.user_width != "0":
    f.write("  " + acc.axi_prefix + "aruser : out std_logic_vector(" + str(acc.user_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "arready : in std_logic;\n")
  f.write("  " + acc.axi_prefix + "rready : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "rid : in std_logic_vector (" + str(acc.id_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "rdata : in std_logic_vector (" + str(dma_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "rresp : in std_logic_vector (1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "rlast : in std_logic;\n")
  f.write("  " + acc.axi_prefix + "rvalid : in std_logic;\n")
  if acc.user_width != "0":
    f.write("  " + acc.axi_prefix + "ruser : in std_logic_vector(" + str(acc.user_width) + " - 1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "bready : out std_logic;\n")
  f.write("  " + acc.axi_prefix + "bid : in std_logic_vector (" + str(acc.id_width) + "-1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "bresp : in std_logic_vector (1 downto 0);\n")
  f.write("  " + acc.axi_prefix + "bvalid : in std_logic")
  if acc.user_width != "0" or acc.interrupt != "":
    f.write(";\n")
  if acc.user_width != "0":
    f.write("  " + acc.axi_prefix + "buser : in std_logic_vector(" + str(acc.user_width) + "-1 downto 0)")
    if acc.interrupt != "":
      f.write(";\n")
  if acc.interrupt != "":
    f.write("  " + acc.interrupt + " : out std_logic\n")

def bind_apb3(f, prefix):
  f.write("      " + prefix + "psel => apbi.psel(pindex),\n");
  f.write("      " + prefix + "penable => apbi.penable,\n");
  f.write("      " + prefix + "paddr => apbi_paddr,\n");
  f.write("      " + prefix + "pwrite => apbi.pwrite,\n");
  f.write("      " + prefix + "pwdata => apbi.pwdata,\n");
  f.write("      " + prefix + "prdata => apbo.prdata,\n");
  f.write("      " + prefix + "pready => pready,\n");
  f.write("      " + prefix + "pslverr => open, -- TODO: handle APB3 error\n");


def bind_axi(f, acc, dma_width):
  f.write("      " + acc.axi_prefix + "awid => mosi(0).aw.id(" + str(acc.id_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "awaddr => mosi(0).aw.addr(" + str(acc.addr_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "awlen => mosi(0).aw.len,\n")
  f.write("      " + acc.axi_prefix + "awsize => mosi(0).aw.size,\n")
  f.write("      " + acc.axi_prefix + "awburst => mosi(0).aw.burst,\n")
  f.write("      " + acc.axi_prefix + "awlock => mosi(0).aw.lock,\n")
  f.write("      " + acc.axi_prefix + "awcache => mosi(0).aw.cache,\n")
  f.write("      " + acc.axi_prefix + "awprot => mosi(0).aw.prot,\n")
  f.write("      " + acc.axi_prefix + "awvalid => mosi(0).aw.valid,\n")
  f.write("      " + acc.axi_prefix + "awqos => mosi(0).aw.qos,\n")
  f.write("      " + acc.axi_prefix + "awatop => mosi(0).aw.atop,\n")
  f.write("      " + acc.axi_prefix + "awregion => mosi(0).aw.region,\n")
  if acc.user_width != "0":
    f.write("      " + acc.axi_prefix + "awuser => mosi(0).aw.user(" + str(acc.user_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "awready => somi(0).aw.ready,\n")
  f.write("      " + acc.axi_prefix + "wdata => mosi(0).w.data,\n")
  f.write("      " + acc.axi_prefix + "wstrb => mosi(0).w.strb,\n")
  f.write("      " + acc.axi_prefix + "wlast => mosi(0).w.last,\n")
  f.write("      " + acc.axi_prefix + "wvalid => mosi(0).w.valid,\n")
  if acc.user_width != "0":
    f.write("      " + acc.axi_prefix + "wuser => mosi(0).w.user(" + str(acc.user_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "wready => somi(0).w.ready,\n")
  f.write("      " + acc.axi_prefix + "arid  => mosi(0).ar.id(" + str(acc.id_width) + " - 1 downto 0) ,\n")
  f.write("      " + acc.axi_prefix + "araddr => mosi(0).ar.addr(" + str(acc.addr_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "arlen => mosi(0).ar.len,\n")
  f.write("      " + acc.axi_prefix + "arsize => mosi(0).ar.size,\n")
  f.write("      " + acc.axi_prefix + "arburst => mosi(0).ar.burst,\n")
  f.write("      " + acc.axi_prefix + "arlock => mosi(0).ar.lock,\n")
  f.write("      " + acc.axi_prefix + "arcache => mosi(0).ar.cache,\n")
  f.write("      " + acc.axi_prefix + "arprot => mosi(0).ar.prot,\n")
  f.write("      " + acc.axi_prefix + "arvalid => mosi(0).ar.valid,\n")
  f.write("      " + acc.axi_prefix + "arqos => mosi(0).ar.qos,\n")
  f.write("      " + acc.axi_prefix + "arregion => mosi(0).ar.region,\n")
  if acc.user_width != "0":
    f.write("      " + acc.axi_prefix + "aruser => mosi(0).ar.user(" + str(acc.user_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "arready => somi(0).ar.ready,\n")
  f.write("      " + acc.axi_prefix + "rready => mosi(0).r.ready,\n")
  f.write("      " + acc.axi_prefix + "rid => somi(0).r.id(" + str(acc.id_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "rdata => somi(0).r.data,\n")
  f.write("      " + acc.axi_prefix + "rresp => somi(0).r.resp,\n")
  f.write("      " + acc.axi_prefix + "rlast => somi(0).r.last,\n")
  f.write("      " + acc.axi_prefix + "rvalid => somi(0).r.valid,\n")
  if acc.user_width != "0":
    f.write("      " + acc.axi_prefix + "ruser => somi(0).r.user(" + str(acc.user_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "bready => mosi(0).b.ready,\n")
  f.write("      " + acc.axi_prefix + "bid => somi(0).b.id(" + str(acc.id_width) + " - 1 downto 0),\n")
  f.write("      " + acc.axi_prefix + "bresp => somi(0).b.resp,\n")
  f.write("      " + acc.axi_prefix + "bvalid => somi(0).b.valid")
  if acc.user_width != "0":
    f.write(",\n")
    f.write("      " + acc.axi_prefix + "buser => somi(0).b.user")


def tie_unused_axi(f, acc, dma_width):
  f.write("  pad_id_gen : if XID_WIDTH > " + str(acc.id_width) + " generate\n")
  f.write("    mosi(0).aw.id(XID_WIDTH - 1 downto " + str(acc.id_width) + ") <= (others => '0');\n")
  f.write("    mosi(0).ar.id(XID_WIDTH - 1 downto " + str(acc.id_width) + ") <= (others => '0');\n")
  f.write("  end generate;\n")
  f.write("  pad_paddr_gen : if GLOB_PHYS_ADDR_BITS > " + str(acc.addr_width) + " generate\n")
  f.write("    mosi(0).aw.addr(GLOB_PHYS_ADDR_BITS - 1 downto " + str(acc.addr_width) + ") <= (others => '0');\n")
  f.write("    mosi(0).ar.addr(GLOB_PHYS_ADDR_BITS - 1 downto " + str(acc.addr_width) + ") <= (others => '0');\n")
  f.write("  end generate;\n")
  f.write("  pad_user_gen : if XUSER_WIDTH > " + str(acc.user_width) + " generate\n")
  f.write("    mosi(0).aw.user(XUSER_WIDTH - 1 downto " + str(acc.user_width) + ") <= (others => '0');\n")
  f.write("    mosi(0).w.user(XUSER_WIDTH - 1 downto " + str(acc.user_width) + ") <= (others => '0');\n")
  f.write("    mosi(0).ar.user(XUSER_WIDTH - 1 downto " + str(acc.user_width) + ") <= (others => '0');\n")
  f.write("  end generate;\n")


def write_axi_acc_port_map(f, acc, dma_width):
  f.write("    port map(\n")
  for clk in acc.clocks:
    f.write("      " + clk + " => clk,\n")
  for rst in acc.resets:
    f.write("      " + rst + " => rst,\n")
  bind_apb3(f, acc.apb_prefix)
  bind_axi(f, acc, dma_width)
  if acc.interrupt != "":
    f.write(",\n")
    f.write("      " + acc.interrupt + " => acc_done\n")
  f.write("    );\n")


def write_acc_interface(f, acc, dma_width, datatype, rst, is_vivadohls_if, is_catapulthls_cxx_if, is_catapulthls_sysc_if):

  if is_catapulthls_cxx_if:
    conf_info_size = 0
    for param in acc.param:
      if not param.readonly:
        conf_info_size = conf_info_size + param.size
    spacing = " "
    f.write("      clk                        : in  std_ulogic;\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + ": in  std_ulogic;\n")
    f.write("\n")
    f.write("      conf_info_rsc_dat          : in  std_logic_vector(" + str(conf_info_size - 1) + " downto 0);\n")
    f.write("      conf_info_rsc_vld          : in  std_ulogic;\n")
    f.write("      conf_info_rsc_rdy          : out std_ulogic;\n")
    f.write("\n")
    f.write("      dma_read_ctrl_rsc_dat      : out std_logic_vector(" + str(66) + " downto 0);\n")
    f.write("      dma_read_ctrl_rsc_vld      : out std_ulogic;\n")
    f.write("      dma_read_ctrl_rsc_rdy      : in  std_ulogic;\n")
    f.write("\n")
    f.write("      dma_write_ctrl_rsc_dat     : out std_logic_vector(" + str(66) + " downto 0);\n")
    f.write("      dma_write_ctrl_rsc_vld     : out std_ulogic;\n")
    f.write("      dma_write_ctrl_rsc_rdy     : in  std_ulogic;\n")
    f.write("\n")
    f.write("      dma_read_chnl_rsc_dat      : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      dma_read_chnl_rsc_vld      : in  std_ulogic;\n")
    f.write("      dma_read_chnl_rsc_rdy      : out std_ulogic;\n")
    f.write("\n")
    f.write("      dma_write_chnl_rsc_dat     : out std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      dma_write_chnl_rsc_vld     : out std_ulogic;\n")
    f.write("      dma_write_chnl_rsc_rdy     : in  std_ulogic;\n")
    f.write("\n")
    f.write("      acc_done_rsc_vld           : out std_ulogic\n")

  elif is_catapulthls_sysc_if:
    conf_info_size = 0
    for param in acc.param:
      if not param.readonly:
        conf_info_size = conf_info_size + param.size
    spacing = " "
    f.write("      clk                        : in  std_ulogic;\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + ": in  std_ulogic;\n")
    f.write("\n")
    f.write("      conf_info_msg          : in std_logic_vector(" + str(conf_info_size - 1) + " downto 0);\n")
    f.write("      conf_info_val          : in std_ulogic;\n")
    f.write("      conf_info_rdy          : out  std_ulogic;\n")
    f.write("\n")
    f.write("      dma_read_ctrl_msg          : out std_logic_vector(" + str(66) + " downto 0);\n")
    f.write("      dma_read_ctrl_val          : out std_ulogic;\n")
    f.write("      dma_read_ctrl_rdy          : in  std_ulogic;\n")
    f.write("\n")
    f.write("      dma_write_ctrl_msg         : out std_logic_vector(" + str(66) + " downto 0);\n")
    f.write("      dma_write_ctrl_val         : out std_ulogic;\n")
    f.write("      dma_write_ctrl_rdy         : in  std_ulogic;\n")
    f.write("\n")
    f.write("      dma_read_chnl_msg          : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      dma_read_chnl_val          : in  std_ulogic;\n")
    f.write("      dma_read_chnl_rdy          : out std_ulogic;\n")
    f.write("\n")
    f.write("      dma_write_chnl_msg         : out std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      dma_write_chnl_val         : out std_ulogic;\n")
    f.write("      dma_write_chnl_rdy         : in  std_ulogic;\n")
    f.write("\n")
    f.write("      acc_done                   : out std_ulogic\n")
  elif is_vivadohls_if:
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 17 - len(param.name) > 0:
          spacing = (17-len(param.name))*" "
        f.write("      conf_info_" + param.name + spacing + ": in  std_logic_vector(" + str(param.size - 1) + " downto 0);\n")
    f.write("      ap_clk                     : in  std_ulogic;\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + ": in  std_ulogic;\n")
    f.write("      ap_start                   : in  std_ulogic;\n")
    f.write("      ap_done                    : out std_ulogic;\n")
    f.write("      ap_idle                    : out std_ulogic;\n")
    f.write("      ap_ready                   : out std_ulogic;\n")
    if datatype == 'float' or  datatype == 'float_out':
      f.write("      out_word_din             : out std_logic_vector (" + str(dma_width - 1) + " downto 0);\n")
      f.write("      out_word_full_n          : in  std_logic;\n")
      f.write("      out_word_write           : out std_logic;\n")
    else:
      f.write("      out_word_V_din             : out std_logic_vector (" + str(dma_width - 1) + " downto 0);\n")
      f.write("      out_word_V_full_n          : in  std_logic;\n")
      f.write("      out_word_V_write           : out std_logic;\n")
    if datatype == 'float' or  datatype == 'float_in':
      f.write("      in1_word_dout            : in  std_logic_vector (" + str(dma_width - 1) + " downto 0);\n")
      f.write("      in1_word_empty_n         : in  std_logic;\n")
      f.write("      in1_word_read            : out std_logic;\n")
    else:
      f.write("      in1_word_V_dout            : in  std_logic_vector (" + str(dma_width - 1) + " downto 0);\n")
      f.write("      in1_word_V_empty_n         : in  std_logic;\n")
      f.write("      in1_word_V_read            : out std_logic;\n")
    f.write("      load_ctrl                  : out std_logic_vector (" + str(95) + " downto 0);\n")
    f.write("      load_ctrl_ap_ack           : in  std_logic;\n")
    f.write("      load_ctrl_ap_vld           : out std_logic;\n")
    f.write("      store_ctrl                 : out std_logic_vector (" + str(95) + " downto 0);\n")
    f.write("      store_ctrl_ap_ack          : in  std_logic;\n")
    f.write("      store_ctrl_ap_vld          : out std_logic\n")
  else:
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 17 - len(param.name) > 0:
          spacing = (17-len(param.name))*" "
        f.write("      conf_info_" + param.name + spacing + ": in  std_logic_vector(" + str(param.size - 1) + " downto 0);\n")
    f.write("      clk                        : in  std_ulogic;\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + ": in  std_ulogic;\n")
    f.write("      conf_done                  : in  std_ulogic;\n")
    f.write("      dma_read_ctrl_valid        : out std_ulogic;\n")
    f.write("      dma_read_ctrl_ready        : in  std_ulogic;\n")
    f.write("      dma_read_ctrl_data_index   : out std_logic_vector(" + str(31) + " downto 0);\n")
    f.write("      dma_read_ctrl_data_length  : out std_logic_vector(" + str(31) + " downto 0);\n")
    f.write("      dma_read_ctrl_data_size    : out std_logic_vector(" + str(2) + " downto 0);\n")
    f.write("      dma_write_ctrl_valid       : out std_ulogic;\n")
    f.write("      dma_write_ctrl_ready       : in  std_ulogic;\n")
    f.write("      dma_write_ctrl_data_index  : out std_logic_vector(" + str(31) + " downto 0);\n")
    f.write("      dma_write_ctrl_data_length : out std_logic_vector(" + str(31) + " downto 0);\n")
    f.write("      dma_write_ctrl_data_size   : out std_logic_vector(" + str(2) + " downto 0);\n")
    f.write("      dma_read_chnl_valid        : in  std_ulogic;\n")
    f.write("      dma_read_chnl_ready        : out std_ulogic;\n")
    f.write("      dma_read_chnl_data         : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      dma_write_chnl_valid       : out std_ulogic;\n")
    f.write("      dma_write_chnl_ready       : in  std_ulogic;\n")
    f.write("      dma_write_chnl_data        : out std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      acc_done                   : out std_ulogic\n")

def write_ap_acc_signals(f):
  f.write("\n")
  f.write("signal ap_rst : std_ulogic;\n")
  f.write("\n")
  f.write("-- signals for start fsm\n")
  f.write("\n")
  f.write("type start_state_t is (aps_idle, aps_starting, aps_running, aps_wait_for_completion);\n")
  f.write("signal ap_state, ap_next : start_state_t;\n")
  f.write("signal ap_start : std_ulogic;\n")
  f.write("signal ap_done : std_ulogic;\n")
  f.write("signal ap_idle : std_ulogic;\n")
  f.write("signal ap_ready : std_ulogic;\n")
  f.write("\n")
  f.write("-- signals for ctrl struct unpakc\n")
  f.write("\n")
  f.write("signal dma_read_ctrl_data : std_logic_vector(95 downto 0);\n")
  f.write("signal dma_write_ctrl_data : std_logic_vector(95 downto 0);\n")
  f.write("\n")

def write_acc_port_map(f, acc, dma_width, datatype, rst, is_noc_interface, is_vivadohls_if, is_catapulthls_cxx_if, is_catapulthls_sysc_if):

  if is_vivadohls_if:
    f.write("    port map(\n")
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 16 - len(param.name) > 0:
          spacing = (16-len(param.name))*" "
        if is_noc_interface:
          f.write("      conf_info_" + param.name + spacing + " => " + "bank(" + acc.name.upper() + "_" + param.name.upper() + "_REG)(" + str(param.size - 1) + " downto 0),\n")
        else:
          f.write("      conf_info_" + param.name + spacing + " => " + "conf_info_" + param.name +",\n")
    f.write("      ap_clk                     => clk,\n")
    f.write("      ap_rst                     => ap_rst,\n")
    f.write("      ap_start                   => ap_start,\n")
    f.write("      load_ctrl_ap_vld           => dma_read_ctrl_valid,\n")
    f.write("      load_ctrl_ap_ack           => dma_read_ctrl_ready,\n")
    f.write("      load_ctrl                  => dma_read_ctrl_data,\n")
    f.write("      store_ctrl_ap_vld          => dma_write_ctrl_valid,\n")
    f.write("      store_ctrl_ap_ack          => dma_write_ctrl_ready,\n")
    f.write("      store_ctrl                 => dma_write_ctrl_data,\n")
    if datatype == 'float':
      f.write("      in1_word_empty_n         => dma_read_chnl_valid,\n")
      f.write("      in1_word_read            => dma_read_chnl_ready,\n")
      f.write("      in1_word_dout            => dma_read_chnl_data,\n")
      f.write("      out_word_write           => dma_write_chnl_valid,\n")
      f.write("      out_word_full_n          => dma_write_chnl_ready,\n")
      f.write("      out_word_din             => dma_write_chnl_data,\n")
    else:
      f.write("      in1_word_V_empty_n         => dma_read_chnl_valid,\n")
      f.write("      in1_word_V_read            => dma_read_chnl_ready,\n")
      f.write("      in1_word_V_dout            => dma_read_chnl_data,\n")
      f.write("      out_word_V_write           => dma_write_chnl_valid,\n")
      f.write("      out_word_V_full_n          => dma_write_chnl_ready,\n")
      f.write("      out_word_V_din             => dma_write_chnl_data,\n")
    f.write("      ap_done                    => ap_done,\n")
    f.write("      ap_idle                    => ap_idle,\n")
    f.write("      ap_ready                   => ap_ready\n")
    f.write("      );\n")
    f.write("\n")
    f.write("  ap_rst <= not acc_rst;\n")
    f.write("  acc_done <= ap_done;\n");
    f.write("\n")
    f.write("  -- START FSM\n")
    f.write("\n")
    f.write("  ap_acc_fsm: process (ap_state, conf_done, ap_idle, ap_ready, ap_done) is\n")
    f.write("  begin  -- process ap_acc_fsm\n")
    f.write("    ap_next <= ap_state;\n")
    f.write("    ap_start <= '0';\n")
    f.write("\n")
    f.write("    case ap_state is\n")
    f.write("\n")
    f.write("      when aps_idle =>\n")
    f.write("        if (ap_idle and conf_done) = '1' then\n")
    f.write("          ap_next <= aps_starting;\n")
    f.write("        end if;\n")
    f.write("\n")
    f.write("      when aps_starting =>\n")
    f.write("        ap_start <= '1';\n")
    f.write("        if ap_ready = '1' then\n")
    f.write("          ap_next <= aps_wait_for_completion;\n")
    f.write("        elsif ap_idle = '0' then\n")
    f.write("          ap_next <= aps_running;\n")
    f.write("        end if;\n")
    f.write("\n")
    f.write("      when aps_running =>\n")
    f.write("        ap_start <= '1';\n")
    f.write("        if ap_done = '1' then\n")
    f.write("          ap_next <= aps_idle;\n")
    f.write("        elsif ap_ready = '1' then\n")
    f.write("          ap_next <= aps_wait_for_completion;\n")
    f.write("        end if;\n")
    f.write("\n")
    f.write("      when aps_wait_for_completion =>\n")
    f.write("        if ap_done = '1' then\n")
    f.write("          ap_next <= aps_idle;\n")
    f.write("        end if;\n")
    f.write("\n")
    f.write("      when others =>\n")
    f.write("        ap_next <= aps_idle;\n")
    f.write("\n")
    f.write("    end case;\n")
    f.write("  end process ap_acc_fsm;\n")
    f.write("\n")
    f.write("  ap_acc_state_update: process (clk, ap_rst) is\n")
    f.write("  begin  -- process ap_acc_state_update\n")
    f.write("    if clk'event and clk = '1' then    -- rising clock edge\n")
    f.write("      if ap_rst = '1' then                -- synchronous active high\n")
    f.write("        ap_state <= aps_idle;\n")
    f.write("      else\n")
    f.write("        ap_state <= ap_next;\n")
    f.write("      end if;\n")
    f.write("    end if;\n")
    f.write("  end process ap_acc_state_update;\n")
    f.write("\n")
    f.write("  ---- CTRL FSM\n")
    f.write("\n")
    f.write("  dma_read_ctrl_data_size    <= dma_read_ctrl_data(66 downto 64);\n")
    f.write("  dma_read_ctrl_data_length  <= dma_read_ctrl_data(63 downto 32);\n")
    f.write("  dma_read_ctrl_data_index   <= dma_read_ctrl_data(31 downto  0);\n")
    f.write("  dma_write_ctrl_data_size   <= dma_write_ctrl_data(66 downto 64);\n")
    f.write("  dma_write_ctrl_data_length <= dma_write_ctrl_data(63 downto 32);\n")
    f.write("  dma_write_ctrl_data_index  <= dma_write_ctrl_data(31 downto  0);\n")
    f.write("\n")
  elif is_catapulthls_cxx_if:
    f.write("    port map(\n")
    f.write("      clk                        => clk,\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + "=> acc_rst,\n")
    f.write("\n")
    conf_info_rsc_data_size = 0
    for param in acc.param:
      if not param.readonly:
          conf_info_rsc_data_size += param.size
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 14 - len(param.name) > 0:
          spacing = (14-len(param.name))*" "
        f.write("      conf_info_rsc_dat(" + str(conf_info_rsc_data_size-1) + " downto " +  str(conf_info_rsc_data_size-param.size) + ") => " + "conf_info_" + param.name +",\n")
        conf_info_rsc_data_size -= param.size
    f.write("      conf_info_rsc_vld          => conf_info_rsc_valid,\n")
    f.write("      conf_info_rsc_rdy          => conf_info_rsc_ready,\n")
    f.write("\n")
    f.write("      dma_read_ctrl_rsc_dat(66 downto 64) => dma_read_ctrl_data_size,\n")
    f.write("      dma_read_ctrl_rsc_dat(63 downto 32) => dma_read_ctrl_data_length,\n")
    f.write("      dma_read_ctrl_rsc_dat(31 downto 0)  => dma_read_ctrl_data_index,\n")
    f.write("      dma_read_ctrl_rsc_vld      => dma_read_ctrl_valid,\n")
    f.write("      dma_read_ctrl_rsc_rdy      => dma_read_ctrl_ready,\n")
    f.write("\n")
    f.write("      dma_write_ctrl_rsc_dat(" + str(66) + " downto " + str(64) + ") => dma_write_ctrl_data_size,\n"),
    f.write("      dma_write_ctrl_rsc_dat(" + str(63) + " downto " + str(32) + ") => dma_write_ctrl_data_length,\n")
    f.write("      dma_write_ctrl_rsc_dat(" + str(31) + " downto 0)  => dma_write_ctrl_data_index,\n")
    f.write("      dma_write_ctrl_rsc_vld     => dma_write_ctrl_valid,\n")
    f.write("      dma_write_ctrl_rsc_rdy     => dma_write_ctrl_ready,\n")
    f.write("\n")
    f.write("      dma_read_chnl_rsc_dat      => dma_read_chnl_data,\n")
    f.write("      dma_read_chnl_rsc_vld      => dma_read_chnl_valid,\n")
    f.write("      dma_read_chnl_rsc_rdy      => dma_read_chnl_ready,\n")
    f.write("\n")
    f.write("      dma_write_chnl_rsc_dat     => dma_write_chnl_data,\n")
    f.write("      dma_write_chnl_rsc_vld     => dma_write_chnl_valid,\n")
    f.write("      dma_write_chnl_rsc_rdy     => dma_write_chnl_ready,\n")
    f.write("\n")
    f.write("      acc_done_rsc_vld           => acc_done\n")
    f.write("    );\n")
  elif is_catapulthls_sysc_if:

    f.write("    port map(\n")
    f.write("      clk                        => clk,\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + "=> acc_rst,\n")
    f.write("\n")
    conf_info_size = 0

    for param in acc.param:
      if not param.readonly:
          conf_info_size += param.size
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 14 - len(param.name) > 0:
          spacing = (14-len(param.name))*" "
        f.write("      conf_info_msg(" + str(conf_info_size-1) + " downto " +  str(conf_info_size-param.size) + ") => " + "conf_info_" + param.name +",\n")
        conf_info_size -= param.size

    f.write("      conf_info_val          => conf_info_rsc_valid,\n")
    f.write("      conf_info_rdy          => conf_info_rsc_ready,\n")
    f.write("\n")
    f.write("      dma_read_ctrl_val          => dma_read_ctrl_valid,\n")
    f.write("      dma_read_ctrl_rdy          => dma_read_ctrl_ready,\n")
    f.write("      dma_read_ctrl_msg(" + str(66) + " downto " + str(64) + ") => dma_read_ctrl_data_size,\n")
    f.write("      dma_read_ctrl_msg(" + str(63) + " downto " + str(32) + ") => dma_read_ctrl_data_length,\n")
    f.write("      dma_read_ctrl_msg(" + str(31) + " downto " + str(0) + ") => dma_read_ctrl_data_index,\n")
    f.write("      dma_write_ctrl_val         => dma_write_ctrl_valid,\n")
    f.write("      dma_write_ctrl_rdy         => dma_write_ctrl_ready,\n")
    f.write("      dma_write_ctrl_msg(" + str(66) + " downto " + str(64) + ") => dma_write_ctrl_data_size,\n")
    f.write("      dma_write_ctrl_msg(" + str(63) + " downto " + str(32) + ") => dma_write_ctrl_data_length,\n")
    f.write("      dma_write_ctrl_msg(" + str(31) + " downto " + str(0) + ") => dma_write_ctrl_data_index,\n")
    f.write("      dma_read_chnl_val          => dma_read_chnl_valid,\n")
    f.write("      dma_read_chnl_rdy          => dma_read_chnl_ready,\n")
    f.write("      dma_read_chnl_msg          => dma_read_chnl_data,\n")
    f.write("      dma_write_chnl_val         => dma_write_chnl_valid,\n")
    f.write("      dma_write_chnl_rdy         => dma_write_chnl_ready,\n")
    f.write("      dma_write_chnl_msg         => dma_write_chnl_data,\n")
    f.write("      acc_done                   => acc_done\n")
    f.write("    );\n")

  else:
    f.write("    port map(\n")
    for param in acc.param:
      if not param.readonly:
        spacing = " "
        if 16 - len(param.name) > 0:
          spacing = (16-len(param.name))*" "
        if is_noc_interface:
          f.write("      conf_info_" + param.name + spacing + " => " + "bank(" + acc.name.upper() + "_" + param.name.upper() + "_REG)(" + str(param.size - 1) + " downto 0),\n")
        else:
          f.write("      conf_info_" + param.name + spacing + " => " + "conf_info_" + param.name +",\n")
    f.write("      clk                        => clk,\n")
    spacing = (27-len(rst))*" "
    f.write("      " + rst + spacing       + "=> acc_rst,\n")
    f.write("      conf_done                  => conf_done,\n")
    f.write("      dma_read_ctrl_valid        => dma_read_ctrl_valid,\n")
    f.write("      dma_read_ctrl_ready        => dma_read_ctrl_ready,\n")
    f.write("      dma_read_ctrl_data_index   => dma_read_ctrl_data_index,\n")
    f.write("      dma_read_ctrl_data_length  => dma_read_ctrl_data_length,\n")
    f.write("      dma_read_ctrl_data_size    => dma_read_ctrl_data_size,\n")
    f.write("      dma_write_ctrl_valid       => dma_write_ctrl_valid,\n")
    f.write("      dma_write_ctrl_ready       => dma_write_ctrl_ready,\n")
    f.write("      dma_write_ctrl_data_index  => dma_write_ctrl_data_index,\n")
    f.write("      dma_write_ctrl_data_length => dma_write_ctrl_data_length,\n")
    f.write("      dma_write_ctrl_data_size   => dma_write_ctrl_data_size,\n")
    f.write("      dma_read_chnl_valid        => dma_read_chnl_valid,\n")
    f.write("      dma_read_chnl_ready        => dma_read_chnl_ready,\n")
    f.write("      dma_read_chnl_data         => dma_read_chnl_data,\n")
    f.write("      dma_write_chnl_valid       => dma_write_chnl_valid,\n")
    f.write("      dma_write_chnl_ready       => dma_write_chnl_ready,\n")
    f.write("      dma_write_chnl_data        => dma_write_chnl_data,\n")
    f.write("      acc_done                   => acc_done\n")
    f.write("    );\n")


# TODO replace all hardcoded vector lengths with constants
def write_cache_interface(f, cac, is_llc):
  if (is_llc and 'spandex' not in cac.name):
    f.write("      clk                          : in std_ulogic;\n")
    f.write("      rst                          : in std_ulogic;\n")
    f.write("      llc_req_in_valid             : in std_ulogic;\n")
    f.write("      llc_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);\n")
    f.write("      llc_req_in_data_hprot        : in std_logic_vector(1 downto 0);\n")
    f.write("      llc_req_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_word_offset  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_valid_words  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + "  downto 0);\n")
    f.write("      llc_req_in_data_req_id       : in std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_req_in_valid             : in std_ulogic;\n")
    f.write("      llc_dma_req_in_data_coh_msg      : in std_logic_vector(2 downto 0);\n")
    f.write("      llc_dma_req_in_data_hprot        : in std_logic_vector(1 downto 0);\n")
    f.write("      llc_dma_req_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_word_offset  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_valid_words  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_req_id       : in std_logic_vector(5 downto 0);\n")
    f.write("      llc_rsp_in_valid             : in std_ulogic;\n")
    f.write("      llc_rsp_in_data_coh_msg      : in std_logic_vector(1 downto 0);\n")
    f.write("      llc_rsp_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_rsp_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rsp_in_data_req_id       : in std_logic_vector(3 downto 0);\n")
    f.write("      llc_mem_rsp_valid            : in std_ulogic;\n")
    f.write("      llc_mem_rsp_data_line        : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rst_tb_valid             : in std_ulogic;\n")
    f.write("      llc_rst_tb_data              : in std_ulogic;\n")
    f.write("      llc_rsp_out_ready            : in std_ulogic;\n")
    f.write("      llc_dma_rsp_out_ready            : in std_ulogic;\n")
    f.write("      llc_fwd_out_ready            : in std_ulogic;\n")
    f.write("      llc_mem_req_ready            : in std_ulogic;\n")
    f.write("      llc_rst_tb_done_ready        : in std_ulogic;\n")
    f.write("      llc_stats_ready              : in std_ulogic;\n")
    f.write("      llc_req_in_ready             : out std_ulogic;\n")
    f.write("      llc_dma_req_in_ready             : out std_ulogic;\n")
    f.write("      llc_rsp_in_ready             : out std_ulogic;\n")
    f.write("      llc_mem_rsp_ready            : out std_ulogic;\n")
    f.write("      llc_rst_tb_ready             : out std_ulogic;\n")
    f.write("      llc_rsp_out_valid            : out std_ulogic;\n")
    f.write("      llc_rsp_out_data_coh_msg     : out std_logic_vector(1 downto 0);\n")
    f.write("      llc_rsp_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_rsp_out_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_req_id      : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_word_offset : out std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_valid            : out std_ulogic;\n")
    f.write("      llc_dma_rsp_out_data_coh_msg     : out std_logic_vector(1 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_req_id      : out std_logic_vector(5 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_word_offset : out std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_fwd_out_valid            : out std_ulogic;\n")
    f.write("      llc_fwd_out_data_coh_msg     : out std_logic_vector(2 downto 0);\n")
    f.write("      llc_fwd_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_fwd_out_data_req_id      : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_fwd_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_mem_req_valid            : out std_ulogic;\n")
    f.write("      llc_mem_req_data_hwrite      : out std_ulogic;\n")
    f.write("      llc_mem_req_data_hsize       : out std_logic_vector(2 downto 0);\n")
    f.write("      llc_mem_req_data_hprot       : out std_logic_vector(1 downto 0);\n")
    f.write("      llc_mem_req_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_mem_req_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_stats_valid              : out std_ulogic;\n")
    f.write("      llc_stats_data               : out std_ulogic;\n")
    f.write("      llc_rst_tb_done_valid        : out std_ulogic;\n")
    f.write("      llc_rst_tb_done_data         : out std_ulogic\n")
  elif (is_llc and 'spandex' in cac.name):
    f.write("      clk                          : in std_ulogic;\n")
    f.write("      rst                          : in std_ulogic;\n")
    f.write("      llc_req_in_valid             : in std_ulogic;\n")
    f.write("      llc_req_in_data_coh_msg      : in std_logic_vector(4 downto 0);\n")
    f.write("      llc_req_in_data_hprot        : in std_logic_vector(1 downto 0);\n")
    f.write("      llc_req_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_word_offset  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_valid_words  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_req_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + "  downto 0);\n")
    f.write("      llc_req_in_data_word_mask    : in std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_req_in_data_req_id       : in std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_req_in_valid             : in std_ulogic;\n")
    f.write("      llc_dma_req_in_data_coh_msg      : in std_logic_vector(4 downto 0);\n")
    f.write("      llc_dma_req_in_data_hprot        : in std_logic_vector(1 downto 0);\n")
    f.write("      llc_dma_req_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_word_offset  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_valid_words  : in std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_dma_req_in_data_req_id       : in std_logic_vector(5 downto 0);\n")
    f.write("      llc_dma_req_in_data_word_mask    : in std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_rsp_in_valid             : in std_ulogic;\n")
    f.write("      llc_rsp_in_data_coh_msg      : in std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_in_data_addr         : in std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_rsp_in_data_line         : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rsp_in_data_word_mask    : in std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_rsp_in_data_req_id       : in std_logic_vector(3 downto 0);\n")
    f.write("      llc_mem_rsp_valid            : in std_ulogic;\n")
    f.write("      llc_mem_rsp_data_line        : in std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rst_tb_valid             : in std_ulogic;\n")
    f.write("      llc_rst_tb_data              : in std_ulogic;\n")
    f.write("      llc_rsp_out_ready            : in std_ulogic;\n")
    f.write("      llc_dma_rsp_out_ready            : in std_ulogic;\n")
    f.write("      llc_fwd_out_ready            : in std_ulogic;\n")
    f.write("      llc_mem_req_ready            : in std_ulogic;\n")
    f.write("      llc_rst_tb_done_ready        : in std_ulogic;\n")
    f.write("      llc_stats_ready              : in std_ulogic;\n")
    f.write("      llc_req_in_ready             : out std_ulogic;\n")
    f.write("      llc_dma_req_in_ready             : out std_ulogic;\n")
    f.write("      llc_rsp_in_ready             : out std_ulogic;\n")
    f.write("      llc_mem_rsp_ready            : out std_ulogic;\n")
    f.write("      llc_rst_tb_ready             : out std_ulogic;\n")
    f.write("      llc_rsp_out_valid            : out std_ulogic;\n")
    f.write("      llc_rsp_out_data_coh_msg     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_rsp_out_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_rsp_out_data_word_mask   : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_req_id      : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_rsp_out_data_word_offset : out std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_valid            : out std_ulogic;\n")
    f.write("      llc_dma_rsp_out_data_coh_msg     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_data_invack_cnt  : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_req_id      : out std_logic_vector(5 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_dma_rsp_out_data_word_offset : out std_logic_vector(" + str(word_offset_bits - 1) + " downto 0);\n")
    f.write("      llc_dma_rsp_out_data_word_mask   : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_fwd_out_valid            : out std_ulogic;\n")
    f.write("      llc_fwd_out_data_coh_msg     : out std_logic_vector(4 downto 0);\n")
    f.write("      llc_fwd_out_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_fwd_out_data_req_id      : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_fwd_out_data_dest_id     : out std_logic_vector(3 downto 0);\n")
    f.write("      llc_fwd_out_data_word_mask   : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      llc_fwd_out_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + "  downto 0);\n")
    f.write("      llc_mem_req_valid            : out std_ulogic;\n")
    f.write("      llc_mem_req_data_hwrite      : out std_ulogic;\n")
    f.write("      llc_mem_req_data_hsize       : out std_logic_vector(2 downto 0);\n")
    f.write("      llc_mem_req_data_hprot       : out std_logic_vector(1 downto 0);\n")
    f.write("      llc_mem_req_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      llc_mem_req_data_line        : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      llc_stats_valid              : out std_ulogic;\n")
    f.write("      llc_stats_data               : out std_ulogic;\n")
    f.write("      llc_rst_tb_done_valid        : out std_ulogic;\n")
    f.write("      llc_rst_tb_done_data         : out std_ulogic\n")
  elif (not is_llc and 'spandex' in cac.name):
    f.write("      clk                       : in  std_ulogic;\n")
    f.write("      rst                       : in  std_ulogic;\n")
    f.write("      l2_cpu_req_valid          : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_cpu_msg   : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_cpu_req_data_hsize     : in  std_logic_vector(2 downto 0);\n")
    f.write("      l2_cpu_req_data_hprot     : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_cpu_req_data_addr      : in  std_logic_vector(" + str(phys_addr_bits - 1) + " downto 0);\n")
    f.write("      l2_cpu_req_data_word      : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      l2_cpu_req_data_amo       : in  std_logic_vector(5 downto 0);\n")
    f.write("      l2_cpu_req_data_aq        : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_rl        : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_dcs_en    : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_use_owner_pred : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_dcs       : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_cpu_req_data_pred_cid  : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_fwd_in_valid           : in  std_ulogic;\n")
    f.write("      l2_fwd_in_data_coh_msg    : in  std_logic_vector(4 downto 0);\n")
    f.write("      l2_fwd_in_data_addr       : in  std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_fwd_in_data_req_id     : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_fwd_in_data_word_mask  : in std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      l2_fwd_in_data_line       : in std_logic_vector(" + str(bits_per_line - 1) + "  downto 0);\n")
    f.write("      l2_rsp_in_valid           : in  std_ulogic;\n")
    f.write("      l2_rsp_in_data_coh_msg    : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_rsp_in_data_addr       : in  std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_rsp_in_data_line       : in  std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_rsp_in_data_word_mask  : in std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      l2_rsp_in_data_invack_cnt : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_flush_valid            : in  std_ulogic;\n")
    f.write("      l2_flush_data             : in  std_ulogic;\n")
    f.write("      l2_rd_rsp_ready           : in  std_ulogic;\n")
    f.write("      l2_inval_ready            : in  std_ulogic;\n")
    f.write("      l2_bresp_ready            : in  std_ulogic;\n")
    f.write("      l2_req_out_ready          : in  std_ulogic;\n")
    f.write("      l2_rsp_out_ready          : in  std_ulogic;\n")
    f.write("      l2_fwd_out_ready          : in  std_ulogic;\n")
    f.write("      l2_stats_ready            : in  std_ulogic;\n")
    f.write("      flush_done                : out std_ulogic;\n")
    f.write("      l2_cpu_req_ready          : out std_ulogic;\n")
    f.write("      l2_fwd_in_ready           : out std_ulogic;\n")
    f.write("      l2_rsp_in_ready           : out std_ulogic;\n")
    f.write("      l2_flush_ready            : out std_ulogic;\n")
    f.write("      l2_rd_rsp_valid           : out std_ulogic;\n")
    f.write("      l2_rd_rsp_data_line       : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_inval_valid            : out std_ulogic;\n")
    f.write("      l2_inval_data             : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_bresp_valid            : out std_ulogic;\n")
    f.write("      l2_bresp_data             : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_req_out_valid          : out std_ulogic;\n")
    f.write("      l2_req_out_data_coh_msg   : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_req_out_data_hprot     : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_req_out_data_addr      : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_req_out_data_line      : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_req_out_data_word_mask : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      l2_rsp_out_valid          : out std_ulogic;\n")
    f.write("      l2_rsp_out_data_coh_msg   : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_rsp_out_data_req_id    : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_rsp_out_data_to_req    : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_rsp_out_data_addr      : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_rsp_out_data_line      : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_rsp_out_data_word_mask : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      l2_fwd_out_valid          : out std_ulogic;\n")
    f.write("      l2_fwd_out_data_coh_msg   : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_fwd_out_data_req_id    : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_fwd_out_data_to_req    : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_fwd_out_data_addr      : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_fwd_out_data_line      : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_fwd_out_data_word_mask : out std_logic_vector(" + str(words_per_line - 1) + "  downto 0);\n")
    f.write("      l2_stats_valid            : out std_ulogic;\n")
    f.write("      l2_stats_data             : out std_ulogic;\n")
    f.write("      l2_fence_ready            : out std_ulogic;\n")
    f.write("      l2_fence_valid            : in  std_ulogic;\n")
    f.write("      l2_fence_data             : in  std_logic_vector(1 downto 0)\n")
  elif (not is_llc and 'spandex' not in cac.name):
    f.write("      clk                       : in  std_ulogic;\n")
    f.write("      rst                       : in  std_ulogic;\n")
    f.write("      l2_cpu_req_valid          : in  std_ulogic;\n")
    f.write("      l2_cpu_req_data_cpu_msg   : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_cpu_req_data_hsize     : in  std_logic_vector(2 downto 0);\n")
    f.write("      l2_cpu_req_data_hprot     : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_cpu_req_data_addr      : in  std_logic_vector(" + str(phys_addr_bits - 1) + " downto 0);\n")
    f.write("      l2_cpu_req_data_word      : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
    f.write("      l2_cpu_req_data_amo       : in  std_logic_vector(5 downto 0);\n")
    f.write("      l2_fwd_in_valid           : in  std_ulogic;\n")
    f.write("      l2_fwd_in_data_coh_msg    : in  std_logic_vector(2 downto 0);\n")
    f.write("      l2_fwd_in_data_addr       : in  std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_fwd_in_data_req_id     : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_rsp_in_valid           : in  std_ulogic;\n")
    f.write("      l2_rsp_in_data_coh_msg    : in  std_logic_vector(1 downto 0);\n")
    f.write("      l2_rsp_in_data_addr       : in  std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_rsp_in_data_line       : in  std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_rsp_in_data_invack_cnt : in  std_logic_vector(3 downto 0);\n")
    f.write("      l2_flush_valid            : in  std_ulogic;\n")
    f.write("      l2_flush_data             : in  std_ulogic;\n")
    f.write("      l2_rd_rsp_ready           : in  std_ulogic;\n")
    f.write("      l2_inval_ready            : in  std_ulogic;\n")
    f.write("      l2_bresp_ready            : in  std_ulogic;\n")
    f.write("      l2_req_out_ready          : in  std_ulogic;\n")
    f.write("      l2_rsp_out_ready          : in  std_ulogic;\n")
    f.write("      l2_stats_ready            : in  std_ulogic;\n")
    f.write("      flush_done                : out std_ulogic;\n")
    f.write("      l2_cpu_req_ready          : out std_ulogic;\n")
    f.write("      l2_fwd_in_ready           : out std_ulogic;\n")
    f.write("      l2_rsp_in_ready           : out std_ulogic;\n")
    f.write("      l2_flush_ready            : out std_ulogic;\n")
    f.write("      l2_rd_rsp_valid           : out std_ulogic;\n")
    f.write("      l2_rd_rsp_data_line       : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_inval_valid            : out std_ulogic;\n")
    f.write("      l2_inval_data_addr        : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_inval_data_hprot       : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_bresp_valid            : out std_ulogic;\n")
    f.write("      l2_bresp_data             : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_req_out_valid          : out std_ulogic;\n")
    f.write("      l2_req_out_data_coh_msg   : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_req_out_data_hprot     : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_req_out_data_addr      : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_req_out_data_line      : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_rsp_out_valid          : out std_ulogic;\n")
    f.write("      l2_rsp_out_data_coh_msg   : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_rsp_out_data_req_id    : out std_logic_vector(3 downto 0);\n")
    f.write("      l2_rsp_out_data_to_req    : out std_logic_vector(1 downto 0);\n")
    f.write("      l2_rsp_out_data_addr      : out std_logic_vector(" + str(phys_addr_bits - offset_bits - 1) + " downto 0);\n")
    f.write("      l2_rsp_out_data_line      : out std_logic_vector(" + str(bits_per_line - 1) + " downto 0);\n")
    f.write("      l2_stats_valid            : out std_ulogic;\n")
    f.write("      l2_stats_data             : out std_ulogic\n")


def write_cache_port_map(f, cac, is_llc):
  f.write("    port map(\n")
  if is_llc and 'spandex' in cac.name:
    f.write("      clk                          => clk,\n")
    f.write("      rst                          => rst,\n")
    f.write("      llc_req_in_valid             => llc_req_in_valid,\n")
    f.write("      llc_req_in_data_coh_msg      => llc_req_in_data_coh_msg,\n")
    f.write("      llc_req_in_data_hprot        => llc_req_in_data_hprot,\n")
    f.write("      llc_req_in_data_addr         => llc_req_in_data_addr,\n")
    f.write("      llc_req_in_data_word_offset  => llc_req_in_data_word_offset,\n")
    f.write("      llc_req_in_data_valid_words  => llc_req_in_data_valid_words,\n")
    f.write("      llc_req_in_data_line         => llc_req_in_data_line,\n")
    f.write("      llc_req_in_data_word_mask    => llc_req_in_data_word_mask,\n")
    f.write("      llc_req_in_data_req_id       => llc_req_in_data_req_id,\n")
    f.write("      llc_dma_req_in_valid             => llc_dma_req_in_valid,\n")
    f.write("      llc_dma_req_in_data_coh_msg      => llc_dma_req_in_data_coh_msg,\n")
    f.write("      llc_dma_req_in_data_hprot        => llc_dma_req_in_data_hprot,\n")
    f.write("      llc_dma_req_in_data_addr         => llc_dma_req_in_data_addr,\n")
    f.write("      llc_dma_req_in_data_word_offset  => llc_dma_req_in_data_word_offset,\n")
    f.write("      llc_dma_req_in_data_valid_words  => llc_dma_req_in_data_valid_words,\n")
    f.write("      llc_dma_req_in_data_line         => llc_dma_req_in_data_line,\n")
    f.write("      llc_dma_req_in_data_req_id       => llc_dma_req_in_data_req_id,\n")
    f.write("      llc_dma_req_in_data_word_mask    => llc_dma_req_in_data_word_mask,\n")
    f.write("      llc_rsp_in_valid             => llc_rsp_in_valid,\n")
    f.write("      llc_rsp_in_data_coh_msg      => llc_rsp_in_data_coh_msg,\n")
    f.write("      llc_rsp_in_data_addr         => llc_rsp_in_data_addr,\n")
    f.write("      llc_rsp_in_data_line         => llc_rsp_in_data_line,\n")
    f.write("      llc_rsp_in_data_word_mask    => llc_rsp_in_data_word_mask,\n")
    f.write("      llc_rsp_in_data_req_id       => llc_rsp_in_data_req_id,\n")
    f.write("      llc_mem_rsp_valid            => llc_mem_rsp_valid,\n")
    f.write("      llc_mem_rsp_data_line        => llc_mem_rsp_data_line,\n")
    f.write("      llc_rst_tb_valid             => llc_rst_tb_valid,\n")
    f.write("      llc_rst_tb_data              => llc_rst_tb_data,\n")
    f.write("      llc_rsp_out_ready            => llc_rsp_out_ready,\n")
    f.write("      llc_dma_rsp_out_ready            => llc_dma_rsp_out_ready,\n")
    f.write("      llc_fwd_out_ready            => llc_fwd_out_ready,\n")
    f.write("      llc_mem_req_ready            => llc_mem_req_ready,\n")
    f.write("      llc_rst_tb_done_ready        => llc_rst_tb_done_ready,\n")
    f.write("      llc_stats_ready              => llc_stats_ready,\n")
    f.write("      llc_req_in_ready             => llc_req_in_ready,\n")
    f.write("      llc_dma_req_in_ready             => llc_dma_req_in_ready,\n")
    f.write("      llc_rsp_in_ready             => llc_rsp_in_ready,\n")
    f.write("      llc_mem_rsp_ready            => llc_mem_rsp_ready,\n")
    f.write("      llc_rst_tb_ready             => llc_rst_tb_ready,\n")
    f.write("      llc_rsp_out_valid            => llc_rsp_out_valid,\n")
    f.write("      llc_rsp_out_data_coh_msg     => llc_rsp_out_data_coh_msg,\n")
    f.write("      llc_rsp_out_data_addr        => llc_rsp_out_data_addr,\n")
    f.write("      llc_rsp_out_data_line        => llc_rsp_out_data_line,\n")
    f.write("      llc_rsp_out_data_invack_cnt  => llc_rsp_out_data_invack_cnt,\n")
    f.write("      llc_rsp_out_data_req_id      => llc_rsp_out_data_req_id,\n")
    f.write("      llc_rsp_out_data_dest_id     => llc_rsp_out_data_dest_id,\n")
    f.write("      llc_rsp_out_data_word_offset => llc_rsp_out_data_word_offset,\n")
    f.write("      llc_rsp_out_data_word_mask   => llc_rsp_out_data_word_mask,\n")
    f.write("      llc_dma_rsp_out_valid            => llc_dma_rsp_out_valid,\n")
    f.write("      llc_dma_rsp_out_data_coh_msg     => llc_dma_rsp_out_data_coh_msg,\n")
    f.write("      llc_dma_rsp_out_data_addr        => llc_dma_rsp_out_data_addr,\n")
    f.write("      llc_dma_rsp_out_data_line        => llc_dma_rsp_out_data_line,\n")
    f.write("      llc_dma_rsp_out_data_invack_cnt  => llc_dma_rsp_out_data_invack_cnt,\n")
    f.write("      llc_dma_rsp_out_data_req_id      => llc_dma_rsp_out_data_req_id,\n")
    f.write("      llc_dma_rsp_out_data_dest_id     => llc_dma_rsp_out_data_dest_id,\n")
    f.write("      llc_dma_rsp_out_data_word_offset => llc_dma_rsp_out_data_word_offset,\n")
    f.write("      llc_dma_rsp_out_data_word_mask   => llc_dma_rsp_out_data_word_mask,\n")
    f.write("      llc_fwd_out_valid            => llc_fwd_out_valid,\n")
    f.write("      llc_fwd_out_data_coh_msg     => llc_fwd_out_data_coh_msg,\n")
    f.write("      llc_fwd_out_data_addr        => llc_fwd_out_data_addr,\n")
    f.write("      llc_fwd_out_data_req_id      => llc_fwd_out_data_req_id,\n")
    f.write("      llc_fwd_out_data_dest_id     => llc_fwd_out_data_dest_id,\n")
    f.write("      llc_fwd_out_data_word_mask   => llc_fwd_out_data_word_mask,\n")
    f.write("      llc_fwd_out_data_line        => llc_fwd_out_data_line,\n")
    f.write("      llc_mem_req_valid            => llc_mem_req_valid,\n")
    f.write("      llc_mem_req_data_hwrite      => llc_mem_req_data_hwrite,\n")
    f.write("      llc_mem_req_data_hsize       => llc_mem_req_data_hsize,\n")
    f.write("      llc_mem_req_data_hprot       => llc_mem_req_data_hprot,\n")
    f.write("      llc_mem_req_data_addr        => llc_mem_req_data_addr,\n")
    f.write("      llc_mem_req_data_line        => llc_mem_req_data_line,\n")
    f.write("      llc_stats_valid              => llc_stats_valid,\n")
    f.write("      llc_stats_data               => llc_stats_data,\n")
    f.write("      llc_rst_tb_done_valid        => llc_rst_tb_done_valid,\n")
    f.write("      llc_rst_tb_done_data         => llc_rst_tb_done_data\n")
  elif is_llc and 'spandex' not in cac.name:
    f.write("      clk                          => clk,\n")
    f.write("      rst                          => rst,\n")
    f.write("      llc_req_in_valid             => llc_req_in_valid,\n")
    f.write("      llc_req_in_data_coh_msg      => llc_req_in_data_coh_msg,\n")
    f.write("      llc_req_in_data_hprot        => llc_req_in_data_hprot,\n")
    f.write("      llc_req_in_data_addr         => llc_req_in_data_addr,\n")
    f.write("      llc_req_in_data_word_offset  => llc_req_in_data_word_offset,\n")
    f.write("      llc_req_in_data_valid_words  => llc_req_in_data_valid_words,\n")
    f.write("      llc_req_in_data_line         => llc_req_in_data_line,\n")
    f.write("      llc_req_in_data_req_id       => llc_req_in_data_req_id,\n")
    f.write("      llc_dma_req_in_valid             => llc_dma_req_in_valid,\n")
    f.write("      llc_dma_req_in_data_coh_msg      => llc_dma_req_in_data_coh_msg,\n")
    f.write("      llc_dma_req_in_data_hprot        => llc_dma_req_in_data_hprot,\n")
    f.write("      llc_dma_req_in_data_addr         => llc_dma_req_in_data_addr,\n")
    f.write("      llc_dma_req_in_data_word_offset  => llc_dma_req_in_data_word_offset,\n")
    f.write("      llc_dma_req_in_data_valid_words  => llc_dma_req_in_data_valid_words,\n")
    f.write("      llc_dma_req_in_data_line         => llc_dma_req_in_data_line,\n")
    f.write("      llc_dma_req_in_data_req_id       => llc_dma_req_in_data_req_id,\n")
    f.write("      llc_rsp_in_valid             => llc_rsp_in_valid,\n")
    f.write("      llc_rsp_in_data_coh_msg      => llc_rsp_in_data_coh_msg,\n")
    f.write("      llc_rsp_in_data_addr         => llc_rsp_in_data_addr,\n")
    f.write("      llc_rsp_in_data_line         => llc_rsp_in_data_line,\n")
    f.write("      llc_rsp_in_data_req_id       => llc_rsp_in_data_req_id,\n")
    f.write("      llc_mem_rsp_valid            => llc_mem_rsp_valid,\n")
    f.write("      llc_mem_rsp_data_line        => llc_mem_rsp_data_line,\n")
    f.write("      llc_rst_tb_valid             => llc_rst_tb_valid,\n")
    f.write("      llc_rst_tb_data              => llc_rst_tb_data,\n")
    f.write("      llc_rsp_out_ready            => llc_rsp_out_ready,\n")
    f.write("      llc_dma_rsp_out_ready            => llc_dma_rsp_out_ready,\n")
    f.write("      llc_fwd_out_ready            => llc_fwd_out_ready,\n")
    f.write("      llc_mem_req_ready            => llc_mem_req_ready,\n")
    f.write("      llc_rst_tb_done_ready        => llc_rst_tb_done_ready,\n")
    f.write("      llc_stats_ready              => llc_stats_ready,\n")
    f.write("      llc_req_in_ready             => llc_req_in_ready,\n")
    f.write("      llc_dma_req_in_ready             => llc_dma_req_in_ready,\n")
    f.write("      llc_rsp_in_ready             => llc_rsp_in_ready,\n")
    f.write("      llc_mem_rsp_ready            => llc_mem_rsp_ready,\n")
    f.write("      llc_rst_tb_ready             => llc_rst_tb_ready,\n")
    f.write("      llc_rsp_out_valid            => llc_rsp_out_valid,\n")
    f.write("      llc_rsp_out_data_coh_msg     => llc_rsp_out_data_coh_msg,\n")
    f.write("      llc_rsp_out_data_addr        => llc_rsp_out_data_addr,\n")
    f.write("      llc_rsp_out_data_line        => llc_rsp_out_data_line,\n")
    f.write("      llc_rsp_out_data_invack_cnt  => llc_rsp_out_data_invack_cnt,\n")
    f.write("      llc_rsp_out_data_req_id      => llc_rsp_out_data_req_id,\n")
    f.write("      llc_rsp_out_data_dest_id     => llc_rsp_out_data_dest_id,\n")
    f.write("      llc_rsp_out_data_word_offset => llc_rsp_out_data_word_offset,\n")
    f.write("      llc_dma_rsp_out_valid            => llc_dma_rsp_out_valid,\n")
    f.write("      llc_dma_rsp_out_data_coh_msg     => llc_dma_rsp_out_data_coh_msg,\n")
    f.write("      llc_dma_rsp_out_data_addr        => llc_dma_rsp_out_data_addr,\n")
    f.write("      llc_dma_rsp_out_data_line        => llc_dma_rsp_out_data_line,\n")
    f.write("      llc_dma_rsp_out_data_invack_cnt  => llc_dma_rsp_out_data_invack_cnt,\n")
    f.write("      llc_dma_rsp_out_data_req_id      => llc_dma_rsp_out_data_req_id,\n")
    f.write("      llc_dma_rsp_out_data_dest_id     => llc_dma_rsp_out_data_dest_id,\n")
    f.write("      llc_dma_rsp_out_data_word_offset => llc_dma_rsp_out_data_word_offset,\n")
    f.write("      llc_fwd_out_valid            => llc_fwd_out_valid,\n")
    f.write("      llc_fwd_out_data_coh_msg     => llc_fwd_out_data_coh_msg,\n")
    f.write("      llc_fwd_out_data_addr        => llc_fwd_out_data_addr,\n")
    f.write("      llc_fwd_out_data_req_id      => llc_fwd_out_data_req_id,\n")
    f.write("      llc_fwd_out_data_dest_id     => llc_fwd_out_data_dest_id,\n")
    f.write("      llc_mem_req_valid            => llc_mem_req_valid,\n")
    f.write("      llc_mem_req_data_hwrite      => llc_mem_req_data_hwrite,\n")
    f.write("      llc_mem_req_data_hsize       => llc_mem_req_data_hsize,\n")
    f.write("      llc_mem_req_data_hprot       => llc_mem_req_data_hprot,\n")
    f.write("      llc_mem_req_data_addr        => llc_mem_req_data_addr,\n")
    f.write("      llc_mem_req_data_line        => llc_mem_req_data_line,\n")
    f.write("      llc_stats_valid              => llc_stats_valid,\n")
    f.write("      llc_stats_data               => llc_stats_data,\n")
    f.write("      llc_rst_tb_done_valid        => llc_rst_tb_done_valid,\n")
    f.write("      llc_rst_tb_done_data         => llc_rst_tb_done_data\n")
  elif not is_llc and 'spandex' in cac.name:
    f.write("      clk                       => clk,\n")
    f.write("      rst                       => rst,\n")
    f.write("      l2_cpu_req_valid          => l2_cpu_req_valid,\n")
    f.write("      l2_cpu_req_data_cpu_msg   => l2_cpu_req_data_cpu_msg,\n")
    f.write("      l2_cpu_req_data_hsize     => l2_cpu_req_data_hsize,\n")
    f.write("      l2_cpu_req_data_hprot     => l2_cpu_req_data_hprot,\n")
    f.write("      l2_cpu_req_data_addr      => l2_cpu_req_data_addr,\n")
    f.write("      l2_cpu_req_data_word      => l2_cpu_req_data_word,\n")
    f.write("      l2_cpu_req_data_amo       => l2_cpu_req_data_amo,\n")
    f.write("      l2_cpu_req_data_aq        => l2_cpu_req_data_aq,\n")
    f.write("      l2_cpu_req_data_rl        => l2_cpu_req_data_rl,\n")
    f.write("      l2_cpu_req_data_dcs_en    => l2_cpu_req_data_dcs_en,\n")
    f.write("      l2_cpu_req_data_use_owner_pred => l2_cpu_req_data_use_owner_pred,\n")
    f.write("      l2_cpu_req_data_dcs       => l2_cpu_req_data_dcs,\n")
    f.write("      l2_cpu_req_data_pred_cid  => l2_cpu_req_data_pred_cid,\n")
    f.write("      l2_fwd_in_valid           => l2_fwd_in_valid,\n")
    f.write("      l2_fwd_in_data_coh_msg    => l2_fwd_in_data_coh_msg,\n")
    f.write("      l2_fwd_in_data_addr       => l2_fwd_in_data_addr,\n")
    f.write("      l2_fwd_in_data_req_id     => l2_fwd_in_data_req_id,\n")
    f.write("      l2_fwd_in_data_word_mask  => l2_fwd_in_data_word_mask,\n")
    f.write("      l2_fwd_in_data_line       => l2_fwd_in_data_line,\n")
    f.write("      l2_rsp_in_valid           => l2_rsp_in_valid,\n")
    f.write("      l2_rsp_in_data_coh_msg    => l2_rsp_in_data_coh_msg,\n")
    f.write("      l2_rsp_in_data_addr       => l2_rsp_in_data_addr,\n")
    f.write("      l2_rsp_in_data_line       => l2_rsp_in_data_line,\n")
    f.write("      l2_rsp_in_data_invack_cnt => l2_rsp_in_data_invack_cnt,\n")
    f.write("      l2_rsp_in_data_word_mask  => l2_rsp_in_data_word_mask,\n")
    f.write("      l2_flush_valid            => l2_flush_valid,\n")
    f.write("      l2_flush_data             => l2_flush_data,\n")
    f.write("      l2_rd_rsp_ready           => l2_rd_rsp_ready,\n")
    f.write("      l2_inval_ready            => l2_inval_ready,\n")
    f.write("      l2_bresp_ready            => l2_bresp_ready,\n")
    f.write("      l2_req_out_ready          => l2_req_out_ready,\n")
    f.write("      l2_rsp_out_ready          => l2_rsp_out_ready,\n")
    f.write("      l2_fwd_out_ready          => l2_rsp_out_ready,\n")
    f.write("      l2_stats_ready            => l2_stats_ready,\n")
    f.write("      flush_done                => flush_done,\n")
    f.write("      l2_cpu_req_ready          => l2_cpu_req_ready,\n")
    f.write("      l2_fwd_in_ready           => l2_fwd_in_ready,\n")
    f.write("      l2_rsp_in_ready           => l2_rsp_in_ready,\n")
    f.write("      l2_flush_ready            => l2_flush_ready,\n")
    f.write("      l2_rd_rsp_valid           => l2_rd_rsp_valid,\n")
    f.write("      l2_rd_rsp_data_line       => l2_rd_rsp_data_line,\n")
    f.write("      l2_inval_valid            => l2_inval_valid,\n")
    f.write("      l2_inval_data             => l2_inval_data,\n")
    f.write("      l2_bresp_valid            => l2_bresp_valid,\n")
    f.write("      l2_bresp_data             => l2_bresp_data,\n")
    f.write("      l2_req_out_valid          => l2_req_out_valid,\n")
    f.write("      l2_req_out_data_coh_msg   => l2_req_out_data_coh_msg,\n")
    f.write("      l2_req_out_data_hprot     => l2_req_out_data_hprot,\n")
    f.write("      l2_req_out_data_addr      => l2_req_out_data_addr,\n")
    f.write("      l2_req_out_data_line      => l2_req_out_data_line,\n")
    f.write("      l2_req_out_data_word_mask => l2_req_out_data_word_mask,\n")
    f.write("      l2_rsp_out_valid          => l2_rsp_out_valid,\n")
    f.write("      l2_rsp_out_data_coh_msg   => l2_rsp_out_data_coh_msg,\n")
    f.write("      l2_rsp_out_data_req_id    => l2_rsp_out_data_req_id,\n")
    f.write("      l2_rsp_out_data_to_req    => l2_rsp_out_data_to_req,\n")
    f.write("      l2_rsp_out_data_addr      => l2_rsp_out_data_addr,\n")
    f.write("      l2_rsp_out_data_line      => l2_rsp_out_data_line,\n")
    f.write("      l2_rsp_out_data_word_mask => l2_rsp_out_data_word_mask,\n")
    f.write("      l2_fwd_out_valid          => l2_fwd_out_valid,\n")
    f.write("      l2_fwd_out_data_coh_msg   => l2_fwd_out_data_coh_msg,\n")
    f.write("      l2_fwd_out_data_req_id    => l2_fwd_out_data_req_id,\n")
    f.write("      l2_fwd_out_data_to_req    => l2_fwd_out_data_to_req,\n")
    f.write("      l2_fwd_out_data_addr      => l2_fwd_out_data_addr,\n")
    f.write("      l2_fwd_out_data_line      => l2_fwd_out_data_line,\n")
    f.write("      l2_fwd_out_data_word_mask => l2_fwd_out_data_word_mask,\n")
    f.write("      l2_stats_valid            => l2_stats_valid,\n")
    f.write("      l2_stats_data             => l2_stats_data,\n")
    f.write("      l2_fence_ready            => l2_fence_ready,\n")
    f.write("      l2_fence_valid            => l2_fence_valid,\n")
    f.write("      l2_fence_data             => l2_fence_data\n")
  elif not is_llc and 'spandex' not in cac.name:
    f.write("      clk                       => clk,\n")
    f.write("      rst                       => rst,\n")
    f.write("      l2_cpu_req_valid          => l2_cpu_req_valid,\n")
    f.write("      l2_cpu_req_data_cpu_msg   => l2_cpu_req_data_cpu_msg,\n")
    f.write("      l2_cpu_req_data_hsize     => l2_cpu_req_data_hsize,\n")
    f.write("      l2_cpu_req_data_hprot     => l2_cpu_req_data_hprot,\n")
    f.write("      l2_cpu_req_data_addr      => l2_cpu_req_data_addr,\n")
    f.write("      l2_cpu_req_data_word      => l2_cpu_req_data_word,\n")
    f.write("      l2_cpu_req_data_amo       => l2_cpu_req_data_amo,\n")
    f.write("      l2_fwd_in_valid           => l2_fwd_in_valid,\n")
    f.write("      l2_fwd_in_data_coh_msg    => l2_fwd_in_data_coh_msg,\n")
    f.write("      l2_fwd_in_data_addr       => l2_fwd_in_data_addr,\n")
    f.write("      l2_fwd_in_data_req_id     => l2_fwd_in_data_req_id,\n")
    f.write("      l2_rsp_in_valid           => l2_rsp_in_valid,\n")
    f.write("      l2_rsp_in_data_coh_msg    => l2_rsp_in_data_coh_msg,\n")
    f.write("      l2_rsp_in_data_addr       => l2_rsp_in_data_addr,\n")
    f.write("      l2_rsp_in_data_line       => l2_rsp_in_data_line,\n")
    f.write("      l2_rsp_in_data_invack_cnt => l2_rsp_in_data_invack_cnt,\n")
    f.write("      l2_flush_valid            => l2_flush_valid,\n")
    f.write("      l2_flush_data             => l2_flush_data,\n")
    f.write("      l2_rd_rsp_ready           => l2_rd_rsp_ready,\n")
    f.write("      l2_inval_ready            => l2_inval_ready,\n")
    f.write("      l2_bresp_ready            => l2_bresp_ready,\n")
    f.write("      l2_req_out_ready          => l2_req_out_ready,\n")
    f.write("      l2_rsp_out_ready          => l2_rsp_out_ready,\n")
    f.write("      l2_stats_ready            => l2_stats_ready,\n")
    f.write("      flush_done                => flush_done,\n")
    f.write("      l2_cpu_req_ready          => l2_cpu_req_ready,\n")
    f.write("      l2_fwd_in_ready           => l2_fwd_in_ready,\n")
    f.write("      l2_rsp_in_ready           => l2_rsp_in_ready,\n")
    f.write("      l2_flush_ready            => l2_flush_ready,\n")
    f.write("      l2_rd_rsp_valid           => l2_rd_rsp_valid,\n")
    f.write("      l2_rd_rsp_data_line       => l2_rd_rsp_data_line,\n")
    f.write("      l2_inval_valid            => l2_inval_valid,\n")
    f.write("      l2_inval_data_addr        => l2_inval_data_addr,\n")
    f.write("      l2_inval_data_hprot       => l2_inval_data_hprot,\n")
    f.write("      l2_bresp_valid            => l2_bresp_valid,\n")
    f.write("      l2_bresp_data             => l2_bresp_data,\n")
    f.write("      l2_req_out_valid          => l2_req_out_valid,\n")
    f.write("      l2_req_out_data_coh_msg   => l2_req_out_data_coh_msg,\n")
    f.write("      l2_req_out_data_hprot     => l2_req_out_data_hprot,\n")
    f.write("      l2_req_out_data_addr      => l2_req_out_data_addr,\n")
    f.write("      l2_req_out_data_line      => l2_req_out_data_line,\n")
    f.write("      l2_rsp_out_valid          => l2_rsp_out_valid,\n")
    f.write("      l2_rsp_out_data_coh_msg   => l2_rsp_out_data_coh_msg,\n")
    f.write("      l2_rsp_out_data_req_id    => l2_rsp_out_data_req_id,\n")
    f.write("      l2_rsp_out_data_to_req    => l2_rsp_out_data_to_req,\n")
    f.write("      l2_rsp_out_data_addr      => l2_rsp_out_data_addr,\n")
    f.write("      l2_rsp_out_data_line      => l2_rsp_out_data_line,\n")
    f.write("      l2_stats_valid            => l2_stats_valid,\n")
    f.write("      l2_stats_data             => l2_stats_data\n")
  f.write("    );\n")


# Component declaration matching HLS-generated verilog
def gen_tech_dep(accelerator_list, cache_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/allacc.vhd', 'w')
  with open(template_dir + '/allacc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerators-components>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
        for impl in acc.hlscfg:
          f.write("\n")
          if acc.hls_tool == 'stratus_hls' or acc.hls_tool == 'rtl':
            f.write("  component " + acc.name + "_" + impl.name + "\n")
            f.write("    port (\n")
            write_acc_interface(f, acc, dma_width, impl.datatype, "rst", False, False, False)
          elif acc.hls_tool == 'catapult_hls_cxx':
            f.write("  component " + acc.name + "_" + impl.name + "\n")
            f.write("    port (\n")
            write_acc_interface(f, acc, dma_width, impl.datatype, "rst", False, True, False)
          elif acc.hls_tool == 'catapult_hls_sysc':
            f.write("  component " + acc.name + "_" + impl.name + "\n")
            f.write("    port (\n")
            write_acc_interface(f, acc, dma_width, impl.datatype, "rst", False, False, True)
          else:
            f.write("  component " + acc.name + "_" + impl.name + "_top\n")
            f.write("    port (\n")
            write_acc_interface(f, acc, dma_width, impl.datatype, "ap_rst", True, False, False)
          f.write("    );\n")
          f.write("  end component;\n\n")
          f.write("\n")
  f.close()
  ftemplate.close()
  f = open(out_dir + '/allcaches.vhd', 'w')
  with open(template_dir + '/allcaches.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<caches-components>>") < 0:
        f.write(tline)
        continue
      for cac in cache_list:
        is_llc = "llc" in cac.name
        for impl in cac.hlscfg:
          f.write("\n")
          f.write("  component " + cac.name + "_" + impl + "\n")
          f.write("    port (\n")
          write_cache_interface(f, cac, is_llc)
          f.write("    );\n")
          f.write("  end component;\n\n")
          f.write("\n")
  f.close()
  ftemplate.close()


# Component declaration independent from technology and implementation
def gen_tech_indep(accelerator_list, axi_accelerator_list, cache_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/genacc.vhd', 'w')
  with open(template_dir + '/genacc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerators-components>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
        f.write("\n")
        f.write("  component " + acc.name + "_rtl\n")
        f.write("    generic (\n")
        f.write("      hls_conf  : hlscfg_t\n")
        f.write("    );\n")
        f.write("\n")
        f.write("    port (\n")
        write_acc_interface(f, acc, dma_width, "", "acc_rst", False, False, False)
        f.write("    );\n")
        f.write("  end component;\n\n")
        f.write("\n")
      for acc in axi_accelerator_list:
        f.write("\n")
        f.write("  component " + acc.name + "_wrapper\n")
        f.write("    port (\n")
        write_axi_acc_interface(f, acc, dma_width)
        f.write("    );\n")
        f.write("  end component;\n\n")
        f.write("\n")
  f.close()
  ftemplate.close()
  # f = open(out_dir + '/gencaches.vhd', 'w')
  # with open(template_dir + '/gencaches.vhd', 'r') as ftemplate:
  #   for tline in ftemplate:
  #     if tline.find("-- <<caches-components>>") < 0:
  #       f.write(tline)
  #       continue
  #     for cac in cache_list:
  #       is_llc = cac.name == "llc"
  #       f.write("\n")
  #       f.write("  component " + cac.name + "\n")
  #       f.write("    generic (\n")
  #       f.write("      sets  : integer;\n")
  #       f.write("      ways  : integer\n")
  #       f.write("    );\n")
  #       f.write("\n")
  #       f.write("    port (\n")
  #       write_cache_interface(f, cac, is_llc)
  #       f.write("    );\n")
  #       f.write("  end component;\n\n")
  #       f.write("\n")
  # f.close()
  # ftemplate.close()


# Mapping from generic components to technology and implementation dependent ones
def gen_tech_indep_impl(accelerator_list, cache_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/accelerators.vhd', 'w')
  with open(template_dir + '/accelerators.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerators-entities>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
        if acc.hls_tool == 'catapult_hls_cxx':
          f.write("library ieee;\n")
          f.write("use ieee.std_logic_1164.all;\n")
          f.write("use work.sld_devices.all;\n")
          f.write("use work.allacc.all;\n")
          f.write("\n")
          f.write("entity " + acc.name + "_rtl is\n\n")
          f.write("    generic (\n")
          f.write("      hls_conf  : hlscfg_t\n")
          f.write("    );\n")
          f.write("\n")
          f.write("    port (\n")
          write_acc_interface(f, acc, dma_width, "", "acc_rst", False, False, False)
          f.write("    );\n")
          f.write("\n")
          f.write("end entity " + acc.name + "_rtl;\n\n")
          f.write("\n")
          f.write("architecture mapping of " + acc.name + "_rtl is\n\n")
          f.write("\n")
          f.write("-- signals for conf_done fsm\n")
          f.write("\n")
          f.write("type rsc_state_t is (rsc_idle, rsc_handshake);\n")
          f.write("signal rsc_state, rsc_state_next : rsc_state_t;\n")
          f.write("\n")
          f.write("signal conf_info_rsc_valid : std_ulogic;\n")
          f.write("signal conf_info_rsc_ready : std_ulogic;\n")
          f.write("\n")
          f.write("\n")
          f.write("begin  -- mapping\n\n")
          for impl in acc.hlscfg:
            f.write("\n")
            f.write("  impl_" + impl.name + "_gen: if hls_conf = HLSCFG_" + acc.name.upper() + "_" + impl.name.upper() + " generate\n")
            f.write("    " + acc.name + "_" + impl.name + "_i: " + acc.name + "_" + impl.name + "\n")
            write_acc_port_map(f, acc, dma_width, impl.datatype, "rst", False, False, True, False)
            f.write("\n\n")
            f.write("  -- CONF_DONE FSM\n")
            f.write("\n")
            f.write("  conf_done_fsm: process (rsc_state, conf_done, conf_info_rsc_ready) is\n")
            f.write("  begin  -- process conf_done_fsm\n")
            f.write("    rsc_state_next <= rsc_state;\n")
            f.write("    conf_info_rsc_valid <= '0';\n")
            f.write("\n")
            f.write("    case rsc_state is\n")
            f.write("\n")
            f.write("      when rsc_idle =>\n")
            f.write("        if conf_done = '1' then\n")
            f.write("          rsc_state_next <= rsc_handshake;\n")
            f.write("        end if;\n")
            f.write("\n")
            f.write("      when rsc_handshake =>\n")
            f.write("        conf_info_rsc_valid <= '1';\n")
            f.write("        if conf_info_rsc_ready = '1' then\n")
            f.write("          rsc_state_next <= rsc_idle;\n")
            f.write("        end if;\n")
            f.write("\n")
            f.write("      when others =>\n")
            f.write("        rsc_state_next <= rsc_idle;\n")
            f.write("\n")
            f.write("    end case;\n")
            f.write("  end process conf_done_fsm;\n")
            f.write("\n")
            f.write("  conf_done_state_update: process (clk, acc_rst) is\n")
            f.write("  begin  -- process conf_done_state_update\n")
            f.write("    if clk'event and clk = '1' then    -- rising clock edge\n")
            f.write("      if acc_rst = '0' then            -- synchronous active low\n")
            f.write("        rsc_state <= rsc_idle;\n")
            f.write("      else\n")
            f.write("        rsc_state <= rsc_state_next;\n")
            f.write("      end if;\n")
            f.write("    end if;\n")
            f.write("  end process conf_done_state_update;\n")
            f.write("\n")
            f.write("  end generate impl_" +  impl.name + "_gen;\n\n")
          f.write("end mapping;\n\n")
        elif acc.hls_tool == 'catapult_hls_sysc':
          f.write("library ieee;\n")
          f.write("use ieee.std_logic_1164.all;\n")
          f.write("use work.sld_devices.all;\n")
          f.write("use work.allacc.all;\n")
          f.write("\n")
          f.write("entity " + acc.name + "_rtl is\n\n")
          f.write("    generic (\n")
          f.write("      hls_conf  : hlscfg_t\n")
          f.write("    );\n")
          f.write("\n")
          f.write("    port (\n")
          write_acc_interface(f, acc, dma_width, "", "acc_rst", False, False, False)
          f.write("    );\n")
          f.write("\n")
          f.write("end entity " + acc.name + "_rtl;\n\n")
          f.write("\n")
          f.write("architecture mapping of " + acc.name + "_rtl is\n\n")
          f.write("\n")
          f.write("-- signals for conf_done fsm\n")
          f.write("\n")
          f.write("type rsc_state_t is (rsc_idle, rsc_handshake);\n")
          f.write("signal rsc_state, rsc_state_next : rsc_state_t;\n")
          f.write("\n")
          f.write("signal conf_info_rsc_valid : std_ulogic;\n")
          f.write("signal conf_info_rsc_ready : std_ulogic;\n")
          f.write("\n")
          f.write("\n")
          f.write("begin  -- mapping\n\n")
          for impl in acc.hlscfg:
            f.write("\n")
            f.write("  impl_" + impl.name + "_gen: if hls_conf = HLSCFG_" + acc.name.upper() + "_" + impl.name.upper() + " generate\n")
            f.write("    " + acc.name + "_" + impl.name + "_i: " + acc.name + "_" + impl.name + "\n")
            write_acc_port_map(f, acc, dma_width, impl.datatype, "rst", False, False, False, True)
            f.write("\n\n")
            f.write("  -- CONF_DONE FSM\n")
            f.write("\n")
            f.write("  conf_done_fsm: process (rsc_state, conf_done, conf_info_rsc_ready) is\n")
            f.write("  begin  -- process conf_done_fsm\n")
            f.write("    rsc_state_next <= rsc_state;\n")
            f.write("    conf_info_rsc_valid <= '0';\n")
            f.write("\n")
            f.write("    case rsc_state is\n")
            f.write("\n")
            f.write("      when rsc_idle =>\n")
            f.write("        if conf_done = '1' then\n")
            f.write("          rsc_state_next <= rsc_handshake;\n")
            f.write("        end if;\n")
            f.write("\n")
            f.write("      when rsc_handshake =>\n")
            f.write("        conf_info_rsc_valid <= '1';\n")
            f.write("        if conf_info_rsc_ready = '1' then\n")
            f.write("          rsc_state_next <= rsc_idle;\n")
            f.write("        end if;\n")
            f.write("\n")
            f.write("      when others =>\n")
            f.write("        rsc_state_next <= rsc_idle;\n")
            f.write("\n")
            f.write("    end case;\n")
            f.write("  end process conf_done_fsm;\n")
            f.write("\n")
            f.write("  conf_done_state_update: process (clk, acc_rst) is\n")
            f.write("  begin  -- process conf_done_state_update\n")
            f.write("    if clk'event and clk = '1' then    -- rising clock edge\n")
            f.write("      if acc_rst = '0' then            -- synchronous active low\n")
            f.write("        rsc_state <= rsc_idle;\n")
            f.write("      else\n")
            f.write("        rsc_state <= rsc_state_next;\n")
            f.write("      end if;\n")
            f.write("    end if;\n")
            f.write("  end process conf_done_state_update;\n")
            f.write("\n")
            f.write("  end generate impl_" +  impl.name + "_gen;\n\n")
          f.write("end mapping;\n\n")

        else:
          f.write("library ieee;\n")
          f.write("use ieee.std_logic_1164.all;\n")
          f.write("use work.sld_devices.all;\n")
          f.write("use work.allacc.all;\n")
          f.write("\n")
          f.write("entity " + acc.name + "_rtl is\n\n")
          f.write("    generic (\n")
          f.write("      hls_conf  : hlscfg_t\n")
          f.write("    );\n")
          f.write("\n")
          f.write("    port (\n")
          write_acc_interface(f, acc, dma_width, "", "acc_rst", False, False, False)
          f.write("    );\n")
          f.write("\n")
          f.write("end entity " + acc.name + "_rtl;\n\n")
          f.write("\n")
          f.write("architecture mapping of " + acc.name + "_rtl is\n\n")
          if acc.hls_tool == 'vivado_hls':
            write_ap_acc_signals(f)
          f.write("begin  -- mapping\n\n")
          for impl in acc.hlscfg:
            f.write("\n")
            f.write("  impl_" + impl.name + "_gen: if hls_conf = HLSCFG_" + acc.name.upper() + "_" + impl.name.upper() + " generate\n")
            if acc.hls_tool == 'stratus_hls' or acc.hls_tool == 'rtl':
              f.write("    " + acc.name + "_" + impl.name + "_i: " + acc.name + "_" + impl.name + "\n")
              write_acc_port_map(f, acc, dma_width, impl.datatype, "rst", False, False, False, False)
            else:
              f.write("    " + acc.name + "_" + impl.name + "_top_i: " + acc.name + "_" + impl.name + "_top\n")
              write_acc_port_map(f, acc, dma_width, impl.datatype, "rst", False, True, False, False)
            f.write("  end generate impl_" +  impl.name + "_gen;\n\n")
          f.write("end mapping;\n\n")
  f.close()
  ftemplate.close()
  f = open(out_dir + '/caches.vhd', 'w')
  with open(template_dir + '/caches.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<caches-entities>>") < 0:
        f.write(tline)
        continue
      for cac in cache_list:
        is_llc = "llc" in cac.name
        f.write("library ieee;\n")
        f.write("use ieee.std_logic_1164.all;\n")
        f.write("use work.sld_devices.all;\n")
        f.write("use work.allcaches.all;\n")
        f.write("\n")
        f.write("entity " + cac.name + " is\n\n")
        f.write("    generic (\n")
        f.write("      use_rtl          : integer;\n")
        if (not is_llc):
          f.write("      little_end       : integer range 0 to 1;\n")
          if 'spandex' not in cac.name:
            f.write("      llsc             : integer range 0 to 1;\n")
        f.write("      sets             : integer;\n")
        f.write("      ways             : integer\n")
        f.write("    );\n")
        f.write("\n")
        f.write("    port (\n")
        write_cache_interface(f, cac, is_llc)
        f.write("    );\n")
        f.write("\n")
        f.write("end entity " + cac.name + ";\n\n")
        f.write("\n")
        f.write("architecture mapping of " + cac.name + " is\n\n")
        f.write("begin  -- mapping\n\n")
        if 'spandex' in cac.name:
          pass
        else:
          f.write("  rtl_gen: if use_rtl /= 0 generate\n")
          f.write("    " + cac.name + "_rtl_top_i: " + cac.name + "_rtl_top\n")
          write_cache_port_map(f, cac, is_llc)
          f.write("  end generate rtl_gen;\n\n")
        f.write("\n")
        f.write("  hls_gen: if use_rtl = 0 generate\n")
        for impl in cac.hlscfg:
          info = re.split('_|x', impl)
          sets = 0
          ways = 0
          this_addr_bits = 0
          this_word_offset_bits = 0
          this_offset_bits = 0
          this_llsc = 0
          this_endian = "le"
          for item in info:
            if re.match(r'[0-9]+sets', item, re.M|re.I):
              sets = int(item.replace("sets", ""))
            elif re.match(r'[0-9]+ways', item, re.M|re.I):
              ways = int(item.replace("ways", ""))
            elif re.match(r'[0-9]+$', item, re.M|re.I):
              this_word_offset_bits = int(math.log2(int(item)))
            elif re.match(r'[0-9]+line', item, re.M|re.I):
              this_offset_bits = int(int(math.log2((int(item.replace("line", "")))/8) + word_offset_bits))
            elif re.match(r'[0-9]+addr', item, re.M|re.I):
              this_addr_bits = int(item.replace("addr", ""))
            elif re.match(r'(no)?llsc', item, re.M|re.I):
              if item == "llsc":
                this_llsc = 1
              else:
                this_llsc = 0
            elif re.match(r'[b|l]e', item, re.M|re.I):
              if item == "le":
                this_endian = 1
              else:
                this_endian = 0
          if is_llc:
            this_endian = little_endian
          if sets * ways == 0:
            print("    ERROR: hls config must report number of sets and ways, both different from zero")
            sys.exit(1)
          if this_word_offset_bits != word_offset_bits or this_offset_bits != offset_bits or this_addr_bits != phys_addr_bits or this_endian != little_endian:
            print("    INFO: skipping cache implementation " + impl + " incompatible with SoC architecture")
            continue
          f.write("\n")
          if is_llc:
            f.write("  " + impl + "_gen: if sets = " + str(sets) + " and ways = " + str(ways) + " generate\n")
          elif 'spandex' in cac.name:
            f.write("  " + impl + "_gen: if little_end = " + str(this_endian) + " and sets = " + str(sets) + " and ways = " + str(ways) + " generate\n")
          else:
            f.write("  " + impl + "_gen: if little_end = " + str(this_endian) + " and llsc = " + str(this_llsc) + " and sets = " + str(sets) + " and ways = " + str(ways) + " generate\n")
          f.write("    " + cac.name + "_" + impl + "_i: " + cac.name + "_" + impl + "\n")
          write_cache_port_map(f, cac, is_llc)
          f.write("  end generate " +  impl + "_gen;\n\n")
        f.write("  end generate hls_gen;\n\n")
        f.write("end mapping;\n\n")
  f.close()
  ftemplate.close()


# Component declaration of NoC wrappers
def gen_interfaces(accelerator_list, axi_accelerator_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/sldacc.vhd', 'w')
  with open(template_dir + '/sldacc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<wrappers-components>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list + axi_accelerator_list:
        f.write("\n")
        f.write("  component noc_" + acc.name + "\n")
        f.write("    generic (\n")
        f.write("      hls_conf       : hlscfg_t;\n")
        f.write("      tech           : integer;\n")
        f.write("      mem_num        : integer;\n")
        f.write("      cacheable_mem_num : integer;\n")
        f.write("      mem_info       : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE);\n")
        f.write("      io_y           : local_yx;\n")
        f.write("      io_x           : local_yx;\n")
        f.write("      pindex         : integer;\n")
        f.write("      irq_type       : integer := 0;\n")
        f.write("      scatter_gather : integer := 1;\n")
        f.write("      sets           : integer;\n")
        f.write("      ways           : integer;\n")
        f.write("      little_end     : integer range 0 to 1;\n")
        f.write("      cache_tile_id  : cache_attribute_array;\n")
        f.write("      cache_y        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);\n")
        f.write("      cache_x        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);\n")
        f.write("      has_l2         : integer := 1;\n")
        f.write("      has_dvfs       : integer := 1;\n")
        f.write("      has_pll        : integer;\n")
        f.write("      extra_clk_buf  : integer\n")
        f.write("    );\n")
        f.write("\n")
        f.write("    port (\n")
        f.write("      rst               : in  std_ulogic;\n")
        f.write("      clk               : in  std_ulogic;\n")
        f.write("      local_y           : in  local_yx;\n")
        f.write("      local_x           : in  local_yx;\n")
        f.write("      tile_id           : in  integer;\n")
        f.write("      paddr             : in  integer range 0 to 4095;\n")
        f.write("      pmask             : in  integer range 0 to 4095;\n")
        f.write("      paddr_ext         : in  integer range 0 to 4095;\n")
        f.write("      pmask_ext         : in  integer range 0 to 4095;\n")
        f.write("      pirq              : in  integer range 0 to NAHBIRQ - 1;\n")
        f.write("      apbi              : in apb_slv_in_type;\n")
        f.write("      apbo              : out apb_slv_out_type;\n")
        f.write("      pready            : out std_ulogic;\n")
        f.write("      coherence_req_wrreq        : out std_ulogic;\n")
        f.write("      coherence_req_data_in      : out noc_flit_type;\n")
        f.write("      coherence_req_full         : in  std_ulogic;\n")
        f.write("      coherence_fwd_rdreq        : out std_ulogic;\n")
        f.write("      coherence_fwd_data_out     : in  noc_flit_type;\n")
        f.write("      coherence_fwd_empty        : in  std_ulogic;\n")
        f.write("      coherence_rsp_rcv_rdreq    : out std_ulogic;\n")
        f.write("      coherence_rsp_rcv_data_out : in  noc_flit_type;\n")
        f.write("      coherence_rsp_rcv_empty    : in  std_ulogic;\n")
        f.write("      coherence_rsp_snd_wrreq    : out std_ulogic;\n")
        f.write("      coherence_rsp_snd_data_in  : out noc_flit_type;\n")
        f.write("      coherence_rsp_snd_full     : in  std_ulogic;\n")
        f.write("      coherence_fwd_snd_wrreq    : out std_ulogic;\n")
        f.write("      coherence_fwd_snd_data_in  : out noc_flit_type;\n")
        f.write("      coherence_fwd_snd_full     : in  std_ulogic;\n")
        f.write("      dma_rcv_rdreq     : out std_ulogic;\n")
        f.write("      dma_rcv_data_out  : in  noc_flit_type;\n")
        f.write("      dma_rcv_empty     : in  std_ulogic;\n")
        f.write("      dma_snd_wrreq     : out std_ulogic;\n")
        f.write("      dma_snd_data_in   : out noc_flit_type;\n")
        f.write("      dma_snd_full      : in  std_ulogic;\n")
        f.write("      coherent_dma_rcv_rdreq     : out std_ulogic;\n")
        f.write("      coherent_dma_rcv_data_out  : in  noc_flit_type;\n")
        f.write("      coherent_dma_rcv_empty     : in  std_ulogic;\n")
        f.write("      coherent_dma_snd_wrreq     : out std_ulogic;\n")
        f.write("      coherent_dma_snd_data_in   : out noc_flit_type;\n")
        f.write("      coherent_dma_snd_full      : in  std_ulogic;\n")
        f.write("      interrupt_wrreq   : out std_ulogic;\n")
        f.write("      interrupt_data_in : out misc_noc_flit_type;\n")
        f.write("      interrupt_full    : in  std_ulogic;\n")
        f.write("      interrupt_ack_rdreq    : out std_ulogic;\n")
        f.write("      interrupt_ack_data_out : in misc_noc_flit_type;\n")
        f.write("      interrupt_ack_empty    : in  std_ulogic;\n")
        f.write("      dvfs_transient_acc     : in  std_ulogic;\n")
        f.write("      mon_dvfs_in       : in  monitor_dvfs_type;\n")
        f.write("      mon_acc           : out monitor_acc_type;\n")
        f.write("      mon_cache         : out monitor_cache_type;\n")
        f.write("      mon_dvfs          : out monitor_dvfs_type;\n")
        f.write("      coherence         : in integer range 0 to 3);\n")
        f.write("  end component;\n\n")
        f.write("\n")
  f.close()
  ftemplate.close()


def gen_noc_interface(acc, dma_width, template_dir, out_dir, is_axi):
  f = open(out_dir + "/noc_" + acc.name + ".vhd", 'w')

  if not is_axi:
    extra_str = ""
  else:
    extra_str = "2axi"

  template_file = template_dir + '/noc' + extra_str + '_interface.vhd'

  with open(template_file, 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<entity>>") >= 0:
        f.write("entity noc" + "_" + acc.name + " is\n")
      elif tline.find("-- <<architecture>>") >= 0:
        f.write("architecture rtl of noc" + "_" + acc.name + " is\n")
      elif tline.find("-- <<devid>>") >= 0:
        f.write("  constant devid         : devid_t                := SLD_" + acc.name.upper() + ";\n")
      elif tline.find("-- <<tlb_entries>>") >= 0:
        f.write("  constant tlb_entries   : integer                := " + str(acc.data)  + ";\n")
      elif tline.find("-- <<user_registers>>") >= 0:
        for param in acc.param:
          f.write("  -- bank(" + str(param.reg) + "): " + param.desc + "\n")
          f.write("  constant " + acc.name.upper() + "_" + param.name.upper() + "_REG : integer range 0 to MAXREGNUM - 1 := " + str(param.reg) + ";\n\n")
      elif tline.find("-- <<user_read_only>>") >= 0:
        for param in acc.param:
          if param.readonly:
            f.write("    " + acc.name.upper() + "_" + param.name.upper() + "_REG" + (31 - len(acc.name) - len(param.name))*" " + "=> '1',\n")
      elif tline.find("-- <<user_mask>>") >= 0:
        for param in acc.param:
          f.write("    " + acc.name.upper() + "_" + param.name.upper() + "_REG" + (31 - len(acc.name) - len(param.name))*" " + "=> '1',\n")
      elif tline.find("-- <<user_read_only_default>>") >= 0:
        for param in acc.param:
          if param.readonly:
            f.write("    " + acc.name.upper() + "_" + param.name.upper() + "_REG" + (31 - len(acc.name) - len(param.name))*" " + "=> X\"" + format(param.value, '08x') + "\",\n")
      elif tline.find("-- <<axi_unused>>") >= 0:
        tie_unused_axi(f, acc, dma_width)
      elif tline.find("-- <<accelerator_instance>>") >= 0:
        f.write("  " + acc.name + "_rlt_i: " + acc.name)
        if is_axi:
          f.write("_wrapper\n")
          write_axi_acc_port_map(f, acc, dma_width)
        else:
          f.write("_rtl\n")
          f.write("    generic map (\n")
          f.write("      hls_conf => hls_conf\n")
          f.write("    )\n")
          write_acc_port_map(f, acc, dma_width, "", "acc_rst", True, False, False, False)
      else:
        f.write(tline)


def gen_tile_acc(accelerator_list, axi_acceleratorlist, template_dir, out_dir):
  f = open(out_dir + "/acc_top.vhd", 'w')
  with open(template_dir + '/acc_top.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerator-wrappers-gen>>") >= 0:
        for acc in accelerator_list + axi_accelerator_list:
          f.write("  " + acc.name + "_gen: if this_device = SLD_" + acc.name.upper() + " generate\n")
          f.write("    noc_" + acc.name + "_i: noc_" + acc.name + "\n")
          f.write("      generic map (\n")
          f.write("        hls_conf       => hls_conf,\n")
          f.write("        tech           => tech,\n")
          f.write("        mem_num        => mem_num,\n")
          f.write("        cacheable_mem_num => cacheable_mem_num,\n")
          f.write("        mem_info       => mem_info,\n")
          f.write("        io_y           => io_y,\n")
          f.write("        io_x           => io_x,\n")
          f.write("        pindex         => 1,\n")
          f.write("        irq_type       => irq_type,\n")
          f.write("        scatter_gather => scatter_gather,\n")
          f.write("        sets           => sets,\n")
          f.write("        ways           => ways,\n")
          f.write("        little_end     => little_end,\n")
          f.write("        cache_tile_id  => cache_tile_id,\n")
          f.write("        cache_y        => cache_y,\n")
          f.write("        cache_x        => cache_x,\n")
          f.write("        has_l2         => has_l2,\n")
          f.write("        has_dvfs       => has_dvfs,\n")
          f.write("        has_pll        => has_pll,\n")
          f.write("        extra_clk_buf  => extra_clk_buf)\n")
          f.write("      port map (\n")
          f.write("        rst               => rst,\n")
          f.write("        clk               => clk,\n")
          f.write("        local_y           => local_y,\n")
          f.write("        local_x           => local_x,\n")
          f.write("        tile_id           => tile_id,\n")
          f.write("        paddr             => paddr,\n")
          f.write("        pmask             => pmask,\n")
          f.write("        paddr_ext         => paddr_ext,\n")
          f.write("        pmask_ext         => pmask_ext,\n")
          f.write("        pirq              => pirq,\n")
          f.write("        apbi              => apbi,\n")
          f.write("        apbo              => apbo,\n")
          f.write("        pready            => pready,\n")
          f.write("        coherence_req_wrreq        => coherence_req_wrreq,\n")
          f.write("        coherence_req_data_in      => coherence_req_data_in,\n")
          f.write("        coherence_req_full         => coherence_req_full,\n")
          f.write("        coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq,\n")
          f.write("        coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,\n")
          f.write("        coherent_dma_rcv_empty     => coherent_dma_rcv_empty,\n")
          f.write("        coherence_fwd_rdreq        => coherence_fwd_rdreq,\n")
          f.write("        coherence_fwd_data_out     => coherence_fwd_data_out,\n")
          f.write("        coherence_fwd_empty        => coherence_fwd_empty,\n")
          f.write("        coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq,\n")
          f.write("        coherent_dma_snd_data_in   => coherent_dma_snd_data_in,\n")
          f.write("        coherent_dma_snd_full      => coherent_dma_snd_full,\n")
          f.write("        coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,\n")
          f.write("        coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,\n")
          f.write("        coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,\n")
          f.write("        coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,\n")
          f.write("        coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,\n")
          f.write("        coherence_rsp_snd_full     => coherence_rsp_snd_full,\n")
          f.write("        coherence_fwd_snd_wrreq    => coherence_fwd_snd_wrreq,\n")
          f.write("        coherence_fwd_snd_data_in  => coherence_fwd_snd_data_in,\n")
          f.write("        coherence_fwd_snd_full     => coherence_fwd_snd_full,\n")
          f.write("        dma_rcv_rdreq     => dma_rcv_rdreq,\n")
          f.write("        dma_rcv_data_out  => dma_rcv_data_out,\n")
          f.write("        dma_rcv_empty     => dma_rcv_empty,\n")
          f.write("        dma_snd_wrreq     => dma_snd_wrreq,\n")
          f.write("        dma_snd_data_in   => dma_snd_data_in,\n")
          f.write("        dma_snd_full      => dma_snd_full,\n")
          f.write("        interrupt_wrreq   => interrupt_wrreq,\n")
          f.write("        interrupt_data_in => interrupt_data_in,\n")
          f.write("        interrupt_full    => interrupt_full,\n")
          f.write("        interrupt_ack_rdreq    => interrupt_ack_rdreq,\n")
          f.write("        interrupt_ack_data_out => interrupt_ack_data_out,\n")
          f.write("        interrupt_ack_empty    => interrupt_ack_empty,\n")
          f.write("        mon_dvfs_in       => mon_dvfs_in,\n")
          f.write("        dvfs_transient_acc => dvfs_transient_in,\n")
          f.write("        -- Monitor signals\n")
          f.write("        mon_acc           => mon_acc,\n")
          f.write("        mon_cache         => mon_cache,\n")
          f.write("        mon_dvfs          => mon_dvfs,\n")
          f.write("        -- Coherence\n")
          f.write("        coherence         => coherence\n")
          f.write("      );\n")
          f.write("  end generate " + acc.name + "_gen;\n\n")
      else:
        f.write(tline)

#
### Main script ###
#

if len(sys.argv) != 7:
    print_usage()
    sys.exit(1)

dma_width = int(sys.argv[1])
cpu_arch = sys.argv[2]
acc_rtl_dir = sys.argv[3] + "/acc"
caches_rtl_dir = sys.argv[3] + "/sccs"
axi_acc_dir = sys.argv[4]
template_dir = sys.argv[5]
out_dir = sys.argv[6]
if cpu_arch == "leon3":
  little_endian = 0
else:
  little_endian = 1
accelerator_list = [ ]
axi_accelerator_list = [ ]
cache_list = [ ]

# Get scheduled accelerators
accelerators = next(os.walk(acc_rtl_dir))[1]
axi_accelerators = next(os.walk(axi_acc_dir))[1]
accelerators.sort()
axi_accelerators.sort()

caches = [ ]

tmp_l2_dir = caches_rtl_dir + '/l2'
tmp_l2_spandex_dir = caches_rtl_dir + '/l2_spandex'
tmp_llc_dir = caches_rtl_dir + '/llc'
tmp_llc_spandex_dir = caches_rtl_dir + '/llc_spandex'
caches.append('l2')
caches.append('l2_spandex')
caches.append('llc')
caches.append('llc_spandex')


if (len(accelerators) == 0):
  print("    INFO: No accelerators found in " + acc_rtl_dir + ".")
  print("          Please run 'make accelerators' or make <accelerator>-hls.")
  print("          Get available accelerators with 'make print-available-accelerators'")

if (not os.path.exists(tmp_l2_dir) or not os.path.exists(tmp_llc_dir)):
  print("    WARNING: No caches found in " + caches_rtl_dir + ".")
  print("             Please check the \"Use RTL\" option in the \"Cache Configuration\" tab when configuring ESP.")

for acc in axi_accelerators:
  accd = AxiAccelerator()
  accd.name = acc

  elem = xml.etree.ElementTree.parse(axi_acc_dir + "/" + acc + "/" + acc + ".xml")
  e = elem.getroot()
  for xmlacc in e.findall('accelerator'):
    acc_name = xmlacc.get('name')
    if acc_name != acc:
      continue

    print("    INFO: Retrieving information for " + acc)
    if "desc" in xmlacc.attrib:
      accd.desc = xmlacc.get('desc')
    else:
      print("    ERROR: Missing description for " + acc)
      sys.exit(1)
    if "device_id" in xmlacc.attrib:
      accd.device_id = xmlacc.get('device_id')
    else:
      print("    ERROR: Missing device ID for " + acc)
      sys.exit(1)

    if "interrupt" in xmlacc.attrib:
      accd.interrupt = xmlacc.get('interrupt')

    if "axi_prefix" in xmlacc.attrib:
      accd.axi_prefix = xmlacc.get('axi_prefix')

    if "apb_prefix" in xmlacc.attrib:
      accd.apb_prefix = xmlacc.get('apb_prefix')

    if "addr_width" in xmlacc.attrib:
      accd.addr_width = xmlacc.get('addr_width')

    if "id_width" in xmlacc.attrib:
      accd.id_width = xmlacc.get('id_width')

    if "user_width" in xmlacc.attrib:
      accd.user_width = xmlacc.get('user_width')

    for xmlparam in xmlacc.findall('clock'):
      accd.clocks.append(xmlparam.get('name'))
    for xmlparam in xmlacc.findall('reset'):
      #TODO: get polarity from XML (assuming active low for now)
      accd.resets.append(xmlparam.get('name'))

    axi_accelerator_list.append(accd)
    print(str(accd))
    break

for acc in accelerators:
  accd = Accelerator()
  accd.name = acc

  # Get scheduled HLS configurations
  acc_dir = acc_rtl_dir + "/" + acc
  acc_dp = get_immediate_subdirectories(acc_dir)
  for dp_str in acc_dp:
    dp = dp_str.replace(acc + "_", "")
    dp_info = dp.split("_")
    skip = False
    datatype = ""
    for item in dp_info:
      if re.match(r'dma[1-9]+', item, re.M|re.I):
        dp_dma_width = int(item.replace("dma", ""))
        if dp_dma_width != dma_width:
          skip = True
          break;
      if re.fullmatch(r'fl32in', item):
        datatype = "float_in"
      elif re.fullmatch(r'fl32out', item):
        datatype = "float_out"
      elif re.fullmatch(r'fl32', item):
        datatype = "float"

    if skip:
      print("    INFO: System DMA_WIDTH is " + str(dma_width) + "; skipping " + acc + "_" + dp)
      continue
    print("    INFO: Found implementation " + dp + " for " + acc)
    impl = Implementation()
    impl.name = dp
    impl.dma_width = dma_width
    impl.datatype = datatype
    accd.hlscfg.append(impl)

  # Read accelerator parameters and info
  if len(accd.hlscfg) == 0:
    print("    WARNING: No valid HLS configuration found for " + acc)
    continue

  elem = xml.etree.ElementTree.parse(acc_dir + "/" + acc + ".xml")
  e = elem.getroot()
  for xmlacc in e.findall('accelerator'):
    acc_name = xmlacc.get('name')

    print("    INFO: Retrieving information for " + acc)
    if "desc" in xmlacc.attrib:
      accd.desc = xmlacc.get('desc')
    else:
      print("    ERROR: Missing description for " + acc)
      sys.exit(1)
    if "data_size" in xmlacc.attrib:
      accd.data = int(xmlacc.get('data_size'))
    else:
      print("    ERROR: Missing memory footprint (MB) for " + acc)
      sys.exit(1)
    if accd.data == 0:
      print("    WARNING: memory footprint (MB) for " + acc + " is 0; defaulting to 4")
      accd.data = 4
    if "device_id" in xmlacc.attrib:
      accd.device_id = xmlacc.get('device_id')
    else:
      print("    ERROR: Missing device ID for " + acc)
      sys.exit(1)

    if "hls_tool" in xmlacc.attrib:
      accd.hls_tool = xmlacc.get('hls_tool')
      # hls4ml accelerators are implemented as Vivado HLS accelerators
      if accd.hls_tool in ('hls4ml'):
        accd.hls_tool = 'vivado_hls'
      if not accd.hls_tool in ('stratus_hls', 'vivado_hls', 'catapult_hls_cxx', 'catapult_hls_sysc', 'rtl'):
        print("    ERROR: Wrong HLS tool for " + acc)
        print(" " + accd.hls_tool)
        sys.exit(1)

    else:
      # Default to stratus_hls for Chisel, because the interface matches the Stratus HLS flow
      accd.hls_tool = 'stratus_hls'

    reg = 16
    for xmlparam in xmlacc.findall('param'):
      param = Parameter()
      param.name = xmlparam.get('name')
      param.reg = reg
      reg += 1
      if "desc" in xmlparam.attrib:
        param.desc = xmlparam.get('desc')
      if "value" in xmlparam.attrib:
        param.value = int(xmlparam.get('value'))
        param.readonly = True
      if "size" in xmlparam.attrib:
        param.size = int(xmlparam.get('size'))
      else:
        param.size = 32
      if param.size > 32:
        print("    ERROR: configuration parameter " + param.name + " of " + acc + " has bit-width larger than 32")
        sys.exit(1)
      accd.param.append(param)
    accelerator_list.append(accd)
    print(str(accd))
    break


# Compute relevan bitwidths for cache interfaces
# based on DMA_WIDTH and a fixed 128-bits cache line
bits_per_line = 128
words_per_line = int(bits_per_line/dma_width)
word_offset_bits = int(math.log2(words_per_line))
byte_offset_bits = int(math.log2(dma_width/8))
offset_bits = word_offset_bits + byte_offset_bits

for cac in caches:
  cacd = Component()
  cacd.name = cac

  # Get scheduled HLS configurations
  cac_dir = caches_rtl_dir + "/" + cac
  if os.path.exists(cac_dir):
    cac_dp = get_immediate_subdirectories(cac_dir)
    for dp_str in cac_dp:
      dp = dp_str.replace(cac + "_", "")
      cacd.hlscfg.append(dp)
      print("    INFO: Found implementation " + dp + " for " + cac)
  cache_list.append(cacd)


# Generate RTL
print("    INFO: Generating RTL to " + out_dir)
gen_device_id(accelerator_list, axi_accelerator_list, template_dir, out_dir)
gen_tech_dep(accelerator_list, cache_list, dma_width, template_dir, out_dir)
gen_tech_indep(accelerator_list, axi_accelerator_list, cache_list, dma_width, template_dir, out_dir)
gen_tech_indep_impl(accelerator_list, cache_list, dma_width, template_dir, out_dir)
gen_interfaces(accelerator_list, axi_accelerator_list, dma_width, template_dir, out_dir)
for acc in accelerator_list:
  gen_noc_interface(acc, dma_width, template_dir, out_dir, False)
for acc in axi_accelerator_list:
  gen_noc_interface(acc, dma_width, template_dir, out_dir, True)
gen_tile_acc(accelerator_list, axi_accelerator_list, template_dir, out_dir)
