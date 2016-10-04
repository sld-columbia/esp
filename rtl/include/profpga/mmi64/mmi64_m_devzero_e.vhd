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
--!  @file         mmi64_m_devzero_e.vhd
--!  @author       Martin Langner
--!  @email        martin.langner@prodesign-europe.com
--!  @brief        MMI64 module for speedtests
--!                (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! @brief   MMI64 module mmi64_m_devzero reads all incoming data as fast as possible and provides requested amount of zeros
--! @details mmi64_m_devzero can be used for speedtest and behaves like unix /dev/zero

entity mmi64_m_devzero is
  generic (
    MODULE_ID : mmi64_module_id_t := X"00000000"  --! unique id of the module instance
    );
  port (
    -- clock and reset
    mmi64_clk   : in std_ulogic;                  --! clock of mmi64 domain
    mmi64_reset : in std_ulogic;                  --! reset of mmi64 domain

    -- connections to mmi64 router
    mmi64_h_dn_d_i      : in  mmi64_data_t;  --! downstream data from router
    mmi64_h_dn_valid_i  : in  std_ulogic;    --! downstream data valid from router
    mmi64_h_dn_accept_o : out std_ulogic;    --! downstream data accept to router
    mmi64_h_dn_start_i  : in  std_ulogic;    --! downstream data start (first byte of transfer) from router
    mmi64_h_dn_stop_i   : in  std_ulogic;    --! downstream data end (last byte of transfer) from router

    mmi64_h_up_d_o      : out mmi64_data_t;  --! upstream data output to router
    mmi64_h_up_valid_o  : out std_ulogic;    --! upstream data valid to router
    mmi64_h_up_accept_i : in  std_ulogic;    --! upstream data accept from router
    mmi64_h_up_start_o  : out std_ulogic;    --! upstream data start (first byte of transfer) to router
    mmi64_h_up_stop_o   : out std_ulogic     --! upstream data end (last byte of transfer) to router
    );
end entity mmi64_m_devzero;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.rtl_templates.all;

--! component declaration package for mmi64_m_devzero
package mmi64_m_devzero_comp is
  
  --! see description of entity mmi64_m_devzero
  component mmi64_m_devzero
    generic (
      MODULE_ID : mmi64_module_id_t);
    port (
         mmi64_clk           : in  std_ulogic;
         mmi64_reset         : in  std_ulogic;
         mmi64_h_dn_d_i      : in  mmi64_data_t;
         mmi64_h_dn_valid_i  : in  std_ulogic;
         mmi64_h_dn_accept_o : out std_ulogic;
         mmi64_h_dn_start_i  : in  std_ulogic;
         mmi64_h_dn_stop_i   : in  std_ulogic;
         mmi64_h_up_d_o      : out mmi64_data_t;
         mmi64_h_up_valid_o  : out std_ulogic;
         mmi64_h_up_accept_i : in  std_ulogic;
         mmi64_h_up_start_o  : out std_ulogic;
         mmi64_h_up_stop_o   : out std_ulogic);
  end component;
  
end package mmi64_m_devzero_comp;
