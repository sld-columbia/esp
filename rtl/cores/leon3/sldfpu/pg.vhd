-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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

