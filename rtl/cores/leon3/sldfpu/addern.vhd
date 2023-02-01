-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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
