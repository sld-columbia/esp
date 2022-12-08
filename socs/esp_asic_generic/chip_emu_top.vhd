-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
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
library unisim;
use unisim.VCOMPONENTS.all;
-- pragma translate_off
use work.sim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity chip_emu_top is
  generic (
    SIMULATION : boolean := false);
  port (
    reset           : in    std_logic;
    -- Chip clock used for emulation on FPGA only
    clk_emu_p       : in    std_logic;
    clk_emu_n       : in    std_logic;
    -- Backup external clocks for selected tiles and NoC (unused for emulation)
    ext_clk         : in    std_logic;
    -- FPGA proxy memory link
    fpga_data       : inout std_logic_vector(CFG_NMEM_TILE * 64 - 1 downto 0);
    fpga_valid_in   : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_valid_out  : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_in     : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_out    : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_in  : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_out : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    -- I/O link
    iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_valid_in   : in    std_ulogic;
    iolink_valid_out  : out   std_ulogic;
    iolink_clk_in     : in    std_ulogic;
    iolink_clk_out    : out   std_ulogic;
    iolink_credit_in  : in    std_ulogic;
    iolink_credit_out : out   std_ulogic;
-- Ethernet signals
    reset_o2        : out   std_ulogic;
    etx_clk         : in    std_ulogic;
    erx_clk         : in    std_ulogic;
    erxd            : in    std_logic_vector(3 downto 0);
    erx_dv          : in    std_ulogic;
    erx_er          : in    std_ulogic;
    erx_col         : in    std_ulogic;
    erx_crs         : in    std_ulogic;
    etxd            : out   std_logic_vector(3 downto 0);
    etx_en          : out   std_ulogic;
    etx_er          : out   std_ulogic;
    emdc            : out   std_ulogic;
    emdio           : inout std_logic;
    -- UART
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    --JTAG
    tclk            : in    std_logic;
    tms             : in    std_logic;
    tdi_io          : in    std_logic;
    tdi_cpu         : in    std_logic;
    tdi_mem         : in    std_logic;
    tdi_acc         : in    std_logic;
    tdo_io          : out   std_logic;
    tdo_cpu         : out   std_logic;
    tdo_mem         : out   std_logic;
    tdo_acc         : out   std_logic
);
end chip_emu_top;


architecture rtl of chip_emu_top is

  -----------------------------------------------------------------------------
  -- ESP chip specific instance
  -----------------------------------------------------------------------------
  component ESP_ASIC_TOP is
    generic (
      SIMULATION : boolean);
    port (
      reset           : in    std_logic;
      ext_clk         : in    std_logic;
      fpga_data       : inout std_logic_vector(CFG_NMEM_TILE * 64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      fpga_valid_out  : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      fpga_clk_in     : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      fpga_clk_out    : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      fpga_credit_in  : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      fpga_credit_out : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      reset_o2        : out   std_ulogic;
      -- I/O link
      iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in   : in    std_ulogic;
      iolink_valid_out  : out   std_ulogic;
      iolink_clk_in     : in    std_ulogic;
      iolink_clk_out    : out   std_ulogic;
      iolink_credit_in  : in    std_ulogic;
      iolink_credit_out : out   std_ulogic;
      --Ethernet signals
      etx_clk         : in    std_ulogic;
      erx_clk         : in    std_ulogic;
      erxd            : in    std_logic_vector(3 downto 0);
      erx_dv          : in    std_ulogic;
      erx_er          : in    std_ulogic;
      erx_col         : in    std_ulogic;
      erx_crs         : in    std_ulogic;
      etxd            : out   std_logic_vector(3 downto 0);
      etx_en          : out   std_ulogic;
      etx_er          : out   std_ulogic;
      emdc            : out   std_ulogic;
      emdio           : inout std_logic;
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      --JTAG
      tclk            : in    std_logic;
      tms             : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_cpu         : in    std_logic;
      tdi_mem         : in    std_logic;
      tdi_acc         : in    std_logic;
      tdo_io          : out    std_logic;
      tdo_cpu         : out    std_logic;
      tdo_mem         : out    std_logic;
      tdo_acc         : out    std_logic
  );
  end component ESP_ASIC_TOP;

  signal ext_clk_int : std_logic;

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of ext_clk_int : signal is true;
  attribute syn_keep of ext_clk_int : signal is "true";

begin  -- architecture rtl

  clk_emu_gen: if ESP_EMU /= 0 generate
    clk_emu_buf : ibufgds
      generic map(
        IBUF_LOW_PWR => FALSE
        )
      port map (
        I  => clk_emu_p,
        IB => clk_emu_n,
        O  => ext_clk_int
        );

  end generate clk_emu_gen;

  chip_clk_gen: if ESP_EMU = 0 generate
    ext_clk_int <= ext_clk;
  end generate chip_clk_gen;


  chip_i : ESP_ASIC_TOP
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset              => reset,
      ext_clk            => ext_clk_int,
      fpga_data          => fpga_data,
      fpga_valid_in      => fpga_valid_in,
      fpga_valid_out     => fpga_valid_out,
      fpga_clk_in        => fpga_clk_in,
      fpga_clk_out       => fpga_clk_out,
      fpga_credit_in     => fpga_credit_in,
      fpga_credit_out    => fpga_credit_out,
      iolink_data        => iolink_data,
      iolink_valid_in    => iolink_valid_in,
      iolink_valid_out   => iolink_valid_out,
      iolink_clk_in      => iolink_clk_in,
      iolink_clk_out     => iolink_clk_out,
      iolink_credit_in   => iolink_credit_in,
      iolink_credit_out  => iolink_credit_out,
      reset_o2           => reset_o2,
      etx_clk            => etx_clk,
      erx_clk            => erx_clk,
      erxd               => erxd,
      erx_dv             => erx_dv,
      erx_er             => erx_er,
      erx_col            => erx_col,
      erx_crs            => erx_crs,
      etxd               => etxd,
      etx_en             => etx_en,
      etx_er             => etx_er,
      emdc               => emdc,
      emdio              => emdio,
      uart_rxd           => uart_rxd,
      uart_txd           => uart_txd,
      uart_ctsn          => uart_ctsn,
      uart_rtsn          => uart_rtsn,
      tclk               => tclk,
      tms                => tms,
      tdi_io             => tdi_io,
      tdi_cpu            => tdi_cpu,
      tdi_mem            => tdi_mem,
      tdi_acc            => tdi_acc,
      tdo_io             => tdo_io,
      tdo_cpu            => tdo_cpu,
      tdo_mem            => tdo_mem,
      tdo_acc            => tdo_acc
  );

end architecture rtl;
