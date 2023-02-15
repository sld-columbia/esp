-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_jtag is
  port (
    clk    : in  std_logic;
    clear  : in  std_logic;
    enable : in  std_logic;
    co     : out integer range 0 to 255);
end counter_jtag;

architecture arch of counter_jtag is
begin
  process (clk)
    variable cnt : integer range 0 to 255;
  begin
    if (clk'event and clk = '1') then
      if clear = '1' then
        cnt := 0;
      else
        if enable = '1' then
          cnt := cnt + 1;
        end if;
      end if;
    end if;

    co <= cnt;

  end process;
end arch;

