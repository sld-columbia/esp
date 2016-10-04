------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
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
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  misc_noc2interrupt
-- File:    misc_noc2interrupt.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	Interrupt forwarding from NoC to APB proxy
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;

entity misc_noc2interrupt is
  generic (
    tech         : integer := virtex7;
    local_y      : local_yx;
    local_x      : local_yx);

  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    noc_pirq : out std_logic_vector(NAHBIRQ-1 downto 0);

    -- NoC5->tile
    interrupt_rdreq                     : out std_ulogic;
    interrupt_data_out                  : in  noc_flit_type;
    interrupt_empty                     : in  std_ulogic);

end misc_noc2interrupt;

architecture rtl of misc_noc2interrupt is


begin  -- rtl

  set_interrupt: process (interrupt_data_out, interrupt_empty)
    variable irq_info : std_logic_vector(RESERVED_WIDTH-1 downto 0);
    variable pirq : integer range 0 to NAHBIRQ-1;
  begin  -- process set_interrupt
    irq_info := get_reserved_field(interrupt_data_out);
    noc_pirq <= (others => '0');
    interrupt_rdreq <= '0';
    pirq := conv_integer(irq_info);

    if interrupt_empty = '0' then
      interrupt_rdreq <= '1';
      noc_pirq(pirq) <= '1';
    end if;
  end process set_interrupt;

end rtl;
