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
--  Project       : MMI64 (Module Message Interface)
--  Module/Entity : mmi64_rt (Architecture)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  MMI64 Reliable Transmission (MMI64 RT)
-- =============================================================================
-------------------
-- Architecture  --
-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generic_ram_comp.all;          --! Generic Memory
library work;
use work.rtl_templates.all;
use work.mmi64_rt_pkg.all;
use work.ethernet_crc_comp.all;
use work.timer_comp.all;
use work.mmi64_deserializer_comp.all;

architecture rtl of mmi64_rt is
-----------------------------------
-- Constants
-----------------------------------
  subtype  RT_SYNC0 is natural range 71 downto 64;  --! Synchronization word
  subtype  RT_SYNC1 is natural range 63 downto 56;  --! Synchronization word
  subtype  RT_SYNC2 is natural range 55 downto 48;  --! Synchronization word
  subtype  RT_TYPE is natural range 47 downto 40;   --! Packet type
  subtype  RT_DID is natural range 39 downto 24;    --! Data message Identification number
  subtype  RT_DAID is natural range 23 downto 8;    --! Identification number of last correctly received message
  subtype  RT_UNUSED is natural range 7 downto 3;   --! unused space
  subtype  RT_VERSION is natural range 4 downto 3;  --! Version of RT module
  subtype  RT_HEADER is natural range 7 downto 5;   --! Header definition
  constant RT_FIRST : integer := 2;                 --! First data of MMI64 message
  constant RT_LAST  : integer := 1;                 --! First data of MMI64 message
  constant RT_VALID : integer := 0;                 --! Valid data

  constant RT_PACKET_SIZE : integer := 16;                                     --! Number of MMI64 words inside one RT packet
  subtype  RT_CRC is natural range rt_data_o'high downto rt_data_o'length-32;  --! CRC of received message

  constant SYNC0          : std_ulogic_vector(7 downto 0) := convert(SYNC);
  constant SYNC1          : std_ulogic_vector(7 downto 0) := convert(SYNC);
  constant SYNC2          : std_ulogic_vector(7 downto 0) := convert(SYNC);
  constant DATA_MSG       : std_ulogic_vector(7 downto 0) := "00000001";
  constant ACK_MSG        : std_ulogic_vector(7 downto 0) := "00000010";
  constant RT_VERSION0    : std_ulogic_vector(1 downto 0) := "00";
  constant RT_VERSION1    : std_ulogic_vector(1 downto 0) := "01";
  constant MSG_HEADER     : std_ulogic_vector(2 downto 0) := "101";
  constant MAX_MSG_OFFSET : std_ulogic_vector(16 downto 0):= std_ulogic_vector(to_unsigned(16, 17));             --! Maximal offset between two repeated mesages where ack will be sent
  

-----------------------------------------
-- Interconnection signals and registers
-----------------------------------------
  signal mmi64_reset_n                : std_ulogic;                                    --! MMI64 reset (low active)
  signal rt_reset_n                   : std_ulogic;                                    --! RT reset (low active)
  signal ul_enable_mmi64              : std_ulogic;                                    --! Enable Uplink memory buffer
  signal ul_enable_r_mmi64            : std_ulogic;                                    --! Enable Uplink memory buffer
  signal ul_wr_enable_mmi64           : std_ulogic;                                    --! Write enable Uplink memory buffer
  signal ul_wr_and_ce_mmi64           : std_ulogic;                                    --! Write enable Uplink memory buffer and chip enable
  signal ul_r2w_sync_ptr_mmi64        : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Read pointer of Uplink memory synchronized on write clock domain
  signal ul_w2r_sync_ptr_mmi64        : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Write pointer which need to be synchronized to read clokc domain
  signal ul_wr_diff_mmi64             : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Number of free word location in Uplink buffer
  signal ul_wr_address_r_mmi64        : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Uplink buffer write address
  signal ul_w2r_sync_ptr_stable_mmi64 : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Stable pointer value for synchronization purpose
  signal ul_wr_data_r_mmi64           : std_ulogic_vector(71 downto 0);                --! Uplink buffer write data
  signal ul_rd_address_rt             : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Uplink buffer read address
  signal ul_rd_data_r_rt              : std_ulogic_vector(71 downto 0);                --! Uplink buffer read data
  signal ul_rd_enable_rt              : std_ulogic;                                    --! Uplink buffer read enable
  signal ul_addional_read_rt          : std_ulogic;                                    --! Additional read required
  signal ul_wr_full_mmi64             : std_ulogic;                                    --! Uplink buffer full
  signal ul_buf_rd_enable_rt          : std_ulogic;                                    --! Uplink buffer read enable
  signal ul_w2r_sync_ptr_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Uplink buffer write pointer synchronized to RT clock domain
  signal ul_r2w_sync_ptr_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Uplink buffer read pointer which need to be synchronized to read clock domain
  signal ul_rd_diff_rt                : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Number of available data for trasmission
  signal rt_out_cnt_rt                : std_ulogic_vector(RT_PACKET_SIZE+2 downto 0);  --! Control counter (one hot) for output RT
  signal rt_in_cnt_rt                 : std_ulogic_vector(RT_PACKET_SIZE+1 downto 0);  --! Control counter (one hot) for input RT
  signal enable_rt_out_rt             : std_ulogic;                                    --! Enable for RT output contorl counter
  signal enable_rt_accept_rt          : std_ulogic;                                    --! Enable for RT accept contorl counter
  signal rt_message_fill_mmi64        : std_ulogic;                                    --! Enable filling zeros until one RT message size is reached
  signal ul_wr_sync_req_mmi64         : std_ulogic;                                    --! Synchronization request from MMI64 clock domain
  signal ul_wr_sync_req_t1_mmi64      : std_ulogic;                                    --! Synchronization request from MMI64 clock domain (one cycle delayed)
  signal ul_wr_sync_req_meta_rt       : std_ulogic;                                    --! Synchronization request metastable on MMI64 clock domain
  signal ul_wr_sync_req_sync_rt       : std_ulogic;                                    --! Synchronization request synchronized on RT clock domain
  signal ul_wr_sync_req_accept_rt     : std_ulogic;                                    --! Synchronization request acceptd on RT clock domain
  signal ul_wr_sync_accept_meta_mmi64 : std_ulogic;                                    --! Synchronization request synchronized on MMI64 clock domain
  signal ul_wr_sync_accept_sync_mmi64 : std_ulogic;                                    --! Synchronization request acceptd on MMI64 clock domain
  signal dl_wr_accept_address_rt      : std_ulogic_vector(15 downto 0);                --! Downlink write address used as accept
  signal dl_wr_accept_address_sent_rt : std_ulogic_vector(15 downto 0);                --! Downlink write address used as accept which is last sent. Needed when Repeated message is received
  signal rt_data_o_crc_rt             : std_ulogic_vector(31 downto 0);                --! Calculated CRC for outgoing message
  signal rt_data_i_crc_rt             : std_ulogic_vector(31 downto 0);                --! Calculated CRC for incommi64ng message
  signal rt_data_out_rt               : std_ulogic_vector(rt_data_o'range);            --! Output RT data
  signal rt_data_out_crc_rt           : std_ulogic_vector(rt_data_o'range);            --! Output RT data
  signal crc_out_reset_n              : std_ulogic;                                    --! Reset CRC block for outgoing message
  signal crc_in_reset_n               : std_ulogic;                                    --! Rdset CRC block for incommi64ng message
  signal crc_in_valid_rt              : std_ulogic;                                    --! Enable CRC calculation for incommi64ng message
  signal rt_in_valid_rt               : std_ulogic;                                    --! Input RT message valid
  signal rt_in_repeated_rt            : std_ulogic;                                    --! Input RT message repeated
  signal rt_in_data_msg_rt            : std_ulogic;                                    --! Input RT data message
  signal rt_in_accept_msg_rt          : std_ulogic;                                    --! Input RT accept message
  signal rt_in_data_rt                : std_ulogic_vector(71 downto 0);                --! Input data register
  signal rt_in_correct_rt             : std_ulogic;                                    --! Input RT message correct
  signal rt_in_correct_repeat_rt      : std_ulogic;                                    --! CRC correct on repeated message
  signal rt_in_error_rt               : std_ulogic;                                    --! Input RT message contain CRC message
  signal dl_accept_address_rt         : std_ulogic_vector(15 downto 0);                --! Downlink buffer write address
  signal dl_exp_id_rt                 : std_ulogic_vector(15 downto 0);                --! Downlink buffer expected message ID
  signal dl_rcv_id_rt                 : std_ulogic_vector(15 downto 0);                --! Downlink buffer received message ID
  signal dl_rcv_id_offset_rt          : std_ulogic_vector(16 downto 0);                --! Downlink buffer received message ID offset (received <-> expected)
  signal dl_rcv_valid_id_rt           : std_ulogic_vector(15 downto 0);                --! Downlink buffer received message ID valid
  signal dl_exp_accept_rt             : std_ulogic_vector(15 downto 0);                --! Downlink buffer expected accept ID
  signal dl_terminal_accept_rt        : std_ulogic_vector(15 downto 0);                --! Downlink buffer maximum accept ID
  signal dl_rcv_accept_rt             : std_ulogic_vector(15 downto 0);                --! Downlink buffer received accept ID
  signal dl_rcv_last_accept_rt        : std_ulogic_vector(15 downto 0);                --! Downlink buffer last correctly received accept
  signal dl_exp_accept_valid_rt       : std_ulogic;                                    --! Expected accept valid
  signal dl_rcv_accept_valid_rt       : std_ulogic;                                    --! Received accept valid
  signal dl_r2w_sync_ptr_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Downlink buffer read pointer which need to be synchronized to read clock domain
  signal dl_r2w_sync_ptr_mmi64        : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Read pointer of Downlink memory synchronized on write clock domain
  signal dl_rd_data_mmi64             : std_ulogic_vector(71 downto 0);                --! Read data from downlink buffer
  signal dl_rd_address_mmi64          : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Read address for downlink buffer
  signal dl_buf_rd_enable_mmi64       : std_ulogic;                                    --! Read enable for downlink buffer
  signal dl_wr_data_r_rt              : std_ulogic_vector(71 downto 0);                --! Data for downlink buffer
  signal dl_wr_address_r_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Write address for downlink buffer
  signal dl_wr_enable_rt              : std_ulogic;                                    --! Write enable for downlink buffer
  signal dl_wr_diff_rt                : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Diffence between read and write pointer
  signal dl_w2r_sync_ptr_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Pointer which need to be synchronized do read domain
  signal dl_w2r_sync_ptr_stable_rt    : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Stable address for synchronization purpose
  signal dl_wr_address_stable_r_rt    : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Last correct address
  signal dl_w2r_sync_request_rt       : std_ulogic;                                    --! Request synchronization of pointer from RT clock domain
  signal dl_w2r_sync_request_t1_rt    : std_ulogic;                                    --! Request synchronization of pointer from RT clock domain (one cycle dekysed)
  signal dl_w2r_sync_ptr_mmi64        : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Write ponter synchronized to read clock domain
  signal ack_req_rt                   : std_ulogic;                                    --! Request accept message (once data message has been sent)
  signal crc_out_enable_rt            : std_ulogic;                                    --! Enable CRC calculataion for outgoing message
  signal timer_expired_rt             : std_ulogic;                                    --! Aknowledge has not been arrived in defined time so message need to be retransmited
  signal ul_load_address_rt           : std_ulogic_vector(BUFF_AWIDTH downto 0);       --! Address which need to be loaded (of unacceptd message)
  signal ul_load_rt                   : std_ulogic;                                    --! Load uplink address to retransmit message
  signal timer_reset_n                : std_ulogic;                                    --! Reset timer -> when accept is received
  signal dl_accept_received_rt        : std_ulogic;                                    --! Acknowledge is received
  signal dl_r2w_sync_request_rt       : std_ulogic;                                    --! Synchronization request to MMI64 clock domain
  signal dl_r2w_sync_request_t1_rt    : std_ulogic;                                    --! Synchronization request to MMI64 clock domain (one cycle delayed)
  signal ul_rd_sync_req_meta_mmi64    : std_ulogic;                                    --! Synchronization request metastable from RT clokc domain
  signal ul_rd_sync_req_sync_mmi64    : std_ulogic;                                    --! Synchronization request synchronized from RT clokc domain
  signal ul_rd_sync_req_accept_mmi64  : std_ulogic;                                    --! Acknowledge synchronization from RT clock domain
  signal ul_rd_sync_accept_sync_rt    : std_ulogic;                                    --! Synchronization accept synchronized from MMI64 clock domain
  signal ul_rd_sync_accept_meta_rt    : std_ulogic;                                    --! Synchronization accept metastable from MMI64 clock domain
  signal dl_rd_enable_mmi64           : std_ulogic;                                    --! Read data from Downlink buffer
  signal dl_empty_mmi64               : std_ulogic;                                    --! Downlink buffer empty

  signal dl_wr_sync_req_meta_mmi64   : std_ulogic;                                    --! Synchronization request metastable from RT clock domain
  signal dl_wr_sync_req_sync_mmi64   : std_ulogic;                                    --! Synchronization request synchronized from RT clock domain
  signal dl_wr_sync_req_accept_mmi64 : std_ulogic;                                    --! Acknowledge synchronization request from RT clock domain
  signal dl_wr_sync_accept_meta_rt   : std_ulogic;                                    --! Synchronization accept metastable from MMI64 clock domain
  signal dl_wr_sync_accept_sync_rt   : std_ulogic;                                    --! Synchronization accept synchronized from MMI64 clock domain
  signal rt_data_out_dummy_rt        : std_ulogic_vector(16-BUFF_AWIDTH+2 downto 0);  --! Dummy signals for data with generic bus width connection
  signal crc_errors_r                : std_ulogic_vector(15 downto 0);                --! Number of Message with brocken CRC   (For thease messages acknowedge has not been generated)
  signal ack_errors_r                : std_ulogic_vector(15 downto 0);                --! Number of accept ID errors (Number of unacceptd messages which has been retransmited)
  signal id_errors_r                 : std_ulogic_vector(15 downto 0);                --! Number of Message ID errors   (Messages with greather ID then expected.)
  signal id_warnings_r               : std_ulogic_vector(15 downto 0);                --! Number of Message ID wornings (Messages with smaller ID then expected. Acknowledge for that message was broken so message is retransmitted)
  signal ul_load_accept_rt           : std_ulogic;                                    --! Uplink buffer address load acceptd (Address load is required when message CRC is broken-> Roll back address on state before message is written)
  signal ul_rd_empty_rt              : std_ulogic;                                    --! Uplink buffer empty
  signal dl_sync_detected            : std_ulogic;                                    --! Synchronization packet detected
  signal dl_header_detected          : std_ulogic;                                    --! Header word detected
  
  signal dl_correct_data_msg         : std_ulogic;                                    --! Correct data message (ID metches with expected)
  signal dl_accept_msg               : std_ulogic;                                    --! Accept message
  signal dl_data_msg                 : std_ulogic;                                    --! Data message
  signal dl_fifo_avail_rt            : std_ulogic;                                    --! Enough space in FIFO for one message
  signal dl_repeated_rt              : std_ulogic;                                    --! Repeated message (With ID which is already accepted)
  
  signal deserializer_data           : std_ulogic_vector(63 downto 0);               --! Dederializer input data
  signal deserializer_ready          : std_ulogic;                                   --! Deserializer data accepted
  signal deserializer_valid          : std_ulogic;                                   --! Deserializer input data valid
  signal rt_version_rx               : std_ulogic_vector(1 downto 0);                --! Version received from connected peer and without CRC errors
  signal rt_version_draft_rx         : std_ulogic_vector(1 downto 0);                --! Version received from connected peer
  

begin
--------------------------------------------------
-- Low active reset
--------------------------------------------------
  mmi64_reset_n <= not mmi64_reset;
  rt_reset_n    <= not rt_reset;

--------------------------------------------------
-- Statistic output
--------------------------------------------------
  crc_errors_o  <= crc_errors_r;
  ack_errors_o  <= ack_errors_r;
  id_errors_o   <= id_errors_r;
  id_warnings_o <= id_warnings_r;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- RT TX PATH
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--------------------------------------------------
-- Control write pointer of Uplink buffer
--------------------------------------------------
  -- Synchronize read pointer to write domain and generate accept
  MMI64_RD_SYNC_ACK_FF : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset_n = '0' then
        ul_rd_sync_req_meta_mmi64   <= '0';
        ul_rd_sync_req_sync_mmi64   <= '0';
        ul_rd_sync_req_accept_mmi64 <= '0';
        ul_r2w_sync_ptr_mmi64       <= (others => '0');
      else
        ul_rd_sync_req_meta_mmi64   <= dl_r2w_sync_request_t1_rt;  --! Metastable signal
        ul_rd_sync_req_sync_mmi64   <= ul_rd_sync_req_meta_mmi64;  --! Sync signal
        ul_rd_sync_req_accept_mmi64 <= ul_rd_sync_req_sync_mmi64;  --! Sync acceptd
        
        if ul_rd_sync_req_accept_mmi64 /= ul_rd_sync_req_sync_mmi64 then
          --! Update pointer
          ul_r2w_sync_ptr_mmi64 <= ul_r2w_sync_ptr_rt;
        end if;
      end if;
    end if;
  end process MMI64_RD_SYNC_ACK_FF;

  --! Generate write pointer and flags
  u_ul_wr_ptr : rt_wr_ptr_full
    generic map(
      ADDR_WIDTH => BUFF_AWIDTH
      ) port map (
        clk            => mmi64_clk,
        reset_n        => mmi64_reset_n,
        wr_addr_i      => (others => '0'),
        wr_addr_load_i => '0',
        wr_enable_i    => ul_wr_and_ce_mmi64,
        wr_rptr_i      => ul_r2w_sync_ptr_mmi64,
        wr_ptr_o       => ul_w2r_sync_ptr_mmi64,
        wr_addr_o      => ul_wr_address_r_mmi64,
        wr_full_o      => ul_wr_full_mmi64,
        wr_diff_o      => ul_wr_diff_mmi64
        );

  --! Generate pointer sicnhronization request
  MMI64_WR_SYNC_REQ_FF : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset_n = '0' then
        ul_wr_sync_req_mmi64         <= '0';
        ul_wr_sync_req_t1_mmi64      <= '0';
        ul_w2r_sync_ptr_stable_mmi64 <= (others => '0');
        ul_wr_sync_accept_meta_mmi64 <= '0';
        ul_wr_sync_accept_sync_mmi64 <= '0';
      else
        --! Sync accept to MMI64 domain
        ul_wr_sync_accept_meta_mmi64 <= ul_wr_sync_req_accept_rt;
        ul_wr_sync_accept_sync_mmi64 <= ul_wr_sync_accept_meta_mmi64;
  
        --! Trigger sync process
        if (ul_wr_address_r_mmi64(3 downto 0) = "1111") and (ul_wr_and_ce_mmi64 = '1') then
          ul_wr_sync_req_mmi64 <= not ul_wr_sync_req_mmi64;
        end if;
  
        --! Apply new sync request only if previous is acceptd
        if ul_wr_sync_accept_sync_mmi64 = ul_wr_sync_req_t1_mmi64 then
          ul_wr_sync_req_t1_mmi64 <= ul_wr_sync_req_mmi64;
        end if;
  
        --! Save stable value for sync purposes
        if ul_wr_sync_req_t1_mmi64 /= ul_wr_sync_req_mmi64 then
          ul_w2r_sync_ptr_stable_mmi64 <= ul_w2r_sync_ptr_mmi64;
        end if;
      end if;
    end if;
  end process MMI64_WR_SYNC_REQ_FF;


--------------------------------------------------
-- Control write access of Uplink buffer
--------------------------------------------------
  MMI64_CTRL_IN_FF : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset_n = '0' then
        ul_wr_enable_mmi64    <= '0';
        rt_message_fill_mmi64 <= '0';
        ul_wr_enable_mmi64    <= '0';
        ul_wr_data_r_mmi64    <= (others => '0');
      else
        --! Enable data accepting only when there is free space in buffer
        ul_enable_r_mmi64 <= ul_enable_mmi64;
        
        if ul_enable_mmi64 = '1' then
          if rt_message_fill_mmi64 = '1' then
            --! Fill up until one RT message is ready
            if ul_wr_address_r_mmi64(3 downto 0) = "1111" then
              --! Reached one buffer size (16 words)
              rt_message_fill_mmi64 <= '0';
              ul_wr_enable_mmi64    <= '0';
            else
              rt_message_fill_mmi64 <= '1';
              ul_wr_enable_mmi64    <= '1';
            end if;
            ul_wr_data_r_mmi64 <= (others => '0');
          elsif mmi64_m_up_valid_i = '1' then
            if mmi64_m_up_stop_i = '1' then
              rt_message_fill_mmi64 <= '1';
              ul_wr_enable_mmi64    <= '1';
            else
              ul_wr_enable_mmi64    <= '1';
              rt_message_fill_mmi64 <= '0';
            end if;
            ul_wr_data_r_mmi64 <= mmi64_m_up_d_i & "00000" & mmi64_m_up_start_i & mmi64_m_up_stop_i & mmi64_m_up_valid_i;
  
          else
            ul_wr_enable_mmi64 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process MMI64_CTRL_IN_FF;
  
  ul_wr_and_ce_mmi64 <= ul_wr_enable_mmi64 and ul_enable_mmi64;

--------------------------------------------------
-- Uplink buffer
--------------------------------------------------
  ul_enable_mmi64 <= '1' when (unsigned(ul_wr_diff_mmi64) <= ((2**BUFF_AWIDTH)-32)) else '0';  --! Enable only when there is space for message
  mmi64_m_up_accept_o <= ul_enable_mmi64 when rt_message_fill_mmi64 = '0' else '0';  --! Do dot accept during filling up RT buffer with zeros

  u_ulink_buffer : generic_dpram_separated_ports
    generic map(
      ADDR_W => BUFF_AWIDTH,
      DATA_W => 64+8
      ) port map(
        clk1   => mmi64_clk,
        ce1    => ul_enable_mmi64,
        we1    => ul_wr_enable_mmi64,
        addr1  => ul_wr_address_r_mmi64(BUFF_AWIDTH-1 downto 0),
        wdata1 => ul_wr_data_r_mmi64,

        clk2   => rt_clk,
        ce2    => ul_buf_rd_enable_rt,
        addr2  => ul_rd_address_rt(BUFF_AWIDTH-1 downto 0),
        rdata2 => ul_rd_data_r_rt
        );

--------------------------------------------------
-- Control read pointer of Uplink buffer
--------------------------------------------------
  -- Synchronize write pointer to read domain and generate acknnowledge
  RT_WR_SYNC_ACK_FF : process(rt_clk)
  begin
    if rising_edge(rt_clk) then
      if rt_reset_n = '0' then
        ul_wr_sync_req_meta_rt   <= '0';
        ul_wr_sync_req_sync_rt   <= '0';
        ul_wr_sync_req_accept_rt <= '0';
        ul_w2r_sync_ptr_rt       <= (others => '0');
      else
        ul_wr_sync_req_meta_rt   <= ul_wr_sync_req_t1_mmi64;  --! Metastable signal
        ul_wr_sync_req_sync_rt   <= ul_wr_sync_req_meta_rt;   --! Sync signal
        ul_wr_sync_req_accept_rt <= ul_wr_sync_req_sync_rt;   --! Sync acceptd
  
        if ul_wr_sync_req_accept_rt /= ul_wr_sync_req_sync_rt then
          --! Update pointer
          ul_w2r_sync_ptr_rt <= ul_w2r_sync_ptr_stable_mmi64;
        end if;
      end if;
    end if;
  end process RT_WR_SYNC_ACK_FF;

  --! Generate read pointer and flags
  u_ul_rd_ptr : rt_rd_ptr_empty
    generic map(
      ADDR_WIDTH               => BUFF_AWIDTH,
      FIRST_WORD_FALLS_THROUGH => false
      ) port map (
        clk            => rt_clk,
        reset_n        => rt_reset_n,
        rd_addr_i      => ul_load_address_rt,
        rd_addr_load_i => ul_load_accept_rt,
        rd_enable_i    => ul_rd_enable_rt,
        enb_o          => ul_buf_rd_enable_rt,
        rd_wptr_i      => ul_w2r_sync_ptr_rt,
        rd_ptr_o       => open,
        rd_addr_o      => ul_rd_address_rt,
        rd_empty_o     => ul_rd_empty_rt,
        rd_diff_o      => ul_rd_diff_rt
        );

--------------------------------------------------
-- Calculate TX Data CRC
--------------------------------------------------
  crc_out_reset_n   <= not rt_out_cnt_rt(0);
  crc_out_enable_rt <= not rt_out_cnt_rt(rt_out_cnt_rt'high); --! Generate CRC for data and accept packets

  u_data_o_crc : ethernet_crc
    generic map (
      DWIDTH => 72
      ) port map(
        clk     => rt_clk,
        reset_n => crc_out_reset_n,
        dv_i    => crc_out_enable_rt,
        data_i  => rt_data_out_rt,
        crc_o   => rt_data_o_crc_rt
        );

--------------------------------------------------
-- Control RT TX data flow
--------------------------------------------------
  RT_CTRL_OUT_FF : process(rt_clk)
    variable rd_bin_next : std_ulogic_vector(BUFF_AWIDTH downto 0);
  begin
    if rising_edge(rt_clk) then
      if rt_reset_n = '0' then
        enable_rt_out_rt <= '0';
        rt_out_cnt_rt <= (0      => '1',
                          others => '0');
        dl_wr_accept_address_rt      <= (others => '0');
        dl_wr_accept_address_sent_rt <= (others => '0');
        ack_req_rt                   <= '0';
        enable_rt_accept_rt          <= '0';
        dl_exp_accept_rt             <= (others => '0');
        dl_terminal_accept_rt        <= (others => '0');
        dl_exp_accept_valid_rt       <= '0';
        ul_load_address_rt           <= (others => '0');
        ul_load_rt                   <= '0';
        dl_r2w_sync_request_rt       <= '0';
        ul_r2w_sync_ptr_rt           <= (others => '0');
        dl_accept_received_rt        <= '0';
        rt_data_out_dummy_rt         <= (others => '0');
        ul_rd_sync_accept_sync_rt    <= '0';
        ul_rd_sync_accept_meta_rt    <= '0';
        ack_errors_r                 <= (others => '0');
        ul_load_accept_rt            <= '0';
        dl_rcv_last_accept_rt        <= (others => '1');
        dl_rcv_valid_id_rt           <= (others => '0');
        ul_addional_read_rt          <= '0';
        rt_data_out_crc_rt           <= (others => '0');
        rt_data_out_rt               <= (others => '0');
        dl_rcv_id_offset_rt          <= (others => '0');
      else
        rt_data_out_dummy_rt      <= (others => '0');
        dl_terminal_accept_rt(BUFF_AWIDTH-3-1 downto 0) <= (others=>'1');
        --! Synchronize accept from MMI64 domain
        ul_rd_sync_accept_meta_rt <= ul_rd_sync_req_accept_mmi64;
        ul_rd_sync_accept_sync_rt <= ul_rd_sync_accept_meta_rt;
        
        dl_rcv_id_offset_rt <= std_ulogic_vector(abs(signed('0' & dl_rcv_id_rt) - signed('0' & dl_wr_accept_address_rt)));
  
        --! Request accept message (for valid and repeated messages)
        if (rt_in_data_msg_rt = '1') and (rt_in_correct_rt = '1') then
          if rt_in_correct_repeat_rt = '0' then
            --! Update ID only if not repeated message
            dl_rcv_valid_id_rt      <= dl_rcv_id_rt;
            dl_wr_accept_address_rt <= dl_rcv_id_rt;
          elsif (dl_rcv_id_offset_rt < MAX_MSG_OFFSET) then 
            --! Acknowleddge last received message repeated message
            dl_wr_accept_address_rt <= dl_rcv_id_rt;
          end if;
          ack_req_rt <= '1';
        end if;
  
        dl_accept_received_rt <= '0';
        --! Check for acceptd id
        if dl_exp_accept_valid_rt = '1' then
          --! Check only if one is expected
          if (dl_rcv_accept_valid_rt = '1') and (rt_in_correct_rt = '1') then
            --! Message (data or accept) is received wihout  CRC errors
            if dl_exp_accept_rt = dl_rcv_accept_rt then
              --! All messages are acceptd
              dl_exp_accept_valid_rt <= '0';
              dl_rcv_last_accept_rt  <= dl_rcv_accept_rt;
  
              --! Request pointer sync (discard acknowleged message from Uplink buffer)
              dl_r2w_sync_request_rt <= not dl_r2w_sync_request_rt;
              rd_bin_next            := std_ulogic_vector(unsigned(dl_rcv_accept_rt(rd_bin_next'high-4 downto 0)) + 1) & "0000";
              ul_r2w_sync_ptr_rt     <= ('0' & rd_bin_next(rd_bin_next'left downto 1)) xor rd_bin_next;
            else                          --if dl_exp_accept_rt >= dl_rcv_accept_rt then
              --! Subset of sent messages is acknowleeged
              dl_exp_accept_valid_rt <= '1';
              if dl_rcv_accept_rt /= dl_rcv_last_accept_rt then
                --! Accept (reset timer) only if different form already received one
                dl_accept_received_rt  <= '1';
              end if;
              dl_rcv_last_accept_rt  <= dl_rcv_accept_rt;
  
              --! Request pointer sync (discard acknowleged message from Uplink buffer)
              dl_r2w_sync_request_rt <= not dl_r2w_sync_request_rt;
              rd_bin_next            := std_ulogic_vector(unsigned(dl_rcv_accept_rt(rd_bin_next'high-4 downto 0)) + 1) & "0000";
              ul_r2w_sync_ptr_rt     <= ('0' & rd_bin_next(rd_bin_next'left downto 1)) xor rd_bin_next;
            end if;
          end if;
        end if;
  
        --! Enable RT Transmission
        if (unsigned(ul_rd_diff_rt) >= RT_PACKET_SIZE-1) and (rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1') then
          --! Enough data for one packet
          if (dl_exp_accept_rt = dl_terminal_accept_rt) and (dl_exp_accept_valid_rt = '1') then
            --! Wait all messages acknowledged before allow buffer wrap-around
            enable_rt_out_rt <= '0';
          else
            enable_rt_out_rt <= '1';
          end if;
        elsif rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1' then
          --! One packet sent
          if unsigned(ul_rd_diff_rt) < RT_PACKET_SIZE then
            --! Not enough data for one packet
            enable_rt_out_rt <= '0';
          end if;
          enable_rt_accept_rt <= '0';
        end if;
  
        --! Control counter (one-hot) for output RT
        if rt_out_cnt_rt(RT_PACKET_SIZE+2) = '1' then
          --! Reached final state
          rt_out_cnt_rt <= (0      => '1',
                            others => '0');
        else
          --! Shift left
          for idx in rt_out_cnt_rt'high downto 1 loop
            rt_out_cnt_rt(idx) <= rt_out_cnt_rt(idx-1);
          end loop;
          rt_out_cnt_rt(0) <= '0';
        end if;
  
        --! Output data
        if enable_rt_out_rt = '1' then
          --! Send data message
          if rt_out_cnt_rt(0) = '1' then
            --! Send header
            rt_data_out_rt(RT_SYNC0)     <= SYNC0;
            rt_data_out_rt(RT_SYNC1)     <= SYNC1;
            rt_data_out_rt(RT_SYNC2)     <= SYNC2;
            rt_data_out_rt(RT_TYPE)      <= DATA_MSG;
            rt_data_out_rt(RT_DID)       <= rt_data_out_dummy_rt & ul_rd_address_rt(ul_rd_address_rt'high downto 4);
            rt_data_out_rt(RT_DAID)      <= dl_wr_accept_address_rt;
            dl_wr_accept_address_sent_rt <= dl_wr_accept_address_rt;  --! Save sent accept addresss
            rt_data_out_rt(RT_FIRST)     <= '0';
            rt_data_out_rt(RT_LAST)      <= '0';
            rt_data_out_rt(RT_VALID)     <= '1';
            rt_data_out_rt(RT_HEADER)    <= MSG_HEADER;
            rt_data_out_rt(RT_VERSION)   <= RT_VERSION1;
  
            dl_exp_accept_rt             <= rt_data_out_dummy_rt & ul_rd_address_rt(ul_rd_address_rt'high downto 4);
            dl_exp_accept_valid_rt       <= '1';
            if ack_req_rt = '1' then
              --! Acknowledge is included in data message so no independent message required
              ack_req_rt <= '0';
            end if;
          elsif rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1' then
            --! Send CRC
            rt_data_out_rt(RT_CRC)                     <= rt_data_o_crc_rt;
            rt_data_out_rt(rt_data_o'high-32 downto 3) <= (others => '0');
            rt_data_out_rt(RT_FIRST)                   <= '0';
            rt_data_out_rt(RT_LAST)                    <= '0';
            rt_data_out_rt(RT_VALID)                   <= '1';
          else
            rt_data_out_rt(rt_data_o'high downto 8)                  <= ul_rd_data_r_rt(ul_rd_data_r_rt'high downto 8);
            rt_data_out_rt(7 downto 3)                               <= (others => '0');
            rt_data_out_rt(RT_FIRST)                                 <= ul_rd_data_r_rt(2);
            rt_data_out_rt(RT_LAST)                                  <= ul_rd_data_r_rt(1);
            rt_data_out_rt(RT_VALID)                                 <= ul_rd_data_r_rt(0);
          end if;
        elsif ack_req_rt = '1' then
          --! Send accept message
          if rt_out_cnt_rt(0) = '1' then
            enable_rt_accept_rt          <= '1';
            --! Send header
            rt_data_out_rt(RT_SYNC0)     <= SYNC0;
            rt_data_out_rt(RT_SYNC1)     <= SYNC1;
            rt_data_out_rt(RT_SYNC2)     <= SYNC2;
            rt_data_out_rt(RT_TYPE)      <= ACK_MSG;
            rt_data_out_rt(RT_DID)       <= (others => '0');
            rt_data_out_rt(RT_DAID)      <= dl_wr_accept_address_rt;
            dl_wr_accept_address_sent_rt <= dl_wr_accept_address_rt;  --! Save sent accept addresss
            rt_data_out_rt(RT_FIRST)     <= '0';
            rt_data_out_rt(RT_LAST)      <= '0';
            rt_data_out_rt(RT_VALID)     <= '1';
            rt_data_out_rt(RT_HEADER)    <= MSG_HEADER;
            rt_data_out_rt(RT_VERSION)   <= RT_VERSION1;
          elsif (rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1') and (enable_rt_accept_rt = '1') then
            --! Send CRC
            rt_data_out_rt(RT_CRC)                     <= rt_data_o_crc_rt;
            rt_data_out_rt(rt_data_o'high-32 downto 3) <= (others => '0');
            rt_data_out_rt(RT_FIRST)                   <= '0';
            rt_data_out_rt(RT_LAST)                    <= '0';
            rt_data_out_rt(RT_VALID)                   <= '1';
            if dl_wr_accept_address_sent_rt = dl_wr_accept_address_rt then
              --! Disable accept request only if no new message is arrived;
              ack_req_rt <= '0';
            end if;
          else
            rt_data_out_rt <= (others => '0');
          end if;
        else
          if rt_out_cnt_rt(0) = '1' then
            --! Send header
            rt_data_out_rt(RT_SYNC0)     <= SYNC0;
            rt_data_out_rt(RT_SYNC1)     <= SYNC1;
            rt_data_out_rt(RT_SYNC2)     <= SYNC2; 
            rt_data_out_rt(RT_VALID)     <= '0';          
          else
            rt_data_out_rt <= (others => '0');
          end if;
        end if;
        
        if rt_out_cnt_rt(rt_out_cnt_rt'high) = '1' then
          rt_data_out_crc_rt(RT_CRC) <= rt_data_o_crc_rt;
          rt_data_out_crc_rt(rt_data_o'high-32 downto 3) <= (others => '0');
          rt_data_out_crc_rt(RT_FIRST)                   <= '0';
          rt_data_out_crc_rt(RT_LAST)                    <= '0';
          rt_data_out_crc_rt(RT_VALID)                   <= '1';
        else
          rt_data_out_crc_rt <= rt_data_out_rt;
        end if;
        
        
        
  
        --! Allow sync request only if previous sync is done
        if dl_r2w_sync_request_t1_rt = ul_rd_sync_accept_sync_rt then
          dl_r2w_sync_request_t1_rt <= dl_r2w_sync_request_rt;
        end if;
  
        --! Repeat if timer expired
        if timer_expired_rt = '1' then
          --! Request load of address
          ack_errors_r           <= std_ulogic_vector(unsigned(ack_errors_r) + 1);
          ul_load_address_rt     <= std_ulogic_vector(unsigned(dl_rcv_last_accept_rt(rd_bin_next'high-4 downto 0)) + 1) & "0000";  --dl_rcv_accept_rt(rt_load_address_rt'high-4 downto 0) & "0000";
          ul_load_rt             <= '1';
          dl_exp_accept_valid_rt <= '0';
          ul_load_accept_rt      <= '0';
        --elsif (ul_rd_enable_rt = '0') and (ul_load_rt = '1') then
        elsif (rt_out_cnt_rt(RT_PACKET_SIZE) = '1') and (ul_load_rt = '1') then
          --! Allow address load only when memory is stoped been read (2 additional cycles available for syncing of pointers)
          ul_load_rt        <= '0';
          ul_load_accept_rt <= '1';
        else
          ul_load_accept_rt <= '0';
        end if;
  
        if (ul_rd_enable_rt = '1') and (ul_rd_empty_rt = '1') then
          --! FIFO empty at the end of transfer-> Aditional read cycle required before next transfer
          ul_addional_read_rt <= '1';
        elsif ul_load_accept_rt = '1' then
          --! Interrupt this operation if some message is repeated
          ul_addional_read_rt <= '0';
        elsif (ul_addional_read_rt = '1') and (ul_rd_enable_rt = '1') then
          --! Additional read done
          ul_addional_read_rt <= '0';
        end if;
      end if;
    end if;
  end process RT_CTRL_OUT_FF;
  rt_data_o          <= rt_data_out_crc_rt;
   
  ul_rd_enable_rt <= '1' when (ul_addional_read_rt = '1') and (unsigned(ul_rd_diff_rt) >= RT_PACKET_SIZE-1) and (rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1') else                        --! Additional read cycle
                     '0' when ((rt_out_cnt_rt(RT_PACKET_SIZE) = '1') or (rt_out_cnt_rt(RT_PACKET_SIZE+1) = '1') or (rt_out_cnt_rt(RT_PACKET_SIZE+2) = '1')) else enable_rt_out_rt;  --! Disable when Header or CRC is sent

  rt_sync_o <= rt_out_cnt_rt(2); --! Output data contains sync signal
  
-------------------------------------------------------------
-- Timer: When expired data message need to be retransmited
-- NOTE: CLK_PERIOD_NS is set to 10ns and time of expiration
--       to 1us so acknowledment must be received in 100 cycles
--       not realy 1us which is roughly 5 messages
-------------------------------------------------------------
  timer_reset_n <= not (ul_load_rt or dl_accept_received_rt);
  u_timer : timer
    generic map(
      CLK_PERIOD_NS => 10.0,
      TIME_SCALE    => "us"
      ) port map (
        clk       => rt_clk,
        reset_n   => timer_reset_n,
        enable_i  => dl_exp_accept_valid_rt,
        time_i    => std_ulogic_vector(to_unsigned(TIMEOUT, 10)),
        expired_o => timer_expired_rt
        );

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- RT RX PATH
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--------------------------------------------------
-- Decode header
--------------------------------------------------
  dl_header_detected   <= '1' when (rt_version_rx = RT_VERSION0)       else  --! Dont check for header bit if version 0
                          '1' when (rt_data_i(RT_HEADER) = MSG_HEADER) else '0';
  dl_sync_detected     <= '1' when (rt_data_i(RT_VALID) = '1') and ((rt_data_i(RT_SYNC0) = SYNC0) and (rt_data_i(RT_SYNC1) = SYNC1) and (rt_data_i(RT_SYNC2) = SYNC2)) else '0';
  dl_correct_data_msg  <= '1' when dl_exp_id_rt = rt_data_i(RT_DID) else '0';
  dl_data_msg          <= '1' when rt_data_i(RT_TYPE) = DATA_MSG else '0';
  dl_accept_msg        <= '1' when rt_data_i(RT_TYPE) = ACK_MSG else '0';

--------------------------------------------------
-- Control RT RX data flow
--------------------------------------------------
  dl_fifo_avail_rt <= '1' when (unsigned(dl_wr_diff_rt) <= ((2**BUFF_AWIDTH)-32)) else '0';
  dl_repeated_rt   <= '1' when (dl_exp_id_rt > rt_data_i(RT_DID)) else                                    --! "normal" case
                      '1' when (unsigned(dl_exp_id_rt) = 0) and (unsigned(rt_data_i(RT_DID)) > 15) else   --! Once pointer wrap-around is waited
                      '0';

  RT_CTRL_IN_FF : process(rt_clk)
  begin
    if rising_edge(rt_clk) then
      if rt_reset_n = '0' then
        rt_in_valid_rt    <= '0';
        rt_in_repeated_rt <= '0';
        rt_in_cnt_rt <= (0      => '1',
                        others => '0');
        rt_in_data_rt             <= (others => '0');
        rt_in_correct_rt          <= '0';
        rt_in_correct_repeat_rt   <= '0';
        rt_in_error_rt            <= '0';
        dl_accept_address_rt      <= (others => '0');
        dl_exp_id_rt              <= (others => '0');
        dl_rcv_id_rt              <= (others => '0');
        rt_in_data_msg_rt         <= '0';
        rt_in_accept_msg_rt       <= '0';
        dl_rcv_accept_rt          <= (others => '0');
        dl_w2r_sync_ptr_stable_rt <= (others => '0');
        dl_w2r_sync_request_rt    <= '0';
        dl_w2r_sync_request_t1_rt <= '0';
        dl_wr_sync_accept_meta_rt <= '0';
        dl_wr_sync_accept_sync_rt <= '0';
        dl_wr_address_stable_r_rt <= (others => '0');
        crc_errors_r              <= (others => '0');
        id_errors_r               <= (others => '0');
        id_warnings_r             <= (others => '0');
        rt_version_rx             <= RT_VERSION0; --! Always start communication as initial version
        rt_version_draft_rx       <= RT_VERSION0; --! Always start communication as initial version
        dl_rcv_accept_valid_rt    <= '0';
      else
        --! Synchronize accept from MMI64 domain
        dl_wr_sync_accept_meta_rt <= dl_wr_sync_req_accept_mmi64;
        dl_wr_sync_accept_sync_rt <= dl_wr_sync_accept_meta_rt;
  
        if (dl_sync_detected = '1') and (rt_in_valid_rt = '0') and (rt_in_repeated_rt = '0') and (dl_header_detected = '1') then
          --! Sync detected (message header) out of data field; rt_in_valid_rt = '0' prevents interpreting payload as sync
          if dl_data_msg = '1' then
            --! Data message detected
            if dl_correct_data_msg = '1' then
              --! Identification number of message equal to expected message number
              rt_version_draft_rx <= rt_data_i(RT_VERSION); --! Save detected version number
              if dl_fifo_avail_rt = '1' then
                --! If there is enough space in buffer for one message
                rt_in_valid_rt         <= rt_data_i(RT_VALID);
                rt_in_repeated_rt      <= '0';
                rt_in_data_msg_rt      <= rt_data_i(RT_VALID);
                rt_in_accept_msg_rt    <= '0';
                dl_rcv_accept_rt       <= rt_data_i(RT_DAID);
                dl_rcv_accept_valid_rt <= rt_data_i(RT_VALID);
                dl_rcv_id_rt           <= rt_data_i(RT_DID);
              end if;
            elsif dl_repeated_rt = '1' then
              --! Identification number of message smaller from expected message number -> Repeated Transmission -> Send last valid accept id
              rt_in_data_msg_rt      <= '1';  --! Message will not be stored in buffer (already there)
              rt_in_repeated_rt      <= '1';  --! Acknowledge message will be sent again with latest accept id
              id_warnings_r          <= std_ulogic_vector(unsigned(id_warnings_r) + 1);
              dl_rcv_id_rt           <= rt_data_i(RT_DID);
              dl_rcv_accept_valid_rt <= rt_data_i(RT_VALID);
            else
              id_errors_r <= std_ulogic_vector(unsigned(id_errors_r) + 1);
            end if;
          elsif (dl_accept_msg = '1')  and (dl_header_detected = '1') then
            --! Acknowledge message detected
            rt_in_data_msg_rt      <= '0';
            rt_in_accept_msg_rt    <= rt_data_i(RT_VALID);
            rt_in_valid_rt         <= rt_data_i(RT_VALID);
            rt_in_repeated_rt      <= '0';
            dl_rcv_accept_rt       <= rt_data_i(RT_DAID);
            dl_rcv_accept_valid_rt <= rt_data_i(RT_VALID);
          end if;
  
        elsif rt_in_cnt_rt(RT_PACKET_SIZE) = '1' then
          rt_in_valid_rt    <= '0';
          rt_in_repeated_rt <= '0';
        elsif rt_in_cnt_rt(RT_PACKET_SIZE+1) = '1' then
          rt_in_data_msg_rt      <= '0';
          rt_in_accept_msg_rt    <= '0';
          dl_rcv_accept_valid_rt <= '0';
        end if;
  
        --! Control message valid flag (valid message or retransmition)
        if (rt_in_valid_rt = '1') or (rt_in_repeated_rt = '1') then
          --! Shift left
          for idx in rt_in_cnt_rt'high downto 1 loop
            rt_in_cnt_rt(idx) <= rt_in_cnt_rt(idx-1);
          end loop;
          rt_in_cnt_rt(0) <= '0';
        else
          rt_in_cnt_rt <= (0      => '1',
                          others => '0');
        end if;
  
        --! Register input data
        rt_in_data_rt <= rt_data_i;
  
        --! Check if message is correct
        if rt_in_cnt_rt(RT_PACKET_SIZE) = '1' then
          if rt_data_i_crc_rt = rt_data_i(RT_CRC) then
            --! Correct message (No CRC errors)
            rt_version_rx    <= rt_version_draft_rx; --! Update version
            rt_in_correct_rt <= '1';
            rt_in_error_rt   <= '0';
            --! Flag if repeated message (data is not saved but accept need to be sent)
            if rt_in_repeated_rt = '1' then
              rt_in_correct_repeat_rt <= '1';
            else
              rt_in_correct_repeat_rt <= '0';
            end if;
          else
            --! CRC error detected (discard message)
            rt_in_correct_rt        <= '0';
            rt_in_error_rt          <= '1';
            rt_in_correct_repeat_rt <= '0';
            crc_errors_r            <= std_ulogic_vector(unsigned(crc_errors_r) + 1);
          end if;
        else
          rt_in_correct_rt        <= '0';
          rt_in_correct_repeat_rt <= '0';
          rt_in_error_rt          <= '0';
        end if;
  
        --! Correct message received and it's not repeated message
        if (rt_in_correct_rt = '1') and (rt_in_correct_repeat_rt = '0') then
          --! Update expected ID
          dl_accept_address_rt(dl_wr_address_r_rt'high-4 downto 0) <= dl_wr_address_r_rt(dl_wr_address_r_rt'high downto 4);
          dl_exp_id_rt(dl_exp_id_rt'high-4 downto 0)               <= std_ulogic_vector(resize(unsigned(dl_wr_address_r_rt(dl_wr_address_r_rt'high downto 4)) , dl_exp_id_rt'length-4));
  
          --! Request pointers synchronitation
          dl_w2r_sync_ptr_stable_rt <= dl_w2r_sync_ptr_rt;
          dl_w2r_sync_request_rt    <= not dl_w2r_sync_request_rt;
  
          --! Save last correct address
          dl_wr_address_stable_r_rt <= dl_wr_address_r_rt;
        elsif (rt_in_cnt_rt(0) = '1') and (dl_w2r_sync_ptr_stable_rt /= dl_w2r_sync_ptr_mmi64) then
          --! If no activity on line and pointers are different request synchronization (required vhen freq. difference is high (rt_freq > mmi64_froq*16))
          if (dl_w2r_sync_request_rt = dl_w2r_sync_request_t1_rt) and (dl_wr_sync_accept_sync_rt = dl_w2r_sync_request_t1_rt) then
            dl_w2r_sync_request_rt <= not dl_w2r_sync_request_rt;
          end if;
        end if;
  
        --! Allow sync request only if previous sync is acceptd
        if dl_wr_sync_accept_sync_rt = dl_w2r_sync_request_t1_rt then
          dl_w2r_sync_request_t1_rt <= dl_w2r_sync_request_rt;
        end if;
      end if;
    end if;
  end process RT_CTRL_IN_FF;

--------------------------------------------------
-- Calculate RX data CRC
--------------------------------------------------
  crc_in_reset_n  <= (not rt_in_cnt_rt(RT_PACKET_SIZE+1)) and rt_reset_n;                                      --! Global reset and at the end of received message
  crc_in_valid_rt <= rt_in_valid_rt or                                                                         --! Valid input message
                     rt_in_repeated_rt or                                                                      --! repeated message
                     (dl_sync_detected and dl_header_detected and                                              --! Header detected  AND
                     (dl_accept_msg    or                                                                      --! Header detected  AND accept message 
                     (dl_data_msg      and ((dl_correct_data_msg and dl_fifo_avail_rt) or dl_repeated_rt))));  --! Header detected  AND (data message with correct ID number and enough space in memory OR repeated message header)
  u_data_i_crc : ethernet_crc
    generic map (
      DWIDTH => 72
      ) port map(
        clk     => rt_clk,
        reset_n => crc_in_reset_n,
        dv_i    => crc_in_valid_rt,
        data_i  => rt_data_i, --rt_in_data_rt,
        crc_o   => rt_data_i_crc_rt
        );


--------------------------------------------------
-- Control write pointer of Uplink buffer
--------------------------------------------------
  -- Synchronize read pointer to write domain
  u_dl_sync_r2w : rt_synchronizer
    generic map(
      DATA_WIDTH => BUFF_AWIDTH+1
      ) port map (
        clk     => rt_clk,
        reset_n => rt_reset_n,
        data_i  => dl_r2w_sync_ptr_mmi64,
        data_o  => dl_r2w_sync_ptr_rt
        );

  --! Generate write pointer and flags
  u_dl_wr_ptr : rt_wr_ptr_full
    generic map(
      ADDR_WIDTH => BUFF_AWIDTH
      ) port map (
        clk            => rt_clk,
        reset_n        => rt_reset_n,
        wr_addr_i      => dl_wr_address_stable_r_rt,
        wr_addr_load_i => rt_in_error_rt,
        wr_enable_i    => dl_wr_enable_rt,
        wr_rptr_i      => dl_r2w_sync_ptr_rt,
        wr_ptr_o       => dl_w2r_sync_ptr_rt,
        wr_addr_o      => dl_wr_address_r_rt,
        wr_full_o      => open,
        wr_diff_o      => dl_wr_diff_rt
        );

--------------------------------------------------
-- Downlink buffer
--------------------------------------------------
  dl_wr_enable_rt                                                       <= (rt_in_valid_rt and rt_in_data_msg_rt) when rt_in_cnt_rt(0) = '0' else '0';  --! Write only for valid data messages (only message body->Not header and CRC)
  dl_wr_data_r_rt(dl_wr_data_r_rt'high downto 8)                        <= rt_in_data_rt(rt_in_data_rt'high downto 8);                                  --! Extract data form message body
  dl_wr_data_r_rt(7 downto 3)                                           <= (others => '0');                                                             --! Unused field (reserved for 64 bit data)
  dl_wr_data_r_rt(2)                                                    <= rt_in_data_rt(RT_FIRST);                                                     --! Extract first form message body
  dl_wr_data_r_rt(1)                                                    <= rt_in_data_rt(RT_LAST);                                                      --! Extract last form message body
  dl_wr_data_r_rt(0)                                                    <= rt_in_data_rt(RT_VALID);                                                     --! Extract valid form message body

  u_dlink_buffer : generic_dpram_separated_ports
    generic map(
      ADDR_W => BUFF_AWIDTH,
      DATA_W => 64+8
      ) port map(
        clk1   => rt_clk,
        ce1    => '1',
        we1    => dl_wr_enable_rt,
        addr1  => dl_wr_address_r_rt(BUFF_AWIDTH-1 downto 0),
        wdata1 => dl_wr_data_r_rt,

        clk2   => mmi64_clk,
        ce2    => dl_buf_rd_enable_mmi64,
        addr2  => dl_rd_address_mmi64(BUFF_AWIDTH-1 downto 0),
        rdata2 => dl_rd_data_mmi64
        );

--------------------------------------------------
-- Control read pointer of Downlink buffer
--------------------------------------------------
  -- Synchronize write pointer to read domain and generate accept
  MMI64_WR_SYNC_ACK_FF : process(mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset_n = '0' then
        dl_wr_sync_req_meta_mmi64   <= '0';
        dl_wr_sync_req_sync_mmi64   <= '0';
        dl_wr_sync_req_accept_mmi64 <= '0';
        dl_w2r_sync_ptr_mmi64       <= (others => '0');
      else
        dl_wr_sync_req_meta_mmi64   <= dl_w2r_sync_request_t1_rt;  --! Metastable signal
        dl_wr_sync_req_sync_mmi64   <= dl_wr_sync_req_meta_mmi64;  --! Sync signal
        dl_wr_sync_req_accept_mmi64 <= dl_wr_sync_req_sync_mmi64;  --! Sync acceptd
  
        if dl_wr_sync_req_accept_mmi64 /= dl_wr_sync_req_sync_mmi64 then
          --! Update pointer
          dl_w2r_sync_ptr_mmi64 <= dl_w2r_sync_ptr_stable_rt;
        end if;
      end if;
    end if;
  end process MMI64_WR_SYNC_ACK_FF;

  --! Generate read pointer and flags
  u_dl_rd_ptr : rt_rd_ptr_empty
    generic map(
      ADDR_WIDTH               => BUFF_AWIDTH,
      FIRST_WORD_FALLS_THROUGH => true
      ) port map (
        clk            => mmi64_clk,
        reset_n        => mmi64_reset_n,
        rd_addr_i      => (others => '0'),
        rd_addr_load_i => '0',
        rd_enable_i    => dl_rd_enable_mmi64,
        enb_o          => dl_buf_rd_enable_mmi64,
        rd_wptr_i      => dl_w2r_sync_ptr_mmi64,
        rd_ptr_o       => dl_r2w_sync_ptr_mmi64,
        rd_addr_o      => dl_rd_address_mmi64,
        rd_empty_o     => dl_empty_mmi64,
        rd_diff_o      => open
        );


------------------------------------------------------
---- Recrate MMI64 handshake
------------------------------------------------------
  deserializer_data  <= dl_rd_data_mmi64(dl_rd_data_mmi64'high downto 8);
  deserializer_valid <= (not dl_empty_mmi64) and dl_rd_data_mmi64(0); --! When data is available and 'valid' in order to filter zeros added by RT module for message alignment
  dl_rd_enable_mmi64 <= deserializer_ready;
  
  --! MMI64 Deserializer
  u_mmi64_deserializer: mmi64_deserializer
  generic map (
    SERIAL_DATA_WIDTH   => 64
    )
  port map (
    mmi64_clk           => mmi64_clk,
    mmi64_reset         => mmi64_reset,
    serial_d_i          => deserializer_data,
    serial_valid_i      => deserializer_valid,
    serial_ready_o      => deserializer_ready,
    mmi64_m_dn_d_o      => mmi64_m_dn_d_o,
    mmi64_m_dn_valid_o  => mmi64_m_dn_valid_o,
    mmi64_m_dn_accept_i => mmi64_m_dn_accept_i,
    mmi64_m_dn_start_o  => mmi64_m_dn_start_o,
    mmi64_m_dn_stop_o   => mmi64_m_dn_stop_o
  );
end architecture rtl;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2012-08-30  First draft.
-- 0.2      2012-12-20  Several bugfixes.
-- 0.3      2013-01-09  Added SYNC and TIMEOUT time as generic. Sending Sync even
--                       when idle for MGT synchronization purposes
-- 0.4      2013-03-25  Bugfix in MMI64_CTRL_IN_FF 
--                      bugfix for u_data_i_crc enable and reset
-- 0.5      2014-03-03  Bugfix in RT_CTRL_IN_FF
--                      Prevention of data misinterpreted as sync 
-- 0.6      2014-03-06  Output register block replaced with mmi64_deserializer
--                      Bugfix in ul_enable_mmi64 generation (must be greather from 16)
--                      due to FDFT option
-- 0.7      2014-03-12  Bugfix in RT_CTRL_OUT_FF
-- 2.0      2014-04-04  Major update. Not compatible with previous versions
-- 2.1      2014-05-13  Introduced version nr. inside header to support communication 
--                      with 0.x versions of source
-- 2.2      2014-07-24  Bugfix in acknowledge area
-- 1.0      2016-03-07  Reset re-structured. All resets are sync now
-- =============================================================================
