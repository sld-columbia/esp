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
--  Module/Entity : ethernet_crc (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Ethernet CRC calculation
--	                Polynomial : 0x04c11db7
-- =============================================================================

-------------
-- Entity  --
-------------
library ieee;
    use ieee.std_logic_1164.all;
entity ethernet_crc is
  generic (
    DWIDTH               : integer := 8);
  port (
    clk                  : in  std_ulogic;                                   --! Input clock
    reset_n              : in  std_ulogic;                                   --! Input reset (Active low)
    dv_i                 : in  std_ulogic;                                   --! Data valid
    data_i               : in  std_ulogic_vector(DWIDTH-1 downto 0);         --! Data
    crc_o                : out std_ulogic_vector(31 downto 0)                --! CRC output
  );
end entity ethernet_crc;

------------------------
-- Component/Package  --
------------------------
library ieee;
    use ieee.std_logic_1164.all;
package ethernet_crc_comp is
  component ethernet_crc is
  generic (
    DWIDTH               : integer := 8);
  port (
    clk                  : in  std_ulogic;
    reset_n              : in  std_ulogic;
    dv_i                 : in  std_ulogic;
    data_i               : in  std_ulogic_vector(DWIDTH-1 downto 0);
    crc_o                : out std_ulogic_vector(31 downto 0)
  );
  end component ethernet_crc;
end package ethernet_crc_comp;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-12-02  First draft.
-- =============================================================================
