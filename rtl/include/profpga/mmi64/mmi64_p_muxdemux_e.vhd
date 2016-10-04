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

-------------
-- Entity  --
-------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;                 --! MMI64 definitions
use work.mmi64_p_muxdemux_pkg.all;      --! muxdemux specific definitions

entity mmi64_p_muxdemux is
  generic (
    PIN_TRAINING_SPEED  : string := "auto";         --! Pin training speed: "real"=real calibration, "fast"=fast simulation, "auto"=auto-detect (synthesis tool must support "synthesis translate_off")
    MUX_FACTOR          : integer range 2 to 8:= 4;
    DEVICE              : string := "XV7S"          --! "XV7S"- Xilinx Virtex 7series; "XVUS"- Xilinx Virtex UltraScale
  );
  port (
    --! Pad interface
    pad_hs_clk          : in  std_ulogic;                                       --! Serialized high speed data clk freq(pad_clk) = freq(rt_clk) * MUX_FACTOR
    pad_data_o          : out std_ulogic_vector((72/MUX_FACTOR)-1 downto 0);    --! Serialized output data
    pad_data_i          : in  std_ulogic_vector((72/MUX_FACTOR)-1 downto 0);    --! Serialized input data    

    pad_dv_clk          : in  std_ulogic;                                       --! Serializers divided clock
    pad_dv_reset        : in  std_ulogic;                                       --! Serializers reset
    --! MMI64 Reliable Transmission statistic
    rt_crc_errors_o     : out std_ulogic_vector(15 downto 0);                   --! Number of frames with CRC error
    rt_ack_errors_o     : out std_ulogic_vector(15 downto 0);                   --! Number of retransmited messages
    rt_id_errors_o      : out std_ulogic_vector(15 downto 0);                   --! Number of messages with wrong id
    rt_id_warnings_o    : out std_ulogic_vector(15 downto 0);                   --! Number of messages with repeated id
    --! MUXDEMUX status
    muxdemux_status_o   : out std_ulogic_vector(GetStatBitWidth(DEVICE, MUX_FACTOR)-1 downto 0);
    muxdemux_mode_o     : out std_ulogic_vector(8 downto 0);                    --! Pin multioplexer mode
    -- MMI64 connections
    mmi64_clk           : in  std_ulogic;                                        --! MMI64 clock
    mmi64_reset         : in  std_ulogic;                                        --! MMI64 reset
    mmi64_m_dn_d_o      : out mmi64_data_t;                                      --! Downstream data output to router
    mmi64_m_dn_valid_o  : out std_ulogic;                                        --! Downstream data valid to router
    mmi64_m_dn_accept_i : in  std_ulogic;                                        --! Downstream data accept from router
    mmi64_m_dn_start_o  : out std_ulogic;                                        --! Downstream data start (first byte of transfer) to router
    mmi64_m_dn_stop_o   : out std_ulogic;                                        --! Downstream data end (last byte of transfer) to router
    mmi64_m_up_d_i      : in  mmi64_data_t;                                      --! Upstream data from router
    mmi64_m_up_valid_i  : in  std_ulogic;                                        --! Upstream data valid from router
    mmi64_m_up_accept_o : out std_ulogic;                                        --! Upstream data accept to router
    mmi64_m_up_start_i  : in  std_ulogic;                                        --! Upstream data start (first byte of transfer) from router
    mmi64_m_up_stop_i   : in  std_ulogic                                         --! Upstream data end (last byte of transfer) from router
  );
end entity mmi64_p_muxdemux;

------------------------
-- Component/Package  --
------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.mmi64_p_muxdemux_pkg.all;
package mmi64_p_muxdemux_comp is
  component mmi64_p_muxdemux is
    generic (
      PIN_TRAINING_SPEED  : string := "auto"; --! Pin training speed: "real"=real calibration, "fast"=fast simulation, "auto"=auto-detect (synthesis tool must support "synthesis translate_off")
      MUX_FACTOR          : integer range 2 to 8:= 4;
      DEVICE              : string := "XV7S"
    );
    port (
      pad_hs_clk          : in  std_ulogic;
      pad_data_o          : out std_ulogic_vector((72/MUX_FACTOR)-1 downto 0);
      pad_data_i          : in  std_ulogic_vector((72/MUX_FACTOR)-1 downto 0);
      pad_dv_clk          : in  std_ulogic;
      pad_dv_reset        : in  std_ulogic;
      rt_crc_errors_o     : out std_ulogic_vector(15 downto 0);
      rt_ack_errors_o     : out std_ulogic_vector(15 downto 0);
      rt_id_errors_o      : out std_ulogic_vector(15 downto 0);
      rt_id_warnings_o    : out std_ulogic_vector(15 downto 0);
      muxdemux_status_o   : out std_ulogic_vector(GetStatBitWidth(DEVICE, MUX_FACTOR)-1 downto 0);
      muxdemux_mode_o     : out std_ulogic_vector(8 downto 0); 
      mmi64_clk           : in  std_ulogic;
      mmi64_reset         : in  std_ulogic;
      mmi64_m_dn_d_o      : out mmi64_data_t;
      mmi64_m_dn_valid_o  : out std_ulogic;
      mmi64_m_dn_accept_i : in  std_ulogic;
      mmi64_m_dn_start_o  : out std_ulogic;
      mmi64_m_dn_stop_o   : out std_ulogic;
      mmi64_m_up_d_i      : in  mmi64_data_t;
      mmi64_m_up_valid_i  : in  std_ulogic;
      mmi64_m_up_accept_o : out std_ulogic;
      mmi64_m_up_start_i  : in  std_ulogic;
      mmi64_m_up_stop_i   : in  std_ulogic
    );
  end component mmi64_p_muxdemux;

end package mmi64_p_muxdemux_comp;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-12-25  First draft.
-- 1.0      2013-06-21  Added generic PIN_TRAINING_SPEED
-- 2.0      2015-01-29  Added generic DEVICE
-- =============================================================================
