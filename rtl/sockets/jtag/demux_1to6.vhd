-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;

entity demux_1to6 is
  port(
    data_in                            : in  std_logic;
    sel                                : in  std_logic_vector(5 downto 0);
    out1, out2, out3, out4, out5, out6 : out std_logic);
end demux_1to6;

architecture arch of demux_1to6 is
begin
  process(data_in, sel)
  begin
    out6 <= '0';
    out5 <= '0';
    out4 <= '0';
    out3 <= '0';
    out2 <= '0';
    out1 <= '0';
    case sel is
      when "100000" =>
        out1 <= data_in;
      when "010000" =>
        out2 <= data_in;
      when "001000" =>
        out3 <= data_in;
      when "000100"=>
        out4 <= data_in;
      when "000010"=>
        out5 <= data_in;
      when "000001"=>
        out6 <= data_in;
      when others =>
        null;
    end case;
  end process;
end arch;
