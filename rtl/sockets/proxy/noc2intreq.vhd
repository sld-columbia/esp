-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;

entity noc2intreq is
  generic (
    tech         : integer := virtex7);
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    noc_pirq : out std_logic_vector(NAHBIRQ-1 downto 0);

    -- NoC5->tile
    interrupt_rdreq                     : out std_ulogic;
    interrupt_data_out                  : in  misc_noc_flit_type;
    interrupt_empty                     : in  std_ulogic);

end noc2intreq;

architecture rtl of noc2intreq is


begin  -- rtl

  set_interrupt: process (interrupt_data_out, interrupt_empty)
    variable irq_info : std_logic_vector(RESERVED_WIDTH-1 downto 0);
    variable pirq : integer range 0 to NAHBIRQ-1;
  begin  -- process set_interrupt
    irq_info := get_reserved_field(MISC_NOC_FLIT_SIZE, noc_flit_pad & interrupt_data_out);
    noc_pirq <= (others => '0');
    interrupt_rdreq <= '0';
    pirq := conv_integer(irq_info);

    if interrupt_empty = '0' then
      interrupt_rdreq <= '1';
      noc_pirq(pirq) <= '1';
    end if;
  end process set_interrupt;

end rtl;
