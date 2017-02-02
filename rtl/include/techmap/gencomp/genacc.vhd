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


end;

