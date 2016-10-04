------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity: 	sldacc
-- File:	sldacc.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description: SLD accelerators package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;

use work.acctypes.all;

use work.sldcommon.all;
use work.nocpackage.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

package sldacc is

  component noc_sort
    generic (
      tech         : integer;
      local_y      : local_yx;
      local_x      : local_yx;
      mem_num         : integer;
      mem_info         : tile_mem_info_vector;
      io_y         : local_yx;
      io_x         : local_yx;
      pindex       : integer;
      paddr        : integer;
      pmask        : integer;
      pirq         : integer;
      scatter_gather : integer := 1;
      has_dvfs     : integer := 1;
      has_pll        : integer;
      extra_clk_buf  : integer;
      local_apb_en : std_logic_vector(NAPBSLV-1 downto 0));
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      refclk    : in  std_ulogic;
      pllbypass : in  std_ulogic;
      pllclk    : out std_ulogic;
      dma_rcv_rdreq     : out std_ulogic;
      dma_rcv_data_out  : in  noc_flit_type;
      dma_rcv_empty     : in  std_ulogic;
      dma_snd_wrreq     : out std_ulogic;
      dma_snd_data_in   : out noc_flit_type;
      dma_snd_full      : in  std_ulogic;
      interrupt_wrreq   : out std_ulogic;
      interrupt_data_in : out noc_flit_type;
      interrupt_full    : in  std_ulogic;
      apb_snd_wrreq     : out std_ulogic;
      apb_snd_data_in   : out noc_flit_type;
      apb_snd_full      : in  std_ulogic;
      apb_rcv_rdreq     : out std_ulogic;
      apb_rcv_data_out  : in  noc_flit_type;
      apb_rcv_empty     : in  std_ulogic;
      vdd_ivr   : in std_ulogic;
      vref      : out std_ulogic;
      mon_dvfs_in       : in  monitor_dvfs_type;
      --Monitor signals
      mon_acc           : out monitor_acc_type;
      mon_dvfs          : out monitor_dvfs_type
      );
  end component;

  component noc_fft
    generic (
      tech         : integer;
      local_y      : local_yx;
      local_x      : local_yx;
      mem_num         : integer;
      mem_info         : tile_mem_info_vector;
      io_y         : local_yx;
      io_x         : local_yx;
      pindex       : integer;
      paddr        : integer;
      pmask        : integer;
      pirq         : integer;
      scatter_gather : integer := 1;
      has_dvfs     : integer := 1;
      has_pll        : integer;
      extra_clk_buf  : integer;
      local_apb_en : std_logic_vector(NAPBSLV-1 downto 0));
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      refclk            : in  std_ulogic;
      pllbypass         : in  std_ulogic;
      pllclk            : out std_ulogic;
      dma_rcv_rdreq     : out std_ulogic;
      dma_rcv_data_out  : in  noc_flit_type;
      dma_rcv_empty     : in  std_ulogic;
      dma_snd_wrreq     : out std_ulogic;
      dma_snd_data_in   : out noc_flit_type;
      dma_snd_full      : in  std_ulogic;
      interrupt_wrreq   : out std_ulogic;
      interrupt_data_in : out noc_flit_type;
      interrupt_full    : in  std_ulogic;
      apb_snd_wrreq     : out std_ulogic;
      apb_snd_data_in   : out noc_flit_type;
      apb_snd_full      : in  std_ulogic;
      apb_rcv_rdreq     : out std_ulogic;
      apb_rcv_data_out  : in  noc_flit_type;
      apb_rcv_empty     : in  std_ulogic;
      vdd_ivr   : in std_ulogic;
      vref      : out std_ulogic;
      mon_dvfs_in       : in  monitor_dvfs_type;
      --Monitor signals
      mon_acc           : out monitor_acc_type;
      mon_dvfs          : out monitor_dvfs_type
      );
  end component;

  component noc_fft2d
    generic (
      tech         : integer;
      local_y      : local_yx;
      local_x      : local_yx;
      mem_num         : integer;
      mem_info         : tile_mem_info_vector;
      io_y         : local_yx;
      io_x         : local_yx;
      pindex       : integer;
      paddr        : integer;
      pmask        : integer;
      pirq         : integer;
      scatter_gather : integer := 1;
      has_dvfs     : integer := 1;
      has_pll        : integer;
      extra_clk_buf  : integer;
      local_apb_en : std_logic_vector(NAPBSLV-1 downto 0));
    port (
      rst               : in  std_ulogic;
      clk               : in  std_ulogic;
      refclk            : in  std_ulogic;
      pllbypass         : in  std_ulogic;
      pllclk            : out std_ulogic;
      dma_rcv_rdreq     : out std_ulogic;
      dma_rcv_data_out  : in  noc_flit_type;
      dma_rcv_empty     : in  std_ulogic;
      dma_snd_wrreq     : out std_ulogic;
      dma_snd_data_in   : out noc_flit_type;
      dma_snd_full      : in  std_ulogic;
      interrupt_wrreq   : out std_ulogic;
      interrupt_data_in : out noc_flit_type;
      interrupt_full    : in  std_ulogic;
      apb_snd_wrreq     : out std_ulogic;
      apb_snd_data_in   : out noc_flit_type;
      apb_snd_full      : in  std_ulogic;
      apb_rcv_rdreq     : out std_ulogic;
      apb_rcv_data_out  : in  noc_flit_type;
      apb_rcv_empty     : in  std_ulogic;
      vdd_ivr   : in std_ulogic;
      vref      : out std_ulogic;
      mon_dvfs_in       : in  monitor_dvfs_type;
      --Monitor signals
      mon_acc           : out monitor_acc_type;
      mon_dvfs          : out monitor_dvfs_type
      );
  end component;


end sldacc;
