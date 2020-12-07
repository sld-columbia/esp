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
-- Entity:      leon3cg
-- File:        leon3cg.vhd
-- Author:      Jan Andersson, Aeroflex Gaisler
-- Description: Top-level LEON3 component with clock gating
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;
use work.leon3.all;
use work.coretypes.all;

entity leon3cg is
  generic (
    hindex     :     integer                  := 0;
    fabtech    :     integer range 0 to NTECH := DEFFABTECH;
    memtech    :     integer                  := DEFMEMTECH;
    nwindows   :     integer range 2 to 32    := 8;
    dsu        :     integer range 0 to 1     := 0;
    fpu        :     integer range 0 to 31    := 0;
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
    dsnoop     :     integer range 0 to 6     := 0;
    ilram      :     integer range 0 to 1     := 0;
    ilramsize  :     integer range 1 to 512   := 1;
    ilramstart :     integer range 0 to 255   := 16#8e#;
    dlram      :     integer range 0 to 1     := 0;
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
    pwd        :     integer range 0 to 2     := 2;  -- power-down
    svt        :     integer range 0 to 1     := 1;  -- single vector trapping
    rstaddr    :     integer                  := 0;
    smp        :     integer range 0 to 15    := 0;  -- support SMP systems
    cached     :     integer                  := 0;  -- cacheability table
    scantest   :     integer                  := 0;
    mmupgsz    :     integer range 0 to 5     := 0;
    bp         :     integer                  := 1;
    npasi      :     integer range 0 to 1     := 0;
    pwrpsr     :     integer range 0 to 1     := 0;
    rex        :     integer range 0 to 1     := 0;
    altwin     :     integer range 0 to 1     := 0
    );
  port (
    clk        : in  std_ulogic;        -- AHB clock (free-running)
    rstn       : in  std_ulogic;
    cpuid      : in  integer range 0 to 15:= 0;
    ahbi       : in  ahb_mst_in_type;
    ahbo       : out ahb_mst_out_type;
    ahbsi      : in  ahb_slv_in_type;
    ahbso      : in  ahb_slv_out_vector;
    dflush     : out std_ulogic;
    irqi       : in  l3_irq_in_type;
    irqo       : out l3_irq_out_type;
    dbgi       : in  l3_debug_in_type;
    dbgo       : out l3_debug_out_type;
    gclk       : in  std_ulogic         -- gated clock
    );
end; 

architecture rtl of leon3cg is

  signal gnd, vcc : std_logic;
  signal fpuo : grfpu_out_type;
  
begin

  gnd <= '0'; vcc <= '1';
  fpuo <= grfpu_out_none;
  
  leon3x0 : leon3x
    generic map (
      hindex     => hindex,
      fabtech    => fabtech,
      memtech    => memtech,
      nwindows   => nwindows,
      dsu        => dsu,
      fpu        => fpu,
      v8         => v8,
      cp         => cp,
      mac        => mac, 
      pclow      => pclow,
      notag      => notag,
      nwp        => nwp,
      icen       => icen,
      irepl      => irepl,
      isets      => isets,
      ilinesize  => ilinesize,
      isetsize   => isetsize,
      isetlock   => isetlock,
      dcen       => dcen,
      drepl      => drepl,
      dsets      => dsets,
      dlinesize  => dlinesize,
      dsetsize   => dsetsize,
      dsetlock   => dsetlock,
      dsnoop     => dsnoop, 
      ilram      => ilram,
      ilramsize  => ilramsize,
      ilramstart => ilramstart,
      dlram      => dlram,
      dlramsize  => dlramsize,
      dlramstart => dlramstart,
      mmuen      => mmuen,
      itlbnum    => itlbnum, 
      dtlbnum    => dtlbnum,
      tlb_type   => tlb_type,
      tlb_rep    => tlb_rep,
      lddel      => lddel,
      disas      => disas, 
      tbuf       => tbuf,
      pwd        => pwd,
      svt        => svt,
      rstaddr    => rstaddr, 
      smp        => smp,
      iuft       => 0,
      fpft       => 0,
      cmft       => 0,
      iuinj      => 0,
      ceinj      => 0,
      cached     => cached,
      clk2x      => 0,
      netlist    => 0,
      scantest   => scantest,
      mmupgsz    => mmupgsz,
      bp         => bp,
      npasi      => npasi,
      pwrpsr     => pwrpsr,
      rex        => rex,
      altwin     => altwin)
    port map (
      clk        => gnd,
      gclk2      => gclk,
      gfclk2     => clk,
      clk2       => clk,
      rstn       => rstn,
      cpuid      => cpuid,
      ahbi       => ahbi,
      ahbo       => ahbo,
      ahbsi      => ahbsi,
      ahbso      => ahbso,
      irqi       => irqi,
      irqo       => irqo,
      dbgi       => dbgi,
      dbgo       => dbgo,
      fpui       => open,
      fpuo       => fpuo,
      dflush     => dflush,
      clken      => vcc
      );

end;

