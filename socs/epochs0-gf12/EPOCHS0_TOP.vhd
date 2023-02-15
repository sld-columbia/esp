-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.tiles_asic_pkg.all;
use work.pads_loc.all;


entity EPOCHS0_TOP is
  generic (
    SIMULATION : boolean := false);
  port (
    reset           : in    std_logic;
    -- Backup external clocks for selected tiles and NoC
    ext_clk_noc     : in    std_logic;
    ext_clk_io      : in    std_logic;
    ext_clk_cpu     : in    std_logic;
    ext_clk_mem     : in    std_logic;
    ext_clk_acc0    : in    std_logic;
    ext_clk_acc1    : in    std_logic;
    -- Test clock output (DCO divided clock) for selected tiles and NoC
    clk_div_noc     : out   std_logic;
    clk_div_io      : out   std_logic;
    clk_div_cpu     : out   std_logic;
    clk_div_mem     : out   std_logic;
    clk_div_acc0    : out   std_logic;
    clk_div_acc1    : out   std_logic;
    -- FPGA proxy memory link
    fpga_data       : inout std_logic_vector(4 * 64 - 1 downto 0);
    fpga_valid_in   : in    std_logic_vector(3 downto 0);
    fpga_valid_out  : out   std_logic_vector(3 downto 0);
    fpga_clk_in     : in    std_logic_vector(3 downto 0);
    fpga_clk_out    : out   std_logic_vector(3 downto 0);
    fpga_credit_in  : in    std_logic_vector(3 downto 0);
    fpga_credit_out : out   std_logic_vector(3 downto 0);
    -- Test interface
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
    -- -- DVI
    -- tft_nhpd        : in    std_ulogic;  -- Hot plug
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
    -- LPDDR0
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
    -- LPDDR1
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
    -- UART
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    -- IVR
    ivr_pmb_dat     : in    std_ulogic;
    ivr_pmb_clk     : in    std_ulogic;
    ivr_avs_clk     : in    std_ulogic;
    ivr_avs_dat     : in    std_ulogic;
    ivr_avs_sdat    : in    std_ulogic;
    ivr_control     : in    std_ulogic;
    ivr_gpio        : in    std_logic_vector(3 downto 0);
    -- Unused
    unused          : in    std_ulogic
    );
end;



architecture rtl of EPOCHS0_TOP is


  type handshake_vec is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(3 downto 0);

  -- NOC Signals
  signal noc1_data_n_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_in  : handshake_vec;
  signal noc1_stop_in       : handshake_vec;
  signal noc1_data_n_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_out : handshake_vec;
  signal noc1_stop_out      : handshake_vec;
  signal noc2_data_n_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_in  : handshake_vec;
  signal noc2_stop_in       : handshake_vec;
  signal noc2_data_n_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_out : handshake_vec;
  signal noc2_stop_out      : handshake_vec;
  signal noc3_data_n_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_in  : handshake_vec;
  signal noc3_stop_in       : handshake_vec;
  signal noc3_data_n_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_out : handshake_vec;
  signal noc3_stop_out      : handshake_vec;
  signal noc4_data_n_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_in  : handshake_vec;
  signal noc4_stop_in       : handshake_vec;
  signal noc4_data_n_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_out : handshake_vec;
  signal noc4_stop_out      : handshake_vec;
  signal noc5_data_n_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_in     : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_in  : handshake_vec;
  signal noc5_stop_in       : handshake_vec;
  signal noc5_data_n_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_out    : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_out : handshake_vec;
  signal noc5_stop_out      : handshake_vec;
  signal noc6_data_n_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_in     : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_in  : handshake_vec;
  signal noc6_stop_in       : handshake_vec;
  signal noc6_data_n_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_out    : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_out : handshake_vec;
  signal noc6_stop_out      : handshake_vec;

  -- Global NoC reset and clock
  signal sys_clk  : std_ulogic;
  signal sys_rstn : std_ulogic;
  signal sys_clk_lock : std_ulogic;

  -- I/O for PADS
  constant pad_fixed_cfg : std_logic_vector(19 - (ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB + 1) downto 0) := (others => '0');
  type pad_cfg_full_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(19 downto 0);
  type pad_cfg_array is array (0 to CFG_TILES_NUM - 1) of std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
  -- Current default configuration is SR=0, DS1=1, DS0=1
  signal pad_cfg : pad_cfg_array;
  signal full_pad_cfg : pad_cfg_full_array;

  -- External clocks and reset
  signal reset_int   : std_logic;
  signal ext_clk_int : std_logic_vector(0 to CFG_TILES_NUM - 1);  -- backup tile clock
  signal clk_div_int : std_logic_vector(0 to CFG_TILES_NUM - 1);  -- tile clock monitor for testing purposes
  signal ext_clk_noc_int : std_logic;
  signal clk_div_noc_int : std_logic;

  -- Test interface
  signal tdi_int  : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tdo_int  : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tms_int  : std_logic;
  signal tclk_int : std_logic;

  -- FPGA proxy
  signal fpga_oen            : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_data_in        : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_data_out       : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_valid_in_int   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in_int     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out_int    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out_int : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);

  -- Use thsese signals to swap pads connection based on pin location
  signal fpga_oen_swap        : std_logic_vector(4 * 64 - 1 downto 0);
  signal fpga_data_in_swap    : std_logic_vector(4 * 64 - 1 downto 0);
  signal fpga_data_out_swap   : std_logic_vector(4 * 64 - 1 downto 0);
  signal fpga_valid_in_swap   : std_logic_vector(3 downto 0);
  signal fpga_valid_out_swap  : std_logic_vector(3 downto 0);
  signal fpga_clk_in_swap     : std_logic_vector(3 downto 0);
  signal fpga_clk_out_swap    : std_logic_vector(3 downto 0);
  signal fpga_credit_in_swap  : std_logic_vector(3 downto 0);
  signal fpga_credit_out_swap : std_logic_vector(3 downto 0);
  signal fpga_data_pad_cfg    : std_logic_vector(4 * 64 * 20 - 1 downto 0);
  signal fpga_c_pad_cfg       : std_logic_vector(4 * 20 - 1 downto 0);

  -- Ethernet signals
  signal reset_o2_int    : std_ulogic;
  signal etx_clk_int     : std_ulogic;
  signal erx_clk_int     : std_ulogic;
  signal erxd_int        : std_logic_vector(3 downto 0);
  signal erx_dv_int      : std_ulogic;
  signal erx_er_int      : std_ulogic;
  signal erx_col_int     : std_ulogic;
  signal erx_crs_int     : std_ulogic;
  signal etxd_int        : std_logic_vector(3 downto 0);
  signal etx_en_int      : std_ulogic;
  signal etx_er_int      : std_ulogic;
  signal emdc_int        : std_ulogic;
  signal emdio_i         : std_logic;
  signal emdio_o         : std_logic;
  signal emdio_oe        : std_logic;
  -- -- DVI
  -- signal dvi_nhpd        : std_ulogic;
  -- signal dvi_data        : std_logic_vector(23 downto 0);
  -- signal dvi_hsync       : std_ulogic;
  -- signal dvi_vsync       : std_ulogic;
  -- signal dvi_de          : std_ulogic;
  -- signal dvi_dken        : std_ulogic;
  -- signal dvi_ctl1_a1_dk1 : std_ulogic;
  -- signal dvi_ctl2_a2_dk2 : std_ulogic;
  -- signal dvi_a3_dk3      : std_ulogic;
  -- signal dvi_isel        : std_ulogic;
  -- signal dvi_bsel        : std_ulogic;
  -- signal dvi_dsel        : std_ulogic;
  -- signal dvi_edge        : std_ulogic;
  -- signal dvi_npd         : std_ulogic;
  -- signal clkvga_p        : std_ulogic;
  -- signal clkvga_n        : std_ulogic;
  -- UART
  signal uart_rxd_int    : std_logic;   -- UART1_RX (u1i.rxd)
  signal uart_txd_int    : std_logic;   -- UART1_TX (u1o.txd)
  signal uart_ctsn_int   : std_logic;   -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int   : std_logic;   -- UART1_RTSN (u1o.rtsn)

begin

  -----------------------------------------------------------------------------
  -- PADS
  -----------------------------------------------------------------------------

  pad_cfg_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    full_pad_cfg(i) <= pad_fixed_cfg & pad_cfg(i);
  end generate pad_cfg_gen;

  -- External clocks and reset and test interface
  reset_pad : inpad generic map (loc => reset_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (reset, reset_int);

  -- ext_clk and div_clk for NoC (DCO located in the I/O tile)
  ext_clk_noc_pad : inpad generic map (loc => ext_clk_noc_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_noc, ext_clk_noc_int);
  clk_div_noc_pad : outpad generic map (loc => clk_div_noc_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_noc, clk_div_noc_int, full_pad_cfg(io_tile_id));

  -----------------------------------------------------------------------------
  -- chip-specific pads mapping (based on pin availability and selected tiles)
  -- TODO: add selection for this mapping to ESP GUI
  -- ext_clk and div_clk for I/O tile
  ext_clk_io_pad : inpad generic map (loc => ext_clk_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_io, ext_clk_int(io_tile_id));
  clk_div_io_pad : outpad generic map (loc => clk_div_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_io, clk_div_int(io_tile_id), full_pad_cfg(io_tile_id));
  -- ext_clk and div_clk for CPU are close to CPU0
  ext_clk_cpu_pad : inpad generic map (loc => ext_clk_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_cpu, ext_clk_int(cpu_tile_id(0)));
  clk_div_cpu_pad : outpad generic map (loc => clk_div_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_cpu, clk_div_int(cpu_tile_id(0)), full_pad_cfg(cpu_tile_id(0)));
  -- ext_clk and div_clk for memory tile are close to MEM0
  ext_clk_mem_pad : inpad generic map (loc => ext_clk_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_mem, ext_clk_int(mem_tile_id(0)));
  clk_div_mem_pad : outpad generic map (loc => clk_div_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_mem, clk_div_int(mem_tile_id(0)), full_pad_cfg(mem_tile_id(0)));
  -- ext_clk and div_clk for accelerator0 are close to tile 1
  ext_clk_acc0_pad : inpad generic map (loc => ext_clk_acc0_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_acc0, ext_clk_int(1));
  clk_div_acc0_pad : outpad generic map (loc => clk_div_acc0_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_acc0, clk_div_int(1), full_pad_cfg(1));
  -- ext_clk and div_clk for accelerator1 are close to tile 12
  ext_clk_acc1_pad : inpad generic map (loc => ext_clk_acc1_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk_acc1, ext_clk_int(12));
  clk_div_acc1_pad : outpad generic map (loc => clk_div_acc1_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div_acc1, clk_div_int(12), full_pad_cfg(12));
  -- tdi/o_cpu
  tdi_cpu_pad : inpad generic map (loc => tdi_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_cpu, tdi_int(cpu_tile_id(0)));
  tdo_cpu_pad : outpad generic map (loc => tdo_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_cpu, tdo_int(cpu_tile_id(0)), full_pad_cfg(cpu_tile_id(0)));
  -- tdi/o_io
  tdi_io_pad : inpad generic map (loc => tdi_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_io, tdi_int(io_tile_id));
  tdo_io_pad : outpad generic map (loc => tdo_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_io, tdo_int(io_tile_id), full_pad_cfg(io_tile_id));
  -- tdi/o_mem pad is close to memory tile 0
  tdi_mem_pad : inpad generic map (loc => tdi_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_mem, tdi_int(mem_tile_id(0)));
  tdo_mem_pad : outpad generic map (loc => tdo_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_mem, tdo_int(mem_tile_id(0)), full_pad_cfg(mem_tile_id(0)));
  -- tdi/o_acc0
  tdi_acc0_pad : inpad generic map (loc => tdi_acc0_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc0, tdi_int(8));
  tdo_acc0_pad : outpad generic map (loc => tdo_acc0_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc0, tdo_int(8), full_pad_cfg(8));
  -- tdi/o_acc1
  tdi_acc1_pad : inpad generic map (loc => tdi_acc1_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc1, tdi_int(4));
  tdo_acc1_pad : outpad generic map (loc => tdo_acc1_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc1, tdo_int(4), full_pad_cfg(4));
  -- tdi/o_acc2
  tdi_acc2_pad : inpad generic map (loc => tdi_acc2_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc2, tdi_int(1));
  tdo_acc2_pad : outpad generic map (loc => tdo_acc2_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc2, tdo_int(1), full_pad_cfg(1));
  -- tdi/o_acc3
  tdi_acc3_pad : inpad generic map (loc => tdi_acc3_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc3, tdi_int(2));
  tdo_acc3_pad : outpad generic map (loc => tdo_acc3_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc3, tdo_int(2), full_pad_cfg(2));
  -- tdi/o_acc4 pad is close to memory tile 1
  tdi_acc4_pad : inpad generic map (loc => tdi_acc4_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc4, tdi_int(mem_tile_id(1)));
  tdo_acc4_pad : outpad generic map (loc => tdo_acc4_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc4, tdo_int(mem_tile_id(1)), full_pad_cfg(mem_tile_id(1)));
  -- tdi/o_acc5
  tdi_acc5_pad : inpad generic map (loc => tdi_acc5_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc5, tdi_int(15));
  tdo_acc5_pad : outpad generic map (loc => tdo_acc5_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc5, tdo_int(15), full_pad_cfg(15));
  -- tdi/o_acc6 is close to memory tile 3
  tdi_acc6_pad : inpad generic map (loc => tdi_acc6_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc6, tdi_int(mem_tile_id(3)));
  tdo_acc6_pad : outpad generic map (loc => tdo_acc6_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc6, tdo_int(mem_tile_id(3)), full_pad_cfg(mem_tile_id(3)));
  -- tdi/o_acc7 is close to memory tile 2
  tdi_acc7_pad : inpad generic map (loc => tdi_acc7_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc7, tdi_int(mem_tile_id(2)));
  tdo_acc7_pad : outpad generic map (loc => tdo_acc7_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc7, tdo_int(mem_tile_id(2)), full_pad_cfg(mem_tile_id(2)));

  unused_interface_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    unused_ext_clk_io_gen: if i /= cpu_tile_id(0) and i /= io_tile_id and i /= 1 and i /= 12 and i /= mem_tile_id(0) generate
      ext_clk_int(i) <= ext_clk_noc_int;
    end generate unused_ext_clk_io_gen;
    unused_td_io_gen: if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) and i /= mem_tile_id(1) and i /= mem_tile_id(2) and i /= mem_tile_id(3)
                         and i /= 8 and i /= 4 and i /= 1 and i /= 2 and i /= 15 generate
      tdi_int(i) <= '0';
    end generate unused_td_io_gen;
  end generate unused_interface_gen;
  -- end chip-specific pads mapping
  -----------------------------------------------------------------------------

  tms_pad  : inpad generic map (loc => tms_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tms, tms_int);
  tclk_pad : inpad generic map (loc => tclk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tclk, tclk_int);

  -- Ethernet
  reset_o2_pad : outpad generic map (tech => CFG_FABTECH, loc => reset_o2_pad_loc, level => cmos, voltage => x18v)
    port map (reset_o2, reset_o2_int, full_pad_cfg(io_tile_id));

  etx_clk_pad : inpad generic map (tech => CFG_FABTECH, loc => etx_clk_pad_loc, level => cmos, voltage => x18v)
    port map (etx_clk, etx_clk_int);
  erx_clk_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_clk_pad_loc, level => cmos, voltage => x18v)
    port map (erx_clk, erx_clk_int);
  erxd_pad : inpadv generic map (tech => CFG_FABTECH, loc => erxd_pad_loc, level => cmos, voltage => x18v, width => 4)
    port map (erxd, erxd_int);
  erx_dv_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_dv_pad_loc, level => cmos, voltage => x18v)
    port map (erx_dv, erx_dv_int);
  erx_er_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_er_pad_loc, level => cmos, voltage => x18v)
    port map (erx_er, erx_er_int);
  erx_col_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_col_pad_loc, level => cmos, voltage => x18v)
    port map (erx_col, erx_col_int);
  erx_crs_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_crs_pad_loc, level => cmos, voltage => x18v)
    port map (erx_crs, erx_crs_int);

  emdio_pad : iopad generic map (tech => CFG_FABTECH, loc => emdio_pad_loc, level => cmos, voltage => x18v, oepol => 1)
    port map (emdio, emdio_o, emdio_oe, emdio_i, full_pad_cfg(io_tile_id));

  etxd_pad : outpadv generic map (tech => CFG_FABTECH, loc => etxd_pad_loc, level => cmos, voltage => x18v, width => 4)
    port map (etxd, etxd_int, full_pad_cfg(io_tile_id));
  etx_en_pad : outpad generic map (tech => CFG_FABTECH, loc => etx_en_pad_loc, level => cmos, voltage => x18v)
    port map (etx_en, etx_en_int, full_pad_cfg(io_tile_id));
  etx_er_pad : outpad generic map (tech => CFG_FABTECH, loc => etx_er_pad_loc, level => cmos, voltage => x18v)
    port map (etx_er, etx_er_int, full_pad_cfg(io_tile_id));
  emdc_pad : outpad generic map (tech => CFG_FABTECH, loc => emdc_pad_loc, level => cmos, voltage => x18v)
    port map (emdc, emdc_int, full_pad_cfg(io_tile_id));

  -- DVI
  -- tft_nhpd_pad : inpad generic map (tech => CFG_FABTECH, loc => tft_nhpd_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_nhpd, dvi_nhpd);

  -- tft_clk_p_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_clk_p_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_clk_p, clkvga_p, full_pad_cfg(io_tile_id));
  -- tft_clk_n_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_clk_n_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_clk_n, clkvga_n, full_pad_cfg(io_tile_id));

  -- tft_data_pad : outpadv generic map (width => 24, tech => CFG_FABTECH, loc => tft_data_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_data, dvi_data, full_pad_cfg(io_tile_id));
  -- tft_hsync_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_hsync_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_hsync, dvi_hsync, full_pad_cfg(io_tile_id));
  -- tft_vsync_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_vsync_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_vsync, dvi_vsync, full_pad_cfg(io_tile_id));
  -- tft_de_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_de_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_de, dvi_de, full_pad_cfg(io_tile_id));

  -- tft_dken_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_dken_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_dken, dvi_dken, full_pad_cfg(io_tile_id));
  -- tft_ctl1_a1_dk1_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_ctl1_a1_dk1_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_ctl1_a1_dk1, dvi_ctl1_a1_dk1, full_pad_cfg(io_tile_id));
  -- tft_ctl2_a2_dk2_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_ctl2_a2_dk2_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_ctl2_a2_dk2, dvi_ctl2_a2_dk2, full_pad_cfg(io_tile_id));
  -- tft_a3_dk3_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_a3_dk3_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_a3_dk3, dvi_a3_dk3, full_pad_cfg(io_tile_id));

  -- tft_isel_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_isel_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_isel, dvi_isel, full_pad_cfg(io_tile_id));
  -- tft_bsel_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_bsel_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_bsel, dvi_bsel, full_pad_cfg(io_tile_id));
  -- tft_dsel_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_dsel_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_dsel, dvi_dsel, full_pad_cfg(io_tile_id));
  -- tft_edge_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_edge_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_edge, dvi_edge, full_pad_cfg(io_tile_id));
  -- tft_npd_pad : outpad generic map (tech => CFG_FABTECH, loc => tft_npd_pad_loc, level => cmos, voltage => x18v)
  --   port map (tft_npd, dvi_npd, full_pad_cfg(io_tile_id));

  -- LPDDR
  lpddr0_ck_p_pad  : outpad generic map (loc => lpddr0_ck_p_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_ck_p, '0', X"00003");
  lpddr0_ck_n_pad  : outpad generic map (loc => lpddr0_ck_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_ck_n, '0', X"00003");
  lpddr0_cke_pad  : outpad generic map (loc => lpddr0_cke_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_cke, '0', X"00003");
  lpddr0_ba_pad  : outpadv generic map (loc => lpddr0_ba_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 3) port map (lpddr0_ba, "000", X"00003");
  lpddr0_addr_pad  : outpadv generic map (loc => lpddr0_addr_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 16) port map (lpddr0_addr, X"0000", X"00003");
  lpddr0_cs_n_pad  : outpad generic map (loc => lpddr0_cs_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_cs_n, '0', X"00003");
  lpddr0_ras_n_pad  : outpad generic map (loc => lpddr0_ras_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_ras_n, '0', X"00003");
  lpddr0_cas_n_pad  : outpad generic map (loc => lpddr0_cas_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_cas_n, '0', X"00003");
  lpddr0_we_n_pad  : outpad generic map (loc => lpddr0_we_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_we_n, '0', X"00003");
  lpddr0_reset_n_pad  : outpad generic map (loc => lpddr0_reset_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_reset_n, '0', X"00003");
  lpddr0_odt_pad  : outpad generic map (loc => lpddr0_odt_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr0_odt, '0', X"00003");
  lpddr0_dm_pad  : outpadv generic map (loc => lpddr0_dm_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4) port map (lpddr0_dm, "0000", X"00003");
  lpddr0_dqs_p_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr0_dqs_p_pad_loc, level => cmos, voltage => x18v, width => 4, oepol => 1) port map (lpddr0_dqs_p, "0000", '0', open, X"00003");
  lpddr0_dqs_n_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr0_dqs_n_pad_loc, level => cmos, voltage => x18v, width => 4, oepol => 1) port map (lpddr0_dqs_n, "0000", '0', open, X"00003");
  lpddr0_dq_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr0_dq_pad_loc, level => cmos, voltage => x18v, width => 32, oepol => 1) port map (lpddr0_dq, X"00000000", '0', open, X"00003");

  lpddr1_ck_p_pad  : outpad generic map (loc => lpddr1_ck_p_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_ck_p, '0', X"00003");
  lpddr1_ck_n_pad  : outpad generic map (loc => lpddr1_ck_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_ck_n, '0', X"00003");
  lpddr1_cke_pad  : outpad generic map (loc => lpddr1_cke_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_cke, '0', X"00003");
  lpddr1_ba_pad  : outpadv generic map (loc => lpddr1_ba_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 3) port map (lpddr1_ba, "000", X"00003");
  lpddr1_addr_pad  : outpadv generic map (loc => lpddr1_addr_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 16) port map (lpddr1_addr, X"0000", X"00003");
  lpddr1_cs_n_pad  : outpad generic map (loc => lpddr1_cs_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_cs_n, '0', X"00003");
  lpddr1_ras_n_pad  : outpad generic map (loc => lpddr1_ras_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_ras_n, '0', X"00003");
  lpddr1_cas_n_pad  : outpad generic map (loc => lpddr1_cas_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_cas_n, '0', X"00003");
  lpddr1_we_n_pad  : outpad generic map (loc => lpddr1_we_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_we_n, '0', X"00003");
  lpddr1_reset_n_pad  : outpad generic map (loc => lpddr1_reset_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_reset_n, '0', X"00003");
  lpddr1_odt_pad  : outpad generic map (loc => lpddr1_odt_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (lpddr1_odt, '0', X"00003");
  lpddr1_dm_pad  : outpadv generic map (loc => lpddr1_dm_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4) port map (lpddr1_dm, "0000", X"00003");
  lpddr1_dqs_p_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr1_dqs_p_pad_loc, level => cmos, voltage => x18v, width => 4, oepol => 1) port map (lpddr1_dqs_p, "0000", '0', open, X"00003");
  lpddr1_dqs_n_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr1_dqs_n_pad_loc, level => cmos, voltage => x18v, width => 4, oepol => 1) port map (lpddr1_dqs_n, "0000", '0', open, X"00003");
  lpddr1_dq_pad : iopadv generic map (tech => CFG_FABTECH, loc => lpddr1_dq_pad_loc, level => cmos, voltage => x18v, width => 32, oepol => 1) port map (lpddr1_dq, X"00000000", '0', open, X"00003");

  -- UART
  uart_rxd_pad  : inpad generic map (loc => uart_rxd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad  : outpad generic map (loc => uart_txd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int, full_pad_cfg(io_tile_id));
  uart_ctsn_pad : inpad generic map (loc => uart_ctsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (loc => uart_rtsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int, full_pad_cfg(io_tile_id));

  -- IVR (set to inputs; unused for now)
  ivr_pmb_dat_pad  : inpad generic map (loc  => ivr_pmb_dat_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_pmb_dat, open);
  ivr_pmb_clk_pad  : inpad generic map (loc  => ivr_pmb_clk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_pmb_clk, open);
  ivr_avs_clk_pad  : inpad generic map (loc  => ivr_avs_clk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_avs_clk, open);
  ivr_avs_dat_pad  : inpad generic map (loc  => ivr_avs_dat_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_avs_dat, open);
  ivr_avs_sdat_pad : inpad generic map (loc  => ivr_avs_sdat_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_avs_sdat, open);
  ivr_control_pad  : inpad generic map (loc  => ivr_control_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ivr_control, open);

  ivr_gpio_pad     : inpadv generic map (loc => ivr_gpio_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4) port map (ivr_gpio, open);

  -- UNUSED
  unused_pad  : inpad generic map (loc => unused_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (unused, open);

  -- DUMMY
  dummy_pad : outpad generic map (loc => dummy_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (open, '0', X"00003");

  -----------------------------------------------------------------------------
  -- chip-specific mapping of memory tile pins to package pins
  -- TODO: select this mapping from ESP GUI
  -- Memory tile 0 - FPGA link 0
  -- Memory tile 1 - FPGA link 1
  -- Memory tile 2 - FPGA link 3
  -- Memory tile 3 - FPGA link 2
  -- data_out
  fpga_data_out_swap(63 downto 0)    <= fpga_data_out(63 downto 0);     -- 0
  fpga_data_out_swap(127 downto 64)  <= fpga_data_out(127 downto 64);   -- 1
  fpga_data_out_swap(255 downto 192) <= fpga_data_out(191 downto 128);  -- 2
  fpga_data_out_swap(191 downto 128) <= fpga_data_out(255 downto 192);  -- 3
  -- data in
  fpga_data_in(63 downto 0)    <= fpga_data_in_swap(63 downto 0);     -- 0
  fpga_data_in(127 downto 64)  <= fpga_data_in_swap(127 downto 64);   -- 1
  fpga_data_in(191 downto 128) <= fpga_data_in_swap(255 downto 192);  -- 2
  fpga_data_in(255 downto 192) <= fpga_data_in_swap(191 downto 128);  -- 3
  -- valid out
  fpga_valid_out_swap(0) <= fpga_valid_out_int(0);  -- 0
  fpga_valid_out_swap(1) <= fpga_valid_out_int(1);  -- 1
  fpga_valid_out_swap(3) <= fpga_valid_out_int(2);  -- 2
  fpga_valid_out_swap(2) <= fpga_valid_out_int(3);  -- 3
  -- valid in
  fpga_valid_in_int(0) <= fpga_valid_in_swap(0);  -- 0
  fpga_valid_in_int(1) <= fpga_valid_in_swap(1);  -- 1
  fpga_valid_in_int(2) <= fpga_valid_in_swap(3);  -- 2
  fpga_valid_in_int(3) <= fpga_valid_in_swap(2);  -- 3
  -- clk out
  fpga_clk_out_swap(0) <= fpga_clk_out_int(0);  -- 0
  fpga_clk_out_swap(1) <= fpga_clk_out_int(1);  -- 1
  fpga_clk_out_swap(3) <= fpga_clk_out_int(2);  -- 2
  fpga_clk_out_swap(2) <= fpga_clk_out_int(3);  -- 3
  -- clk in
  fpga_clk_in_int(0) <= fpga_clk_in_swap(0);  -- 0
  fpga_clk_in_int(1) <= fpga_clk_in_swap(1);  -- 1
  fpga_clk_in_int(2) <= fpga_clk_in_swap(3);  -- 2
  fpga_clk_in_int(3) <= fpga_clk_in_swap(2);  -- 3
  -- credit out
  fpga_credit_out_swap(0) <= fpga_credit_out_int(0);  -- 0
  fpga_credit_out_swap(1) <= fpga_credit_out_int(1);  -- 1
  fpga_credit_out_swap(3) <= fpga_credit_out_int(2);  -- 2
  fpga_credit_out_swap(2) <= fpga_credit_out_int(3);  -- 3
  -- credit in
  fpga_credit_in_int(0) <= fpga_credit_in_swap(0);  -- 0
  fpga_credit_in_int(1) <= fpga_credit_in_swap(1);  -- 1
  fpga_credit_in_int(2) <= fpga_credit_in_swap(3);  -- 2
  fpga_credit_in_int(3) <= fpga_credit_in_swap(2);  -- 3
  fpga_pad_wires_gen : for i in 0 to 63 generate
    -- oen
    fpga_oen_swap(0 + i)   <= fpga_oen(0);  -- 0
    fpga_oen_swap(64 + i)  <= fpga_oen(1);  -- 1
    fpga_oen_swap(192 + i) <= fpga_oen(2);  -- 2
    fpga_oen_swap(128 + i) <= fpga_oen(3);  -- 3
    -- data pad cfg
    fpga_data_pad_cfg(0 * 64 * 20 + (i+1) * 20 - 1 downto 0 * 64 * 20 + i * 20) <= full_pad_cfg(mem_tile_id(0));  -- 0
    fpga_data_pad_cfg(1 * 64 * 20 + (i+1) * 20 - 1 downto 1 * 64 * 20 + i * 20) <= full_pad_cfg(mem_tile_id(1));  -- 1
    fpga_data_pad_cfg(3 * 64 * 20 + (i+1) * 20 - 1 downto 3 * 64 * 20 + i * 20) <= full_pad_cfg(mem_tile_id(2));  -- 2
    fpga_data_pad_cfg(2 * 64 * 20 + (i+1) * 20 - 1 downto 2 * 64 * 20 + i * 20) <= full_pad_cfg(mem_tile_id(3));  -- 3
  end generate fpga_pad_wires_gen;
  -- clock and credit pad cfg
  fpga_c_pad_cfg(19 downto 0)  <= full_pad_cfg(mem_tile_id(0));  -- 0
  fpga_c_pad_cfg(39 downto 20) <= full_pad_cfg(mem_tile_id(1));  -- 1
  fpga_c_pad_cfg(79 downto 60) <= full_pad_cfg(mem_tile_id(2));  -- 2
  fpga_c_pad_cfg(59 downto 40) <= full_pad_cfg(mem_tile_id(3));  -- 3
  -- End of chip-specific pad mapping
  -----------------------------------------------------------------------------

  fpga_data_pad : iopadvvv generic map (tech => CFG_FABTECH, loc => fpga_data_pad_loc, level => cmos, voltage => x18v, width => 4*64, oepol => 1)
    port map (fpga_data, fpga_data_out_swap, fpga_oen_swap, fpga_data_in_swap, fpga_data_pad_cfg);
  fpga_valid_in_pad : inpadv generic map (loc => fpga_valid_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_valid_in, fpga_valid_in_swap);
  fpga_valid_out_pad : outpadvvv generic map (loc => fpga_valid_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_valid_out, fpga_valid_out_swap, fpga_c_pad_cfg);
  fpga_clk_in_pad : inpadv generic map (loc => fpga_clk_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_clk_in, fpga_clk_in_swap);
  fpga_clk_out_pad : outpadvvv generic map (loc => fpga_clk_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_clk_out, fpga_clk_out_swap, fpga_c_pad_cfg);
  fpga_credit_in_pad : inpadv generic map (loc => fpga_credit_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_credit_in, fpga_credit_in_swap);
  fpga_credit_out_pad : outpadvvv generic map (loc => fpga_credit_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4)
    port map (fpga_credit_out, fpga_credit_out_swap, fpga_c_pad_cfg);

  -----------------------------------------------------------------------------
  -- NOC CONNECTIONS
  -----------------------------------------------------------------------------
  meshgen_y : for i in 0 to CFG_YLEN-1 generate
    meshgen_x : for j in 0 to CFG_XLEN-1 generate

      y_0 : if (i = 0) generate
        -- North port is unconnected
        noc1_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc2_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc3_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc4_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc5_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(0)      <= '0';
        noc6_data_n_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(0) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(0)      <= '0';
      end generate y_0;

      y_non_0 : if (i /= 0) generate
        -- North port is connected
        noc1_data_n_in(i*CFG_XLEN + j)       <= noc1_data_s_out((i-1)*CFG_XLEN + j);
        noc1_data_void_in(i*CFG_XLEN + j)(0) <= noc1_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc1_stop_in(i*CFG_XLEN + j)(0)      <= noc1_stop_out((i-1)*CFG_XLEN + j)(1);
        noc2_data_n_in(i*CFG_XLEN + j)       <= noc2_data_s_out((i-1)*CFG_XLEN + j);
        noc2_data_void_in(i*CFG_XLEN + j)(0) <= noc2_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc2_stop_in(i*CFG_XLEN + j)(0)      <= noc2_stop_out((i-1)*CFG_XLEN + j)(1);
        noc3_data_n_in(i*CFG_XLEN + j)       <= noc3_data_s_out((i-1)*CFG_XLEN + j);
        noc3_data_void_in(i*CFG_XLEN + j)(0) <= noc3_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc3_stop_in(i*CFG_XLEN + j)(0)      <= noc3_stop_out((i-1)*CFG_XLEN + j)(1);
        noc4_data_n_in(i*CFG_XLEN + j)       <= noc4_data_s_out((i-1)*CFG_XLEN + j);
        noc4_data_void_in(i*CFG_XLEN + j)(0) <= noc4_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc4_stop_in(i*CFG_XLEN + j)(0)      <= noc4_stop_out((i-1)*CFG_XLEN + j)(1);
        noc5_data_n_in(i*CFG_XLEN + j)       <= noc5_data_s_out((i-1)*CFG_XLEN + j);
        noc5_data_void_in(i*CFG_XLEN + j)(0) <= noc5_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc5_stop_in(i*CFG_XLEN + j)(0)      <= noc5_stop_out((i-1)*CFG_XLEN + j)(1);
        noc6_data_n_in(i*CFG_XLEN + j)       <= noc6_data_s_out((i-1)*CFG_XLEN + j);
        noc6_data_void_in(i*CFG_XLEN + j)(0) <= noc6_data_void_out((i-1)*CFG_XLEN + j)(1);
        noc6_stop_in(i*CFG_XLEN + j)(0)      <= noc6_stop_out((i-1)*CFG_XLEN + j)(1);
      end generate y_non_0;

      y_YLEN : if (i = CFG_YLEN-1) generate
        -- South port is unconnected
        noc1_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc2_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc3_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc4_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc5_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(1)      <= '0';
        noc6_data_s_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(1) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(1)      <= '0';
      end generate y_YLEN;

      y_non_YLEN : if (i /= CFG_YLEN-1) generate
        -- south port is connected
        noc1_data_s_in(i*CFG_XLEN + j)       <= noc1_data_n_out((i+1)*CFG_XLEN + j);
        noc1_data_void_in(i*CFG_XLEN + j)(1) <= noc1_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc1_stop_in(i*CFG_XLEN + j)(1)      <= noc1_stop_out((i+1)*CFG_XLEN + j)(0);
        noc2_data_s_in(i*CFG_XLEN + j)       <= noc2_data_n_out((i+1)*CFG_XLEN + j);
        noc2_data_void_in(i*CFG_XLEN + j)(1) <= noc2_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc2_stop_in(i*CFG_XLEN + j)(1)      <= noc2_stop_out((i+1)*CFG_XLEN + j)(0);
        noc3_data_s_in(i*CFG_XLEN + j)       <= noc3_data_n_out((i+1)*CFG_XLEN + j);
        noc3_data_void_in(i*CFG_XLEN + j)(1) <= noc3_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc3_stop_in(i*CFG_XLEN + j)(1)      <= noc3_stop_out((i+1)*CFG_XLEN + j)(0);
        noc4_data_s_in(i*CFG_XLEN + j)       <= noc4_data_n_out((i+1)*CFG_XLEN + j);
        noc4_data_void_in(i*CFG_XLEN + j)(1) <= noc4_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc4_stop_in(i*CFG_XLEN + j)(1)      <= noc4_stop_out((i+1)*CFG_XLEN + j)(0);
        noc5_data_s_in(i*CFG_XLEN + j)       <= noc5_data_n_out((i+1)*CFG_XLEN + j);
        noc5_data_void_in(i*CFG_XLEN + j)(1) <= noc5_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc5_stop_in(i*CFG_XLEN + j)(1)      <= noc5_stop_out((i+1)*CFG_XLEN + j)(0);
        noc6_data_s_in(i*CFG_XLEN + j)       <= noc6_data_n_out((i+1)*CFG_XLEN + j);
        noc6_data_void_in(i*CFG_XLEN + j)(1) <= noc6_data_void_out((i+1)*CFG_XLEN + j)(0);
        noc6_stop_in(i*CFG_XLEN + j)(1)      <= noc6_stop_out((i+1)*CFG_XLEN + j)(0);
      end generate y_non_YLEN;

      x_0 : if (j = 0) generate
        -- West port is unconnected
        noc1_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc2_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc3_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc4_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc5_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(2)      <= '0';
        noc6_data_w_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(2) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(2)      <= '0';
      end generate x_0;

      x_non_0 : if (j /= 0) generate
        -- West port is connected
        noc1_data_w_in(i*CFG_XLEN + j)       <= noc1_data_e_out(i*CFG_XLEN + j - 1);
        noc1_data_void_in(i*CFG_XLEN + j)(2) <= noc1_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc1_stop_in(i*CFG_XLEN + j)(2)      <= noc1_stop_out(i*CFG_XLEN + j - 1)(3);
        noc2_data_w_in(i*CFG_XLEN + j)       <= noc2_data_e_out(i*CFG_XLEN + j - 1);
        noc2_data_void_in(i*CFG_XLEN + j)(2) <= noc2_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc2_stop_in(i*CFG_XLEN + j)(2)      <= noc2_stop_out(i*CFG_XLEN + j - 1)(3);
        noc3_data_w_in(i*CFG_XLEN + j)       <= noc3_data_e_out(i*CFG_XLEN + j - 1);
        noc3_data_void_in(i*CFG_XLEN + j)(2) <= noc3_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc3_stop_in(i*CFG_XLEN + j)(2)      <= noc3_stop_out(i*CFG_XLEN + j - 1)(3);
        noc4_data_w_in(i*CFG_XLEN + j)       <= noc4_data_e_out(i*CFG_XLEN + j - 1);
        noc4_data_void_in(i*CFG_XLEN + j)(2) <= noc4_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc4_stop_in(i*CFG_XLEN + j)(2)      <= noc4_stop_out(i*CFG_XLEN + j - 1)(3);
        noc5_data_w_in(i*CFG_XLEN + j)       <= noc5_data_e_out(i*CFG_XLEN + j - 1);
        noc5_data_void_in(i*CFG_XLEN + j)(2) <= noc5_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc5_stop_in(i*CFG_XLEN + j)(2)      <= noc5_stop_out(i*CFG_XLEN + j - 1)(3);
        noc6_data_w_in(i*CFG_XLEN + j)       <= noc6_data_e_out(i*CFG_XLEN + j - 1);
        noc6_data_void_in(i*CFG_XLEN + j)(2) <= noc6_data_void_out(i*CFG_XLEN + j - 1)(3);
        noc6_stop_in(i*CFG_XLEN + j)(2)      <= noc6_stop_out(i*CFG_XLEN + j - 1)(3);
      end generate x_non_0;

      x_XLEN : if (j = CFG_XLEN-1) generate
        -- East port is unconnected
        noc1_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc1_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc1_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc2_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc2_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc2_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc3_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc3_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc3_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc4_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc4_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc4_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc5_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc5_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc5_stop_in(i*CFG_XLEN + j)(3)      <= '0';
        noc6_data_e_in(i*CFG_XLEN + j)       <= (others => '0');
        noc6_data_void_in(i*CFG_XLEN + j)(3) <= '1';
        noc6_stop_in(i*CFG_XLEN + j)(3)      <= '0';
      end generate x_XLEN;

      x_non_XLEN : if (j /= CFG_XLEN-1) generate
        -- East port is connected
        noc1_data_e_in(i*CFG_XLEN + j)       <= noc1_data_w_out(i*CFG_XLEN + j + 1);
        noc1_data_void_in(i*CFG_XLEN + j)(3) <= noc1_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc1_stop_in(i*CFG_XLEN + j)(3)      <= noc1_stop_out(i*CFG_XLEN + j + 1)(2);
        noc2_data_e_in(i*CFG_XLEN + j)       <= noc2_data_w_out(i*CFG_XLEN + j + 1);
        noc2_data_void_in(i*CFG_XLEN + j)(3) <= noc2_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc2_stop_in(i*CFG_XLEN + j)(3)      <= noc2_stop_out(i*CFG_XLEN + j + 1)(2);
        noc3_data_e_in(i*CFG_XLEN + j)       <= noc3_data_w_out(i*CFG_XLEN + j + 1);
        noc3_data_void_in(i*CFG_XLEN + j)(3) <= noc3_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc3_stop_in(i*CFG_XLEN + j)(3)      <= noc3_stop_out(i*CFG_XLEN + j + 1)(2);
        noc4_data_e_in(i*CFG_XLEN + j)       <= noc4_data_w_out(i*CFG_XLEN + j + 1);
        noc4_data_void_in(i*CFG_XLEN + j)(3) <= noc4_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc4_stop_in(i*CFG_XLEN + j)(3)      <= noc4_stop_out(i*CFG_XLEN + j + 1)(2);
        noc5_data_e_in(i*CFG_XLEN + j)       <= noc5_data_w_out(i*CFG_XLEN + j + 1);
        noc5_data_void_in(i*CFG_XLEN + j)(3) <= noc5_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc5_stop_in(i*CFG_XLEN + j)(3)      <= noc5_stop_out(i*CFG_XLEN + j + 1)(2);
        noc6_data_e_in(i*CFG_XLEN + j)       <= noc6_data_w_out(i*CFG_XLEN + j + 1);
        noc6_data_void_in(i*CFG_XLEN + j)(3) <= noc6_data_void_out(i*CFG_XLEN + j + 1)(2);
        noc6_stop_in(i*CFG_XLEN + j)(3)      <= noc6_stop_out(i*CFG_XLEN + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;


  -----------------------------------------------------------------------------
  -- TILES
  -----------------------------------------------------------------------------
  tiles_gen : for i in 0 to CFG_TILES_NUM - 1 generate

    empty_tile : if tile_type(i) = 0 generate
      tile_empty_i : asic_tile_empty
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,
          sys_clk            => sys_clk,
          sys_clk_lock       => '1',
          ext_clk            => ext_clk_int(i),
          clk_div            => clk_div_int(i),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i));
    end generate empty_tile;


    cpu_tile : if tile_type(i) = 1 generate
-- pragma translate_off
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
-- pragma translate_on
      tile_cpu_i : asic_tile_cpu
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,
          sys_clk            => sys_clk,
          sys_clk_lock       => '1',
          ext_clk            => ext_clk_int(i),
          clk_div            => clk_div_int(i),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i));
    end generate cpu_tile;


    accelerator_tile : if tile_type(i) = 2 generate
-- pragma translate_off
      assert tile_device(i) /= 0 report "Undefined device ID for accelerator tile" severity error;
-- pragma translate_on
      tile_acc_i : asic_tile_acc
        generic map (
          this_hls_conf => tile_design_point(i),
          this_device   => tile_device(i),
          this_irq_type => tile_irq_type(i),
          this_has_l2   => tile_has_l2(i),
          ROUTER_PORTS  => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,
          sys_clk            => sys_clk,
          sys_clk_lock       => '1',
          ext_clk            => ext_clk_int(i),
          clk_div            => clk_div_int(i),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i)
          );
    end generate accelerator_tile;


    io_tile : if tile_type(i) = 3 generate
      tile_io_i : asic_tile_io
        generic map (
          SIMULATION   => SIMULATION,
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,       -- from I/O PAD reset
          sys_rstn_out       => sys_rstn,        -- NoC reset out (unused; connect other tiles directly to reset PAD)
          sys_clk_out        => sys_clk,         -- NoC clock out
          sys_clk            => sys_clk,         -- NoC clock in
          sys_clk_lock_out   => sys_clk_lock,     -- NoC DCO lock
          ext_clk_noc        => ext_clk_noc_int, -- backup NoC clock
          clk_div_noc        => clk_div_noc_int,
          ext_clk            => ext_clk_int(i),  -- backup clock (fixed)
          clk_div            => clk_div_int(i),
          reset_o2           => reset_o2_int,
          etx_clk            => etx_clk_int,
          erx_clk            => erx_clk_int,
          erxd               => erxd_int,
          erx_dv             => erx_dv_int,
          erx_er             => erx_er_int,
          erx_col            => erx_col_int,
          erx_crs            => erx_crs_int,
          etxd               => etxd_int,
          etx_en             => etx_en_int,
          etx_er             => etx_er_int,
          emdc               => emdc_int,
          emdio_i            => emdio_i,
          emdio_o            => emdio_o,
          emdio_oe           => emdio_oe,
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
          -- dvi_nhpd           => dvi_nhpd,
          -- clkvga_p           => clkvga_p,
          -- clkvga_n           => clkvga_n,
          -- dvi_data           => dvi_data,
          -- dvi_hsync          => dvi_hsync,
          -- dvi_vsync          => dvi_vsync,
          -- dvi_de             => dvi_de,
          -- dvi_dken           => dvi_dken,
          -- dvi_ctl1_a1_dk1    => dvi_ctl1_a1_dk1,
          -- dvi_ctl2_a2_dk2    => dvi_ctl2_a2_dk2,
          -- dvi_a3_dk3         => dvi_a3_dk3,
          -- dvi_isel           => dvi_isel,
          -- dvi_bsel           => dvi_bsel,
          -- dvi_dsel           => dvi_dsel,
          -- dvi_edge           => dvi_edge,
          -- dvi_npd            => dvi_npd,
          uart_rxd           => uart_rxd_int,
          uart_txd           => uart_txd_int,
          uart_ctsn          => uart_ctsn_int,
          uart_rtsn          => uart_rtsn_int,
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i));
    end generate io_tile;


    mem_tile : if tile_type(i) = 4 generate
      tile_mem_i : asic_tile_mem
        generic map (
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,
          sys_clk            => sys_clk,
          sys_clk_lock       => '1',
          ext_clk            => ext_clk_int(i),
          clk_div            => clk_div_int(i),
          fpga_data_in       => fpga_data_in((tile_mem_id(i) + 1) * (ARCH_BITS) - 1 downto tile_mem_id(i) * (ARCH_BITS)),
          fpga_data_out      => fpga_data_out((tile_mem_id(i) + 1) * (ARCH_BITS) - 1 downto tile_mem_id(i) * (ARCH_BITS)),
          fpga_oen           => fpga_oen(tile_mem_id(i)),
          fpga_valid_in      => fpga_valid_in_int(tile_mem_id(i)),
          fpga_valid_out     => fpga_valid_out_int(tile_mem_id(i)),
          fpga_clk_in        => fpga_clk_in_int(tile_mem_id(i)),
          fpga_clk_out       => fpga_clk_out_int(tile_mem_id(i)),
          fpga_credit_in     => fpga_credit_in_int(tile_mem_id(i)),
          fpga_credit_out    => fpga_credit_out_int(tile_mem_id(i)),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i));
    end generate mem_tile;

    slm_tile : if tile_type(i) = 5 generate
      tile_slm_i : asic_tile_slm
        generic map (
          ROUTER_PORTS => set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(i), tile_y(i)),
          this_has_dco => 1 - ESP_EMU)
        port map (
          rst                => reset_int,
          sys_clk            => sys_clk,
          sys_clk_lock       => '1',
          ext_clk            => ext_clk_int(i),
          clk_div            => clk_div_int(i),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          pad_cfg            => pad_cfg(i),
          noc1_data_n_in     => noc1_data_n_in(i),
          noc1_data_s_in     => noc1_data_s_in(i),
          noc1_data_w_in     => noc1_data_w_in(i),
          noc1_data_e_in     => noc1_data_e_in(i),
          noc1_data_void_in  => noc1_data_void_in(i),
          noc1_stop_in       => noc1_stop_in(i),
          noc1_data_n_out    => noc1_data_n_out(i),
          noc1_data_s_out    => noc1_data_s_out(i),
          noc1_data_w_out    => noc1_data_w_out(i),
          noc1_data_e_out    => noc1_data_e_out(i),
          noc1_data_void_out => noc1_data_void_out(i),
          noc1_stop_out      => noc1_stop_out(i),
          noc2_data_n_in     => noc2_data_n_in(i),
          noc2_data_s_in     => noc2_data_s_in (i),
          noc2_data_w_in     => noc2_data_w_in(i),
          noc2_data_e_in     => noc2_data_e_in(i),
          noc2_data_void_in  => noc2_data_void_in(i),
          noc2_stop_in       => noc2_stop_in(i),
          noc2_data_n_out    => noc2_data_n_out(i),
          noc2_data_s_out    => noc2_data_s_out(i),
          noc2_data_w_out    => noc2_data_w_out(i),
          noc2_data_e_out    => noc2_data_e_out(i),
          noc2_data_void_out => noc2_data_void_out(i),
          noc2_stop_out      => noc2_stop_out(i),
          noc3_data_n_in     => noc3_data_n_in(i),
          noc3_data_s_in     => noc3_data_s_in(i),
          noc3_data_w_in     => noc3_data_w_in(i),
          noc3_data_e_in     => noc3_data_e_in(i),
          noc3_data_void_in  => noc3_data_void_in(i),
          noc3_stop_in       => noc3_stop_in(i),
          noc3_data_n_out    => noc3_data_n_out(i),
          noc3_data_s_out    => noc3_data_s_out(i),
          noc3_data_w_out    => noc3_data_w_out(i),
          noc3_data_e_out    => noc3_data_e_out(i),
          noc3_data_void_out => noc3_data_void_out(i),
          noc3_stop_out      => noc3_stop_out(i),
          noc4_data_n_in     => noc4_data_n_in(i),
          noc4_data_s_in     => noc4_data_s_in(i),
          noc4_data_w_in     => noc4_data_w_in(i),
          noc4_data_e_in     => noc4_data_e_in(i),
          noc4_data_void_in  => noc4_data_void_in(i),
          noc4_stop_in       => noc4_stop_in(i),
          noc4_data_n_out    => noc4_data_n_out(i),
          noc4_data_s_out    => noc4_data_s_out(i),
          noc4_data_w_out    => noc4_data_w_out(i),
          noc4_data_e_out    => noc4_data_e_out(i),
          noc4_data_void_out => noc4_data_void_out(i),
          noc4_stop_out      => noc4_stop_out(i),
          noc5_data_n_in     => noc5_data_n_in(i),
          noc5_data_s_in     => noc5_data_s_in(i),
          noc5_data_w_in     => noc5_data_w_in(i),
          noc5_data_e_in     => noc5_data_e_in(i),
          noc5_data_void_in  => noc5_data_void_in(i),
          noc5_stop_in       => noc5_stop_in(i),
          noc5_data_n_out    => noc5_data_n_out(i),
          noc5_data_s_out    => noc5_data_s_out(i),
          noc5_data_w_out    => noc5_data_w_out(i),
          noc5_data_e_out    => noc5_data_e_out(i),
          noc5_data_void_out => noc5_data_void_out(i),
          noc5_stop_out      => noc5_stop_out(i),
          noc6_data_n_in     => noc6_data_n_in(i),
          noc6_data_s_in     => noc6_data_s_in(i),
          noc6_data_w_in     => noc6_data_w_in(i),
          noc6_data_e_in     => noc6_data_e_in(i),
          noc6_data_void_in  => noc6_data_void_in(i),
          noc6_stop_in       => noc6_stop_in(i),
          noc6_data_n_out    => noc6_data_n_out(i),
          noc6_data_s_out    => noc6_data_s_out(i),
          noc6_data_w_out    => noc6_data_w_out(i),
          noc6_data_e_out    => noc6_data_e_out(i),
          noc6_data_void_out => noc6_data_void_out(i),
          noc6_stop_out      => noc6_stop_out(i));
    end generate slm_tile;

  end generate tiles_gen;

end;
