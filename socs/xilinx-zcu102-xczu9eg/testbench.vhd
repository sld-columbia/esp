-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------------
-- Testbench for ESP on Xilinx ZCU102 (NB: the host ARM core is not simulated)
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use work.libdcom.all;
  use work.sim.all;
  use work.amba.all;
  use work.stdlib.all;
  use work.devices.all;
  use work.gencomp.all;
  use work.grlib_config.all;
  use work.sim.all;
  use work.esp_global.all;
  use work.socmap.all;

entity testbench is
end entity testbench;

architecture behav of testbench is

  constant SIMULATION : boolean := true;

  constant PROMFILE : string := "prom.srec"; -- rom contents
  constant RAMFILE  : string := "ram.srec";  -- ram contents

  component top is
    generic (
      simulation : boolean
    );
    port (
      reset       : in    std_ulogic;
      chip_refclk : in    std_ulogic;
      uart_rxd    : in    std_ulogic;
      uart_txd    : out   std_ulogic;
      uart_ctsn   : in    std_ulogic;
      uart_rtsn   : out   std_ulogic;
      led         : out   std_logic_vector(6 downto 0);
      so_hready   : in    std_ulogic;
      so_hresp    : in    std_logic_vector(1 downto 0);
      so_hrdata   : in    std_logic_vector(AHBDW - 1 downto 0);
      si_htrans   : out   std_logic_vector(1 downto 0);
      si_haddr    : out   std_logic_vector(31 downto 0);
      si_hwrite   : out   std_ulogic;
      si_hsize    : out   std_logic_vector(2 downto 0);
      si_hburst   : out   std_logic_vector(2 downto 0);
      si_hprot    : out   std_logic_vector(3 downto 0);
      si_hwdata   : out   std_logic_vector(AHBDW - 1 downto 0);
      si_hsel     : out   std_ulogic;
      si_hready   : out   std_ulogic;
      mi_hready   : out   std_ulogic;
      mi_hresp    : out   std_logic_vector(1 downto 0);
      mi_hrdata   : out   std_logic_vector(31 downto 0);
      mo_hlock    : in    std_ulogic;
      mo_htrans   : in    std_logic_vector(1 downto 0);
      mo_haddr    : in    std_logic_vector(31 downto 0);
      mo_hwrite   : in    std_ulogic;
      mo_hsize    : in    std_logic_vector(2 downto 0);
      mo_hburst   : in    std_logic_vector(2 downto 0);
      mo_hprot    : in    std_logic_vector(3 downto 0);
      mo_hwdata   : in    std_logic_vector(31 downto 0)
    );
  end component top;

  -- ESP top
  signal so_hready : std_ulogic;
  signal so_hresp  : std_logic_vector(1 downto 0);
  signal so_hrdata : std_logic_vector(AHBDW - 1 downto 0);
  signal si_htrans : std_logic_vector(1 downto 0);
  signal si_haddr  : std_logic_vector(31 downto 0);
  signal si_hwrite : std_ulogic;
  signal si_hsize  : std_logic_vector(2 downto 0);
  signal si_hburst : std_logic_vector(2 downto 0);
  signal si_hprot  : std_logic_vector(3 downto 0);
  signal si_hwdata : std_logic_vector(AHBDW - 1 downto 0);
  signal mi_hready : std_ulogic;
  signal mi_hresp  : std_logic_vector(1 downto 0);
  signal si_hsel   : std_ulogic;
  signal si_hready : std_ulogic;

  -- PS-side memory model
  signal ddr_ahbsi : ahb_slv_in_type;
  signal ddr_ahbso : ahb_slv_out_type;

  -- Reset and clock
  signal reset           : std_ulogic := '1';
  signal rstn            : std_ulogic;
  signal chip_refclk_int : std_logic  := '0';
  signal chip_refclk     : std_logic;

  -- UART
  signal uart_rxd  : std_ulogic;
  signal uart_txd  : std_ulogic;
  signal uart_ctsn : std_ulogic;
  signal uart_rtsn : std_ulogic;

  -- GPIO
  signal led : std_logic_vector(6 downto 0);

begin

  -- clock and reset
  reset           <= '0'                 after 2500 ns;
  chip_refclk_int <= not chip_refclk_int after 6.67 ns;
  chip_refclk     <= chip_refclk_int;

  -- UART
  uart_rxd  <= '0';
  uart_ctsn <= '0';

  -- DDR model
  rstn <= not reset;

  ddr_ahbsi.hready <= si_hready;

  hsel_gen : process (si_hsel) is
  begin  -- process hsel_gen

    ddr_ahbsi.hsel                <= (others => '0');
    ddr_ahbsi.hsel(0)             <= si_hsel;
    ddr_ahbsi.hmaster             <= (others => '0');
    ddr_ahbsi.hmaster(CFG_DEFMST) <= '1';

  end process hsel_gen;

  ddr_ahbsi.htrans    <= si_htrans;
  ddr_ahbsi.haddr     <= si_haddr;
  ddr_ahbsi.hwrite    <= si_hwrite;
  ddr_ahbsi.hsize     <= si_hsize;
  ddr_ahbsi.hburst    <= si_hburst;
  ddr_ahbsi.hprot     <= si_hprot;
  ddr_ahbsi.hwdata    <= si_hwdata;
  ddr_ahbsi.hmastlock <= '0';
  ddr_ahbsi.hirq      <= (others => '0');
  ddr_ahbsi.testen    <= '0';
  ddr_ahbsi.testrst   <= '0';
  ddr_ahbsi.scanen    <= '0';
  ddr_ahbsi.testoen   <= '0';
  ddr_ahbsi.testin    <= (others => '0');

  so_hready <= ddr_ahbso.hready;
  so_hresp  <= ddr_ahbso.hresp;
  so_hrdata <= ddr_ahbso.hrdata;

  ddr_model : component ahbram_sim
    generic map (
      hindex => 0,
      tech   => 0,
      kbytes => 2048,
      pipe   => 0,
      maccsz => AHBDW,
      fname  => "ram.srec"
    )
    port map (
      rst   => rstn,
      clk   => chip_refclk,
      haddr => 16#400#,
      hmask => ddr_hmask(0),
      ahbsi => ddr_ahbsi,
      ahbso => ddr_ahbso
    );

  -- ESP top
  cpu : component top
    generic map (
      simulation => SIMULATION
    )
    port map (
      reset       => reset,
      chip_refclk => chip_refclk,
      uart_rxd    => uart_rxd,
      uart_txd    => uart_txd,
      uart_ctsn   => uart_ctsn,
      uart_rtsn   => uart_rtsn,
      led         => led,
      so_hready   => so_hready,
      so_hresp    => so_hresp,
      so_hrdata   => so_hrdata,
      si_htrans   => si_htrans,
      si_haddr    => si_haddr,
      si_hwrite   => si_hwrite,
      si_hsize    => si_hsize,
      si_hburst   => si_hburst,
      si_hprot    => si_hprot,
      si_hwdata   => si_hwdata,
      si_hsel     => si_hsel,
      si_hready   => si_hready,
      mi_hready   => open,
      mi_hresp    => open,
      mi_hrdata   => open,
      mo_hlock    => '0',
      mo_htrans   => (others => '0'),
      mo_haddr    => (others => '0'),
      mo_hwrite   => '0',
      mo_hsize    => (others => '0'),
      mo_hburst   => (others => '0'),
      mo_hprot    => (others => '0'),
      mo_hwdata   => (others => '0')
    );

end architecture behav;
