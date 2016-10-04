------------------------------------------------------------------------------
--  Copyright (C) 2015, System Level Design (SLD) group @ Columbia University
-----------------------------------------------------------------------------
-- Package: bus_fft2d
-- File:    bus_fft2d.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description: Bus based SoC wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.sldacc.all;
use work.sldbus.all;

use work.acctypes.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity bus_fft2d is

  generic (
    tech     : integer := virtex5;
    hindex   : integer := 0;
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    pirq     : integer := 0;
    scatter_gather : integer := 1;
    memtech  : integer range 0 to NTECH := 0);

  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type
    );

end;

architecture rtl of bus_fft2d is

  -- Device ID and revision numner
  constant vendorid : amba_vendor_type := VENDOR_SLD;
  constant devid : amba_device_type := SLD_FFT2D;
  constant revision : integer := 0;
  constant exp_registers : integer range 0 to 1 := 0;
  constant tlb_entries : integer := 256;  -- assuming 1MB chunks, 1<<12 input
                                          -- size and non-in-place approach
  -- User defined registers
  -- bank(16): input vector length (number of float)
  constant FFT2D_LEN_REG : integer range 0 to MAXREGNUM - 1 := 16;

  -- bank(17): log2(LEN)
  constant FFT2D_LOG2_REG : integer range 0 to MAXREGNUM - 1 := 17;

  -- bank(18): Maximum allowed log2 (12). Read Only
  constant FFT2D_LOG2_MAX_REG : integer range 0 to MAXREGNUM - 1 := 18;

  -- bank(19): Batch or number of matrix rows; must be equal to LEN
  constant FFT2D_BATCH_REG : integer range 0 to MAXREGNUM - 1 := 19;

  -- bank(20): hardware transpose.
  --          "0" -> software transpose; need to be invoked 2 times
  --          "1" -> hardware transpose;
  constant FFT2D_TRANSPOSE_REG : integer range 0 to MAXREGNUM - 1 := 20;

  -- Read only registers mask (lo: common; hi: user defined)
  constant rdonly_reg_mask : std_logic_vector(0 to MAXREGNUM - 1) := (
    STATUS_REG => '1',
    DEVID_REG => '1',
    PT_NCHUNK_MAX_REG => '1',
    EXP_DO_REG => '1',
    FFT2D_LOG2_MAX_REG => '1',
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
    FFT2D_LEN_REG => '1',
    FFT2D_LOG2_REG => '1',
    FFT2D_LOG2_MAX_REG => '1',
    FFT2D_BATCH_REG => '1',
    FFT2D_TRANSPOSE_REG => '1',
    others => '0');

  signal bank          : bank_type(0 to MAXREGNUM - 1);
  constant bankdef     : bank_type(0 to MAXREGNUM - 1) := (
    DEVID_REG => conv_std_logic_vector(vendorid, 16) & conv_std_logic_vector(devid, 16),
    PT_NCHUNK_MAX_REG => conv_std_logic_vector(tlb_entries, 32),
    FFT2D_LOG2_MAX_REG => X"0000000c",
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

begin

  -- FFT2D instantiation
  fft2d_rtl_1: fft2d_rtl
    generic map (
      tech => tech)
    port map (
      clk            => clk,
      rst            => acc_rst,
      rd_grant       => rd_grant,
      wr_grant       => wr_grant,
      conf_size      => bank(FFT2D_LEN_REG),
      conf_log2      => bank(FFT2D_LOG2_REG),
      conf_batch     => bank(FFT2D_BATCH_REG),
      conf_transpose => bank(FFT2D_TRANSPOSE_REG)(0),
      conf_done      => conf_done,
      bufdin_valid   => bufdin_valid,
      bufdin_data    => bufdin_data,
      bufdin_ready   => bufdin_ready,
      bufdout_valid  => bufdout_valid,
      bufdout_data   => bufdout_data,
      bufdout_ready  => bufdout_ready,
      rd_index       => rd_index,
      rd_length      => rd_length,
      rd_request     => rd_request,
      wr_index       => wr_index,
      wr_length      => wr_length,
      wr_request     => wr_request,
      fft2d_done     => acc_done);

-- boot message

-- pragma translate_off
  bootmsg : report_version
    generic map ("sld_fft2d_" & tost(pindex) &
                 ": " & "FFT2D Accelerator. Unit rev " & tost(revision));
-- pragma translate_on

  acc_dma2bus_1: acc_dma2bus
    generic map (
      tech               => tech,
      hindex             => hindex,
      pindex             => pindex,
      paddr              => paddr,
      pmask              => pmask,
      pirq               => pirq,
      memtech            => memtech,
      revision           => revision,
      devid              => devid,
      available_reg_mask => available_reg_mask,
      rdonly_reg_mask    => rdonly_reg_mask,
      exp_registers       => exp_registers,
      scatter_gather      => scatter_gather,
      tlb_entries         => tlb_entries
      )
    port map (
      rst           => rst,
      clk           => clk,
      apbi          => apbi,
      apbo          => apbo,
      ahbi          => ahbi,
      ahbo          => ahbo,
      bank          => bank,
      bankdef       => bankdef,
      acc_rst       => acc_rst,
      conf_done     => conf_done,
      rd_request    => rd_request,
      rd_index      => rd_index,
      rd_length     => rd_length,
      rd_grant      => rd_grant,
      bufdin_ready  => bufdin_ready,
      bufdin_data   => bufdin_data,
      bufdin_valid  => bufdin_valid,
      wr_request    => wr_request,
      wr_index      => wr_index,
      wr_length     => wr_length,
      wr_grant      => wr_grant,
      bufdout_ready => bufdout_ready,
      bufdout_data  => bufdout_data,
      bufdout_valid => bufdout_valid,
      acc_done      => acc_done);

end rtl;
