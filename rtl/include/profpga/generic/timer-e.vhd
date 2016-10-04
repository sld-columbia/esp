-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2011-2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : ProDesign generic HDL components
--  Module/Entity : timer (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  General purpose timer
--  NOTE          : Input clock period MUST be in range 1 ns  to 1 ms
--                  Module provides granularity of input clock frequency and
--                  timing interrupts are accurate as possible
-- =============================================================================

-------------
-- Entity  --
-------------
library ieee;
    use ieee.std_logic_1164.all;
entity timer is
  generic (
    CLK_PERIOD_NS   : real;                               --! Input clock period in nano seconds
    TIME_SCALE      : string                              --! Timer timescale ("us"- micro seconds, "ms"- mili seconds)
  );
  port (
    --! Clock and reset inputs
    clk             : in  std_ulogic;                     --! Input clock
    reset_n         : in  std_ulogic;                     --! Input reset (low active)

    --! User interface
    enable_i        : in  std_ulogic;                     --! Enable signal
    time_i          : in  std_ulogic_vector(9 downto 0);  --! Enable signal
    expired_o       : out std_ulogic                      --! Timer expired
  );
end entity timer;

------------------------
-- Component/Package  --
------------------------
library ieee;
    use ieee.std_logic_1164.all;
package timer_comp is
  component timer is
  generic (
    CLK_PERIOD_NS   : real;
    TIME_SCALE      : string
  );
  port (
    --! Clock and reset inputs
    clk             : in  std_ulogic;
    reset_n         : in  std_ulogic;

    --! User interface
    enable_i        : in  std_ulogic;
    time_i          : in  std_ulogic_vector(9 downto 0);
    expired_o       : out std_ulogic
  );
  end component timer;
end package timer_comp;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-02-07  First draft.
-- =============================================================================
