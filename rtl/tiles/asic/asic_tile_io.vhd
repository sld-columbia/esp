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
use work.esp_csr_pkg.all;
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
    -- ext_clk_sel     : in  std_ulogic;  -- backup tile clock select ??(usign registers otherwise)
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
    -- DVI
    -- dvi_nhpd           : in    std_ulogic;
    -- clkvga_p           : out   std_ulogic;
    -- clkvga_n           : out   std_ulogic;
    -- dvi_data           : out   std_logic_vector(23 downto 0);
    -- dvi_hsync          : out   std_ulogic;
    -- dvi_vsync          : out   std_ulogic;
    -- dvi_de             : out   std_ulogic;
    -- dvi_dken           : out   std_ulogic;
    -- dvi_ctl1_a1_dk1    : out   std_ulogic;
    -- dvi_ctl2_a2_dk2    : out   std_ulogic;
    -- dvi_a3_dk3         : out   std_ulogic;
    -- dvi_isel           : out   std_ulogic;
    -- dvi_bsel           : out   std_ulogic;
    -- dvi_dsel           : out   std_ulogic;
    -- dvi_edge           : out   std_ulogic;
    -- dvi_npd            : out   std_ulogic;
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
  signal sys_clk_int  : std_ulogic;
  signal sys_clk_lock : std_ulogic;
  signal sys_rstn     : std_ulogic;
  signal raw_rstn     : std_ulogic;

  -- Tile clock and reset (only for I/O tile)
  signal dco_clk      : std_ulogic;
  signal dco_rstn     : std_ulogic;
  signal dco_clk_lock : std_ulogic;

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

  attribute keep                        : boolean;
  attribute syn_keep                    : boolean;
  attribute syn_preserve                : boolean;

  attribute keep of dco_clk         : signal is true;
  attribute syn_keep of dco_clk     : signal is true;
  attribute syn_preserve of dco_clk : signal is true;

begin

  rst0 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk, sys_clk_lock, sys_rstn, raw_rstn);

  rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, dco_clk, dco_clk_lock, dco_rstn, open);

  -- NoC output clock and reset
  sys_rstn_out <= sys_rstn;

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

  -- I/O
  -- clkvga_p           <= '0';
  -- clkvga_n           <= '0';
  -- dvi_data           <= (others => '0');
  -- dvi_hsync          <= '0';
  -- dvi_vsync          <= '0';
  -- dvi_de             <= '0';
  -- dvi_dken           <= '0';
  -- dvi_ctl1_a1_dk1    <= '0';
  -- dvi_ctl2_a2_dk2    <= '0';
  -- dvi_a3_dk3         <= '0';
  -- dvi_isel           <= '0';
  -- dvi_bsel           <= '0';
  -- dvi_dsel           <= '0';
  -- dvi_edge           <= '0';
  -- dvi_npd            <= '0';

  -----------------------------------------------------------------------------
  -- Tile
  -----------------------------------------------------------------------------
  tile_io_1 : tile_io
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => 1,
      test_if_en   => 1,
      ROUTER_PORTS => ROUTER_PORTS,
      HAS_SYNC     => 1)
    port map (
      raw_rstn           => raw_rstn,
      rst                => dco_rstn,
      clk                => dco_clk,    -- Local DCO clock
      refclk_noc         => ext_clk_noc,  -- Backup NoC clock when DCO is enabled
      pllclk_noc         => clk_div_noc,  -- NoC DCO clock out
      refclk             => ext_clk,    -- Local backup ext clock
      pllbypass          => ext_clk_sel_default,  --ext_clk_sel,
      pllclk             => clk_div,    -- DCO clock monitor
      dco_clk            => dco_clk,    -- Local DCO clock out (fixed @ TILE_FREQ)
      dco_clk_lock       => dco_clk_lock,
      -- Test interface
      tdi                => tdi,
      tdo                => tdo,
      tms                => tms,
      tclk               => tclk,
      -- Ethernet MDC Scaler configuration
      mdcscaler          => mdcscaler,
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
      -- Pad configuration
      pad_cfg            => pad_cfg,
      -- NOC
      sys_clk_int        => sys_clk,      -- Global NoC clock in
      sys_rstn           => sys_rstn,
      sys_clk_out        => sys_clk_out,  -- Global NoC clock out
      sys_clk_lock       => sys_clk_lock,
      noc1_data_n_in     => noc1_data_n_in,
      noc1_data_s_in     => noc1_data_s_in,
      noc1_data_w_in     => noc1_data_w_in,
      noc1_data_e_in     => noc1_data_e_in,
      noc1_data_void_in  => noc1_data_void_in,
      noc1_stop_in       => noc1_stop_in,
      noc1_data_n_out    => noc1_data_n_out,
      noc1_data_s_out    => noc1_data_s_out,
      noc1_data_w_out    => noc1_data_w_out,
      noc1_data_e_out    => noc1_data_e_out,
      noc1_data_void_out => noc1_data_void_out,
      noc1_stop_out      => noc1_stop_out,
      noc2_data_n_in     => noc2_data_n_in,
      noc2_data_s_in     => noc2_data_s_in,
      noc2_data_w_in     => noc2_data_w_in,
      noc2_data_e_in     => noc2_data_e_in,
      noc2_data_void_in  => noc2_data_void_in,
      noc2_stop_in       => noc2_stop_in,
      noc2_data_n_out    => noc2_data_n_out,
      noc2_data_s_out    => noc2_data_s_out,
      noc2_data_w_out    => noc2_data_w_out,
      noc2_data_e_out    => noc2_data_e_out,
      noc2_data_void_out => noc2_data_void_out,
      noc2_stop_out      => noc2_stop_out,
      noc3_data_n_in     => noc3_data_n_in,
      noc3_data_s_in     => noc3_data_s_in,
      noc3_data_w_in     => noc3_data_w_in,
      noc3_data_e_in     => noc3_data_e_in,
      noc3_data_void_in  => noc3_data_void_in,
      noc3_stop_in       => noc3_stop_in,
      noc3_data_n_out    => noc3_data_n_out,
      noc3_data_s_out    => noc3_data_s_out,
      noc3_data_w_out    => noc3_data_w_out,
      noc3_data_e_out    => noc3_data_e_out,
      noc3_data_void_out => noc3_data_void_out,
      noc3_stop_out      => noc3_stop_out,
      noc4_data_n_in     => noc4_data_n_in,
      noc4_data_s_in     => noc4_data_s_in,
      noc4_data_w_in     => noc4_data_w_in,
      noc4_data_e_in     => noc4_data_e_in,
      noc4_data_void_in  => noc4_data_void_in,
      noc4_stop_in       => noc4_stop_in,
      noc4_data_n_out    => noc4_data_n_out,
      noc4_data_s_out    => noc4_data_s_out,
      noc4_data_w_out    => noc4_data_w_out,
      noc4_data_e_out    => noc4_data_e_out,
      noc4_data_void_out => noc4_data_void_out,
      noc4_stop_out      => noc4_stop_out,
      noc5_data_n_in     => noc5_data_n_in,
      noc5_data_s_in     => noc5_data_s_in,
      noc5_data_w_in     => noc5_data_w_in,
      noc5_data_e_in     => noc5_data_e_in,
      noc5_data_void_in  => noc5_data_void_in,
      noc5_stop_in       => noc5_stop_in,
      noc5_data_n_out    => noc5_data_n_out,
      noc5_data_s_out    => noc5_data_s_out,
      noc5_data_w_out    => noc5_data_w_out,
      noc5_data_e_out    => noc5_data_e_out,
      noc5_data_void_out => noc5_data_void_out,
      noc5_stop_out      => noc5_stop_out,
      noc6_data_n_in     => noc6_data_n_in,
      noc6_data_s_in     => noc6_data_s_in,
      noc6_data_w_in     => noc6_data_w_in,
      noc6_data_e_in     => noc6_data_e_in,
      noc6_data_void_in  => noc6_data_void_in,
      noc6_stop_in       => noc6_stop_in,
      noc6_data_n_out    => noc6_data_n_out,
      noc6_data_s_out    => noc6_data_s_out,
      noc6_data_w_out    => noc6_data_w_out,
      noc6_data_e_out    => noc6_data_e_out,
      noc6_data_void_out => noc6_data_void_out,
      noc6_stop_out      => noc6_stop_out,
      noc1_mon_noc_vec   => open,
      noc2_mon_noc_vec   => open,
      noc3_mon_noc_vec   => open,
      noc4_mon_noc_vec   => open,
      noc5_mon_noc_vec   => open,
      noc6_mon_noc_vec   => open,
      mon_dvfs           => open);

end;
