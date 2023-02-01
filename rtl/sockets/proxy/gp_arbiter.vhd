-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity gp_arbiter is

  generic (
    log2n : integer range 0 to 4 := 2);

  port (
    clk         : in  std_ulogic;
    rst         : in  std_ulogic;
    req_i       : in  std_logic_vector(2**log2n - 1 downto 0);
    req_valid_i : in  std_ulogic;
    gnt_o       : out std_logic_vector(2**log2n - 1 downto 0);
    priority_o  : out std_logic_vector(log2n - 1 downto 0));

end entity gp_arbiter;


architecture rtl of gp_arbiter is

  constant zero : std_logic_vector(2**log2n - 1 downto 0) := (others => '0');

  signal last_gnt    : std_logic_vector(2**log2n - 1 downto 0);
  signal default_gnt : std_logic_vector(2**log2n - 1 downto 0);
  signal mask        : std_logic_vector(2**log2n - 1 downto 0);
  signal masked_req  : std_logic_vector(2**log2n - 1 downto 0);

  -- Output both 1-hot (gnd) and binary (priority)
  signal gnt      : std_logic_vector(2**log2n - 1 downto 0);
  signal priority : std_logic_vector(log2n - 1 downto 0);

begin  -- architecture rtl

  -- Output
  gnt_o      <= gnt;
  priority_o <= priority;

  -- Arbitration
  -- Default highest priority to the first request bit set
  default_gnt <= req_i and (not(req_i) + 1);
  -- Highest priority to last_gnt << 1 (last_priority + 1)
  mask        <= last_gnt or (last_gnt - 1);
  masked_req  <= req_i and mask;
  gnt         <= default_gnt when masked_req = zero else
                 masked_req and (not(masked_req) + 1);

  arbiter_state : process (clk, rst) is
  begin  -- process arbiter_state
    if rst = '0' then                   -- asynchronous reset (active low)
      last_gnt <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if req_i /= zero and req_valid_i = '1' then
        last_gnt <= gnt;
      end if;
    end if;
  end process arbiter_state;

  -- Priority encoder
  priority_enc : process (gnt) is
    variable gnt_extended      : std_logic_vector(15 downto 0);
    variable priority_extended : std_logic_vector(3 downto 0);
  begin  -- process priority_enc
    gnt_extended                        := (others => '0');
    gnt_extended(2**log2n - 1 downto 0) := gnt;

    case gnt_extended is
      when X"0002" => priority_extended := "0001";
      when X"0004" => priority_extended := "0010";
      when X"0008" => priority_extended := "0011";
      when X"0010" => priority_extended := "0100";
      when X"0020" => priority_extended := "0101";
      when X"0040" => priority_extended := "0110";
      when X"0080" => priority_extended := "0111";
      when X"0100" => priority_extended := "1000";
      when X"0200" => priority_extended := "1001";
      when X"0400" => priority_extended := "1010";
      when X"0800" => priority_extended := "1011";
      when X"1000" => priority_extended := "1100";
      when X"2000" => priority_extended := "1101";
      when X"4000" => priority_extended := "1110";
      when X"8000" => priority_extended := "1111";
      when others  => priority_extended := "0000";
    end case;

    priority <= priority_extended(log2n - 1 downto 0);

  end process priority_enc;

end architecture rtl;
