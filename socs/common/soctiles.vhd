------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity: 	soctiles
-- File:	soctiles.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description: Fixed system address mapping configuration
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.leon3.all;
use work.gencomp.all;
use work.sldcommon.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

package soctiles is

  component esp is
    port (
      rst                : in  std_logic;
      noc_clk            : in  std_logic;
      refclk             : in  std_logic;
      mem_clk            : in  std_logic;
      pllbypass          : in  std_logic_vector(CFG_TILES_NUM - 1 downto 0);
      --pragma translate_off
      mctrl_ahbsi        : out ahb_slv_in_type;
      mctrl_ahbso        : in  ahb_slv_out_type;
      mctrl_apbi         : out apb_slv_in_type;
      mctrl_apbo         : in  apb_slv_out_type;
      --pragma translate_on
      uart_rxd           : in  std_logic;
      uart_txd           : out std_logic;
      uart_ctsn          : in  std_logic;
      uart_rtsn          : out std_logic;
      ndsuact            : out std_logic;
      dsuerr             : out std_logic;
      ddr_ahbsi          : out ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);
      ddr_ahbso          : in  ahb_slv_out_vector_type(0 to CFG_NMEM_TILE - 1);
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      mon_noc            : out monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
      mon_acc            : out monitor_acc_vector(0 to accelerators_num-1);
      mon_mem            : out monitor_mem_vector(0 to CFG_NLLC - 1);
      mon_l2             : out monitor_cache_vector(0 to CFG_NL2 - 1);
      mon_llc            : out monitor_cache_vector(0 to CFG_NLLC - 1);
      mon_dvfs           : out monitor_dvfs_vector(0 to CFG_TILES_NUM-1));
  end component esp;

  component tile_cpu is
    generic (
      tile_id : integer range 0 to CFG_TILES_NUM - 1);
    port (
      rst                : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      dbgi               : in  l3_debug_in_type;
      dbgo               : out l3_debug_out_type;
      noc1_input_port    : out noc_flit_type;
      noc1_data_void_in  : out std_ulogic;
      noc1_stop_in       : out std_ulogic;
      noc1_output_port   : in  noc_flit_type;
      noc1_data_void_out : in  std_ulogic;
      noc1_stop_out      : in  std_ulogic;
      noc2_input_port    : out noc_flit_type;
      noc2_data_void_in  : out std_ulogic;
      noc2_stop_in       : out std_ulogic;
      noc2_output_port   : in  noc_flit_type;
      noc2_data_void_out : in  std_ulogic;
      noc2_stop_out      : in  std_ulogic;
      noc3_input_port    : out noc_flit_type;
      noc3_data_void_in  : out std_ulogic;
      noc3_stop_in       : out std_ulogic;
      noc3_output_port   : in  noc_flit_type;
      noc3_data_void_out : in  std_ulogic;
      noc3_stop_out      : in  std_ulogic;
      noc4_input_port    : out noc_flit_type;
      noc4_data_void_in  : out std_ulogic;
      noc4_stop_in       : out std_ulogic;
      noc4_output_port   : in  noc_flit_type;
      noc4_data_void_out : in  std_ulogic;
      noc4_stop_out      : in  std_ulogic;
      noc5_input_port    : out noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_in       : out std_ulogic;
      noc5_output_port   : in  noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc6_input_port    : out noc_flit_type;
      noc6_data_void_in  : out std_ulogic;
      noc6_stop_in       : out std_ulogic;
      noc6_output_port   : in  noc_flit_type;
      noc6_data_void_out : in  std_ulogic;
      noc6_stop_out      : in  std_ulogic;
      mon_cache          : out monitor_cache_type;
      mon_dvfs_in        : in  monitor_dvfs_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_cpu;

  component tile_acc is
    generic (
      tile_id : integer range 0 to CFG_TILES_NUM - 1);
    port (
      rst                : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      noc1_input_port    : out noc_flit_type;
      noc1_data_void_in  : out std_ulogic;
      noc1_stop_in       : out std_ulogic;
      noc1_output_port   : in  noc_flit_type;
      noc1_data_void_out : in  std_ulogic;
      noc1_stop_out      : in  std_ulogic;
      noc2_input_port    : out noc_flit_type;
      noc2_data_void_in  : out std_ulogic;
      noc2_stop_in       : out std_ulogic;
      noc2_output_port   : in  noc_flit_type;
      noc2_data_void_out : in  std_ulogic;
      noc2_stop_out      : in  std_ulogic;
      noc3_input_port    : out noc_flit_type;
      noc3_data_void_in  : out std_ulogic;
      noc3_stop_in       : out std_ulogic;
      noc3_output_port   : in  noc_flit_type;
      noc3_data_void_out : in  std_ulogic;
      noc3_stop_out      : in  std_ulogic;
      noc4_input_port    : out noc_flit_type;
      noc4_data_void_in  : out std_ulogic;
      noc4_stop_in       : out std_ulogic;
      noc4_output_port   : in  noc_flit_type;
      noc4_data_void_out : in  std_ulogic;
      noc4_stop_out      : in  std_ulogic;
      noc5_input_port    : out noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_in       : out std_ulogic;
      noc5_output_port   : in  noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc6_input_port    : out noc_flit_type;
      noc6_data_void_in  : out std_ulogic;
      noc6_stop_in       : out std_ulogic;
      noc6_output_port   : in  noc_flit_type;
      noc6_data_void_out : in  std_ulogic;
      noc6_stop_out      : in  std_ulogic;
      mon_dvfs_in        : in  monitor_dvfs_type;
      mon_acc            : out monitor_acc_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_acc;

  component tile_io is
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      --pragma translate_off
      mctrl_ahbsi        : out ahb_slv_in_type;
      mctrl_ahbso        : in  ahb_slv_out_type;
      mctrl_apbi         : out apb_slv_in_type;
      mctrl_apbo         : in  apb_slv_out_type;
      --pragma translate_on
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      ndsuact            : out std_ulogic;
      dsuerr             : out std_ulogic;
      dbgi               : out l3_debug_in_vector(0 to CFG_NCPU_TILE-1);
      dbgo               : in  l3_debug_out_vector(0 to CFG_NCPU_TILE-1);
      noc1_input_port    : out noc_flit_type;
      noc1_data_void_in  : out std_ulogic;
      noc1_stop_in       : out std_ulogic;
      noc1_output_port   : in  noc_flit_type;
      noc1_data_void_out : in  std_ulogic;
      noc1_stop_out      : in  std_ulogic;
      noc2_input_port    : out noc_flit_type;
      noc2_data_void_in  : out std_ulogic;
      noc2_stop_in       : out std_ulogic;
      noc2_output_port   : in  noc_flit_type;
      noc2_data_void_out : in  std_ulogic;
      noc2_stop_out      : in  std_ulogic;
      noc3_input_port    : out noc_flit_type;
      noc3_data_void_in  : out std_ulogic;
      noc3_stop_in       : out std_ulogic;
      noc3_output_port   : in  noc_flit_type;
      noc3_data_void_out : in  std_ulogic;
      noc3_stop_out      : in  std_ulogic;
      noc4_input_port    : out noc_flit_type;
      noc4_data_void_in  : out std_ulogic;
      noc4_stop_in       : out std_ulogic;
      noc4_output_port   : in  noc_flit_type;
      noc4_data_void_out : in  std_ulogic;
      noc4_stop_out      : in  std_ulogic;
      noc5_input_port    : out noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_in       : out std_ulogic;
      noc5_output_port   : in  noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc6_input_port    : out noc_flit_type;
      noc6_data_void_in  : out std_ulogic;
      noc6_stop_in       : out std_ulogic;
      noc6_output_port   : in  noc_flit_type;
      noc6_data_void_out : in  std_ulogic;
      noc6_stop_out      : in  std_ulogic;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_io;

  component tile_mem is
    generic (
      tile_id : integer range 0 to CFG_TILES_NUM - 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      dbgi               : in  l3_debug_in_type;
      noc1_input_port    : out noc_flit_type;
      noc1_data_void_in  : out std_ulogic;
      noc1_stop_in       : out std_ulogic;
      noc1_output_port   : in  noc_flit_type;
      noc1_data_void_out : in  std_ulogic;
      noc1_stop_out      : in  std_ulogic;
      noc2_input_port    : out noc_flit_type;
      noc2_data_void_in  : out std_ulogic;
      noc2_stop_in       : out std_ulogic;
      noc2_output_port   : in  noc_flit_type;
      noc2_data_void_out : in  std_ulogic;
      noc2_stop_out      : in  std_ulogic;
      noc3_input_port    : out noc_flit_type;
      noc3_data_void_in  : out std_ulogic;
      noc3_stop_in       : out std_ulogic;
      noc3_output_port   : in  noc_flit_type;
      noc3_data_void_out : in  std_ulogic;
      noc3_stop_out      : in  std_ulogic;
      noc4_input_port    : out noc_flit_type;
      noc4_data_void_in  : out std_ulogic;
      noc4_stop_in       : out std_ulogic;
      noc4_output_port   : in  noc_flit_type;
      noc4_data_void_out : in  std_ulogic;
      noc4_stop_out      : in  std_ulogic;
      noc5_input_port    : out noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_in       : out std_ulogic;
      noc5_output_port   : in  noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc6_input_port    : out noc_flit_type;
      noc6_data_void_in  : out std_ulogic;
      noc6_stop_in       : out std_ulogic;
      noc6_output_port   : in  noc_flit_type;
      noc6_data_void_out : in  std_ulogic;
      noc6_stop_out      : in  std_ulogic;
      mon_mem            : out monitor_mem_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_mem;

end soctiles;
