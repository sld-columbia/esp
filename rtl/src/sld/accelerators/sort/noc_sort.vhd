------------------------------------------------------------------------------
--  Copyright (C) 2015, System Level Design (SLD) group @ Columbia University
-----------------------------------------------------------------------------
-- Package: noc_sort
-- File:    noc_sort.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description: NoC based SoC wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.sldcommon.all;

use work.acctypes.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity noc_sort is

  generic (
    tech         : integer := virtex7;
    local_y      : local_yx;
    local_x      : local_yx;
    mem_num         : integer;
    mem_info         : tile_mem_info_vector;
    io_y         : local_yx;
    io_x         : local_yx;
    pindex       : integer := 0;
    paddr        : integer := 0;
    pmask        : integer := 16#fff#;
    pirq         : integer := 0;
    scatter_gather : integer := 1;
    has_dvfs     : integer := 1;
    has_pll        : integer;
      extra_clk_buf  : integer;
    local_apb_en : std_logic_vector(NAPBSLV-1 downto 0));
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    refclk    : in  std_ulogic;
    pllbypass : in  std_ulogic;
    pllclk    : out std_ulogic;

    -- NoC4->tile
    dma_rcv_rdreq       : out std_ulogic;
    dma_rcv_data_out    : in  noc_flit_type;
    dma_rcv_empty       : in  std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq       : out std_ulogic;
    dma_snd_data_in     : out noc_flit_type;
    dma_snd_full        : in  std_ulogic;
    -- tile->NoC5
    interrupt_wrreq     : out std_ulogic;
    interrupt_data_in   : out noc_flit_type;
    interrupt_full      : in  std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq       : out std_ulogic;
    apb_snd_data_in     : out noc_flit_type;
    apb_snd_full        : in  std_ulogic;
    -- Noc5->tile
    apb_rcv_rdreq       : out std_ulogic;
    apb_rcv_data_out    : in  noc_flit_type;
    apb_rcv_empty       : in  std_ulogic;
    vdd_ivr   : in std_ulogic;
    vref      : out std_ulogic;
     mon_dvfs_in      : in  monitor_dvfs_type;
    --Monitor signals
    mon_acc           : out monitor_acc_type;
      mon_dvfs          : out monitor_dvfs_type



    );

end;

architecture rtl of noc_sort is

  -- Device ID and revision numner
  constant vendorid : vendor_t := VENDOR_SLD;
  constant devid : devid_t := SLD_SORT;
  constant revision : integer := 0;
  constant exp_registers : integer range 0 to 1 := 0;
  constant tlb_entries : integer := 4;  -- assuming 1MB chunks and largest input
  -- User defined registers
  -- bank(16): input vector length (number of float)
  constant SORT_LEN_REG : integer range 0 to MAXREGNUM - 1 := 16;

  -- bank(17): number of input vectors (sorted in batch)
  constant SORT_BATCH_REG : integer range 0 to MAXREGNUM - 1 := 17;

  -- bank(18): Minimum allowed length (32). Read Only
  constant SORT_LEN_MIN_REG : integer range 0 to MAXREGNUM - 1 := 18;

  -- bank(19): Maximum allowed length (1024). Read Only
  constant SORT_LEN_MAX_REG : integer range 0 to MAXREGNUM - 1 := 19;

  -- bank(20): Maximum allowed batch (1024). Read Only
  constant SORT_BATCH_MAX_REG : integer range 0 to MAXREGNUM - 1 := 20;

  -- Read only registers mask (lo: common; hi: user defined)
  constant rdonly_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (
    STATUS_REG => '1',
    DEVID_REG => '1',
    PT_NCHUNK_MAX_REG => '1',
    EXP_DO_REG => '1',
    SORT_LEN_MIN_REG => '1',
    SORT_LEN_MAX_REG => '1',
    SORT_BATCH_MAX_REG => '1',
    others => '0');
  -- Available registers mask (lo: common; hi: user defined)
  constant available_reg_mask  : std_logic_vector(0 to MAXREGNUM - 1):= (
    CMD_REG => '1',
    STATUS_REG => '1',
    SELECT_REG => '1',
    DEVID_REG => '1',
    PT_ADDRESS_REG => '1',
    PT_NCHUNK_REG => '1',
    PT_SHIFT_REG => '1',
    PT_NCHUNK_MAX_REG => '1',
    SRC_OFFSET_REG => '1',
    DST_OFFSET_REG => '1',
    SORT_LEN_REG => '1',
    SORT_BATCH_REG => '1',
    SORT_LEN_MIN_REG => '1',
    SORT_LEN_MAX_REG => '1',
    SORT_BATCH_MAX_REG => '1',
    others => '0');

  signal bank          : bank_type(0 to MAXREGNUM - 1);
  constant bankdef     : bank_type(0 to MAXREGNUM - 1) := (
    DEVID_REG => conv_std_logic_vector(vendorid, 16) & conv_std_logic_vector(devid, 16),
    PT_NCHUNK_MAX_REG => conv_std_logic_vector(tlb_entries, 32),
    SORT_LEN_MIN_REG => X"00000020",
    SORT_LEN_MAX_REG => X"00000400",
    SORT_BATCH_MAX_REG => X"00000400",
    others => (others => '0'));
  signal acc_rst       : std_ulogic;
  signal conf_done     : std_ulogic;
  signal rd_request    : std_ulogic;
  signal rd_index      : std_logic_vector(31 downto 0);
  signal rd_length     : std_logic_vector(31 downto 0);
  signal rd_grant      : std_ulogic;
  signal bufdin_ready  : std_ulogic;
  signal bufdin_data   : std_logic_vector(31 downto 0);
  signal bufdin_valid  : std_ulogic;
  signal wr_request    : std_ulogic;
  signal wr_index      : std_logic_vector(31 downto 0);
  signal wr_length     : std_logic_vector(31 downto 0);
  signal wr_grant      : std_ulogic;
  signal bufdout_ready : std_ulogic;
  signal bufdout_data  : std_logic_vector(31 downto 0);
  signal bufdout_valid : std_ulogic;
  signal acc_done      : std_ulogic;

  signal pllclk_int : std_ulogic;
  signal apbi : apb_slv_in_type;
  signal apbo : apb_slv_out_vector;
  signal mon_dvfs_feedthru : monitor_dvfs_type;

begin

  -- SORT instantiation
  sort_rtl_1: sort_rtl
    generic map (
      tech => tech)
    port map (
      clk           => clk,
      rst           => acc_rst,
      rd_grant      => rd_grant,
      wr_grant      => wr_grant,
      conf_len      => bank(SORT_LEN_REG),
      conf_batch    => bank(SORT_BATCH_REG),
      conf_done     => conf_done,
      bufdin_valid  => bufdin_valid,
      bufdin_data   => bufdin_data,
      bufdin_ready  => bufdin_ready,
      bufdout_valid => bufdout_valid,
      bufdout_data  => bufdout_data,
      bufdout_ready => bufdout_ready,
      rd_index      => rd_index,
      rd_length     => rd_length,
      rd_request    => rd_request,
      wr_index      => wr_index,
      wr_length     => wr_length,
      wr_request    => wr_request,
      sort_done     => acc_done);

-- boot message

-- pragma translate_off
  bootmsg : report_version
    generic map ("sld_sort_" & tost(pindex) &
                 ": " & "SORT Accelerator. Unit rev " & tost(revision));
-- pragma translate_on

  acc_dma2noc_1: acc_dma2noc
    generic map (
      tech                 => tech,
      extra_clk_buf        => extra_clk_buf,
      local_y              => local_y,
      local_x              => local_x,
      mem_num             => mem_num,
      mem_info             => mem_info,
      io_y                 => io_y,
      io_x                 => io_x,
      pindex               => pindex,
      paddr                => paddr,
      pmask                => pmask,
      pirq                 => pirq,
      revision             => revision,
      devid                => devid,
      available_reg_mask  => available_reg_mask,
      rdonly_reg_mask     => rdonly_reg_mask,
      exp_registers       => exp_registers,
      scatter_gather      => scatter_gather,
      tlb_entries         => tlb_entries,
      has_dvfs             => has_dvfs,
      has_pll             => has_pll)
    port map (
      rst               => rst,
      clk               => clk,
      refclk            => refclk,
      pllbypass         => pllbypass,
      pllclk            => pllclk_int,
      apbi              => apbi,
      apbo              => apbo(pindex),
      bank              => bank,
      bankdef           => bankdef,
      acc_rst           => acc_rst,
      conf_done         => conf_done,
      rd_request        => rd_request,
      rd_index          => rd_index,
      rd_length         => rd_length,
      rd_grant          => rd_grant,
      bufdin_ready      => bufdin_ready,
      bufdin_data       => bufdin_data,
      bufdin_valid      => bufdin_valid,
      wr_request        => wr_request,
      wr_index          => wr_index,
      wr_length         => wr_length,
      wr_grant          => wr_grant,
      bufdout_ready     => bufdout_ready,
      bufdout_data      => bufdout_data,
      bufdout_valid     => bufdout_valid,
      acc_done          => acc_done,
      mon_dvfs_in       => mon_dvfs_in,
      mon_dvfs          => mon_dvfs_feedthru,
      dma_rcv_rdreq     => dma_rcv_rdreq,
      dma_rcv_data_out  => dma_rcv_data_out,
      dma_rcv_empty     => dma_rcv_empty,
      dma_snd_wrreq     => dma_snd_wrreq,
      dma_snd_data_in   => dma_snd_data_in,
      dma_snd_full      => dma_snd_full,
      interrupt_wrreq   => interrupt_wrreq,
      interrupt_data_in => interrupt_data_in,
      interrupt_full    => interrupt_full,
      vdd_ivr           => vdd_ivr,
      vref              => vref);
  

  misc_noc2apb_1: misc_noc2apb
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
      apb_rcv_empty    => apb_rcv_empty);

  -- Using only one apbo signal
  no_apb: for i in 0 to NAPBSLV-1 generate
    local_apb: if i /= pindex generate
      apbo(i) <= apb_none;
      apbo(i).pirq <= (others => '0');
    end generate local_apb;
  end generate no_apb;

  mon_acc.clk <= pllclk_int; pllclk <= pllclk_int;
  mon_acc.go <= bank(CMD_REG)(0);
  mon_acc.run <= bank(STATUS_REG)(STATUS_BIT_RUN);
  mon_acc.done <= bank(STATUS_REG)(STATUS_BIT_DONE);
  mon_acc.burst <= mon_dvfs_feedthru.burst;
  mon_dvfs <= mon_dvfs_feedthru;

end rtl;
