-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.grlib_config.all;
use work.stdlib.all;
use work.amba.all;
use work.gencomp.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;

entity zynqmp_top_wrapper is
  port (
    uart_rxd         : in    std_ulogic;
    uart_txd         : out   std_ulogic;
    uart_ctsn        : in    std_ulogic;
    uart_rtsn        : out   std_ulogic;
    switch           : in    std_logic_vector(7 downto 0);
    led              : out   std_logic_vector(6 downto 0)
    );

end zynqmp_top_wrapper;

architecture rtl of zynqmp_top_wrapper is

  component top is
    generic (
      SIMULATION : boolean);
    port (
      reset       : in  std_ulogic;
      chip_refclk : in  std_ulogic;
      uart_rxd    : in  std_ulogic;
      uart_txd    : out std_ulogic;
      uart_ctsn   : in  std_ulogic;
      uart_rtsn   : out std_ulogic;
      led         : out std_logic_vector(6 downto 0);
      so_hready   : in  std_ulogic;
      so_hresp    : in  std_logic_vector(1 downto 0);
      so_hrdata   : in  std_logic_vector(AHBDW - 1 downto 0);
      si_htrans   : out std_logic_vector(1 downto 0);
      si_haddr    : out std_logic_vector(31 downto 0);
      si_hwrite   : out std_ulogic;
      si_hsize    : out std_logic_vector(2 downto 0);
      si_hburst   : out std_logic_vector(2 downto 0);
      si_hprot    : out std_logic_vector(3 downto 0);
      si_hwdata   : out std_logic_vector(AHBDW - 1 downto 0);
      si_hsel     : out std_ulogic;
      si_hready   : out std_ulogic;
      mi_hready   : out std_ulogic;
      mi_hresp    : out std_logic_vector(1 downto 0);
      mi_hrdata   : out std_logic_vector(31 downto 0);
      mo_hlock    : in  std_ulogic;
      mo_htrans   : in  std_logic_vector(1 downto 0);
      mo_haddr    : in  std_logic_vector(31 downto 0);
      mo_hwrite   : in  std_ulogic;
      mo_hsize    : in  std_logic_vector(2 downto 0);
      mo_hburst   : in  std_logic_vector(2 downto 0);
      mo_hprot    : in  std_logic_vector(3 downto 0);
      mo_hwdata   : in  std_logic_vector(31 downto 0));
  end component top;

  component zynqmpsoc is
    port (
      peripheral_reset_0         : out std_logic_vector (0 to 0);
      pl_clk0                    : out std_logic;
      dip_switches_8bits_tri_i   : in  std_logic_vector(7 downto 0);
      ahb_interface_0_htrans     : in  std_logic_vector (1 downto 0);
      ahb_interface_0_haddr      : in  std_logic_vector (31 downto 0);
      ahb_interface_0_hwrite     : in  std_logic;
      ahb_interface_0_hsize      : in  std_logic_vector (2 downto 0);
      ahb_interface_0_hburst     : in  std_logic_vector (2 downto 0);
      ahb_interface_0_hprot      : in  std_logic_vector (3 downto 0);
      ahb_interface_0_hwdata     : in  std_logic_vector (AHBDW - 1 downto 0);
      ahb_interface_0_sel        : in  std_logic;
      ahb_interface_0_hready_in  : in  std_logic;
      ahb_interface_0_hrdata     : out std_logic_vector (AHBDW - 1 downto 0);
      ahb_interface_0_hready_out : out std_logic;
      ahb_interface_0_hresp      : out std_logic;
      m_ahb_0_haddr              : out std_logic_vector (31 downto 0);
      m_ahb_0_hburst             : out std_logic_vector (2 downto 0);
      m_ahb_0_hmastlock          : out std_logic;
      m_ahb_0_hprot              : out std_logic_vector (3 downto 0);
      m_ahb_0_hrdata             : in  std_logic_vector (31 downto 0);
      m_ahb_0_hready             : in  std_logic;
      m_ahb_0_hresp              : in  std_logic;
      m_ahb_0_hsize              : out std_logic_vector (2 downto 0);
      m_ahb_0_htrans             : out std_logic_vector (1 downto 0);
      m_ahb_0_hwdata             : out std_logic_vector (31 downto 0);
      m_ahb_0_hwrite             : out std_logic);
  end component zynqmpsoc;

  -- Clock and reset
  signal reset       : std_ulogic;
  signal chip_refclk : std_ulogic;

  -- AHB slave outputs
  signal so_hready   : std_ulogic;
  signal so_hresp    : std_logic_vector(1 downto 0);
  signal so_hrdata   : std_logic_vector(AHBDW - 1 downto 0);

  -- AHB slave inputs
  signal si_htrans   : std_logic_vector(1 downto 0);
  signal si_haddr    : std_logic_vector(31 downto 0);
  signal si_hwrite   : std_ulogic;
  signal si_hsize    : std_logic_vector(2 downto 0);
  signal si_hburst   : std_logic_vector(2 downto 0);
  signal si_hprot    : std_logic_vector(3 downto 0);
  signal si_hwdata   : std_logic_vector(AHBDW - 1 downto 0);
  signal si_hsel     : std_ulogic;
  signal si_hready   : std_ulogic;

  -- AHB master inputs
  signal mi_hready : std_ulogic;                          -- transfer done
  signal mi_hresp  : std_logic_vector(1 downto 0);        -- response type
  signal mi_hrdata : std_logic_vector(31 downto 0);       -- read data bus

  -- AHB master outputs
  signal mo_hlock  : std_ulogic;                          -- lock request
  signal mo_htrans : std_logic_vector(1 downto 0);        -- transfer type
  signal mo_haddr  : std_logic_vector(31 downto 0);       -- address bus (byte)
  signal mo_hwrite : std_ulogic;                          -- read/write
  signal mo_hsize  : std_logic_vector(2 downto 0);        -- transfer size
  signal mo_hburst : std_logic_vector(2 downto 0);        -- burst type
  signal mo_hprot  : std_logic_vector(3 downto 0);        -- protection control
  signal mo_hwdata : std_logic_vector(31 downto 0);       -- write data bus

begin

  esptop_i : top
    generic map (
      simulation => false)
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
      mi_hready   => mi_hready,
      mi_hresp    => mi_hresp,
      mi_hrdata   => mi_hrdata,
      mo_hlock    => mo_hlock,
      mo_htrans   => mo_htrans,
      mo_haddr    => mo_haddr,
      mo_hwrite   => mo_hwrite,
      mo_hsize    => mo_hsize,
      mo_hburst   => mo_hburst,
      mo_hprot    => mo_hprot,
      mo_hwdata   => mo_hwdata);

  so_hresp(1) <= '0';

  zynqmpsoc_i : zynqmpsoc
    port map (
      peripheral_reset_0(0)      => reset,
      pl_clk0                    => chip_refclk,
      dip_switches_8bits_tri_i   => switch,
      ahb_interface_0_htrans     => si_htrans,
      ahb_interface_0_haddr      => si_haddr,
      ahb_interface_0_hwrite     => si_hwrite,
      ahb_interface_0_hsize      => si_hsize,
      ahb_interface_0_hburst     => si_hburst,
      ahb_interface_0_hprot      => si_hprot,
      ahb_interface_0_hwdata     => si_hwdata,
      ahb_interface_0_sel        => si_hsel,
      ahb_interface_0_hready_in  => si_hready,
      ahb_interface_0_hrdata     => so_hrdata,
      ahb_interface_0_hready_out => so_hready,
      ahb_interface_0_hresp      => so_hresp(0),
      m_ahb_0_haddr              => mo_haddr,
      m_ahb_0_hburst             => mo_hburst,
      m_ahb_0_hmastlock          => mo_hlock,
      m_ahb_0_hprot              => mo_hprot,
      m_ahb_0_hrdata             => mi_hrdata,
      m_ahb_0_hready             => mi_hready,
      m_ahb_0_hresp              => mi_hresp(0),
      m_ahb_0_hsize              => mo_hsize,
      m_ahb_0_htrans             => mo_htrans,
      m_ahb_0_hwdata             => mo_hwdata,
      m_ahb_0_hwrite             => mo_hwrite);

end;
