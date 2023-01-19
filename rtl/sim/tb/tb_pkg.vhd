-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.stdlib.all;
-- pragma translate_off
use work.sim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on

package tb_pkg is

  component tb_iolink is
    port (
      reset                 : in  std_ulogic;
      iolink_clk_in_int     : in  std_ulogic;
      iolink_valid_in_int   : in  std_ulogic;
      iolink_data_in_int    : in  std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_clk_out_int    : in  std_ulogic;
      iolink_credit_out_int : out std_ulogic;
      iolink_valid_out_int  : out std_ulogic;
      iolink_data_out_int   : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_data_oen       : out std_ulogic);
  end component tb_iolink;

  procedure snd_flit_iolink (
    signal clk   : in  std_ulogic;
    signal word  : in  std_logic_vector(31 downto 0);
    signal valid : out std_ulogic;
    signal data  : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0));

end package tb_pkg;

package body tb_pkg is

  procedure snd_flit_iolink (
    signal clk   : in  std_ulogic;
    signal word  : in  std_logic_vector(31 downto 0);
    signal valid : out std_ulogic;
    signal data  : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0)) is
  begin

    wait until rising_edge(clk);
    valid <= '1';
    data  <= word(15 downto 0);
    wait until rising_edge(clk);
    valid <= '1';
    data  <= word(31 downto 16);
    wait until rising_edge(clk);
    valid <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);

  end procedure snd_flit_iolink;

end package body tb_pkg;
