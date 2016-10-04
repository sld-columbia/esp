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
--!  @file         mmi64_buffer_uni_e.vhd
--!  @author       Norman Nolte, Sebastian Fluegel
--!  @email        norman.nolte@prodesign-europe.com
--!                sebastian.fluegel@prodesign-europe.com
--!  @brief        Unidirectional MMI64 buffer
--!                (component declaration package).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! @brief Unidirectional MMI64 Buffer for adding pipeline stages to the MMI64 bus.
--! @details Two of these buffer build build up a
--!           bidirectional buffer (see: mmi64_buffer.vhd). The user should
--!           have no need to instantiate mmi64_buffer_uni directly.
--!           Use mmi64_buffer instead.
entity mmi64_buffer_uni is
  port (
    -- clock and reset
    mmi64_clk   : in std_ulogic;        --! clock of mmi64 domain
    mmi64_reset : in std_ulogic;        --! reset of mmi64 domain

    -- buffer enable signal
    enable_i : in std_ulogic;           --! buffer accepts or provides data only if enabled

    --  mmi64 data input
    mmi64_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data input
    mmi64_valid_i  : in  std_ulogic;                                      --! mmi64 data input valid
    mmi64_accept_o : out std_ulogic;                                      --! mmi64 data input accept
    mmi64_start_i  : in  std_ulogic;                                      --! mmi64 data input packet start
    mmi64_stop_i   : in  std_ulogic;                                      --! mmi64 data inpur packet end

    -- mmi64 data output (buffered)
    mmi64_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data output
    mmi64_valid_o  : out std_ulogic;                                      --! mmi64 data output valid
    mmi64_accept_i : in  std_ulogic;                                      --! mmi64 data output accept
    mmi64_start_o  : out std_ulogic;                                      --! mmi64 data output packet start
    mmi64_stop_o   : out std_ulogic                                       --! mmi64 data output packet end
    );
end entity mmi64_buffer_uni;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_buffer_uni
package mmi64_buffer_uni_comp is

  --! see description of entity mmi64_buffer_uni
  component mmi64_buffer_uni
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;      --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;      --! reset of mmi64 domain

      -- buffer enable signal
      enable_i : in std_ulogic;         --! buffer accepts or provides data only if enabled

      --  mmi64 data input
      mmi64_d_i      : in  std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data input
      mmi64_valid_i  : in  std_ulogic;                                      --! mmi64 data input valid
      mmi64_accept_o : out std_ulogic;                                      --! mmi64 data input accept
      mmi64_start_i  : in  std_ulogic;                                      --! mmi64 data input packet start
      mmi64_stop_i   : in  std_ulogic;                                      --! mmi64 data inpur packet end

      -- mmi64 data output (buffered)
      mmi64_d_o      : out std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data output
      mmi64_valid_o  : out std_ulogic;                                      --! mmi64 data output valid
      mmi64_accept_i : in  std_ulogic;                                      --! mmi64 data output accept
      mmi64_start_o  : out std_ulogic;                                      --! mmi64 data output packet start
      mmi64_stop_o   : out std_ulogic                                       --! mmi64 data output packet end
      );
  end component;

end mmi64_buffer_uni_comp;
