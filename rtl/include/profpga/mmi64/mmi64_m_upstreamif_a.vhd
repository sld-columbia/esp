-- =============================================================================
--  COPYRIGHT (C) 2014, 2015 Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  @project      Module Message Interface 64
-- =============================================================================
--  @file         mmi64_m_upstreamif_e.vhd
--  @author       mberger
--  @brief        MMI64 module to implement a data upstream interface
--                (implementation).
-- =============================================================================

-- =============================================================================
-- mmi64_m_upstreamif_core module
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

entity mmi64_m_upstreamif_core is
    generic (
      MODULE_ID         : mmi64_module_id_t  := X"00000000"; --! unique id of the module instance
      BUFF_AWIDTH       : natural;                           --! address bitwidth of the FIFO memory
      MMI64_UPSTREAMIF_VERSION : natural     := 1            --! upstream module version reported by the module itself
      );
    port (
      -- clock and reset
      mmi64_clk   : in std_ulogic;             --! clock of mmi64 domain
      mmi64_reset : in std_ulogic;             --! reset of mmi64 domain

      -- connections to mmi64 router
      mmi64_h_dn_d_i        : in  mmi64_data_t;  --! downstream data from router
      mmi64_h_dn_valid_i    : in  std_ulogic;    --! downstream data valid from router
      mmi64_h_dn_accept_o   : out std_ulogic;    --! downstream data accept to router
      mmi64_h_dn_start_i    : in  std_ulogic;    --! downstream data start (first byte of transfer) from router
      mmi64_h_dn_stop_i     : in  std_ulogic;    --! downstream data end (last byte of transfer) from router

      mmi64_h_up_d_o        : out mmi64_data_t;  --! upstream data output to router
      mmi64_h_up_valid_o    : out std_ulogic;    --! upstream data valid to router
      mmi64_h_up_accept_i   : in  std_ulogic;    --! upstream data accept from router
      mmi64_h_up_start_o    : out std_ulogic;    --! upstream data start (first byte of transfer) to router
      mmi64_h_up_stop_o     : out std_ulogic;    --! upstream data end (last byte of transfer) to router

      -- connections to upstream data interface
      upstream_clk          : in  std_ulogic;    --! clock of the upstream data interface
      upstream_reset        : in  std_ulogic;    --! reset of the upstream data interface
      upstream_d_i          : in mmi64_data_t;   --! data interface: input
      upstream_valid_i      : in  std_ulogic;    --! data interface: data valid
      upstream_accept_o     : out std_ulogic;    --! data interface: accept
      upstream_flush_req_i  : in  std_ulogic;    --! requests to flush the upstream FIFO
      upstream_flush_ack_o  : out std_ulogic;    --! signals that the flush operation is done
      upstream_fifo_count_o : out std_ulogic_vector(BUFF_AWIDTH downto 0)
                                               --! reports the actual FIFO fill level
      );
end entity mmi64_m_upstreamif_core;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generic_ram_comp.all;          -- Generic Memory
use work.afifo_core_pkg.all;            -- Async FIFO core
use work.rtl_templates.all;
use work.mmi64_pkg.all;


-- implementation of mmi64_m_upstreamif
architecture rtl of mmi64_m_upstreamif_core is

  -- downstream state machine 
  type mmi64_upstreamif_downstream_state is (
    ST_MMI64_UPSTREAMIF_DN_IDLE,          -- wait for start of new message
    ST_MMI64_UPSTREAMIF_DN_CONTROL_WORD,  -- receive and evaluate control word
    ST_MMI64_UPSTREAMIF_DN_READ,          -- read current upstream interface settings
    ST_MMI64_UPSTREAMIF_DN_WRITE          -- change current upstream interface settings
    );

  -- upstream state machine 
  type mmi64_upstreamif_upstream_state is (
    ST_MMI64_UPSTREAMIF_UP_IDLE,                  -- wait for request to generate upstream message
    ST_MMI64_UPSTREAMIF_UP_READ_HEADER,           -- generate read header
    ST_MMI64_UPSTREAMIF_UP_READ,                  -- generate read payload
    ST_MMI64_UPSTREAMIF_UP_IDENTIFY_HEADER,       -- generate identify response header
    ST_MMI64_UPSTREAMIF_UP_IDENTIFY_TYPE_AND_ID,  -- generate identify unique module id and type id
    ST_MMI64_UPSTREAMIF_UP_SEND_HEADER,           -- generate send header
    ST_MMI64_UPSTREAMIF_UP_SEND_DATA,             -- generate send data
    ST_MMI64_UPSTREAMIF_UP_FLUSH_HEADER,          -- generate flush header
    ST_MMI64_UPSTREAMIF_UP_FLUSH_NREQ             -- wait for upstream_flush_req_i becomes low
    );

  -- number of data words in identify response from router
  constant MMI64_MODULE_IDENTIFY_PAYLOAD_LEN : natural := 1;

  -- number of data words in settings response
  constant MMI64_MODULE_READ_PAYLOAD_LEN : natural := 1;

  -- flush command does not have any payload
  constant MMI64_MODULE_FLUSH_PAYLOAD_LEN : natural := 0;

  -- list of module specific commands
  constant MMI64_CMD_UPSTREAMIF_READ  : mmi64_command_t := x"20";  -- settings read access
  constant MMI64_CMD_UPSTREAMIF_WRITE : mmi64_command_t := x"21";  -- settings write access
  constant MMI64_CMD_UPSTREAMIF_SEND  : mmi64_command_t := x"22";  -- upstream data send command
  constant MMI64_CMD_UPSTREAMIF_FLUSH : mmi64_command_t := x"23";  -- upstream data flush command

  -- module downstream state machine
  signal dn_upstreamif_state_r     : mmi64_upstreamif_downstream_state;
  signal dn_upstreamif_state_r_nxt : mmi64_upstreamif_downstream_state;

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

  -- downstream to upstream read request
  signal dn_do_read_r     : std_ulogic;
  signal dn_do_read_r_nxt : std_ulogic;

  -- module upstream state machine
  signal up_upstreamif_state_r     : mmi64_upstreamif_upstream_state;
  signal up_upstreamif_state_r_nxt : mmi64_upstreamif_upstream_state;

  -- assembled data word during read access
  signal up_data_r     : mmi64_data_t;
  signal up_data_r_nxt : mmi64_data_t;

  -- feedback from upstream to downstream path requests
  signal up_identify_done : std_ulogic;
  signal up_read_done     : std_ulogic;

  -- global enable/disable signal and message size(s)
  signal enable_nxt_int, enable_nxt_int_r                           : std_ulogic;
  signal enable_nxt, enable_r, enable_r_upstream_clk                : std_ulogic;
  signal upstream_max_message_size_nxt, upstream_max_message_size_r : unsigned(15 downto 0);
  signal upstream_min_message_size_nxt, upstream_min_message_size_r : unsigned(15 downto 0);
  signal upstream_message_counter_nxt, upstream_message_counter_r   : unsigned(15 downto 0);
  signal upstream_accept                                            : std_ulogic_vector(5 downto 0);

  -- tag to mark all send packets
  signal send_tag_r   : mmi64_tag_t;
  signal send_tag_nxt : mmi64_tag_t;

  -- fifo memory
  signal mem_wr_enable  : std_ulogic;                                      -- Write enable memory
  signal mem_wr_address : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);       -- Memory write address
  signal mem_wr_data    : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  -- Memory write data
  signal mem_rd_enable  : std_ulogic;                                      -- Read enable memory
  signal mem_rd_address : std_ulogic_vector(BUFF_AWIDTH-1 downto 0);       -- Memory read address
  signal mem_rd_data    : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  -- Memory read data

  -- intermediate fifo signals
  signal upstream_fifo_we, upstream_fifo_full : std_ulogic;
  signal rdfifo_renable, rdfifo_empty         : std_ulogic;
  signal rdfifo_count                         : std_ulogic_vector(BUFF_AWIDTH downto 0);
  signal rdfifo_rdata                         : mmi64_data_t;
  signal rdfifo_count_r, rdfifo_count_nxt     : unsigned(BUFF_AWIDTH downto 0);
  signal upstream_reset_n, mmi64_reset_n      : std_ulogic;

  -- handshake signals for flush operation
  signal flush_req_uclk     : std_ulogic;
  signal flush_req_mclk     : std_ulogic;
  signal flush_ack_uclk     : std_ulogic;
  signal flush_ack_mclk     : std_ulogic;
  signal flush_ack_mclk_nxt : std_ulogic;

begin

  -------------------------------------------------------------------------------------------------
  -- generic async fifo
  -------------------------------------------------------------------------------------------------

  -- FIFO core
  i_afifo_core : afifo_core
    generic map(
      DATA_WIDTH               => MMI64_DATA_WIDTH,
      ADDR_WIDTH               => BUFF_AWIDTH,
      FIRST_WORD_FALLS_THROUGH => true
      ) port map(
        --Write clock domain
        wr_clk                 => upstream_clk,
        wr_reset_n             => upstream_reset_n,
        wr_enable_i            => upstream_fifo_we,
        wr_data_i              => upstream_d_i,
        wr_full_o              => upstream_fifo_full,
        wr_diff_o              => upstream_fifo_count_o,
        -- Read clock domain
        rd_clk                 => mmi64_clk,
        rd_reset_n             => mmi64_reset_n,
        rd_enable_i            => rdfifo_renable,
        rd_data_o              => rdfifo_rdata,
        rd_empty_o             => rdfifo_empty,
        rd_diff_o              => rdfifo_count,
        -- Memory interface
        wea_o                  => mem_wr_enable,
        addra_o                => mem_wr_address,
        dataa_o                => mem_wr_data,
        enb_o                  => mem_rd_enable,
        addrb_o                => mem_rd_address,
        datab_i                => mem_rd_data
        );
  upstream_fifo_we  <= upstream_valid_i and (not upstream_fifo_full) and upstream_accept(5);
  upstream_accept_o <= (not upstream_fifo_full) and upstream_accept(5);
  upstream_reset_n  <= (not upstream_reset) and enable_r;
  mmi64_reset_n     <= (not mmi64_reset) and enable_r_upstream_clk;

  -- FIFO storage memory
  u_dl_generic_dpram : generic_dpram
    generic map(
      ADDR_W   => BUFF_AWIDTH,
      DATA_W   => MMI64_DATA_WIDTH
      ) port map(
        clk1   => upstream_clk,
        ce1    => '1',
        we1    => mem_wr_enable,
        addr1  => mem_wr_address,
        wdata1 => mem_wr_data,
        rdata1 => open,

        clk2   => mmi64_clk,
        ce2    => mem_rd_enable,
        we2    => '0',
        addr2  => mem_rd_address,
        wdata2 => (others => '0'),
        rdata2 => mem_rd_data
        );

  -------------------------------------------------------------------------------------------------
  -- up/downstream state machines
  -------------------------------------------------------------------------------------------------

  -- downstream path 
  p_upstreamif_downstream : process (dn_command_r, dn_do_identify_r, dn_do_read_r, dn_identify_tag_r,
                                     dn_upstreamif_state_r, dn_tag_r, mmi64_h_dn_d_i, mmi64_h_dn_start_i,
                                     mmi64_h_dn_valid_i, up_identify_done, up_read_done, enable_nxt_int_r,
                                     upstream_max_message_size_r, upstream_min_message_size_r)
  begin  -- process p_rf
    -- default assignments
    dn_upstreamif_state_r_nxt     <= dn_upstreamif_state_r;
    dn_command_r_nxt              <= dn_command_r;
    dn_do_identify_r_nxt          <= dn_do_identify_r;
    dn_do_read_r_nxt              <= dn_do_read_r;
    dn_tag_r_nxt                  <= dn_tag_r;
    dn_identify_tag_r_nxt         <= dn_identify_tag_r;
    enable_nxt_int                <= enable_nxt_int_r;
    upstream_max_message_size_nxt <= upstream_max_message_size_r;
    upstream_min_message_size_nxt <= upstream_min_message_size_r;

    -- do not accept downstream data
    mmi64_h_dn_accept_o <= '0';

    -- reset mmi64 identify request flag
    if (up_identify_done = '1') then
      dn_do_identify_r_nxt <= '0';
    end if;

    -- reset read request flag
    if (up_read_done = '1') then
      dn_do_read_r_nxt <= '0';
    end if;

    case dn_upstreamif_state_r is
      when ST_MMI64_UPSTREAMIF_DN_IDLE =>
        -- ST_MMI64_UPSTREAMIF_DN_IDLE is a special state handled below
        null;

-- *
-- ** module specific states
-- *
      when ST_MMI64_UPSTREAMIF_DN_CONTROL_WORD =>
        -- *** receive control word for read, write or write acknoledge transfer

        -- accept downstream data
        mmi64_h_dn_accept_o <= '1';

        -- continue depending on access mode
        if dn_command_r = MMI64_CMD_UPSTREAMIF_READ then
          -- read access
          dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_READ;

          -- trigger upstream read message generation
          dn_do_read_r_nxt <= '1';
        else
          if mmi64_h_dn_valid_i = '1' then
            -- write access

            -- write settings 
            enable_nxt_int                <= mmi64_h_dn_d_i(0);
            upstream_max_message_size_nxt <= unsigned(mmi64_h_dn_d_i(23 downto 8));
            upstream_min_message_size_nxt <= unsigned(mmi64_h_dn_d_i(39 downto 24));

            dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_WRITE;
          end if;
        end if;

      when ST_MMI64_UPSTREAMIF_DN_WRITE =>
        -- *** perform write access

        -- acknowledge current data word
        mmi64_h_dn_accept_o <= '1';

        -- return to idle state
        dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_IDLE;

      when ST_MMI64_UPSTREAMIF_DN_READ =>
        -- *** perform read request 

        -- return to idle state
        if up_read_done = '1' then
          dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_IDLE;
        end if;

    end case;

    -- special handling for idle state, always going back to idle when start flag is set
    if (dn_upstreamif_state_r = ST_MMI64_UPSTREAMIF_DN_IDLE) or (mmi64_h_dn_valid_i = '1' and mmi64_h_dn_start_i = '1') then

      -- stay in idle state (or go back to it on start)
      dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_IDLE;

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

        if mmi64_header_is_valid(mmi64_h_dn_d_i) then
          -- evaluate downstream command
          case mmi64_command_t'(mmi64_command(mmi64_h_dn_d_i)) is
            when MMI64_CMD_INITIALIZE                  =>
              -- reset settings to default
              enable_nxt_int                <= '0';
              upstream_max_message_size_nxt <= (others => '0');
              upstream_min_message_size_nxt <= (others => '0');

            when MMI64_CMD_IDENTIFY =>
              -- trigger generation of identify response
              dn_do_identify_r_nxt <= '1';

            when MMI64_CMD_UPSTREAMIF_READ | MMI64_CMD_UPSTREAMIF_WRITE =>
              -- receiving access control word
              dn_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_DN_CONTROL_WORD;

            when others =>
              -- other commands are not supported an will be ignored
              null;
          end case;
        end if;
      end if;
    end if;

  end process p_upstreamif_downstream;


  -- upstream path 
  p_upstreamif_upstream           : process (dn_do_identify_r, dn_do_read_r, dn_identify_tag_r, dn_tag_r, mmi64_h_up_accept_i,
                                   up_data_r, up_upstreamif_state_r, send_tag_r, upstream_max_message_size_r,
                                   upstream_min_message_size_r, upstream_message_counter_r, upstream_d_i, enable_r,
                                   rdfifo_count, rdfifo_empty, rdfifo_count_r, rdfifo_rdata, enable_nxt_int_r, flush_req_mclk)
    variable mmi64_data_v         : mmi64_data_t;
    variable read_transfer_done_v : boolean;
    variable message_size         : unsigned(15 downto 0);
    variable fifo_fill_level      : unsigned(BUFF_AWIDTH downto 0);
  begin
    -- default assignments
    up_upstreamif_state_r_nxt <= up_upstreamif_state_r;
    up_identify_done          <= '0';
    up_read_done              <= '0';
    up_data_r_nxt             <= up_data_r;

    send_tag_nxt                 <= send_tag_r;
    upstream_message_counter_nxt <= upstream_message_counter_r;
    rdfifo_count_nxt             <= rdfifo_count_r;

    -- disable upstream port
    mmi64_h_up_valid_o <= '0';
    mmi64_h_up_start_o <= '0';
    mmi64_h_up_stop_o  <= '0';
    mmi64_h_up_d_o     <= (others => '-');

    -- block data streaming
    rdfifo_renable <= '0';

    enable_nxt <= enable_r;

    flush_ack_mclk_nxt <= flush_ack_mclk;

    case up_upstreamif_state_r is
      when ST_MMI64_UPSTREAMIF_UP_IDLE =>
        enable_nxt <= enable_nxt_int_r;
        if dn_do_read_r = '1' then
          -- generate read response
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_READ_HEADER;
        elsif dn_do_identify_r = '1' then
          -- generate identify reponse
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDENTIFY_HEADER;
        elsif (enable_r = '1') and (enable_nxt_int_r = '1') then
          -- upstream data is enabled
          -- start data transfer if the fifo has some (or enough) data

          -- determine the actual FIFO fill level
          fifo_fill_level := unsigned(rdfifo_count);

          -- test if we have enough data
          if (rdfifo_empty = '0') and ((fifo_fill_level >= upstream_min_message_size_r) or  -- FIFO has enough data
                                       (flush_req_mclk = '1')) then                         -- flush requested
            up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_SEND_HEADER;
            -- save the fifo count
            rdfifo_count_nxt          <= fifo_fill_level;
          end if;

          -- if the fifo is empty and a flush is requested proceed with sensing the flush command to the host
          if (rdfifo_empty = '1') and (flush_req_mclk = '1') then
            -- signal application that flush is in progress
            flush_ack_mclk_nxt     <= '1';
            up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_FLUSH_HEADER;
          end if;
          
        end if;

-- **
-- *** read related states
-- **

      when ST_MMI64_UPSTREAMIF_UP_READ_HEADER =>

        -- generate mmi64 packet header for settings read
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_UPSTREAMIF_READ,    -- command
          MMI64_ZERO_COMMAND_PARAMETER,  -- command parameter
          to_unsigned(MMI64_MODULE_READ_PAYLOAD_LEN, mmi64_payload_length_t'length),  -- payload length
          dn_tag_r                      -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_READ;
        end if;

-- **
-- *** identify related states
-- **

      when ST_MMI64_UPSTREAMIF_UP_IDENTIFY_HEADER =>

        -- generate mmi64 packet header for identify
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_IDENTIFY,           -- command
          MMI64_ZERO_COMMAND_PARAMETER,  -- command parameter
          to_unsigned(MMI64_MODULE_IDENTIFY_PAYLOAD_LEN, mmi64_payload_length_t'length),  -- payload length
          dn_identify_tag_r             -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        -- inform downstream path that identify request is handled
        up_identify_done <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDENTIFY_TYPE_AND_ID;
        end if;

      when ST_MMI64_UPSTREAMIF_UP_IDENTIFY_TYPE_AND_ID        =>
        -- generate common identify response
        mmi64_data_v                               := (others => '0');
        mmi64_data_v(mmi64_identify_module_type_r) := std_ulogic_vector(MMI64_TID_M_UPSTREAMIF);
        mmi64_data_v(mmi64_identify_module_id_r)   := convert(MODULE_ID);

        -- send identify data to upstream
        mmi64_h_up_d_o     <= mmi64_data_v;
        mmi64_h_up_valid_o <= '1';

        -- end of response message
        mmi64_h_up_stop_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDLE;
        end if;

-- **
-- *** return module settings to host
-- **

      when ST_MMI64_UPSTREAMIF_UP_READ        =>
        -- send settings
        mmi64_data_v               := (others => '0');
        mmi64_data_v(0)            := enable_r;
        mmi64_data_v(7 downto 1)   := std_ulogic_vector(to_unsigned(MMI64_UPSTREAMIF_VERSION, 7));
        mmi64_data_v(23 downto 8)  := std_ulogic_vector(upstream_max_message_size_r);
        mmi64_data_v(39 downto 24) := std_ulogic_vector(upstream_min_message_size_r);
        mmi64_data_v(63 downto 40) := std_ulogic_vector(to_unsigned(BUFF_AWIDTH, 24));

        -- send data to upstream
        mmi64_h_up_d_o     <= mmi64_data_v;
        mmi64_h_up_valid_o <= '1';

        -- end of response message
        mmi64_h_up_stop_o <= '1';

        -- inform downstream state machine that we are ready
        up_read_done <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDLE;
        end if;

-- **
-- *** upstream data
-- **

      when ST_MMI64_UPSTREAMIF_UP_SEND_HEADER =>

        -- if the FIFO contains more data then the message size we need to limit the size
        if rdfifo_count_r > upstream_max_message_size_r then
          message_size := resize(upstream_max_message_size_r, message_size'length);
        else
          message_size := resize(rdfifo_count_r, message_size'length);
        end if;

        -- generate mmi64 packet header
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_UPSTREAMIF_SEND,                            -- command
          MMI64_ZERO_COMMAND_PARAMETER,                         -- command parameter
          resize(message_size, mmi64_payload_length_t'length),  -- payload length
          send_tag_r                                            -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          up_upstreamif_state_r_nxt    <= ST_MMI64_UPSTREAMIF_UP_SEND_DATA;
          send_tag_nxt                 <= mmi64_tag_t(unsigned(send_tag_r) + 1);
          upstream_message_counter_nxt <= message_size - 1;
        end if;

      when ST_MMI64_UPSTREAMIF_UP_SEND_DATA =>
        -- generate payload for upstream data
        mmi64_h_up_d_o     <= rdfifo_rdata;
        mmi64_h_up_valid_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          rdfifo_renable               <= '1';
          upstream_message_counter_nxt <= upstream_message_counter_r - 1;

          if (upstream_message_counter_r = 0) then
            -- end of response message
            mmi64_h_up_stop_o         <= '1';
            up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDLE;
          end if;
        end if;

-- **
-- *** flush command
-- **

      when ST_MMI64_UPSTREAMIF_UP_FLUSH_HEADER =>

        -- generate mmi64 packet header for flush command
        mmi64_h_up_d_o <= mmi64_header_generate (
          MMI64_CMD_UPSTREAMIF_FLUSH,    -- command
          MMI64_ZERO_COMMAND_PARAMETER,  -- command parameter
          to_unsigned(MMI64_MODULE_FLUSH_PAYLOAD_LEN, mmi64_payload_length_t'length),  -- payload length
          send_tag_r                     -- tag
          );

        -- set start flag and indicate valid data
        mmi64_h_up_valid_o <= '1';
        mmi64_h_up_start_o <= '1';
        -- end of response message
        mmi64_h_up_stop_o <= '1';

        if mmi64_h_up_accept_i = '1' then
          send_tag_nxt              <= mmi64_tag_t(unsigned(send_tag_r) + 1);
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_FLUSH_NREQ;
        end if;

      when ST_MMI64_UPSTREAMIF_UP_FLUSH_NREQ =>
        -- handshake with application

        if flush_req_mclk = '0' then
          flush_ack_mclk_nxt        <= '0';
          up_upstreamif_state_r_nxt <= ST_MMI64_UPSTREAMIF_UP_IDLE;
        end if;

    end case;

  end process p_upstreamif_upstream;

  -- create registers
  p_ff : process (mmi64_clk)
  begin  -- process ff
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then         -- synchronous reset
        dn_upstreamif_state_r <= ST_MMI64_UPSTREAMIF_DN_IDLE;
        dn_command_r          <= (others => '0');
        dn_tag_r              <= (others => '0');
        dn_identify_tag_r     <= (others => '0');
        dn_do_identify_r      <= '0';
        dn_do_read_r          <= '0';

        up_upstreamif_state_r <= ST_MMI64_UPSTREAMIF_UP_IDLE;
        up_data_r             <= (others => '0');

        enable_r                    <= '0';
        enable_nxt_int_r            <= '0';
        upstream_max_message_size_r <= (others => '0');
        upstream_min_message_size_r <= (others => '0');
        send_tag_r                  <= (others => '0');
        upstream_message_counter_r  <= (others => '0');
        rdfifo_count_r              <= (others => '0');

        flush_req_mclk <= '0';
        flush_ack_mclk <= '0';
      else
        dn_upstreamif_state_r       <= dn_upstreamif_state_r_nxt;
        dn_command_r                <= dn_command_r_nxt;
        dn_tag_r                    <= dn_tag_r_nxt;
        dn_identify_tag_r           <= dn_identify_tag_r_nxt;
        dn_do_identify_r            <= dn_do_identify_r_nxt;
        dn_do_read_r                <= dn_do_read_r_nxt;

        up_upstreamif_state_r <= up_upstreamif_state_r_nxt;
        up_data_r             <= up_data_r_nxt;

        enable_r                    <= enable_nxt;
        enable_nxt_int_r            <= enable_nxt_int;
        upstream_max_message_size_r <= upstream_max_message_size_nxt;
        upstream_min_message_size_r <= upstream_min_message_size_nxt;
        send_tag_r                  <= send_tag_nxt;
        upstream_message_counter_r  <= upstream_message_counter_nxt;
        rdfifo_count_r <= rdfifo_count_nxt;

        flush_req_mclk <= flush_req_uclk;
        flush_ack_mclk <= flush_ack_mclk_nxt;
      end if;

    end if;
  end process p_ff;
  P_ff_upstream_clk: process (upstream_clk)
  begin
    if upstream_clk'event and upstream_clk = '1' then
      if upstream_reset = '1' then
        enable_r_upstream_clk <= '0';
        upstream_accept <= (others => '0');

        flush_req_uclk <= '0';
        flush_ack_uclk <= '0';
        upstream_flush_ack_o <= '0';
      else
        enable_r_upstream_clk <= enable_r;
        -- upstream_accept must be delayed by a few clock cycles to give the
        -- FIFO time to revover after reset
        upstream_accept <= upstream_accept(4 downto 0) & enable_r_upstream_clk;

        flush_req_uclk <= upstream_flush_req_i;
        flush_ack_uclk <= flush_ack_mclk;
        upstream_flush_ack_o <= flush_ack_uclk;
      end if;
    end if;
  end process P_ff_upstream_clk;

end architecture rtl;

-- =============================================================================
-- package of mmi64_m_upstreamif_core
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;

package mmi64_m_upstreamif_core_comp is

  component mmi64_m_upstreamif_core
    generic (
      MODULE_ID   : mmi64_module_id_t;
      BUFF_AWIDTH : natural;
      MMI64_UPSTREAMIF_VERSION: natural);
    port (
      mmi64_clk             : in  std_ulogic;
      mmi64_reset           : in  std_ulogic;
      mmi64_h_dn_d_i        : in  mmi64_data_t;
      mmi64_h_dn_valid_i    : in  std_ulogic;
      mmi64_h_dn_accept_o   : out std_ulogic;
      mmi64_h_dn_start_i    : in  std_ulogic;
      mmi64_h_dn_stop_i     : in  std_ulogic;
      mmi64_h_up_d_o        : out mmi64_data_t;
      mmi64_h_up_valid_o    : out std_ulogic;
      mmi64_h_up_accept_i   : in  std_ulogic;
      mmi64_h_up_start_o    : out std_ulogic;
      mmi64_h_up_stop_o     : out std_ulogic;
      upstream_clk          : in  std_ulogic;
      upstream_reset        : in  std_ulogic;
      upstream_d_i          : in  mmi64_data_t;
      upstream_valid_i      : in  std_ulogic;
      upstream_accept_o     : out std_ulogic;
      upstream_flush_req_i  : in  std_ulogic;
      upstream_flush_ack_o  : out std_ulogic;
      upstream_fifo_count_o : out std_ulogic_vector(BUFF_AWIDTH downto 0));
  end component;

end package mmi64_m_upstreamif_core_comp;

-- =============================================================================
-- wrapper for mmi64_m_upstreamif and mmi64_m_upstreamif_flush
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.mmi64_m_upstreamif_core_comp.all;

architecture rtl of mmi64_m_upstreamif is

begin

  inst_mmi64_m_upstreamif_core: mmi64_m_upstreamif_core
    generic map (
        MODULE_ID   => MODULE_ID,
        BUFF_AWIDTH => BUFF_AWIDTH,
        MMI64_UPSTREAMIF_VERSION => 1)
    port map (
        mmi64_clk             => mmi64_clk,
        mmi64_reset           => mmi64_reset,
        mmi64_h_dn_d_i        => mmi64_h_dn_d_i,
        mmi64_h_dn_valid_i    => mmi64_h_dn_valid_i,
        mmi64_h_dn_accept_o   => mmi64_h_dn_accept_o,
        mmi64_h_dn_start_i    => mmi64_h_dn_start_i,
        mmi64_h_dn_stop_i     => mmi64_h_dn_stop_i,
        mmi64_h_up_d_o        => mmi64_h_up_d_o,
        mmi64_h_up_valid_o    => mmi64_h_up_valid_o,
        mmi64_h_up_accept_i   => mmi64_h_up_accept_i,
        mmi64_h_up_start_o    => mmi64_h_up_start_o,
        mmi64_h_up_stop_o     => mmi64_h_up_stop_o,
        upstream_clk          => upstream_clk,
        upstream_reset        => upstream_reset,
        upstream_d_i          => upstream_d_i,
        upstream_valid_i      => upstream_valid_i,
        upstream_accept_o     => upstream_accept_o,
        upstream_flush_req_i  => '0',
        upstream_flush_ack_o  => open,
        upstream_fifo_count_o => open);

end rtl;

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mmi64_pkg.all;
use work.mmi64_m_upstreamif_core_comp.all;

architecture rtl of mmi64_m_upstreamif_flush is

begin

  inst_mmi64_m_upstreamif_core: mmi64_m_upstreamif_core
    generic map (
        MODULE_ID   => MODULE_ID,
        BUFF_AWIDTH => BUFF_AWIDTH,
        MMI64_UPSTREAMIF_VERSION => 2)
    port map (
        mmi64_clk             => mmi64_clk,
        mmi64_reset           => mmi64_reset,
        mmi64_h_dn_d_i        => mmi64_h_dn_d_i,
        mmi64_h_dn_valid_i    => mmi64_h_dn_valid_i,
        mmi64_h_dn_accept_o   => mmi64_h_dn_accept_o,
        mmi64_h_dn_start_i    => mmi64_h_dn_start_i,
        mmi64_h_dn_stop_i     => mmi64_h_dn_stop_i,
        mmi64_h_up_d_o        => mmi64_h_up_d_o,
        mmi64_h_up_valid_o    => mmi64_h_up_valid_o,
        mmi64_h_up_accept_i   => mmi64_h_up_accept_i,
        mmi64_h_up_start_o    => mmi64_h_up_start_o,
        mmi64_h_up_stop_o     => mmi64_h_up_stop_o,
        upstream_clk          => upstream_clk,
        upstream_reset        => upstream_reset,
        upstream_d_i          => upstream_d_i,
        upstream_valid_i      => upstream_valid_i,
        upstream_accept_o     => upstream_accept_o,
        upstream_flush_req_i  => upstream_flush_req_i,
        upstream_flush_ack_o  => upstream_flush_ack_o,
        upstream_fifo_count_o => upstream_fifo_count_o);

end rtl;
