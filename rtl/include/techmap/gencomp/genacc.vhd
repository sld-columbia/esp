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
-- Entity: 	genacc
-- File:	genacc.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description: SLD accelerators tech independent component declarations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package genacc is

  component wami_app_debayer_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_debayer_rtl;

  component wami_app_grayscale_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_grayscale_rtl;

  component wami_app_gradient_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_gradient_rtl;

  component wami_app_warp_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_warp_rtl;

  component wami_app_subtract_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_subtract_rtl;

  component wami_app_steepest_descent_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_steepest_descent_rtl;

  component wami_app_hessian_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_hessian_rtl;

  component wami_app_invert_gauss_jordan_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_invert_gauss_jordan_rtl;

  component wami_app_sd_update_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_sd_update_rtl;

  component wami_app_mult_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_mult_rtl;

  component wami_app_reshape_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_reshape_rtl;

  component wami_app_add_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_add_rtl;

  component wami_app_change_detection_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(327 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component wami_app_change_detection_rtl;

  component black_scholes_rtl is
    generic (
      tech : integer);
    port (
      clk                  : in  std_ulogic;
      rst                  : in  std_ulogic;
      conf_info            : in  std_logic_vector(287 downto 0);
      conf_done            : in  std_ulogic;
      dma_read_ctrl_valid  : out std_ulogic;
      dma_read_ctrl_ready  : in  std_ulogic;
      dma_read_ctrl_data   : out std_logic_vector(63 downto 0);
      dma_write_ctrl_valid : out std_ulogic;
      dma_write_ctrl_ready : in  std_ulogic;
      dma_write_ctrl_data  : out std_logic_vector(63 downto 0);
      dma_read_chnl_valid  : in std_ulogic;
      dma_read_chnl_ready  : out  std_ulogic;
      dma_read_chnl_data   : in std_logic_vector(31 downto 0);
      dma_write_chnl_valid : out std_ulogic;
      dma_write_chnl_ready : in  std_ulogic;
      dma_write_chnl_data  : out std_logic_vector(31 downto 0);
      kernel_done          : out std_ulogic);
  end component black_scholes_rtl;

  component sort_rtl is
    generic (
      tech : integer);
    port (
      clk                   : in  std_ulogic;
      rst                   : in  std_ulogic;
      rd_grant              : in  std_ulogic;
      wr_grant              : in  std_ulogic;
      conf_len              : in  std_logic_vector(31 downto 0);
      conf_batch            : in  std_logic_vector(31 downto 0);
      conf_done             : in  std_ulogic;
      bufdin_valid          : in  std_ulogic;
      bufdin_data           : in  std_logic_vector(31 downto 0);
      bufdin_ready          : out std_ulogic;
      bufdout_valid         : out std_ulogic;
      bufdout_data          : out std_logic_vector(31 downto 0);
      bufdout_ready         : in  std_ulogic;
      rd_index              : out std_logic_vector(31 downto 0);
      rd_length             : out std_logic_vector(31 downto 0);
      rd_request            : out std_ulogic;
      wr_index              : out std_logic_vector(31 downto 0);
      wr_length             : out std_logic_vector(31 downto 0);
      wr_request            : out std_ulogic;
      sort_done             : out std_ulogic);

  end component;

  component fft_rtl is
    generic (
      tech : integer);
    port (
      clk                   : in  std_ulogic;
      rst                   : in  std_ulogic;
      rd_grant              : in  std_ulogic;
      wr_grant              : in  std_ulogic;
      conf_len              : in  std_logic_vector(31 downto 0);
      conf_log_len          : in  std_logic_vector(31 downto 0);
      conf_done             : in  std_ulogic;
      bufdin_valid          : in  std_ulogic;
      bufdin_data           : in  std_logic_vector(31 downto 0);
      bufdin_ready          : out std_ulogic;
      bufdout_valid         : out std_ulogic;
      bufdout_data          : out std_logic_vector(31 downto 0);
      bufdout_ready         : in  std_ulogic;
      rd_index              : out std_logic_vector(31 downto 0);
      rd_length             : out std_logic_vector(31 downto 0);
      rd_request            : out std_ulogic;
      wr_index              : out std_logic_vector(31 downto 0);
      wr_length             : out std_logic_vector(31 downto 0);
      wr_request            : out std_ulogic;
      dft_done              : out std_ulogic);

  end component;

  component fft2d_rtl
    generic (
      tech : integer);
    port (
      clk            : in  std_ulogic;
      rst            : in  std_ulogic;
      rd_grant       : in  std_ulogic;
      wr_grant       : in  std_ulogic;
      conf_size      : in  std_logic_vector(31 downto 0);
      conf_log2      : in  std_logic_vector(31 downto 0);
      conf_batch     : in  std_logic_vector(31 downto 0);
      conf_transpose : in  std_ulogic;
      conf_done      : in  std_ulogic;
      bufdin_valid   : in  std_ulogic;
      bufdin_data    : in  std_logic_vector(31 downto 0);
      bufdin_ready   : out std_ulogic;
      bufdout_valid  : out std_ulogic;
      bufdout_data   : out std_logic_vector(31 downto 0);
      bufdout_ready  : in  std_ulogic;
      rd_index       : out std_logic_vector(31 downto 0);
      rd_length      : out std_logic_vector(31 downto 0);
      rd_request     : out std_ulogic;
      wr_index       : out std_logic_vector(31 downto 0);
      wr_length      : out std_logic_vector(31 downto 0);
      wr_request     : out std_ulogic;
      fft2d_done     : out std_ulogic);

  end component;


  component debayer_rtl
    generic (
      tech         : integer);
    port (
      clk          : in  std_ulogic;
      rst          : in  std_ulogic;
      rd_grant     : in  std_ulogic;
      wr_grant     : in  std_ulogic;
      conf_num_row : in  std_logic_vector(31 downto 0);
      conf_num_col : in  std_logic_vector(31 downto 0);
      conf_done    : in  std_ulogic;
      bufdin_valid : in std_ulogic; -- FIXME non used 
      bufdin_data  : in  std_logic_vector(31 downto 0);
      bufdin_ready : out std_ulogic;
      bufdout_valid : out std_ulogic;
      bufdout_data  : out std_logic_vector(31 downto 0);
      bufdout_ready : in std_ulogic; -- FIXME non used
      rd_index     : out std_logic_vector(31 downto 0);
      rd_length    : out std_logic_vector(31 downto 0);
      rd_request   : out std_ulogic;
      wr_index     : out std_logic_vector(31 downto 0);
      wr_length    : out std_logic_vector(31 downto 0);
      wr_request   : out std_ulogic;
      debayer_done     : out std_ulogic);
    
  end component;

  component change_detection_rtl
    generic (
      tech         : integer);
    port (
      clk          : in  std_ulogic;
      rst          : in  std_ulogic;
      rd_grant     : in  std_ulogic;
      wr_grant     : in  std_ulogic;
      conf_num_row : in  std_logic_vector(31 downto 0);
      conf_num_col : in  std_logic_vector(31 downto 0);
      conf_done    : in  std_ulogic;
      -- bufdin.GET()
      bufdin_valid : in std_ulogic; -- FIXME non used 
      bufdin_data  : in  std_logic_vector(31 downto 0);
      bufdin_ready : out std_ulogic;
      --bufdin       : in  std_logic_vector(31 downto 0);
      --bufen        : in  std_ulogic;
      -- bufdout.PUT()
      bufdout_valid : out std_ulogic;
      bufdout_data  : out std_logic_vector(31 downto 0);
      bufdout_ready : in std_ulogic; -- FIXME non used
      --bufwren      : in  std_ulogic;
      --bufdout      : out std_logic_vector(31 downto 0);
      rd_half      : out std_ulogic;
      rd_index     : out std_logic_vector(31 downto 0);
      rd_length     : out std_logic_vector(31 downto 0);
      rd_request   : out std_ulogic;
      wr_half      : out std_ulogic;
      wr_index     : out std_logic_vector(31 downto 0);
      wr_length    : out std_logic_vector(31 downto 0);
      wr_request   : out std_ulogic;
      change_detection_done     : out std_ulogic);
    
  end component;

  component lucas_kanade_rtl
    generic (
      tech         : integer);
    port (
      clk          : in  std_ulogic;
      rst          : in  std_ulogic;
      rd_grant     : in  std_ulogic;
      wr_grant     : in  std_ulogic;
      conf_num_row : in  std_logic_vector(31 downto 0);
      conf_num_col : in  std_logic_vector(31 downto 0);
      conf_done    : in  std_ulogic;
      -- bufdin.GET()
      bufdin_valid : in std_ulogic; -- FIXME non used 
      bufdin_data  : in  std_logic_vector(31 downto 0);
      bufdin_ready : out std_ulogic;
      --bufdin       : in  std_logic_vector(31 downto 0);
      --bufen        : in  std_ulogic;
      -- bufdout.PUT()
      bufdout_valid : out std_ulogic;
      bufdout_data  : out std_logic_vector(31 downto 0);
      bufdout_ready : in std_ulogic; -- FIXME non used
      --bufwren      : in  std_ulogic;
      --bufdout      : out std_logic_vector(31 downto 0);
      --rd_half      : out std_ulogic;
      rd_index     : out std_logic_vector(31 downto 0);
      rd_length     : out std_logic_vector(31 downto 0);
      rd_request   : out std_ulogic;
      --wr_half      : out std_ulogic;
      wr_index     : out std_logic_vector(31 downto 0);
      wr_length    : out std_logic_vector(31 downto 0);
      wr_request   : out std_ulogic;
      lucas_kanade_done     : out std_ulogic);
    
  end component;

  component pfa_interp1_rtl
    generic (
      tech : integer);
    port (
      clk                    : in  std_ulogic;
      rst                    : in  std_ulogic;
      rd_grant               : in  std_ulogic;
      wr_grant               : in  std_ulogic;
      conf_n_range           : in  std_logic_vector(11 downto 0);
      conf_n_pulses          : in  std_logic_vector(11 downto 0);
      conf_pfa_nout_range    : in  std_logic_vector(11 downto 0);
      conf_t_pfa             : in  std_logic_vector(3 downto 0);
      debug_conf_start_pulse : in  std_logic_vector(11 downto 0);
      debug_conf_pulse_count : in  std_logic_vector(11 downto 0);
      is_le                  : in  std_ulogic;
      conf_done              : in  std_ulogic;
      d_in_valid             : in  std_ulogic;
      d_in_data              : in  std_logic_vector(31 downto 0);
      d_in_ready             : out std_ulogic;
      d_out_valid            : out std_ulogic;
      d_out_data             : out std_logic_vector(31 downto 0);
      d_out_ready            : in  std_ulogic;
      rd_index               : out std_logic_vector(31 downto 0);
      rd_request             : out std_ulogic;
      rd_length              : out std_logic_vector(31 downto 0);
      wr_index               : out std_logic_vector(31 downto 0);
      wr_request             : out std_ulogic;
      wr_length              : out std_logic_vector(31 downto 0);
      task_done              : out std_ulogic);
  end component;

  component pfa_interp2_rtl
    generic (
      tech : integer);
    port (
      clk                    : in  std_ulogic;
      rst                    : in  std_ulogic;
      rd_grant               : in  std_ulogic;
      wr_grant               : in  std_ulogic;
      conf_n_pulses          : in  std_logic_vector(11 downto 0);
      conf_pfa_nout_range    : in  std_logic_vector(11 downto 0);
      conf_pfa_nout_azimuth  : in  std_logic_vector(11 downto 0);
      conf_t_pfa             : in  std_logic_vector(3 downto 0);
      debug_conf_start_range : in  std_logic_vector(11 downto 0);
      debug_conf_range_count : in  std_logic_vector(11 downto 0);
      is_le                  : in  std_ulogic;
      conf_done              : in  std_ulogic;
      d_in_valid             : in  std_ulogic;
      d_in_data              : in  std_logic_vector(31 downto 0);
      d_in_ready             : out std_ulogic;
      d_out_valid            : out std_ulogic;
      d_out_data             : out std_logic_vector(31 downto 0);
      d_out_ready            : in  std_ulogic;
      rd_index               : out std_logic_vector(31 downto 0);
      rd_request             : out std_ulogic;
      rd_length              : out std_logic_vector(31 downto 0);
      wr_index               : out std_logic_vector(31 downto 0);
      wr_request             : out std_ulogic;
      wr_length              : out std_logic_vector(31 downto 0);
      task_done              : out std_ulogic);
  end component;

  component backprojection_rtl
    generic (
      tech : integer);
    port (
      clk                           : in  std_ulogic;
      rst                           : in  std_ulogic;
      rd_grant                      : in  std_ulogic;
      wr_grant                      : in  std_ulogic;
      conf_n_range                  : in  std_logic_vector(11 downto 0);
      conf_n_pulses                 : in  std_logic_vector(11 downto 0);
      conf_range_upsample_factor    : in  std_logic_vector(3 downto 0);
      conf_bp_npix_x                : in  std_logic_vector(11 downto 0);
      conf_bp_npix_y                : in  std_logic_vector(11 downto 0);
      debug_conf_x_start            : in  std_logic_vector(11 downto 0);
      debug_conf_x_len              : in  std_logic_vector(11 downto 0);
      debug_conf_y_start            : in  std_logic_vector(11 downto 0);
      debug_conf_y_len              : in  std_logic_vector(11 downto 0);
      is_le                         : in  std_ulogic;
      conf_done                     : in  std_ulogic;
      d_in_valid                    : in  std_ulogic;
      d_in_data                     : in  std_logic_vector(31 downto 0);
      d_in_ready                    : out std_ulogic;
      d_out_valid                   : out std_ulogic;
      d_out_data                    : out std_logic_vector(31 downto 0);
      d_out_ready                   : in  std_ulogic;
      rd_index                      : out std_logic_vector(31 downto 0);
      rd_request                    : out std_ulogic;
      rd_length                     : out std_logic_vector(31 downto 0);
      wr_index                      : out std_logic_vector(31 downto 0);
      wr_request                    : out std_ulogic;
      wr_length                     : out std_logic_vector(31 downto 0);
      task_done                     : out std_ulogic);
  end component;

  component rbm_rtl
    generic (
      tech : integer);
    port (
      clk                          : in  std_ulogic;
      rst                          : in  std_ulogic;
      visible_rd_grant             : in  std_ulogic;
      visible_wr_grant             : in  std_ulogic;
      conf_num_hidden              : in  std_logic_vector(31 downto 0);
      conf_num_loops               : in  std_logic_vector(31 downto 0);
      conf_num_users               : in  std_logic_vector(31 downto 0);
      conf_num_movies              : in  std_logic_vector(31 downto 0);
      conf_num_testusers           : in  std_logic_vector(31 downto 0);
      conf_num_visible             : in  std_logic_vector(31 downto 0);
      conf_done                    : in  std_ulogic;
      data_in_valid                : in  std_ulogic;
      data_in_data                 : in  std_logic_vector(31 downto 0);
      data_in_ready                : out std_ulogic;
      result_out_valid             : out std_ulogic;
      result_out_data              : out std_logic_vector(31 downto 0);
      result_out_ready             : in  std_ulogic;
      visible_rd_index             : out std_logic_vector(31 downto 0);
      visible_rd_request           : out std_ulogic;
      visible_rd_length            : out std_logic_vector(31 downto 0);
      visible_wr_index             : out std_logic_vector(31 downto 0);
      visible_wr_request           : out std_ulogic;
      visible_wr_length            : out std_logic_vector(31 downto 0);
      rbm_done                     : out std_ulogic;
      rbm_train_done               : out std_ulogic);
  end component;

end;

