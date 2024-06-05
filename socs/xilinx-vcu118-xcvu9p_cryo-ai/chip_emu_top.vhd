------------------------------------------------------------------------------
--  Cryo-ai FPGA emulator  -- vcu118
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

entity chip_emu_top is
  generic (
    SIMULATION : boolean := false);
  port (
    --reset             : in    std_logic;
	rstn			  : in 	  std_logic; -- temporary signal
    chip_clk		  : in 	  std_ulogic;
	clkm			  : in 	  std_ulogic;
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
end;

architecture rtl of chip_emu_top is

  -- CPU flags
  signal cpuerr : std_ulogic;

  -- chip signals
  signal chip_rst       : std_ulogic;
  signal sys_clk : std_logic_vector(0 to 0);
  signal chip_refclk    : std_ulogic := '0';
  signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal chip_pllclk    : std_ulogic;

  signal ddr_ahbsi   : ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
  signal ddr_ahbso   : ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);

begin

    process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_refclk <= chip_clk;
  chip_rst <= rstn;
  sys_clk(0) <= clkm;
  chip_pllbypass <= (others => '0');

  esp_1: esp
    generic map (
      SIMULATION => SIMULATION)
    port map (
      rst            => chip_rst,
      sys_clk        => sys_clk(0 to MEM_ID_RANGE_MSB),
      refclk         => chip_refclk,
      pllbypass      => chip_pllbypass,
      uart_rxd       => uart_rxd,
      uart_txd       => uart_txd,
      uart_ctsn      => uart_ctsn,
      uart_rtsn      => uart_rtsn,
      cpuerr         => cpuerr,
      ddr_ahbsi      => ddr_ahbsi, --open,
      ddr_ahbso      => ddr_ahbso, --ahbsv_none,
      eth0_ahbmi     => open,
      eth0_ahbmo     => ahbm_none,
      edcl_ahbmo     => ahbm_none,
      eth0_apbi      => open,
      eth0_apbo      => apb_none,
      sgmii0_apbi    => open,
      sgmii0_apbo    => apb_none,
      dvi_apbi       => open,
      dvi_apbo       => apb_none,
      dvi_ahbmi      => open,
      dvi_ahbmo      => ahbm_none,
      iolink_data_oen   => open,
      iolink_data_in    => iolink_data_in,
      iolink_data_out   => iolink_data_out,
      iolink_valid_in   => iolink_valid_in,
      iolink_valid_out  => iolink_valid_out,
      iolink_clk_in     => iolink_clk_in,
      iolink_clk_out    => iolink_clk_out,
      iolink_credit_in  => iolink_credit_in,
      iolink_credit_out => iolink_credit_out,
	  mon_noc	=> open,
	  mon_acc	=> open,
	  mon_mem	=> open,
	  mon_l2    => open,
	  mon_llc	=> open,
	  mon_dvfs	=> open
      );

end;
