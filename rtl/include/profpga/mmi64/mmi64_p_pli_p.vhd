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
--!  @project      Module Message Interface
--!  @file         mmi64_p_pli_p.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 PHY connecting to host via verilog pli integration
--!                (component package declaration).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_p_pli
package mmi64_p_pli_comp is

  component mmi64_p_pli
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;      --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;      --! reset of mmi64 domain

      -- connections to first router
      mmi64_m_dn_d_o      : out mmi64_data_t;  --! downstream data output to router
      mmi64_m_dn_valid_o  : out std_ulogic;    --! downstream data valid to router
      mmi64_m_dn_accept_i : in  std_ulogic;    --! downstream data accept from router
      mmi64_m_dn_start_o  : out std_ulogic;    --! downstream data start (first byte of transfer) to router
      mmi64_m_dn_stop_o   : out std_ulogic;    --! downstream data end (last byte of transfer) to router

      mmi64_m_up_d_i      : in  mmi64_data_t;  --! upstream data from router
      mmi64_m_up_valid_i  : in  std_ulogic;    --! upstream data valid from router
      mmi64_m_up_accept_o : out std_ulogic;    --! upstream data accept to router
      mmi64_m_up_start_i  : in  std_ulogic;    --! upstream data start (first byte of transfer) from router
      mmi64_m_up_stop_i   : in  std_ulogic     --! upstream data end (last byte of transfer) from router
      );
  end component mmi64_p_pli;

end package mmi64_p_pli_comp;
