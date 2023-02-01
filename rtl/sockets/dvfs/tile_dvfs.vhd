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
use work.dvfs.all;

use work.esp_acc_regmap.all;

entity tile_dvfs is
  generic (
    tech          :     integer := virtex7;
    pindex        :     integer := 0);
  port (
    rst           : in  std_ulogic;
    clk           : in  std_ulogic;
    -- APB interface
    paddr         : in  integer;
    pmask         : in  integer;
    apbi          : in  apb_slv_in_type;
    apbo          : out apb_slv_out_type;
    -- DVFS interface
    clear_command : in  std_ulogic;
    sample_status : in  std_ulogic;
    voltage       : in  std_logic_vector(31 downto 0);
    frequency     : in  std_logic_vector(31 downto 0);
    qadc          : in  std_logic_vector(31 downto 0);  -- Feedback from IVR
    -- DVFS registers
    bank          : out bank_type(0 to MAXREGNUM - 1)
    );

end tile_dvfs;

architecture rtl of tile_dvfs is

  -- APB interface signals and constants
  constant REVISION : integer := 0;

  -- Read only registers mask
  constant rdonly_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (
    VOLTAGE_STATUS_REG => '1',
    FREQUENCY_STATUS_REG => '1',
    QADC_REG => '1',
    others => '0');
  -- Available registers mask
  constant available_reg_mask  : std_logic_vector(0 to MAXREGNUM - 1):= (
    DVFS_CMD_REG => '1',
    VOLTAGE_STATUS_REG => '1',
    FREQUENCY_STATUS_REG => '1',
    VOLTAGE_SELECT_REG => '1',
    FREQUENCY_SELECT_REG => '1',
    POLICY_REG => '1',
    BUDGET_REG => '1',
    POWER_VF_0_REG => '1',
    POWER_VF_1_REG => '1',
    POWER_VF_2_REG => '1',
    POWER_VF_3_REG => '1',
    MIN_WAIT_REG => '1',
    QADC_REG => '1',
    PLL_MODE_REG => '1',
    POLICY_AUTO_WINDOW_REG => '1',
    POLICY_ONDEMAND_TH_REG => '1',
    POLICY_TRAFFIC_TH_REG  => '1',
    POLICY_BALANCE_TH_REG  => '1',
    others => '0');

  constant bankdef : bank_type(0 to MAXREGNUM-1) := (
    DVFS_CMD_REG           => x"00000000",              -- no command
    VOLTAGE_STATUS_REG     => x"00000008",              -- V0: highest (status)
    FREQUENCY_STATUS_REG   => x"00000008",              -- F0: highest (status)
    VOLTAGE_SELECT_REG     => x"00000008",              -- V0: highest (select)
    FREQUENCY_SELECT_REG   => x"00000008",              -- F0: highest (select)
    POLICY_REG             => x"00000001",              -- policy_none
    BUDGET_REG             => x"00000008",              -- fastest/highest
    POWER_VF_0_REG         => x"00000000",              -- unset
    POWER_VF_1_REG         => x"00000000",              -- unset
    POWER_VF_2_REG         => x"00000000",              -- unset
    POWER_VF_3_REG         => x"00000000",              -- unset
    MIN_WAIT_REG           => x"00000020",              -- 32 cycles
    QADC_REG               => x"00000000",              -- unset
    PLL_MODE_REG           => x"00000001",              -- dynamic
    POLICY_AUTO_WINDOW_REG => x"00000100",              -- 256 cycles
    POLICY_ONDEMAND_TH_REG => x"00000040",              -- 64 cycles
    POLICY_TRAFFIC_TH_REG  => x"00000100",              -- 256 cycles
    POLICY_BALANCE_TH_REG  => x"00000100",              -- 256 cycles
    others => (others => '0'));
  signal bankreg : bank_type(0 to MAXREGNUM - 1);
  signal bankin  : bank_type(0 to MAXREGNUM - 1);
  signal sample  : std_logic_vector(0 to MAXREGNUM - 1);
  signal readdata : std_logic_vector(31 downto 0);


begin  -- rtl

  -- APB Interface
  apbo.prdata  <= readdata;
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig(0) <= ahb_device_reg (VENDOR_SLD, SLD_POWERCTRL, 0, revision, 0);
  apbo.pconfig(1) <= apb_iobar(paddr, pmask);
  apbo.pconfig(2) <= (others => '0');

  reg_out: for i in 0 to MAXREGNUM - 1 generate
    bank(i) <= bankreg(i);
  end generate reg_out;

  -- rd/wr registers
  process(apbi, bankreg)
    variable addr : integer range 0 to MAXREGNUM - 1;
  begin
    addr := conv_integer(apbi.paddr(6 downto 2));

    bankin <= (others => (others => '0'));
    sample <= (others => '0');

    -- DVFS controller is selected when paddr(7) is '1'
    -- Accelerator is selected when paddr(7) is '0'
    if apbi.paddr(7) = '1' then
      sample(addr) <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
    end if;
    bankin(addr) <= apbi.pwdata;
    readdata <= bankreg(addr);
  end process;

  -- Other registers
  registers: for i in 0 to MAXREGNUM - 1 generate
    written_from_noc: if available_reg_mask(i) = '1' and i /= CMD_REG and rdonly_reg_mask(i) = '0' generate
      process (clk)
      begin  -- process
        if clk'event and clk = '1' then  -- rising clock edge
          if rst = '0' then                   -- synchronous reset (active low)
            bankreg(i) <= bankdef(i);
          elsif sample(i) = '1' then
            bankreg(i) <= bankin(i);
          end if;
        end if;
      end process;
    end generate written_from_noc;

    command_register: if i = DVFS_CMD_REG generate
      process (clk)
      begin  -- process
        if clk'event and clk = '1' then  -- rising clock edge
          if rst = '0' then                   -- synchronous reset (active low)
            bankreg(i) <= bankdef(i);
          else
            -- Clear command register
            if clear_command = '1' then
              bankreg(i) <= (others => '0');
            end if;
            -- read/write from NoC
            if sample(i) = '1' then
              bankreg(i) <= bankin(i);
            end if;
          end if;
        end if;
      end process;
    end generate command_register;

  end generate registers;

  status_registers: process (clk)
  begin  -- process
    if clk'event and clk = '1' then  -- rising clock edge
      if rst = '0' then                   -- synchronous reset (active low)
          bankreg(VOLTAGE_STATUS_REG) <= bankdef(VOLTAGE_STATUS_REG);
          bankreg(FREQUENCY_STATUS_REG) <= bankdef(FREQUENCY_STATUS_REG);
          bankreg(QADC_REG) <= bankdef(QADC_REG);
      else
        -- Update status registers
        if sample_status = '1' then
          bankreg(VOLTAGE_STATUS_REG) <= voltage;
          bankreg(FREQUENCY_STATUS_REG) <= frequency;
        end if;
        -- Current feedback is always updated
        bankreg(QADC_REG) <= qadc;
      end if;
    end if;
  end process status_registers;

  unused_registers: for i in 0 to MAXREGNUM - 1 generate
    not_available: if available_reg_mask(i) = '0' generate
      bankreg(i) <= (others => '0');
    end generate not_available;
  end generate unused_registers;


end rtl;
