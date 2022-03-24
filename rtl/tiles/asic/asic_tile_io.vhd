-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  I/O tile.
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
use work.uart.all;
use work.misc.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.ariane_esp_pkg.all;
use work.tiles_pkg.all;

entity asic_tile_io is
  generic (
    SIMULATION   : boolean   := false;
    ROUTER_PORTS : ports_vec := "11111");
  port (
    rst                : in    std_ulogic;  -- Global reset (active high)
    sys_rstn_out       : out   std_ulogic;  -- NoC reset (active low)
    sys_clk_out        : out   std_ulogic;  -- NoC clock
    ext_clk_noc        : in    std_ulogic;
    clk_div_noc        : out   std_ulogic;
    sys_clk            : in    std_ulogic;  -- NoC clock in (connect to sys_clk_out)
    ext_clk            : in    std_ulogic;  -- backup tile clock
    clk_div            : out   std_ulogic;  -- tile clock monitor for testing purposes
    -- Ethernet
    reset_o2           : out   std_ulogic;
    etx_clk            : in    std_ulogic;
    erx_clk            : in    std_ulogic;
    erxd               : in    std_logic_vector(3 downto 0);
    erx_dv             : in    std_ulogic;
    erx_er             : in    std_ulogic;
    erx_col            : in    std_ulogic;
    erx_crs            : in    std_ulogic;
    etxd               : out   std_logic_vector(3 downto 0);
    etx_en             : out   std_ulogic;
    etx_er             : out   std_ulogic;
    emdc               : out   std_ulogic;
    emdio_i            : in    std_ulogic;
    emdio_o            : out   std_ulogic;
    emdio_oe           : out   std_ulogic;
    -- UART
    uart_rxd           : in    std_ulogic;
    uart_txd           : out   std_ulogic;
    uart_ctsn          : in    std_ulogic;
    uart_rtsn          : out   std_ulogic;
    -- Test interface
    tdi                : in    std_logic;
    tdo                : out   std_logic;
    tms                : in    std_logic;
    tclk               : in    std_logic;
    -- Pad configuratio
    pad_cfg            : out std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
    -- NOC
    noc1_data_n_in     : in    noc_flit_type;
    noc1_data_s_in     : in    noc_flit_type;
    noc1_data_w_in     : in    noc_flit_type;
    noc1_data_e_in     : in    noc_flit_type;
    noc1_data_void_in  : in    std_logic_vector(3 downto 0);
    noc1_stop_in       : in    std_logic_vector(3 downto 0);
    noc1_data_n_out    : out   noc_flit_type;
    noc1_data_s_out    : out   noc_flit_type;
    noc1_data_w_out    : out   noc_flit_type;
    noc1_data_e_out    : out   noc_flit_type;
    noc1_data_void_out : out   std_logic_vector(3 downto 0);
    noc1_stop_out      : out   std_logic_vector(3 downto 0);
    noc2_data_n_in     : in    noc_flit_type;
    noc2_data_s_in     : in    noc_flit_type;
    noc2_data_w_in     : in    noc_flit_type;
    noc2_data_e_in     : in    noc_flit_type;
    noc2_data_void_in  : in    std_logic_vector(3 downto 0);
    noc2_stop_in       : in    std_logic_vector(3 downto 0);
    noc2_data_n_out    : out   noc_flit_type;
    noc2_data_s_out    : out   noc_flit_type;
    noc2_data_w_out    : out   noc_flit_type;
    noc2_data_e_out    : out   noc_flit_type;
    noc2_data_void_out : out   std_logic_vector(3 downto 0);
    noc2_stop_out      : out   std_logic_vector(3 downto 0);
    noc3_data_n_in     : in    noc_flit_type;
    noc3_data_s_in     : in    noc_flit_type;
    noc3_data_w_in     : in    noc_flit_type;
    noc3_data_e_in     : in    noc_flit_type;
    noc3_data_void_in  : in    std_logic_vector(3 downto 0);
    noc3_stop_in       : in    std_logic_vector(3 downto 0);
    noc3_data_n_out    : out   noc_flit_type;
    noc3_data_s_out    : out   noc_flit_type;
    noc3_data_w_out    : out   noc_flit_type;
    noc3_data_e_out    : out   noc_flit_type;
    noc3_data_void_out : out   std_logic_vector(3 downto 0);
    noc3_stop_out      : out   std_logic_vector(3 downto 0);
    noc4_data_n_in     : in    noc_flit_type;
    noc4_data_s_in     : in    noc_flit_type;
    noc4_data_w_in     : in    noc_flit_type;
    noc4_data_e_in     : in    noc_flit_type;
    noc4_data_void_in  : in    std_logic_vector(3 downto 0);
    noc4_stop_in       : in    std_logic_vector(3 downto 0);
    noc4_data_n_out    : out   noc_flit_type;
    noc4_data_s_out    : out   noc_flit_type;
    noc4_data_w_out    : out   noc_flit_type;
    noc4_data_e_out    : out   noc_flit_type;
    noc4_data_void_out : out   std_logic_vector(3 downto 0);
    noc4_stop_out      : out   std_logic_vector(3 downto 0);
    noc5_data_n_in     : in    misc_noc_flit_type;
    noc5_data_s_in     : in    misc_noc_flit_type;
    noc5_data_w_in     : in    misc_noc_flit_type;
    noc5_data_e_in     : in    misc_noc_flit_type;
    noc5_data_void_in  : in    std_logic_vector(3 downto 0);
    noc5_stop_in       : in    std_logic_vector(3 downto 0);
    noc5_data_n_out    : out   misc_noc_flit_type;
    noc5_data_s_out    : out   misc_noc_flit_type;
    noc5_data_w_out    : out   misc_noc_flit_type;
    noc5_data_e_out    : out   misc_noc_flit_type;
    noc5_data_void_out : out   std_logic_vector(3 downto 0);
    noc5_stop_out      : out   std_logic_vector(3 downto 0);
    noc6_data_n_in     : in    noc_flit_type;
    noc6_data_s_in     : in    noc_flit_type;
    noc6_data_w_in     : in    noc_flit_type;
    noc6_data_e_in     : in    noc_flit_type;
    noc6_data_void_in  : in    std_logic_vector(3 downto 0);
    noc6_stop_in       : in    std_logic_vector(3 downto 0);
    noc6_data_n_out    : out   noc_flit_type;
    noc6_data_s_out    : out   noc_flit_type;
    noc6_data_w_out    : out   noc_flit_type;
    noc6_data_e_out    : out   noc_flit_type;
    noc6_data_void_out : out   std_logic_vector(3 downto 0);
    noc6_stop_out      : out   std_logic_vector(3 downto 0)
    );

end;

architecture rtl of asic_tile_io is

  constant ext_clk_sel_default : std_ulogic := '0';

  -- NoC clock and reset (reset propagates to all tiles)
  signal raw_rstn     : std_ulogic;
  signal sys_rstn     : std_ulogic;
  signal noc_rstn              : std_ulogic;
  signal sys_clk_int  : std_ulogic;
  signal sys_clk_lock : std_ulogic;

  -- Tile clock and reset (only for I/O tile)
  signal dco_rstn     : std_ulogic;
  signal dco_clk      : std_ulogic;

  -- DCO config
  signal dco_en       : std_ulogic;
  signal dco_clk_sel  : std_ulogic;
  signal dco_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_div_sel  : std_logic_vector(2 downto 0);
  signal dco_freq_sel : std_logic_vector(1 downto 0);

  -- NoC DCO config
  signal dco_noc_en       : std_ulogic;
  signal dco_noc_clk_sel  : std_ulogic;
  signal dco_noc_cc_sel   : std_logic_vector(5 downto 0);
  signal dco_noc_fc_sel   : std_logic_vector(5 downto 0);
  signal dco_noc_div_sel  : std_logic_vector(2 downto 0);
  signal dco_noc_freq_sel : std_logic_vector(1 downto 0);

  -- Tile parameters
  signal tile_config : std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0);
  
  -- Ethernet and Debug link
  signal mdcscaler : integer range 0 to 2047;
  signal mdcscaler_reg : integer range 0 to 2047;
  signal mdcscaler_not_changed : std_ulogic;
  signal eth_rstn : std_ulogic;

  signal eth0_apbi  : apb_slv_in_type;
  signal eth0_apbo  : apb_slv_out_type;
  signal eth0_ahbmi : ahb_mst_in_type;
  signal eth0_ahbmo : ahb_mst_out_type;
  signal edcl_ahbmo : ahb_mst_out_type;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;

  -- DVI (TODO: missing part selection for GF12. no instance for now)
  signal dvi_apbi  : apb_slv_in_type;
  signal dvi_apbo  : apb_slv_out_type;
  signal dvi_ahbmi : ahb_mst_in_type;
  signal dvi_ahbmo : ahb_mst_out_type;

  attribute keep                        : string;
  attribute syn_keep                    : boolean;
  attribute syn_preserve                : boolean;

  attribute keep of dco_clk         : signal is "true";
  attribute syn_keep of dco_clk     : signal is true;
  attribute syn_preserve of dco_clk : signal is true;

  -- Tile NoC interface
  signal test_rstn             : std_ulogic;
  signal test1_output_port_s   : noc_flit_type;
  signal test1_data_void_out_s : std_ulogic;
  signal test1_stop_in_s       : std_ulogic;
  signal test2_output_port_s   : noc_flit_type;
  signal test2_data_void_out_s : std_ulogic;
  signal test2_stop_in_s       : std_ulogic;
  signal test3_output_port_s   : noc_flit_type;
  signal test3_data_void_out_s : std_ulogic;
  signal test3_stop_in_s       : std_ulogic;
  signal test4_output_port_s   : noc_flit_type;
  signal test4_data_void_out_s : std_ulogic;
  signal test4_stop_in_s       : std_ulogic;
  signal test5_output_port_s   : misc_noc_flit_type;
  signal test5_data_void_out_s : std_ulogic;
  signal test5_stop_in_s       : std_ulogic;
  signal test6_output_port_s   : noc_flit_type;
  signal test6_data_void_out_s : std_ulogic;
  signal test6_stop_in_s       : std_ulogic;
  signal test1_input_port_s    : noc_flit_type;
  signal test1_data_void_in_s  : std_ulogic;
  signal test1_stop_out_s      : std_ulogic;
  signal test2_input_port_s    : noc_flit_type;
  signal test2_data_void_in_s  : std_ulogic;
  signal test2_stop_out_s      : std_ulogic;
  signal test3_input_port_s    : noc_flit_type;
  signal test3_data_void_in_s  : std_ulogic;
  signal test3_stop_out_s      : std_ulogic;
  signal test4_input_port_s    : noc_flit_type;
  signal test4_data_void_in_s  : std_ulogic;
  signal test4_stop_out_s      : std_ulogic;
  signal test5_input_port_s    : misc_noc_flit_type;
  signal test5_data_void_in_s  : std_ulogic;
  signal test5_stop_out_s      : std_ulogic;
  signal test6_input_port_s    : noc_flit_type;
  signal test6_data_void_in_s  : std_ulogic;
  signal test6_stop_out_s      : std_ulogic;
  
  -- Noc interface
  signal noc1_stop_in_tile       : std_ulogic;
  signal noc1_stop_out_tile      : std_ulogic;
  signal noc1_data_void_in_tile  : std_ulogic;
  signal noc1_data_void_out_tile : std_ulogic;
  signal noc2_stop_in_tile       : std_ulogic;
  signal noc2_stop_out_tile      : std_ulogic;
  signal noc2_data_void_in_tile  : std_ulogic;
  signal noc2_data_void_out_tile : std_ulogic;
  signal noc3_stop_in_tile       : std_ulogic;
  signal noc3_stop_out_tile      : std_ulogic;
  signal noc3_data_void_in_tile  : std_ulogic;
  signal noc3_data_void_out_tile : std_ulogic;
  signal noc4_stop_in_tile       : std_ulogic;
  signal noc4_stop_out_tile      : std_ulogic;
  signal noc4_data_void_in_tile  : std_ulogic;
  signal noc4_data_void_out_tile : std_ulogic;
  signal noc5_stop_in_tile       : std_ulogic;
  signal noc5_stop_out_tile      : std_ulogic;
  signal noc5_data_void_in_tile  : std_ulogic;
  signal noc5_data_void_out_tile : std_ulogic;
  signal noc6_stop_in_tile       : std_ulogic;
  signal noc6_stop_out_tile      : std_ulogic;
  signal noc6_data_void_in_tile  : std_ulogic;
  signal noc6_data_void_out_tile : std_ulogic;
  signal noc1_input_port_tile        : noc_flit_type;
  signal noc2_input_port_tile        : noc_flit_type;
  signal noc3_input_port_tile        : noc_flit_type;
  signal noc4_input_port_tile        : noc_flit_type;
  signal noc5_input_port_tile        : misc_noc_flit_type;
  signal noc6_input_port_tile        : noc_flit_type;
  signal noc1_output_port_tile       : noc_flit_type;
  signal noc2_output_port_tile       : noc_flit_type;
  signal noc3_output_port_tile       : noc_flit_type;
  signal noc4_output_port_tile       : noc_flit_type;
  signal noc5_output_port_tile       : misc_noc_flit_type;
  signal noc6_output_port_tile       : noc_flit_type;

  -- NoC monitors
  signal mon_noc : monitor_noc_vector(1 to 6);

begin

  rst0 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk, sys_clk_lock, sys_rstn, open);

  -- NoC output clock and reset
  sys_rstn_out <= sys_rstn;

  raw_rstn <= not rst;

  rst_noc : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk, '1', noc_rstn, open);

  rst_jtag : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (rst, tclk, '1', test_rstn, open);

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => 1)
    port map (
      rst                 => test_rstn,
      refclk              => dco_clk,
      tile_rst            => dco_rstn,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port_tile,
      noc1_data_void_out  => noc1_data_void_out_tile,
      noc1_stop_in        => noc1_stop_in_tile,
      noc2_output_port    => noc2_output_port_tile,
      noc2_data_void_out  => noc2_data_void_out_tile,
      noc2_stop_in        => noc2_stop_in_tile,
      noc3_output_port    => noc3_output_port_tile,
      noc3_data_void_out  => noc3_data_void_out_tile,
      noc3_stop_in        => noc3_stop_in_tile,
      noc4_output_port    => noc4_output_port_tile,
      noc4_data_void_out  => noc4_data_void_out_tile,
      noc4_stop_in        => noc4_stop_in_tile,
      noc5_output_port    => noc5_output_port_tile,
      noc5_data_void_out  => noc5_data_void_out_tile,
      noc5_stop_in        => noc5_stop_in_tile,
      noc6_output_port    => noc6_output_port_tile,
      noc6_data_void_out  => noc6_data_void_out_tile,
      noc6_stop_in        => noc6_stop_in_tile,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_in_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_out_s,
      noc1_input_port     => noc1_input_port_tile,
      noc1_data_void_in   => noc1_data_void_in_tile,
      noc1_stop_out       => noc1_stop_out_tile,
      noc2_input_port     => noc2_input_port_tile,
      noc2_data_void_in   => noc2_data_void_in_tile,
      noc2_stop_out       => noc2_stop_out_tile,
      noc3_input_port     => noc3_input_port_tile,
      noc3_data_void_in   => noc3_data_void_in_tile,
      noc3_stop_out       => noc3_stop_out_tile,
      noc4_input_port     => noc4_input_port_tile,
      noc4_data_void_in   => noc4_data_void_in_tile,
      noc4_stop_out       => noc4_stop_out_tile,
      noc5_input_port     => noc5_input_port_tile,
      noc5_data_void_in   => noc5_data_void_in_tile,
      noc5_stop_out       => noc5_stop_out_tile,
      noc6_input_port     => noc6_input_port_tile,
      noc6_data_void_in   => noc6_data_void_in_tile,
      noc6_stop_out       => noc6_stop_out_tile);

  -----------------------------------------------------------------------
  ---  ETHERNET ---------------------------------------------------------
  -----------------------------------------------------------------------
  -- Reset Ethernet if MDC scaler value changes
  eth_rstn_gen: process (dco_clk) is
  begin  -- process eth_rstn_gen
    if dco_clk'event and dco_clk = '1' then  -- rising clock edge
      mdcscaler_reg <= mdcscaler;
    end if;
  end process eth_rstn_gen;

    -- MDC scaler configuration
  mdcscaler              <= conv_integer(tile_config(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB));
  mdcscaler_not_changed <= '1' when mdcscaler_reg = mdcscaler else '0';
  eth_rstn <= dco_rstn and mdcscaler_not_changed;

  e1 : grethm
    generic map(
      hindex      => 0,
      ehindex     => 1,
      pindex      => 14,
      paddr       => 16#800#,
      pmask       => 16#f00#,
      pirq        => 12,
      little_end  => GLOB_CPU_AXI * CFG_L2_DISABLE,
      memtech     => CFG_FABTECH,
      enable_mdio => 1,
      fifosize    => CFG_ETH_FIFO,
      nsync       => 1,
      oepol       => 1,
      edcl        => CFG_DSU_ETH,
      edclbufsz   => CFG_ETH_BUF,
      macaddrh    => CFG_ETH_ENM,
      macaddrl    => CFG_ETH_ENL,
      phyrstadr   => 1,
      ipaddrh     => CFG_ETH_IPM,
      ipaddrl     => CFG_ETH_IPL,
      giga        => CFG_GRETH1G,
      edclsepahbg => 1)
    port map(
      rst    => dco_rstn,
      clk    => dco_clk,                -- Fixed I/O tile frequency
      mdcscaler => mdcscaler,
      ahbmi  => eth0_ahbmi,
      ahbmo  => eth0_ahbmo,
      eahbmo => edcl_ahbmo,
      apbi   => eth0_apbi,
      apbo   => eth0_apbo,
      ethi   => ethi,
      etho   => etho);

  ethi.edclsepahb <= '1';

  -- Ethernet I/O
  reset_o2             <= dco_rstn;
  ethi.tx_clk          <= etx_clk;
  ethi.rx_clk          <= erx_clk;
  ethi.rxd(3 downto 0) <= erxd;
  ethi.rx_dv           <= erx_dv;
  ethi.rx_er           <= erx_er;
  ethi.rx_col          <= erx_col;
  ethi.rx_crs          <= erx_crs;
  ethi.mdio_i          <= emdio_i;

  etxd     <= etho.txd(3 downto 0);
  etx_en   <= etho.tx_en;
  etx_er   <= etho.tx_er;
  emdc     <= etho.mdc;
  emdio_o  <= etho.mdio_o;
  emdio_oe <= etho.mdio_oe;

  -----------------------------------------------------------------------------
  -- DVI (not available for GF12 for now)
  -----------------------------------------------------------------------------
  -- To tile
  dvi_apbo  <= apb_none;
  dvi_ahbmo <= ahbm_none;

  -----------------------------------------------------------------------------
  -- Tile
  -----------------------------------------------------------------------------
  tile_io_1 : tile_io
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => 1)
    port map (
      raw_rstn           => raw_rstn,
      tile_rst           => rst,
      clk                => dco_clk,    -- Local DCO clock
      refclk_noc         => ext_clk_noc,  -- Backup NoC clock when DCO is enabled
      pllclk_noc         => clk_div_noc,  -- NoC DCO clock out
      refclk             => ext_clk,    -- Local backup ext clock
      pllbypass          => ext_clk_sel_default,  --ext_clk_sel,
      pllclk             => clk_div,    -- DCO clock monitor
      dco_clk            => dco_clk,    -- Local DCO clock out (fixed @ TILE_FREQ)
      dco_rstn           => dco_rstn,
      -- DCO config
      dco_freq_sel       => dco_freq_sel,
      dco_div_sel        => dco_div_sel,
      dco_fc_sel         => dco_fc_sel,
      dco_cc_sel         => dco_cc_sel,
      dco_clk_sel        => dco_clk_sel,
      dco_en             => dco_en,
      -- NoC DCO config
      dco_noc_freq_sel   => dco_noc_freq_sel,
      dco_noc_div_sel    => dco_noc_div_sel,
      dco_noc_fc_sel     => dco_noc_fc_sel,
      dco_noc_cc_sel     => dco_noc_cc_sel,
      dco_noc_clk_sel    => dco_noc_clk_sel,
      dco_noc_en         => dco_noc_en,
      -- Ethernet
      eth0_apbi          => eth0_apbi,
      eth0_apbo          => eth0_apbo,
      sgmii0_apbi        => open,
      sgmii0_apbo        => apb_none,
      eth0_ahbmi         => eth0_ahbmi,
      eth0_ahbmo         => eth0_ahbmo,
      edcl_ahbmo         => edcl_ahbmo,
      -- DVI
      dvi_apbi           => dvi_apbi,
      dvi_apbo           => dvi_apbo,
      dvi_ahbmi          => dvi_ahbmi,
      dvi_ahbmo          => dvi_ahbmo,
      -- UART
      uart_rxd           => uart_rxd,
      uart_txd           => uart_txd,
      uart_ctsn          => uart_ctsn,
      uart_rtsn          => uart_rtsn,
      -- NOC
      sys_clk_out        => sys_clk_out,  -- Global NoC clock out
      sys_clk_lock       => sys_clk_lock,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_out_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_in_s,
      mon_noc             => mon_noc,
      mon_dvfs            => open);

  noc_domain_socket_i : noc_domain_socket
    generic map (
      this_has_token_pm => 0,
      is_tile_io        => true,
      SIMULATION        => SIMULATION,
      ROUTER_PORTS      => ROUTER_PORTS,
      HAS_SYNC          => 1,
      is_asic           => true)
    port map (
      raw_rstn                => raw_rstn,
      noc_rstn                => noc_rstn,
      dco_rstn                => dco_rstn,
      sys_clk                 => sys_clk,
      dco_clk                 => dco_clk,
      acc_clk                 => open,
      refclk                  => dco_clk,
      plllock                 => open,
      -- CSRs
      tile_config             => tile_config,
      -- DCO config
      dco_freq_sel            => dco_freq_sel,
      dco_div_sel             => dco_div_sel,
      dco_fc_sel              => dco_fc_sel,
      dco_cc_sel              => dco_cc_sel,
      dco_clk_sel             => dco_clk_sel,
      dco_en                  => dco_en,
      dco_clk_delay_sel       => open,
      ext_dco_cc_sel          => (others => '0'),
      ext_ldo_res_sel         => (others => '0'),
      -- pad config
      pad_cfg                 => pad_cfg,
      -- NoC
      noc1_data_n_in          => noc1_data_n_in,
      noc1_data_s_in          => noc1_data_s_in,
      noc1_data_w_in          => noc1_data_w_in,
      noc1_data_e_in          => noc1_data_e_in,
      noc1_data_void_in       => noc1_data_void_in,
      noc1_stop_in            => noc1_stop_in,
      noc1_data_n_out         => noc1_data_n_out,
      noc1_data_s_out         => noc1_data_s_out,
      noc1_data_w_out         => noc1_data_w_out,
      noc1_data_e_out         => noc1_data_e_out,
      noc1_data_void_out      => noc1_data_void_out,
      noc1_stop_out           => noc1_stop_out,
      noc2_data_n_in          => noc2_data_n_in,
      noc2_data_s_in          => noc2_data_s_in,
      noc2_data_w_in          => noc2_data_w_in,
      noc2_data_e_in          => noc2_data_e_in,
      noc2_data_void_in       => noc2_data_void_in,
      noc2_stop_in            => noc2_stop_in,
      noc2_data_n_out         => noc2_data_n_out,
      noc2_data_s_out         => noc2_data_s_out,
      noc2_data_w_out         => noc2_data_w_out,
      noc2_data_e_out         => noc2_data_e_out,
      noc2_data_void_out      => noc2_data_void_out,
      noc2_stop_out           => noc2_stop_out,
      noc3_data_n_in          => noc3_data_n_in,
      noc3_data_s_in          => noc3_data_s_in,
      noc3_data_w_in          => noc3_data_w_in,
      noc3_data_e_in          => noc3_data_e_in,
      noc3_data_void_in       => noc3_data_void_in,
      noc3_stop_in            => noc3_stop_in,
      noc3_data_n_out         => noc3_data_n_out,
      noc3_data_s_out         => noc3_data_s_out,
      noc3_data_w_out         => noc3_data_w_out,
      noc3_data_e_out         => noc3_data_e_out,
      noc3_data_void_out      => noc3_data_void_out,
      noc3_stop_out           => noc3_stop_out,
      noc4_data_n_in          => noc4_data_n_in,
      noc4_data_s_in          => noc4_data_s_in,
      noc4_data_w_in          => noc4_data_w_in,
      noc4_data_e_in          => noc4_data_e_in,
      noc4_data_void_in       => noc4_data_void_in,
      noc4_stop_in            => noc4_stop_in,
      noc4_data_n_out         => noc4_data_n_out,
      noc4_data_s_out         => noc4_data_s_out,
      noc4_data_w_out         => noc4_data_w_out,
      noc4_data_e_out         => noc4_data_e_out,
      noc4_data_void_out      => noc4_data_void_out,
      noc4_stop_out           => noc4_stop_out,
      noc5_data_n_in          => noc5_data_n_in,
      noc5_data_s_in          => noc5_data_s_in,
      noc5_data_w_in          => noc5_data_w_in,
      noc5_data_e_in          => noc5_data_e_in,
      noc5_data_void_in       => noc5_data_void_in,
      noc5_stop_in            => noc5_stop_in,
      noc5_data_n_out         => noc5_data_n_out,
      noc5_data_s_out         => noc5_data_s_out,
      noc5_data_w_out         => noc5_data_w_out,
      noc5_data_e_out         => noc5_data_e_out,
      noc5_data_void_out      => noc5_data_void_out,
      noc5_stop_out           => noc5_stop_out,
      noc6_data_n_in          => noc6_data_n_in,
      noc6_data_s_in          => noc6_data_s_in,
      noc6_data_w_in          => noc6_data_w_in,
      noc6_data_e_in          => noc6_data_e_in,
      noc6_data_void_in       => noc6_data_void_in,
      noc6_stop_in            => noc6_stop_in,
      noc6_data_n_out         => noc6_data_n_out,
      noc6_data_s_out         => noc6_data_s_out,
      noc6_data_w_out         => noc6_data_w_out,
      noc6_data_e_out         => noc6_data_e_out,
      noc6_data_void_out      => noc6_data_void_out,
      noc6_stop_out           => noc6_stop_out,
      -- monitors
      mon_noc                 => mon_noc,
      -- synchronizers out to tile
      noc1_output_port_tile   => noc1_output_port_tile,
      noc1_data_void_out_tile => noc1_data_void_out_tile,
      noc1_stop_in_tile       => noc1_stop_in_tile,
      noc2_output_port_tile   => noc2_output_port_tile,
      noc2_data_void_out_tile => noc2_data_void_out_tile,
      noc2_stop_in_tile       => noc2_stop_in_tile,
      noc3_output_port_tile   => noc3_output_port_tile,
      noc3_data_void_out_tile => noc3_data_void_out_tile,
      noc3_stop_in_tile       => noc3_stop_in_tile,
      noc4_output_port_tile   => noc4_output_port_tile,
      noc4_data_void_out_tile => noc4_data_void_out_tile,
      noc4_stop_in_tile       => noc4_stop_in_tile,
      noc5_output_port_tile   => noc5_output_port_tile,
      noc5_data_void_out_tile => noc5_data_void_out_tile,
      noc5_stop_in_tile       => noc5_stop_in_tile,
      noc6_output_port_tile   => noc6_output_port_tile,
      noc6_data_void_out_tile => noc6_data_void_out_tile,
      noc6_stop_in_tile       => noc6_stop_in_tile,
      -- tile to synchronizers in
      noc1_input_port_tile    => noc1_input_port_tile,
      noc1_data_void_in_tile  => noc1_data_void_in_tile,
      noc1_stop_out_tile      => noc1_stop_out_tile,
      noc2_input_port_tile    => noc2_input_port_tile,
      noc2_data_void_in_tile  => noc2_data_void_in_tile,
      noc2_stop_out_tile      => noc2_stop_out_tile,
      noc3_input_port_tile    => noc3_input_port_tile,
      noc3_data_void_in_tile  => noc3_data_void_in_tile,
      noc3_stop_out_tile      => noc3_stop_out_tile,
      noc4_input_port_tile    => noc4_input_port_tile,
      noc4_data_void_in_tile  => noc4_data_void_in_tile,
      noc4_stop_out_tile      => noc4_stop_out_tile,
      noc5_input_port_tile    => noc5_input_port_tile,
      noc5_data_void_in_tile  => noc5_data_void_in_tile,
      noc5_stop_out_tile      => noc5_stop_out_tile,
      noc6_input_port_tile    => noc6_input_port_tile,
      noc6_data_void_in_tile  => noc6_data_void_in_tile,
      noc6_stop_out_tile      => noc6_stop_out_tile);

  dco_noc_freq_sel <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 0  downto ESP_CSR_DCO_NOC_CFG_MSB - 0  - 1);
  dco_noc_div_sel  <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 2  downto ESP_CSR_DCO_NOC_CFG_MSB - 2  - 2);
  dco_noc_fc_sel   <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 5  downto ESP_CSR_DCO_NOC_CFG_MSB - 5  - 5);
  dco_noc_cc_sel   <= tile_config(ESP_CSR_DCO_NOC_CFG_MSB - 11 downto ESP_CSR_DCO_NOC_CFG_MSB - 11 - 5);
  dco_noc_clk_sel  <= tile_config(ESP_CSR_DCO_NOC_CFG_LSB + 1);
  dco_noc_en       <= raw_rstn and tile_config(ESP_CSR_DCO_NOC_CFG_LSB);
  
end;
