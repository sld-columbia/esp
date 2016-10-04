------------------------------------------------------------------------------
--  This file is part of Floating Point Unit design for the Leon3 processor
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
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
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity: 	compressor42
-- File:	compressor42.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	(4,2) compressor
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity compressor42 is
  
  port (
    x  : in  std_logic_vector(3 downto 0);
    ci : in  std_ulogic;
    S  : out std_ulogic;
    C  : out std_ulogic;
    co : out std_ulogic);

end compressor42;

architecture rtl of compressor42 is

  signal w, y, z : std_ulogic;
  
begin  -- rtl

  w <= x(3) xor x(2);
  y <= x(1) xor x(0);
  z <= w xor y;

  co <= x(3) when w='0' else x(1);
  C <= x(0) when z='0' else ci;
  S <= z xor ci;

end rtl;
