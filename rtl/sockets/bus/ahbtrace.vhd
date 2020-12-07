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
-- Entity: 	ahbtrace
-- File:	ahbtrace.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	AHB trace unit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;

entity ahbtrace is
  generic (
    hindex   : integer := 0;
    ioaddr   : integer := 16#000#;
    iomask   : integer := 16#E00#;
    tech     : integer := DEFMEMTECH; 
    irq      : integer := 0; 
    kbytes   : integer := 1;
    bwidth   : integer := 32;
    ahbfilt  : integer := 0;
    scantest : integer range 0 to 1 := 0;
    exttimer : integer range 0 to 1 := 0;
    exten    : integer range 0 to 1 := 0);
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbmi    : in  ahb_mst_in_type;
    ahbsi    : in  ahb_slv_in_type;
    ahbso    : out ahb_slv_out_type;
    timer    : in  std_logic_vector(30 downto 0) := (others => '0');
    astat    : out amba_stat_type;
    resen    : in  std_ulogic := '0'
  );
end; 

architecture rtl of ahbtrace is

begin

  ahbt0 : ahbtrace_mb
    generic map (
      hindex   => hindex,
      ioaddr   => ioaddr,
      iomask   => iomask,
      tech     => tech,
      irq      => irq,
      kbytes   => kbytes,
      bwidth   => bwidth,
      ahbfilt  => ahbfilt,
      scantest => scantest,
      exttimer => exttimer,
      exten    => exten)
    port map(
      rst      => rst,
      clk      => clk,
      ahbsi    => ahbsi,
      ahbso    => ahbso,
      tahbmi   => ahbmi,
      tahbsi   => ahbsi,
      timer    => timer,
      astat    => astat,
      resen    => resen);
  
end;

