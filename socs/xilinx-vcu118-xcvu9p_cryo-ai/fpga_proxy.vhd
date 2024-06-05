------------------------------------------------------------------------------
--  FPGA proxy for cryo-ai  -- vcu118
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

entity fpga_proxy_cryo_top is

  generic (
    SIMULATION : boolean := false);
  port (
	reset            : in    std_ulogic;
	chip_rstn		 : out 	 std_ulogic;  -- temporary out_clk signal for chip
	chip_clk		 : out 	 std_ulogic; -- temporary out_clk signal for chip
	chip_clkm		 : out 	 std_ulogic; -- temporary out_clk signal for chip
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
end;

architecture rtl of fpga_proxy_cryo_top is

  component sgmii_vcu118 is
    generic (
      pindex          : integer;
      paddr           : integer;
      pmask           : integer;
      abits           : integer;
      autonegotiation : integer;
      pirq            : integer;
      debugmem        : integer;
      tech            : integer;
      vcu128          : integer range 0 to 1;
      simulation      : boolean);
    port (
      sgmiii   : in  eth_sgmii_in_type;
      sgmiio   : out eth_sgmii_out_type;
      sgmii_dummy : in std_logic;
      gmiii    : out eth_in_type;
      gmiio    : in  eth_out_type;
      reset    : in  std_logic;
      apb_clk  : in  std_logic;
      apb_rstn : in  std_logic;
      apbi     : in  apb_slv_in_type;
      apbo     : out apb_slv_out_type);
  end component sgmii_vcu118;

-- FPGA DDR4 Controller. Must be moved to FPGA partition
  component ahb2mig_up is
    generic (
      hindex : integer;
      haddr  : integer;
      hmask  : integer;
      clamshell : integer range 0 to 1);
    port (
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(0 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(0 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(0 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
      ahbso            : out   ahb_slv_out_type;
      ahbsi            : in    ahb_slv_in_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      clk_amba         : in    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_slow      : out   std_logic;
      ui_clk_sync_rst  : out   std_logic);
  end component ahb2mig_up;

  component ahbslv2iolink is
  generic (
    hindex        : integer range 0 to NAHBSLV - 1;
    io_bitwidth   : integer range 1 to ARCH_BITS := 32;  
    word_bitwidth : integer range 1 to ARCH_BITS := 32;
    little_end    : integer range 0 to 1         := 0);
  port (
    clk           : in  std_ulogic;
    rstn          : in  std_ulogic;
    io_clk_in     : in  std_logic;
    io_clk_out    : out std_logic;
    io_valid_in   : in  std_ulogic;
    io_valid_out  : out std_ulogic;
    io_credit_in  : in  std_logic;
    io_credit_out : out std_logic;
    io_data_oen   : out std_logic;
    io_data_in    : in  std_logic_vector(io_bitwidth - 1 downto 0);
    io_data_out   : out std_logic_vector(io_bitwidth - 1 downto 0);
    ahbsi         : in  ahb_slv_in_type;
    ahbso         : out ahb_slv_out_type);
  end component ahbslv2iolink;

  component edcl_ahbmst_emu is
  generic(
    hindex         : integer := 0
   );
	port (
      clk    :  in  std_ulogic;
      reset  :  in  std_ulogic;
      ahbmo  :  out ahb_mst_out_type;
      ahbmi  :  in  ahb_mst_in_type;
      edcl_oen_ctrl  : out std_logic
    );
  end component edcl_ahbmst_emu;

  -- Switches
  signal sel0, sel1, sel2, sel3 : std_ulogic;

  -- clock and reset
  signal clkm                  : std_ulogic := '0';
  signal rstn, rstraw          : std_ulogic;
  signal lock, calib_done, rst : std_ulogic;
  signal migrstn               : std_logic;

  -- UART
  --signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  --signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  --signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  --signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

  -- Memory controller DDR4
  signal ddr_ahbsi   : ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
  signal ddr_ahbso   : ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);
  signal c0_ddr4_cs_n_vec : std_logic_vector(1 downto 0);

-- Ethernet
  signal gmiii            : eth_in_type;
  signal gmiio            : eth_out_type;
  signal sgmiii           : eth_sgmii_in_type;
  signal sgmiio           : eth_sgmii_out_type;
  signal sgmiirst         : std_logic;
  signal ethernet_phy_int : std_logic;
  signal rxd1             : std_logic;
  signal txd1             : std_logic;
  signal ethi             : eth_in_type;
  signal etho             : eth_out_type;
  signal egtx_clk         : std_ulogic;
  signal negtx_clk        : std_ulogic;
  signal eth0_apbi        : apb_slv_in_type;
  signal eth0_apbo        : apb_slv_out_type;
  signal sgmii0_apbi      : apb_slv_in_type;
  signal sgmii0_apbo      : apb_slv_out_type;
  signal eth0_ahbmi       : ahb_mst_in_type;
  signal eth0_ahbmo       : ahb_mst_out_type;
  signal edcl_ahbmo       : ahb_mst_out_vector;

  signal iolink_ahbsi : ahb_slv_in_type;
  signal iolink_ahbso : ahb_slv_out_vector;

-- IO Link
  signal iolink_data_in_int    : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_data_out_int   : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in_int   : std_ulogic;
  signal iolink_valid_out_int  : std_ulogic;
  signal iolink_clk_in_int     : std_logic;
  signal iolink_clk_out_int    : std_logic;
  signal iolink_credit_in_int  : std_logic;
  signal iolink_credit_out_int : std_logic;

  -- chip signals
  signal chip_rst       : std_ulogic;
  signal sys_clk : std_logic_vector(0 to 0);
  signal chip_refclk    : std_ulogic := '0';
  signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
  signal chip_pllclk    : std_ulogic;

  constant CPU_FREQ : integer := 50000; --78125;  -- cpu frequency in KHz

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of clkm : signal is true;
  attribute keep of chip_refclk : signal is true;
  attribute syn_keep of clkm : signal is "true";
  attribute syn_keep of chip_refclk : signal is "true";

  attribute mark_debug : string;

  attribute mark_debug of edcl_ahbmo    : signal is "true";
  attribute mark_debug of eth0_ahbmi    : signal is "true";
  attribute mark_debug of iolink_ahbso : signal is "true";
  attribute mark_debug of iolink_ahbsi : signal is "true";
  attribute mark_debug of iolink_data_in_int    : signal is "true";
  attribute mark_debug of iolink_data_out_int   : signal is "true";
  attribute mark_debug of iolink_valid_in_int   : signal is "true";
  attribute mark_debug of iolink_valid_out_int  : signal is "true";
  attribute mark_debug of iolink_clk_in_int     : signal is "true";
  attribute mark_debug of iolink_clk_out_int    : signal is "true";
  attribute mark_debug of iolink_credit_in_int  : signal is "true";
  attribute mark_debug of iolink_credit_out_int : signal is "true";

  attribute keep of edcl_ahbmo  : signal is true;
  attribute keep of eth0_ahbmi  : signal is true;
  attribute keep of iolink_ahbso : signal is true;
  attribute keep of iolink_ahbsi : signal is true;
  attribute keep of iolink_data_in_int 		: signal is true;
  attribute keep of iolink_data_out_int 	: signal is true;
  attribute keep of iolink_valid_in_int 	: signal is true;
  attribute keep of iolink_valid_out_int 	: signal is true;
  attribute keep of iolink_clk_in_int 		: signal is true;
  attribute keep of iolink_clk_out_int 		: signal is true;
  attribute keep of iolink_credit_in_int 	: signal is true;
  attribute keep of iolink_credit_out_int 	: signal is true;

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------
begin

  -- From CPU 0
  -- led0_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
  --  port map (led(0), cpuerr);
  ----pragma translate_off
  --process(clkm, rstn)
  --begin  -- process
  --  if rstn = '1' then
  --    assert cpuerr = '0' report "Program Completed!" severity failure;
  --  end if;
  --end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  led2_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(2), calib_done);
  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(3), lock);
  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(4), ddr_ahbso(0).hready);

  -- unused
  led1_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(1), '0');
  led5_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(5), '0');
  led6_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (led(6), '0');

-------------------------------------------------------------------------------
-- Switches -------------------------------------------------------------------
-------------------------------------------------------------------------------

  sw0_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (switch(0), '0', '1', sel0);
  sw1_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (switch(1), '0', '1', sel1);
  sw2_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (switch(2), '0', '1', sel2);
  sw3_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v, strength => 8)
    port map (switch(3), '0', '1', sel3);


----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);
  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, rstn, rstraw);
  lock <= calib_done;

  rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm, lock, migrstn, open);

-----------------------------------------------------------------------------
-- UART pads
-----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int);


----------------------------------------------------------------------
---  DDR4 memory controller ------------------------------------------
----------------------------------------------------------------------

  gen_mig : if (SIMULATION /= true) generate
    ddrc : ahb2mig_up
      generic map (
        hindex    => 0,
        haddr     => ddr_haddr(0),
        hmask     => ddr_hmask(0),
        clamshell => 0)
      port map (
        c0_sys_clk_p     => c0_sys_clk_p,
        c0_sys_clk_n     => c0_sys_clk_n,
        c0_ddr4_act_n    => c0_ddr4_act_n,
        c0_ddr4_adr      => c0_ddr4_adr,
        c0_ddr4_ba       => c0_ddr4_ba,
        c0_ddr4_bg       => c0_ddr4_bg,
        c0_ddr4_cke      => c0_ddr4_cke,
        c0_ddr4_odt      => c0_ddr4_odt,
        c0_ddr4_cs_n     => c0_ddr4_cs_n_vec,
        c0_ddr4_ck_t     => c0_ddr4_ck_t,
        c0_ddr4_ck_c     => c0_ddr4_ck_c,
        c0_ddr4_reset_n  => c0_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c0_ddr4_dq,
        c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
        ahbso            => open, --ddr_ahbso(0),
        ahbsi            => ahbs_in_none, --ddr_ahbsi(0),
        calib_done       => calib_done,
        rst_n_syn        => migrstn,
        rst_n_async      => rstraw,
        clk_amba         => clkm,
        ui_clk           => clkm,
        ui_clk_slow      => chip_refclk,
        ui_clk_sync_rst  => open
        );

    c0_ddr4_cs_n <= c0_ddr4_cs_n_vec(0 downto 0);

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
        clk   => clkm,
        haddr => ddr_haddr(0),
        hmask => ddr_hmask(0),
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

    calib_done <= '1';
    clkm       <= not clkm after 3.2 ns;
    chip_refclk <= not chip_refclk after 6.4 ns;

  -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if SIMULATION = false and CFG_GRETH = 1 generate      -- Gaisler ethernet MAC
    e1 : grethm
      generic map(
        hindex       => 1,
        ehindex      => 0,
		pindex       => 14,
        paddr        => 16#800#,
        pmask        => 16#f00#,
        pirq         => 12,
        memtech      => CFG_FABTECH,
        little_end   => GLOB_CPU_RISCV * CFG_L2_DISABLE,
        rmii         => 0,
        enable_mdio  => 1,
        fifosize     => CFG_ETH_FIFO,
        nsync        => 2,
        edcl         => 1,
        edclbufsz    => CFG_ETH_BUF,
        phyrstadr    => 3,
        vcu118       => 1,
        macaddrh     => CFG_ETH_ENM,
        macaddrl     => CFG_ETH_ENL,
        enable_mdint => 1,
        ipaddrh      => CFG_ETH_IPM,
        ipaddrl      => CFG_ETH_IPL,
        giga         => CFG_GRETH1G,
        ramdebug     => 0,
        gmiimode     => 1,
        edclsepahbg => 1)
      port map(
        rst   => rstn,
        clk   => chip_refclk,
        mdcscaler  => CPU_FREQ/1000,
        ahbmi => eth0_ahbmi,
        ahbmo => open,
        apbi  => apb_slv_in_none,
        apbo  => open,
        eahbmo => edcl_ahbmo (CFG_AHB_JTAG),
        ethi  => gmiii,
        etho  => gmiio);

    sgmiirst <= not rstraw;

    sgmii0 : sgmii_vcu118
      generic map(
        pindex          => 15,
        paddr           => 16#010#,
        pmask           => 16#ff0#,
        abits           => 8,
        autonegotiation => 1,
        pirq            => 11,
        debugmem        => 1,
        tech            => CFG_FABTECH,
        vcu128          => 0,
        simulation      => SIMULATION
        )
      port map(
        sgmiii   => sgmiii,
        sgmiio   => sgmiio,
        sgmii_dummy => '0',
        gmiii    => gmiii,
        gmiio    => gmiio,
        reset    => sgmiirst,
        apb_clk  => chip_refclk,
        apb_rstn => rstn,
        apbi     => apb_slv_in_none,
        apbo     => open
        );

    emdio_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (emdio, sgmiio.mdio_o, sgmiio.mdio_oe, sgmiii.mdio_i);

    emdc_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (emdc, sgmiio.mdc);

    eint_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (eint, sgmiii.mdint);

    erst_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erst, sgmiio.reset);

    sgmiii.clkp <= gtrefclk_p;
    sgmiii.clkn <= gtrefclk_n;
    txp         <= sgmiio.txp;
    txn         <= sgmiio.txn;
    sgmiii.rxp  <= rxp;
    sgmiii.rxn  <= rxn;

  end generate;

  no_eth0 : if SIMULATION = true or CFG_GRETH = 0 generate
    eth0_apbo   <= apb_none;
    sgmii0_apbo <= apb_none;
    eth0_ahbmo  <= ahbm_none;
    --edcl_ahbmo <= ahbm_none;
    txp         <= '0';
    txn         <= '1';
    emdc        <= '0';
    erst        <= '0';
    emdio       <= '0';
  end generate;

  no_onchip_eth : if CFG_ETH_EN = 0 generate
  -- iolink proxy
	ahbslv2iolink_i : ahbslv2iolink
	generic map (
      hindex      	=> 0,
      io_bitwidth 	=> CFG_IOLINK_BITS,  
      word_bitwidth => ARCH_BITS, 
      little_end    => GLOB_CPU_AXI)
    port map (
      clk             =>  chip_refclk,
      rstn            =>  rstn,
      io_clk_in       =>  iolink_clk_in_int,
      io_clk_out      =>  iolink_clk_out_int,
      io_valid_in     =>  iolink_valid_in_int,
      io_valid_out    =>  iolink_valid_out_int,
      io_credit_in    =>  iolink_credit_in_int,
      io_credit_out   =>  iolink_credit_out_int,
      io_data_oen     =>  open, --iolink_data_oen,
      io_data_in      =>  iolink_data_in_int,
      io_data_out     =>  iolink_data_out_int,
      ahbsi           =>  iolink_ahbsi,
      ahbso           =>  iolink_ahbso(0));

	iolink_clk_in_int 	<= iolink_clk_in;
	iolink_data_in_int 	<= iolink_data_in;
	iolink_valid_in_int <= iolink_valid_in;
	iolink_credit_in_int  <= iolink_credit_in;
	iolink_data_out 	<= iolink_data_out_int;
	iolink_valid_out 	<= iolink_valid_out_int;
	iolink_credit_out 	<= iolink_credit_out_int;
	iolink_clk_out 		<= iolink_clk_out_int;

  	ahbmst_gen : if SIMULATION = true generate
	  edcl_ahb_emu_i : edcl_ahbmst_emu
	  generic map (
		hindex => CFG_AHB_JTAG 
	  )
	  port map (
	    clk   => chip_refclk,
		reset => rstn,
		ahbmo => edcl_ahbmo(CFG_AHB_JTAG),
		ahbmi => eth0_ahbmi
	  );
	end generate ahbmst_gen;


 -- AHB bus
  ahbctrl_edcl_1 : ahbctrl                        -- AHB arbiter/multiplexer
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, fpnpen => CFG_FPNPEN,
                 nahbm   => 1, nahbs => NAHBSLV,
                 cfgmask => 0)
    port map (rstn, chip_refclk, eth0_ahbmi, edcl_ahbmo, iolink_ahbsi, iolink_ahbso);

  end generate no_onchip_eth;

    -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_rstn <= rstn;
  chip_clkm <= clkm;
  chip_clk <= chip_refclk;

  --chip_clk <= chip_refclk;
  --chip_rst <= rstn;
  --sys_clk(0) <= clkm;
  --chip_pllbypass <= (others => '0');

  --esp_1: esp
  --  generic map (
  --    SIMULATION => SIMULATION)
  --  port map (
  --    rst            => chip_rst,
  --    sys_clk        => sys_clk(0 to MEM_ID_RANGE_MSB),
  --    refclk         => chip_refclk,
  --    pllbypass      => chip_pllbypass,
  --    uart_rxd       => uart_rxd_int,
  --    uart_txd       => uart_txd_int,
  --    uart_ctsn      => uart_ctsn_int,
  --    uart_rtsn      => uart_rtsn_int,
  --    cpuerr         => cpuerr,
  --    ddr_ahbsi      => ddr_ahbsi,
  --    ddr_ahbso      => ddr_ahbso,
  --    eth0_ahbmi     => open, 
  --    eth0_ahbmo     => ahbm_none, 
  --    edcl_ahbmo     => ahbm_none, 
  --    eth0_apbi      => apb_slv_in_none,
  --   eth0_apbo      => open,
  --    sgmii0_apbi    => apb_slv_in_none,
  --    sgmii0_apbo    => open,
  --    dvi_apbi       => apb_slv_in_none,
  --    dvi_apbo       => open,
  --    dvi_ahbmi      => ahbm_in_none,
  --    dvi_ahbmo      => open,
  --    iolink_data_oen   => open,
  --    iolink_data_in    => iolink_data_in,
  --    iolink_data_out   => iolink_data_out,
  --    iolink_valid_in   => iolink_valid_in,
  --    iolink_valid_out  => iolink_valid_out,
  --    iolink_clk_in     => iolink_clk_in,
  --    iolink_clk_out    => iolink_clk_out,
  --    iolink_credit_in  => iolink_credit_in,
  --    iolink_credit_out => iolink_credit_out
  --    );
 end;
