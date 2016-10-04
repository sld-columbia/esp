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
-- Entity:      i2c2ahb_gen
-- File:        i2c2ahb_gen.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler AB
-- Contact:     support@gaisler.com
-- Description: Generic wrapper for I2C-slave, see i2c2ahb.vhd
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;

use work.i2c.all;

entity i2c2ahb_gen is
 generic (
   ahbaddrh   : integer := 0;
   ahbaddrl   : integer := 0;
   ahbmaskh   : integer := 0;
   ahbmaskl   : integer := 0;
   -- I2C configuration
   i2cslvaddr : integer range 0 to 127 := 0;
   i2ccfgaddr : integer range 0 to 127 := 0;
   oepol      : integer range 0 to 1 := 0;
   --
   filter     : integer range 2 to 512 := 2
   );
 port (
   rstn          : in  std_ulogic;
   clk           : in  std_ulogic;
   -- AHB master interface
   ahbi_hgrant   : in  std_ulogic;
   ahbi_hready   : in  std_ulogic;
   ahbi_hresp    : in  std_logic_vector(1 downto 0);
   ahbi_hrdata   : in  std_logic_vector(AHBDW-1 downto 0);
   --ahbo   : out ahb_mst_out_type;
   ahbo_hbusreq  : out  std_ulogic;
   ahbo_hlock    : out  std_ulogic;
   ahbo_htrans   : out  std_logic_vector(1 downto 0);
   ahbo_haddr    : out  std_logic_vector(31 downto 0);
   ahbo_hwrite   : out  std_ulogic;
   ahbo_hsize    : out  std_logic_vector(2 downto 0);
   ahbo_hburst   : out  std_logic_vector(2 downto 0);
   ahbo_hprot    : out  std_logic_vector(3 downto 0);
   ahbo_hwdata   : out  std_logic_vector(AHBDW-1 downto 0);
   -- I2C signals
   --i2ci    : in  i2c_in_type;
   i2ci_scl      : in  std_ulogic;
   i2ci_sda      : in  std_ulogic;
   --i2co    : out i2c_out_type
   i2co_scl      : out std_ulogic;
   i2co_scloen   : out std_ulogic;
   i2co_sda      : out std_ulogic;
   i2co_sdaoen   : out std_ulogic;
   i2co_enable   : out std_ulogic
   );
end entity i2c2ahb_gen;

architecture rtl of i2c2ahb_gen is
  
  -- AHB signals
  signal ahbi  : ahb_mst_in_type;
  signal ahbo  : ahb_mst_out_type;
  
  -- I2C signals
  signal i2ci  : i2c_in_type;
  signal i2co  : i2c_out_type;

begin

  ahbi.hgrant(0) <= ahbi_hgrant;
  ahbi.hgrant(1 to NAHBMST-1) <= (others => '0');
  ahbi.hready    <= ahbi_hready;
  ahbi.hresp     <= ahbi_hresp;
  ahbi.hrdata    <= ahbi_hrdata;

  ahbo_hbusreq   <= ahbo.hbusreq;
  ahbo_hlock     <= ahbo.hlock;
  ahbo_htrans    <= ahbo.htrans;
  ahbo_haddr     <= ahbo.haddr;
  ahbo_hwrite    <= ahbo.hwrite;
  ahbo_hsize     <= ahbo.hsize;
  ahbo_hburst    <= ahbo.hburst;
  ahbo_hprot     <= ahbo.hprot;
  ahbo_hwdata    <= ahbo.hwdata;
  
  i2ci.scl     <= i2ci_scl;
  i2ci.sda     <= i2ci_sda;

  i2co_scl     <= i2co.scl;
  i2co_scloen  <= i2co.scloen;
  i2co_sda     <= i2co.sda;
  i2co_sdaoen  <= i2co.sdaoen;
  i2co_enable  <= i2co.enable;
  
  i2c0 : i2c2ahb
    generic map (
      hindex => 0,
      ahbaddrh => ahbaddrh, ahbaddrl => ahbaddrl,
      ahbmaskh => ahbmaskh, ahbmaskl => ahbmaskl,
      i2cslvaddr => i2cslvaddr, i2ccfgaddr => i2ccfgaddr,
      oepol  => oepol, filter => filter)
    port map (rstn, clk, ahbi, ahbo, i2ci, i2co);
  
end architecture rtl;

