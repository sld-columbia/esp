------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
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
-------------------------------------------------------------------------------
-- Entity:      spictrl_net
-- File:        spictrl_net.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler
-- Description: Netlist wrapper for SPICTRL core
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.gencomp.all;

entity spictrl_net is
  generic (
    tech      : integer range 0 to NTECH := 0;
    fdepth    : integer range 1 to 7  := 1;
    slvselen  : integer range 0 to 1  := 0;
    slvselsz  : integer range 1 to 32 := 1;
    oepol     : integer range 0 to 1  := 0;
    odmode    : integer range 0 to 1  := 0;
    automode  : integer range 0 to 1  := 0;
    acntbits  : integer range 1 to 32 := 32;
    aslvsel   : integer range 0 to 1  := 0;
    twen      : integer range 0 to 1  := 1;
    maxwlen   : integer range 0 to 15 := 0;
    automask0 : integer               := 0;
    automask1 : integer               := 0;
    automask2 : integer               := 0;
    automask3 : integer               := 0
  );
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
    slvsel        : out std_logic_vector((slvselsz-1) downto 0)
    );
end entity spictrl_net;

architecture rtl of spictrl_net is
  
  component spictrl_unisim
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
  end component;

begin

  xil : if false generate --(is_unisim(tech) = 1) generate
    xilctrl :  spictrl_unisim
      generic map (
        slvselen => slvselen,
        slvselsz => slvselsz)
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

-- pragma translate_off
  nonet : if true generate --not ((is_unisim(tech) = 1)) generate
    err : process
    begin
      assert false report "ERROR : No SPICTRL netlist available for this process!"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end architecture;

