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
-- Entity:      apbmem
-- File:        apbmem.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: AMBA APB memory
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;

entity apbmem is
  generic (
    pindex      : integer := 0;   -- APB configuration slave index
    paddr       : integer := 1;
    pmask       : integer := 16#FFF#;
    size        : integer range 4 to 1024 := 1024);  -- size in Bytes
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    apbi        : in apb_slv_in_type;
    apbo        : out  apb_slv_out_type);
end;

architecture rtl of apbmem is

  constant MEM_BITS : integer := log2ext(size);

  constant apbmax : integer := 19;

  constant VERSION   : amba_version_type := 0;
  -- TODO: move this constant with other amba constants and change value
  constant GAISLER_APBMEM : integer := 0;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  constant pconfig: apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBMEM, 0, VERSION, 0 ),
    1 => apb_iobar(paddr, pmask)
    );

  type memory_vector_type is array (0 to size/4) of std_logic_vector(31 downto 0);
  
  type reg_type is record
    memarr : memory_vector_type;
  end record;

  constant RES : reg_type := (
    memarr => (others => zero32));

  signal r, rin : reg_type;

begin

  reg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

  comb : process(r, rst, apbi)
    variable vprdata  : std_logic_vector(31 downto 0);
    variable v : reg_type;
  begin
    v := r;

    -- APB slave
    -- write
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      v.memarr(conv_integer(apbi.paddr(MEM_BITS-1 downto 2))) := apbi.pwdata;
    end if;

    --read
    vprdata := r.memarr(conv_integer(apbi.paddr(MEM_BITS-1 downto 2)));

    if (not RESET_ALL) and (rst = '0') then
      v := RES;
    end if;

    rin <= v;

    apbo <= ( prdata  => vprdata,
              pirq    => (others => '0'),
              pconfig => pconfig,
              pindex  => pindex);

  end process;

-- pragma translate_off
  bootmsg : report_version
  generic map ("apbmem" & tost(pindex) &
      ": APB memory size " & tost(size) & "Bytes");
-- pragma translate_on

end architecture;
