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
-- Entity:      apbctrl
-- File:        apbctrl.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: AMBA AHB/APB bridge with plug&play support
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;

entity apbctrl is
  generic (
    hindex      : integer := 0;
    haddr       : integer := 0;
    hmask       : integer := 16#fff#;
    nslaves     : integer range 1 to NAPBSLV := NAPBSLV;
    debug       : integer range 0 to 2 := 2;
    icheck      : integer range 0 to 1 := 1;
    enbusmon    : integer range 0 to 1 := 0;
    asserterr   : integer range 0 to 1 := 0;
    assertwarn  : integer range 0 to 1 := 0;
    pslvdisable : integer := 0;
    mcheck      : integer range 0 to 1 := 1;
    ccheck      : integer range 0 to 1 := 1
    );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_type;
    apbo    : in  apb_slv_out_vector
  );
end;

architecture struct of apbctrl is
signal lahbi    : ahb_slv_in_vector_type(0 to 0);
signal lahbo    : ahb_slv_out_vector_type(0 to 0);
signal lapbi    : apb_slv_in_vector;
signal lwp      : std_logic_vector(0 to 0);
signal lwpv     : std_logic_vector(256-1 downto 0);
begin

  lahbi(0) <= ahbi;
  ahbo <= lahbo(0);
  apbi <= lapbi(0);
  lwp(0) <= '0';
  lwpv <= (others => '0');

  apbx : apbctrlx
    generic map(
      hindex0     => hindex,
      haddr0      => haddr,
      hmask0      => hmask,
      hindex1     => 0,
      haddr1      => 0,
      hmask1      => 0,
      nslaves     => nslaves,
      nports      => 1,
      wprot       => 0,
      debug       => debug,
      icheck      => icheck,
      enbusmon    => enbusmon,
      asserterr   => asserterr,
      assertwarn  => assertwarn,
      pslvdisable => pslvdisable,
      mcheck      => mcheck,
      ccheck      => ccheck)
    port map(
      rst         => rst,
      clk         => clk,
      ahbi        => lahbi,
      ahbo        => lahbo,
      apbi        => lapbi,
      apbo        => apbo,
      wp          => lwp,
      wpv         => lwpv);
end;
