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
-- Entity:        syncfifo_2p
-- File:          syncfifo_2p.vhd
-- Authors:       Pascal Trotta
--                Andrea Gianarro - Cobham Gaisler AB
-- Description:   Syncronous 2-port fifo with tech selection
-----------------------------------------------------------------------------
--  Notes: Generic fifo has the following features & limitations:
--         -almost full is driven only in write clock domain;
--         -almost empty is driven only in read clock domain;
--         -full and empty are driven in both clock domains;
--         -usedw is re-computed in each clock domain;
--         -in "first word fall through" mode rempty should be observed as data 
--          valid signal, as the first word written into the FIFO immediately
--          appears on the output. If renable is asserted while empty='0', and 
--          at the next read clock rising edge empty='1', then new read data is
--          not valid because fifo is empty. This does not apply in standard fifo
--          mode, i.e., when empty is asserted, the last read data is valid;
--         -it works also if rclk = wclk. With sepclk=0 synchronization stages
--          and gray encoder/decoder are not instantiated, since not necessary.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncfifo_2p is
  generic (
    tech  : integer := 0;   -- target technology
    abits : integer := 10;  -- fifo address bits (actual fifo depth = 2**abits)
    dbits : integer := 32;  -- fifo data width
    sepclk : integer := 1;  -- 1 = asynchrounous read/write clocks, 0 = synchronous read/write clocks
    pfull : integer := 100; -- almost full threshold (max 2**abits - 3)
    pempty : integer := 10; -- almost empty threshold (min 2)
    fwft : integer := 0     -- 1 = first word fall trough mode, 0 = standard mode
	);
  port (
    rclk    : in std_logic;  -- read clock
    rrstn   : in std_logic;  -- read clock domain synchronous reset
    wrstn   : in std_logic;  -- write clock domain synchronous reset
    renable : in std_logic;  -- read enable
    rfull   : out std_logic; -- fifo full (synchronized in read clock domain)
    rempty  : out std_logic; -- fifo empty
    aempty  : out std_logic; -- fifo almost empty (depending on pempty threshold)
    rusedw  : out std_logic_vector(abits-1 downto 0);  -- fifo used words (synchronized in read clock domain)
    dataout : out std_logic_vector(dbits-1 downto 0);  -- fifo data output
    wclk    : in std_logic;  -- write clock
    write   : in std_logic;  -- write enable
    wfull   : out std_logic; -- fifo full
    afull   : out std_logic; -- fifo almost full (depending on pfull threshold)
    wempty  : out std_logic; -- fifo empty (synchronized in write clock domain)
    wusedw  : out std_logic_vector(abits-1 downto 0); -- fifo used words (synchronized in write clock domain)
    datain  : in std_logic_vector(dbits-1 downto 0)); -- fifo data input
end;

architecture rtl of syncfifo_2p is

begin

-- Altera fifo
  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
    (tech = stratix3) or (tech = stratix4) generate
    x0 : altera_fifo_dp generic map (tech, abits, dbits)
      port map (rclk, renable, rfull, rempty, rusedw, dataout, wclk,
        write, wfull, wempty, wusedw, datain);
  end generate;

-- generic FIFO implemented using syncram_2p component
  inf : if (tech /= altera) and (tech /= stratix1) and (tech /= stratix2) and 
    (tech /= stratix3) and (tech /= stratix4) generate
    x0: generic_fifo generic map (tech, abits, dbits, sepclk, pfull, pempty, fwft)
      port map (rclk, rrstn, wrstn, renable, rfull, rempty, aempty, rusedw, dataout,
        wclk, write, wfull, afull, wempty, wusedw, datain);
  end generate;

-- pragma translate_off
  nofifo : if (has_2pfifo(tech) = 0) and (has_2pram(tech) = 0) generate
    x : process
    begin
      assert false report "syncfifo_2p: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
  dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
    x : process
    begin
      assert false report "syncfifo_2p: " & tost(2**abits) & "x" & tost(dbits) &
       " (" & tech_table(tech) & ")"
      severity note;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;

