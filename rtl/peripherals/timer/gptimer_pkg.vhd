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
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;

package gptimer_pkg is

  type gptimer_in_type is record
    dhalt    : std_ulogic;
    extclk   : std_ulogic;
    wdogen   : std_ulogic;
    latchv   : std_logic_vector(NAHBIRQ-1 downto 0);
    latchd   : std_logic_vector(NAHBIRQ-1 downto 0);
  end record;

  type gptimer_in_vector is array (natural range <>) of gptimer_in_type;

  type gptimer_out_type is record
    tick     : std_logic_vector(0 to 7);
    timer1   : std_logic_vector(31 downto 0);
    wdogn    : std_ulogic;
    wdog    : std_ulogic;
  end record;

  type gptimer_out_vector is array (natural range <>) of gptimer_out_type;

  constant gptimer_in_none : gptimer_in_type := ('0', '0', '0', zxirq(NAHBIRQ-1 downto 0), zxirq(NAHBIRQ-1 downto 0));

  constant gptimer_out_none : gptimer_out_type :=
    ((others => '0'), (others => '0'), '1', '0');

  component gptimer
    generic (
      pindex   : integer := 0;
      paddr    : integer := 0;
      pmask    : integer := 16#fff#;
      pirq     : integer := 0;
      sepirq   : integer := 0;	-- use separate interrupts for each timer
      sbits    : integer := 16;			-- scaler bits
      ntimers  : integer range 1 to 7 := 1; 	-- number of timers
      nbits    : integer := 32;			-- timer bits
      wdog     : integer := 0;
      ewdogen  : integer := 0;
      glatch   : integer := 0;
      gextclk  : integer := 0;
      gset     : integer := 0;
      gelatch  : integer range 0 to 2 := 0;
      wdogwin  : integer := 0
      );
    port (
      rst    : in  std_ulogic;
      clk    : in  std_ulogic;
      apbi   : in  apb_slv_in_type;
      apbo   : out apb_slv_out_type;
      gpti   : in gptimer_in_type;
      gpto   : out gptimer_out_type
      );
  end component;

end package gptimer_pkg;

