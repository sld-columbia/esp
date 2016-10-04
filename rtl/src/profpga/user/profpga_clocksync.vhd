-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013-2014, Pro Design Electronic GmbH
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
--!  @file         profpga_clksync.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA user fpga clock synchronization module
--!                (Xilinx Virtex-7 implementation)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity profpga_clocksync is
  generic (
    CLK_CORE_COMPENSATION : string := "DELAYED" -- "DELAYED" , "DELAYED_XVUS" or "ZHOLD"
  );
  port (
    -- access to FPGA pins
    clk_p           : in  std_ulogic;
    clk_n           : in  std_ulogic;
    sync_p          : in  std_ulogic;
    sync_n          : in  std_ulogic;

    -- clock from pad
    clk_o           : out std_ulogic;

    -- clock feedback (either clk_o or 1:1 output from MMCM/PLL)
    clk_i           : in  std_ulogic;
    clk_locked_i    : in  std_ulogic;

    -- configuration access from profpga_infrastructure
    mmi64_clk       : in  std_ulogic;
    mmi64_reset     : in  std_ulogic;
    cfg_dn_i        : in  std_ulogic_vector(19 downto 0);
    cfg_up_o        : out std_ulogic_vector(19 downto 0);

    -- sync events
    user_reset_o    : out std_ulogic;
    user_strobe1_o  : out std_ulogic;
    user_strobe2_o  : out std_ulogic;
    user_event_id_o : out std_ulogic_vector(7 downto 0);
    user_event_en_o : out std_ulogic
  );
end entity profpga_clocksync;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.profpga_pkg.all;
library unisim;
use unisim.vcomponents.all;

architecture rtl_7series of profpga_clocksync is
  -- bit index definitions for CFG vector
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

  signal sync_delay_r     : std_ulogic_vector(5 downto 0) := (others=>'0'); -- sync configuration register (MMI-64 clock domain)
  signal sync_delay_rEXT  : std_ulogic_vector(5 downto 0) := (others=>'0'); -- sync configuration register (input clock domain)

  signal sync_delay_changing_r          : std_ulogic;
  signal sync_delay_changing_meta_rEXT  : std_ulogic;
  signal sync_delay_changing_rEXT       : std_ulogic;
  
  signal sync_delay_changed_rEXT        : std_ulogic;
  signal sync_delay_changed_meta_r      : std_ulogic;
  signal sync_delay_changed_r           : std_ulogic;
   
  signal mmi64_reset_meta              : std_ulogic;
  signal mmi64_reset_sync              : std_ulogic;

  signal reset            : std_ulogic;
  signal reset_rEXT       : unsigned(2 downto 0); -- sync receiver reset generator (input clock domain)
    
  signal clk_pad          : std_ulogic;
  signal clk_bufio        : std_ulogic;

  attribute KEEP : string;
  attribute KEEP of reset_rEXT : signal is "TRUE";  -- this signal may be mentioned in the XDC file 
  attribute KEEP of clk_pad : signal is "TRUE";     -- this signal may be mentioned in the XDC file 
  
  -- Attribute TIG not supported by VIVADO...
  -- -- ignore path to sync config register (pseudo-static signal, not sending SYNC events during configuration)
  -- attribute TIG : string;
  -- attribute TIG of sync_delay_rEXT : signal is "TRUE";
  -- -- ignore path to reset_rEXT
  -- attribute TIG of reset_rEXT : signal is "TRUE";
begin

  -- convert LVDS clock input into logic
  U_CLK_PAD : IBUFGDS
  generic map (
    DIFF_TERM => true,
    IBUF_LOW_PWR => false,
    IOSTANDARD => "DEFAULT"
  ) port map (
    i => clk_p,
    ib => clk_n,
    o => clk_pad
  );

  clk_o <= clk_pad;
  
  G_DELAYED_XVUS: if CLK_CORE_COMPENSATION="DELAYED_XVUS" generate
    clk_buf : BUFG  
    port map( 
      I => clk_pad, 
      O => clk_bufio
    );
  end generate G_DELAYED_XVUS;
  
  G_DELAYED_OR_ZHOLD: if CLK_CORE_COMPENSATION/="DELAYED_XVUS" generate
    clk_bufio <= clk_pad;
  end generate G_DELAYED_OR_ZHOLD;
  
  
  -- Note: Using external feedback clk_o --> clk_i. This allows sampling of the SYNC signal
  -- with a clock signal driven by PLL/MMCM, which simplifies clock synchronization issues.

  -- transport sync delay configuration into input clock frequency
  -- transport sync delay configuration into input clock frequency
  SYNC_DELAY_FF : process(clk_i, reset_rEXT)
  begin
    if reset_rEXT(0)='1' then
      sync_delay_rEXT               <= (others=>'0');
      sync_delay_changing_meta_rEXT <= '0';
      sync_delay_changing_rEXT      <= '0';
      sync_delay_changed_rEXT       <= '0';
    elsif rising_edge(clk_i) then
      sync_delay_changing_meta_rEXT <= sync_delay_changing_r;
      sync_delay_changing_rEXT      <= sync_delay_changing_meta_rEXT;
      sync_delay_changed_rEXT       <= sync_delay_changing_rEXT;
      if sync_delay_changing_rEXT='1' and sync_delay_changed_rEXT='0' then
        sync_delay_rEXT  <= sync_delay_r;
      end if;
    end if;
  end process SYNC_DELAY_FF;


  -- synchronize MMI64 reset on clk_i domain
  SYNC_MMI64_RST_FF : process(clk_i)
  begin
    if rising_edge(clk_i) then
      mmi64_reset_meta <= mmi64_reset;
      mmi64_reset_sync <= mmi64_reset_meta;
    end if;
  end process SYNC_MMI64_RST_FF;
  
  -- reset SYNC receiver when MMI-64 reset is active or when user PLL has not locked yet
  reset <= mmi64_reset_sync or not clk_locked_i;
  reset_rEXT <= (others=>'1') when reset='1'
        else shift_right(reset_rEXT, 1) when rising_edge(clk_i);

  -- sync receiver
  U_SYNC_RX : profpga_sync_rx2
  generic map (
    CLK_CORE_COMPENSATION => CLK_CORE_COMPENSATION
  ) port map (
    clk_pad         => clk_bufio,
    clk_core        => clk_i,
    rst             => reset_rEXT(0),
    sync_p_i        => sync_p,
    sync_n_i        => sync_n,
    sync_delay_i    => sync_delay_rEXT,

    user_reset_o    => user_reset_o,
    user_strobe1_o  => user_strobe1_o,
    user_strobe2_o  => user_strobe2_o,
    event_id_o      => user_event_id_o,
    event_en_o      => user_event_en_o
  );

  -- configuration register access from profpga_infrastructure
  MMI64_FF : process (mmi64_clk, mmi64_reset)
  begin
    if mmi64_reset='1' then
      sync_delay_r              <= (others=>'0');
      sync_delay_changing_r     <= '0';
      sync_delay_changed_meta_r <= '0';
      sync_delay_changed_r      <= '0';
    elsif rising_edge(mmi64_clk) then
      sync_delay_changed_meta_r <= sync_delay_changed_rEXT;
      sync_delay_changed_r      <= sync_delay_changed_meta_r;
      
      if cfg_dn_i(IDX_DN_EN)='1'
      and cfg_dn_i(IDX_DN_WE)='1'
      and cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)="11"
      and sync_delay_changing_r='0' and sync_delay_changed_r='0'
      then
        sync_delay_changing_r <= '1';
        sync_delay_r <= cfg_dn_i(IDX_DN_DATA_LO+5 downto IDX_DN_DATA_LO);
      elsif sync_delay_changed_r='1' then
        sync_delay_changing_r <= '0';
      end if;
    end if;
  end process MMI64_FF;

  -- configuration read access
  cfg_up_o(IDX_UP_DATA_LO+5 downto IDX_UP_DATA_LO) <= sync_delay_r;
  cfg_up_o(IDX_UP_DATA_HI downto IDX_UP_DATA_LO+6) <= (others=>'0');
  cfg_up_o(IDX_UP_ACCEPT)  <= not sync_delay_changing_r and not sync_delay_changed_r;
  cfg_up_o(IDX_UP_RVALID)  <= cfg_dn_i(IDX_DN_EN) and not cfg_dn_i(IDX_DN_WE);

  -- declare who I am
  cfg_up_o(IDX_UP_PRESENT) <= '1';  -- clocksync module is present
  cfg_up_o(IDX_UP_IS_ACM)  <= '0';  -- this is not an ACM module

end architecture rtl_7series;
