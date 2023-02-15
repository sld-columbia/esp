-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;

package allpll is

  component pll_virtex7
    generic (
      clk_mul    : integer;
      clk0_div   : integer;
      clk1_div   : integer;
      clk2_div   : integer;
      clk3_div   : integer;
      clk4_div   : integer;
      clk5_div   : integer;
      clk0_phase : real;
      clk1_phase : real;
      clk2_phase : real;
      clk3_phase : real;
      clk4_phase : real;
      clk5_phase : real;
      freq       : integer);
    port (
      clk    : in  std_ulogic;
      rst    : in  std_ulogic;
      dvfs_clk0   : out std_ulogic;
      dvfs_clk1   : out std_ulogic;
      dvfs_clk2   : out std_ulogic;
      dvfs_clk3   : out std_ulogic;
      dvfs_clk4   : out std_ulogic;
      dvfs_clk5   : out std_ulogic;
      locked : out std_ulogic);
  end component;

  component pll_virtexu is
    generic (
      clk_mul    : integer;
      clk0_div   : integer;
      clk1_div   : integer;
      clk2_div   : integer;
      clk3_div   : integer;
      clk4_div   : integer;
      clk5_div   : integer;
      clk0_phase : real;
      clk1_phase : real;
      clk2_phase : real;
      clk3_phase : real;
      clk4_phase : real;
      clk5_phase : real;
      freq       : integer);
    port (
      clk       : in  std_ulogic;
      rst       : in  std_ulogic;
      dvfs_clk0 : out std_ulogic;
      dvfs_clk1 : out std_ulogic;
      dvfs_clk2 : out std_ulogic;
      dvfs_clk3 : out std_ulogic;
      dvfs_clk4 : out std_ulogic;
      dvfs_clk5 : out std_ulogic;
      locked    : out std_ulogic);
  end component pll_virtexu;

  component pll_virtexup is
    generic (
      clk_mul    : integer;
      clk0_div   : integer;
      clk1_div   : integer;
      clk2_div   : integer;
      clk3_div   : integer;
      clk4_div   : integer;
      clk5_div   : integer;
      clk0_phase : real;
      clk1_phase : real;
      clk2_phase : real;
      clk3_phase : real;
      clk4_phase : real;
      clk5_phase : real;
      freq       : integer);
    port (
      clk       : in  std_ulogic;
      rst       : in  std_ulogic;
      dvfs_clk0 : out std_ulogic;
      dvfs_clk1 : out std_ulogic;
      dvfs_clk2 : out std_ulogic;
      dvfs_clk3 : out std_ulogic;
      dvfs_clk4 : out std_ulogic;
      dvfs_clk5 : out std_ulogic;
      locked    : out std_ulogic);
  end component pll_virtexup;

end allpll;
