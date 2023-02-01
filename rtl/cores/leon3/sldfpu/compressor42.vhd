-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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
