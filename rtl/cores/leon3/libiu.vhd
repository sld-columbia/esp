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
-- Package:     libiu
-- File:        libiu.vhd
-- Author:      Jiri Gaisler Gaisler Research
-- Description: LEON3 IU types and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.leon3.all;
use work.libfpu.all;
use work.arith.all;
use work.mmuconfig.all;
use work.coretypes.all;

package libiu is

  constant RDBITS : integer := 32;
  constant IDBITS : integer := 32;

  subtype cword is std_logic_vector(IDBITS-1 downto 0);
  type cdatatype is array (0 to 3) of cword;


  type iregfile_in_type is record
     raddr1        : std_logic_vector(9 downto 0); -- read address 1
     raddr2        : std_logic_vector(9 downto 0); -- read address 2
     waddr         : std_logic_vector(9 downto 0); -- write address
     wdata         : std_logic_vector(31 downto 0); -- write data
     ren1          : std_ulogic;                    -- read 1 enable
     ren2          : std_ulogic;                    -- read 2 enable
     wren          : std_ulogic;                    -- write enable
  end record;

  type iregfile_out_type is record
     data1         : std_logic_vector(RDBITS-1 downto 0); -- read data 1
     data2         : std_logic_vector(RDBITS-1 downto 0); -- read data 2
  end record;


  type cctrltype is record
     burst  : std_ulogic;                          -- icache burst enable
     dfrz   : std_ulogic;                          -- dcache freeze enable
     ifrz   : std_ulogic;                          -- icache freeze enable
     dsnoop : std_ulogic;                          -- data cache snooping
     dcs    : std_logic_vector(1 downto 0);        -- dcache state
     ics    : std_logic_vector(1 downto 0);        -- icache state
  end record;
  
  constant cctrl_none : cctrltype := (
    burst => '0', dfrz => '0', ifrz => '0', dsnoop => '0',
    dcs => (others => '0'), ics => (others => '0')
    );
  
  type icache_in_type is record
     rpc              : std_logic_vector(31 downto 0); -- raw address (npc)
     fpc              : std_logic_vector(31 downto 0); -- latched address (fpc)
     dpc              : std_logic_vector(31 downto 0); -- latched address (dpc)
     rbranch          : std_ulogic;                        -- Instruction branch
     fbranch          : std_ulogic;                        -- Instruction branch
     inull            : std_ulogic;                        -- instruction nullify
     su               : std_ulogic;                        -- super-user
     flush            : std_ulogic;                        -- flush icache
     fline            : std_logic_vector(31 downto 3);     -- flush line offset
     nobpmiss         : std_ulogic;     -- Predicted instruction, block hold
  end record;

  type icache_out_type is record
     data             : cdatatype;
     set              : std_logic_vector(1 downto 0);
     mexc             : std_ulogic;
     hold             : std_ulogic;
     flush            : std_ulogic;                        -- flush in progress
     diagrdy          : std_ulogic;                        -- diagnostic access ready
     diagdata         : std_logic_vector(IDBITS-1 downto 0);-- diagnostic data
     mds              : std_ulogic;                        -- memory data strobe
     cfg              : std_logic_vector(31 downto 0);
     idle             : std_ulogic;                        -- idle mode
     cstat            : l3_cstat_type;
     bpmiss           : std_ulogic;
     eocl             : std_ulogic;
  end record;

  type icdiag_in_type is record
     addr             : std_logic_vector(31 downto 0); -- memory stage address
     enable           : std_ulogic;
     read             : std_ulogic;
     tag              : std_ulogic;
     ctx              : std_ulogic;
     flush            : std_ulogic;
     ilramen          : std_ulogic;
     cctrl            : cctrltype;
     pflush           : std_ulogic;
     pflushaddr       : std_logic_vector(VA_I_U downto VA_I_D); 
     pflushtyp        : std_ulogic;
  end record;

  type dcache_in_type is record
     asi              : std_logic_vector(7 downto 0); 
     maddress         : std_logic_vector(31 downto 0); 
     eaddress         : std_logic_vector(31 downto 0); 
     edata            : std_logic_vector(31 downto 0); 
     size             : std_logic_vector(1 downto 0);
     enaddr           : std_ulogic;
     eenaddr          : std_ulogic;
     nullify          : std_ulogic;
     lock             : std_ulogic;
     read             : std_ulogic;
     write            : std_ulogic;
     flush            : std_ulogic;
     flushl           : std_ulogic;                        -- flush line  
     dsuen            : std_ulogic;
     msu              : std_ulogic;                   -- memory stage supervisor
     esu              : std_ulogic;                   -- execution stage supervisor
     intack           : std_ulogic;
     mmucacheclr      : std_ulogic;
  end record;

  type dcache_out_type is record
     data             : cdatatype;
     set              : std_logic_vector(1 downto 0);
     mexc             : std_ulogic;
     hold             : std_ulogic;
     mds              : std_ulogic;
     werr             : std_ulogic;        
     icdiag           : icdiag_in_type;
     cache            : std_ulogic;
     idle             : std_ulogic;                        -- idle mode
     hit              : std_ulogic;
     cstat            : l3_cstat_type;
     wbhold           : std_ulogic;
  end record;

  component iu3
    generic (
      nwin    :     integer range 2 to 32    := 8;
      isets   :     integer range 1 to 4     := 1;
      dsets   :     integer range 1 to 4     := 1;
      fpu     :     integer range 0 to 15    := 0;
      v8      :     integer range 0 to 63    := 0;
      cp, mac :     integer range 0 to 1     := 0;
      dsu     :     integer range 0 to 1     := 0;
      nwp     :     integer range 0 to 4     := 0;
      pclow   :     integer range 0 to 2     := 2;
      notag   :     integer range 0 to 1     := 0;
      index   :     integer range 0 to 15    := 0;
      lddel   :     integer range 1 to 2     := 2;
      irfwt   :     integer range 0 to 1     := 0;
      disas   :     integer range 0 to 2     := 0;
      tbuf    :     integer range 0 to 128    := 0;  -- trace buf size in kB (0 - no trace buffer)
      pwd     :     integer range 0 to 2     := 0;  -- power-down    
      svt     :     integer range 0 to 1     := 0;  -- single-vector trapping
      rstaddr :     integer                  := 0;
      smp     :     integer range 0 to 15    := 0;  -- support SMP systems
      fabtech :     integer range 0 to NTECH := 0;
      clk2x   :     integer                  := 0;
      bp      :     integer                  := 1;
      npasi   :     integer range 0 to 1     := 0;
      pwrpsr  :     integer range 0 to 1     := 0;
      rex     :     integer                  := 0;
      altwin  :     integer range 0 to 1     := 0
      );
    port (
      clk     : in  std_ulogic;
      rstn    : in  std_ulogic;
      cpuid   : in  integer range 0 to 15:= 0;
      holdn   : in  std_ulogic;
      ici     : out icache_in_type;
      ico     : in  icache_out_type;
      dci     : out dcache_in_type;
      dco     : in  dcache_out_type;
      rfi     : out iregfile_in_type;
      rfo     : in  iregfile_out_type;
      irqi    : in  l3_irq_in_type;
      irqo    : out l3_irq_out_type;
      dbgi    : in  l3_debug_in_type;
      dbgo    : out l3_debug_out_type;
      muli    : out mul32_in_type;
      mulo    : in  mul32_out_type;
      divi    : out div32_in_type;
      divo    : in  div32_out_type;
      fpo     : in  fpc_out_type;
      fpi     : out fpc_in_type;
      cpo     : in  fpc_out_type;
      cpi     : out fpc_in_type;
      tbo     : in  tracebuf_out_type;
      tbi     : out tracebuf_in_type;
      tbo_2p  : in  tracebuf_2p_out_type;
      tbi_2p  : out tracebuf_2p_in_type;
      sclk    : in  std_ulogic
      );
  end component;

end;

