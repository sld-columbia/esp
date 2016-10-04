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
-- Entity:      spi2ahb
-- File:        spi2ahb.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler AB
-- Contact:     support@gaisler.com
-- Description: Simple SPI slave providing a bridge to AMBA AHB
--              See spi2ahbx.vhd and GRIP for documentation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.conv_std_logic_vector;

use work.spi.all;

entity spi2ahb is
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
   cpha       : integer range 0 to 1 := 0
   );
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
end entity spi2ahb;

architecture rtl of spi2ahb is

  signal spi2ahbi : spi2ahb_in_type;

begin
  
  bridge : spi2ahbx
    generic map (
      hindex   => hindex,
      oepol    => oepol,
      filter   => filter,
      cpol     => cpol,
      cpha     => cpha)
    port map (
      rstn     => rstn,
      clk      => clk,
      ahbi     => ahbi,
      ahbo     => ahbo,
      spii     => spii,
      spio     => spio,
      spi2ahbi => spi2ahbi,
      spi2ahbo => open);
  
  spi2ahbi.en <= '1';
  spi2ahbi.haddr <= conv_std_logic_vector(ahbaddrh, 16) &
                    conv_std_logic_vector(ahbaddrl, 16);
  spi2ahbi.hmask <= conv_std_logic_vector(ahbmaskh, 16) &
                    conv_std_logic_vector(ahbmaskl, 16);
  
end architecture rtl;

