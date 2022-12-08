-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  I/O tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.ariane_esp_pkg.all;
use work.tiles_pkg.all;

entity fpga_tile_io is
  generic (
    SIMULATION   : boolean   := false;
    ROUTER_PORTS : ports_vec := "11111";
    HAS_SYNC     : integer range 0 to 1 := 1);
  port (
    raw_rstn           : in    std_ulogic;
    rst                : in    std_ulogic;  -- Global reset (active high)
    clk                : in    std_ulogic;
    refclk_noc         : in    std_ulogic;
    pllclk_noc         : out   std_ulogic;
    refclk             : in    std_ulogic;
    pllbypass          : in    std_ulogic;
    pllclk             : out   std_ulogic; 
    dco_clk            : out   std_ulogic;
    -- Ethernet
    mdcscaler          : out   integer range 0 to 2047;
    eth0_apbi          : out   apb_slv_in_type;
    eth0_apbo          : in    apb_slv_out_type;
    sgmii0_apbi        : out   apb_slv_in_type;
    sgmii0_apbo        : in    apb_slv_out_type;
    eth0_ahbmi         : out   ahb_mst_in_type;
    eth0_ahbmo         : in    ahb_mst_out_type;
    edcl_ahbmo         : in    ahb_mst_out_type;
    dvi_apbi           : out   apb_slv_in_type;
    dvi_apbo           : in    apb_slv_out_type;
    dvi_ahbmi          : out   ahb_mst_in_type;
    dvi_ahbmo          : in    ahb_mst_out_type;
    -- UART
    uart_rxd           : in    std_ulogic;
    uart_txd           : out   std_ulogic;
    uart_ctsn          : in    std_ulogic;
    uart_rtsn          : out   std_ulogic;
    -- Test interface
    tdi                : in    std_logic;
    tdo                : out   std_logic;
    tms                : in    std_logic;
    tclk               : in    std_logic;
    -- NOC
    sys_clk_int        : in    std_ulogic;
    sys_rstn           : in    std_ulogic;
    sys_clk_out        : out   std_ulogic;
    sys_clk_lock       : out   std_ulogic;
    noc1_data_n_in     : in    noc_flit_type;
    noc1_data_s_in     : in    noc_flit_type;
    noc1_data_w_in     : in    noc_flit_type;
    noc1_data_e_in     : in    noc_flit_type;
    noc1_data_void_in  : in    std_logic_vector(3 downto 0);
    noc1_stop_in       : in    std_logic_vector(3 downto 0);
    noc1_data_n_out    : out   noc_flit_type;
    noc1_data_s_out    : out   noc_flit_type;
    noc1_data_w_out    : out   noc_flit_type;
    noc1_data_e_out    : out   noc_flit_type;
    noc1_data_void_out : out   std_logic_vector(3 downto 0);
    noc1_stop_out      : out   std_logic_vector(3 downto 0);
    noc2_data_n_in     : in    noc_flit_type;
    noc2_data_s_in     : in    noc_flit_type;
    noc2_data_w_in     : in    noc_flit_type;
    noc2_data_e_in     : in    noc_flit_type;
    noc2_data_void_in  : in    std_logic_vector(3 downto 0);
    noc2_stop_in       : in    std_logic_vector(3 downto 0);
    noc2_data_n_out    : out   noc_flit_type;
    noc2_data_s_out    : out   noc_flit_type;
    noc2_data_w_out    : out   noc_flit_type;
    noc2_data_e_out    : out   noc_flit_type;
    noc2_data_void_out : out   std_logic_vector(3 downto 0);
    noc2_stop_out      : out   std_logic_vector(3 downto 0);
    noc3_data_n_in     : in    noc_flit_type;
    noc3_data_s_in     : in    noc_flit_type;
    noc3_data_w_in     : in    noc_flit_type;
    noc3_data_e_in     : in    noc_flit_type;
    noc3_data_void_in  : in    std_logic_vector(3 downto 0);
    noc3_stop_in       : in    std_logic_vector(3 downto 0);
    noc3_data_n_out    : out   noc_flit_type;
    noc3_data_s_out    : out   noc_flit_type;
    noc3_data_w_out    : out   noc_flit_type;
    noc3_data_e_out    : out   noc_flit_type;
    noc3_data_void_out : out   std_logic_vector(3 downto 0);
    noc3_stop_out      : out   std_logic_vector(3 downto 0);
    noc4_data_n_in     : in    noc_flit_type;
    noc4_data_s_in     : in    noc_flit_type;
    noc4_data_w_in     : in    noc_flit_type;
    noc4_data_e_in     : in    noc_flit_type;
    noc4_data_void_in  : in    std_logic_vector(3 downto 0);
    noc4_stop_in       : in    std_logic_vector(3 downto 0);
    noc4_data_n_out    : out   noc_flit_type;
    noc4_data_s_out    : out   noc_flit_type;
    noc4_data_w_out    : out   noc_flit_type;
    noc4_data_e_out    : out   noc_flit_type;
    noc4_data_void_out : out   std_logic_vector(3 downto 0);
    noc4_stop_out      : out   std_logic_vector(3 downto 0);
    noc5_data_n_in     : in    misc_noc_flit_type;
    noc5_data_s_in     : in    misc_noc_flit_type;
    noc5_data_w_in     : in    misc_noc_flit_type;
    noc5_data_e_in     : in    misc_noc_flit_type;
    noc5_data_void_in  : in    std_logic_vector(3 downto 0);
    noc5_stop_in       : in    std_logic_vector(3 downto 0);
    noc5_data_n_out    : out   misc_noc_flit_type;
    noc5_data_s_out    : out   misc_noc_flit_type;
    noc5_data_w_out    : out   misc_noc_flit_type;
    noc5_data_e_out    : out   misc_noc_flit_type;
    noc5_data_void_out : out   std_logic_vector(3 downto 0);
    noc5_stop_out      : out   std_logic_vector(3 downto 0);
    noc6_data_n_in     : in    noc_flit_type;
    noc6_data_s_in     : in    noc_flit_type;
    noc6_data_w_in     : in    noc_flit_type;
    noc6_data_e_in     : in    noc_flit_type;
    noc6_data_void_in  : in    std_logic_vector(3 downto 0);
    noc6_stop_in       : in    std_logic_vector(3 downto 0);
    noc6_data_n_out    : out   noc_flit_type;
    noc6_data_s_out    : out   noc_flit_type;
    noc6_data_w_out    : out   noc_flit_type;
    noc6_data_e_out    : out   noc_flit_type;
    noc6_data_void_out : out   std_logic_vector(3 downto 0);
    noc6_stop_out      : out   std_logic_vector(3 downto 0);
    noc1_mon_noc_vec   : out   monitor_noc_type;
    noc2_mon_noc_vec   : out   monitor_noc_type;
    noc3_mon_noc_vec   : out   monitor_noc_type;
    noc4_mon_noc_vec   : out   monitor_noc_type;
    noc5_mon_noc_vec   : out   monitor_noc_type;
    noc6_mon_noc_vec   : out   monitor_noc_type;
    mon_dvfs           : out   monitor_dvfs_type
    );

end;

architecture rtl of fpga_tile_io is

  attribute keep                        : string;
  attribute syn_keep                    : boolean;
  attribute syn_preserve                : boolean;

  -- DCO reset -> keeping the logic compliant with the asic flow
  signal dco_rstn : std_ulogic;

  -- JTAG signals
  signal test1_output_port_s   : noc_flit_type;
  signal test1_data_void_out_s : std_ulogic;
  signal test1_stop_in_s       : std_ulogic;
  signal test2_output_port_s   : noc_flit_type;
  signal test2_data_void_out_s : std_ulogic;
  signal test2_stop_in_s       : std_ulogic;
  signal test3_output_port_s   : noc_flit_type;
  signal test3_data_void_out_s : std_ulogic;
  signal test3_stop_in_s       : std_ulogic;
  signal test4_output_port_s   : noc_flit_type;
  signal test4_data_void_out_s : std_ulogic;
  signal test4_stop_in_s       : std_ulogic;
  signal test5_output_port_s   : misc_noc_flit_type;
  signal test5_data_void_out_s : std_ulogic;
  signal test5_stop_in_s       : std_ulogic;
  signal test6_output_port_s   : noc_flit_type;
  signal test6_data_void_out_s : std_ulogic;
  signal test6_stop_in_s       : std_ulogic;
  signal test1_input_port_s    : noc_flit_type;
  signal test1_data_void_in_s  : std_ulogic;
  signal test1_stop_out_s      : std_ulogic;
  signal test2_input_port_s    : noc_flit_type;
  signal test2_data_void_in_s  : std_ulogic;
  signal test2_stop_out_s      : std_ulogic;
  signal test3_input_port_s    : noc_flit_type;
  signal test3_data_void_in_s  : std_ulogic;
  signal test3_stop_out_s      : std_ulogic;
  signal test4_input_port_s    : noc_flit_type;
  signal test4_data_void_in_s  : std_ulogic;
  signal test4_stop_out_s      : std_ulogic;
  signal test5_input_port_s    : misc_noc_flit_type;
  signal test5_data_void_in_s  : std_ulogic;
  signal test5_stop_out_s      : std_ulogic;
  signal test6_input_port_s    : noc_flit_type;
  signal test6_data_void_in_s  : std_ulogic;
  signal test6_stop_out_s      : std_ulogic;

  signal noc1_mon_noc_vec_int  : monitor_noc_type;
  signal noc2_mon_noc_vec_int  : monitor_noc_type;
  signal noc3_mon_noc_vec_int  : monitor_noc_type;
  signal noc4_mon_noc_vec_int  : monitor_noc_type;
  signal noc5_mon_noc_vec_int  : monitor_noc_type;
  signal noc6_mon_noc_vec_int  : monitor_noc_type;

  -- Noc signals
  signal this_local_x          : local_yx;
  signal this_local_y          : local_yx;
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_io_stop_in       : std_ulogic;
  signal noc1_io_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_io_data_void_in  : std_ulogic;
  signal noc1_io_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_io_stop_in       : std_ulogic;
  signal noc2_io_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_io_data_void_in  : std_ulogic;
  signal noc2_io_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_io_stop_in       : std_ulogic;
  signal noc3_io_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_io_data_void_in  : std_ulogic;
  signal noc3_io_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_io_stop_in       : std_ulogic;
  signal noc4_io_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_io_data_void_in  : std_ulogic;
  signal noc4_io_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_io_stop_in       : std_ulogic;
  signal noc5_io_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_io_data_void_in  : std_ulogic;
  signal noc5_io_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_io_stop_in       : std_ulogic;
  signal noc6_io_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_io_data_void_in  : std_ulogic;
  signal noc6_io_data_void_out : std_ulogic;
  signal noc1_input_port        : noc_flit_type;
  signal noc2_input_port        : noc_flit_type;
  signal noc3_input_port        : noc_flit_type;
  signal noc4_input_port        : noc_flit_type;
  signal noc5_input_port        : misc_noc_flit_type;
  signal noc6_input_port        : noc_flit_type;
  signal noc1_output_port       : noc_flit_type;
  signal noc2_output_port       : noc_flit_type;
  signal noc3_output_port       : noc_flit_type;
  signal noc4_output_port       : noc_flit_type;
  signal noc5_output_port       : misc_noc_flit_type;
  signal noc6_output_port       : noc_flit_type;

  attribute keep of noc1_io_stop_in       : signal is "true";
  attribute keep of noc1_io_stop_out      : signal is "true";
  attribute keep of noc1_io_data_void_in  : signal is "true";
  attribute keep of noc1_io_data_void_out : signal is "true";
  attribute keep of noc1_input_port        : signal is "true";
  attribute keep of noc1_output_port       : signal is "true";
  attribute keep of noc1_data_n_in     : signal is "true";
  attribute keep of noc1_data_s_in     : signal is "true";
  attribute keep of noc1_data_w_in     : signal is "true";
  attribute keep of noc1_data_e_in     : signal is "true";
  attribute keep of noc1_data_void_in  : signal is "true";
  attribute keep of noc1_stop_in       : signal is "true";
  attribute keep of noc1_data_n_out    : signal is "true";
  attribute keep of noc1_data_s_out    : signal is "true";
  attribute keep of noc1_data_w_out    : signal is "true";
  attribute keep of noc1_data_e_out    : signal is "true";
  attribute keep of noc1_data_void_out : signal is "true";
  attribute keep of noc1_stop_out      : signal is "true";
  attribute keep of noc2_io_stop_in       : signal is "true";
  attribute keep of noc2_io_stop_out      : signal is "true";
  attribute keep of noc2_io_data_void_in  : signal is "true";
  attribute keep of noc2_io_data_void_out : signal is "true";
  attribute keep of noc2_input_port        : signal is "true";
  attribute keep of noc2_output_port       : signal is "true";
  attribute keep of noc2_data_n_in     : signal is "true";
  attribute keep of noc2_data_s_in     : signal is "true";
  attribute keep of noc2_data_w_in     : signal is "true";
  attribute keep of noc2_data_e_in     : signal is "true";
  attribute keep of noc2_data_void_in  : signal is "true";
  attribute keep of noc2_stop_in       : signal is "true";
  attribute keep of noc2_data_n_out    : signal is "true";
  attribute keep of noc2_data_s_out    : signal is "true";
  attribute keep of noc2_data_w_out    : signal is "true";
  attribute keep of noc2_data_e_out    : signal is "true";
  attribute keep of noc2_data_void_out : signal is "true";
  attribute keep of noc2_stop_out      : signal is "true";
  attribute keep of noc3_io_stop_in       : signal is "true";
  attribute keep of noc3_io_stop_out      : signal is "true";
  attribute keep of noc3_io_data_void_in  : signal is "true";
  attribute keep of noc3_io_data_void_out : signal is "true";
  attribute keep of noc3_input_port        : signal is "true";
  attribute keep of noc3_output_port       : signal is "true";
  attribute keep of noc3_data_n_in     : signal is "true";
  attribute keep of noc3_data_s_in     : signal is "true";
  attribute keep of noc3_data_w_in     : signal is "true";
  attribute keep of noc3_data_e_in     : signal is "true";
  attribute keep of noc3_data_void_in  : signal is "true";
  attribute keep of noc3_stop_in       : signal is "true";
  attribute keep of noc3_data_n_out    : signal is "true";
  attribute keep of noc3_data_s_out    : signal is "true";
  attribute keep of noc3_data_w_out    : signal is "true";
  attribute keep of noc3_data_e_out    : signal is "true";
  attribute keep of noc3_data_void_out : signal is "true";
  attribute keep of noc3_stop_out      : signal is "true";
  attribute keep of noc4_io_stop_in       : signal is "true";
  attribute keep of noc4_io_stop_out      : signal is "true";
  attribute keep of noc4_io_data_void_in  : signal is "true";
  attribute keep of noc4_io_data_void_out : signal is "true";
  attribute keep of noc4_input_port        : signal is "true";
  attribute keep of noc4_output_port       : signal is "true";
  attribute keep of noc4_data_n_in     : signal is "true";
  attribute keep of noc4_data_s_in     : signal is "true";
  attribute keep of noc4_data_w_in     : signal is "true";
  attribute keep of noc4_data_e_in     : signal is "true";
  attribute keep of noc4_data_void_in  : signal is "true";
  attribute keep of noc4_stop_in       : signal is "true";
  attribute keep of noc4_data_n_out    : signal is "true";
  attribute keep of noc4_data_s_out    : signal is "true";
  attribute keep of noc4_data_w_out    : signal is "true";
  attribute keep of noc4_data_e_out    : signal is "true";
  attribute keep of noc4_data_void_out : signal is "true";
  attribute keep of noc4_stop_out      : signal is "true";
  attribute keep of noc5_io_stop_in       : signal is "true";
  attribute keep of noc5_io_stop_out      : signal is "true";
  attribute keep of noc5_io_data_void_in  : signal is "true";
  attribute keep of noc5_io_data_void_out : signal is "true";
  attribute keep of noc5_input_port        : signal is "true";
  attribute keep of noc5_output_port       : signal is "true";
  attribute keep of noc5_data_n_in     : signal is "true";
  attribute keep of noc5_data_s_in     : signal is "true";
  attribute keep of noc5_data_w_in     : signal is "true";
  attribute keep of noc5_data_e_in     : signal is "true";
  attribute keep of noc5_data_void_in  : signal is "true";
  attribute keep of noc5_stop_in       : signal is "true";
  attribute keep of noc5_data_n_out    : signal is "true";
  attribute keep of noc5_data_s_out    : signal is "true";
  attribute keep of noc5_data_w_out    : signal is "true";
  attribute keep of noc5_data_e_out    : signal is "true";
  attribute keep of noc5_data_void_out : signal is "true";
  attribute keep of noc5_stop_out      : signal is "true";
  attribute keep of noc6_io_stop_in       : signal is "true";
  attribute keep of noc6_io_stop_out      : signal is "true";
  attribute keep of noc6_io_data_void_in  : signal is "true";
  attribute keep of noc6_io_data_void_out : signal is "true";
  attribute keep of noc6_input_port        : signal is "true";
  attribute keep of noc6_output_port       : signal is "true";
  attribute keep of noc6_data_n_in     : signal is "true";
  attribute keep of noc6_data_s_in     : signal is "true";
  attribute keep of noc6_data_w_in     : signal is "true";
  attribute keep of noc6_data_e_in     : signal is "true";
  attribute keep of noc6_data_void_in  : signal is "true";
  attribute keep of noc6_stop_in       : signal is "true";
  attribute keep of noc6_data_n_out    : signal is "true";
  attribute keep of noc6_data_s_out    : signal is "true";
  attribute keep of noc6_data_w_out    : signal is "true";
  attribute keep of noc6_data_e_out    : signal is "true";
  attribute keep of noc6_data_void_out : signal is "true";
  attribute keep of noc6_stop_out      : signal is "true";


begin

  noc1_mon_noc_vec <= noc1_mon_noc_vec_int;
  noc2_mon_noc_vec <= noc2_mon_noc_vec_int;
  noc3_mon_noc_vec <= noc3_mon_noc_vec_int;
  noc4_mon_noc_vec <= noc4_mon_noc_vec_int;
  noc5_mon_noc_vec <= noc5_mon_noc_vec_int;
  noc6_mon_noc_vec <= noc6_mon_noc_vec_int;

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => 0)
    port map (
      rst                 => rst,
      refclk              => clk,
      tile_rst            => dco_rstn,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port,
      noc1_data_void_out  => noc1_io_data_void_out,
      noc1_stop_in        => noc1_io_stop_in,
      noc2_output_port    => noc2_output_port,
      noc2_data_void_out  => noc2_io_data_void_out,
      noc2_stop_in        => noc2_io_stop_in,
      noc3_output_port    => noc3_output_port,
      noc3_data_void_out  => noc3_io_data_void_out,
      noc3_stop_in        => noc3_io_stop_in,
      noc4_output_port    => noc4_output_port,
      noc4_data_void_out  => noc4_io_data_void_out,
      noc4_stop_in        => noc4_io_stop_in,
      noc5_output_port    => noc5_output_port,
      noc5_data_void_out  => noc5_io_data_void_out,
      noc5_stop_in        => noc5_io_stop_in,
      noc6_output_port    => noc6_output_port,
      noc6_data_void_out  => noc6_io_data_void_out,
      noc6_stop_in        => noc6_io_stop_in,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_in_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_out_s,
      noc1_input_port     => noc1_input_port,
      noc1_data_void_in   => noc1_io_data_void_in,
      noc1_stop_out       => noc1_io_stop_out,
      noc2_input_port     => noc2_input_port,
      noc2_data_void_in   => noc2_io_data_void_in,
      noc2_stop_out       => noc2_io_stop_out,
      noc3_input_port     => noc3_input_port,
      noc3_data_void_in   => noc3_io_data_void_in,
      noc3_stop_out       => noc3_io_stop_out,
      noc4_input_port     => noc4_input_port,
      noc4_data_void_in   => noc4_io_data_void_in,
      noc4_stop_out       => noc4_io_stop_out,
      noc5_input_port     => noc5_input_port,
      noc5_data_void_in   => noc5_io_data_void_in,
      noc5_stop_out       => noc5_io_stop_out,
      noc6_input_port     => noc6_input_port,
      noc6_data_void_in   => noc6_io_data_void_in,
      noc6_stop_out       => noc6_io_stop_out);

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_io_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_io_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_io_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_io_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_io_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_io_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_io_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_io_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_io_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_io_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_io_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_io_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_io_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_io_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_io_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_io_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_io_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_io_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_io_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_io_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_io_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_io_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_io_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_io_data_void_out <= noc6_data_void_out_s(4);

  sync_noc_set_io: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
     HAS_SYNC => HAS_SYNC )
   port map (
     clk                => sys_clk_int,
     clk_tile           => clk,
     rst                => sys_rstn,
     rst_tile           => dco_rstn,
     CONST_local_x      => this_local_x,
     CONST_local_y      => this_local_y,
     noc1_data_n_in     => noc1_data_n_in,
     noc1_data_s_in     => noc1_data_s_in,
     noc1_data_w_in     => noc1_data_w_in,
     noc1_data_e_in     => noc1_data_e_in,
     noc1_input_port    => noc1_input_port,
     noc1_data_void_in  => noc1_data_void_in_s,
     noc1_stop_in       => noc1_stop_in_s,
     noc1_data_n_out    => noc1_data_n_out,
     noc1_data_s_out    => noc1_data_s_out,
     noc1_data_w_out    => noc1_data_w_out,
     noc1_data_e_out    => noc1_data_e_out,
     noc1_output_port   => noc1_output_port,
     noc1_data_void_out => noc1_data_void_out_s,
     noc1_stop_out      => noc1_stop_out_s,
     noc2_data_n_in     => noc2_data_n_in,
     noc2_data_s_in     => noc2_data_s_in,
     noc2_data_w_in     => noc2_data_w_in,
     noc2_data_e_in     => noc2_data_e_in,
     noc2_input_port    => noc2_input_port,
     noc2_data_void_in  => noc2_data_void_in_s,
     noc2_stop_in       => noc2_stop_in_s,
     noc2_data_n_out    => noc2_data_n_out,
     noc2_data_s_out    => noc2_data_s_out,
     noc2_data_w_out    => noc2_data_w_out,
     noc2_data_e_out    => noc2_data_e_out,
     noc2_output_port   => noc2_output_port,
     noc2_data_void_out => noc2_data_void_out_s,
     noc2_stop_out      => noc2_stop_out_s,
     noc3_data_n_in     => noc3_data_n_in,
     noc3_data_s_in     => noc3_data_s_in,
     noc3_data_w_in     => noc3_data_w_in,
     noc3_data_e_in     => noc3_data_e_in,
     noc3_input_port    => noc3_input_port,
     noc3_data_void_in  => noc3_data_void_in_s,
     noc3_stop_in       => noc3_stop_in_s,
     noc3_data_n_out    => noc3_data_n_out,
     noc3_data_s_out    => noc3_data_s_out,
     noc3_data_w_out    => noc3_data_w_out,
     noc3_data_e_out    => noc3_data_e_out,
     noc3_output_port   => noc3_output_port,
     noc3_data_void_out => noc3_data_void_out_s,
     noc3_stop_out      => noc3_stop_out_s,
     noc4_data_n_in     => noc4_data_n_in,
     noc4_data_s_in     => noc4_data_s_in,
     noc4_data_w_in     => noc4_data_w_in,
     noc4_data_e_in     => noc4_data_e_in,
     noc4_input_port    => noc4_input_port,
     noc4_data_void_in  => noc4_data_void_in_s,
     noc4_stop_in       => noc4_stop_in_s,
     noc4_data_n_out    => noc4_data_n_out,
     noc4_data_s_out    => noc4_data_s_out,
     noc4_data_w_out    => noc4_data_w_out,
     noc4_data_e_out    => noc4_data_e_out,
     noc4_output_port   => noc4_output_port,
     noc4_data_void_out => noc4_data_void_out_s,
     noc4_stop_out      => noc4_stop_out_s,
     noc5_data_n_in     => noc5_data_n_in,
     noc5_data_s_in     => noc5_data_s_in,
     noc5_data_w_in     => noc5_data_w_in,
     noc5_data_e_in     => noc5_data_e_in,
     noc5_input_port    => noc5_input_port,
     noc5_data_void_in  => noc5_data_void_in_s,
     noc5_stop_in       => noc5_stop_in_s,
     noc5_data_n_out    => noc5_data_n_out,
     noc5_data_s_out    => noc5_data_s_out,
     noc5_data_w_out    => noc5_data_w_out,
     noc5_data_e_out    => noc5_data_e_out,
     noc5_output_port   => noc5_output_port,
     noc5_data_void_out => noc5_data_void_out_s,
     noc5_stop_out      => noc5_stop_out_s,
     noc6_data_n_in     => noc6_data_n_in,
     noc6_data_s_in     => noc6_data_s_in,
     noc6_data_w_in     => noc6_data_w_in,
     noc6_data_e_in     => noc6_data_e_in,
     noc6_input_port    => noc6_input_port,
     noc6_data_void_in  => noc6_data_void_in_s,
     noc6_stop_in       => noc6_stop_in_s,
     noc6_data_n_out    => noc6_data_n_out,
     noc6_data_s_out    => noc6_data_s_out,
     noc6_data_w_out    => noc6_data_w_out,
     noc6_data_e_out    => noc6_data_e_out,
     noc6_output_port   => noc6_output_port,
     noc6_data_void_out => noc6_data_void_out_s,
     noc6_stop_out      => noc6_stop_out_s,
     noc1_mon_noc_vec   => noc1_mon_noc_vec_int,
     noc2_mon_noc_vec   => noc2_mon_noc_vec_int,
     noc3_mon_noc_vec   => noc3_mon_noc_vec_int,
     noc4_mon_noc_vec   => noc4_mon_noc_vec_int,
     noc5_mon_noc_vec   => noc5_mon_noc_vec_int,
     noc6_mon_noc_vec   => noc6_mon_noc_vec_int
     );

  -----------------------------------------------------------------------------
  -- Tile
  -----------------------------------------------------------------------------
  tile_io_1 : tile_io
    generic map (
      SIMULATION   => SIMULATION,
      this_has_dco => 0)
    port map (
      raw_rstn           => raw_rstn,
      tile_rst           => rst,
      clk                => clk,    -- Local DCO clock
      refclk_noc         => refclk_noc,  -- Backup NoC clock when DCO is enabled
      pllclk_noc         => pllclk_noc,  -- NoC DCO clock out
      refclk             => refclk,    -- Local backup ext clock
      pllbypass          => pllbypass,  --ext_clk_sel,
      pllclk             => pllclk,    -- DCO clock monitor
      dco_clk            => dco_clk,    -- Local DCO clock out (fixed @ TILE_FREQ)
      dco_rstn           => dco_rstn,
      local_x            => this_local_x,
      local_y            => this_local_y,
      -- Ethernet MDC Scaler configuration
      mdcscaler          => mdcscaler,
      -- Ethernet
      eth0_apbi          => eth0_apbi,
      eth0_apbo          => eth0_apbo,
      sgmii0_apbi        => sgmii0_apbi,
      sgmii0_apbo        => sgmii0_apbo,
      eth0_ahbmi         => eth0_ahbmi,
      eth0_ahbmo         => eth0_ahbmo,
      edcl_ahbmo         => edcl_ahbmo,
      -- DVI
      dvi_apbi           => dvi_apbi,
      dvi_apbo           => dvi_apbo,
      dvi_ahbmi          => dvi_ahbmi,
      dvi_ahbmo          => dvi_ahbmo,
      -- UART
      uart_rxd           => uart_rxd,
      uart_txd           => uart_txd,
      uart_ctsn          => uart_ctsn,
      uart_rtsn          => uart_rtsn,
      -- I/O link
      iolink_data_oen    => open,
      iolink_data_in     => (others => '0'),
      iolink_data_out    => open,
      iolink_valid_in    => '0',
      iolink_valid_out   => open,
      iolink_clk_in      => '0',
      iolink_clk_out     => open,
      iolink_credit_in   => '0',
      iolink_credit_out  => open,
      -- Pad configuration
      pad_cfg            => open,
      -- NOC
      sys_clk_out        => sys_clk_out,  -- Global NoC clock out
      sys_clk_lock       => sys_clk_lock,
      noc1_mon_noc_vec    => noc1_mon_noc_vec_int,
      noc2_mon_noc_vec    => noc2_mon_noc_vec_int,
      noc3_mon_noc_vec    => noc3_mon_noc_vec_int,
      noc4_mon_noc_vec    => noc4_mon_noc_vec_int,
      noc5_mon_noc_vec    => noc5_mon_noc_vec_int,
      noc6_mon_noc_vec    => noc6_mon_noc_vec_int,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_out_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_in_s,
      mon_dvfs            => mon_dvfs);

end;
