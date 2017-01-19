-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.libdcom.all;
use work.sim.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

use work.grlib_config.all;

entity testbench is
  generic (
    fabtech   : integer := CFG_FABTECH;
    memtech   : integer := CFG_MEMTECH;
    padtech   : integer := CFG_PADTECH;
    disas     : integer := CFG_DISAS;      -- Enable disassembly to console
    dbguart   : integer := CFG_DUART;      -- Print UART on console
    pclow     : integer := CFG_PCLOW;
    testahb   : boolean := true;
    USE_MIG_INTERFACE_MODEL : boolean := false

  );
end;

architecture behav of testbench is

-- DDR3 Simulation parameters
constant SIM_BYPASS_INIT_CAL : string := "FAST";
          -- # = "OFF" -  Complete memory init &
          --               calibration sequence
          -- # = "SKIP" - Not supported
          -- # = "FAST" - Complete memory init & use
          --              abbreviated calib sequence

constant SIMULATION          : string := "TRUE";
          -- Should be TRUE during design simulations and
          -- FALSE during implementations


constant promfile      : string := "prom.srec";  -- rom contents
constant ramfile       : string := "ram.srec";  -- ram contents

signal clk             : std_logic := '0';
signal rst             : std_logic := '0';

signal address         : std_logic_vector(25 downto 0);
signal data            : std_logic_vector(15 downto 0);
signal button          : std_logic_vector(3 downto 0) := "0000";
signal genio           : std_logic_vector(59 downto 0);
signal romsn           : std_logic;
signal oen             : std_ulogic;
signal writen          : std_ulogic;
signal adv             : std_logic;

signal GND             : std_ulogic := '0';
signal VCC             : std_ulogic := '1';
signal NC              : std_ulogic := 'Z';

signal txd1  , rxd1  , dsurx   : std_logic;
signal txd2  , rxd2  , dsutx   : std_logic;
signal ctsn1 , rtsn1 , dsuctsn : std_ulogic;
signal ctsn2 , rtsn2 , dsurtsn : std_ulogic;

  -- Ethernet signals
  signal reset_o2   : std_ulogic;
  signal etx_clk    : std_ulogic;
  signal erx_clk    : std_ulogic;
  signal erxdt      : std_logic_vector(7 downto 0);
  signal erx_dv     : std_ulogic;
  signal erx_er     : std_ulogic;
  signal erx_col    : std_ulogic;
  signal erx_crs    : std_ulogic;
  signal etxdt      : std_logic_vector(7 downto 0);
  signal etx_en     : std_ulogic;
  signal etx_er     : std_ulogic;
  signal emdc       : std_ulogic;
  signal emdio      : std_logic;

    -- DVI
  signal tft_nhpd : std_ulogic;
  signal tft_clk_p : std_ulogic;
  signal tft_clk_n : std_ulogic;
  signal tft_data : std_logic_vector(23 downto 0);
  signal tft_hsync : std_ulogic;
  signal tft_vsync : std_ulogic;
  signal tft_de : std_ulogic;
  signal tft_dken : std_ulogic;
  signal tft_ctl1_a1_dk1 : std_ulogic;
  signal tft_ctl2_a2_dk2 : std_ulogic;
  signal tft_a3_dk3 : std_ulogic;
  signal tft_isel : std_ulogic;
  signal tft_bsel : std_logic;
  signal tft_dsel : std_logic;
  signal tft_edge : std_ulogic;
  signal tft_npd : std_ulogic;

signal clk27           : std_ulogic := '0';
signal c0_main_clk_p         : std_ulogic := '0';
signal c0_main_clk_n         : std_ulogic := '1';
signal c1_main_clk_p         : std_ulogic := '0';
signal c1_main_clk_n         : std_ulogic := '1';
signal clk_ref_p       : std_ulogic := '0';
signal clk_ref_n       : std_ulogic := '1';
signal clk33           : std_ulogic := '0';
signal clkethp         : std_ulogic := '0';
signal clkethn         : std_ulogic := '1';
signal txp1            : std_logic;
signal txn             : std_logic;
signal rxp             : std_logic := '1';
signal rxn             : std_logic := '0';


-- DDR3 memory
signal c0_ddr3_dq         : std_logic_vector(63 downto 0);
signal c0_ddr3_dqs_p      : std_logic_vector(7 downto 0);
signal c0_ddr3_dqs_n      : std_logic_vector(7 downto 0);
signal c0_ddr3_addr       : std_logic_vector(14 downto 0);
signal c0_ddr3_ba         : std_logic_vector(2 downto 0);
signal c0_ddr3_ras_n      : std_logic;
signal c0_ddr3_cas_n      : std_logic;
signal c0_ddr3_we_n       : std_logic;
signal c0_ddr3_reset_n    : std_logic;
signal c0_ddr3_ck_p       : std_logic_vector(0 downto 0);
signal c0_ddr3_ck_n       : std_logic_vector(0 downto 0);
signal c0_ddr3_cke        : std_logic_vector(0 downto 0);
signal c0_ddr3_cs_n       : std_logic_vector(0 downto 0);
signal c0_ddr3_dm         : std_logic_vector(7 downto 0);
signal c0_ddr3_odt        : std_logic_vector(0 downto 0);
-- DDR3 memory
signal c1_ddr3_dq         : std_logic_vector(63 downto 0);
signal c1_ddr3_dqs_p      : std_logic_vector(7 downto 0);
signal c1_ddr3_dqs_n      : std_logic_vector(7 downto 0);
signal c1_ddr3_addr       : std_logic_vector(14 downto 0);
signal c1_ddr3_ba         : std_logic_vector(2 downto 0);
signal c1_ddr3_ras_n      : std_logic;
signal c1_ddr3_cas_n      : std_logic;
signal c1_ddr3_we_n       : std_logic;
signal c1_ddr3_reset_n    : std_logic;
signal c1_ddr3_ck_p       : std_logic_vector(0 downto 0);
signal c1_ddr3_ck_n       : std_logic_vector(0 downto 0);
signal c1_ddr3_cke        : std_logic_vector(0 downto 0);
signal c1_ddr3_cs_n       : std_logic_vector(0 downto 0);
signal c1_ddr3_dm         : std_logic_vector(7 downto 0);
signal c1_ddr3_odt        : std_logic_vector(0 downto 0);


signal dsurst          : std_ulogic;
signal errorn          : std_logic;

signal switch          : std_logic_vector(4 downto 0);    -- I/O port
signal led             : std_logic_vector(6 downto 0);    -- I/O port
constant lresp         : boolean := false;

signal tdqs_n : std_logic;

signal gmii_tx_clk     : std_logic;
signal gmii_rx_clk     : std_logic;
signal gmii_txd        : std_logic_vector(7 downto 0);
signal gmii_tx_en      : std_logic;
signal gmii_tx_er      : std_logic;
signal gmii_rxd        : std_logic_vector(7 downto 0);
signal gmii_rx_dv      : std_logic;
signal gmii_rx_er      : std_logic;

signal configuration_finished : boolean;
signal speed_is_10_100        : std_logic;
signal speed_is_100           : std_logic;


signal phy_mdio        : std_logic;
signal phy_mdc         : std_ulogic;

signal txp_eth, txn_eth : std_logic;

-- MMI64
signal    profpga_clk0_p        : std_ulogic := '0';  -- 100 MHz clock
signal    profpga_clk0_n        : std_ulogic := '1';  -- 100 MHz clock
signal    profpga_sync0_p       : std_ulogic;
signal    profpga_sync0_n       : std_ulogic;
signal    dmbi_h2f              : std_ulogic_vector(19 downto 0);
signal    dmbi_f2h              : std_ulogic_vector(19 downto 0);

component top
  generic (
    fabtech                 : integer;
    memtech                 : integer;
    padtech                 : integer;
    disas                   : integer;
    dbguart                 : integer;
    pclow                   : integer;
    testahb                 : boolean;
    SIM_BYPASS_INIT_CAL     : string;
    SIMULATION              : string;
    USE_MIG_INTERFACE_MODEL : boolean;
    autonegotiation         : integer);
  port (
    -- MMI64 interface:
    profpga_clk0_p        : in  std_ulogic;  -- 100 MHz clock
    profpga_clk0_n        : in  std_ulogic;  -- 100 MHz clock
    profpga_sync0_p       : in  std_ulogic;
    profpga_sync0_n       : in  std_ulogic;
    dmbi_h2f              : in  std_ulogic_vector(19 downto 0);
    dmbi_f2h              : out std_ulogic_vector(19 downto 0);
    --
    reset          : in    std_ulogic;
    c0_main_clk_p          : in    std_ulogic;  -- 160 MHz clock
    c0_main_clk_n          : in    std_ulogic;  -- 160 MHz clock
    c1_main_clk_p          : in    std_ulogic;  -- 160 MHz clock
    c1_main_clk_n          : in    std_ulogic;  -- 160 MHz clock
    clk_ref_p       : in    std_ulogic;  -- 200 MHz clock
    clk_ref_n       : in    std_ulogic;  -- 200 MHz clock
    --dsu_break      : in    std_ulogic;
    address        : out   std_logic_vector(25 downto 0);
    data           : inout std_logic_vector(15 downto 0);
    oen            : out   std_ulogic;
    writen         : out   std_ulogic;
    romsn          : out   std_logic;
    adv            : out   std_logic;
    c0_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c0_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c0_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c0_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c0_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c0_ddr3_ras_n     : out   std_logic;
    c0_ddr3_cas_n     : out   std_logic;
    c0_ddr3_we_n      : out   std_logic;
    c0_ddr3_reset_n   : out   std_logic;
    c0_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c0_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c0_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c0_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c0_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c0_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c0_calib_complete : out   std_logic;
    c1_ddr3_dq        : inout std_logic_vector(63 downto 0);
    c1_ddr3_dqs_p     : inout std_logic_vector(7 downto 0);
    c1_ddr3_dqs_n     : inout std_logic_vector(7 downto 0);
    c1_ddr3_addr      : out   std_logic_vector(14 downto 0);
    c1_ddr3_ba        : out   std_logic_vector(2 downto 0);
    c1_ddr3_ras_n     : out   std_logic;
    c1_ddr3_cas_n     : out   std_logic;
    c1_ddr3_we_n      : out   std_logic;
    c1_ddr3_reset_n   : out   std_logic;
    c1_ddr3_ck_p      : out   std_logic_vector(0 downto 0);
    c1_ddr3_ck_n      : out   std_logic_vector(0 downto 0);
    c1_ddr3_cke       : out   std_logic_vector(0 downto 0);
    c1_ddr3_cs_n      : out   std_logic_vector(0 downto 0);
    c1_ddr3_dm        : out   std_logic_vector(7 downto 0);
    c1_ddr3_odt       : out   std_logic_vector(0 downto 0);
    c1_calib_complete : out   std_logic;
    uart_rxd          : in    std_ulogic;
    uart_txd          : out   std_ulogic;
    uart_ctsn         : in    std_ulogic;
    uart_rtsn         : out   std_ulogic;
    -- Ethernet signals
    reset_o2  : out   std_ulogic;
    etx_clk   : in    std_ulogic;
    erx_clk   : in    std_ulogic;
    erxd      : in    std_logic_vector(3 downto 0);
    erx_dv    : in    std_ulogic;
    erx_er    : in    std_ulogic;
    erx_col   : in    std_ulogic;
    erx_crs   : in    std_ulogic;
    etxd      : out   std_logic_vector(3 downto 0);
    etx_en    : out   std_ulogic;
    etx_er    : out   std_ulogic;
    emdc      : out   std_ulogic;
    emdio     : inout std_logic;
    -- DVI
    tft_nhpd        : in  std_ulogic;   -- Hot plug
    tft_clk_p       : out std_ulogic;
    tft_clk_n       : out std_ulogic;
    tft_data        : out std_logic_vector(23 downto 0);
    tft_hsync       : out std_ulogic;
    tft_vsync       : out std_ulogic;
    tft_de          : out std_ulogic;
    tft_dken        : out std_ulogic;
    tft_ctl1_a1_dk1 : out std_ulogic;
    tft_ctl2_a2_dk2 : out std_ulogic;
    tft_a3_dk3      : out std_ulogic;
    tft_isel        : out std_ulogic;
    tft_bsel        : out std_logic;
    tft_dsel        : out std_logic;
    tft_edge        : out std_ulogic;
    tft_npd         : out std_ulogic;

    LED_RED        : out   std_ulogic;
    LED_GREEN      : out   std_ulogic;
    LED_BLUE       : out   std_ulogic;
    LED_YELLOW     : out   std_ulogic;
    c0_diagnostic_led  : out   std_ulogic;
    c1_diagnostic_led  : out   std_ulogic);
end component;

begin

  --MMI 64
  profpga_clk0_p <= not profpga_clk0_p after 5 ns;
  profpga_clk0_n <= not profpga_clk0_n after 5 ns;
  profpga_sync0_p <= '0';
  profpga_sync0_n <= '1';
  dmbi_h2f <= (others => '0');

  -- clock and reset
  c0_main_clk_p <= not c0_main_clk_p after 3.125 ns;
  c0_main_clk_n <= not c0_main_clk_n after 3.125 ns;
  c1_main_clk_p <= not c1_main_clk_p after 3.125 ns;
  c1_main_clk_n <= not c1_main_clk_n after 3.125 ns;
  clk_ref_p <= not clk_ref_p after 2.5 ns;
  clk_ref_n <= not clk_ref_n after 2.5 ns;
  clkethp <= not clkethp after 4 ns;
  clkethn <= not clkethp after 4 ns;

  rst <= not dsurst;
  rxd1 <= 'H'; ctsn1 <= '0';
  rxd2 <= 'H'; ctsn2 <= '0';
  button <= "0000";
  switch(3 downto 0) <= "0000";

  cpu : top
      generic map (
       fabtech              => fabtech,
       memtech              => memtech,
       padtech              => padtech,
       disas                => disas,
       dbguart              => dbguart,
       pclow                => pclow,
       testahb              => testahb,
       SIM_BYPASS_INIT_CAL  => SIM_BYPASS_INIT_CAL,
       SIMULATION           => SIMULATION,
       USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL,
       autonegotiation      => 0
   )
      port map (
       -- MMI64
       profpga_clk0_p  => profpga_clk0_p,
       profpga_clk0_n  => profpga_clk0_n,
       profpga_sync0_p => profpga_sync0_p,
       profpga_sync0_n => profpga_sync0_n,
       dmbi_h2f        => dmbi_h2f,
       dmbi_f2h        => dmbi_f2h,
       reset           => rst,
       c0_main_clk_p          => c0_main_clk_p,
       c0_main_clk_n          => c0_main_clk_n,
       c1_main_clk_p          => c1_main_clk_p,
       c1_main_clk_n          => c1_main_clk_n,
       clk_ref_p       => clk_ref_p,
       clk_ref_n       => clk_ref_n,
       --dsu_break       => '0',
       address         => address,
       data            => data,
       oen             => oen,
       writen          => writen,
       romsn           => romsn,
       adv             => adv,
       c0_ddr3_dq         => c0_ddr3_dq,
       c0_ddr3_dqs_p      => c0_ddr3_dqs_p,
       c0_ddr3_dqs_n      => c0_ddr3_dqs_n,
       c0_ddr3_addr       => c0_ddr3_addr,
       c0_ddr3_ba         => c0_ddr3_ba,
       c0_ddr3_ras_n      => c0_ddr3_ras_n,
       c0_ddr3_cas_n      => c0_ddr3_cas_n,
       c0_ddr3_we_n       => c0_ddr3_we_n,
       c0_ddr3_reset_n    => c0_ddr3_reset_n,
       c0_ddr3_ck_p       => c0_ddr3_ck_p,
       c0_ddr3_ck_n       => c0_ddr3_ck_n,
       c0_ddr3_cke        => c0_ddr3_cke,
       c0_ddr3_cs_n       => c0_ddr3_cs_n,
       c0_ddr3_dm         => c0_ddr3_dm,
       c0_ddr3_odt        => c0_ddr3_odt,
       c0_calib_complete  => open,
       c1_ddr3_dq         => c0_ddr3_dq,
       c1_ddr3_dqs_p      => c0_ddr3_dqs_p,
       c1_ddr3_dqs_n      => c0_ddr3_dqs_n,
       c1_ddr3_addr       => c0_ddr3_addr,
       c1_ddr3_ba         => c0_ddr3_ba,
       c1_ddr3_ras_n      => c0_ddr3_ras_n,
       c1_ddr3_cas_n      => c0_ddr3_cas_n,
       c1_ddr3_we_n       => c0_ddr3_we_n,
       c1_ddr3_reset_n    => c0_ddr3_reset_n,
       c1_ddr3_ck_p       => c0_ddr3_ck_p,
       c1_ddr3_ck_n       => c0_ddr3_ck_n,
       c1_ddr3_cke        => c0_ddr3_cke,
       c1_ddr3_cs_n       => c0_ddr3_cs_n,
       c1_ddr3_dm         => c0_ddr3_dm,
       c1_ddr3_odt        => c0_ddr3_odt,
       c1_calib_complete  => open,
       uart_rxd           => dsurx,
       uart_txd           => dsutx,
       uart_ctsn          => dsuctsn,
       uart_rtsn          => dsurtsn,
       reset_o2  => reset_o2,
       etx_clk   => etx_clk,
       erx_clk   => erx_clk,
       erxd      => erxdt(3 downto 0),
       erx_dv    => erx_dv,
       erx_er    => erx_er,
       erx_col   => erx_col,
       erx_crs   => erx_crs,
       etxd      => etxdt(3 downto 0),
       etx_en    => etx_en,
       etx_er    => etx_er,
       emdc      => emdc,
       emdio     => emdio,
       tft_nhpd  => '0',
       tft_clk_p  => tft_clk_p,
       tft_clk_n  => tft_clk_n,
       tft_data  => tft_data,
       tft_hsync  => tft_hsync,
       tft_vsync  => tft_vsync,
       tft_de  => tft_de,
       tft_dken  => tft_dken,
       tft_ctl1_a1_dk1 => tft_ctl1_a1_dk1,
       tft_ctl2_a2_dk2 => tft_ctl2_a2_dk2,
       tft_a3_dk3  => tft_a3_dk3,
       tft_isel  => tft_isel,
       tft_bsel  => tft_bsel,
       tft_dsel  => tft_dsel,
       tft_edge  => tft_edge,
       tft_npd  => tft_npd,

       LED_RED         => open,
       LED_GREEN       => open,
       LED_BLUE        => open,
       LED_YELLOW      => open,
       c0_diagnostic_led => open,
       c1_diagnostic_led => open
      );

  phy0 : if (CFG_GRETH = 1) generate
    etxdt(7 downto 4) <= "0000";
    emdio <= 'H';
    p0: phy
      generic map (address => 1)
      port map(reset_o2, emdio, etx_clk, erx_clk, erxdt, erx_dv, erx_er,
               erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, '0');
  end generate;

  tft_nhpd <= '1';

  prom0 : for i in 0 to 1 generate
      sr0 : sram generic map (index => i+4, abits => 26, fname => promfile)
        port map (address(25 downto 0), data(15-i*8 downto 8-i*8), romsn,
                  writen, oen);
  end generate;

  -- Memory model instantiation
  gen_mem_model : if (USE_MIG_INTERFACE_MODEL /= true) generate
     u1 : ddr3ram
       generic map (
         width     => 64,
         abits     => 14,
         colbits   => 10,
         rowbits   => 10,
         implbanks => 1,
         fname     => ramfile,
         lddelay   => (0 ns),
         ldguard   => 1,
         speedbin  => 9, --DDR3-1600K
         density   => 3,
         pagesize  => 1,
         changeendian => 8)
       port map (
          ck     => c0_ddr3_ck_p(0),
          ckn    => c0_ddr3_ck_n(0),
          cke    => c0_ddr3_cke(0),
          csn    => c0_ddr3_cs_n(0),
          odt    => c0_ddr3_odt(0),
          rasn   => c0_ddr3_ras_n,
          casn   => c0_ddr3_cas_n,
          wen    => c0_ddr3_we_n,
          dm     => c0_ddr3_dm,
          ba     => c0_ddr3_ba,
          a      => c0_ddr3_addr(13 downto 0),
          resetn => c0_ddr3_reset_n,
          dq     => c0_ddr3_dq,
          dqs    => c0_ddr3_dqs_p,
          dqsn   => c0_ddr3_dqs_n,
          doload => led(3)
          );
     c0_ddr3_addr(14) <= '0';

     u2 : ddr3ram
       generic map (
         width     => 64,
         abits     => 14,
         colbits   => 10,
         rowbits   => 10,
         implbanks => 1,
         fname     => ramfile,
         lddelay   => (0 ns),
         ldguard   => 1,
         speedbin  => 9, --DDR3-1600K
         density   => 3,
         pagesize  => 1,
         changeendian => 8)
       port map (
          ck     => c1_ddr3_ck_p(0),
          ckn    => c1_ddr3_ck_n(0),
          cke    => c1_ddr3_cke(0),
          csn    => c1_ddr3_cs_n(0),
          odt    => c1_ddr3_odt(0),
          rasn   => c1_ddr3_ras_n,
          casn   => c1_ddr3_cas_n,
          wen    => c1_ddr3_we_n,
          dm     => c1_ddr3_dm,
          ba     => c1_ddr3_ba,
          a      => c1_ddr3_addr(13 downto 0),
          resetn => c1_ddr3_reset_n,
          dq     => c1_ddr3_dq,
          dqs    => c1_ddr3_dqs_p,
          dqsn   => c1_ddr3_dqs_n,
          doload => led(3)
          );
     c1_ddr3_addr(14) <= '0';

  end generate gen_mem_model;

  mig_mem_model : if (USE_MIG_INTERFACE_MODEL = true) generate
    c0_ddr3_dq    <= (others => 'Z');
    c0_ddr3_dqs_p <= (others => 'Z');
    c0_ddr3_dqs_n <= (others => 'Z');
    c1_ddr3_dq    <= (others => 'Z');
    c1_ddr3_dqs_p <= (others => 'Z');
    c1_ddr3_dqs_n <= (others => 'Z');
  end generate mig_mem_model;

  errorn <= led(1);
  errorn <= 'H'; -- ERROR pull-up

   iuerr : process
   begin
     wait for 210 us; -- This is for proper DDR3 behaviour durign init phase not needed durin simulation
     wait on led(3);  -- DDR3 Memory Init ready
     wait for 5000 ns;
     if to_x01(errorn) = '1' then wait on errorn; end if;
     assert (to_x01(errorn) = '1')
       report "*** IU in error mode, simulation halted ***"
          severity failure ; -- this should be a failure
   end process;

  data <= buskeep(data) after 5 ns;

  dsucom : process
    procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
    variable w32 : std_logic_vector(31 downto 0);
    variable c8  : std_logic_vector(7 downto 0);
    constant txp : time := 320 * 1 ns;
    begin
    dsutx <= '1';
    dsurst <= '0';
    switch(4) <= '0';
    wait for 2500 ns;
    if (USE_MIG_INTERFACE_MODEL /= true) then
       wait for 210 us; -- This is for proper DDR3 behaviour durign init phase not needed durin simulation
    end if;
    dsurst <= '1';
    switch(4) <= '1';
    if (USE_MIG_INTERFACE_MODEL /= true) then
       wait on led(3);  -- Wait for DDR3 Memory Init ready
    end if;
    report "Start DSU transfer";
    wait for 5000 ns;
    txc(dsutx, 16#55#, txp);      -- sync uart

    -- Reads from memory and DSU register to mimic GRMON during simulation
    l1 : loop
     txc(dsutx, 16#80#, txp);
     txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
     rxi(dsurx, w32, txp, lresp);
     --report "DSU read memory " & tost(w32);
     txc(dsutx, 16#80#, txp);
     txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
     rxi(dsurx, w32, txp, lresp);
     --report "DSU Break and Single Step register" & tost(w32);
    end loop l1;

    wait;

    -- ** This is only kept for reference --

    -- do test read and writes to DDR3 to check status
    -- Write
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#01#, 16#23#, 16#45#, 16#67#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
    txa(dsutx, 16#89#, 16#AB#, 16#CD#, 16#EF#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#08#, txp);
    txa(dsutx, 16#08#, 16#19#, 16#2A#, 16#3B#, txp);
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#0C#, txp);
    txa(dsutx, 16#4C#, 16#5D#, 16#6E#, 16#7F#, txp);
    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
    rxi(dsurx, w32, txp, lresp);
    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
    rxi(dsurx, w32, txp, lresp);
    report "* Read " & tost(w32);
    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#08#, txp);
    rxi(dsurx, w32, txp, lresp);
    txc(dsutx, 16#a0#, txp);
    txa(dsutx, 16#40#, 16#00#, 16#00#, 16#0C#, txp);
    rxi(dsurx, w32, txp, lresp);
    wait;

    -- Register 0x90000000 (DSU Control Register)
    -- Data 0x0000202e (b0010 0000 0010 1110)
    -- [0] - Trace Enable
    -- [1] - Break On Error
    -- [2] - Break on IU watchpoint
    -- [3] - Break on s/w break points
    --
    -- [4] - (Break on trap)
    -- [5] - Break on error traps
    -- [6] - Debug mode (Read mode only)
    -- [7] - DSUEN (read mode)
    --
    -- [8] - DSUBRE (read mode)
    -- [9] - Processor mode error (clears error)
    -- [10] - processor halt (returns 1 if processor halted)
    -- [11] - power down mode (return 1 if processor in power down mode)
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#80#, 16#02#, txp);
    wait;
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#2e#, txp);

    wait for 25000 ns;
    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#01#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#24#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#00#, 16#0D#, txp);

    txc(dsutx, 16#c0#, txp);
    txa(dsutx, 16#90#, 16#70#, 16#11#, 16#78#, txp);
    txa(dsutx, 16#91#, 16#00#, 16#00#, 16#0D#, txp);

    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);
    txa(dsutx, 16#00#, 16#00#, 16#20#, 16#00#, txp);

    txc(dsutx, 16#80#, txp);
    txa(dsutx, 16#90#, 16#40#, 16#00#, 16#44#, txp);

    wait;

   end;

   begin
    dsuctsn <= '0';
    dsucfg(dsutx, dsurx);
    wait;
  end process;
end ;

