-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
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
    interrupt_data_out                  : in  misc_noc_flit_type;
    interrupt_empty                     : in  std_ulogic);

end misc_noc2interrupt;

architecture rtl of misc_noc2interrupt is

  type irq_fsm is (idle, rcv_tail);
  signal irq_state, irq_next : irq_fsm;


begin  -- rtl

  -- Update FSM state
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      irq_state <= idle;
    elsif clk'event and clk = '1' then  -- rising clock edge
      irq_state <= irq_next;
    end if;
  end process;

  set_interrupt: process (interrupt_data_out, interrupt_empty, irq_state)
    variable irq_info : std_logic_vector(RESERVED_WIDTH-1 downto 0);
    variable pirq : integer range 0 to NAHBIRQ-1;
  begin  -- process set_interrupt

    irq_next <= irq_state;
    irq_info := get_reserved_field(MISC_NOC_FLIT_SIZE, noc_flit_pad & interrupt_data_out);
    noc_pirq <= (others => '0');
    interrupt_rdreq <= '0';
    pirq := conv_integer(irq_info);

    case irq_state is
      when idle =>
        if interrupt_empty = '0' then
          interrupt_rdreq <= '1';
          noc_pirq(pirq) <= '1';
          irq_next <= rcv_tail;
        end if;

      when rcv_tail =>
        if interrupt_empty = '0' then
          interrupt_rdreq <= '1';
          irq_next <= idle;
        end if;

      when others => 
        irq_next <= idle;

    end case;

  end process set_interrupt;
  
end rtl;
