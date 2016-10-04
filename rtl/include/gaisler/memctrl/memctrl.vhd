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
-- Entity:  memctrl
-- File: memctrl.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Description:   Memory controller package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.log2;
use work.gencomp.all;

package memctrl is

type memory_in_type is record
  data          : std_logic_vector(31 downto 0); -- Data bus address
  brdyn         : std_logic;
  bexcn         : std_logic;
  writen        : std_logic;
  wrn           : std_logic_vector(3 downto 0);
  bwidth        : std_logic_vector(1 downto 0);
  sd            : std_logic_vector(63 downto 0);
  cb            : std_logic_vector(15 downto 0);
  scb           : std_logic_vector(15 downto 0);
  edac          : std_logic;
end record;

constant memory_in_none : memory_in_type :=
  ((others => '0'), '0', '0', '0', (others => '0'), (others => '0'),
   (others => '0'), (others => '0'), (others => '0'), '0');

type memory_out_type is record
  address       : std_logic_vector(31 downto 0);
  data          : std_logic_vector(31 downto 0);
  sddata        : std_logic_vector(63 downto 0);
  ramsn         : std_logic_vector(7 downto 0);
  ramoen        : std_logic_vector(7 downto 0);
  ramn          : std_ulogic;
  romn          : std_ulogic;
  mben          : std_logic_vector(3 downto 0);
  iosn          : std_logic;
  romsn         : std_logic_vector(7 downto 0);
  oen           : std_logic;
  writen        : std_logic;
  wrn           : std_logic_vector(3 downto 0);
  bdrive        : std_logic_vector(3 downto 0);
  vbdrive       : std_logic_vector(31 downto 0); --vector bus drive
  svbdrive      : std_logic_vector(63 downto 0); --vector bus drive sdram
  read          : std_logic;
  sa            : std_logic_vector(14 downto 0);
  cb            : std_logic_vector(15 downto 0);
  scb           : std_logic_vector(15 downto 0);
  vcdrive       : std_logic_vector(15 downto 0); --vector bus drive cb
  svcdrive      : std_logic_vector(15 downto 0); --vector bus drive cb sdram
  ce            : std_ulogic;
  sdram_en      : std_ulogic;                      -- SDRAM enabled
  rs_edac_en    : std_ulogic;                      -- Reed-Solomon enabled
end record;

constant memory_out_none : memory_out_type :=
  ((others => '0'), (others => '0'), (others => '0'), (others => '1'),
   (others => '1'), '1', '1', (others => '1'), '1', (others => '1'),
   '1', '1', (others => '1'), (others => '1'), (others => '1'),
   (others => '1'), '0', (others => '0'), (others => '1'), (others => '1'),
   (others => '1'), (others => '1'), '0', '0', '0');

type sdctrl_in_type is record
  wprot     : std_ulogic;
  data      : std_logic_vector (127 downto 0);  -- data in
  cb        : std_logic_vector(63 downto 0);  
  regrdata  : std_logic_vector(63 downto 0);  -- PHY-specific reg in
  datavalid : std_logic;                -- Data-valid signal
end record;

constant sdctrl_in_none : sdctrl_in_type :=
  ('0', (others => '0'), (others => '0'), (others => '0'), '0');

type sdctrl_out_type is record
  sdcke     : std_logic_vector ( 1 downto 0);  -- clk en
  sdcsn     : std_logic_vector ( 1 downto 0);  -- chip sel
  xsdcsn    : std_logic_vector ( 7 downto 0);  -- ext. chip sel
  sdwen     : std_ulogic;                       -- write en
  rasn      : std_ulogic;                       -- row addr stb
  casn      : std_ulogic;                       -- col addr stb
  dqm       : std_logic_vector ( 15 downto 0);  -- data i/o mask
  bdrive    : std_ulogic;                       -- bus drive
  qdrive    : std_ulogic;                       -- bus drive
  nbdrive   : std_ulogic;                      -- bdrive 1 cycle early
  vbdrive   : std_logic_vector(63 downto 0);   -- vector bus drive
  address   : std_logic_vector (16 downto 2);  -- address out
  data      : std_logic_vector (127 downto 0);  -- data out
  cb        : std_logic_vector(63 downto 0);
  ce        : std_ulogic;
  ba        : std_logic_vector (2 downto 0);  -- bank address
  sdck      : std_logic_vector(2 downto 0);
  moben     : std_logic;                       -- Mobile support
  cal_en    : std_logic_vector(7 downto 0); -- enable delay calibration
  cal_inc   : std_logic_vector(7 downto 0); -- inc/dec delay
  cal_pll   : std_logic_vector(1 downto 0); -- (enable,inc/dec) pll phase
  cal_rst   : std_logic;                    -- calibration reset
  odt       : std_logic_vector(1 downto 0); -- In Die Termination
  conf      : std_logic_vector(63 downto 0);
  oct       : std_logic;                    -- On Chip Termination
  vcbdrive  : std_logic_vector(31 downto 0);   -- cb vector bus drive
  dqs_gate  : std_logic;
  cbdqm     : std_logic_vector(7 downto 0);
  cbcal_en  : std_logic_vector(3 downto 0);
  cbcal_inc : std_logic_vector(3 downto 0);
  read_pend : std_logic_vector(7 downto 0);  -- Read pending within 7...0
                                             -- cycles (not including phy delays)
  -- PHY-specific register interface
  regwdata  : std_logic_vector(63 downto 0);
  regwrite  : std_logic_vector(1 downto 0);
end record;

constant sdctrl_out_none : sdctrl_out_type :=
  ((others => '0'), (others => '1'), (others => '1'), '0', '0', '0', (others => '0'),
   '0', '0', '0', (others => '0'), (others => '0'), (others => '0'),
   (others => '0'), '0', (others => '0'), (others => '0'), '0',
   (others => '0'), (others => '0'), (others => '0'), '0',
   (others => '0'), (others => '0'), '0', (others => '0'), '0',
   (others => '0'), (others => '0'), (others => '0'), "00000000",
   (others => '0'), "00");

type sdram_out_type is record
  sdcke     : std_logic_vector ( 1 downto 0);  -- clk en
  sdcsn     : std_logic_vector ( 1 downto 0);  -- chip sel
  sdwen     : std_ulogic;                       -- write en
  rasn      : std_ulogic;                       -- row addr stb
  casn      : std_ulogic;                       -- col addr stb
  dqm       : std_logic_vector ( 7 downto 0);  -- data i/o mask
end record;
constant sdram_out_none : sdram_out_type := (
  sdcke => (others => '0'),
  sdcsn => (others => '0'),
  sdwen => '0',
  rasn  => '0',
  casn  => '0',
  dqm   => (others => '0'));

type zbtssram_out_type is record
  cen       : std_ulogic;
  oen       : std_ulogic;
  wen       : std_ulogic;
  advld     : std_ulogic;
  addr      : std_logic_vector(22 downto 0);
  bwn       : std_logic_vector(15 downto 0);
  data      : std_logic_vector(127 downto 0);
  dqoen     : std_logic_vector(127 downto 0);
  zz        : std_ulogic;
  shutdown  : std_ulogic;
end record;

constant zbtssram_out_none : zbtssram_out_type := (
  '1','1','1','1',(others => '0'),(others => '1'),(others => '0'),(others => '1'),'0','0');

type zbtssram_in_type is record
  data      : std_logic_vector(127 downto 0);
  mbe       : std_logic_vector(7 downto 0);
end record;

constant zbtssram_in_none : zbtssram_in_type := ( data => (others => '0'), mbe => (others => '0') );

component sdctrl
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    wprot   : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    pwron   : integer := 0;
    sdbits  : integer := 32;
    oepol   : integer := 0;
    pageburst : integer := 0;
    mobile  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    sdi    : in  sdctrl_in_type;
    sdo    : out sdctrl_out_type
  );
end component;

component sdctrl64
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    wprot   : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    pwron   : integer := 0;
    oepol   : integer := 0;
    pageburst : integer := 0;
    mobile  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    sdi    : in  sdctrl_in_type;
    sdo    : out sdctrl_out_type
  );
end component;

component ftsdctrl is
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    wprot   : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    pwron   : integer := 0;
    sdbits  : integer := 32;
    edacen  : integer := 1;
    errcnt  : integer := 0;
    cntbits : integer range 1 to 8 := 1;
    oepol   : integer := 0;
    pageburst : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sdi     : in  sdctrl_in_type;
    sdo     : out sdctrl_out_type
  );
end component;

component ftsdctrl64
  generic (
    hindex  : integer := 0;
    haddr   : integer := 0;
    hmask   : integer := 16#f00#;
    ioaddr  : integer := 16#000#;
    iomask  : integer := 16#fff#;
    wprot   : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    pwron   : integer := 0;
    oepol   : integer := 0;
    pageburst : integer := 0;
    mobile  : integer := 0;
    edac    : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sdi     : in  sdctrl_in_type;
    sdo     : out sdctrl_out_type
  );
end component;

component srctrl
  generic (
    hindex  : integer := 0;
    romaddr : integer := 0;
    rommask : integer := 16#ff0#;
    ramaddr : integer := 16#400#;
    rammask : integer := 16#ff0#;
    ioaddr  : integer := 16#200#;
    iomask  : integer := 16#ff0#;
    ramws   : integer := 0;
    romws   : integer := 2;
    iows    : integer := 2;
    rmw     : integer := 0;
    prom8en : integer := 0;
    oepol   : integer := 0;
    srbanks : integer range 1 to 5 := 1;
    banksz  : integer range 0 to 13 := 13;
    romasel : integer range 0 to 28 := 19
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sri     : in  memory_in_type;
    sro     : out memory_out_type;
    sdo     : out sdctrl_out_type
  );
end component;

component ftsrctrl is
  generic (
    hindex       : integer := 0;
    romaddr      : integer := 0;
    rommask      : integer := 16#ff0#;
    ramaddr      : integer := 16#400#;
    rammask      : integer := 16#ff0#;
    ioaddr       : integer := 16#200#;
    iomask       : integer := 16#ff0#;
    ramws        : integer := 0;
    romws        : integer := 2;
    iows         : integer := 2;
    rmw          : integer := 0;
    srbanks      : integer range 1 to 8  := 1;
    banksz       : integer range 0 to 15 := 15;
    rombanks     : integer range 1 to 8  := 1;
    rombanksz    : integer range 0 to 15 := 15;
    rombankszdef : integer range 0 to 15 := 15;
    pindex       : integer := 0;
    paddr        : integer := 0;
    pmask        : integer := 16#fff#;
    edacen       : integer range 0 to 1 := 1;
    errcnt       : integer range 0 to 1 := 0;   
    cntbits      : integer range 1 to 8 := 1;
    wsreg        : integer := 0;
    oepol        : integer := 0;
    prom8en      : integer := 0;
    netlist      : integer := 0;
    tech         : integer := 0
  );
  port (
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    ahbsi        : in  ahb_slv_in_type;
    ahbso        : out ahb_slv_out_type;
    apbi         : in  apb_slv_in_type;
    apbo         : out apb_slv_out_type;
    sri          : in  memory_in_type;
    sro          : out memory_out_type;
    sdo          : out sdctrl_out_type
  );
end component; 

type sdram_in_type is record
  haddr         : std_logic_vector(31 downto 0);  -- memory address
  rhaddr        : std_logic_vector(31 downto 0);  -- latched memory address
  hready        : std_ulogic;
  hsize         : std_logic_vector(1 downto 0);
  hsel          : std_ulogic;
  hwrite        : std_ulogic;
  htrans        : std_logic_vector(1 downto 0);
  rhtrans       : std_logic_vector(1 downto 0);
  nhtrans       : std_logic_vector(1 downto 0);
  idle      : std_ulogic;
  enable    : std_ulogic;
  error     : std_ulogic;
  merror    : std_ulogic;
  brmw      : std_ulogic;
  edac      : std_ulogic;
  srdis         : std_logic;
end record;

type sdram_mctrl_out_type is record
  address       : std_logic_vector(16 downto 2);
  busy          : std_ulogic;
  aload         : std_ulogic;
  bdrive        : std_ulogic;
  hready        : std_ulogic;
  hsel          : std_ulogic;
  bsel          : std_ulogic;
  hresp     	: std_logic_vector (1 downto 0);
  vhready       : std_ulogic;
  prdata    	: std_logic_vector (31 downto 0);
end record;

type wprot_out_type is record
  wprothit      : std_ulogic;
end record;

component sdmctrl
  generic (
    pindex  : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    wprot   : integer := 0;
    sdbits  : integer := 32;
    pageburst : integer := 0;
    mobile  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    sdi    : in  sdram_in_type;
    sdo    : out sdram_out_type;
    apbi   : in  apb_slv_in_type;
    wpo    : in  wprot_out_type;
    sdmo   : out sdram_mctrl_out_type
  );
end component;

component ftsdmctrl
  generic (
    pindex  : integer := 0;
    invclk  : integer := 0;
    fast    : integer := 0;
    wprot   : integer := 0;
    sdbits  : integer := 32;
    syncrst : integer := 0;
    pageburst : integer := 0;
    edac    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    sdi    : in  sdram_in_type;
    sdo    : out sdram_out_type;
    apbi   : in  apb_slv_in_type;
    wpo    : in  wprot_out_type;
    sdmo   : out sdram_mctrl_out_type
  );
end component;

component ftmctrl
  generic (
    hindex    : integer := 0;
    pindex    : integer := 0;
    romaddr   : integer := 16#000#;
    rommask   : integer := 16#E00#;
    ioaddr    : integer := 16#200#;
    iomask    : integer := 16#E00#;
    ramaddr   : integer := 16#400#;
    rammask   : integer := 16#C00#;
    paddr     : integer := 0;
    pmask     : integer := 16#fff#;
    wprot     : integer := 0;
    invclk    : integer := 0;
    fast      : integer := 0;
    romasel   : integer := 28;
    sdrasel   : integer := 29;
    srbanks   : integer := 4;
    ram8      : integer := 0;
    ram16     : integer := 0;
    sden      : integer := 0;
    sepbus    : integer := 0;
    sdbits    : integer := 32;
    sdlsb     : integer := 2;          -- set to 12 for the GE-HPE board
    oepol     : integer := 0;
    edac      : integer := 0;
    syncrst   : integer := 0;
    pageburst : integer := 0;
    scantest  : integer := 0;
    writefb   : integer := 0;
    netlist   : integer := 0;
    tech      : integer := 0;
    rahold    : integer := 0;
    wsshift   : integer := 0;
    brdynto   : integer := 0
  );
  port (
    rst       : in  std_ulogic;
    clk       : in  std_ulogic;
    memi      : in  memory_in_type;
    memo      : out memory_out_type;
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    apbi      : in  apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    wpo       : in  wprot_out_type;
    sdo       : out sdram_out_type
  );
end component;

component ssrctrl
  generic (
    hindex  : integer := 0;
    pindex  : integer := 0;
    romaddr : integer := 0;
    rommask : integer := 16#ff0#;
    ramaddr : integer := 16#400#;
    rammask : integer := 16#ff0#;
    ioaddr  : integer := 16#200#;
    iomask  : integer := 16#ff0#;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    oepol   : integer := 0;
    bus16   : integer := 0
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    sri     : in  memory_in_type;
    sro     : out memory_out_type

  );
end component;

component ftsrctrl_v1
  generic (
      hindex:                 Integer := 1;
      romaddr:                Integer := 16#000#;
      rommask:                Integer := 16#ff0#;
      ramaddr:                Integer := 16#400#;
      rammask:                Integer := 16#ff0#;
      ioaddr:                 Integer := 16#200#;
      iomask:                 Integer := 16#ff0#;
      ramws:                  Integer := 0;
      romws:                  Integer := 0;
      iows:                   Integer := 0;
      rmw:                    Integer := 1;
      srbanks:                Integer range 1 to 8  := 8;
      banksz:                 Integer range 0 to 13 := 0;
      rombanks:               Integer range 1 to 8  := 8;
      rombanksz:              Integer range 0 to 13 := 0;
      rombankszdef:           Integer range 0 to 13 := 6;
      romasel:                Integer range 0 to 28 := 0;
      pindex:                 Integer := 0;
      paddr:                  Integer := 16#000#;
      pmask:                  Integer := 16#fff#;
      edacen:                 Integer range 0 to 1 := 1;
      errcnt:                 Integer range 0 to 1 := 0;
      cntbits:                Integer range 1 to 8 := 1;
      wsreg:                  Integer := 1;
      oepol:                  Integer := 0);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    sri    : in  memory_in_type;
    sro    : out memory_out_type;
    sdo    : out sdctrl_out_type
  );
end component;
  
  component ftsrctrl8 is
  generic (
    hindex       : integer := 0;
    ramaddr      : integer := 16#400#;
    rammask      : integer := 16#ff0#;
    ioaddr       : integer := 16#200#;
    iomask       : integer := 16#ff0#;
    ramws        : integer := 0;
    iows         : integer := 2;
    srbanks      : integer range 1 to 8  := 1;
    banksz       : integer range 0 to 15 := 15;
    pindex       : integer := 0;
    paddr        : integer := 0;
    pmask        : integer := 16#fff#;
    edacen       : integer range 0 to 1 := 1;
    errcnt       : integer range 0 to 1 := 1;   
    cntbits      : integer range 1 to 8 := 1;
    wsreg        : integer := 0;
    oepol        : integer := 0
    
  );
  port (
    rst          : in  std_ulogic;
    clk          : in  std_ulogic;
    ahbsi        : in  ahb_slv_in_type;
    ahbso        : out ahb_slv_out_type;
    apbi         : in  apb_slv_in_type;
    apbo         : out apb_slv_out_type;
    sri          : in  memory_in_type;
    sro          : out memory_out_type
  );
  end component; 

  component p8ctrl
  generic (
    hindex  : integer := 0;
    romaddr : integer := 0;
    rommask : integer := 16#ff0#;
    ramaddr : integer := 0;
    iomask  : integer := 16#ff0#;
    ioaddr  : integer := 0;
    rammask : integer := 16#ff0#;
    romws   : integer := 15;
    ramws   : integer := 15;
    prom8en : integer := 0;
    rmw     : integer := 0;
    oepol   : integer := 0;
    romasel : integer range 0 to 28 := 23
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sri     : in  memory_in_type;
    sro     : out memory_out_type;
    sdo     : out sdctrl_out_type
  );
  end component;
  
end;

