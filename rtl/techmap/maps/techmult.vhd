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
-- Entity: 	techmult
-- File:	techmult.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Multiplier with tech mapping
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.multlib.all;
use work.allmul.all;
use work.gencomp.all;

entity techmult is
    generic (
         tech          : integer := 0;
         arch          : integer := 0;
         a_width       : positive := 2;                      -- multiplier word width
         b_width       : positive := 2;                      -- multiplicand word width
         num_stages    : natural := 2;                 -- number of pipeline stages
         stall_mode    : natural range 0 to 1 := 1      -- '0': non-stallable; '1': stallable
    );
    port(a       : in std_logic_vector(a_width-1 downto 0);
         b       : in std_logic_vector(b_width-1 downto 0);
         clk     : in std_logic;
         en      : in std_logic;
         sign    : in std_logic;
         product : out std_logic_vector(a_width+b_width-1 downto 0));
end;

architecture rtl of techmult is

  signal gnd, vcc       : std_ulogic;
-- pragma translate_off
  signal pres : std_ulogic := '0';
  signal sonly : std_ulogic := '0';
-- pragma translate_on

begin

  gnd <= '0'; vcc <= '1';

  np : if num_stages = 1 generate
    arch0 : if (arch = 0) generate	--inferred
      product <= mixed_mul(a, b, sign);
-- pragma translate_off
      pres <= '1';
-- pragma translate_on
    end generate;
    arch1 : if (arch = 1) generate	-- modgen
      m1717 : if (a_width = 17) and (b_width = 17) generate
        m17 : mul_17_17 generic map (mulpipe => 0)
		port map (clk, vcc, a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
      m3317 : if (a_width = 33) and (b_width = 17) generate
        m33 : mul_33_17 port map (a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
      m339 : if (a_width = 33) and (b_width = 9) generate
        m33 : mul_33_9 port map (a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
      m3333 : if (a_width = 33) and (b_width = 33) generate
        m33 : mul_33_33 generic map (mulpipe => 0)
		port map (clk, vcc, a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
      mgen  : if not(((a_width = 17) and (b_width = 17)) or
                     ((a_width = 33) and (b_width = 33)) or
                     ((a_width = 33) and (b_width = 17)) or
                     ((a_width = 33) and (b_width = 9)))
      generate
        product <= mixed_mul(a, b, sign);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
      end generate;
    end generate;

    arch3 : if (arch = 3) generate	-- designware
      dwm : mul_dw
        generic map (a_width => a_width, b_width => b_width,
		num_stages => 1, stall_mode => 0)
        port map (a => a, b => b, clk => clk, en => en, sign => sign,
		  product => product);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
    end generate;
  end generate;

  pipe2 : if num_stages = 2 generate
    arch0 : if (arch = 0) generate	-- inferred
      dwm : gen_mult_pipe
        generic map (a_width => a_width, b_width => b_width,
		num_stages => num_stages, stall_mode => stall_mode)
        port map (a => a, b => b, clk => clk, en => en, tc => sign,
		  product => product);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
    end generate;
    arch1 : if (arch = 1) generate	-- modgen
      m1717 : if (a_width = 17) and (b_width = 17) generate
        m17 : mul_17_17 generic map (mulpipe => 1)
		port map (clk, en, a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
      m3333 : if (a_width = 33) and (b_width = 33) generate
        m33 : mul_33_33 generic map (mulpipe => 1)
		port map (clk, en, a, b, product);
-- pragma translate_off
        pres <= '1'; sonly <= '1';
-- pragma translate_on
      end generate;
    end generate;
    arch3 : if (arch = 3) generate	-- designware
      dwm : mul_dw
        generic map (a_width => a_width, b_width => b_width,
		num_stages => num_stages, stall_mode => stall_mode)
        port map (a => a, b => b, clk => clk, en => en, sign => sign,
		  product => product);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
    end generate;
  end generate;

  pipe3 : if num_stages > 2 generate
    arch0 : if (arch = 0) generate	-- inferred
      dwm : gen_mult_pipe
        generic map (a_width => a_width, b_width => b_width,
		num_stages => num_stages, stall_mode => stall_mode)
        port map (a => a, b => b, clk => clk, en => en, tc => sign,
		  product => product);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
    end generate;
    arch3 : if (arch = 3) generate	-- designware
      dwm : mul_dw
        generic map (a_width => a_width, b_width => b_width,
		num_stages => num_stages, stall_mode => stall_mode)
        port map (a => a, b => b, clk => clk, en => en, sign => sign,
		  product => product);
-- pragma translate_off
        pres <= '1';
-- pragma translate_on
    end generate;

  end generate;

-- pragma translate_off
    process begin
      wait for 5 ns;
      assert pres = '1' report "techmult: configuration not supported. (width " &
	tost(a_width) & "x" & tost(b_width) & ", tech " & tost(tech) & ", arch " &
	tost(arch) & ")"
      severity failure;
      wait;
    end process;
    process begin
      wait for 5 ns;
      assert not ((sonly = '1') and (sign = '0')) report "techmult: unsinged multiplication for this configuration not supported"
      severity failure;
      if sonly = '1' then wait on sign; else wait; end if;
    end process;

-- pragma translate_on

end;
