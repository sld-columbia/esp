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
-- package: 	ge_1000baseX_comp
-- File:	ge_1000baseX_comp.vhd
-- Author:	Andrea Gianarro - Aeroflex Gaisler
-- Description:	1000 Base-X core components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package ge_1000baseX_comp is
	
	component ge_1000baseX is
    generic (
      PHY_ADDR      : integer := 0;
      BASEX_AN_MODE : integer := 0
    );
    port(
      rx_ck           : in    std_logic;
      tx_ck           : in    std_logic;
      rx_reset        : in    std_logic;
      tx_reset        : in    std_logic;
      startup_enable  : in    std_logic;
      tbi_rxd         : in    std_logic_vector(9 downto 0);
      tbi_txd         : out   std_logic_vector(9 downto 0);
      gmii_rxd        : out   std_logic_vector(7 downto 0);
      gmii_rx_dv      : out   std_logic;
      gmii_rx_er      : out   std_logic;
      gmii_col        : out   std_logic;
      gmii_cs         : out   std_logic;
      gmii_txd        : in    std_logic_vector(7 downto 0);
      gmii_tx_en      : in    std_logic;
      gmii_tx_er      : in    std_logic;
      repeater_mode   : in    std_logic;
      mdc_reset       : in    std_logic;
      mdio_i          : in    std_logic;
      mdio_o          : out   std_logic;
      mdc             : in    std_logic;
      debug           : out   std_logic_vector(31 downto 0)
    );
  end component;

end package;

