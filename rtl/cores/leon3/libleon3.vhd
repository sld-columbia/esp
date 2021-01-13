------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
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
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package:     libleon3
-- File:        libleon3.vhd
-- Author:      Jiri Gaisler Gaisler Research
-- Description: LEON3 internal components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;
use work.leon3.all;
use work.libiu.all;
use work.libcache.all;
use work.libfpu.all;
use work.mmuiface.all;
use work.coretypes.all;

package libleon3 is

  component proc3
    generic (
      hindex     :     integer                  := 0;
      fabtech    :     integer range 0 to NTECH := 0;
      memtech    :     integer                  := 0;
      nwindows   :     integer range 2 to 32    := 8;
      dsu        :     integer range 0 to 1     := 0;
      fpu        :     integer range 0 to 15    := 0;
      v8         :     integer range 0 to 63    := 0;
      cp         :     integer range 0 to 1     := 0;
      mac        :     integer range 0 to 1     := 0;
      pclow      :     integer range 0 to 2     := 2;
      notag      :     integer range 0 to 1     := 0;
      nwp        :     integer range 0 to 4     := 0;
      icen       :     integer range 0 to 1     := 0;
      irepl      :     integer range 0 to 3     := 2;
      isets      :     integer range 1 to 4     := 1;
      ilinesize  :     integer range 4 to 8     := 4;
      isetsize   :     integer range 1 to 256   := 1;
      isetlock   :     integer range 0 to 1     := 0;
      dcen       :     integer range 0 to 1     := 0;
      drepl      :     integer range 0 to 3     := 2;
      dsets      :     integer range 1 to 4     := 1;
      dlinesize  :     integer range 4 to 8     := 4;
      dsetsize   :     integer range 1 to 256   := 1;
      dsetlock   :     integer range 0 to 1     := 0;
      dsnoop     :     integer range 0 to 7     := 0;
      ilram      :     integer range 0 to 2     := 0;
      ilramsize  :     integer range 1 to 512   := 1;
      ilramstart :     integer range 0 to 255   := 16#8e#;
      dlram      :     integer range 0 to 2     := 0;
      dlramsize  :     integer range 1 to 512   := 1;
      dlramstart :     integer range 0 to 255   := 16#8f#;
      mmuen      :     integer range 0 to 1     := 0;
      itlbnum    :     integer range 2 to 64    := 8;
      dtlbnum    :     integer range 2 to 64    := 8;
      tlb_type   :     integer range 0 to 3     := 1;
      tlb_rep    :     integer range 0 to 1     := 0;
      lddel      :     integer range 1 to 2     := 2;
      disas      :     integer range 0 to 2     := 0;
      tbuf       :     integer range 0 to 128    := 0;
      pwd        :     integer range 0 to 2     := 0;  -- power-down
      svt        :     integer range 0 to 1     := 0;  -- single-vector trapping
      rstaddr    :     integer                  := 0;
      smp        :     integer range 0 to 15    := 0;  -- support SMP systems
      cached     :     integer                  := 0;
      clk2x      :     integer                  := 0;
      scantest   :     integer                  := 0;
      mmupgsz    :     integer range 0 to 5     := 0;
      bp         :     integer                  := 1;
      npasi      :     integer range 0 to 1     := 0;
      pwrpsr     :     integer range 0 to 1     := 0;
      rex        :     integer                  := 0;
      altwin     :     integer range 0 to 1     := 0
      );
    port (
      clk        : in  std_ulogic;
      rstn       : in  std_ulogic;
      cpuid      : in  integer range 0 to 15:= 0;
      holdn      : out std_ulogic;
      ahbi       : in  ahb_mst_in_type;
      ahbo       : out ahb_mst_out_type;
      ahbsi      : in  ahb_slv_in_type;
      ahbso      : in  ahb_slv_out_vector;
      rfi        : out iregfile_in_type;
      rfo        : in  iregfile_out_type;
      crami      : out cram_in_type;
      cramo      : in  cram_out_type;
      tbi        : out tracebuf_in_type;
      tbo        : in  tracebuf_out_type;
      tbi_2p     : out tracebuf_2p_in_type;
      tbo_2p     : in  tracebuf_2p_out_type;
      fpi        : out fpc_in_type;
      fpo        : in  fpc_out_type;
      cpi        : out fpc_in_type;
      cpo        : in  fpc_out_type;
      irqi       : in  l3_irq_in_type;
      irqo       : out l3_irq_out_type;
      dbgi       : in  l3_debug_in_type;
      dbgo       : out l3_debug_out_type;
      hclk, sclk : in  std_ulogic;
      hclken     : in  std_ulogic
      );
  end component;

  component grfpwx
    generic (
      fabtech :     integer              := 0;
      memtech :     integer              := 0;
      mul     :     integer range 0 to 3 := 0;
      pclow   :     integer range 0 to 2 := 2;
      dsu     :     integer range 0 to 1 := 0;
      disas   :     integer range 0 to 2 := 0;
      netlist :     integer              := 0;
      index   :     integer              := 0;
      scantest:     integer              := 0);
    port (
      rst     : in  std_ulogic;         -- Reset
      clk     : in  std_ulogic;
      holdn   : in  std_ulogic;         -- pipeline hold
      cpi     : in  fpc_in_type;
      cpo     : out fpc_out_type;
      testin  : in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
      );
  end component;

  component grlfpwx
    generic (
      tech    :     integer              := 0;
      pclow   :     integer range 0 to 2 := 2;
      dsu     :     integer range 0 to 1 := 0;
      disas   :     integer range 0 to 2 := 0;
      pipe    :     integer              := 0;
      netlist :     integer              := 0;
      index   :     integer              := 0;
      scantest:     integer              := 0
      );
    port (
      rst   : in  std_ulogic;           -- Reset
      clk   : in  std_ulogic;
      holdn : in  std_ulogic;           -- pipeline hold
      cpi   : in  fpc_in_type;
      cpo   : out fpc_out_type;
      testin: in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
      );
  end component;


  component regfile_3p_l3
    generic (
      tech :     integer := 0;
      abits   :     integer := 6;
      dbits   :     integer := 8;
      wrfst   :     integer := 0;
      numregs :     integer := 64;
      testen  :     integer := 0);
    port (
      wclk    : in  std_ulogic;
      waddr   : in  std_logic_vector((abits -1) downto 0);
      wdata   : in  std_logic_vector((dbits -1) downto 0);
      we      : in  std_ulogic;
      rclk    : in  std_ulogic;
      raddr1  : in  std_logic_vector((abits -1) downto 0);
      re1     : in  std_ulogic;
      rdata1  : out std_logic_vector((dbits -1) downto 0);
      raddr2  : in  std_logic_vector((abits -1) downto 0);
      re2     : in  std_ulogic;
      rdata2  : out std_logic_vector((dbits -1) downto 0);
      testin  : in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
      );
  end component;

end;

