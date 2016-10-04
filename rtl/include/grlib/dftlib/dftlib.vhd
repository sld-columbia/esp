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
-- Package:     dftlib
-- File:        dftlib.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Package for ASIC design-for-test functionality
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package dftlib is

  -----------------------------------------------------------------------------
  -- Synchronous I/O test module
  -----------------------------------------------------------------------------
  component synciotest is
    generic (
      ninputs : integer;
      noutputs : integer;
      nbidir : integer;
      dirmode : integer := 0
      );
    port (
      clk: in std_ulogic;
      rstn: in std_ulogic;
      datain: in std_logic_vector(ninputs+nbidir-1 downto 0);
      dataout: out std_logic_vector(noutputs+nbidir-1 downto 0);
      tmode: in std_logic_vector(5 downto 0);
      tmodeact: out std_ulogic;
      tmodeoe: out std_ulogic
      );
  end component;

end;

