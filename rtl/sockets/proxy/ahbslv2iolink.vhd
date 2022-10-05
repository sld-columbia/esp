-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
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
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.ioproxy.all; --remove this when done 

entity ahbslv2iolink is
  generic (
    hindex        : integer range 0 to NAHBSLV - 1;
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

 -- constant ddr_haddr : attribute_vector(0 to CFG_NMEM_TILE - 1) := (
 --   0 => 16#400#,
 --   others => 0);

 -- AHB bus configuration
  constant hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_SLD, SLD_IO_LINK, 0, 0, 0),
    others => zero32); 
  -----------------------------------------------------------------------------
  --FSM: ahb rd/wr
  ------------------------------------------------------------------------------
  type ahb_to_io_state is (recv_address, get_length, snd_data, rcv_data);
  
  type ahb_slv_out_local_type is record
    hready : std_ulogic; 
    hresp  : std_logic_vector(1 downto 0); 
    hrdata : std_logic_vector(AHBDW-1 downto 0);
  end record;

  type reg_type is record
    state       : ahb_to_io_state;
    ahbsout     : ahb_slv_out_local_type;
  end record;
  
  constant QUEUE_DEPTH : integer := 8;
  
  constant ahbsout_reset : ahb_slv_out_local_type := (
    hready  => '1',
    hresp   => HRESP_OKAY,
    hrdata  => (others => '0'));
  
  constant REG_DEF   : reg_type := (
    state       => recv_address,
    ahbsout     => ahbsout_reset
  );

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
  constant IO_BEATS : natural range 1 to 64 := 2; --word_bitwidth / io_bitwidth;
  
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
  signal ahb_rcv_data_in    : std_logic_vector(AHBDW - 1 downto 0);
  signal ahb_rcv_data_out   : std_logic_vector(AHBDW - 1 downto 0);
  signal ahb_rcv_full       : std_ulogic;
  signal ahb_rcv_empty      : std_ulogic;
  signal ahb_rcv_almost_full : std_ulogic;
 
  signal r, rin : reg_type;
  signal ahb_clk_in : std_ulogic;
  
  signal credits         : integer range 0 to QUEUE_DEPTH;
  signal credit_in       : std_ulogic;
  signal credit_in_empty : std_ulogic;
  signal credit_received : std_ulogic;

  signal io_snd_wrreq_in    : std_logic;
  signal io_snd_data_in     : std_logic_vector (AHBDW - 1 downto 0);
  signal io_snd_full_in     : std_logic;
  signal io_snd_clk_out     : std_logic;
  signal io_snd_rdreq_out   : std_logic;
  signal io_snd_data_out    : std_logic_vector (AHBDW - 1 downto 0);
  signal io_snd_empty       : std_logic;
  
  signal io_clk_out_int   : std_logic;
  signal io_valid_out_int : std_ulogic;
  signal rst :std_ulogic;
  
  signal ahb_snd_wrreq      : std_ulogic;
  signal ahb_snd_rdreq      : std_ulogic;
  signal ahb_snd_data_in    : std_logic_vector(AHBDW - 1 downto 0);
  signal ahb_snd_data_out   : std_logic_vector(AHBDW - 1 downto 0);
  signal ahb_snd_full       : std_ulogic;
  signal ahb_snd_almost_full       : std_ulogic;
  signal ahb_snd_empty      : std_ulogic;
  
  signal io_rcv_wrreq_in    : std_logic;
  signal io_rcv_data_in     : std_logic_vector (AHBDW - 1 downto 0);
  signal io_rcv_full_in     : std_logic;
  signal io_rcv_clk_out     : std_logic;
  signal io_rcv_rdreq_out   : std_logic;
  signal io_rcv_data_out    : std_logic_vector (AHBDW - 1 downto 0);
  signal io_rcv_almost_full : std_ulogic;
  signal io_rcv_empty       : std_logic;
  

begin
  -------------------------------------------------------------------------
  -- Receiving FIFO
  --ahb_in_fifo : inferred_async_fifo
    --generic map (
      --g_data_width  => word_bitwidth,
      --g_size        => 2 * QUEUE_DEPTH)
    --port map (
      --rst_n_i    => rstn,
      --clk_wr_i   => ahb_clk_in,     --fix this clk
      --we_i       => ahb_rcv_wrreq,
      --d_i        => ahb_rcv_data_in,
      --wr_full_o  => ahb_rcv_full,
      --clk_rd_i   => clk,
      --rd_i       => ahb_rcv_rdreq, 
      --q_o        => ahb_rcv_data_out,
      --rd_empty_o => ahb_rcv_empty);
 -----------------------------------------------------------------------------
  rst <= not rstn;

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


  --ahb_in_fifo : fifo3
  --generic map (
      --depth => QUEUE_DEPTH,
      --width => word_bitwidth)
      --port map (    
      --clk         => clk,
      --rst         => rstn,
      --wrreq       => ahb_rcv_wrreq,
      --data_in     => ahb_rcv_data_in,
      --full        => ahb_rcv_full,
      --almost_full => ahb_rcv_almost_full,
      --rdreq       => ahb_rcv_rdreq,
      --data_out    => ahb_rcv_data_out,
      --empty       => ahb_rcv_empty);
 
  --io_snd_wrreq_in <= not ahb_rcv_empty and not io_snd_full_in;
  --ahb_rcv_rdreq <= not ahb_rcv_empty and not io_snd_full_in;
  --io_snd_data_in <= ahb_rcv_data_out;


-- ahb sending FIFO
  ahb_out_fifo : inferred_async_fifo
    generic map (
      g_data_width => word_bitwidth,
      g_size       => QUEUE_DEPTH)
    port map (
      rst_n_i    => rstn,
      clk_wr_i   => clk,
      we_i       => io_rcv_wrreq_in, 
      d_i        => io_rcv_data_in,
      wr_full_o  => io_rcv_full_in,
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

  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  -----------------------------------------------------------------------------
  -- Credits in
  credits_in_fifo : inferred_async_fifo
    generic map (
      g_data_width => 1,
      g_size       => 2 * QUEUE_DEPTH)
    port map (
      rst_n_i    => rstn,
      clk_wr_i   => io_clk_in,
      we_i       => io_credit_in,
      d_i        => "0",
      wr_full_o  => open,
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
  ahb_rdwr_reqsts_fsm : process (r, ahbsi, io_snd_empty, ahb_rcv_almost_full, ahb_rcv_full, ahb_snd_empty, ahb_snd_wrreq)
  variable v : reg_type;
  begin

    v := r;

    ahb_rcv_wrreq <= '0';
    ahb_rcv_data_in <= (others => '0');
    ahb_snd_rdreq <= '0';
    v.ahbsout.hready := '0';
     
    case r.state is

      when recv_address =>
        if(ahb_rcv_full = '0') then
          v.ahbsout.hready := '1';
          --if (ahbsi.hsel(hindex) = '1' and ahbsi.hready = '1') then
            if (ahbsi.htrans = HTRANS_NONSEQ) or (ahbsi.htrans = HTRANS_SEQ) then
              v.ahbsout.hready := '0';
              if (ahbsi.hwrite = '1') then
                ahb_rcv_data_in <= ahbsi.haddr(31 downto 1) & '1';
              else
                ahb_rcv_data_in <= ahbsi.haddr(31 downto 1) & '0';
              end if;  
                ahb_rcv_wrreq <= '1';
                v.state := get_length;
            end if;
          --end if;
        end if;      
       
      -- TODO: calcualte size from burst length 
      when get_length =>
        if(ahb_rcv_full = '0') then
          ahb_rcv_data_in <= default_len;
          ahb_rcv_wrreq <= '1';
          if (ahbsi.hwrite = '1') then
            v.state := snd_data;
            --v.ahbsout.hready := '1';
          else
            v.state := rcv_data;
            --v.ahbsout.hready := '1';
          end if;
        end if;

      when snd_data =>
        if(ahb_rcv_full = '0') then
           v.ahbsout.hready := '1';
           ahb_rcv_data_in <= ahbsi.hwdata;
           ahb_rcv_wrreq <= '1';
           v.state := recv_address;
        end if;

      when rcv_data =>
        v.ahbsout.hready := '0';
        if(ahb_snd_empty = '0') then
          v.ahbsout.hready := '1';
          v.ahbsout.hrdata := ahb_snd_data_out;
          v.state := recv_address;
          ahb_snd_rdreq <= '1';
        end if;

    end case; 
    rin <= v;

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

    if io_valid_in = '1' and io_rcv_full_in = '0' then
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
    elsif clk'event and clk = '1' then
      io_snd_reg <= io_snd_reg_next;
    end if;
  end process snd_to_chip_state_update;

 --ahb_rd_wr state register 
  rd_wr_state_update : process (clk, rstn)
  begin
    if(rstn = '0') then
      r <= REG_DEF; 
     elsif clk'event and clk = '1' then
      r <= rin;
    end if;
  end process rd_wr_state_update;

  ahbso.hready <= r.ahbsout.hready;
  ahbso.hrdata <= r.ahbsout.hrdata;
  ahbso.hresp  <= r.ahbsout.hresp;
  io_valid_out <= io_valid_out_int;
  
  io_clk_out_int <= clk;
  io_clk_out <= io_clk_out_int;


end architecture rtl;
