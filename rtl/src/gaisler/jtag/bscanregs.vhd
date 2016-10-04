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
-- Entity: 	bscanregs
-- File:	bscanregs.vhd
-- Author:	Magnus Hjorth - Aeroflex Gaisler
-- Description:	JTAG boundary scan registers, single-ended IO
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity bscanregs is
  generic (
    tech: integer := 0;
    nsigs: integer range 1 to 30 := 8;
    dirmask: integer := 2#00000000#;
    enable: integer range 0 to 1 := 1
    );
  port (
    sigi: in  std_logic_vector(nsigs-1 downto 0);
    sigo: out std_logic_vector(nsigs-1 downto 0);
    tck: in std_ulogic;
    tckn:in std_ulogic;
    tdi: in std_ulogic;
    tdo: out std_ulogic;
    bsshft: in std_ulogic;
    bscapt: in std_ulogic;
    bsupdi: in std_ulogic;
    bsupdo: in std_ulogic;
    bsdrive: in std_ulogic;
    bshighz: in std_ulogic
    );
end;

architecture hier of bscanregs is

  signal itdi: std_logic_vector(nsigs downto 0);
  
begin

  disgen: if enable=0 generate
    sigo <= sigi;
    itdi <= (others => '0');
    tdo <= '0';
  end generate;

  engen: if enable /= 0 generate
    
    g0: for x in 0 to nsigs-1 generate
      
      irgen: if ((dirmask / (2**x)) mod 2)=0 generate
        ireg: scanregi
          generic map (tech)
          port map (sigi(x),sigo(x),tck,tckn,itdi(x),itdi(x+1),bsshft,bscapt,bsupdi,bsdrive,bshighz);
      end generate;
      
      orgen: if ((dirmask / (2**x)) mod 2)/=0 generate
        oreg: scanrego
          generic map (tech)
          port map (sigo(x),sigi(x),sigi(x),tck,tckn,itdi(x),itdi(x+1),bsshft,bscapt,bsupdo,bsdrive);
      end generate;
      
    end generate;
    
    itdi(0) <= tdi;
    tdo <= itdi(nsigs);

  end generate;
    
end;
  

