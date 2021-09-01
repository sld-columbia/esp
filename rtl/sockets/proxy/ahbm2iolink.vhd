-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

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
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity ahbm2iolink is
  generic (
    hindex        : integer range 0 to NAHBSLV - 1;
    io_bitwidth   : integer range 1 to ARCH_BITS := 32;  -- power of 2, <= word_bitwidth
    word_bitwidth : integer range 1 to ARCH_BITS := 32;  -- 32 or 64
    little_end    : integer range 0 to 1         := 0);
  port (
    clk           : in  std_ulogic;
    rstn          : in  std_ulogic;
    io_clk_in     : in  std_logic;
    io_clk_out    : out std_logic;
    io_valid_in   : in  std_ulogic;
    io_valid_out  : out std_ulogic;
    io_credit_in  : in  std_logic;
    io_credit_out : out std_logic;
    io_data_oen   : out std_logic;
    io_data_in    : in  std_logic_vector(io_bitwidth - 1 downto 0);
    io_data_out   : out std_logic_vector(io_bitwidth - 1 downto 0);
    ahbmi         : in  ahb_mst_in_type;
    ahbmo         : out ahb_mst_out_type);

end entity ahbm2iolink;

architecture rtl of ahbm2iolink is

begin

  io_data_out   <= (others => '0');
  io_valid_out  <= '0';
  io_clk_out    <= '0';
  io_credit_out <= '0';
  ahbmo         <= ahbm_none;

end architecture rtl;
