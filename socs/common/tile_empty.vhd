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
    SIMULATION   : boolean              := false;
    ROUTER_PORTS : ports_vec            := "11111";
    HAS_SYNC     : integer range 0 to 1 := 0);
  port (
    rst                : in  std_logic;
    sys_clk_int        : in  std_logic;
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc1_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc1_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc2_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc2_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc3_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc3_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc4_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc4_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic; 
    noc5_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc5_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc6_stop_in       : in  std_logic_vector(3 downto 0);  --std_ulogic;
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);  --std_ulogic;
    noc6_stop_out      : out std_logic_vector(3 downto 0);  --std_ulogic;
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
      PORTS    : std_logic_vector(4 downto 0);
      HAS_SYNC : integer range 0 to 1 := 0);
    port (
      clk                : in  std_logic;
      clk_tile           : in  std_logic;
      rst                : in  std_logic;
      CONST_local_x      : in  std_logic_vector(2 downto 0);
      CONST_local_y      : in  std_logic_vector(2 downto 0);
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
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type

      );

  end component;


  -- Queues
  signal apb_rcv_rdreq    : std_ulogic;
  signal apb_rcv_data_out : misc_noc_flit_type;
  signal apb_rcv_empty    : std_ulogic;
  signal apb_snd_wrreq    : std_ulogic;
  signal apb_snd_data_in  : misc_noc_flit_type;
  signal apb_snd_full     : std_ulogic;

  -- Bus
  signal apbi           : apb_slv_in_type;
  signal apbo           : apb_slv_out_vector;

  -- NoC
  signal noc1_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc1_mem_stop_in       : std_ulogic;
  signal noc1_mem_stop_out      : std_ulogic;
  signal noc1_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc1_mem_data_void_in  : std_ulogic;
  signal noc1_mem_data_void_out : std_ulogic;
  signal noc2_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc2_mem_stop_in       : std_ulogic;
  signal noc2_mem_stop_out      : std_ulogic;
  signal noc2_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc2_mem_data_void_in  : std_ulogic;
  signal noc2_mem_data_void_out : std_ulogic;
  signal noc3_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc3_mem_stop_in       : std_ulogic;
  signal noc3_mem_stop_out      : std_ulogic;
  signal noc3_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc3_mem_data_void_in  : std_ulogic;
  signal noc3_mem_data_void_out : std_ulogic;
  signal noc4_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc4_mem_stop_in       : std_ulogic;
  signal noc4_mem_stop_out      : std_ulogic;
  signal noc4_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc4_mem_data_void_in  : std_ulogic;
  signal noc4_mem_data_void_out : std_ulogic;
  signal noc5_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc5_mem_stop_in       : std_ulogic;
  signal noc5_mem_stop_out      : std_ulogic;
  signal noc5_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc5_mem_data_void_in  : std_ulogic;
  signal noc5_mem_data_void_out : std_ulogic;
  signal noc6_stop_in_s         : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s        : std_logic_vector(4 downto 0);
  signal noc6_mem_stop_in       : std_ulogic;
  signal noc6_mem_stop_out      : std_ulogic;
  signal noc6_data_void_in_s    : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s   : std_logic_vector(4 downto 0);
  signal noc6_mem_data_void_in  : std_ulogic;
  signal noc6_mem_data_void_out : std_ulogic;
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

  -- Mon
  signal mon_dvfs_int         : monitor_dvfs_type;
  signal mon_noc              : monitor_noc_vector(1 to 6);
  signal noc1_mon_noc_vec_int : monitor_noc_type;
  signal noc2_mon_noc_vec_int : monitor_noc_type;
  signal noc3_mon_noc_vec_int : monitor_noc_type;
  signal noc4_mon_noc_vec_int : monitor_noc_type;
  signal noc5_mon_noc_vec_int : monitor_noc_type;
  signal noc6_mon_noc_vec_int : monitor_noc_type;
  
  attribute keep              : string;
  attribute keep of noc1_mem_stop_in       : signal is "true";
  attribute keep of noc1_mem_stop_out      : signal is "true";
  attribute keep of noc1_mem_data_void_in  : signal is "true";
  attribute keep of noc1_mem_data_void_out : signal is "true";
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
  attribute keep of noc2_mem_stop_in       : signal is "true";
  attribute keep of noc2_mem_stop_out      : signal is "true";
  attribute keep of noc2_mem_data_void_in  : signal is "true";
  attribute keep of noc2_mem_data_void_out : signal is "true";
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
  attribute keep of noc3_mem_stop_in       : signal is "true";
  attribute keep of noc3_mem_stop_out      : signal is "true";
  attribute keep of noc3_mem_data_void_in  : signal is "true";
  attribute keep of noc3_mem_data_void_out : signal is "true";
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
  attribute keep of noc4_mem_stop_in       : signal is "true";
  attribute keep of noc4_mem_stop_out      : signal is "true";
  attribute keep of noc4_mem_data_void_in  : signal is "true";
  attribute keep of noc4_mem_data_void_out : signal is "true";
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
  attribute keep of noc5_mem_stop_in       : signal is "true";
  attribute keep of noc5_mem_stop_out      : signal is "true";
  attribute keep of noc5_mem_data_void_in  : signal is "true";
  attribute keep of noc5_mem_data_void_out : signal is "true";
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
  attribute keep of noc6_mem_stop_in       : signal is "true";
  attribute keep of noc6_mem_stop_out      : signal is "true";
  attribute keep of noc6_mem_data_void_in  : signal is "true";
  attribute keep of noc6_mem_data_void_out : signal is "true";
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

  -- Tile parameters
  signal config : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  signal tile_id : integer range 0 to CFG_TILES_NUM - 1;

  signal this_csr_pindex        : integer range 0 to NAPBSLV - 1;
  signal this_csr_pconfig       : apb_config_type;

  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := (
    0 => '1',                           -- CSRs
    others => '0');

begin

  -----------------------------------------------------------------------------
  -- Tile parameters
  -----------------------------------------------------------------------------
  tile_id                <= to_integer(unsigned(config(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB)));

  this_csr_pindex        <= tile_csr_pindex(tile_id);
  this_csr_pconfig       <= fixed_apbo_pconfig(this_csr_pindex);

  this_local_y           <= tile_y(tile_id);
  this_local_x           <= tile_x(tile_id);

  -----------------------------------------------------------------------------
  -- Buse
  -----------------------------------------------------------------------------
  -- Unused APB ports
  no_apb : for i in 0 to NAPBSLV - 1 generate
    local_apb : if this_local_apb_en(i) = '0' generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  -----------------------------------------------------------------------------
  -- Services
  -----------------------------------------------------------------------------

  -- APB
  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => CFG_FABTECH,
      local_apb_en => this_local_apb_en)
    port map (
      rst              => rst,
      clk              => sys_clk_int,
      local_y          => this_local_y,
      local_x          => this_local_x,
      apbi             => apbi,
      apbo             => apbo,
      pready           => '1',
      dvfs_transient   => '0',
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty);

  --Monitors
  mon_dvfs_int.vf        <= (others => '0');
  mon_dvfs_int.clk       <= sys_clk_int;
  mon_dvfs_int.acc_idle  <= '0';
  mon_dvfs_int.traffic   <= '0';
  mon_dvfs_int.burst     <= '0';
  mon_dvfs_int.transient <= '0';
  mon_dvfs_out           <= mon_dvfs_int;

  noc1_mon_noc_vec <= noc1_mon_noc_vec_int;
  noc2_mon_noc_vec <= noc2_mon_noc_vec_int;
  noc3_mon_noc_vec <= noc3_mon_noc_vec_int;
  noc4_mon_noc_vec <= noc4_mon_noc_vec_int;
  noc5_mon_noc_vec <= noc5_mon_noc_vec_int;
  noc6_mon_noc_vec <= noc6_mon_noc_vec_int;

  mon_noc(1) <= noc1_mon_noc_vec_int;
  mon_noc(2) <= noc2_mon_noc_vec_int;
  mon_noc(3) <= noc3_mon_noc_vec_int;
  mon_noc(4) <= noc4_mon_noc_vec_int;
  mon_noc(5) <= noc5_mon_noc_vec_int;
  mon_noc(6) <= noc6_mon_noc_vec_int;

  --Memory mapped registers
 empty_tile_csr : esp_tile_csr
    generic map(
      pindex => 0)
   port map(
     clk => sys_clk_int,
     rstn => rst,
     pconfig => this_csr_pconfig,
     mon_ddr => monitor_ddr_none,
     mon_mem => monitor_mem_none,
     mon_noc => mon_noc,
     mon_l2 => monitor_cache_none,
     mon_llc => monitor_cache_none,
     mon_acc => monitor_acc_none,
     mon_dvfs => mon_dvfs_int,
     config => config,
     srst => open,
     apbi => apbi,
     apbo => apbo(0)
   );


  -----------------------------------------------------------------------------
  -- Tile queues
  -----------------------------------------------------------------------------

  empty_tile_q_1 : empty_tile_q
    generic map (
      tech => CFG_FABTECH)
    port map (
      rst                        => rst,
      clk                        => sys_clk_int,
      apb_snd_wrreq              => apb_snd_wrreq,
      apb_snd_data_in            => apb_snd_data_in,
      apb_snd_full               => apb_snd_full,
      apb_rcv_rdreq              => apb_rcv_rdreq,
      apb_rcv_data_out           => apb_rcv_data_out,
      apb_rcv_empty              => apb_rcv_empty,
      noc1_out_data              => noc1_output_port,
      noc1_out_void              => noc1_mem_data_void_out,
      noc1_out_stop              => noc1_mem_stop_in,
      noc1_in_data               => noc1_input_port,
      noc1_in_void               => noc1_mem_data_void_in,
      noc1_in_stop               => noc1_mem_stop_out,
      noc2_out_data              => noc2_output_port,
      noc2_out_void              => noc2_mem_data_void_out,
      noc2_out_stop              => noc2_mem_stop_in,
      noc2_in_data               => noc2_input_port,
      noc2_in_void               => noc2_mem_data_void_in,
      noc2_in_stop               => noc2_mem_stop_out,
      noc3_out_data              => noc3_output_port,
      noc3_out_void              => noc3_mem_data_void_out,
      noc3_out_stop              => noc3_mem_stop_in,
      noc3_in_data               => noc3_input_port,
      noc3_in_void               => noc3_mem_data_void_in,
      noc3_in_stop               => noc3_mem_stop_out,
      noc4_out_data              => noc4_output_port,
      noc4_out_void              => noc4_mem_data_void_out,
      noc4_out_stop              => noc4_mem_stop_in,
      noc4_in_data               => noc4_input_port,
      noc4_in_void               => noc4_mem_data_void_in,
      noc4_in_stop               => noc4_mem_stop_out,
      noc5_out_data              => noc5_output_port,
      noc5_out_void              => noc5_mem_data_void_out,
      noc5_out_stop              => noc5_mem_stop_in,
      noc5_in_data               => noc5_input_port,
      noc5_in_void               => noc5_mem_data_void_in,
      noc5_in_stop               => noc5_mem_stop_out,
      noc6_out_data              => noc6_output_port,
      noc6_out_void              => noc6_mem_data_void_out,
      noc6_out_stop              => noc6_mem_stop_in,
      noc6_in_data               => noc6_input_port,
      noc6_in_void               => noc6_mem_data_void_in,
      noc6_in_stop               => noc6_mem_stop_out);


  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------

  noc1_stop_in_s         <= noc1_mem_stop_in  & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_mem_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_mem_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_mem_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_mem_stop_in  & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_mem_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_mem_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_mem_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_mem_stop_in  & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_mem_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_mem_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_mem_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_mem_stop_in  & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_mem_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_mem_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_mem_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_mem_stop_in  & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_mem_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_mem_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_mem_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_mem_stop_in  & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_mem_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_mem_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_mem_data_void_out <= noc6_data_void_out_s(4);

  sync_noc_set_empty : sync_noc_set
    generic map (
      PORTS    => ROUTER_PORTS,
      HAS_SYNC => HAS_SYNC)
    port map (
      clk                => sys_clk_int,
      clk_tile           => sys_clk_int,
      rst                => rst,
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


end;
