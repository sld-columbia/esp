-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

package itsqrdiv is

  type divfsm is (idle, div1, div2, div3, div4, div5, div6, div7, div8, div9, div10, div11, div12, div13, div14, div15,
                  sqrt1, sqrt2, sqrt3, sqrt4, sqrt5, sqrt6, sqrt7, sqrt8, sqrt9, sqrt10, sqrt11, sqrt12,
                  sqrt13, sqrt14, sqrt15, sqrt16, sqrt17, sqrt18, sqrt19, sqrt20, sqrt21, sqrt22, sqrt23,
                  sqrt24);

  component divlut
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(9 downto 0));
  end component;

  component sqrtlut
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(9 downto 0));
  end component;

  component sqrtlut2
    port (
      addr    : in  std_logic_vector(5 downto 0);
      romdata : out std_logic_vector(19 downto 0));
  end component;

  component exp_adder_div
    port (
      clk       : in  std_ulogic;
      rst       : in  std_ulogic;
      exp       : in  std_logic_vector(10 downto 0);
      expp1     : in  std_logic_vector(10 downto 0);
      q_exp_inc : in  std_logic_vector(10 downto 0);
      ovf_in    : in  std_ulogic;
      udf_in    : in  std_ulogic;
      nstd_in   : in  std_ulogic;
      double    : in  std_ulogic;
      exp_div   : out std_logic_vector(10 downto 0);
      expp1_div : out std_logic_vector(10 downto 0);
      ovf_div   : out std_ulogic;
      udf_div   : out std_ulogic;
      nstd_div  : out std_ulogic);
  end component;

end itsqrdiv;
