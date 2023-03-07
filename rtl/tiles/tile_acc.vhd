-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Accelerator Tile
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
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.coretypes.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.grlib_config.all;
use work.misc.all;

entity tile_acc is
  generic (
    this_hls_conf      : hlscfg_t             := 0;
    this_device        : devid_t              := 0;
    this_irq_type      : integer              := 0;
    this_has_l2        : integer range 0 to 1 := 0;
    this_has_dvfs      : integer range 0 to 1 := 0;
    this_has_pll       : integer range 0 to 1 := 0;
    this_has_dco       : integer range 0 to 1 := 0;
    this_extra_clk_buf : integer range 0 to 1 := 0);
  port (
    raw_rstn           : in  std_ulogic;
    tile_rst           : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    dco_clk            : out std_ulogic;
    dco_rstn           : out std_ulogic;
    -- Pads configuration
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    local_x             : out local_yx;
    local_y             : out local_yx;
    noc1_mon_noc_vec    : in monitor_noc_type;
    noc2_mon_noc_vec    : in monitor_noc_type;
    noc3_mon_noc_vec    : in monitor_noc_type;
    noc4_mon_noc_vec    : in monitor_noc_type;
    noc5_mon_noc_vec    : in monitor_noc_type;
    noc6_mon_noc_vec    : in monitor_noc_type;
    test1_output_port   : in noc_flit_type;
    test1_data_void_out : in std_ulogic;
    test1_stop_in       : in std_ulogic;
    test2_output_port   : in noc_flit_type;
    test2_data_void_out : in std_ulogic;
    test2_stop_in       : in std_ulogic;
    test3_output_port   : in noc_flit_type;
    test3_data_void_out : in std_ulogic;
    test3_stop_in       : in std_ulogic;
    test4_output_port   : in noc_flit_type;
    test4_data_void_out : in std_ulogic;
    test4_stop_in       : in std_ulogic;
    test5_output_port   : in misc_noc_flit_type;
    test5_data_void_out : in std_ulogic;
    test5_stop_in       : in std_ulogic;
    test6_output_port   : in noc_flit_type;
    test6_data_void_out : in std_ulogic;
    test6_stop_in       : in std_ulogic;
    test1_input_port    : out noc_flit_type;
    test1_data_void_in  : out std_ulogic;
    test1_stop_out      : out std_ulogic;
    test2_input_port    : out noc_flit_type;
    test2_data_void_in  : out std_ulogic;
    test2_stop_out      : out std_ulogic;
    test3_input_port    : out noc_flit_type;
    test3_data_void_in  : out std_ulogic;
    test3_stop_out      : out std_ulogic;
    test4_input_port    : out noc_flit_type;
    test4_data_void_in  : out std_ulogic;
    test4_stop_out      : out std_ulogic;
    test5_input_port    : out misc_noc_flit_type;
    test5_data_void_in  : out std_ulogic;
    test5_stop_out      : out std_ulogic;
    test6_input_port    : out noc_flit_type;
    test6_data_void_in  : out std_ulogic;
    test6_stop_out      : out std_ulogic;
    mon_dvfs_in         : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc             : out monitor_acc_type;
    mon_cache           : out monitor_cache_type;
    mon_dvfs            : out monitor_dvfs_type
    );

end;

architecture rtl of tile_acc is

  signal clk_feedthru : std_ulogic;
  signal dvfs_clk     : std_ulogic;

  -- Tile synchronous reset
  signal rst          : std_ulogic;

  -- Decoupler
  signal decouple_acc : std_ulogic;

  -- DCO
  signal dco_clk_int  : std_ulogic;
  signal dco_en       : std_ulogic;
  signal dco_clk_sel  : std_ulogic;
  signal dco_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_div_sel  : std_logic_vector(2 downto 0);
  signal dco_freq_sel : std_logic_vector(1 downto 0);
  signal dco_clk_lock : std_ulogic;

  signal acc_dvfs_transient   : std_ulogic := '0';

  -- BUS
  signal apbi           : apb_slv_in_type;
  signal apbo           : apb_slv_out_vector;
  signal pready         : std_ulogic;
  signal pready_noc     : std_ulogic;
  signal mon_dvfs_int   : monitor_dvfs_type;
  signal mon_cache_int  : monitor_cache_type;
  signal mon_acc_int    : monitor_acc_type;
  signal mon_noc        : monitor_noc_vector(1 to 6);

  signal coherence_req_wrreq        : std_ulogic;
  signal coherence_req_wrreq_acc        : std_ulogic;
  signal coherence_req_data_in      : noc_flit_type;
  signal coherence_req_full         : std_ulogic;
  signal coherence_fwd_rdreq        : std_ulogic;
  signal coherence_fwd_rdreq_acc    : std_ulogic;
  signal coherence_fwd_data_out     : noc_flit_type;
  signal coherence_fwd_empty        : std_ulogic;
  signal coherence_rsp_rcv_rdreq    : std_ulogic;
  signal coherence_rsp_rcv_rdreq_acc : std_ulogic;
  signal coherence_rsp_rcv_data_out : noc_flit_type;
  signal coherence_rsp_rcv_empty    : std_ulogic;
  signal coherence_rsp_snd_wrreq    : std_ulogic;
  signal coherence_rsp_snd_wrreq_acc : std_ulogic;
  signal coherence_rsp_snd_data_in  : noc_flit_type;
  signal coherence_rsp_snd_full     : std_ulogic;
  signal coherence_fwd_snd_wrreq    : std_ulogic;
  signal coherence_fwd_snd_wrreq_acc : std_ulogic;
  signal coherence_fwd_snd_data_in  : noc_flit_type;
  signal coherence_fwd_snd_full     : std_ulogic;
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_rdreq_acc          : std_ulogic;
  signal dma_rcv_data_out           : noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_wrreq_acc          : std_ulogic;
  signal dma_snd_data_in            : noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal coherent_dma_rcv_rdreq_acc : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_wrreq_acc : std_ulogic;
  signal coherent_dma_snd_data_in   : noc_flit_type;
  signal coherent_dma_snd_full      : std_ulogic;
  signal interrupt_wrreq            : std_ulogic;
  signal interrupt_wrreq_acc        : std_ulogic;
  signal interrupt_data_in          : misc_noc_flit_type;
  signal interrupt_full             : std_ulogic;
  signal interrupt_ack_rdreq        : std_ulogic;
  signal interrupt_ack_rdreq_acc    : std_ulogic;
  signal interrupt_ack_data_out     : misc_noc_flit_type;
  signal interrupt_ack_empty        : std_ulogic;
  signal apb_snd_wrreq              : std_ulogic;
  signal apb_snd_data_in            : misc_noc_flit_type;
  signal apb_snd_full               : std_ulogic;
  signal apb_rcv_rdreq              : std_ulogic;
  signal apb_rcv_data_out           : misc_noc_flit_type;
  signal apb_rcv_empty              : std_ulogic;

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_pindex    : integer range 0 to NAPBSLV - 1;
  signal this_paddr     : integer range 0 to 4095;
  signal this_pmask     : integer range 0 to 4095;
  signal this_paddr_ext : integer range 0 to 4095;
  signal this_pmask_ext : integer range 0 to 4095;
  signal this_pirq      : integer range 0 to NAHBIRQ - 1;

  signal this_csr_pindex        : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig       : apb_config_type;

  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    1 => '1',                           -- ESP accelerator w/ DVFS controller
    others => '0');

  constant io_y                : local_yx                           := tile_y(io_tile_id);
  constant io_x                : local_yx                           := tile_x(io_tile_id);
  constant this_scatter_gather : integer range 0 to 1               := CFG_SCATTER_GATHER;

  constant little_end          : integer range 0 to 1               := GLOB_CPU_RISCV;
  
  signal coherence : integer range 0 to 3;

  -- add attribute 'keep' to fix a bug with Vivado HLS accelerators
  attribute keep : string;

  attribute keep of coherence_req_wrreq        : signal is "true";
  attribute keep of coherence_req_data_in      : signal is "true";
  attribute keep of coherence_req_full         : signal is "true";
  attribute keep of coherence_fwd_rdreq        : signal is "true";
  attribute keep of coherence_fwd_data_out     : signal is "true";
  attribute keep of coherence_fwd_empty        : signal is "true";
  attribute keep of coherence_rsp_rcv_rdreq    : signal is "true";
  attribute keep of coherence_rsp_rcv_data_out : signal is "true";
  attribute keep of coherence_rsp_rcv_empty    : signal is "true";
  attribute keep of coherence_rsp_snd_wrreq    : signal is "true";
  attribute keep of coherence_rsp_snd_data_in  : signal is "true";
  attribute keep of coherence_rsp_snd_full     : signal is "true";
  attribute keep of dma_rcv_rdreq              : signal is "true";
  attribute keep of dma_rcv_data_out           : signal is "true";
  attribute keep of dma_rcv_empty              : signal is "true";
  attribute keep of dma_snd_wrreq              : signal is "true";
  attribute keep of dma_snd_data_in            : signal is "true";
  attribute keep of dma_snd_full               : signal is "true";
  attribute keep of coherent_dma_rcv_rdreq     : signal is "true";
  attribute keep of coherent_dma_rcv_data_out  : signal is "true";
  attribute keep of coherent_dma_rcv_empty     : signal is "true";
  attribute keep of coherent_dma_snd_wrreq     : signal is "true";
  attribute keep of coherent_dma_snd_data_in   : signal is "true";
  attribute keep of coherent_dma_snd_full      : signal is "true";
  attribute keep of interrupt_wrreq            : signal is "true";
  attribute keep of interrupt_data_in          : signal is "true";
  attribute keep of interrupt_full             : signal is "true";
  attribute keep of interrupt_ack_rdreq        : signal is "true";
  attribute keep of interrupt_ack_data_out     : signal is "true";
  attribute keep of interrupt_ack_empty        : signal is "true";
  attribute keep of apb_snd_wrreq              : signal is "true";
  attribute keep of apb_snd_data_in            : signal is "true";
  attribute keep of apb_snd_full               : signal is "true";
  attribute keep of apb_rcv_rdreq              : signal is "true";
  attribute keep of apb_rcv_data_out           : signal is "true";
  attribute keep of apb_rcv_empty              : signal is "true";

  attribute mark_debug : string;
  --attribute keep       : string;

  attribute mark_debug of  interrupt_wrreq    : signal is "true";
  attribute mark_debug of  interrupt_wrreq_acc      : signal is "true";
  attribute mark_debug of  interrupt_data_in        : signal is "true";
  attribute mark_debug of  interrupt_full           : signal is "true";
  attribute mark_debug of  interrupt_ack_rdreq      : signal is "true";
  attribute mark_debug of  interrupt_ack_rdreq_acc  : signal is "true";
  attribute mark_debug of  interrupt_ack_data_out   : signal is "true";
  attribute mark_debug of  interrupt_ack_empty      : signal is "true";
  attribute mark_debug of  apb_snd_wrreq            : signal is "true";
  attribute mark_debug of  apb_snd_data_in          : signal is "true";
  attribute mark_debug of  apb_snd_full             : signal is "true";
  attribute mark_debug of  apb_rcv_rdreq            : signal is "true";
  attribute mark_debug of  apb_rcv_data_out         : signal is "true";
  attribute mark_debug of  apb_rcv_empty            : signal is "true";
  attribute mark_debug of  apbi                     : signal is "true";
  attribute mark_debug of  apbo                     : signal is "true";
  attribute mark_debug of  pready                   : signal is "true";
  attribute mark_debug of  pready_noc               : signal is "true";
  attribute mark_debug of coherence_req_wrreq        : signal is "true";
  attribute mark_debug of coherence_req_data_in      : signal is "true";
  attribute mark_debug of coherence_req_full         : signal is "true";
  attribute mark_debug of coherence_fwd_rdreq        : signal is "true";
  attribute mark_debug of coherence_fwd_data_out     : signal is "true";
  attribute mark_debug of coherence_fwd_empty        : signal is "true";
  attribute mark_debug of coherence_rsp_rcv_rdreq    : signal is "true";
  attribute mark_debug of coherence_rsp_rcv_data_out : signal is "true";
  attribute mark_debug of coherence_rsp_rcv_empty    : signal is "true";
  attribute mark_debug of coherence_rsp_snd_wrreq    : signal is "true";
  attribute mark_debug of coherence_rsp_snd_data_in  : signal is "true";
  attribute mark_debug of coherence_rsp_snd_full     : signal is "true";
  attribute mark_debug of  dma_rcv_rdreq             : signal is "true";
  attribute mark_debug of dma_rcv_data_out           : signal is "true";
  attribute mark_debug of dma_rcv_empty              : signal is "true";
  attribute mark_debug of dma_snd_wrreq              : signal is "true";
  attribute mark_debug of dma_snd_data_in            : signal is "true";
  attribute mark_debug of dma_snd_full               : signal is "true";
  attribute mark_debug of coherent_dma_rcv_rdreq     : signal is "true";
  attribute mark_debug of coherent_dma_rcv_data_out  : signal is "true";
  attribute mark_debug of coherent_dma_rcv_empty     : signal is "true";
  attribute mark_debug of coherent_dma_snd_wrreq     : signal is "true";
  attribute mark_debug of coherent_dma_snd_data_in   : signal is "true";
  attribute mark_debug of coherent_dma_snd_full      : signal is "true";
  attribute mark_debug of tile_config                : signal is "true";
  attribute mark_debug of acc_dvfs_transient         : signal is "true";
  attribute mark_debug of decouple_acc               : signal is "true";


begin

  local_x <= this_local_x;
  local_y <= this_local_y;

  -- DCO Reset synchronizer
  rst_gen: if this_has_dco /= 0 generate
    tile_rstn : rstgen
      generic map (acthigh => 1, syncin => 0)
      port map (tile_rst, dco_clk_int, dco_clk_lock, rst, open);
  end generate rst_gen;

  no_rst_gen: if this_has_dco = 0 generate
    rst <= tile_rst;
  end generate no_rst_gen;

  dco_rstn <= rst;

  -- DCO
  dco_gen: if this_has_dco /= 0 generate

    dco_i: dco
      generic map (
        tech => CFG_FABTECH,
        enable_div2 => 0,
        dlog => 9)                      -- come out of reset after NoC, but
                                        -- before tile_io.
      port map (
        rstn     => raw_rstn,
        ext_clk  => refclk,
        en       => dco_en,
        clk_sel  => dco_clk_sel,
        cc_sel   => dco_cc_sel,
        fc_sel   => dco_fc_sel,
        div_sel  => dco_div_sel,
        freq_sel => dco_freq_sel,
        clk      => dco_clk_int,
        clk_div  => pllclk,
        lock     => dco_clk_lock);

    dco_freq_sel <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 0  downto ESP_CSR_DCO_CFG_MSB - 4 - 0  - 1);
    dco_div_sel  <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 2  downto ESP_CSR_DCO_CFG_MSB - 4 - 2  - 2);
    dco_fc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 5  downto ESP_CSR_DCO_CFG_MSB - 4 - 5  - 5);
    dco_cc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 11 downto ESP_CSR_DCO_CFG_MSB - 4 - 11 - 5);
    dco_clk_sel  <= tile_config(ESP_CSR_DCO_CFG_LSB + 1);
    dco_en       <= raw_rstn and tile_config(ESP_CSR_DCO_CFG_LSB);

    -- PLL reference clock comes from DCO
    dvfs_clk <= dco_clk_int;
    dco_clk <= dco_clk_int;
    clk_feedthru <= dco_clk_int;
  end generate dco_gen;

  no_dco_gen: if this_has_dco = 0 generate
    dco_clk      <= refclk;
    dco_clk_lock <= '1';
    -- clk_feedthru is generated by PLL if present, or connected to refclk
    pllclk <= clk_feedthru;
    clk_feedthru <= refclk;
    -- PLL reference clock comes form refclk pin
    dvfs_clk <= refclk;
  end generate no_dco_gen;

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id          <= to_integer(unsigned(tile_config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));
  pad_cfg          <= tile_config(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);

  this_pindex      <= tile_apb_idx(tile_id);
  this_paddr       <= tile_apb_paddr(tile_id);
  this_pmask       <= tile_apb_pmask(tile_id);
  this_paddr_ext   <= tile_apb_paddr_ext(tile_id);
  this_pmask_ext   <= tile_apb_pmask_ext(tile_id);
  this_pirq        <= tile_apb_irq(tile_id);

  this_csr_pindex  <= tile_csr_pindex(tile_id);
  this_csr_pconfig <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y     <= tile_y(tile_id);
  this_local_x     <= tile_x(tile_id);

  coherence        <= to_integer(unsigned(tile_config(ESP_CSR_ACC_COH_MSB downto ESP_CSR_ACC_COH_LSB)));

   -------------------------------------------------------------------------------
  -- Accelerator Top
  -------------------------------------------------------------------------------

  acc_top_inst : acc_top
    generic map (
      hls_conf       => this_hls_conf,
      this_device    => this_device,
      tech           => CFG_FABTECH,
      mem_num        => CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_SVGA_ENABLE,
      cacheable_mem_num => CFG_NMEM_TILE,
      mem_info       => tile_acc_mem_list,
      io_y           => io_y,
      io_x           => io_x,
      pindex         => 1,
      irq_type       => this_irq_type,
      scatter_gather => this_scatter_gather,
      sets           => CFG_ACC_L2_SETS,
      ways           => CFG_ACC_L2_WAYS,
      little_end     => little_end,
      cache_tile_id  => cache_tile_id,
      cache_y        => cache_y,
      cache_x        => cache_x,
      has_l2         => this_has_l2,
      has_dvfs       => this_has_dvfs,
      has_pll        => this_has_pll,
      extra_clk_buf  => this_extra_clk_buf)
    port map (
      rst               => rst,
      clk               => clk_feedthru,
      local_y           => this_local_y,
      local_x           => this_local_x,
      tile_id           => tile_id,
      paddr             => this_paddr,
      pmask             => this_pmask,
      paddr_ext         => this_paddr_ext,
      pmask_ext         => this_pmask_ext,
      pirq              => this_pirq,
      apbi              => apbi,
      apbo              => apbo(1),
      pready            => pready,
      coherence_req_wrreq        => coherence_req_wrreq_acc,
      coherence_req_data_in      => coherence_req_data_in,
      coherence_req_full         => coherence_req_full,
      coherent_dma_rcv_rdreq     => coherent_dma_rcv_rdreq_acc,
      coherent_dma_rcv_data_out  => coherent_dma_rcv_data_out,
      coherent_dma_rcv_empty     => coherent_dma_rcv_empty,
      coherence_fwd_rdreq        => coherence_fwd_rdreq_acc,
      coherence_fwd_data_out     => coherence_fwd_data_out,
      coherence_fwd_empty        => coherence_fwd_empty,
      coherent_dma_snd_wrreq     => coherent_dma_snd_wrreq_acc,
      coherent_dma_snd_data_in   => coherent_dma_snd_data_in,
      coherent_dma_snd_full      => coherent_dma_snd_full,
      coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq_acc,
      coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
      coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
      coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq_acc,
      coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
      coherence_rsp_snd_full     => coherence_rsp_snd_full,
      coherence_fwd_snd_wrreq    => coherence_fwd_snd_wrreq_acc,
      coherence_fwd_snd_data_in  => coherence_fwd_snd_data_in,
      coherence_fwd_snd_full     => coherence_fwd_snd_full,
      dma_rcv_rdreq     => dma_rcv_rdreq_acc,
      dma_rcv_data_out  => dma_rcv_data_out,
      dma_rcv_empty     => dma_rcv_empty,
      dma_snd_wrreq     => dma_snd_wrreq_acc,
      dma_snd_data_in   => dma_snd_data_in,
      dma_snd_full      => dma_snd_full,
      interrupt_wrreq   => interrupt_wrreq_acc,
      interrupt_data_in => interrupt_data_in,
      interrupt_full    => interrupt_full,
      interrupt_ack_rdreq    => interrupt_ack_rdreq_acc,
      interrupt_ack_data_out => interrupt_ack_data_out,
      interrupt_ack_empty    => interrupt_ack_empty,
      mon_dvfs_in       => mon_dvfs_in,
      dvfs_transient_in   => acc_dvfs_transient,
      -- Monitor signals
      mon_acc           => mon_acc_int,
      mon_cache         => mon_cache_int,
      mon_dvfs          => mon_dvfs_int,
      coherence         => coherence
      );

  -- loopbback pllclk with refclk
  pllclk <= refclk;

  -- decouple signals if decouple_acc is asserted
  decoupler_gen: process (decouple_acc, coherence_req_wrreq_acc, coherence_fwd_rdreq_acc,
                          coherent_dma_snd_wrreq_acc, coherence_rsp_rcv_rdreq_acc,
                          coherence_rsp_snd_wrreq_acc, dma_rcv_rdreq_acc, dma_snd_wrreq_acc,
                          interrupt_wrreq_acc, interrupt_ack_rdreq_acc) is
  begin  -- process decoupler_gen
    if decouple_acc = '1' then
      coherence_req_wrreq        <= '0';
      coherence_fwd_rdreq        <= '0';
      coherence_fwd_snd_wrreq    <= '0';
      coherent_dma_snd_wrreq     <= '0';
      coherent_dma_rcv_rdreq     <= '0';
      coherence_rsp_rcv_rdreq    <= '0';
      coherence_rsp_snd_wrreq    <= '0';
      dma_rcv_rdreq              <= '0';
      dma_snd_wrreq              <= '0';
      interrupt_wrreq            <= '0';
      interrupt_ack_rdreq        <= '0';
    else
      coherence_req_wrreq        <= coherence_req_wrreq_acc;
      coherence_fwd_rdreq        <= coherence_fwd_rdreq_acc;
      coherence_fwd_snd_wrreq    <= coherence_fwd_snd_wrreq_acc;
      coherent_dma_snd_wrreq     <= coherent_dma_snd_wrreq_acc;
      coherent_dma_rcv_rdreq     <= coherent_dma_rcv_rdreq_acc;
      coherence_rsp_rcv_rdreq    <= coherence_rsp_rcv_rdreq_acc;
      coherence_rsp_snd_wrreq    <= coherence_rsp_snd_wrreq_acc;
      dma_rcv_rdreq              <= dma_rcv_rdreq_acc;
      dma_snd_wrreq              <= dma_snd_wrreq_acc;
      interrupt_wrreq            <= interrupt_wrreq_acc;
      interrupt_ack_rdreq        <= interrupt_ack_rdreq_acc;
    end if;
  end process decoupler_gen;

  -- CSR map for decoupler
  --decouple_acc <= tile_config(ESP_CSR_ACC_DECOUPLER_MSB downto ESP_CSR_ACC_DECOUPLER_LSB);
  decouple_acc <= tile_config(98);

  -- Using only one apbo signal
  no_apb : for i in 0 to NAPBSLV - 1 generate
    local_apb : if this_local_apb_en(i) = '0' generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  -- Connect pready for APB3 accelerators
  pready_gen: process (pready, apbi) is
  begin  -- process pready_gen
    if apbi.psel(1) = '1' then
      pready_noc <= pready;
    else
      pready_noc <= '1';
    end if;
  end process pready_gen;

  -- APB proxy
  noc2apb_1 : noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => clk_feedthru,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => apbi,
      apbo             => apbo,
      pready           => pready_noc,
      dvfs_transient   => acc_dvfs_transient,
      --dvfs_transient   => mon_dvfs_int.transient,
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty
    );

  --Monitors
  mon_dvfs  <= mon_dvfs_int;
  mon_cache <= mon_cache_int;
  mon_acc   <= mon_acc_int;

  mon_noc(1) <= noc1_mon_noc_vec;
  mon_noc(2) <= noc2_mon_noc_vec;
  mon_noc(3) <= noc3_mon_noc_vec;
  mon_noc(4) <= noc4_mon_noc_vec;
  mon_noc(5) <= noc5_mon_noc_vec;
  mon_noc(6) <= noc6_mon_noc_vec;

  -- Memory mapped registers
  acc_tile_csr : esp_tile_csr
    generic map(
      pindex  => 0)
    port map(
      clk => clk_feedthru,
      rstn => rst,
      pconfig => this_csr_pconfig,
      mon_ddr => monitor_ddr_none,
      mon_mem => monitor_mem_none,
      mon_noc => mon_noc,
      mon_l2 => mon_cache_int,
      mon_llc => monitor_cache_none,
      mon_acc => mon_acc_int,
      mon_dvfs => mon_dvfs_int,
      tile_config => tile_config,
      srst => open,
      apbi => apbi,
      apbo => apbo(0),
      prc_interrupt => '0'
    );

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
      coherence_fwd_snd_wrreq    => coherence_fwd_snd_wrreq,
      coherence_fwd_snd_data_in  => coherence_fwd_snd_data_in,
      coherence_fwd_snd_full     => coherence_fwd_snd_full,
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
      interrupt_ack_rdreq        => interrupt_ack_rdreq,
      interrupt_ack_data_out     => interrupt_ack_data_out,
      interrupt_ack_empty        => interrupt_ack_empty,
      noc1_out_data              => test1_output_port,
      noc1_out_void              => test1_data_void_out,
      noc1_out_stop              => test1_stop_out,
      noc1_in_data               => test1_input_port,
      noc1_in_void               => test1_data_void_in,
      noc1_in_stop               => test1_stop_in,
      noc2_out_data              => test2_output_port,
      noc2_out_void              => test2_data_void_out,
      noc2_out_stop              => test2_stop_out,
      noc2_in_data               => test2_input_port,
      noc2_in_void               => test2_data_void_in,
      noc2_in_stop               => test2_stop_in,
      noc3_out_data              => test3_output_port,
      noc3_out_void              => test3_data_void_out,
      noc3_out_stop              => test3_stop_out,
      noc3_in_data               => test3_input_port,
      noc3_in_void               => test3_data_void_in,
      noc3_in_stop               => test3_stop_in,
      noc4_out_data              => test4_output_port,
      noc4_out_void              => test4_data_void_out,
      noc4_out_stop              => test4_stop_out,
      noc4_in_data               => test4_input_port,
      noc4_in_void               => test4_data_void_in,
      noc4_in_stop               => test4_stop_in,
      noc5_out_data              => test5_output_port,
      noc5_out_void              => test5_data_void_out,
      noc5_out_stop              => test5_stop_out,
      noc5_in_data               => test5_input_port,
      noc5_in_void               => test5_data_void_in,
      noc5_in_stop               => test5_stop_in,
      noc6_out_data              => test6_output_port,
      noc6_out_void              => test6_data_void_out,
      noc6_out_stop              => test6_stop_out,
      noc6_in_data               => test6_input_port,
      noc6_in_void               => test6_data_void_in,
      noc6_in_stop               => test6_stop_in);

end;
