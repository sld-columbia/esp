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
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

package soctiles is

  component esp
    generic (
      fabtech                 : integer;
      memtech                 : integer;
      padtech                 : integer;
      disas                   : integer;
      dbguart                 : integer;
      pclow                   : integer;
      has_dvfs                : integer;
      has_sync                : integer;
      XLEN                    : integer;
      YLEN                    : integer;
      TILES_NUM               : integer;
      testahb                 : boolean;
      SIM_BYPASS_INIT_CAL     : string;
      SIMULATION              : string;
      USE_MIG_INTERFACE_MODEL : boolean;
      autonegotiation         : integer);
    port (
      rst           : in    std_ulogic;
      noc_clk       : in    std_ulogic;
      refclk        : in    std_ulogic;
      mem_clk       : in    std_ulogic;
      pllbypass     : in    std_logic_vector(TILES_NUM-1 downto 0);
      --pragma translate_off
      mctrl_ahbsi   : out   ahb_slv_in_type;
      mctrl_ahbso   : in    ahb_slv_out_type;
      mctrl_apbi    : out   apb_slv_in_type;
      mctrl_apbo    : in    apb_slv_out_type;
      mctrl_clk     : out   std_ulogic;
      --pragma translate_on
      uart_rxd      : in    std_ulogic;
      uart_txd      : out   std_ulogic;
      uart_ctsn     : in    std_ulogic;
      uart_rtsn     : out   std_ulogic;
      ndsuact       : out   std_ulogic;
      dsuerr        : out   std_ulogic;
      ddr0_ahbsi    : out ahb_slv_in_type;
      ddr0_ahbso    : in  ahb_slv_out_type;
      ddr1_ahbsi    : out ahb_slv_in_type;
      ddr1_ahbso    : in  ahb_slv_out_type;
      eth0_apbi     : out apb_slv_in_type;
      eth0_apbo     : in  apb_slv_out_type;
      sgmii0_apbi   : out apb_slv_in_type;
      sgmii0_apbo   : in  apb_slv_out_type;
      eth0_ahbmi    : out ahb_mst_in_type;
      eth0_ahbmo    : in  ahb_mst_out_type;
      dvi_apbi      : out apb_slv_in_type;
      dvi_apbo      : in  apb_slv_out_type;
      dvi_ahbmi     : out ahb_mst_in_type;
      dvi_ahbmo     : in  ahb_mst_out_type;
      -- Monitor signals
      mon_noc       : out monitor_noc_matrix(1 to 6, 0 to TILES_NUM-1);
      mon_acc       : out monitor_acc_vector(0 to accelerators_num-1);
      mon_dvfs      : out monitor_dvfs_vector(0 to TILES_NUM-1)
      );
  end component;

  component tile_cpu
    generic (
      fabtech                 : integer;
      memtech                 : integer;
      padtech                 : integer;
      disas                   : integer;
      pclow                   : integer;
      cpu_id                  : integer;
      local_y                 : local_yx;
      local_x                 : local_yx;
      remote_apb_slv_en       : std_logic_vector(NAPBSLV-1 downto 0);
      has_dvfs                : integer;
      has_pll                 : integer;
      domain                  : integer;
      USE_MIG_INTERFACE_MODEL : boolean);
    port (
      rst                : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      -- TODO: REMOVE!
      irqi_i             : in  l3_irq_in_type;
      irqo_o             : out l3_irq_out_type;
      dbgi               : in l3_debug_in_type;
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
      mon_dvfs_in        : in  monitor_dvfs_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component;

  component tile_acc
    generic (
      fabtech        : integer;
      memtech        : integer;
      padtech        : integer;
      hls_conf       : hlscfg_t;
      local_y        : local_yx;
      local_x        : local_yx;
      io_y           : local_yx;
      io_x           : local_yx;
      device         : devid_t;
      pindex         : integer;
      paddr          : integer;
      pmask          : integer;
      pirq           : integer;
      scatter_gather : integer range 0 to 1;
      local_apb_mask : std_logic_vector(NAPBSLV-1 downto 0);
      has_dvfs       : integer;
      has_pll        : integer;
      extra_clk_buf  : integer;
      domain         : integer);
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
      --Monitor signals
      mon_acc            : out monitor_acc_type;
      mon_dvfs           : out monitor_dvfs_type
      );
  end component;

  component tile_io
    generic (
      fabtech : integer;
      memtech : integer;
      padtech : integer;
      disas   : integer;
      dbguart : integer;
      pclow   : integer);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      --TODO: REMOVE and use proxy for eth irq!
      eth0_pirq          : in  std_logic_vector(NAHBIRQ-1 downto 0);
      sgmii0_pirq        : in  std_logic_vector(NAHBIRQ-1 downto 0);
      -- TODO: REMOVE!
      irqi_o             : out irq_in_vector(0 to CFG_NCPU_TILE-1);
      irqo_i             : in  irq_out_vector(0 to CFG_NCPU_TILE-1);
      noc1_input_port    : out noc_flit_type;
      noc1_data_void_in  : out std_ulogic;
      noc1_stop_in       : out  std_ulogic;
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
      noc4_stop_in       : out  std_ulogic;
      noc4_output_port   : in  noc_flit_type;
      noc4_data_void_out : in  std_ulogic;
      noc4_stop_out      : in  std_ulogic;
      noc5_input_port    : out noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_in       : out  std_ulogic;
      noc5_output_port   : in  noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc6_input_port    : out noc_flit_type;
      noc6_data_void_in  : out std_ulogic;
      noc6_stop_in       : out  std_ulogic;
      noc6_output_port   : in  noc_flit_type;
      noc6_data_void_out : in  std_ulogic;
      noc6_stop_out      : in  std_ulogic;
      mon_dvfs           : out monitor_dvfs_type
      );
  end component;

  component tile_mem
    generic (
      fabtech                 : integer;
      memtech                 : integer;
      padtech                 : integer;
      disas                   : integer;
      dbguart                 : integer;
      pclow                   : integer;
      testahb                 : boolean;
      USE_MIG_INTERFACE_MODEL : boolean);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      --pragma translate_off
      mctrl_ahbsi        : out   ahb_slv_in_type;
      mctrl_ahbso        : in    ahb_slv_out_type;
      mctrl_apbi         : out   apb_slv_in_type;
      mctrl_apbo         : in    apb_slv_out_type;
      --pragma translate_on
      ndsuact            : out std_ulogic; -- to chip_led(0)
      dsuerr             : out std_ulogic;
      dbgi               : out l3_debug_in_vector(0 to CFG_NCPU_TILE-1);
      dbgo               : in l3_debug_out_vector(0 to CFG_NCPU_TILE-1);
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
      mon_dvfs           : out monitor_dvfs_type
      );
  end component;

  component tile_mem_lite
    generic (
      fabtech                 : integer;
      memtech                 : integer;
      padtech                 : integer;
      disas                   : integer;
      dbguart                 : integer;
      pclow                   : integer;
      testahb                 : boolean;
      USE_MIG_INTERFACE_MODEL : boolean);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
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
      mon_dvfs           : out monitor_dvfs_type
      );
  end component;

end soctiles;
