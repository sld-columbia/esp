-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	dot
-- File:	dot.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Dot operator for parallel prefix adder
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity dot is

  port (
    gi1, pi1 : in  std_logic;
    gi2, pi2 : in  std_logic;
    go , po  : out std_logic);

end dot;

architecture behav of dot is

  
begin

  go <= gi1 or (pi1 and gi2);
  po <= pi1 and pi2;
  
end behav;

