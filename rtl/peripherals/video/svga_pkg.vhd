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

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.amba.all;

package svga_pkg is

  type apbvga_out_type is record
    hsync           : std_ulogic;                       -- horizontal sync
    vsync           : std_ulogic;                       -- vertical sync
    comp_sync       : std_ulogic;                       -- composite sync
    blank           : std_ulogic;                       -- blank signal
    video_out_r     : std_logic_vector(7 downto 0);     -- red channel
    video_out_g     : std_logic_vector(7 downto 0);     -- green channel
    video_out_b     : std_logic_vector(7 downto 0);     -- blue channel
    bitdepth        : std_logic_vector(1 downto 0);     -- Bith depth
  end record;

  component svgactrl
    generic(
      length      : integer := 384;        -- Fifo-length
      part        : integer := 128;        -- Fifo-part lenght
      memtech     : integer := DEFMEMTECH;
      pindex      : integer := 0;
      paddr       : integer := 0;
      pmask       : integer := 16#fff#;
      hindex      : integer := 0;
      hirq        : integer := 0;
      clk0        : integer := 40000;
      clk1        : integer := 20000;
      clk2        : integer := 15385;
      clk3        : integer := 0;
      burstlen    : integer range 2 to 8 := 8;
      ahbaccsz    : integer := 32;
      asyncrst    : integer range 0 to 1 := 0
      );
    port (
      rst       : in std_logic;
      clk       : in std_logic;
      vgaclk    : in std_logic;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      vgao      : out apbvga_out_type;
      ahbi      : in  ahb_mst_in_type;
      ahbo      : out ahb_mst_out_type;
      clk_sel   : out std_logic_vector(1 downto 0);
      arst      : in  std_ulogic := '1'
      );

  end component;

  constant vgao_none : apbvga_out_type :=
    ('0', '0', '0', '0', "00000000", "00000000", "00000000", "00");

end package svga_pkg;
