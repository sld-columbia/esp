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
--!  @file         mmi64_stimulate_p.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        Verilog PLI and System C stimulus generator.
--!                (component package declaration).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_stimulate
package mmi64_stimulate_comp is

  component mmi64_stimulate
    port (
      mmi64_done_o : out std_ulogic     -- mmi64 user main function termination state
      );
  end component mmi64_stimulate;

end package mmi64_stimulate_comp;
