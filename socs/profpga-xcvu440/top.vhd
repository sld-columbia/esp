-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
--  ESP - profpga - TA1 - xcvu440
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
use work.svga_pkg.all;
library unisim;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on
use unisim.VCOMPONENTS.all;
use work.monitor_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity top is
  generic (
    SIMULATION : boolean := false
    );
  port (
    -- MMI64 interface:
    profpga_clk0_p    : in    std_ulogic;  -- 100 MHz clock
    profpga_clk0_n    : in    std_ulogic;  -- 100 MHz clock
    profpga_sync0_p   : in    std_ulogic;
    profpga_sync0_n   : in    std_ulogic;
    dmbi_h2f          : in    std_logic_vector(19 downto 0);
    dmbi_f2h          : out   std_logic_vector(19 downto 0);
    -- Main ESP clock
    esp_clk_p         : in    std_ulogic;  -- 78.25 MHz clock
    esp_clk_n         : in    std_ulogic;  -- 78.25 MHz clock
    -- DDR4
    reset             : in    std_ulogic;
    
    c0_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c0_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c0_ddr4_act_n     : out   std_logic;
    c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n   : out   std_logic;
    c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c0_calib_complete : out   std_logic;
    c0_diagnostic_led : out   std_ulogic;
    
    c1_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c1_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c1_ddr4_act_n     : out   std_logic;
    c1_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c1_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c1_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c1_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c1_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c1_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c1_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c1_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c1_ddr4_reset_n   : out   std_logic;
    c1_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c1_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c1_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c1_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c1_calib_complete : out   std_logic;
    c1_diagnostic_led : out   std_ulogic;
    
    c2_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c2_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c2_ddr4_act_n     : out   std_logic;
    c2_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c2_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c2_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c2_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c2_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c2_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c2_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c2_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c2_ddr4_reset_n   : out   std_logic;
    c2_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c2_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c2_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c2_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c2_calib_complete : out   std_logic;
    c2_diagnostic_led : out   std_ulogic;
    
    c3_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c3_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c3_ddr4_act_n     : out   std_logic;
    c3_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c3_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c3_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c3_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c3_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c3_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c3_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c3_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c3_ddr4_reset_n   : out   std_logic;
    c3_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c3_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c3_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c3_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c3_calib_complete : out   std_logic;
    c3_diagnostic_led : out   std_ulogic;
    -- UART
    uart_rxd          : in    std_ulogic;
    uart_txd          : out   std_ulogic;
    uart_ctsn         : in    std_ulogic;
    uart_rtsn         : out   std_ulogic;
    -- Ethernet signals
    reset_o2          : out   std_ulogic;
    etx_clk           : in    std_ulogic;
    erx_clk           : in    std_ulogic;
    erxd              : in    std_logic_vector(3 downto 0);
    erx_dv            : in    std_ulogic;
    erx_er            : in    std_ulogic;
    erx_col           : in    std_ulogic;
    erx_crs           : in    std_ulogic;
    etxd              : out   std_logic_vector(3 downto 0);
    etx_en            : out   std_ulogic;
    etx_er            : out   std_ulogic;
    emdc              : out   std_ulogic;
    emdio             : inout std_logic;
    -- DVI
    tft_nhpd          : in    std_ulogic;  -- Hot plug
    tft_clk_p         : out   std_ulogic;
    tft_clk_n         : out   std_ulogic;
    tft_data          : out   std_logic_vector(23 downto 0);
    tft_hsync         : out   std_ulogic;
    tft_vsync         : out   std_ulogic;
    tft_de            : out   std_ulogic;
    tft_dken          : out   std_ulogic;
    tft_ctl1_a1_dk1   : out   std_ulogic;
    tft_ctl2_a2_dk2   : out   std_ulogic;
    tft_a3_dk3        : out   std_ulogic;
    tft_isel          : out   std_ulogic;
    tft_bsel          : out   std_logic;
    tft_dsel          : out   std_logic;
    tft_edge          : out   std_ulogic;
    tft_npd           : out   std_ulogic;

    LED_RED    : out std_ulogic;
    LED_GREEN  : out std_ulogic;
    LED_BLUE   : out std_ulogic;
    LED_YELLOW : out std_ulogic
    );
end;


architecture rtl of top is

  component ahb2mig_ebddr4r5 is
    generic (
      hindex : integer;
      haddr  : integer;
      hmask  : integer
      );
    port (
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
      ahbso            : out   ahb_slv_out_type;
      ahbsi            : in    ahb_slv_in_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      clk_amba         : in    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_sync_rst  : out   std_logic);
  end component ahb2mig_ebddr4r5;

  function set_ddr_index (
    constant n : integer range 0 to 3)
    return integer is
  begin
    if n > (MEM_ID_RANGE_MSB) then
      return MEM_ID_RANGE_MSB;
    else
      return n;
    end if;
  end set_ddr_index;

  constant this_ddr_index : attribute_vector(0 to 3) := (
    0 => set_ddr_index(0),
    1 => set_ddr_index(1),
    2 => set_ddr_index(2),
    3 => set_ddr_index(3)
    );

-- Switches
  signal sel0, sel1, sel2, sel3, sel4 : std_ulogic;

-- clock and reset
  signal clkm, clkm_1, clkm_2, clkm_3                   : std_ulogic := '0';
  signal clkm_sync_rst, clkm_sync_rst_1                 : std_ulogic;
  signal clkm_sync_rst_2, clkm_sync_rst_3               : std_ulogic;
  signal rstn, rstraw, rstraw_1, rstraw_2, rstraw_3     : std_ulogic;
  signal lock, rst                                      : std_ulogic;
  signal migrstn, migrstn_1, migrstn_2, migrstn_3       : std_logic;
  signal cgi                                            : clkgen_in_type;
  signal cgo                                            : clkgen_out_type;

---mig signals
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c0_diagnostic_toggle : std_ulogic;
  signal c1_calib_done        : std_ulogic;
  signal c1_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c1_diagnostic_toggle : std_ulogic;
  signal c2_calib_done        : std_ulogic;
  signal c2_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c2_diagnostic_toggle : std_ulogic;
  signal c3_calib_done        : std_ulogic;
  signal c3_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c3_diagnostic_toggle : std_ulogic;

-- Ethernet signals
  signal ethi : eth_in_type;
  signal etho : eth_out_type;

-- Tiles

-- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

constant MAX_NMEM_TILES : integer := 4;
-- Memory controller DDR4
  signal ddr_ahbsi : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

-- Ethernet
constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz

  signal eth0_apbi   : apb_slv_in_type;
  signal eth0_apbo   : apb_slv_out_type;
  signal sgmii0_apbi : apb_slv_in_type;

  signal sgmii0_apbo : apb_slv_out_type;
  signal eth0_ahbmi  : ahb_mst_in_type;
  signal eth0_ahbmo  : ahb_mst_out_type;
  signal edcl_ahbmo  : ahb_mst_out_type;

-- DVI

  component svga2tfp410
    generic (
      tech : integer);
    port (
      clk         : in  std_ulogic;
      rstn        : in  std_ulogic;
      vgaclk_fb   : in  std_ulogic;
      vgao        : in  apbvga_out_type;
      vgaclk      : out std_ulogic;
      idck_p      : out std_ulogic;
      idck_n      : out std_ulogic;
      data        : out std_logic_vector(23 downto 0);
      hsync       : out std_ulogic;
      vsync       : out std_ulogic;
      de          : out std_ulogic;
      dken        : out std_ulogic;
      ctl1_a1_dk1 : out std_ulogic;
      ctl2_a2_dk2 : out std_ulogic;
      a3_dk3      : out std_ulogic;
      isel        : out std_ulogic;
      bsel        : out std_ulogic;
      dsel        : out std_ulogic;
      edge        : out std_ulogic;
      npd         : out std_ulogic);
  end component;

  signal dvi_apbi  : apb_slv_in_type;
  signal dvi_apbo  : apb_slv_out_type;
  signal dvi_ahbmi : ahb_mst_in_type;
  signal dvi_ahbmo : ahb_mst_out_type;

  signal dvi_nhpd        : std_ulogic;
  signal dvi_data        : std_logic_vector(23 downto 0);
  signal dvi_hsync       : std_ulogic;
  signal dvi_vsync       : std_ulogic;
  signal dvi_de          : std_ulogic;
  signal dvi_dken        : std_ulogic;
  signal dvi_ctl1_a1_dk1 : std_ulogic;
  signal dvi_ctl2_a2_dk2 : std_ulogic;
  signal dvi_a3_dk3      : std_ulogic;
  signal dvi_isel        : std_ulogic;
  signal dvi_bsel        : std_ulogic;
  signal dvi_dsel        : std_ulogic;
  signal dvi_edge        : std_ulogic;
  signal dvi_npd         : std_ulogic;

  signal vgao                       : apbvga_out_type;
  signal clkvga, clkvga_p, clkvga_n : std_ulogic;

  attribute syn_keep               : boolean;
  attribute syn_preserve           : boolean;
  attribute syn_keep of clkvga     : signal is true;
  attribute syn_preserve of clkvga : signal is true;
  attribute keep                   : boolean;
  attribute keep of clkvga         : signal is true;

-- CPU flags
  signal cpuerr : std_ulogic;

-- NOC
  signal chip_rst       : std_ulogic;
  signal sys_clk        : std_logic_vector(0 to MAX_NMEM_TILES - 1);
  signal esp_clk        : std_ulogic;
  signal chip_refclk    : std_ulogic;
  signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal chip_pllclk    : std_ulogic;


  attribute keep of clkm        : signal is true;
  attribute keep of clkm_1      : signal is true;
  attribute keep of clkm_2      : signal is true;
  attribute keep of clkm_3      : signal is true;
  attribute keep of chip_refclk : signal is true;

-- MMI64
  signal user_rstn      : std_ulogic;
  signal mon_ddr        : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);
  signal mon_ddr_reg    : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);
  signal mon_noc        : monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
  signal mon_noc_actual : monitor_noc_matrix(0 to 1, 0 to CFG_TILES_NUM-1);
  signal mon_mem        : monitor_mem_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
  signal mon_mem_reg    : monitor_mem_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
  signal mon_l2         : monitor_cache_vector(0 to relu(CFG_NL2 - 1));
  signal mon_llc        : monitor_cache_vector(0 to relu(CFG_NLLC - 1));
  signal mon_acc        : monitor_acc_vector(0 to relu(accelerators_num-1));
  signal mon_dvfs       : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);

begin

  c0_diagnostic : process (clkm, clkm_sync_rst)
  begin  -- process c0_diagnostic
    if clkm_sync_rst = '1' then           -- asynchronous reset (active high)
      c0_diagnostic_count <= (others => '0');
    elsif clkm'event and clkm = '1' then  -- rising clock edge
      c0_diagnostic_count <= c0_diagnostic_count + 1;
    end if;
  end process c0_diagnostic;
  c0_diagnostic_toggle <= c0_diagnostic_count(26);
  c0_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);
  
  c1_diagnostic : process (clkm_1, clkm_sync_rst_1)
  begin  -- process c1_diagnostic
    if clkm_sync_rst_1 = '1' then           -- asynchronous reset (active high)
      c1_diagnostic_count <= (others => '0');
    elsif clkm_1'event and clkm_1 = '1' then  -- rising clock edge
      c1_diagnostic_count <= c1_diagnostic_count + 1;
    end if;
  end process c1_diagnostic;
  c1_diagnostic_toggle <= c1_diagnostic_count(26);
  c1_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_diagnostic_led, c1_diagnostic_toggle);

  c2_diagnostic : process (clkm_2, clkm_sync_rst_2)
  begin  -- process c2_diagnostic
    if clkm_sync_rst_2 = '1' then           -- asynchronous reset (active high)
      c2_diagnostic_count <= (others => '0');
    elsif clkm_2'event and clkm_2 = '1' then  -- rising clock edge
      c2_diagnostic_count <= c2_diagnostic_count + 1;
    end if;
  end process c2_diagnostic;
  c2_diagnostic_toggle <= c2_diagnostic_count(26);
  c2_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_diagnostic_led, c2_diagnostic_toggle);

  c3_diagnostic : process (clkm_3, clkm_sync_rst_3)
  begin  -- process c3_diagnostic
    if clkm_sync_rst_3 = '1' then           -- asynchronous reset (active high)
      c3_diagnostic_count <= (others => '0');
    elsif clkm_3'event and clkm_3 = '1' then  -- rising clock edge
      c3_diagnostic_count <= c3_diagnostic_count + 1;
    end if;
  end process c3_diagnostic;
  c3_diagnostic_toggle <= c3_diagnostic_count(26);
  c3_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_diagnostic_led, c3_diagnostic_toggle);


-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------

  -- From memory controllers' PLLs
  lock_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_GREEN, lock);

  -- From CPU 0 (on chip)
  cpuerr_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_RED, cpuerr);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);
  calib1_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_calib_complete, c1_calib_done);
  calib2_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_calib_complete, c2_calib_done);
  calib3_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_calib_complete, c3_calib_done);


  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_BLUE, '0');

  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_YELLOW, '0');

-------------------------------------------------------------------------------
-- Switches -------------------------------------------------------------------
-------------------------------------------------------------------------------

  --sw0_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(0), '0', '1', sel0);
  --sw1_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(1), '0', '1', sel1);
  --sw2_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(2), '0', '1', sel2);
  --sw3_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(3), '0', '1', sel3);
  --sw4_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(4), '0', '1', sel4);
  sel0 <= '1';
  sel1 <= '0';
  sel2 <= '0';
  sel3 <= '0';
  sel4 <= '0';

-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  cgi.pllctrl <= "00";
  cgi.pllrst  <= rstraw;

  lock <= c0_calib_done and c1_calib_done and c2_calib_done and c3_calib_done and cgo.clklock;

  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);
  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, rstn, open);

  mig_rst0 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm, lock, migrstn, rstraw);
  mig_rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_1, lock, migrstn_1, rstraw_1);
  mig_rst2 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_2, lock, migrstn_2, rstraw_2);
  mig_rst3 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_3, lock, migrstn_3, rstraw_3);

  esp_clk_buf : ibufgds
    generic map(
      IBUF_LOW_PWR => FALSE
      )
    port map (
      I  => esp_clk_p,
      IB => esp_clk_n,
      O  => esp_clk
      );

  esp_clkgen : clkgen
    generic map (CFG_FABTECH, 8, 8, 0, 0, 0, 0, 0, CPU_FREQ)
    port map (esp_clk, esp_clk, chip_refclk, open, open, open, open, cgi, cgo, open, open, open);

-----------------------------------------------------------------------------
-- UART pads
-----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int);

----------------------------------------------------------------------
---  DDR4 memory controller ------------------------------------------
----------------------------------------------------------------------

  gen_mig : if (SIMULATION /= true) generate
    ddrc0 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)))
      port map (
        c0_sys_clk_p     => c0_sys_clk_p,
        c0_sys_clk_n     => c0_sys_clk_n,
        c0_ddr4_act_n    => c0_ddr4_act_n,
        c0_ddr4_adr      => c0_ddr4_adr,
        c0_ddr4_ba       => c0_ddr4_ba,
        c0_ddr4_bg       => c0_ddr4_bg,
        c0_ddr4_cke      => c0_ddr4_cke,
        c0_ddr4_odt      => c0_ddr4_odt,
        c0_ddr4_cs_n     => c0_ddr4_cs_n,
        c0_ddr4_ck_t     => c0_ddr4_ck_t,
        c0_ddr4_ck_c     => c0_ddr4_ck_c,
        c0_ddr4_reset_n  => c0_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c0_ddr4_dq,
        c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
        ahbso            => ddr_ahbso(0),
        ahbsi            => ddr_ahbsi(0),
        calib_done       => c0_calib_done,
        rst_n_syn        => migrstn,
        rst_n_async      => rstraw,
        clk_amba         => clkm,
        ui_clk           => clkm,
        ui_clk_sync_rst  => clkm_sync_rst
        );
    
    ddrc1 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(1)),
        hmask  => ddr_hmask(this_ddr_index(1)))
      port map (
        c0_sys_clk_p     => c1_sys_clk_p,
        c0_sys_clk_n     => c1_sys_clk_n,
        c0_ddr4_act_n    => c1_ddr4_act_n,
        c0_ddr4_adr      => c1_ddr4_adr,
        c0_ddr4_ba       => c1_ddr4_ba,
        c0_ddr4_bg       => c1_ddr4_bg,
        c0_ddr4_cke      => c1_ddr4_cke,
        c0_ddr4_odt      => c1_ddr4_odt,
        c0_ddr4_cs_n     => c1_ddr4_cs_n,
        c0_ddr4_ck_t     => c1_ddr4_ck_t,
        c0_ddr4_ck_c     => c1_ddr4_ck_c,
        c0_ddr4_reset_n  => c1_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c1_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c1_ddr4_dq,
        c0_ddr4_dqs_c    => c1_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c1_ddr4_dqs_t,
        ahbso            => ddr_ahbso(1),
        ahbsi            => ddr_ahbsi(1),
        calib_done       => c1_calib_done,
        rst_n_syn        => migrstn_1,
        rst_n_async      => rstraw_1,
        clk_amba         => clkm_1,
        ui_clk           => clkm_1,
        ui_clk_sync_rst  => clkm_sync_rst_1
        );
    
    ddrc2 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(2)),
        hmask  => ddr_hmask(this_ddr_index(2)))
      port map (
        c0_sys_clk_p     => c2_sys_clk_p,
        c0_sys_clk_n     => c2_sys_clk_n,
        c0_ddr4_act_n    => c2_ddr4_act_n,
        c0_ddr4_adr      => c2_ddr4_adr,
        c0_ddr4_ba       => c2_ddr4_ba,
        c0_ddr4_bg       => c2_ddr4_bg,
        c0_ddr4_cke      => c2_ddr4_cke,
        c0_ddr4_odt      => c2_ddr4_odt,
        c0_ddr4_cs_n     => c2_ddr4_cs_n,
        c0_ddr4_ck_t     => c2_ddr4_ck_t,
        c0_ddr4_ck_c     => c2_ddr4_ck_c,
        c0_ddr4_reset_n  => c2_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c2_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c2_ddr4_dq,
        c0_ddr4_dqs_c    => c2_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c2_ddr4_dqs_t,
        ahbso            => ddr_ahbso(2),
        ahbsi            => ddr_ahbsi(2),
        calib_done       => c2_calib_done,
        rst_n_syn        => migrstn_2,
        rst_n_async      => rstraw_2,
        clk_amba         => clkm_2,
        ui_clk           => clkm_2,
        ui_clk_sync_rst  => clkm_sync_rst_2
        );
    
    ddrc3 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(3)),
        hmask  => ddr_hmask(this_ddr_index(3)))
      port map (
        c0_sys_clk_p     => c3_sys_clk_p,
        c0_sys_clk_n     => c3_sys_clk_n,
        c0_ddr4_act_n    => c3_ddr4_act_n,
        c0_ddr4_adr      => c3_ddr4_adr,
        c0_ddr4_ba       => c3_ddr4_ba,
        c0_ddr4_bg       => c3_ddr4_bg,
        c0_ddr4_cke      => c3_ddr4_cke,
        c0_ddr4_odt      => c3_ddr4_odt,
        c0_ddr4_cs_n     => c3_ddr4_cs_n,
        c0_ddr4_ck_t     => c3_ddr4_ck_t,
        c0_ddr4_ck_c     => c3_ddr4_ck_c,
        c0_ddr4_reset_n  => c3_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c3_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c3_ddr4_dq,
        c0_ddr4_dqs_c    => c3_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c3_ddr4_dqs_t,
        ahbso            => ddr_ahbso(3),
        ahbsi            => ddr_ahbsi(3),
        calib_done       => c3_calib_done,
        rst_n_syn        => migrstn_3,
        rst_n_async      => rstraw_3,
        clk_amba         => clkm_3,
        ui_clk           => clkm_3,
        ui_clk_sync_rst  => clkm_sync_rst_3
        );
  
     end generate gen_mig;

  gen_mig_model : if (SIMULATION = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 1000,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => clkm,
        haddr => ddr_haddr(this_ddr_index(0)),
        hmask => ddr_hmask(this_ddr_index(0)),
        ahbsi => ddr_ahbsi(0),
        ahbso => ddr_ahbso(0)
        );
    
    mig_ahbram1 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 1000,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => clkm,
        haddr => ddr_haddr(this_ddr_index(1)),
        hmask => ddr_hmask(this_ddr_index(1)),
        ahbsi => ddr_ahbsi(1),
        ahbso => ddr_ahbso(1)
        );
      
    mig_ahbram2 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 1000,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => clkm,
        haddr => ddr_haddr(this_ddr_index(2)),
        hmask => ddr_hmask(this_ddr_index(2)),
        ahbsi => ddr_ahbsi(2),
        ahbso => ddr_ahbso(2)
        );
    
    mig_ahbram3 : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 1000,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => clkm,
        haddr => ddr_haddr(this_ddr_index(3)),
        hmask => ddr_hmask(this_ddr_index(3)),
        ahbsi => ddr_ahbsi(3),
        ahbso => ddr_ahbso(3)
        );

    c0_ddr4_act_n    <= '1';
    c0_ddr4_adr      <= (others => '0');
    c0_ddr4_ba       <= (others => '0');
    c0_ddr4_bg       <= (others => '0');
    c0_ddr4_cke      <= (others => '0');
    c0_ddr4_odt      <= (others => '0');
    c0_ddr4_cs_n     <= (others => '0');
    c0_ddr4_ck_t     <= (others => '0');
    c0_ddr4_ck_c     <= (others => '0');
    c0_ddr4_reset_n  <= '1';
    c0_ddr4_dm_dbi_n <= (others => 'Z');
    c0_ddr4_dq       <= (others => 'Z');
    c0_ddr4_dqs_c    <= (others => 'Z');
    c0_ddr4_dqs_t    <= (others => 'Z');
    c0_calib_done <= '1';
    clkm          <= not clkm        after 3.2 ns;
    
    c1_ddr4_act_n    <= '1';
    c1_ddr4_adr      <= (others => '0');
    c1_ddr4_ba       <= (others => '0');
    c1_ddr4_bg       <= (others => '0');
    c1_ddr4_cke      <= (others => '0');
    c1_ddr4_odt      <= (others => '0');
    c1_ddr4_cs_n     <= (others => '0');
    c1_ddr4_ck_t     <= (others => '0');
    c1_ddr4_ck_c     <= (others => '0');
    c1_ddr4_reset_n  <= '1';
    c1_ddr4_dm_dbi_n <= (others => 'Z');
    c1_ddr4_dq       <= (others => 'Z');
    c1_ddr4_dqs_c    <= (others => 'Z');
    c1_ddr4_dqs_t    <= (others => 'Z');
    c1_calib_done <= '1';
    clkm_1          <= not clkm_1        after 3.2 ns;
    
    c2_ddr4_act_n    <= '1';
    c2_ddr4_adr      <= (others => '0');
    c2_ddr4_ba       <= (others => '0');
    c2_ddr4_bg       <= (others => '0');
    c2_ddr4_cke      <= (others => '0');
    c2_ddr4_odt      <= (others => '0');
    c2_ddr4_cs_n     <= (others => '0');
    c2_ddr4_ck_t     <= (others => '0');
    c2_ddr4_ck_c     <= (others => '0');
    c2_ddr4_reset_n  <= '1';
    c2_ddr4_dm_dbi_n <= (others => 'Z');
    c2_ddr4_dq       <= (others => 'Z');
    c2_ddr4_dqs_c    <= (others => 'Z');
    c2_ddr4_dqs_t    <= (others => 'Z');
    c2_calib_done <= '1';
    clkm_2          <= not clkm_2        after 3.2 ns;
    
    c3_ddr4_act_n    <= '1';
    c3_ddr4_adr      <= (others => '0');
    c3_ddr4_ba       <= (others => '0');
    c3_ddr4_bg       <= (others => '0');
    c3_ddr4_cke      <= (others => '0');
    c3_ddr4_odt      <= (others => '0');
    c3_ddr4_cs_n     <= (others => '0');
    c3_ddr4_ck_t     <= (others => '0');
    c3_ddr4_ck_c     <= (others => '0');
    c3_ddr4_reset_n  <= '1';
    c3_ddr4_dm_dbi_n <= (others => 'Z');
    c3_ddr4_dq       <= (others => 'Z');
    c3_ddr4_dqs_c    <= (others => 'Z');
    c3_ddr4_dqs_t    <= (others => 'Z');
    c3_calib_done <= '1';
    clkm_3          <= not clkm_3        after 3.2 ns;

  -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  reset_o2 <= rstn;
  eth0 : if SIMULATION = false and CFG_GRETH = 1 generate  -- Gaisler ethernet MAC
    e1 : grethm
      generic map(
        hindex      => CFG_AHB_JTAG,
        ehindex     => CFG_AHB_JTAG + 1,
        pindex      => 14,
        paddr       => 16#800#,
        pmask       => 16#f00#,
        pirq        => 12,
        little_end  => GLOB_CPU_RISCV * CFG_L2_DISABLE,
        memtech     => CFG_FABTECH,
        enable_mdio => 1,
        fifosize    => CFG_ETH_FIFO,
        nsync       => 1,
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
        rst    => rstn,
        clk    => chip_refclk,
        mdcscaler => CPU_FREQ/1000,
        ahbmi  => eth0_ahbmi,
        ahbmo  => eth0_ahbmo,
        eahbmo => edcl_ahbmo,
        apbi   => eth0_apbi,
        apbo   => eth0_apbo,
        ethi   => ethi,
        etho   => etho);
  end generate;

  ethi.edclsepahb <= '1';

  -- eth pads
  eth0_inpads : if (CFG_GRETH = 1) generate
    etxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
      port map (erx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
      port map (erxd, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_crs, ethi.rx_crs);
  end generate eth0_inpads;

  emdio_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  etxd_pad : outpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
    port map (etxd, etho.txd(3 downto 0));
  etxen_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (etx_en, etho.tx_en);
  etxer_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (etx_er, etho.tx_er);
  emdc_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (emdc, etho.mdc);

  no_eth0 : if SIMULATION = true or CFG_GRETH = 0 generate
    eth0_apbo    <= apb_none;
    eth0_ahbmo   <= ahbm_none;
    edcl_ahbmo   <= ahbm_none;
    etho.mdio_o  <= '0';
    etho.mdio_oe <= '0';
    etho.txd     <= (others => '0');
    etho.tx_en   <= '0';
    etho.tx_er   <= '0';
    etho.mdc     <= '0';
  end generate no_eth0;

  sgmii0_apbo <= apb_none;

  -----------------------------------------------------------------------------
  -- DVI
  -----------------------------------------------------------------------------

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(
      memtech  => CFG_FABTECH,
      pindex   => 13,
      paddr    => 6,
      hindex   => 0,
      clk0     => 25000,
      clk1     => 25000,
      clk2     => 25000,
      clk3     => 25000,
      burstlen => 6,
      ahbaccsz => CFG_AHBDW)
      port map(
        rst     => rstn,
        clk     => chip_refclk,
        vgaclk  => clkvga,
        apbi    => dvi_apbi,
        apbo    => dvi_apbo,
        vgao    => vgao,
        ahbi    => dvi_ahbmi,
        ahbo    => dvi_ahbmo,
        clk_sel => open);

    dvi0 : svga2tfp410
      generic map (
        tech => CFG_FABTECH)
      port map (
        clk         => chip_refclk,
        rstn        => rstraw,
        vgao        => vgao,
        vgaclk_fb   => clkvga,
        vgaclk      => clkvga,
        idck_p      => clkvga_p,
        idck_n      => clkvga_n,
        data        => dvi_data,
        hsync       => dvi_hsync,
        vsync       => dvi_vsync,
        de          => dvi_de,
        dken        => dvi_dken,
        ctl1_a1_dk1 => dvi_ctl1_a1_dk1,
        ctl2_a2_dk2 => dvi_ctl2_a2_dk2,
        a3_dk3      => dvi_a3_dk3,
        isel        => dvi_isel,
        bsel        => dvi_bsel,
        dsel        => dvi_dsel,
        edge        => dvi_edge,
        npd         => dvi_npd);

  end generate;

  novga : if CFG_SVGA_ENABLE = 0 generate
    dvi_apbo        <= apb_none;
    dvi_ahbmo       <= ahbm_none;
    dvi_data        <= (others => '0');
    clkvga_p        <= '0';
    clkvga_n        <= '0';
    dvi_hsync       <= '0';
    dvi_vsync       <= '0';
    dvi_de          <= '0';
    dvi_dken        <= '0';
    dvi_ctl1_a1_dk1 <= '0';
    dvi_ctl2_a2_dk2 <= '0';
    dvi_a3_dk3      <= '0';
    dvi_isel        <= '0';
    dvi_bsel        <= '0';
    dvi_dsel        <= '0';
    dvi_edge        <= '0';
    dvi_npd         <= '0';
  end generate;

  tft_nhpd_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_nhpd, dvi_nhpd);

  tft_clkp_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_clk_p, clkvga_p);
  tft_clkn_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_clk_n, clkvga_n);

  tft_data_pad : outpadv generic map (width => 24, tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_data, dvi_data);
  tft_hsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_hsync, dvi_hsync);
  tft_vsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_vsync, dvi_vsync);
  tft_de_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_de, dvi_de);

  tft_dken_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_dken, dvi_dken);
  tft_ctl1_a1_dk1_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_ctl1_a1_dk1, dvi_ctl1_a1_dk1);
  tft_ctl2_a2_dk2_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_ctl2_a2_dk2, dvi_ctl2_a2_dk2);
  tft_a3_dk3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_a3_dk3, dvi_a3_dk3);

  tft_isel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_isel, dvi_isel);
  tft_bsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_bsel, dvi_bsel);
  tft_dsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_dsel, dvi_dsel);
  tft_edge_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_edge, dvi_edge);
  tft_npd_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_npd, dvi_npd);

  -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_rst       <= rstn;
  sys_clk(0)     <= clkm;
  sys_clk(1)     <= clkm_1;
  sys_clk(2)     <= clkm_2;
  sys_clk(3)     <= clkm_3; 
  chip_pllbypass <= (others => '0');

  set_upper_ahbsi : for i in CFG_NMEM_TILE to MAX_NMEM_TILES-1 generate
        ddr_ahbsi(i) <= ahbs_in_none; 
  end generate set_upper_ahbsi; 

  esp_1 : esp
    generic map (
      SIMULATION => SIMULATION)
    port map (
      rst         => chip_rst,
      sys_clk     => sys_clk(0 to MEM_ID_RANGE_MSB),
      refclk      => chip_refclk,
      pllbypass   => chip_pllbypass,
      uart_rxd    => uart_rxd_int,
      uart_txd    => uart_txd_int,
      uart_ctsn   => uart_ctsn_int,
      uart_rtsn   => uart_rtsn_int,
      cpuerr      => cpuerr,
      ddr_ahbsi   => ddr_ahbsi(0 to MEM_ID_RANGE_MSB),
      ddr_ahbso   => ddr_ahbso(0 to MEM_ID_RANGE_MSB),
      eth0_apbi   => eth0_apbi,
      eth0_apbo   => eth0_apbo,
      edcl_ahbmo  => edcl_ahbmo,
      sgmii0_apbi => sgmii0_apbi,
      sgmii0_apbo => sgmii0_apbo,
      eth0_ahbmi  => eth0_ahbmi,
      eth0_ahbmo  => eth0_ahbmo,
      dvi_apbi    => dvi_apbi,
      dvi_apbo    => dvi_apbo,
      dvi_ahbmi   => dvi_ahbmi,
      dvi_ahbmo   => dvi_ahbmo,
      -- Monitor signals
      mon_noc     => mon_noc,
      mon_acc     => mon_acc,
      mon_mem     => mon_mem,
      mon_l2      => mon_l2,
      mon_llc     => mon_llc,
      mon_dvfs    => mon_dvfs
      );


  profpga_mmi64_gen : if CFG_MON_DDR_EN + CFG_MON_NOC_INJECT_EN + CFG_MON_NOC_QUEUES_EN + CFG_MON_ACC_EN + CFG_MON_DVFS_EN /= 0 generate
    -- MMI64
    user_rstn <= rstn;
    
    gen_mon_ddr : for i in 0 to MEM_ID_RANGE_MSB generate
        mon_ddr(i).clk <= sys_clk(i);
        detect_ddr_access : process (ddr_ahbsi)
        begin  -- process detect_mem_access
          mon_ddr(i).word_transfer <= '0';

          if ((ddr_ahbsi(i).haddr(31 downto 20) xor conv_std_logic_vector(ddr_haddr(i), 12))
              and conv_std_logic_vector(ddr_hmask(i), 12)) = zero32(31 downto 20) then
            if ddr_ahbsi(i).hready = '1' and ddr_ahbsi(i).htrans /= HTRANS_IDLE then
              mon_ddr(i).word_transfer <= '1';
            end if;
          end if;
        end process detect_ddr_access;
    end generate gen_mon_ddr;
    
    gen_mon_regs : for i in 0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1 generate
        mon_mem_reg(i).clk <= mon_mem(i).clk;
        mon_mem_reg_gen : process(mon_mem(i).clk, rstn) 
        begin 
            if rstn = '0' then 
                mon_mem_reg(i).coherent_req <= '0';
                mon_mem_reg(i).coherent_fwd <= '0';
                mon_mem_reg(i).coherent_rsp_rcv <= '0';
                mon_mem_reg(i).coherent_rsp_snd <= '0';
                mon_mem_reg(i).dma_req <= '0';
                mon_mem_reg(i).dma_rsp <= '0';
                mon_mem_reg(i).coherent_dma_req <= '0';
                mon_mem_reg(i).coherent_dma_rsp <= '0';
            elsif mon_mem(i).clk'event and mon_mem(i).clk = '1' then 
                mon_mem_reg(i).coherent_req <= mon_mem(i).coherent_req;
                mon_mem_reg(i).coherent_fwd <= mon_mem(i).coherent_fwd;
                mon_mem_reg(i).coherent_rsp_rcv <= mon_mem(i).coherent_rsp_rcv;
                mon_mem_reg(i).coherent_rsp_snd <= mon_mem(i).coherent_rsp_snd;
                mon_mem_reg(i).dma_req <= mon_mem(i).dma_req;
                mon_mem_reg(i).dma_rsp <= mon_mem(i).dma_rsp;
                mon_mem_reg(i).coherent_dma_req <= mon_mem(i).coherent_dma_req;
                mon_mem_reg(i).coherent_dma_rsp <= mon_mem(i).coherent_dma_rsp;
            end if;
        end process mon_mem_reg_gen;
   
        mon_ddr_reg(i).clk <= mon_ddr(i).clk;
        mon_ddr_reg_gen : process(mon_ddr(i).clk, rstn)
        begin 
            if rstn = '0' then 
                mon_ddr_reg(i).word_transfer <= '0';
            elsif mon_ddr(i).clk'event and mon_ddr(i).clk = '1' then 
                mon_ddr_reg(i).word_transfer <= mon_ddr(i).word_transfer;
            end if;
        end process mon_ddr_reg_gen;
        
    end generate gen_mon_regs; 
    
    mon_noc_map_gen : for i in 0 to CFG_TILES_NUM-1 generate
      --mon_noc_actual(0,i) <= mon_noc(1,i);
      --mon_noc_actual(1,i) <= mon_noc(3,i);
      mon_noc_actual(0, i) <= mon_noc(4, i);
      --mon_noc_actual(3,i) <= mon_noc(5,i);
      mon_noc_actual(1, i) <= mon_noc(6, i);
    end generate mon_noc_map_gen;

    monitor_1 : monitor
      generic map (
        memtech                => CFG_FABTECH,
        mmi64_width            => 32,
        ddrs_num               => CFG_NMEM_TILE,
        slms_num               => CFG_NSLM_TILE + CFG_NSLMDDR_TILE,
        nocs_num               => 2,
        tiles_num              => CFG_TILES_NUM,
        accelerators_num       => accelerators_num,
        l2_num                 => CFG_NL2,
        llc_num                => CFG_NLLC,
        mon_ddr_en             => CFG_MON_DDR_EN,
        mon_mem_en             => CFG_MON_MEM_EN,
        mon_noc_tile_inject_en => CFG_MON_NOC_INJECT_EN,
        mon_noc_queues_full_en => CFG_MON_NOC_QUEUES_EN,
        mon_acc_en             => CFG_MON_ACC_EN,
        mon_l2_en              => CFG_MON_L2_EN,
        mon_llc_en             => CFG_MON_LLC_EN,
        mon_dvfs_en            => CFG_MON_DVFS_EN)
      port map (
        profpga_clk0_p  => profpga_clk0_p,
        profpga_clk0_n  => profpga_clk0_n,
        profpga_sync0_p => profpga_sync0_p,
        profpga_sync0_n => profpga_sync0_n,
        dmbi_h2f        => dmbi_h2f,
        dmbi_f2h        => dmbi_f2h,
        user_rstn       => user_rstn,
        mon_ddr         => mon_ddr_reg,
        mon_mem         => mon_mem_reg,
        mon_noc         => mon_noc_actual,
        mon_acc         => mon_acc,
        mon_l2          => mon_l2,
        mon_llc         => mon_llc,
        mon_dvfs        => mon_dvfs);

  end generate profpga_mmi64_gen;

  no_profpga_mmi64_gen : if CFG_MON_DDR_EN + CFG_MON_NOC_INJECT_EN + CFG_MON_NOC_QUEUES_EN + CFG_MON_ACC_EN + CFG_MON_DVFS_EN = 0 generate
    dmbi_f2h <= (others => '0');
  end generate no_profpga_mmi64_gen;

end;

