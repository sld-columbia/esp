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
-- Entity:      tbufmem_2p
-- File:        tbufmem_2p.vhd
-- Author:      Jiri Gaisler - Gaisler Research
--              Andrea Gianarro - Aeroflex Gaisler AB
-- Description: 256-bit trace buffer memory (CPU/AHB), two ports
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.leon3.all;
use work.gencomp.all;
use work.stdlib.all;

entity tbufmem_2p is
  generic (
    tech   : integer := 0;
    tbuf   : integer := 0; -- trace buf size in kB (0 - no trace buffer)
    dwidth : integer := 32; -- AHB data width
    testen : integer := 0
    );
  port (
    clk : in std_ulogic;
    di  : in tracebuf_2p_in_type;
    do  : out tracebuf_2p_out_type;
    testin: in std_logic_vector(TESTIN_WIDTH-1 downto 0)
  );


end;

architecture rtl of tbufmem_2p is

constant ADDRBITS : integer := 10 + log2(tbuf) - 4;

  
begin

  mem32 : for i in 0 to 3 generate  -- basic 128 buffer
    ram0 : syncram_2p
      generic map (
        tech            => tech,
        abits           => addrbits,
        dbits           => 32,
        wrfst           => 1,
        testen          => testen,
        custombits      => memtest_vlen
      )
      port map (
        rclk            => clk,
        renable         => di.renable,
        raddress        => di.raddr(addrbits-1 downto 0),
        dataout         => do.data(((i*32)+31) downto (i*32)),
        wclk            => clk,
        write           => di.write(i),
        waddress        => di.waddr(addrbits-1 downto 0),
        datain          => di.data(((i*32)+31) downto (i*32)),
        testin          => testin
        );
  end generate;
  mem64 : if dwidth > 32 generate -- extra data buffer for 64-bit bus
    ram0 : syncram_2p
      generic map (
        tech            => tech,
        abits           => addrbits,
        dbits           => 32,
        wrfst           => 1,
        testen          => testen,
        custombits      => memtest_vlen
      )
      port map (
        rclk            => clk, 
        renable         => di.renable, 
        raddress        => di.raddr(addrbits-1 downto 0), 
        dataout         => do.data((128+31) downto 128), 
        wclk            => clk, 
        write           => di.write(7), 
        waddress        => di.waddr(addrbits-1 downto 0), 
        datain          => di.data((128+31) downto 128),
        testin          => testin
        );
  end generate;
  mem128 : if dwidth > 64 generate -- extra data buffer for 128-bit bus
    memwd: for i in 0 to 1 generate
      ram0 : syncram_2p
        generic map (
          tech            => tech,
          abits           => addrbits,
          dbits           => 32,
          wrfst           => 1,
          testen          => testen,
          custombits      => memtest_vlen
        )
        port map (
          rclk            => clk,
          renable         => di.renable,
          raddress        => di.raddr(addrbits-1 downto 0),
          dataout         => do.data((128+63+i*32) downto (128+32+i*32)),
          wclk            => clk,
          write           => di.write(5+i),
          waddress        => di.waddr(addrbits-1 downto 0),
          datain          => di.data((128+63+i*32) downto (128+32+i*32)),
          testin          => testin
          );
    end generate;
  end generate;

  nomem64 : if dwidth < 64 generate -- no extra data buffer for 64-bit bus
    do.data((128+31) downto 128) <= (others => '0');
  end generate;
  nomem128 : if dwidth < 128 generate -- no extra data buffer for 128-bit bus
    do.data((128+95) downto (128+32)) <= (others => '0');
  end generate;
  do.data(255 downto 224) <= (others => '0');

end;
  

