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
--!  @file         mmi64_msgsource.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 message generator (simulation only).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;
use work.txt_util.all;

entity mmi64_msgsource is
  generic (
    source_id : string := ""
    );
  port (
    -- clock and reset
    mmi64_clk      : in std_ulogic;     --! clock of mmi64 domain
    mmi64_reset    : in std_ulogic;     --! reset of mmi64 domain

    -- testbench control interface
    msg_data       : in  mmi64_data_vector_t;
    msg_length     : in  natural;
    msg_send       : in  std_ulogic;
    msg_busy       : out std_ulogic;

    -- ports for generated mmi64 message
    mmi64_d_o      : out mmi64_data_t;  --! mmi64 data
    mmi64_valid_o  : out std_ulogic;    --! mmi64 data valid
    mmi64_accept_i : in  std_ulogic;    --! mmi64 data accept
    mmi64_start_o  : out std_ulogic;    --! mmi64 start of message
    mmi64_stop_o   : out std_ulogic     --! mmi64 end of message
    );
end entity mmi64_msgsource;

--

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

--! component declaration package for mmi64_msgsource
package mmi64_msgsource_comp is

  --! see description of entity mmi64_msgsource
  component mmi64_msgsource is
    generic (
      source_id : string := ""
      );
    port (
      -- clock and reset
      mmi64_clk      : in std_ulogic;     --! clock of mmi64 domain
      mmi64_reset    : in std_ulogic;     --! reset of mmi64 domain

      -- testbench control interface
      msg_data       : in  mmi64_data_vector_t;
      msg_length     : in  natural;
      msg_send       : in  std_ulogic;
      msg_busy       : out std_ulogic;

      -- ports for generated mmi64 message
      mmi64_d_o      : out mmi64_data_t;  --! mmi64 data
      mmi64_valid_o  : out std_ulogic;    --! mmi64 data valid
      mmi64_accept_i : in  std_ulogic;    --! mmi64 data accept
      mmi64_start_o  : out std_ulogic;    --! mmi64 start of message
      mmi64_stop_o   : out std_ulogic     --! mmi64 end of message
      );
  end component mmi64_msgsource;

end mmi64_msgsource_comp;

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_pkg.all;

architecture beh of mmi64_msgsource is

  --! state definition for downstream state machine
  type mmi64_msgsource_state_t is (
    ST_MSGSOURCE_IDLE,
    ST_MSGSOURCE_TRANSFER
    );

  signal mmi64_msgsource_state_r     : mmi64_msgsource_state_t;
  signal mmi64_msgsource_state_r_nxt : mmi64_msgsource_state_t;

  signal msg_length_r        : natural;
  signal msg_length_r_nxt    : natural;

  signal msg_idx_r           : natural;
  signal msg_idx_r_nxt       : natural;

  signal valid               : std_ulogic := '1';

  signal mmi64_d      : mmi64_data_t;  --! mmi64 data
  signal mmi64_valid  : std_ulogic;    --! mmi64 data valid
  signal mmi64_start  : std_ulogic;    --! mmi64 start of message
  signal mmi64_stop   : std_ulogic;    --! mmi64 end of message

begin

  p_msgsource: process (mmi64_accept_i, mmi64_msgsource_state_r, msg_data, msg_idx_r, msg_length, msg_length_r, msg_send, valid)
  begin
    -- default assignments
    mmi64_msgsource_state_r_nxt <= mmi64_msgsource_state_r;
    msg_length_r_nxt  <= msg_length_r;
    msg_idx_r_nxt     <= msg_idx_r;
    mmi64_d           <= (others=>'-');
    mmi64_valid       <= '0';
    mmi64_start       <= '0';
    mmi64_stop        <= '0';
    msg_busy          <= '0';

    case mmi64_msgsource_state_r is
      when ST_MSGSOURCE_IDLE =>
        if msg_send = '1' then
          -- save message length
          msg_length_r_nxt <= msg_length;

          -- reset message send index
          msg_idx_r_nxt <= 0;

          -- advance to message transmission
          mmi64_msgsource_state_r_nxt <= ST_MSGSOURCE_TRANSFER;
        end if;

      when ST_MSGSOURCE_TRANSFER =>
        -- message generator is busy
        msg_busy          <= '1';

        -- output data word
        mmi64_d      <= msg_data(msg_idx_r);
        mmi64_valid  <= valid;

        -- generate start flag
        if msg_idx_r = 0 then
          mmi64_start <= '1';
        end if;

        -- generate stop flag
        if msg_idx_r = msg_length_r-1 then
          mmi64_stop <= '1';
        end if;

        if mmi64_accept_i = '1' and valid='1' then
          -- advance to next data word
          msg_idx_r_nxt <= msg_idx_r + 1;

          -- final transfer?
          if msg_idx_r = msg_length_r-1 then
            -- return to idle state
            mmi64_msgsource_state_r_nxt <= ST_MSGSOURCE_IDLE;
          end if;
        end if;
    end case;

  end process p_msgsource;

  p_ff: process (mmi64_clk)
  begin  -- process p_ff
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
        mmi64_msgsource_state_r <= ST_MSGSOURCE_IDLE;
        msg_length_r            <= 0;
        msg_idx_r               <= 0;
      else
        mmi64_msgsource_state_r <= mmi64_msgsource_state_r_nxt;
        msg_length_r            <= msg_length_r_nxt;
        msg_idx_r               <= msg_idx_r_nxt;
      end if;

      if mmi64_valid='1' and mmi64_accept_i = '1' then
--        print("source " & source_id & ": " & hstr(std_logic_vector(mmi64_d)) & " " & str(mmi64_start) & " " & str(mmi64_stop));
      end if;
    end if;
  end process p_ff;

  mmi64_d_o      <= mmi64_d;
  mmi64_valid_o  <= mmi64_valid;
  mmi64_start_o  <= mmi64_start;
  mmi64_stop_o   <= mmi64_stop;

end beh;
