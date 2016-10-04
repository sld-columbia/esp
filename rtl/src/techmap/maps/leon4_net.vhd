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
library  ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

entity leon4_net is
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63  := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 2  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    cached    : integer               := 0;
    scantest  : integer               := 0
  );

   port (
      clk     : in  std_ulogic;
      gclk    : in  std_ulogic;
      hclken  : in  std_ulogic;
      rstn    : in  std_ulogic;
      ahbix   : in  ahb_mst_in_type;
      ahbox   : out ahb_mst_out_type;
      ahbsix  : in  ahb_slv_in_type;
      ahbso   : in  ahb_slv_out_vector;
      irqi_irl:         in    std_logic_vector(3 downto 0);
      irqi_rst:         in    std_ulogic;
      irqi_run:         in    std_ulogic;
      irqi_rstvec:      in    std_logic_vector(31 downto 12);
      irqi_iact:        in    std_ulogic;
      irqi_index:       in    std_logic_vector(3 downto 0);
      irqi_hrdrst:      in    std_ulogic;

      irqo_intack:      out   std_ulogic;
      irqo_irl:         out   std_logic_vector(3 downto 0);
      irqo_pwd:         out   std_ulogic;
      irqo_fpen:        out   std_ulogic;
      irqo_idle:        out   std_ulogic;

      dbgi_dsuen:       in    std_ulogic;                               -- DSU enable
      dbgi_denable:     in    std_ulogic;                               -- diagnostic register access enable
      dbgi_dbreak:      in    std_ulogic;                               -- debug break-in
      dbgi_step:        in    std_ulogic;                               -- single step
      dbgi_halt:        in    std_ulogic;                               -- halt processor
      dbgi_reset:       in    std_ulogic;                               -- reset processor
      dbgi_dwrite:      in    std_ulogic;                               -- read/write
      dbgi_daddr:       in    std_logic_vector(23 downto 2);            -- diagnostic address
      dbgi_ddata:       in    std_logic_vector(31 downto 0);            -- diagnostic data
      dbgi_btrapa:      in    std_ulogic;                               -- break on IU trap
      dbgi_btrape:      in    std_ulogic;                               -- break on IU trap
      dbgi_berror:      in    std_ulogic;                               -- break on IU error mode
      dbgi_bwatch:      in    std_ulogic;                               -- break on IU watchpoint
      dbgi_bsoft:       in    std_ulogic;                               -- break on software breakpoint (TA 1)
      dbgi_tenable:     in    std_ulogic;
      dbgi_timer:       in    std_logic_vector(63 downto 0);

      dbgo_data:        out   std_logic_vector(31 downto 0);
      dbgo_crdy:        out   std_ulogic;
      dbgo_dsu:         out   std_ulogic;
      dbgo_dsumode:     out   std_ulogic;
      dbgo_error:       out   std_ulogic;
      dbgo_halt:        out   std_ulogic;
      dbgo_pwd:         out   std_ulogic;
      dbgo_idle:        out   std_ulogic;
      dbgo_ipend:       out   std_ulogic;
      dbgo_icnt:        out   std_ulogic;
      dbgo_fcnt    : 	out   std_ulogic;
      dbgo_optype  : 	out   std_logic_vector(5 downto 0);	-- instruction type
      dbgo_bpmiss  : 	out   std_ulogic;			-- branch predict miss
      dbgo_istat_cmiss:  out   std_ulogic;
      dbgo_istat_tmiss:  out   std_ulogic;
      dbgo_istat_chold:  out   std_ulogic;
      dbgo_istat_mhold:  out   std_ulogic;
      dbgo_dstat_cmiss:  out   std_ulogic;
      dbgo_dstat_tmiss:  out   std_ulogic;
      dbgo_dstat_chold:  out   std_ulogic;
      dbgo_dstat_mhold:  out   std_ulogic;
      dbgo_wbhold  : 	out   std_ulogic;			-- write buffer hold
      dbgo_su      : 	out   std_ulogic;
      dbgo_ducnt   :    out   std_ulogic);
end ;

architecture rtl of leon4_net is

signal disasen : std_ulogic;

 component leon4_ut90nhbd
  generic (
    hindex    : integer               := 0;
    fabtech   : integer range 0 to NTECH  := DEFFABTECH;
    memtech   : integer range 0 to NTECH  := DEFMEMTECH;
    nwindows  : integer range 2 to 32 := 8;
    dsu       : integer range 0 to 1  := 0;
    fpu       : integer range 0 to 31 := 0;
    v8        : integer range 0 to 63 := 0;
    cp        : integer range 0 to 1  := 0;
    mac       : integer range 0 to 1  := 0;
    pclow     : integer range 0 to 2  := 2;
    notag     : integer range 0 to 1  := 0;
    nwp       : integer range 0 to 4  := 0;
    icen      : integer range 0 to 1  := 0;
    irepl     : integer range 0 to 2  := 2;
    isets     : integer range 1 to 4  := 1;
    ilinesize : integer range 4 to 8  := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1  := 0;
    dcen      : integer range 0 to 1  := 0;
    drepl     : integer range 0 to 2  := 2;
    dsets     : integer range 1 to 4  := 1;
    dlinesize : integer range 4 to 8  := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1  := 0;
    dsnoop    : integer range 0 to 6  := 0;
    ilram      : integer range 0 to 1 := 0;
    ilramsize  : integer range 1 to 512 := 1;
    ilramstart : integer range 0 to 255 := 16#8e#;
    dlram      : integer range 0 to 1 := 0;
    dlramsize  : integer range 1 to 512 := 1;
    dlramstart : integer range 0 to 255 := 16#8f#;
    mmuen     : integer range 0 to 1  := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 1  := 1;
    tlb_rep   : integer range 0 to 1  := 0;
    lddel     : integer range 1 to 2  := 2;
    disas     : integer range 0 to 1  := 0;
    tbuf      : integer range 0 to 64 := 0;
    pwd       : integer range 0 to 2  := 2;     -- power-down
    svt       : integer range 0 to 1  := 1;     -- single vector trapping
    rstaddr   : integer               := 0;
    smp       : integer range 0 to 31 := 0;    -- support SMP systems
    iuft      : integer range 0 to 4  := 0;
    fpft      : integer range 0 to 4  := 0;
    cmft      : integer range 0 to 1  := 0;
    cached    : integer               := 0;
    scantest  : integer               := 0
  );

   port (
      clk:              in    std_ulogic;
      gclk:             in    std_ulogic;
      hclken:           in    std_ulogic;
      rstn:             in    std_ulogic;

      ahbi_hgrant:      in    std_logic_vector(0 to NAHBMST-1);         -- bus grant
      ahbi_hready:      in    std_ulogic;                               -- transfer done
      ahbi_hresp:       in    std_logic_vector(1 downto 0);             -- response type
      ahbi_hrdata:      in    std_logic_vector(127 downto 0);            -- read data bus
      ahbi_hirq:        in    std_logic_vector(NAHBIRQ-1 downto 0);     -- interrupt result bus
      ahbi_testen:      in    std_ulogic;
      ahbi_testrst:     in    std_ulogic;
      ahbi_scanen:      in    std_ulogic;
      ahbi_testoen:     in    std_ulogic;

      ahbo_hbusreq:     out   std_ulogic;                               -- bus request
      ahbo_hlock:       out   std_ulogic;                               -- lock request
      ahbo_htrans:      out   std_logic_vector(1 downto 0);             -- transfer type
      ahbo_haddr:       out   std_logic_vector(31 downto 0);            -- address bus (byte)
      ahbo_hwrite:      out   std_ulogic;                               -- read/write
      ahbo_hsize:       out   std_logic_vector(2 downto 0);             -- transfer size
      ahbo_hburst:      out   std_logic_vector(2 downto 0);             -- burst type
      ahbo_hprot:       out   std_logic_vector(3 downto 0);             -- protection control
      ahbo_hwdata:      out   std_logic_vector(127 downto 0);            -- write data bus
      ahbo_hirq:        out   std_logic_vector(NAHBIRQ-1 downto 0);     -- interrupt bus

      ahbsi_hsel:       in    std_logic_vector(0 to NAHBSLV-1);         -- slave select
      ahbsi_haddr:      in    std_logic_vector(31 downto 0);            -- address bus (byte)
      ahbsi_hwrite:     in    std_ulogic;                               -- read/write
      ahbsi_htrans:     in    std_logic_vector(1 downto 0);             -- transfer type
      ahbsi_hsize:      in    std_logic_vector(2 downto 0);             -- transfer size
      ahbsi_hburst:     in    std_logic_vector(2 downto 0);             -- burst type
      ahbsi_hwdata:     in    std_logic_vector(127 downto 0);            -- write data bus
      ahbsi_hprot:      in    std_logic_vector(3 downto 0);             -- protection control
      ahbsi_hready:     in    std_ulogic;                               -- transfer done
      ahbsi_hmaster:    in    std_logic_vector(3 downto 0);             -- current master
      ahbsi_hmastlock:  in    std_ulogic;                               -- locked access
      ahbsi_hmbsel:     in    std_logic_vector(0 to NAHBAMR-1);         -- memory bank select
      ahbsi_hirq:       in    std_logic_vector(NAHBIRQ-1 downto 0);     -- interrupt result bus

      irqi_irl:         in    std_logic_vector(3 downto 0);
      irqi_rst:         in    std_ulogic;
      irqi_run:         in    std_ulogic;
      irqi_rstvec:      in    std_logic_vector(31 downto 12);
      irqi_iact:        in    std_ulogic;
      irqi_index:       in    std_logic_vector(3 downto 0);

      irqo_intack:      out   std_ulogic;
      irqo_irl:         out   std_logic_vector(3 downto 0);
      irqo_pwd:         out   std_ulogic;
      irqo_fpen:        out   std_ulogic;
      irqo_idle:        out   std_ulogic;
      
      dbgi_dsuen:       in    std_ulogic;                               -- DSU enable
      dbgi_denable:     in    std_ulogic;                               -- diagnostic register access enable
      dbgi_dbreak:      in    std_ulogic;                               -- debug break-in
      dbgi_step:        in    std_ulogic;                               -- single step
      dbgi_halt:        in    std_ulogic;                               -- halt processor
      dbgi_reset:       in    std_ulogic;                               -- reset processor
      dbgi_dwrite:      in    std_ulogic;                               -- read/write
      dbgi_daddr:       in    std_logic_vector(23 downto 2);            -- diagnostic address
      dbgi_ddata:       in    std_logic_vector(31 downto 0);            -- diagnostic data
      dbgi_btrapa:      in    std_ulogic;                               -- break on IU trap
      dbgi_btrape:      in    std_ulogic;                               -- break on IU trap
      dbgi_berror:      in    std_ulogic;                               -- break on IU error mode
      dbgi_bwatch:      in    std_ulogic;                               -- break on IU watchpoint
      dbgi_bsoft:       in    std_ulogic;                               -- break on software breakpoint (TA 1)
      dbgi_tenable:     in    std_ulogic;
      dbgi_timer:       in    std_logic_vector(30 downto 0);

      dbgo_data:        out   std_logic_vector(31 downto 0);
      dbgo_crdy:        out   std_ulogic;
      dbgo_dsu:         out   std_ulogic;
      dbgo_dsumode:     out   std_ulogic;
      dbgo_error:       out   std_ulogic;
      dbgo_halt:        out   std_ulogic;
      dbgo_pwd:         out   std_ulogic;
      dbgo_idle:  	out   std_ulogic;
      dbgo_ipend: 	out   std_ulogic;
      dbgo_icnt:  	out   std_ulogic;
      dbgo_fcnt    : 	out   std_ulogic;
      dbgo_optype  : 	out   std_logic_vector(5 downto 0);	-- instruction type
      dbgo_bpmiss  : 	out   std_ulogic;			-- branch predict miss
      dbgo_istat_cmiss:  out   std_ulogic;
      dbgo_istat_tmiss:  out   std_ulogic;
      dbgo_istat_chold:  out   std_ulogic;
      dbgo_istat_mhold:  out   std_ulogic;
      dbgo_dstat_cmiss:  out   std_ulogic;
      dbgo_dstat_tmiss:  out   std_ulogic;
      dbgo_dstat_chold:  out   std_ulogic;
      dbgo_dstat_mhold:  out   std_ulogic;
      dbgo_wbhold  : 	out   std_ulogic;			-- write buffer hold
      dbgo_su      : 	out   std_ulogic;	
      disasen :         in    std_ulogic);
  end component;

   signal   ahbi_hgrant:      std_logic_vector(0 to NAHBMST-1);
   signal   ahbi_hready:      std_ulogic;
   signal   ahbi_hresp:       std_logic_vector(1 downto 0);
   signal   ahbi_hrdata:      std_logic_vector(127 downto 0);
   signal   ahbi_hirq:        std_logic_vector(NAHBIRQ-1 downto 0);
   signal   ahbi_testen:      std_ulogic;
   signal   ahbi_testrst:     std_ulogic;
   signal   ahbi_scanen:      std_ulogic;
   signal   ahbi_testoen:     std_ulogic;

   signal   ahbo_hbusreq:     std_ulogic;
   signal   ahbo_hlock:       std_ulogic;
   signal   ahbo_htrans:      std_logic_vector(1 downto 0);
   signal   ahbo_haddr:       std_logic_vector(31 downto 0);
   signal   ahbo_hwrite:      std_ulogic;
   signal   ahbo_hsize:       std_logic_vector(2 downto 0);
   signal   ahbo_hburst:      std_logic_vector(2 downto 0);
   signal   ahbo_hprot:       std_logic_vector(3 downto 0);
   signal   ahbo_hwdata:      std_logic_vector(127 downto 0);
   signal   ahbo_hirq:        std_logic_vector(NAHBIRQ-1 downto 0);

   signal   ahbsi_hsel:       std_logic_vector(0 to NAHBSLV-1);
   signal   ahbsi_haddr:      std_logic_vector(31 downto 0);
   signal   ahbsi_hwrite:     std_ulogic;
   signal   ahbsi_htrans:     std_logic_vector(1 downto 0);
   signal   ahbsi_hsize:      std_logic_vector(2 downto 0);
   signal   ahbsi_hburst:     std_logic_vector(2 downto 0);
   signal   ahbsi_hwdata:     std_logic_vector(127 downto 0);
   signal   ahbsi_hprot:      std_logic_vector(3 downto 0);
   signal   ahbsi_hready:     std_ulogic;
   signal   ahbsi_hmaster:    std_logic_vector(3 downto 0);
   signal   ahbsi_hmastlock:  std_ulogic;
   signal   ahbsi_hmbsel:     std_logic_vector(0 to NAHBAMR-1);
   signal   ahbsi_hirq:       std_logic_vector(NAHBIRQ-1 downto 0);

   constant hconfig: ahb_config_type := (
      0      => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LEON4, 0, 0, 0),
      others => zero32);

begin
  
   disasen <= '1' when disas /= 0 else '0';

   -- Plug&Play information
   ahbox.hconfig   <= hconfig;
   ahbox.hindex    <= hindex;

  ut09 : if fabtech = ut90 generate
      wrp: leon4_ut90nhbd
      generic map (fpu => fpu, v8 => v8, mmuen => mmuen, isets => isets, isetsize => isetsize, smp => smp)
      port map(
         clk               => clk,
         gclk              => gclk,
         hclken            => hclken,
         rstn              => rstn,
         ahbi_hgrant       => ahbi_hgrant,
         ahbi_hready       => ahbi_hready,
         ahbi_hresp        => ahbi_hresp,
         ahbi_hrdata       => ahbi_hrdata,
         ahbi_hirq         => ahbi_hirq,
         ahbi_testen       => ahbi_testen,
         ahbi_testrst      => ahbi_testrst,
         ahbi_scanen       => ahbi_scanen,
         ahbi_testoen      => ahbi_testoen,
         ahbo_hbusreq      => ahbo_hbusreq,
         ahbo_hlock        => ahbo_hlock,
         ahbo_htrans       => ahbo_htrans,
         ahbo_haddr        => ahbo_haddr,
         ahbo_hwrite       => ahbo_hwrite,
         ahbo_hsize        => ahbo_hsize,
         ahbo_hburst       => ahbo_hburst,
         ahbo_hprot        => ahbo_hprot,
         ahbo_hwdata       => ahbo_hwdata,
         ahbo_hirq         => ahbo_hirq,
         ahbsi_hsel        => ahbsi_hsel,
         ahbsi_haddr       => ahbsi_haddr,
         ahbsi_hwrite      => ahbsi_hwrite,
         ahbsi_htrans      => ahbsi_htrans,
         ahbsi_hsize       => ahbsi_hsize,
         ahbsi_hburst      => ahbsi_hburst,
         ahbsi_hwdata      => ahbsi_hwdata,
         ahbsi_hprot       => ahbsi_hprot,
         ahbsi_hready      => ahbsi_hready,
         ahbsi_hmaster     => ahbsi_hmaster,
         ahbsi_hmastlock   => ahbsi_hmastlock,
         ahbsi_hmbsel      => ahbsi_hmbsel,
         ahbsi_hirq        => ahbsi_hirq,
         irqi_irl          => irqi_irl,
         irqi_rst          => irqi_rst,
         irqi_run          => irqi_run,
         irqi_rstvec       => irqi_rstvec,
         irqi_iact         => irqi_iact,
         irqi_index        => irqi_index,
         irqo_intack       => irqo_intack,
         irqo_irl          => irqo_irl,
         irqo_pwd          => irqo_pwd,
         irqo_fpen         => irqo_fpen,
         irqo_idle         => irqo_idle,
         dbgi_dsuen        => dbgi_dsuen,
         dbgi_denable      => dbgi_denable,
         dbgi_dbreak       => dbgi_dbreak,
         dbgi_step         => dbgi_step,
         dbgi_halt         => dbgi_halt,
         dbgi_reset        => dbgi_reset,
         dbgi_dwrite       => dbgi_dwrite,
         dbgi_daddr        => dbgi_daddr,
         dbgi_ddata        => dbgi_ddata,
         dbgi_btrapa       => dbgi_btrapa,
         dbgi_btrape       => dbgi_btrape,
         dbgi_berror       => dbgi_berror,
         dbgi_bwatch       => dbgi_bwatch,
         dbgi_bsoft        => dbgi_bsoft,
         dbgi_tenable      => dbgi_tenable,
         dbgi_timer        => dbgi_timer(30 downto 0),
         dbgo_data         => dbgo_data,
         dbgo_crdy         => dbgo_crdy,
         dbgo_dsu          => dbgo_dsu,
         dbgo_dsumode      => dbgo_dsumode,
         dbgo_error        => dbgo_error,
         dbgo_halt         => dbgo_halt,
         dbgo_pwd          => dbgo_pwd,
         dbgo_idle         => dbgo_idle,
         dbgo_ipend        => dbgo_ipend,
         dbgo_icnt         => dbgo_icnt,

         dbgo_fcnt         => dbgo_fcnt,
         dbgo_optype         => dbgo_optype,
         dbgo_bpmiss         => dbgo_bpmiss,
         dbgo_istat_cmiss         => dbgo_istat_cmiss,
         dbgo_istat_tmiss         => dbgo_istat_tmiss,
         dbgo_istat_chold         => dbgo_istat_chold,
         dbgo_istat_mhold         => dbgo_istat_mhold,
         dbgo_dstat_cmiss         => dbgo_dstat_cmiss,
         dbgo_dstat_tmiss         => dbgo_dstat_tmiss,
         dbgo_dstat_chold         => dbgo_dstat_chold,
         dbgo_dstat_mhold         => dbgo_dstat_mhold,
         dbgo_wbhold         => dbgo_wbhold,
         dbgo_su         => dbgo_su,
         disasen           => disasen);
      dbgo_ducnt <= '1';
  end generate;

      ahbi_hgrant(0)       <= ahbix.hgrant(hindex);
      ahbi_hgrant(1 to NAHBMST-1) <= (others => '0');

      ahbi_hready       <= ahbix.hready;
      ahbi_hresp        <= ahbix.hresp;
      ahbi_hrdata(127 mod AHBDW downto 0) <= ahbix.hrdata(127 mod AHBDW downto 0);
      ahbi_hirq         <= ahbix.hirq;
      ahbi_testen       <= ahbix.testen;
      ahbi_testrst      <= ahbix.testrst;
      ahbi_scanen       <= ahbix.scanen;
      ahbi_testoen      <= ahbix.testoen;

      ahbox.hbusreq      <= ahbo_hbusreq;
      ahbox.hlock        <= ahbo_hlock;
      ahbox.htrans       <= ahbo_htrans;
      ahbox.haddr        <= ahbo_haddr;
      ahbox.hwrite       <= ahbo_hwrite;
      ahbox.hsize        <= ahbo_hsize(2 downto 0);
      ahbox.hburst       <= "00" & ahbo_hburst(0);
      ahbox.hprot        <= ahbo_hprot;
      ahbox.hwdata(127 mod AHBDW downto 0)       <= ahbo_hwdata(127 mod AHBDW downto 0);
      ahbox.hirq         <= (others => '0'); --ahbo_hirq;

      ahbsi_hsel        <= ahbsix.hsel;
      ahbsi_haddr       <= ahbsix.haddr;
      ahbsi_hwrite      <= ahbsix.hwrite;
      ahbsi_htrans      <= ahbsix.htrans;
      ahbsi_hsize       <= ahbsix.hsize;
      ahbsi_hburst      <= ahbsix.hburst;
      ahbsi_hwdata(127 mod AHBDW downto 0)      <= ahbsix.hwdata(127 mod AHBDW downto 0);
      ahbsi_hprot       <= ahbsix.hprot;
      ahbsi_hready      <= ahbsix.hready;
      ahbsi_hmaster     <= ahbsix.hmaster;
      ahbsi_hmastlock   <= ahbsix.hmastlock;
      ahbsi_hmbsel      <= ahbsix.hmbsel;
      ahbsi_hirq        <= ahbsix.hirq;


-- pragma translate_off
   assert NAHBSLV=16
      report "LEON4FT netlist: Only NAHBSLV=16 supported by wrapper"
      severity Failure;
-- pragma translate_on

end architecture;

