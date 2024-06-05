------------------------------------------------------------------------------
--  ESP - xilinx - vcu118
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
use work.svga_pkg.all;
library unisim;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on
use unisim.VCOMPONENTS.all;
use work.monitor_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity top is
  generic (
    SIMULATION      : boolean := false
    );
  port (
    reset            : in    std_ulogic;
    c0_sys_clk_p     : in    std_logic;      -- 250 MHz clock
    c0_sys_clk_n     : in    std_logic;      -- 250 MHz clock
    c0_ddr4_act_n    : out   std_logic;
    c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg       : out   std_logic_vector(0 downto 0);
    c0_ddr4_cke      : out   std_logic_vector(0 downto 0);
    c0_ddr4_odt      : out   std_logic_vector(0 downto 0);
    c0_ddr4_cs_n     : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n  : out   std_logic;
    c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
    c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
    c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
    c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
    gtrefclk_p       : in    std_logic;
    gtrefclk_n       : in    std_logic;
    txp              : out   std_logic;
    txn              : out   std_logic;
    rxp              : in    std_logic;
    rxn              : in    std_logic;
    emdio            : inout std_logic;
    emdc             : out   std_ulogic;
    eint             : in    std_ulogic;
    erst             : out   std_ulogic;
    uart_rxd         : in    std_ulogic;     -- UART1_RX (u1i.rxd)
    uart_txd         : out   std_ulogic;     -- UART1_TX (u1o.txd)
    uart_ctsn        : in    std_ulogic;     -- UART1_RTSN (u1i.ctsn)
    uart_rtsn        : out   std_ulogic;     -- UART1_RTSN (u1o.rtsn)
    button           : in    std_logic_vector(3 downto 0);
    switch           : inout std_logic_vector(3 downto 0);
    led              : out   std_logic_vector(6 downto 0));
end;

architecture rtl of top is

component fpga_proxy_cryo_top is
  generic (
    SIMULATION : boolean := false);
  port (
    reset            : in    std_ulogic;
    chip_rstn        : out   std_ulogic;  -- temporary out_clk signal for chip
    chip_clk         : out   std_ulogic; -- temporary out_clk signal for chip
    chip_clkm        : out   std_ulogic; -- temporary out_clk signal for chip
    -- DDR signals
    c0_sys_clk_p     : in    std_logic;
    c0_sys_clk_n     : in    std_logic;
    c0_ddr4_act_n    : out   std_logic;
    c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg       : out   std_logic_vector(0 downto 0);
    c0_ddr4_cke      : out   std_logic_vector(0 downto 0);
    c0_ddr4_odt      : out   std_logic_vector(0 downto 0);
    c0_ddr4_cs_n     : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n  : out   std_logic;
    c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
    c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
    c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
    c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
    -- I/O link
    --iolink_data     : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_data_in    : in  std_logic_vector(15 downto 0);
    iolink_data_out   : out std_logic_vector(15 downto 0);
    iolink_valid_in   : in    std_ulogic;
    iolink_valid_out  : out   std_ulogic;
    iolink_clk_in     : in    std_ulogic;
    iolink_clk_out    : out   std_ulogic;
    iolink_credit_in  : in    std_ulogic;
    iolink_credit_out : out   std_ulogic;
    -- ethernet
    gtrefclk_p       : in    std_logic;
    gtrefclk_n       : in    std_logic;
    txp              : out   std_logic;
    txn              : out   std_logic;
    rxp              : in    std_logic;
    rxn              : in    std_logic;
    emdio            : inout std_logic;
    emdc             : out   std_ulogic;
    eint             : in    std_ulogic;
    erst             : out   std_ulogic;
    uart_rxd_int     : out    std_ulogic;     -- UART1_RX (u1i.rxd)
    uart_txd_int     : in   std_ulogic;     -- UART1_TX (u1o.txd)
    uart_ctsn_int    : out  std_ulogic;     -- UART1_RTSN (u1i.ctsn)
    uart_rtsn_int    : in   std_ulogic;     -- UART1_RTSN (u1o.rtsn)
    uart_rxd         : in    std_ulogic;     -- UART1_RX (u1i.rxd)
    uart_txd         : out   std_ulogic;     -- UART1_TX (u1o.txd)
    uart_ctsn        : in    std_ulogic;     -- UART1_RTSN (u1i.ctsn)
    uart_rtsn        : out   std_ulogic;     -- UART1_RTSN (u1o.rtsn)
    button           : in    std_logic_vector(3 downto 0);
    switch           : inout std_logic_vector(3 downto 0);
    led              : out   std_logic_vector(6 downto 0));
end component fpga_proxy_cryo_top;

component chip_emu_top is
  generic (
    SIMULATION : boolean := false);
  port (
    --reset             : in    std_logic;
    rstn              : in    std_logic; -- temporary signal
    chip_clk          : in    std_ulogic;
    clkm              : in    std_ulogic;
    -- Backup external clock
    ext_clk           : in    std_logic;
    -- Test clock output (DCO divided clock)
    clk_div           : out   std_logic;
    -- I/O link
    --iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_data_in    : in std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_data_out   : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_valid_in   : in    std_ulogic;
    iolink_valid_out  : out   std_ulogic;
    iolink_clk_in     : in    std_ulogic;
    iolink_clk_out    : out   std_ulogic;
    iolink_credit_in  : in    std_ulogic;
    iolink_credit_out : out   std_ulogic;
    -- UART
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic   -- UART1_RTSN (u1o.rtsn)
    );
end component chip_emu_top;

-- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

  signal chip_rstn       : std_ulogic;
  signal chip_clk        : std_ulogic;
  signal chip_clkm       : std_ulogic;
  signal sys_clk : std_logic_vector(0 to 0);
  signal chip_refclk    : std_ulogic := '0';
  signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal chip_pllclk    : std_ulogic;

  constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz

-- IO Link
  signal iolink_data_in    : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_data_out   : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in   : std_ulogic;
  signal iolink_valid_out  : std_ulogic;
  signal iolink_clk_in     : std_logic;
  signal iolink_clk_out    : std_logic;
  signal iolink_credit_in  : std_logic;
  signal iolink_credit_out : std_logic;

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------
begin

  fpga_proxy_cryo_top_i : fpga_proxy_cryo_top
    generic map (
	  SIMULATION => SIMULATION)
	port map (
      reset            => reset,
      chip_rstn        => chip_rstn,
      chip_clk         => chip_clk,
      chip_clkm        => chip_clkm,
      -- DDR signals
      c0_sys_clk_p     => c0_sys_clk_p,
      c0_sys_clk_n     => c0_sys_clk_n,
      c0_ddr4_act_n    => c0_ddr4_act_n,
      c0_ddr4_adr      => c0_ddr4_adr,
      c0_ddr4_ba       => c0_ddr4_ba,
      c0_ddr4_bg       => c0_ddr4_bg,
      c0_ddr4_cke      => c0_ddr4_cke,
      c0_ddr4_odt      => c0_ddr4_odt,
      c0_ddr4_cs_n     => c0_ddr4_cs_n,
      c0_ddr4_ck_t     => c0_ddr4_ck_t,
      c0_ddr4_ck_c     => c0_ddr4_ck_c,
      c0_ddr4_reset_n  => c0_ddr4_reset_n,
      c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
      c0_ddr4_dq       => c0_ddr4_dq,
      c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
      c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
      -- I/O link
      --iolink_data     : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_data_in    =>  iolink_data_in,
      iolink_data_out   => iolink_data_out,
      iolink_valid_in   => iolink_valid_in,
      iolink_valid_out  => iolink_valid_out,
      iolink_clk_in     => iolink_clk_in,
      iolink_clk_out    => iolink_clk_out,
      iolink_credit_in  => iolink_credit_in,
      iolink_credit_out => iolink_credit_out,
    -- ethernet
      gtrefclk_p       => gtrefclk_p,
      gtrefclk_n       => gtrefclk_n,
      txp              => txp,
      txn              => txn,
      rxp              => rxp,
      rxn              => rxn,
      emdio            => emdio,
      emdc             => emdc,
	  eint             => eint,
      erst             => erst,
      uart_rxd_int     => uart_rxd_int,
      uart_txd_int     => uart_txd_int,
      uart_ctsn_int    => uart_ctsn_int,
      uart_rtsn_int    => uart_rtsn_int,
      uart_rxd         => uart_rxd,
      uart_txd         => uart_txd,
      uart_ctsn        => uart_ctsn,
      uart_rtsn        => uart_rtsn,
      button           => button,
      switch           => switch,
      led              => led
	);


  chip_emu_top_i : chip_emu_top
  generic map (
    SIMULATION => SIMULATION)
  port map (
    --reset             : in    std_logic;
    rstn              => chip_rstn,  --
    chip_clk          => chip_clk,
    clkm              => chip_clkm,
    -- Backup external clock
    ext_clk           => '0', --
    -- Test clock output (DCO divided clock)
    clk_div           => open,
    -- I/O link
    --iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_data_in    => iolink_data_out,
    iolink_data_out   => iolink_data_in,
    iolink_valid_in   => iolink_valid_out,
    iolink_valid_out  => iolink_valid_in,
    iolink_clk_in     => iolink_clk_out,
	iolink_clk_out    => iolink_clk_in,
    iolink_credit_in  => iolink_credit_out,
    iolink_credit_out => iolink_credit_in,
    -- UART
    uart_rxd        => uart_rxd_int,
    uart_txd        => uart_txd_int,
    uart_ctsn       => uart_ctsn_int,
    uart_rtsn       => uart_rtsn_int
    );

end;
