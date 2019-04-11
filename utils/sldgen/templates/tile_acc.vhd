-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

-----------------------------------------------------------------------------
--  Accelerator Tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.coretypes.all;
use work.acctypes.all;
use work.socmap.all;
use work.grlib_config.all;

entity tile_acc is
  generic (
    tile_id : integer range 0 to CFG_TILES_NUM - 1 := 0);
  port (
    rst                : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    -- NOC
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
    noc5_input_port    : out misc_noc_flit_type;
    noc5_data_void_in  : out std_ulogic;
    noc5_stop_in       : out std_ulogic;
    noc5_output_port   : in  misc_noc_flit_type;
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
    mon_cache          : out monitor_cache_type;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of tile_acc is

  signal clk_feedthru : std_ulogic;

  signal coherence_req_wrreq        : std_ulogic;
  signal coherence_req_data_in      : noc_flit_type;
  signal coherence_req_full         : std_ulogic;
  signal coherence_fwd_rdreq        : std_ulogic;
  signal coherence_fwd_data_out     : noc_flit_type;
  signal coherence_fwd_empty        : std_ulogic;
  signal coherence_rsp_rcv_rdreq    : std_ulogic;
  signal coherence_rsp_rcv_data_out : noc_flit_type;
  signal coherence_rsp_rcv_empty    : std_ulogic;
  signal coherence_rsp_snd_wrreq    : std_ulogic;
  signal coherence_rsp_snd_data_in  : noc_flit_type;
  signal coherence_rsp_snd_full     : std_ulogic;
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_data_in   : noc_flit_type;
  signal coherent_dma_snd_full      : std_ulogic;
  signal interrupt_wrreq            : std_ulogic;
  signal interrupt_data_in          : misc_noc_flit_type;
  signal interrupt_full             : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : misc_noc_flit_type;
  signal apb_snd_full               : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : misc_noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;

  -- Tile parameters
  constant this_hls_conf       : hlscfg_t                           := tile_design_point(tile_id);
  constant this_local_y        : local_yx                           := tile_y(tile_id);
  constant this_local_x        : local_yx                           := tile_x(tile_id);
  constant io_y                : local_yx                           := tile_y(io_tile_id);
  constant io_x                : local_yx                           := tile_x(io_tile_id);
  constant this_device         : devid_t                            := tile_device(tile_id);
  constant this_pindex         : integer                            := tile_apb_idx(tile_id);
  constant this_paddr          : integer                            := tile_apb_paddr(tile_id);
  constant this_pmask          : integer                            := tile_apb_pmask(tile_id);
  constant this_pirq           : integer                            := tile_apb_irq(tile_id);
  constant this_scatter_gather : integer range 0 to 1               := tile_scatter_gather(tile_id);
  constant this_local_apb_mask : std_logic_vector(0 to NAPBSLV - 1) := local_apb_mask(tile_id);
  constant this_has_l2         : integer                            := tile_has_l2(tile_id);
  constant this_has_dvfs       : integer                            := tile_has_dvfs(tile_id);
  constant this_has_pll        : integer                            := tile_has_pll(tile_id);
  constant this_extra_clk_buf  : integer                            := extra_clk_buf(tile_id);
  constant this_domain         : integer                            := tile_domain(tile_id);


  -- attribute mark_debug : string;

  -- attribute mark_debug of coherence_req_wrreq        : signal is "true";
  -- attribute mark_debug of coherence_req_data_in      : signal is "true";
  -- attribute mark_debug of coherence_req_full         : signal is "true";
  -- attribute mark_debug of coherence_fwd_rdreq        : signal is "true";
  -- attribute mark_debug of coherence_fwd_data_out     : signal is "true";
  -- attribute mark_debug of coherence_fwd_empty        : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_rdreq    : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_data_out : signal is "true";
  -- attribute mark_debug of coherence_rsp_rcv_empty    : signal is "true";
  -- attribute mark_debug of coherence_rsp_snd_wrreq    : signal is "true";
  -- attribute mark_debug of coherence_rsp_snd_data_in  : signal is "true";
  -- attribute mark_debug of coherence_rsp_snd_full     : signal is "true";
  -- attribute mark_debug of dma_rcv_rdreq              : signal is "true";
  -- attribute mark_debug of dma_rcv_data_out           : signal is "true";
  -- attribute mark_debug of dma_rcv_empty              : signal is "true";
  -- attribute mark_debug of dma_snd_wrreq              : signal is "true";
  -- attribute mark_debug of dma_snd_data_in            : signal is "true";
  -- attribute mark_debug of dma_snd_full               : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_rdreq     : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_data_out  : signal is "true";
  -- attribute mark_debug of coherent_dma_rcv_empty     : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_wrreq     : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_data_in   : signal is "true";
  -- attribute mark_debug of coherent_dma_snd_full      : signal is "true";
  -- attribute mark_debug of interrupt_wrreq            : signal is "true";
  -- attribute mark_debug of interrupt_data_in          : signal is "true";
  -- attribute mark_debug of interrupt_full             : signal is "true";
  -- attribute mark_debug of apb_snd_wrreq              : signal is "true";
  -- attribute mark_debug of apb_snd_data_in            : signal is "true";
  -- attribute mark_debug of apb_snd_full               : signal is "true";
  -- attribute mark_debug of apb_rcv_rdreq              : signal is "true";
  -- attribute mark_debug of apb_rcv_data_out           : signal is "true";
  -- attribute mark_debug of apb_rcv_empty              : signal is "true";

begin

  pllclk <= clk_feedthru;


-------------------------------------------------------------------------------
-- ACCELERATOR ----------------------------------------------------------------
-------------------------------------------------------------------------------

  -- <<accelerator-wrappers-gen>>

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  acc_tile_q_1 : acc_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => clk_feedthru,
      coherence_req_wrreq        => coherence_req_wrreq,
      coherence_req_data_in      => coherence_req_data_in,
      coherence_req_full         => coherence_req_full,
      coherence_fwd_rdreq        => coherence_fwd_rdreq,
      coherence_fwd_data_out     => coherence_fwd_data_out,
      coherence_fwd_empty        => coherence_fwd_empty,
      coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
      coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
      coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
      coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
      coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
      coherence_rsp_snd_full     => coherence_rsp_snd_full,
      dma_rcv_rdreq              => dma_rcv_rdreq,
      dma_rcv_data_out           => dma_rcv_data_out,
      dma_rcv_empty              => dma_rcv_empty,
      coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq,
      coherent_dma_snd_data_in   => coherent_dma_snd_data_in,
      coherent_dma_snd_full      => coherent_dma_snd_full,
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq,
      coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty     => coherent_dma_rcv_empty,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      interrupt_wrreq            => interrupt_wrreq,
      interrupt_data_in          => interrupt_data_in,
      interrupt_full             => interrupt_full,
      noc1_out_data              => noc1_output_port,
      noc1_out_void              => noc1_data_void_out,
      noc1_out_stop              => noc1_stop_in,
      noc1_in_data               => noc1_input_port,
      noc1_in_void               => noc1_data_void_in,
      noc1_in_stop               => noc1_stop_out,
      noc2_out_data              => noc2_output_port,
      noc2_out_void              => noc2_data_void_out,
      noc2_out_stop              => noc2_stop_in,
      noc2_in_data               => noc2_input_port,
      noc2_in_void               => noc2_data_void_in,
      noc2_in_stop               => noc1_stop_out,
      noc3_out_data              => noc3_output_port,
      noc3_out_void              => noc3_data_void_out,
      noc3_out_stop              => noc3_stop_in,
      noc3_in_data               => noc3_input_port,
      noc3_in_void               => noc3_data_void_in,
      noc3_in_stop               => noc3_stop_out,
      noc4_out_data              => noc4_output_port,
      noc4_out_void              => noc4_data_void_out,
      noc4_out_stop              => noc4_stop_in,
      noc4_in_data               => noc4_input_port,
      noc4_in_void               => noc4_data_void_in,
      noc4_in_stop               => noc4_stop_out,
      noc5_out_data              => noc5_output_port,
      noc5_out_void              => noc5_data_void_out,
      noc5_out_stop              => noc5_stop_in,
      noc5_in_data               => noc5_input_port,
      noc5_in_void               => noc5_data_void_in,
      noc5_in_stop               => noc5_stop_out,
      noc6_out_data              => noc6_output_port,
      noc6_out_void              => noc6_data_void_out,
      noc6_out_stop              => noc6_stop_in,
      noc6_in_data               => noc6_input_port,
      noc6_in_void               => noc6_data_void_in,
      noc6_in_stop               => noc6_stop_out);

end;

