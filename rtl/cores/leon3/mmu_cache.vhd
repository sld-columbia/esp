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
-- Entity:      mmu_cache
-- File:        mmu_cache.vhd
-- Author:      Jiri Gaisler
-- Description: Cache controllers and AHB interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.libiu.all;
use work.libcache.all;
use work.libleon3.all;
use work.mmuconfig.all;
use work.mmuiface.all;
use work.libmmu.all;

entity mmu_cache is
  generic (
    hindex     :     integer                  := 0;
    fabtech    :     integer                  := 0;
    memtech    :     integer                  := 0;
    dsu        :     integer range 0 to 1     := 0;
    icen       :     integer range 0 to 1     := 0;
    irepl      :     integer range 0 to 3     := 0;
    isets      :     integer range 1 to 4     := 1;
    ilinesize  :     integer range 4 to 8     := 4;
    isetsize   :     integer range 1 to 256   := 1;
    isetlock   :     integer range 0 to 1     := 0;
    dcen       :     integer range 0 to 1     := 0;
    drepl      :     integer range 0 to 3     := 0;
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
    itlbnum    :     integer range 2 to 64    := 8;
    dtlbnum    :     integer range 2 to 64    := 8;
    tlb_type   :     integer range 0 to 3     := 1;
    tlb_rep    :     integer range 0 to 1     := 0;
    cached     :     integer                  := 0;
    clk2x      :     integer                  := 0;
    scantest   :     integer                  := 0;
    mmupgsz    :     integer range 0 to 5     := 0;
    smp        :     integer                  := 0;
    mmuen      :     integer range 0 to 1     := 0
    );
  port (
    rst        : in  std_ulogic;
    clk        : in  std_ulogic;
    ici        : in  icache_in_type;
    ico        : out icache_out_type;
    dci        : in  dcache_in_type;
    dco        : out dcache_out_type;
    ahbi       : in  ahb_mst_in_type;
    ahbo       : out ahb_mst_out_type;
    ahbsi      : in  ahb_slv_in_type;
    ahbso      : in  ahb_slv_out_vector;
    crami      : out cram_in_type;
    cramo      : in  cram_out_type;
    fpuholdn   : in  std_ulogic;
    hclk, sclk : in  std_ulogic;
    hclken     : in  std_ulogic
  );


end; 

architecture rtl of mmu_cache is

  constant MEMTECH_MOD : integer := memtech mod 65536;
  constant MEMTECH_VEC : std_logic_vector(31 downto 0) := conv_std_logic_vector(memtech, 32);
  constant TLB_INFER  : integer := conv_integer(MEMTECH_VEC(16));

  signal icol : icache_out_type;
  signal dcol : dcache_out_type;
  signal mcii : memory_ic_in_type;
  signal mcio : memory_ic_out_type;
  signal mcdi : memory_dc_in_type;
  signal mcdo : memory_dc_out_type;

  signal mcmmi : memory_mm_in_type;
  signal mcmmo : memory_mm_out_type;

  signal mmudci : mmudc_in_type;
  signal mmudco : mmudc_out_type;
  signal mmuici : mmuic_in_type;
  signal mmuico : mmuic_out_type;

  signal ahbsi2 : ahb_slv_in_type;
  signal ahbi2  : ahb_mst_in_type;
  signal ahbo2  : ahb_mst_out_type;

  signal gndv: std_logic_vector(1 downto 0);

begin

  gndv <= (others => '0');

  icache0 : mmu_icache 
    generic map (fabtech, icen, irepl, isets, ilinesize, isetsize, isetlock, ilram,
                 ilramsize, ilramstart,
                 mmuen)
    port map (rst, clk, ici, icol, dci, dcol, mcii, mcio, 
              crami.icramin, cramo.icramo, fpuholdn, mmudci, mmuici, mmuico);
  dcache0 : mmu_dcache 
    generic map (dsu, dcen, drepl, dsets, dlinesize, dsetsize,  dsetlock, dsnoop,
                 dlram, dlramsize, dlramstart, ilram, ilramstart,
                 itlbnum, dtlbnum, tlb_type,
                 MEMTECH_MOD, cached, mmupgsz, smp, mmuen, icen)
    port map (rst, clk, dci, dcol, icol, mcdi, mcdo, ahbsi2,
              crami.dcramin, cramo.dcramo, fpuholdn, mmudci, mmudco, sclk, ahbso);

-- AMBA AHB interface
  a0 : mmu_acache
    generic map (hindex, ilinesize, cached, clk2x, scantest
                 )
    port map (rst, sclk, mcii, mcio, mcdi, mcdo, mcmmi, mcmmo, ahbi2, ahbo2, ahbso, hclken);

  -- MMU
  mmugen : if mmuen = 1 generate
    m0 : l3_mmu
      generic map (MEMTECH_MOD*(1-TLB_INFER), itlbnum, dtlbnum, tlb_type, tlb_rep, mmupgsz, memtest_vlen)
      port map (rst, clk, mmudci, mmudco, mmuici, mmuico, mcmmo, mcmmi, ahbi.testin
                );
  end generate;
  nommu : if mmuen = 0 generate
    mcmmi <= mci_zero; mmudco <= mmudco_zero; mmuico <= mmuico_zero;
  end generate;

  ico <= icol;
  dco <= dcol;


  clk2xgen: if clk2x /= 0 generate
    sync0 : clk2xsync generic map (hindex, clk2x)
      port map (rst, hclk, clk, ahbi, ahbi2, ahbo2, ahbo, ahbsi, ahbsi2,
                mcii, mcdi, mcdo, mcmmi.req, mcmmo.grant, hclken);
  end generate;
     
  noclk2x : if clk2x = 0 generate
    ahbsi2 <= ahbsi;
    ahbi2  <= ahbi;
    ahbo   <= ahbo2;
  end generate;
  
end;

