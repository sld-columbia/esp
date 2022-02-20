-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sipo is
  generic (DIM : integer);
  port(
    rst       : in  std_logic;
    clk       : in  std_logic;
    clear     : in  std_logic;
    en_in     : in  std_logic;
    serial_in : in  std_logic;
    test_comp : out std_logic_vector(DIM-1 downto 0);
    data_out  : out std_logic_vector(DIM-10 downto 0);
    op        : out std_logic;
    done      : out std_logic;
    end_trace : out std_logic);
end sipo;


architecture arch of sipo is
  signal q      : std_logic_vector(DIM-1 downto 0);
  signal data   : std_logic_vector(DIM-10 downto 0);
  signal source : std_logic_vector(5 downto 0);

  signal end_trace_i  : std_ulogic;

begin

  process(clk, rst)
  begin
    if rst = '0' then
      q <= (others => '0');
      end_trace <= '0';
    elsif clk'event and clk = '1' then
      if clear = '1' then
        q <= (others => '0');
      elsif en_in = '1' then
        q(DIM-2 downto 0) <= q(DIM-1 downto 1);
        q(DIM-1)          <= serial_in;
      end if;

      if end_trace_i = '1' then
        end_trace <= '1';
      end if;

    end if;
  end process;

  end_trace_i <= '0' when source /= "111111" else q(0);

  source    <= q(8 downto 3);
  done      <= q(0);
  op        <= q(1);
  test_comp <= q(DIM-1 downto 0);
  data      <= q(DIM-1 downto 9);
  data_out  <= data;
end;
