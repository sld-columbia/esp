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
-- Entity: 	pg
-- File:	pg.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Carry and Propagate bits generate module
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity pg is

  port (
    a, b : in  std_logic;
    g, p : out std_logic);

end pg;

architecture behav of pg is

  
begin

  g <= a and b;
  p <= a xor b;
  
end behav;

