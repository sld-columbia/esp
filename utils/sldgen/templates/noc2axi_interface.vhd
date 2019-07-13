-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.sldcommon.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.genacc.all;
use work.acctypes.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

-- <<entity>>

  generic (
    tech           : integer;
    local_y        : local_yx;
    local_x        : local_yx;
    mem_num        : integer;
    mem_info       : tile_mem_info_vector(0 to MEM_MAX_NUM);
    io_y           : local_yx;
    io_x           : local_yx;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#fff#;
    pirq           : integer := 0;
    has_dvfs       : integer := 1;
    has_pll        : integer;
    extra_clk_buf  : integer;
    local_apb_en   : std_logic_vector(0 to NAPBSLV - 1));
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    pllclk    : out std_ulogic;

    -- NoC plane coherence request
    coherence_req_wrreq        : out std_ulogic;
    coherence_req_data_in      : out noc_flit_type;
    coherence_req_full         : in  std_ulogic;
    -- NoC plane coherence forward
    coherence_fwd_rdreq        : out std_ulogic;
    coherence_fwd_data_out     : in  noc_flit_type;
    coherence_fwd_empty        : in  std_ulogic;
    -- Noc plane coherence response
    coherence_rsp_rcv_rdreq    : out std_ulogic;
    coherence_rsp_rcv_data_out : in  noc_flit_type;
    coherence_rsp_rcv_empty    : in  std_ulogic;
    coherence_rsp_snd_wrreq    : out std_ulogic;
    coherence_rsp_snd_data_in  : out noc_flit_type;
    coherence_rsp_snd_full     : in  std_ulogic;
    -- NoC plane MEM2DEV
    dma_rcv_rdreq     : out std_ulogic;
    dma_rcv_data_out  : in  noc_flit_type;
    dma_rcv_empty     : in  std_ulogic;
    -- NoC plane DEV2MEM
    dma_snd_wrreq     : out std_ulogic;
    dma_snd_data_in   : out noc_flit_type;
    dma_snd_full      : in  std_ulogic;
    -- NoC plane LLC-coherent MEM2DEV
    coherent_dma_rcv_rdreq     : out std_ulogic;
    coherent_dma_rcv_data_out  : in  noc_flit_type;
    coherent_dma_rcv_empty     : in  std_ulogic;
    -- NoC plane LLC-coherent DEV2MEM
    coherent_dma_snd_wrreq     : out std_ulogic;
    coherent_dma_snd_data_in   : out noc_flit_type;
    coherent_dma_snd_full      : in  std_ulogic;
    -- Noc plane miscellaneous (tile -> NoC)
    interrupt_wrreq   : out std_ulogic;
    interrupt_data_in : out misc_noc_flit_type;
    interrupt_full    : in  std_ulogic;
    -- Noc plane miscellaneous (tile -> NoC)
    apb_snd_wrreq     : out std_ulogic;
    apb_snd_data_in   : out misc_noc_flit_type;
    apb_snd_full      : in  std_ulogic;
    -- Noc plane miscellaneous (NoC -> tile)
    apb_rcv_rdreq     : out std_ulogic;
    apb_rcv_data_out  : in  misc_noc_flit_type;
    apb_rcv_empty     : in  std_ulogic;
    mon_dvfs_in       : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc           : out monitor_acc_type;
    mon_cache         : out monitor_cache_type;
    mon_dvfs          : out monitor_dvfs_type
    );

end;

-- <<architecture>>

  -- AXI4 Master
  signal mosi : axi_mosi_vector(0 to 0);
  signal somi : axi_somi_vector(0 to 0);

  -- APB
  signal apbi : apb_slv_in_type;
  signal apbo : apb_slv_out_vector;

  -- IRQ
  signal irq      : std_logic_vector(NAHBIRQ-1 downto 0);
  signal irqset   : std_ulogic;
  type irq_fsm is (idle, pending);
  signal irq_state, irq_next : irq_fsm;
  signal irq_header_i, irq_header            : misc_noc_flit_type;
  constant irq_info                          : std_logic_vector(3 downto 0) := conv_std_logic_vector(

  -- Other signals
  signal acc_go : std_ulogic;
  signal acc_run : std_ulogic;
  signal acc_done : std_ulogic;
  type acc_state_t is (idle, go, run);
  signal acc_current, acc_next : acc_state_t;

  -- DVFS (unused for now)
  signal pllclk_int        : std_ulogic;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

begin

  -- <<accelerator_instance>>

  -- <<axi_unused>>

  -- Unused queues
  coherence_req_wrreq <= '0';
  coherence_req_data_in <= (others => '0');
  coherence_fwd_rdreq <= '0';
  coherence_rsp_rdreq <= '0';
  cohernece_rsp_wrreq <= '0';
  coherence_rsp_snd_data_in <= (others => '0');

  coherent_dma_rcv_rdreq <= '0';
  coherent_dma_snd_wrreq <= '0';
  coherent_dma_snd_data_in <= (others => '0');

  axi2noc_1: cpu_axi2noc
    generic map (
      tech             => tech,
      nmst             => 1,
      local_y          => local_y,
      local_x          => local_x,
      retarget_for_dma => 1,
      mem_axi_port     => 0,
      mem_num          => mem_num,
      mem_info         => mem_info,
      slv_y            => io_y,
      slv_x            => io_x)
    port map (
      rst                        => rst,
      clk                        => clk,
      mosi                       => mosi,
      somi                       => somi,
      coherence_req_wrreq        => dma_snd_wrreq,
      coherence_req_data_in      => dma_snd_data_in,
      coherence_req_full         => dma_snd_full,
      coherence_rsp_rcv_rdreq    => dma_rcv_rdreq,
      coherence_rsp_rcv_data_out => dma_rcv_data_out,
      coherence_rsp_rcv_empty    => dma_rcv_empty,
      remote_ahbs_snd_wrreq      => open,
      remote_ahbs_snd_data_in    => open,
      remote_ahbs_snd_full       => '0',
      remote_ahbs_rcv_rdreq      => open,
      remote_ahbs_rcv_data_out   => (others => '0'),
      remote_ahbs_rcv_empty      => '0');

  -- APB proxy
  misc_noc2apb_1 : misc_noc2apb
    generic map (
      tech         => tech,
      local_y      => local_y,
      local_x      => local_x,
      local_apb_en => local_apb_en)
    port map (
      rst              => rst,
      clk              => clk,
      apbi             => apbi,
      apbo             => apbo,
      dvfs_transient   => mon_dvfs_feedthru.transient,
      apb_snd_wrreq    => apb_snd_wrreq,
      apb_snd_data_in  => apb_snd_data_in,
      apb_snd_full     => apb_snd_full,
      apb_rcv_rdreq    => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty    => apb_rcv_empty
    );

  -- Using only one apbo signal
  no_apb : for i in 0 to NAPBSLV - 1 generate
    local_apb : if i /= pindex generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  apbo(pindex)(NAHBIRQ - 1 downto pirq + 1) <= (others => '0');
  apbo(pindex)(pirq) <= acc_done;
  apbo(pindex)(pirq - 1 downto 0) <= (others => '0');


  -- IRQ packet
  irq_header_i <= create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, io_y, io_x, INTERRUPT, irq_info)(MISC_NOC_FLIT_SIZE - 1 downto 0);
  irq_header(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_1FLIT;
  irq_header(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <=
    irq_header_i(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0);

  -- Interrupt over NoC
  irq_send: process (irq, interrupt_full, irq_state, irq_header)
  begin  -- process irq_send
    interrupt_data_in <= irq_header;
    interrupt_wrreq <= '0';
    irq_next <= irq_state;

    case irq_state is
      when idle =>
        if irq(pirq) = '1' then
          if interrupt_full = '1' then
            irq_next <= pending;
          else
            interrupt_wrreq <= '1';
          end if;
        end if;

      when pending =>
        if interrupt_full = '0' then
          interrupt_wrreq <= '1';
          irq_next <= idle;
        end if;

      when others =>
        irq_next <= idle;
    end case;
  end process irq_send;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      dma_state <= idle;
      irq_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      dma_state <= dma_next;
      irq_state <= irq_next;
    end if;
  end process;



  -- Acelerator monitor an
  process (clk, rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      acc_current <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      acc_current <= acc_next;
    end if;
  end process;

  process (mosi, acc_done, acc_current) is
  begin  -- process
    acc_go <= '0';
    acc_run <= '0';
    acc_next <= acc_rurrent;

    case acc_current is

      when idle =>
        if mosi.ar.valid or mosi.aw.valid = '1' then
          acc_go <= '1';
          acc_next <= run;
        end if;

      when run =>
        acc_run <= '1';
        if acc_done = '1' then
          acc_next <= done;
        end if;

      when done =>
        if not acc_done then
          acc_next <= idle;
        end if;

      when others =>
        acc_next <= idle;

    end case;

  end process;


  mon_acc.clk   <= pllclk_int;
  mon_acc.go    <= acc_go;
  mon_acc.run   <= acc_run;
  mon_acc.done  <= acc_done;
  mon_acc.burst <= mosi.w.valid or mosi.r.ready;

  -- No DVFS on this tile for now
  pllclk_int <= refclk;
  pllclk <= pllclk_int;

  mon_dvfs      <= mon_dvfs_none;

end rtl;
