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
--!  @file         mmi64_router_a.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 router for building domain trees spanning
--!                multiple MMI64 modules
--!                (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;

--! @brief mmi64_router implements a mmi64 packet router.
--! @details
--! Supports connection of multiple downstream modules or routers to an upstream router or phy.
--! MMI64_router contains MMI64 buffers on upstream and all downstream ports.
entity mmi64_router is
  generic (
    MODULE_ID  : mmi64_module_id_t    := X"00000000";  --! unique id of the module instance
    PORT_COUNT : mmi64_module_range_t := 1  --! number of modules connected to downstream ports of the router
    );
  port (
    -- clock and reset
    mmi64_clk          : in  std_ulogic;      --! Clock of MMI64 domain.
    mmi64_reset        : in  std_ulogic;      --! Reset of MMI64 domain.
    mmi64_initialize_o : out std_ulogic;      --! Router MMI64 initialization in progress.

    -- connections to mmi64 phy or upstream router
    mmi64_h_up_d_o      : out mmi64_data_t;  --! Data to upstream router or phy.
    mmi64_h_up_valid_o  : out std_ulogic;    --! Data valid to upstream router or phy.
    mmi64_h_up_accept_i : in  std_ulogic;    --! Data accept from upstream router or phy.
    mmi64_h_up_start_o  : out std_ulogic;    --! Start of packet from upstream router or phy.
    mmi64_h_up_stop_o   : out std_ulogic;    --! End of packet from upstream router or phy.

    mmi64_h_dn_d_i      : in  mmi64_data_t;  --! Data from upstream router or phy.
    mmi64_h_dn_valid_i  : in  std_ulogic;    --! Data valid from upstream router or phy.
    mmi64_h_dn_accept_o : out std_ulogic;    --! Data accept to upstream router or phy.
    mmi64_h_dn_start_i  : in  std_ulogic;    --! Start of packet from upstream router or phy.
    mmi64_h_dn_stop_i   : in  std_ulogic;    --! End of packet from upstream router or phy.

    -- connections to mmi64 modules or downstream router
    mmi64_m_up_d_i      : in  mmi64_data_vector_t(0 to PORT_COUNT-1);  --! Data from downstream router or module.
    mmi64_m_up_valid_i  : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Data valid from downstream router or module.
    mmi64_m_up_accept_o : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Data accept to downstream router or module.
    mmi64_m_up_start_i  : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Start of packet from downstream router or module.
    mmi64_m_up_stop_i   : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! End of packet from  downstream router or module.

    mmi64_m_dn_d_o      : out mmi64_data_vector_t(0 to PORT_COUNT-1);  --! Data to downstream router or module.
    mmi64_m_dn_valid_o  : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Data valid to downstream router or module.
    mmi64_m_dn_accept_i : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Data accept from downstream router or module.
    mmi64_m_dn_start_o  : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Start of packet from downstream router or module.
    mmi64_m_dn_stop_o   : out std_ulogic_vector(0 to PORT_COUNT-1);    --! End of packet from downstream router or module.

    -- module presence detection
    module_presence_detection_i : in std_ulogic_vector(0 to PORT_COUNT-1) := (others=>'1') --! Module is present if modules bit is set.
    );
end entity mmi64_router;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_router
package mmi64_router_comp is

  --! see description of entity mmi64_router
  component mmi64_router
    generic (
      MODULE_ID  : mmi64_module_id_t    := X"00000000";  --! unique id of the module instance
      PORT_COUNT : mmi64_module_range_t := 1             --! number of modules connected to downstream ports of the router
      );
    port (
      -- clock and reset
      mmi64_clk          : in  std_ulogic;     --! Clock of MMI64 domain.
      mmi64_reset        : in  std_ulogic;     --! Reset of MMI64 domain.
      mmi64_initialize_o : out std_ulogic;     --! Router MMI64 initialization in progress.

      -- connections to mmi64 phy or upstream router
      mmi64_h_up_d_o      : out mmi64_data_t;  --! Data to upstream router or phy.
      mmi64_h_up_valid_o  : out std_ulogic;    --! Data valid to upstream router or phy.
      mmi64_h_up_accept_i : in  std_ulogic;    --! Data accept from upstream router or phy.
      mmi64_h_up_start_o  : out std_ulogic;    --! Start of packet from upstream router or phy.
      mmi64_h_up_stop_o   : out std_ulogic;    --! End of packet from upstream router or phy.

      mmi64_h_dn_d_i      : in  mmi64_data_t;  --! Data from upstream router or phy.
      mmi64_h_dn_valid_i  : in  std_ulogic;    --! Data valid from upstream router or phy.
      mmi64_h_dn_accept_o : out std_ulogic;    --! Data accept to upstream router or phy.
      mmi64_h_dn_start_i  : in  std_ulogic;    --! Start of packet from upstream router or phy.
      mmi64_h_dn_stop_i   : in  std_ulogic;    --! End of packet from upstream router or phy.

      -- connections to mmi64 modules or downstream router
      mmi64_m_up_d_i      : in  mmi64_data_vector_t(0 to PORT_COUNT-1);  --! Data from downstream router or module.
      mmi64_m_up_valid_i  : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Data valid from downstream router or module.
      mmi64_m_up_accept_o : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Data accept to downstream router or module.
      mmi64_m_up_start_i  : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Start of packet from downstream router or module.
      mmi64_m_up_stop_i   : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! End of packet from  downstream router or module.

      mmi64_m_dn_d_o      : out mmi64_data_vector_t(0 to PORT_COUNT-1);  --! Data to downstream router or module.
      mmi64_m_dn_valid_o  : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Data valid to downstream router or module.
      mmi64_m_dn_accept_i : in  std_ulogic_vector(0 to PORT_COUNT-1);    --! Data accept from downstream router or module.
      mmi64_m_dn_start_o  : out std_ulogic_vector(0 to PORT_COUNT-1);    --! Start of packet from downstream router or module.
      mmi64_m_dn_stop_o   : out std_ulogic_vector(0 to PORT_COUNT-1);    --! End of packet from downstream router or module.

      -- module presence detection
      module_presence_detection_i : in std_ulogic_vector(0 to PORT_COUNT-1) := (others=>'1') --! Module is present if modules bit is set.
      );
  end component;

end mmi64_router_comp;
