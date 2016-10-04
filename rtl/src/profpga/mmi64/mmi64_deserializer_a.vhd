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
--!  @file         mmi64_deserializer_a.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 data word deserializer joins single bytes into
--!                64 bit data word establishing packet framing.
--!                (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rtl_templates.all;
use work.mmi64_pkg.all;

architecture rtl of mmi64_deserializer is

  --! number of serial data transfers required to complete mmi64 data word
  constant SERIAL_TRANSFERS_PER_MMI64_WORD : natural := MMI64_DATA_WIDTH / SERIAL_DATA_WIDTH;

  --! type of nnu64 data word fill level for deserialization
  subtype mmi64_data_fill_level_t is unsigned(Log2(SERIAL_TRANSFERS_PER_MMI64_WORD) downto 0);

  -- mmi64 data word to be deserialized
  signal mmi64_data_r     : mmi64_data_t;
  signal mmi64_data_r_nxt : mmi64_data_t;

  -- number of serial data words the mmi64 data register is currently filled with
  signal mmi64_data_fill_level_r     : mmi64_data_fill_level_t;
  signal mmi64_data_fill_level_r_nxt : mmi64_data_fill_level_t;

  --! message payload word counter
  signal payload_counter_r     : mmi64_payload_length_t;
  signal payload_counter_r_nxt : mmi64_payload_length_t;
  
  signal serial_ready_nxt      : std_ulogic;
  signal serial_ready_r        : std_ulogic;
  
  signal mmi64_start_r          : std_ulogic;
  signal mmi64_start_next       : std_ulogic;

begin

  --! deserialize incoming n bit data words into mmi64 data word
  p_deserialize: process (mmi64_data_fill_level_r, mmi64_data_r, mmi64_m_dn_accept_i, payload_counter_r, serial_d_i, serial_valid_i, mmi64_start_r)
    variable mmi64_data_fill_level_v : mmi64_data_fill_level_t;
    variable serial_read_enable_v    : std_ulogic;
    variable mmi64_data_valid_v      : std_ulogic;
    variable mmi64_start_v           : std_ulogic;
    variable mmi64_stop_v            : std_ulogic;

  begin
    -- set default assignments
    mmi64_data_r_nxt            <= mmi64_data_r;
    mmi64_data_fill_level_r_nxt <= mmi64_data_fill_level_r;
    payload_counter_r_nxt       <= payload_counter_r;

    mmi64_m_dn_valid_o          <= '0';  -- no ready to provide data to downstream module port
    serial_ready_nxt            <= '0';  -- not ready to accept serial input data
    mmi64_m_dn_start_o          <= '0';  -- assume not start of an mmi64 message
    mmi64_m_dn_stop_o           <= '0';  -- assume not end of an mmi64 message

    -- get a local copy of data buffer fill level for combinatorial modification
    mmi64_data_fill_level_v     := mmi64_data_fill_level_r;

    -- assume content of mmi64 data buffer is not yet valid
    mmi64_data_valid_v := '0';
    mmi64_start_v      := mmi64_start_r;
    mmi64_stop_v       := '0';

    -- assume mmi64 buffer word needs to be updated with serial data
    serial_read_enable_v := '1';

    -- *** evaluate data currently available in mmi64 data buffer and deliver data to downstream module port

    -- mmi64 data register is completely filled with serial data?
    if (mmi64_data_fill_level_r = to_unsigned(SERIAL_TRANSFERS_PER_MMI64_WORD, mmi64_data_fill_level_r'length)) then

      -- ongoing message payload transfer?
      if (payload_counter_r /= to_unsigned(0, payload_counter_r'length)) then
        -- try to deliver data to downstream port
        mmi64_data_valid_v := '1';
      elsif mmi64_header_is_valid(mmi64_data_r) then
        -- so this is (potentially) the start of new message, so offer data to downstream module port
        mmi64_data_valid_v := '1';

        -- set start flag
        mmi64_start_v := '1';

        -- extract payload length from header data
        payload_counter_r_nxt <= mmi64_payload_length(mmi64_data_r);

        -- set the stop flag if this is a zero payload length message
        if mmi64_payload_length(mmi64_data_r) = 0 then
          mmi64_stop_v := '1';
        end if;

      end if;
    end if;

    -- *** provide mmi64 buffer data on downstream module port

    if mmi64_data_valid_v = '1' then
      -- offer data to downstream port
      mmi64_m_dn_valid_o  <= '1';

      -- set start flag on first word of mmi64 message
      mmi64_m_dn_start_o  <= mmi64_start_v;

      -- set stop flag on last word of mmi64 message
      if (payload_counter_r = 1 and mmi64_start_v = '0') or mmi64_stop_v = '1' then
        mmi64_m_dn_stop_o  <= '1';
      end if;

      -- downstream ports accepts data?
      if mmi64_m_dn_accept_i = '1' then

        -- decrease payload counter if not already zero
        if (payload_counter_r /= to_unsigned(0, payload_counter_r'length)) then
          if mmi64_start_v = '0' then
            -- decrease payload only if inital value is accepted
            payload_counter_r_nxt <= payload_counter_r - 1;
          end if;
        end if;

        -- empty mmi64 data register by resetting fill level counter
        mmi64_data_fill_level_v := (others=>'0');
      else
        -- downstream port is not able to accept data, so hold data buffer content
        serial_read_enable_v := '0';
      end if;

    end if;

    -- *** shift in fresh data from serial input port

    -- request to update mmi64 data buffer with serial data?
    if serial_read_enable_v='1' then

      -- indicate acceptance of serial input data;
      serial_ready_nxt<= '1';

      -- data on serial input is valid?
      if serial_valid_i = '1' then

        -- shift mmi64 data buffer and insert serial data bits at most significant bit positions
        mmi64_data_r_nxt <= serial_d_i & mmi64_data_r(mmi64_data_r'length-1 downto SERIAL_DATA_WIDTH);

        -- update mmi64 data buffer fill level
        mmi64_data_fill_level_v := mmi64_data_fill_level_v + 1;
      end if;
    end if;

    -- update mmi64 data buffer fill level after (potential) buffer refill
    mmi64_data_fill_level_r_nxt <= mmi64_data_fill_level_v;
    
    -- extend start if not accepted
    if mmi64_m_dn_accept_i = '0' then
      mmi64_start_next <= mmi64_start_v;
    else
      mmi64_start_next <= '0';
    end if;

  end process p_deserialize;

  --! create registers
  p_ff: process (mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
        mmi64_data_r            <= (others=>'1');
        mmi64_data_fill_level_r <= (others=>'0');
        payload_counter_r       <= (others=>'0');
        serial_ready_r          <= '0';
        mmi64_start_r           <= '0';
      else
        mmi64_data_r            <= mmi64_data_r_nxt;
        mmi64_data_fill_level_r <= mmi64_data_fill_level_r_nxt;
        payload_counter_r       <= payload_counter_r_nxt;
        serial_ready_r          <= serial_ready_nxt;
        mmi64_start_r           <= mmi64_start_next;
      end if;
    end if;

  end process p_ff;

  -- assign output ports
  mmi64_m_dn_d_o     <= mmi64_data_r;
  
  serial_ready_o <= serial_ready_nxt;

end architecture rtl;
