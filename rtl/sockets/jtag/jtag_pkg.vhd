-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;
use work.amba.all;

package jtag_pkg is

  component jtag_tb
    port (
      ahbsi : out ahb_slv_in_type;
      ahbso : in  ahb_slv_out_type);
  end component jtag_tb;

  component demux_1to6
    port (
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

  component sipo_jtag
    generic (
      DIM       : integer;
      en_mo     : integer := 0;
      shift_dir : integer := 0
      );
    port (
      rst       : in  std_logic;
      clk       : in  std_ulogic;
      clear     : in  std_ulogic;
      en_in     : in  std_logic;
      serial_in : in  std_ulogic;
      test_comp : out std_logic_vector(DIM-1 downto 0);
      data_out  : out std_logic_vector(DIM-10 downto 0);
      op        : out std_ulogic;
      done      : out std_ulogic;
      end_trace : out std_ulogic);
  end component sipo_jtag;

  component sipo0
    generic (DIM : integer);
    port(
      rst       : in  std_logic;
      clk       : in  std_logic;
      clear     : in  std_logic;
      en_in     : in  std_logic;
      serial_in : in  std_logic;
      data_out  : out std_logic_vector(DIM-1 downto 0));
  end component sipo0;

  component sipo1
    generic (DIM : integer);
    port(
      rst       : in  std_logic;
      clk       : in  std_logic;
      clear     : in  std_logic;
      en_in     : in  std_logic;
      serial_in : in  std_logic;
      data_out  : out std_logic_vector(DIM-1 downto 0));
  end component sipo1;

  component piso_jtag
    generic (
      sz        : integer;
      shift_dir : integer := 0);
    port (
      rst      : in  std_logic;
      clk      : in  std_ulogic;
      clear    : in  std_ulogic;
      load     : in  std_ulogic;
      A        : in  std_logic_vector(sz-1 downto 0);
      shift_en : in  std_ulogic;
      Y        : out std_ulogic;
      done     : out std_ulogic);
  end component piso_jtag;

  component piso0
    generic (
      sz : integer);
    port (
      rst      : in  std_logic;
      clk      : in  std_logic;
      clear    : in  std_logic;
      load     : in  std_logic;
      A        : in  std_logic_vector(sz-1 downto 0);
      shift_en : in  std_logic;
      Y        : out std_logic);
  end component piso0;

  component apb2jtag_reg
    generic (
      pindex : integer range 0 to 1);
    port(
      clk     : in  std_logic;
      rstn    : in  std_logic;
      pconfig : in  apb_config_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      ack_w   : in  std_logic_vector(5 downto 0);
      ack2apb : out std_logic;
      apbreq  : in  std_logic;
      valid   : out std_logic_vector(5 downto 0);
      out_p   : out std_logic_vector(74 downto 0));
  end component apb2jtag_reg;

  component jtag2apb_reg
    generic (
      pindex : integer range 0 to 1);
    port(
      clk     : in  std_logic;
      rstn    : in  std_logic;
      pconfig : in  apb_config_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      fifo_c  : in  std_logic_vector(5 downto 0);
      req     : out std_logic_vector(5 downto 0);
      ack2apb : out std_logic;
      apbreq  : in  std_logic;
      in_p    : in  std_logic_vector(3*32-1 downto 0));
  end component jtag2apb_reg;

  component jtag2apb
    port (
      rst     : in  std_ulogic;
      tclk    : in  std_logic;
      main_clk    : in  std_logic;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      apbreq  : in  std_logic;
      ack2apb : out std_logic;
      wr_flit : in  std_logic_vector(5 downto 0);

      sipo1_c  : in std_logic;
      sipo1_en : in std_logic;
      sipo2_c  : in std_logic;
      sipo2_en : in std_logic;

      tdo     : in std_logic;
      sel_tdo : in std_logic_vector(1 downto 0);

      sipo1_out : out std_logic_vector(5 downto 0);
      sipo2_out : out std_logic_vector(73 downto 0));
  end component jtag2apb;

  component apb2jtag
    port (
      rst      : in  std_ulogic;
      tclk     : in  std_logic;
      main_clk     : in  std_logic;
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type;
      apbreq   : in  std_logic;
      ack2apb  : out std_logic;
      req_flit : in  std_logic_vector(5 downto 0);
      empty_fifo : out std_logic_vector(5 downto 0);
      piso_c   : in  std_logic;
      piso_l   : in  std_logic;
      piso_en  : in  std_logic;
      load_invld : in std_logic;
      tdi      : out std_logic);
  end component apb2jtag;



  component fpga_proxy_jtag
    port (
      rst   : in  std_ulogic;
      tdi   : out std_ulogic;
      tdo   : in  std_ulogic;
      tms   : in  std_ulogic;
      tclk  : in  std_ulogic;
      main_clk : in std_ulogic;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type);
  end component fpga_proxy_jtag;

  component jtag_apb_config
    generic(
      DEF_TILE : std_logic_vector(31 downto 0) := (others => '0');
      DEF_TMS : std_logic_vector(31 downto 0) := (others => '0'));
    port (
      rst   : in  std_ulogic;
      main_clk  : in  std_ulogic;
      ahbsi : in  ahb_slv_in_type;
      ahbso : out ahb_slv_out_type;
      out_p : out std_logic_vector(31 downto 0);
      out_p1 : out std_logic_vector(31 downto 0));
  end component jtag_apb_config;

  component jtag_apb_slv_config
    generic(
      lpindex :  integer range 0 to 2;
      DEF_TMS : std_logic_vector(31 downto 0) := (others => '0'));
    port (
      rst   : in  std_ulogic;
      main_clk : in std_logic;
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type;
      apbreq   : in  std_logic;
      out_p    : out std_logic_vector(31 downto 0));
  end component jtag_apb_slv_config;

  component jtag_apb_slv
    generic (
      pindex :  integer range 0 to 2;
      DEF_TMS : std_logic_vector(31 downto 0) := (others => '0')
      );
    port(
      clk     : in  std_logic;
      rstn    : in  std_logic;
      pconfig : in  apb_config_type;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      apbreq  : in  std_logic;
      out_p   : out std_logic_vector(31 downto 0));
  end component jtag_apb_slv;


  component counter_jtag
    port (
      clk    : in  std_logic;
      clear  : in  std_logic;
      enable : in  std_logic;
      co     : out integer range 0 to 255);
  end component counter_jtag;

  component demux_1to2
    port(
      data_in    : in  std_logic;
      sel        : in  std_logic_vector(1 downto 0);
      out1, out2 : out std_logic);
  end component demux_1to2;

  component demux_1to6_vs
    generic (
      SZ : integer);
    port(
      data_in                            : in  std_logic_vector(SZ-1 downto 0);
      sel                                : in  std_logic_vector(5 downto 0);
      out1, out2, out3, out4, out5, out6 : out std_logic_vector(SZ-1 downto 0));
  end component demux_1to6_vs;

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
