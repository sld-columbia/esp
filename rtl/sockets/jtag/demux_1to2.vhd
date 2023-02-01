-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;

entity demux_1to2 is
  port(
    data_in    : in  std_logic;
    sel        : in  std_logic_vector(1 downto 0);
    out1, out2 : out std_logic);
end demux_1to2;

architecture arch of demux_1to2 is
begin
  process(data_in, sel)
  begin
    out2 <= '0';
    out1 <= '0';
    case sel is
      when "10" =>
        out1 <= data_in;
      when "01" =>
        out2 <= data_in;
      when others =>
        null;
    end case;
  end process;
end arch;
