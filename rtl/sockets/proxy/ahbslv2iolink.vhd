-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;


entity ahbslv2iolink is
  generic (
    hindex        : integer range 0 to  NAHBSLV - 1 := 0;
    hconfig       : ahb_config_type;
    io_bitwidth   : integer range 1 to ARCH_BITS := 32;  -- power of 2, <= word_bitwidth
    word_bitwidth : integer range 1 to ARCH_BITS := 32;  -- 32 or 64
    little_end    : integer range 0 to 1         := 0);
  port (
    clk           : in  std_ulogic;
    rstn          : in  std_ulogic;
    io_clk_in     : in  std_logic;
    io_clk_out    : out std_logic;
    io_valid_in   : in  std_ulogic;
    io_valid_out  : out std_ulogic;
    io_credit_in  : in  std_logic;
    io_credit_out : out std_logic;
    io_data_oen   : out std_logic;
    io_data_in    : in  std_logic_vector(io_bitwidth - 1 downto 0);
    io_data_out   : out std_logic_vector(io_bitwidth - 1 downto 0);
    ahbsi         : in  ahb_slv_in_type;
    ahbso         : out ahb_slv_out_type);

end entity ahbslv2iolink;

architecture rtl of ahbslv2iolink is

  ----------------------------------------------------------------------------
  --AHB slv
  type attribute_vector is array (natural range <>) of integer;
  --signal hconfig : ahb_config_type;
  
  constant ddr_haddr : integer := 16#400#;
  constant hmask : integer := 16#C00#;  
  -- added for compatability with ahb ramsim
  constant maccsz : integer := AHBDW;
  constant dw : integer := maccsz;
  constant kbytes : integer := 2 * 1024;
  constant abits : integer := log2ext(kbytes) + 10 - log2(dw/8); -- understand value 
  
  
  -----------------------------------------------------------------------------
  --FSM: ahb rd/wr
  ------------------------------------------------------------------------------
  type ahb_to_io_state is (recv_address, get_length, snd_data, rcv_data, early_burst_term);
  
  type ahb_slv_out_local_type is record
    hready : std_ulogic; 
    hresp  : std_logic_vector(1 downto 0); 
    hrdata : std_logic_vector(AHBDW-1 downto 0);
  end record;

  type reg_type is record
    state       : ahb_to_io_state;
    ahbsout     : ahb_slv_out_local_type;
    cnt         : integer;
    burst_mode  : std_ulogic;
    load_first  : std_ulogic;
  end record;
  
  constant QUEUE_DEPTH : integer := 8;
  
  constant ahbsout_reset : ahb_slv_out_local_type := (
    hready  => '1',
    hresp   => HRESP_OKAY,
    hrdata  => (others => '0'));
  
  constant REG_DEF   : reg_type := (
    state       => recv_address,
    ahbsout     => ahbsout_reset,
    cnt         => 0,
    burst_mode  => '0',
    load_first  => '0'
  );
  
  constant zero_ahb_flags : std_logic_vector(0 to NAHBSLV - 1) := (others => '0');
  
  -------------------------------------------------------------------------------
  -- FSM: I/O Send
  -------------------------------------------------------------------------------
  type io_snd_fsm_t is (idle, send);

  type io_snd_reg_type is record
    state : io_snd_fsm_t;
    word  : std_logic_vector(word_bitwidth - 1 downto 0);
    cnt   : integer range 0 to 64;
  end record io_snd_reg_type;

  constant IO_SND_REG_DEFAULT : io_snd_reg_type := (
    state => idle,
    word  => (others => '0'),
    cnt   => 0);

  signal io_snd_reg, io_snd_reg_next : io_snd_reg_type;

  constant default_len : std_logic_vector := x"00000001";
  constant MAX_BURST_SIZE : integer := 27; --256;
  constant IO_BEATS : natural range 1 to 64 := word_bitwidth / io_bitwidth;
  
  ---------------------------------------------------
  -- io_en sync delay
  --------------------------------------------------
  type snd_sync_type is record
    sync_clk    : std_ulogic;
    async       : std_ulogic;
    sync_clk_io : std_ulogic;
  end record snd_sync_type;

  type rcv_sync_type is record
    sync_clk    : std_ulogic;
    async       : std_ulogic;
    delay       : std_logic_vector(3 downto 0);
    sync_clk_io : std_ulogic;
  end record rcv_sync_type;

  signal receiving : rcv_sync_type;
  signal sending   : snd_sync_type;

  attribute ASYNC_REG              : string;
  attribute ASYNC_REG of receiving : signal is "TRUE";
  -- attribute ASYNC_REG of sending : signal is "TRUE";

  -------------------------------------------------------------------------------
  -- FSM: Output enable
  -------------------------------------------------------------------------------
  type oen_fsm_t is (receive_address, receive_length, receive_data, send_data);

  type oen_reg_type is record
    state  : oen_fsm_t;
    count  : integer;
    write  : std_ulogic;
  end record oen_reg_type;

  constant OEN_REG_DEFAULT : oen_reg_type := (
    state => receive_address,
    count => 0,
    write => '0');

  signal oen_reg, oen_reg_next : oen_reg_type;
  signal oen_fsm_idle, oen_fsm_idle_sync : std_logic;
  
  
  -------------------------------------------------------------------------------
  -- FSM: I/O Receive
  -------------------------------------------------------------------------------
  type io_rcv_reg_type is record
    word : std_logic_vector(word_bitwidth - 1 downto 0);
    cnt  : integer range 0 to 64;
  end record io_rcv_reg_type;

  constant IO_RCV_REG_DEFAULT : io_rcv_reg_type := (
    word => (others => '0'),
    cnt  => 0);

  signal io_rcv_reg, io_rcv_reg_next : io_rcv_reg_type;

  
  signal ahb_rcv_wrreq      : std_ulogic;
  signal ahb_rcv_rdreq      : std_ulogic;
  signal ahb_rcv_data_in    : std_logic_vector(word_bitwidth - 1 downto 0);
  signal ahb_rcv_data_out   : std_logic_vector(word_bitwidth - 1 downto 0);
  signal ahb_rcv_full       : std_ulogic;
  signal ahb_rcv_empty      : std_ulogic;
  signal ahb_rcv_almost_full : std_ulogic;
  
  signal hsel_reg   : std_logic_vector(0 to NAHBSLV - 1);
  signal hwdata_reg : std_logic_vector (word_bitwidth - 1 downto 0);
  signal hwrite_reg : std_ulogic;
  signal hburst_reg : std_logic_vector (2 downto 0);
  signal htrans_reg : std_logic_vector (1 downto 0);

  signal sample_bus : std_ulogic;

  signal r, rin : reg_type;
  signal ahb_clk_in : std_ulogic;
  
  signal credits         : integer range 0 to QUEUE_DEPTH;
  signal credit_in       : std_ulogic;
  signal credit_in_empty : std_ulogic;
  signal credit_received : std_ulogic;

  signal io_snd_wrreq_in    : std_logic;
  signal io_snd_data_in     : std_logic_vector (word_bitwidth - 1 downto 0);
  signal io_snd_full_in     : std_logic;
  signal io_snd_clk_out     : std_logic;
  signal io_snd_rdreq_out   : std_logic;
  signal io_snd_data_out    : std_logic_vector (word_bitwidth - 1 downto 0);
  signal io_snd_empty       : std_logic;
  
  signal io_clk_out_int   : std_logic;
  signal io_valid_out_int : std_ulogic;
  signal rst :std_ulogic;
  
  signal ahb_snd_wrreq      : std_ulogic;
  signal ahb_snd_rdreq      : std_ulogic;
  signal ahb_snd_data_in    : std_logic_vector(word_bitwidth - 1 downto 0);
  signal ahb_snd_data_out   : std_logic_vector(word_bitwidth - 1 downto 0);
  signal ahb_snd_full       : std_ulogic;
  signal ahb_snd_almost_full       : std_ulogic;
  signal ahb_snd_empty      : std_ulogic;
  
  signal io_rcv_wrreq_in    : std_logic;
  signal io_rcv_data_in     : std_logic_vector (word_bitwidth - 1 downto 0);
  signal io_rcv_full_in     : std_logic;
  signal io_rcv_clk_out     : std_logic;
  signal io_rcv_rdreq_out   : std_logic;
  signal io_rcv_data_out    : std_logic_vector (word_bitwidth - 1 downto 0);
  signal io_rcv_almost_full : std_ulogic;
  signal io_rcv_empty       : std_logic;
  
  attribute mark_debug : string;
  --attribute keep       : string;
  
  --attribute mark_debug of ahb_snd_wrreq : signal is "true";
  --attribute mark_debug of ahb_snd_rdreq : signal is "true";
  --attribute mark_debug of ahb_snd_data_in : signal is "true";
  --attribute mark_debug of ahb_snd_data_out : signal is "true";
  --attribute mark_debug of ahb_snd_full : signal is "true";
  --attribute mark_debug of ahb_snd_almost_full : signal is "true";
  --attribute mark_debug of ahb_snd_empty : signal is "true";
  --attribute mark_debug of io_rcv_wrreq_in : signal is "true";
  --attribute mark_debug of io_rcv_data_in : signal is "true";
  --attribute mark_debug of io_rcv_full_in : signal is "true";
  --attribute mark_debug of io_rcv_clk_out : signal is "true";
  --attribute mark_debug of io_rcv_rdreq_out : signal is "true";
  --attribute mark_debug of io_rcv_data_out : signal is "true";
  --attribute mark_debug of io_rcv_almost_full : signal is "true";
  --attribute mark_debug of io_rcv_empty : signal is "true";
  --attribute mark_debug of credits : signal is "true";  
  --attribute mark_debug of credit_in : signal is "true";  
  --attribute mark_debug of credit_in_empty : signal is "true";  
  --attribute mark_debug of credit_received : signal is "true";  
  --attribute mark_debug of r : signal is "true";  
  --attribute mark_debug of ahb_rcv_wrreq : signal is "true";  
  --attribute mark_debug of ahb_rcv_rdreq : signal is "true";  
  --attribute mark_debug of ahb_rcv_data_in : signal is "true";  
  --attribute mark_debug of ahb_rcv_data_out : signal is "true";  
  --attribute mark_debug of ahb_rcv_full : signal is "true";  
  --attribute mark_debug of ahb_rcv_empty : signal is "true";  
  --attribute mark_debug of ahb_rcv_almost_full : signal is "true";  
  --attribute mark_debug of io_snd_reg : signal is "true";  
  --attribute mark_debug of receiving : signal is "true";  
  --attribute mark_debug of sending : signal is "true";
  --attribute mark_debug of hsel_reg   : signal is "true";
  --attribute mark_debug of hwdata_reg : signal is "true";
  --attribute mark_debug of hwrite_reg : signal is "true";
  --attribute mark_debug of hburst_reg : signal is "true";
  --attribute mark_debug of htrans_reg : signal is "true";
  --attribute mark_debug of io_rcv_reg : signal is "true";
  --attribute mark_debug of oen_reg : signal is "true";
  --attribute mark_debug of oen_fsm_idle : signal is "true";
 
begin
  
  rst <= not rstn;
  io_data_oen <= sending.sync_clk_io or not receiving.sync_clk_io;

  -----------------------------------------------------------------------------
  -- Delay FSM state change
  -- Switch from sending (io_data_oen = '1') to receiving (io_data_oen = '0') in 2
  -- cycles, but switching from receiving to sending in 4 cycles to make sure
  -- pads enables are never driven on both ends of the line at the same time.
  state_synchronizer : process (io_clk_in) is
  begin
    if rising_edge(io_clk_in) then
      sending.async       <= sending.sync_clk;
      sending.sync_clk_io <= sending.async;
    end if;
  end process state_synchronizer;

  state_delay : process (io_clk_out_int) is
  begin
    if rising_edge(io_clk_out_int) then
      receiving.async       <= receiving.sync_clk;
      receiving.delay(0)    <= receiving.async;
      receiving.delay(1)    <= receiving.delay(0);
      receiving.delay(2)    <= receiving.delay(1);
      receiving.delay(3)    <= receiving.delay(2);
      --receiving.delay(4)    <= receiving.delay(3);
      receiving.sync_clk_io <= receiving.delay(3) and not sending.sync_clk;
    end if;
  end process state_delay;

  receiving.sync_clk <= not sending.sync_clk;
  
  -- oen fsm
  oen_fsm : process (oen_reg, ahb_rcv_wrreq, io_rcv_data_in, ahb_snd_rdreq, hburst_reg, ahbsi) is
    variable reg : oen_reg_type;
  begin
    reg := oen_reg;

    sending.sync_clk <= '1';

    case oen_reg.state is

      when receive_address =>
        if ahb_rcv_wrreq = '1' then
          reg.state := receive_length;
          reg.write := ahb_rcv_data_in(0);
        end if;

      when receive_length =>
        if ahb_rcv_wrreq = '1' then
          if (hburst_reg = "001" and ahbsi.htrans = HTRANS_SEQ) then
            reg.count := MAX_BURST_SIZE;
          else
            reg.count := to_integer(unsigned(default_len));
          end if;
          --reg.count := conv_integer(io_rcv_data_in(31 downto 0));
          if reg.write = '1' then
            reg.state := send_data;
          else
            reg.state := receive_data;
          end if;
        end if;

      when send_data =>
        if ahb_rcv_wrreq = '1' then
          reg.count := reg.count - 1;
          if reg.count = 0 then
            reg.state := receive_address;
          end if;
        end if;

      when receive_data =>
        sending.sync_clk <= '0';
        if ahb_snd_rdreq = '1' then
          reg.count := reg.count - 1;
          if reg.count = 0 then
            reg.state := receive_address;
          end if;
        end if;

    end case;

    oen_reg_next <= reg;
  end process oen_fsm;
 oen_fsm_idle <= '1' when oen_reg.state = receive_address else '0';  
 --oen_fsm_idle <= '1' when oen_reg.state = '0';
  
  -- Credits in
  oen_reg_fifo : inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => '1',
      d_i(0)     => oen_fsm_idle,
      wr_full_o  => open,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => '1',
      q_o(0)     => oen_fsm_idle_sync,
      rd_empty_o => open);


  -- ahb reqst receiving FIFO
  ahb_in_fifo : fifo3
    generic map (
      depth => QUEUE_DEPTH,
      width => word_bitwidth)
    port map (
      clk           => clk,
      rst           => rstn,
      wrreq         => ahb_rcv_wrreq, 
      data_in       => ahb_rcv_data_in,
      full          => ahb_rcv_full,
      almost_full   => ahb_rcv_almost_full,
      rdreq         => io_snd_rdreq_out,
      data_out      => io_snd_data_out,
      empty         => io_snd_empty);

-- ahb sending FIFO
  ahb_out_fifo : inferred_async_fifo
    generic map (
      g_data_width => word_bitwidth,
      g_size       => QUEUE_DEPTH)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => io_rcv_wrreq_in, 
      d_i        => io_rcv_data_in,
      wr_full_o  => io_rcv_full_in,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => io_rcv_rdreq_out,
      q_o        => io_rcv_data_out,
      rd_empty_o => io_rcv_empty);


  io_out_fifo : fifo3
  generic map (
      depth => QUEUE_DEPTH,
      width => word_bitwidth)
      port map (    
      clk         => clk,
      rst         => rstn,
      wrreq       => ahb_snd_wrreq,
      data_in     => ahb_snd_data_in,
      full        => ahb_snd_full,
      almost_full => ahb_snd_almost_full,
      rdreq       => ahb_snd_rdreq,
      data_out    => ahb_snd_data_out,
      empty       => ahb_snd_empty);
 
  ahb_snd_wrreq <= not io_rcv_empty and not ahb_snd_full;
  io_rcv_rdreq_out <= not io_rcv_empty and not ahb_snd_full;
  ahb_snd_data_in <= io_rcv_data_out;
  
  --io_data_out   <= (others => '0');
  --io_valid_out  <= '0';
  --io_clk_out    <= '0';
  --io_credit_out <= '0';
  --ahbso.hresp   <= "00";
  --ahbso.hsplit  <= (others => '0');
  --ahbso.hirq    <= (others => '0');
  --ahbso.hconfig <= hconfig;
  --ahbso.hindex  <= hindex;

  -----------------------------------------------------------------------------
  -- Credits in
  credits_in_fifo : inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_wr_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => io_credit_in,
      d_i        => "0",
      wr_full_o  => open,
      rst_rd_n_i    => rstn,
      clk_rd_i   => clk,
      rd_i       => '1',
      q_o(0)     => credit_in,
      rd_empty_o => credit_in_empty);

  credit_received <= credit_in nor credit_in_empty;
  
  -----------------------------------------------------------------------------
  -- credits fsm
  credits_fsm : process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if rstn = '0' then
        credits <= QUEUE_DEPTH;
      else
        if io_snd_rdreq_out = '1' and credit_received = '0' and credits /= 0 then
          credits <= credits - 1;
        elsif io_snd_rdreq_out = '0' and credit_received = '1' and credits /= QUEUE_DEPTH then
          credits <= credits + 1;
        end if;
    end if;
    end if;
  end process credits_fsm;

  -----------------------------------------------------------------------------
  -- Credits out
  credits_out_reg : process (clk) is
  begin  -- process io_credit_out_reg
    if clk'event and clk = '1' then
      io_credit_out <= ahb_snd_rdreq;
    end if;
  end process credits_out_reg;

  -----------------------------------------------------------------------------
  --FSM ahbslv rd/write
  ahb_rdwr_reqsts_fsm : process (r, ahbsi, io_snd_empty, ahb_rcv_almost_full, ahb_rcv_full, ahb_snd_empty, ahb_snd_wrreq, ahb_snd_data_out, hwrite_reg, hburst_reg, hwdata_reg)
  variable v : reg_type;
  variable burst_mode : std_ulogic;
  variable selected : std_ulogic;
  
  begin

    v := r;
    
    --burst_mode := '0';
    sample_bus <= '0';
    ahb_rcv_wrreq <= '0';
    ahb_rcv_data_in <= (others => '0');
    ahb_snd_rdreq <= '0';
    v.ahbsout.hready := '1';
    --ahbso.hready <= '1';
    --ahbso.hrdata <= X"00000000";
    
    -- Default ahbso assignment
    ahbso.hready <= '1';
    ahbso.hrdata <= (others => '0');
    ahbso.hresp <= HRESP_OKAY;
    ahbso.hsplit <= (others => '0');
    ahbso.hirq <= (others => '0');
    ahbso.hrdata <= (others => '0');
    ahbso.hconfig <= hconfig;
    ahbso.hindex <= hindex;
    
    selected := '0';
    --if (ahbsi.hsel and hindex) /= zero_ahb_flags then
    if (ahbsi.hsel(hindex)) = '1' then
      selected := '1';
    end if;
 
    case r.state is

      when recv_address =>
        if (ahb_rcv_full or ahb_rcv_almost_full) = '0' then
          v.burst_mode := '0';
          v.load_first := '1';
            if (selected = '1' and ahbsi.hready = '1' and ahbsi.htrans = HTRANS_NONSEQ) then
              sample_bus <= '1';
              ahb_rcv_data_in <= (others => '0');
              if (ahbsi.hwrite = '1') then
                ahb_rcv_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= ahbsi.haddr(31 downto 1) & '1';
              else
                ahb_rcv_data_in(GLOB_PHYS_ADDR_BITS - 1 downto 0) <= ahbsi.haddr(31 downto 1) & '0';
              end if;
              ahb_rcv_wrreq <= '1';
              v.state := get_length;
            end if;
              --TODO: hanlde splitted burst transaction
          --end if;
        end if;
       
      -- TODO: add different burst lengths 
      when get_length =>
        v.ahbsout.hready := '0';
        --ahbso.hready <= '0';
        if(ahb_rcv_full or ahb_rcv_almost_full ) = '0' then
          --undefined burst length
          if (hburst_reg = "001" and ahbsi.htrans = HTRANS_SEQ) then
            ahb_rcv_data_in <= std_logic_vector(to_signed (MAX_BURST_SIZE, ahb_rcv_data_in'length));
            v.cnt := MAX_BURST_SIZE;
            v.burst_mode := '1';
          else 
            ahb_rcv_data_in <= (others => '0');
            ahb_rcv_data_in(0) <= '1';
            v.cnt := 1;
            v.burst_mode := '0';
           end if;         
          ahb_rcv_wrreq <= '1';
          
          if (hwrite_reg = '1') then
            v.state := snd_data;
          else
            v.state := rcv_data;
          end if;
        end if;

      when snd_data =>
        v.ahbsout.hready := '0';
        if (ahb_rcv_almost_full or ahb_rcv_full) = '0' then
          v.ahbsout.hready := '1';
          if (v.burst_mode = '1') then
            -- burst mode
            --check early termination of burst
            if (ahbsi.htrans = HTRANS_IDLE and r.cnt > 2) then
              v.state := early_burst_term;
            --first word of the burst
            elsif (v.load_first = '1') then
              ahb_rcv_data_in <= hwdata_reg;
              ahb_rcv_wrreq <= '1';
              v.load_first := '0';
              v.cnt := r.cnt - 1;
            --load remaining burst words
            elsif (r.cnt /= 0) then
              ahb_rcv_data_in <= ahbreadword(ahbsi.hwdata);
              ahb_rcv_wrreq <= '1';
              v.load_first := '0';
              v.cnt := r.cnt - 1;
            else
               v.state := recv_address;
            end if;
          -- single transaction mode
          elsif (v.burst_mode = '0') then
            ahb_rcv_data_in <= hwdata_reg;
            ahb_rcv_wrreq <= '1';
            v.state := recv_address;
          end if;
        end if;

      --In case of early burst termination
      --send 0s for the remaining burst beats
      when early_burst_term =>
        v.ahbsout.hready := '0';
        if (ahb_rcv_almost_full or ahb_rcv_full) = '0' then
          if (r.cnt /= 0) then
            ahb_rcv_data_in <= (others => '0');
            ahb_rcv_wrreq <= '1';
            v.load_first := '0';
            v.cnt := r.cnt - 1;
          else
            v.state := recv_address;
          end if;
        end if;
        
      when rcv_data =>
        if (v.cnt = 0) then 
          v.state := recv_address;
        else
          v.ahbsout.hready := '0';
          -- flush receieved data if burst is terminated early
          --if (ahbsi.htrans = HTRANS_IDLE or ahbsi.htrans = HTRANS_NONSEQ) then
          --  if (ahb_snd_empty = '0') then
          --    ahb_snd_rdreq <= '1';
          --    v.cnt := r.cnt - 1;
              --ahbso.hready <= '0';
          --  end if;
          if (ahb_snd_empty = '0') then
            v.ahbsout.hready := '1';
            v.ahbsout.hrdata := ahbdrivedata(ahb_snd_data_out);
            ahb_snd_rdreq <= '1';
            v.cnt := r.cnt - 1;
        end if;
      end if;
    end case; 
    rin <= v;
  
    if hsel_reg(hindex) = '1' then
      ahbso.hrdata <= v.ahbsout.hrdata; -- hrdata;
      ahbso.hready <= v.ahbsout.hready; --hready;
    end if;

  end process ahb_rdwr_reqsts_fsm;

  send_to_chip_fsm : process (io_snd_reg, io_snd_empty, io_snd_data_out, credits) is
  --io_snd_fsm : process (io_snd_reg, io_snd_empty, io_snd_data_out, credits, sending) is
  variable reg : io_snd_reg_type;
  begin
    
    reg          := io_snd_reg;
    io_snd_rdreq_out <= '0';
    io_valid_out_int <= '0';
    io_data_out <= (others => '0');

    case io_snd_reg.state is

      when idle =>
        reg.cnt := 0;
        --if credits /= 0 and io_snd_empty = '0' and sending.sync_clk_io = '1' then
        if credits /= 0 and io_snd_empty = '0' then
          reg.word     := io_snd_data_out;
          io_valid_out_int <= '1';
          io_data_out  <= io_snd_data_out((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth);
          if IO_BEATS > 1 then
            reg.state := send;
            reg.cnt   := reg.cnt + 1;
          else
            io_snd_rdreq_out <= '1';
          end if;
        end if;

      when send =>
        --if credits /= 0 and sending.sync_clk_io = '1' then
        if credits /= 0 then
          io_valid_out_int <= '1';
          io_data_out  <= io_snd_data_out((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth);
          reg.cnt      := reg.cnt + 1;
          if reg.cnt = IO_BEATS then
            reg.state    := idle;
            io_snd_rdreq_out <= '1';
          end if;
        end if;

    end case;

    io_snd_reg_next <= reg;

  end process send_to_chip_fsm;

  rcv_from_chip_fsm : process (io_rcv_reg, io_rcv_full_in, io_valid_in, io_data_in) is
    variable reg : io_rcv_reg_type;
  begin
    reg          := io_rcv_reg;
    io_rcv_wrreq_in <= '0';

    if io_valid_in = '1' and io_rcv_full_in = '0'  then
      reg.word((reg.cnt + 1) * io_bitwidth - 1 downto reg.cnt * io_bitwidth) := io_data_in;
      reg.cnt                                                                := reg.cnt + 1;
      if reg.cnt = IO_BEATS then
        reg.cnt        := 0;
        io_rcv_wrreq_in   <= '1';
        io_rcv_data_in <= reg.word;
      end if;
    end if;

    io_rcv_reg_next <= reg;
  end process rcv_from_chip_fsm;

  rcv_from_chip_state_update : process (clk, rstn)
  begin
    if(rstn = '0') then
      io_rcv_reg <= IO_RCV_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      io_rcv_reg <= io_rcv_reg_next;
    end if;
  end process rcv_from_chip_state_update;

 --io_snd state update
  snd_to_chip_state_update : process (clk, rstn)
  begin
    if rstn = '0' then
      io_snd_reg <= IO_SND_REG_DEFAULT;
      oen_reg    <= OEN_REG_DEFAULT;
    elsif clk'event and clk = '1' then
      io_snd_reg <= io_snd_reg_next;
      oen_reg    <= oen_reg_next;
    end if;
  end process snd_to_chip_state_update;

 --ahb_rd_wr state register 
  rd_wr_state_update : process (clk, rstn)
  begin
    if(rstn = '0') then
      r <= REG_DEF; 
      --hsel_reg <= (others => '0');
     elsif clk'event and clk = '1' then
      r <= rin;
      --hsel_reg <= ahbsi.hsel;
    end if;
  end process rd_wr_state_update;

  sample_ahb_bus : process (clk, rstn) 
  begin
    if (rstn = '0') then
       hsel_reg   <= (others => '0');
       hwdata_reg <= (others => '0');
       hwrite_reg <= '0';
       hburst_reg <= (others => '0');
       htrans_reg <= (others => '0');

    elsif  clk'event and clk = '1' then
      if (sample_bus = '1') then
        hsel_reg <= ahbsi.hsel;
        hwdata_reg <= ahbreadword(ahbsi.hwdata);
        hwrite_reg <= ahbsi.hwrite;
        hburst_reg <= ahbsi.hburst;
        htrans_reg <= ahbsi.htrans;
      end if;
    end if;
    
  end process sample_ahb_bus;

  --ahbso.hready <= r.ahbsout.hready;
  --ahbso.hrdata <= r.ahbsout.hrdata;
  --ahbso.hresp  <= "00"; -- r.ahbsout.hresp;
  --ahbso.hirq   <= (others => '0');
  io_valid_out <= io_valid_out_int;
  
  io_clk_out_int <= clk;
  io_clk_out <= io_clk_out_int;
  --io_data_oen <= '0';

end architecture rtl;
