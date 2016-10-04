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
-- Entity: 	grethm_mb
-- File:	grethm_mb.vhd
-- Author:	Andrea Gianarro
-- Description:	Module to select between greth_mb and greth_gbit_mb
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.gencomp.all;
use work.net.all;

entity grethm_mb is
  generic(
    hindex         : integer := 0;
    ehindex        : integer := 0;
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#FFF#;
    pirq           : integer := 0;
    memtech        : integer := 0;
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    slot_time      : integer := 128;
    mdcscaler      : integer range 0 to 255 := 25; 
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
    rmii           : integer range 0 to 1 := 0;
    sim            : integer range 0 to 1 := 0;
    giga           : integer range 0 to 1  := 0;
    oepol          : integer range 0 to 1  := 0;
    scanen         : integer range 0 to 1  := 0;
    ft             : integer range 0 to 2  := 0;
    edclft         : integer range 0 to 2  := 0;
    mdint_pol      : integer range 0 to 1  := 0;
    enable_mdint   : integer range 0 to 1  := 0;
    multicast      : integer range 0 to 1  := 0;
    edclsepahb     : integer range 0 to 1 := 0;
    ramdebug       : integer range 0 to 2  := 0;
    mdiohold       : integer := 1;
    maxsize        : integer := 1500;
    gmiimode       : integer range 0 to 1  := 0
    );
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    ahbmi          : in  ahb_mst_in_type;
    ahbmo          : out ahb_mst_out_type;
    ahbmi2         : in  ahb_mst_in_type;
    ahbmo2         : out ahb_mst_out_type;
    apbi           : in  apb_slv_in_type;
    apbo           : out apb_slv_out_type;
    ethi           : in  eth_in_type;
    etho           : out eth_out_type
  );
end entity;
  
architecture rtl of grethm_mb is
begin

  m100 : if giga = 0 generate
    u0 : greth_mb
      generic map (
        hindex         => hindex,
        ehindex        => ehindex,
        pindex         => pindex,
        paddr          => paddr,
        pmask          => pmask,
        pirq           => pirq,
        memtech        => memtech,
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        slot_time      => slot_time,
        mdcscaler      => mdcscaler,
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
        rmii           => rmii,
        oepol          => oepol,
        scanen         => scanen,
        ft             => ft,
        edclft         => edclft,
        mdint_pol      => mdint_pol,
        enable_mdint   => enable_mdint,
        multicast      => multicast,
        edclsepahb     => edclsepahb,
        ramdebug       => ramdebug,
        mdiohold       => mdiohold,
        maxsize        => maxsize,
        gmiimode       => gmiimode
        )
      port map (
        rst            => rst,
        clk            => clk,
        ahbmi          => ahbmi,
        ahbmo          => ahbmo,
        ahbmi2         => ahbmi2,
        ahbmo2         => ahbmo2,
        apbi           => apbi,
        apbo           => apbo,
        ethi           => ethi,
        etho           => etho);
  end generate;

  m1000 : if giga = 1 generate
    u0 : greth_gbit_mb
      generic map (
        hindex         => hindex,
        ehindex        => ehindex,
        pindex         => pindex,
        paddr          => paddr,
        pmask          => pmask,
        pirq           => pirq,
        memtech        => memtech,
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        slot_time      => slot_time,
        mdcscaler      => mdcscaler,
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
        edclsepahb     => edclsepahb,
        ramdebug       => ramdebug,
        mdiohold       => mdiohold,
        gmiimode       => gmiimode
        ) 
      port map (
        rst            => rst,
        clk            => clk,
        ahbmi          => ahbmi,
        ahbmo          => ahbmo,
        ahbmi2         => ahbmi2,
        ahbmo2         => ahbmo2,
        apbi           => apbi,
        apbo           => apbo,
        ethi           => ethi,
        etho           => etho,
        mdchain_ui     => greth_mdiochain_down_first,
        mdchain_uo     => open,
        mdchain_di     => open,
        mdchain_do     => greth_mdiochain_up_last);
  end generate;

end architecture;

