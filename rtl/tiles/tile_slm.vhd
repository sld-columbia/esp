-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
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
    dco_rst_cfg  : std_logic_vector(22 downto 0) := (others => '0'));
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

  -- Delay line for DDR ui_clk delay
  signal dco_clk_div2_int    : std_logic;
  signal dco_clk_div2_90_int : std_logic;
  signal dco_clk_delay_sel   : std_logic_vector(3 downto 0);
  component DELAY_CELL_GF12_C14 is
    port (
      data_in : in std_logic;
      sel     : in std_Logic_vector(3 downto 0);
      data_out : out std_logic);
  end component DELAY_CELL_GF12_C14;

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
  
  attribute mark_debug : string;
  attribute keep       : string;

  -- DPR DMA queue entries
  signal prc_dma_rcv_rdreq             : std_ulogic;
  signal prc_dma_rcv_data_out          : noc_flit_type;
  signal prc_dma_rcv_empty             : std_ulogic;
  signal prc_dma_snd_wrreq             : std_ulogic;
  signal prc_dma_snd_data_in           : noc_flit_type;
  signal prc_dma_snd_full              : std_ulogic;

  -- PRC noc2ahbm queue entries
  signal prc_noc2ahbm_dma_rcv_rdreq             : std_ulogic;
  signal prc_noc2ahbm_dma_rcv_data_out          : noc_flit_type;
  signal prc_noc2ahbm_dma_rcv_empty             : std_ulogic;
  signal prc_noc2ahbm_dma_snd_wrreq             : std_ulogic;
  signal prc_noc2ahbm_dma_snd_data_in           : noc_flit_type;
  signal prc_noc2ahbm_dma_snd_full              : std_ulogic;
  signal prc_noc2ahbm_dma_snd_atleast_4slots     : std_ulogic;
  signal prc_noc2ahbm_dma_snd_exactly_3slots     : std_ulogic;  
  
  -- apb2axil
  signal s_axil_awvalid     : std_logic;
  signal s_axil_awready     : std_logic;
  signal s_axil_awaddr      : std_logic_vector(31 downto 0);
  signal s_axil_awaddr_masked : std_logic_vector(31 downto 0);
  signal s_axil_wvalid      : std_logic;
  signal s_axil_wready      : std_logic;
  signal s_axil_wdata       : std_logic_vector(31 downto 0);
  signal s_axil_wstrb       : std_logic_vector(3 downto 0);
  signal s_axil_arvalid     : std_logic;
  signal s_axil_arready     : std_logic;
  signal s_axil_araddr      : std_logic_vector(31 downto 0);
  signal s_axil_araddr_masked      : std_logic_vector(31 downto 0);
  signal s_axil_rvalid      : std_logic;
  signal s_axil_rready      : std_logic;
  signal s_axil_rdata       : std_logic_vector(31 downto 0);
  signal s_axil_rresp       : std_logic_vector(1 downto 0);
  signal s_axil_bvalid      : std_logic;
  signal s_axil_bready      : std_logic;
  signal s_axil_bresp       : std_logic_vector(1 downto 0);

  signal prc_pready         : std_logic;
  signal pready             : std_ulogic;
  
-- AXI4 Master
  signal mosi : axi_mosi_vector(0 to 0);
  signal somi : axi_somi_vector(0 to 0);

  -- PRC axi master bus
  signal m_axi_mem_araddr   : std_logic_vector(31 downto 0);
  signal m_axi_mem_arlen    : std_logic_vector(7 downto 0);
  signal m_axi_mem_arsize   : std_logic_vector(2 downto 0);
  signal m_axi_mem_arburst  : std_logic_vector(1 downto 0);
  signal m_axi_mem_arprot   : std_logic_vector(2 downto 0);
  signal m_axi_mem_arcache  : std_logic_vector(3 downto 0);
  signal m_axi_mem_aruser   : std_logic_vector(3 downto 0);
  signal m_axi_mem_arvalid  : std_logic;
  signal m_axi_mem_arready  : std_logic;
  signal m_axi_mem_rdata    : std_logic_vector(31 downto 0);
  signal m_axi_mem_rresp    : std_logic_vector(1  downto 0);
  signal m_axi_mem_rlast    : std_logic;
  signal m_axi_mem_rvalid   : std_logic;
  signal m_axi_mem_rready   : std_logic;

  --ICAP3 
  signal icap_clk       : std_logic;
  signal icap_reset     : std_logic;
  signal icap_csib      : std_logic;
  signal icap_rdwrb     : std_logic;
  signal icap_i         : std_logic_vector(31 downto 0);
  signal icap_o         : std_logic_vector(31 downto 0);
  signal icap_avail     : std_logic;
  signal icap_prdone    : std_logic;
  signal icap_prerror   : std_logic;

  --PRC configuration signals
  signal vsm_VS_0_rm_shutdown_req       : std_logic := '0';
  signal vsm_VS_0_rm_shutdown_ack       : std_logic := '1';
  signal vsm_VS_0_rm_decouple           : std_logic := '0';
  signal vsm_VS_0_rm_reset              : std_logic := '0';
  signal vsm_VS_0_event_error           : std_logic;
  signal vsm_VS_0_sw_shutdown_req       : std_logic;
  signal vsm_VS_0_sw_startup_req        : std_logic;  --interrupt

  constant prc_mask  : std_logic_vector(31 downto 0) := x"000000FF";
  constant prc_coherence : integer := 0;
  constant DISABLE_PRC_INST           : integer := 1; 
  
  --attribute mark_debug of ahbmo  : signal is "true";
  --attribute mark_debug of ahbso  : signal is "true";

  attribute mark_debug of s_axil_awvalid     : signal is "true";
  attribute mark_debug of s_axil_awready     : signal is "true";
  attribute mark_debug of s_axil_awaddr      : signal is "true";
  attribute mark_debug of s_axil_awaddr_masked      : signal is "true";
  attribute mark_debug of s_axil_wvalid      : signal is "true";
  attribute mark_debug of s_axil_wready      : signal is "true";
  attribute mark_debug of s_axil_wdata       : signal is "true";
  attribute mark_debug of s_axil_wstrb       : signal is "true";
  attribute mark_debug of s_axil_arvalid     : signal is "true";
  attribute mark_debug of s_axil_arready     : signal is "true";
  attribute mark_debug of s_axil_araddr      : signal is "true";
  attribute mark_debug of s_axil_araddr_masked      : signal is "true";
  attribute mark_debug of s_axil_rvalid      : signal is "true";
  attribute mark_debug of s_axil_rready      : signal is "true";
  attribute mark_debug of s_axil_rdata       : signal is "true";
  attribute mark_debug of s_axil_rresp       : signal is "true";
  attribute mark_debug of s_axil_bvalid      : signal is "true";
  attribute mark_debug of s_axil_bready      : signal is "true";
  attribute mark_debug of s_axil_bresp       : signal is "true";

  attribute mark_debug of icap_clk       : signal is "true";
  attribute mark_debug of icap_reset     : signal is "true";
  attribute mark_debug of icap_csib      : signal is "true";
  attribute mark_debug of icap_rdwrb     : signal is "true";
  attribute mark_debug of icap_i         : signal is "true";
  attribute mark_debug of icap_o         : signal is "true";
  attribute mark_debug of icap_avail     : signal is "true";
  attribute mark_debug of icap_prdone    : signal is "true";
  attribute mark_debug of icap_prerror   : signal is "true";

  attribute mark_debug of vsm_VS_0_sw_startup_req : signal is "true";

  attribute mark_debug of m_axi_mem_araddr   : signal is "true";
  attribute mark_debug of m_axi_mem_arlen    : signal is "true";
  attribute mark_debug of m_axi_mem_arsize   : signal is "true";
  attribute mark_debug of m_axi_mem_arburst  : signal is "true";
  attribute mark_debug of m_axi_mem_arprot   : signal is "true";
  attribute mark_debug of m_axi_mem_arcache  : signal is "true";
  attribute mark_debug of m_axi_mem_aruser   : signal is "true";
  attribute mark_debug of m_axi_mem_arvalid  : signal is "true";
  attribute mark_debug of m_axi_mem_arready  : signal is "true";
  attribute mark_debug of m_axi_mem_rdata    : signal is "true";
  attribute mark_debug of m_axi_mem_rresp    : signal is "true";
  attribute mark_debug of m_axi_mem_rlast    : signal is "true";
  attribute mark_debug of m_axi_mem_rvalid   : signal is "true";
  attribute mark_debug of m_axi_mem_rready   : signal is "true";

  attribute mark_debug of prc_dma_rcv_rdreq    : signal is "true";
  attribute mark_debug of prc_dma_rcv_data_out : signal is "true";
  attribute mark_debug of prc_dma_rcv_empty    : signal is "true";
  attribute mark_debug of prc_dma_snd_wrreq    : signal is "true";
  attribute mark_debug of prc_dma_snd_data_in  : signal is "true";
  attribute mark_debug of prc_dma_snd_full     : signal is "true";

  attribute mark_debug of prc_noc2ahbm_dma_rcv_rdreq    : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_rcv_data_out : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_rcv_empty    : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_snd_wrreq    : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_snd_data_in  : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_snd_full     : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_snd_atleast_4slots  : signal is "true";
  attribute mark_debug of prc_noc2ahbm_dma_snd_exactly_3slots  : signal is "true";  
  
  attribute mark_debug of ahbmo  : signal is "true";
  attribute mark_debug of ahbso  : signal is "true";
  attribute mark_debug of ddr_ahbso : signal is "true";
  attribute mark_debug of ddr_ahbsi : signal is "true";

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    127    => to_std_logic(CFG_PRC),    -- prc
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

    clk_delay_gf12_gen: if CFG_FABTECH = gf12 generate
      DELAY_CELL_GF12_C14_1: DELAY_CELL_GF12_C14
        port map (
          data_in  => dco_clk_div2_int,
          sel      => dco_clk_delay_sel,
          data_out => dco_clk_div2_90_int);
    end generate clk_delay_gf12_gen;

    noc_clk_delay_gen: if CFG_FABTECH /= gf12 generate
      dco_clk_div2_90_int <= dco_clk_div2_int;
    end generate noc_clk_delay_gen;

  end generate dco_gen;

  -- DCO runtime reconfiguration
  dco_freq_sel <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 0  downto ESP_CSR_DCO_CFG_MSB - 4 - 0  - 1);
  dco_div_sel  <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 2  downto ESP_CSR_DCO_CFG_MSB - 4 - 2  - 2);
  dco_fc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 5  downto ESP_CSR_DCO_CFG_MSB - 4 - 5  - 5);
  dco_cc_sel   <= tile_config(ESP_CSR_DCO_CFG_MSB - 4 - 11 downto ESP_CSR_DCO_CFG_MSB - 4 - 11 - 5);
  dco_clk_sel  <= tile_config(ESP_CSR_DCO_CFG_LSB + 1);
  dco_en       <= raw_rstn and tile_config(ESP_CSR_DCO_CFG_LSB);

  no_dco_gen: if this_has_dco = 0 generate
    pllclk              <= '0';
    dco_clk_int         <= '0';
    dco_clk_lock        <= '1';
    dco_clk_div2_int    <= '0';
    dco_clk_div2_90_int <= '0';
  end generate no_dco_gen;

  dco_clk         <= dco_clk_int;
  dco_clk_div2    <= dco_clk_div2_int;
  dco_clk_div2_90 <= dco_clk_div2_90_int;

  -- DDR Controller configuration
  ddr_cfg0 <= tile_config(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB);
  ddr_cfg1 <= tile_config(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB);
  ddr_cfg2 <= tile_config(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB);

  dco_clk_delay_sel <= tile_config(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_MSB - 3);

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
      apbo => apbo(0),
      prc_interrupt =>  vsm_VS_0_sw_startup_req --'0'
    );

  -----------------------------------------------------------------------------
  -- Proxies
  -----------------------------------------------------------------------------

  -- FROM NoC

  -- Handle CPU requests accelerator DMA
  noc2ahbmst_1 : noc2ahbmst
    generic map (
      tech        => CFG_FABTECH,
      hindex      => 0,
      axitran     => GLOB_CPU_AXI,
      little_end  => GLOB_CPU_RISCV,
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
  noc2ahbmst_2 : noc2ahbmst
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
      pready           => pready, --'1',
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  -----------------------------------------------------------------------------
  --- The modification of the MEM tile for PRC controller starts here
  -----------------------------------------------------------------------------
    pready_gen: process(prc_pready, apbi) is
    begin
        if apbi.psel(127) = '1' then
          pready <= prc_pready;
        else
          pready <= '1';
        end if;
    end process pready_gen;

  -----------------------------------------------------------------------------
  -- APB 127: apb2axi 
  -----------------------------------------------------------------------------
  disable_prc : if DISABLE_PRC_INST = 1 generate
  apb2axil_1: apb2axil
    port map (
      clk               => clk,
      rstn              => rst,
      paddr             => apbi.paddr,
      penable           => apbi.penable,
      psel              => apbi.psel(127),
      pwdata            => apbi.pwdata,
      pwrite            => apbi.pwrite,
      prdata            => apbo(127).prdata,
      pready            => prc_pready,            -- prc_pready -->axil_rvalid      
      pslverr           => open,                  -- temporary assignement
      s_axil_awvalid    => s_axil_awvalid,
      s_axil_awready    => s_axil_awready,
      s_axil_awaddr     => s_axil_awaddr,
      s_axil_wvalid     => s_axil_wvalid,
      s_axil_wready     => s_axil_wready,
      s_axil_wdata      => s_axil_wdata,
      s_axil_wstrb      => s_axil_wstrb,
      s_axil_arvalid    => s_axil_arvalid,
      s_axil_arready    => s_axil_arready,
      s_axil_araddr     => s_axil_araddr,
      s_axil_rvalid     => s_axil_rvalid,
      s_axil_rready     => s_axil_rready,
      s_axil_rdata      => s_axil_rdata,
      s_axil_rresp      => s_axil_rresp,
      s_axil_bvalid     => s_axil_bvalid,
      s_axil_bready     => s_axil_bready,
      s_axil_bresp      => s_axil_bresp);
  
  -- tie off the other apbo signals
  apbo(127).pirq <= (others => '0');
  apbo(127).pconfig <= fixed_apbo_pconfig(127);
  apbo(127).pindex <= 127;

  -- PRC 
  generate_prc : if has_prc(CFG_FABTECH) = 1 and CFG_PRC = 1 and SIMULATION = false generate
  prc_1: prc_inst
    port map (
      clk                       => clk,
      reset                     => rst,                 --check reset polarity
      m_axi_mem_araddr          => m_axi_mem_araddr,
      m_axi_mem_arlen           => m_axi_mem_arlen,
      m_axi_mem_arsize          => m_axi_mem_arsize,
      m_axi_mem_arburst         => m_axi_mem_arburst,
      m_axi_mem_arprot          => m_axi_mem_arprot,
      m_axi_mem_arcache         => m_axi_mem_arcache,
      m_axi_mem_aruser          => m_axi_mem_aruser,
      m_axi_mem_arvalid         => m_axi_mem_arvalid,
      m_axi_mem_arready         => m_axi_mem_arready,
      m_axi_mem_rdata           => m_axi_mem_rdata,
      m_axi_mem_rresp           => m_axi_mem_rresp,
      m_axi_mem_rlast           => m_axi_mem_rlast,
      m_axi_mem_rvalid          => m_axi_mem_rvalid,
      m_axi_mem_rready          => m_axi_mem_rready,
      icap_clk                  => clk,
      icap_reset                => rst,
      icap_csib                 => icap_csib,
      icap_rdwrb                => icap_rdwrb,
      icap_i                    => icap_o,
      icap_o                    => icap_i,
      --vsm_VS_0_rm_shutdown_req  => vsm_VS_0_rm_shutdown_req,
      vsm_VS_0_rm_shutdown_ack  => vsm_VS_0_rm_shutdown_ack,
      --vsm_VS_0_rm_decouple      => vsm_VS_0_rm_decouple,
      --vsm_VS_0_rm_reset         => vsm_VS_0_rm_reset,
      --vsm_VS_0_event_error      => vsm_VS_0_event_error,
      --vsm_VS_0_sw_shutdown_req  => vsm_VS_0_sw_shutdown_req,
      vsm_VS_0_sw_startup_req   => vsm_VS_0_sw_startup_req,
      --icap_avail                => icap_avail,
      --icap_prdone               => icap_prdone,
      --icap_prerror              => icap_prerror,
      s_axi_reg_awaddr          => s_axil_awaddr_masked,
      s_axi_reg_awvalid         => s_axil_awvalid,
      s_axi_reg_awready         => s_axil_awready,
      s_axi_reg_wdata           => s_axil_wdata,
      s_axi_reg_wvalid          => s_axil_wvalid,
      s_axi_reg_wready          => s_axil_wready,
      s_axi_reg_bresp           => s_axil_bresp,
      s_axi_reg_bvalid          => s_axil_bvalid,
      s_axi_reg_bready          => s_axil_bready,
      s_axi_reg_araddr          => s_axil_araddr_masked,
      s_axi_reg_arvalid         => s_axil_arvalid,
      s_axi_reg_arready         => s_axil_arready,
      s_axi_reg_rdata           => s_axil_rdata,
      s_axi_reg_rresp           => s_axil_rresp,
      s_axi_reg_rvalid          => s_axil_rvalid,
      s_axi_reg_rready          => s_axil_rready);

    s_axil_araddr_masked <= s_axil_araddr and prc_mask;
    s_axil_awaddr_masked <= s_axil_awaddr and prc_mask;

  -- ICAP3 instance
  icap_inst_1: icap
    generic map (
      tech  =>  CFG_FABTECH)
    port map (
      icap_clk      => clk,
      icap_csib     => icap_csib,
      icap_rdwrb    => icap_rdwrb,
      icap_i        => icap_i,
      icap_o        => icap_o,
      icap_avail    => icap_avail,
      icap_prdone   => icap_prdone,
      icap_prerror  => icap_prerror);
 end generate generate_prc;

  axi2noc_1: axislv2noc
    generic map (
      tech             => CFG_FABTECH,
      nmst             => 1,
      retarget_for_dma => 1,    --enable retarget_for_dma
      mem_axi_port     => 0,
      mem_num          => CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE,
      mem_info         => tile_mem_list(0 to CFG_NMEM_TILE + CFG_NSLM_TILE - 1), --tile_mem_list, --nofb_mem_info,
      slv_y            => tile_x(slm_tile_id(0)), --this_local_y, --io_y,
      slv_x            => tile_y(slm_tile_id(0))) --this_local_x) --, io_x)
    port map (
      rst                        => rst,
      clk                        => clk,
      local_y                    => this_local_y, --local_y,
      local_x                    => this_local_x, --local_x,
      mosi                       => mosi,
      somi                       => somi,
      coherence_req_wrreq        => prc_dma_snd_wrreq,
      coherence_req_data_in      => prc_dma_snd_data_in,
      coherence_req_full         => prc_dma_snd_full,
      coherence_rsp_rcv_rdreq    => prc_dma_rcv_rdreq,
      coherence_rsp_rcv_data_out => prc_dma_rcv_data_out,
      coherence_rsp_rcv_empty    => prc_dma_rcv_empty,
      remote_ahbs_snd_wrreq      => open,
      remote_ahbs_snd_data_in    => open,
      remote_ahbs_snd_full       => '0',
      remote_ahbs_rcv_rdreq      => open,
      remote_ahbs_rcv_data_out   => (others => '0'),
      remote_ahbs_rcv_empty      => '1',
      coherence                  => prc_coherence);

      mosi(0).ar.addr(31 downto 0)      <= m_axi_mem_araddr;
      mosi(0).ar.len                    <= m_axi_mem_arlen;
      mosi(0).ar.size                   <= m_axi_mem_arsize;
      mosi(0).ar.burst                  <= m_axi_mem_arburst;
      mosi(0).ar.prot                   <= m_axi_mem_arprot;
      mosi(0).ar.cache                  <= m_axi_mem_arcache;
      mosi(0).ar.valid                  <= m_axi_mem_arvalid;
      mosi(0).r.ready                   <= m_axi_mem_rready;
      m_axi_mem_arready                 <= somi(0).ar.ready;
      m_axi_mem_rdata                   <= somi(0).r.data(31 downto 0);
      m_axi_mem_rresp                   <= somi(0).r.resp;
      m_axi_mem_rlast                   <= somi(0).r.last;
      m_axi_mem_rvalid                  <= somi(0).r.valid;

    -- Handle non-coherent mem requests from the PRC (reconfigurable bitstreams)
    noc2ahbmst_prc : noc2ahbmst
      generic map (
        tech        => CFG_FABTECH,
        hindex      => 2,
        axitran     => GLOB_CPU_AXI,
        little_end  => GLOB_CPU_RISCV,
        eth_dma     => 0,
        narrow_noc  => 0,
        cacheline   => CFG_DLINE,
        l2_cache_en => CFG_L2_ENABLE)
      port map (
        rst                       => rst,
        clk                       => clk,
        local_y                   => this_local_y,
        local_x                   => this_local_x,
        ahbmi                     => ahbmi,
        ahbmo                     => ahbmo(2),
        coherence_req_rdreq       => open,
        coherence_req_data_out    => (others => '0'),
        coherence_req_empty       => '1',
        coherence_fwd_wrreq       => open,
        coherence_fwd_data_in     => open,
        coherence_fwd_full        => '0',
        coherence_rsp_snd_wrreq   => open,
        coherence_rsp_snd_data_in => open,
        coherence_rsp_snd_full    => '0',
        dma_rcv_rdreq             => prc_noc2ahbm_dma_rcv_rdreq,
        dma_rcv_data_out          => prc_noc2ahbm_dma_rcv_data_out,
        dma_rcv_empty             => prc_noc2ahbm_dma_rcv_empty,
        dma_snd_wrreq             => prc_noc2ahbm_dma_snd_wrreq,
        dma_snd_data_in           => prc_noc2ahbm_dma_snd_data_in,
        dma_snd_full              => prc_noc2ahbm_dma_snd_full,
        dma_snd_atleast_4slots    => '1', --prc_noc2ahbm_dma_snd_atleast_4slots,
        dma_snd_exactly_3slots    => '0'); --prc_noc2ahbm_dma_snd_exactly_3slots);

     fifo0_from_prc : fifo0 
     generic map (
      depth => 1024,
      width => NOC_FLIT_SIZE)
     port map (
      clk      => clk,
      rst      => rst,
      rdreq    => prc_noc2ahbm_dma_rcv_rdreq,
      wrreq    => prc_dma_snd_wrreq,
      data_in  => prc_dma_snd_data_in,
      empty    => prc_noc2ahbm_dma_rcv_empty,
      full     => prc_dma_snd_full,
      data_out => prc_noc2ahbm_dma_rcv_data_out);

     fifo0_to_prc : fifo0 
     generic map (
      depth => 1024,
      width => NOC_FLIT_SIZE)
     port map (
      clk      => clk,
      rst      => rst,
      rdreq    => prc_dma_rcv_rdreq,
      wrreq    => prc_noc2ahbm_dma_snd_wrreq,
      data_in  => prc_noc2ahbm_dma_snd_data_in,
      empty    => prc_dma_rcv_empty,
      full     => prc_noc2ahbm_dma_snd_full,
      data_out => prc_dma_rcv_data_out);

    end generate disable_prc;


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
