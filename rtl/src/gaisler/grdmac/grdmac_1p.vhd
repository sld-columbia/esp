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
-- Entity:      grdmac_1p
-- File:        grdmac_1p.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: AMBA DMA controller with single master interface
--              Supports scatter gather on unaligned data through internal
--              re-alignment buffer and conditional descriptors
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.grdmac_pkg.all;
use work.devices.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

entity grdmac_1p is
  generic (
    hmindex         : integer := 0; -- AHB master index
    hirq            : integer := 0;
    pindex          : integer := 0; -- APB configuration slave index
    paddr           : integer := 1;
    pmask           : integer := 16#FFF#;
    ndmach          : integer range 1 to 16 := 1;   -- number of DMA channels --TODO: implement ndmach = 0
    bufsize         : integer range 4*AHBDW/8 to 64*1024:= 256; -- number of bytes in buffer (must be a multiple of 4*WORD_SIZE)
    burstbound      : integer range 4 to 1024 := 512;
    memtech         : integer := 0;
    testen          : integer := 0;
    ft              : integer range 0 to 2  := 0;
    wbmask          : integer := 0;
    busw            : integer := 64
    );
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbmi       : in  ahb_mst_in_type;
    ahbmo       : out ahb_mst_out_type;
    apbi        : in  apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    irq_trig    : in  std_logic_vector(63 downto 0)
  );
end;

architecture rtl of grdmac_1p is
begin

    dma: grdmac
        generic map(
            hmindex     => hmindex,
            hirq        => hirq,
            pindex      => pindex,
            paddr       => paddr,
            pmask       => pmask,
            en_ahbm1    => 0,
            hmindex1    => 0,
            ndmach      => ndmach,
            bufsize     => bufsize,
            burstbound  => burstbound,
            memtech     => memtech,
            testen      => testen,
            ft          => ft,
            wbmask      => wbmask,
            busw        => busw
        )
        port map (
            rst         => rst,
            clk         => clk,
            ahbmi       => ahbmi,
            ahbmo       => ahbmo,
            ahbmi1      => ahbm_in_none,
            ahbmo1      => open,
            apbi        => apbi,
            apbo        => apbo,
            irq_trig    => irq_trig
        );

end architecture;
