-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
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
use work.sldcommon.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.soctiles.all;

entity esp is
  port (
    rst             : in    std_logic;
    sys_clk         : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
    refclk          : in    std_logic;
    pllbypass       : in    std_logic_vector(CFG_TILES_NUM - 1 downto 0);
    --pragma translate_off
    mctrl_ahbsi : out ahb_slv_in_type;
    mctrl_ahbso : in  ahb_slv_out_type;
    mctrl_apbi  : out apb_slv_in_type;
    mctrl_apbo  : in  apb_slv_out_type;
    --pragma translate_on
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    ndsuact         : out   std_logic;
    dsuerr          : out   std_logic;
    ddr_ahbsi      : out ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);
    ddr_ahbso      : in  ahb_slv_out_vector_type(0 to CFG_NMEM_TILE - 1);
    eth0_apbi       : out apb_slv_in_type;
    eth0_apbo       : in  apb_slv_out_type;
    sgmii0_apbi     : out apb_slv_in_type;
    sgmii0_apbo     : in  apb_slv_out_type;
    eth0_ahbmi      : out ahb_mst_in_type;
    eth0_ahbmo      : in  ahb_mst_out_type;
    edcl_ahbmo      : in  ahb_mst_out_type;
    dvi_apbi        : out apb_slv_in_type;
    dvi_apbo        : in  apb_slv_out_type;
    dvi_ahbmi       : out ahb_mst_in_type;
    dvi_ahbmo       : in  ahb_mst_out_type;
    -- Monitor signals
    mon_noc         : out monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
    mon_acc         : out monitor_acc_vector(0 to accelerators_num-1);
    mon_mem         : out monitor_mem_vector(0 to CFG_NMEM_TILE - 1);
    mon_l2          : out monitor_cache_vector(0 to CFG_NL2 - 1);
    mon_llc         : out monitor_cache_vector(0 to CFG_NLLC - 1);
    mon_dvfs        : out monitor_dvfs_vector(0 to CFG_TILES_NUM-1));
end;


architecture rtl of esp is

  component sync_noc_xy
    generic (
      flit_size : integer;
      XLEN      : integer;
      YLEN      : integer;
      TILES_NUM : integer;
      has_sync  : integer range 0 to 1);
    port (
      clk           : in  std_logic;
      clk_tile      : in  std_logic_vector(TILES_NUM-1 downto 0);
      rst           : in  std_logic;
      input_port    : in  noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
      stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
      output_port   : out noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
      stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
      -- Monitor output. Can be left unconnected
      mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
      );
  end component;

  constant nocs_num : integer := 6;

signal clk_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
type noc_flit_matrix is array (1 to nocs_num) of noc_flit_vector(CFG_TILES_NUM-1 downto 0);
type noc_ctrl_matrix is array (1 to nocs_num) of std_logic_vector(CFG_TILES_NUM-1 downto 0);

signal noc_input_port    : noc_flit_matrix;
signal noc_data_void_in  : noc_ctrl_matrix;
signal noc_stop_in       : noc_ctrl_matrix;
signal noc_output_port   : noc_flit_matrix;
signal noc_data_void_out : noc_ctrl_matrix;
signal noc_stop_out      : noc_ctrl_matrix;

signal rst_int       : std_logic;
signal sys_clk_int   : std_logic_vector(0 to CFG_NMEM_TILE - 1);
signal refclk_int    : std_logic_vector(CFG_TILES_NUM -1 downto 0);
signal pllbypass_int : std_logic_vector(CFG_TILES_NUM - 1 downto 0);
signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

type monitor_noc_cast_vector is array (1 to nocs_num) of monitor_noc_vector(0 to CFG_TILES_NUM-1);
signal mon_noc_vec : monitor_noc_cast_vector;
signal mon_dvfs_out : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);
signal mon_dvfs_domain  : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);

signal mon_l2_int : monitor_cache_vector(0 to CFG_TILES_NUM-1);
signal mon_llc_int : monitor_cache_vector(0 to CFG_TILES_NUM-1);

-- TODO: REMOVE!!! Debug unit messages must go through the NoC!
signal dbgi : l3_debug_in_vector(0 to CFG_NCPU_TILE-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU_TILE-1);

begin

  rst_int <= rst;
  clk_int_gen: for i in 0 to CFG_NMEM_TILE - 1 generate
    sys_clk_int(i) <= sys_clk(i);
  end generate clk_int_gen;
  pllbypass_int <= pllbypass;

  -----------------------------------------------------------------------------
  -- UART pads
  -----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_rtsn, uart_rtsn_int);


  -----------------------------------------------------------------------------
  -- DVFS domain probes steering
  -----------------------------------------------------------------------------
  domain_in_gen: for i in 0 to CFG_TILES_NUM-1 generate
    mon_dvfs_domain(i).clk <= '0';
    mon_dvfs_domain(i).transient <= mon_dvfs_out(tile_domain_master(i)).transient;
    mon_dvfs_domain(i).vf <= mon_dvfs_out(tile_domain_master(i)).vf;

    no_domain_master: if tile_domain(i) /= 0 and tile_has_pll(i) = 0 generate
      mon_dvfs_domain(i).acc_idle <= mon_dvfs_domain(tile_domain_master(i)).acc_idle;
      mon_dvfs_domain(i).traffic <= mon_dvfs_domain(tile_domain_master(i)).traffic;
      mon_dvfs_domain(i).burst <= mon_dvfs_domain(tile_domain_master(i)).burst;
      refclk_int(i) <= clk_tile(tile_domain_master(i));
    end generate no_domain_master;

    domain_master_gen: if tile_domain(i) = 0 or tile_has_pll(i) /= 0 generate
      refclk_int(i) <= refclk;
    end generate domain_master_gen;

  end generate domain_in_gen;

  domain_probes_gen: for k in 1 to domains_num-1 generate
    -- DVFS masters need info from slave DVFS tiles
    process (mon_dvfs_out)
      variable mon_dvfs_or : monitor_dvfs_type;
    begin  -- process
      mon_dvfs_or.acc_idle := '1';
      mon_dvfs_or.traffic := '0';
      mon_dvfs_or.burst := '0';
      for i in 0 to CFG_TILES_NUM-1 loop
        if tile_domain(i) = k then
          mon_dvfs_or.acc_idle := mon_dvfs_or.acc_idle and mon_dvfs_out(i).acc_idle;
          mon_dvfs_or.traffic := mon_dvfs_or.traffic or mon_dvfs_out(i).traffic;
          mon_dvfs_or.burst := mon_dvfs_or.burst or mon_dvfs_out(i).burst;
        end if;
      end loop;  -- i
      mon_dvfs_domain(domain_master_tile(k)).acc_idle <= mon_dvfs_or.acc_idle;
      mon_dvfs_domain(domain_master_tile(k)).traffic <= mon_dvfs_or.traffic;
      mon_dvfs_domain(domain_master_tile(k)).burst <= mon_dvfs_or.burst;
    end process;
  end generate domain_probes_gen;

  mon_dvfs <= mon_dvfs_out;
  -----------------------------------------------------------------------------
  -- TILES
  -----------------------------------------------------------------------------

  tiles_gen: for i in 0 to CFG_TILES_NUM - 1  generate
    empty_tile: if tile_type(i) = 0 generate
      noc_input_port(1)(i) <= (others => '0');
      noc_data_void_in(1)(i) <= '1';
      noc_stop_in(1)(i) <= '0';
      noc_input_port(2)(i) <= (others => '0');
      noc_data_void_in(2)(i) <= '1';
      noc_stop_in(2)(i) <= '0';
      noc_input_port(3)(i) <= (others => '0');
      noc_data_void_in(3)(i) <= '1';
      noc_stop_in(3)(i) <= '0';
      noc_input_port(4)(i) <= (others => '0');
      noc_data_void_in(4)(i) <= '1';
      noc_stop_in(4)(i) <= '0';
      noc_input_port(5)(i) <= (others => '0');
      noc_data_void_in(5)(i) <= '1';
      noc_stop_in(5)(i) <= '0';
      noc_input_port(6)(i) <= (others => '0');
      noc_data_void_in(6)(i) <= '1';
      noc_stop_in(6)(i) <= '0';
      mon_dvfs_out(i).vf <= (others => '0');
      mon_dvfs_out(i).clk <= sys_clk_int(0);
      mon_dvfs_out(i).acc_idle <= '0';
      mon_dvfs_out(i).traffic <= '0';
      mon_dvfs_out(i).burst <= '0';
      clk_tile(i) <= sys_clk_int(0);
    end generate empty_tile;

    cpu_tile: if tile_type(i) = 1 generate
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
      tile_cpu_i: tile_cpu
        generic map (
          tile_id => i)
        port map (
          rst                => rst_int,
          refclk             => refclk_int(i),
          pllbypass          => pllbypass_int(i),
          pllclk             => clk_tile(i),
          --TODO: REMOVE!
          dbgi   => dbgi(tile_cpu_id(i)),
          dbgo   => dbgo(tile_cpu_id(i)),
          noc1_input_port    => noc_input_port(1)(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port(1)(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port(2)(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port(2)(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port(3)(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port(3)(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port(4)(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port(4)(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port(5)(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port(5)(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port(6)(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port(6)(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_cache          => mon_l2_int(i),
          mon_dvfs_in        => mon_dvfs_domain(i),
          mon_dvfs           => mon_dvfs_out(i));

    end generate cpu_tile;

    accelerator_tile: if tile_type(i) = 2 generate
      assert tile_device(i) /= 0 report "Undefined device ID for accelerator tile" severity error;
      tile_acc_i: tile_acc
        generic map (
          tile_id => i)
        port map (
          rst                => rst_int,
          refclk             => refclk_int(i),
          pllbypass          => pllbypass_int(i),
          pllclk             => clk_tile(i),
          noc1_input_port    => noc_input_port(1)(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port(1)(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port(2)(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port(2)(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port(3)(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port(3)(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port(4)(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port(4)(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port(5)(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port(5)(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port(6)(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port(6)(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_dvfs_in        => mon_dvfs_domain(i),
          --Monitor signals
          mon_acc            => mon_acc(tile_acc_id(i)),
          mon_cache          => mon_l2_int(i),
          mon_dvfs           => mon_dvfs_out(i)
          );

    end generate accelerator_tile;

    io_tile: if tile_type(i) = 3 generate
      tile_io_i : tile_io
        port map (
          rst                => rst_int,
          clk                => sys_clk_int(0),
          eth0_apbi          => eth0_apbi,
          eth0_apbo          => eth0_apbo,
          sgmii0_apbi        => sgmii0_apbi,
          sgmii0_apbo        => sgmii0_apbo,
          eth0_ahbmi         => eth0_ahbmi,
          eth0_ahbmo         => eth0_ahbmo,
          edcl_ahbmo         => edcl_ahbmo,
          dvi_apbi           => dvi_apbi,
          dvi_apbo           => dvi_apbo,
          dvi_ahbmi          => dvi_ahbmi,
          dvi_ahbmo          => dvi_ahbmo,
          --pragma translate_off
          mctrl_ahbsi        => mctrl_ahbsi,
          mctrl_ahbso        => mctrl_ahbso,
          mctrl_apbi         => mctrl_apbi,
          mctrl_apbo         => mctrl_apbo,
          --pragma translate_on
          uart_rxd           => uart_rxd_int,
          uart_txd           => uart_txd_int,
          uart_ctsn          => uart_ctsn_int,
          uart_rtsn          => uart_rtsn_int,
          ndsuact            => ndsuact,
          dsuerr             => dsuerr,
          dbgi               => dbgi,
          dbgo               => dbgo,
          noc1_input_port    => noc_input_port(1)(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port(1)(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port(2)(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port(2)(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port(3)(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port(3)(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port(4)(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port(4)(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port(5)(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port(5)(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port(6)(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port(6)(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_dvfs           => mon_dvfs_out(i));
      clk_tile(i) <= sys_clk_int(0);
    end generate io_tile;

    mem_tile: if tile_type(i) = 4 generate
      tile_mem_i: tile_mem
        generic map (
          tile_id => i)
        port map (
          rst                => rst_int,
          clk                => sys_clk_int(tile_mem_id(i)),
          ddr_ahbsi          => ddr_ahbsi(tile_mem_id(i)),
          ddr_ahbso          => ddr_ahbso(tile_mem_id(i)),
          -- TODO: replace with direct reset for LLC instead!
          dbgi               => dbgi(0),
          noc1_input_port    => noc_input_port(1)(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port(1)(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port(2)(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port(2)(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port(3)(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port(3)(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port(4)(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port(4)(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port(5)(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port(5)(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port(6)(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port(6)(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_mem            => mon_mem(tile_mem_id(i)),
          mon_cache          => mon_llc_int(i),
          mon_dvfs           => mon_dvfs_out(i));
      clk_tile(i) <= sys_clk_int(tile_mem_id(i));

    end generate mem_tile;

  end generate tiles_gen;


  -----------------------------------------------------------------------------
  -- NoC
  -----------------------------------------------------------------------------

  sync_noc_xy_1: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(1),
      data_void_in    => noc_data_void_in(1),
      stop_in         => noc_stop_in(1),
      output_port     => noc_output_port(1),
      data_void_out   => noc_data_void_out(1),
      stop_out        => noc_stop_out(1),
      mon_noc         => mon_noc_vec(1)
      );

  --noc_output_port(2) <= (others => (others => '0'));
  --noc_data_void_out(2) <= (others => '1');
  --noc_stop_out(2) <= (others => '0');
  --mon_noc_vec(2) <= (others => monitor_noc_none);
  sync_noc_xy_2: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(2),
      data_void_in    => noc_data_void_in(2),
      stop_in         => noc_stop_in(2),
      output_port     => noc_output_port(2),
      data_void_out   => noc_data_void_out(2),
      stop_out        => noc_stop_out(2),
      mon_noc         => mon_noc_vec(2)
      );

  sync_noc_xy_3: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(3),
      data_void_in    => noc_data_void_in(3),
      stop_in         => noc_stop_in(3),
      output_port     => noc_output_port(3),
      data_void_out   => noc_data_void_out(3),
      stop_out        => noc_stop_out(3),
      mon_noc         => mon_noc_vec(3)
      );

  sync_noc_xy_4: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(4),
      data_void_in    => noc_data_void_in(4),
      stop_in         => noc_stop_in(4),
      output_port     => noc_output_port(4),
      data_void_out   => noc_data_void_out(4),
      stop_out        => noc_stop_out(4),
      mon_noc         => mon_noc_vec(4)
      );

  sync_noc_xy_5: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(5),
      data_void_in    => noc_data_void_in(5),
      stop_in         => noc_stop_in(5),
      output_port     => noc_output_port(5),
      data_void_out   => noc_data_void_out(5),
      stop_out        => noc_stop_out(5),
      mon_noc         => mon_noc_vec(5)
      );

  sync_noc_xy_6: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port(6),
      data_void_in    => noc_data_void_in(6),
      stop_in         => noc_stop_in(6),
      output_port     => noc_output_port(6),
      data_void_out   => noc_data_void_out(6),
      stop_out        => noc_stop_out(6),
      mon_noc         => mon_noc_vec(6)
      );

  monitor_noc_gen: for i in 1 to nocs_num generate
    monitor_noc_tiles_gen: for j in 0 to CFG_TILES_NUM-1 generate
      mon_noc(i,j) <= mon_noc_vec(i)(j);
    end generate monitor_noc_tiles_gen;
  end generate monitor_noc_gen;

  monitor_l2_gen: for i in 0 to CFG_NL2 - 1 generate
    mon_l2(i) <= mon_l2_int(cache_tile_id(i));
  end generate monitor_l2_gen;

  monitor_llc_gen: for i in 0 to CFG_NLLC - 1 generate
    mon_llc(i) <= mon_llc_int(llc_tile_id(i));
  end generate monitor_llc_gen;
 end;

