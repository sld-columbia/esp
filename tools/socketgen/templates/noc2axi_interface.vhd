-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.monitor_pkg.all;
use work.nocpackage.all;
use work.allcaches.all;
use work.cachepackage.all;
use work.tile.all;
use work.genacc.all;
use work.esp_acc_regmap.all;
use work.amba.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

-- <<entity>>

  generic (
    hls_conf       : hlscfg_t;
    tech           : integer;
    mem_num        : integer;
    cacheable_mem_num : integer;
    mem_info       : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE);
    io_y           : local_yx;
    io_x           : local_yx;
    pindex         : integer := 0;
    irq_type       : integer := 0;
    scatter_gather : integer := 1;
    sets           : integer := 256;
    ways           : integer := 8;
    little_end     : integer range 0 to 1 := 1;
    cache_tile_id  : cache_attribute_array;
    cache_y        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    cache_x        : yx_vec(0 to 2**NL2_MAX_LOG2 - 1);
    has_l2         : integer := 1;
    has_dvfs       : integer := 1;
    has_pll        : integer;
    extra_clk_buf  : integer);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    pllclk    : out std_ulogic;
    local_y   : in  local_yx;
    local_x   : in  local_yx;
    tile_id   : in  integer range 0 to CFG_TILES_NUM - 1;
    paddr     : in  integer range 0 to 4095;
    pmask     : in  integer range 0 to 4095;
    paddr_ext : in  integer range 0 to 4095;
    pmask_ext : in  integer range 0 to 4095;
    pirq      : in  integer range 0 to NAHBIRQ - 1;
    -- APB
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    pready    : out std_ulogic;

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
    coherence_fwd_snd_wrreq    : out std_ulogic;
    coherence_fwd_snd_data_in  : out noc_flit_type;
    coherence_fwd_snd_full     : in  std_ulogic;
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
    -- Noc plane miscellaneous (NoC -> tile)
    interrupt_ack_rdreq    : out std_ulogic;
    interrupt_ack_data_out : in  misc_noc_flit_type;
    interrupt_ack_empty    : in  std_ulogic;
    mon_dvfs_in       : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc           : out monitor_acc_type;
    mon_cache         : out monitor_cache_type;
    mon_dvfs          : out monitor_dvfs_type;
    dvfs_transient_acc    : in std_ulogic;
    -- Coherence
    coherence         : in integer range 0 to 3);

end;

-- <<architecture>>

  -- AXI4 Master
  signal mosi : axi_mosi_vector(0 to 0);
  signal somi : axi_somi_vector(0 to 0);

  -- Plug&Play info
  constant vendorid      : vendor_t               := VENDOR_SLD;
  constant revision      : integer                := 0;
  -- <<devid>>
  signal pconfig : apb_config_type;
  signal apbi_paddr : std_logic_vector(31 downto 0);

  -- IRQ
  type irq_fsm is (idle, pending, wait_for_clear_irq);
  signal irq_state, irq_next : irq_fsm;
  signal irq_header_i, irq_header : misc_noc_flit_type;
  signal irq_info : std_logic_vector(RESERVED_WIDTH - 1 downto 0);

  -- Other signals
  signal acc_go : std_ulogic;
  signal acc_run : std_ulogic;
  signal acc_done : std_ulogic;
  type acc_state_t is (idle, run, done);
  signal acc_current, acc_next : acc_state_t;

  -- DVFS (unused for now)
  signal pllclk_int        : std_ulogic;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

  constant nofb_mem_info : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1) := mem_info(0 to CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE - 1);

  -- NoC plane MEM2DEV
  signal dma_rcv_rdreq_int    : std_ulogic;
  signal dma_rcv_data_out_int : noc_flit_type;
  signal dma_rcv_empty_int    : std_ulogic;
  -- NoC plane DEV2MEM
  signal dma_snd_wrreq_int    : std_ulogic;
  signal dma_snd_data_in_int  : noc_flit_type;
  signal dma_snd_full_int     : std_ulogic;

begin

  pconfig <= (
    0 => ahb_device_reg (vendorid, devid, 0, revision, pirq),
    1 => apb_iobar(paddr, pmask),
    2 => apb_iobar(paddr_ext, pmask_ext));

  irq_info <= conv_std_logic_vector(pirq, RESERVED_WIDTH);

  apbi_paddr <= apbi.paddr and X"0FFFFFFF";

  -- Unused queues
  coherence_req_wrreq <= '0';
  coherence_req_data_in <= (others => '0');
  coherence_fwd_rdreq <= '0';
  coherence_rsp_rcv_rdreq <= '0';
  coherence_rsp_snd_wrreq <= '0';
  coherence_rsp_snd_data_in <= (others => '0');
  coherence_fwd_snd_wrreq <= '0';
  coherence_fwd_snd_data_in <= (others => '0');

  -- <<accelerator_instance>>

  -- <<axi_unused>>

  axi2noc_1: axislv2noc
    generic map (
      tech             => tech,
      nmst             => 1,
      retarget_for_dma => 1,
      mem_axi_port     => 0,
      mem_num          => CFG_NSLM_TILE + CFG_NSLMDDR_TILE + CFG_NMEM_TILE,
      mem_info         => nofb_mem_info,
      slv_y            => io_y,
      slv_x            => io_x)
    port map (
      rst                        => rst,
      clk                        => clk,
      local_y                    => local_y,
      local_x                    => local_x,
      mosi                       => mosi,
      somi                       => somi,
      coherence_req_wrreq        => dma_snd_wrreq_int,
      coherence_req_data_in      => dma_snd_data_in_int,
      coherence_req_full         => dma_snd_full_int,
      coherence_rsp_rcv_rdreq    => dma_rcv_rdreq_int,
      coherence_rsp_rcv_data_out => dma_rcv_data_out_int,
      coherence_rsp_rcv_empty    => dma_rcv_empty_int,
      remote_ahbs_snd_wrreq      => open,
      remote_ahbs_snd_data_in    => open,
      remote_ahbs_snd_full       => '0',
      remote_ahbs_rcv_rdreq      => open,
      remote_ahbs_rcv_data_out   => (others => '0'),
      remote_ahbs_rcv_empty      => '1',
      coherence                  => coherence);

  -- Coherence selection
  -- coherence <= conv_integer(bankreg(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));

  coherence_model_select: process (coherence,
                                   dma_snd_wrreq_int, dma_snd_data_in_int, dma_rcv_rdreq_int,
                                   dma_snd_full, dma_rcv_data_out, dma_rcv_empty,
                                   coherent_dma_snd_full, coherent_dma_rcv_data_out, coherent_dma_rcv_empty)
  begin -- process coherence_model_select

    if coherence = ACC_COH_LLC or coherence = ACC_COH_RECALL then
      coherent_dma_snd_wrreq    <= dma_snd_wrreq_int;
      coherent_dma_snd_data_in  <= dma_snd_data_in_int;
      dma_snd_full_int          <= coherent_dma_snd_full;
      coherent_dma_rcv_rdreq    <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int      <= coherent_dma_rcv_data_out;
      dma_rcv_empty_int         <= coherent_dma_rcv_empty;

      dma_rcv_rdreq   <= '0';
      dma_snd_wrreq   <= '0';
      dma_snd_data_in <= (others => '0');
    else
      dma_snd_wrreq        <= dma_snd_wrreq_int;
      dma_snd_data_in      <= dma_snd_data_in_int;
      dma_snd_full_int     <= dma_snd_full;
      dma_rcv_rdreq        <= dma_rcv_rdreq_int;
      dma_rcv_data_out_int <= dma_rcv_data_out;
      dma_rcv_empty_int    <= dma_rcv_empty;

      coherent_dma_snd_wrreq   <= '0';
      coherent_dma_snd_data_in <= (others => '0');
      coherent_dma_rcv_rdreq   <= '0';
    end if;
  end process coherence_model_select;

  apbo.pirq <= (others => '0');         -- IRQ forwarded to NoC directly
  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;

  -- IRQ packet
  irq_header_i <= create_header(MISC_NOC_FLIT_SIZE, local_y, local_x, io_y, io_x, INTERRUPT, irq_info)(MISC_NOC_FLIT_SIZE - 1 downto 0);
  irq_header(MISC_NOC_FLIT_SIZE-1 downto MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH) <= PREAMBLE_1FLIT;
  irq_header(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) <=
    irq_header_i(MISC_NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0);

 
  -- Interrupt over NoC
  irq_send: process (acc_done, interrupt_full, irq_state, irq_header,
                     interrupt_ack_empty, interrupt_ack_data_out)
  begin  -- process irq_send
    interrupt_data_in <= irq_header;
    interrupt_wrreq <= '0';
    interrupt_ack_rdreq <= '0';
    irq_next <= irq_state;

    case irq_state is
      when idle =>
        if acc_done = '1' then
          if interrupt_full = '1' then
            irq_next <= pending;
          else
            interrupt_wrreq <= '1';
            irq_next <= wait_for_clear_irq;
          end if;
        end if;

      when pending =>
        if interrupt_full = '0' then
          interrupt_wrreq <= '1';
          irq_next <= wait_for_clear_irq;
        end if;

      when wait_for_clear_irq =>
        if irq_type = 0 then
          if acc_done = '0' then
            irq_next <= idle;
          end if;
        else
          if interrupt_ack_empty = '0' then
            interrupt_ack_rdreq <= '1';
            if acc_done = '0' then
              irq_next <= idle;
            else
              if interrupt_full = '1' then
                irq_next <= pending;
              else
                interrupt_wrreq <= '1';
                irq_next <= wait_for_clear_irq;
              end if;
            end if;
          end if;

        end if;

      when others =>
        irq_next <= idle;

    end case;

  end process irq_send;

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      irq_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
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
    acc_next <= acc_current;

    case acc_current is

      when idle =>
        if mosi(0).ar.valid = '1' or mosi(0).aw.valid = '1' then
          acc_go <= '1';
          acc_next <= run;
        end if;

      when run =>
        acc_run <= '1';
        if acc_done = '1' then
          acc_next <= done;
        end if;

      when done =>
        if acc_done = '0' then
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
  mon_acc.burst <= mosi(0).w.valid or mosi(0).r.ready;

  -- No DVFS on this tile for now
  pllclk_int <= refclk;
  pllclk <= pllclk_int;

  mon_dvfs      <= monitor_dvfs_none;
  mon_cache     <= monitor_cache_none;

  mon_dvfs_feedthru.transient <= '0';

end rtl;
