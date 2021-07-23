-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;

use work.esp_acc_regmap.all;
use work.esp_csr_pkg.all;

package dvfs is

  function tech_v (
    constant tech   : integer;
    constant vlevel : integer)
    return std_logic_vector;

  function tech_f (
    constant tech   : integer;
    constant vlevel : integer)
    return std_logic_vector;

  constant DVFS_CMD_REG : integer range 0 to MAXREGNUM-1 := 0;
  constant DVFS_CMD_UPDATE_V_BIT  : integer range 0 to 31 := 0;
  constant DVFS_CMD_UPDATE_F_BIT  : integer range 0 to 31 := 1;
  constant DVFS_CMD_UPDATE_VF_BIT : integer range 0 to 31 := 2;
  constant DVFS_CMD_REG_WIDTH     : integer range 0 to 31 := 3;

  -- Current voltage: 1 hot encoding
  constant VOLTAGE_STATUS_REG : integer range 0 to MAXREGNUM-1 := 1;
  -- Current frequency 1 hot encoding;
  constant FREQUENCY_STATUS_REG : integer range 0 to MAXREGNUM-1 := 2;
  -- Set voltage when POLICY_NONE is selected: 1 hot encoding
  constant VOLTAGE_SELECT_REG : integer range 0 to MAXREGNUM-1 := 3;
  -- Set frequency when POLICY_NONE is selected: 1 hot encoding;
  constant FREQUENCY_SELECT_REG : integer range 0 to MAXREGNUM-1 := 4;

  constant POLICY_REG : integer range 0 to MAXREGNUM-1 := 5;
  -- NONE: VF pair set by software
  -- AUTO_BUDGET: VF chosen depending on the power budget (requires current sensing)
  -- AUTO_ONDEMAND: VF chosen depending on the accelerator burstiness (used for NoC planes)
  -- AUTO_TRAFFIC: VF reacts to NoC congention
  -- AUTO_BALANCE: VF depends on communication/computation ration
  constant POLICY_NONE_BIT          : integer range 0 to 31 := 0;
  constant POLICY_AUTO_BUDGET_BIT   : integer range 0 to 31 := 1;
  constant POLICY_AUTO_ONDEMAND_BIT : integer range 0 to 31 := 2;
  constant POLICY_AUTO_TRAFFIC_BIT  : integer range 0 to 31 := 3;
  constant POLICY_AUTO_BALANCE_BIT  : integer range 0 to 31 := 4;

  -- Power budget: set the maximum allowd operation point
  constant BUDGET_REG : integer range 0 to MAXREGNUM-1 := 6;

  -- Power consumption per each VF pair
  constant POWER_VF_0_REG : integer range 0 to MAXREGNUM-1 := 7;
  constant POWER_VF_1_REG : integer range 0 to MAXREGNUM-1 := 8;
  constant POWER_VF_2_REG : integer range 0 to MAXREGNUM-1 := 9;
  constant POWER_VF_3_REG : integer range 0 to MAXREGNUM-1 := 10;

  -- Minimum period before next update in cycles
  constant MIN_WAIT_REG : integer range 0 to MAXREGNUM-1 := 11;

  -- Feedback from IVR. Ideally information on current
  constant QADC_REG : integer range 0 to MAXREGNUM-1 := 12;

  -- PLL frequency change mode: DYNAMIC (default), RESET
  constant PLL_MODE_REG : integer range 0 to MAXREGNUM-1 := 13;
  constant PLL_MODE_DFS_BIT : integer range 0 to 31 := 0;
  constant PLL_MODE_RST_BIT : integer range 0 to 31 := 1;

  -- PLICY_AUTO_WINDOW: take decision every WINDOW cycles
  -- POLICY_*_TH: slow down accelerator if below/above threshold
  constant POLICY_AUTO_WINDOW_REG : integer range 0 to MAXREGNUM-1 := 14;
  constant POLICY_ONDEMAND_TH_REG : integer range 0 to MAXREGNUM-1 := 15;
  constant POLICY_TRAFFIC_TH_REG  : integer range 0 to MAXREGNUM-1 := 16;
  constant POLICY_BALANCE_TH_REG  : integer range 0 to MAXREGNUM-1 := 17;

  component Token_FSM is
    port (
      clock                  : in  std_ulogic;
      reset                  : in  std_ulogic;
      packet_in              : in  std_ulogic;
      packet_in_val          : in  std_logic_vector(31 downto 0);
      packet_in_addr         : in  std_logic_vector(4  downto 0);
      packet_out_ready       : in  std_ulogic;
      packet_out             : out std_ulogic;
      packet_out_val         : out std_logic_vector(31 downto 0);
      packet_out_addr        : out std_logic_vector(4  downto 0);
      enable                 : in  std_ulogic;
      activity               : in  std_ulogic;
      max_tokens             : in  std_logic_vector(5  downto 0);
      token_counter_override : in  std_logic_vector(7  downto 0);
      refresh_rate_min       : in  std_logic_vector(11 downto 0);
      refresh_rate_max       : in  std_logic_vector(11 downto 0);
      random_rate            : in  std_logic_vector(4  downto 0);
      LUT_write              : in  std_logic_vector(17 downto 0);
      neighbors_ID           : in  std_logic_vector(19 downto 0);
      PM_network             : in  std_logic_vector(31 downto 0);
      tokens_next            : out std_logic_vector(6  downto 0);
      LUT_read               : out std_logic_vector(7  downto 0);
      freq_target            : out std_logic_vector(7  downto 0));
  end component Token_FSM;

  component Tile_LDO_Ctrl is
    port (
      clk         : in  std_ulogic;
      DCO_clk     : in  std_ulogic;
      reset       : in  std_ulogic;
      freq_target : in  std_logic_vector(7 downto 0);
      LDO_setup_0 : in  std_logic_vector(31 downto 0);
      LDO_setup_1 : in  std_logic_vector(31 downto 0);
      LDO_setup_2 : in  std_logic_vector(31 downto 0);
      LDO_setup_3 : in  std_logic_vector(31 downto 0);
      LDO_setup_4 : in  std_logic_vector(31 downto 0);
      LDO_debug_0 : out std_logic_vector(31 downto 0);
      LDO0        : out std_ulogic;
      LDO1        : out std_ulogic;
      LDO2        : out std_ulogic;
      LDO3        : out std_ulogic;
      LDO4        : out std_ulogic;
      LDO5        : out std_ulogic;
      LDO6        : out std_ulogic;
      LDO7        : out std_ulogic);
  end component Tile_LDO_Ctrl;

  component pm2noc is
    port (
      rstn               : in  std_ulogic;
      clk                : in  std_ulogic;
      -- tile parameters
      local_x            : in  local_yx;
      local_y            : in  local_yx;
      -- token FSM interface towards NoC
      packet_in          : out std_ulogic;
      packet_in_val      : out std_logic_vector(31 downto 0);
      packet_in_addr     : out std_logic_vector(4 downto 0);
      packet_out_ready   : out std_ulogic;
      packet_out         : in  std_ulogic;
      packet_out_val     : in  std_logic_vector(31 downto 0);
      packet_out_addr    : in  std_logic_vector(4 downto 0);
      -- NoC interface
      noc5_input_port    : out misc_noc_flit_type;
      noc5_data_void_in  : out std_ulogic;
      noc5_stop_out      : in  std_ulogic;
      noc5_output_port   : in  misc_noc_flit_type;
      noc5_data_void_out : in  std_ulogic;
      noc5_stop_in       : out std_ulogic);
  end component pm2noc;

  component token_pm is
    generic (
      SIMULATION : boolean := false;
      is_asic    : boolean := false);
    port (
      noc_rstn               : in  std_ulogic;
      tile_rstn              : in  std_ulogic;
      noc_clk                : in  std_ulogic;
      tile_clk               : in  std_ulogic;
      -- runtime configuration for LDO ctrl and token FSM
      pm_config              : in  pm_config_type;
      -- runtime status for LDO ctrl and token FSM
      pm_status              : out pm_status_type;
      -- tile parameters
      local_x                : in  local_yx;
      local_y                : in  local_yx;
      -- NoC interface
      noc5_input_port        : out misc_noc_flit_type;
      noc5_data_void_in      : out std_ulogic;
      noc5_stop_out          : in  std_ulogic;
      noc5_output_port       : in  misc_noc_flit_type;
      noc5_data_void_out     : in  std_ulogic;
      noc5_stop_in           : out std_ulogic;
      -- Accelerator tile NoC inferface
      noc5_input_port_pm     : in  misc_noc_flit_type;
      noc5_data_void_in_pm   : in  std_ulogic;
      noc5_stop_out_pm       : out std_ulogic;
      noc5_output_port_pm    : out misc_noc_flit_type;
      noc5_data_void_out_pm  : out std_ulogic;
      noc5_stop_in_pm        : in  std_ulogic;
      -- LDO switch control
      acc_clk                : out std_ulogic);

  end component token_pm;

end dvfs;

package body dvfs is

  function tech_v (
    constant tech   : integer;
    constant vlevel : integer)
    return std_logic_vector is
    variable ddac : std_logic_vector(4 downto 0);
  begin
    ddac := (others => '0');

    if tech = virtex7 or tech = virtexup then
      for i in 0 to 4 loop
        if vlevel = i then
          ddac(i) := '1';
        end if;
      end loop;  -- i
    end if;

    return ddac;
  end tech_v;

  function tech_f (
    constant tech   : integer;
    constant vlevel : integer)
    return std_logic_vector is
    variable rangea : std_logic_vector(4 downto 0);
  begin
    rangea := (others => '0');

    if tech = virtex7 or tech = virtexup then
      for i in 0 to 4 loop
        if vlevel = i then
          rangea(i) := '1';
        end if;
      end loop;  -- i
    end if;

    return rangea;
  end tech_f;

end dvfs;
