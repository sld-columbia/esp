-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

-----------------------------------------------------------------------------
--  Memory interface tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
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

entity tile_mem is
  generic (
    tile_id : integer range 0 to CFG_TILES_NUM - 1 := 0);
  port (
    rst                : in  std_ulogic;
    clk                : in  std_ulogic;
    ddr_ahbsi          : out ahb_slv_in_type;
    ddr_ahbso          : in  ahb_slv_out_type;
    --TODO: REMOVE THIS!
    dbgi               : in  l3_debug_in_type;
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
end;


architecture rtl of tile_mem is

  -- LLC
  signal llc_rstn : std_ulogic;

  -- Queues
  signal coherence_req_rdreq        : std_ulogic;
  signal coherence_req_data_out     : noc_flit_type;
  signal coherence_req_empty        : std_ulogic;
  signal coherence_fwd_wrreq        : std_ulogic;
  signal coherence_fwd_data_in      : noc_flit_type;
  signal coherence_fwd_full         : std_ulogic;
  signal coherence_rsp_snd_wrreq    : std_ulogic;
  signal coherence_rsp_snd_data_in  : noc_flit_type;
  signal coherence_rsp_snd_full     : std_ulogic;
  signal coherence_rsp_rcv_rdreq    : std_ulogic;
  signal coherence_rsp_rcv_data_out : noc_flit_type;
  signal coherence_rsp_rcv_empty    : std_ulogic;
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal dma_snd_atleast_4slots     : std_ulogic;
  signal dma_snd_exactly_3slots     : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_data_in   : noc_flit_type;
  signal coherent_dma_snd_full      : std_ulogic;
  signal remote_ahbm_rcv_rdreq      : std_ulogic;
  signal remote_ahbm_rcv_data_out   : noc_flit_type;
  signal remote_ahbm_rcv_empty      : std_ulogic;
  signal remote_ahbm_snd_wrreq      : std_ulogic;
  signal remote_ahbm_snd_data_in    : noc_flit_type;
  signal remote_ahbm_snd_full       : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : noc_flit_type;
  signal apb_snd_full               : std_ulogic;

  -- Bus
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector;
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector;
  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector;

  signal ctrl_ahbsi : ahb_slv_in_type;
  signal ctrl_ahbso : ahb_slv_out_vector;
  signal ctrl_ahbmi : ahb_mst_in_type;
  signal ctrl_ahbmo : ahb_mst_out_vector;
  signal ctrl_apbi  : apb_slv_in_type;
  signal ctrl_apbo  : apb_slv_out_vector;

  -- Tile parameters
  constant this_mem_id       : integer                            := tile_mem_id(tile_id);
  constant this_ddr_hindex   : integer                            := ddr_hindex(this_mem_id);
  constant this_llc_pindex   : integer                            := llc_cache_pindex(tile_id);
  constant this_llc_pconfig  : apb_config_type                    := fixed_apbo_pconfig(this_llc_pindex);
  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := local_apb_mask(tile_id);
  constant this_local_ahb_en : std_logic_vector(0 to NAHBSLV - 1) := local_ahb_mask(tile_id);
  constant this_local_y      : local_yx                           := tile_y(tile_id);
  constant this_local_x      : local_yx                           := tile_x(tile_id);

begin

  -----------------------------------------------------------------------------
  -- Bus
  -----------------------------------------------------------------------------

  hp_pandp_gen : process (ctrl_ahbmi, ctrl_ahbsi, ahbmo, ahbso)
  begin  -- process assign_bus_ctrl_sig
    ahbmi      <= ctrl_ahbmi;
    ahbsi      <= ctrl_ahbsi;
    ctrl_ahbmo <= ahbmo;
    ctrl_ahbso <= ahbso;

    for i in 0 to NAHBSLV - 1 loop
      if this_local_ahb_en(i) = '1' then
        ctrl_ahbso(i).hconfig <= fixed_ahbso_hconfig(i);
      else
        ctrl_ahbso(i).hconfig <= hconfig_none;
      end if;
    end loop;  -- i
  end process hp_pandp_gen;

  ahb2 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk, ctrl_ahbmi, ctrl_ahbmo, ctrl_ahbsi, ctrl_ahbso);


  io_pandp_gen : process (ctrl_apbi, apbo)
  begin  -- process assign_bus_ctrl_sig
    apbi      <= ctrl_apbi;
    ctrl_apbo <= apbo;

    for i in 0 to NAPBSLV - 1 loop
      if this_local_apb_en(i) = '1' then
        ctrl_apbo(i).pconfig <= fixed_apbo_pconfig(i);
      else
        ctrl_apbo(i).pconfig <= pconfig_none;
      end if;
    end loop;  -- i
  end process io_pandp_gen;

  -----------------------------------------------------------------------
  ---  Drive unused bus ports
  -----------------------------------------------------------------------

  no_hmst_gen : for i in 3 to NAHBMST-1 generate
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

  -- DDR Controller
  ahbso(this_ddr_hindex) <= ddr_ahbso;
  ddr_ahbsi              <= ahbsi;


  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  -- DVFS monitor
  mon_dvfs.vf        <= "1000";         --run at highest frequency always
  mon_dvfs.transient <= '0';
  mon_dvfs.clk       <= clk;
  mon_dvfs.acc_idle  <= '0';
  mon_dvfs.traffic   <= '0';
  mon_dvfs.burst     <= '0';

  -- Memory access monitor
  mon_mem.clk              <= clk;
  mon_mem.coherent_req     <= coherence_req_rdreq;
  mon_mem.coherent_fwd     <= coherence_fwd_wrreq;
  mon_mem.coherent_rsp_rcv <= coherence_rsp_rcv_rdreq;
  mon_mem.coherent_rsp_snd <= coherence_rsp_snd_wrreq;
  mon_mem.dma_req          <= dma_rcv_rdreq;
  mon_mem.dma_rsp          <= dma_snd_wrreq;
  mon_mem.coherent_dma_req <= coherent_dma_rcv_rdreq;
  mon_mem.coherent_dma_rsp <= coherent_dma_snd_wrreq;

  -----------------------------------------------------------------------------
  -- Proxies
  -----------------------------------------------------------------------------

  -- FROM NoC
  no_cache_coherence : if CFG_LLC_ENABLE = 0 generate

    mem_noc2ahbm_1 : mem_noc2ahbm
      generic map (
        tech        => CFG_FABTECH,
        hindex      => 0,
        local_y     => this_local_y,
        local_x     => this_local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE)
      port map (
        rst                       => rst,
        clk                       => clk,
        ahbmi                     => ahbmi,
        ahbmo                     => ahbmo(0),
        coherence_req_rdreq       => coherence_req_rdreq,
        coherence_req_data_out    => coherence_req_data_out,
        coherence_req_empty       => coherence_req_empty,
        coherence_fwd_wrreq       => coherence_fwd_wrreq,
        coherence_fwd_data_in     => coherence_fwd_data_in,
        coherence_fwd_full        => coherence_fwd_full,
        coherence_rsp_snd_wrreq   => coherence_rsp_snd_wrreq,
        coherence_rsp_snd_data_in => coherence_rsp_snd_data_in,
        coherence_rsp_snd_full    => coherence_rsp_snd_full,
        dma_rcv_rdreq             => dma_rcv_rdreq,
        dma_rcv_data_out          => dma_rcv_data_out,
        dma_rcv_empty             => dma_rcv_empty,
        dma_snd_wrreq             => dma_snd_wrreq,
        dma_snd_data_in           => dma_snd_data_in,
        dma_snd_full              => dma_snd_full,
        dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
        dma_snd_exactly_3slots    => dma_snd_exactly_3slots);

    -- No LLC wrapper
    ahbmo(2)                 <= ahbm_none;
    coherent_dma_rcv_rdreq   <= '0';
    coherent_dma_snd_wrreq   <= '0';
    coherent_dma_snd_data_in <= (others => '0');

    apbo(this_llc_pindex) <= apb_none;
    mon_cache             <= monitor_cache_none;

    apb_snd_wrreq   <= '0';
    apb_snd_data_in <= (others => '0');
    apb_rcv_rdreq   <= '0';

  end generate no_cache_coherence;

  with_cache_coherence : if CFG_LLC_ENABLE /= 0 generate

    mem_noc2ahbm_1 : mem_noc2ahbm
      generic map (
        tech        => CFG_FABTECH,
        hindex      => 0,
        local_y     => this_local_y,
        local_x     => this_local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE)
      port map (
        rst                       => rst,
        clk                       => clk,
        ahbmi                     => ahbmi,
        ahbmo                     => ahbmo(0),
        coherence_req_rdreq       => open,
        coherence_req_data_out    => (others => '0'),
        coherence_req_empty       => '1',
        coherence_fwd_wrreq       => open,
        coherence_fwd_data_in     => open,
        coherence_fwd_full        => '0',
        coherence_rsp_snd_wrreq   => open,
        coherence_rsp_snd_data_in => open,
        coherence_rsp_snd_full    => '0',
        dma_rcv_rdreq             => dma_rcv_rdreq,
        dma_rcv_data_out          => dma_rcv_data_out,
        dma_rcv_empty             => dma_rcv_empty,
        dma_snd_wrreq             => dma_snd_wrreq,
        dma_snd_data_in           => dma_snd_data_in,
        dma_snd_full              => dma_snd_full,
        dma_snd_atleast_4slots    => dma_snd_atleast_4slots,
        dma_snd_exactly_3slots    => dma_snd_exactly_3slots);

    llc_rstn <= not dbgi.reset and rst;

    llc_wrapper_1 : llc_wrapper
      generic map (
        tech          => CFG_MEMTECH,
        sets          => CFG_LLC_SETS,
        ways          => CFG_LLC_WAYS,
        nl2           => CFG_NL2,
        nllc          => CFG_NLLC_COHERENT,
        noc_xlen      => CFG_XLEN,
        hindex        => 2,
        pindex        => this_llc_pindex,
        pirq          => CFG_SLD_LLC_CACHE_IRQ,
        pconfig       => this_llc_pconfig,
        local_y       => this_local_y,
        local_x       => this_local_x,
        cacheline     => CFG_DLINE,
        l2_cache_en   => CFG_L2_ENABLE,
        cache_tile_id => cache_tile_id,
        dma_tile_id   => dma_tile_id,
        tile_cache_id => tile_cache_id,
        tile_dma_id   => tile_dma_id,
        dma_y         => dma_y,
        dma_x         => dma_x,
        cache_y       => cache_y,
        cache_x       => cache_x)
      port map (
        rst                        => llc_rstn,
        clk                        => clk,
        ahbmi                      => ahbmi,
        ahbmo                      => ahbmo(2),
        apbi                       => apbi,
        apbo                       => apbo(this_llc_pindex),
        -- NoC1->tile
        coherence_req_rdreq        => coherence_req_rdreq,
        coherence_req_data_out     => coherence_req_data_out,
        coherence_req_empty        => coherence_req_empty,
        -- tile->NoC2
        coherence_fwd_wrreq        => coherence_fwd_wrreq,
        coherence_fwd_data_in      => coherence_fwd_data_in,
        coherence_fwd_full         => coherence_fwd_full,
        -- tile->NoC3
        coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
        coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
        coherence_rsp_snd_full     => coherence_rsp_snd_full,
        -- NoC3->tile
        coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
        coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
        coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
        -- NoC4->tile
        dma_rcv_rdreq              => coherent_dma_rcv_rdreq,
        dma_rcv_data_out           => coherent_dma_rcv_data_out,
        dma_rcv_empty              => coherent_dma_rcv_empty,
        -- tile->NoC6
        dma_snd_wrreq              => coherent_dma_snd_wrreq,
        dma_snd_data_in            => coherent_dma_snd_data_in,
        dma_snd_full               => coherent_dma_snd_full,
        -- Monitor
        mon_cache                  => mon_cache
        );

    -- APB to LLC cache
    misc_noc2apb_1 : misc_noc2apb
      generic map (
        tech         => CFG_FABTECH,
        local_y      => this_local_y,
        local_x      => this_local_x,
        local_apb_en => this_local_apb_en)
      port map (
        rst              => rst,
        clk              => clk,
        apbi             => ctrl_apbi,
        apbo             => ctrl_apbo,
        dvfs_transient   => '0',
        apb_snd_wrreq    => apb_snd_wrreq,
        apb_snd_data_in  => apb_snd_data_in,
        apb_snd_full     => apb_snd_full,
        apb_rcv_rdreq    => apb_rcv_rdreq,
        apb_rcv_data_out => apb_rcv_data_out,
        apb_rcv_empty    => apb_rcv_empty);

  end generate with_cache_coherence;

  -- FROM JTAG to DDR1
  mem_noc2ahbm_2 : mem_noc2ahbm
    generic map (
      tech        => CFG_FABTECH,
      hindex      => 1,
      local_y     => this_local_y,
      local_x     => this_local_x,
      cacheline   => 1,
      l2_cache_en => 0)
    port map (
      rst                       => rst,
      clk                       => clk,
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
      dma_rcv_rdreq             => open,
      dma_rcv_data_out          => (others => '0'),
      dma_rcv_empty             => '1',
      dma_snd_wrreq             => open,
      dma_snd_data_in           => open,
      dma_snd_full              => '0',
      dma_snd_atleast_4slots    => '1',
      dma_snd_exactly_3slots    => '0');

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------


  mem_tile_q_1 : mem_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => clk,
      coherence_req_rdreq        => coherence_req_rdreq,
      coherence_req_data_out     => coherence_req_data_out,
      coherence_req_empty        => coherence_req_empty,
      coherence_fwd_wrreq        => coherence_fwd_wrreq,
      coherence_fwd_data_in      => coherence_fwd_data_in,
      coherence_fwd_full         => coherence_fwd_full,
      coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
      coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
      coherence_rsp_snd_full     => coherence_rsp_snd_full,
      coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
      coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
      coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
      dma_rcv_rdreq              => dma_rcv_rdreq,
      dma_rcv_data_out           => dma_rcv_data_out,
      dma_rcv_empty              => dma_rcv_empty,
      coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq,
      coherent_dma_snd_data_in   => coherent_dma_snd_data_in,
      coherent_dma_snd_full      => coherent_dma_snd_full,
      dma_snd_wrreq              => dma_snd_wrreq,
      dma_snd_data_in            => dma_snd_data_in,
      dma_snd_full               => dma_snd_full,
      dma_snd_atleast_4slots     => dma_snd_atleast_4slots,
      dma_snd_exactly_3slots     => dma_snd_exactly_3slots,
      coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq,
      coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty     => coherent_dma_rcv_empty,
      remote_ahbs_rcv_rdreq      => remote_ahbm_rcv_rdreq,
      remote_ahbs_rcv_data_out   => remote_ahbm_rcv_data_out,
      remote_ahbs_rcv_empty      => remote_ahbm_rcv_empty,
      remote_ahbs_snd_wrreq      => remote_ahbm_snd_wrreq,
      remote_ahbs_snd_data_in    => remote_ahbm_snd_data_in,
      remote_ahbs_snd_full       => remote_ahbm_snd_full,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
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
