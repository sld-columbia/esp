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
-- Entity:      leon_dsu_stat_base
-- File:        leon_dsu_stat_base.vhd
-- Author:      Cobham Gaisler AB
-- Description: Entity that instantiates LEON3 together with the
--              corresponding debug support unit and performance counters.
--
-- Limitations:
--
--  Primarly targeted for FPGA designs and for designs without clock gating
--  since the same clock feeds all instantiated blocks.
--
--  Memory BIST signals are not propagated to the top-level
--
--  Scan test is disabled
--
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.coretypes.all;
use work.leon3.all;
use work.subsys.all;


entity leon_dsu_stat_base is
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
end;

architecture rtl of leon_dsu_stat_base is

  signal fpi : grfpu_in_vector_type;
  signal fpo : grfpu_out_vector_type;

  signal vcc : std_ulogic;

begin

  vcc <= '1';

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------

  l3 : if leon = 3 generate
    leon3blk : block
      signal l3dbgi : l3_debug_in_vector(0 to ncpu-1);
      signal l3dbgo : l3_debug_out_vector(0 to ncpu-1);
      signal l3dsui : dsu_in_type;
      signal l3dsuo : dsu_out_type;
    begin
      cpu : for i in 0 to ncpu-1 generate
        leon3 : leon3x               -- LEON3 processor
          generic map (
            hindex     => i,
            fabtech    => fabtech,
            memtech    => memtech,
            nwindows   => nwindows,
            dsu        => dsu,
            fpu        => fpu + 32*grfpush,
            v8         => v8,
            cp         => 0,
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
            smp        => ncpu-1,
            iuft       => ft mod 4,
            fpft       => ft mod 4,
            cmft       => ft/8,
            iuinj      => 0, --iuinj,
            ceinj      => 0, --ceinj,
            cached     => cached,
            clk2x      => clk2x,
            netlist    => netlist,
            scantest   => 0,
            mmupgsz    => 0,            -- 4 KiB
            bp         => 2,            -- programmable
            npasi      => npasi,
            pwrpsr     => pwrpsr,
            rex        => rex,
            altwin     => altwin
            )
          port map (
            clk        => ahbclk,
            gclk2      => cpuclk,
            gfclk2     => cpuclk,
            clk2       => cpuclk,
            rstn       => rstn,
            cpuid      => i,
            ahbi       => leon_ahbmi,
            ahbo       => leon_ahbmo(i),
            ahbsi      => leon_ahbsi,
            ahbso      => leon_ahbso,
            irqi       => irqi(i),
            irqo       => irqo(i),
            dbgi       => l3dbgi(i),
            dbgo       => l3dbgo(i),
            fpui       => fpi(i),
            fpuo       => fpo(i),
            clken      => hclken);
      end generate cpu;
      syso.proc_error  <= l3dbgo(0).error;
      syso.proc_errorn <= not l3dbgo(0).error;
      -- LEON3 Debug Support Unit
      dsugen : if dsu = 1 generate
        dsu0 : dsu3x
          generic map (
            hindex   => dsu_hindex,
            haddr    => dsu_haddr,
            hmask    => dsu_hmask,
            ncpu     => ncpu,
            tbits    => 30,
            tech     => memtech,
            irq      => 0,
            kbytes   => atbsz,
            clk2x    => 0,
            testen   => 0,
            bwidth   => AHBDW,
            ahbpf    => 0)
          port map (
            rst      => rstn,
            hclk     => ahbclk,
            cpuclk   => cpuclk,
            ahbmi    => dsu_tahbmi,
            ahbsi    => dsu_ahbsi,
            ahbso    => dsu_ahbso,
            tahbsi   => dsu_tahbsi,
            dbgi     => l3dbgo,
            dbgo     => l3dbgi,
            dsui     => l3dsui,
            dsuo     => l3dsuo,
            hclken   => hclken
            );
        l3dsui.enable <= sysi.dsu_enable;
        l3dsui.break <= sysi.dsu_break;
        syso.dsu_active <= l3dsuo.active;
        syso.dsu_tstop <= l3dsuo.tstop;
      end generate;
      nodsugen : if dsu = 0 generate
        l3dbgi <= (others => dbgi_none);
      end generate;
      l3sgen : if stat /= 0 generate
        l3s : l3stat
          generic map (
            pindex  => stat_pindex,
            paddr   => stat_paddr,
            pmask   => stat_pmask,
            ncnt    => stat_ncnt,
            ncpu    => ncpu,
            nmax    => stat_nmax,
            lahben  => 1,
            dsuen   => dsu,
            forcer0 => 0)
          port map (
            rstn    => rstn,
            clk     => ahbclk,
            apbi    => stat_apbi,
            apbo    => stat_apbo,
            ahbsi   => stat_ahbsi,
            dbgo    => l3dbgo,
            dsuo    => l3dsuo,
            stati   => stati,
            apb2i   => apb_slv_in_none,
            apb2o   => open,
            astat   => amba_stat_none);
      end generate;
      nol3s : if stat = 0 generate
        stat_apbo <= apb_none;
      end generate;
    end block leon3blk;
  end generate;

  nodsu : if dsu = 0 generate
    syso.dsu_tstop <= '0'; syso.dsu_active <= '0';
    dsu_ahbso <= ahbs_none;
  end generate;

----------------------------------------------------------------------
---  Optional shared FPU     -----------------------------------------
----------------------------------------------------------------------

  shfpu : if grfpush = 1 generate
    grfpush0 : grfpushwx generic map ((fpu-1), ncpu, fabtech)
      port map (cpuclk, rstn, fpi, fpo);
  end generate;
  noshfpu : if grfpush = 0 generate
    fpo <= (others => grfpu_out_none);
  end generate;

end;
