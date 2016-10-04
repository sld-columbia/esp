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
-- Description: SLD accelerators tech dependent instantiation
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allacc.all;

use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity sort_rtl is

  generic (
    tech : integer);

  port (
    clk           : in  std_ulogic;
    rst           : in  std_ulogic;
    rd_grant      : in  std_ulogic;
    wr_grant      : in  std_ulogic;
    conf_len      : in  std_logic_vector(31 downto 0);
    conf_batch    : in  std_logic_vector(31 downto 0);
    conf_done     : in  std_ulogic;
    bufdin_valid  : in  std_ulogic;
    bufdin_data   : in  std_logic_vector(31 downto 0);
    bufdin_ready  : out std_ulogic;
    bufdout_valid : out std_ulogic;
    bufdout_data  : out std_logic_vector(31 downto 0);
    bufdout_ready : in  std_ulogic;
    rd_index      : out std_logic_vector(31 downto 0);
    rd_length     : out std_logic_vector(31 downto 0);
    rd_request    : out std_ulogic;
    wr_index      : out std_logic_vector(31 downto 0);
    wr_length     : out std_logic_vector(31 downto 0);
    wr_request    : out std_ulogic;
    sort_done     : out std_ulogic);

end sort_rtl;

architecture mapping of sort_rtl is

begin  -- mapping

  xv7: if tech = virtex7 generate
    sort_unisim_rtl_1: sort_top_unisim_rtl
      port map (
        clk           => clk,
        rst           => rst,
        rd_grant      => rd_grant,
        wr_grant      => wr_grant,
        conf_len      => conf_len,
        conf_batch    => conf_batch,
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
        sort_done     => sort_done);
  end generate xv7;

-- pragma translate_off
  nosort : if (has_sort(tech) = 0) generate
    x : process
    begin
      assert false
        report  "Current technology does not provide HW sort implementation"
        severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end mapping;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allacc.all;

use work.config.all;
use work.config_types.all;
use work.stdlib.all;


entity fft_rtl is

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

end fft_rtl;

architecture mapping of fft_rtl is

begin  -- map

  xv7: if tech = virtex7 generate
    fft_unisim_rtl_1: fft_top_unisim_rtl
      port map (
        clk           => clk,
        rst           => rst,
        rd_grant      => rd_grant,
        wr_grant      => wr_grant,
        conf_len      => conf_len,
        conf_log_len  => conf_log_len,
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
        dft_done      => dft_done);
  end generate xv7;

-- pragma translate_off
  nofft : if (has_fft(tech) = 0) generate
    x : process
    begin
      assert false
        report  "Current technology does not provide HW fft implementation"
        severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end mapping;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allacc.all;

use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity fft2d_rtl is

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

end fft2d_rtl;

architecture mapping of fft2d_rtl is

begin  -- mapping

  xv7: if tech = virtex7 generate
    fft2d_unisim_rtl_1: fft2d_top_unisim_rtl
      port map (
        clk            => clk,
        rst            => rst,
        rd_grant       => rd_grant,
        wr_grant       => wr_grant,
        conf_size      => conf_size,
        conf_log2      => conf_log2,
        conf_batch     => conf_batch,
        conf_transpose => conf_transpose,
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
        fft2d_done     => fft2d_done);
  end generate xv7;

-- pragma translate_off
  nofft2d : if (has_fft2d(tech) = 0) generate
    x : process
    begin
      assert false
        report  "Current technology does not provide HW fft-2d implementation"
        severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end mapping;
