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
--  Module/Entity : ethernet_crc (Architecture)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Ethernet CRC calculation
--	                Polynomial : 0x04c11db7
-- =============================================================================

-------------------
-- Architecture  --
-------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

architecture rtl of ethernet_crc is
  signal crc_r : std_ulogic_vector(crc_o'range);

begin
  CALCULATE_CRC_FF : process(clk)
    variable crc_v      : std_ulogic_vector(crc_r'range);
    variable feedback_v : std_ulogic;
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        crc_r <= (others=>'0');
      else
        if dv_i = '1' then
          crc_v := not crc_r;
          for bit_idx in 0 to data_i'length-1 loop
            feedback_v := crc_v(0) xor data_i(bit_idx);
  
            crc_v(0 ) := crc_v(1);
            crc_v(1 ) := crc_v(2);
            crc_v(2 ) := crc_v(3);
            crc_v(3 ) := crc_v(4);
            crc_v(4 ) := crc_v(5);
            crc_v(5 ) := crc_v(6)  xor feedback_v;
            crc_v(6 ) := crc_v(7);
            crc_v(7 ) := crc_v(8);
            crc_v(8 ) := crc_v(9)  xor feedback_v;
            crc_v(9 ) := crc_v(10) xor feedback_v;
            crc_v(10) := crc_v(11);
            crc_v(11) := crc_v(12);
            crc_v(12) := crc_v(13);
            crc_v(13) := crc_v(14);
            crc_v(14) := crc_v(15);
            crc_v(15) := crc_v(16) xor feedback_v;
            crc_v(16) := crc_v(17);
            crc_v(17) := crc_v(18);
            crc_v(18) := crc_v(19);
            crc_v(19) := crc_v(20) xor feedback_v;
            crc_v(20) := crc_v(21) xor feedback_v;
            crc_v(21) := crc_v(22) xor feedback_v;
            crc_v(22) := crc_v(23);
            crc_v(23) := crc_v(24) xor feedback_v;
            crc_v(24) := crc_v(25) xor feedback_v;
            crc_v(25) := crc_v(26);
            crc_v(26) := crc_v(27) xor feedback_v;
            crc_v(27) := crc_v(28) xor feedback_v;
            crc_v(28) := crc_v(29);
            crc_v(29) := crc_v(30) xor feedback_v;
            crc_v(30) := crc_v(31) xor feedback_v;
            crc_v(31) :=               feedback_v;
          end loop;
  
          crc_r <= not crc_v;
        end if;
      end if;
    end if;
  end process CALCULATE_CRC_FF;

  crc_o <= crc_r;


end architecture rtl;
-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-12-02  First draft.
-- 1.0      2016-02-07  Reset structure changed. All resets are sync now
-- =============================================================================
