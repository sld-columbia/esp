------------------------------------------------------------------------------
--  ESP - xilinx - vc707
------------------------------------------------------------------------------
-- DISCLAIMER --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.memctrl.all;
use work.memoryctrl.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
use work.jtag.all;
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
use work.config.all;
use work.socmap.all;
use work.soctiles.all;

entity top is
  generic (
    fabtech             : integer := CFG_FABTECH;
    memtech             : integer := CFG_MEMTECH;
    padtech             : integer := CFG_PADTECH;
    disas               : integer := CFG_DISAS;   -- Enable disassembly to console
    dbguart             : integer := CFG_DUART;   -- Print UART on console
    pclow               : integer := CFG_PCLOW;
    testahb             : boolean := false;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION          : string := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false;
    autonegotiation     : integer := 1
  );
  port (
    reset           : in    std_ulogic;
    sys_clk_p       : in    std_ulogic;  -- 200 MHz clock
    sys_clk_n       : in    std_ulogic;  -- 200 MHz clock
    --pragma translate_off
    address         : out   std_logic_vector(25 downto 0);
    data            : inout std_logic_vector(15 downto 0);
    oen             : out   std_ulogic;
    writen          : out   std_ulogic;
    romsn           : out   std_logic;
    adv             : out   std_logic;
    --pragma translate_on
    ddr3_dq         : inout std_logic_vector(63 downto 0);
    ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    ddr3_addr       : out   std_logic_vector(13 downto 0);
    ddr3_ba         : out   std_logic_vector(2 downto 0);
    ddr3_ras_n      : out   std_logic;
    ddr3_cas_n      : out   std_logic;
    ddr3_we_n       : out   std_logic;
    ddr3_reset_n    : out   std_logic;
    ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    ddr3_cke        : out   std_logic_vector(0 downto 0);
    ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    ddr3_dm         : out   std_logic_vector(7 downto 0);
    ddr3_odt        : out   std_logic_vector(0 downto 0);
    gtrefclk_p      : in    std_logic;
    gtrefclk_n      : in    std_logic;
    txp             : out   std_logic;
    txn             : out   std_logic;
    rxp             : in    std_logic;
    rxn             : in    std_logic;
    emdio           : inout std_logic;
    emdc            : out   std_ulogic;
    eint            : in    std_ulogic;
    erst            : out   std_ulogic;
    uart_rxd        : in    std_ulogic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_ulogic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_ulogic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_ulogic;  -- UART1_RTSN (u1o.rtsn)
    button          : in    std_logic_vector(3 downto 0);
    switch          : inout std_logic_vector(4 downto 0);
    led             : out   std_logic_vector(6 downto 0)
   );
end;


architecture rtl of top is

component sgmii_vc707
  generic(
    pindex          : integer := 0;
    paddr           : integer := 0;
    pmask           : integer := 16#fff#;
    abits           : integer := 8;
    autonegotiation : integer := 1;
    pirq            : integer := 0;
    debugmem        : integer := 0;
    tech            : integer := 0
  );
  port(
    sgmiii    :  in  eth_sgmii_in_type;
    sgmiio    :  out eth_sgmii_out_type;
    gmiii     : out   eth_in_type;
    gmiio     : in    eth_out_type;
    reset     : in    std_logic;                     -- Asynchronous reset for entire core.
    apb_clk   : in    std_logic;
    apb_rstn  : in    std_logic;
    apbi      : in    apb_slv_in_type;
    apbo      : out   apb_slv_out_type
  );
end component;

-- FPGA DDR3 Controller. Must be moved to FPGA partition
component ahb2mig_7series
  generic(
    hindex     : integer := 0;
    haddr      : integer := 0;
    hmask      : integer := 16#f00#;
    pindex     : integer := 0;
    paddr      : integer := 0;
    pmask      : integer := 16#fff#;
    SIM_BYPASS_INIT_CAL : string := "OFF";
    SIMULATION : string  := "FALSE";
    USE_MIG_INTERFACE_MODEL : boolean := false
  );
  port(
    ddr3_dq           : inout std_logic_vector(63 downto 0);
    ddr3_dqs_p        : inout std_logic_vector(7 downto 0);
    ddr3_dqs_n        : inout std_logic_vector(7 downto 0);
    ddr3_addr         : out   std_logic_vector(13 downto 0);
    ddr3_ba           : out   std_logic_vector(2 downto 0);
    ddr3_ras_n        : out   std_logic;
    ddr3_cas_n        : out   std_logic;
    ddr3_we_n         : out   std_logic;
    ddr3_reset_n      : out   std_logic;
    ddr3_ck_p         : out   std_logic_vector(0 downto 0);
    ddr3_ck_n         : out   std_logic_vector(0 downto 0);
    ddr3_cke          : out   std_logic_vector(0 downto 0);
    ddr3_cs_n         : out   std_logic_vector(0 downto 0);
    ddr3_dm           : out   std_logic_vector(7 downto 0);
    ddr3_odt          : out   std_logic_vector(0 downto 0);
    ahbso             : out   ahb_slv_out_type;
    ahbsi             : in    ahb_slv_in_type;
    calib_done        : out   std_logic;
    rst_n_syn         : in    std_logic;
    rst_n_async       : in    std_logic;
    clk_amba          : in    std_logic;
    sys_clk_p         : in    std_logic;
    sys_clk_n         : in    std_logic;
    clk_ref_i         : in    std_logic;
    ui_clk            : out   std_logic;
    ui_clk_sync_rst   : out   std_logic
   );
end component ;

-- pragma translate_off
-- Memory model for simulation purposes only
component ahbram_sim
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#fff#;
    tech    : integer := DEFMEMTECH; 
    kbytes  : integer := 1;
    pipe    : integer := 0;
    maccsz  : integer := AHBDW;
    fname   : string  := "ram.dat"
   );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type
  );
end component ;

-- Signals for memory controller used to boot in simulation
signal memi  : memory_in_type;
signal memo  : memory_out_type;
signal wpo   : wprot_out_type;
signal sdi   : sdctrl_in_type;
signal sdo   : sdram_out_type;
-- pragma translate_on


-- constants
signal vcc, gnd   : std_logic_vector(31 downto 0);

-- Switches
signal sel0, sel1, sel2, sel3, sel4 : std_ulogic;

-- clock and reset
signal clkm : std_ulogic := '0';
signal rstn, rstraw : std_ulogic;
signal cgi : clkgen_in_type;
signal cgo : clkgen_out_type;
signal lock, calib_done, rst : std_ulogic;
signal clkref  : std_logic;
signal migrstn : std_logic;


-- Tiles
--pragma translate_off
signal mctrl_ahbsi : ahb_slv_in_type;
signal mctrl_ahbso : ahb_slv_out_type;
signal mctrl_apbi  : apb_slv_in_type;
signal mctrl_apbo  : apb_slv_out_type;
signal mctrl_clk   : std_ulogic;
--pragma translate_on

-- Memory controller DDR3
signal ddr_ahbsi   : ahb_slv_in_type;
signal ddr_ahbso   : ahb_slv_out_type;

-- DVI (unused on this board)
signal dvi_apbi  : apb_slv_in_type;
signal dvi_apbo  : apb_slv_out_type;
signal dvi_ahbmi : ahb_mst_in_type;
signal dvi_ahbmo : ahb_mst_out_type;

-- Ethernet
signal gmiii : eth_in_type;
signal gmiio : eth_out_type;
signal sgmiii :  eth_sgmii_in_type;
signal sgmiio :  eth_sgmii_out_type;
signal sgmiirst : std_logic;
signal ethernet_phy_int : std_logic;
signal rxd1 : std_logic;
signal txd1 : std_logic;
signal ethi : eth_in_type;
signal etho : eth_out_type;
signal egtx_clk :std_ulogic;
signal negtx_clk :std_ulogic;
constant BOARD_FREQ : integer := 200000;   -- input frequency in KHz
constant BOARD_CLKMUL : integer := 4;
constant BOARD_CLKDIV : integer := 8;
constant CPU_FREQ : integer := BOARD_FREQ * BOARD_CLKMUL / BOARD_CLKDIV;  -- cpu frequency in KHz
signal eth0_apbi : apb_slv_in_type;
signal eth0_apbo : apb_slv_out_type;
signal sgmii0_apbi : apb_slv_in_type;
signal sgmii0_apbo : apb_slv_out_type;
signal eth0_ahbmi : ahb_mst_in_type;
signal eth0_ahbmo : ahb_mst_out_type;

-- DSU
signal ndsuact     : std_ulogic;
signal dsuerr      : std_ulogic;

-- NOC
signal chip_rst : std_ulogic;
signal noc_clk : std_ulogic;
signal chip_refclk : std_ulogic;
signal chip_pllbypass : std_logic_vector(CFG_TILES_NUM-1 downto 0);
signal chip_pllclk : std_ulogic;

signal debug_led : std_ulogic;

attribute keep : boolean;
attribute syn_keep : string;
attribute keep of clkm : signal is true;

signal eth0_ahbmi_hready : std_ulogic;
signal eth0_ahbmi_hrdata : std_logic_vector(AHBDW-1 downto 0);
signal eth0_ahbmo_haddr : std_logic_vector(31 downto 0);
signal eth0_ahbmo_htrans : std_logic_vector(1 downto 0);
signal eth0_ahbmo_hwrite : std_ulogic;
signal eth0_ahbmo_hwdata : std_logic_vector(AHBDW-1 downto 0);

attribute mark_debug : string;
attribute mark_debug of eth0_ahbmi_hready : signal is "true";
attribute mark_debug of eth0_ahbmi_hrdata : signal is "true";
attribute mark_debug of eth0_ahbmo_haddr : signal is "true";
attribute mark_debug of eth0_ahbmo_htrans : signal is "true";
attribute mark_debug of eth0_ahbmo_hwrite : signal is "true";
attribute mark_debug of eth0_ahbmo_hwdata : signal is "true";

begin

eth0_ahbmi_hready <= eth0_ahbmi.hready;
eth0_ahbmi_hrdata <= eth0_ahbmi.hrdata;
eth0_ahbmo_haddr <= eth0_ahbmo.haddr;
eth0_ahbmo_htrans <= eth0_ahbmo.htrans;
eth0_ahbmo_hwrite <= eth0_ahbmo.hwrite;
eth0_ahbmo_hwdata <= eth0_ahbmo.hwdata;
  
-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------

  -- From DSU 0 (on chip)
  led0_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(0), ndsuact);
  -- From CPU 0 (on chip)
  led1_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(1), dsuerr);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert dsuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  led2_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(2), calib_done);
  led3_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(3), lock);
  led4_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(4), ddr_ahbso.hready);

  -- Unused
  led5_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(5), debug_led);
  led6_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (led(6), '0');

-------------------------------------------------------------------------------
-- Switches -------------------------------------------------------------------
-------------------------------------------------------------------------------

  sw0_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (switch(0), '0', '1', sel0);
  sw1_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (switch(1), '0', '1', sel1);
  sw2_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (switch(2), '0', '1', sel2);
  sw3_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (switch(3), '0', '1', sel3);
  sw4_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (switch(4), '0', '1', sel4);

-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  vcc <= (others => '1'); gnd <= (others => '0');
  cgi.pllctrl <= "00"; cgi.pllrst <= rstraw;

  reset_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v) port map (reset, rst);
  rst0 : rstgen         -- reset generator
  generic map (acthigh => 1, syncin => 0)
  port map (rst, clkm, lock, rstn, rstraw);
  lock <= calib_done;

  rst1 : rstgen         -- reset generator
  generic map (acthigh => 1)
  port map (rst, clkm, lock, migrstn, open);



  -- pragma translate_off
----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------
  -- Memory controller is required for current testbench, because it drives a
  -- boot ROM. On the final system, instead, there is no ROM and the system
  -- boots from DRAM thanks to grmon and the DSU.
  memi.writen <= '1'; memi.wrn <= "1111"; memi.bwidth <= "01";
  memi.brdyn <= '0'; memi.bexcn <= '1';

  mctrl0 : mctrl generic map (hindex => 0, pindex => 0,
                              paddr => 0, srbanks => 2, ram8 => 1,
                              ram16 => 1, sden => CFG_MCTRL_SDEN,
                              invclk => 0, sepbus => CFG_MCTRL_SEPBUS,
                              pageburst => CFG_MCTRL_PAGE, rammask => 0, iomask => 0)
    port map (rstn, mctrl_clk, memi, memo, mctrl_ahbsi, mctrl_ahbso, mctrl_apbi, mctrl_apbo, wpo, sdo);

  addr_pad : outpadv generic map (width => 26, tech => padtech, level => cmos, voltage => x18v)
    port map (address(25 downto 0), memo.address(26 downto 1));
  roms_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (romsn, memo.romsn(0));
  oen_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (oen, memo.oen);
  adv_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (adv, '0');
  wri_pad  : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
    port map (writen, memo.writen);
  data_pad : iopadvv generic map (tech => padtech, width => 16, level => cmos, voltage => x18v)
    port map (data(15 downto 0), memo.data(31 downto 16),
              memo.vbdrive(31 downto 16), memi.data(31 downto 16));
  -- pragma translate_on



----------------------------------------------------------------------
---  DDR3 memory controller ------------------------------------------
----------------------------------------------------------------------

  gen_mig : if (USE_MIG_INTERFACE_MODEL /= true) generate
    ddrc : ahb2mig_7series generic map(
      hindex => 4, haddr => 16#400#, hmask => 16#C00#,
      SIM_BYPASS_INIT_CAL => SIM_BYPASS_INIT_CAL,
      SIMULATION => SIMULATION, USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL)
      port map(
        ddr3_dq         => ddr3_dq,
        ddr3_dqs_p      => ddr3_dqs_p,
        ddr3_dqs_n      => ddr3_dqs_n,
        ddr3_addr       => ddr3_addr,
        ddr3_ba         => ddr3_ba,
        ddr3_ras_n      => ddr3_ras_n,
        ddr3_cas_n      => ddr3_cas_n,
        ddr3_we_n       => ddr3_we_n,
        ddr3_reset_n    => ddr3_reset_n,
        ddr3_ck_p       => ddr3_ck_p,
        ddr3_ck_n       => ddr3_ck_n,
        ddr3_cke        => ddr3_cke,
        ddr3_cs_n       => ddr3_cs_n,
        ddr3_dm         => ddr3_dm,
        ddr3_odt        => ddr3_odt,
        ahbsi           => ddr_ahbsi,
        ahbso           => ddr_ahbso,
        calib_done      => calib_done,
        rst_n_syn       => migrstn,
        rst_n_async     => rstraw,
        clk_amba        => clkm,
        sys_clk_p       => sys_clk_p,
        sys_clk_n       => sys_clk_n,
        clk_ref_i       => clkref,
        ui_clk          => clkm,
        ui_clk_sync_rst => open
        );

    clkgenmigref0 : clkgen
      generic map (fabtech, 22, 9, 0, 0, 0, 0, 0, 81248)
      port map (clkm, clkm, clkref, open, open, open, open, cgi, cgo, open, open, open);
  end generate gen_mig;

  gen_mig_model : if (USE_MIG_INTERFACE_MODEL = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex   => 4,
        haddr    => 16#400#,
        hmask    => 16#C00#,
        tech     => 0,
        kbytes   => 1000,
        pipe     => 0,
        maccsz   => AHBDW,
        fname    => "ram.srec"
        )
      port map(
        rst     => rstn,
        clk     => clkm,
        ahbsi   => ddr_ahbsi,
        ahbso   => ddr_ahbso
        );

    ddr3_dq           <= (others => 'Z');
    ddr3_dqs_p        <= (others => 'Z');
    ddr3_dqs_n        <= (others => 'Z');
    ddr3_addr         <= (others => '0');
    ddr3_ba           <= (others => '0');
    ddr3_ras_n        <= '0';
    ddr3_cas_n        <= '0';
    ddr3_we_n         <= '0';
    ddr3_reset_n      <= '1';
    ddr3_ck_p         <= (others => '0');
    ddr3_ck_n         <= (others => '0');
    ddr3_cke          <= (others => '0');
    ddr3_cs_n         <= (others => '0');
    ddr3_dm           <= (others => '0');
    ddr3_odt          <= (others => '0');

    --calib_done        : out   std_logic;
    calib_done <= '1';
    --ui_clk            : out   std_logic;
    clkm <= not clkm after 5.0 ns;
    --ui_clk_sync_rst   : out   std_logic
    -- n/a
    -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  eth0 : if CFG_GRETH = 1 generate -- Gaisler ethernet MAC
    e1 : grethm
      generic map(
        hindex => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG,
        pindex => 14,
        paddr => 16#800#,
        pmask => 16#f00#,
        pirq => 12,
        memtech => memtech,
        mdcscaler => CPU_FREQ/1000,
        rmii => 0,
        enable_mdio => 1,
        fifosize => CFG_ETH_FIFO,
        nsync => 2,
        edcl => CFG_DSU_ETH,
        edclbufsz => CFG_ETH_BUF,
        phyrstadr => 7,
        macaddrh => CFG_ETH_ENM,
        macaddrl => CFG_ETH_ENL,
        enable_mdint => 1,
        ipaddrh => CFG_ETH_IPM,
        ipaddrl => CFG_ETH_IPL,
        giga => CFG_GRETH1G,
        ramdebug => 0,
        gmiimode => 1)
      port map(
        rst => rstn,
        clk => clkm,
        ahbmi => eth0_ahbmi,
        ahbmo => eth0_ahbmo,            -- ahbmo(CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG)
        apbi => eth0_apbi,
        apbo => eth0_apbo,              -- Connect to apbo(14) on socmap for cpu_tile
        ethi => gmiii,
        etho => gmiio);

    sgmiirst <= not rstraw;

    sgmii0 : sgmii_vc707
      generic map(
        pindex          => 15,
        paddr           => 16#010#,
        pmask           => 16#ff0#,
        abits           => 8,
        autonegotiation => autonegotiation,
        pirq            => 11,
        debugmem        => 1,
        tech            => fabtech
        )
      port map(
        sgmiii   => sgmiii,
        sgmiio   => sgmiio,
        gmiii    => gmiii,
        gmiio    => gmiio,
        reset    => sgmiirst,
        apb_clk  => clkm,
        apb_rstn => rstn,
        apbi     => sgmii0_apbi,
        apbo     => sgmii0_apbo          -- Connect to apbo(15) on socmap for cpu_tile
        );

    emdio_pad : iopad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdio, sgmiio.mdio_o, sgmiio.mdio_oe, sgmiii.mdio_i);

    emdc_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (emdc, sgmiio.mdc);

    eint_pad : inpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (eint, sgmiii.mdint);

    erst_pad : outpad generic map (tech => padtech, level => cmos, voltage => x18v)
      port map (erst, sgmiio.reset);

    sgmiii.clkp <= gtrefclk_p;
    sgmiii.clkn <= gtrefclk_n;
    txp         <= sgmiio.txp;
    txn         <= sgmiio.txn;
    sgmiii.rxp  <= rxp;
    sgmiii.rxn  <= rxn;

  end generate;

  no_eth0 : if CFG_GRETH = 0 generate
    eth0_apbo <= apb_none;
    sgmii0_apbo <= apb_none;
    eth0_ahbmo <= ahbm_none;
    txp <= '0';
    txn <= '1';
    emdc <= '0';
    erst <= '0';
    emdio <= '0';
  end generate;

  -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_rst <= rstn;
  noc_clk <= clkm;
  chip_refclk <= clkm;
  chip_pllbypass <= (others => '0');

  esp_1: esp
    generic map (
      fabtech                 => CFG_FABTECH,
      memtech                 => CFG_MEMTECH,
      padtech                 => CFG_PADTECH,
      disas                   => disas,
      dbguart                 => dbguart,
      pclow                   => pclow,
      testahb                 => testahb,
      has_dvfs                => CFG_HAS_DVFS,
      has_sync                => CFG_HAS_SYNC,
      XLEN                    => CFG_XLEN,
      YLEN                    => CFG_YLEN,
      TILES_NUM               => CFG_TILES_NUM,
      SIM_BYPASS_INIT_CAL     => SIM_BYPASS_INIT_CAL,
      SIMULATION              => SIMULATION,
      USE_MIG_INTERFACE_MODEL => USE_MIG_INTERFACE_MODEL,
      autonegotiation         => autonegotiation)
    port map (
      rst           => chip_rst,
      noc_clk       => noc_clk,
      refclk        => chip_refclk,
      mem_clk       => noc_clk,
      pllbypass     => chip_pllbypass,
      --pragma translate_off
      mctrl_ahbsi   => mctrl_ahbsi,
      mctrl_ahbso   => mctrl_ahbso,
      mctrl_apbi    => mctrl_apbi,
      mctrl_apbo    => mctrl_apbo,
      mctrl_clk     => mctrl_clk,
      --pragma translate_on
      uart_rxd       => uart_rxd,
      uart_txd       => uart_txd,
      uart_ctsn      => uart_ctsn,
      uart_rtsn      => uart_rtsn,
      ndsuact        => ndsuact,
      dsuerr         => dsuerr,
      ddr0_ahbsi     => ddr_ahbsi,
      ddr0_ahbso     => ddr_ahbso,
      ddr1_ahbsi     => open,
      ddr1_ahbso     => ahbs_none,
      eth0_ahbmi     => eth0_ahbmi,
      eth0_ahbmo     => eth0_ahbmo,
      eth0_apbi      => eth0_apbi,
      eth0_apbo      => eth0_apbo,
      sgmii0_apbi    => sgmii0_apbi,
      sgmii0_apbo    => sgmii0_apbo,
      dvi_apbi       => dvi_apbi,
      dvi_apbo       => dvi_apbo,
      dvi_ahbmi      => dvi_ahbmi,
      dvi_ahbmo      => dvi_ahbmo,
      debug_led      => debug_led);

 end;

