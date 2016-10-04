-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012, Pro Design Electronic GmbH
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
--  Module/Entity : mmi64_rt (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  MMI64 Reliable Transmission
-- =============================================================================

-------------
-- Entity  --
-------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.rtl_templates.all;             --! Common functions
use work.mmi64_pkg.all;                 --! MMI64 definitions
entity mmi64_rt is
  generic (
    SYNC        : bit_vector(7 downto 0) := "00101100";  --! Synchronization data
    TIMEOUT     : integer := 1;                                 --! Timeout for retransmition
    BUFF_AWIDTH : integer := 10);                               --! Buffer address width
  port (
    --! MMI64 Reliable Transmission data
    rt_clk    : in  std_ulogic;                      --! Input Clock
    rt_reset  : in  std_ulogic;                      --! Input reset
    rt_data_o : out std_ulogic_vector(71 downto 0);  --! RT output data stream
    rt_data_i : in  std_ulogic_vector(71 downto 0);  --! RT input data stream
    rt_sync_o : out std_ulogic;                      --! Output data contains sync signal

    --! Status outputs
    crc_errors_o  : out std_ulogic_vector(15 downto 0);  --! Number of frames with CRC error
    ack_errors_o  : out std_ulogic_vector(15 downto 0);  --! Number of retransmited messages
    id_errors_o   : out std_ulogic_vector(15 downto 0);  --! Number of messages with wrong id
    id_warnings_o : out std_ulogic_vector(15 downto 0);  --! Number of messages with repeated id


    -- Connections to router
    mmi64_clk           : in  std_ulogic;    --! MMI64 clock
    mmi64_reset         : in  std_ulogic;    --! MMI64 reset
    mmi64_m_dn_d_o      : out mmi64_data_t;  --! Downstream data output to router
    mmi64_m_dn_valid_o  : out std_ulogic;    --! Downstream data valid to router
    mmi64_m_dn_accept_i : in  std_ulogic;    --! Downstream data accept from router
    mmi64_m_dn_start_o  : out std_ulogic;    --! Downstream data start (first byte of transfer) to router
    mmi64_m_dn_stop_o   : out std_ulogic;    --! Downstream data end (last byte of transfer) to router
    mmi64_m_up_d_i      : in  mmi64_data_t;  --! Upstream data from router
    mmi64_m_up_valid_i  : in  std_ulogic;    --! Upstream data valid from router
    mmi64_m_up_accept_o : out std_ulogic;    --! Upstream data accept to router
    mmi64_m_up_start_i  : in  std_ulogic;    --! Upstream data start (first byte of transfer) from router
    mmi64_m_up_stop_i   : in  std_ulogic     --! Upstream data end (last byte of transfer) from router
    );
end entity mmi64_rt;

------------------------
-- Component/Package  --
------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.rtl_templates.all;
use work.mmi64_pkg.all;

package mmi64_rt_comp is
  component mmi64_rt is
    generic (
      SYNC        : bit_vector(7 downto 0) := "00101100";
      TIMEOUT     : integer := 1; 
      BUFF_AWIDTH : integer := 12);
    port (
      rt_clk        : in  std_ulogic;
      rt_reset      : in  std_ulogic;
      rt_data_o     : out std_ulogic_vector(71 downto 0);
      rt_data_i     : in  std_ulogic_vector(71 downto 0);
      rt_sync_o     : out std_ulogic;
      crc_errors_o  : out std_ulogic_vector(15 downto 0);
      ack_errors_o  : out std_ulogic_vector(15 downto 0);
      id_errors_o   : out std_ulogic_vector(15 downto 0);
      id_warnings_o : out std_ulogic_vector(15 downto 0);

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
  end component mmi64_rt;

end package mmi64_rt_comp;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-08-30  First draft.
-- 0.2      2013-01-09  Added SYNC as generic
-- =============================================================================
