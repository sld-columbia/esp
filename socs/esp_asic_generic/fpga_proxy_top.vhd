-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
use work.tb_pkg.all;

entity fpga_proxy_top is

  generic (
    SIMULATION : boolean := false;
    JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1 := -1);
  port (
    reset             : in    std_ulogic;  -- GLobal FPGA reset (active high)
    ext_clk_noc       : out   std_logic;
    ext_clk           : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
    -- Main clock
    main_clk_p         : in    std_ulogic;  -- 78.25 MHz clock
    main_clk_n         : in    std_ulogic;  -- 78.25 MHz clock
    -- Memory link
    fpga_data         : inout std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
    fpga_valid_in     : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_valid_out    : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_in       : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_out      : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_in    : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_out   : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
      -- I/O link
    iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_valid_in   : in    std_ulogic;
    iolink_valid_out  : out   std_ulogic;
    iolink_clk_in     : in    std_ulogic;
    iolink_clk_out    : out   std_ulogic;
    iolink_credit_in  : in    std_ulogic;
    iolink_credit_out : out   std_ulogic;
    -- Test interface
    tdi               : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
    tdo               : in    std_logic_vector(0 to CFG_TILES_NUM - 1);
    tms               : out   std_logic;
    tclk              : out   std_logic;
    -- Ethernet signals
    reset_o2          : out   std_ulogic;
    etx_clk           : in    std_ulogic;
    erx_clk           : in    std_ulogic;
    erxd              : in    std_logic_vector(3 downto 0);
    erx_dv            : in    std_ulogic;
    erx_er            : in    std_ulogic;
    erx_col           : in    std_ulogic;
    erx_crs           : in    std_ulogic;
    etxd              : out   std_logic_vector(3 downto 0);
    etx_en            : out   std_ulogic;
    etx_er            : out   std_ulogic;
    emdc              : out   std_ulogic;
    emdio             : inout std_logic;
    -- DDR0
    c0_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c0_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c0_ddr4_act_n     : out   std_logic;
    c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n   : out   std_logic;
    c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c0_calib_complete : out   std_logic;
    c0_diagnostic_led : out   std_ulogic;
    LED_RED           : out   std_ulogic;
    LED_GREEN         : out   std_ulogic;
    LED_BLUE          : out   std_ulogic;
    LED_YELLOW        : out   std_ulogic
    );
end entity fpga_proxy_top;

architecture rtl of fpga_proxy_top is

  constant FPGA_PROXY_TECH : integer := virtexu;
  constant FPGA_PROXY_FREQ : integer := 78125;  -- FPGA frequency in KHz
  constant MAX_NMEM_TILES  : integer := 4;

  component ahb2mig_ebddr4r5 is
    generic (
      hindex : integer;
      haddr  : integer;
      hmask  : integer
      );
    port (
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
      ahbso            : out   ahb_slv_out_type;
      ahbsi            : in    ahb_slv_in_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      clk_amba         : in    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_sync_rst  : out   std_logic);
  end component ahb2mig_ebddr4r5;

  function set_ddr_index (
    constant n : integer range 0 to 3)
    return integer is
  begin
    if n > (CFG_NMEM_TILE - 1) then
      return CFG_NMEM_TILE - 1;
    else
      return n;
    end if;
  end set_ddr_index;

  constant this_ddr_index : attribute_vector(0 to 3) := (
    0 => set_ddr_index(0),
    1 => set_ddr_index(1),
    2 => set_ddr_index(2),
    3 => set_ddr_index(3)
    );


  -- Create socmap array for this inversion as well as for selected clock div/backup and tdi/tdo
  -- EPOCHS-0/1 specific
  -- Memory tile 0 - FPGA link 0
  -- Memory tile 1 - FPGA link 1
  -- Memory tile 2 - FPGA link 3
  -- Memory tile 3 - FPGA link 2
  function memswap (
    constant n : integer range 0 to 3)
    return integer is
  begin
    if n = 2 then
      return 3;
    elsif n = 3 then
      return 2;
    else
      return n;
    end if;
  end memswap;

  -----------------------------------------------------------------------------
  -- clock and reset

  -- main clock (EDCL clock)
  signal main_clk                         : std_ulogic;

  -- DDR clocks
  signal sys_clk  : std_logic_vector(0 to MAX_NMEM_TILES - 1) := (others => '0');
  signal sys_rst  : std_logic_vector(0 to MAX_NMEM_TILES - 1);

  -- Resets
  signal rstn, rstraw, rstraw_1, rstraw_2, rstraw_3 : std_ulogic;
  signal lock, rst                                  : std_ulogic;
  signal migrstn, migrstn_1, migrstn_2, migrstn_3   : std_logic;

  -- ESP backup clocks
  signal ext_clk_noc_int : std_logic := '0';
  -- ESP clock monitors
  signal ext_clk_int : std_logic_vector(0 to CFG_TILES_NUM - 1) := (others  => '0');

  -----------------------------------------------------------------------------
  -- DDRs domain
  -- MIG clock and diagnostic
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c0_diagnostic_toggle : std_ulogic;
  signal c1_calib_done        : std_ulogic;
  signal c1_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c1_diagnostic_toggle : std_ulogic;
  signal c2_calib_done        : std_ulogic;
  signal c2_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c2_diagnostic_toggle : std_ulogic;
  signal c3_calib_done        : std_ulogic;
  signal c3_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c3_diagnostic_toggle : std_ulogic;

  -- AHB proxy extended
  type noc_flit_vector is array (natural range <>) of noc_flit_type;
  signal extended_ahbm_rcv_rdreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal extended_ahbm_rcv_data_out : noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal extended_ahbm_rcv_empty    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal extended_ahbm_snd_wrreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal extended_ahbm_snd_data_in  : noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal extended_ahbm_snd_full     : std_logic_vector(0 to CFG_NMEM_TILE - 1);

  -- AHB proxy queues
  type misc_noc_flit_vector is array (natural range <>) of misc_noc_flit_type;
  signal ahbm_rcv_rdreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbm_rcv_data_out : misc_noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbm_rcv_empty    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbm_snd_wrreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbm_snd_data_in  : misc_noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbm_snd_full     : std_logic_vector(0 to CFG_NMEM_TILE - 1);

  -- Dual-clock queues
  signal ahbs_rcv_rdreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbs_rcv_data_out : misc_noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbs_rcv_empty    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbs_snd_wrreq    : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbs_snd_data_in  : misc_noc_flit_vector(0 to CFG_NMEM_TILE - 1);
  signal ahbs_snd_full     : std_logic_vector(0 to CFG_NMEM_TILE - 1);

  -- AHB bus
  type ahb_mst_out_ddr_matrix is array (natural range <>) of ahb_mst_out_vector;
  type ahb_slv_out_ddr_matrix is array (natural range <>) of ahb_slv_out_vector;

  signal ahb_mst_out_ddr : ahb_mst_out_ddr_matrix(0 to CFG_NMEM_TILE - 1);
  signal ahb_slv_out_ddr : ahb_slv_out_ddr_matrix(0 to CFG_NMEM_TILE - 1);

  signal ahb_mst_in_ddr  : ahb_mst_in_vector_type(0 to CFG_NMEM_TILE - 1);
  signal ahb_slv_in_ddr  : ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);

  signal ddr_ahbsi        : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso        : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

  -----------------------------------------------------------------------------
  -- Debug domain
  -- Mux to/from debug queues
  signal mux_ahbs_rcv_rdreq     : std_ulogic;
  signal mux_ahbs_rcv_data_out  : misc_noc_flit_type;
  signal mux_ahbs_rcv_empty     : std_ulogic;
  signal mux_ahbs_rcv_wrreq     : std_ulogic;
  signal mux_ahbs_rcv_data_in   : misc_noc_flit_type;
  signal mux_ahbs_rcv_full      : std_ulogic;
  signal mux_ahbs_snd_rdreq     : std_ulogic;
  signal mux_ahbs_snd_data_out  : misc_noc_flit_type;
  signal mux_ahbs_snd_empty     : std_ulogic;
  signal mux_ahbs_snd_wrreq     : std_ulogic;
  signal mux_ahbs_snd_data_in   : misc_noc_flit_type;
  signal mux_ahbs_snd_full      : std_ulogic;

  signal sending_packet : std_logic_vector(0 to CFG_NMEM_TILE - 1);
  signal receiving_packet : std_logic_vector(0 to CFG_NMEM_TILE - 1);

  signal target_y : local_yx;
  signal target_x : local_yx;

  -- AHB bus
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector;
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector;

  function set_remote_ahb_mask (
    constant N : in integer range 1 to CFG_NMEM_TILE)
    return std_logic_vector is
    variable ret : std_logic_vector(0 to NAHBSLV - 1);
  begin
    ret := (others => '0');
    for i in 0 to N - 1 loop
      ret(ddr_hindex(i)) := '1';
    end loop;  -- i
    return ret;
  end set_remote_ahb_mask;

  constant this_remote_ahb_slv_en : std_logic_vector(0 to NAHBSLV - 1) := set_remote_ahb_mask(CFG_NMEM_TILE);

  -----------------------------------------------------------------------------
  -- EDCL
  constant FPGA_PROXY_ETH_IPM : integer := 16#C0A8#;
  constant FPGA_PROXY_ETH_IPL : integer := 16#0114#;
  constant FPGA_PROXY_ETH_ENM : integer := 16#A6A7A0#;
  constant FPGA_PROXY_ETH_ENL : integer := 16#F82440#;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;

  -----------------------------------------------------------------------------
  -- FPGA proxy
  signal fpga_data_ien       : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_data_in        : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_data_out       : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_valid_in_int   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in_int     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out_int    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in_int  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out_int : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);

  -- I/O Link
  signal iolink_data_oen       : std_ulogic;
  signal iolink_data_in_int    : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_data_out_int   : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in_int   : std_ulogic;
  signal iolink_valid_out_int  : std_ulogic;
  signal iolink_clk_in_int     : std_ulogic;
  signal iolink_clk_out_int    : std_ulogic;
  signal iolink_credit_in_int  : std_ulogic;
  signal iolink_credit_out_int : std_ulogic;

  -----------------------------------------------------------------------------
  -- JTAG
  signal tclk_sim : std_logic := '0';

  -- pragma translate_off
  type jtag_trace_count_t is array (1 to 6) of integer;
  -- pragma translate_on

  attribute keep : boolean;

  attribute keep of main_clk : signal is true;
  attribute keep of sys_clk  : signal is true;

begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- DDR clock diagnostic

  c0_diagnostic : process (sys_clk(0), sys_rst(0))
  begin  -- process c0_diagnostic
    if sys_rst(0) = '1' then           -- asynchronous reset (active high)
      c0_diagnostic_count <= (others => '0');
    elsif sys_clk(0)'event and sys_clk(0) = '1' then  -- rising clock edge
      c0_diagnostic_count <= c0_diagnostic_count + 1;
    end if;
  end process c0_diagnostic;
  c0_diagnostic_toggle <= c0_diagnostic_count(26);
  c0_led_diag_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);

  -------------------------------------------------------------------------------
  -- Leds

  -- From memory controllers' PLLs
  lock_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_GREEN, lock);

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);


  led_red_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_RED, '0');

  led_blue_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_BLUE, '0');

  led_yellow_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v) port map (LED_YELLOW, '0');

  ----------------------------------------------------------------------
  --- FPGA Reset and Clock generation

  lock <= c0_calib_done and c1_calib_done and c2_calib_done and c3_calib_done;

  reset_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x12v) port map (reset, rst);
  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, sys_clk(0), lock, rstn, open);

  mig_rst0 : rstgen                     -- reset generator
    generic map (acthigh => 1)
    port map (rst, sys_clk(0), lock, migrstn, rstraw);

  main_clk_buf : ibufgds
    generic map(
      IBUF_LOW_PWR => FALSE
      )
    port map (
      I  => main_clk_p,
      IB => main_clk_n,
      O  => main_clk
      );

  ----------------------------------------------------------------------
  ---  DDR4 memory controller

  gen_mig : if (SIMULATION /= true) generate
    ddrc0 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)))
      port map (
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
        ahbso            => ddr_ahbso(0),
        ahbsi            => ddr_ahbsi(0),
        calib_done       => c0_calib_done,
        rst_n_syn        => migrstn,
        rst_n_async      => rstraw,
        clk_amba         => sys_clk(0),
        ui_clk           => sys_clk(0),
        ui_clk_sync_rst  => sys_rst(0)
        );


  end generate gen_mig;

  gen_mig_model : if (SIMULATION = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 2048,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => sys_clk(0),
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)),
        ahbsi => ddr_ahbsi(0),
        ahbso => ddr_ahbso(0)
        );

    c0_ddr4_act_n    <= '1';
    c0_ddr4_adr      <= (others => '0');
    c0_ddr4_ba       <= (others => '0');
    c0_ddr4_bg       <= (others => '0');
    c0_ddr4_cke      <= (others => '0');
    c0_ddr4_odt      <= (others => '0');
    c0_ddr4_cs_n     <= (others => '0');
    c0_ddr4_ck_t     <= (others => '0');
    c0_ddr4_ck_c     <= (others => '0');
    c0_ddr4_reset_n  <= '1';
    c0_ddr4_dm_dbi_n <= (others => 'Z');
    c0_ddr4_dq       <= (others => 'Z');
    c0_ddr4_dqs_c    <= (others => 'Z');
    c0_ddr4_dqs_t    <= (others => 'Z');
    c0_calib_done    <= '1';
    sys_clk(0)       <= not sys_clk(0) after 3.2 ns;

  -- pragma translate_on
  end generate gen_mig_model;

  -----------------------------------------------------------------------------
  -- Link to ESP memory tiles

  set_upper_ahbsi : for i in CFG_NMEM_TILE to MAX_NMEM_TILES-1 generate
    -- Disable AHB port
    ddr_ahbsi(i) <= ahbs_in_none;
  end generate set_upper_ahbsi;

  fpga_io_gen : for i in 0 to CFG_NMEM_TILE - 1 generate

    -- Bidirection data pins
    fpga_iopad_data_gen : for j in 0 to ARCH_BITS - 1 generate
        fpga_data_pad  : iopad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, oepol => 1) 
          port map (fpga_data(memswap(i) * ARCH_BITS + j), fpga_data_in(i * ARCH_BITS + j), fpga_data_ien(i), fpga_data_out(i * ARCH_BITS + j));
    end generate fpga_iopad_data_gen;

    -- Valid bit
    fpga_valid_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_valid_in(memswap(i)), fpga_valid_in_int(i));
    fpga_valid_out_pad : inpad generic map (level  => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_valid_out(memswap(i)), fpga_valid_out_int(i));

    -- Source-synchronous clocks
    fpga_clk_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_clk_in(memswap(i)), fpga_clk_in_int(i));
    fpga_clk_out_pad : clkpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_clk_out(memswap(i)), fpga_clk_out_int(i));

    -- Credit-based flow control
    fpga_credit_in_pad  : outpad generic map (level => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_credit_in(memswap(i)), fpga_credit_in_int(i));
    fpga_credit_out_pad : inpad generic map (level  => cmos, voltage => x18v, tech => FPGA_PROXY_TECH) port map (fpga_credit_out(memswap(i)), fpga_credit_out_int(i));

   -- I/O link pads
  iolink_data_pad : iopadv
    generic map (tech => inferred, level => cmos, voltage => x18v, width => CFG_IOLINK_BITS, oepol => 1)
    port map (iolink_data, iolink_data_out_int, iolink_data_oen, iolink_data_in_int);
  iolink_valid_in_pad : inpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_valid_in, iolink_valid_in_int);
  iolink_valid_out_pad : outpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_valid_out, iolink_valid_out_int);
  iolink_clk_in_pad : inpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_clk_in, iolink_clk_in_int);
  iolink_clk_out_pad : outpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_clk_out, iolink_clk_out_int);
  iolink_credit_in_pad : inpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_credit_in, iolink_credit_in_int);
  iolink_credit_out_pad : outpad
    generic map (level => cmos, voltage => x18v, tech => inferred)
    port map (iolink_credit_out, iolink_credit_out_int);

    iolink_clk_out_int <= ext_clk_noc_int;

    ahb_slv_out_ddr(i)(0) <= ddr_ahbso(i);
    ddr_ahbsi(i) <= ahb_slv_in_ddr(i);

    -- External-link transaction to AHB master transaction for DDR controllers
    ext2ahbm_i : ext2ahbm
      generic map (
        hindex => 0,
        little_end => GLOB_CPU_AXI)
      port map (
        clk             => sys_clk(i),
        rstn            => rstn,
        fpga_data_in    => fpga_data_in((i + 1) * (ARCH_BITS) - 1 downto i * (ARCH_BITS)),
        fpga_data_out   => fpga_data_out((i + 1) * (ARCH_BITS) - 1 downto i * (ARCH_BITS)),
        fpga_valid_in   => fpga_valid_in_int(i),
        fpga_valid_out  => fpga_valid_out_int(i),
        fpga_data_ien   => fpga_data_ien(i),
        fpga_clk_in     => fpga_clk_in_int(i),
        fpga_clk_out    => fpga_clk_out_int(i),
        fpga_credit_in  => fpga_credit_in_int(i),
        fpga_credit_out => fpga_credit_out_int(i),
        ahbmi           => ahb_mst_in_ddr(i),
        ahbmo           => ahb_mst_out_ddr(i)(0));

    -- Handle EDCL requests to memory (load program/data)
    noc2ahbmst_i  : noc2ahbmst
      generic map (
        tech        => FPGA_PROXY_TECH,
        hindex      => 1,
        axitran     => 0,
        little_end  => 0,
        eth_dma     => 0,
        narrow_noc  => 0,
        cacheline   => 1,
        l2_cache_en => 0)
      port map (
        rst                       => rstn,
        clk                       => sys_clk(i),
        local_y                   => tile_x(mem_tile_id(i)),
        local_x                   => tile_y(mem_tile_id(i)),
        ahbmi                     => ahb_mst_in_ddr(i),
        ahbmo                     => ahb_mst_out_ddr(i)(1),
        coherence_req_rdreq       => extended_ahbm_rcv_rdreq(i),
        coherence_req_data_out    => extended_ahbm_rcv_data_out(i),
        coherence_req_empty       => extended_ahbm_rcv_empty(i),
        coherence_fwd_wrreq       => open,
        coherence_fwd_data_in     => open,
        coherence_fwd_full        => '0',
        coherence_rsp_snd_wrreq   => extended_ahbm_snd_wrreq(i),
        coherence_rsp_snd_data_in => extended_ahbm_snd_data_in(i),
        coherence_rsp_snd_full    => extended_ahbm_snd_full(i),
        dma_rcv_rdreq             => open,
        dma_rcv_data_out          => (others => '0'),
        dma_rcv_empty             => '1',
        dma_snd_wrreq             => open,
        dma_snd_data_in           => open,
        dma_snd_full              => '0',
        dma_snd_atleast_4slots    => '1',
        dma_snd_exactly_3slots    => '0');

    ahbm_rcv_rdreq(i)          <= extended_ahbm_rcv_rdreq(i);
    extended_ahbm_rcv_empty(i) <= ahbm_rcv_empty(i);
    ahbm_snd_wrreq(i)          <= extended_ahbm_snd_wrreq(i);
    extended_ahbm_snd_full(i)  <= ahbm_snd_full(i);

    large_bus: if ARCH_BITS /= 32 generate
      extended_ahbm_rcv_data_out(i) <= narrow_to_large_flit(ahbm_rcv_data_out(i));
      ahbm_snd_data_in(i)           <= large_to_narrow_flit(extended_ahbm_snd_data_in(i));
    end generate large_bus;

    std_bus: if ARCH_BITS = 32 generate
      extended_ahbm_rcv_data_out(i) <= ahbm_rcv_data_out(i);
      ahbm_snd_data_in(i)           <= extended_ahbm_snd_data_in(i);
    end generate std_bus;

    -- AHB bus for DDR access
    ahbctrl_ddr_i : ahbctrl                        -- AHB arbiter/multiplexer
      generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                   rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                   nahbm   => 2, nahbs => 1,
                   cfgmask => 0)
      port map (rstn, sys_clk(i), ahb_mst_in_ddr(i), ahb_mst_out_ddr(i), ahb_slv_in_ddr(i), ahb_slv_out_ddr(i));

    -- Unused bus ports
    unused_ahbm_gen: for j in 2 to NAHBMST - 1 generate
      ahb_mst_out_ddr(i)(j) <= ahbm_none;
    end generate unused_ahbm_gen;
    unused_ahbs_gen: for j in 1 to NAHBSLV - 1 generate
      ahb_slv_out_ddr(i)(j) <= ahbs_none;
    end generate unused_ahbs_gen;

    -- noc2ahbm to ahbs2noc
    mem2ext_fifo_1: inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 8)
      port map (
        rst_wr_n_i => rstn,
        clk_wr_i   => sys_clk(i),
        we_i       => ahbm_snd_wrreq(i),
        d_i        => ahbm_snd_data_in(i),
        wr_full_o  => ahbm_snd_full(i),
        rst_rd_n_i => rstn,
        clk_rd_i   => main_clk,
        rd_i       => ahbs_rcv_rdreq(i),
        q_o        => ahbs_rcv_data_out(i),
        rd_empty_o => ahbs_rcv_empty(i));

    -- ahbs2noc to noc2ahbm
    mem2ext_fifo_2: inferred_async_fifo
      generic map (
        g_data_width => MISC_NOC_FLIT_SIZE,
        g_size       => 8)
      port map (
        rst_wr_n_i => rstn,
        clk_wr_i   => main_clk,
        we_i       => ahbs_snd_wrreq(i),
        d_i        => ahbs_snd_data_in(i),
        wr_full_o  => ahbs_snd_full(i),
        rst_rd_n_i => rstn,
        clk_rd_i   => sys_clk(i),
        rd_i       => ahbm_rcv_rdreq(i),
        q_o        => ahbm_rcv_data_out(i),
        rd_empty_o => ahbm_rcv_empty(i));

  end generate fpga_io_gen;

  -----------------------------------------------------------------------------
  -- EDCL interface

  -- Multiplexing sending queue
  fifo0_from_edcl : fifo0
    generic map (
      depth => 8,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => main_clk,
      rst      => rstn,
      rdreq    => mux_ahbs_snd_rdreq,
      wrreq    => mux_ahbs_snd_wrreq,
      data_in  => mux_ahbs_snd_data_in,
      empty    => mux_ahbs_snd_empty,
      full     => mux_ahbs_snd_full,
      data_out => mux_ahbs_snd_data_out);

  snd_mux_gen: process (ahbs_snd_full, mux_ahbs_snd_data_out, mux_ahbs_snd_empty, sending_packet) is
  begin
    mux_ahbs_snd_rdreq <= '0';

    ahbs_snd_wrreq    <= (others => '0');
    ahbs_snd_data_in  <= (others => (others => '0'));

    case sending_packet is
      when "1" =>
        ahbs_snd_wrreq(0)   <= not mux_ahbs_snd_empty;
        ahbs_snd_data_in(0) <= mux_ahbs_snd_data_out;
        mux_ahbs_snd_rdreq  <= not ahbs_snd_full(0);

      when others => null;
    end case;
  end process snd_mux_gen;

  -- Multiplexing receiving queue
  fifo0_to_edcl : fifo0
    generic map (
      depth => 8,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => main_clk,
      rst      => rstn,
      rdreq    => mux_ahbs_rcv_rdreq,
      wrreq    => mux_ahbs_rcv_wrreq,
      data_in  => mux_ahbs_rcv_data_in,
      empty    => mux_ahbs_rcv_empty,
      full     => mux_ahbs_rcv_full,
      data_out => mux_ahbs_rcv_data_out);

  rcv_mux_gen: process (ahbs_rcv_empty, ahbs_rcv_data_out, mux_ahbs_rcv_full, receiving_packet) is
  begin
    mux_ahbs_rcv_wrreq   <= '0';
    mux_ahbs_rcv_data_in <= (others => '0');

    ahbs_rcv_rdreq    <= (others => '0');

    case receiving_packet is
      when "1" =>
        mux_ahbs_rcv_wrreq   <= not ahbs_rcv_empty(0);
        mux_ahbs_rcv_data_in <= ahbs_rcv_data_out(0);
        ahbs_rcv_rdreq(0)    <= not mux_ahbs_rcv_full;

      when others => null;
    end case;

  end process rcv_mux_gen;

  -- Mux selectors
  target_x <= get_destination_x(MISC_NOC_FLIT_SIZE, noc_flit_pad & mux_ahbs_snd_data_out);
  target_y <= get_destination_y(MISC_NOC_FLIT_SIZE, noc_flit_pad & mux_ahbs_snd_data_out);

  mux_state_gen: process (main_clk, rstn) is
  begin  -- process mux_state_gen
    if rstn = '0' then                   -- asynchronous reset (active low)
      sending_packet   <= (others => '0');
      receiving_packet <= (others => '0');
    elsif main_clk'event and main_clk = '1' then  -- rising clock edge

      -- Sender state
      if sending_packet = "0" then
        -- Select target DDR
        if mux_ahbs_snd_empty = '0' then
          for i in 0 to CFG_NMEM_TILE - 1 loop
            if (target_y = tile_mem_list(i).y) and (target_x = tile_mem_list(i).x) then
              sending_packet(i) <= '1';
            end if;
          end loop;  -- i
        end if;
      else
        -- Wait for current transaction to complete (look for tail)
        if (mux_ahbs_snd_empty = '0') and (mux_ahbs_snd_data_out(MISC_NOC_FLIT_SIZE - 2) = '1') then
          sending_packet <= (others => '0');
        end if;
      end if;

      -- Receiver state
      if receiving_packet = "0" then
        -- Select source DDR
        for i in 0 to CFG_NMEM_TILE - 1 loop
          if ahbs_rcv_empty(i) = '0' then
            receiving_packet    <= (others => '0');
            receiving_packet(i) <= '1';
          end if;
        end loop;  -- i
      else
        -- Wait for current transaction to complete (look for tail)
        if (mux_ahbs_rcv_empty = '0') and (mux_ahbs_rcv_data_out(MISC_NOC_FLIT_SIZE - 2) = '1') then
          receiving_packet <= (others => '0');
        end if;
      end if;

    end if;
  end process mux_state_gen;

  -- Handle EDCL requests to memory
  ahbslv2noc_1 : ahbslv2noc
    generic map (
      tech             => FPGA_PROXY_TECH,
      hindex           => this_remote_ahb_slv_en,
      hconfig          => fixed_ahbso_hconfig,
      mem_hindex       => ddr_hindex(0),
      mem_num          => CFG_NMEM_TILE,
      mem_info         => tile_acc_mem_list(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1),
      slv_y            => tile_y(io_tile_id),
      slv_x            => tile_x(io_tile_id),
      retarget_for_dma => 1,
      dma_length       => CFG_DLINE)
    port map (
      rst                        => rstn,
      clk                        => main_clk,
      local_y                    => tile_y(io_tile_id),
      local_x                    => tile_x(io_tile_id),
      ahbsi                      => ahbsi,
      ahbso                      => ahbso,
      dma_selected               => '0',
      coherence_req_wrreq        => open,
      coherence_req_data_in      => open,
      coherence_req_full         => '0',
      coherence_rsp_rcv_rdreq    => open,
      coherence_rsp_rcv_data_out => (others => '0'),
      coherence_rsp_rcv_empty    => '1',
      remote_ahbs_snd_wrreq      => mux_ahbs_snd_wrreq,
      remote_ahbs_snd_data_in    => mux_ahbs_snd_data_in,
      remote_ahbs_snd_full       => mux_ahbs_snd_full,
      remote_ahbs_rcv_rdreq      => mux_ahbs_rcv_rdreq,
      remote_ahbs_rcv_data_out   => mux_ahbs_rcv_data_out,
      remote_ahbs_rcv_empty      => mux_ahbs_rcv_empty);

  -- AHB bus for EDCL
  ahbctrl_edcl_1 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => 1, nahbs => NAHBSLV,
                 cfgmask => 0)
    port map (rstn, main_clk, ahbmi, ahbmo, ahbsi, ahbso);

  -- Unused bus ports
  unused_ahbm_eth_gen: for j in 1 to NAHBSLV - 1 generate
    ahbmo(j) <= ahbm_none;
  end generate unused_ahbm_eth_gen;

  -- Ethernet EDCL
  eth0 : if SIMULATION = false and CFG_GRETH = 1 generate  -- Gaisler ethernet MAC
  e1 : grethm
    generic map(
      hindex      => 1,                 -- unused
      ehindex     => 0,
      pindex      => 14,
      paddr       => 16#800#,
      pmask       => 16#f00#,
      pirq        => 12,
      little_end  => GLOB_CPU_AXI,      -- no caches on FPGA proxy
      memtech     => FPGA_PROXY_TECH,
      enable_mdio => 1,
      fifosize    => CFG_ETH_FIFO,
      nsync       => 1,
      edcl        => 1,
      edclbufsz   => CFG_ETH_BUF,
      macaddrh    => FPGA_PROXY_ETH_ENM,
      macaddrl    => FPGA_PROXY_ETH_ENL,
      phyrstadr   => 1,
      ipaddrh     => FPGA_PROXY_ETH_IPM,
      ipaddrl     => FPGA_PROXY_ETH_IPL,
      giga        => CFG_GRETH1G,
      edclsepahbg => 1)
    port map(
      rst    => rstn,
      clk    => main_clk,
      mdcscaler => FPGA_PROXY_FREQ/1000,
      ahbmi  => ahbmi,
      ahbmo  => open,
      eahbmo => ahbmo(0),
      apbi   => apb_slv_in_none,
      apbo   => open,
      ethi   => ethi,
      etho   => etho);
  end generate;

  ethi.edclsepahb <= '1';

  -- eth pads
  reset_o2 <= rstn;
  eth0_inpads : if (CFG_GRETH = 1) generate
    etxc_pad : clkpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, arch => 2)
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, arch => 2)
      port map (erx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, width => 4)
      port map (erxd, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
      port map (erx_crs, ethi.rx_crs);
  end generate eth0_inpads;

  emdio_pad : iopad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  etxd_pad : outpadv generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v, width => 4)
    port map (etxd, etho.txd(3 downto 0));
  etxen_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (etx_en, etho.tx_en);
  etxer_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (etx_er, etho.tx_er);
  emdc_pad : outpad generic map (tech => FPGA_PROXY_TECH, level => cmos, voltage => x18v)
    port map (emdc, etho.mdc);

  no_eth0 : if SIMULATION = true or CFG_GRETH = 0 generate
    ahbmo(0)     <= ahbm_none;
    etho.mdio_o  <= '0';
    etho.mdio_oe <= '0';
    etho.txd     <= (others => '0');
    etho.tx_en   <= '0';
    etho.tx_er   <= '0';
    etho.mdc     <= '0';
  end generate no_eth0;

  -----------------------------------------------------------------------------
  -- DCO backup clocks
  ext_clk_sim_gen: if SIMULATION = true generate
    ext_clk_noc_int <= not ext_clk_noc_int after 5 ns;
    ext_clk_sim_for_gen: for i in 0 to CFG_TILES_NUM - 1 generate
      ext_clk_int(i) <= not ext_clk_int(i) after 8 ns;
    end generate ext_clk_sim_for_gen;

  end generate ext_clk_sim_gen;

  ext_clk_gen: if SIMULATION = false generate
    -- TODO: generate external backup clocks
    ext_clk_int <= (others => '0');
    ext_clk_noc_int <= '0';
  end generate ext_clk_gen;

  ext_clk <= ext_clk_int;
  ext_clk_noc <= ext_clk_noc_int;

  -----------------------------------------------------------------------------
  -- JTAG interface

  jtag_driver_gen: if SIMULATION = false generate
    -- TODO: ADD synthesizable TB for JTAG interface. This will run on proxy FPGA.
    tdi <= (others => '0');
    tms <= '0';
    tclk <= '0';
  end generate jtag_driver_gen;

  -- pragma translate_off
  jtag_sim_gen: if SIMULATION = true and JTAG_TRACE /= -1 generate

    tclk_sim <= not tclk_sim after 10 ns;
    tclk <= tclk_sim;
    tms <= '1';

    tdi_sim_gen: for i in 0 to CFG_TILES_NUM - 1 generate
      tdi_inactive_tile_sim_gen: if i /= JTAG_TRACE generate
        tdi(i) <= '0';
      end generate tdi_inactive_tile_sim_gen;
    end generate tdi_sim_gen;

    PROC_SEQUENCER : process
      file text_file1 : text open read_mode is "stim1.txt";
      file text_file2 : text open read_mode is "stim2.txt";
      file text_file3 : text open read_mode is "stim3.txt";
      file text_file4 : text open read_mode is "stim4.txt";
      file text_file5 : text open read_mode is "stim5.txt";
      file text_file6 : text open read_mode is "stim6.txt";
      file out_file : text open write_mode is "test_out.txt";
      variable text_line :line ;
      variable out_line :line;
      variable ok : boolean;
      variable testin : std_logic_vector(74 downto 0);
      variable flit66 : std_logic_vector(71 downto 0);
      variable flit34 : std_logic_vector(39 downto 0);
      variable source : std_logic_vector(5 downto 0);
      variable source_bin : integer range 1 to 6;
      variable injection_counter : jtag_trace_count_t;
      variable end_trace : std_logic_vector(1 to 6);
      variable testout : std_logic_vector(73 downto 0);
    begin

      source := "000000";
      testout := (others => '0');
      injection_counter := (others => 0);
      source_bin := 5;
      end_trace := (others => '0');

      while true loop

        assert end_trace /= "111111"  report "JTAG mode test complete!" severity failure;

        wait until rising_edge(tclk_sim);
        if tdo(JTAG_TRACE)= '1' then
          assert false report "TDO_RISE" severity note;

          wait until rising_edge(tclk_sim);

          if tdo(JTAG_TRACE)= '0' then
            --extract
            assert false report "start_extract " severity note;

            wait until rising_edge(tclk_sim);

            for i in 0 to 72 loop
              testout(72 - i) := tdo(JTAG_TRACE);
              wait until rising_edge(tclk_sim);
            end loop;

            --hwrite(out_line, testout(5 downto 0), right, 5);
            --hwrite(out_line, testout(NOC_FLIT_SIZE - 1 downto 7), right, 18);

            if testout(6) = '1' then
              -- Mismatch detected
              assert false report "*** mismatch *** on NoC " & tost(testout(5 downto 0)) & " " & tost(testout(NOC_FLIT_SIZE + 7 - 1 downto 7)) severity note;
              --hwrite(out_line, "1", right, 4);
            else
              --hwrite(out_line, "0", right, 4);
            end if;

            writeline(out_file,out_line);

            assert false report "end_extract " severity note;

          else
            --- update plane+inject
            wait until rising_edge(tclk_sim);

            for i in 0 to 5 loop
              source(5 - i) := tdo(JTAG_TRACE);
              wait until rising_edge(tclk_sim);
            end loop;

            assert false report " update plane+inject " & tost(source)  severity note;

            case source is
              when "100000" =>  if not endfile(text_file1) then
                                  readline(text_file1, text_line);
                                  hread(text_line, flit66, ok);
                                  testin := flit66(NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" & flit66(0) & '1';
                                else
                                  assert false report "End trace 1" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(1) := '1';
                                end if;
                                source_bin := 1;
                                injection_counter(1) := injection_counter(1) + 1;

              when "010000" =>  if not endfile(text_file2) then
                                  readline(text_file2, text_line);
                                  hread(text_line, flit66, ok);
                                  testin := flit66(NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" &  flit66(0) & '1';
                                else
                                  assert false report "End trace 2" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(2) := '1';
                                end if;
                                source_bin := 2;
                                injection_counter(2) := injection_counter(2) + 1;

              when "001000" => if not endfile(text_file3) then
                                 readline(text_file3, text_line);
                                 hread(text_line, flit66, ok);
                                 testin := flit66(NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" &  flit66(0) & '1';
                               else
                                  assert false report "End trace 3" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(3) := '1';
                               end if;
                               source_bin := 3;
                               injection_counter(3) := injection_counter(3) + 1;

              when "000100" =>  if not endfile(text_file4) then
                                  readline(text_file4, text_line);
                                  hread(text_line, flit66, ok);
                                  testin := flit66(NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" &  flit66(0) & '1';
                                else
                                  assert false report "End trace 4" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(4) := '1';
                                end if;
                                source_bin := 4;
                                injection_counter(4) := injection_counter(4) + 1;

              when "000010" =>  if not endfile(text_file5) then
                                  readline(text_file5, text_line);
                                  hread(text_line, flit34, ok);
                                  testin := X"00000000" & flit34(MISC_NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" & flit34(0) & '1';
                                else
                                  assert false report "End trace 5" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(5) := '1';
                                end if;
                                source_bin := 5;
                                injection_counter(5) := injection_counter(5) + 1;

              when "000001" =>  if not endfile(text_file6) then
                                  readline(text_file6, text_line);
                                  hread(text_line, flit66, ok);
                                  testin := flit66(NOC_FLIT_SIZE + 4 - 1 downto 4) & source & "0" &  flit66(0) & '1';
                                else
                                  assert false report "End trace 6" severity note;
                                  testin := (others => '0');
                                  testin(8 downto 3) := (others => '1');
                                  testin(0) := '1';
                                  end_trace(6) := '1';
                                end if;
                                source_bin := 6;
                                injection_counter(6) := injection_counter(6) + 1;

              when others => assert false report "invalid NoC plane for injection" severity failure;

            end case ;

            assert false report "start_injection N" & tost(source_bin) & "[" & tost(injection_counter(source_bin)) & "]: " & tost(testin(74 downto 9)) & " - " & tost(testin(1)) severity note;


            for i in 0 to 74 loop
              wait until rising_edge(tclk_sim);
              tdi(JTAG_TRACE) <= testin(i);
            end loop;

            wait until rising_edge(tclk_sim);
            tdi(JTAG_TRACE) <= '0';

            assert false report "end_injection" severity note;

          end if;
        end if ;
      end loop;
    end process;

  end generate jtag_sim_gen;
  -- pragma translate_on

  normal_mode_sim_gen: if SIMULATION = true and JTAG_TRACE = -1 generate
    tdi <= (others => '0');
    tms <= '0';
    tclk <= '0';
  end generate normal_mode_sim_gen;

  tb_iolink_i : tb_iolink port map (
    reset                 => reset,
    iolink_clk_in_int     => iolink_clk_in_int,
    iolink_valid_in_int   => iolink_valid_in_int,
    iolink_data_in_int    => iolink_data_in_int,
    iolink_clk_out_int    => iolink_clk_out_int,
    iolink_credit_out_int => iolink_credit_out_int,
    iolink_valid_out_int  => iolink_valid_out_int,
    iolink_data_out_int   => iolink_data_out_int,
    iolink_data_oen       => iolink_data_oen);


end architecture rtl;
