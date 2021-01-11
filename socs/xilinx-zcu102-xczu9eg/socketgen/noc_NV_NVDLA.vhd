-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
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

entity noc_NV_NVDLA is

  generic (
    hls_conf       : hlscfg_t;
    tech           : integer;
    mem_num        : integer;
    cacheable_mem_num : integer;
    mem_info       : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE);
    io_y           : local_yx;
    io_x           : local_yx;
    pindex         : integer := 0;
    irq_type       : integer := 0;
    scatter_gather : integer := 1;
    sets           : integer := 256;
    ways           : integer := 8;
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
    mon_dvfs          : out monitor_dvfs_type
    );

end;

architecture rtl of noc_NV_NVDLA is

  -- AXI4 Master
  signal mosi : axi_mosi_vector(0 to 0);
  signal somi : axi_somi_vector(0 to 0);

  -- Plug&Play info
  constant vendorid      : vendor_t               := VENDOR_SLD;
  constant revision      : integer                := 0;
  constant devid         : devid_t                := SLD_NV_NVDLA;
  signal pconfig : apb_config_type;
  signal apbi_paddr : std_logic_vector(31 downto 0);

  -- IRQ
  type irq_fsm is (idle, pending, wait_for_clear_irq);
  signal irq_state, irq_next : irq_fsm;
  signal irq_header_i, irq_header : misc_noc_flit_type;
  signal irq_info : std_logic_vector(3 downto 0);

  -- Other signals
  signal acc_go : std_ulogic;
  signal acc_run : std_ulogic;
  signal acc_done : std_ulogic;
  type acc_state_t is (idle, run, done);
  signal acc_current, acc_next : acc_state_t;

  -- DVFS (unused for now)
  signal pllclk_int        : std_ulogic;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

  constant nofb_mem_info : tile_mem_info_vector(0 to CFG_NSLM_TILE + CFG_NMEM_TILE - 1) := mem_info(0 to CFG_NSLM_TILE + CFG_NMEM_TILE - 1);

begin

  pconfig <= (
    0 => ahb_device_reg (vendorid, devid, 0, revision, pirq),
    1 => apb_iobar(paddr, pmask),
    2 => apb_iobar(paddr_ext, pmask_ext));

  irq_info <= conv_std_logic_vector(pirq, 4);

  apbi_paddr <= apbi.paddr and X"0FFFFFFF";

  NV_NVDLA_rlt_i: NV_NVDLA_wrapper
    port map(
      dla_core_clk => clk,
      dla_csb_clk => clk,
      dla_reset_rstn => rst,
      direct_reset => rst,
      psel => apbi.psel(pindex),
      penable => apbi.penable,
      paddr => apbi_paddr,
      pwrite => apbi.pwrite,
      pwdata => apbi.pwdata,
      prdata => apbo.prdata,
      pready => pready,
      pslverr => open, -- TODO: handle APB3 error
      nvdla_core2dbb_awid => mosi(0).aw.id(8 - 1 downto 0),
      nvdla_core2dbb_awaddr => mosi(0).aw.addr(32 - 1 downto 0),
      nvdla_core2dbb_awlen => mosi(0).aw.len,
      nvdla_core2dbb_awsize => mosi(0).aw.size,
      nvdla_core2dbb_awburst => mosi(0).aw.burst,
      nvdla_core2dbb_awlock => mosi(0).aw.lock,
      nvdla_core2dbb_awcache => mosi(0).aw.cache,
      nvdla_core2dbb_awprot => mosi(0).aw.prot,
      nvdla_core2dbb_awvalid => mosi(0).aw.valid,
      nvdla_core2dbb_awqos => mosi(0).aw.qos,
      nvdla_core2dbb_awatop => mosi(0).aw.atop,
      nvdla_core2dbb_awregion => mosi(0).aw.region,
      nvdla_core2dbb_awready => somi(0).aw.ready,
      nvdla_core2dbb_wdata => mosi(0).w.data,
      nvdla_core2dbb_wstrb => mosi(0).w.strb,
      nvdla_core2dbb_wlast => mosi(0).w.last,
      nvdla_core2dbb_wvalid => mosi(0).w.valid,
      nvdla_core2dbb_wready => somi(0).w.ready,
      nvdla_core2dbb_arid  => mosi(0).ar.id(8 - 1 downto 0) ,
      nvdla_core2dbb_araddr => mosi(0).ar.addr(32 - 1 downto 0),
      nvdla_core2dbb_arlen => mosi(0).ar.len,
      nvdla_core2dbb_arsize => mosi(0).ar.size,
      nvdla_core2dbb_arburst => mosi(0).ar.burst,
      nvdla_core2dbb_arlock => mosi(0).ar.lock,
      nvdla_core2dbb_arcache => mosi(0).ar.cache,
      nvdla_core2dbb_arprot => mosi(0).ar.prot,
      nvdla_core2dbb_arvalid => mosi(0).ar.valid,
      nvdla_core2dbb_arqos => mosi(0).ar.qos,
      nvdla_core2dbb_arregion => mosi(0).ar.region,
      nvdla_core2dbb_arready => somi(0).ar.ready,
      nvdla_core2dbb_rready => mosi(0).r.ready,
      nvdla_core2dbb_rid => somi(0).r.id(8 - 1 downto 0),
      nvdla_core2dbb_rdata => somi(0).r.data,
      nvdla_core2dbb_rresp => somi(0).r.resp,
      nvdla_core2dbb_rlast => somi(0).r.last,
      nvdla_core2dbb_rvalid => somi(0).r.valid,
      nvdla_core2dbb_bready => mosi(0).b.ready,
      nvdla_core2dbb_bid => somi(0).b.id(8 - 1 downto 0),
      nvdla_core2dbb_bresp => somi(0).b.resp,
      nvdla_core2dbb_bvalid => somi(0).b.valid,
      dla_intr => acc_done
    );

  pad_id_gen : if XID_WIDTH > 8 generate
    mosi(0).aw.id(XID_WIDTH - 1 downto 8) <= (others => '0');
    mosi(0).ar.id(XID_WIDTH - 1 downto 8) <= (others => '0');
  end generate;
  pad_paddr_gen : if GLOB_PHYS_ADDR_BITS > 32 generate
    mosi(0).aw.addr(GLOB_PHYS_ADDR_BITS - 1 downto 32) <= (others => '0');
    mosi(0).ar.addr(GLOB_PHYS_ADDR_BITS - 1 downto 32) <= (others => '0');
  end generate;
  pad_user_gen : if XUSER_WIDTH > 0 generate
    mosi(0).aw.user(XUSER_WIDTH - 1 downto 0) <= (others => '0');
    mosi(0).w.user(XUSER_WIDTH - 1 downto 0) <= (others => '0');
    mosi(0).ar.user(XUSER_WIDTH - 1 downto 0) <= (others => '0');
  end generate;

  -- Unused queues
  coherence_req_wrreq <= '0';
  coherence_req_data_in <= (others => '0');
  coherence_fwd_rdreq <= '0';
  coherence_rsp_rcv_rdreq <= '0';
  coherence_rsp_snd_wrreq <= '0';
  coherence_rsp_snd_data_in <= (others => '0');

  coherent_dma_rcv_rdreq <= '0';
  coherent_dma_snd_wrreq <= '0';
  coherent_dma_snd_data_in <= (others => '0');

  axi2noc_1: axislv2noc
    generic map (
      tech             => tech,
      nmst             => 1,
      retarget_for_dma => 1,
      mem_axi_port     => 0,
      mem_num          => CFG_NSLM_TILE + CFG_NMEM_TILE,
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
      remote_ahbs_rcv_empty      => '1');

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
