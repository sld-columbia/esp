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
-- Package:     alltap
-- File:        alltap.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: JTAG Test Access Port (TAP) Controller component declaration
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package alltap is

component tap_gen 
  generic (
    irlen  : integer range 2 to 8 := 2;
    idcode : integer range 0 to 255 := 9;
    manf   : integer range 0 to 2047 := 804;
    part   : integer range 0 to 65535 := 0;
    ver    : integer range 0 to 15 := 0;
    trsten : integer range 0 to 1 := 1;    
    scantest : integer := 0;
    oepol  : integer := 1);
  port (
    trst        : in std_ulogic;
    tckp        : in std_ulogic;
    tckn        : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    tdo         : out std_ulogic;
    tapi_en1    : in std_ulogic;
    tapi_tdo1   : in std_ulogic;
    tapi_tdo2   : in std_ulogic;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0);
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;
    tapo_xsel1  : out std_ulogic;
    tapo_xsel2  : out std_ulogic;
    tapo_ninst  : out std_logic_vector(7 downto 0);
    tapo_iupd   : out std_ulogic;
    testen      : in std_ulogic := '0';
    testrst     : in std_ulogic := '1';
    testoen     : in std_ulogic := '0';
    tdoen       : out std_ulogic
    );
end component;

component virtex_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component virtex2_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component virtex4_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component virtex5_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component spartan3_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component altera_tap
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;  
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0);     
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic     
    );
end component;

component fusion_tap 
port (
     tck         : in std_ulogic;
     tms         : in std_ulogic;
     tdi         : in std_ulogic;
     trst        : in std_ulogic;
     tdo         : out std_ulogic;                      
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapi_en1    : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0)
    );
end component;

component proasic3_tap 
port (
     tck         : in std_ulogic;
     tms         : in std_ulogic;
     tdi         : in std_ulogic;
     trst        : in std_ulogic;
     tdo         : out std_ulogic;                      
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapi_en1    : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0)
    );
end component;

component proasic3e_tap 
port (
     tck         : in std_ulogic;
     tms         : in std_ulogic;
     tdi         : in std_ulogic;
     trst        : in std_ulogic;
     tdo         : out std_ulogic;                      
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapi_en1    : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0)
    );
end component;

component proasic3l_tap 
port (
     tck         : in std_ulogic;
     tms         : in std_ulogic;
     tdi         : in std_ulogic;
     trst        : in std_ulogic;
     tdo         : out std_ulogic;                      
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapi_en1    : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0)
    );
end component;

component virtex6_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component spartan6_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component virtex7_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component kintex7_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component artix7_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component zynq_tap 
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end component;

component igloo2_tap is
  port (
    tck         : in std_ulogic;
    tms         : in std_ulogic;
    tdi         : in std_ulogic;
    trst        : in std_ulogic;
    tdo         : out std_ulogic;                    
    tapi_tdo    : in std_ulogic;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0));
end component;


-------------------------------------------------------------------------------

component scanregi_inf
  generic (
    intesten : integer := 1
    );
  port (
    pad     : in std_ulogic;
    core    : out std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bsupd   : in std_ulogic;    -- update data reg from scan reg on next tck edge
    bsdrive : in std_ulogic;     -- drive data reg to core
    bshighz : in std_ulogic
    );
end component;

component scanrego_inf
  port (
    pad     : out std_ulogic;
    core    : in std_ulogic;
    samp    : in std_ulogic;    -- normally same as core unless outpad has feedback
    tck     : in std_ulogic;   
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;    -- capture signal to scan reg on next tck edge
    bsupd   : in std_ulogic;    -- update data reg from scan reg on next tck edge
    bsdrive : in std_ulogic     -- drive data reg to pad
    );
end component;

component scanregio_inf -- 3 scan registers: tdo<--input<--output<--outputen<--tdi
  generic (
    hzsup   : integer range 0 to 1 := 1;
    intesten: integer := 1
    );
  port (
    pado    : out std_ulogic;
    padoen  : out std_ulogic;
    padi    : in std_ulogic;
    coreo   : in std_ulogic;
    coreoen : in std_ulogic;
    corei   : out std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;    -- capture signals to scan regs on next tck edge
    bsupdi  : in std_ulogic;    -- update indata reg from scan reg on next tck edge
    bsupdo  : in std_ulogic;    -- update outdata reg from scan reg on next tck edge
    bsdrive : in std_ulogic;    -- drive outdata regs to pad,
                                -- drive datareg(coreoen=0) or coreo(coreoen=1) to corei
    bshighz : in std_ulogic
    );
end component;


end;

