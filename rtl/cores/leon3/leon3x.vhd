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
------------------------------------------------------------------------------
-- Entity:      leon3x
-- File:        leon3x.vhd
-- Author:      Jiri Gaisler, Jan Andersson, Aeroflex Gaisler
-- Description: Top-level LEON3v3 component with all options
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.leon3.all;
use work.libiu.all;
use work.libcache.all;
use work.libleon3.all;
use work.libfpu.all;
use work.arith.all;
use work.coretypes.all;
use work.sldfpp.all;

entity leon3x is
  generic (
    hindex     :     integer                  := 0;
    fabtech    :     integer range 0 to NTECH := DEFFABTECH;
    memtech    :     integer                  := DEFMEMTECH;
    nwindows   :     integer range 2 to 32    := 8;
    dsu        :     integer range 0 to 1     := 0;
    fpu        :     integer range 0 to 63    := 0;
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
    tbuf       :     integer range 0 to 128   := 0;
    pwd        :     integer range 0 to 2     := 2;
    svt        :     integer range 0 to 1     := 1;
    rstaddr    :     integer                  := 0;
    smp        :     integer range 0 to 15    := 0;
    iuft       :     integer range 0 to 6     := 0;
    fpft       :     integer range 0 to 6     := 0;
    cmft       :     integer range 0 to 1     := 0;
    iuinj      :     integer                  := 0;
    ceinj      :     integer range 0 to 3     := 0;
    cached     :     integer                  := 0;
    clk2x      :     integer                  := 1;
    netlist    :     integer                  := 0;
    scantest   :     integer                  := 0;
    mmupgsz    :     integer range 0 to 5     := 0;
    bp         :     integer                  := 1;
    npasi      :     integer range 0 to 1     := 0;
    pwrpsr     :     integer range 0 to 1     := 0;
    rex        :     integer                  := 0;
    altwin     :     integer range 0 to 1     := 0
    );
  port (
    clk        : in  std_ulogic;                     -- free-running clock
    gclk2      : in  std_ulogic;                     -- gated 2x clock
    gfclk2     : in  std_ulogic;                     -- gated 2x FPU clock
    clk2       : in  std_ulogic;                     -- free-running 2x clock
    rstn       : in  std_ulogic;
    cpuid      : in  integer range 0 to 15:= 0;
    ahbi       : in  ahb_mst_in_type;
    ahbo       : out ahb_mst_out_type;
    ahbsi      : in  ahb_slv_in_type;
    ahbso      : in  ahb_slv_out_vector;
    irqi       : in  l3_irq_in_type;
    irqo       : out l3_irq_out_type;
    dbgi       : in  l3_debug_in_type;
    dbgo       : out l3_debug_out_type;
    fpui       : out grfpu_in_type;
    fpuo       : in  grfpu_out_type;
    dflush     : out std_ulogic;                     -- data-cache flush
    clken      : in  std_ulogic
    );


end; 

architecture rtl of leon3x is

constant IRFBITS  : integer range 6 to 10 := log2(NWINDOWS+1) + 4;
constant IREGNUM  : integer := NWINDOWS * 16 + 8;

constant IRFWT     : integer := 1;--regfile_3p_write_through(memtech);
constant fpuarch   : integer := fpu mod 16;
constant fpunet    : integer := (fpu mod 32) / 16;
constant fpushared : boolean := (fpu / 32) /= 0;

constant MEMTECH_MOD : integer := memtech mod 65536;
constant MEMTECH_VEC : std_logic_vector(31 downto 0) := conv_std_logic_vector(memtech, 32);
constant IURF_INFER : integer := conv_integer(MEMTECH_VEC(17));
constant FPRF_INFER : integer := conv_integer(MEMTECH_VEC(18));

constant FTSUP     : integer := 0
                                ;

-- Create an array length mismatch error if the user tries to enable FT
-- features in non-FT release.
constant dummy_ft_consistency_check:
  std_logic_vector(FTSUP*(iuft+fpft+cmft) downto (iuft+fpft+cmft)) := "0";

signal holdn : std_logic;
signal rfi   : iregfile_in_type;
signal rfo   : iregfile_out_type;
signal crami : cram_in_type;
signal cramo : cram_out_type;
signal tbi   : tracebuf_in_type;
signal tbo   : tracebuf_out_type;
signal tbi_2p : tracebuf_2p_in_type;
signal tbo_2p : tracebuf_2p_out_type;
signal rst   : std_ulogic;
signal fpi   : fpc_in_type;
signal fpo   : fpc_out_type;
signal cpi   : fpc_in_type;
signal cpo   : fpc_out_type;
signal gnd, vcc : std_logic;

attribute sync_set_reset : string;
attribute sync_set_reset of rst : signal is "true";

begin

   gnd <= '0'; vcc <= '1';

   vhdl : if netlist = 0 generate
     -- leon3 processor core (iu, caches & mul/div)
     p0 : proc3
       generic map (
         hindex, fabtech, memtech, nwindows, dsu, fpuarch, v8, cp, mac, pclow,
         notag, nwp, icen, irepl, isets, ilinesize, isetsize, isetlock, dcen,
         drepl, dsets, dlinesize, dsetsize, dsetlock, dsnoop, ilram, ilramsize,
         ilramstart, dlram, dlramsize, dlramstart, mmuen, itlbnum, dtlbnum,
         tlb_type, tlb_rep, lddel, disas, tbuf, pwd, svt, rstaddr, smp,
         cached, clk2x, scantest, mmupgsz, bp, npasi, pwrpsr, rex, altwin)
       port map (gclk2, rst, cpuid, holdn, ahbi, ahbo, ahbsi, ahbso, rfi, rfo, crami, cramo, 
                 tbi, tbo, tbi_2p, tbo_2p, fpi, fpo, cpi, cpo, irqi, irqo, dbgi, dbgo, clk, clk2, clken
                 );

     -- Export data-cache flush signal and forward it to L2 private caches
     dflush <= crami.dcramin.flushc;


     -- IU register file
     rf0 : regfile_3p_l3 generic map (MEMTECH_MOD*(1-IURF_INFER), IRFBITS, 32, IRFWT, IREGNUM,
                                      scantest)
       port map (gclk2, rfi.waddr(IRFBITS-1 downto 0), rfi.wdata, rfi.wren,
                 gclk2, rfi.raddr1(IRFBITS-1 downto 0), rfi.ren1, rfo.data1,
                 rfi.raddr2(IRFBITS-1 downto 0), rfi.ren2, rfo.data2,
                 ahbi.testin
                 );

     -- cache memory
     cmem0 : cachemem
       generic map (MEMTECH_MOD, icen, irepl, isets, ilinesize, isetsize, isetlock, dcen,
                    drepl, dsets,  dlinesize, dsetsize, dsetlock, dsnoop, ilram,
                    ilramsize, dlram, dlramsize, mmuen, scantest
                    )
       port map (gclk2, crami, cramo, clk2, ahbi.testin
                 );

     -- instruction trace buffer memory
     tbmem_gen : if (tbuf /= 0) generate
       tbmem_1p : if (tbuf <= 64) generate
         tbmem0 : tbufmem
           generic map (tech => MEMTECH_MOD, tbuf => tbuf, dwidth => 32, testen => scantest)
           port map (gclk2, tbi, tbo, ahbi.testin
                     );
         tbo_2p <= tracebuf_2p_out_type_none;
       end generate;
       tbmem_2p: if (tbuf > 64) generate
         tbmem0 : tbufmem_2p
           generic map (tech => MEMTECH_MOD, tbuf => (tbuf-64), dwidth => 32, testen => scantest)
           port map (gclk2, tbi_2p, tbo_2p, ahbi.testin
                     );
         tbo <= tracebuf_out_type_none;
       end generate;
     end generate;
     notbmem_gen : if (tbuf = 0) generate
       tbo <= tracebuf_out_type_none;
       tbo_2p <= tracebuf_2p_out_type_none;
     end generate;

     -- FPU
     fpu0 : if (fpu = 0) generate
       fpo <= fpc_out_none;
     end generate;

     fpshare : if fpushared generate
       grfpw0gen : if (fpuarch > 0) and (fpuarch < 8) generate
         fpu0: grfpwxsh
           generic map (MEMTECH_MOD*(1-FPRF_INFER), pclow, dsu, disas, hindex,
                        scantest
                     )
           port map (rst, gclk2, holdn, fpi, fpo, fpui, fpuo, ahbi.testin
                     );
       end generate;
       nogrfpw0gen : if not ((fpuarch > 0) and (fpuarch < 8)) generate
         fpui <= grfpu_in_none;
       end generate;
     end generate;

     nofpshare : if not fpushared generate
       grfpw1gen : if (fpuarch > 0) and (fpuarch < 7) generate
         fpu0: grfpwx
           generic map (fabtech, MEMTECH_MOD*(1-FPRF_INFER), (fpuarch-1), pclow, dsu, disas,
                        fpunet, hindex, scantest)
           port map (rst, gfclk2, holdn, fpi, fpo, ahbi.testin
                     );
       end generate;  

       sldfpw0gen : if (fpuarch = 7) generate
         fpu0 : sldfpw
           generic map (memtech)
           port map (rst, gclk2, holdn, fpi, fpo);
       end generate;

       grlfpc1gen : if (fpuarch >=8) and (fpuarch < 15) generate
         fpu0 : grlfpwx
           generic map (MEMTECH_MOD*(1-FPRF_INFER), pclow, dsu, disas,
                        (fpuarch-8), fpunet, hindex, scantest)
           port map (rst, gfclk2, holdn, fpi, fpo, ahbi.testin
                     );
       end generate;    
       fpui <= grfpu_in_none;
     end generate;    
  
     -- CP
     cpo <= fpc_out_none;

     -- 1-clock reset delay
     rstreg : process(gclk2)
     begin if rising_edge(gclk2) then rst <= rstn; end if; end process;

   end generate vhdl;

   
-- pragma translate_off
   bootmsg : report_version 
     generic map (
       "leon3_" & tost(hindex) & ": LEON3 SPARC V8 processor rev " & tost(LEON3_VERSION)
       & ": iuft: " & tost(iuft) & ", fpft: " & tost(fpft) & ", cacheft: " & tost(cmft)
       , "leon3_" & tost(hindex) & ": icache " & tost(isets*icen) & "*" & tost(isetsize*icen) &
       " kbyte, dcache "  & tost(dsets*dcen) & "*" & tost(dsetsize*dcen) & " kbyte"
       );
-- pragma translate_on

end;

