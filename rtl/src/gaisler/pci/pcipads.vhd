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
-- Entity: 	pcipads
-- File:	pcipads.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	PCI pads module
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.gencomp.all;
use work.pci.all;
use work.stdlib.all;

entity pcipads is
  generic (
    padtech      : integer := 0;
    noreset      : integer := 0;
    oepol        : integer := 0;
    host         : integer := 1;
    int          : integer := 0;
    no66         : integer := 0;
    onchipreqgnt : integer := 0;        -- Internal req and gnt signals
    drivereset   : integer := 0;        -- Drive PCI rst with outpad
    constidsel   : integer := 0;        -- pci_idsel is tied to local constant
    level        : integer := pci33;    -- input/output level
    voltage      : integer := x33v;     -- input/output voltage
    nolock       : integer := 0
  );
  port (
    pci_rst     : inout std_logic;
    pci_gnt     : in std_ulogic;
    pci_idsel   : in std_ulogic;
    pci_lock    : inout std_ulogic;
    pci_ad 	: inout std_logic_vector(31 downto 0);
    pci_cbe 	: inout std_logic_vector(3 downto 0);
    pci_frame   : inout std_ulogic;
    pci_irdy 	: inout std_ulogic;
    pci_trdy 	: inout std_ulogic;
    pci_devsel  : inout std_ulogic;
    pci_stop 	: inout std_ulogic;
    pci_perr 	: inout std_ulogic;
    pci_par 	: inout std_ulogic;    
    pci_req 	: inout std_ulogic;  -- tristate pad but never read
    pci_serr    : inout std_ulogic;  -- open drain output
    pci_host   	: in std_ulogic;
    pci_66	: in std_ulogic;
    pcii   	: out pci_in_type;
    pcio   	: in  pci_out_type;
    pci_int     : inout std_logic_vector(3 downto 0) --:= conv_std_logic_vector(16#F#, 4) -- Disable int by default
    --pci_int     : inout std_logic_vector(3 downto 0) := 
    --                 conv_std_logic_vector(16#F# - (16#F# * oepol), 4) -- Disable int by default
  );
end; 
 
architecture rtl of pcipads is
signal vcc : std_ulogic;
begin

  vcc <= '1';

  -- Reset
  rstpad : if noreset = 0 generate
    nodrive: if drivereset = 0 generate
      pci_rst_pad : iodpad generic map (tech => padtech, level => level,
                                        voltage => voltage, oepol => 0) 
          port map (pci_rst, pcio.rst, pcii.rst);
    end generate nodrive;
    drive: if drivereset /= 0 generate
      pci_rst_pad : outpad generic map (tech => padtech, level => level,
                                        voltage => voltage)
        port map (pci_rst, pcio.rst);
      pcii.rst <= pcio.rst;
    end generate drive;
  end generate;
  norstpad : if noreset = 1 generate
    pcii.rst <= pci_rst;
  end generate;

  localgnt: if onchipreqgnt = 1 generate
    pcii.gnt <= pci_gnt;
    pci_req <= pcio.req when pcio.reqen = conv_std_logic(oepol=1) else '1';
  end generate localgnt;
  extgnt: if onchipreqgnt = 0 generate
    pad_pci_gnt   : inpad generic map (padtech, level, voltage) port map (pci_gnt, pcii.gnt);
    pad_pci_req   : toutpad generic map (tech => padtech, level => level,
                                         voltage => voltage, oepol => oepol)
      port map (pci_req, pcio.req, pcio.reqen);
  end generate extgnt;

  idsel_pad: if constidsel = 0 generate
    pad_pci_idsel : inpad generic map (padtech, level, voltage) port map (pci_idsel, pcii.idsel);
  end generate idsel_pad;
  idsel_local: if constidsel /= 0 generate
    pcii.idsel <= pci_idsel;
  end generate idsel_local;

  onlyhost : if host = 2 generate
    pcii.host <= '0';   -- Always host
  end generate;
  dohost : if host = 1 generate
    pad_pci_host  : inpad generic map (padtech, level, voltage) port map (pci_host, pcii.host);
  end generate;
  nohost : if host = 0 generate
    pcii.host <= '1';	-- disable pci host functionality
  end generate;
  
  do66 : if no66 = 0 generate
    pad_pci_66    : inpad generic map (padtech, level, voltage) port map (pci_66, pcii.pci66);
  end generate;
  dono66 : if no66 = 1 generate
    pcii.pci66 <= '0';
  end generate;

  dolock : if nolock = 0 generate
    pad_pci_lock  : iopad 
      generic map (tech => padtech, level => level,
                   voltage => voltage, oepol => oepol)
	    port map (pci_lock, pcio.lock, pcio.locken, pcii.lock);
  end generate;
  donolock : if nolock = 1 generate
    pcii.lock <= pci_lock;
  end generate;

  pad_pci_ad    : iopadvv generic map (tech => padtech, level => level,
                                       voltage => voltage, width => 32,
                                       oepol => oepol)
	          port map (pci_ad, pcio.ad, pcio.vaden, pcii.ad);
  pad_pci_cbe0  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_cbe(0), pcio.cbe(0), pcio.cbeen(0), pcii.cbe(0));
  pad_pci_cbe1  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_cbe(1), pcio.cbe(1), pcio.cbeen(1), pcii.cbe(1));
  pad_pci_cbe2  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_cbe(2), pcio.cbe(2), pcio.cbeen(2), pcii.cbe(2));
  pad_pci_cbe3  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_cbe(3), pcio.cbe(3), pcio.cbeen(3), pcii.cbe(3));
  pad_pci_frame : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_frame, pcio.frame, pcio.frameen, pcii.frame);
  pad_pci_trdy  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_trdy, pcio.trdy, pcio.trdyen, pcii.trdy);
  pad_pci_irdy  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_irdy, pcio.irdy, pcio.irdyen, pcii.irdy);
  pad_pci_devsel: iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_devsel, pcio.devsel, pcio.devselen, pcii.devsel);
  pad_pci_stop  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_stop, pcio.stop, pcio.stopen, pcii.stop);
  pad_pci_perr  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_perr, pcio.perr, pcio.perren, pcii.perr);
  pad_pci_par   : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_par, pcio.par, pcio.paren, pcii.par);
  pad_pci_serr  : iopad generic map (tech => padtech, level => level, voltage => voltage, oepol => oepol)
	          port map (pci_serr, pcio.serr, pcio.serren, pcii.serr);

  -- PCI interrupt pads
  -- int = 0 => no interrupt
  -- int = 1 => PCI_INT[A] = out, PCI_INT[B,C,D] = Not connected
  -- int = 2 => PCI_INT[B] = out, PCI_INT[A,C,D] = Not connected
  -- int = 3 => PCI_INT[C] = out, PCI_INT[A,B,D] = Not connected
  -- int = 4 => PCI_INT[D] = out, PCI_INT[A,B,C] = Not connected
  
  -- int = 10 => PCI_INT[A] = inout, PCI_INT[B,C,D] = in
  -- int = 11 => PCI_INT[B] = inout, PCI_INT[A,C,D] = in
  -- int = 12 => PCI_INT[C] = inout, PCI_INT[A,B,D] = in
  -- int = 13 => PCI_INT[D] = inout, PCI_INT[A,B,C] = in

  -- int = 14 => PCI_INT[A,B,C,D] = in
  
  -- int = 100 => PCI_INT[A]        = out, PCI_INT[B,C,D]   = Not connected
  -- int = 101 => PCI_INT[A,B]      = out, PCI_INT[C,D]     = Not connected
  -- int = 102 => PCI_INT[A,B,C]    = out, PCI_INT[D]       = Not connected
  -- int = 103 => PCI_INT[A,B,C,D]  = out
  
  -- int = 110 => PCI_INT[A]       = inout, PCI_INT[B,C,D]  = in
  -- int = 111 => PCI_INT[A,B]     = inout, PCI_INT[C,D]    = in
  -- int = 112 => PCI_INT[A,B,C]   = inout, PCI_INT[D]      = in
  -- int = 113 => PCI_INT[A,B,C,D] = inout 

  interrupt : if int /= 0 generate
    x : for i in 0 to 3 generate 
      xo : if i = int - 1 and int < 10 generate
        pad_pci_int : odpad generic map (tech => padtech, level => level,
                                         voltage => voltage, oepol => oepol)
          port map (pci_int(i), pcio.inten);
      end generate;
      xonon : if i /= int - 1 and int < 10 and int < 100 generate
        pci_int(i) <= '1';
      end generate;
      xio : if i = (int - 10) and int >= 10 and int < 100 generate
        pad_pci_int : iodpad generic map (tech => padtech, level => level,
                                          voltage => voltage, oepol => oepol)
          port map (pci_int(i), pcio.inten, pcii.int(i));
      end generate;
      xi  : if i /= (int - 10) and int >= 10 and int < 100 generate
        pad_pci_int : inpad generic map (tech => padtech, level => level, voltage => voltage)
          port map (pci_int(i), pcii.int(i));
      end generate;
      
      x2o : if i <= (int - 100) and int < 110 and int >= 100 generate
        pad_pci_int : odpad generic map (tech => padtech, level => level,
                                         voltage => voltage, oepol => oepol)
          port map (pci_int(i), pcio.vinten(i));
      end generate;
      x2onon : if i > (int - 100) and int < 110 and int >= 100 generate
        pci_int(i) <= '1';
      end generate;
      
      x2oi : if i <= (int - 110) and int >= 110 generate
        pad_pci_int : iodpad generic map (tech => padtech, level => level,
                                          voltage => voltage, oepol => oepol)
          port map (pci_int(i), pcio.vinten(i), pcii.int(i));
      end generate;
      x2i : if i > (int - 110) and int >= 110 generate
        pad_pci_int : inpad generic map (tech => padtech, level => level, voltage => voltage)
          port map (pci_int(i), pcii.int(i));
      end generate;


    end generate;
  end generate;
  nointerrupt : if int = 0 generate
    pcii.int <= (others => '0');
  end generate;
  pcii.pme_status <= '0';

end;

