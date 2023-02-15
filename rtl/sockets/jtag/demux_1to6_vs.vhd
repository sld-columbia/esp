-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;

entity demux_1to6_vs is
  generic (
    SZ : integer);
  port(
    data_in                            : in  std_logic_vector(SZ-1 downto 0);
    sel                                : in  std_logic_vector(5 downto 0);
    out1, out2, out3, out4, out5, out6 : out std_logic_vector(SZ-1 downto 0));
end demux_1to6_vs;

architecture arch of demux_1to6_vs is
begin
  process(data_in, sel)
  begin
    out1 <= (others => '0');
    out2 <= (others => '0');
    out3 <= (others => '0');
    out4 <= (others => '0');
    out5 <= (others => '0');
    out6 <= (others => '0');

    case sel is
      when "100000" =>
        out6 <= data_in;
      when "010000" =>
        out5 <= data_in;
      when "001000" =>
        out4 <= data_in;
      when "000100" =>
        out3 <= data_in;
      when "000010" =>
        out2 <= data_in;
      when "000001" =>
        out1 <= data_in;
      when others =>
        null;
    end case;
  end process;
end arch;
