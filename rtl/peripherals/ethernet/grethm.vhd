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
-- Entity: 	grethm
-- File:	grethm.vhd
-- Author:	Jiri Gaisler
-- Description:	Module to select between greth and greth1g
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.gencomp.all;
use work.net.all;

entity grethm is
  generic(
    hindex         : integer := 0;
    ehindex        : integer := 1;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    little_end     : integer range 0 to 1 := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 64 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 3 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    burstlength    : integer range 4 to 128 := 32;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    vcu118         : integer range 0 to 1  := 0;
    rmii           : integer range 0 to 1 := 0;
    sim            : integer range 0 to 1 := 0;
    giga           : integer range 0 to 1  := 0;
    oepol          : integer range 0 to 1  := 0;
    scanen         : integer range 0 to 1  := 0;
    ft             : integer range 0 to 2  := 0;
    edclsepahbg    : integer range 0 to 1  := 0;
    edclft         : integer range 0 to 2  := 0;
    mdint_pol      : integer range 0 to 1  := 0;
    enable_mdint   : integer range 0 to 1  := 0;
    multicast      : integer range 0 to 1  := 0;
    ramdebug       : integer range 0 to 2  := 0;
    mdiohold       : integer := 1;
    maxsize        : integer := 1500;
    gmiimode       : integer range 0 to 1  := 0
    );
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    mdcscaler      : in  integer range 0 to 2047 := 25; 
    ahbmi          : in  ahb_mst_in_type;
    ahbmo          : out ahb_mst_out_type;
    eahbmo         : out ahb_mst_out_type;
    apbi           : in  apb_slv_in_type;
    apbo           : out apb_slv_out_type;
    ethi           : in  eth_in_type;
    etho           : out eth_out_type
  );
end entity;
  
architecture rtl of grethm is
begin

  m100 : if giga = 0 generate
    u0 : greth
      generic map (
        hindex         => hindex,
        ehindex        => ehindex,
        pindex         => pindex,
        paddr          => paddr,
        pmask          => pmask,
        pirq           => pirq,
        memtech        => memtech,
        little_end     => little_end,
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        slot_time      => slot_time,
        enable_mdio    => enable_mdio,
        fifosize       => fifosize,
        nsync          => nsync,
        edcl           => edcl,
        edclbufsz      => edclbufsz,
        macaddrh       => macaddrh,
        macaddrl       => macaddrl,
        ipaddrh        => ipaddrh,
        ipaddrl        => ipaddrl,
        phyrstadr      => phyrstadr,
        vcu118         => vcu118,
        rmii           => rmii,
        oepol          => oepol,
        scanen         => scanen,
        ft             => ft,
        edclsepahbg    => edclsepahbg,
        edclft         => edclft,
        mdint_pol      => mdint_pol,
        enable_mdint   => enable_mdint,
        multicast      => multicast,
        ramdebug       => ramdebug,
        mdiohold       => mdiohold,
        maxsize        => maxsize,
        gmiimode       => gmiimode
        )
      port map (
        rst            => rst,
        clk            => clk,
        mdcscaler      => mdcscaler,
        ahbmi          => ahbmi,
        ahbmo          => ahbmo,
        eahbmo         => eahbmo,
        apbi           => apbi,
        apbo           => apbo,
        ethi           => ethi,
        etho           => etho);
  end generate;

  m1000 : if giga = 1 generate
    u0 : greth_gbit
      generic map (
        hindex         => hindex,
        pindex         => pindex,
        paddr          => paddr,
        pmask          => pmask,
        pirq           => pirq,
        memtech        => memtech,
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        slot_time      => slot_time,
        nsync          => nsync,
        edcl           => edcl,
        edclbufsz      => edclbufsz,
        burstlength    => burstlength,
        macaddrh       => macaddrh,
        macaddrl       => macaddrl,
        ipaddrh        => ipaddrh,
        ipaddrl        => ipaddrl,
        phyrstadr      => phyrstadr,
        sim            => sim,
        oepol          => oepol,
        scanen         => scanen,
        ft             => ft,
        edclft         => edclft,
        mdint_pol      => mdint_pol,
        enable_mdint   => enable_mdint,
        multicast      => multicast,
        ramdebug       => ramdebug,
        mdiohold       => mdiohold,
        gmiimode       => gmiimode
        ) 
      port map (
        rst            => rst,
        clk            => clk,
        mdcscaler      => mdcscaler,
        ahbmi          => ahbmi,
        ahbmo          => ahbmo,
        apbi           => apbi,
        apbo           => apbo,
        ethi           => ethi,
        etho           => etho);

    eahbmo <= ahbm_none;
  end generate;

end architecture;

