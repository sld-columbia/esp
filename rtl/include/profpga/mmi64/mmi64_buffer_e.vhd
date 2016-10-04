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
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_buffer_e.vhd
--!  @author       Norman Nolte, Sebastian Fluegel
--!  @email        norman.nolte@prodesign-europe.com
--!                sebastian.fluegel@prodesign-europe.com
--!  @brief        Buffer for pipelining MMI64 bus
--                 (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

entity mmi64_buffer is
  generic (
    DOWNSTREAM_BUFFER_ENABLE_HOLDOFF : natural := 0; --! number of cycles buffer stays disabled between to enabled states regarding downstream transfers
    UPSTREAM_BUFFER_ENABLE_HOLDOFF   : natural := 0  --! number of cycles buffer stays disabled between to enabled states regarding upstream transfers
    );
  port (
    -- clock and reset
    mmi64_clk   : in std_ulogic;          --! clock of mmi64 domain
    mmi64_reset : in std_ulogic;          --! reset of mmi64 domain

    -- mmi64 buffer connections towards host (root)
    mmi64_h_up_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to upstream router or phy
    mmi64_h_up_valid_o  : out std_ulogic;                                      --! mmi64 data valid to upstream router or phy
    mmi64_h_up_accept_i : in  std_ulogic;                                      --! mmi64 data accept from upstream router or phy
    mmi64_h_up_start_o  : out std_ulogic;                                      --! mmi64 data packet start to upstream router or phy
    mmi64_h_up_stop_o   : out std_ulogic;                                      --! mmi64 data packet end to upstream router or phy

    mmi64_h_dn_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data from upstream router or phy
    mmi64_h_dn_valid_i  : in  std_ulogic;                                      --! mmi64 data valid from upstream router or phy
    mmi64_h_dn_accept_o : out std_ulogic;                                      --! mmi64 data accept to upstream router or phy
    mmi64_h_dn_start_i  : in  std_ulogic;                                      --! mmi64 data packet start from upstream router or phy
    mmi64_h_dn_stop_i   : in  std_ulogic;                                      --! mmi64 data packet end from upstream router or phy

    -- mmi64 buffer connections towards modules (leaves)
    mmi64_m_up_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data from downstream router or module
    mmi64_m_up_valid_i  : in  std_ulogic;                                      --! mmi64 data valid from downstream router or module
    mmi64_m_up_accept_o : out std_ulogic;                                      --! mmi64 data accept to downstream router or module
    mmi64_m_up_start_i  : in  std_ulogic;                                      --! mmi64 data packet start from downstream router or module
    mmi64_m_up_stop_i   : in  std_ulogic;                                      --! mmi64 data packet end from downstream router or module

    mmi64_m_dn_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to downstream router or module
    mmi64_m_dn_valid_o  : out std_ulogic;                                      --! mmi64 data valid to downstream router or module
    mmi64_m_dn_accept_i : in  std_ulogic;                                      --! mmi64 data accept from downstream router or module
    mmi64_m_dn_start_o  : out std_ulogic;                                      --! mmi64 data packet start to downstream router or module
    mmi64_m_dn_stop_o   : out std_ulogic                                       --! mmi64 data packet end to downstream router or module
    );
end entity mmi64_buffer;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_buffer
package mmi64_buffer_comp is

  --! see description of entity mmi64_buffer
  component mmi64_buffer
    generic (
      DOWNSTREAM_BUFFER_ENABLE_HOLDOFF : natural := 0; --! number of cycles buffer stays disabled between to enabled states regarding downstream transfers
      UPSTREAM_BUFFER_ENABLE_HOLDOFF   : natural := 0  --! number of cycles buffer stays disabled between to enabled states regarding upstream transfers
      );
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;          --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;          --! reset of mmi64 domain

      -- mmi64 buffer connections towards host (root)
      mmi64_h_up_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to upstream router or phy
      mmi64_h_up_valid_o  : out std_ulogic;                                      --! mmi64 data valid to upstream router or phy
      mmi64_h_up_accept_i : in  std_ulogic;                                      --! mmi64 data accept from upstream router or phy
      mmi64_h_up_start_o  : out std_ulogic;                                      --! mmi64 data packet start to upstream router or phy
      mmi64_h_up_stop_o   : out std_ulogic;                                      --! mmi64 data packet end to upstream router or phy

      mmi64_h_dn_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data from upstream router or phy
      mmi64_h_dn_valid_i  : in  std_ulogic;                                      --! mmi64 data valid from upstream router or phy
      mmi64_h_dn_accept_o : out std_ulogic;                                      --! mmi64 data accept to upstream router or phy
      mmi64_h_dn_start_i  : in  std_ulogic;                                      --! mmi64 data packet start from upstream router or phy
      mmi64_h_dn_stop_i   : in  std_ulogic;                                      --! mmi64 data packet end from upstream router or phy

      -- mmi64 buffer connections towards modules (leaves)
      mmi64_m_up_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data from downstream router or module
      mmi64_m_up_valid_i  : in  std_ulogic;                                      --! mmi64 data valid from downstream router or module
      mmi64_m_up_accept_o : out std_ulogic;                                      --! mmi64 data accept to downstream router or module
      mmi64_m_up_start_i  : in  std_ulogic;                                      --! mmi64 data packet start from downstream router or module
      mmi64_m_up_stop_i   : in  std_ulogic;                                      --! mmi64 data packet end from downstream router or module

      mmi64_m_dn_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to downstream router or module
      mmi64_m_dn_valid_o  : out std_ulogic;                                      --! mmi64 data valid to downstream router or module
      mmi64_m_dn_accept_i : in  std_ulogic;                                      --! mmi64 data accept from downstream router or module
      mmi64_m_dn_start_o  : out std_ulogic;                                      --! mmi64 data packet start to downstream router or module
      mmi64_m_dn_stop_o   : out std_ulogic                                       --! mmi64 data packet end to downstream router or module
      );
  end component;

end mmi64_buffer_comp;
