#!/usr/bin/python3

###############################################################################
#
# ESP Wrapper Generator for Accelerators
#
# Copyright (c) 2014-2017, Columbia University
#
# @authors: Christian Pilato <pilato@cs.columbia.edu>
#           Paolo Mantovani <paolo@cs.columbia.edu>
#
###############################################################################

import shutil
import os
import xml.etree.ElementTree
import glob
import sys
import re

def get_immediate_subdirectories(a_dir):
  return [name for name in os.listdir(a_dir)
        if os.path.isdir(os.path.join(a_dir, name))]

def print_usage():
  print("Usage                    : ./sld_generate.py <dma_width> <rtl_path> <template_path> <out_path>")
  print("")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (currently supporting 32 bits only)")
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

  def __str__(self):
    return self.name

class Accelerator():
  def __init__(self):
    self.name = ""
    self.hlscfg = []
    self.desc = ""
    self.data = 0
    self.device_id = ""
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


#
### VHDL writer ###
#

def gen_device_id(accelerator_list, template_dir, out_dir):
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
        for acc in accelerator_list:
          f.write("  constant SLD_" + acc.name.upper() + " " + ": devid_t := 16#" + acc.device_id + "#;\n")
      elif tline.find("-- <<ddesc>>") >= 0:
        for acc in accelerator_list:
          desc = acc.desc
          if len(acc.desc) < 31:
            desc = acc.desc + (31 - len(acc.desc))*" "
          elif len(acc.desc) > 31:
            desc = acc.desc[0:30]
          f.write("    SLD_" + acc.name.upper() + " " + "=> \"" + desc + "\",\n")
      else:
        f.write(tline)



def write_acc_interface(f, acc, dma_width, rst):
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
  f.write("      dma_write_ctrl_valid       : out std_ulogic;\n")
  f.write("      dma_write_ctrl_ready       : in  std_ulogic;\n")
  f.write("      dma_write_ctrl_data_index  : out std_logic_vector(" + str(31) + " downto 0);\n")
  f.write("      dma_write_ctrl_data_length : out std_logic_vector(" + str(31) + " downto 0);\n")
  f.write("      dma_read_chnl_valid        : in  std_ulogic;\n")
  f.write("      dma_read_chnl_ready        : out std_ulogic;\n")
  f.write("      dma_read_chnl_data         : in  std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
  f.write("      dma_write_chnl_valid       : out std_ulogic;\n")
  f.write("      dma_write_chnl_ready       : in  std_ulogic;\n")
  f.write("      dma_write_chnl_data        : out std_logic_vector(" + str(dma_width - 1) + " downto 0);\n")
  f.write("      acc_done                   : out std_ulogic\n")

def write_acc_port_map(f, acc, dma_width, rst, is_noc_interface):
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
  f.write("      dma_write_ctrl_valid       => dma_write_ctrl_valid,\n")
  f.write("      dma_write_ctrl_ready       => dma_write_ctrl_ready,\n")
  f.write("      dma_write_ctrl_data_index  => dma_write_ctrl_data_index,\n")
  f.write("      dma_write_ctrl_data_length => dma_write_ctrl_data_length,\n")
  f.write("      dma_read_chnl_valid        => dma_read_chnl_valid,\n")
  f.write("      dma_read_chnl_ready        => dma_read_chnl_ready,\n")
  f.write("      dma_read_chnl_data         => dma_read_chnl_data,\n")
  f.write("      dma_write_chnl_valid       => dma_write_chnl_valid,\n")
  f.write("      dma_write_chnl_ready       => dma_write_chnl_ready,\n")
  f.write("      dma_write_chnl_data        => dma_write_chnl_data,\n")
  f.write("      acc_done                   => acc_done\n")
  f.write("    );\n")


# Component declaration matching HLS-generated verilog
def gen_tech_dep(accelerator_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/allacc.vhd', 'w')
  with open(template_dir + '/allacc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerators-components>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
        for impl in acc.hlscfg:
          f.write("\n")
          f.write("  component " + acc.name + "_" + impl.name + "\n")
          f.write("    port (\n")
          write_acc_interface(f, acc, dma_width, "rst")
          f.write("    );\n")
          f.write("  end component;\n\n")
          f.write("\n")
  f.close()
  ftemplate.close()


# Component declaration independent from technology and implementation
def gen_tech_indep(accelerator_list, dma_width, template_dir, out_dir):
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
        write_acc_interface(f, acc, dma_width, "acc_rst")
        f.write("    );\n")
        f.write("  end component;\n\n")
        f.write("\n")
  f.close()
  ftemplate.close()


# Mapping from generic components to technology and implementation dependent ones
def gen_tech_indep_impl(accelerator_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/accelerators.vhd', 'w')
  with open(template_dir + '/accelerators.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerators-entities>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
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
        write_acc_interface(f, acc, dma_width, "acc_rst")
        f.write("    );\n")
        f.write("\n")
        f.write("end entity " + acc.name + "_rtl;\n\n")
        f.write("\n")
        f.write("architecture mapping of " + acc.name + "_rtl is\n\n")
        f.write("begin  -- mapping\n\n")
        for impl in acc.hlscfg:
          f.write("\n")
          f.write("  " + impl.name + "_gen: if hls_conf = HLSCFG_" + acc.name.upper() + "_" + impl.name.upper() + " generate\n")
          f.write("    " + acc.name + "_" + impl.name + "_i: " + acc.name + "_" + impl.name + "\n")
          write_acc_port_map(f, acc, dma_width, "rst", False)
          f.write("  end generate " +  impl.name + "_gen;\n\n")
        f.write("end mapping;\n\n")
  f.close()
  ftemplate.close()


# Component declaration of NoC wrappers
def gen_interfaces(accelerator_list, dma_width, template_dir, out_dir):
  f = open(out_dir + '/sldacc.vhd', 'w')
  with open(template_dir + '/sldacc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<wrappers-components>>") < 0:
        f.write(tline)
        continue
      for acc in accelerator_list:
        f.write("\n")
        f.write("  component noc_" + acc.name + "\n")
        f.write("    generic (\n")
        f.write("      hls_conf       : hlscfg_t;\n")
        f.write("      tech           : integer;\n")
        f.write("      local_y        : local_yx;\n")
        f.write("      local_x        : local_yx;\n")
        f.write("      mem_num        : integer;\n")
        f.write("      mem_info       : tile_mem_info_vector;\n")
        f.write("      io_y           : local_yx;\n")
        f.write("      io_x           : local_yx;\n")
        f.write("      pindex         : integer;\n")
        f.write("      paddr          : integer;\n")
        f.write("      pmask          : integer;\n")
        f.write("      pirq           : integer;\n")
        f.write("      scatter_gather : integer := 1;\n")
        f.write("      has_dvfs       : integer := 1;\n")
        f.write("      has_pll        : integer;\n")
        f.write("      extra_clk_buf  : integer;\n")
        f.write("      local_apb_en   : std_logic_vector(NAPBSLV-1 downto 0)\n")
        f.write("    );\n")
        f.write("\n")
        f.write("    port (\n")
        f.write("      rst               : in  std_ulogic;\n")
        f.write("      clk               : in  std_ulogic;\n")
        f.write("      refclk            : in  std_ulogic;\n")
        f.write("      pllbypass         : in  std_ulogic;\n")
        f.write("      pllclk            : out std_ulogic;\n")
        f.write("      dma_rcv_rdreq     : out std_ulogic;\n")
        f.write("      dma_rcv_data_out  : in  noc_flit_type;\n")
        f.write("      dma_rcv_empty     : in  std_ulogic;\n")
        f.write("      dma_snd_wrreq     : out std_ulogic;\n")
        f.write("      dma_snd_data_in   : out noc_flit_type;\n")
        f.write("      dma_snd_full      : in  std_ulogic;\n")
        f.write("      interrupt_wrreq   : out std_ulogic;\n")
        f.write("      interrupt_data_in : out noc_flit_type;\n")
        f.write("      interrupt_full    : in  std_ulogic;\n")
        f.write("      apb_snd_wrreq     : out std_ulogic;\n")
        f.write("      apb_snd_data_in   : out noc_flit_type;\n")
        f.write("      apb_snd_full      : in  std_ulogic;\n")
        f.write("      apb_rcv_rdreq     : out std_ulogic;\n")
        f.write("      apb_rcv_data_out  : in  noc_flit_type;\n")
        f.write("      apb_rcv_empty     : in  std_ulogic;\n")
        f.write("      mon_dvfs_in       : in  monitor_dvfs_type;\n")
        f.write("      mon_acc           : out monitor_acc_type;\n")
        f.write("      mon_dvfs          : out monitor_dvfs_type\n")
        f.write("    );\n")
        f.write("  end component;\n\n")
        f.write("\n")
  f.close()
  ftemplate.close()


def gen_noc_interface(acc, dma_width, template_dir, out_dir):
  f = open(out_dir + "/noc_" + acc.name + ".vhd", 'w')
  with open(template_dir + '/noc_interface.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<header>>") >= 0:
        f.write("-- Entity       noc_" + acc.name + "\n")
        f.write("-- File         noc_" + acc.name + ".vhd\n")
      elif tline.find("-- <<entity>>") >= 0:
        f.write("entity noc_" + acc.name + " is\n")
      elif tline.find("-- <<architecture>>") >= 0:
        f.write("architecture rtl of noc_" + acc.name + " is\n")
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
      elif tline.find("-- <<accelerator_instance>>") >= 0:
        f.write("  " + acc.name + "_rlt_i: " + acc.name + "_rtl\n")
        f.write("    generic map (\n")
        f.write("      hls_conf => hls_conf\n")
        f.write("    )\n")
        write_acc_port_map(f, acc, dma_width, "acc_rst", True)
      else:
        f.write(tline)


def gen_tile_acc(accelerator_list, template_dir, out_dir):
  f = open(out_dir + "/tile_acc.vhd", 'w')
  with open(template_dir + '/tile_acc.vhd', 'r') as ftemplate:
    for tline in ftemplate:
      if tline.find("-- <<accelerator-wrappers-gen>>") >= 0:
        for acc in accelerator_list:
          f.write("  " + acc.name + "_gen: if device = SLD_" + acc.name.upper() + " generate\n")
          f.write("    noc_" + acc.name + "_i: noc_" + acc.name + "\n")
          f.write("      generic map (\n")
          f.write("        hls_conf       => hls_conf,\n")
          f.write("        tech           => memtech,\n")
          f.write("        local_y        => local_y,\n")
          f.write("        local_x        => local_x,\n")
          f.write("        mem_num        => NMIG+CFG_SVGA_ENABLE,\n")
          f.write("        mem_info       => tile_mem_list,\n")
          f.write("        io_y           => io_y,\n")
          f.write("        io_x           => io_x,\n")
          f.write("        pindex         => pindex,\n")
          f.write("        paddr          => paddr,\n")
          f.write("        pmask          => pmask,\n")
          f.write("        pirq           => pirq,\n")
          f.write("        scatter_gather => scatter_gather,\n")
          f.write("        has_dvfs       => has_dvfs,\n")
          f.write("        has_pll        => has_pll,\n")
          f.write("        extra_clk_buf  => extra_clk_buf,\n")
          f.write("        local_apb_en   => local_apb_mask)\n")
          f.write("      port map (\n")
          f.write("        rst               => rst,\n")
          f.write("        clk               => clk_feedthru,\n")
          f.write("        refclk            => refclk,\n")
          f.write("        pllbypass         => pllbypass,\n")
          f.write("        pllclk            => clk_feedthru,\n")
          f.write("        dma_rcv_rdreq     => dma_rcv_rdreq,\n")
          f.write("        dma_rcv_data_out  => dma_rcv_data_out,\n")
          f.write("        dma_rcv_empty     => dma_rcv_empty,\n")
          f.write("        dma_snd_wrreq     => dma_snd_wrreq,\n")
          f.write("        dma_snd_data_in   => dma_snd_data_in,\n")
          f.write("        dma_snd_full      => dma_snd_full,\n")
          f.write("        interrupt_wrreq   => interrupt_wrreq,\n")
          f.write("        interrupt_data_in => interrupt_data_in,\n")
          f.write("        interrupt_full    => interrupt_full,\n")
          f.write("        apb_snd_wrreq     => apb_snd_wrreq,\n")
          f.write("        apb_snd_data_in   => apb_snd_data_in,\n")
          f.write("        apb_snd_full      => apb_snd_full,\n")
          f.write("        apb_rcv_rdreq     => apb_rcv_rdreq,\n")
          f.write("        apb_rcv_data_out  => apb_rcv_data_out,\n")
          f.write("        apb_rcv_empty     => apb_rcv_empty,\n")
          f.write("        mon_dvfs_in       => mon_dvfs_in,\n")
          f.write("        -- Monitor signals\n")
          f.write("        mon_acc           => mon_acc,\n")
          f.write("        mon_dvfs          => mon_dvfs\n")
          f.write("      );\n")
          f.write("  end generate " + acc.name + "_gen;\n\n")
      else:
        f.write(tline)

#
### Main script ###
#

if len(sys.argv) != 5:
    print_usage()
    sys.exit(1)

dma_width = int(sys.argv[1])
rtl_dir = sys.argv[2]
template_dir = sys.argv[3]
out_dir = sys.argv[4]
accelerator_list = [ ]

# Get scheduled accelerators
accelerators = next(os.walk(rtl_dir))[1]

if (len(accelerators) == 0):
  print("    WARNING: No accelerators found in " + rtl_dir + ".")
  print("             Please run 'make accelerators' or make <accelerator>-hls.")
  print("             Get available accelerators with 'make print-available-accelerators'")

for acc in accelerators:
  accd = Accelerator()
  accd.name = acc

  # Get scheduled HLS configurations
  acc_dir = rtl_dir + "/" + acc
  acc_dp = get_immediate_subdirectories(acc_dir)
  for dp_str in acc_dp:
    dp = dp_str.replace(acc_dir + "/" + acc + "_", "")
    dp = dp.replace(".v", "")
    dp_info = dp.split("_")
    skip = False
    for item in dp_info:
      if re.match(r'dma[1-9]+', item, re.M|re.I):
        dp_dma_width = int(item.replace("dma", ""))
        if dp_dma_width != dma_width:
          skip = True
          break;
    if skip:
      print("    INFO: System DMA_WIDTH is " + str(dma_width) + "; skipping " + acc + "_" + dp)
      continue
    print("    INFO: Found implementation " + dp + " for " + acc)
    impl = Implementation()
    impl.name = dp
    impl.dma_width = dma_width
    accd.hlscfg.append(impl)

  # Read accelerator parameters and info
  if len(accd.hlscfg) == 0:
    print("    WARNING: No valid HLS configuration found for " + acc)
    continue

  elem = xml.etree.ElementTree.parse(acc_dir + "/" + acc + ".xml")
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
    if "data_size" in xmlacc.attrib:
      accd.data = int(xmlacc.get('data_size'))
    else:
      print("    ERROR: Missing memory footprint (MB) for " + acc)
      sys.exit(1)
    if "device_id" in xmlacc.attrib:
      accd.device_id = xmlacc.get('device_id')
    else:
      print("    ERROR: Missing device ID for " + acc)
      sys.exit(1)

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

# Generate RTL
print("    INFO: Generating RTL to " + out_dir)
gen_device_id(accelerator_list, template_dir, out_dir)
gen_tech_dep(accelerator_list, dma_width, template_dir, out_dir)
gen_tech_indep(accelerator_list, dma_width, template_dir, out_dir)
gen_tech_indep_impl(accelerator_list, dma_width, template_dir, out_dir)
gen_interfaces(accelerator_list, dma_width, template_dir, out_dir)
for acc in accelerator_list:
  gen_noc_interface(acc, dma_width, template_dir, out_dir)
gen_tile_acc(accelerator_list, template_dir, out_dir)

