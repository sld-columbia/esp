-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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

