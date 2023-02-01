-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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
