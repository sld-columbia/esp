-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  EMPTY tile
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
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.memoryctrl.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_empty is
  generic (
    SIMULATION : boolean := false;
    tile_id : integer range 0 to CFG_TILES_NUM - 1 := 0;
    HAS_SYNC : integer range 0 to 1 := 0 );
  port (
    rst                : in  std_logic;
    sys_clk_int        : in  std_logic;
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc1_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc1_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc2_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc2_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc3_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc3_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc4_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc4_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic; 
    noc5_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc5_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc6_stop_in       : in  std_logic_vector(3 downto 0); --std_ulogic;
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0); --std_ulogic;
    noc6_stop_out      : out std_logic_vector(3 downto 0); --std_ulogic;
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type;
    mon_dvfs_out       : out monitor_dvfs_type);

end;

architecture rtl of tile_empty is

  component sync_noc_set
    generic (
    PORTS     : std_logic_vector(4 downto 0);
--    local_x   : std_logic_vector(2 downto 0);
--    local_y   : std_logic_vector(2 downto 0);
    HAS_SYNC  : integer range 0 to 1 := 0);
    port (
    clk           : in  std_logic;
    clk_tile      : in  std_logic;
    rst           : in  std_logic;
--    CONST_PORTS   : in  std_logic_vector(4 downto 0);
    CONST_local_x : in  std_logic_vector(2 downto 0);
    CONST_local_y : in  std_logic_vector(2 downto 0);
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_input_port    : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(4 downto 0);
    noc1_stop_in       : in  std_logic_vector(4 downto 0);
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_output_port   : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(4 downto 0);
    noc1_stop_out      : out std_logic_vector(4 downto 0);
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_input_port    : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(4 downto 0);
    noc2_stop_in       : in  std_logic_vector(4 downto 0);
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_output_port   : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(4 downto 0);
    noc2_stop_out      : out std_logic_vector(4 downto 0);
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_input_port    : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(4 downto 0);
    noc3_stop_in       : in  std_logic_vector(4 downto 0);
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_output_port   : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(4 downto 0);
    noc3_stop_out      : out std_logic_vector(4 downto 0);
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_input_port    : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(4 downto 0);
    noc4_stop_in       : in  std_logic_vector(4 downto 0);
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_output_port   : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(4 downto 0);
    noc4_stop_out      : out std_logic_vector(4 downto 0);
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_input_port    : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(4 downto 0);
    noc5_stop_in       : in  std_logic_vector(4 downto 0);
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_output_port   : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(4 downto 0);
    noc5_stop_out      : out std_logic_vector(4 downto 0);
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_input_port    : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(4 downto 0);
    noc6_stop_in       : in  std_logic_vector(4 downto 0);
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_output_port   : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(4 downto 0);
    noc6_stop_out      : out std_logic_vector(4 downto 0);

    -- Monitor output. Can be left unconnected
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type

    );

  end component;


signal noc1_input_port  : noc_flit_type;
signal noc2_input_port  : noc_flit_type;
signal noc3_input_port  : noc_flit_type;
signal noc4_input_port  : noc_flit_type;
signal noc5_input_port  : misc_noc_flit_type;
signal noc6_input_port  : noc_flit_type;

signal noc1_output_port : noc_flit_type;
signal noc2_output_port : noc_flit_type;
signal noc3_output_port : noc_flit_type;
signal noc4_output_port : noc_flit_type;
signal noc5_output_port : misc_noc_flit_type;
signal noc6_output_port : noc_flit_type;

signal noc1_data_void_in_s : std_logic_vector(4 downto 0);
signal noc2_data_void_in_s : std_logic_vector(4 downto 0);
signal noc3_data_void_in_s : std_logic_vector(4 downto 0);
signal noc4_data_void_in_s : std_logic_vector(4 downto 0);
signal noc5_data_void_in_s : std_logic_vector(4 downto 0);
signal noc6_data_void_in_s : std_logic_vector(4 downto 0);

signal noc1_stop_in_s  : std_logic_vector(4 downto 0);
signal noc2_stop_in_s  : std_logic_vector(4 downto 0);
signal noc3_stop_in_s  : std_logic_vector(4 downto 0);
signal noc4_stop_in_s  : std_logic_vector(4 downto 0);
signal noc5_stop_in_s  : std_logic_vector(4 downto 0);
signal noc6_stop_in_s  : std_logic_vector(4 downto 0);

signal noc1_data_void_out_s : std_logic_vector(4 downto 0);
signal noc2_data_void_out_s : std_logic_vector(4 downto 0);
signal noc3_data_void_out_s : std_logic_vector(4 downto 0);
signal noc4_data_void_out_s : std_logic_vector(4 downto 0);
signal noc5_data_void_out_s : std_logic_vector(4 downto 0);
signal noc6_data_void_out_s : std_logic_vector(4 downto 0);

signal noc1_stop_out_s : std_logic_vector(4 downto 0);
signal noc2_stop_out_s : std_logic_vector(4 downto 0);
signal noc3_stop_out_s : std_logic_vector(4 downto 0);
signal noc4_stop_out_s : std_logic_vector(4 downto 0);
signal noc5_stop_out_s : std_logic_vector(4 downto 0);
signal noc6_stop_out_s : std_logic_vector(4 downto 0);

constant this_local_y  : local_yx  := tile_y(tile_id);
constant this_local_x  : local_yx  := tile_x(tile_id);
constant ROUTER_PORTS  : ports_vec := set_router_ports(CFG_XLEN, CFG_YLEN, this_local_x, this_local_y);

begin

mon_dvfs_out.vf        <= (others => '0');
mon_dvfs_out.clk       <= sys_clk_int;
mon_dvfs_out.acc_idle  <= '0';
mon_dvfs_out.traffic   <= '0';
mon_dvfs_out.burst     <= '0';
mon_dvfs_out.transient <= '0';

-- Connect data_void, data_stop, data_in


noc1_input_port <= (others => '0');
noc2_input_port <= (others => '0');
noc3_input_port <= (others => '0');
noc4_input_port <= (others => '0');
noc5_input_port <= (others => '0');
noc6_input_port <= (others => '0');

noc1_data_void_in_s <= '1' & noc1_data_void_in; 
noc2_data_void_in_s <= '1' & noc2_data_void_in; 
noc3_data_void_in_s <= '1' & noc3_data_void_in; 
noc4_data_void_in_s <= '1' & noc4_data_void_in; 
noc5_data_void_in_s <= '1' & noc5_data_void_in; 
noc6_data_void_in_s <= '1' & noc6_data_void_in; 

noc1_stop_in_s <= '0' & noc1_stop_in;
noc2_stop_in_s <= '0' & noc2_stop_in;
noc3_stop_in_s <= '0' & noc3_stop_in;
noc4_stop_in_s <= '0' & noc4_stop_in;
noc5_stop_in_s <= '0' & noc5_stop_in;
noc6_stop_in_s <= '0' & noc6_stop_in;

noc1_data_void_out <= noc1_data_void_out_s(3 downto 0);
noc2_data_void_out <= noc2_data_void_out_s(3 downto 0);
noc3_data_void_out <= noc3_data_void_out_s(3 downto 0);
noc4_data_void_out <= noc4_data_void_out_s(3 downto 0);
noc5_data_void_out <= noc5_data_void_out_s(3 downto 0);
noc6_data_void_out <= noc6_data_void_out_s(3 downto 0);

noc1_stop_out <= noc1_stop_out_s(3 downto 0);
noc2_stop_out <= noc2_stop_out_s(3 downto 0);
noc3_stop_out <= noc3_stop_out_s(3 downto 0);
noc4_stop_out <= noc4_stop_out_s(3 downto 0);
noc5_stop_out <= noc5_stop_out_s(3 downto 0);
noc6_stop_out <= noc6_stop_out_s(3 downto 0);

  sync_noc_set_empty: sync_noc_set
  generic map (
     PORTS    => ROUTER_PORTS,
--     local_x  => this_local_x,
--     local_y  => this_local_y,
     HAS_SYNC => HAS_SYNC )
   port map (
     clk                => sys_clk_int,
     clk_tile           => sys_clk_int,
     rst                => rst,
--     CONST_PORTS        => ROUTER_PORTS,
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
     noc1_mon_noc_vec   => noc1_mon_noc_vec,
     noc2_mon_noc_vec   => noc2_mon_noc_vec,
     noc3_mon_noc_vec   => noc3_mon_noc_vec,
     noc4_mon_noc_vec   => noc4_mon_noc_vec,
     noc5_mon_noc_vec   => noc5_mon_noc_vec,
     noc6_mon_noc_vec   => noc6_mon_noc_vec
   
     );


end;
