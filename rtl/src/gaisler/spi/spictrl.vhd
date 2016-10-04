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
-- Entity:      spictrl
-- File:        spictrl.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler AB
-- Contact:     support@gaisler.com

-- Description: Wrapper for SPICTRL core
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.gencomp.all;
use work.netcomp.all;
use work.amba.all;
use work.devices.all;
use work.stdlib.all;
use work.spi.all;

entity spictrl is
  generic (
    -- APB generics
    pindex : integer := 0;                -- slave bus index
    paddr  : integer := 0;                -- APB address
    pmask  : integer := 16#fff#;          -- APB mask
    pirq   : integer := 0;                -- interrupt index

    -- SPI controller configuration
    fdepth    : integer range 1 to 7      := 1;  -- FIFO depth is 2^fdepth
    slvselen  : integer range 0 to 1      := 0;  -- Slave select register enable
    slvselsz  : integer range 1 to 32     := 1;  -- Number of slave select signals
    oepol     : integer range 0 to 1      := 0;  -- Output enable polarity
    odmode    : integer range 0 to 1      := 0;  -- Support open drain mode, only
                                                -- set if pads are i/o or od pads.
    automode  : integer range 0 to 1      := 0;  -- Enable automated transfer mode
    acntbits  : integer range 1 to 32     := 32; -- # Bits in am period counter
    aslvsel   : integer range 0 to 1      := 0;  -- Automatic slave select
    twen      : integer range 0 to 1      := 1;  -- Enable three wire mode
    maxwlen   : integer range 0 to 15     := 0;  -- Maximum word length

    netlist   : integer                   := 0;  -- Use netlist (tech)

    syncram   : integer range 0 to 1      := 1;  -- Use SYNCRAM for buffers
    memtech   : integer                   := 0;  -- Memory technology
    ft        : integer range 0 to 2      := 0;  -- Fault-Tolerance
    scantest  : integer range 0 to 1      := 0;  -- Scan test support
    syncrst   : integer range 0 to 1      := 0;  -- Use only sync reset
    automask0 : integer                   := 0;  -- Mask 0 for automated transfers
    automask1 : integer                   := 0;  -- Mask 1 for automated transfers
    automask2 : integer                   := 0;  -- Mask 2 for automated transfers
    automask3 : integer                   := 0;  -- Mask 3 for automated transfers
    ignore    : integer range 0 to 1      := 0   -- Ignore samples
    );
  port (
    rstn   : in std_ulogic;
    clk    : in std_ulogic;

    -- APB signals
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;

    -- SPI signals
    spii   : in  spi_in_type;
    spio   : out spi_out_type;
    slvsel : out std_logic_vector((slvselsz-1) downto 0)
    );
end entity spictrl;

architecture rtl of spictrl is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant SPICTRL_REV : integer := 5;

  constant PCONFIG : apb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_SPICTRL, 0, SPICTRL_REV, pirq),
  1 => apb_iobar(paddr, pmask));

  -----------------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------------
  component spictrlx
    generic (
      rev       : integer                  := 0;
      fdepth    : integer range 1 to 7     := 1;
      slvselen  : integer range 0 to 1     := 0;
      slvselsz  : integer range 1 to 32    := 1;
      oepol     : integer range 0 to 1     := 0;
      odmode    : integer range 0 to 1     := 0;
      automode  : integer range 0 to 1     := 0;
      acntbits  : integer range 1 to 32    := 32;
      aslvsel   : integer range 0 to 1     := 0;
      twen      : integer range 0 to 1     := 1;
      maxwlen   : integer range 0 to 15    := 0;
      syncram   : integer range 0 to 1     := 1;
      memtech   : integer range 0 to NTECH := 0;
      ft        : integer range 0 to 2     := 0;
      scantest  : integer range 0 to 1     := 0;
      syncrst   : integer range 0 to 1     := 0;
      automask0 : integer                  := 0;
      automask1 : integer                  := 0;
      automask2 : integer                  := 0;
      automask3 : integer                  := 0;
      ignore    : integer range 0 to 1     := 0);
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
      spii_ignore   : in  std_ulogic;
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

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal apbo_pirq : std_ulogic;

begin

  ctrl_rtl : if netlist = 0 generate
    rtlc :  spictrlx
      generic map (
        rev       => SPICTRL_REV,
        fdepth    => fdepth,
        slvselen  => slvselen,
        slvselsz  => slvselsz,
        oepol     => oepol,
        odmode    => odmode,
        automode  => automode,
        acntbits  => acntbits,
        aslvsel   => aslvsel,
        twen      => twen,
        maxwlen   => maxwlen,
        syncram   => syncram,
        memtech   => memtech,
        ft        => ft,
        scantest  => scantest,
        syncrst   => syncrst,
        automask0 => automask0,
        automask1 => automask1,
        automask2 => automask2,
        automask3 => automask3,
        ignore    => ignore)
      port map (
        rstn         => rstn,
        clk          => clk,
        -- APB signals
        apbi_psel    => apbi.psel(pindex),
        apbi_penable => apbi.penable,
        apbi_paddr   => apbi.paddr,
        apbi_pwrite  => apbi.pwrite,
        apbi_pwdata  => apbi.pwdata,
        apbi_testen  => apbi.testen,
        apbi_testrst => apbi.testrst,
        apbi_scanen  => apbi.scanen,
        apbi_testoen => apbi.testoen,
        apbo_prdata  => apbo.prdata,
        apbo_pirq    => apbo_pirq,
        -- SPI signals
        spii_miso    => spii.miso,
        spii_mosi    => spii.mosi,
        spii_sck     => spii.sck,
        spii_spisel  => spii.spisel,
        spii_astart  => spii.astart,
        spii_cstart  => spii.cstart,
        spii_ignore  => spii.ignore,
        spio_miso    => spio.miso,
        spio_misooen => spio.misooen,
        spio_mosi    => spio.mosi,
        spio_mosioen => spio.mosioen,
        spio_sck     => spio.sck,
        spio_sckoen  => spio.sckoen,
        spio_enable  => spio.enable,
        spio_astart  => spio.astart,
        spio_aready  => spio.aready,
        slvsel       => slvsel);
  end generate ctrl_rtl;

  ctrl_netlist : if netlist /= 0 generate
    netlc :  spictrl_net
      generic map (
        tech      => netlist,
        fdepth    => fdepth,
        slvselen  => slvselen,
        slvselsz  => slvselsz,
        oepol     => oepol,
        odmode    => odmode,
        automode  => automode,
        acntbits  => acntbits,
        aslvsel   => aslvsel,
        twen      => twen,
        maxwlen   => maxwlen,
        automask0 => automask0,
        automask1 => automask1,
        automask2 => automask2,
        automask3 => automask3)
      port map (
        rstn         => rstn,
        clk          => clk,
        -- APB signals
        apbi_psel    => apbi.psel(pindex),
        apbi_penable => apbi.penable,
        apbi_paddr   => apbi.paddr,
        apbi_pwrite  => apbi.pwrite,
        apbi_pwdata  => apbi.pwdata,
        apbi_testen  => apbi.testen,
        apbi_testrst => apbi.testrst,
        apbi_scanen  => apbi.scanen,
        apbi_testoen => apbi.testoen,
        apbo_prdata  => apbo.prdata,
        apbo_pirq    => apbo_pirq,
        -- SPI signals
        spii_miso    => spii.miso,
        spii_mosi    => spii.mosi,
        spii_sck     => spii.sck,
        spii_spisel  => spii.spisel,
        spii_astart  => spii.astart,
        spii_cstart  => spii.cstart,
        spio_miso    => spio.miso,
        spio_misooen => spio.misooen,
        spio_mosi    => spio.mosi,
        spio_mosioen => spio.mosioen,
        spio_sck     => spio.sck,
        spio_sckoen  => spio.sckoen,
        spio_enable  => spio.enable,
        spio_astart  => spio.astart,
        spio_aready  => spio.aready,
        slvsel       => slvsel);
  end generate ctrl_netlist;

  spio.ssn <= (others => '0');

  irqgen : process(apbo_pirq)
    variable irq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
     irq := (others => '0'); irq(pirq) := apbo_pirq;
     apbo.pirq <= irq;
  end process;

  apbo.pconfig <= PCONFIG;
  apbo.pindex <= pindex;

  -- Boot message
  -- pragma translate_off
  bootmsg : report_version
    generic map (
      "spictrl" & tost(pindex) & ": SPI controller, rev " &
      tost(SPICTRL_REV) & ", irq " & tost(pirq));
  -- pragma translate_on

end architecture rtl;

