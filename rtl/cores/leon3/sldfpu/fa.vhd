-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	fa
-- File:	fa.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Full Adder
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fa is
  
  port (
    in0  : in  std_ulogic;
    in1  : in  std_ulogic;
    cin  : in  std_ulogic;
    sum  : out std_ulogic;
    cout : out std_ulogic);

end fa;

architecture beh of fa is

begin  -- beh

  sum <= (in0 xor in1) xor cin;
  cout <= (in0 and in1) or (in0 and cin) or (in1 and cin);

end beh;
