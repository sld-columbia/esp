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

entity tb_cryoai is
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
end entity tb_cryoai;

architecture rtl of tb_cryoai is

  signal valid_out      : std_ulogic;
  signal data_out       : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal word, exp_word : std_logic_vector(31 downto 0);

begin

  -- pragma translate_off
  iolink_valid_out_int <= valid_out;
  iolink_data_out_int  <= data_out;

  ---------------------------------------------------------------------------
  -- Cryo-AI test for ad03_cxx_catapult accelerator
  ---------------------------------------------------------------------------
  test_cryoai : process

    file bootloader : text open read_mode is "../soft-build/ibex/prom.txt";
    file program    : text open read_mode is "../soft-build/ibex/baremetal/ad03_cxx_catapult.txt";
    file in_data    : text open read_mode is "../ad03_cxx_catapult_in.txt";
    file out_data   : text open read_mode is "../ad03_cxx_catapult_out.txt";
    file exp_data   : text open read_mode is "../ad03_cxx_catapult_exp.txt";

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
      wait for 80000 ns;
    end loop;  -- i

    ---------------------------------------------------------------------------
    -- Send bootloader binary
    ---------------------------------------------------------------------------
    -- send address
    word <= X"00000081";
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
    word           <= X"80000001";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    readline(program, text_word);
    hread(text_word, word_var, ok);
    program_length := to_integer(unsigned(word_var));
    word           <= word_var + X"3e8";  -- add 0s at the end of the prorgam (TODO is it needed?)
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send data
    while not endfile(program) loop
      readline(program, text_word);
      hread(text_word, word_var, ok);
      word <= word_var;
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    end loop;
    word <= X"00000000";  -- add 0s at the end of the prorgam (TODO is it needed?)
    for i in 0 to 999 loop
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    end loop;

    -- ---------------------------------------------------------------------------
    -- -- Initialize input/output data handshakes
    -- ---------------------------------------------------------------------------
    -- TO DO. For now for the handshakes we are reusing the CSRs 0 and 6 of the
    -- IO tile, as they are unused. This can be improved.

    -- send address
    word <= X"60090381";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    word <= X"00000001";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send data
    word <= X"00000000";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

    -- send address
    word <= X"60090399";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send length
    word <= X"00000001";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
    -- send data
    word <= X"00000000";
    snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

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
      wait for 80000 ns;
    end loop;  -- i

    ---------------------------------------------------------------------------
    -- Accelerator execution
    ---------------------------------------------------------------------------
    for i in 0 to 1 loop
      -------------------------------------------------------------------------
      -- Send accelerator inputs
      -------------------------------------------------------------------------
      -- send address
      word <= X"80020bb1";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000020";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      for j in 0 to 31 loop
        readline(in_data, text_word);
        read(text_word, data, ok);
        word(31 downto 24) <= std_logic_vector(to_signed(data, 8));
        readline(in_data, text_word);
        read(text_word, data, ok);
        word(23 downto 16) <= std_logic_vector(to_signed(data, 8));
        readline(in_data, text_word);
        read(text_word, data, ok);
        word(15 downto 8)  <= std_logic_vector(to_signed(data, 8));
        readline(in_data, text_word);
        read(text_word, data, ok);
        word(7 downto 0)   <= std_logic_vector(to_signed(data, 8));

        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      end loop;  -- j

      -------------------------------------------------------------------------
      -- Send accelerator expected outputs
      -------------------------------------------------------------------------
      -- send address
      word <= X"80020b21";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000020";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      for j in 0 to 31 loop
        readline(out_data, text_word);
        read(text_word, data, ok);
        word(31 downto 24) <= std_logic_vector(to_signed(data, 8));
        readline(out_data, text_word);
        read(text_word, data, ok);
        word(23 downto 16) <= std_logic_vector(to_signed(data, 8));
        readline(out_data, text_word);
        read(text_word, data, ok);
        word(15 downto 8)  <= std_logic_vector(to_signed(data, 8));
        readline(out_data, text_word);
        read(text_word, data, ok);
        word(7 downto 0)   <= std_logic_vector(to_signed(data, 8));

        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      end loop;  -- j

      -------------------------------------------------------------------------
      -- Wait for reset of output data handshake
      -------------------------------------------------------------------------
      while true loop
        -- send address
        word <= X"60090398";
        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
        -- send length
        word <= X"00000001";
        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

        iolink_data_oen <= '0';

        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if iolink_valid_in_int = '1' then
            word(15 downto 0) <= iolink_data_in_int;
            exit;
          end if;
        end loop;
        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if iolink_valid_in_int = '1' then
            exit;
          end if;
        end loop;

        wait until rising_edge(iolink_clk_out_int);
        iolink_credit_out_int <= '1';
        wait until rising_edge(iolink_clk_out_int);
        iolink_credit_out_int <= '0';

        iolink_data_oen <= '1';

        if word(15 downto 0) = X"0000" then
          exit;
        end if;

        for j in 0 to 31 loop
          wait until rising_edge(iolink_clk_in_int);
        end loop;
      end loop;

      -------------------------------------------------------------------------
      -- Set input data handshake
      -------------------------------------------------------------------------
      -- send address
      word <= X"60090381";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

      -------------------------------------------------------------------------
      -- Wait for output data handshake
      -------------------------------------------------------------------------
      while true loop
        -- send addressess
        word <= X"60090398";
        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
        -- send length
        word <= X"00000001";
        snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

        iolink_data_oen <= '0';
        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if iolink_valid_in_int = '1' then
            word(15 downto 0) <= iolink_data_in_int;
            exit;
          end if;
        end loop;
        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if iolink_valid_in_int = '1' then
            exit;
          end if;
        end loop;

        wait until rising_edge(iolink_clk_out_int);
        iolink_credit_out_int <= '1';
        wait until rising_edge(iolink_clk_out_int);
        iolink_credit_out_int <= '0';

        iolink_data_oen <= '1';

        if word(15 downto 0) = X"0001" then
          exit;
        end if;

        for j in 0 to 31 loop
          wait until rising_edge(iolink_clk_in_int);
        end loop;
      end loop;

      -------------------------------------------------------------------------
      -- Read output data
      -------------------------------------------------------------------------
      -- send address
      word <= X"80020c30";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000020";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

      iolink_data_oen <= '0';

      credit_to_clear := false;
      credit_to_set   := true;

      -- send data
      for j in 0 to 31 loop
        readline(exp_data, text_word);
        read(text_word, data, ok);
        exp_word(31 downto 24) <= std_logic_vector(to_signed(data, 8));
        readline(exp_data, text_word);
        read(text_word, data, ok);
        exp_word(23 downto 16) <= std_logic_vector(to_signed(data, 8));
        readline(exp_data, text_word);
        read(text_word, data, ok);
        exp_word(15 downto 8)  <= std_logic_vector(to_signed(data, 8));
        readline(exp_data, text_word);
        read(text_word, data, ok);
        exp_word(7 downto 0)   <= std_logic_vector(to_signed(data, 8));

        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if credit_to_clear = true then
            iolink_credit_out_int <= '0';
          end if;
          if j /= 0 and credit_to_set = true then
            iolink_credit_out_int <= '1';
            credit_to_clear       := true;
            credit_to_set         := false;
          end if;
          if iolink_valid_in_int = '1' then
            word(15 downto 0) <= iolink_data_in_int;
            exit;
          end if;
        end loop;
        while true loop
          wait until rising_edge(iolink_clk_in_int);
          if iolink_valid_in_int = '1' then
            word(31 downto 16) <= iolink_data_in_int;
            credit_to_set      := true;
            exit;
          end if;
        end loop;

        wait for 0.2 ns;

        if word /= exp_word then
          tmp := to_integer(unsigned(word));
          report "Wrong output word: " & integer'image(tmp);
          tmp := to_integer(unsigned(exp_word));
          report "Wrong output exp_word: " & integer'image(tmp);
        end if;

      end loop;  -- j

      wait until rising_edge(iolink_clk_out_int);
      iolink_credit_out_int <= '1';
      wait until rising_edge(iolink_clk_out_int);
      iolink_credit_out_int <= '0';
      iolink_data_oen       <= '1';

      -------------------------------------------------------------------------
      -- Reset input data handshake
      -------------------------------------------------------------------------
      -- send address
      word <= X"60090381";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send length
      word <= X"00000001";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);
      -- send data
      word <= X"00000000";
      snd_flit_iolink(iolink_clk_out_int, word, valid_out, data_out);

    end loop;  -- i

    while true loop
      wait until rising_edge(iolink_valid_in_int);
    end loop;

  end process;
  -- pragma translate_on

end architecture rtl;
