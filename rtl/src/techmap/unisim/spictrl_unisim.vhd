------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2011, Aeroflex Gaisler AB - all rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE GAISLER LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING.
------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--library synplify;


entity spictrl_unisim is
  generic (
    slvselen      : integer range 0 to 1  := 0;
    slvselsz      : integer range 1 to 32 := 1);
  port (
    rstn          : in std_ulogic;
    clk           : in std_ulogic; 
    -- APB signals
    apbi_psel     : in  std_ulogic;
    apbi_penable  : in  std_ulogic;
    apbi_paddr    : in  std_logic_vector(31 downto 0);
    apbi_pwrite   : in  std_ulogic;
    apbi_pwdata   : in  std_logic_vector(31 downto 0);
    apbi_testen   : in  std_ulogic;
    apbi_testrst  : in  std_ulogic;
    apbi_scanen   : in  std_ulogic;
    apbi_testoen  : in  std_ulogic;
    apbo_prdata   : out std_logic_vector(31 downto 0);
    apbo_pirq     : out std_ulogic;
    -- SPI signals
    spii_miso     : in  std_ulogic;
    spii_mosi     : in  std_ulogic;
    spii_sck      : in  std_ulogic;
    spii_spisel   : in  std_ulogic;
    spii_astart   : in  std_ulogic;
    spii_cstart   : in  std_ulogic;
    spio_miso     : out std_ulogic;
    spio_misooen  : out std_ulogic;
    spio_mosi     : out std_ulogic;
    spio_mosioen  : out std_ulogic;
    spio_sck      : out std_ulogic;
    spio_sckoen   : out std_ulogic;
    spio_enable   : out std_ulogic;
    spio_astart   : out std_ulogic;
    spio_aready   : out std_ulogic;
    slvsel        : out std_logic_vector((slvselsz-1) downto 0));
end spictrl_unisim;

architecture rtl of spictrl_unisim is
  
  -- Combination 0, 32 slave selects
  component spictrl_unisim_comb0
    port (
      rstn          : in std_ulogic;
      clk           : in std_ulogic; 
      -- APB signals
      apbi_psel     : in  std_ulogic;
      apbi_penable  : in  std_ulogic;
      apbi_paddr    : in  std_logic_vector(31 downto 0);
      apbi_pwrite   : in  std_ulogic;
      apbi_pwdata   : in  std_logic_vector(31 downto 0);
      apbi_testen   : in  std_ulogic;
      apbi_testrst  : in  std_ulogic;
      apbi_scanen   : in  std_ulogic;
      apbi_testoen  : in  std_ulogic;
      apbo_prdata   : out std_logic_vector(31 downto 0);
      apbo_pirq     : out std_ulogic;
      -- SPI signals
      spii_miso     : in  std_ulogic;
      spii_mosi     : in  std_ulogic;
      spii_sck      : in  std_ulogic;
      spii_spisel   : in  std_ulogic;
      spii_astart   : in  std_ulogic;
      spii_cstart   : in  std_ulogic;
      spio_miso     : out std_ulogic;
      spio_misooen  : out std_ulogic;
      spio_mosi     : out std_ulogic;
      spio_mosioen  : out std_ulogic;
      spio_sck      : out std_ulogic;
      spio_sckoen   : out std_ulogic;
      spio_enable   : out std_ulogic;
      spio_astart   : out std_ulogic;
      spio_aready   : out std_ulogic;
      slvsel        : out std_logic_vector(31 downto 0));
  end component;

  -- Combination 1, 32 disabled slave selects
  component spictrl_unisim_comb1
    port (
      rstn          : in std_ulogic;
      clk           : in std_ulogic; 
      -- APB signals
      apbi_psel     : in  std_ulogic;
      apbi_penable  : in  std_ulogic;
      apbi_paddr    : in  std_logic_vector(31 downto 0);
      apbi_pwrite   : in  std_ulogic;
      apbi_pwdata   : in  std_logic_vector(31 downto 0);
      apbi_testen   : in  std_ulogic;
      apbi_testrst  : in  std_ulogic;
      apbi_scanen   : in  std_ulogic;
      apbi_testoen  : in  std_ulogic;
      apbo_prdata   : out std_logic_vector(31 downto 0);
      apbo_pirq     : out std_ulogic;
      -- SPI signals
      spii_miso     : in  std_ulogic;
      spii_mosi     : in  std_ulogic;
      spii_sck      : in  std_ulogic;
      spii_spisel   : in  std_ulogic;
      spii_astart   : in  std_ulogic;
      spii_cstart   : in  std_ulogic;
      spio_miso     : out std_ulogic;
      spio_misooen  : out std_ulogic;
      spio_mosi     : out std_ulogic;
      spio_mosioen  : out std_ulogic;
      spio_sck      : out std_ulogic;
      spio_sckoen   : out std_ulogic;
      spio_enable   : out std_ulogic;
      spio_astart   : out std_ulogic;
      spio_aready   : out std_ulogic;
      slvsel        : out std_logic_vector(31 downto 0));
  end component;
  
begin

  slvselact : if slvselen /= 0 generate
    spic0 : spictrl_unisim_comb0
      port map (
        rstn => rstn,
        clk => clk,
        -- APB signals
        apbi_psel    => apbi_psel,
        apbi_penable => apbi_penable,
        apbi_paddr   => apbi_paddr,
        apbi_pwrite  => apbi_pwrite,
        apbi_pwdata  => apbi_pwdata,
        apbi_testen  => apbi_testen,
        apbi_testrst => apbi_testrst,
        apbi_scanen  => apbi_scanen,
        apbi_testoen => apbi_testoen,
        apbo_prdata  => apbo_prdata,
        apbo_pirq    => apbo_pirq,
        -- SPI signals
        spii_miso    => spii_miso,
        spii_mosi    => spii_mosi,
        spii_sck     => spii_sck,
        spii_spisel  => spii_spisel,
        spii_astart  => spii_astart,
        spii_cstart  => spii_cstart,
        spio_miso    => spio_miso,
        spio_misooen => spio_misooen,
        spio_mosi    => spio_mosi,
        spio_mosioen => spio_mosioen,
        spio_sck     => spio_sck,
        spio_sckoen  => spio_sckoen,
        spio_enable  => spio_enable,
        spio_astart  => spio_astart,
        spio_aready  => spio_aready,
        slvsel       => slvsel);
  end generate;

  noslvsel : if slvselen = 0 generate
    spic0 : spictrl_unisim_comb1
      port map (
        rstn => rstn,
        clk => clk,
        -- APB signals
        apbi_psel    => apbi_psel,
        apbi_penable => apbi_penable,
        apbi_paddr   => apbi_paddr,
        apbi_pwrite  => apbi_pwrite,
        apbi_pwdata  => apbi_pwdata,
        apbi_testen  => apbi_testen,
        apbi_testrst => apbi_testrst,
        apbi_scanen  => apbi_scanen,
        apbi_testoen => apbi_testoen,
        apbo_prdata  => apbo_prdata,
        apbo_pirq    => apbo_pirq,
        -- SPI signals
        spii_miso    => spii_miso,
        spii_mosi    => spii_mosi,
        spii_sck     => spii_sck,
        spii_spisel  => spii_spisel,
        spii_astart  => spii_astart,
        spii_cstart  => spii_cstart,
        spio_miso    => spio_miso,
        spio_misooen => spio_misooen,
        spio_mosi    => spio_mosi,
        spio_mosioen => spio_mosioen,
        spio_sck     => spio_sck,
        spio_sckoen  => spio_sckoen,
        spio_enable  => spio_enable,
        spio_astart  => spio_astart,
        spio_aready  => spio_aready,
        slvsel       => slvsel);
  end generate;
  
end rtl;

