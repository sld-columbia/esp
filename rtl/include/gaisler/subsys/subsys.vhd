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
-- Package:     subsys
-- File:        subsys.vhd
-- Author:      Cobham Gaisler AB
-- Description: Package for GRLIB subsystems
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.gencomp.all;
use work.leon3.all;
use work.coretypes.all;

package subsys is

  type leon_dsu_stat_base_out_type is record
    dsu_active  : std_ulogic;
    dsu_tstop   : std_ulogic;
    proc_error  : std_ulogic;
    proc_errorn : std_ulogic;
  end record;

  type leon_dsu_stat_base_in_type is record
    dsu_enable : std_ulogic;
    dsu_break  : std_ulogic;
  end record;

  component leon_dsu_stat_base
  generic (
    -- LEON selection
    leon        : integer range 0 to 4 := 0;
    ncpu        : integer range 1 to 16 := 1;
    -- LEON configuration
    fabtech     : integer range 0 to NTECH  := DEFFABTECH;
    memtech     : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows    : integer range 2 to 32 := 8;
    dsu         : integer range 0 to 1  := 0;
    fpu         : integer range 0 to 63 := 0;
    v8          : integer range 0 to 63 := 0;
    cp          : integer range 0 to 1  := 0;
    mac         : integer range 0 to 1  := 0;
    pclow       : integer range 0 to 2  := 2;
    notag       : integer range 0 to 1  := 0;
    nwp         : integer range 0 to 4  := 0;
    icen        : integer range 0 to 1  := 0;
    irepl       : integer range 0 to 2  := 2;
    isets       : integer range 1 to 4  := 1;
    ilinesize   : integer range 4 to 8  := 4;
    isetsize    : integer range 1 to 256 := 1;
    isetlock    : integer range 0 to 1  := 0;
    dcen        : integer range 0 to 1  := 0;
    drepl       : integer range 0 to 2  := 2;
    dsets       : integer range 1 to 4  := 1;
    dlinesize   : integer range 4 to 8  := 4;
    dsetsize    : integer range 1 to 256 := 1;
    dsetlock    : integer range 0 to 1  := 0;
    dsnoop      : integer range 0 to 7  := 0;
    ilram       : integer range 0 to 1 := 0;
    ilramsize   : integer range 1 to 512 := 1;
    ilramstart  : integer range 0 to 255 := 16#8e#;
    dlram       : integer range 0 to 1 := 0;
    dlramsize   : integer range 1 to 512 := 1;
    dlramstart  : integer range 0 to 255 := 16#8f#;
    mmuen       : integer range 0 to 1  := 0;
    itlbnum     : integer range 2 to 64 := 8;
    dtlbnum     : integer range 2 to 64 := 8;
    tlb_type    : integer range 0 to 3  := 1;
    tlb_rep     : integer range 0 to 1  := 0;
    lddel       : integer range 1 to 2  := 2;
    disas       : integer range 0 to 2  := 0;
    tbuf        : integer range 0 to 128 := 0;
    pwd         : integer range 0 to 2  := 2;     -- power-down
    svt         : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr     : integer               := 0;
    smp         : integer range 0 to 31 := 0;     -- support SMP systems
    cached      : integer               := 0;	-- cacheability table
    clk2x       : integer               := 0;
    wbmask      : integer               := 0;    -- Wide-bus mask
    busw        : integer               := 64;   -- AHB/Cache data width (64/128)
    netlist     : integer               := 0;    -- Use netlist
    ft          : integer               := 0;    -- FT option
    npasi       : integer range 0 to 1  := 0;
    pwrpsr      : integer range 0 to 1  := 0;
    rex         : integer range 0 to 1  := 0;
    altwin      : integer range 0 to 1  := 0;
    ahbpipe     : integer := 0;
    --
    grfpush     : integer range 0 to 1 := 0;
    -- DSU
    dsu_hindex  : integer := 2;
    dsu_haddr   : integer := 16#900#;
    dsu_hmask   : integer := 16#F00#;
    atbsz       : integer := 4;
    --
    stat        : integer range 0 to 1 := 0;
    stat_pindex : integer := 0;
    stat_paddr  : integer := 0;
    stat_pmask  : integer := 16#ffc#;
    stat_ncnt   : integer := 1;
    stat_nmax   : integer := 0
    --
    );
  port (
    rstn                : in  std_ulogic;
    --
    ahbclk              : in  std_ulogic;    -- bus clock
    cpuclk              : in  std_ulogic;    -- cpu clock
    hclken              : in  std_ulogic;    -- bus clock enable qualifier
    -- 
    leon_ahbmi          : in  ahb_mst_in_type;
    leon_ahbmo          : out ahb_mst_out_vector_type(ncpu-1 downto 0);
    leon_ahbsi          : in  ahb_slv_in_type;
    leon_ahbso          : in  ahb_slv_out_vector;
    --
    irqi                : in  irq_in_vector(0 to ncpu-1);
    irqo                : out irq_out_vector(0 to ncpu-1);
    --
    stat_apbi           : in  apb_slv_in_type;
    stat_apbo           : out apb_slv_out_type;
    stat_ahbsi          : in  ahb_slv_in_type;
    stati               : in  l3stat_in_type;
    --
    dsu_ahbsi           : in  ahb_slv_in_type;
    dsu_ahbso           : out ahb_slv_out_type;
    dsu_tahbmi          : in  ahb_mst_in_type;
    dsu_tahbsi          : in  ahb_slv_in_type;
    --
    sysi                : in  leon_dsu_stat_base_in_type;
    syso                : out leon_dsu_stat_base_out_type
   );
  end component;

end;
  
package body subsys is

end;
