-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
------------------------------------------------------------------------------
--  ESP - xilinx - zcu106
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity top is
  generic (
    SIMULATION : boolean := false
    );
  port (
    reset            : in    std_ulogic;
    chip_refclk      : in    std_ulogic;  -- ZYNQ MP PL clock (configured to 75MHz)
    uart_rxd         : in    std_ulogic;  -- UART1_RX (u1i.rxd)
    uart_txd         : out   std_ulogic;  -- UART1_TX (u1o.txd)
    uart_ctsn        : in    std_ulogic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn        : out   std_ulogic;  -- UART1_RTSN (u1o.rtsn)
    led              : out   std_logic_vector(6 downto 0);
    -- AHB slave outputs
    so_hready        : in    std_ulogic;  -- transfer done
    so_hresp         : in    std_logic_vector(1 downto 0);  -- response type
    so_hrdata        : in    std_logic_vector(AHBDW - 1 downto 0);  -- read data bus
    -- AHB slave inputs
    si_htrans        : out   std_logic_vector(1 downto 0);  -- transfer type
    si_haddr         : out   std_logic_vector(31 downto 0);  -- address bus (byte)
    si_hwrite        : out   std_ulogic;  -- read/write
    si_hsize         : out   std_logic_vector(2 downto 0);  -- transfer size
    si_hburst        : out   std_logic_vector(2 downto 0);  -- burst type
    si_hprot         : out   std_logic_vector(3 downto 0);  -- protection control
    si_hwdata        : out   std_logic_vector(AHBDW - 1 downto 0); -- write data bus
    si_hsel          : out   std_ulogic;  -- slave selected
    si_hready        : out   std_ulogic;  -- AHB ready in
    -- AHB master inputs
    mi_hready        : out   std_ulogic;  -- transfer done
    mi_hresp         : out   std_logic_vector(1 downto 0);  -- response type
    mi_hrdata        : out   std_logic_vector(31 downto 0);  -- read data bus
    -- AHB master outputs
    mo_hlock         : in    std_ulogic;  -- lock request
    mo_htrans        : in    std_logic_vector(1 downto 0);  -- transfer type
    mo_haddr         : in    std_logic_vector(31 downto 0);  -- address bus (byte)
    mo_hwrite        : in    std_ulogic;  -- read/write
    mo_hsize         : in    std_logic_vector(2 downto 0);  -- transfer size
    mo_hburst        : in    std_logic_vector(2 downto 0);  -- burst type
    mo_hprot         : in    std_logic_vector(3 downto 0);  -- protection control
    mo_hwdata        : in    std_logic_vector(31 downto 0)  -- write data bus
    );
end top;


architecture rtl of top is

constant CPU_FREQ : integer := 75000;  -- cpu frequency in KHz

  -- clock and reset
  signal rstn      : std_ulogic;
  signal lock  : std_ulogic;

  -- Memory controller DDR4
  signal ddr_ahbsi        : ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
  signal ddr_ahbso        : ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);

  -- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

  -- DVI (unused on this board)
  signal dvi_apbi  : apb_slv_in_type;
  signal dvi_apbo  : apb_slv_out_type;
  signal dvi_ahbmi : ahb_mst_in_type;
  signal dvi_ahbmo : ahb_mst_out_type;

  -- Ethernet (unused on this board)
  signal eth0_apbi   : apb_slv_in_type;
  signal eth0_apbo   : apb_slv_out_type;
  signal sgmii0_apbi : apb_slv_in_type;
  signal sgmii0_apbo : apb_slv_out_type;
  signal eth0_ahbmi  : ahb_mst_in_type;
  signal eth0_ahbmo  : ahb_mst_out_type;
  signal edcl_ahbmo  : ahb_mst_out_type;

  -- CPU flags
  signal cpuerr : std_ulogic;

  -- NOC
  signal sys_clk        : std_logic_vector(0 to 0);
  signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);

  attribute keep                    : boolean;
  attribute syn_keep                : string;
  attribute keep of chip_refclk     : signal is true;
  attribute syn_keep of chip_refclk : signal is "true";

  constant edcl_hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_GAISLER, GAISLER_EDCLMST, 0, 0, 0),
    others => zero32);

begin

  ----------------------------------------------------------------------
  --- FPGA Reset and Clock generation  ---------------------------------
  ----------------------------------------------------------------------

  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (reset, chip_refclk, lock, rstn, open);
  lock <= '1';

  -----------------------------------------------------------------------------
  -- LEDs
  -----------------------------------------------------------------------------

  -- From CPU 0
  led0_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(0), cpuerr);
  --pragma translate_off
  process(chip_refclk, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  led2_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(2), '0');
  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(3), '0');
  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(4), ddr_ahbso(0).hready);

  -- unused
  led1_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(1), '0');
  led5_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(5), '0');
  led6_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(6), '0');


  -----------------------------------------------------------------------------
  -- UART pads
  -----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x12v, strength => 8, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x12v, strength => 8, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x12v, strength => 8, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x12v, strength => 8, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int);

  ----------------------------------------------------------------------
  --- PS-side DDR4 interface through Xilinx AHB-L-to-AXI adapter
  ----------------------------------------------------------------------
  si_hready             <= ddr_ahbsi(0).hready;
  si_hsel               <= ddr_ahbsi(0).hsel(0);
  si_htrans             <= ddr_ahbsi(0).htrans;
  si_haddr(31)          <= '0'; -- ZCU102 has fixed address map
  si_haddr(30 downto 0) <= ddr_ahbsi(0).haddr(30 downto 0);
  si_hwrite             <= ddr_ahbsi(0).hwrite;
  si_hsize              <= ddr_ahbsi(0).hsize;
  si_hburst             <= ddr_ahbsi(0).hburst;
  si_hprot              <= ddr_ahbsi(0).hprot;
  si_hwdata             <= ddr_ahbsi(0).hwdata;

  ddr_ahbso(0).hready  <= so_hready;
  ddr_ahbso(0).hresp   <= so_hresp;
  ddr_ahbso(0).hrdata  <= so_hrdata;
  ddr_ahbso(0).hsplit  <= (others => '0');
  ddr_ahbso(0).hirq    <= (others => '0');
  ddr_ahbso(0).hconfig <= mig7_hconfig(0);
  ddr_ahbso(0).hindex  <= 0;

  -----------------------------------------------------------------------------
  -- Host interface through Xilinx AXI-to-AHB-L adapter
  -----------------------------------------------------------------------------
  edcl_ahbmo.hbusreq <= '0' when edcl_ahbmo.htrans = HTRANS_IDLE else '1';
  edcl_ahbmo.hlock   <= mo_hlock;
  edcl_ahbmo.htrans  <= mo_htrans;
  edcl_ahbmo.haddr   <= mo_haddr;
  edcl_ahbmo.hwrite  <= mo_hwrite;
  edcl_ahbmo.hsize   <= mo_hsize;
  edcl_ahbmo.hburst  <= mo_hburst;
  edcl_ahbmo.hprot   <= mo_hprot;
  edcl_ahbmo.hwdata  <= ahbdrivedata(mo_hwdata);
  edcl_ahbmo.hirq    <= (others => '0');
  edcl_ahbmo.hconfig <= edcl_hconfig;
  edcl_ahbmo.hindex  <= 1;

  mi_hready <= eth0_ahbmi.hready;
  mi_hresp  <= eth0_ahbmi.hresp;
  mi_hrdata <= eth0_ahbmi.hrdata(31 downto 0);

  -----------------------------------------------------------------------
  ---  ETHERNET ---------------------------------------------------------
  -----------------------------------------------------------------------

  eth0_apbo   <= apb_none;
  sgmii0_apbo <= apb_none;
  eth0_ahbmo  <= ahbm_none;

  ------------------------------------------------------------------------
  -- CHIP
  ------------------------------------------------------------------------
  sys_clk(0)     <= chip_refclk;
  chip_pllbypass <= (others => '0');

  esp_1 : esp
    generic map (
      SIMULATION => SIMULATION)
    port map (
      rst         => rstn,
      sys_clk     => sys_clk(0 to MEM_ID_RANGE_MSB),
      refclk      => chip_refclk,
      pllbypass   => chip_pllbypass,
      uart_rxd    => uart_rxd_int,
      uart_txd    => uart_txd_int,
      uart_ctsn   => uart_ctsn_int,
      uart_rtsn   => uart_rtsn_int,
      cpuerr      => cpuerr,
      ddr_ahbsi   => ddr_ahbsi,
      ddr_ahbso   => ddr_ahbso,
      eth0_ahbmi  => eth0_ahbmi,
      eth0_ahbmo  => eth0_ahbmo,
      edcl_ahbmo  => edcl_ahbmo,
      eth0_apbi   => eth0_apbi,
      eth0_apbo   => eth0_apbo,
      sgmii0_apbi => sgmii0_apbi,
      sgmii0_apbo => sgmii0_apbo,
      dvi_apbi    => dvi_apbi,
      dvi_apbo    => dvi_apbo,
      dvi_ahbmi   => dvi_ahbmi,
      dvi_ahbmo   => dvi_ahbmo);

end;
