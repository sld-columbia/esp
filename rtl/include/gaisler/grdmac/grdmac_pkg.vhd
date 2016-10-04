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
-- Package:     grdmac_pkg
-- File:        grdmac_pkg.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: Package for GRDMAC and its components
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.amba.all;

package grdmac_pkg is

  type grdmac_ahb_dma_in_type is record
    address         : std_logic_vector(31 downto 0);
    wdata           : std_logic_vector(AHBDW-1 downto 0);
    start           : std_ulogic;
    burst           : std_ulogic;
    first_beat      : std_ulogic;
    write           : std_ulogic;
    busy            : std_ulogic;
    idle            : std_ulogic;
    irq             : std_ulogic;
    size            : std_logic_vector(2 downto 0);
  end record;

  type grdmac_ahb_dma_out_type is record
    start           : std_ulogic;
    active          : std_ulogic;
    ready           : std_ulogic;
    retry           : std_ulogic;
    mexc            : std_ulogic;
    haddr           : std_logic_vector(9 downto 0);
    rdata           : std_logic_vector(AHBDW-1 downto 0);
  end record;

  constant grdmac_ahb_dma_in_none : grdmac_ahb_dma_in_type  := ( zx, zahbdw, '0', '0', '0', '0', '0', '0', '0', "000");
  constant grdmac_ahb_dma_none    : grdmac_ahb_dma_out_type := ('0', '0', '0', '0', '0', (others => '0'), zahbdw);

  component grdmac is
    generic (
      hmindex         : integer := 0; -- AHB master index
      hirq            : integer := 0;
      pindex          : integer := 0; -- APB configuration slave index
      paddr           : integer := 1;
      pmask           : integer := 16#FF0#;
      en_ahbm1        : integer range 0 to 1 := 0;
      hmindex1        : integer := 1; -- AHB master 1 index
      ndmach          : integer range 1 to 16 := 1;   -- number of DMA channels --TODO: implement ndmach = 0
      bufsize         : integer range 4*AHBDW/8 to 64*1024:= 256; -- number of bytes in buffer (must be a multiple of WORD_SIZE and 4)
      burstbound      : integer range 4 to 1024 := 512;
      en_timer        : integer := 0;
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
      ahbmi1      : in  ahb_mst_in_type;
      ahbmo1      : out ahb_mst_out_type;
      apbi        : in  apb_slv_in_type;
      apbo        : out apb_slv_out_type;
      irq_trig    : in  std_logic_vector(63 downto 0)
    );
  end component;

  component grdmac_1p is
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
  end component;

  component grdmac_ahbmst
    generic (
      hindex  : integer := 0;
      hirq    : integer := 0;
      venid   : integer := 1;
      devid   : integer := 0;
      version : integer := 0;
      chprot  : integer := 3;
      incaddr : integer := 0);
     port (
        rst  : in  std_ulogic;
        clk  : in  std_ulogic;
        dmai : in  grdmac_ahb_dma_in_type;
        dmao : out grdmac_ahb_dma_out_type;
        ahbi : in  ahb_mst_in_type;
        ahbo : out ahb_mst_out_type
        );
  end component;

  component grdmac_alignram is
    generic (
      memtech  : integer := 0;
      abits    : integer := 6; -- number of BYTES in buffer
      dbits    : integer := 8;
      testen   : integer := 0;
      ft       : integer range 0 to 2  := 0
    );
    port (
      clk      : in std_ulogic;
      rst      : in std_logic;
      enable   : in std_logic;
      write    : in std_logic;
      address  : in std_logic_vector((abits-1) downto 0);
      size     : in std_logic_vector(2 downto 0); -- AHB HSIZE format
      dataout  : out std_logic_vector((dbits-1) downto 0);
      datain   : in std_logic_vector((dbits-1) downto 0);
      data_offset : in std_logic_vector((log2(dbits/8))-1 downto 0)); -- offset in bytes
  end component;
  
  function sll_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector;

  function srl_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector;

  function rol_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector;

  function ror_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector;

  function mask_byte_lanes(arg: std_logic_vector; mask: std_logic_vector)
  return std_logic_vector;
end package;

package body grdmac_pkg is

  function sll_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector is
    type striped_type is array (0 to 7) of std_logic_vector((arg'length/8)-1 downto 0);
    variable arr : striped_type;
    variable o : std_logic_vector(arg'high downto arg'low);
  begin
    -- stripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        arr(j)(i) := arg(arg'low+i*8+j);
      end loop;
    end loop;
    -- shift
    for j in 0 to 7 loop
      arr(j) := std_logic_vector(shift_left(unsigned(arr(j)), count));
    end loop;
    -- unstripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        o(arg'low+i*8+j) := arr(j)(i);
      end loop;
    end loop;
    return o;
  end;

  function srl_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector is
    type striped_type is array (0 to 7) of std_logic_vector((arg'length/8)-1 downto 0);
    variable arr : striped_type;
    variable o : std_logic_vector(arg'high downto arg'low);
  begin
    -- stripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        arr(j)(i) := arg(arg'low+i*8+j);
      end loop;
    end loop;
    -- shift
    for j in 0 to 7 loop
      arr(j) := std_logic_vector(shift_right(unsigned(arr(j)), count));
    end loop;
    -- unstripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        o(arg'low+i*8+j) := arr(j)(i);
      end loop;
    end loop;
    return o;
  end;

  function rol_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector is
    type striped_type is array (0 to 7) of std_logic_vector((arg'length/8)-1 downto 0);
    variable arr : striped_type;
    variable o : std_logic_vector(arg'high downto arg'low);
  begin
    -- stripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        arr(j)(i) := arg(arg'low+i*8+j);
      end loop;
    end loop;
    -- rotate
    for j in 0 to 7 loop
      arr(j) := std_logic_vector(rotate_left(unsigned(arr(j)), count));
    end loop;
    -- unstripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        o(arg'low+i*8+j) := arr(j)(i);
      end loop;
    end loop;
    return o;
  end;

  function ror_byte_lanes(arg: std_logic_vector; count: natural)
  return std_logic_vector is
    type striped_type is array (0 to 7) of std_logic_vector((arg'length/8)-1 downto 0);
    variable arr : striped_type;
    variable o : std_logic_vector(arg'high downto arg'low);
  begin
    -- stripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        arr(j)(i) := arg(arg'low+i*8+j);
      end loop;
    end loop;
    -- rotate
    for j in 0 to 7 loop
      arr(j) := std_logic_vector(rotate_right(unsigned(arr(j)), count));
    end loop;
    -- unstripe
    for j in 0 to 7 loop
      for i in 0 to (arg'length/8)-1 loop
        o(arg'low+i*8+j) := arr(j)(i);
      end loop;
    end loop;
    return o;
  end;

  function mask_byte_lanes(arg: std_logic_vector; mask: std_logic_vector)
  return std_logic_vector is
    --variable m        : std_logic_vector((arg'length/8)-1 downto 0);
    variable lanemask : std_logic_vector(7 downto 0);
    variable o        : std_logic_vector(arg'high downto arg'low);
  begin
    for i in 0 to (arg'length/8)-1 loop
      lanemask := (others => mask(mask'low+i));
      --print(tost_bits(lanemask));
      o(arg'low+i*8+7 downto arg'low+i*8) := (arg(arg'low+i*8+7 downto arg'low+i*8) and lanemask);
    end loop;
    return o;
  end;

end package body;
