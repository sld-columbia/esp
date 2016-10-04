-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2015, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      proFPGA
-- =============================================================================
--!  @file         profpga_ctrl.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA user fpga control module
--!                (Xilinx Virtex-7 implementation)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.mmi64_pkg.all;
use work.profpga_pkg.all;
use work.mmi64_p_muxdemux_pkg.all;      --! muxdemux specific definitions

entity profpga_ctrl is
  generic (
    DEVICE              : string := "XV7S"; --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
    ENABLE_DEBUG        : string := "FALSE";--! set to "TRUE" when instructed by ProDesign
    PIN_TRAINING_SPEED  : string := "auto"  --! Pin training speed: "real"=real calibration, "fast"=fast simulation, "auto"=auto-detect (synthesis tool must support "--synthesis translate_off/on")
  );
  port (
    -- access to FPGA pins
    clk0_p              : in  std_ulogic;
    clk0_n              : in  std_ulogic;
    sync0_p             : in  std_ulogic;
    sync0_n             : in  std_ulogic;
    srcclk_p            : out std_ulogic_vector(3 downto 0);
    srcclk_n            : out std_ulogic_vector(3 downto 0);
    srcsync_p           : out std_ulogic_vector(3 downto 0);
    srcsync_n           : out std_ulogic_vector(3 downto 0);
    dmbi_h2f            : in  std_ulogic_vector(19 downto 0);
    dmbi_f2h            : out std_ulogic_vector(19 downto 0);

    --! MUXDEMUX status
    rt_crc_errors_o     : out std_ulogic_vector(15 downto 0);         --! RX CRC errors
    rt_ack_errors_o     : out std_ulogic_vector(15 downto 0);         --! Number of retransmited messages
    rt_id_errors_o      : out std_ulogic_vector(15 downto 0);         --! Number of messages with wrong id
    rt_id_warnings_o    : out std_ulogic_vector(15 downto 0);         --! Number of messages with repeated id
    muxdemux_status_o   : out std_ulogic_vector(GetStatBitWidth(DEVICE, 4)-1 downto 0);
    muxdemux_mode_o     : out std_ulogic_vector(15 downto 0);
    
    -- 200 MHz clock (useful for delay calibration)
    clk_200mhz_o        : out std_ulogic;

    -- source clock/sync input
    src_clk_i           : in  std_ulogic_vector(3 downto 0) := "0000";
    src_clk_locked_i    : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_id_i      : in  sync_event_vector(3 downto 0) := (others=>x"00");
    src_event_en_i      : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_busy_o    : out std_ulogic_vector(3 downto 0);
    src_event_reset_i   : in  std_ulogic_vector(3 downto 0) := "1111";
    src_event_strobe1_i : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_strobe2_i : in  std_ulogic_vector(3 downto 0) := "0000";

    -- clk0 sync events (synchronized with mmi64_clk)
    clk0_event_id_o     : out std_ulogic_vector(7 downto 0);
    clk0_event_en_o     : out std_ulogic;
    clk0_event_strobe1_o: out std_ulogic;
    clk0_event_strobe2_o: out std_ulogic;

    -- MMI-64 access
    mmi64_present_i     : in  std_ulogic := '0';
    mmi64_clk_o         : out std_ulogic;
    mmi64_reset_o       : out std_ulogic;

    mmi64_m_dn_d_o      : out mmi64_data_t;
    mmi64_m_dn_valid_o  : out std_ulogic;
    mmi64_m_dn_accept_i : in  std_ulogic := '0';
    mmi64_m_dn_start_o  : out std_ulogic;
    mmi64_m_dn_stop_o   : out std_ulogic;
    mmi64_m_up_d_i      : in  mmi64_data_t := (others=>'0');
    mmi64_m_up_valid_i  : in  std_ulogic := '0';
    mmi64_m_up_accept_o : out std_ulogic;
    mmi64_m_up_start_i  : in  std_ulogic := '0';
    mmi64_m_up_stop_i   : in  std_ulogic := '0';

    -- clock configuration ports
    clk1_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk1_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk2_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk2_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk3_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk3_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk4_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk4_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk5_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk5_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk6_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk6_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk7_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk7_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0')
  );
end entity profpga_ctrl;





library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.mmi64_pkg.all;
    use work.mmi64_p_muxdemux_comp.all;
    use work.mmi64_router_comp.all;
    use work.mmi64_buffer_comp.all;
    use work.mmi64_m_regif_comp.all;
    use work.mmi64_m_devzero_comp.all;
    use work.profpga_pkg.all;
library unisim;
  use unisim.vcomponents.all;
architecture rtl of profpga_ctrl is
  function Log2(constant W : integer) return integer is
  begin
    for i in 0 to 31 loop
      if 2**i>=W then return i; end if;
    end loop;
    return 32;
  end function Log2;
  
  -- Set appropriate clock compenstion for CLK0
  function GetClkCompensation(constant DEVICE : string) return string is
  begin
    if DEVICE = "XV7S" then
      return "ZHOLD";
    elsif DEVICE = "XVUS" then
      return "DELAYED";
    else
      return "NOT_SUPPORTED";
    end if;
  end function GetClkCompensation;
  
  constant CLK0_CORE_COMPENSATION : string := GetClkCompensation(DEVICE);
  
  constant HDL_REVISION         : integer := 1;
  constant CLK0_PERIOD_NS       : integer := 10;
  
   

  constant MMI64_MODULES        : integer := 3; -- number of MMI-64 modules on primary router
  constant MMI64_M_USER         : integer := 0; -- MMI-64 router port to user
  constant MMI64_M_CONFIG       : integer := 1; -- MMI-64 router port for configuration
  constant MMI64_M_TEST         : integer := 2; -- MMI-64 router port for performance and load testing

  -- configuration registers
  constant REGID_REVISION       : integer := 0; -- infrastructure revision (read-only)
  constant REGID_CLK_CFG        : integer := 1; -- clk1 to clk7 configuration (read-only)
  constant REGID_SRCCLK_PRESENT : integer := 2; -- srcclk present ? (read-only)
  constant REGID_SYNC0_DELAY    : integer := 3; -- sync0 delay value (read-write)

  constant REGID_CLK1_ADDR      : integer := 4;
  constant REGID_CLK1_MASK      : integer := 5;
  constant REGID_CLK1_DATA      : integer := 6;
  constant REGID_SYNC1_DELAY    : integer := 7;
  constant REGID_CLK2_ADDR      : integer := 8;
  constant REGID_CLK2_MASK      : integer := 9;
  constant REGID_CLK2_DATA      : integer := 10;
  constant REGID_SYNC2_DELAY    : integer := 11;
  constant REGID_CLK3_ADDR      : integer := 12;
  constant REGID_CLK3_MASK      : integer := 13;
  constant REGID_CLK3_DATA      : integer := 14;
  constant REGID_SYNC3_DELAY    : integer := 15;
  constant REGID_CLK4_ADDR      : integer := 16;
  constant REGID_CLK4_MASK      : integer := 17;
  constant REGID_CLK4_DATA      : integer := 18;
  constant REGID_SYNC4_DELAY    : integer := 19;
  constant REGID_CLK5_ADDR      : integer := 20;
  constant REGID_CLK5_MASK      : integer := 21;
  constant REGID_CLK5_DATA      : integer := 22;
  constant REGID_SYNC5_DELAY    : integer := 23;
  constant REGID_CLK6_ADDR      : integer := 24;
  constant REGID_CLK6_MASK      : integer := 25;
  constant REGID_CLK6_DATA      : integer := 26;
  constant REGID_SYNC6_DELAY    : integer := 27;
  constant REGID_CLK7_ADDR      : integer := 28;
  constant REGID_CLK7_MASK      : integer := 29;
  constant REGID_CLK7_DATA      : integer := 30;
  constant REGID_SYNC7_DELAY    : integer := 31;

  constant REGID_SRCSYNC0_CFG   : integer := 32;
  constant REGID_SRCSYNC0_EVENT : integer := 33;
  constant REGID_SRCSYNC1_CFG   : integer := 34;
  constant REGID_SRCSYNC1_EVENT : integer := 35;
  constant REGID_SRCSYNC2_CFG   : integer := 36;
  constant REGID_SRCSYNC2_EVENT : integer := 37;
  constant REGID_SRCSYNC3_CFG   : integer := 38;
  constant REGID_SRCSYNC3_EVENT : integer := 39;
  constant CONFIG_REGISTERS     : integer := 40;

  -- bit index definitions for clkX_cfg vector
  --    downstream
  constant IDX_DN_DATA_LO       : integer := 0;   -- clkX_cfg_dn_o[15:0]  cfg_wdata
  constant IDX_DN_DATA_HI       : integer := 15;
  constant IDX_DN_ADDR_LO       : integer := 16;  -- clkX_cfg_dn_o[17:16] cfg_addr
  constant IDX_DN_ADDR_HI       : integer := 17;
  constant IDX_DN_EN            : integer := 18;  -- clkX_cfg_dn_o[18]    cfg_en
  constant IDX_DN_WE            : integer := 19;  -- clkX_cfg_dn_o[19]    cfg_we
  --    upstream
  constant IDX_UP_DATA_LO       : integer := 0;   -- clkX_cfg_up_i[15:0]  cfg_rdata
  constant IDX_UP_DATA_HI       : integer := 15;
  constant IDX_UP_ACCEPT        : integer := 16;  -- clkX_cfg_up_i[16]    cfg_accept
  constant IDX_UP_RVALID        : integer := 17;  -- clkX_cfg_up_i[17]    cfg_rvalid
  constant IDX_UP_IS_ACM        : integer := 18;  -- clkX_cfg_up_i[18]    is_acm (1=profpga_acm, 0=profpga_clocksync)
  constant IDX_UP_PRESENT       : integer := 19;  -- clkX_cfg_up_i[19]    present (1=yes, 0=port unused)

  -- signal processing directly at clk0 input pad
  signal clk0_pad               : std_ulogic;
  signal clk0_pad_srl           : std_ulogic;
  signal clk0_pll_rst           : std_ulogic;

  -- signals connected to clk0 PLL
  signal clk0_pll_fbout         : std_ulogic;
  signal clk0_pll_fbin          : std_ulogic;
  signal clk0_pll_clk_dmbi_x4   : std_ulogic;
  signal clk0_pll_clk_dmbi      : std_ulogic;
  signal clk0_pll_clk_200mhz    : std_ulogic;
  signal clk0_pll_clk_mmi64    : std_ulogic;
  signal clk0_pll_locked        : std_ulogic;

  -- PLL output after adding BUFG
  signal mmi64_clk              : std_ulogic;
  signal dmbi_clk               : std_ulogic;
  signal dmbi_clk_x4            : std_ulogic;
  signal clk_200mhz             : std_ulogic;

  -- local reset (16 cycles after PLL has locked)
  signal local_rst_r            : unsigned(15 downto 0);
  signal local_reset            : std_ulogic;
  signal local_reset_clk200     : std_ulogic;
  signal muxdemux_reset         : std_ulogic;
  signal muxdemux_async_rst     : std_ulogic;
  signal muxdemux_rst_r         : std_ulogic_vector(1 downto 0);

  -- clk0 events
  signal clk0_event_id          : std_ulogic_vector(7 downto 0);
  signal clk0_event_en          : std_ulogic;
  signal clk0_event_strobe1     : std_ulogic;
  signal clk0_event_strobe2     : std_ulogic;
  signal mmi64_reset            : std_Ulogic;  --  MMI-64 reset is identical to clk0_event_reset

  signal phy2buf_dn_d         : mmi64_data_t;
  signal phy2buf_dn_valid     : std_ulogic;
  signal phy2buf_dn_accept    : std_ulogic;
  signal phy2buf_dn_start     : std_ulogic;
  signal phy2buf_dn_stop      : std_ulogic;
  signal phy2buf_up_d         : mmi64_data_t;
  signal phy2buf_up_valid     : std_ulogic;
  signal phy2buf_up_accept    : std_ulogic;
  signal phy2buf_up_start     : std_ulogic;
  signal phy2buf_up_stop      : std_ulogic;

  signal buf2router_dn_d      : mmi64_data_t;
  signal buf2router_dn_valid  : std_ulogic;
  signal buf2router_dn_accept : std_ulogic;
  signal buf2router_dn_start  : std_ulogic;
  signal buf2router_dn_stop   : std_ulogic;
  signal buf2router_up_d      : mmi64_data_t;
  signal buf2router_up_valid  : std_ulogic;
  signal buf2router_up_accept : std_ulogic;
  signal buf2router_up_start  : std_ulogic;
  signal buf2router_up_stop   : std_ulogic;

  signal module_up_d          : mmi64_data_vector_t(0 to MMI64_MODULES-1);
  signal module_up_valid      : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_up_accept     : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_up_start      : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_up_stop       : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_dn_d          : mmi64_data_vector_t(0 to MMI64_MODULES-1);
  signal module_dn_valid      : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_dn_accept     : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_dn_start      : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_dn_stop       : std_ulogic_vector(0 to MMI64_MODULES-1);
  signal module_present       : std_ulogic_vector(0 to MMI64_MODULES-1);
  
  signal devzero_up_d      : mmi64_data_t;
  signal devzero_up_valid  : std_ulogic;
  signal devzero_up_accept : std_ulogic;
  signal devzero_up_start  : std_ulogic;
  signal devzero_up_stop   : std_ulogic;
  
  signal devzero_dn_d      : mmi64_data_t;
  signal devzero_dn_valid  : std_ulogic;
  signal devzero_dn_accept : std_ulogic;
  signal devzero_dn_start  : std_ulogic;
  signal devzero_dn_stop   : std_ulogic;


  -- configuration interface
  signal reg_en           : std_ulogic;
  signal reg_we           : std_ulogic;
  signal reg_addr         : std_ulogic_vector(log2(CONFIG_REGISTERS)-1 downto 0);
  signal reg_wdata        : std_ulogic_vector(15 downto 0);
  signal reg_accept       : std_ulogic;
  signal reg_rdata        : std_ulogic_vector(15 downto 0);
  signal reg_rvalid       : std_ulogic;

  signal cfg_select       : std_ulogic_vector(7 downto 0);
  signal cfgreg_rdata_r   : std_ulogic_vector(15 downto 0);
  signal cfgreg_rvalid_r  : std_ulogic;
  signal cfgreg_accept_r  : std_ulogic;

  -- configuration registers
  signal sync0_delay_r    : std_ulogic_vector(5 downto 0);
  signal srcclk_present_r : std_ulogic_vector(3 downto 0);
  signal clk_cfg_r        : std_ulogic_vector(15 downto 0);
  
  signal dmbi_h2f_r       : std_ulogic_vector(1 downto 0);
  signal config_rst_r     : std_ulogic;

  -- source sync command
  type sync_cmd_t is record
    event_id    : std_ulogic_vector(7 downto 0);
    event_en    : std_ulogic;
    event_pause : std_ulogic_vector(15 downto 0);
  end record;
  type sync_cmd_vector is array(natural range <>) of sync_cmd_t;

  constant SYNC_CMD_INIT : sync_cmd_t := (
    event_id    => x"00",
    event_en    => '0',
    event_pause => x"0000" );

  -- SYNC handshake over clock domains:
  --     1. srcsync_cmd_r(i).event_en     <= '1';
  --     2. srcsync_event_en_META_rEXT(i) <= '1';
  --     3. srcsync_cmd_rEXT(i).event_en  <= '1';
  --     4. srcsync_event_done_rEXT(i)    <= '1'; --> after srcsync_event_busy_EXT(i)='0'
  --        srcsync_cmd_rEXT(i).event_en  <= '0';
  --     5. srcsync_event_done_r(i)       <= '1';
  --     6. srcsync_cmd_r(i).event_en     <= '0';
  --     7. srcsync_event_en_META_rEXT(i) <= '0';
  --     8. srcsync_event_done_rEXT(i)    <= '0';
  --     9. srcsync_event_done_r(i)       <= '0';
  --  not accepting REGIF command while sync_cmd_r(i).event_en='1' or sync_event_done_r(i)='1'

  signal srcsync_cmd_r          : sync_cmd_vector(3 downto 0);  -- MMI64 clock domain
  signal srcsync_cmd_rEXT       : sync_cmd_vector(3 downto 0);  -- external SRCCLK domain

  signal srcsync_reset_EXT          : std_ulogic_vector(3 downto 0);
  signal srcsync_reset_meta_EXT     : std_ulogic_vector(3 downto 0);
  signal srcsync_event_en_META_rEXT : std_ulogic_vector(3 downto 0);  -- handshake MMI64->SRCCLK (1 cycle slower than command)
  signal srcsync_event_done_rEXT    : std_ulogic_vector(3 downto 0);  -- handshake SRCCLK->MMI64
  signal srcsync_event_done_r       : std_ulogic_vector(3 downto 0);  -- handshake SRCCLK->MMI64

  signal srcsync_event_busy_EXT     : std_ulogic_vector(3 downto 0);
  signal srcsync_event_en_EXT       : std_ulogic_vector(3 downto 0);
  signal srcsync_event_id_EXT       : sync_event_vector(3 downto 0);

  signal srcclk_pad                 : std_ulogic_vector(3 downto 0);
  signal srcclk_locked_r            : std_ulogic_vector(3 downto 0);

  -- ignore clock domain transitions for quasi-static signals
  attribute TIG : string;
  attribute TIG of srcclk_present_r : signal is "TRUE";
  attribute TIG of clk_cfg_r : signal is "TRUE";

  
--  -- the following signals are required for automatic core insertion
  attribute MARK_DEBUG : string;
  -- This causes synthesis failure: attribute MARK_DEBUG of clk_200mhz        : signal is "TRUE";
  -- This causes synthesis warnings: attribute MARK_DEBUG of mmi64_clk         : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of mmi64_reset       : signal is ENABLE_DEBUG;
  
  attribute MARK_DEBUG of devzero_up_d      : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_up_valid  : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_up_accept : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_up_start  : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_up_stop   : signal is ENABLE_DEBUG;
  
  attribute MARK_DEBUG of devzero_dn_d      : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_dn_valid  : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_dn_accept : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_dn_start  : signal is ENABLE_DEBUG;
  attribute MARK_DEBUG of devzero_dn_stop   : signal is ENABLE_DEBUG;

  
begin

  -- convert clk0 from LVDS to logic
  CLK0_PAD_I : IBUFGDS
  generic map (
    DIFF_TERM => true,
    IBUF_LOW_PWR => false,
    IOSTANDARD => "DEFAULT"
  ) port map (
    i=>clk0_p,
    ib=>clk0_n,
    o=>clk0_pad
  );

  BUFR_inst : BUFR port map (I => clk0_pad, O => clk0_pad_srl, CE => '1', CLR => '0');

  -- generate PLL reset signal
  srlc32_pll_reset_inst : SRLC32E
  generic map (
    INIT => x"FFFF0000"
  ) port map(
    D   => '0',
    Q   => open,
    Q31 => clk0_pll_rst,
    A   => "11111",
    CE  => '1',
    CLK => clk0_pad_srl
  );

G_XILINX_7_SERIES_PLL: if DEVICE ="XV7S" generate
  -- derive MMI-64 clock
  CLK0_PLL : PLLE2_ADV
  generic map (
    COMPENSATION      => "ZHOLD",
    BANDWIDTH         => "OPTIMIZED",
    CLKFBOUT_MULT     => integer(1.2*real(CLK0_PERIOD_NS)),  -- 1.2 GHz
    CLKFBOUT_PHASE    => 0.0,
    CLKIN1_PERIOD     => real(CLK0_PERIOD_NS),
    CLKOUT0_DIVIDE    => 6,                     -- 200 MHz
    CLKOUT1_DIVIDE    => 24,                    -- 50 MHz
    CLKOUT2_DIVIDE    => 6,                     -- 200 MHz
    CLKOUT3_DIVIDE    => integer(1.2*real(CLK0_PERIOD_NS)),  -- original clock 0
    DIVCLK_DIVIDE     => 1,
    REF_JITTER1       => 0.010,
    STARTUP_WAIT      => "FALSE"
  ) port map (
    CLKIN1   => clk0_pad,
    CLKIN2   => '0',
    CLKINSEL => '1',
    CLKFBOUT => clk0_pll_fbout,
    CLKOUT0  => clk0_pll_clk_dmbi_x4,
    CLKOUT1  => clk0_pll_clk_dmbi,
    CLKOUT2  => clk0_pll_clk_200mhz,
    CLKOUT3  => clk0_pll_clk_mmi64,
    LOCKED   => clk0_pll_locked,
    CLKFBIN  => clk0_pll_fbin,
    PWRDWN   => '0',
    RST      => clk0_pll_rst,
    DADDR    => (others=>'0'),
    DCLK     => '0',
    DEN      => '0',
    DI       => (others=>'0'),
    DWE      => '0'
  );

  -- provide global clock buffers
  BUF_MMI64_CLK :    BUFG port map ( i=>clk0_pll_clk_mmi64, o=>mmi64_clk     );
  BUF_DMBI_CLK :     BUFG port map ( i=>clk0_pll_clk_dmbi, o=>dmbi_clk       );
  BUF_DMBI_CLK_X4 :  BUFG port map ( i=>clk0_pll_clk_dmbi_x4, o=>dmbi_clk_x4 );
  BUF_CLK_200MHZ :   BUFG port map ( i=>clk0_pll_clk_200mhz, o=>clk_200mhz    );
end generate G_XILINX_7_SERIES_PLL;

G_XILINX_ULTRA_SCALE_PLL: if DEVICE = "XVUS" generate
  CLK0_PLL : PLLE3_ADV
  generic map(
    CLKFBOUT_MULT  => 12                   , -- 600 MHz
    CLKFBOUT_PHASE => 0.0                 ,
    CLKIN_PERIOD   => real(CLK0_PERIOD_NS),
    CLKOUT0_DIVIDE => 6                   , -- 200 MHz
    CLKOUT1_DIVIDE => 24                  , -- 50 MHz
    REF_JITTER     => 0.010               
  ) port map  (
    CLKIN          => clk0_pad             ,
    CLKFBOUT       => clk0_pll_fbout       ,
    CLKOUT0        => clk0_pll_clk_dmbi_x4 ,
    CLKOUT0B       => open                 ,
    CLKOUT1        => clk0_pll_clk_dmbi    ,
    CLKOUT1B       => open                 ,
    CLKOUTPHYEN    => '0'                  ,
    CLKOUTPHY      => open                 ,
    LOCKED         => clk0_pll_locked      ,
    CLKFBIN        => clk0_pll_fbin        ,
    PWRDWN         => '0'                  ,
    RST            => clk0_pll_rst         ,
    DADDR          => (others=>'0')        ,
    DCLK           => '0'                  ,
    DI             => (others=>'0')        ,
    DO             => open                 ,
    DRDY           => open                 ,
    DEN            => '0'                  ,
    DWE            => '0'
  );
  BUF_DMBI_CLK    :  BUFG port map ( i=>clk0_pll_clk_dmbi,    o=>dmbi_clk     );
  BUF_DMBI_CLK_X4 :  BUFG port map ( i=>clk0_pll_clk_dmbi_x4, o=>dmbi_clk_x4  );
  
  BUF_MMI64_CLK : BUFGCE_DIV
  generic map(
    BUFGCE_DIVIDE => 2
  ) port map ( 
    CLR           => '0' ,
    CE            => '1' ,
    I             => clk0_pll_clk_dmbi_x4 ,
    O             => mmi64_clk  
  );
  clk_200mhz    <= dmbi_clk_x4;

end generate G_XILINX_ULTRA_SCALE_PLL;

  -- use compensated feedback path
  BUF_CLK0_PLL_FB :  BUFG port map ( i=>clk0_pll_fbout, o=>clk0_pll_fbin     );
  --clk0_pll_fbin <= clk0_pll_fbout ;
 
  -- assign clock outputs
  mmi64_clk_o <= mmi64_clk; -- Note: This adds a simulation delta cycle. All related outputs will also be delayed by 1 delta cycle.
  clk_200mhz_o <= clk_200mhz;

  -- generate local reset (16 cycles after clk0 PLL has locked)
  local_rst_r <= (others=>'1') when clk0_pll_locked='0'
                 else shift_right(local_rst_r, 1) when rising_edge(mmi64_clk);
  local_reset <= local_rst_r(0);
  P_LOCAL_RESET_CLK200: process (clk_200mhz)
  begin
    if rising_edge(clk_200mhz) then
      local_reset_clk200 <= local_reset;
    end if;
  end process P_LOCAL_RESET_CLK200;
  
  -- Enable communication to MB
  CTRL_ENABLE_FF : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      dmbi_h2f_r <= dmbi_h2f(19 downto 18);
      if dmbi_h2f_r = "10" then
        config_rst_r <= '0';
      else
        config_rst_r <= '1';
      end if;
    end if;
  end process CTRL_ENABLE_FF;
  
  -- keep muxdemux in reset while motherboard is not ready yet
  muxdemux_async_rst <= '1' when (local_reset='1') or (config_rst_r='1') else '0';
  muxdemux_rst_r <= (others => '1') when muxdemux_async_rst='1'
                  else '0' & muxdemux_rst_r(muxdemux_rst_r'high downto 1) when rising_edge(dmbi_clk);
                  
  muxdemux_reset <= muxdemux_rst_r(0);

  -- clk0 event receiver
  SYNC : profpga_sync_rx2
  generic map (
    CLK_CORE_COMPENSATION => CLK0_CORE_COMPENSATION
  ) port map (
    clk_pad         => clk0_pad_srl,
    clk_core        => mmi64_clk,
    rst             => local_reset,
    sync_p_i        => sync0_p,
    sync_n_i        => sync0_n,
    sync_delay_i    => sync0_delay_r,

    user_reset_o    => mmi64_reset,
    user_strobe1_o  => clk0_event_strobe1,
    user_strobe2_o  => clk0_event_strobe2,
    event_id_o      => clk0_event_id,
    event_en_o      => clk0_event_en
  );

  -- Note: This assignment is needed to compensate the delta-delay of mmi64_clk_o.
  clk0_event_id_o      <= clk0_event_id;
  clk0_event_en_o      <= clk0_event_en;
  clk0_event_strobe1_o <= clk0_event_strobe1;
  clk0_event_strobe2_o <= clk0_event_strobe2;
  mmi64_reset_o        <= mmi64_reset;


  -- declare this UserFPGA as present after PLL has locked
  dmbi_f2h(19 downto 18) <= "1" & local_reset;

  -- add IDELAYCTRL for MMI64_P_MUXDEMUX
  G_XILINX_7_SERIES_IDELAYCTRL: if DEVICE /="XVUS" generate
    IDEALAYCTRL_INST : IDELAYCTRL
    port map (
      refclk=> clk_200mhz,
      rst   => local_reset_clk200,
      rdy   => open
    );
  end generate G_XILINX_7_SERIES_IDELAYCTRL;
  G_XILINX_ULTRA_SCALE_IDELAYCTRL: if DEVICE ="XVUS" generate
    IDEALAYCTRL_INST : IDELAYCTRL
    generic map (
      SIM_DEVICE => "ULTRASCALE"
    )
    port map (
      refclk=> clk_200mhz,
      rst   => local_reset_clk200,
      rdy   => open
    );
  end generate G_XILINX_ULTRA_SCALE_IDELAYCTRL;

  -- MMI-64 PHY to motherboard
  PHY : mmi64_p_muxdemux
  generic map (
    DEVICE             => DEVICE,
    PIN_TRAINING_SPEED => PIN_TRAINING_SPEED
  ) port map (
    -- SERDES high-speed side
    pad_hs_clk          => dmbi_clk_x4,
    pad_data_o          => dmbi_f2h(17 downto 0),
    pad_data_i          => dmbi_h2f(17 downto 0),
    -- SERDES low-speed side
    pad_dv_clk          => dmbi_clk,
    pad_dv_reset        => muxdemux_reset,
    rt_crc_errors_o     => rt_crc_errors_o,
    rt_ack_errors_o     => rt_ack_errors_o,
    rt_id_errors_o      => rt_id_errors_o,
    rt_id_warnings_o    => rt_id_warnings_o,

    --! MUXDEMUX status
    muxdemux_status_o   => muxdemux_status_o,
    muxdemux_mode_o     => muxdemux_mode_o(8 downto 0),
     -- MMI64 connections
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => phy2buf_dn_d,
    mmi64_m_dn_valid_o  => phy2buf_dn_valid,
    mmi64_m_dn_accept_i => phy2buf_dn_accept,
    mmi64_m_dn_start_o  => phy2buf_dn_start,
    mmi64_m_dn_stop_o   => phy2buf_dn_stop,
    mmi64_m_up_d_i      => phy2buf_up_d,
    mmi64_m_up_valid_i  => phy2buf_up_valid,
    mmi64_m_up_accept_o => phy2buf_up_accept,
    mmi64_m_up_start_i  => phy2buf_up_start,
    mmi64_m_up_stop_i   => phy2buf_up_stop
  );
  muxdemux_mode_o(9) <= muxdemux_reset;
  muxdemux_mode_o(15 downto 10) <= (others=>'0');

  -- ease synthesis timing issues
  PHYBUF : mmi64_buffer
  port map (
    -- clock and reset
    mmi64_clk   => mmi64_clk,
    mmi64_reset => mmi64_reset,

    -- mmi64 buffer connections towards host (root)
    mmi64_h_up_d_o      => phy2buf_up_d,
    mmi64_h_up_valid_o  => phy2buf_up_valid,
    mmi64_h_up_accept_i => phy2buf_up_accept,
    mmi64_h_up_start_o  => phy2buf_up_start,
    mmi64_h_up_stop_o   => phy2buf_up_stop,
    mmi64_h_dn_d_i      => phy2buf_dn_d,
    mmi64_h_dn_valid_i  => phy2buf_dn_valid,
    mmi64_h_dn_accept_o => phy2buf_dn_accept,
    mmi64_h_dn_start_i  => phy2buf_dn_start,
    mmi64_h_dn_stop_i   => phy2buf_dn_stop,

    -- mmi64 buffer connections towards modules (leaves)
    mmi64_m_up_d_i      => buf2router_up_d,
    mmi64_m_up_valid_i  => buf2router_up_valid,
    mmi64_m_up_accept_o => buf2router_up_accept,
    mmi64_m_up_start_i  => buf2router_up_start,
    mmi64_m_up_stop_i   => buf2router_up_stop,
    mmi64_m_dn_d_o      => buf2router_dn_d,
    mmi64_m_dn_valid_o  => buf2router_dn_valid,
    mmi64_m_dn_accept_i => buf2router_dn_accept,
    mmi64_m_dn_start_o  => buf2router_dn_start,
    mmi64_m_dn_stop_o   => buf2router_dn_stop
  );

  -- MMI-64 router for configuration access
  ROUTER : mmi64_router
  generic map (
    MODULE_ID  => X"800001FF",
    PORT_COUNT => MMI64_MODULES
  ) port map (
    -- clock and reset
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_initialize_o  => open,

    -- connections to mmi64 phy or upstream router
    mmi64_h_up_d_o      => buf2router_up_d,
    mmi64_h_up_valid_o  => buf2router_up_valid,
    mmi64_h_up_accept_i => buf2router_up_accept,
    mmi64_h_up_start_o  => buf2router_up_start,
    mmi64_h_up_stop_o   => buf2router_up_stop,
    mmi64_h_dn_d_i      => buf2router_dn_d,
    mmi64_h_dn_valid_i  => buf2router_dn_valid,
    mmi64_h_dn_accept_o => buf2router_dn_accept,
    mmi64_h_dn_start_i  => buf2router_dn_start,
    mmi64_h_dn_stop_i   => buf2router_dn_stop,

    -- connections to mmi64 modules or downstream router
    mmi64_m_up_d_i      => module_up_d,
    mmi64_m_up_valid_i  => module_up_valid,
    mmi64_m_up_accept_o => module_up_accept,
    mmi64_m_up_start_i  => module_up_start,
    mmi64_m_up_stop_i   => module_up_stop,
    mmi64_m_dn_d_o      => module_dn_d,
    mmi64_m_dn_valid_o  => module_dn_valid,
    mmi64_m_dn_accept_i => module_dn_accept,
    mmi64_m_dn_start_o  => module_dn_start,
    mmi64_m_dn_stop_o   => module_dn_stop,

    -- module presence detection
    module_presence_detection_i => module_present
  );
  module_present(MMI64_M_CONFIG) <= '1';              -- always present
  module_present(MMI64_M_TEST)   <= '1';              -- always present
  module_present(MMI64_M_USER)   <= mmi64_present_i;  -- presence depends on user settings

  -- Note: This assignment adds one delta-cycle to compensate for assignment to mmi64_clk_o
  mmi64_m_dn_d_o      <= module_dn_d     (MMI64_M_USER);
  mmi64_m_dn_valid_o  <= module_dn_valid (MMI64_M_USER);
  mmi64_m_dn_start_o  <= module_dn_start (MMI64_M_USER);
  mmi64_m_dn_stop_o   <= module_dn_stop  (MMI64_M_USER);
  mmi64_m_up_accept_o <= module_up_accept(MMI64_M_USER);

  module_dn_accept(MMI64_M_USER) <= mmi64_m_dn_accept_i;
  module_up_d     (MMI64_M_USER) <= mmi64_m_up_d_i;
  module_up_valid (MMI64_M_USER) <= mmi64_m_up_valid_i;
  module_up_start (MMI64_M_USER) <= mmi64_m_up_start_i;
  module_up_stop  (MMI64_M_USER) <= mmi64_m_up_stop_i;

  -- control register interface
  REGIF : mmi64_m_regif
  generic map (
    MODULE_ID         => X"80000101",
    REGISTER_COUNT    => CONFIG_REGISTERS,
    REGISTER_WIDTH    => 16,
    READ_BUFFER_DEPTH => 1
  ) port map (
    -- clock and reset
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,

    -- connections to mmi64 router
    mmi64_h_dn_d_i      => module_dn_d     (MMI64_M_CONFIG),
    mmi64_h_dn_valid_i  => module_dn_valid (MMI64_M_CONFIG),
    mmi64_h_dn_accept_o => module_dn_accept(MMI64_M_CONFIG),
    mmi64_h_dn_start_i  => module_dn_start (MMI64_M_CONFIG),
    mmi64_h_dn_stop_i   => module_dn_stop  (MMI64_M_CONFIG),
    mmi64_h_up_d_o      => module_up_d     (MMI64_M_CONFIG),
    mmi64_h_up_valid_o  => module_up_valid (MMI64_M_CONFIG),
    mmi64_h_up_accept_i => module_up_accept(MMI64_M_CONFIG),
    mmi64_h_up_start_o  => module_up_start (MMI64_M_CONFIG),
    mmi64_h_up_stop_o   => module_up_stop  (MMI64_M_CONFIG),

    -- connections to register interface
    reg_en_o            => reg_en,
    reg_we_o            => reg_we,
    reg_addr_o          => reg_addr,
    reg_wdata_o         => reg_wdata,
    reg_accept_i        => reg_accept,
    reg_rdata_i         => reg_rdata,
    reg_rvalid_i        => reg_rvalid
  );

  -- test pattern interface
  DEVZERO : mmi64_m_devzero 
  generic map (
    MODULE_ID => X"80000102"
  ) port map (
    -- clock and reset
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,

    -- connections to mmi64 router
    mmi64_h_dn_d_i      => devzero_dn_d,
    mmi64_h_dn_valid_i  => devzero_dn_valid,
    mmi64_h_dn_accept_o => devzero_dn_accept,
    mmi64_h_dn_start_i  => devzero_dn_start,
    mmi64_h_dn_stop_i   => devzero_dn_stop,
    mmi64_h_up_d_o      => devzero_up_d,
    mmi64_h_up_valid_o  => devzero_up_valid,
    mmi64_h_up_accept_i => devzero_up_accept,
    mmi64_h_up_start_o  => devzero_up_start,
    mmi64_h_up_stop_o   => devzero_up_stop
  );

  devzero_dn_d      <= module_dn_d     (MMI64_M_TEST);
  devzero_dn_valid  <= module_dn_valid (MMI64_M_TEST);
  module_dn_accept(MMI64_M_TEST) <= devzero_dn_accept;
  devzero_dn_start  <= module_dn_start (MMI64_M_TEST);
  devzero_dn_stop   <= module_dn_stop  (MMI64_M_TEST);
  module_up_d     (MMI64_M_TEST) <= devzero_up_d ;
  module_up_valid (MMI64_M_TEST) <= devzero_up_valid ;
  devzero_up_accept <= module_up_accept(MMI64_M_TEST);
  module_up_start (MMI64_M_TEST) <= devzero_up_start ;
  module_up_stop  (MMI64_M_TEST) <= devzero_up_stop ;

  -- decode who is addressed
  REG_ADDR_DECODE : process(reg_addr, reg_en)
  begin
    cfg_select <= (others=>'0');
    if reg_en='1' then
      -- decode local configuration register access
      if unsigned(reg_addr)<=REGID_SYNC0_DELAY or unsigned(reg_addr)>=REGID_SRCSYNC0_CFG then
        cfg_select(0) <= '1';
      end if;

      -- decode clock configuration register access
      for i in 1 to 7 loop
        if unsigned(reg_addr(reg_addr'high downto 2))=i then
          cfg_select(i) <= '1';
        end if;
      end loop;
    end if;
  end process REG_ADDR_DECODE;

  -- check if addressed component accepts REGIF command
  reg_accept <= (cfg_select(0) and cfgreg_accept_r)
             or (cfg_select(1) and clk1_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(2) and clk2_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(3) and clk3_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(4) and clk4_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(5) and clk5_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(6) and clk6_cfg_up_i(IDX_UP_ACCEPT))
             or (cfg_select(7) and clk7_cfg_up_i(IDX_UP_ACCEPT));

  -- multiplex read responses
  -- Note: There is only 1 outstanding read operation. So we don't need to care about multiple responses.
  reg_rvalid <= cfgreg_rvalid_r
             or clk1_cfg_up_i(IDX_UP_RVALID)
             or clk2_cfg_up_i(IDX_UP_RVALID)
             or clk3_cfg_up_i(IDX_UP_RVALID)
             or clk4_cfg_up_i(IDX_UP_RVALID)
             or clk5_cfg_up_i(IDX_UP_RVALID)
             or clk6_cfg_up_i(IDX_UP_RVALID)
             or clk7_cfg_up_i(IDX_UP_RVALID);

  REG_RDATA_MUX : process(cfgreg_rdata_r, cfgreg_rvalid_r, clk1_cfg_up_i, clk2_cfg_up_i, clk3_cfg_up_i, clk4_cfg_up_i, clk5_cfg_up_i, clk6_cfg_up_i, clk7_cfg_up_i)
  variable rdata_v : std_ulogic_vector(15 downto 0);
  begin
    rdata_v := (others=>'0');

    -- select accept from local config register interface
    if cfgreg_rvalid_r='1'              then rdata_v := rdata_v or cfgreg_rdata_r; end if;
    -- select accepts from clock configuration interfaces
    if clk1_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk1_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk2_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk2_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk3_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk3_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk4_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk4_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk5_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk5_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk6_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk6_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;
    if clk7_cfg_up_i(IDX_UP_RVALID)='1' then rdata_v := rdata_v or clk7_cfg_up_i(IDX_UP_DATA_HI downto IDX_UP_DATA_LO); end if;

    reg_rdata  <= rdata_v;
  end process REG_RDATA_MUX;

  -- assign outputs to clock configuration interfaces
  clk1_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk1_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk1_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(1);
  clk1_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk2_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk2_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk2_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(2);
  clk2_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk3_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk3_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk3_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(3);
  clk3_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk4_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk4_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk4_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(4);
  clk4_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk5_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk5_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk5_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(5);
  clk5_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk6_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk6_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk6_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(6);
  clk6_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  clk7_cfg_dn_o(IDX_DN_DATA_HI downto IDX_DN_DATA_LO) <= reg_wdata;
  clk7_cfg_dn_o(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO) <= reg_addr(1 downto 0);
  clk7_cfg_dn_o(IDX_DN_EN)                            <= cfg_select(7);
  clk7_cfg_dn_o(IDX_DN_WE)                            <= reg_we;

  -- control registers
  CTRL_FF : process (mmi64_clk, mmi64_reset)
    variable addr_v   : integer range 0 to 2**reg_addr'length - 1;
    variable rdata_v  : std_ulogic_vector(15 downto 0);
  begin
    if mmi64_reset='1' then
      sync0_delay_r   <= (others=>'0');
      srcclk_present_r<= (others=>'0');
      clk_cfg_r       <= (others=>'0');

      cfgreg_rdata_r  <= (others=>'0');
      cfgreg_rvalid_r <= '0';
      cfgreg_accept_r <= '0';

      srcsync_cmd_r   <= (others=>SYNC_CMD_INIT);
      srcsync_event_done_r <= (others=>'0');
    elsif rising_edge(mmi64_clk) then
      srcclk_present_r <= src_clk_locked_i;

      -- SYNC handshake over clock domains: phase 5 and 9
      srcsync_event_done_r <= srcsync_event_done_rEXT;

      -- SYNC handshake over clock domains: phase 6
      for i in 0 to 3 loop
        if srcsync_event_done_r(i)='1' then
          srcsync_cmd_r(i).event_en <= '0';
        end if;
      end loop;

      -- CLK_CFG[7:1]   clock module present
      clk_cfg_r(0)  <= '1'; -- clock #0 is always present
      clk_cfg_r(1)  <= clk1_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(2)  <= clk2_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(3)  <= clk3_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(4)  <= clk4_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(5)  <= clk5_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(6)  <= clk6_cfg_up_i(IDX_UP_PRESENT);
      clk_cfg_r(7)  <= clk7_cfg_up_i(IDX_UP_PRESENT);

      -- CLK_CFG[15:8]  clock module type
      clk_cfg_r(8)  <= '0';  -- clock #0 doesn't support ACM
      clk_cfg_r(9)  <= clk1_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(10) <= clk2_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(11) <= clk3_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(12) <= clk4_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(13) <= clk5_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(14) <= clk6_cfg_up_i(IDX_UP_IS_ACM);
      clk_cfg_r(15) <= clk7_cfg_up_i(IDX_UP_IS_ACM);

      -- do not accept configuration commands while any of the SRCSYNC generators is busy
      cfgreg_accept_r <= '1';
      for i in 0 to 3 loop
        if srcsync_cmd_r(i).event_en='1' or srcsync_event_done_r(i)='1' then
          cfgreg_accept_r <= '0';
        end if;
      end loop;
      cfgreg_rvalid_r <= '0';
      rdata_v := (others=>'0');

      -- control register access
      if reg_en='1' and cfgreg_accept_r='1' then  -- only evaluate REGIF command when it was accepted
        addr_v := to_integer(unsigned(reg_addr));

        if reg_we='1' then  -- === write operation

          case addr_v is
            when REGID_SYNC0_DELAY    => sync0_delay_r <= reg_wdata(sync0_delay_r'range);

            when REGID_SRCSYNC0_CFG   => srcsync_cmd_r(0).event_pause <= reg_wdata;
            when REGID_SRCSYNC1_CFG   => srcsync_cmd_r(1).event_pause <= reg_wdata;
            when REGID_SRCSYNC2_CFG   => srcsync_cmd_r(2).event_pause <= reg_wdata;
            when REGID_SRCSYNC3_CFG   => srcsync_cmd_r(3).event_pause <= reg_wdata;

            -- SYNC handshake over clock domains: phase 1
            when REGID_SRCSYNC0_EVENT => srcsync_cmd_r(0).event_id <= reg_wdata(7 downto 0);
                                         srcsync_cmd_r(0).event_en <= '1';
                                         cfgreg_accept_r <= '0';
            when REGID_SRCSYNC1_EVENT => srcsync_cmd_r(1).event_id <= reg_wdata(7 downto 0);
                                         srcsync_cmd_r(1).event_en <= '1';
                                         cfgreg_accept_r <= '0';
            when REGID_SRCSYNC2_EVENT => srcsync_cmd_r(2).event_id <= reg_wdata(7 downto 0);
                                         srcsync_cmd_r(2).event_en <= '1';
                                         cfgreg_accept_r <= '0';
            when REGID_SRCSYNC3_EVENT => srcsync_cmd_r(3).event_id <= reg_wdata(7 downto 0);
                                         srcsync_cmd_r(3).event_en <= '1';
                                         cfgreg_accept_r <= '0';
            when others => null; -- remaining registers are not writable
          end case;

        else              -- === read operation

          case addr_v is
            when REGID_REVISION       => rdata_v             := rdata_v             or std_ulogic_vector(to_unsigned(HDL_REVISION, 16));
            when REGID_CLK_CFG        => rdata_v             := rdata_v             or clk_cfg_r;
            when REGID_SRCCLK_PRESENT => rdata_v(3 downto 0) := rdata_v(3 downto 0) or srcclk_present_r;
            when REGID_SYNC0_DELAY    => rdata_v(5 downto 0) := rdata_v(5 downto 0) or sync0_delay_r;
            when REGID_SRCSYNC0_CFG   => rdata_v             := rdata_v             or srcsync_cmd_r(0).event_pause;
            when REGID_SRCSYNC0_EVENT => rdata_v(7 downto 0) := rdata_v(7 downto 0) or srcsync_cmd_r(0).event_id;
            when REGID_SRCSYNC1_CFG   => rdata_v             := rdata_v             or srcsync_cmd_r(1).event_pause;
            when REGID_SRCSYNC1_EVENT => rdata_v(7 downto 0) := rdata_v(7 downto 0) or srcsync_cmd_r(1).event_id;
            when REGID_SRCSYNC2_CFG   => rdata_v             := rdata_v             or srcsync_cmd_r(2).event_pause;
            when REGID_SRCSYNC2_EVENT => rdata_v(7 downto 0) := rdata_v(7 downto 0) or srcsync_cmd_r(2).event_id;
            when REGID_SRCSYNC3_CFG   => rdata_v             := rdata_v             or srcsync_cmd_r(3).event_pause;
            when REGID_SRCSYNC3_EVENT => rdata_v(7 downto 0) := rdata_v(7 downto 0) or srcsync_cmd_r(3).event_id;
            when others => null;
          end case;

          cfgreg_rvalid_r <= cfg_select(0); -- return something (at least 0) if local config was selected
        end if;
      end if;

      cfgreg_rdata_r <= rdata_v;

    end if;
  end process CTRL_FF;

  SRCSYNC_GEN : for srcclk in 0 to 3 generate
    SRCSYNC_FF : process(src_clk_i, srcsync_reset_EXT)
    begin
      if srcsync_reset_EXT(srcclk)='1' then
        srcsync_event_en_META_rEXT(srcclk) <= '0';
        srcsync_cmd_rEXT          (srcclk) <= SYNC_CMD_INIT;
        srcsync_event_done_rEXT   (srcclk) <= '0';
      elsif rising_edge(src_clk_i(srcclk)) then


        -- copy EVENT_PAUSE setting to SRCCLK domain
        srcsync_cmd_rEXT(srcclk).event_pause <= srcsync_cmd_r(srcclk).event_pause; -- no extra guard mechanism required (SYNC events will not be sent during reconfiguration)

        -- SYNC handshake over clock domains: phase 2 and 7
        srcsync_event_en_META_rEXT(srcclk) <= srcsync_cmd_r(srcclk).event_en;

        -- SYNC handshake over clock domains: phase 3
        if srcsync_cmd_rEXT(srcclk).event_en='0' and srcsync_event_busy_EXT(srcclk)='0' then
          srcsync_cmd_rEXT(srcclk).event_en <= srcsync_event_en_META_rEXT(srcclk);
          srcsync_cmd_rEXT(srcclk).event_id <= srcsync_cmd_r(srcclk).event_id;
        end if;

        -- SYNC handshake over clock domains: phase 4
        if srcsync_cmd_rEXT(srcclk).event_en='1'  -- phase 4 applies
        and srcsync_event_busy_EXT(srcclk)='0'    -- SYNC_TX is not busy
        and src_event_en_i(srcclk)='0'            -- user logic doesn't generate its own event
        then
          srcsync_cmd_rEXT(srcclk).event_en <= '0';
          srcsync_event_done_rEXT(srcclk) <= '1';
        end if;

        -- SYNC handshake over clock domains: phase 8
        if srcsync_event_en_META_rEXT(srcclk)='0' then
          srcsync_event_done_rEXT(srcclk) <= '0';
        end if;
      end if;
    end process SRCSYNC_FF;

    -- reset SRCSYNC_TX while clock has not locked
    RESET_EXT : process(src_clk_locked_i, local_reset, src_clk_i)
    begin
      if src_clk_locked_i(srcclk)='0' or local_reset='1' then
        srcsync_reset_EXT(srcclk) <= '1';
        srcsync_reset_meta_EXT(srcclk) <= '1';
      elsif rising_edge(src_clk_i(srcclk)) then
        srcsync_reset_meta_EXT(srcclk) <= '0';
        srcsync_reset_EXT(srcclk) <= srcsync_reset_meta_EXT(srcclk);
      end if;
    end process RESET_EXT;
 
    -- generate events from external input (hardware)  or config register (software)
    srcsync_event_en_EXT(srcclk) <= src_event_en_i(srcclk) or srcsync_cmd_rEXT(srcclk).event_en;
    srcsync_event_id_EXT(srcclk) <= src_event_id_i(srcclk) when src_event_en_i(srcclk)='1'  -- high prio: hardware events
                               else srcsync_cmd_rEXT(srcclk).event_id;                      -- low prio: software events

    SRCSYNC_TX : profpga_sync_tx
    port map (
      -- sync event interface
      clk             => src_clk_i(srcclk),
      rst             => srcsync_reset_EXT(srcclk),
      event_id_i      => srcsync_event_id_EXT(srcclk),
      event_en_i      => srcsync_event_en_EXT(srcclk),
      event_busy_o    => srcsync_event_busy_EXT(srcclk),

      -- extra wait cycles between 2 sync events (needed when recipent derives very slow clock)
      event_pause_i   => srcsync_cmd_rEXT(srcclk).event_pause,

      -- automatic sync events
      user_reset_i    => src_event_reset_i(srcclk),
      user_strobe1_i  => src_event_strobe1_i(srcclk),
      user_strobe2_i  => src_event_strobe2_i(srcclk),

      -- sync output
      sync_p_o        => srcsync_p(srcclk),
      sync_n_o        => srcsync_n(srcclk)
    );

    src_event_busy_o(srcclk) <= srcsync_event_busy_EXT(srcclk);
    
    -- Timimg optimization for high-frequency source clocks (>250 MHZ)
    srcclk_locked_r(srcclk) <= src_clk_locked_i(srcclk) when rising_edge(src_clk_i(srcclk));
    G_XILINX_7_SERIES_ODDR: if DEVICE = "XV7S" generate
      -- srcclk output to motherboard
      SRCCLK_ODDR :  ODDR generic map (
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT         => '0',
        SRTYPE       => "ASYNC"
      ) port map (
        d1 => srcclk_locked_r(srcclk),
        d2 => '0',
        c  => src_clk_i(srcclk),
        ce => '1',
        r  => '0',
        q  => srcclk_pad(srcclk)
      );
    end generate G_XILINX_7_SERIES_ODDR;
    
    G_XILINX_ULTRA_SCALE_ODDR: if DEVICE ="XVUS" generate
      -- srcclk output to motherboard
      SRCCLK_ODDR   : ODDRE1
      generic map(
        IS_C_INVERTED  => '0',
        IS_D1_INVERTED => '0',
        IS_D2_INVERTED => '0',
        SRVAL          => '0'
      ) port map (
        D1             => srcclk_locked_r(srcclk),
        D2             => '0',
        C              => src_clk_i(srcclk),
        SR             => '0',
        Q              => srcclk_pad(srcclk)     
      );
    end generate G_XILINX_ULTRA_SCALE_ODDR;

    SRCCLK_OBUFDS : OBUFDS generic map (
      IOSTANDARD => "LVDS"
    ) port map (
      i  => srcclk_pad(srcclk),
      o  => srcclk_p(srcclk),
      ob => srcclk_n(srcclk)
    );

  end generate;

end architecture rtl;


-- port type remapping for Verilog compliance
library ieee;
    use ieee.std_logic_1164.all;
entity profpga_ctrl_v is
  port (
    -- access to FPGA pins
    clk0_p              : in  std_ulogic;
    clk0_n              : in  std_ulogic;
    sync0_p             : in  std_ulogic;
    sync0_n             : in  std_ulogic;
    srcclk_p            : out std_ulogic_vector(3 downto 0);
    srcclk_n            : out std_ulogic_vector(3 downto 0);
    srcsync_p           : out std_ulogic_vector(3 downto 0);
    srcsync_n           : out std_ulogic_vector(3 downto 0);
    dmbi_h2f            : in  std_ulogic_vector(19 downto 0);
    dmbi_f2h            : out std_ulogic_vector(19 downto 0);
    
    -- 200 MHz clock (useful for delay calibration)
    clk_200mhz_o        : out std_ulogic;

    -- source clock/sync input
    src_clk_i           : in  std_ulogic_vector(3 downto 0) := "0000";
    src_clk_locked_i    : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_id_i      : in  std_ulogic_vector(3*8+7 downto 0) := (others=>'0');
    src_event_en_i      : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_busy_o    : out std_ulogic_vector(3 downto 0);
    src_event_reset_i   : in  std_ulogic_vector(3 downto 0) := "1111";
    src_event_strobe1_i : in  std_ulogic_vector(3 downto 0) := "0000";
    src_event_strobe2_i : in  std_ulogic_vector(3 downto 0) := "0000";

    -- clk0 sync events (synchronized with mmi64_clk)
    clk0_event_id_o     : out std_ulogic_vector(7 downto 0);
    clk0_event_en_o     : out std_ulogic;
    clk0_event_strobe1_o: out std_ulogic;
    clk0_event_strobe2_o: out std_ulogic;

    -- MMI-64 access
    mmi64_present_i     : in  std_ulogic := '0';
    mmi64_clk_o         : out std_ulogic;
    mmi64_reset_o       : out std_ulogic;

    mmi64_m_dn_d_o      : out std_ulogic_vector(63 downto 0);
    mmi64_m_dn_valid_o  : out std_ulogic;
    mmi64_m_dn_accept_i : in  std_ulogic := '0';
    mmi64_m_dn_start_o  : out std_ulogic;
    mmi64_m_dn_stop_o   : out std_ulogic;
    mmi64_m_up_d_i      : in  std_ulogic_vector(63 downto 0) := (others=>'0');
    mmi64_m_up_valid_i  : in  std_ulogic := '0';
    mmi64_m_up_accept_o : out std_ulogic;
    mmi64_m_up_start_i  : in  std_ulogic := '0';
    mmi64_m_up_stop_i   : in  std_ulogic := '0';

    -- clock configuration ports
    clk1_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk1_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk2_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk2_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk3_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk3_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk4_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk4_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk5_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk5_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk6_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk6_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0');
    clk7_cfg_dn_o       : out std_ulogic_vector(19 downto 0);
    clk7_cfg_up_i       : in  std_ulogic_vector(19 downto 0) := (others=>'0')
  );
end entity profpga_ctrl_v;


library ieee;
    use ieee.std_logic_1164.all;
library work;
    use work.mmi64_pkg.all;
    use work.profpga_pkg.all;
architecture verilog_remap of profpga_ctrl_v is
  signal src_event_id : sync_event_vector(3 downto 0);
begin
  -- map vector to array
  EVENT_MAP : for i in 0 to 3 generate
    src_event_id(i) <= src_event_id_i(8*i+7 downto 8*i);
  end generate;
  
  U_PROFPGA_CTRL : profpga_ctrl
  port map (
    -- access to FPGA pins
    clk0_p              => clk0_p   ,
    clk0_n              => clk0_n   ,
    sync0_p             => sync0_p  ,
    sync0_n             => sync0_n  ,
    srcclk_p            => srcclk_p ,
    srcclk_n            => srcclk_n ,
    srcsync_p           => srcsync_p,
    srcsync_n           => srcsync_n,
    dmbi_h2f            => dmbi_h2f ,
    dmbi_f2h            => dmbi_f2h ,

    --! MUXDEMUX status
--    rt_crc_errors_o     => open,
--    rt_ack_errors_o     => open,
--    rt_id_errors_o      => open,
--    rt_id_warnings_o    => open,
--    muxdemux_status_o   => open,
--    muxdemux_mode_o     => open,
    
    -- 200 MHz clock (useful for delay calibration)
    clk_200mhz_o        => clk_200mhz_o,

    -- source clock/sync input
    src_clk_i           => src_clk_i,
    src_clk_locked_i    => src_clk_locked_i,
    src_event_id_i      => src_event_id,
    src_event_en_i      => src_event_en_i,
    src_event_busy_o    => src_event_busy_o,
    src_event_reset_i   => src_event_reset_i,
    src_event_strobe1_i => src_event_strobe1_i,
    src_event_strobe2_i => src_event_strobe2_i,

    -- clk0 sync events (synchronized with mmi64_clk)
    clk0_event_id_o     => clk0_event_id_o,     
    clk0_event_en_o     => clk0_event_en_o,     
    clk0_event_strobe1_o=> clk0_event_strobe1_o,
    clk0_event_strobe2_o=> clk0_event_strobe2_o,

    -- MMI-64 access
    mmi64_present_i     => mmi64_present_i ,
    mmi64_clk_o         => mmi64_clk_o     ,
    mmi64_reset_o       => mmi64_reset_o   ,

    mmi64_m_dn_d_o      => mmi64_m_dn_d_o     ,
    mmi64_m_dn_valid_o  => mmi64_m_dn_valid_o ,
    mmi64_m_dn_accept_i => mmi64_m_dn_accept_i,
    mmi64_m_dn_start_o  => mmi64_m_dn_start_o ,
    mmi64_m_dn_stop_o   => mmi64_m_dn_stop_o  ,
    mmi64_m_up_d_i      => mmi64_m_up_d_i     ,
    mmi64_m_up_valid_i  => mmi64_m_up_valid_i ,
    mmi64_m_up_accept_o => mmi64_m_up_accept_o,
    mmi64_m_up_start_i  => mmi64_m_up_start_i ,
    mmi64_m_up_stop_i   => mmi64_m_up_stop_i  ,

    -- clock configuration ports
    clk1_cfg_dn_o       => clk1_cfg_dn_o,
    clk1_cfg_up_i       => clk1_cfg_up_i,
    clk2_cfg_dn_o       => clk2_cfg_dn_o,
    clk2_cfg_up_i       => clk2_cfg_up_i,
    clk3_cfg_dn_o       => clk3_cfg_dn_o,
    clk3_cfg_up_i       => clk3_cfg_up_i,
    clk4_cfg_dn_o       => clk4_cfg_dn_o,
    clk4_cfg_up_i       => clk4_cfg_up_i,
    clk5_cfg_dn_o       => clk5_cfg_dn_o,
    clk5_cfg_up_i       => clk5_cfg_up_i,
    clk6_cfg_dn_o       => clk6_cfg_dn_o,
    clk6_cfg_up_i       => clk6_cfg_up_i,
    clk7_cfg_dn_o       => clk7_cfg_dn_o,
    clk7_cfg_up_i       => clk7_cfg_up_i
  );
end architecture verilog_remap;
