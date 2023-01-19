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
use work.tb_pkg.all;

entity tb_iolink is
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
end entity tb_iolink;

architecture rtl of tb_iolink is

  signal valid_out      : std_ulogic;
  signal data_out       : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal word, exp_word : std_logic_vector(31 downto 0);

begin

  -- pragma translate_off
  iolink_valid_out_int <= valid_out;
  iolink_data_out_int  <= data_out;

  ---------------------------------------------------------------------------
  -- Basic testbench for ESP SoC using IOLink
  ---------------------------------------------------------------------------
  test_iolink : process

    file bootloader : text open read_mode is "../soft-build/ariane/prom.txt";
    file program    : text open read_mode is "../soft-build/ariane/systest.txt";

    variable text_word, text_data : line;
    variable word_var             : std_logic_vector(31 downto 0);
    variable ok                   : boolean;
    variable credit_to_clear      : boolean;
    variable credit_to_set        : boolean;
    variable program_length       : integer;
    variable data, tmp            : integer;

  begin

    valid_out             <= '0';
    iolink_data_oen       <= '1';
    iolink_credit_out_int <= '0';

    wait for 10 ns;
    wait until reset = '0';
    wait for 20000 ns;

    -- TEST of CSR Read through IOLink; uncomment to run
    -- send address
    --word <= X"000000006009078D";
    --snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    --word <= X"0000000000000001";
    --snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

    --word <= X"0000000000014085";
    --snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

    --iolink_data_oen <= '0';

    --while true loop
    --  wait until rising_edge(iolink_clk_in_int);
    --  if iolink_valid_in_int = '1' then
    --    word(15 downto 0) <= iolink_data_in_int;
    --    exit;
    --  end if;
    --end loop;

    --while true loop
    --  wait until rising_edge(iolink_clk_in_int);
    --    if iolink_valid_in_int = '1' then
    --    word(31 downto 16) <= iolink_data_in_int;
    --    exit;
    --  end if;
    --end loop;

    --while true loop
    --  wait until rising_edge(iolink_clk_in_int);
    --    if iolink_valid_in_int = '1' then
    --    word(47 downto 32) <= iolink_data_in_int;
    --    exit;
    --  end if;
    --end loop;

    --while true loop
    --  wait until rising_edge(iolink_clk_in_int);
    --    if iolink_valid_in_int = '1' then
    --    word(63 downto 48) <= iolink_data_in_int;
    --    exit;
    --  end if;
    --end loop;

    --wait until rising_edge(iolink_clk_out_int);
    --iolink_credit_out_int <= '1';
    --wait until rising_edge(iolink_clk_out_int);
    --iolink_credit_out_int <= '0';
    --iolink_data_oen       <= '1';

    --wait for 0.2 ns;

    --report "word: " & integer'image(to_integer(unsigned(word)));


    ---------------------------------------------------------------------------
    -- send first 2 soft resets
    ---------------------------------------------------------------------------
    for i in 0 to 1 loop
      -- send address
      word <= X"60000401";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      wait for 100000 ns;
    end loop;  -- i

    ---------------------------------------------------------------------------
    -- Send bootloader binary
    ---------------------------------------------------------------------------
    -- send address
    word <= X"00010001";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    readline(bootloader, text_word);
    hread(text_word, word_var, ok);
    word <= word_var;
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send data
    while not endfile(bootloader) loop
      readline(bootloader, text_word);
      hread(text_word, word_var, ok);
      word <= word_var;
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    end loop;

    ---------------------------------------------------------------------------
    -- Send program binary
    ---------------------------------------------------------------------------
    -- send address
    --word           <= X"0000000080000001";
    --snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    --readline(program, text_word);
    --hread(text_word, word_var, ok);
    --program_length := to_integer(unsigned(word_var));
    --word           <= word_var + X"3e8";  -- add 0s at the end of the prorgam (TODO is it needed?)
    --snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send data
    --while not endfile(program) loop
    --  readline(program, text_word);
    --  hread(text_word, word_var, ok);
    --  word <= word_var;
    --  snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    --end loop;
    --word <= X"0000000000000000";  -- add 0s at the end of the prorgam (TODO is it needed?)
    --for i in 0 to 999 loop
    --  snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    --end loop;


    ---------------------------------------------------------------------------
    -- Send last 2 soft resets
    ---------------------------------------------------------------------------
    for i in 0 to 1 loop
      -- send address
      word <= X"60000401";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      wait for 100000 ns;
    end loop;  -- i
  end process;
  -- pragma translate_on

end architecture rtl;
