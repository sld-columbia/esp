-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
-------------------------------------------------------------------------------

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
use work.jtag.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.memoryctrl.all;

entity ext2ahbm is

  port (
    clk             : in  std_ulogic;
    rstn            : in  std_ulogic;
    -- Memory link
    fpga_data_in    : out std_logic_vector(ARCH_BITS downto 0);
    fpga_data_out   : in  std_logic_vector(ARCH_BITS downto 0);
    fpga_data_ien   : out std_logic;
    fpga_clk_in     : out std_logic;
    fpga_clk_out    : in  std_logic;
    fpga_credit_in  : out std_logic;
    fpga_credit_out : in  std_logic;
    ddr_ahbsi       : out ahb_slv_in_type;
    ddr_ahbso       : in  ahb_slv_out_type);

end entity ext2ahbm;

architecture rtl of ext2ahbm is

begin  -- architecture rtl

  -- TODO: implement FPGA side of link
  fpga_data_in <= (others => '0');
  fpga_data_ien <= '0';

  fpga_clk_in <= '0';
  fpga_credit_in <= '0';
  ddr_ahbsi <= ahbs_in_none;

end architecture rtl;
