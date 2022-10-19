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
    ext_clk_noc     : in    std_logic;
    ext_clk_io      : in    std_logic;
    ext_clk_cpu     : in    std_logic;
    ext_clk_mem     : in    std_logic;
    ext_clk_acc0    : in    std_logic;
    ext_clk_acc1    : in    std_logic;
    -- FPGA proxy memory link
    fpga_data       : inout std_logic_vector(4 * 64 - 1 downto 0);
    fpga_valid_in   : in    std_logic_vector(3 downto 0);
    fpga_valid_out  : out   std_logic_vector(3 downto 0);
    fpga_clk_in     : in    std_logic_vector(3 downto 0);
    fpga_clk_out    : out   std_logic_vector(3 downto 0);
    fpga_credit_in  : in    std_logic_vector(3 downto 0);
    fpga_credit_out : out   std_logic_vector(3 downto 0);
    -- Test interface
    tdi             : in    std_logic_vector(0 to CFG_TILES_NUM - 1);
    tdo             : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
    tms             : in    std_logic;
    tclk            : in    std_logic;
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
    uart_rtsn       : out   std_logic   -- UART1_RTSN (u1o.rtsn)
    );
end chip_emu_top;


architecture rtl of chip_emu_top is

  -----------------------------------------------------------------------------
  -- ESP chip specific instance
  -----------------------------------------------------------------------------
  component EPOCHS0_TOP is
    generic (
      SIMULATION : boolean);
    port (
      reset           : in    std_logic;
      ext_clk_noc     : in    std_logic;
      ext_clk_io      : in    std_logic;
      ext_clk_cpu     : in    std_logic;
      ext_clk_mem     : in    std_logic;
      ext_clk_acc0    : in    std_logic;
      ext_clk_acc1    : in    std_logic;
      clk_div_noc     : out   std_logic;
      clk_div_io      : out   std_logic;
      clk_div_cpu     : out   std_logic;
      clk_div_mem     : out   std_logic;
      clk_div_acc0    : out   std_logic;
      clk_div_acc1    : out   std_logic;
      fpga_data       : inout std_logic_vector(4 * 64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(3 downto 0);
      fpga_valid_out  : out   std_logic_vector(3 downto 0);
      fpga_clk_in     : in    std_logic_vector(3 downto 0);
      fpga_clk_out    : out   std_logic_vector(3 downto 0);
      fpga_credit_in  : in    std_logic_vector(3 downto 0);
      fpga_credit_out : out   std_logic_vector(3 downto 0);
      tdi_cpu         : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_mem         : in    std_logic;
      tdi_acc0        : in    std_logic;
      tdi_acc1        : in    std_logic;
      tdi_acc2        : in    std_logic;
      tdi_acc3        : in    std_logic;
      tdi_acc4        : in    std_logic;
      tdi_acc5        : in    std_logic;
      tdi_acc6        : in    std_logic;
      tdi_acc7        : in    std_logic;
      tdo_cpu         : out   std_logic;
      tdo_io          : out   std_logic;
      tdo_mem         : out   std_logic;
      tdo_acc0        : out   std_logic;
      tdo_acc1        : out   std_logic;
      tdo_acc2        : out   std_logic;
      tdo_acc3        : out   std_logic;
      tdo_acc4        : out   std_logic;
      tdo_acc5        : out   std_logic;
      tdo_acc6        : out   std_logic;
      tdo_acc7        : out   std_logic;
      tms             : in    std_logic;
      tclk            : in    std_logic;
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
      -- tft_nhpd        : in    std_ulogic;
      -- tft_clk_p       : out   std_ulogic;
      -- tft_clk_n       : out   std_ulogic;
      -- tft_data        : out   std_logic_vector(23 downto 0);
      -- tft_hsync       : out   std_ulogic;
      -- tft_vsync       : out   std_ulogic;
      -- tft_de          : out   std_ulogic;
      -- tft_dken        : out   std_ulogic;
      -- tft_ctl1_a1_dk1 : out   std_ulogic;
      -- tft_ctl2_a2_dk2 : out   std_ulogic;
      -- tft_a3_dk3      : out   std_ulogic;
      -- tft_isel        : out   std_ulogic;
      -- tft_bsel        : out   std_ulogic;
      -- tft_dsel        : out   std_ulogic;
      -- tft_edge        : out   std_ulogic;
      -- tft_npd         : out   std_ulogic;
      lpddr0_ck_p     : out   std_logic;
      lpddr0_ck_n     : out   std_logic;
      lpddr0_cke      : out   std_logic;
      lpddr0_ba       : out   std_logic_vector(2 downto 0);
      lpddr0_addr     : out   std_logic_vector(15 downto 0);
      lpddr0_cs_n     : out   std_logic;
      lpddr0_ras_n    : out   std_logic;
      lpddr0_cas_n    : out   std_logic;
      lpddr0_we_n     : out   std_logic;
      lpddr0_reset_n  : out   std_logic;
      lpddr0_odt      : out   std_logic;
      lpddr0_dm       : out   std_logic_vector(3 downto 0);
      lpddr0_dqs_p    : inout std_logic_vector(3 downto 0);
      lpddr0_dqs_n    : inout std_logic_vector(3 downto 0);
      lpddr0_dq       : inout std_logic_vector(31 downto 0);
      lpddr1_ck_p     : out   std_logic;
      lpddr1_ck_n     : out   std_logic;
      lpddr1_cke      : out   std_logic;
      lpddr1_ba       : out   std_logic_vector(2 downto 0);
      lpddr1_addr     : out   std_logic_vector(15 downto 0);
      lpddr1_cs_n     : out   std_logic;
      lpddr1_ras_n    : out   std_logic;
      lpddr1_cas_n    : out   std_logic;
      lpddr1_we_n     : out   std_logic;
      lpddr1_reset_n  : out   std_logic;
      lpddr1_odt      : out   std_logic;
      lpddr1_dm       : out   std_logic_vector(3 downto 0);
      lpddr1_dqs_p    : inout std_logic_vector(3 downto 0);
      lpddr1_dqs_n    : inout std_logic_vector(3 downto 0);
      lpddr1_dq       : inout std_logic_vector(31 downto 0);
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      ivr_pmb_dat     : in    std_ulogic;
      ivr_pmb_clk     : in    std_ulogic;
      ivr_avs_clk     : in    std_ulogic;
      ivr_avs_dat     : in    std_ulogic;
      ivr_avs_sdat    : in    std_ulogic;
      ivr_control     : in    std_ulogic;
      ivr_gpio        : in    std_logic_vector(3 downto 0);
      unused          : in    std_ulogic
      );
  end component EPOCHS0_TOP;

  signal ext_clk_int : std_logic;
  signal ext_clk_noc_int : std_logic;
  signal ext_clk_io_int : std_logic;
  signal ext_clk_cpu_int : std_logic;
  signal ext_clk_mem_int : std_logic;
  signal ext_clk_acc0_int : std_logic;
  signal ext_clk_acc1_int : std_logic;

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of ext_clk_int : signal is true;
  attribute syn_keep of ext_clk_int : signal is "true";

begin  -- architecture rtl

  -- JTAG output pins
  unused_interface_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    unused_td_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) and i /= mem_tile_id(1) and i /= mem_tile_id(2) and i /= mem_tile_id(3)
                         and i /= 8 and i /= 4 and i /= 1 and i /= 2 and i /= 15 generate
      tdo(i) <= '0';
    end generate unused_td_io_gen;
  end generate unused_interface_gen;

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

    ext_clk_noc_int <= ext_clk_int;
    ext_clk_io_int <= ext_clk_int;
    ext_clk_cpu_int <= ext_clk_int;
    ext_clk_mem_int <= ext_clk_int;
    ext_clk_acc0_int <= ext_clk_int;
    ext_clk_acc1_int <= ext_clk_int;

  end generate clk_emu_gen;

  chip_clk_gen: if ESP_EMU = 0 generate
    ext_clk_noc_int <= ext_clk_noc;
    ext_clk_io_int <= ext_clk_io;
    ext_clk_cpu_int <= ext_clk_cpu;
    ext_clk_mem_int <= ext_clk_mem;
    ext_clk_acc0_int <= ext_clk_acc0;
    ext_clk_acc1_int <= ext_clk_acc1;
  end generate chip_clk_gen;


  chip_i : EPOCHS0_TOP
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset           => reset,
      ext_clk_noc     => ext_clk_noc_int,
      ext_clk_io      => ext_clk_io_int,
      ext_clk_cpu     => ext_clk_cpu_int,
      ext_clk_mem     => ext_clk_mem_int,
      ext_clk_acc0    => ext_clk_acc0_int,
      ext_clk_acc1    => ext_clk_acc1_int,
      clk_div_noc     => open,
      clk_div_io      => open,
      clk_div_cpu     => open,
      clk_div_mem     => open,
      clk_div_acc0    => open,
      clk_div_acc1    => open,
      fpga_data       => fpga_data,
      fpga_valid_in   => fpga_valid_in,
      fpga_valid_out  => fpga_valid_out,
      fpga_clk_in     => fpga_clk_in,
      fpga_clk_out    => fpga_clk_out,
      fpga_credit_in  => fpga_credit_in,
      fpga_credit_out => fpga_credit_out,
      tdi_cpu         => tdi(cpu_tile_id(0)),
      tdi_io          => tdi(io_tile_id),
      tdi_mem         => tdi(mem_tile_id(0)),
      tdi_acc0        => tdi(8),
      tdi_acc1        => tdi(4),
      tdi_acc2        => tdi(1),
      tdi_acc3        => tdi(2),
      tdi_acc4        => tdi(mem_tile_id(1)),
      tdi_acc5        => tdi(15),
      tdi_acc6        => tdi(mem_tile_id(3)),
      tdi_acc7        => tdi(mem_tile_id(2)),
      tdo_cpu         => tdo(cpu_tile_id(0)),
      tdo_io          => tdo(io_tile_id),
      tdo_mem         => tdo(mem_tile_id(0)),
      tdo_acc0        => tdo(8),
      tdo_acc1        => tdo(4),
      tdo_acc2        => tdo(1),
      tdo_acc3        => tdo(2),
      tdo_acc4        => tdo(mem_tile_id(1)),
      tdo_acc5        => tdo(15),
      tdo_acc6        => tdo(mem_tile_id(3)),
      tdo_acc7        => tdo(mem_tile_id(2)),
      tms             => tms,
      tclk            => tclk,
      reset_o2        => reset_o2,
      etx_clk         => etx_clk,
      erx_clk         => erx_clk,
      erxd            => erxd,
      erx_dv          => erx_dv,
      erx_er          => erx_er,
      erx_col         => erx_col,
      erx_crs         => erx_crs,
      etxd            => etxd,
      etx_en          => etx_en,
      etx_er          => etx_er,
      emdc            => emdc,
      emdio           => emdio,
      -- tft_nhpd        => tft_nhpd,
      -- tft_clk_p       => tft_clk_p,
      -- tft_clk_n       => tft_clk_n,
      -- tft_data        => tft_data,
      -- tft_hsync       => tft_hsync,
      -- tft_vsync       => tft_vsync,
      -- tft_de          => tft_de,
      -- tft_dken        => tft_dken,
      -- tft_ctl1_a1_dk1 => tft_ctl1_a1_dk1,
      -- tft_ctl2_a2_dk2 => tft_ctl2_a2_dk2,
      -- tft_a3_dk3      => tft_a3_dk3,
      -- tft_isel        => tft_isel,
      -- tft_bsel        => tft_bsel,
      -- tft_dsel        => tft_dsel,
      -- tft_edge        => tft_edge,
      -- tft_npd         => tft_npd,
      lpddr0_ck_p     => open,
      lpddr0_ck_n     => open,
      lpddr0_cke      => open,
      lpddr0_ba       => open,
      lpddr0_addr     => open,
      lpddr0_cs_n     => open,
      lpddr0_ras_n    => open,
      lpddr0_cas_n    => open,
      lpddr0_we_n     => open,
      lpddr0_reset_n  => open,
      lpddr0_odt      => open,
      lpddr0_dm       => open,
      lpddr0_dqs_p    => open,
      lpddr0_dqs_n    => open,
      lpddr0_dq       => open,
      lpddr1_ck_p     => open,
      lpddr1_ck_n     => open,
      lpddr1_cke      => open,
      lpddr1_ba       => open,
      lpddr1_addr     => open,
      lpddr1_cs_n     => open,
      lpddr1_ras_n    => open,
      lpddr1_cas_n    => open,
      lpddr1_we_n     => open,
      lpddr1_reset_n  => open,
      lpddr1_odt      => open,
      lpddr1_dm       => open,
      lpddr1_dqs_p    => open,
      lpddr1_dqs_n    => open,
      lpddr1_dq       => open,
      uart_rxd        => uart_rxd,
      uart_txd        => uart_txd,
      uart_ctsn       => uart_ctsn,
      uart_rtsn       => uart_rtsn,
      ivr_pmb_dat     => '0',
      ivr_pmb_clk     => '0',
      ivr_avs_clk     => '0',
      ivr_avs_dat     => '0',
      ivr_avs_sdat    => '0',
      ivr_control     => '0',
      ivr_gpio        => (others => '0'),
      unused          => '0'
      );

end architecture rtl;
