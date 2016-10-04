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
-- Entity: 	bscanregsbd
-- File:	bscanregsbd.vhd
-- Author:	Magnus Hjorth - Aeroflex Gaisler
-- Description:	JTAG boundary scan registers, bi-directional IO
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity bscanregsbd is
  generic (
    tech: integer:= 0;
    nsigs: integer := 8;
    enable: integer range 0 to 1 := 1;
    hzsup: integer range 0 to 1 := 1
    );
  port (
    pado    : out std_logic_vector(nsigs-1 downto 0);
    padoen  : out std_logic_vector(nsigs-1 downto 0);
    padi    : in std_logic_vector(nsigs-1 downto 0);
    coreo   : in std_logic_vector(nsigs-1 downto 0);
    coreoen : in std_logic_vector(nsigs-1 downto 0);
    corei   : out std_logic_vector(nsigs-1 downto 0);
    
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
    bshighz : in std_ulogic     -- tri-state output
    );
end;

architecture rtl of bscanregsbd is
  signal ltdi: std_logic_vector(nsigs downto 0);
begin

  disgen: if enable = 0 generate
    pado <= coreo;
    padoen <= coreoen;
    corei <= padi;
    tdo <= '0';
    ltdi <= (others => '0');
  end generate;
  
  engen: if enable /= 0 generate
    
    g: for x in 0 to nsigs-1 generate
      r: scanregio
        generic map (tech,hzsup)
        port map (pado(x),padoen(x),padi(x),coreo(x),coreoen(x),corei(x),
                  tck,tckn,ltdi(x),ltdi(x+1),bsshft,bscapt,bscapt,bscapt,bsupdi,bsupdo,bsdrive,bshighz);
    end generate;
    
    ltdi(0) <= tdi;
    tdo <= ltdi(nsigs);

  end generate;
    
end;

