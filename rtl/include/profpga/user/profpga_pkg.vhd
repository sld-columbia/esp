-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013, Pro Design Electronic GmbH
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
--!  @file         mmi64_p.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA user component declaration package.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

package profpga_pkg is

  constant EVENTID_NULL       : std_ulogic_vector(7 downto 0) := x"00";
  constant EVENTID_ACMSYNC    : std_ulogic_vector(7 downto 0) := x"01";
  constant EVENTID_RESET_0    : std_ulogic_vector(7 downto 0) := x"02";
  constant EVENTID_RESET_1    : std_ulogic_vector(7 downto 0) := x"03";
  constant EVENTID_STROBE1_0  : std_ulogic_vector(7 downto 0) := x"04";
  constant EVENTID_STROBE1_1  : std_ulogic_vector(7 downto 0) := x"05";
  constant EVENTID_STROBE2_0  : std_ulogic_vector(7 downto 0) := x"06";
  constant EVENTID_STROBE2_1  : std_ulogic_vector(7 downto 0) := x"07";

  type sync_event_vector is array(natural range <>) of std_ulogic_vector(7 downto 0);

  component profpga_ctrl is
    generic (
      DEVICE              : string := "XV7S"; --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
      ENABLE_DEBUG        : string := "FALSE";--! set to "TRUE" when instructed by ProDesign
      PIN_TRAINING_SPEED  : string := "auto"  --! Pin training speed: "real"=real calibration, "fast"=fast simulation, "auto"=auto-detect (synthesis tool must support "synthesis translate_off")
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

      -- 200 MHz clock (useful for IDELAYCTRL calibration)
      clk_200mhz_o        : out std_ulogic;

      -- source clock/sync input
      src_clk_i           : in  std_ulogic_vector(3 downto 0) := "0000";
      -- the following signals are synchronous to the associated src_clk_i(i)
      src_clk_locked_i    : in  std_ulogic_vector(3 downto 0) := "0000";
      src_event_id_i      : in  sync_event_vector(3 downto 0) := (others=>x"00");
      src_event_en_i      : in  std_ulogic_vector(3 downto 0) := "0000";
      src_event_busy_o    : out std_ulogic_vector(3 downto 0);
      src_event_reset_i   : in  std_ulogic_vector(3 downto 0) := "1111";
      src_event_strobe1_i : in  std_ulogic_vector(3 downto 0) := "0000";
      src_event_strobe2_i : in  std_ulogic_vector(3 downto 0) := "0000";

      -- clk0 sync events (synchronous to mmi64_clk)
      clk0_event_id_o     : out std_ulogic_vector(7 downto 0);
      clk0_event_en_o     : out std_ulogic;
      clk0_event_strobe1_o: out std_ulogic;
      clk0_event_strobe2_o: out std_ulogic;

      -- MMI-64 access (synchronous to mmi64_clk)
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

      -- clock configuration ports (synchronous to mmi64_clk)
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
  end component profpga_ctrl;

  component profpga_acm is
    generic (
      ACM_CLOCKS      : natural := 0
    );
    port (
      -- FPGA input pins
      clk_p           : in  std_ulogic;
      clk_n           : in  std_ulogic;
      sync_p          : in  std_ulogic;
      sync_n          : in  std_ulogic;

      -- ACM configuration (connect with profpga_ctrl)
      mmi64_clk       : in  std_ulogic;
      mmi64_reset     : in  std_ulogic;
      cfg_dn_i        : in  std_ulogic_vector(19 downto 0);
      cfg_up_o        : out std_ulogic_vector(19 downto 0);

      -- ACM status
      locked_o        : out std_ulogic;

      -- ACM clock outputs: acm_clk(0) is the primary 1:1 clock output,
      --                    acm_clk(ACM_CLOCS...1) are derived clocks
      acm_clk_o       : out std_ulogic_vector(ACM_CLOCKS downto 0);
      acm_event_id_o  : out sync_event_vector(ACM_CLOCKS downto 0);
      acm_event_en_o  : out std_ulogic_vector(ACM_CLOCKS downto 0);
      acm_reset_o     : out std_ulogic_vector(ACM_CLOCKS downto 0);
      acm_strobe1_o   : out std_ulogic_vector(ACM_CLOCKS downto 0);
      acm_strobe2_o   : out std_ulogic_vector(ACM_CLOCKS downto 0);

      --local clock outputs (not synchronized with other FPGAs)
      local_clk_o     : out std_ulogic_vector(4 downto 0)
    );
  end component profpga_acm;

  component profpga_clocksync is
    generic (
      CLK_CORE_COMPENSATION : string := "DELAYED" -- "DELAYED" or "ZHOLD"
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
  end component profpga_clocksync;

  component profpga_sync_rx is
    port (
      clk             : in  std_ulogic;
      rst             : in  std_ulogic;
      sync_p_i        : in  std_ulogic;
      sync_n_i        : in  std_ulogic;
      sync_delay_i    : in  std_ulogic_vector(5 downto 0);  -- input delay (for multi-motherboard operations)

      user_reset_o    : out std_ulogic;
      user_strobe1_o  : out std_ulogic;
      user_strobe2_o  : out std_ulogic;
      event_id_o      : out std_ulogic_vector(7 downto 0);
      event_en_o      : out std_ulogic
    );
  end component profpga_sync_rx;

  component profpga_sync_rx2 is
    generic (
      CLK_CORE_COMPENSATION : string := "DELAYED" -- "DELAYED" or "ZHOLD"
    );
    port (
      clk_pad         : in  std_ulogic;
      clk_core        : in  std_ulogic;
      rst             : in  std_ulogic;
      sync_p_i        : in  std_ulogic;
      sync_n_i        : in  std_ulogic;
      sync_delay_i    : in  std_ulogic_vector(5 downto 0);  -- input delay (for multi-motherboard operations)

      user_reset_o    : out std_ulogic;
      user_strobe1_o  : out std_ulogic;
      user_strobe2_o  : out std_ulogic;
      event_id_o      : out std_ulogic_vector(7 downto 0);
      event_en_o      : out std_ulogic
    );
  end component profpga_sync_rx2;

  component profpga_sync_tx is
    port (
      -- sync event interface
      clk             : in  std_ulogic;
      rst             : in  std_ulogic;
      event_id_i      : in  std_ulogic_vector(7 downto 0);
      event_en_i      : in  std_ulogic;
      event_busy_o    : out std_ulogic;

      -- extra wait cycles between 2 sync events (needed when recipent derives very slow clock)
      event_pause_i   : in  std_ulogic_vector(15 downto 0);

      -- automatic sync events
      user_reset_i    : in  std_ulogic;
      user_strobe1_i  : in  std_ulogic;
      user_strobe2_i  : in  std_ulogic;

      -- sync output
      sync_p_o        : out std_ulogic;
      sync_n_o        : out std_ulogic
    );
  end component profpga_sync_tx;

  component profpga_mb is
    generic (
      DMBI_TRAINING_SPEED  : string := "fast"; -- Pin training speed: "real"=real calibration, "fast"=fast simulation
      MB_IS_MASTER     : boolean := true
    );
    port (
      -- external clock/sync inputs
      ext_clk       : in  std_ulogic_vector(3 downto 0) := (others=>'0');
      ext_sync      : in  std_ulogic_vector(3 downto 0) := (others=>'0');

      -- master beats
      clk_p         : out std_ulogic_vector(7 downto 0);
      clk_n         : out std_ulogic_vector(7 downto 0);
      sync_p        : out std_ulogic_vector(7 downto 0);
      sync_n        : out std_ulogic_vector(7 downto 0);

      -- communication with user FPGAs
      ta1_dmbi_h2f  : out std_ulogic_vector(19 downto 0);
      ta1_dmbi_f2h  : in  std_ulogic_vector(19 downto 0) := (others=>'0');
      ta1_srcclk_p  : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      ta1_srcclk_n  : in  std_ulogic_vector(3 downto 0)  := (others=>'1');
      ta1_srcsync_p : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      ta1_srcsync_n : in  std_ulogic_vector(3 downto 0)  := (others=>'1');

      tc1_dmbi_h2f  : out std_ulogic_vector(19 downto 0);
      tc1_dmbi_f2h  : in  std_ulogic_vector(19 downto 0) := (others=>'0');
      tc1_srcclk_p  : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      tc1_srcclk_n  : in  std_ulogic_vector(3 downto 0)  := (others=>'1');
      tc1_srcsync_p : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      tc1_srcsync_n : in  std_ulogic_vector(3 downto 0)  := (others=>'1');

      ta3_dmbi_h2f  : out std_ulogic_vector(19 downto 0);
      ta3_dmbi_f2h  : in  std_ulogic_vector(19 downto 0) := (others=>'0');
      ta3_srcclk_p  : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      ta3_srcclk_n  : in  std_ulogic_vector(3 downto 0)  := (others=>'1');
      ta3_srcsync_p : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      ta3_srcsync_n : in  std_ulogic_vector(3 downto 0)  := (others=>'1');

      tc3_dmbi_h2f  : out std_ulogic_vector(19 downto 0);
      tc3_dmbi_f2h  : in  std_ulogic_vector(19 downto 0) := (others=>'0');
      tc3_srcclk_p  : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      tc3_srcclk_n  : in  std_ulogic_vector(3 downto 0)  := (others=>'1');
      tc3_srcsync_p : in  std_ulogic_vector(3 downto 0)  := (others=>'0');
      tc3_srcsync_n : in  std_ulogic_vector(3 downto 0)  := (others=>'1');

      -- communication with next motherboard (if present)
      nmb_dn        : out std_ulogic_vector(84 downto 0) := (others=>'0'); -- 8 clk, 8 sync, 64 data, 5 ctrl (valid,first,last,ack,present)
      nmb_up        : in  std_ulogic_vector(84 downto 0) := (others=>'0');

      -- communication with previous motherboard (only if this is not the master motherboad)
      pmb_up        : out std_ulogic_vector(84 downto 0) := (others=>'0');
      pmb_dn        : in  std_ulogic_vector(84 downto 0) := (others=>'0')
    );
  end component profpga_mb;

end package profpga_pkg;
