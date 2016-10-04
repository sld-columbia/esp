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
-- Entity: 	addern
-- File:	addern.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	n bit ripple carry adder
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.basic.all;

entity addern is
  
  generic (
    n : natural := 8);
  port (
    in0    : in  std_logic_vector(n-1 downto 0);
    in1    : in  std_logic_vector(n-1 downto 0);
    cin    : in  std_ulogic;
    total  : out std_logic_vector(n-1 downto 0);
    cout   : out std_ulogic);

end addern;


architecture sum of addern is

   signal carryint : std_logic_vector(n-1 downto 0);
   signal cin0 : std_ulogic;
   
begin  -- sum

  cin0 <= cin;
  
  firstfulladder : fa port map (
    in0  => in0(0),
    in1  => in1(0),
    cin  => cin0,
    sum  => total(0),
    cout => carryint(0));
        
 nfulladder: for i in 1 to n-1 generate    
    add : fa  port map (
      in0  => in0(i),
      in1  => in1(i),
      cin  => carryint(i-1),
      sum  => total(i),
      cout => carryint(i));
  end generate nfulladder;

    cout <= carryint(n-1);

end sum;
