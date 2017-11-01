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
  generic (
    fabtech             : integer := CFG_FABTECH;
    memtech             : integer := CFG_MEMTECH;
    padtech             : integer := CFG_PADTECH;
    disas               : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart             : integer := CFG_DUART;   -- Print UART on console
    pclow               : integer := CFG_PCLOW;
    has_sync            : integer := CFG_HAS_SYNC;
    has_dvfs            : integer := CFG_HAS_DVFS;
    XLEN                : integer := CFG_XLEN;
    YLEN                : integer := CFG_YLEN;
    TILES_NUM           : integer := CFG_TILES_NUM;
    testahb             : boolean := false;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION          : string := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false;
    autonegotiation     : integer := 1
  );
  port (
    rst             : in    std_logic;
    noc_clk         : in    std_logic;
    refclk          : in    std_logic;
    mem_clk         : in    std_logic;
    pllbypass       : in    std_logic_vector(TILES_NUM - 1 downto 0);
    --pragma translate_off
    mctrl_ahbsi : out ahb_slv_in_type;
    mctrl_ahbso : in  ahb_slv_out_type;
    mctrl_apbi  : out apb_slv_in_type;
    mctrl_apbo  : in  apb_slv_out_type;
    mctrl_clk   : out std_ulogic;
    --pragma translate_on
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    ndsuact         : out   std_logic;
    dsuerr          : out   std_logic;
    ddr0_ahbsi      : out ahb_slv_in_type;
    ddr0_ahbso      : in  ahb_slv_out_type;
    ddr1_ahbsi      : out ahb_slv_in_type;
    ddr1_ahbso      : in  ahb_slv_out_type;
    eth0_apbi       : out apb_slv_in_type;
    eth0_apbo       : in  apb_slv_out_type;
    sgmii0_apbi     : out apb_slv_in_type;
    sgmii0_apbo     : in  apb_slv_out_type;
    eth0_ahbmi      : out ahb_mst_in_type;
    eth0_ahbmo      : in  ahb_mst_out_type;
    dvi_apbi        : out apb_slv_in_type;
    dvi_apbo        : in  apb_slv_out_type;
    dvi_ahbmi       : out ahb_mst_in_type;
    dvi_ahbmo       : in  ahb_mst_out_type;
    -- Monitor signals
    mon_noc         : out monitor_noc_matrix(1 to 6, 0 to TILES_NUM-1);
    mon_acc         : out monitor_acc_vector(0 to accelerators_num-1);
    mon_dvfs        : out monitor_dvfs_vector(0 to TILES_NUM-1);
    debug_led       : out std_ulogic);
end;


architecture rtl of esp is

  component sync_noc_xy
    generic (
      flit_size : integer;
      XLEN      : integer;
      YLEN      : integer;
      TILES_NUM : integer;
      has_sync  : integer);
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

signal clk_tile : std_logic_vector(TILES_NUM-1 downto 0);
type noc_flit_matrix is array (1 to nocs_num) of noc_flit_vector(TILES_NUM-1 downto 0);
type noc_ctrl_matrix is array (1 to nocs_num) of std_logic_vector(TILES_NUM-1 downto 0);

signal noc_input_port    : noc_flit_matrix;
signal noc_data_void_in  : noc_ctrl_matrix;
signal noc_stop_in       : noc_ctrl_matrix;
signal noc_output_port   : noc_flit_matrix;
signal noc_data_void_out : noc_ctrl_matrix;
signal noc_stop_out      : noc_ctrl_matrix;

--pragma translate_off
signal mctrl_ahbsi_mem : ahb_slv_in_type_vec;
signal mctrl_apbi_mem  : apb_slv_in_type_vec;
--pragma translate_on

signal rst_int       : std_logic;
signal noc_clk_int   : std_logic;
signal mem_clk_int   : std_logic;
signal refclk_int    : std_logic_vector(TILES_NUM -1 downto 0);
signal pllbypass_int : std_logic_vector(TILES_NUM - 1 downto 0);
signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

type monitor_noc_cast_vector is array (1 to nocs_num) of monitor_noc_vector(0 to TILES_NUM-1);
signal mon_noc_vec : monitor_noc_cast_vector;
signal mon_dvfs_out : monitor_dvfs_vector(0 to TILES_NUM-1);
signal mon_dvfs_domain  : monitor_dvfs_vector(0 to TILES_NUM-1);

-- TODO: REMOVE!!! Interrupt controller
signal irqi : irq_in_vector(0 to CFG_NCPU_TILE-1);
signal irqo : irq_out_vector(0 to CFG_NCPU_TILE-1);
  
signal dbgi : l3_debug_in_vector(0 to CFG_NCPU_TILE-1);
signal dbgo : l3_debug_out_vector(0 to CFG_NCPU_TILE-1);

-- type debug_led_vector_type is array (1 to CFG_NCPU_TILE) of std_ulogic;
-- signal debug_led_vector : debug_led_vector_type;
signal debug_led_vector : std_logic_vector(0 to CFG_NCPU_TILE);

begin

  rst_int <= rst;
  noc_clk_int <= noc_clk;
  mem_clk_int <= mem_clk;
  pllbypass_int <= pllbypass;

  -----------------------------------------------------------------------------
  -- UART pads
  -----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => padtech) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => padtech) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => padtech) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => padtech) port map (uart_rtsn, uart_rtsn_int);


  -----------------------------------------------------------------------------
  -- DVFS domain probes steering
  -----------------------------------------------------------------------------
  domain_in_gen: for i in 0 to TILES_NUM-1 generate
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
      for i in 0 to TILES_NUM-1 loop
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

  tiles_gen: for i in 0 to TILES_NUM - 1  generate
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
      mon_dvfs_out(i).clk <= noc_clk_int;
      mon_dvfs_out(i).acc_idle <= '0';
      mon_dvfs_out(i).traffic <= '0';
      mon_dvfs_out(i).burst <= '0';
      clk_tile(i) <= noc_clk_int;
    end generate empty_tile;

    cpu_tile: if tile_type(i) = 1 generate
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
      tile_cpu_i: tile_cpu
        generic map (
          fabtech                 => fabtech,
          memtech                 => memtech,
          padtech                 => padtech,
          disas                   => disas,
          pclow                   => pclow,
          cpu_id                  => tile_cpu_id(i),
          local_y                 => tile_y(i),
          local_x                 => tile_x(i),
          remote_apb_slv_en       => remote_apb_slv_en,
          has_dvfs                => tile_has_dvfs(i),
          has_pll                 => tile_has_pll(i),
          domain                  => tile_domain(i),
          USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL)
        port map (
          rst                => rst_int,
          refclk             => refclk_int(i),
          pllbypass          => pllbypass_int(i),
          pllclk             => clk_tile(i),
          --TODO: REMOVE!
          irqi_i => irqi(tile_cpu_id(i)),
          irqo_o => irqo(tile_cpu_id(i)),
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
          mon_dvfs_in        => mon_dvfs_domain(i),
          mon_dvfs           => mon_dvfs_out(i),
          debug_led          => debug_led_vector(tile_cpu_id(i)));
    end generate cpu_tile;

    accelerator_tile: if tile_type(i) = 2 generate
      assert tile_device(i) /= 0 report "Undefined device ID for accelerator tile" severity error;
      tile_acc_i: tile_acc
        generic map (
          fabtech  => fabtech,
          memtech  => memtech,
          padtech  => padtech,
          hls_conf => tile_design_point(i),
          local_y  => tile_y(i),
          local_x  => tile_x(i),
          io_y     => tile_y(io_tile_id),
          io_x     => tile_x(io_tile_id),
          device   => tile_device(i),
          pindex   => tile_apb_idx(i),
          paddr    => tile_apb_paddr(i),
          pmask    => tile_apb_pmask(i),
          pirq     => tile_apb_irq(i),
          scatter_gather => tile_scatter_gather(i),
          local_apb_mask => local_apb_mask(i),
          has_dvfs       => tile_has_dvfs(i),
          has_pll        => tile_has_pll(i),
          extra_clk_buf  => extra_clk_buf(i),
          domain         => tile_domain(i))
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
          mon_acc            => mon_acc(accelerators_tile2number(i)),
          mon_dvfs           => mon_dvfs_out(i)
          );
    end generate accelerator_tile;

    io_tile: if tile_type(i) = 3 generate
      tile_io_i : tile_io
        generic map (
          fabtech => fabtech,
          memtech => memtech,
          padtech => padtech,
          disas   => disas,
          dbguart => dbguart,
          pclow   => pclow)
        port map (
          rst                => rst_int,
          clk                => noc_clk_int,
          uart_rxd           => uart_rxd_int,
          uart_txd           => uart_txd_int,
          uart_ctsn          => uart_ctsn_int,
          uart_rtsn          => uart_rtsn_int,
          dvi_apbi           => dvi_apbi,
          dvi_apbo           => dvi_apbo,
          dvi_ahbmi          => dvi_ahbmi,
          dvi_ahbmo          => dvi_ahbmo,
          --TODO: use proxy later for eth irq!!
          eth0_pirq          => eth0_apbo.pirq,
          sgmii0_pirq        => sgmii0_apbo.pirq,
          --TODO: REMOVE!
          irqi_o => irqi,
          irqo_i => irqo,
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
      clk_tile(i) <= noc_clk_int;
    end generate io_tile;

    mem_tile: if tile_type(i) = 4 generate
      tile_mem_i: tile_mem
        generic map (
          fabtech                 => fabtech,
          memtech                 => memtech,
          padtech                 => padtech,
          disas                   => disas,
          dbguart                 => dbguart,
          pclow                   => pclow,
          testahb                 => testahb,
          USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL)
        port map (
          rst                => rst_int,
          clk                => noc_clk_int,
          ddr_ahbsi          => ddr0_ahbsi,
          ddr_ahbso          => ddr0_ahbso,
          eth0_apbi          => eth0_apbi,
          eth0_apbo          => eth0_apbo,
          sgmii0_apbi        => sgmii0_apbi,
          sgmii0_apbo        => sgmii0_apbo,
          eth0_ahbmi         => eth0_ahbmi,
          eth0_ahbmo         => eth0_ahbmo,
          --pragma translate_off
          mctrl_ahbsi        => mctrl_ahbsi_mem(0),
          mctrl_ahbso        => mctrl_ahbso,
          mctrl_apbi         => mctrl_apbi_mem(0),
          mctrl_apbo         => mctrl_apbo,
          --pragma translate_on
          ndsuact            => ndsuact,
          dsuerr             => dsuerr,
          dbgi   => dbgi,
          dbgo   => dbgo,
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
          mon_dvfs           => mon_dvfs_out(i),
          debug_led          => debug_led_vector(CFG_NCPU_TILE));
      clk_tile(i) <= noc_clk_int;
    end generate mem_tile;

    multi_mem_ctrl: if CFG_MIG_DUAL /= 0 generate
      mem_lite_tile: if tile_type(i) = 5 generate
        tile_mem_lite_i: tile_mem_lite
          generic map (
            fabtech                 => fabtech,
            memtech                 => memtech,
            padtech                 => padtech,
            disas                   => disas,
            dbguart                 => dbguart,
            pclow                   => pclow,
            testahb                 => testahb,
            USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL)
          port map (
            rst                => rst_int,
            clk                => clk_tile(i),
            ddr_ahbsi          => ddr1_ahbsi,
            ddr_ahbso          => ddr1_ahbso,
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
        clk_tile(i) <= mem_clk_int;
      end generate mem_lite_tile;
    end generate multi_mem_ctrl;

    --pragma translate_off
    single_mem_ctrl: if CFG_MIG_DUAL = 0 generate
      no_mem_lite_tile: if tile_type(i) = 5 generate
        assert false report "Dual memory controller not enabled" severity error;
      end generate no_mem_lite_tile;
    end generate single_mem_ctrl;
    --pragma translate_on

  end generate tiles_gen;

  no_multi_mem_ctrl: if CFG_MIG_DUAL = 0 generate
    ddr1_ahbsi <= ahbs_in_none;
  end generate no_multi_mem_ctrl;
  
  --pragma translate_off
  mctrl_ahbsi <= mctrl_ahbsi_mem(0);
  mctrl_apbi <= mctrl_apbi_mem(0);
  mctrl_clk <= clk_tile(cpu_tile_id(0));
  --pragma translate_on

  -----------------------------------------------------------------------------
  -- NoC
  -----------------------------------------------------------------------------

  sync_noc_xy_1: sync_noc_xy
    generic map (
      flit_size => NOC_FLIT_SIZE,
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
      XLEN      => XLEN,
      YLEN      => YLEN,
      TILES_NUM => TILES_NUM,
      has_sync  => has_sync)
    port map (
      clk             => noc_clk_int,
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
    monitor_noc_tiles_gen: for j in 0 to TILES_NUM-1 generate
      mon_noc(i,j) <= mon_noc_vec(i)(j);
    end generate monitor_noc_tiles_gen;
  end generate monitor_noc_gen;

  debug_led <= or_reduce(debug_led_vector);
  
 end;

