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
--!  @file         mmi64_m_devzero_a.vhd
--!  @author       Martin Langner
--!  @email        martin.langner@prodesign-europe.com
--!  @brief        MMI64 module for speedtests
--!                (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rtl_templates.all;

--! implementation of mmi64_m_devzero
architecture rtl of mmi64_m_devzero is

  --! downstream state machine of register file
  type mmi64_devzero_downstream_state is (
    ST_MMI64_DEVZERO_DN_IDLE,           --! wait for start of new message
    ST_MMI64_DEVZERO_DN_CONTROL_WORD,   --! receive and evaluate control word
    ST_MMI64_DEVZERO_DN_WRITE
    );

  --! upstream state machine of register file
  type mmi64_devzero_upstream_state is (
    ST_MMI64_DEVZERO_UP_IDLE,                 --! wait for request to generate upstream message
    ST_MMI64_DEVZERO_UP_WRITE_ACK_HEADER,     --! generate write acknoledgement message
    ST_MMI64_DEVZERO_UP_READ_HEADER,          --! generate read header
    ST_MMI64_DEVZERO_UP_READ,                 --! generate read payload
    ST_MMI64_DEVZERO_UP_IDENTIFY_HEADER,      --! generate identify response header
    ST_MMI64_DEVZERO_UP_IDENTIFY_TYPE_AND_ID  --! generate identify unique module id and type id
    );

  --! number of data words in identify response from router
  constant MMI64_MODULE_IDENTIFY_PAYLOAD_LEN : natural := 1;

  -- list of module specific commands
  constant MMI64_CMD_DEVZERO_READ      : mmi64_command_t := x"20";  --! register read access
  constant MMI64_CMD_DEVZERO_WRITE     : mmi64_command_t := x"21";  --! register write access
  constant MMI64_CMD_DEVZERO_WRITE_ACK : mmi64_command_t := x"22";  --! register write access with acknowlement

  -- module downstream state machine
  signal dn_devzero_state_r     : mmi64_devzero_downstream_state;
  signal dn_devzero_state_r_nxt : mmi64_devzero_downstream_state;

  -- downstream payload length
  signal dn_payload_length_r     : mmi64_payload_length_t;
  signal dn_payload_length_r_nxt : mmi64_payload_length_t;

  -- command to perform
  signal dn_command_r     : mmi64_command_t;
  signal dn_command_r_nxt : mmi64_command_t;

  -- tag required for read and write acknowledgement responses to host requests
  signal dn_tag_r     : mmi64_tag_t;
  signal dn_tag_r_nxt : mmi64_tag_t;

  -- tag required for identify responses to host requests
  signal dn_identify_tag_r     : mmi64_tag_t;
  signal dn_identify_tag_r_nxt : mmi64_tag_t;

  -- downstream to upstream  identify request
  signal dn_do_identify_r     : std_ulogic;
  signal dn_do_identify_r_nxt : std_ulogic;

  -- downstream to upstream write acknowledge request
  signal dn_do_write_ack_r     : std_ulogic;
  signal dn_do_write_ack_r_nxt : std_ulogic;

  -- downstream to upstream read request
  signal dn_do_read_r     : std_ulogic;
  signal dn_do_read_r_nxt : std_ulogic;

  -- downstream to upstream requested payload length
  signal up_payload_to_send_r     : mmi64_payload_length_t;
  signal up_payload_to_send_r_nxt : mmi64_payload_length_t;

  -- module upstream state machine
  signal up_devzero_state_r     : mmi64_devzero_upstream_state;
  signal up_devzero_state_r_nxt : mmi64_devzero_upstream_state;

  -- feedback from upstream to downstream path requests
  signal up_identify_done  : std_ulogic;
  signal up_read_done      : std_ulogic;
  signal up_write_ack_done : std_ulogic;

  -- register subword access counter
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal up_words_to_send_r     : mmi64_payload_length_t;
  signal up_words_to_send_r_nxt : mmi64_payload_length_t;

  -- data register
  signal mmi64_data_r : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);

begin

  -- downstream path of register file
  p_devzero_downstream : process (dn_command_r, dn_devzero_state_r, dn_do_identify_r, dn_do_read_r, dn_do_write_ack_r, dn_identify_tag_r, dn_payload_length_r, dn_tag_r, mmi64_h_dn_d_i, mmi64_h_dn_start_i, mmi64_h_dn_valid_i, up_identify_done, up_payload_to_send_r, up_read_done, up_write_ack_done)
  begin  -- process p_rf
    -- default assignments
    dn_devzero_state_r_nxt   <= dn_devzero_state_r;
    dn_payload_length_r_nxt  <= dn_payload_length_r;
    dn_command_r_nxt         <= dn_command_r;
    dn_do_identify_r_nxt     <= dn_do_identify_r;
    dn_do_write_ack_r_nxt    <= dn_do_write_ack_r;
    dn_do_read_r_nxt         <= dn_do_read_r;
    dn_tag_r_nxt             <= dn_tag_r;
    dn_identify_tag_r_nxt    <= dn_identify_tag_r;
    up_payload_to_send_r_nxt <= up_payload_to_send_r;

    -- do not accept downstream data
    mmi64_h_dn_accept_o <= '0';

    -- reset mmi64 identify request flag
    if (up_identify_done = '1') then
      dn_do_identify_r_nxt <= '0';
    end if;

    -- reset write acknowledgement request flag
    if (up_write_ack_done = '1') then
      dn_do_write_ack_r_nxt <= '0';
    end if;

    -- reset read request flag
    if (up_read_done = '1') then
      dn_do_read_r_nxt <= '0';
    end if;

    case dn_devzero_state_r is
      when ST_MMI64_DEVZERO_DN_IDLE =>
        -- ST_MMI64_DEVZERO_DN_IDLE is a special state handled below
        null;

-- *
-- ** register file specific states
-- *

      when ST_MMI64_DEVZERO_DN_WRITE =>
        -- *** real all incoming data

        -- advance to next data word by accepting downstream data
        mmi64_h_dn_accept_o <= '1';

        -- write data valid?
        if mmi64_h_dn_valid_i = '1' then
       --DD   mmi64_data_r <= mmi64_h_dn_d_i;
          
          -- decrease payload length
          dn_payload_length_r_nxt <= dn_payload_length_r - 1;

          -- if terminal payload word, stop transfer
          if (dn_payload_length_r = to_unsigned(1, dn_payload_length_r'length)) then
            if dn_command_r = MMI64_CMD_DEVZERO_WRITE_ACK then
              -- trigger generation of write acknowledge message
              dn_do_write_ack_r_nxt <= '1';
            end if;

            -- return to idle state
            dn_devzero_state_r_nxt <= ST_MMI64_DEVZERO_DN_IDLE;
          end if;
        end if;

        
      when ST_MMI64_DEVZERO_DN_CONTROL_WORD =>
        -- *** receive control word for read
        up_payload_to_send_r_nxt <= resize(unsigned(mmi64_h_dn_d_i(15 downto 0)), up_payload_to_send_r_nxt'length);

        -- accept downstream data
        mmi64_h_dn_accept_o <= '1';

        if mmi64_h_dn_valid_i = '1' then
          -- trigger upstream read message generation
          dn_do_read_r_nxt <= '1';

          -- return to idle state
          dn_devzero_state_r_nxt <= ST_MMI64_DEVZERO_DN_IDLE;
        end if;

    end case;


    -- special handling for idle state, always going back to idle when start flag is set
    if (dn_devzero_state_r = ST_MMI64_DEVZERO_DN_IDLE) or (mmi64_h_dn_valid_i = '1' and mmi64_h_dn_start_i = '1') then

      -- stay in idle state (or go back to it on start)
      dn_devzero_state_r_nxt <= ST_MMI64_DEVZERO_DN_IDLE;

      -- accept incoming data
      mmi64_h_dn_accept_o <= '1';

      -- wait for valid data start of new message
      if (mmi64_h_dn_valid_i = '1') and (mmi64_h_dn_start_i = '1') then

        -- store mmi64 command for operation mode decisions
        dn_command_r_nxt <= mmi64_command(mmi64_h_dn_d_i);

        -- store mmi64 tag for responses to upstream
        dn_tag_r_nxt <= mmi64_tag(mmi64_h_dn_d_i);

        -- extract mmi64 tag header
        dn_identify_tag_r_nxt <= mmi64_tag(mmi64_h_dn_d_i);

        -- save mmi64 payload length for processing of write accesses
        dn_payload_length_r_nxt <= mmi64_payload_length(mmi64_h_dn_d_i);

        if mmi64_header_is_valid(mmi64_h_dn_d_i) then
          -- evaluate downstream command
          case mmi64_command_t'(mmi64_command(mmi64_h_dn_d_i)) is
            when MMI64_CMD_INITIALIZE =>
              -- TODO: unblock upstream path
              null;

            when MMI64_CMD_IDENTIFY =>
              -- trigger generation of identify response
              dn_do_identify_r_nxt <= '1';

            when MMI64_CMD_DEVZERO_READ =>
              dn_devzero_state_r_nxt <= ST_MMI64_DEVZERO_DN_CONTROL_WORD;
              
            when MMI64_CMD_DEVZERO_WRITE | MMI64_CMD_DEVZERO_WRITE_ACK =>
              dn_devzero_state_r_nxt <= ST_MMI64_DEVZERO_DN_WRITE;

            when others =>
              -- other commands are not supported an will be ignored
              null;
          end case;
        end if;
      end if;
    end if;

  end process p_devzero_downstream;


  -- upstream path of register file
  p_devzero_upstream : process (dn_do_identify_r, dn_do_read_r, dn_do_write_ack_r, dn_identify_tag_r, dn_tag_r, mmi64_h_up_accept_i, up_devzero_state_r, up_payload_to_send_r, up_words_to_send_r, mmi64_data_r)
    variable mmi64_data_v : mmi64_data_t;
  begin
    -- default assignments
    up_devzero_state_r_nxt <= up_devzero_state_r;
    up_words_to_send_r_nxt <= up_words_to_send_r;

    up_identify_done  <= '0';
    up_read_done      <= '0';
    up_write_ack_done <= '0';

    -- disable upstream port
    mmi64_h_up_valid_o <= '0';
    mmi64_h_up_start_o <= '0';
    mmi64_h_up_stop_o  <= '0';
    mmi64_h_up_d_o     <= (others => '-');

    case up_devzero_state_r is
      when ST_MMI64_DEVZERO_UP_IDLE =>
        if dn_do_write_ack_r = '1' then
          -- generate write acknowledge reponse
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_WRITE_ACK_HEADER;
        elsif dn_do_read_r = '1' then
          -- generate read response
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_READ_HEADER;
          up_words_to_send_r_nxt <= up_payload_to_send_r;
        elsif dn_do_identify_r = '1' then
          -- generate identify reponse
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDENTIFY_HEADER;
        end if;

-- **
-- *** write acknoledgement related states
-- **

      when ST_MMI64_DEVZERO_UP_WRITE_ACK_HEADER =>

        -- generate mmi64 packet header for register write acknowledgement
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_DEVZERO_WRITE_ACK,   -- command
          MMI64_ZERO_COMMAND_PARAMETER,  -- command parameter
          MMI64_ZERO_PAYLOAD_LENGTH,     -- payload length
          dn_tag_r                       -- tag
          );

        -- set start and stop flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';
        mmi64_h_up_stop_o  <= '1';

        -- indicate write acknowledge request is fulfilled
        up_write_ack_done <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDLE;
        end if;

-- **
-- *** read related states
-- **

      when ST_MMI64_DEVZERO_UP_READ_HEADER =>

        -- generate mmi64 packet header for register read
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_DEVZERO_READ,        -- command
          MMI64_ZERO_COMMAND_PARAMETER,  -- command parameter
          up_words_to_send_r,            -- payload length
          dn_tag_r                       -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          -- handle zero length read request properly
          if up_words_to_send_r = 0 then
            -- indicate read request is fulfilled
            up_read_done <= '1';

            -- return to idle state
            up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDLE;
          else
            up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_READ;
          end if;
        end if;

      when ST_MMI64_DEVZERO_UP_READ =>

        -- send only zeros
        mmi64_h_up_d_o <= mmi64_data_r; -- ensure that no bit is synthesized away

        -- make data word available to upstream
        mmi64_h_up_valid_o <= '1';

        if up_words_to_send_r = 1 then
          mmi64_h_up_stop_o <= '1';
        end if;

        -- upstream accepts data word?
        if (mmi64_h_up_accept_i = '1') then

          if up_words_to_send_r = 1 then
            -- indicate read request is fulfilled
            up_read_done <= '1';

            -- return to idle state
            up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDLE;
          end if;
          
          up_words_to_send_r_nxt <= up_words_to_send_r - 1;
          
        end if;

-- **
-- *** identify related states
-- **

      when ST_MMI64_DEVZERO_UP_IDENTIFY_HEADER =>

        -- generate mmi64 packet header for register write acknowledgement
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_IDENTIFY,                                                             -- command
          MMI64_ZERO_COMMAND_PARAMETER,                                                   -- command parameter
          to_unsigned(MMI64_MODULE_IDENTIFY_PAYLOAD_LEN, mmi64_payload_length_t'length),  -- payload length
          dn_identify_tag_r                                                               -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        -- inform downstream path that identify request is handled
        up_identify_done <= '1';

        -- indicate write acknowledge request is fulfilled
        up_write_ack_done <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDENTIFY_TYPE_AND_ID;
        end if;

      when ST_MMI64_DEVZERO_UP_IDENTIFY_TYPE_AND_ID =>
        -- generate common identify response
        mmi64_data_v                               := (others => '0');
        mmi64_data_v(mmi64_identify_module_type_r) := std_ulogic_vector(MMI64_TID_M_DEVZERO);
        mmi64_data_v(mmi64_identify_module_id_r)   := convert(MODULE_ID);

        -- send identify data to upstream
        mmi64_h_up_d_o     <= mmi64_data_v;
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_stop_o  <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_devzero_state_r_nxt <= ST_MMI64_DEVZERO_UP_IDLE;
        end if;

    end case;

  end process p_devzero_upstream;

  -- create registers
  p_ff : process (mmi64_clk)
  begin  -- process ff
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then         -- synchronous reset
        dn_devzero_state_r     <= ST_MMI64_DEVZERO_DN_IDLE;
        dn_command_r           <= (others => '0');
        dn_payload_length_r    <= (others => '0');
        dn_tag_r               <= (others => '0');
        dn_identify_tag_r      <= (others => '0');
        dn_do_identify_r       <= '0';
        dn_do_write_ack_r      <= '0';
        dn_do_read_r           <= '0';

        up_payload_to_send_r  <= (others => '0');

        up_devzero_state_r    <= ST_MMI64_DEVZERO_UP_IDLE;
        up_words_to_send_r    <= (others => '0');
        mmi64_data_r          <= (others => '0');
      else
        -- write data valid?
        if (mmi64_h_dn_valid_i = '1') and  (dn_devzero_state_r = ST_MMI64_DEVZERO_DN_WRITE) then
          mmi64_data_r <= mmi64_h_dn_d_i;
        end if;
        dn_devzero_state_r     <= dn_devzero_state_r_nxt;
        dn_command_r           <= dn_command_r_nxt;
        dn_payload_length_r    <= dn_payload_length_r_nxt;
        dn_tag_r               <= dn_tag_r_nxt;
        dn_identify_tag_r      <= dn_identify_tag_r_nxt;
        dn_do_identify_r       <= dn_do_identify_r_nxt;
        dn_do_write_ack_r      <= dn_do_write_ack_r_nxt;
        dn_do_read_r           <= dn_do_read_r_nxt;

        up_payload_to_send_r <= up_payload_to_send_r_nxt;

        up_devzero_state_r <= up_devzero_state_r_nxt;
        up_words_to_send_r <= up_words_to_send_r_nxt;
      end if;

    end if;
  end process p_ff;

end architecture rtl;
