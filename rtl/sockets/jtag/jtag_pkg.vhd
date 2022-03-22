-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;

package jtag_pkg is

  component demux_1to6
    port(
      data_in : in  std_ulogic;
      sel     : in  std_logic_vector(5 downto 0);
      out1    : out std_ulogic;
      out2    : out std_ulogic;
      out3    : out std_ulogic;
      out4    : out std_ulogic;
      out5    : out std_ulogic;
      out6    : out std_ulogic);
  end component demux_1to6;

  component mux_6to1
    generic (
      sz : integer);
    port (
      sel : in  std_logic_vector(5 downto 0);
      A   : in  std_logic_vector(sz-1 downto 0);
      B   : in  std_logic_vector(sz-1 downto 0);
      C   : in  std_logic_vector(sz-1 downto 0);
      D   : in  std_logic_vector(sz-1 downto 0);
      E   : in  std_logic_vector(sz-1 downto 0);
      F   : in  std_logic_vector(sz-1 downto 0);
      X   : out std_logic_vector(sz-1 downto 0));
  end component mux_6to1;

  component sipo
    generic (
      DIM : integer);
    port (
      rst       : in  std_logic;
      clk       : in  std_ulogic;
      clear     : in  std_ulogic;
      en_in     : in  std_ulogic;
      serial_in : in  std_ulogic;
      test_comp : out std_logic_vector(DIM-3 downto 0);
      data_out  : out std_logic_vector(DIM-6 downto 0);
      op        : out std_ulogic;
      done      : out std_ulogic;
      end_trace : out std_ulogic);
  end component sipo;

  component piso
    generic (
      sz : integer);
    port (
      rst      : in  std_logic;
      clk      : in  std_ulogic;
      clear    : in  std_ulogic;
      load     : in  std_ulogic;
      A        : in  std_logic_vector(sz-1 downto 0);
      B        : out std_logic_vector(sz-1 downto 0);
      shift_en : in  std_ulogic;
      Y        : out std_ulogic;
      done     : out std_ulogic);
  end component piso;

  component jtag_test is
    generic (
      test_if_en : integer range 0 to 1);
    port (
      rst                 : in  std_ulogic;
      refclk              : in  std_ulogic;
      tile_rst            : in  std_ulogic;
      tdi                 : in  std_ulogic;
      tdo                 : out std_ulogic;
      tms                 : in  std_ulogic;
      tclk                : in  std_ulogic;
      noc1_output_port    : in  noc_flit_type;
      noc1_data_void_out  : in  std_ulogic;
      noc1_stop_in        : out std_ulogic;
      noc2_output_port    : in  noc_flit_type;
      noc2_data_void_out  : in  std_ulogic;
      noc2_stop_in        : out std_ulogic;
      noc3_output_port    : in  noc_flit_type;
      noc3_data_void_out  : in  std_ulogic;
      noc3_stop_in        : out std_ulogic;
      noc4_output_port    : in  noc_flit_type;
      noc4_data_void_out  : in  std_ulogic;
      noc4_stop_in        : out std_ulogic;
      noc5_output_port    : in  misc_noc_flit_type;
      noc5_data_void_out  : in  std_ulogic;
      noc5_stop_in        : out std_ulogic;
      noc6_output_port    : in  noc_flit_type;
      noc6_data_void_out  : in  std_ulogic;
      noc6_stop_in        : out std_ulogic;
      test1_output_port   : out noc_flit_type;
      test1_data_void_out : out std_ulogic;
      test1_stop_in       : in  std_ulogic;
      test2_output_port   : out noc_flit_type;
      test2_data_void_out : out std_ulogic;
      test2_stop_in       : in  std_ulogic;
      test3_output_port   : out noc_flit_type;
      test3_data_void_out : out std_ulogic;
      test3_stop_in       : in  std_ulogic;
      test4_output_port   : out noc_flit_type;
      test4_data_void_out : out std_ulogic;
      test4_stop_in       : in  std_ulogic;
      test5_output_port   : out misc_noc_flit_type;
      test5_data_void_out : out std_ulogic;
      test5_stop_in       : in  std_ulogic;
      test6_output_port   : out noc_flit_type;
      test6_data_void_out : out std_ulogic;
      test6_stop_in       : in  std_ulogic;
      test1_input_port    : in  noc_flit_type;
      test1_data_void_in  : in  std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : in  noc_flit_type;
      test2_data_void_in  : in  std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : in  noc_flit_type;
      test3_data_void_in  : in  std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : in  noc_flit_type;
      test4_data_void_in  : in  std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : in  misc_noc_flit_type;
      test5_data_void_in  : in  std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : in  noc_flit_type;
      test6_data_void_in  : in  std_ulogic;
      test6_stop_out      : out std_ulogic;
      noc1_input_port     : out noc_flit_type;
      noc1_data_void_in   : out std_ulogic;
      noc1_stop_out       : in  std_ulogic;
      noc2_input_port     : out noc_flit_type;
      noc2_data_void_in   : out std_ulogic;
      noc2_stop_out       : in  std_ulogic;
      noc3_input_port     : out noc_flit_type;
      noc3_data_void_in   : out std_ulogic;
      noc3_stop_out       : in  std_ulogic;
      noc4_input_port     : out noc_flit_type;
      noc4_data_void_in   : out std_ulogic;
      noc4_stop_out       : in  std_ulogic;
      noc5_input_port     : out misc_noc_flit_type;
      noc5_data_void_in   : out std_ulogic;
      noc5_stop_out       : in  std_ulogic;
      noc6_input_port     : out noc_flit_type;
      noc6_data_void_in   : out std_ulogic;
      noc6_stop_out       : in  std_ulogic);
  end component jtag_test;


end;
