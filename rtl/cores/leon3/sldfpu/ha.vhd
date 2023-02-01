-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	ha
-- File:	ha.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Half Adder
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ha is

  port (
    in0  : in  std_ulogic;
    in1  : in  std_ulogic;
    sum  : out std_ulogic;
    cout : out std_ulogic);

end ha;

architecture beh of ha is

begin  -- beh

  sum <= (in0 xor in1);
  cout <= (in0 and in1);

end beh;
