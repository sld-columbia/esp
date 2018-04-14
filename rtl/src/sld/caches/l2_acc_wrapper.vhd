-------------------------------------------------------------------------------
-- Entity: l2_acc_wrapper
-- File: l2_acc_wrapper.vhd
-- Author: Davide Giri - SLD @ Columbia University
-- Description: RTL wrapper for a private L2 cache to be included on a
-- accelerator tile on a Embedded Scalable Platform.
-- Frontend: Accelerator wrapper to L2 cache wrapper.
-- Backend: L2 cache to Network on Chip wrapper.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.cachepackage.all;              -- contains l2 cache component


entity l2_acc_wrapper is
  generic (
    tech        : integer := virtex7;
    sets        : integer := 256;
    ways        : integer := 8;
    coherence   : integer := ACC_COH_NONE;
    nslaves     : integer := 1;
    noc_xlen    : integer := 3;
    hindex_slv  : hindex_vector(0 to NAHBSLV-1);
    hindex_mst  : integer := 0;
    local_y     : local_yx;
    local_x     : local_yx;
    mem_num     : integer := 1;
    mem_info    : tile_mem_info_vector;
    destination : integer := 0;         -- 0: mem, 1: DSU
    l1_cache_en : integer := 0;
    cache_tile_id : cache_attribute_array);

  port (
    rst : in std_ulogic;
    clk : in std_ulogic;

    -- frontend (cache - Accelerator DMA)
    -- header / lenght parallel ports
    dma_read                  : in  std_ulogic;
    dma_write                 : in  std_ulogic;
    dma_length                : in  addr_t;
    dma_address               : in  addr_t;
    dma_ready                 : out std_ulogic;
    -- cache->acc (data only)
    dma_rcv_ready             : in  std_ulogic;
    dma_rcv_data              : out noc_flit_type;
    dma_rcv_valid             : out std_ulogic;
    -- acc->cache (data only)
    dma_snd_valid             : in  std_ulogic;
    dma_snd_data              : in  noc_flit_type;
    dma_snd_ready             : out std_ulogic;
    -- Accelerator done causes a flush
    flush                     : in  std_ulogic;

    -- backend (cache - NoC)
    -- tile->NoC1
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- NoC2->tile
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    -- tile->Noc3
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;

    debug_led : out std_ulogic);

end l2_acc_wrapper;

architecture rtl of l2_acc_wrapper is

  -- Interface with L2 cache

  -- TODO: Replace AHB with DMA handling

  -- AHB to cache
  signal cpu_req_ready          : std_ulogic;
  signal cpu_req_valid          : std_ulogic;
  signal cpu_req_data_cpu_msg   : cpu_msg_t;
  signal cpu_req_data_hsize     : hsize_t;
  signal cpu_req_data_hprot     : hprot_t;
  signal cpu_req_data_addr      : addr_t;
  signal cpu_req_data_word      : word_t;
  signal flush_ready            : std_ulogic;
  signal flush_valid            : std_ulogic;
  signal flush_data             : std_ulogic;
  -- cache to AHB
  signal rd_rsp_ready           : std_ulogic;
  signal rd_rsp_valid           : std_ulogic;
  signal rd_rsp_data_line       : line_t;
  signal inval_ready            : std_ulogic;
  signal inval_valid            : std_ulogic;
  signal inval_data             : line_addr_t;
  -- cache to NoC
  signal req_out_ready          : std_ulogic;
  signal req_out_valid          : std_ulogic;
  signal req_out_data_coh_msg   : coh_msg_t;
  signal req_out_data_hprot     : hprot_t;
  signal req_out_data_addr      : line_addr_t;
  signal req_out_data_line      : line_t;
  signal rsp_out_ready          : std_ulogic;
  signal rsp_out_valid          : std_ulogic;
  signal rsp_out_data_coh_msg   : coh_msg_t;
  signal rsp_out_data_req_id    : cache_id_t;
  signal rsp_out_data_to_req    : std_logic_vector(1 downto 0);
  signal rsp_out_data_addr      : line_addr_t;
  signal rsp_out_data_line      : line_t;
  -- NoC to cache
  signal fwd_in_ready           : std_ulogic;
  signal fwd_in_valid           : std_ulogic;
  signal fwd_in_data_coh_msg    : mix_msg_t;
  signal fwd_in_data_addr       : line_addr_t;
  signal fwd_in_data_req_id     : cache_id_t;
  signal rsp_in_valid           : std_ulogic;
  signal rsp_in_ready           : std_ulogic;
  signal rsp_in_data_coh_msg    : coh_msg_t;
  signal rsp_in_data_addr       : line_addr_t;
  signal rsp_in_data_line       : line_t;
  signal rsp_in_data_invack_cnt : invack_cnt_t;
  -- debug
  --signal asserts                : asserts_t;
  --signal bookmark               : bookmark_t;
  --signal custom_dbg             : custom_dbg_t;
  signal flush_done             : std_ulogic;

  -------------------------------------------------------------------------------
  -- Flush FSM signals
  -------------------------------------------------------------------------------
  type flush_fsm is (idle, issue);
  signal flush_state      : flush_fsm := idle;
  signal flush_state_next : flush_fsm := idle;
  
  -------------------------------------------------------------------------------
  -- FSM: Requests from accelerator
  -------------------------------------------------------------------------------
  type req_acc_fsm is (idle, load, store);

  type req_acc_reg_type is record
    state         : req_acc_fsm;
    addr          : addr_t;
    length        : addr_t;
    length_rsp    : addr_t;
  end record;

  constant REQ_ACC_REG_DEFAULT : req_acc_reg_type := (
    state         => idle,
    addr          => (others => '0'),
    length        => (others => '0'),
    length_rsp    => (others => '0'));

  signal req_acc_reg      : req_acc_reg_type := REQ_ACC_REG_DEFAULT;
  signal req_acc_reg_next : req_acc_reg_type := REQ_ACC_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Responses to accelerator
  -------------------------------------------------------------------------------
  type rsp_acc_fsm is (idle, rsp);

  type rsp_acc_reg_type is record
    state         : rsp_acc_fsm;
    line          : line_t;
    word_index    : integer;
    cnt           : addr_t;
  end record;

  constant RSP_ACC_REG_DEFAULT : rsp_acc_reg_type := (
    state         => idle,
    line          => (others => '0'),
    word_index    => 0,
    cnt           => (others => '0'));

  signal rsp_acc_reg      : rsp_acc_reg_type := RSP_ACC_REG_DEFAULT;
  signal rsp_acc_reg_next : rsp_acc_reg_type := RSP_ACC_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Request to NoC
  -------------------------------------------------------------------------------
  type req_fsm is (send_header, send_addr, send_data);

  type req_reg_type is record
    state    : req_fsm;
    coh_msg  : coh_msg_t;
    addr     : line_addr_t;
    line     : line_t;
    word_cnt : natural range 0 to 3;
    asserts  : asserts_req_t;
  end record req_reg_type;

  constant REQ_REG_DEFAULT : req_reg_type := (
    state    => send_header,
    coh_msg  => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0'));

  signal req_reg      : req_reg_type := REQ_REG_DEFAULT;
  signal req_reg_next : req_reg_type := REQ_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Response to NoC
  -------------------------------------------------------------------------------
  type rsp_out_fsm is (send_header, send_addr, send_data);

  type rsp_out_reg_type is record
    state    : rsp_out_fsm;
    coh_msg  : coh_msg_t;
    addr     : line_addr_t;
    line     : line_t;
    word_cnt : natural range 0 to 3;
    asserts  : asserts_rsp_out_t;
  end record rsp_out_reg_type;

  constant RSP_OUT_REG_DEFAULT : rsp_out_reg_type := (
    state    => send_header,
    coh_msg  => (others => '0'),
    addr     => (others => '0'),
    line     => (others => '0'),
    word_cnt => 0,
    asserts  => (others => '0'));

  signal rsp_out_reg      : rsp_out_reg_type := RSP_OUT_REG_DEFAULT;
  signal rsp_out_reg_next : rsp_out_reg_type := RSP_OUT_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Forward from  NoC
  -------------------------------------------------------------------------------

  type fwd_in_fsm is (rcv_header, rcv_addr);

  type fwd_in_reg_type is record
    state   : fwd_in_fsm;
    coh_msg : mix_msg_t;
    req_id  : cache_id_t;
    asserts : asserts_fwd_t;
  end record fwd_in_reg_type;

  constant FWD_IN_REG_DEFAULT : fwd_in_reg_type := (
    state   => rcv_header,
    coh_msg => (others => '0'),
    req_id  => (others => '0'),
    asserts => (others => '0'));

  signal fwd_in_reg      : fwd_in_reg_type := FWD_IN_REG_DEFAULT;
  signal fwd_in_reg_next : fwd_in_reg_type := FWD_IN_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- FSM: Response from  NoC
  -------------------------------------------------------------------------------

  type rsp_in_fsm is (rcv_header, rcv_addr, rcv_data);

  type rsp_in_reg_type is record
    state      : rsp_in_fsm;
    coh_msg    : coh_msg_t;
    invack_cnt : invack_cnt_t;
    addr       : line_addr_t;
    line       : line_t;
    word_cnt   : natural range 0 to 3;
    asserts    : asserts_rsp_in_t;
  end record rsp_in_reg_type;

  constant RSP_IN_REG_DEFAULT : rsp_in_reg_type := (
    state      => rcv_header,
    coh_msg    => (others => '0'),
    invack_cnt => (others => '0'),
    addr       => (others => '0'),
    line       => (others => '0'),
    word_cnt   => 0,
    asserts    => (others => '0'));

  signal rsp_in_reg      : rsp_in_reg_type := RSP_IN_REG_DEFAULT;
  signal rsp_in_reg_next : rsp_in_reg_type := RSP_IN_REG_DEFAULT;

  -------------------------------------------------------------------------------
  -- Others
  -------------------------------------------------------------------------------
       
  signal empty_offset : std_logic_vector(OFFSET_BITS - 1 downto 0) := (others => '0');
 
  -------------------------------------------------------------------------------
  -- Debug
  -------------------------------------------------------------------------------

  -- Debug signals
  signal req_acc_reg_state    : req_acc_fsm;
  signal req_reg_state     : req_fsm;
  signal rsp_out_reg_state : req_fsm;
  signal rsp_in_reg_state  : rsp_in_fsm;
  signal req_asserts       : asserts_req_t;
  signal rsp_in_asserts    : asserts_rsp_in_t;

  -- Debug LEDs
  --signal led_bookmarks       : std_ulogic;
  --signal led_cache_asserts   : std_ulogic;
  --signal led_wrapper_asserts : std_ulogic;

  attribute mark_debug : string;

  -- attribute mark_debug of req_acc_reg_state   : signal is "true";
  -- attribute mark_debug of req_reg_state    : signal is "true";
  -- attribute mark_debug of rsp_out_reg_state    : signal is "true";
  -- attribute mark_debug of rsp_in_reg_state : signal is "true";

  attribute mark_debug of flush_state : signal is "true";
  
  -- attribute mark_debug of req_asserts    : signal is "true";
  -- attribute mark_debug of rsp_out_asserts    : signal is "true";
  -- attribute mark_debug of rsp_in_asserts : signal is "true";

  -- AHB to cache
  attribute mark_debug of cpu_req_ready          : signal is "true";
  attribute mark_debug of cpu_req_valid          : signal is "true";
  attribute mark_debug of cpu_req_data_cpu_msg   : signal is "true";
  attribute mark_debug of cpu_req_data_hsize     : signal is "true";
  attribute mark_debug of cpu_req_data_hprot     : signal is "true";
  attribute mark_debug of cpu_req_data_addr      : signal is "true";
  attribute mark_debug of cpu_req_data_word      : signal is "true";
  attribute mark_debug of flush_ready            : signal is "true";
  attribute mark_debug of flush_valid            : signal is "true";
  attribute mark_debug of flush_data             : signal is "true";
  -- cache to AHB
  attribute mark_debug of rd_rsp_ready           : signal is "true";
  attribute mark_debug of rd_rsp_valid           : signal is "true";
  -- attribute mark_debug of rd_rsp_data_line       : signal is "true";
  -- cache to NoC
  attribute mark_debug of req_out_ready          : signal is "true";
  attribute mark_debug of req_out_valid          : signal is "true";
  attribute mark_debug of req_out_data_coh_msg   : signal is "true";
  attribute mark_debug of req_out_data_hprot     : signal is "true";
  attribute mark_debug of req_out_data_addr      : signal is "true";
  -- attribute mark_debug of req_out_data_line      : signal is "true";
  attribute mark_debug of rsp_out_ready          : signal is "true";
  attribute mark_debug of rsp_out_valid          : signal is "true";
  attribute mark_debug of rsp_out_data_coh_msg   : signal is "true";
  attribute mark_debug of rsp_out_data_req_id    : signal is "true";
  attribute mark_debug of rsp_out_data_to_req    : signal is "true";
  attribute mark_debug of rsp_out_data_addr      : signal is "true";
  -- attribute mark_debug of rsp_out_data_line      : signal is "true";
  -- NoC to cache
  attribute mark_debug of fwd_in_ready           : signal is "true";
  attribute mark_debug of fwd_in_valid           : signal is "true";
  attribute mark_debug of fwd_in_data_coh_msg    : signal is "true";
  attribute mark_debug of fwd_in_data_addr       : signal is "true";
  attribute mark_debug of fwd_in_data_req_id     : signal is "true";
  attribute mark_debug of rsp_in_valid           : signal is "true";
  attribute mark_debug of rsp_in_ready           : signal is "true";
  attribute mark_debug of rsp_in_data_coh_msg    : signal is "true";
  attribute mark_debug of rsp_in_data_addr       : signal is "true";
  -- attribute mark_debug of rsp_in_data_line       : signal is "true";
  attribute mark_debug of rsp_in_data_invack_cnt : signal is "true";
  -- debug
  --attribute mark_debug of asserts                : signal is "true";
  --attribute mark_debug of bookmark               : signal is "true";
  -- attribute mark_debug of custom_dbg             : signal is "true";
  attribute mark_debug of flush_done             : signal is "true";
  
begin  -- architecture rtl of l2_acc_wrapper

  -----------------------------------------------------------------------------
  -- Instantiations
  -----------------------------------------------------------------------------

  -- instantiation of l2 cache on cpu tile
  l2_i : l2

    generic map (
      sets => sets,
      ways => ways)

    port map (
      clk => clk,
      rst => rst,

      -- AHB to cache
      l2_cpu_req_ready          => cpu_req_ready,
      l2_cpu_req_valid          => cpu_req_valid,
      l2_cpu_req_data_cpu_msg   => cpu_req_data_cpu_msg,
      l2_cpu_req_data_hsize     => cpu_req_data_hsize,
      l2_cpu_req_data_hprot     => cpu_req_data_hprot,
      l2_cpu_req_data_addr      => cpu_req_data_addr,
      l2_cpu_req_data_word      => cpu_req_data_word,
      l2_flush_ready            => flush_ready,
      l2_flush_valid            => flush_valid,
      l2_flush_data             => flush_data,
      -- cache to AHB
      l2_rd_rsp_ready           => rd_rsp_ready,
      l2_rd_rsp_valid           => rd_rsp_valid,
      l2_rd_rsp_data_line       => rd_rsp_data_line,
      l2_inval_ready            => inval_ready,
      l2_inval_valid            => inval_valid,
      l2_inval_data             => inval_data,
      -- cache to NoC
      l2_req_out_ready          => req_out_ready,
      l2_req_out_valid          => req_out_valid,
      l2_req_out_data_coh_msg   => req_out_data_coh_msg,
      l2_req_out_data_hprot     => req_out_data_hprot,
      l2_req_out_data_addr      => req_out_data_addr,
      l2_req_out_data_line      => req_out_data_line,
      l2_rsp_out_ready          => rsp_out_ready,
      l2_rsp_out_valid          => rsp_out_valid,
      l2_rsp_out_data_coh_msg   => rsp_out_data_coh_msg,
      l2_rsp_out_data_req_id    => rsp_out_data_req_id,
      l2_rsp_out_data_to_req    => rsp_out_data_to_req,
      l2_rsp_out_data_addr      => rsp_out_data_addr,
      l2_rsp_out_data_line      => rsp_out_data_line,
      -- NoC to cache
      l2_fwd_in_ready           => fwd_in_ready,
      l2_fwd_in_valid           => fwd_in_valid,
      l2_fwd_in_data_coh_msg    => fwd_in_data_coh_msg,
      l2_fwd_in_data_addr       => fwd_in_data_addr,
      l2_fwd_in_data_req_id     => fwd_in_data_req_id,
      l2_rsp_in_ready           => rsp_in_ready,
      l2_rsp_in_valid           => rsp_in_valid,
      l2_rsp_in_data_coh_msg    => rsp_in_data_coh_msg,
      l2_rsp_in_data_addr       => rsp_in_data_addr,
      l2_rsp_in_data_line       => rsp_in_data_line,
      l2_rsp_in_data_invack_cnt => rsp_in_data_invack_cnt,
      flush_done                => flush_done

      -- debug
      --asserts                   => asserts,
      --bookmark                  => bookmark,
      --custom_dbg                => custom_dbg,
      );
    
-------------------------------------------------------------------------------
-- Static signals
-------------------------------------------------------------------------------

  flush_data           <= '0';
  inval_ready          <= '1'; -- inval not used by accelerators
  cpu_req_data_hsize   <= "010";
  cpu_req_data_hprot   <= "01";
  
-------------------------------------------------------------------------------
-- State update for all the FSMs
-------------------------------------------------------------------------------
  fsms_state_update : process (clk, rst)
  begin

    if rst = '0' then

      flush_state    <= idle;
      req_acc_reg    <= REQ_ACC_REG_DEFAULT;
      rsp_acc_reg    <= RSP_ACC_REG_DEFAULT;
      req_reg        <= REQ_REG_DEFAULT;
      rsp_out_reg    <= RSP_OUT_REG_DEFAULT;
      fwd_in_reg     <= FWD_IN_REG_DEFAULT;
      rsp_in_reg     <= RSP_IN_REG_DEFAULT;

    elsif clk'event and clk = '1' then

      flush_state    <= flush_state_next;
      req_acc_reg    <= req_acc_reg_next;
      rsp_acc_reg    <= rsp_acc_reg_next;
      req_reg        <= req_reg_next;
      rsp_out_reg    <= rsp_out_reg_next;
      fwd_in_reg     <= fwd_in_reg_next;
      rsp_in_reg     <= rsp_in_reg_next;

    end if;

  end process fsms_state_update;

-------------------------------------------------------------------------------
-- FSM: L2 flush management
-------------------------------------------------------------------------------
  fsm_flush : process (flush_state, flush, flush_ready)

  begin
    
    case flush_state is

      -- IDLE
      when idle =>

        if flush = '1' then

          flush_valid <= '1';

          if flush_ready = '0' then

            flush_state_next <= issue;

          else

            flush_state_next <= idle;
            
          end if;
          
        else

          flush_valid <= '0';

          flush_state_next <= idle;

        end if;

      -- ISSUE
      when issue =>

        flush_valid <= '1';

        if flush_ready = '0' then

          flush_state_next <= issue;

        else

          flush_state_next <= idle;
          
        end if;
        
    end case;

  end process fsm_flush;
  
-------------------------------------------------------------------------------
-- FSM: Bridge from accelerator wrapper to L2 cache frontend input
-------------------------------------------------------------------------------
  fsm_req_acc : process (req_acc_reg, cpu_req_ready,
                         dma_read, dma_write, dma_length, dma_address,
                         dma_snd_valid, dma_snd_data)

    variable reg : req_acc_reg_type;

  begin

    -- copy current state into a variable
    reg := req_acc_reg;

    -- default values of output signals
    dma_ready <= '0'; 
    dma_snd_ready <= '0';
    
    cpu_req_valid        <= '0';
    cpu_req_data_cpu_msg <= (others => '0');
    cpu_req_data_addr    <= (others => '0');
    cpu_req_data_word    <= (others => '0');

    case req_acc_reg.state is

      -- IDLE
      when idle =>

        if cpu_req_ready = '1' then

          dma_ready <= '1';

          if dma_read = '1' then

            cpu_req_valid        <= '1';
            cpu_req_data_cpu_msg <= CPU_READ;
            cpu_req_data_addr    <= dma_address;
            
            reg.addr   := dma_address + BYTES_PER_LINE;
            reg.length := dma_length - WORDS_PER_LINE;
            reg.length_rsp := dma_length;
            
            if to_integer(unsigned(reg.length)) /= 0 then

              reg.state := load;

            end if;

          elsif dma_write = '1' then

            reg.addr := dma_address;
            
            reg.state := store;

          end if;

        end if;
          
      -- LOAD
      when load =>

        if cpu_req_ready = '1' then

          cpu_req_valid        <= '1';
          cpu_req_data_cpu_msg <= CPU_READ;
          cpu_req_data_addr    <= reg.addr;
            
          reg.addr   := dma_address + BYTES_PER_LINE;
          reg.length := dma_length - WORDS_PER_LINE;
          reg.length_rsp := dma_length;

          if to_integer(unsigned(reg.length)) = 0 then

            reg.state := idle;

          end if;

        end if;
        
      -- STORE
      when store =>

        if cpu_req_ready = '1' then

          dma_snd_ready <= '1';

          if dma_snd_valid = '1'  then

            cpu_req_valid        <= '1';
            cpu_req_data_cpu_msg <= CPU_WRITE;
            cpu_req_data_addr    <= reg.addr;
            cpu_req_data_word    <= dma_snd_data(ADDR_BITS - 1 downto 0);

            reg.addr := reg.addr + BYTES_PER_WORD;

            if get_preamble(dma_snd_data) = PREAMBLE_TAIL then

              reg.state := idle;

            end if;

          end if;

        end if;

    end case;

    req_acc_reg_next <= reg;

  end process fsm_req_acc;

-------------------------------------------------------------------------------
-- FSM: Bridge from L2 cache frontend output to accelerator wrapper
-------------------------------------------------------------------------------
  fsm_rsp_acc : process (rsp_acc_reg, req_acc_reg, dma_rcv_ready,
                         rd_rsp_valid, rd_rsp_data_line)

    variable reg : rsp_acc_reg_type;

  begin

    -- copy current state into a variable
    reg         := rsp_acc_reg;
    
    -- default values of output signals
    dma_rcv_valid <= '0';
    dma_rcv_data <= (others => '0');

    rd_rsp_ready <= '1';

    case rsp_acc_reg.state is

      -- IDLE
      when idle =>

        rd_rsp_ready <= '1';
        
        if rd_rsp_valid = '1' then

          reg.line := rd_rsp_data_line;
          reg.state := rsp;
          
          if dma_rcv_ready <= '1' then 

            dma_rcv_valid <= '1';

            reg.cnt := reg.cnt + 1;

            if (reg.cnt = req_acc_reg.length_rsp) then

              reg.cnt := (others => '0');

              dma_rcv_data <= PREAMBLE_TAIL &
                              read_word(reg.line, 0);
            else

              dma_rcv_data <= PREAMBLE_BODY &
                              read_word(reg.line, 0);
            end if;
            
            reg.word_index := 1;

          else

            reg.word_index := 0;

          end if;

        end if;

      -- RESPOND
      when rsp =>

        dma_rcv_valid <= '1';
        
        if dma_rcv_ready <= '1' then 

          reg.cnt := reg.cnt + 1;

          if (reg.cnt = req_acc_reg.length_rsp) then

            reg.cnt := (others => '0');

            dma_rcv_data <= PREAMBLE_TAIL &
                            read_word(reg.line, reg.word_index);
          else

            dma_rcv_data <= PREAMBLE_BODY &
                            read_word(reg.line, reg.word_index);
          end if;
          
          if reg.word_index /= WORDS_PER_LINE - 1 then
            
            reg.word_index := reg.word_index + 1;

          end if;
          
        else

          rd_rsp_ready <= '1';

          if rd_rsp_valid = '1' then

            reg.line := rd_rsp_data_line;

            reg.word_index := 0;

          else

            reg.state := idle;
            
          end if;

        end if;

    end case;

    rsp_acc_reg_next <= reg;

  end process fsm_rsp_acc;
  
-------------------------------------------------------------------------------
-- FSM: Requests to NoC
-------------------------------------------------------------------------------
  fsm_req : process (req_reg, coherence_req_full,
                     req_out_valid, req_out_data_coh_msg, req_out_data_hprot,
                     req_out_data_addr, req_out_data_line) is

    variable reg    : req_reg_type;
    variable req_id : cache_id_t := (others => '0');
    
  begin  -- process fsm_cache2noc

    -- initialize variables
    reg         := req_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (receive from cache)
    req_out_ready <= '0';

    -- initialize signals toward noc
    coherence_req_wrreq   <= '0';
    coherence_req_data_in <= (others => '0');


    case reg.state is

      -- SEND HEADER
      when send_header =>

        if coherence_req_full = '0' then

          req_out_ready <= '1';

          if req_out_valid = '1' then

            reg.coh_msg := req_out_data_coh_msg;
            reg.addr    := req_out_data_addr;
            reg.line    := req_out_data_line;

            coherence_req_wrreq <= '1';
            coherence_req_data_in <= make_header(req_out_data_coh_msg, mem_info,
                                                 mem_num, req_out_data_hprot,
                                                 req_out_data_addr, local_x, local_y,
                                                 '0', req_id, cache_tile_id, noc_xlen);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_req_full = '0' then

          coherence_req_wrreq <= '1';

          if '0' & reg.coh_msg = REQ_PUTM then

            coherence_req_data_in <= PREAMBLE_BODY & reg.addr & empty_offset;
            reg.state             := send_data;
            reg.word_cnt          := 0;

          else

            coherence_req_data_in <= PREAMBLE_TAIL & reg.addr & empty_offset;
            reg.state             := send_header;

          end if;
        end if;

      -- SEND DATA
      when send_data =>

        if coherence_req_full = '0' then

          coherence_req_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            coherence_req_data_in <=
              PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) +
                                       BITS_PER_WORD - 1 downto (BITS_PER_WORD * reg.word_cnt));

            reg.state := send_header;

          else

            coherence_req_data_in <=
              PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) +
                                       BITS_PER_WORD - 1 downto (BITS_PER_WORD * reg.word_cnt));

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    req_reg_next <= reg;

  end process fsm_req;

-------------------------------------------------------------------------------
-- FSM: Responses to NoC
-------------------------------------------------------------------------------
  fsm_rsp_out : process (rsp_out_reg, coherence_rsp_snd_full,
                         rsp_out_valid, rsp_out_data_coh_msg, rsp_out_data_req_id,
                         rsp_out_data_to_req, rsp_out_data_addr, rsp_out_data_line) is

    variable reg   : rsp_out_reg_type;
    variable hprot : hprot_t := (others => '0');

  begin  -- process fsm_cache2noc

    -- initialize variables
    reg         := rsp_out_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (receive from cache)
    rsp_out_ready <= '0';

    -- initialize signals toward noc
    coherence_rsp_snd_wrreq   <= '0';
    coherence_rsp_snd_data_in <= (others => '0');


    case reg.state is

      -- SEND HEADER
      when send_header =>

        if coherence_rsp_snd_full = '0' then

          rsp_out_ready <= '1';

          if rsp_out_valid = '1' then

            reg.coh_msg := rsp_out_data_coh_msg;
            reg.addr    := rsp_out_data_addr;
            reg.line    := rsp_out_data_line;

            coherence_rsp_snd_wrreq <= '1';



            coherence_rsp_snd_data_in <= make_header(rsp_out_data_coh_msg, mem_info,
                                                     mem_num, hprot, rsp_out_data_addr, local_x,
                                                     local_y, rsp_out_data_to_req(0),
                                                     rsp_out_data_req_id, cache_tile_id, noc_xlen);

            reg.state := send_addr;

          end if;
        end if;

      -- SEND ADDRESS
      when send_addr =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if '0' & reg.coh_msg = RSP_DATA then

            coherence_rsp_snd_data_in <= PREAMBLE_BODY & reg.addr & empty_offset;
            reg.state                 := send_data;
            reg.word_cnt              := 0;

          else

            coherence_rsp_snd_data_in <= PREAMBLE_TAIL & reg.addr & empty_offset;
            reg.state                 := send_header;

          end if;
        end if;

      -- SEND DATA
      when send_data =>

        if coherence_rsp_snd_full = '0' then

          coherence_rsp_snd_wrreq <= '1';

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            coherence_rsp_snd_data_in <=
              PREAMBLE_TAIL & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                                       downto (BITS_PER_WORD * reg.word_cnt));

            reg.state := send_header;

          else

            coherence_rsp_snd_data_in <=
              PREAMBLE_BODY & reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1
                                       downto (BITS_PER_WORD * reg.word_cnt));

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    rsp_out_reg_next <= reg;

  end process fsm_rsp_out;

-----------------------------------------------------------------------------
-- FSM: Forwards from NoC
-----------------------------------------------------------------------------
  fsm_fwd_in : process (fwd_in_reg, fwd_in_ready,
                        coherence_fwd_empty, coherence_fwd_data_out) is

    variable reg          : fwd_in_reg_type;
    variable rsp_preamble : noc_preamble_type;
    variable msg_type     : noc_msg_type;
    variable reserved     : reserved_field_type;

  begin  -- process fsm_fwd_in

    -- initialize variables
    reg         := fwd_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    fwd_in_valid        <= '0';
    fwd_in_data_coh_msg <= (others => '0');
    fwd_in_data_addr    <= (others => '0');
    fwd_in_data_req_id  <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_fwd_rdreq <= '0';

    -- get preambles
    rsp_preamble := get_preamble(coherence_fwd_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        if coherence_fwd_empty = '0' then

          coherence_fwd_rdreq <= '1';

          msg_type    := get_msg_type(coherence_fwd_data_out);
          reg.coh_msg := msg_type(reg.coh_msg'length - 1 downto 0);
          reserved    := get_reserved_field(coherence_fwd_data_out);
          reg.req_id  := reserved(reg.req_id'length - 1 downto 0);

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_fwd_empty = '0' and fwd_in_ready = '1' then

          coherence_fwd_rdreq <= '1';

          fwd_in_valid        <= '1';
          fwd_in_data_coh_msg <= reg.coh_msg;
          fwd_in_data_addr    <= coherence_fwd_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
          fwd_in_data_req_id  <= reg.req_id;

          reg.state := rcv_header;

        end if;

    end case;

    fwd_in_reg_next <= reg;

  end process fsm_fwd_in;

-----------------------------------------------------------------------------
-- FSM: Responses from NoC
-----------------------------------------------------------------------------
  fsm_rsp_in : process (rsp_in_reg, rsp_in_ready,
                        coherence_rsp_rcv_empty, coherence_rsp_rcv_data_out) is

    variable reg          : rsp_in_reg_type;
    variable rsp_preamble : noc_preamble_type;
    variable msg_type     : noc_msg_type;
    variable reserved     : reserved_field_type;

  begin  -- process fsm_rsp_in

    -- initialize variables
    reg         := rsp_in_reg;
    reg.asserts := (others => '0');

    -- initialize signals toward cache (send to cache)
    rsp_in_valid           <= '0';
    rsp_in_data_coh_msg    <= (others => '0');
    rsp_in_data_addr       <= (others => '0');
    rsp_in_data_line       <= (others => '0');
    rsp_in_data_invack_cnt <= (others => '0');

    -- initialize signals toward noc (receive from noc)
    coherence_rsp_rcv_rdreq <= '0';

    -- get preambles
    rsp_preamble := get_preamble(coherence_rsp_rcv_data_out);

    -- fsm states
    case reg.state is

      -- RECEIVE HEADER
      when rcv_header =>

        if coherence_rsp_rcv_empty = '0' then

          coherence_rsp_rcv_rdreq <= '1';

          msg_type       := get_msg_type(coherence_rsp_rcv_data_out);
          reg.coh_msg    := msg_type(reg.coh_msg'length - 1 downto 0);
          reserved       := get_reserved_field(coherence_rsp_rcv_data_out);
          reg.invack_cnt := reserved(reg.invack_cnt'length - 1 downto 0);

          reg.state := rcv_addr;

        end if;

      -- RECEIVE ADDRESS
      when rcv_addr =>
        if coherence_rsp_rcv_empty = '0' then

          if ('0' & reg.coh_msg = RSP_INV_ACK) then

            if rsp_in_ready = '1' then

              coherence_rsp_rcv_rdreq <= '1';
              rsp_in_valid            <= '1';
              rsp_in_data_coh_msg     <= reg.coh_msg;
              rsp_in_data_addr        <= coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
              reg.state               := rcv_header;

            end if;

          else
            -- RSP_DATA, RSP_EDATA

            coherence_rsp_rcv_rdreq <= '1';
            reg.addr                := coherence_rsp_rcv_data_out(ADDR_BITS - 1 downto LINE_RANGE_LO);
            reg.word_cnt            := 0;
            reg.state               := rcv_data;

          end if;

        end if;

      -- RECEIVE DATA
      when rcv_data =>
        if coherence_rsp_rcv_empty = '0' then

          if reg.word_cnt = WORDS_PER_LINE - 1 then

            if rsp_in_ready = '1' then

              coherence_rsp_rcv_rdreq <= '1';

              reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                       BITS_PER_WORD * reg.word_cnt)
                := coherence_rsp_rcv_data_out(BITS_PER_WORD - 1 downto 0);

              reg.state := rcv_header;

              rsp_in_valid           <= '1';
              rsp_in_data_coh_msg    <= reg.coh_msg;
              rsp_in_data_invack_cnt <= reg.invack_cnt;
              rsp_in_data_addr       <= reg.addr;
              rsp_in_data_line       <= reg.line;
            end if;

          else

            coherence_rsp_rcv_rdreq <= '1';

            reg.line((BITS_PER_WORD * reg.word_cnt) + BITS_PER_WORD - 1 downto
                     (BITS_PER_WORD * reg.word_cnt))
              := coherence_rsp_rcv_data_out(BITS_PER_WORD - 1 downto 0);

            reg.word_cnt := reg.word_cnt + 1;

          end if;

        end if;

    end case;

    rsp_in_reg_next <= reg;

  end process fsm_rsp_in;


-------------------------------------------------------------------------------
-- Debug
-------------------------------------------------------------------------------

  req_acc_reg_state   <= req_acc_reg.state;
  req_reg_state    <= req_reg.state;
  rsp_in_reg_state <= rsp_in_reg.state;

  --req_asserts    <= req_reg.asserts;
  --rsp_in_asserts <= rsp_in_reg.asserts;

  --led_wrapper_asserts <= or_reduce(req_reg.asserts) or or_reduce(rsp_in_reg.asserts);

  --debug_led <= or_reduce(bookmark) or or_reduce(asserts) or led_wrapper_asserts;

end rtl;
