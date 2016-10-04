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
-- Entity: 	scanregi, scanrego, scanregio
-- File:	scanreg.vhd
-- Author:	Magnus Hjorth - Aeroflex Gaisler
-- Description:	Technology wrapper for boundary scan registers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.alltap.all;

entity scanregi is
  generic (
    tech : integer := 0;
    intesten: integer := 1
    );
  port (
    pad     : in std_ulogic;
    core    : out std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;
    bsupd   : in std_ulogic;
    bsdrive : in std_ulogic;
    bshighz : in std_ulogic
    );
end;

architecture tmap of scanregi is
signal d1, d2, q1, q2, m3i, o1o : std_ulogic;
begin

  gen0: if tech = 0 generate
    x: scanregi_inf generic map (intesten) port map (pad,core,tck,tckn,tdi,tdo,bsshft,bscapt,bsupd,bsdrive,bshighz);
  end generate;
  map0: if tech /= 0 generate
    iten: if intesten /= 0 generate
      m1 : grmux2 generic map (tech) port map (pad, q1, bsdrive, core);
      f1 : grdff  generic map (tech) port map (tckn, d1, q1);
      m2 : grmux2 generic map (tech) port map (q1, q2, bsupd, d1);
    end generate;
    itdis: if intesten = 0 generate
      core <= pad;
      q1 <= '0';
      d1 <= '0';
    end generate;
    m3 : grmux2 generic map (tech) port map (m3i, tdi, bsshft, d2);
    m4 : grmux2 generic map (tech) port map (q2, o1o, bscapt, m3i);
    o1 : gror2  generic map (tech) port map (pad, bshighz, o1o);
    f2 : grdff  generic map (tech) port map (tck, d2, q2);
    tdo <= q2;
  end generate;
  
end;
  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.alltap.all;

entity scanrego is
  generic (
    tech : integer := 0
    );
  port (
    pad     : out std_ulogic;
    core    : in std_ulogic;
    samp    : in std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapt  : in std_ulogic;
    bsupd   : in std_ulogic;
    bsdrive : in std_ulogic
    );
end;

architecture tmap of scanrego is
signal d1, d2, q1, q2, m3i, o1o : std_ulogic;

begin

  gen0: if tech = 0 generate
    x: scanrego_inf port map (pad,core,samp,tck,tckn,tdi,tdo,bsshft,bscapt,bsupd,bsdrive);
  end generate;
 
  map0: if tech /= 0 generate
    m1 : grmux2 generic map (tech) port map (core, q1, bsdrive, pad);
    m2 : grmux2 generic map (tech) port map (q1, q2, bsupd, d1);
    m3 : grmux2 generic map (tech) port map (m3i, tdi, bsshft, d2);
    m4 : grmux2 generic map (tech) port map (q2, samp, bscapt, m3i);
    f1 : grdff  generic map (tech) port map (tckn, d1, q1);
    f2 : grdff  generic map (tech) port map (tck, d2, q2);
    tdo <= q2;
  end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.alltap.all;

entity scanregto is
  generic (
    tech : integer := 0;
    hzsup: integer range 0 to 1 := 1;
    oepol: integer range 0 to 1 := 1;
    scantest: integer range 0 to 1 := 0
    );
  port (
    pado    : out std_ulogic;
    padoen  : out std_ulogic;
    samp    : in std_ulogic;
    coreo   : in std_ulogic;
    coreoen : in std_ulogic;
    tck     : in std_ulogic;
    tckn    : in std_ulogic;
    tdi     : in std_ulogic;
    tdo     : out std_ulogic;
    bsshft  : in std_ulogic;
    bscapto : in std_ulogic;
    bscaptoe: in std_ulogic;
    bsupdo  : in std_ulogic;
    bsdrive : in std_ulogic;
    bshighz : in std_ulogic;
    testen  : in std_ulogic;
    testoen : in std_ulogic
    );
end;

architecture tmap of scanregto is
signal tdo1, padoenx,padoenxx : std_ulogic;
begin

    x1: scanrego generic map (tech)
	port map (pado, coreo, samp, tck, tckn, tdo1, tdo, bsshft, bscapto, bsupdo, bsdrive);
    x2: scanrego generic map (tech)
	port map (padoenx, coreoen, coreoen, tck, tckn, tdi, tdo1, bsshft, bscaptoe, bsupdo, bsdrive);

    hz : if hzsup = 1 generate
      x3 : if oepol = 0 generate
        x33 : gror2 generic map (tech) port map (padoenx, bshighz, padoenxx);
      end generate;
      x4 : if oepol = 1 generate
        x33 : grand12 generic map (tech) port map (padoenx, bshighz, padoenxx);
      end generate;
    end generate;
    nohz : if hzsup = 0 generate
      padoenxx <= padoenx;
    end generate;

    oem: if scantest /= 0 generate
      x4: grmux2 generic map (tech) port map (padoenxx, testoen, testen, padoen);
    end generate;
    nooem: if scantest = 0 generate
      padoen <= padoenxx;
    end generate;

end;
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.alltap.all;

entity scanregio is
  generic (
    tech : integer := 0;
    hzsup: integer range 0 to 1 := 1;
    oepol: integer range 0 to 1 := 1;
    intesten: integer range 0 to 1 := 1;
    scantest: integer range 0 to 1 := 0
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
    bscapti : in std_ulogic;
    bscapto : in std_ulogic;
    bscaptoe: in std_ulogic;
    bsupdi  : in std_ulogic;
    bsupdo  : in std_ulogic;
    bsdrive : in std_ulogic;
    bshighz : in std_ulogic;
    testen  : in std_ulogic;
    testoen : in std_ulogic
    );
end;

architecture tmap of scanregio is
signal tdo1, tdo2, padoenx : std_ulogic;
begin

  gen0: if tech = 0 generate
    x: scanregio_inf
      generic map (hzsup,intesten)
      port map (pado,padoen,padi,coreo,coreoen,corei,tck,tckn,tdi,tdo,
                bsshft,bscapti,bsupdi,bsupdo,bsdrive,bshighz);
  end generate;
  map0: if tech /= 0 generate
    x0: scanregi generic map (tech,intesten)
	port map (padi, corei, tck, tckn, tdo1, tdo, bsshft, bscapti, bsupdi, bsdrive, bshighz);
    x1: scanregto generic map (tech, hzsup, oepol, scantest)
	port map (pado, padoen, coreo, coreo, coreoen, 
		 tck, tckn, tdi, tdo1, bsshft, bscapto, bscaptoe, bsupdo, bsdrive, bshighz, testen, testoen);
  end generate;
  
end;

