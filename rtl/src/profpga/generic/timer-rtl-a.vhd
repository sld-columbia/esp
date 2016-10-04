-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2011-2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Straße 14-16            info@prodesign-europe.com
--  83052 Bruckmühl                      +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : ProDesign generic HDL components
--  Module/Entity : timer ((Architecture)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  General purpose timer
--  NOTE          : Input clock period MUST be min 1 ns  and max to 1 ms
--                  Module provides granularity of input clock frequency and
--                  timing interrupts are accurate as possible
-- =============================================================================

-------------------
-- Architecture  --
-------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

architecture rtl of timer is

  constant MICRO_SECOND : integer  :=  integer(ceil(1000.0/CLK_PERIOD_NS));  --! Number of clock cycles necessary for one micro second

  signal cnt_r          : std_ulogic_vector(9 downto 0);                   --! Counter implementing one micro second
  signal cnt_tc         : std_ulogic;                                      --! Counter reached value corresponding to one micro second
  signal micro_cnt_r    : std_ulogic_vector(9 downto 0);                   --! Counter of micro seconds
  signal micro_cnt_tc   : std_ulogic;                                      --! Counter reached value corresponding to one mili second
  signal mili_cnt_r     : std_ulogic_vector(9 downto 0);                   --! Counter of mili seconds
  signal expired        : std_ulogic;                                      --! Timer expired

begin
  ------------------------------
  -- Count to one micro second
  ------------------------------
  COUNT_TO_1_US_FF : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        cnt_r <= (others=>'0');
      else
        if enable_i = '1' then
          -- Don't count when timer is expired
          if expired = '0' then
            if unsigned(cnt_r) = (MICRO_SECOND-1) then
              cnt_r <= (others=>'0');
            else
              cnt_r <= std_ulogic_vector(unsigned(cnt_r)+1);
            end if;
          end if;
        else
          cnt_r <= (others=>'0');
        end if;
      end if;
    end if;
  end process COUNT_TO_1_US_FF;
  cnt_tc <= '1' when unsigned(cnt_r) = (MICRO_SECOND-1) else '0';

  ------------------------------
  -- Count micro seconds
  ------------------------------
  MICRO_SEC_FF : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        micro_cnt_r <= (others=>'0');
      else
        if enable_i = '1' then
          -- Update micro second counter when cnt reaches terminal count value
          if cnt_tc = '1' then
            if unsigned(micro_cnt_r) = 999 then
              -- If one mili second is reached restart counter
              micro_cnt_r <= (others=>'0');
            else
              micro_cnt_r <= std_ulogic_vector(unsigned(micro_cnt_r)+1);
            end if;
          end if;
        else
          -- Reset counter once timer is disabled
          micro_cnt_r <= (others=>'0');
        end if;
      end if;
    end if;
  end process MICRO_SEC_FF;
  micro_cnt_tc <= '1' when (unsigned(micro_cnt_r) = 999) and (cnt_tc = '1') else '0';

  ------------------------------
  -- Count mili seconds
  ------------------------------
  MILI_SEC_FF : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        mili_cnt_r <= (others=>'0');
      else
        if enable_i = '1' then
          -- Update mili second counter once micro counter reaches terminal count value
          if  cnt_tc = '1' and micro_cnt_tc = '1' then
            if unsigned(mili_cnt_r) = 999 then
              -- If one centi second is reached restart counter
              -- This should never occur because expired event must hapen before
              mili_cnt_r <= (others=>'0');
            else
              mili_cnt_r <= std_ulogic_vector(unsigned(mili_cnt_r)+1);
            end if;
          end if;
        else
          mili_cnt_r <= (others=>'0');
        end if;
      end if;
    end if;
  end process MILI_SEC_FF;

  ------------------------------
  -- Define when timer is expired
  ------------------------------
  expired <= '1' when ((micro_cnt_r = time_i) and (TIME_SCALE = "us")) else
             '1' when ((mili_cnt_r  = time_i) and (TIME_SCALE = "ms")) else '0';

  expired_o <= expired;

end architecture rtl;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-02-07  First draft.
-- 1.0      2016-03-07  Async resets modified. All resets are sync now
-- =============================================================================
