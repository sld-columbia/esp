-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.nocpackage.all;
use work.allcaches.all;
use work.cachepackage.all;
use work.tile.all;
use work.genacc.all;
use work.esp_acc_regmap.all;

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

  -- Device ID and revision numner
  constant vendorid      : vendor_t               := VENDOR_SLD;
  constant revision      : integer                := 0;
  constant exp_registers : integer range 0 to 1   := 0;
  -- <<devid>>
  -- <<tlb_entries>>

  -- User defined registers
  -- <<user_registers>>

  -- Read only registers mask (lo: common; hi: user defined)
  constant rdonly_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (
    STATUS_REG         => '1',
    DEVID_REG          => '1',
    PT_NCHUNK_MAX_REG  => '1',
    -- EXP_DO_REG         => '1', -- uncomment if re-enabling regs for SRAM
                                  -- expansion to reg bank
    YX_REG             => '1',
    -- <<user_read_only>>
    others             => '0');
  -- Available registers mask (lo: common; hi: user defined)
  constant available_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (
    CMD_REG            => '1',
    STATUS_REG         => '1',
    SELECT_REG         => '1',
    DEVID_REG          => '1',
    PT_ADDRESS_REG     => '1',
    PT_NCHUNK_REG      => '1',
    PT_SHIFT_REG       => '1',
    PT_NCHUNK_MAX_REG  => '1',
    SRC_OFFSET_REG     => '1',
    DST_OFFSET_REG     => '1',
    COHERENCE_REG      => '1',
    P2P_REG            => '1',
    YX_REG             => '1',
    SPANDEX_REG        => '1',
    -- <<user_mask>>
    others             => '0');

  function check_scatter_gather (
    constant entries : integer)
    return integer is
    variable ret : integer;
  begin  -- mem_offset
    if scatter_gather = 1 then
      ret := entries;
    else
      ret := 0;
    end if;
    return ret;
  end check_scatter_gather;

  signal bank : bank_type(0 to MAXREGNUM - 1);
  constant bankdef : bank_type(0 to MAXREGNUM - 1) := (
    DEVID_REG          => conv_std_logic_vector(vendorid, 16) & conv_std_logic_vector(devid, 16),
    PT_NCHUNK_MAX_REG  => conv_std_logic_vector(check_scatter_gather(tlb_entries), 32),
    YX_REG             => (others => '0'),
    -- <<user_read_only_default>>
    others             => (others => '0'));

  -- DMA queues
  signal dma_read             : std_ulogic;
  signal dma_write            : std_ulogic;
  signal dma_length           : addr_t;
  signal dma_address          : addr_t;
  signal dma_ready            : std_ulogic;
  signal dma_rcv_rdreq_int    : std_ulogic;
  signal dma_rcv_data_out_int : noc_flit_type;
  signal dma_rcv_empty_int    : std_ulogic;
  signal dma_snd_wrreq_int    : std_ulogic;
  signal dma_snd_data_in_int  : noc_flit_type;
  signal dma_snd_full_int     : std_ulogic;
  signal dma_rcv_ready        : std_ulogic;
  signal dma_rcv_data         : noc_flit_type;
  signal dma_rcv_valid        : std_ulogic;
  signal dma_snd_valid        : std_ulogic;
  signal dma_snd_data         : noc_flit_type;
  signal dma_snd_ready        : std_ulogic;

  --signal acc_dvfs_transient   : std_ulogic;

  -- Accelerator signals
  signal acc_rst                    : std_ulogic;
  signal conf_done                  : std_ulogic;
  signal dma_read_ctrl_valid        : std_ulogic;
  signal dma_read_ctrl_ready        : std_ulogic;
  signal dma_read_ctrl_data_index   : std_logic_vector(31 downto 0);
  signal dma_read_ctrl_data_length  : std_logic_vector(31 downto 0);
  signal dma_read_ctrl_data_size    : std_logic_vector(2 downto 0);
  signal dma_write_ctrl_valid       : std_ulogic;
  signal dma_write_ctrl_ready       : std_ulogic;
  signal dma_write_ctrl_data_index  : std_logic_vector(31 downto 0);
  signal dma_write_ctrl_data_length : std_logic_vector(31 downto 0);
  signal dma_write_ctrl_data_size   : std_logic_vector(2 downto 0);
  signal dma_read_chnl_valid        : std_ulogic;
  signal dma_read_chnl_ready        : std_ulogic;
  signal dma_read_chnl_data         : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal dma_write_chnl_valid       : std_ulogic;
  signal dma_write_chnl_ready       : std_ulogic;
  signal dma_write_chnl_data        : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal acc_done                   : std_ulogic;
  signal flush                      : std_ulogic;
  signal acc_flush_done             : std_ulogic;
  -- Register control, interrupt and monitor signals
  signal pllclk_int        : std_ulogic;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

  constant ahbslv_proxy_hindex : hindex_vector(0 to NAHBSLV - 1) := (
    others => 0);

  constant cacheable_mem_info : tile_mem_info_vector(0 to MEM_ID_RANGE_MSB) := mem_info(0 to MEM_ID_RANGE_MSB);

  -- add attribute 'keep' to fix a bug with Vivado HLS accelerators
  attribute keep : string;

  attribute keep of dma_read : signal is "true";
  attribute keep of dma_write : signal is "true";
  attribute keep of dma_length : signal is "true";
  attribute keep of dma_address : signal is "true";
  attribute keep of dma_ready : signal is "true";
  attribute keep of dma_rcv_rdreq_int : signal is "true";
  attribute keep of dma_rcv_data_out_int : signal is "true";
  attribute keep of dma_rcv_empty_int : signal is "true";
  attribute keep of dma_snd_wrreq_int : signal is "true";
  attribute keep of dma_snd_data_in_int : signal is "true";
  attribute keep of dma_snd_full_int : signal is "true";
  attribute keep of dma_rcv_ready : signal is "true";
  attribute keep of dma_rcv_data : signal is "true";
  attribute keep of dma_rcv_valid : signal is "true";
  attribute keep of dma_snd_valid : signal is "true";
  attribute keep of dma_snd_data : signal is "true";
  attribute keep of dma_snd_ready : signal is "true";
  attribute keep of acc_rst : signal is "true";
  attribute keep of conf_done : signal is "true";
  attribute keep of dma_read_ctrl_valid : signal is "true";
  attribute keep of dma_read_ctrl_ready : signal is "true";
  attribute keep of dma_read_ctrl_data_index : signal is "true";
  attribute keep of dma_read_ctrl_data_length : signal is "true";
  attribute keep of dma_read_ctrl_data_size : signal is "true";
  attribute keep of dma_write_ctrl_valid : signal is "true";
  attribute keep of dma_write_ctrl_ready : signal is "true";
  attribute keep of dma_write_ctrl_data_index : signal is "true";
  attribute keep of dma_write_ctrl_data_length : signal is "true";
  attribute keep of dma_write_ctrl_data_size : signal is "true";
  attribute keep of dma_read_chnl_valid : signal is "true";
  attribute keep of dma_read_chnl_ready : signal is "true";
  attribute keep of dma_read_chnl_data : signal is "true";
  attribute keep of dma_write_chnl_valid : signal is "true";
  attribute keep of dma_write_chnl_ready : signal is "true";
  attribute keep of dma_write_chnl_data : signal is "true";
  attribute keep of acc_done : signal is "true";
  attribute keep of flush : signal is "true";
  attribute keep of pllclk_int : signal is "true";

begin

  interrupt_ack_rdreq <= '0';
  
  -- <<accelerator_instance>>

  l2_gen: if has_l2 /= 0 generate
    -- Private cache
    l2_acc_wrapper_1: l2_acc_wrapper
      generic map (
        tech          => tech,
        sets          => sets,
        ways          => ways,
        little_end    => little_end,
        mem_num       => cacheable_mem_num,
        mem_info      => cacheable_mem_info,
        cache_y       => cache_y,
        cache_x       => cache_x,
        cache_tile_id => cache_tile_id)
      port map (
        rst                        => rst,
        clk                        => clk,
        local_y                    => local_y,
        local_x                    => local_x,
        tile_id                    => tile_id,
        dma_read                   => dma_read,
        dma_write                  => dma_write,
        dma_length                 => dma_length,
        dma_address                => dma_address,
        dma_ready                  => dma_ready,
        dma_rcv_ready              => dma_rcv_ready,
        dma_rcv_data               => dma_rcv_data,
        dma_rcv_valid              => dma_rcv_valid,
        dma_snd_valid              => dma_snd_valid,
        dma_snd_data               => dma_snd_data,
        dma_snd_ready              => dma_snd_ready,
        flush                      => flush,
        aq                         => conf_done,
        rl                         => acc_done,
        spandex_conf               => bank(SPANDEX_REG),
        acc_flush_done             => acc_flush_done,
        coherence_req_wrreq        => coherence_req_wrreq,
        coherence_req_data_in      => coherence_req_data_in,
        coherence_req_full         => coherence_req_full,
        coherence_fwd_rdreq        => coherence_fwd_rdreq,
        coherence_fwd_data_out     => coherence_fwd_data_out,
        coherence_fwd_empty        => coherence_fwd_empty,
        coherence_rsp_rcv_rdreq    => coherence_rsp_rcv_rdreq,
        coherence_rsp_rcv_data_out => coherence_rsp_rcv_data_out,
        coherence_rsp_rcv_empty    => coherence_rsp_rcv_empty,
        coherence_rsp_snd_wrreq    => coherence_rsp_snd_wrreq,
        coherence_rsp_snd_data_in  => coherence_rsp_snd_data_in,
        coherence_rsp_snd_full     => coherence_rsp_snd_full,
        coherence_fwd_snd_wrreq    => coherence_fwd_snd_wrreq,
        coherence_fwd_snd_data_in  => coherence_fwd_snd_data_in,
        coherence_fwd_snd_full     => coherence_fwd_snd_full,
        mon_cache                  => mon_cache);
  end generate l2_gen;

  no_l2_gen : if has_l2 = 0 generate
    dma_ready <= '0';
    dma_rcv_data <= (others => '0');
    dma_rcv_valid <= '0';
    dma_snd_ready <= '0';
    coherence_req_wrreq <= '0';
    coherence_req_data_in <= (others => '0');
    coherence_fwd_rdreq <= '0';
    coherence_rsp_rcv_rdreq <= '0';
    coherence_rsp_snd_wrreq <= '0';
    coherence_rsp_snd_data_in <= (others => '0');
    coherence_fwd_snd_wrreq <= '0';
    coherence_fwd_snd_data_in <= (others => '0');
    mon_cache <= monitor_cache_none;
  end generate no_l2_gen;


  -- DMA controller for NoC
  esp_acc_dma_1 : esp_acc_dma
    generic map (
      tech               => tech,
      extra_clk_buf      => extra_clk_buf,
      mem_num            => mem_num,
      mem_info           => mem_info,
      io_y               => io_y,
      io_x               => io_x,
      pindex             => pindex,
      revision           => revision,
      devid              => devid,
      available_reg_mask => available_reg_mask,
      rdonly_reg_mask    => rdonly_reg_mask,
      exp_registers      => exp_registers,
      scatter_gather     => scatter_gather,
      tlb_entries        => tlb_entries,
      has_dvfs           => has_dvfs,
      has_pll            => has_pll)
    port map (
      rst                           => rst,
      clk                           => clk,
      local_y                       => local_y,
      local_x                       => local_x,
      paddr                         => paddr,
      pmask                         => pmask,
      pirq                          => pirq,
      apbi                          => apbi,
      apbo                          => apbo,
      bank                          => bank,
      bankdef                       => bankdef,
      acc_rst                       => acc_rst,
      conf_done                     => conf_done,
      rd_request                    => dma_read_ctrl_valid,
      rd_index                      => dma_read_ctrl_data_index,
      rd_length                     => dma_read_ctrl_data_length,
      rd_size                       => dma_read_ctrl_data_size,
      rd_grant                      => dma_read_ctrl_ready,
      bufdin_ready                  => dma_read_chnl_ready,
      bufdin_data                   => dma_read_chnl_data,
      bufdin_valid                  => dma_read_chnl_valid,
      wr_request                    => dma_write_ctrl_valid,
      wr_index                      => dma_write_ctrl_data_index,
      wr_length                     => dma_write_ctrl_data_length,
      wr_size                       => dma_write_ctrl_data_size,
      wr_grant                      => dma_write_ctrl_ready,
      bufdout_ready                 => dma_write_chnl_ready,
      bufdout_data                  => dma_write_chnl_data,
      bufdout_valid                 => dma_write_chnl_valid,
      acc_done                      => acc_done,
      flush                         => flush,
      acc_flush_done                => acc_flush_done,
      mon_dvfs_in                   => mon_dvfs_in,
      mon_dvfs                      => mon_dvfs_feedthru,
      dvfs_transient_in             => dvfs_transient_acc,
      llc_coherent_dma_rcv_rdreq    => coherent_dma_rcv_rdreq,
      llc_coherent_dma_rcv_data_out => coherent_dma_rcv_data_out,
      llc_coherent_dma_rcv_empty    => coherent_dma_rcv_empty,
      llc_coherent_dma_snd_wrreq    => coherent_dma_snd_wrreq,
      llc_coherent_dma_snd_data_in  => coherent_dma_snd_data_in,
      llc_coherent_dma_snd_full     => coherent_dma_snd_full,
      coherent_dma_read             => dma_read,
      coherent_dma_write            => dma_write,
      coherent_dma_length           => dma_length,
      coherent_dma_address          => dma_address,
      coherent_dma_ready            => dma_ready,
      dma_rcv_rdreq                 => dma_rcv_rdreq_int,
      dma_rcv_data_out              => dma_rcv_data_out_int,
      dma_rcv_empty                 => dma_rcv_empty_int,
      dma_snd_wrreq                 => dma_snd_wrreq_int,
      dma_snd_data_in               => dma_snd_data_in_int,
      dma_snd_full                  => dma_snd_full_int,
      interrupt_wrreq               => interrupt_wrreq,
      interrupt_data_in             => interrupt_data_in,
      interrupt_full                => interrupt_full
      );

  pready <= '1';

  -- Fully coherent (to L2 wrapper)
  dma_snd_data         <= dma_snd_data_in_int;

  -- Non coherent (to NoC)
  dma_snd_data_in      <= dma_snd_data_in_int;

  -- From Noc or l2 wrapper to DMA
  coherence_model_select: process (bank, dma_rcv_data, dma_rcv_valid, dma_snd_ready,
                                   dma_rcv_data_out, dma_rcv_empty, dma_snd_full,
                                   dma_rcv_rdreq_int, dma_snd_wrreq_int) is
    variable coherence : integer range 0 to ACC_COH_FULL;
  begin  -- process coherence_model_select
    coherence := conv_integer(bank(COHERENCE_REG)(COH_T_LOG2 - 1 downto 0));
    if coherence = ACC_COH_FULL then
      dma_rcv_data_out_int <= dma_rcv_data;
      dma_rcv_empty_int    <= not dma_rcv_valid;
      dma_snd_full_int     <= not dma_snd_ready;

      dma_rcv_ready        <= dma_rcv_rdreq_int;
      dma_snd_valid        <= dma_snd_wrreq_int;
    else
      dma_rcv_data_out_int <= dma_rcv_data_out;
      dma_rcv_empty_int    <= dma_rcv_empty;
      dma_snd_full_int     <= dma_snd_full;

      dma_rcv_ready        <= '0';
      dma_snd_valid        <= '0';
    end if;

    if coherence = ACC_COH_NONE then
      dma_rcv_rdreq        <= dma_rcv_rdreq_int;
      dma_snd_wrreq        <= dma_snd_wrreq_int;
    else
      dma_rcv_rdreq        <= '0';
      dma_snd_wrreq        <= '0';
    end if;

  end process coherence_model_select;

  mon_acc.clk   <= pllclk_int; 
  mon_acc.go    <= bank(CMD_REG)(0);
  mon_acc.run   <= bank(STATUS_REG)(STATUS_BIT_RUN);
  mon_acc.done  <= bank(STATUS_REG)(STATUS_BIT_DONE);
  mon_acc.burst <= mon_dvfs_feedthru.burst;
  mon_dvfs      <= mon_dvfs_feedthru;

end rtl;
