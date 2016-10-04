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
-----------------------------------------------------------------------------
-- Pacakge: spi
-- File: spi.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Description:  SPI interface package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;

package spi is

  type spi_in_type is record
    miso    : std_ulogic;
    mosi    : std_ulogic;
    sck     : std_ulogic;
    spisel  : std_ulogic;
    astart  : std_ulogic;
    cstart  : std_ulogic;
    ignore  : std_ulogic;
  end record;

  type spi_in_vector is array (natural range <>) of spi_in_type;

  constant spi_in_none : spi_in_type := ('0', '0', '0', '0', '0', '0', '0');

  type spi_out_type is record
    miso     : std_ulogic;
    misooen  : std_ulogic;
    mosi     : std_ulogic;
    mosioen  : std_ulogic;
    sck      : std_ulogic;
    sckoen   : std_ulogic;
    ssn      : std_logic_vector(7 downto 0);  -- used by GE/OC SPI core
    enable   : std_ulogic;
    astart   : std_ulogic;
    aready   : std_ulogic;
  end record;

  type spi_out_vector is array (natural range <>) of spi_out_type;

  constant spi_out_none : spi_out_type := ('0', '0', '0', '0', '0', '0',
                                           (others => '0'), '0', '0', '0');

  -- SPI master/slave controller
  component spictrl
    generic (
      pindex    : integer := 0;
      paddr     : integer := 0;
      pmask     : integer := 16#fff#;
      pirq      : integer := 0;
      fdepth    : integer range 1 to 7       := 1;
      slvselen  : integer range 0 to 1       := 0;
      slvselsz  : integer range 1 to 32      := 1;
      oepol     : integer range 0 to 1       := 0;
      odmode    : integer range 0 to 1       := 0;
      automode  : integer range 0 to 1       := 0;
      acntbits  : integer range 1 to 32      := 32;
      aslvsel   : integer range 0 to 1       := 0;
      twen      : integer range 0 to 1       := 1;
      maxwlen   : integer range 0 to 15      := 0;
      netlist   : integer                    := 0;
      syncram   : integer range 0 to 1       := 1;
      memtech   : integer                    := 0;
      ft        : integer range 0 to 2       := 0;
      scantest  : integer range 0 to 1       := 0;
      syncrst   : integer range 0 to 1       := 0;
      automask0 : integer                    := 0;
      automask1 : integer                    := 0;
      automask2 : integer                    := 0;
      automask3 : integer                    := 0;
      ignore    : integer range 0 to 1       := 0
      );
    port (
      rstn   : in std_ulogic;
      clk    : in std_ulogic;
      apbi   : in apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      spii   : in  spi_in_type;
      spio   : out spi_out_type;
      slvsel : out std_logic_vector((slvselsz-1) downto 0)
    );
  end component;

  -- SPI to AHB bridge

  type spi2ahb_in_type is record
    haddr   : std_logic_vector(31 downto 0);
    hmask   : std_logic_vector(31 downto 0);
    en      : std_ulogic;
  end record;

  type spi2ahb_out_type is record
    dma     : std_ulogic;
    wr      : std_ulogic;
    prot    : std_ulogic;
  end record;

  component spi2ahb
    generic (
      -- AHB Configuration
      hindex     : integer := 0;
      --
      ahbaddrh   : integer := 0;
      ahbaddrl   : integer := 0;
      ahbmaskh   : integer := 0;
      ahbmaskl   : integer := 0;
      --
      oepol      : integer range 0 to 1 := 0;
      --
      filter     : integer range 2 to 512 := 2;
      --
      cpol       : integer range 0 to 1 := 0;
      cpha       : integer range 0 to 1 := 0);
    port (
      rstn   : in  std_ulogic;
      clk    : in  std_ulogic;
      -- AHB master interface
      ahbi   : in  ahb_mst_in_type;
      ahbo   : out ahb_mst_out_type;
      -- SPI signals
      spii   : in  spi_in_type;
      spio   : out spi_out_type
      );
  end component;

  component spi2ahb_apb
    generic (
      -- AHB Configuration
      hindex     : integer := 0;
      --
      ahbaddrh   : integer := 0;
      ahbaddrl   : integer := 0;
      ahbmaskh   : integer := 0;
      ahbmaskl   : integer := 0;
      resen      : integer := 0;
      -- APB configuration
      pindex     : integer := 0;
      paddr      : integer := 0;
      pmask      : integer := 16#fff#;
      pirq       : integer := 0;
      --
      oepol      : integer range 0 to 1 := 0;
      --
      filter     : integer range 2 to 512 := 2;
      --
      cpol       : integer range 0 to 1 := 0;
      cpha       : integer range 0 to 1 := 0);
    port (
      rstn   : in  std_ulogic;
      clk    : in  std_ulogic;
      -- AHB master interface
      ahbi   : in  ahb_mst_in_type;
      ahbo   : out ahb_mst_out_type;
      --
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      -- SPI signals
      spii   : in  spi_in_type;
      spio   : out spi_out_type
      );
  end component;

  component spi2ahbx
    generic (
      hindex   : integer := 0;
      oepol    : integer range 0 to 1 := 0;
      filter   : integer range 2 to 512 := 2;
      cpol     : integer range 0 to 1 := 0;
      cpha     : integer range 0 to 1 := 0);
    port (
      rstn     : in  std_ulogic;
      clk      : in  std_ulogic;
      -- AHB master interface
      ahbi     : in  ahb_mst_in_type;
      ahbo     : out ahb_mst_out_type;
      -- SPI signals
      spii     : in  spi_in_type;
      spio     : out spi_out_type;
      --
      spi2ahbi : in  spi2ahb_in_type;
      spi2ahbo : out spi2ahb_out_type
      );
  end component;

  type spimctrl_in_type is record
    miso        : std_ulogic;
    mosi        : std_ulogic;
    cd          : std_ulogic;
  end record;

  type spimctrl_out_type is record
    mosi        : std_ulogic;
    mosioen     : std_ulogic;
    sck         : std_ulogic;
    csn         : std_ulogic;
    cdcsnoen    : std_ulogic;
--    errorn      : std_ulogic;
    ready       : std_ulogic;
    initialized : std_ulogic;
  end record;

  constant spimctrl_out_none : spimctrl_out_type :=
    ('0', '1', '0', '1', '1', '0', '0');

  component spimctrl
    generic (
      hindex      : integer := 0;
      hirq        : integer := 0;
      faddr       : integer := 16#000#;
      fmask       : integer := 16#fff#;
      ioaddr      : integer := 16#000#;
      iomask      : integer := 16#fff#;
      spliten     : integer := 0;
      oepol       : integer := 0;
      sdcard      : integer range 0 to 1   := 0;
      readcmd     : integer range 0 to 255 := 16#0B#;
      dummybyte   : integer range 0 to 1   := 1;
      dualoutput  : integer range 0 to 1   := 0;
      scaler      : integer range 1 to 512 := 1;
      altscaler   : integer range 1 to 512 := 1;
      pwrupcnt    : integer := 0;
      maxahbaccsz : integer range 0 to 256 := AHBDW;
      offset      : integer := 0
      );
    port (
      rstn    : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      spii    : in  spimctrl_in_type;
      spio    : out spimctrl_out_type
    );
  end component;

end;

