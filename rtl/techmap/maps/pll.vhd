-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;
use work.gencomp.all;
use work.allclkgen.all;
use work.allpll.all;

entity pll is
  generic (tech : integer := virtex7);
  port (
    plllock   : out std_ulogic;
    pllouta   : out std_ulogic;
    reset     : in  std_ulogic;
    divchange : in  std_ulogic;
    rangea    : in  std_logic_vector(4 downto 0);
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    stopclka  : in  std_ulogic;
    framestop : in  std_ulogic;
    locksel   : in  std_ulogic;
    lftune    : in  std_logic_vector(40 downto 0);
    startup   : in  std_logic_vector(1 downto 0);
    locktune  : in  std_logic_vector(4 downto 0);
    vergtune  : in  std_logic_vector(2 downto 0));

end pll;

architecture rtl of pll is

  signal dvfs_clk0   : std_ulogic;
  signal dvfs_clk1   : std_ulogic;
  signal dvfs_clk2   : std_ulogic;
  signal dvfs_clk3   : std_ulogic;

  signal clk01, clk23 : std_ulogic;
  signal sel : std_logic_vector(2 downto 0);

  attribute keep : string;
  attribute keep of dvfs_clk0 : signal is "true";
  attribute keep of dvfs_clk1 : signal is "true";
  attribute keep of dvfs_clk2 : signal is "true";
  attribute keep of dvfs_clk3 : signal is "true";

begin  -- rtl

  xcv : if (tech = virtex7) generate
    select_clock: process (rangea)
    begin  -- process select_clock
      sel <= (others => '0');           --clk0 is default
      if rangea = "01000" then
        -- 100 MHz
        sel <= "000";
      elsif rangea = "00100" then
        -- 88.8 MHz
        sel <= "001";
      elsif rangea = "00010" then
        -- 80 MHz
        sel <= "010";
      elsif rangea = "00001" then
        -- 61.5 MHz
        sel <= "011";
      else
        -- 100 MHz (default)
        sel <= "000";
      end if;
    end process select_clock;

    pll_virtex7_1: pll_virtex7
      generic map (
        clk_mul    => 16,
        clk0_div   => 16,               --100MHz
        clk1_div   => 18,               --88.8MHz
        clk2_div   => 20,               --80.0MHz
        clk3_div   => 26,               --61.5MHz
        clk4_div   => 48,               --33.3MHz
        clk5_div   => 64,               --25MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 100000)
      port map (
        clk    => refclk,
        rst    => reset,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => open,
        dvfs_clk5   => open,
        locked => plllock);

    clk01 <= dvfs_clk0 when sel(0) = '0' else dvfs_clk1;
    clk23 <= dvfs_clk2 when sel(0) = '0' else dvfs_clk3;
    clkmux_3 : clkmuxctrl_unisim
      port map (
        clk01, clk23, sel(1), pllouta);

  end generate;


  xcvu : if (tech = virtexu) generate
    select_clock: process (rangea)
    begin  -- process select_clock
      sel <= (others => '0');           --clk0 is default
      if rangea = "01000" then
        -- 100 MHz
        sel <= "000";
      elsif rangea = "00100" then
        -- 88.8 MHz
        sel <= "001";
      elsif rangea = "00010" then
        -- 80 MHz
        sel <= "010";
      elsif rangea = "00001" then
        -- 61.5 MHz
        sel <= "011";
      else
        -- 100 MHz (default)
        sel <= "000";
      end if;
    end process select_clock;

    pll_virtexu_1: pll_virtexu
      generic map (
        clk_mul    => 16,
        clk0_div   => 16,               --100MHz
        clk1_div   => 18,               --88.8MHz
        clk2_div   => 20,               --80.0MHz
        clk3_div   => 26,               --61.5MHz
        clk4_div   => 48,               --33.3MHz
        clk5_div   => 64,               --25MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 100000)
      port map (
        clk    => refclk,
        rst    => reset,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => open,
        dvfs_clk5   => open,
        locked => plllock);

    clk01 <= dvfs_clk0 when sel(0) = '0' else dvfs_clk1;
    clk23 <= dvfs_clk2 when sel(0) = '0' else dvfs_clk3;
    clkmux_3 : clkmuxctrl_unisim
      port map (
        clk01, clk23, sel(1), pllouta);

  end generate;


  xcvup : if (tech = virtexup) generate
    select_clock: process (rangea)
    begin  -- process select_clock
      sel <= (others => '0');           --clk0 is default
      if rangea = "01000" then
        -- 100 MHz
        sel <= "000";
      elsif rangea = "00100" then
        -- 88.8 MHz
        sel <= "001";
      elsif rangea = "00010" then
        -- 80 MHz
        sel <= "010";
      elsif rangea = "00001" then
        -- 61.5 MHz
        sel <= "011";
      else
        -- 100 MHz (default)
        sel <= "000";
      end if;
    end process select_clock;

    pll_virtexup_1: pll_virtexup
      generic map (
        clk_mul    => 16,
        clk0_div   => 16,               --100MHz
        clk1_div   => 18,               --88.8MHz
        clk2_div   => 20,               --80.0MHz
        clk3_div   => 26,               --61.5MHz
        clk4_div   => 48,               --33.3MHz
        clk5_div   => 64,               --25MHz
        clk0_phase => 0.0,
        clk1_phase => 0.0,
        clk2_phase => 0.0,
        clk3_phase => 0.0,
        clk4_phase => 0.0,
        clk5_phase => 0.0,
        freq       => 100000)
      port map (
        clk    => refclk,
        rst    => reset,
        dvfs_clk0   => dvfs_clk0,
        dvfs_clk1   => dvfs_clk1,
        dvfs_clk2   => dvfs_clk2,
        dvfs_clk3   => dvfs_clk3,
        dvfs_clk4   => open,
        dvfs_clk5   => open,
        locked => plllock);

    clk01 <= dvfs_clk0 when sel(0) = '0' else dvfs_clk1;
    clk23 <= dvfs_clk2 when sel(0) = '0' else dvfs_clk3;
    clkmux_3 : clkmuxctrl_unisim
      port map (
        clk01, clk23, sel(1), pllouta);

  end generate;

-- pragma translate_off
  noram : if has_pll(tech) = 0 generate
    x : process
    begin
      assert false report "pll: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end rtl;
