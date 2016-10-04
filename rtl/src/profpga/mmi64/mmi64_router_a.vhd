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
--!  @file         mmi64_router_a.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        MMI64 router for building domain trees spanning
--!                multiple MMI64 modules (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.rtl_templates.all;
use work.mmi64_pkg.all;
use work.mmi64_router_upstream_comp.all;
use work.mmi64_buffer_comp.all;

--! implementation of mmi64_router
architecture rtl of mmi64_router is

  --! state definition for downstream state machine
  type mmi64_router_downstream_state_t is (
    ST_MMI64_ROUTER_DOWN_IDLE,          --! Downstrem path is idle; waiting for next message.
    ST_MMI64_ROUTER_DOWN_INITIALIZE,    --! Router performs MMI64 initialization.
    ST_MMI64_ROUTER_DOWN_ROUTE,         --! Router performs message routing from host to modules.
    ST_MMI64_ROUTER_DOWN_LOOPBACK       --! Router performs message loopback from host back to host.
    );

  --! state definition for upstream state machine
  type mmi64_router_upstream_state_t is (
    ST_MMI64_ROUTER_UP_IDLE,                     --! Upstream path is idle; waiting for next message.
    ST_MMI64_ROUTER_UP_ROUTE_HEADER,             --! Generate routing message header.
    ST_MMI64_ROUTER_UP_ROUTE_PAYLOAD,            --! Route message payload upstream.
    ST_MMI64_ROUTER_UP_IDENTIFY_HEADER,          --! Generate identify response header.
    ST_MMI64_ROUTER_UP_IDENTIFY_TYPE_AND_ID,     --! Send identify response to upstream.
    ST_MMI64_ROUTER_UP_IDENTIFY_PORT_COUNT,      --! Send identify response to upstream.
    ST_MMI64_ROUTER_UP_IDENTIFY_MODULE_PRESENCE, --! Send module presence information via identify response
    ST_MMI64_ROUTER_UP_LOOPBACK_HEADER,          --! Generate loopback header.
    ST_MMI64_ROUTER_UP_LOOPBACK_PAYLOAD          --! Send incoming downstream message back to upstream.
    );

  --! number of data words in identify response from router
  constant MMI64_ROUTER_IDENTIFY_PAYLOAD_LEN : natural := 1;

  signal mmi64_h_up_d_int_o      : mmi64_data_t;  --! to be buffered data to upstream router or phy
  signal mmi64_h_up_valid_int_o  : std_ulogic;    --! to be buffered data valid to upstream router or phy
  signal mmi64_h_up_accept_int_i : std_ulogic;    --! buffered data accept from upstream router or phy
  signal mmi64_h_up_start_int_o  : std_ulogic;    --! to be buffered start of packet from upstream router or phy
  signal mmi64_h_up_stop_int_o   : std_ulogic;    --! to be buffered end of packet from upstream router or phy

  signal mmi64_h_dn_d_int_i      : mmi64_data_t;  --! buffered data from upstream router or phy
  signal mmi64_h_dn_valid_int_i  : std_ulogic;    --! buffered data valid from upstream router or phy
  signal mmi64_h_dn_accept_int_o : std_ulogic;    --! to be buffered data accept to upstream router or phy
  signal mmi64_h_dn_start_int_i  : std_ulogic;    --! buffered start of packet from upstream router or phy
  signal mmi64_h_dn_stop_int_i   : std_ulogic;    --! buffered end of packet from upstream router or phy

  signal mmi64_m_up_d_int_i          : mmi64_data_vector_t(0 to PORT_COUNT-1);  --! data from downstream router or module
  signal mmi64_m_up_valid_int_i      : std_ulogic_vector(0 to PORT_COUNT-1);    --! data valid from downstream router or module
  signal mmi64_m_up_accept_int_o     : std_ulogic_vector(0 to PORT_COUNT-1);    --! data accept to downstream router or module
  signal mmi64_m_up_start_int_i      : std_ulogic_vector(0 to PORT_COUNT-1);    --! start of packet from downstream router or module
  signal mmi64_m_up_stop_int_i       : std_ulogic_vector(0 to PORT_COUNT-1);    --! end of packet from  downstream router or module

  signal mmi64_m_dn_d_int_o          : mmi64_data_vector_t(0 to PORT_COUNT-1);  --! data to downstream router or module
  signal mmi64_m_dn_valid_int_o      : std_ulogic_vector(0 to PORT_COUNT-1);    --! data valid to downstream router or module
  signal mmi64_m_dn_accept_int_i     : std_ulogic_vector(0 to PORT_COUNT-1);    --! data accept from downstream router or module
  signal mmi64_m_dn_start_int_o      : std_ulogic_vector(0 to PORT_COUNT-1);    --! start of packet from downstream router or module
  signal mmi64_m_dn_stop_int_o       : std_ulogic_vector(0 to PORT_COUNT-1);    --! end of packet from downstream router or module

  --! state of downstream state machine
  signal dn_state_r     : mmi64_router_downstream_state_t;
  signal dn_state_r_nxt : mmi64_router_downstream_state_t;

  --! store payload length for receiver
  signal dn_payload_len_r     : mmi64_payload_length_t;
  signal dn_payload_len_r_nxt : mmi64_payload_length_t;

  --! store target module id of downstream routing request
  signal dn_target_module_addr_r     : unsigned(7 downto 0);
  signal dn_target_module_addr_r_nxt : unsigned(7 downto 0);

  --! loopback request initiated by downstream
  signal dn_do_loopback_r        : std_ulogic;
  signal dn_do_loopback_r_nxt    : std_ulogic;

  --! identify request initiated by downstream
  signal dn_do_identify_r        : std_ulogic;
  signal dn_do_identify_r_nxt    : std_ulogic;

  --! initialize request initiated by downstream
  signal dn_do_initialize        : std_ulogic;

  --! tag used during downstream packet generation
  signal dn_mmi64_tag_r          : mmi64_tag_t;
  signal dn_mmi64_tag_r_nxt      : mmi64_tag_t;

  --! tag derived from latest identify request. Since identify requests are processed asynchronously
  --! (not blocking downstream path) tag needs to be stored separately in order to prevent
  --! next downstream message from overwriting the tag.
  signal dn_mmi64_identify_tag_r      : mmi64_tag_t;
  signal dn_mmi64_identify_tag_r_nxt  : mmi64_tag_t;

  --! connection between downstream and upstream path used by loopback communication
  signal dn_loopback_d              : mmi64_data_t;         --! data for loopback connection
  signal dn_loopback_valid          : std_ulogic;           --! loopback data valid

  --! do gemerate start flag on module port
  signal dn_start_r                 : std_ulogic;
  signal dn_start_r_nxt             : std_ulogic;

  --! state of downstream state machine
  signal up_state_r     : mmi64_router_upstream_state_t;
  signal up_state_r_nxt : mmi64_router_upstream_state_t;

  --! store payload length for transmitter (module payload plus router command length)
  signal up_payload_len_r     : mmi64_payload_length_t;
  signal up_payload_len_r_nxt : mmi64_payload_length_t;

  --! store module id for transmitter
  signal up_source_module_addr_r     : unsigned(7 downto 0);
  signal up_source_module_addr_r_nxt : unsigned(7 downto 0);

  -- signals from upstream module block
  signal up_resync         : std_ulogic_vector(0 to PORT_COUNT-1);       -- resynchronize to next packet header
  signal up_request        : std_ulogic_vector(0 to PORT_COUNT-1);       -- data stream is in sync with data header
  signal up_last           : std_ulogic_vector(0 to PORT_COUNT-1);       -- data stream data word is last one current mmi64 message
  signal up_payload        : mmi64_data_vector_t(0 to PORT_COUNT-1);     -- upstream payload
  signal up_payload_valid  : std_ulogic_vector(0 to PORT_COUNT-1);       -- upstream payload valid
  signal up_payload_accept : std_ulogic_vector(0 to PORT_COUNT-1);       -- upstream paylaod accepted

  -- acknowlegement signals for request from downstream path
  signal up_identify_done    : std_ulogic;  --! pending identify request has been processed
  signal up_loopback_done    : std_ulogic;  --! pending loopback request has been processed

  -- signals from upstream scheduler
  signal up_routing_request               : std_ulogic;           --! module port is requesting message routing
  signal up_routing_request_module_addr   : mmi64_module_addr_t;  --! address of module port requesting message routing

  -- tag used during upstream message generation
  signal up_tag_r                : mmi64_tag_t;  --! mmi64 message tag (register)
  signal up_tag_r_nxt            : mmi64_tag_t;  --! mmi64 message tag (next)

  --! connection between downstream and upstream path used by loopback communication
  signal up_loopback_accept         : std_ulogic;           --! loopback data accept

  -- identify response packet counter for module presence information
  signal up_identify_presence_packet_counter_r_nxt : unsigned(log2(MMI64_MODULES_PER_ROUTER_MAX/MMI64_DATA_WIDTH)-1 downto 0);
  signal up_identify_presence_packet_counter_r     : unsigned(log2(MMI64_MODULES_PER_ROUTER_MAX/MMI64_DATA_WIDTH)-1 downto 0);

  -- module start bit index for module presence information
  signal up_identify_module_start_idx_r            : unsigned(log2(MMI64_MODULES_PER_ROUTER_MAX)-1 downto 0);
  signal up_identify_module_start_idx_r_nxt        : unsigned(log2(MMI64_MODULES_PER_ROUTER_MAX)-1 downto 0);

  -- module initialization request
  signal initialize_module_r                       : std_ulogic_vector(0 to PORT_COUNT-1);
  signal initialize_module_r_nxt                   : std_ulogic_vector(0 to PORT_COUNT-1);

  -- module initialization command buffer (required to decouple uplink and downlink ports)
  signal initialization_command_r                  : mmi64_data_t;
  signal initialization_command_r_nxt              : mmi64_data_t;

begin  --! rtl

  --! transmit data from phy or upstream router to mmi64 module or downstream router
  p_downstream : process (dn_do_identify_r, dn_do_loopback_r, dn_mmi64_identify_tag_r, dn_mmi64_tag_r, dn_payload_len_r, dn_start_r, dn_state_r, dn_target_module_addr_r, initialization_command_r, initialize_module_r, mmi64_h_dn_d_int_i, mmi64_h_dn_start_int_i, mmi64_h_dn_valid_int_i, mmi64_m_dn_accept_int_i, module_presence_detection_i, up_identify_done, up_loopback_accept, up_loopback_done)
  begin

    -- default assignment
    dn_payload_len_r_nxt         <= dn_payload_len_r;
    dn_mmi64_tag_r_nxt           <= dn_mmi64_tag_r;
    dn_mmi64_identify_tag_r_nxt  <= dn_mmi64_identify_tag_r;
    dn_do_identify_r_nxt         <= dn_do_identify_r;
    dn_do_loopback_r_nxt         <= dn_do_loopback_r;
    dn_state_r_nxt               <= dn_state_r;          -- hold router downstream state
    dn_loopback_d                <= (others => '0');
    dn_loopback_valid            <= '0';
    dn_target_module_addr_r_nxt  <= dn_target_module_addr_r;
    initialization_command_r_nxt <= initialization_command_r;
    initialize_module_r_nxt      <= initialize_module_r;

    mmi64_h_dn_accept_int_o     <= '0';         -- do no accept downstream data on host port
    dn_start_r_nxt              <= dn_start_r;  -- disable downstream start signal on module ports
    mmi64_initialize_o          <= '0';
    dn_do_initialize            <= '0';

    -- disable all downstream ports towards modules
    mmi64_m_dn_d_int_o         <= (others => (others => '-'));
    mmi64_m_dn_valid_int_o     <= (others => '0');
    mmi64_m_dn_start_int_o     <= (others => '0');
    mmi64_m_dn_stop_int_o      <= (others => '0');

    -- reset mmi64 identify request flag
    if (up_identify_done = '1') then
      dn_do_identify_r_nxt <= '0';
    end if;

    -- reset mmi64 loopback request flag
    if (up_loopback_done = '1') then
      dn_do_loopback_r_nxt <= '0';
    end if;

    -- downstream is idle or forced to start a new transfer?
    if (dn_state_r = ST_MMI64_ROUTER_DOWN_IDLE) or (mmi64_h_dn_valid_int_i = '1' and mmi64_h_dn_start_int_i = '1') then

      -- *** downstream is idle waiting for a new mmi64 message

      -- assume to stay in idle state
      dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_IDLE;

      -- accept downstream data on host port
      mmi64_h_dn_accept_int_o    <= '1';

      -- extract number of mmi64 words to loop back upstream
      dn_payload_len_r_nxt <= mmi64_payload_length(mmi64_h_dn_d_int_i);

      -- extract mmi64 tag header
      dn_mmi64_tag_r_nxt <= mmi64_tag(mmi64_h_dn_d_int_i);

      -- extract mmi64 tag header
      dn_mmi64_identify_tag_r_nxt <= mmi64_tag(mmi64_h_dn_d_int_i);

      -- extract routing target
      dn_target_module_addr_r_nxt <= mmi64_command_parameter(mmi64_h_dn_d_int_i);

      -- begin of valid downstream message?
      if mmi64_header_is_valid(mmi64_h_dn_d_int_i) and (mmi64_h_dn_valid_int_i='1') then

        -- evaluate downstream command
        case mmi64_command_t'(mmi64_command(mmi64_h_dn_d_int_i)) is
          when MMI64_CMD_INITIALIZE =>
            -- enter initialization state
            dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_INITIALIZE;

            -- request initialization of all present modules
            initialize_module_r_nxt <= module_presence_detection_i;

            -- store initialization command
            initialization_command_r_nxt <=mmi64_h_dn_d_int_i;

          when MMI64_CMD_IDENTIFY =>
            -- trigger generation of identify response
            dn_do_identify_r_nxt <= '1';

          when MMI64_CMD_LOOPBACK =>
            -- enter loopback state
            dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_LOOPBACK;

            -- trigger generation of loopback response
            dn_do_loopback_r_nxt <= '1';

          when MMI64_CMD_ROUTE =>
            -- enter routing state
            dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_ROUTE;

            -- prepare generation of create message start signal on downstream module port
            dn_start_r_nxt <= '1';

          when others =>
            -- other commands are not supported an will be ignored
            null;
        end case;

      end if;

    elsif dn_state_r = ST_MMI64_ROUTER_DOWN_INITIALIZE then
      -- *** propagate module initialization request to all downstream ports

      -- transmit identify payload word to all modules
      for module_idx in 0 to PORT_COUNT-1 loop
        mmi64_m_dn_d_int_o(module_idx) <= initialization_command_r;
      end loop;

      -- send initialization command to all modules that did not accept yet.
      mmi64_m_dn_valid_int_o <= initialize_module_r;

      -- downlink ports accepts initialze command?
      for module_idx in 0 to PORT_COUNT-1 loop
        if mmi64_m_dn_accept_int_i(module_idx) = '1' then
          -- mark initialization as done for given module
          initialize_module_r_nxt(module_idx) <= '0';
        end if;
      end loop;

      -- return to idle, if all downlink ports accepted initialization
      if unsigned(initialize_module_r) = 0 then
        dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_IDLE;
      end if;

      -- indicate initialization state
      mmi64_initialize_o <= '1';

      -- trigger initialzation of upstream path
      dn_do_initialize   <= '1';

    elsif dn_state_r = ST_MMI64_ROUTER_DOWN_LOOPBACK then
      -- *** loopback command: send mmi64 message data upstream

      -- data available from upstream?
      if (mmi64_h_dn_valid_int_i = '1') then

        -- provide mmi64 word to loopback connection
        dn_loopback_d <= std_ulogic_vector(mmi64_h_dn_d_int_i);

        -- indicate to upstream path that loopback data is valid
        dn_loopback_valid <= '1';

        -- upload path accepts loopback accepts data?
        if up_loopback_accept = '1' then
          -- decrease payload length counter
          dn_payload_len_r_nxt <= dn_payload_len_r - 1;

          -- acknowlege current byte to upstream
          mmi64_h_dn_accept_int_o <= '1';

          -- check if this is the last payload byte to be transferred
          if dn_payload_len_r = 1 then
            -- return to idle state and prepare for next transfer
            dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_IDLE;
          end if;
        end if;
      end if;

    elsif dn_state_r = ST_MMI64_ROUTER_DOWN_ROUTE then

      -- *** route command: send mmi64 message data downstream

      -- data available from upstream?
      if (mmi64_h_dn_valid_int_i = '1') then

        -- transmit next payload word to module
        mmi64_m_dn_d_int_o(to_integer(dn_target_module_addr_r)) <= std_ulogic_vector(mmi64_h_dn_d_int_i);

        -- indicate to module that data is valid
        mmi64_m_dn_valid_int_o(to_integer(dn_target_module_addr_r)) <= '1';

        -- last word of payload transfer?
        if dn_payload_len_r = 1 then
          -- indicate end of transfer to module
          mmi64_m_dn_stop_int_o(to_integer(dn_target_module_addr_r)) <= '1';
        end if;

        -- generate start flag on first word of routed message
        mmi64_m_dn_start_int_o(to_integer(dn_target_module_addr_r)) <= dn_start_r;

        -- module accepts data?
        if mmi64_m_dn_accept_int_i(to_integer(dn_target_module_addr_r)) = '1' then
          -- decrease payload length counter
          dn_payload_len_r_nxt <= dn_payload_len_r - 1;

          -- acknowlege current byte to upstream
          mmi64_h_dn_accept_int_o <= '1';

          -- reset the start flag
          dn_start_r_nxt <= '0';

          -- check if this is the last payload byte to be transferred
          if dn_payload_len_r = 1 then
            -- return to idle state and prepare for next transfer
            dn_state_r_nxt <= ST_MMI64_ROUTER_DOWN_IDLE;
            mmi64_m_dn_stop_int_o(to_integer(dn_target_module_addr_r)) <= '1';
          end if;
        end if;
      end if;
    end if;

  end process p_downstream;

  --! upstream modules check and align incoming mmi64 messages from modules ports and indicate routing requests to upstream scheduler
  g_upstream_modules : for module_idx in 0 to PORT_COUNT-1 generate
    mmi64_router_upstream_inst : mmi64_router_upstream
      port map (
        mmi64_clk              => mmi64_clk,
        mmi64_reset            => mmi64_reset,
        mmi64_m_up_d_i         => mmi64_m_up_d_int_i(module_idx),
        mmi64_m_up_valid_i     => mmi64_m_up_valid_int_i(module_idx),
        mmi64_m_up_accept_o    => mmi64_m_up_accept_int_o(module_idx),
        mmi64_m_up_start_i     => mmi64_m_up_start_int_i(module_idx),
        mmi64_m_up_stop_i      => mmi64_m_up_stop_int_i(module_idx),
        up_resync_i            => up_resync(module_idx),
        up_request_o           => up_request(module_idx),
        up_last_o              => up_last(module_idx),
        up_payload_o           => up_payload(module_idx),
        up_payload_valid_o     => up_payload_valid(module_idx),
        up_payload_accept_i    => up_payload_accept(module_idx)
        );
  end generate g_upstream_modules;

  --! evaluate requests from upstream module ports and select module which is next in line
  p_upstream_scheduler : process (up_request, up_source_module_addr_r)
    variable priority_module_addr_v   : mmi64_module_addr_t;
    variable priority_module_found_v  : std_ulogic;

    variable alternate_module_addr_v  : mmi64_module_addr_t;
    variable alternate_module_found_v : std_ulogic;

    variable module_index_unsigned_v  : mmi64_module_addr_t;

  begin
    -- set defaults
    priority_module_found_v  := '0';
    priority_module_addr_v   := (others=>'-');
    alternate_module_found_v := '0';
    alternate_module_addr_v  := (others=>'-');

    for module_idx in PORT_COUNT-1 downto 0 loop

      module_index_unsigned_v := to_unsigned(module_idx, module_index_unsigned_v'length);

      if up_request(module_idx) = '1' then
        if module_index_unsigned_v > up_source_module_addr_r then
          priority_module_addr_v := module_index_unsigned_v;
          priority_module_found_v := '1';
        else
          alternate_module_addr_v := module_index_unsigned_v;
          alternate_module_found_v := '1';
        end if;
      end if;
    end loop;

    up_routing_request <= priority_module_found_v or alternate_module_found_v;

    if priority_module_found_v = '1' then
      up_routing_request_module_addr <= priority_module_addr_v;
    else
      up_routing_request_module_addr <= alternate_module_addr_v;
    end if;

  end process p_upstream_scheduler;

  --! transmit data from mmi64 module or downstream router to phy or upstream router
  p_upstream : process (dn_do_identify_r, dn_do_initialize, dn_do_loopback_r, dn_loopback_d, dn_loopback_valid, dn_mmi64_identify_tag_r, dn_mmi64_tag_r, dn_payload_len_r, mmi64_h_up_accept_int_i, module_presence_detection_i, up_identify_module_start_idx_r, up_identify_presence_packet_counter_r, up_last, up_payload, up_payload_len_r, up_payload_valid, up_routing_request, up_routing_request_module_addr, up_source_module_addr_r, up_state_r, up_tag_r)
    variable mmi64_data_v : mmi64_data_t;
    variable up_payload_len_v : mmi64_payload_length_t;
    variable up_tag_v         : mmi64_tag_t;
  begin
    -- hold current state, module id and payload length
    up_state_r_nxt   <= up_state_r;
    up_source_module_addr_r_nxt     <= up_source_module_addr_r;
    up_payload_len_r_nxt   <= up_payload_len_r;
    up_tag_r_nxt           <= up_tag_r;
    up_resync              <= (others => '0');  -- no need to resync upstream ports to packet headers
    up_payload_accept      <= (others => '0');  -- don't get payload from upstream fifo
    up_loopback_accept     <= '0';

    -- counters for identify presence packet generation
    up_identify_presence_packet_counter_r_nxt <= up_identify_presence_packet_counter_r;
    up_identify_module_start_idx_r_nxt        <= up_identify_module_start_idx_r;

    up_identify_done    <= '0';
    up_loopback_done    <= '0';

    -- disable outgoing uplink port
    mmi64_h_up_d_int_o     <= (others => '0');
    mmi64_h_up_valid_int_o <= '0';
    mmi64_h_up_start_int_o <= '0';
    mmi64_h_up_stop_int_o  <= '0';

    case up_state_r is
      when ST_MMI64_ROUTER_UP_IDLE =>
        -- *** upstream path is idle: wait for new request

        if dn_do_identify_r = '1' then
          -- handle mmi64 identify request
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDENTIFY_HEADER;

          -- inform downstream path that identify request is handled
          up_identify_done <= '1';

          -- copy message tag from original request
          up_tag_r_nxt <= dn_mmi64_identify_tag_r;

          -- set payload size
          up_payload_len_r_nxt <= to_unsigned(MMI64_MODULES_PER_ROUTER_MAX/MMI64_DATA_WIDTH+2, up_payload_len_r_nxt'length);

        elsif dn_do_loopback_r = '1' then
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_LOOPBACK_HEADER;

          -- inform downstream path that identify request is handled
          up_loopback_done <= '1';

          -- copy message tag from original request
          up_tag_r_nxt <= dn_mmi64_tag_r;

          -- set payload size for loopback downstream message to upstream
          up_payload_len_r_nxt <= dn_payload_len_r;

        else

          -- request from any module port to send data upstream?
          if up_routing_request='1' then

            -- store id of module that is next in line to transmit data upstream
            up_source_module_addr_r_nxt <= up_routing_request_module_addr;

            -- advance to generation of mmi64 routing header
            up_state_r_nxt <= ST_MMI64_ROUTER_UP_ROUTE_HEADER;
          end if;
        end if;

-- **
-- *** handle upstream routing request
-- **

      when ST_MMI64_ROUTER_UP_ROUTE_HEADER =>

        -- set payload size (including header word)
        up_payload_len_v := mmi64_payload_length(up_payload(to_integer(up_source_module_addr_r))) + 1;
        up_payload_len_r_nxt <= up_payload_len_v;

        -- set message tag
        up_tag_v := mmi64_tag(up_payload(to_integer(up_source_module_addr_r)));
        up_tag_r_nxt <= up_tag_v;

        -- generate mmi64 packet header for routing
        mmi64_h_up_d_int_o <= mmi64_header_generate (
          MMI64_CMD_ROUTE,                             -- command
          up_source_module_addr_r,                     -- command parameter
          up_payload_len_v,                            -- payload length
          up_tag_v                                     -- tag
          );

        -- send data word upstream
        mmi64_h_up_valid_int_o <= '1';

        -- signal start of new message to upstream
        mmi64_h_up_start_int_o <= '1';

        if mmi64_h_up_accept_int_i = '1' then

          -- advance to upstream payload from module to host
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_ROUTE_PAYLOAD;
        end if;

      when ST_MMI64_ROUTER_UP_ROUTE_PAYLOAD =>

        -- feed through payload word
        mmi64_h_up_d_int_o     <= up_payload(to_integer(up_source_module_addr_r));
        mmi64_h_up_valid_int_o <= up_payload_valid(to_integer(up_source_module_addr_r));

        -- last word of message transfer?
        if up_payload_len_r = 1 then
          -- signal end of message to upstream
          mmi64_h_up_stop_int_o <= '1';
        end if;

        -- valid data accepted by upstream
        if mmi64_h_up_accept_int_i = '1' and up_payload_valid(to_integer(up_source_module_addr_r)) = '1' then

          -- accept data transfer to module
          up_payload_accept(to_integer(up_source_module_addr_r)) <= '1';

          -- decrease payload counter
          up_payload_len_r_nxt <= up_payload_len_r - 1;

          -- terminate after transfer of last payload byte
          if (up_payload_len_r = 1) or (up_last(to_integer(up_source_module_addr_r)) = '1') then
            -- return to idle state
            up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDLE;

            -- trigger resynchronisation of port state machine
            up_resync(to_integer(up_source_module_addr_r)) <= '1';
          end if;
        end if;

-- **
-- *** handle controller identification request
-- **

      when ST_MMI64_ROUTER_UP_IDENTIFY_HEADER =>
        -- generate mmi64 packet header for identify
        mmi64_h_up_d_int_o <= mmi64_header_generate (
          MMI64_CMD_IDENTIFY,                          -- command
          up_source_module_addr_r,                     -- command parameter
          up_payload_len_r,                            -- payload length
          up_tag_r                                     -- tag
          );

        -- send data word upstream
        mmi64_h_up_valid_int_o <= '1';

        -- signal start of new message to upstream
        mmi64_h_up_start_int_o <= '1';

        if mmi64_h_up_accept_int_i = '1' then

          -- advance to upstream payload from module to host
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDENTIFY_TYPE_AND_ID;
        end if;

      when ST_MMI64_ROUTER_UP_IDENTIFY_TYPE_AND_ID =>
        -- generate common identify response
        mmi64_data_v := (others=>'0');
        mmi64_data_v(mmi64_identify_module_type_r) := std_ulogic_vector(MMI64_TID_ROUTER);
        mmi64_data_v(mmi64_identify_module_id_r)   := convert(MODULE_ID);

        -- send identify data to upstream
        mmi64_h_up_d_int_o     <= mmi64_data_v;
        mmi64_h_up_valid_int_o <= '1';

        if mmi64_h_up_accept_int_i = '1' then
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDENTIFY_PORT_COUNT;
        end if;

      when ST_MMI64_ROUTER_UP_IDENTIFY_PORT_COUNT =>
        -- generate router specific common identify response packet
        mmi64_data_v := (others=>'0');
        mmi64_data_v(7 downto 0) := std_ulogic_vector(to_unsigned(PORT_COUNT, 8));

        -- send identify data to upstream
        mmi64_h_up_d_int_o     <= mmi64_data_v;
        mmi64_h_up_valid_int_o <= '1';

        -- initialize presence packet counter and module bit base
        up_identify_presence_packet_counter_r_nxt <= (others=>'0');
        up_identify_module_start_idx_r_nxt        <= (others=>'0');

        if mmi64_h_up_accept_int_i = '1' then
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDENTIFY_MODULE_PRESENCE;
        end if;

      when ST_MMI64_ROUTER_UP_IDENTIFY_MODULE_PRESENCE =>

        -- send module presence state
        for bit_idx in MMI64_DATA_WIDTH-1 downto 0 loop
          if up_identify_module_start_idx_r+bit_idx < PORT_COUNT then
            mmi64_h_up_d_int_o(bit_idx) <= module_presence_detection_i(to_integer(up_identify_module_start_idx_r+bit_idx));
          else
            mmi64_h_up_d_int_o(bit_idx) <=  '0';
          end if;
        end loop;

        mmi64_h_up_valid_int_o <= '1';

        if mmi64_h_up_accept_int_i = '1' then
          -- update presence packet counter and module bit base
          up_identify_presence_packet_counter_r_nxt <= up_identify_presence_packet_counter_r + 1;
          up_identify_module_start_idx_r_nxt        <= up_identify_module_start_idx_r + MMI64_DATA_WIDTH;
        end if;

        -- last identify packet?
        if up_identify_presence_packet_counter_r = to_unsigned(MMI64_MODULES_PER_ROUTER_MAX / MMI64_DATA_WIDTH-1, up_identify_presence_packet_counter_r'length) then

          -- mark end of identify reponse message
          mmi64_h_up_stop_int_o  <= '1';

          if mmi64_h_up_accept_int_i = '1' then
            up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDLE;
          end if;

        end if;

-- **
-- *** handle loopback request
-- **

      when ST_MMI64_ROUTER_UP_LOOPBACK_HEADER =>
        -- generate mmi64 packet header for loopback
        mmi64_h_up_d_int_o <= mmi64_header_generate (
          MMI64_CMD_LOOPBACK,                          -- command
          x"00",                                       -- command parameter
          up_payload_len_r,                            -- payload length
          up_tag_r                                     -- tag
          );

        -- send data word upstream
        mmi64_h_up_valid_int_o <= '1';

        -- signal start of new message to upstream
        mmi64_h_up_start_int_o <= '1';

        -- host accepts our data?
        if mmi64_h_up_accept_int_i = '1' then
          -- advance to upstream payload from module to host
          up_state_r_nxt <= ST_MMI64_ROUTER_UP_LOOPBACK_PAYLOAD;
        end if;

      when ST_MMI64_ROUTER_UP_LOOPBACK_PAYLOAD =>

        -- feed through payload word
        mmi64_h_up_d_int_o     <= dn_loopback_d;
        mmi64_h_up_valid_int_o <= dn_loopback_valid;

        -- last word of message transfer?
        if up_payload_len_r = 1 then
          -- signal end of message to upstream
          mmi64_h_up_stop_int_o <= '1';
        end if;

        -- valid data accepted by upstream
        if mmi64_h_up_accept_int_i = '1' and dn_loopback_valid = '1' then

          -- accept loopback data transfer to downstream path
          up_loopback_accept <= '1';

          -- decrease payload length counter
          up_payload_len_r_nxt <= up_payload_len_r - 1;

          -- terminate after transfer of last payload byte
          if up_payload_len_r = 1 then
            -- return to idle state
            up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDLE;
          end if;
        end if;

    end case;

    -- initialize upstream path
    if dn_do_initialize = '1' then
      up_state_r_nxt <= ST_MMI64_ROUTER_UP_IDLE;
    end if;

  end process p_upstream;

  --! create internal registers
  p_ff : process (mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
        dn_state_r                            <= ST_MMI64_ROUTER_DOWN_IDLE;
        dn_payload_len_r                      <= (others => '0');
        dn_target_module_addr_r               <= (others => '0');
        dn_start_r                            <= '0';
        dn_do_identify_r                      <= '0';
        dn_do_loopback_r                      <= '0';
        dn_mmi64_tag_r                        <= (others => '0');
        dn_mmi64_identify_tag_r               <= (others => '0');
        up_state_r                            <= ST_MMI64_ROUTER_UP_IDLE;
        up_payload_len_r                      <= (others => '0');
        up_source_module_addr_r               <= (others => '0');
        up_tag_r                              <= (others => '0');
        up_identify_module_start_idx_r        <= (others => '0');
        up_identify_presence_packet_counter_r <= (others => '0');
        initialization_command_r              <= (others => '0');
        initialize_module_r                   <= (others => '0');
      else
        dn_state_r                            <= dn_state_r_nxt;
        dn_payload_len_r                      <= dn_payload_len_r_nxt;
        dn_target_module_addr_r               <= dn_target_module_addr_r_nxt;
        dn_start_r                            <= dn_start_r_nxt;
        dn_do_identify_r                      <= dn_do_identify_r_nxt;
        dn_do_loopback_r                      <= dn_do_loopback_r_nxt;
        dn_mmi64_tag_r                        <= dn_mmi64_tag_r_nxt;
        dn_mmi64_identify_tag_r               <= dn_mmi64_identify_tag_r_nxt;
        up_state_r                            <= up_state_r_nxt;
        up_payload_len_r                      <= up_payload_len_r_nxt;
        up_source_module_addr_r               <= up_source_module_addr_r_nxt;
        up_tag_r                              <= up_tag_r_nxt;
        up_identify_module_start_idx_r        <= up_identify_module_start_idx_r_nxt;
        up_identify_presence_packet_counter_r <= up_identify_presence_packet_counter_r_nxt;
        initialization_command_r              <= initialization_command_r_nxt;
        initialize_module_r                   <= initialize_module_r_nxt;
      end if;
    end if;
  end process p_ff;

--  mmi64_h_up_d_o          <= mmi64_h_up_d_int_o;
--  mmi64_h_up_valid_o      <= mmi64_h_up_valid_int_o;
--  mmi64_h_up_accept_int_i <= mmi64_h_up_accept_i;
--  mmi64_h_up_start_o      <= mmi64_h_up_start_int_o;
--  mmi64_h_up_stop_o       <= mmi64_h_up_stop_int_o;
--
--  mmi64_h_dn_d_int_i      <= mmi64_h_dn_d_i;
--  mmi64_h_dn_valid_int_i  <= mmi64_h_dn_valid_i;
--  mmi64_h_dn_accept_o     <= mmi64_h_dn_accept_int_o;
--  mmi64_h_dn_start_int_i  <= mmi64_h_dn_start_i;
--  mmi64_h_dn_stop_int_i   <= mmi64_h_dn_stop_i;

  router_uplink_buffer_inst: mmi64_buffer
    generic map (
      DOWNSTREAM_BUFFER_ENABLE_HOLDOFF => 0,
      UPSTREAM_BUFFER_ENABLE_HOLDOFF   => 0
      )
    port map (
      mmi64_clk           => mmi64_clk,
      mmi64_reset         => mmi64_reset,

      mmi64_h_up_d_o      => mmi64_h_up_d_o,
      mmi64_h_up_valid_o  => mmi64_h_up_valid_o,
      mmi64_h_up_accept_i => mmi64_h_up_accept_i,
      mmi64_h_up_start_o  => mmi64_h_up_start_o,
      mmi64_h_up_stop_o   => mmi64_h_up_stop_o,
      mmi64_h_dn_d_i      => mmi64_h_dn_d_i,
      mmi64_h_dn_valid_i  => mmi64_h_dn_valid_i,
      mmi64_h_dn_accept_o => mmi64_h_dn_accept_o,
      mmi64_h_dn_start_i  => mmi64_h_dn_start_i,
      mmi64_h_dn_stop_i   => mmi64_h_dn_stop_i,

      mmi64_m_up_d_i      => mmi64_h_up_d_int_o,
      mmi64_m_up_valid_i  => mmi64_h_up_valid_int_o,
      mmi64_m_up_accept_o => mmi64_h_up_accept_int_i,
      mmi64_m_up_start_i  => mmi64_h_up_start_int_o,
      mmi64_m_up_stop_i   => mmi64_h_up_stop_int_o,
      mmi64_m_dn_d_o      => mmi64_h_dn_d_int_i,
      mmi64_m_dn_valid_o  => mmi64_h_dn_valid_int_i,
      mmi64_m_dn_accept_i => mmi64_h_dn_accept_int_o,
      mmi64_m_dn_start_o  => mmi64_h_dn_start_int_i,
      mmi64_m_dn_stop_o   => mmi64_h_dn_stop_int_i
      );

--  mmi64_m_up_d_int_i      <= mmi64_m_up_d_i;
--  mmi64_m_up_valid_int_i  <= mmi64_m_up_valid_i;
--  mmi64_m_up_accept_o     <= mmi64_m_up_accept_int_o;
--  mmi64_m_up_start_int_i  <= mmi64_m_up_start_i;
--  mmi64_m_up_stop_int_i   <= mmi64_m_up_stop_i;
--
--  mmi64_m_dn_d_o          <= mmi64_m_dn_d_int_o;
--  mmi64_m_dn_valid_o      <= mmi64_m_dn_valid_int_o;
--  mmi64_m_dn_accept_int_i <= mmi64_m_dn_accept_i;
--  mmi64_m_dn_start_o      <= mmi64_m_dn_start_int_o;
--  mmi64_m_dn_stop_o       <= mmi64_m_dn_stop_int_o;

  g_router_downlink_buffer : for module_idx in 0 to PORT_COUNT-1 generate
    router_downlink_buffer_inst: mmi64_buffer
      generic map (
        DOWNSTREAM_BUFFER_ENABLE_HOLDOFF => 0,
        UPSTREAM_BUFFER_ENABLE_HOLDOFF   => 0
        )
      port map (
        mmi64_clk           => mmi64_clk,
        mmi64_reset         => mmi64_reset,

        mmi64_h_up_d_o      => mmi64_m_up_d_int_i(module_idx),
        mmi64_h_up_valid_o  => mmi64_m_up_valid_int_i(module_idx),
        mmi64_h_up_accept_i => mmi64_m_up_accept_int_o(module_idx),
        mmi64_h_up_start_o  => mmi64_m_up_start_int_i(module_idx),
        mmi64_h_up_stop_o   => mmi64_m_up_stop_int_i(module_idx),
        mmi64_h_dn_d_i      => mmi64_m_dn_d_int_o(module_idx),
        mmi64_h_dn_valid_i  => mmi64_m_dn_valid_int_o(module_idx),
        mmi64_h_dn_accept_o => mmi64_m_dn_accept_int_i(module_idx),
        mmi64_h_dn_start_i  => mmi64_m_dn_start_int_o(module_idx),
        mmi64_h_dn_stop_i   => mmi64_m_dn_stop_int_o(module_idx),

        mmi64_m_up_d_i      => mmi64_m_up_d_i(module_idx),
        mmi64_m_up_valid_i  => mmi64_m_up_valid_i(module_idx),
        mmi64_m_up_accept_o => mmi64_m_up_accept_o(module_idx),
        mmi64_m_up_start_i  => mmi64_m_up_start_i(module_idx),
        mmi64_m_up_stop_i   => mmi64_m_up_stop_i(module_idx),
        mmi64_m_dn_d_o      => mmi64_m_dn_d_o(module_idx),
        mmi64_m_dn_valid_o  => mmi64_m_dn_valid_o(module_idx),
        mmi64_m_dn_accept_i => mmi64_m_dn_accept_i(module_idx),
        mmi64_m_dn_start_o  => mmi64_m_dn_start_o(module_idx),
        mmi64_m_dn_stop_o   => mmi64_m_dn_stop_o(module_idx)
        );
  end generate g_router_downlink_buffer;

end rtl;
