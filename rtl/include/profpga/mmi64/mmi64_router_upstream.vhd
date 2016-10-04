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
--!  @file         mmi64_router_upstream.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 router upstream port used internally by mmi64 router.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

entity mmi64_router_upstream is
  port (
    -- clock and reset
    mmi64_clk   : in std_ulogic;        --! clock of mmi64 domain
    mmi64_reset : in std_ulogic;        --! reset of mmi64 domain

    -- connections to mmi64 modules or downstream router
    mmi64_m_up_d_i      : in  mmi64_data_t;  --! data from downstream router or module
    mmi64_m_up_valid_i  : in  std_ulogic;    --! data valid from downstream router or module
    mmi64_m_up_accept_o : out std_ulogic;    --! data accept to downstream router or module
    mmi64_m_up_start_i  : in  std_ulogic;    --! start of packet from downstream router or module
    mmi64_m_up_stop_i   : in  std_ulogic;    --! end of packet from  downstream router or module

    -- router internal connections
    up_resync_i         : in  std_ulogic;    --! trigger
    up_request_o        : out std_ulogic;    --! module requests transfer
    up_last_o           : out std_ulogic;    --! last packet of mmi64 message transfer

    up_payload_o        : out mmi64_data_t;  --! payload from downstream router or module
    up_payload_valid_o  : out std_ulogic;    --! payload valid from downstream router or module
    up_payload_accept_i : in  std_ulogic     --! payload accept to downstream router or module
    );
end mmi64_router_upstream;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_router
package mmi64_router_upstream_comp is

  component mmi64_router_upstream is
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;      --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;      --! reset of mmi64 domain

      -- connections to mmi64 modules or downstream router
      mmi64_m_up_d_i      : in  mmi64_data_t;  --! data from downstream router or module
      mmi64_m_up_valid_i  : in  std_ulogic;    --! data valid from downstream router or module
      mmi64_m_up_accept_o : out std_ulogic;    --! data accept to downstream router or module
      mmi64_m_up_start_i  : in  std_ulogic;    --! start of packet from downstream router or module
      mmi64_m_up_stop_i   : in  std_ulogic;    --! end of packet from  downstream router or module

      -- router internal connections
      up_resync_i         : in  std_ulogic;    --! trigger
      up_request_o        : out std_ulogic;    --! module requests transfer
      up_last_o           : out std_ulogic;    --! last packet of mmi64 message transfer

      up_payload_o        : out mmi64_data_t;  --! payload from downstream router or module
      up_payload_valid_o  : out std_ulogic;    --! payload valid from downstream router or module
      up_payload_accept_i : in  std_ulogic     --! payload accept to downstream router or module
      );
  end component mmi64_router_upstream;

end package mmi64_router_upstream_comp;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;

architecture rtl of mmi64_router_upstream is

  signal mmi64_insync_r     : std_ulogic;  --! sync status (register)
  signal mmi64_insync_r_nxt : std_ulogic;  --! sync status (next)

  signal mmi64_buffer_r     : mmi64_data_t; --! upstream data buffer (register)
  signal mmi64_buffer_r_nxt : mmi64_data_t; --! upstream data buffer (next)

  signal mmi64_buffer_valid_r     : std_ulogic; --! upstream data buffer valid (register)
  signal mmi64_buffer_valid_r_nxt : std_ulogic; --! upstream data buffer valid (next)

  signal up_request_r     : std_ulogic;  --! upstream transfer request (register)
  signal up_request_r_nxt : std_ulogic;  --! upstream transfer request (next)

  signal up_last_r        : std_ulogic;  --! upstream transfer complete (register)
  signal up_last_r_nxt    : std_ulogic;  --! upstream transfer complete (next)

begin  -- rtl

  -- check header information
  p_check_header : process (mmi64_insync_r, mmi64_m_up_d_i, mmi64_m_up_start_i, mmi64_m_up_valid_i, up_resync_i, up_request_r)
  begin
    -- default settings
    up_request_r_nxt   <= up_request_r;
    mmi64_insync_r_nxt <= mmi64_insync_r;

    if (mmi64_m_up_valid_i = '1') and (mmi64_m_up_start_i = '1') and mmi64_header_is_valid(mmi64_m_up_d_i) then
      -- set sync if current data word is a valid header and start flag is set
      mmi64_insync_r_nxt <= '1';

      -- request upstream routing
      up_request_r_nxt   <= '1';

    elsif up_resync_i = '1' then
      -- clear sync state on resync request
      mmi64_insync_r_nxt <= '0';
      up_request_r_nxt   <= '0';

    end if;

  end process p_check_header;

  p_buffer : process (mmi64_buffer_r, mmi64_buffer_valid_r, mmi64_insync_r, mmi64_m_up_d_i, mmi64_m_up_stop_i, mmi64_m_up_valid_i, up_last_r, up_payload_accept_i)
  begin
    -- hold upstream data
    mmi64_buffer_r_nxt       <= mmi64_buffer_r;
    mmi64_buffer_valid_r_nxt <= mmi64_buffer_valid_r;

    -- hold message last state
    up_last_r_nxt            <= up_last_r;

    -- do not accept input data
    mmi64_m_up_accept_o  <= '0';

    -- fifo is not in sync, buffer is invalid or router accepts data?
    if (mmi64_insync_r = '0') or (mmi64_buffer_valid_r = '0') or (up_payload_accept_i = '1') then
      -- discard module upstream data until resync
      mmi64_m_up_accept_o <= '1';

      -- update internal buffer
      mmi64_buffer_r_nxt       <= mmi64_m_up_d_i;
      mmi64_buffer_valid_r_nxt <= mmi64_m_up_valid_i;
      up_last_r_nxt            <= mmi64_m_up_stop_i;
    end if;

  end process p_buffer;

  -- assign outputs
  up_payload_o       <= mmi64_buffer_r;
  up_payload_valid_o <= mmi64_buffer_valid_r;
  up_request_o       <= up_request_r;
  up_last_o          <= up_last_r;

  p_ff : process(mmi64_clk)
  begin  -- process
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
        mmi64_insync_r <= '0';   -- not in sync after reset
        up_request_r   <= '0';
        up_last_r      <= '0';
      else
        mmi64_insync_r <= mmi64_insync_r_nxt;
        up_request_r   <= up_request_r_nxt;
        up_last_r      <= up_last_r_nxt;
      end if;

      mmi64_buffer_r <= mmi64_buffer_r_nxt;
      mmi64_buffer_valid_r <= mmi64_buffer_valid_r_nxt;
    end if;
  end process;

end rtl;
