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
-- Entity: 	bwmul
-- File:	bwmul.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Booth-Wallace multipler:
--              Partial products are generated with Booth radix 4 econding,
--              then added thorugh a Carry Save Adder tree composed of (4,2)
--              compressors. Finally a Carry Propagated Adder computes the
--              multiplication result. Round to Nearest is applied.
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.bw.all;
use work.basic.all;

entity bwmul is
  
  port (
    x_ext        : in  std_logic_vector(79 downto 0);
    y_ext        : in  std_logic_vector(79 downto 0);
    clk          : in  std_ulogic;
    rst          : in  std_ulogic;
    p            : out std_logic_vector(159 downto 0));
    
end bwmul;

architecture str of bwmul is

  signal sel : booth4_sel_type;
  signal A   : std_logic_vector(159 downto 0);
  signal Ab  : std_logic_vector(159 downto 0);
  signal A2  : std_logic_vector(159 downto 0);
  signal A2b : std_logic_vector(159 downto 0);
  
  signal add : add160b_in_type;
  signal add_reg : add160b_in_type;
  signal css : std_logic_vector(159 downto 0);  --Carry save S
  signal csc : std_logic_vector(159 downto 0);  --Carry save C
  signal C_reg : std_logic_vector(159 downto 0);  --Carry save S
  signal S_reg : std_logic_vector(159 downto 0);  --Carry save C
  signal res : std_logic_vector(159 downto 0);

  signal dummy : std_ulogic;

  --Usigned booth encoding
  --signal extra_pp : std_logic_vector(79 downto 0);
  --signal add0 : std_logic_vector(159 downto 0);

begin  -- str

  -- Output is not registered here.
  p <= res;

  -- Mul Stage 1: Booth Encoding Radix 4
  booth4_1: booth4
    port map (
      mc  => x_ext,
      mp  => y_ext,
      sel => sel,
      A   => A,
      Ab  => Ab,
      A2  => A2,
      A2b => A2b);

  muxes: for i in 39 downto 0 generate
    pp: process (A,Ab,A2,A2b,sel)
      variable add_var : std_logic_vector(159 downto 0);
    begin  -- process pp
      add_var := (others => '0');
      case sel(i) is
        when "00001" => add_var                 := (others => '0');
        when "00010" => add_var(159 downto 2*i) := A(159-(2*i) downto 0);
        when "00100" => add_var(159 downto 2*i) := A2b(159-(2*i) downto 0);
        when "01000" => add_var(159 downto 2*i) := Ab(159-(2*i) downto 0);
        when "10000" => add_var(159 downto 2*i) := A2(159-(2*i) downto 0);
        when others  => add_var                 := (others => '0');
      end case;

      add(i) <= add_var;
    end process pp;
  end generate muxes;

  --Unsigned booth
  --extra_pp <= add(0)(159 downto 104) + x_ext;
  --add0 <= add(0) when y_ext(79) = '0' else extra_pp & add(0)(79 downto 0);
  
  stage1: process (clk, rst)
  begin  -- process stage1
    if rst = '0' then                   -- asynchronous reset (active low)
      add_reg <= (others => (others => '0'));
    elsif clk'event and clk = '1' then  -- rising clock edge
      add_reg <= add;
      --Unsigned booth encoding
      --add_reg(0) <= add0;
    end if;
  end process stage1;


  -- Mul Stage 2: Carry Save Adder Tree
  add160b_2: add160b
    port map (
      add => add_reg,
      css => css,
      csc => csc);

  stage2: process (clk, rst)
  begin  -- process stage2
    if rst = '0' then                   -- asynchronous reset (active low)
      C_reg <= (others => '0');
      S_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      C_reg <= csc;
      S_reg <= css;
    end if;
  end process stage2;


  -- Mul Stage 3: compute product
  -- Carry Propagate Adder (Parallel Prefix Brent-Kung tree)
  res(0) <= S_reg(0);

  ppadd_1: ppadd
    generic map (
      n    => 159,
      logn => 8)
    port map (
      add0_in   => C_reg(158 downto 0),
      add1_in   => S_reg(159 downto 1),
      carry_in  => '0',
      sum_out   => res(159 downto 1),
      carry_out => dummy);
  
end str;
