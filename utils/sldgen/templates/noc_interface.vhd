------------------------------------------------------------------------------
--  Copyright (C) 2015-2017, System Level Design (SLD) @ Columbia University
-----------------------------------------------------------------------------
-- <<header>>
-- Authors:     Paolo Mantovani
-- Description: NoC interface with DMA controller for accelerators
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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
    hls_conf       : hlscfg_t;
    tech           : integer;
    local_y        : local_yx;
    local_x        : local_yx;
    mem_num        : integer;
    mem_info       : tile_mem_info_vector;
    io_y           : local_yx;
    io_x           : local_yx;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#fff#;
    pirq           : integer := 0;
    scatter_gather : integer := 1;
    sets           : integer := 256;
    ways           : integer := 8;
    coherence      : integer := ACC_COH_NONE;
    cache_tile_id  : cache_attribute_array;
    has_dvfs       : integer := 1;
    has_pll        : integer;
    extra_clk_buf  : integer;
    local_apb_en   : std_logic_vector(NAPBSLV-1 downto 0));
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
    interrupt_data_in : out noc_flit_type;
    interrupt_full    : in  std_ulogic;
    -- Noc plane miscellaneous (tile -> NoC)
    apb_snd_wrreq     : out std_ulogic;
    apb_snd_data_in   : out noc_flit_type;
    apb_snd_full      : in  std_ulogic;
    -- Noc plane miscellaneous (NoC -> tile)
    apb_rcv_rdreq     : out std_ulogic;
    apb_rcv_data_out  : in  noc_flit_type;
    apb_rcv_empty     : in  std_ulogic;
    mon_dvfs_in       : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc           : out monitor_acc_type;
    mon_dvfs          : out monitor_dvfs_type
    );

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
    EXP_DO_REG         => '1',
    COHERENCE_REG      => '1',
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
    COHERENCE_REG      => conv_std_logic_vector(coherence, 32),
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

  -- Accelerator signals
  signal acc_rst                    : std_ulogic;
  signal conf_done                  : std_ulogic;
  signal dma_read_ctrl_valid        : std_ulogic;
  signal dma_read_ctrl_ready        : std_ulogic;
  signal dma_read_ctrl_data_index   : std_logic_vector(31 downto 0);
  signal dma_read_ctrl_data_length  : std_logic_vector(31 downto 0);
  signal dma_write_ctrl_valid       : std_ulogic;
  signal dma_write_ctrl_ready       : std_ulogic;
  signal dma_write_ctrl_data_index  : std_logic_vector(31 downto 0);
  signal dma_write_ctrl_data_length : std_logic_vector(31 downto 0);
  signal dma_read_chnl_valid        : std_ulogic;
  signal dma_read_chnl_ready        : std_ulogic;
  signal dma_read_chnl_data         : std_logic_vector(31 downto 0);
  signal dma_write_chnl_valid       : std_ulogic;
  signal dma_write_chnl_ready       : std_ulogic;
  signal dma_write_chnl_data        : std_logic_vector(31 downto 0);
  signal acc_done                   : std_ulogic;
  -- Register control, interrupt and monitor signals
  signal pllclk_int        : std_ulogic;
  signal apbi              : apb_slv_in_type;
  signal apbo              : apb_slv_out_vector;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

begin

  -- <<accelerator_instance>>

  -- Private cache
  fully_coherent_gen : if coherence = ACC_COH_FULL then
    l2_acc_wrapper_1: entity work.l2_acc_wrapper
      generic map (
        tech          => tech,
        sets          => sets,
        ways          => ways,
        coherence     => coherence,
        nslaves       => 1,
        noc_xlen      => noc_xlen,
        hindex_slv    => 0,
        hindex_mst    => 0,
        local_y       => local_y,
        local_x       => local_x,
        mem_num       => mem_num,
        mem_info      => mem_info,
        destination   => 0,
        l1_cache_en   => 0,
        cache_tile_id => cache_tile_id)
      port map (
        rst                        => rst,
        clk                        => clk,
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
        flush                      => acc_done,
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
        debug_led                  => debug_led);

    dma_rcv_ready <= dma_rcv_rdreq_int;
    dma_rcv_data_out_int <= dma_rcv_data;
    dma_rcv_empty_int <= not dma_rcv_valid;
    dma_snd_valid <= dma_snd_wrreq_int;
    dma_snd_data <= dma_snd_data_in_int;
    dma_snd_full_int <= not dma_snd_ready;

    -- DMA controller for NoC
    acc_dma2noc_1 : acc_dma2noc
      generic map (
        tech               => tech,
        extra_clk_buf      => extra_clk_buf,
        local_y            => local_y,
        local_x            => local_x,
        mem_num            => mem_num,
        mem_info           => mem_info,
        io_y               => io_y,
        io_x               => io_x,
        pindex             => pindex,
        paddr              => paddr,
        pmask              => pmask,
        pirq               => pirq,
        revision           => revision,
        devid              => devid,
        available_reg_mask => available_reg_mask,
        rdonly_reg_mask    => rdonly_reg_mask,
        exp_registers      => exp_registers,
        scatter_gather     => scatter_gather,
        tlb_entries        => tlb_entries,
        coherence          => coherence,
        has_dvfs           => has_dvfs,
        has_pll            => has_pll)
      port map (
        rst                  => rst,
        clk                  => clk,
        refclk               => refclk,
        pllbypass            => pllbypass,
        pllclk               => pllclk_int,
        apbi                 => apbi,
        apbo                 => apbo(pindex),
        bank                 => bank,
        bankdef              => bankdef,
        acc_rst              => acc_rst,
        conf_done            => conf_done,
        rd_request           => dma_read_ctrl_valid,
        rd_index             => dma_read_ctrl_data_index,
        rd_length            => dma_read_ctrl_data_length,
        rd_grant             => dma_read_ctrl_ready,
        bufdin_ready         => dma_read_chnl_ready,
        bufdin_data          => dma_read_chnl_data,
        bufdin_valid         => dma_read_chnl_valid,
        wr_request           => dma_write_ctrl_valid,
        wr_index             => dma_write_ctrl_data_index,
        wr_length            => dma_write_ctrl_data_length,
        wr_grant             => dma_write_ctrl_ready,
        bufdout_ready        => dma_write_chnl_ready,
        bufdout_data         => dma_write_chnl_data,
        bufdout_valid        => dma_write_chnl_valid,
        acc_done             => acc_done,
        mon_dvfs_in          => mon_dvfs_in,
        mon_dvfs             => mon_dvfs_feedthru,
        llc_coherent_dma_rcv_rdreq    => coherent_dma_rcv_rdreq,
        llc_coherent_dma_rcv_data_out => coherent_dma_rcv_data_out,
        llc_coherent_dma_rcv_empty    => coherent_dma_rcv_empty,
        llc_coherent_dma_snd_wrreq    => coherent_dma_snd_wrreq,
        llc_coherent_dma_snd_data_in  => coherent_dma_snd_data_in,
        llc_coherent_dma_snd_full     => coherent_dma_snd_full,
        coherent_dma_read    => dma_read,
        coherent_dma_write   => dma_write,
        coherent_dma_length  => dma_length,
        coherent_dma_address => dma_address,
        coherent_dma_ready   => dma_ready,
        dma_rcv_rdreq        => dma_rcv_rdreq_int,
        dma_rcv_data_out     => dma_rcv_data_out_int,
        dma_rcv_empty        => dma_rcv_empty_int,
        dma_snd_wrreq        => dma_snd_wrreq_int,
        dma_snd_data_in      => dma_snd_data_in_int,
        dma_snd_full         => dma_snd_full_int,
        interrupt_wrreq      => interrupt_wrreq,
        interrupt_data_in    => interrupt_data_in,
        interrupt_full       => interrupt_full
        );

    dma_rcv_rdreq <= '0';
    dma_snd_wrreq <= '0';
    dma_snd_data_in <= (others => '0');

  end generate fully_coherent_gen;

  non_fully_coherent_gen : if coherence_rsp_snd_full /= ACC_COH_FULL then
    -- DMA controller for NoC
    acc_dma2noc_1 : acc_dma2noc
      generic map (
        tech               => tech,
        extra_clk_buf      => extra_clk_buf,
        local_y            => local_y,
        local_x            => local_x,
        mem_num            => mem_num,
        mem_info           => mem_info,
        io_y               => io_y,
        io_x               => io_x,
        pindex             => pindex,
        paddr              => paddr,
        pmask              => pmask,
        pirq               => pirq,
        revision           => revision,
        devid              => devid,
        available_reg_mask => available_reg_mask,
        rdonly_reg_mask    => rdonly_reg_mask,
        exp_registers      => exp_registers,
        scatter_gather     => scatter_gather,
        tlb_entries        => tlb_entries,
        coherence          => coherence,
        has_dvfs           => has_dvfs,
        has_pll            => has_pll)
      port map (
        rst                  => rst,
        clk                  => clk,
        refclk               => refclk,
        pllbypass            => pllbypass,
        pllclk               => pllclk_int,
        apbi                 => apbi,
        apbo                 => apbo(pindex),
        bank                 => bank,
        bankdef              => bankdef,
        acc_rst              => acc_rst,
        conf_done            => conf_done,
        rd_request           => dma_read_ctrl_valid,
        rd_index             => dma_read_ctrl_data_index,
        rd_length            => dma_read_ctrl_data_length,
        rd_grant             => dma_read_ctrl_ready,
        bufdin_ready         => dma_read_chnl_ready,
        bufdin_data          => dma_read_chnl_data,
        bufdin_valid         => dma_read_chnl_valid,
        wr_request           => dma_write_ctrl_valid,
        wr_index             => dma_write_ctrl_data_index,
        wr_length            => dma_write_ctrl_data_length,
        wr_grant             => dma_write_ctrl_ready,
        bufdout_ready        => dma_write_chnl_ready,
        bufdout_data         => dma_write_chnl_data,
        bufdout_valid        => dma_write_chnl_valid,
        acc_done             => acc_done,
        mon_dvfs_in          => mon_dvfs_in,
        mon_dvfs             => mon_dvfs_feedthru,
        llc_coherent_dma_rcv_rdreq        => coherent_dma_rcv_rdreq,
        llc_coherent_dma_rcv_data_out     => coherent_dma_rcv_data_out,
        llc_coherent_dma_rcv_empty        => coherent_dma_rcv_empty,
        llc_coherent_dma_snd_wrreq        => coherent_dma_snd_wrreq,
        llc_coherent_dma_snd_data_in      => coherent_dma_snd_data_in,
        llc_coherent_dma_snd_full         => coherent_dma_snd_full,
        coherent_dma_read    => dma_read,
        coherent_dma_write   => dma_write,
        coherent_dma_length  => dma_length,
        coherent_dma_address => dma_address,
        coherent_dma_ready   => dma_ready,
        dma_rcv_rdreq        => dma_rcv_rdreq_int,
        dma_rcv_data_out     => dma_rcv_data_out_int,
        dma_rcv_empty        => dma_rcv_empty_int,
        dma_snd_wrreq        => dma_snd_wrreq_int,
        dma_snd_data_in      => dma_snd_data_in_int,
        dma_snd_full         => dma_snd_full_int,
        interrupt_wrreq      => interrupt_wrreq,
        interrupt_data_in    => interrupt_data_in,
        interrupt_full       => interrupt_full
        );

    dma_rcv_rdreq <= dma_rcv_rdreq_int;
    dma_rcv_data_out_int <= dma_rcv_data_out;
    dma_rcv_empty_int <= dma_rcv_empty;

    dma_snd_wrreq <= dma_snd_wrreq_int;
    dma_snd_data_in <= dma_snd_data_in_int;
    dma_snd_full_int <= dma_snd_full;

    dma_ready <= '0';

  end generate non_fully_coherent_gen;


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
  no_apb : for i in 0 to NAPBSLV-1 generate
    local_apb : if i /= pindex generate
      apbo(i)      <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  mon_acc.clk   <= pllclk_int; pllclk <= pllclk_int;
  mon_acc.go    <= bank(CMD_REG)(0);
  mon_acc.run   <= bank(STATUS_REG)(STATUS_BIT_RUN);
  mon_acc.done  <= bank(STATUS_REG)(STATUS_BIT_DONE);
  mon_acc.burst <= mon_dvfs_feedthru.burst;
  mon_dvfs      <= mon_dvfs_feedthru;

end rtl;
