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
-- Entity:      sgn
-- File:	sgn.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Sign Evaluation for floating point multiplication
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sgn is
  
  port (
    clk      : in  std_ulogic;
    rst      : in  std_ulogic;
    s0       : in  std_ulogic;
    s1       : in  std_ulogic;
    sign     : out std_ulogic);

end sgn;

architecture str of sgn is

  signal sign_tmp, sign1_reg, sign2_reg : std_ulogic;
  
begin  -- str

  --output
  sign <= sign2_reg;

  -- Mul Stage 1: compute sign
  sign_tmp <= s0 xor s1;

  stage1: process (clk, rst)
  begin  -- process stage1
    if rst = '0' then                   -- asynchronous reset (active low)
      sign1_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      sign1_reg <= sign_tmp;
    end if;
  end process stage1;

  -- Mul Stage 2: sign deskew
  stage2: process (clk, rst)
  begin  -- process stage2
    if rst = '0' then                   -- asynchronous reset (active low)
      sign2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      sign2_reg <= sign1_reg;
    end if;
  end process stage2;

end str;

