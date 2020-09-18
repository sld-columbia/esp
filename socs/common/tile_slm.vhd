-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Memory interface tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.memoryctrl.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;

entity tile_slm is
  generic (
    ROUTER_PORTS : ports_vec := "11111";
    HAS_SYNC: integer range 0 to 1 := 0);
  port (
    rst                : in  std_ulogic;
    clk                : in  std_ulogic;
    -- NOC
    sys_clk_int        : in  std_logic;
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in std_logic_vector(3 downto 0);
    noc1_stop_in       : in std_logic_vector(3 downto 0);
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);
    noc1_stop_out      : out std_logic_vector(3 downto 0);
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in std_logic_vector(3 downto 0);
    noc2_stop_in       : in std_logic_vector(3 downto 0);
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);
    noc2_stop_out      : out std_logic_vector(3 downto 0);
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in std_logic_vector(3 downto 0);
    noc3_stop_in       : in std_logic_vector(3 downto 0);
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);
    noc3_stop_out      : out std_logic_vector(3 downto 0);
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in std_logic_vector(3 downto 0);
    noc4_stop_in       : in std_logic_vector(3 downto 0);
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0);
    noc4_stop_out      : out std_logic_vector(3 downto 0);
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in std_logic_vector(3 downto 0); 
    noc5_stop_in       : in std_logic_vector(3 downto 0);
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0);
    noc5_stop_out      : out std_logic_vector(3 downto 0);
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in std_logic_vector(3 downto 0);
    noc6_stop_in       : in std_logic_vector(3 downto 0);
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);
    noc6_stop_out      : out std_logic_vector(3 downto 0);
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type;
    mon_mem            : out monitor_mem_type;
    mon_dvfs           : out monitor_dvfs_type);
end;


architecture rtl of tile_slm is

  component sync_noc_set
    generic (
      PORTS     : std_logic_vector(4 downto 0);
--      local_x   : std_logic_vector(2 downto 0);
--      local_y   : std_logic_vector(2 downto 0);
      HAS_SYNC  : integer range 0 to 1 := 0);
    port (
      clk           : in  std_logic;
      clk_tile      : in  std_logic;
      rst           : in  std_logic;
      CONST_local_x : in  std_logic_vector(2 downto 0);
      CONST_local_y : in  std_logic_vector(2 downto 0);
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_input_port    : in  noc_flit_type;
      noc1_data_void_in  : in  std_logic_vector(4 downto 0);
      noc1_stop_in       : in  std_logic_vector(4 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_output_port   : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(4 downto 0);
      noc1_stop_out      : out std_logic_vector(4 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_input_port    : in  noc_flit_type;
      noc2_data_void_in  : in  std_logic_vector(4 downto 0);
      noc2_stop_in       : in  std_logic_vector(4 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_output_port   : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(4 downto 0);
      noc2_stop_out      : out std_logic_vector(4 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_input_port    : in  noc_flit_type;
      noc3_data_void_in  : in  std_logic_vector(4 downto 0);
      noc3_stop_in       : in  std_logic_vector(4 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_output_port   : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(4 downto 0);
      noc3_stop_out      : out std_logic_vector(4 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_input_port    : in  noc_flit_type;
      noc4_data_void_in  : in  std_logic_vector(4 downto 0);
      noc4_stop_in       : in  std_logic_vector(4 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_output_port   : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(4 downto 0);
      noc4_stop_out      : out std_logic_vector(4 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_input_port    : in  misc_noc_flit_type;
      noc5_data_void_in  : in  std_logic_vector(4 downto 0);
      noc5_stop_in       : in  std_logic_vector(4 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_output_port   : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(4 downto 0);
      noc5_stop_out      : out std_logic_vector(4 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_input_port    : in  noc_flit_type;
      noc6_data_void_in  : in  std_logic_vector(4 downto 0);
      noc6_stop_in       : in  std_logic_vector(4 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_output_port   : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(4 downto 0);
      noc6_stop_out      : out std_logic_vector(4 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type
      );
  end component;

  -- Queues (despite their name, for this tile, all queues carry non-coherent requests)
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal dma_snd_atleast_4slots     : std_ulogic;
  signal dma_snd_exactly_3slots     : std_ulogic;
  signal cpu_dma_rcv_rdreq          : std_ulogic;
  signal cpu_dma_rcv_data_out       : noc_flit_type;
  signal cpu_dma_rcv_empty          : std_ulogic;
  signal cpu_dma_snd_wrreq          : std_ulogic;
  signal cpu_dma_snd_data_in        : noc_flit_type;
  signal cpu_dma_snd_full           : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_data_in   : noc_flit_type;
  signal coherent_dma_snd_full      : std_ulogic;
  signal coherent_dma_snd_atleast_4slots : std_ulogic;
  signal coherent_dma_snd_exactly_3slots : std_ulogic;
  -- These requests are delivered through NoC5 (32 bits always)
  -- however, the proxy that handles expects a flit size in
  -- accordance with ARCH_BITS. Hence we need to pad and move
  -- header info and preamble to the right bit position
  signal remote_ahbs_rcv_rdreq      : std_ulogic;
  signal remote_ahbs_rcv_data_out   : misc_noc_flit_type;
  signal remote_ahbs_rcv_empty      : std_ulogic;
  signal remote_ahbs_snd_wrreq      : std_ulogic;
  signal remote_ahbs_snd_data_in    : misc_noc_flit_type;
  signal remote_ahbs_snd_full       : std_ulogic;
  -- Extended remote_ahbs_* signals that
  signal remote_ahbm_rcv_rdreq      : std_ulogic;
  signal remote_ahbm_rcv_data_out   : noc_flit_type;
  signal remote_ahbm_rcv_empty      : std_ulogic;
  signal remote_ahbm_snd_wrreq      : std_ulogic;
  signal remote_ahbm_snd_data_in    : noc_flit_type;
  signal remote_ahbm_snd_full       : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : misc_noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : misc_noc_flit_type;
  signal apb_snd_full               : std_ulogic;


  -- Bus
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector;
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector;
  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector;

  -- Mon
  signal mon_mem_int  : monitor_mem_type;
  signal mon_dvfs_int : monitor_dvfs_type;
  signal mon_noc      : monitor_noc_vector(1 to 6);
  signal noc1_mon_noc_vec_int  : monitor_noc_type;
  signal noc2_mon_noc_vec_int  : monitor_noc_type;
  signal noc3_mon_noc_vec_int  : monitor_noc_type;
  signal noc4_mon_noc_vec_int  : monitor_noc_type;
  signal noc5_mon_noc_vec_int  : monitor_noc_type;
  signal noc6_mon_noc_vec_int  : monitor_noc_type;

  -- Tile parameters
  signal config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_slm_id     : integer range 0 to CFG_NSLM_TILE;
  signal this_slm_hindex : integer range 0 to NAHBSLV - 1;
  signal this_slm_haddr  : integer range 0 to 4095;
  signal this_slm_hmask  : integer range 0 to 4095;

  signal this_csr_pindex   : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig  : apb_config_type;

  signal this_local_y      : local_yx;
  signal this_local_x      : local_yx;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    others => '0');

  constant this_local_ahb_en : std_logic_vector(0 to NAHBSLV - 1) := (
    0      => '1',                      -- SLM
    others => '0');


  -- Noc signals
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_mem_stop_in       : std_ulogic;
  signal noc1_mem_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_mem_data_void_in  : std_ulogic;
  signal noc1_mem_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_mem_stop_in       : std_ulogic;
  signal noc2_mem_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_mem_data_void_in  : std_ulogic;
  signal noc2_mem_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_mem_stop_in       : std_ulogic;
  signal noc3_mem_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_mem_data_void_in  : std_ulogic;
  signal noc3_mem_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_mem_stop_in       : std_ulogic;
  signal noc4_mem_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_mem_data_void_in  : std_ulogic;
  signal noc4_mem_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_mem_stop_in       : std_ulogic;
  signal noc5_mem_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_mem_data_void_in  : std_ulogic;
  signal noc5_mem_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_mem_stop_in       : std_ulogic;
  signal noc6_mem_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_mem_data_void_in  : std_ulogic;
  signal noc6_mem_data_void_out : std_ulogic;
  signal noc1_input_port        : noc_flit_type;
  signal noc2_input_port        : noc_flit_type;
  signal noc3_input_port        : noc_flit_type;
  signal noc4_input_port        : noc_flit_type;
  signal noc5_input_port        : misc_noc_flit_type;
  signal noc6_input_port        : noc_flit_type;
  signal noc1_output_port       : noc_flit_type;
  signal noc2_output_port       : noc_flit_type;
  signal noc3_output_port       : noc_flit_type;
  signal noc4_output_port       : noc_flit_type;
  signal noc5_output_port       : misc_noc_flit_type;
  signal noc6_output_port       : noc_flit_type;

begin

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id           <= to_integer(unsigned(config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));

  this_slm_id       <= tile_slm_id(tile_id);
  this_slm_hindex   <= slm_hindex(this_slm_id);
  this_slm_haddr    <= slm_haddr(this_slm_id);
  this_slm_hmask    <= slm_hmask(this_slm_id);

  this_csr_pindex   <= tile_csr_pindex(tile_id);
  this_csr_pconfig  <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y      <= tile_y(tile_id);
  this_local_x      <= tile_x(tile_id);

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_mem_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_mem_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_mem_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_mem_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_mem_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_mem_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_mem_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_mem_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_mem_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_mem_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_mem_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_mem_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_mem_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_mem_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_mem_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_mem_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_mem_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_mem_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_mem_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_mem_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_mem_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_mem_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_mem_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_mem_data_void_out <= noc6_data_void_out_s(4);

  sync_noc_set_mem: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
     HAS_SYNC => HAS_SYNC )
   port map (
     clk                => sys_clk_int,
     clk_tile           => clk,
     rst                => rst,
     CONST_local_x      => this_local_x,
     CONST_local_y      => this_local_y,
     noc1_data_n_in     => noc1_data_n_in,
     noc1_data_s_in     => noc1_data_s_in,
     noc1_data_w_in     => noc1_data_w_in,
     noc1_data_e_in     => noc1_data_e_in,
     noc1_input_port    => noc1_input_port,
     noc1_data_void_in  => noc1_data_void_in_s,
     noc1_stop_in       => noc1_stop_in_s,
     noc1_data_n_out    => noc1_data_n_out,
     noc1_data_s_out    => noc1_data_s_out,
     noc1_data_w_out    => noc1_data_w_out,
     noc1_data_e_out    => noc1_data_e_out,
     noc1_output_port   => noc1_output_port,
     noc1_data_void_out => noc1_data_void_out_s,
     noc1_stop_out      => noc1_stop_out_s,
     noc2_data_n_in     => noc2_data_n_in,
     noc2_data_s_in     => noc2_data_s_in,
     noc2_data_w_in     => noc2_data_w_in,
     noc2_data_e_in     => noc2_data_e_in,
     noc2_input_port    => noc2_input_port,
     noc2_data_void_in  => noc2_data_void_in_s,
     noc2_stop_in       => noc2_stop_in_s,
     noc2_data_n_out    => noc2_data_n_out,
     noc2_data_s_out    => noc2_data_s_out,
     noc2_data_w_out    => noc2_data_w_out,
     noc2_data_e_out    => noc2_data_e_out,
     noc2_output_port   => noc2_output_port,
     noc2_data_void_out => noc2_data_void_out_s,
     noc2_stop_out      => noc2_stop_out_s,
     noc3_data_n_in     => noc3_data_n_in,
     noc3_data_s_in     => noc3_data_s_in,
     noc3_data_w_in     => noc3_data_w_in,
     noc3_data_e_in     => noc3_data_e_in,
     noc3_input_port    => noc3_input_port,
     noc3_data_void_in  => noc3_data_void_in_s,
     noc3_stop_in       => noc3_stop_in_s,
     noc3_data_n_out    => noc3_data_n_out,
     noc3_data_s_out    => noc3_data_s_out,
     noc3_data_w_out    => noc3_data_w_out,
     noc3_data_e_out    => noc3_data_e_out,
     noc3_output_port   => noc3_output_port,
     noc3_data_void_out => noc3_data_void_out_s,
     noc3_stop_out      => noc3_stop_out_s,
     noc4_data_n_in     => noc4_data_n_in,
     noc4_data_s_in     => noc4_data_s_in,
     noc4_data_w_in     => noc4_data_w_in,
     noc4_data_e_in     => noc4_data_e_in,
     noc4_input_port    => noc4_input_port,
     noc4_data_void_in  => noc4_data_void_in_s,
     noc4_stop_in       => noc4_stop_in_s,
     noc4_data_n_out    => noc4_data_n_out,
     noc4_data_s_out    => noc4_data_s_out,
     noc4_data_w_out    => noc4_data_w_out,
     noc4_data_e_out    => noc4_data_e_out,
     noc4_output_port   => noc4_output_port,
     noc4_data_void_out => noc4_data_void_out_s,
     noc4_stop_out      => noc4_stop_out_s,
     noc5_data_n_in     => noc5_data_n_in,
     noc5_data_s_in     => noc5_data_s_in,
     noc5_data_w_in     => noc5_data_w_in,
     noc5_data_e_in     => noc5_data_e_in,
     noc5_input_port    => noc5_input_port,
     noc5_data_void_in  => noc5_data_void_in_s,
     noc5_stop_in       => noc5_stop_in_s,
     noc5_data_n_out    => noc5_data_n_out,
     noc5_data_s_out    => noc5_data_s_out,
     noc5_data_w_out    => noc5_data_w_out,
     noc5_data_e_out    => noc5_data_e_out,
     noc5_output_port   => noc5_output_port,
     noc5_data_void_out => noc5_data_void_out_s,
     noc5_stop_out      => noc5_stop_out_s,
     noc6_data_n_in     => noc6_data_n_in,
     noc6_data_s_in     => noc6_data_s_in,
     noc6_data_w_in     => noc6_data_w_in,
     noc6_data_e_in     => noc6_data_e_in,
     noc6_input_port    => noc6_input_port,
     noc6_data_void_in  => noc6_data_void_in_s,
     noc6_stop_in       => noc6_stop_in_s,
     noc6_data_n_out    => noc6_data_n_out,
     noc6_data_s_out    => noc6_data_s_out,
     noc6_data_w_out    => noc6_data_w_out,
     noc6_data_e_out    => noc6_data_e_out,
     noc6_output_port   => noc6_output_port,
     noc6_data_void_out => noc6_data_void_out_s,
     noc6_stop_out      => noc6_stop_out_s,
     noc1_mon_noc_vec   => noc1_mon_noc_vec_int,
     noc2_mon_noc_vec   => noc2_mon_noc_vec_int,
     noc3_mon_noc_vec   => noc3_mon_noc_vec_int,
     noc4_mon_noc_vec   => noc4_mon_noc_vec_int,
     noc5_mon_noc_vec   => noc5_mon_noc_vec_int,
     noc6_mon_noc_vec   => noc6_mon_noc_vec_int

     );

  -----------------------------------------------------------------------------
  -- Bus
  -----------------------------------------------------------------------------

  ahb2 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => 0, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk, ahbmi, ahbmo, ahbsi, ahbso);


  -----------------------------------------------------------------------
  ---  Drive unused bus ports
  -----------------------------------------------------------------------

  no_hmst_gen : for i in 2 to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

  no_hslv_gen : for i in 0 to NAHBSLV - 1 generate
    no_hslv_i_gen : if this_local_ahb_en(i) = '0' generate
      ahbso(i) <= ahbs_none;
    end generate no_hslv_i_gen;
  end generate;

  no_pslv_gen : for i in 0 to NAPBSLV - 1 generate
    no_pslv_i_gen : if this_local_apb_en(i) = '0' generate
      apbo(i) <= apb_none;
    end generate no_pslv_i_gen;
  end generate no_pslv_gen;

  -----------------------------------------------------------------------------
  -- Local devices
  -----------------------------------------------------------------------------

  -- Shared Local Memory (SLM)
  ahbslm_1: ahbslm
    generic map (
      hindex => 0,
      tech   => CFG_FABTECH,
      mbytes => CFG_SLM_MBYTES)
    port map (
      rst    => rst,
      clk    => clk,
      haddr  => this_slm_haddr,
      hmask  => this_slm_hmask,
      ahbsi  => ahbsi,
      ahbso  => ahbso(0));


  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  -- DVFS monitor
  mon_dvfs_int.vf        <= "1000";         --run at highest frequency always
  mon_dvfs_int.transient <= '0';
  mon_dvfs_int.clk       <= clk;
  mon_dvfs_int.acc_idle  <= '0';
  mon_dvfs_int.traffic   <= '0';
  mon_dvfs_int.burst     <= '0';

  mon_dvfs <= mon_dvfs_int;

  -- Memory access monitor
  mon_mem_int.clk              <= clk;
  mon_mem_int.coherent_req     <= '0';
  mon_mem_int.coherent_fwd     <= '0';
  mon_mem_int.coherent_rsp_rcv <= '0';
  mon_mem_int.coherent_rsp_snd <= '0';
  -- we can allow Ethernet to use the SLM and Ethernet operates on the
  -- coherent DMA queues when LLC is enabled. Nevertheless, when using SLM,
  -- Ethernet data will not be cached, hence any activity on the coherent DMA
  -- queues is still reported as non-coherent DMA for this tile.
  mon_mem_int.dma_req          <= dma_rcv_rdreq or cpu_dma_rcv_rdreq or coherent_dma_rcv_rdreq;
  mon_mem_int.dma_rsp          <= dma_snd_wrreq or cpu_dma_snd_wrreq or coherent_dma_snd_wrreq;
  mon_mem_int.coherent_dma_req <= '0';
  mon_mem_int.coherent_dma_rsp <= '0';
  
  mon_mem <= mon_mem_int;

  noc1_mon_noc_vec <= noc1_mon_noc_vec_int;
  noc2_mon_noc_vec <= noc2_mon_noc_vec_int;
  noc3_mon_noc_vec <= noc3_mon_noc_vec_int;
  noc4_mon_noc_vec <= noc4_mon_noc_vec_int;
  noc5_mon_noc_vec <= noc5_mon_noc_vec_int;
  noc6_mon_noc_vec <= noc6_mon_noc_vec_int;
 
  mon_noc(1) <= noc1_mon_noc_vec_int;
  mon_noc(2) <= noc2_mon_noc_vec_int;
  mon_noc(3) <= noc3_mon_noc_vec_int;
  mon_noc(4) <= noc4_mon_noc_vec_int;
  mon_noc(5) <= noc5_mon_noc_vec_int;
  mon_noc(6) <= noc6_mon_noc_vec_int;
 
  -- Memory mapped registers
  slm_tile_csr : esp_tile_csr
    generic map(
      pindex  => 0)
    port map(
      clk => clk,
      rstn => rst,
      pconfig => this_csr_pconfig,
      mon_ddr => monitor_ddr_none,
      mon_mem => mon_mem_int,
      mon_noc => mon_noc,
      mon_l2 => monitor_cache_none,
      mon_llc => monitor_cache_none,
      mon_acc => monitor_acc_none,
      mon_dvfs => mon_dvfs_int,
      config => config,
      srst => open,
      apbi => apbi,
      apbo => apbo(0)
    );

  -----------------------------------------------------------------------------
  -- Proxies
  -----------------------------------------------------------------------------

  -- FROM NoC

  -- Hendle CPU requests accelerator DMA and Ethernet (non coherent only)
  mem_noc2ahbm_1 : mem_noc2ahbm
    generic map (
      tech        => CFG_FABTECH,
      hindex      => 0,
      axitran     => GLOB_CPU_AXI,
      little_end  => 0,
      eth_dma     => 0,
      narrow_noc  => 0,
      cacheline   => 1,
      l2_cache_en => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
      local_y                   => this_local_y,
      local_x                   => this_local_x,
      ahbmi                     => ahbmi,
      ahbmo                     => ahbmo(0),
      coherence_req_rdreq       => cpu_dma_rcv_rdreq,
      coherence_req_data_out    => cpu_dma_rcv_data_out,
      coherence_req_empty       => cpu_dma_rcv_empty,
      coherence_fwd_wrreq       => open,
      coherence_fwd_data_in     => open,
      coherence_fwd_full        => '0',
      coherence_rsp_snd_wrreq   => cpu_dma_snd_wrreq,
      coherence_rsp_snd_data_in => cpu_dma_snd_data_in,
      coherence_rsp_snd_full    => cpu_dma_snd_full,
      dma_rcv_rdreq             => dma_rcv_rdreq,
      dma_rcv_data_out          => dma_rcv_data_out,
      dma_rcv_empty             => dma_rcv_empty,
      dma_snd_wrreq             => dma_snd_wrreq,
      dma_snd_data_in           => dma_snd_data_in,
      dma_snd_full              => dma_snd_full,
      dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots    => dma_snd_exactly_3slots);

  -- Handle JTAG or EDCL requests to memory as well as Ethernet coherent DMA
  mem_noc2ahbm_2 : mem_noc2ahbm
    generic map (
      tech        => CFG_FABTECH,
      hindex      => 1,
      axitran     => 0,
      little_end  => 0,
      eth_dma     => 1,               -- Exception for fixed 32-bits DMA
      narrow_noc  => 0,
      cacheline   => 1,
      l2_cache_en => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
      local_y                   => this_local_y,
      local_x                   => this_local_x,
      ahbmi                     => ahbmi,
      ahbmo                     => ahbmo(1),
      coherence_req_rdreq       => remote_ahbm_rcv_rdreq,
      coherence_req_data_out    => remote_ahbm_rcv_data_out,
      coherence_req_empty       => remote_ahbm_rcv_empty,
      coherence_fwd_wrreq       => open,
      coherence_fwd_data_in     => open,
      coherence_fwd_full        => '0',
      coherence_rsp_snd_wrreq   => remote_ahbm_snd_wrreq,
      coherence_rsp_snd_data_in => remote_ahbm_snd_data_in,
      coherence_rsp_snd_full    => remote_ahbm_snd_full,
      -- These requests are treated as non-coherent when no LLC is present!
      dma_rcv_rdreq             => coherent_dma_rcv_rdreq,
      dma_rcv_data_out          => coherent_dma_rcv_data_out,
      dma_rcv_empty             => coherent_dma_rcv_empty,
      dma_snd_wrreq             => coherent_dma_snd_wrreq,
      dma_snd_data_in           => coherent_dma_snd_data_in,
      dma_snd_full              => coherent_dma_snd_full,
      dma_snd_atleast_4slots    => coherent_dma_snd_atleast_4slots,
      dma_snd_exactly_3slots    => coherent_dma_snd_exactly_3slots);

  remote_ahbs_rcv_rdreq <= remote_ahbm_rcv_rdreq;
  remote_ahbm_rcv_empty <= remote_ahbs_rcv_empty;
  remote_ahbs_snd_wrreq <= remote_ahbm_snd_wrreq;
  remote_ahbm_snd_full  <= remote_ahbs_snd_full;

  large_bus: if ARCH_BITS /= 32 generate
    remote_ahbm_rcv_data_out <= narrow_to_large_flit(remote_ahbs_rcv_data_out);
    remote_ahbs_snd_data_in <= large_to_narrow_flit(remote_ahbm_snd_data_in);
  end generate large_bus;

  std_bus: if ARCH_BITS = 32 generate
    remote_ahbm_rcv_data_out <= remote_ahbs_rcv_data_out;
    remote_ahbs_snd_data_in  <= remote_ahbm_snd_data_in;
  end generate std_bus;


  -- Handle APB requests for CSRs
  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => apbi,
      apbo             => apbo,
      pready           => '1',
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  slm_tile_q_1 : slm_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => clk,
      dma_rcv_rdreq              => dma_rcv_rdreq,
      dma_rcv_data_out           => dma_rcv_data_out,
      dma_rcv_empty              => dma_rcv_empty,
      cpu_dma_rcv_rdreq          => cpu_dma_rcv_rdreq,
      cpu_dma_rcv_data_out       => cpu_dma_rcv_data_out,
      cpu_dma_rcv_empty          => cpu_dma_rcv_empty,
      coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq,
      coherent_dma_snd_data_in   => coherent_dma_snd_data_in,
      coherent_dma_snd_full      => coherent_dma_snd_full,
      coherent_dma_snd_atleast_4slots => coherent_dma_snd_atleast_4slots,
      coherent_dma_snd_exactly_3slots => coherent_dma_snd_exactly_3slots,
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      dma_snd_atleast_4slots     => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots     => dma_snd_exactly_3slots,
      cpu_dma_snd_wrreq          => cpu_dma_snd_wrreq,
      cpu_dma_snd_data_in        => cpu_dma_snd_data_in,
      cpu_dma_snd_full           => cpu_dma_snd_full,
      coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq,
      coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty     => coherent_dma_rcv_empty,
      remote_ahbs_rcv_rdreq      => remote_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => remote_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => remote_ahbs_rcv_empty,
      remote_ahbs_snd_wrreq      => remote_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => remote_ahbs_snd_data_in,
      remote_ahbs_snd_full       => remote_ahbs_snd_full,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      noc1_out_data              => noc1_output_port,
      noc1_out_void              => noc1_mem_data_void_out,
      noc1_out_stop              => noc1_mem_stop_in,
      noc1_in_data               => noc1_input_port,
      noc1_in_void               => noc1_mem_data_void_in,
      noc1_in_stop               => noc1_mem_stop_out,
      noc2_out_data              => noc2_output_port,
      noc2_out_void              => noc2_mem_data_void_out,
      noc2_out_stop              => noc2_mem_stop_in,
      noc2_in_data               => noc2_input_port,
      noc2_in_void               => noc2_mem_data_void_in,
      noc2_in_stop               => noc2_mem_stop_out,
      noc3_out_data              => noc3_output_port,
      noc3_out_void              => noc3_mem_data_void_out,
      noc3_out_stop              => noc3_mem_stop_in,
      noc3_in_data               => noc3_input_port,
      noc3_in_void               => noc3_mem_data_void_in,
      noc3_in_stop               => noc3_mem_stop_out,
      noc4_out_data              => noc4_output_port,
      noc4_out_void              => noc4_mem_data_void_out,
      noc4_out_stop              => noc4_mem_stop_in,
      noc4_in_data               => noc4_input_port,
      noc4_in_void               => noc4_mem_data_void_in,
      noc4_in_stop               => noc4_mem_stop_out,
      noc5_out_data              => noc5_output_port,
      noc5_out_void              => noc5_mem_data_void_out,
      noc5_out_stop              => noc5_mem_stop_in,
      noc5_in_data               => noc5_input_port,
      noc5_in_void               => noc5_mem_data_void_in,
      noc5_in_stop               => noc5_mem_stop_out,
      noc6_out_data              => noc6_output_port,
      noc6_out_void              => noc6_mem_data_void_out,
      noc6_out_stop              => noc6_mem_stop_in,
      noc6_in_data               => noc6_input_port,
      noc6_in_void               => noc6_mem_data_void_in,
      noc6_in_stop               => noc6_mem_stop_out);

end;
