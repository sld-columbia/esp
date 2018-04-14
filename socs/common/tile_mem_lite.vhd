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

entity tile_mem_lite is
  generic (
    fabtech                 : integer := CFG_FABTECH;
    memtech                 : integer := CFG_MEMTECH;
    padtech                 : integer := CFG_PADTECH;
    disas                   : integer := CFG_DISAS;  -- Enable disassembly to console
    dbguart                 : integer := CFG_DUART;  -- Print UART on console
    pclow                   : integer := CFG_PCLOW;
    testahb                 : boolean := false;
    USE_MIG_INTERFACE_MODEL : boolean := false
    );
  port (
    rst                : in  std_ulogic;
    clk                : in  std_ulogic;
    ddr_ahbsi          : out ahb_slv_in_type;
    ddr_ahbso          : in  ahb_slv_out_type;
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
    mon_dvfs           : out monitor_dvfs_type
    );
end;


architecture rtl of tile_mem_lite is

-- constants
  constant vcc : std_logic_vector(31 downto 0) := (others => '1');
  constant gnd : std_logic_vector(31 downto 0) := (others => '0');


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
  signal remote_ahbm_rcv_rdreq    : std_ulogic;
  signal remote_ahbm_rcv_data_out : noc_flit_type;
  signal remote_ahbm_rcv_empty    : std_ulogic;
  signal remote_ahbm_snd_wrreq    : std_ulogic;
  signal remote_ahbm_snd_data_in  : noc_flit_type;
  signal remote_ahbm_snd_full     : std_ulogic;

  signal ahbsi2 : ahb_slv_in_type;
  signal ahbso2 : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi2 : ahb_mst_in_type;
  signal ahbmo2 : ahb_mst_out_vector := (others => ahbm_none);

  signal ctrl_ahbsi2 : ahb_slv_in_type;
  signal ctrl_ahbso2 : ahb_slv_out_vector := (others => ahbs_none);
  signal ctrl_ahbmi2 : ahb_mst_in_type;
  signal ctrl_ahbmo2 : ahb_mst_out_vector := (others => ahbm_none);

  constant local_y : local_yx := tile_mem_1.y;
  constant local_x : local_yx := tile_mem_1.x;

begin


  -----------------------------------------------------------------------------
  -- AMBA2 MST: cpu, JTAG (remote)
  -- AMBA2 SLV: ddr (local)
  -----------------------------------------------------------------------------

  assign_bus_ctrl_sig2 : process (ctrl_ahbmi2, ctrl_ahbsi2,
                                  ahbmo2, ahbso2,
                                  ddr_ahbso)
  begin  -- process assign_bus_ctrl_sig
    ahbmi2      <= ctrl_ahbmi2;
    ahbsi2      <= ctrl_ahbsi2;
    ctrl_ahbmo2 <= ahbmo2;
    ctrl_ahbso2 <= ahbso2;

    ctrl_ahbso2(ddr1_hindex) <= ddr_ahbso;
    ddr_ahbsi                <= ctrl_ahbsi2;

    for i in 0 to NAHBSLV-1 loop
      if i /= ddr0_hindex and i /= fb_hindex then
        ctrl_ahbso2(i).hconfig <= fixed_ahbso_hconfig(i);
      end if;
      if i = ddr0_hindex or i = fb_hindex then
        ctrl_ahbso2(i).hconfig <= hconfig_none;
      end if;
    end loop;  -- i
    --pragma translate_off
    ctrl_ahbso2(ddr1_hindex).hconfig   <= ahbram_sim1_hconfig;
    --pragma translate_on
    ctrl_ahbso2(dsu_hindex).hindex     <= dsu_hindex;
    ctrl_ahbso2(ahb2apb_hindex).hindex <= ahb2apb_hindex;
  end process assign_bus_ctrl_sig2;

  ahb2 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs)
    port map (rst, clk, ctrl_ahbmi2, ctrl_ahbmo2, ctrl_ahbsi2, ctrl_ahbso2);


  -----------------------------------------------------------------------
  ---  Drive unused bus elements  ---------------------------------------
  -----------------------------------------------------------------------

  nam1 : for i in 2 to NAHBMST-1 generate
    ahbmo2(i) <= ahbm_none;
  end generate;

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

  -----------------------------------------------------------------------------
  -- AMBA2 proxies
  -----------------------------------------------------------------------------

  -- FROM NoC
  no_cache_coherence : if CFG_LLC_ENABLE = 0 generate

    mem_noc2ahbm_1 : mem_noc2ahbm
      generic map (
        tech        => fabtech,
        ncpu        => CFG_NCPU_TILE,   --unused
        hindex      => 0,
        local_y     => local_y,
        local_x     => local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE,
        destination => 0)
      port map (
        rst                       => rst,
        clk                       => clk,
        ahbmi                     => ahbmi2,
        ahbmo                     => ahbmo2(0),
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
    ahbmo2(2) <= ahbm_none;
    coherent_dma_rcv_rdreq <= '0';
    coherent_dma_snd_wrreq <= '0';
    coherent_dma_snd_data_in <= (others => '0');

  end generate no_cache_coherence;

  with_cache_coherence : if CFG_LLC_ENABLE /= 0 generate

    mem_noc2ahbm_1 : mem_noc2ahbm
      generic map (
        tech        => fabtech,
        ncpu        => CFG_NCPU_TILE,   --unused
        hindex      => 0,
        local_y     => local_y,
        local_x     => local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE,
        destination => 0)
      port map (
        rst                       => rst,
        clk                       => clk,
        ahbmi                     => ahbmi2,
        ahbmo                     => ahbmo2(0),
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

    llc_wrapper_1 : llc_wrapper
      generic map (
        tech        => memtech,
        sets        => CFG_LLC_SETS,
        ways        => CFG_LLC_WAYS,
        nl2         => CFG_NL2,
        nllcc       => CFG_NLLC_COHERENT,
        noc_xlen    => CFG_XLEN,
        hindex      => 0,
        local_y     => local_y,
        local_x     => local_x,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE,
        cache_tile_id => cache_tile_id,
        dma_tile_id => dma_tile_id,
        tile_cache_id => tile_cache_id,
        tile_dma_id => tile_dma_id,
        destination => 0)
      port map (
        rst   => rst,
        clk   => clk,
        ahbmi => ahbmi2,
        ahbmo => ahbmo2(2),
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

        debug_led                  => open
        );

  end generate with_cache_coherence;
  
  -- FROM JTAG to DDR1
  mem_noc2ahbm_2 : mem_noc2ahbm
    generic map (
      tech        => fabtech,
      ncpu        => CFG_NCPU_TILE,          -- unused
      hindex      => 1,
      local_y     => local_y,
      local_x     => local_x,
      cacheline   => CFG_DLINE,
      l2_cache_en => 0,
      destination => 1)
    port map (
      rst                       => rst,
      clk                       => clk,
      ahbmi                     => ahbmi2,
      ahbmo                     => ahbmo2(1),
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

  --TODO: directory

  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------


  mem_tile_q_1 : mem_tile_q
    generic map (
      tech => fabtech)
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
      remote_apb_rcv_rdreq       => '0',
      remote_apb_rcv_data_out    => open,
      remote_apb_rcv_empty       => open,
      remote_apb_snd_wrreq       => '0',
      remote_apb_snd_data_in     => (others => '0'),
      remote_apb_snd_full        => open,
      apb_rcv_rdreq              => '0',
      apb_rcv_data_out           => open,
      apb_rcv_empty              => open,
      apb_snd_wrreq              => '0',
      apb_snd_data_in            => (others => '0'),
      apb_snd_full               => open,
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

