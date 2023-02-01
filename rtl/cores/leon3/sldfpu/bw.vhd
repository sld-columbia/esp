-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

package bw is
  
  type compressor42_vec is array (0 to 18) of std_logic_vector(3 downto 0);
  type compressor42_mat is array (0 to 159) of compressor42_vec;

  type csa40op_c_type is array (159 downto 0) of std_logic_vector(0 to 18);
  type csa40op_a_type is array (159 downto 0) of std_logic_vector(39 downto 0);

  type add160b_in_type is array (39 downto 0) of std_logic_vector(159 downto 0);

  type booth4_sel_type is array (39 downto 0) of std_logic_vector(4 downto 0);
  type booth4_window_type is array (0 to 39) of std_logic_vector(2 downto 0);

  component compressor42
    port (
      x  : in  std_logic_vector(3 downto 0);
      ci : in  std_ulogic;
      S  : out std_ulogic;
      C  : out std_ulogic;
      co : out std_ulogic);
  end component;

  component add160b
    port (
      add : in  add160b_in_type;
      css : out std_logic_vector(159 downto 0);
      csc : out std_logic_vector(159 downto 0));
  end component;

  component booth4
    port (
      mc  : in  std_logic_vector(79 downto 0);
      mp  : in  std_logic_vector(79 downto 0);
      sel : out booth4_sel_type;
      A   : out std_logic_vector(159 downto 0);
      Ab  : out std_logic_vector(159 downto 0);
      A2  : out std_logic_vector(159 downto 0);
      A2b : out std_logic_vector(159 downto 0));
  end component;

  component bwmul
    port (
      x_ext  : in  std_logic_vector(79 downto 0);
      y_ext  : in  std_logic_vector(79 downto 0);
      clk    : in  std_ulogic;
      rst    : in  std_ulogic;
      p      : out std_logic_vector(159 downto 0));
  end component;

  component exp_adder
    port (
      clk      : in  std_ulogic;
      rst      : in  std_ulogic;
      sub      : in  std_ulogic;
      sqrt     : in  std_ulogic;
      exp_odd  : in  std_ulogic;
      exp0     : in  std_logic_vector(10 downto 0);
      exp1     : in  std_logic_vector(10 downto 0);
      double   : in  std_ulogic;
      man0_ldz : in  std_logic_vector(5 downto 0);
      man1_ldz : in  std_logic_vector(5 downto 0);
      in0_nstd : in  std_ulogic;
      in1_nstd : in  std_ulogic;
      exp      : out std_logic_vector(10 downto 0);
      expp1    : out std_logic_vector(10 downto 0);
      expm1    : out std_logic_vector(10 downto 0);
      ovf      : out std_ulogic;
      udf      : out std_ulogic;
      nstd_res : out std_ulogic);
  end component;

  component norm
    port (
      clk        : in  std_ulogic;
      rst        : in  std_ulogic;
      exp_in     : in  std_logic_vector(10 downto 0);
      expp1_in   : in  std_logic_vector(10 downto 0);
      expm1_in   : in  std_logic_vector(10 downto 0);
      man_in     : in  std_logic_vector(54 downto 0);
      stickys    : in  std_ulogic;
      stickyd    : in  std_ulogic;
      ovf_in     : in  std_ulogic;
      udf_in     : in  std_ulogic;
      double     : in  std_ulogic;
      sqrt       : in  std_ulogic;
      nstd_in    : in  std_ulogic;
      round      : in  std_logic_vector(1 downto 0);
      double_out : out std_ulogic;
      ovf_out    : out std_ulogic;
      udf_out    : out std_logic;
      nstd_out   : out std_logic;
      exp_out    : out std_logic_vector(10 downto 0);
      man_out    : out std_logic_vector(51 downto 0));
  end component;

  component sgn
    port (
      clk  : in  std_ulogic;
      rst  : in  std_ulogic;
      s0   : in  std_ulogic;
      s1   : in  std_ulogic;
      sign : out std_ulogic);
  end component;

  component sdmu
    port (
      clk      : in  std_ulogic;
      rst      : in  std_ulogic;
      start    : in  std_ulogic;
      opc      : in  std_logic_vector(2 downto 0);
      flush    : in  std_ulogic;
      in0      : in  std_logic_vector(63 downto 0);
      in1      : in  std_logic_vector(63 downto 0);
      man0_ldz : in  std_logic_vector(5 downto 0);
      man1_ldz : in  std_logic_vector(5 downto 0);
      in0_zero : in  std_ulogic;
      in1_zero : in  std_ulogic;
      in0_nstd : in  std_ulogic;
      in1_nstd : in  std_ulogic;
      in0_inf  : in  std_ulogic;
      in1_inf  : in  std_ulogic;
      in0_NaN  : in  std_ulogic;
      in1_NaN  : in  std_ulogic;
      in0_SNaN : in  std_ulogic;
      in1_SNaN : in  std_ulogic;
      round    : in  std_logic_vector(1 downto 0);
      result   : out std_logic_vector(63 downto 0);
      flags    : out std_logic_vector(5 downto 0)); 
  end component;
  
end bw;
