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
--!  @file         mmi64_m_regif_a.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 module for accessing register files
--!                (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rtl_templates.all;
use work.mmi64_regfifo_comp.all;

--! implementation of mmi64_m_regif
architecture rtl of mmi64_m_regif is

  --! downstream state machine of register file
  type mmi64_regif_downstream_state is (
    ST_MMI64_REGIF_DN_IDLE,            --! wait for start of new message
    ST_MMI64_REGIF_DN_CONTROL_WORD,    --! receive and evaluate control word
    ST_MMI64_REGIF_DN_READ,
    ST_MMI64_REGIF_DN_WRITE
    );

  --! upstream state machine of register file
  type mmi64_regif_upstream_state is (
    ST_MMI64_REGIF_UP_IDLE,                      --! wait for request to generate upstream message
    ST_MMI64_REGIF_UP_WRITE_ACK_HEADER,          --! generate write acknoledgement message
    ST_MMI64_REGIF_UP_READ_HEADER,               --! generate read header
    ST_MMI64_REGIF_UP_READ,                      --! generate read payload
    ST_MMI64_REGIF_UP_IDENTIFY_HEADER,           --! generate identify response header
    ST_MMI64_REGIF_UP_IDENTIFY_TYPE_AND_ID,      --! generate identify unique module id and type id
    ST_MMI64_REGIF_UP_IDENTIFY_MODULE_PARAMETER  --! generate identify module specific response
    );

  --! register address width
  constant MMI64_REGIF_REGISTER_ADDR_WIDTH : natural := Log2(REGISTER_COUNT);

  --! shift width related to subword width
  constant MMI64_SUBWORD_SHIFT_WIDTH    : natural := Log2(REGISTER_WIDTH);

  --! shift width related to mmi64 data width
  constant MMI64_DATA_SHIFT_WIDTH       : natural := Log2(MMI64_DATA_WIDTH);

  --! number of subword accesses required for each MMI64 payload data word (1, 2, 4 or 8)
  constant MMI64_SUBWORDS_PER_DATA_WORD   : natural := MMI64_DATA_WIDTH / REGISTER_WIDTH;

  --! width of subword access counter
  constant MMI64_SUBWORD_COUNTER_WIDTH  : natural := Log2(MMI64_SUBWORDS_PER_DATA_WORD);

  --! number of data words in identify response from router
  constant MMI64_MODULE_IDENTIFY_PAYLOAD_LEN : natural := 2;

  -- list of module specific commands
  constant MMI64_CMD_REGIF_READ      : mmi64_command_t := x"20";  --! register read access
  constant MMI64_CMD_REGIF_WRITE     : mmi64_command_t := x"21";  --! register write access
  constant MMI64_CMD_REGIF_WRITE_ACK : mmi64_command_t := x"22";  --! register write access with acknowlement

  -- module downstream state machine
  signal dn_regif_state_r            : mmi64_regif_downstream_state;
  signal dn_regif_state_r_nxt        : mmi64_regif_downstream_state;

  -- downstream payload length
  signal dn_payload_length_r         : mmi64_payload_length_t;
  signal dn_payload_length_r_nxt     : mmi64_payload_length_t;

  -- command to perform
  signal dn_command_r                : mmi64_command_t;
  signal dn_command_r_nxt            : mmi64_command_t;

  -- tag required for read and write acknowledgement responses to host requests
  signal dn_tag_r                    : mmi64_tag_t;
  signal dn_tag_r_nxt                : mmi64_tag_t;

  -- tag required for identify responses to host requests
  signal dn_identify_tag_r           : mmi64_tag_t;
  signal dn_identify_tag_r_nxt       : mmi64_tag_t;

  -- register address
  signal dn_reg_addr_r               : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH-1 downto 0);
  signal dn_reg_addr_r_nxt           : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH-1 downto 0);

  -- number of registers to read or write
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal dn_reg_count_r              : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);
  signal dn_reg_count_r_nxt          : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);

  -- number of registers to read
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal dn_reg_read_count_r         : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);
  signal dn_reg_read_count_r_nxt     : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);

  -- register subword access counter
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal dn_subword_count_r          : unsigned (MMI64_SUBWORD_COUNTER_WIDTH downto 0);
  signal dn_subword_count_r_nxt      : unsigned (MMI64_SUBWORD_COUNTER_WIDTH downto 0);

  -- subword start bit index when access mmi64 data word for register access
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal dn_subword_start_idx_r      : unsigned(log2(MMI64_DATA_WIDTH) downto 0);
  signal dn_subword_start_idx_r_nxt  : unsigned(log2(MMI64_DATA_WIDTH) downto 0);

  -- downstream to upstream  identify request
  signal dn_do_identify_r            : std_ulogic;
  signal dn_do_identify_r_nxt        : std_ulogic;

  -- downstream to upstream write acknowledge request
  signal dn_do_write_ack_r           : std_ulogic;
  signal dn_do_write_ack_r_nxt       : std_ulogic;

  -- downstream to upstream read request
  signal dn_do_read_r                : std_ulogic;
  signal dn_do_read_r_nxt            : std_ulogic;

  -- module upstream state machine
  signal up_regif_state_r            : mmi64_regif_upstream_state;
  signal up_regif_state_r_nxt        : mmi64_regif_upstream_state;

  -- assembled data word during read access
  signal up_data_r                   : mmi64_data_t;
  signal up_data_r_nxt               : mmi64_data_t;

  -- number of registers to read
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal up_reg_count_r              : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);
  signal up_reg_count_r_nxt          : unsigned(MMI64_REGIF_REGISTER_ADDR_WIDTH downto 0);

  -- feedback from upstream to downstream path requests
  signal up_identify_done            : std_ulogic;
  signal up_read_done                : std_ulogic;
  signal up_write_ack_done           : std_ulogic;

  -- register subword access counter
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal up_subword_count_r          : unsigned (MMI64_SUBWORD_COUNTER_WIDTH downto 0);
  signal up_subword_count_r_nxt      : unsigned (MMI64_SUBWORD_COUNTER_WIDTH downto 0);

  -- subword start bit index when access mmi64 data word for register access
  -- (one bit more than required in order to overcome std_numeric warnings if register width 64 bit)
  signal up_subword_start_idx_r      : unsigned(log2(MMI64_DATA_WIDTH) downto 0);
  signal up_subword_start_idx_r_nxt  : unsigned(log2(MMI64_DATA_WIDTH) downto 0);


  -- read fifo control signals
  signal read_fifo_re    : std_ulogic;
  signal read_fifo_rdata : std_ulogic_vector(REGISTER_WIDTH-1 downto 0);
  signal read_fifo_clear : std_ulogic;
  signal read_fifo_half  : std_ulogic;
  signal read_fifo_empty : std_ulogic;
  signal read_fifo_reserve : std_ulogic;
  signal read_fifo_full   : std_ulogic;

begin

  -- read data fifo
  mmi64_regfifo_inst: mmi64_regfifo
    generic map (
      FIFO_WIDTH => REGISTER_WIDTH,
      FIFO_DEPTH => READ_BUFFER_DEPTH)
    port map (
      clk     => mmi64_clk,
      reset   => mmi64_reset,
      we_i    => reg_rvalid_i,
      wdata_i => reg_rdata_i,
      re_i    => read_fifo_re,
      rdata_o => read_fifo_rdata,
      clear_i => read_fifo_clear,
      reserve_i => read_fifo_reserve,
      full_o  => read_fifo_full,
      empty_o => read_fifo_empty);

  -- downstream path of register file
  p_regif_downstream : process (dn_command_r, dn_do_identify_r, dn_do_read_r, dn_do_write_ack_r, dn_identify_tag_r, dn_payload_length_r, dn_reg_addr_r, dn_reg_count_r, dn_reg_read_count_r, dn_regif_state_r, dn_subword_count_r, dn_subword_start_idx_r, dn_tag_r, mmi64_h_dn_d_i, mmi64_h_dn_start_i, mmi64_h_dn_valid_i, read_fifo_full, reg_accept_i, up_identify_done, up_read_done, up_write_ack_done)
  begin  -- process p_rf
    -- default assignments
    dn_regif_state_r_nxt       <= dn_regif_state_r;
    dn_payload_length_r_nxt    <= dn_payload_length_r;
    dn_command_r_nxt           <= dn_command_r;
    dn_reg_count_r_nxt         <= dn_reg_count_r;
    dn_reg_read_count_r_nxt    <= dn_reg_read_count_r;
    dn_subword_count_r_nxt     <= dn_subword_count_r;
    dn_subword_start_idx_r_nxt <= dn_subword_start_idx_r;
    dn_do_identify_r_nxt       <= dn_do_identify_r;
    dn_do_write_ack_r_nxt      <= dn_do_write_ack_r;
    dn_do_read_r_nxt           <= dn_do_read_r;
    dn_reg_addr_r_nxt          <= dn_reg_addr_r;
    dn_tag_r_nxt               <= dn_tag_r;
    dn_identify_tag_r_nxt      <= dn_identify_tag_r;

    -- do not accept downstream data
    mmi64_h_dn_accept_o      <= '0';

    -- disable access to register file
    reg_en_o <= '0';
    reg_we_o <= '0';
    reg_addr_o            <= (others=>'-');
    reg_wdata_o           <= (others=>'-');

    read_fifo_reserve <= '0';

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

    case dn_regif_state_r is
      when ST_MMI64_REGIF_DN_IDLE =>
        -- ST_MMI64_REGIF_DN_IDLE is a special state handled below
        null;

-- *
-- ** register file specific states
-- *
      when ST_MMI64_REGIF_DN_CONTROL_WORD =>
        -- *** receive control word for read, write or write acknoledge transfer
        -- store register access start address
        dn_reg_addr_r_nxt <= resize(unsigned(mmi64_h_dn_d_i(15 downto 0)), dn_reg_addr_r_nxt'length);

        -- store number of registers to access
        dn_reg_count_r_nxt      <= resize(unsigned(mmi64_h_dn_d_i(31 downto 16)), dn_reg_count_r_nxt'length);
        dn_reg_read_count_r_nxt <= resize(unsigned(mmi64_h_dn_d_i(31 downto 16)), dn_reg_read_count_r_nxt'length);

        -- accept downstream data
        mmi64_h_dn_accept_o <= '1';

        if mmi64_h_dn_valid_i = '1' then
          -- continue depending on access mode
          if dn_command_r = MMI64_CMD_REGIF_READ then
            -- read access
            dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_READ;

            -- trigger upstream read message generation
            dn_do_read_r_nxt <= '1';
          else
            -- write access
            dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_WRITE;
          end if;

          -- decrease payload length
          dn_payload_length_r_nxt <= dn_payload_length_r - 1;

          -- reset subword access counter
          dn_subword_count_r_nxt   <= (others => '0');

          -- reset subword start bit index
          dn_subword_start_idx_r_nxt <= (others => '0');
        end if;

      when ST_MMI64_REGIF_DN_WRITE =>
        -- *** perform write (burst) access to register file
        -- generate write address
        reg_addr_o <= std_ulogic_vector(dn_reg_addr_r);

        -- select write data
        for bit_idx in REGISTER_WIDTH-1 downto 0 loop
          reg_wdata_o(bit_idx) <= mmi64_h_dn_d_i(to_integer(dn_subword_start_idx_r+bit_idx));
        end loop;

        -- write data valid?
        if mmi64_h_dn_valid_i = '1' then

          -- set register access enable
          reg_en_o <= '1';

          -- set register write enable
          reg_we_o <= '1';

          -- register file accepts write access?
          if reg_accept_i = '1' then

            -- update write address
            dn_reg_addr_r_nxt <= dn_reg_addr_r + 1;

            -- update write counter
            dn_reg_count_r_nxt <= dn_reg_count_r - 1;

            -- update subword write counter
            dn_subword_count_r_nxt <= dn_subword_count_r + 1;

            -- update subword start bit index
            dn_subword_start_idx_r_nxt <= dn_subword_start_idx_r + REGISTER_WIDTH;

            -- final subword access on mmi64 data word?
            if dn_subword_count_r = to_unsigned(MMI64_SUBWORDS_PER_DATA_WORD-1, dn_subword_count_r'length) then

              -- advance to next data word by accepting downstream data
              mmi64_h_dn_accept_o <= '1';

              -- reset subword write counter
              dn_subword_count_r_nxt <= (others=>'0');

              -- decrease payload length
              dn_payload_length_r_nxt <= dn_payload_length_r - 1;

              -- reset subword start bit index
              dn_subword_start_idx_r_nxt <= (others=>'0');

              -- if terminal payload word, stop transfer
              if dn_payload_length_r = to_unsigned(1, dn_payload_length_r'length) then
                if dn_command_r = MMI64_CMD_REGIF_WRITE_ACK then
                  -- trigger generation of write acknowledge message
                  dn_do_write_ack_r_nxt <= '1';
                end if;

                -- return to idle state
                dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_IDLE;
              end if;
            end if;

            -- final register access on this write (burst) transfer reached?
            if dn_reg_count_r = to_unsigned(1, dn_reg_count_r'length) then
              if dn_command_r = MMI64_CMD_REGIF_WRITE_ACK then
                -- trigger generation of write acknowledge message
                dn_do_write_ack_r_nxt <= '1';
              end if;

              -- acknowledge current data word
              mmi64_h_dn_accept_o <= '1';

              -- return to idle state
              dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_IDLE;
            end if;
          end if;
        end if;

      when ST_MMI64_REGIF_DN_READ =>
        -- *** perform read (burst) request to register file

        -- generate read address
        reg_addr_o <= std_ulogic_vector(dn_reg_addr_r);

        -- enough space in fof to capture read data?
        if read_fifo_full='0' then

          -- enable access to register file
          reg_en_o <= '1';

          -- read request accepted by register file?
          if reg_accept_i = '1' then

            -- reserve space in fifo
            read_fifo_reserve <= '1';

            -- update read address
            dn_reg_addr_r_nxt <= dn_reg_addr_r + 1;

            -- update read counter
            dn_reg_count_r_nxt <= dn_reg_count_r - 1;

            -- final register access on this read (burst) transfer reached?
            if dn_reg_count_r = to_unsigned(1, dn_reg_count_r'length) then
              -- return to idle state
              dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_IDLE;
            end if;
          end if;
        end if;

    end case;

        -- special handling for idle state, always going back to idle when start flag is set
    if (dn_regif_state_r = ST_MMI64_REGIF_DN_IDLE) or (mmi64_h_dn_valid_i = '1' and mmi64_h_dn_start_i = '1') then

      -- stay in idle state (or go back to it on start)
      dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_IDLE;

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

            when MMI64_CMD_REGIF_READ | MMI64_CMD_REGIF_WRITE | MMI64_CMD_REGIF_WRITE_ACK =>
              -- prepare register file access by receiving access control word
              dn_regif_state_r_nxt <= ST_MMI64_REGIF_DN_CONTROL_WORD;

            when others =>
              -- other commands are not supported an will be ignored
              null;
          end case;
        end if;
      end if;
    end if;

  end process p_regif_downstream;


  -- upstream path of register file
  p_regif_upstream : process (dn_do_identify_r, dn_do_read_r, dn_do_write_ack_r, dn_identify_tag_r, dn_reg_read_count_r, dn_tag_r, mmi64_h_up_accept_i, read_fifo_empty, read_fifo_rdata, up_data_r, up_reg_count_r, up_regif_state_r, up_subword_count_r, up_subword_start_idx_r)
    variable mmi64_data_v : mmi64_data_t;
    variable bit_count_to_transfer_v  : unsigned(dn_reg_count_r'length+MMI64_SUBWORD_SHIFT_WIDTH downto 0);
    variable word_count_to_transfer_v : mmi64_payload_length_t;
    variable read_subword_done_v  : boolean;
    variable read_transfer_done_v : boolean;
  begin
    -- default assignments
    up_regif_state_r_nxt       <= up_regif_state_r;
    up_identify_done           <= '0';
    up_read_done               <= '0';
    up_write_ack_done          <= '0';
    up_data_r_nxt              <= up_data_r;
    up_reg_count_r_nxt         <= up_reg_count_r;
    up_subword_count_r_nxt     <= up_subword_count_r;
    up_subword_start_idx_r_nxt <= up_subword_start_idx_r;
    read_fifo_re               <= '0';

    -- disable upstream port
    mmi64_h_up_valid_o      <= '0';
    mmi64_h_up_start_o      <= '0';
    mmi64_h_up_stop_o       <= '0';
    mmi64_h_up_d_o          <= (others => '-');

    -- always clear register read fifo buffer as long as no read request is pending
    read_fifo_clear <= not dn_do_read_r;

    case up_regif_state_r is
      when ST_MMI64_REGIF_UP_IDLE =>
        if dn_do_write_ack_r = '1' then
          -- generate write acknowledge reponse
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_WRITE_ACK_HEADER;
        elsif dn_do_read_r = '1' then
          -- generate read response
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_READ_HEADER;
        elsif dn_do_identify_r = '1' then
          -- generate identify reponse
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDENTIFY_HEADER;
        end if;

-- **
-- *** write acknoledgement related states
-- **

      when ST_MMI64_REGIF_UP_WRITE_ACK_HEADER =>

        -- generate mmi64 packet header for register write acknowledgement
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_REGIF_WRITE_ACK,        -- command
          MMI64_ZERO_COMMAND_PARAMETER,     -- command parameter
          MMI64_ZERO_PAYLOAD_LENGTH,        -- payload length
          dn_tag_r                          -- tag
          );

        -- set start and stop flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';
        mmi64_h_up_stop_o  <= '1';

        -- indicate write acknowledge request is fulfilled
        up_write_ack_done       <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDLE;
        end if;

-- **
-- *** read related states
-- **

      when ST_MMI64_REGIF_UP_READ_HEADER =>

        -- number of payload bits to transfer
        bit_count_to_transfer_v := shift_left(resize(dn_reg_read_count_r, bit_count_to_transfer_v'length), MMI64_SUBWORD_SHIFT_WIDTH);

        -- number of payload words to transfer (truncated to next integer)
        word_count_to_transfer_v := resize(shift_right(bit_count_to_transfer_v + MMI64_DATA_WIDTH - 1, MMI64_DATA_SHIFT_WIDTH), word_count_to_transfer_v'length);

        -- generate mmi64 packet header for register read
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_REGIF_READ,                  -- command
          MMI64_ZERO_COMMAND_PARAMETER,          -- command parameter
          word_count_to_transfer_v,              -- payload length
          dn_tag_r                               -- tag
          );

        -- copy number of registers to read
        up_reg_count_r_nxt <= dn_reg_read_count_r;

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          -- handle zero length read request properly
          if dn_reg_read_count_r = to_unsigned(0, dn_reg_read_count_r'length) then
            -- indicate read request is fulfilled
            up_read_done       <= '1';

            -- return to idle state
            up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDLE;
          else
            up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_READ;
          end if;
        end if;

      when ST_MMI64_REGIF_UP_READ =>

        -- accept read data from register file
        read_fifo_re <= '1';

        -- read data from register file is valid?
        if read_fifo_empty = '0' then

          -- assign register read data to internal register and output port
          mmi64_data_v := up_data_r;
          for bit_idx in REGISTER_WIDTH-1 downto 0 loop
            mmi64_data_v(to_integer(up_subword_start_idx_r+bit_idx)) := read_fifo_rdata(bit_idx);
          end loop;
          up_data_r_nxt  <= mmi64_data_v;
          mmi64_h_up_d_o <= mmi64_data_v;

          -- is this the final register access in this read (burst) access?
          read_transfer_done_v := (up_reg_count_r = to_unsigned(1, up_reg_count_r'length));

          -- final read access for current mmi64 data word?
          read_subword_done_v := read_transfer_done_v or (up_subword_count_r = to_unsigned(MMI64_SUBWORDS_PER_DATA_WORD-1, up_subword_count_r'length));

          -- indicate end of message if end of read transfer
          if read_transfer_done_v then
            -- end of identify response message
            mmi64_h_up_stop_o  <= '1';
          end if;

          -- mmi64 data word assembly is complete?
          if (read_subword_done_v) then

            -- make data word available to upstream
            mmi64_h_up_valid_o <= '1';

            -- upstream accepts data word?
            if (mmi64_h_up_accept_i='1') then

              -- clear data word register
              up_data_r_nxt  <= (others=>'0');

              -- update read counter
              up_reg_count_r_nxt <= up_reg_count_r - 1;

              -- reset subword counter
              up_subword_count_r_nxt <= (others=>'0');

              -- reset subword start bit index
              up_subword_start_idx_r_nxt <= (others=>'0');

              -- end of read transfer?
              if read_transfer_done_v then
                -- indicate read request is fulfilled
                up_read_done       <= '1';

                -- return to idle state
                up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDLE;
              end if;
            else
              -- we are blocked from upstream -> do not accept read data from register file
              read_fifo_re <= '0';
            end if;
          else
            -- *** this is not the final access on current mmi64 data word

            -- accept read data from register file
            read_fifo_re <= '1';

            -- update read counter
            up_reg_count_r_nxt <= up_reg_count_r - 1;

            -- update subword counter
            up_subword_count_r_nxt <= up_subword_count_r + 1;

            -- update subword start bit index
            up_subword_start_idx_r_nxt <= up_subword_start_idx_r + REGISTER_WIDTH;
          end if;
        end if;

-- **
-- *** identify related states
-- **

      when ST_MMI64_REGIF_UP_IDENTIFY_HEADER =>

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
        up_write_ack_done       <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDENTIFY_TYPE_AND_ID;
        end if;

      when ST_MMI64_REGIF_UP_IDENTIFY_TYPE_AND_ID =>
        -- generate common identify response
        mmi64_data_v := (others=>'0');
        mmi64_data_v(mmi64_identify_module_type_r) := std_ulogic_vector(MMI64_TID_M_REGIF);
        mmi64_data_v(mmi64_identify_module_id_r)   := convert(MODULE_ID);

        -- send identify data to upstream
        mmi64_h_up_d_o     <= mmi64_data_v;
        mmi64_h_up_valid_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDENTIFY_MODULE_PARAMETER;
        end if;

      when ST_MMI64_REGIF_UP_IDENTIFY_MODULE_PARAMETER =>
        -- generate common identify response
        mmi64_data_v := (others=>'0');
        mmi64_data_v(15 downto  0) := std_ulogic_vector(to_unsigned(REGISTER_COUNT, 16));
        mmi64_data_v(31 downto 16) := std_ulogic_vector(to_unsigned(REGISTER_WIDTH, 16));

        -- send identify data to upstream
        mmi64_h_up_d_o     <= mmi64_data_v;
        mmi64_h_up_valid_o <= '1';

        -- end of identify response message
        mmi64_h_up_stop_o  <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_regif_state_r_nxt <= ST_MMI64_REGIF_UP_IDLE;
        end if;

    end case;

  end process p_regif_upstream;

  -- create registers
  p_ff : process (mmi64_clk)
  begin  -- process ff
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then         -- synchronous reset
        dn_regif_state_r       <= ST_MMI64_REGIF_DN_IDLE;
        dn_command_r           <= (others => '0');
        dn_payload_length_r    <= (others => '0');
        dn_tag_r               <= (others => '0');
        dn_reg_count_r         <= (others => '0');
        dn_reg_read_count_r    <= (others => '0');
        dn_reg_addr_r          <= (others => '0');
        dn_subword_count_r     <= (others => '0');
        dn_subword_start_idx_r <= (others => '0');
        dn_identify_tag_r      <= (others => '0');
        dn_do_identify_r       <= '0';
        dn_do_write_ack_r      <= '0';
        dn_do_read_r           <= '0';

        up_regif_state_r       <= ST_MMI64_REGIF_UP_IDLE;
        up_data_r              <= (others=>'0');
        up_reg_count_r         <= (others=>'0');
        up_subword_count_r     <= (others => '0');
        up_subword_start_idx_r <= (others => '0');
      else
        dn_regif_state_r       <= dn_regif_state_r_nxt;
        dn_command_r           <= dn_command_r_nxt;
        dn_payload_length_r    <= dn_payload_length_r_nxt;
        dn_tag_r               <= dn_tag_r_nxt;
        dn_reg_count_r         <= dn_reg_count_r_nxt;
        dn_reg_read_count_r    <= dn_reg_read_count_r_nxt;
        dn_reg_addr_r          <= dn_reg_addr_r_nxt;
        dn_subword_count_r     <= dn_subword_count_r_nxt;
        dn_subword_start_idx_r <= dn_subword_start_idx_r_nxt;
        dn_identify_tag_r      <= dn_identify_tag_r_nxt;
        dn_do_identify_r       <= dn_do_identify_r_nxt;
        dn_do_write_ack_r      <= dn_do_write_ack_r_nxt;
        dn_do_read_r           <= dn_do_read_r_nxt;

        up_regif_state_r       <= up_regif_state_r_nxt;
        up_data_r              <= up_data_r_nxt;
        up_reg_count_r         <= up_reg_count_r_nxt;
        up_subword_count_r     <= up_subword_count_r_nxt;
        up_subword_start_idx_r <= up_subword_start_idx_r_nxt;
      end if;

    end if;
  end process p_ff;

  -- debug output assignment (read synthesis report for state encoding)
  --state_o <= std_ulogic_vector(to_unsigned(CTRL_MODULE_STATE'pos(up_dn_regif_state_r), state_o'length));x

end architecture rtl;
