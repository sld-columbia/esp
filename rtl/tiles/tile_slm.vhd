-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
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
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.misc.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.coretypes.all;

use work.grlib_config.all;
use work.socmap.all;

entity tile_slm is
  generic (
    SIMULATION   : boolean := false;
    this_has_dco : integer range 0 to 1 := 0;
    this_has_ddr : integer range 0 to 1 := 0;
    dco_rst_cfg  : std_logic_vector(30 downto 0) := (others => '0'));
  port (
    raw_rstn           : in  std_ulogic;
    tile_rst           : in  std_ulogic;
    clk                : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    dco_clk            : out std_ulogic;
    -- DDR controller ports (this_has_ddr -> 1)
    dco_clk_div2       : out std_ulogic;
    dco_clk_div2_90    : out std_ulogic;
    dco_rstn           : out std_ulogic;
    phy_rstn           : out std_ulogic;
    ddr_ahbsi          : out ahb_slv_in_type;
    ddr_ahbso          : in  ahb_slv_out_type;
    ddr_cfg0           : out std_logic_vector(31 downto 0);
    ddr_cfg1           : out std_logic_vector(31 downto 0);
    ddr_cfg2           : out std_logic_vector(31 downto 0);
    slmddr_id          : out integer range 0 to SLMDDR_ID_RANGE_MSB;
    -- Pads configuration
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    local_x            : out local_yx;
    local_y            : out local_yx;
    noc1_mon_noc_vec   : in monitor_noc_type;
    noc2_mon_noc_vec   : in monitor_noc_type;
    noc3_mon_noc_vec   : in monitor_noc_type;
    noc4_mon_noc_vec   : in monitor_noc_type;
    noc5_mon_noc_vec   : in monitor_noc_type;
    noc6_mon_noc_vec   : in monitor_noc_type;
    test1_output_port   : in coh_noc_flit_type;
    test1_data_void_out : in std_ulogic;
    test1_stop_in       : in std_ulogic;
    test2_output_port   : in coh_noc_flit_type;
    test2_data_void_out : in std_ulogic;
    test2_stop_in       : in std_ulogic;
    test3_output_port   : in coh_noc_flit_type;
    test3_data_void_out : in std_ulogic;
    test3_stop_in       : in std_ulogic;
    test4_output_port   : in dma_noc_flit_type;
    test4_data_void_out : in std_ulogic;
    test4_stop_in       : in std_ulogic;
    test5_output_port   : in misc_noc_flit_type;
    test5_data_void_out : in std_ulogic;
    test5_stop_in       : in std_ulogic;
    test6_output_port   : in dma_noc_flit_type;
    test6_data_void_out : in std_ulogic;
    test6_stop_in       : in std_ulogic;
    test1_input_port    : out coh_noc_flit_type;
    test1_data_void_in  : out std_ulogic;
    test1_stop_out      : out std_ulogic;
    test2_input_port    : out coh_noc_flit_type;
    test2_data_void_in  : out std_ulogic;
    test2_stop_out      : out std_ulogic;
    test3_input_port    : out coh_noc_flit_type;
    test3_data_void_in  : out std_ulogic;
    test3_stop_out      : out std_ulogic;
    test4_input_port    : out dma_noc_flit_type;
    test4_data_void_in  : out std_ulogic;
    test4_stop_out      : out std_ulogic;
    test5_input_port    : out misc_noc_flit_type;
    test5_data_void_in  : out std_ulogic;
    test5_stop_out      : out std_ulogic;
    test6_input_port    : out dma_noc_flit_type;
    test6_data_void_in  : out std_ulogic;
    test6_stop_out      : out std_ulogic;
    mon_mem            : out monitor_mem_type;
    mon_dvfs           : out monitor_dvfs_type);
end;


architecture rtl of tile_slm is

  -- Tile synchronous reset
  signal rst : std_ulogic;

  -- DCO
  signal dco_en       : std_ulogic;
  signal dco_clk_sel  : std_ulogic;
  signal dco_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_div_sel  : std_logic_vector(2 downto 0);
  signal dco_freq_sel : std_logic_vector(1 downto 0);
  signal dco_clk_lock : std_ulogic;
  signal dco_clk_int  : std_ulogic;
  signal dco_clk_int_delay      : std_ulogic;
  signal dco_clk_div2_int_delay : std_ulogic;

  -- Delay line for DDR ui_clk delay
  signal dco_clk_div2_int    : std_logic;
  signal dco_clk_div2_90_int : std_logic;
  signal dco_clk_delay_sel   : std_logic_vector(11 downto 0);
  component DELAY_CELL_GF12_C14 is
    port (
      data_in : in std_logic;
      sel     : in std_Logic_vector(3 downto 0);
      data_out : out std_logic);
  end component DELAY_CELL_GF12_C14;

  -- Queues (despite their name, for this tile, all queues carry non-coherent requests)
  signal dma_rcv_rdreq              : std_ulogic;
  signal dma_rcv_data_out           : dma_noc_flit_type;
  signal dma_rcv_empty              : std_ulogic;
  signal dma_snd_wrreq              : std_ulogic;
  signal dma_snd_data_in            : dma_noc_flit_type;
  signal dma_snd_full               : std_ulogic;
  signal dma_snd_atleast_4slots     : std_ulogic;
  signal dma_snd_exactly_3slots     : std_ulogic;
  signal cpu_dma_rcv_rdreq          : std_ulogic;
  signal cpu_dma_rcv_data_out       : dma_noc_flit_type;
  signal cpu_dma_rcv_empty          : std_ulogic;
  signal cpu_dma_snd_wrreq          : std_ulogic;
  signal cpu_dma_snd_data_in        : dma_noc_flit_type;
  signal cpu_dma_snd_full           : std_ulogic;
  signal coherent_dma_rcv_rdreq     : std_ulogic;
  signal coherent_dma_rcv_data_out  : dma_noc_flit_type;
  signal coherent_dma_rcv_empty     : std_ulogic;
  signal coherent_dma_snd_wrreq     : std_ulogic;
  signal coherent_dma_snd_data_in   : dma_noc_flit_type;
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
  signal remote_ahbm_rcv_data_out   : arch_noc_flit_type;
  signal remote_ahbm_rcv_empty      : std_ulogic;
  signal remote_ahbm_snd_wrreq      : std_ulogic;
  signal remote_ahbm_snd_data_in    : arch_noc_flit_type;
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

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

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

begin

  local_x <= this_local_x;
  local_y <= this_local_y;

  -- DCO Reset synchronizer
  rst_gen : if this_has_dco /= 0 generate
    rst_ddr : if this_has_ddr /= 0 generate
      tile_rstn : rstgen
        generic map (acthigh => 1, syncin => 0)
        port map (tile_rst, dco_clk_div2_90_int, dco_clk_lock, rst, open);

      -- DDR PHY reset
      ddr_rstn : rstgen
        generic map (acthigh => 1, syncin => 0)
        port map (tile_rst, dco_clk_div2_int, dco_clk_lock, phy_rstn, open);
    end generate rst_ddr;

    rst_slm: if this_has_ddr = 0 generate 
      tile_rstn : rstgen
        generic map (acthigh => 1, syncin => 0)
        port map (tile_rst, dco_clk_int, dco_clk_lock, rst, open);
      phy_rstn <= rst;
    end generate rst_slm;

  end generate rst_gen;

  no_rst_gen: if this_has_dco = 0 generate
    rst <= tile_rst;
    phy_rstn <= tile_rst;
  end generate no_rst_gen;

  dco_rstn <= rst;

  -- DCO
  dco_gen: if this_has_dco /= 0 generate

    dco_i: dco
      generic map (
        tech => CFG_FABTECH,
        enable_div2 => this_has_ddr,
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
        clk_div2 => dco_clk_div2_int,
        clk_div2_90 => open,
        clk_div  => pllclk,
        lock     => dco_clk_lock);

    --clk_delay_gf12_gen: if CFG_FABTECH = gf12 generate
    clk_delay_asic_gen: if CFG_FABTECH = asic generate
      delay_ddr_gen : if  this_has_ddr /= 0 generate
        DELAY_CELL_GF12_C14_1: DELAY_CELL_GF12_C14
          port map (
            data_in  => dco_clk_div2_int,
            sel      => dco_clk_delay_sel(3 downto 0),
            data_out => dco_clk_div2_90_int);

        --delay_ddr_gen : if this_has_ddr /= 0 generate
          DELAY_CELL_GF12_C14_2: DELAY_CELL_GF12_C14
            port map (
              data_in  => dco_clk_div2_int,
              sel      => dco_clk_delay_sel(7 downto 4),
              data_out => dco_clk_div2_int_delay);

          DELAY_CELL_GF12_C14_3: DELAY_CELL_GF12_C14
            port map (
              data_in  => dco_clk_int,
              sel      => dco_clk_delay_sel(11 downto 8),
              data_out => dco_clk_int_delay);
        end generate delay_ddr_gen;

      no_delay_ddr_gen : if this_has_ddr = 0 generate
        dco_clk_div2_int_delay <= dco_clk_div2_int;
        dco_clk_int_delay <= dco_clk_int;
      end generate no_delay_ddr_gen;

    end generate clk_delay_asic_gen;

    --noc_clk_delay_gen: if CFG_FABTECH /= gf12 generate
    noc_clk_delay_gen: if CFG_FABTECH /= asic generate
      dco_clk_div2_90_int <= dco_clk_div2_int;
    end generate noc_clk_delay_gen;

  end generate dco_gen;

  -- DCO runtime reconfiguration
  dco_freq_sel <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 0  - 1);
  dco_div_sel  <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 2  - 2);
  dco_fc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 5  - 5);
  dco_cc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 - 5);
  dco_clk_sel  <= tile_config(ESP_CSR_DCO_CFG_LSB + 1);
  dco_en       <= raw_rstn and tile_config(ESP_CSR_DCO_CFG_LSB);

  no_dco_gen: if this_has_dco = 0 generate
    pllclk              <= '0';
    dco_clk_int         <= refclk;
    dco_clk_int_delay   <= dco_clk_int;
    dco_clk_lock        <= '1';
    dco_clk_div2_int    <= '0';
    dco_clk_div2_90_int <= '0';
  end generate no_dco_gen;

  dco_clk         <= dco_clk_int_delay;
  dco_clk_div2    <= dco_clk_div2_int_delay;
  dco_clk_div2_90 <= dco_clk_div2_90_int;

  -- DDR Controller configuration
  ddr_cfg0 <= tile_config(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB);
  ddr_cfg1 <= tile_config(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB);
  ddr_cfg2 <= tile_config(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB);

  dco_clk_delay_sel <= tile_config(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_MSB - 11);

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id           <= to_integer(unsigned(tile_config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));
  pad_cfg           <= tile_config(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);

  slmddr_id         <= tile_slmddr_id(tile_id);

  this_slm_id       <= tile_slm_id(tile_id);
  this_slm_hindex   <= slm_hindex(this_slm_id);
  this_slm_haddr    <= slm_haddr(this_slm_id);
  this_slm_hmask    <= slm_hmask(this_slm_id);

  this_csr_pindex   <= tile_csr_pindex(tile_id);
  this_csr_pconfig  <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y      <= tile_y(tile_id);
  this_local_x      <= tile_x(tile_id);

  -----------------------------------------------------------------------------
  -- Bus
  -----------------------------------------------------------------------------

  ahb2 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => 0, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => maxahbm, nahbs => maxahbs,
                 cfgmask => 0)
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

  onchip_gen: if this_has_ddr = 0 generate
    -- Shared Local Memory (SLM)
    ahbslm_1: ahbslm
      generic map (
        SIMULATION => SIMULATION,
        hindex => 0,
        tech   => CFG_FABTECH,
        kbytes => CFG_SLM_KBYTES)
      port map (
        rst    => rst,
        clk    => clk,
        haddr  => this_slm_haddr,
        hmask  => this_slm_hmask,
        ahbsi  => ahbsi,
        ahbso  => ahbso(0));

    ddr_ahbsi <= ahbs_in_none;
  end generate onchip_gen;

  offchip_gen: if this_has_ddr /= 0 generate
    -- Shared Offchip Memory
    ddr_ahbsi <= ahbsi;
    ahbso(0)  <= ddr_ahbso;
  end generate offchip_gen;


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

  mon_noc(1) <= noc1_mon_noc_vec;
  mon_noc(2) <= noc2_mon_noc_vec;
  mon_noc(3) <= noc3_mon_noc_vec;
  mon_noc(4) <= noc4_mon_noc_vec;
  mon_noc(5) <= noc5_mon_noc_vec;
  mon_noc(6) <= noc6_mon_noc_vec;

  -- Memory mapped registers
  slm_tile_csr : esp_tile_csr
    generic map(
      pindex      => 0,
      dco_rst_cfg => dco_rst_cfg)
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
      tile_config => tile_config,
      srst => open,
      apbi => apbi,
      apbo => apbo(0)
    );

  -----------------------------------------------------------------------------
  -- Proxies
  -----------------------------------------------------------------------------

  -- FROM NoC

  -- Handle CPU requests accelerator DMA
  noc2ahbmst_1 : noc2ahbmst
    generic map (
      tech                  => CFG_FABTECH,
      hindex                => 0,
      axitran               => GLOB_CPU_AXI,
      little_end            => GLOB_CPU_RISCV,
      eth_dma               => 0,
      narrow_noc            => 0,
      cacheline             => 1,
      l2_cache_en           => 0,
      this_coh_flit_size    => DMA_NOC_FLIT_SIZE)
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
  noc2ahbmst_2 : noc2ahbmst
    generic map (
      tech                  => CFG_FABTECH,
      hindex                => 1,
      axitran               => 0,
      little_end            => 0,
      eth_dma               => 1,               -- Exception for fixed 32-bits DMA
      narrow_noc            => 0,
      cacheline             => 1,
      l2_cache_en           => 0,
      this_coh_flit_size    => ARCH_NOC_FLIT_SIZE)
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
  noc2apb_1 : noc2apb
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
