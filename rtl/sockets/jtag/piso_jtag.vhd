-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piso_jtag is
  generic (
    sz        : integer;
    shift_dir : integer := 0);
  port (
    rst      : in  std_logic;
    clk      : in  std_logic;
    clear    : in  std_logic;
    load     : in  std_logic;
    A        : in  std_logic_vector(sz-1 downto 0);
    shift_en : in  std_logic;
    Y        : out std_logic;
    done     : out std_logic);
end piso_jtag;

architecture arch of piso_jtag is

  signal sr     : std_logic_vector(sz downto 0);
  constant ZERO : std_logic_vector(sz-1 downto 0) := (others => '0');
  constant D    : std_logic_vector(sz downto 0)   := '1' & ZERO;

begin


  process (clk, rst)
  begin
    if rst = '0' then
      sr <= (others => '0');
    elsif clk'event and clk = '1' then
      if clear = '1' then
        sr <= (others => '0');
      elsif load = '1' then
        if shift_dir = 0 then
          sr <= A & '1';
        else
          sr <= '0' & A;
        end if;
      elsif shift_en = '1' then
        if shift_dir = 0 then
          sr <= sr(sz-1 downto 0) & '0';
        else
          sr <= '0' & sr(sz downto 1);
        end if;
      end if;
    end if;
  end process;

  process(sr)
  begin
    if shift_dir = 0 then
      Y <= sr(sz);
    else
      Y <= sr(0);
    end if;
  end process;

  done <= '1' when sr = D else '0';
end arch;
