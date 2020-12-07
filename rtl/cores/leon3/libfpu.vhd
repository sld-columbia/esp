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
-- Package:     libfpu
-- File:        libfpu.vhd
-- Author:      Jiri Gaisler, Gaisler Research
-- Description: LEON3 FPU interface types and components
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.leon3.all;
use work.gencomp.all;
use work.coretypes.all;

package libfpu is

  component grfpwxsh
  generic (
    tech     : integer range 0 to NTECH := 0;
    pclow    : integer range 0 to 2 := 2;
    dsu      : integer range 0 to 1 := 0;           
    disas    : integer range 0 to 2 := 0;
    id       : integer range 0 to 7 := 0;
    scantest : integer              := 0
    );
  port (
    rst    : in  std_ulogic;                    -- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;                    -- pipeline hold
    cpi    : in  fpc_in_type;
    cpo    : out fpc_out_type;
    fpui   : out grfpu_in_type;
    fpuo   : in  grfpu_out_type;
    testin : in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
    );
  end component;

end;

