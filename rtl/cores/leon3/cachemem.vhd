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
-- Entity:      cachemem
-- File:        cachemem.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Contains ram cells for both instruction and data caches
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.libiu.all;
use work.libcache.all;
use work.mmuconfig.all;
use work.stdlib.all;
use work.gencomp.all;

entity cachemem is
  generic (
    tech      : integer range 0 to NTECH := 0;
    icen      : integer range 0 to 1 := 0;
    irepl     : integer range 0 to 3 := 0;
    isets     : integer range 1 to 4 := 1;
    ilinesize : integer range 4 to 8 := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1 := 0;
    dcen      : integer range 0 to 1 := 0;
    drepl     : integer range 0 to 3 := 0;
    dsets     : integer range 1 to 4 := 1;
    dlinesize : integer range 4 to 8 := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1 := 0;
    dsnoop    : integer range 0 to 7 := 0;
    ilram      : integer range 0 to 2 := 0;
    ilramsize  : integer range 1 to 512 := 1;        
    dlram      : integer range 0 to 2 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    mmuen     : integer range 0 to 1 := 0;
    testen    : integer range 0 to 3 := 0
  );
  port (
        clk   : in  std_ulogic;
        crami : in  cram_in_type;
        cramo : out cram_out_type;
        sclk  : in  std_ulogic;
        testin: in  std_logic_vector(TESTIN_WIDTH-1 downto 0)
  );


end;

architecture rtl of cachemem is
  constant DSNOOPSEP    : boolean := (dsnoop > 3);
  constant DSNOOPFAST   : boolean := (dsnoop = 2) or (dsnoop = 6);
  constant DSNOOPHB     : boolean := (dsnoop = 7);
  
  constant ILINE_BITS   : integer := log2(ilinesize);
  constant IOFFSET_BITS : integer := 8 +log2(isetsize) - ILINE_BITS;
  constant DLINE_BITS   : integer := log2(dlinesize);
  constant DOFFSET_BITS : integer := 8 +log2(dsetsize) - DLINE_BITS;
  constant ITAG_BITS    : integer := TAG_HIGH - IOFFSET_BITS - ILINE_BITS - 2 + ilinesize + 1;
  constant DTAG_BITS    : integer := TAG_HIGH - DOFFSET_BITS - DLINE_BITS - 2 + dlinesize + 1;
  constant IPTAG_BITS   : integer := TAG_HIGH - IOFFSET_BITS - ILINE_BITS - 2 + 1;
  constant ILRR_BIT     : integer := creplalg_tbl(irepl);
  constant DLRR_BIT     : integer := creplalg_tbl(drepl);
  constant ITAG_LOW     : integer := IOFFSET_BITS + ILINE_BITS + 2;
  constant DTAG_LOW     : integer := DOFFSET_BITS + DLINE_BITS + 2;
  constant ICLOCK_BIT   : integer := isetlock;
  constant DCLOCK_BIT   : integer := dsetlock;
  constant ILRAM_BITS   : integer := log2(ilramsize) + 10;
  constant DLRAM_BITS   : integer := log2(dlramsize) + 10;


  constant ITDEPTH : natural := 2**IOFFSET_BITS;
  constant DTDEPTH : natural := 2**DOFFSET_BITS;
  constant MMUCTX_BITS : natural := 8*mmuen;

  -- i/d tag layout
  -- +-----+----------+---+--------+-----+-------+
  -- | LRR | LOCK_BIT |PAR| MMUCTX | TAG | VALID |
  -- +-----+----------+---+--------+-----+-------+
  --  [opt] [  opt   ] [ ] [  opt ] [           ]           


  constant ITWIDTH : natural := ITAG_BITS + ILRR_BIT + ICLOCK_BIT + MMUCTX_BITS
                                ;
  constant DTWIDTH : natural := DTAG_BITS + DLRR_BIT + DCLOCK_BIT + MMUCTX_BITS
                                ;
  constant IDWIDTH : natural := 32
                                ;
  constant DDWIDTH : natural := 32
                                ;
  constant DPTAG_BITS : integer := TAG_HIGH - DOFFSET_BITS - DLINE_BITS - 2 + 1;

  constant DTLRR_BIT_POS  : natural := DTWIDTH-DLRR_BIT;               -- if DTLRR_BIT=0 discard (pos DTWIDTH)
  constant DTLOCK_BIT_POS : natural := DTWIDTH-(DLRR_BIT+DCLOCK_BIT);  -- if DTCLOCK_BIT=0 but DTLRR_BIT=1 lrr will overwrite
  constant DTMMU_VEC_U    : natural := DTWIDTH-(DLRR_BIT+DCLOCK_BIT
                                                )-1;  
  constant DTMMU_VEC_D    : natural := DTWIDTH-(DLRR_BIT+DCLOCK_BIT+
                                                MMUCTX_BITS);
  
  constant ITLRR_BIT_POS  : natural := ITWIDTH-ILRR_BIT;               -- if DLRR_BIT=0 discard (pos DTWIDTH)
  constant ITLOCK_BIT_POS : natural := ITWIDTH-(ILRR_BIT+ICLOCK_BIT);  -- if DCLOCK_BIT=0 but DLRR_BIT=1 lrr will overwrite
  constant ITMMU_VEC_U    : natural := ITWIDTH-(ILRR_BIT+ICLOCK_BIT
                                                )-1;  
  constant ITMMU_VEC_D    : natural := ITWIDTH-(ILRR_BIT+ICLOCK_BIT+
                                                MMUCTX_BITS);  

  constant DPTAG_RAM_BITS : integer := DPTAG_BITS
                                       ;

  constant DTAG_RAM_BITS : integer := DTAG_BITS
                                       ;
  
  subtype dtdatain_vector is std_logic_vector(DTWIDTH downto 0);
  type dtdatain_type is array (0 to MAXSETS-1) of dtdatain_vector;
  subtype itdatain_vector is std_logic_vector(ITWIDTH downto 0);
  type itdatain_type is array (0 to MAXSETS-1) of itdatain_vector;
  subtype dddatain_vector is std_logic_vector(DDWIDTH-1 downto 0);
  type dddatain_type is array (0 to MAXSETS-1) of dddatain_vector;
  
  subtype itdataout_vector is std_logic_vector(ITWIDTH downto 0);
  type itdataout_type is array (0 to MAXSETS-1) of itdataout_vector;
  subtype iddataout_vector is std_logic_vector(IDWIDTH -1 downto 0);
  type iddataout_type is array (0 to MAXSETS-1) of iddataout_vector;
  subtype dtdataout_vector is std_logic_vector(DTWIDTH downto 0);
  type dtdataout_type is array (0 to MAXSETS-1) of dtdataout_vector;
  subtype dddataout_vector is std_logic_vector(DDWIDTH -1 downto 0);
  type dddataout_type is array (0 to MAXSETS-1) of dddataout_vector;



  signal itaddr    : std_logic_vector(IOFFSET_BITS + ILINE_BITS -1 downto ILINE_BITS);
  signal idaddr    : std_logic_vector(IOFFSET_BITS + ILINE_BITS -1 downto 0);
  signal ildaddr   : std_logic_vector(ILRAM_BITS-3 downto 0);

  signal itdatain  : itdatain_type;
  signal itdatainx  : itdatain_type;
  signal itdatain_cmp : itdatain_type;
  signal itdataout : itdataout_type;
  signal iddatain  : std_logic_vector(IDWIDTH -1 downto 0);
  signal iddatainx  : std_logic_vector(IDWIDTH -1 downto 0);
  signal iddatain_cmp  : std_logic_vector(IDWIDTH -1 downto 0);    
  signal iddataout : iddataout_type;
  signal ildataout : std_logic_vector(31 downto 0);

  signal itenable  : std_ulogic;
  signal idenable  : std_ulogic;
  signal itwrite   : std_logic_vector(0 to MAXSETS-1);
  signal idwrite   : std_logic_vector(0 to MAXSETS-1);

  signal dtaddr    : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  signal dtaddr2   : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  signal dtaddr3   : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  signal ddaddr    : std_logic_vector(DOFFSET_BITS + DLINE_BITS -1 downto 0);
  signal ldaddr    : std_logic_vector(DLRAM_BITS-1 downto 2);
  
  signal dtdatain  : dtdatain_type;
  signal dtdatainx  : dtdatain_type;
  signal dtdatain_cmp  : dtdatain_type;     
  signal dtdatain2 : dtdatain_type;
  signal dtdatain3 : dtdatain_type;
  signal dtdatainu : dtdatain_type;
  signal dtdataout : dtdataout_type;
  signal dtdataout2: dtdataout_type;
  signal dtdataout3: dtdataout_type;
  signal dddatain  : dddatain_type;
  signal dddatainx : dddatain_type;
  signal dddatain_cmp : dddatain_type;    
  signal dddataout : dddataout_type;
  signal lddatain, ldataout  : std_logic_vector(31 downto 0);

  signal dtenable  : std_logic_vector(0 to MAXSETS-1);
  signal dtenable2 : std_logic_vector(0 to MAXSETS-1);
  signal ddenable  : std_logic_vector(0 to MAXSETS-1);
  signal dtwrite   : std_logic_vector(0 to MAXSETS-1);
  signal dtwrite2  : std_logic_vector(0 to MAXSETS-1);
  signal dtwrite3  : std_logic_vector(0 to MAXSETS-1);
  signal ddwrite   : std_logic_vector(0 to MAXSETS-1);

  signal vbcrd     : std_logic_vector(0 to DSETS-1);
  signal vbcwd     : std_logic_vector(0 to DSETS-1);

  signal vcc, gnd  : std_ulogic;
  
  
begin

  vcc <= '1'; gnd <= '0'; 
  itaddr <= crami.icramin.address(IOFFSET_BITS + ILINE_BITS -1 downto ILINE_BITS);
  idaddr <= crami.icramin.address(IOFFSET_BITS + ILINE_BITS -1 downto 0);
  ildaddr <= crami.icramin.ldramin.address(ILRAM_BITS-3 downto 0);
  
  itinsel : process(clk, crami, dtdataout2, dtdataout3
                    )

  variable viddatain  : std_logic_vector(IDWIDTH -1 downto 0);
  variable vdddatain  : dddatain_type;
  variable vitdatain : itdatain_type;
  variable vdtdatain : dtdatain_type;
  variable vdtdatain2 : dtdatain_type;
  variable vdtdatain3 : dtdatain_type;
  variable vdtdatainu : dtdatain_type;

  
  begin
    
    viddatain := (others => '0');
    vdddatain := (others => (others => '0'));
    
    viddatain(31 downto 0) := crami.icramin.data;

    for i in 0 to DSETS-1 loop
      vdtdatain(i) := (others => '0');
      if mmuen = 1 then
        vdtdatain(i)(DTMMU_VEC_U downto DTMMU_VEC_D) := crami.dcramin.ctx(i);
      end if;
      vdtdatain(i)(DTLOCK_BIT_POS) := crami.dcramin.tag(i)(CTAG_LOCKPOS);
      if drepl = lrr then
        vdtdatain(i)(DTLRR_BIT_POS) := crami.dcramin.tag(i)(CTAG_LRRPOS);
      end if;
      vdtdatain(i)(DTAG_BITS-1 downto 0) := crami.dcramin.tag(i)(TAG_HIGH downto DTAG_LOW) & crami.dcramin.tag(i)(dlinesize-1 downto 0);
      if (crami.dcramin.flush(i) = '1') then
        vdtdatain(i) := (others => '0');
        vdtdatain(i)(DTAG_BITS-1 downto DTAG_BITS-8) :=  X"FF";
        vdtdatain(i)(DTAG_BITS-9 downto DTAG_BITS-10) :=  conv_std_logic_vector(i,2);
        vdtdatain(i)(DTAG_BITS-11 downto DTAG_BITS-12) :=  conv_std_logic_vector(i,2);                
      end if;
    end loop;


    for i in 0 to DSETS-1 loop
      vdtdatain2(i) := (others => '0');      
      vdddatain(i)(31 downto 0) := crami.dcramin.data(i);
      vdtdatain2(i)(DTAG_BITS-1 downto DTAG_BITS-8) :=  X"FF";
      vdtdatain2(i)(DTAG_BITS-9 downto DTAG_BITS-10) :=  conv_std_logic_vector(i,2);
      vdtdatain2(i)(DTAG_BITS-11 downto DTAG_BITS-12) :=  conv_std_logic_vector(i,2);                
    end loop;

    vdtdatainu := (others => (others => '0'));
    vdtdatain3 := (others => (others => '0'));
    for i in 0 to DSETS-1 loop
      vdtdatain3(i) := (others => '0');
      vdtdatain3(i)(DTAG_BITS-1 downto DTAG_BITS-DPTAG_BITS) := crami.dcramin.ptag(i)(TAG_HIGH downto DTAG_LOW);
      if DSNOOPSEP and (crami.dcramin.flush(i) = '1') then
        vdtdatain3(i) := (others => '0');
        vdtdatain3(i)(DTAG_BITS-1 downto DTAG_BITS-8) :=  X"F3";
        vdtdatain3(i)(DTAG_BITS-9 downto DTAG_BITS-10) :=  conv_std_logic_vector(i,2);
        vdtdatain3(i)(DTAG_BITS-11 downto DTAG_BITS-12) :=  conv_std_logic_vector(i,2);                
      end if;
    end loop;

    for i in 0 to ISETS-1 loop
      vitdatain(i) := (others => '0');
      if mmuen = 1 then
        vitdatain(i)(ITMMU_VEC_U downto ITMMU_VEC_D) := crami.icramin.ctx;
      end if;
      vitdatain(i)(ITLOCK_BIT_POS) := crami.icramin.tag(i)(CTAG_LOCKPOS);
      if irepl = lrr then
        vitdatain(i)(ITLRR_BIT_POS) := crami.icramin.tag(i)(CTAG_LRRPOS);
      end if;
      vitdatain(i)(ITAG_BITS-1 downto 0) := crami.icramin.tag(i)(TAG_HIGH downto ITAG_LOW) 
                & crami.icramin.tag(i)(ilinesize-1 downto 0);
      if (crami.icramin.flush = '1') then
        vitdatain(i) := (others => '0');
        vitdatain(i)(ITAG_BITS-1 downto ITAG_BITS-8) :=  X"FF";
        vitdatain(i)(ITAG_BITS-9 downto ITAG_BITS-10) :=  conv_std_logic_vector(i,2);
        vitdatain(i)(ITAG_BITS-11 downto ITAG_BITS-12) :=  conv_std_logic_vector(i,2);        
      end if;
    end loop;

-- pragma translate_off
     itdatainx <= vitdatain; iddatainx <= viddatain;
     dtdatainx <= vdtdatain; dddatainx <= vdddatain;
    

-- pragma translate_on
    
    itdatain <= vitdatain; iddatain <= viddatain;
    dtdatain <= vdtdatain; dtdatain2 <= vdtdatain2; dddatain <= vdddatain;
    dtdatain3 <= vdtdatain3; dtdatainu <= vdtdatainu;
    
    
  end process;


  
  itwrite   <= crami.icramin.twrite;
  idwrite   <= crami.icramin.dwrite;
  itenable  <= crami.icramin.tenable;
  idenable  <= crami.icramin.denable;

  dtaddr <= crami.dcramin.address(DOFFSET_BITS + DLINE_BITS -1 downto DLINE_BITS);
  dtaddr2 <= crami.dcramin.saddress(DOFFSET_BITS-1 downto 0);  
  dtaddr3 <= crami.dcramin.faddress(DOFFSET_BITS-1 downto 0);  
  ddaddr <= crami.dcramin.address(DOFFSET_BITS + DLINE_BITS -1 downto 0);
  ldaddr <= crami.dcramin.ldramin.address(DLRAM_BITS-1 downto 2);
  dtwrite   <= crami.dcramin.twrite;
  dtwrite2  <= crami.dcramin.swrite;
  dtwrite3  <= crami.dcramin.tpwrite;
  ddwrite   <= crami.dcramin.dwrite;
  dtenable  <= crami.dcramin.tenable;
  dtenable2 <= crami.dcramin.senable;
  ddenable  <= crami.dcramin.denable;


  ime : if icen = 1 generate
    im0 : for i in 0 to ISETS-1 generate
      itags0 : syncram generic map (tech, IOFFSET_BITS, ITWIDTH, testen, memtest_vlen)
      port map ( clk, itaddr, itdatain(i)(ITWIDTH-1 downto 0), itdataout(i)(ITWIDTH-1 downto 0), itenable, itwrite(i), testin
                 );
      idata0 : syncram generic map (tech, IOFFSET_BITS+ILINE_BITS, IDWIDTH, testen, memtest_vlen)
      port map (clk, idaddr, iddatain, iddataout(i), idenable, idwrite(i), testin
                );
      itdataout(i)(ITWIDTH) <= '0';
    end generate;
  end generate;

  imd : if icen = 0 generate
    ind0 : for i in 0 to ISETS-1 generate
      itdataout(i) <= (others => '0');
      iddataout(i) <= (others => '0');
    end generate;
  end generate;

  ild0 : if ilram /= 0 generate
    ildata0 : syncram
     generic map (tech, ILRAM_BITS-2, 32, testen, memtest_vlen)
      port map (clk, ildaddr, iddatain, ildataout, 
          crami.icramin.ldramin.enable, crami.icramin.ldramin.write, testin
                );
  end generate;
  
  dme : if dcen = 1 generate
    dtags0 : if DSNOOP = 0 generate
      dt0 : for i in 0 to DSETS-1 generate
        dtags0 : syncram
        generic map (tech, DOFFSET_BITS, DTWIDTH, testen, memtest_vlen)
        port map (clk, dtaddr, dtdatain(i)(DTWIDTH-1 downto 0), 
            dtdataout(i)(DTWIDTH-1 downto 0), dtenable(i), dtwrite(i), testin
                  );
      end generate;
    end generate;

    dtags1 : if DSNOOP /= 0 generate
      dt1 : if not DSNOOPSEP generate
        dt0 : for i in 0 to DSETS-1 generate
          dtags0 : syncram_dp
          generic map (tech, DOFFSET_BITS, DTWIDTH, testen, memtest_vlen, 0, 1) port map (
           clk, dtaddr, dtdatain(i)(DTWIDTH-1 downto 0), 
                dtdataout(i)(DTWIDTH-1 downto 0), dtenable(i), dtwrite(i),
           sclk, dtaddr2, dtdatain2(i)(DTWIDTH-1 downto 0), 
                dtdataout2(i)(DTWIDTH-1 downto 0), dtenable2(i), dtwrite2(i), testin
           );
        end generate;
      end generate;
      
      -- virtual address snoop case
      mdt1 : if DSNOOPSEP generate
       slow : if not DSNOOPFAST and not DSNOOPHB generate
        mdt0 : for i in 0 to DSETS-1 generate
          dtags0 : syncram_dp
          generic map (tech, DOFFSET_BITS, DTWIDTH-dlinesize+1, testen, memtest_vlen, 0, 1) port map (
            clk, dtaddr, dtdatain(i)(DTWIDTH-1 downto dlinesize-1), 
                 dtdataout(i)(DTWIDTH-1 downto dlinesize-1), dtenable(i), dtwrite(i),
            sclk, dtaddr2, dtdatain2(i)(DTWIDTH-1 downto dlinesize-1), 
                 dtdataout2(i)(DTWIDTH-1 downto dlinesize-1), dtenable2(i), dtwrite2(i), testin
            );
          dtags1 : syncram_dp
          generic map (tech, DOFFSET_BITS, DPTAG_RAM_BITS, testen, memtest_vlen, 0, 1) port map (
            clk, dtaddr, dtdatain3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS), 
                 open, dtwrite3(i), dtwrite3(i),
            sclk, dtaddr2, dtdatainu(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS), 
                 dtdataout3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS), dtenable2(i), dtwrite2(i),
            testin
            );
        end generate;
       end generate;
       fast : if DSNOOPFAST generate
        mdt0 : for i in 0 to DSETS-1 generate
          dtags0 : syncram_2p
          generic map (tech, DOFFSET_BITS, DTWIDTH-dlinesize+1, 0, 1, testen, 0, memtest_vlen) port map (
            clk, dtenable(i), dtaddr, dtdataout(i)(DTWIDTH-1 downto dlinesize-1),
            sclk, dtwrite2(i), dtaddr3, dtdatain(i)(DTWIDTH-1 downto dlinesize-1), testin
            );
          dtags1 : syncram_2p
          generic map (tech, DOFFSET_BITS, DPTAG_RAM_BITS, 0, 1, testen, 0, memtest_vlen) port map (
            sclk, dtenable2(i), dtaddr2, dtdataout3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS),
            clk, dtwrite3(i), dtaddr, dtdatain3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS),
            testin
            );
        end generate;
       end generate;


       hb : if DSNOOPHB generate
        mdt0 : for i in 0 to DSETS-1 generate
          dtags0 : syncram
          generic map (tech, DOFFSET_BITS, DTWIDTH-dlinesize, testen, memtest_vlen) port map (
            clk, dtaddr, dtdatain(i)(DTWIDTH-1 downto dlinesize),
                 dtdataout(i)(DTWIDTH-1 downto dlinesize), dtenable(i), dtwrite(i), testin
            );
          dtags1 : syncram
          generic map (tech, DOFFSET_BITS, DPTAG_RAM_BITS, testen, memtest_vlen) port map (
            sclk, dtaddr2, dtdatain3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS),
            dtdataout3(i)(DTAG_RAM_BITS-1 downto DTAG_BITS-DPTAG_BITS), dtenable(i), dtwrite3(i),
            testin
            );
          vbcwd(i) <= dtdatain(i)(dlinesize-1);
          dtdataout(i)(dlinesize-1) <= vbcrd(i);
        end generate;
        -- Valid bits in DFFs
        vb0: cmvalidbits
          generic map (abits => DOFFSET_BITS, nways => dsets)
          port map (
            clk => sclk,
            caddr => dtaddr,
            cenable => dtenable(0 to dsets-1),
            cwrite => dtwrite(0 to dsets-1),
            cwdata => vbcwd,
            crdata => vbcrd,
            saddr => crami.dcramin.snhitaddr(DOFFSET_BITS-1 downto 0),
            sclear => crami.dcramin.snhit(0 to dsets-1),
            flush => crami.dcramin.flushall
            );
       end generate;
      end generate;

    end generate;
    nodtags1 : if DSNOOP = 0 generate
      dt0 : for i in 0 to DSETS-1 generate
        dtdataout2(i)(DTWIDTH-1 downto 0) <= zero64(DTWIDTH-1 downto 0);
      end generate;
    end generate;

    dd0 : for i in 0 to DSETS-1 generate
      ddata0 : syncram
       generic map (tech, DOFFSET_BITS+DLINE_BITS, DDWIDTH, testen, memtest_vlen)
        port map (clk, ddaddr, dddatain(i), dddataout(i), ddenable(i), ddwrite(i), testin
                  );
      dtdataout(i)(DTWIDTH) <= '0';
    end generate;
    
  end generate;

  nohb : if dcen = 0 or not DSNOOPHB generate
    vbcwd <= (others => '0');
    vbcrd <= (others => '0');
  end generate;

  dmd : if dcen = 0 generate
    dnd0 : for i in 0 to DSETS-1 generate
      dtdataout(i) <= (others => '0');
      dtdataout2(i) <= (others => '0');
      dddataout(i) <= (others => '0');
    end generate;
  end generate;

  ldxs0 : if not ((dlram /= 0) and (DSETS > 1)) generate
    lddatain <= dddatain(0)(31 downto 0);    
  end generate;
  
  ldxs1 : if (dlram /= 0) and (DSETS > 1) generate
    lddatain <= dddatain(1)(31 downto 0);    
  end generate;

  ld0 : if dlram /= 0 generate
    ldata0 : syncram
     generic map (tech, DLRAM_BITS-2, 32, testen, memtest_vlen)
      port map (clk, ldaddr, lddatain, ldataout, crami.dcramin.ldramin.enable,
                crami.dcramin.ldramin.write, testin
                );
  end generate;

  itx : for i in 0 to ISETS-1 generate
    cramo.icramo.tag(i)(TAG_HIGH downto ITAG_LOW) <= itdataout(i)(ITAG_BITS-1 downto (ITAG_BITS-1) - (TAG_HIGH - ITAG_LOW));
    --(ITWIDTH-1-(ILRR_BIT+ICLOCK_BIT) downto ITWIDTH-(TAG_HIGH-ITAG_LOW)-(ILRR_BIT+ICLOCK_BIT)-1);    
    cramo.icramo.tag(i)(ilinesize-1 downto 0) <= itdataout(i)(ilinesize-1 downto 0);
    cramo.icramo.tag(i)(CTAG_LRRPOS) <= itdataout(i)(ITLRR_BIT_POS);
    cramo.icramo.tag(i)(CTAG_LOCKPOS) <= itdataout(i)(ITLOCK_BIT_POS);     
    ictx : if mmuen = 1 generate
      cramo.icramo.ctx(i) <= itdataout(i)(ITMMU_VEC_U downto ITMMU_VEC_D);
    end generate;
    noictx : if mmuen = 0 generate
      cramo.icramo.ctx(i) <= (others => '0');
    end generate;
    cramo.icramo.data(i) <= ildataout when (ilram /= 0) and ((ISETS = 1) or (i = 1)) and (crami.icramin.ldramin.read = '1') else iddataout(i)(31 downto 0);
    itv : if ilinesize = 4 generate
      cramo.icramo.tag(i)(7 downto 4) <= (others => '0');
    end generate;
    ite : for j in 10 to ITAG_LOW-1 generate
      cramo.icramo.tag(i)(j) <= '0';
    end generate;       
  end generate;

  itx2 : for i in ISETS to MAXSETS-1 generate
    cramo.icramo.tag(i) <= (others => '0');
    cramo.icramo.data(i) <= (others => '0');
    cramo.icramo.ctx(i) <= (others => '0');
  end generate;


  itd : for i in 0 to DSETS-1 generate
    cramo.dcramo.tag(i)(TAG_HIGH downto DTAG_LOW) <= dtdataout(i)(DTAG_BITS-1 downto (DTAG_BITS-1) - (TAG_HIGH - DTAG_LOW));
--    cramo.dcramo.tag(i)(dlinesize-1 downto 0) <= dtdataout(i)(dlinesize-1 downto 0);
    cramo.dcramo.tag(i)(dlinesize-1 downto 0) <= (others => dtdataout(i)(dlinesize-1));
    cramo.dcramo.tag(i)(CTAG_LRRPOS) <= dtdataout(i)(DTLRR_BIT_POS);
    cramo.dcramo.tag(i)(CTAG_LOCKPOS) <= dtdataout(i)(DTLOCK_BIT_POS);     
    dctx : if mmuen /= 0 generate
      cramo.dcramo.ctx(i) <= dtdataout(i)(DTMMU_VEC_U downto DTMMU_VEC_D);
    end generate;
    nodctx : if mmuen = 0 generate
      cramo.dcramo.ctx(i) <= (others => '0');
    end generate;
    
    stagv : if DSNOOPSEP generate
      cramo.dcramo.stag(i)(TAG_HIGH downto DTAG_LOW) <= dtdataout3(i)(DTAG_BITS-1 downto (DTAG_BITS-1) - (TAG_HIGH - DTAG_LOW));
      cramo.dcramo.stag(i)(DTAG_LOW-1 downto 0) <= (others =>'0');
    end generate;
    stagp : if not DSNOOPSEP generate
      cramo.dcramo.stag(i)(TAG_HIGH downto DTAG_LOW) <= dtdataout2(i)(DTAG_BITS-1 downto (DTAG_BITS-1) - (TAG_HIGH - DTAG_LOW));
      cramo.dcramo.stag(i)(DTAG_LOW-1 downto 0) <= (others =>'0');
    end generate;
    
    cramo.dcramo.data(i) <= ldataout when (dlram /= 0) and ((DSETS = 1) or (i = 1)) and (crami.dcramin.ldramin.read = '1')
    else dddataout(i)(31 downto 0);
    dtv : if dlinesize = 4 generate
      cramo.dcramo.tag(i)(7 downto 4) <= (others => '0');
    end generate;
    dte : for j in 10 to DTAG_LOW-1 generate
      cramo.dcramo.tag(i)(j) <= '0';
    end generate;
  end generate;

  itd2 : for i in DSETS to MAXSETS-1 generate
    cramo.dcramo.tag(i) <= (others => '0');
    cramo.dcramo.stag(i) <= (others => '0');
    cramo.dcramo.data(i) <= (others => '0');
    cramo.dcramo.ctx(i) <= (others => '0');
  end generate;

  noilr: if ilram=0 generate
    ildataout <= (others => '0');
  end generate;

  nodlr: if dlram=0 generate
    ldataout <= (others => '0');
  end generate;
end ;

