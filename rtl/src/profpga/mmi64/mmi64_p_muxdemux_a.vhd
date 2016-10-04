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
--  Project       : MMI64 (Module Message Interface)
--  Module/Entity : mmi64_p_muxdemux (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  MMI64 PHY usint Reliable Transmission and pin mutiplexing
-- =============================================================================
-------------------
-- Architecture  --
-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_rt_comp.all;
use work.rtl_templates.all;
use work.mmi64_p_muxdemux_pkg.all;

architecture rtl of mmi64_p_muxdemux is
  
-----------------------------------
-- Constants
-----------------------------------
  constant TRAINING_CLOCK_CYCLES_BIT : integer := TrainingCounterWidth(PIN_TRAINING_SPEED);
  constant SB_WIDTH   : integer := GetBasicStatBitWidth(DEVICE);
  constant TC_WIDTH   : integer := GetTCBitWidth(DEVICE);
  constant STAT_WIDTH : integer := (72/MUX_FACTOR)*SB_WIDTH;

  component mmi64_p_muxdemux_ctrl_fsm is
    generic (
      DEVICE                    : string := "XV7S";
      TRAINING_CLOCK_CYCLES_BIT :     integer range 4 to 16 := 8);
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      mode          : out std_logic_vector(8 downto 0));  -- mux/demux training mode
  end component mmi64_p_muxdemux_ctrl_fsm;

  component mmi64_p_muxdemux_mux is
    generic (
      DEVICE        : string         := "XV7S";
      DIFF_ENABLED  :     integer range 0 to 1;
      DDR_ENABLED   :     integer range 0 to 1;
      MUX_FACTOR    :     integer range 2 to 64;
      ODELAY_VALUE  :     integer range 0 to 31);
    port (
      mux_clk_hs    : in  std_logic;
      mux_clk_dv    : in  std_logic;
      mode          : in  std_logic_vector(8 downto 0);
      data_from_dut : in  std_logic_vector (MUX_FACTOR-1 downto 0);
      data_to_pin   : out std_logic;
      data_to_pin_n : out std_logic;
      data_to_pin_p : out std_logic);
  end component mmi64_p_muxdemux_mux;

  component mmi64_p_muxdemux_demux is
    generic (
      DEVICE          :     string := "XV7S";
      DIFF_ENABLED    :     integer range 0 to 1;
      DDR_ENABLED     :     integer range 0 to 1;
      MUX_FACTOR      :     integer range 2 to 64);
    port (
      mux_clk_hs      : in  std_logic;
      mux_clk_dv      : in  std_logic;
      mode            : in  std_logic_vector(8 downto 0);
      data_to_dut     : out std_logic_vector (MUX_FACTOR-1 downto 0);
      output_delay_i  : in  std_logic;
      sync_detected_o : out std_logic; 
      data_from_pin   : in  std_logic;
      data_from_pin_n : in  std_logic;
      data_from_pin_p : in  std_logic;
      tap_start       : out std_logic_vector (TC_WIDTH-1 downto 0);
      tap_end         : out std_logic_vector (TC_WIDTH-1 downto 0);
      tap_value_in    : out std_logic_vector (TC_WIDTH-1 downto 0);
      tap_value_out   : out std_logic_vector (TC_WIDTH-1 downto 0);
      bitslip         : out std_logic_vector (2 downto 0));
  end component mmi64_p_muxdemux_demux;
  
  component mmi64_p_muxdemux_sync is
  generic (
    DMUX_NUM : integer := 8);
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    sync_found_i   : in  std_logic_vector (DMUX_NUM-1 downto 0);
    output_delay_o : out std_logic_vector (DMUX_NUM-1 downto 0);
    error_o        : out std_logic);
  end component mmi64_p_muxdemux_sync;

-----------------------------------------
-- custom types
-----------------------------------------
  --! array type for storing statistic output
  type tap_data_vector_t is array(natural range <>) of std_logic_vector(GetTCBitWidth(DEVICE)-1 downto 0);
  type bitslip_data_vector_t is array(natural range <>) of std_logic_vector(2 downto 0);
  
-----------------------------------------
-- Interconnection signals and registers
-----------------------------------------
  signal rt_out_data          : std_ulogic_vector(71 downto 0);  --! Output data from MMI64 Reliable Transmission
  signal rt_in_data           : std_logic_vector(71 downto 0);  --! Input data to MMI64 Reliable Transmission
  signal mux_mode             : std_logic_vector(8 downto 0);    --! Training sequence mode
  signal mmi64_m_up_accept_rt : std_ulogic;
  signal mmi64_m_up_valid_rt  : std_ulogic;
  signal rt_reset             : std_ulogic;
  signal muxdemux_status      : std_logic_vector(STAT_WIDTH-1 downto 0);
  signal tap_start            : tap_data_vector_t(0 to 72/MUX_FACTOR-1);
  signal tap_end              : tap_data_vector_t(0 to 72/MUX_FACTOR-1);
  signal bitslip              : bitslip_data_vector_t(0 to 72/MUX_FACTOR-1);
  signal dummy                : std_logic_vector(SB_WIDTH-(TC_WIDTH*2)-3-1 downto 0);
  signal sync_found           : std_logic_vector(72/MUX_FACTOR-1 downto 0);
  signal output_delay         : std_logic_vector(72/MUX_FACTOR-1 downto 0);
  signal sync_error           : std_logic;
begin
--------------------------------------------------
--  MMI64 Reliable Transmission
--------------------------------------------------
  u_mmi64_rt : mmi64_rt
  generic map(
    BUFF_AWIDTH => 10
  ) port map (
    rt_clk              => pad_dv_clk,
    rt_reset            => rt_reset,
    rt_data_o           => rt_out_data,
    rt_data_i           => std_ulogic_vector(rt_in_data),
    crc_errors_o        => rt_crc_errors_o,
    ack_errors_o        => rt_ack_errors_o,
    id_errors_o         => rt_id_errors_o,
    id_warnings_o       => rt_id_warnings_o,
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    mmi64_m_dn_d_o      => mmi64_m_dn_d_o,
    mmi64_m_dn_valid_o  => mmi64_m_dn_valid_o,
    mmi64_m_dn_accept_i => mmi64_m_dn_accept_i,
    mmi64_m_dn_start_o  => mmi64_m_dn_start_o,
    mmi64_m_dn_stop_o   => mmi64_m_dn_stop_o,
    mmi64_m_up_d_i      => mmi64_m_up_d_i,
    mmi64_m_up_valid_i  => mmi64_m_up_valid_rt,
    mmi64_m_up_accept_o => mmi64_m_up_accept_rt,
    mmi64_m_up_start_i  => mmi64_m_up_start_i,
    mmi64_m_up_stop_i   => mmi64_m_up_stop_i
  );
  
  rt_reset <= not mux_mode(8); -- keep mmi64_rt in reset until training sequence has finished.
  mmi64_m_up_valid_rt <= '0' when rt_reset='1' -- ignore incoming data while RT is in reset
                  else mmi64_m_up_valid_i;
  mmi64_m_up_accept_o <= '0' when rt_reset='1' -- do not accept transfers while RT is in reset
                  else mmi64_m_up_accept_rt;

--------------------------------------------------
--  mux/demux control FSM
--------------------------------------------------
  u_ctrl_fsm :  mmi64_p_muxdemux_ctrl_fsm
  generic map (
    TRAINING_CLOCK_CYCLES_BIT => TRAINING_CLOCK_CYCLES_BIT,
    DEVICE                    => DEVICE
  ) port map (
    clk  => pad_dv_clk,
    rst  => pad_dv_reset,
    mode => mux_mode
  );
  muxdemux_mode_o <= std_ulogic_vector(mux_mode);
--------------------------------------------------
--  Data multoplexers/demultiplexers
--------------------------------------------------
  G_MUXDEMUX: for mux_num in 0 to (72/MUX_FACTOR)-1 generate
    --! Pin Multiplexer
    u_mux : mmi64_p_muxdemux_mux
    generic map (
      DIFF_ENABLED  => 0,
      DDR_ENABLED   => 0,
      MUX_FACTOR    => MUX_FACTOR,
      ODELAY_VALUE  => 0,
      DEVICE        => DEVICE
    ) port map (
      mux_clk_hs    => pad_hs_clk,
      mux_clk_dv    => pad_dv_clk,
      mode          => mux_mode,
      data_from_dut => std_logic_vector(rt_out_data((mux_num+1)*MUX_FACTOR-1 downto mux_num*MUX_FACTOR)),
      data_to_pin   => pad_data_o(mux_num),
      data_to_pin_n => open,
      data_to_pin_p => open
    );

    --! Pin Demultiplexer
    u_demux : mmi64_p_muxdemux_demux
    generic map (
      DIFF_ENABLED    => 0,
      DDR_ENABLED     => 0,
      MUX_FACTOR      => MUX_FACTOR,
      DEVICE          => DEVICE
    ) port map (
      mux_clk_hs      => pad_hs_clk,
      mux_clk_dv      => pad_dv_clk,
      mode            => mux_mode,
      output_delay_i  => output_delay(mux_num),
      sync_detected_o => sync_found(mux_num),
      data_to_dut     => rt_in_data((mux_num+1)*MUX_FACTOR-1 downto mux_num*MUX_FACTOR),
      data_from_pin   => pad_data_i(mux_num),
      data_from_pin_n => '0',
      data_from_pin_p => '0',
      tap_start       => tap_start(mux_num),
      tap_end         => tap_end(mux_num),
      tap_value_in    => open,
      tap_value_out   => open,
      bitslip         => bitslip(mux_num)
    );
    
    muxdemux_status(SB_WIDTH*(mux_num+1)-1 downto SB_WIDTH*mux_num) <= dummy & bitslip(mux_num) & tap_end(mux_num) & tap_start(mux_num); 
  end generate G_MUXDEMUX;
  
  u_sync : mmi64_p_muxdemux_sync
  generic map(
    DMUX_NUM => 72/MUX_FACTOR
  ) port map(
    clk            => pad_dv_clk,
    rst            => mux_mode(MUX_MODE_BIT_RST),
    sync_found_i   => sync_found,
    output_delay_o => output_delay,
    error_o        => sync_error
  );
  
  dummy <= (others=>'0');
  muxdemux_status_o <= std_ulogic_vector(muxdemux_status);

end architecture rtl;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-12-25  First draft.
-- 1.0      2013-06-21  Added generic PIN_TRAINING_SPEED
-- 2.0      2015-01-29  Added generic DEVICE
-- =============================================================================
