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
--!  @file         mmi64_deserializer_e.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 data word deserializer joins single bytes into
--!                64 bit data word establishing packet framing.
--!                (entity and component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

entity mmi64_deserializer is
  generic (
    SERIAL_DATA_WIDTH : natural := 8                                           --! serial data width (in number of bits)
    );
  port (
    -- clock and reset
    mmi64_clk           : in std_ulogic;                                       --! clock of mmi64 domain
    mmi64_reset         : in std_ulogic;                                       --! reset of mmi64 domain

    -- serial data input
    serial_d_i          : in  std_ulogic_vector(SERIAL_DATA_WIDTH-1 downto 0); --! serial data input
    serial_valid_i      : in  std_ulogic;                                      --! serial data valid
    serial_ready_o      : out std_ulogic;                                      --! serial data ready to accept

    -- mmi64 buffer connections towards modules
    mmi64_m_dn_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to downstream router or module
    mmi64_m_dn_valid_o  : out std_ulogic;                                      --! mmi64 data valid to downstream router or module
    mmi64_m_dn_accept_i : in  std_ulogic;                                      --! mmi64 data accept from downstream router or module
    mmi64_m_dn_start_o  : out std_ulogic;                                      --! mmi64 data packet start to downstream router or module
    mmi64_m_dn_stop_o   : out std_ulogic                                       --! mmi64 data packet end to downstream router or module
    );
end entity mmi64_deserializer;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_deserializer
package mmi64_deserializer_comp is

  --! see description of entity mmi64_deserializer
  component mmi64_deserializer
    generic (
      SERIAL_DATA_WIDTH : natural := 8                                           --! serial data width (in number of bits)
      );
    port (
      -- clock and reset
      mmi64_clk         : in std_ulogic;                                         --! clock of mmi64 domain
      mmi64_reset       : in std_ulogic;                                         --! reset of mmi64 domain

      -- serial data input
      serial_d_i          : in  std_ulogic_vector(SERIAL_DATA_WIDTH-1 downto 0); --! serial data input
      serial_valid_i      : in  std_ulogic;                                      --! serial data valid
      serial_ready_o      : out std_ulogic;                                      --! serial data ready to accept

      -- mmi64 buffer connections towards modules
      mmi64_m_dn_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data to downstream router or module
      mmi64_m_dn_valid_o  : out std_ulogic;                                      --! mmi64 data valid to downstream router or module
      mmi64_m_dn_accept_i : in  std_ulogic;                                      --! mmi64 data accept from downstream router or module
      mmi64_m_dn_start_o  : out std_ulogic;                                      --! mmi64 data packet start to downstream router or module
      mmi64_m_dn_stop_o   : out std_ulogic                                       --! mmi64 data packet end to downstream router or module
      );
  end component;

end mmi64_deserializer_comp;
