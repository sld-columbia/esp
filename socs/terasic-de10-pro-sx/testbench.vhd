-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
-----------------------------------------------------------------------------
-- Testbench for ESP on Terasic DE10-Pro SX; the HPS is not simulated.
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
end;

architecture behav of testbench is

  constant SIMULATION      : boolean := true;

  constant promfile : string := "prom.srec";  -- rom contents
  constant ramfile  : string := "ram.srec";   -- ram contents

  component top is
    generic (
      SIMULATION : boolean);
    port (
      reset       : in    std_ulogic;
      chip_refclk : in    std_ulogic;
      uart_rxd    : in    std_ulogic;
      uart_txd    : out   std_ulogic;
      uart_ctsn   : in    std_ulogic;
      uart_rtsn   : out   std_ulogic;
      led         : out   std_logic_vector(6 downto 0);
      ddr_awid    : out   std_logic_vector(3 downto 0);
      ddr_awaddr  : out   std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      ddr_awlen   : out   std_logic_vector(7 downto 0);
      ddr_awsize  : out   std_logic_vector(2 downto 0);
      ddr_awburst : out   std_logic_vector(1 downto 0);
      ddr_awlock  : out   std_logic;
      ddr_awcache : out   std_logic_vector(3 downto 0);
      ddr_awprot  : out   std_logic_vector(2 downto 0);
      ddr_awqos   : out   std_logic_vector(3 downto 0);
      ddr_awvalid : out   std_logic;
      ddr_awready : in    std_logic;
      ddr_wdata   : out   std_logic_vector(63 downto 0);
      ddr_wstrb   : out   std_logic_vector(7 downto 0);
      ddr_wlast   : out   std_logic;
      ddr_wvalid  : out   std_logic;
      ddr_wready  : in    std_logic;
      ddr_bid     : in    std_logic_vector(3 downto 0);
      ddr_bresp   : in    std_logic_vector(1 downto 0);
      ddr_bvalid  : in    std_logic;
      ddr_bready  : out   std_logic;
      ddr_arid    : out   std_logic_vector(3 downto 0);
      ddr_araddr  : out   std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
      ddr_arlen   : out   std_logic_vector(7 downto 0);
      ddr_arsize  : out   std_logic_vector(2 downto 0);
      ddr_arburst : out   std_logic_vector(1 downto 0);
      ddr_arlock  : out   std_logic;
      ddr_arcache : out   std_logic_vector(3 downto 0);
      ddr_arprot  : out   std_logic_vector(2 downto 0);
      ddr_arqos   : out   std_logic_vector(3 downto 0);
      ddr_arvalid : out   std_logic;
      ddr_arready : in    std_logic;
      ddr_rid     : in    std_logic_vector(3 downto 0);
      ddr_rdata   : in    std_logic_vector(63 downto 0);
      ddr_rresp   : in    std_logic_vector(1 downto 0);
      ddr_rlast   : in    std_logic;
      ddr_rvalid  : in    std_logic;
      ddr_rready  : out   std_logic;
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
      mo_hwdata   : in    std_logic_vector(31 downto 0));
  end component top;

  -- ESP top
  signal ddr_awid    : std_logic_vector(3 downto 0);
  signal ddr_awaddr  : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal ddr_awlen   : std_logic_vector(7 downto 0);
  signal ddr_awsize  : std_logic_vector(2 downto 0);
  signal ddr_awburst : std_logic_vector(1 downto 0);
  signal ddr_awlock  : std_logic;
  signal ddr_awcache : std_logic_vector(3 downto 0);
  signal ddr_awprot  : std_logic_vector(2 downto 0);
  signal ddr_awqos   : std_logic_vector(3 downto 0);
  signal ddr_awvalid : std_logic;
  signal ddr_awready : std_logic;
  signal ddr_wdata   : std_logic_vector(63 downto 0);
  signal ddr_wstrb   : std_logic_vector(7 downto 0);
  signal ddr_wlast   : std_logic;
  signal ddr_wvalid  : std_logic;
  signal ddr_wready  : std_logic;
  signal ddr_bid     : std_logic_vector(3 downto 0);
  signal ddr_bresp   : std_logic_vector(1 downto 0);
  signal ddr_bvalid  : std_logic;
  signal ddr_bready  : std_logic;
  signal ddr_arid    : std_logic_vector(3 downto 0);
  signal ddr_araddr  : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  signal ddr_arlen   : std_logic_vector(7 downto 0);
  signal ddr_arsize  : std_logic_vector(2 downto 0);
  signal ddr_arburst : std_logic_vector(1 downto 0);
  signal ddr_arlock  : std_logic;
  signal ddr_arcache : std_logic_vector(3 downto 0);
  signal ddr_arprot  : std_logic_vector(2 downto 0);
  signal ddr_arqos   : std_logic_vector(3 downto 0);
  signal ddr_arvalid : std_logic;
  signal ddr_arready : std_logic;
  signal ddr_rid     : std_logic_vector(3 downto 0);
  signal ddr_rdata   : std_logic_vector(63 downto 0);
  signal ddr_rresp   : std_logic_vector(1 downto 0);
  signal ddr_rlast   : std_logic;
  signal ddr_rvalid  : std_logic;
  signal ddr_rready  : std_logic;

  signal ddr_axi_si : axi_mosi_type;
  signal ddr_axi_so : axi_somi_type;

  signal tb_ddr_ar_accept : std_logic;
  signal tb_ddr_r_accept  : std_logic;
  signal tb_ddr_read_lane : std_logic;
  signal tb_ddr_read_word : std_logic;

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
  signal led    : std_logic_vector(6 downto 0);

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

  ddr_axi_si.aw.id(3 downto 0)             <= ddr_awid;
  ddr_axi_si.aw.id(XID_WIDTH - 1 downto 4) <= (others => '0');
  ddr_axi_si.aw.addr                       <= ddr_awaddr;
  ddr_axi_si.aw.len                        <= ddr_awlen;
  ddr_axi_si.aw.size                       <= ddr_awsize;
  ddr_axi_si.aw.burst                      <= ddr_awburst;
  ddr_axi_si.aw.lock                       <= ddr_awlock;
  ddr_axi_si.aw.cache                      <= ddr_awcache;
  ddr_axi_si.aw.prot                       <= ddr_awprot;
  ddr_axi_si.aw.valid                      <= ddr_awvalid;
  ddr_axi_si.aw.qos                        <= ddr_awqos;
  ddr_axi_si.aw.atop                       <= (others => '0');
  ddr_axi_si.aw.region                     <= (others => '0');
  ddr_axi_si.aw.user                       <= (others => '0');
  ddr_axi_si.w.last                        <= ddr_wlast;
  ddr_axi_si.w.valid                       <= ddr_wvalid;
  ddr_axi_si.w.user                        <= (others => '0');
  ddr_axi_si.b.ready                       <= ddr_bready;
  ddr_axi_si.ar.id(3 downto 0)             <= ddr_arid;
  ddr_axi_si.ar.id(XID_WIDTH - 1 downto 4) <= (others => '0');
  ddr_axi_si.ar.addr                       <= ddr_araddr;
  ddr_axi_si.ar.len                        <= ddr_arlen;
  ddr_axi_si.ar.size                       <= ddr_arsize;
  ddr_axi_si.ar.burst                      <= ddr_arburst;
  ddr_axi_si.ar.lock                       <= ddr_arlock;
  ddr_axi_si.ar.cache                      <= ddr_arcache;
  ddr_axi_si.ar.prot                       <= ddr_arprot;
  ddr_axi_si.ar.valid                      <= ddr_arvalid;
  ddr_axi_si.ar.qos                        <= ddr_arqos;
  ddr_axi_si.ar.region                     <= (others => '0');
  ddr_axi_si.ar.user                       <= (others => '0');
  ddr_axi_si.r.ready                       <= ddr_rready;

  ddr_awready <= ddr_axi_so.aw.ready;
  ddr_wready  <= ddr_axi_so.w.ready;
  ddr_bid     <= ddr_axi_so.b.id(3 downto 0);
  ddr_bresp   <= ddr_axi_so.b.resp;
  ddr_bvalid  <= ddr_axi_so.b.valid;
  ddr_arready <= ddr_axi_so.ar.ready;
  ddr_rid     <= ddr_axi_so.r.id(3 downto 0);
  ddr_rresp   <= ddr_axi_so.r.resp;
  ddr_rlast   <= ddr_axi_so.r.last;
  ddr_rvalid  <= ddr_axi_so.r.valid;

  tb_ddr_ar_accept <= ddr_arvalid and ddr_arready;
  tb_ddr_r_accept  <= ddr_rvalid and ddr_rready;

  ddr_model_lane : process(chip_refclk, reset)
  begin
    if reset = '1' then
      tb_ddr_read_lane <= '0';
      tb_ddr_read_word <= '0';
    elsif rising_edge(chip_refclk) then
      if tb_ddr_ar_accept = '1' then
        tb_ddr_read_lane <= ddr_araddr(2);
        if ddr_arsize = XSIZE_WORD then
          tb_ddr_read_word <= '1';
        else
          tb_ddr_read_word <= '0';
        end if;
      end if;

      if tb_ddr_r_accept = '1' and tb_ddr_read_word = '1' then
        tb_ddr_read_lane <= not tb_ddr_read_lane;
      end if;
    end if;
  end process ddr_model_lane;

  ddr_model_data_64_gen : if AXIDW = 64 generate
    ddr_axi_si.w.data <= ddr_wdata;
    ddr_axi_si.w.strb <= ddr_wstrb;
    ddr_rdata <= ddr_axi_so.r.data;
  end generate ddr_model_data_64_gen;

  ddr_model_data_32_gen : if AXIDW = 32 generate
    ddr_axi_si.w.data <= ddr_wdata(63 downto 32) when ddr_wstrb(7 downto 4) /= "0000" else
                         ddr_wdata(31 downto 0);
    ddr_axi_si.w.strb <= ddr_wstrb(7 downto 4) when ddr_wstrb(7 downto 4) /= "0000" else
                         ddr_wstrb(3 downto 0);
    ddr_rdata <= ddr_axi_so.r.data & X"00000000" when tb_ddr_read_lane = '1' else
                 X"00000000" & ddr_axi_so.r.data;
  end generate ddr_model_data_32_gen;

  ddr_model : axi_ram_sim
    generic map (
      kbytes => 2048,
      DATA_WIDTH => AXIDW,
      ADDR_WIDTH => GLOB_PHYS_ADDR_BITS,
      STRB_WIDTH => AW
      )
    port map(
      rst        => rstn,
      clk        => chip_refclk,
      ddr_axi_si => ddr_axi_si,
      ddr_axi_so => ddr_axi_so
      );


  -- ESP top
  cpu : top
    generic map (
      SIMULATION => SIMULATION)
    port map (
      reset       => reset,
      chip_refclk => chip_refclk,
      uart_rxd    => uart_rxd,
      uart_txd    => uart_txd,
      uart_ctsn   => uart_ctsn,
      uart_rtsn   => uart_rtsn,
      led         => led,
      ddr_awid    => ddr_awid,
      ddr_awaddr  => ddr_awaddr,
      ddr_awlen   => ddr_awlen,
      ddr_awsize  => ddr_awsize,
      ddr_awburst => ddr_awburst,
      ddr_awlock  => ddr_awlock,
      ddr_awcache => ddr_awcache,
      ddr_awprot  => ddr_awprot,
      ddr_awqos   => ddr_awqos,
      ddr_awvalid => ddr_awvalid,
      ddr_awready => ddr_awready,
      ddr_wdata   => ddr_wdata,
      ddr_wstrb   => ddr_wstrb,
      ddr_wlast   => ddr_wlast,
      ddr_wvalid  => ddr_wvalid,
      ddr_wready  => ddr_wready,
      ddr_bid     => ddr_bid,
      ddr_bresp   => ddr_bresp,
      ddr_bvalid  => ddr_bvalid,
      ddr_bready  => ddr_bready,
      ddr_arid    => ddr_arid,
      ddr_araddr  => ddr_araddr,
      ddr_arlen   => ddr_arlen,
      ddr_arsize  => ddr_arsize,
      ddr_arburst => ddr_arburst,
      ddr_arlock  => ddr_arlock,
      ddr_arcache => ddr_arcache,
      ddr_arprot  => ddr_arprot,
      ddr_arqos   => ddr_arqos,
      ddr_arvalid => ddr_arvalid,
      ddr_arready => ddr_arready,
      ddr_rid     => ddr_rid,
      ddr_rdata   => ddr_rdata,
      ddr_rresp   => ddr_rresp,
      ddr_rlast   => ddr_rlast,
      ddr_rvalid  => ddr_rvalid,
      ddr_rready  => ddr_rready,
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


end;
