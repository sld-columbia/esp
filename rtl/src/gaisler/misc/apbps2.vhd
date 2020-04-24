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
-- Entity:      apbps2
-- File:        apbps2.vhd
-- Author:      Marcus Hellqvist, Jiri Gaisler
-- Modified by: Jan Andersson
-- Description: PS/2 keyboard interface
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.stdlib.all;
use work.amba.all;
use work.devices.all;
use work.misc.all;

entity apbps2 is
  generic(
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    pirq        : integer := 0;
    fKHz        : integer := 50000;
    fixed       : integer := 0;
    oepol       : integer range 0 to 1 := 0
    );
  port(
    rst         : in std_ulogic;        -- Global asynchronous reset
    clk         : in std_ulogic;        -- Global clock
    apbi        : in apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    ps2i        : in ps2_in_type;
    ps2o        : out ps2_out_type
    );
end;

architecture rtl of apbps2 is

constant fifosize       : integer := 16;
type rxstates is (idle,start,data,parity,stop);
type txstates is (idle,waitrequest,start,data,parity,stop,ack);
type fifotype is array(0 to fifosize-1) of std_logic_vector(7 downto 0);

type ps2_regs is record
  -- status reg
  data_ready     : std_ulogic;                                   -- data ready
  parity_error   : std_ulogic;                                   -- parity carry out/ error bit
  frame_error    : std_ulogic;                                   -- frame error when receiving
  kb_inh         : std_ulogic;                                   -- keyboard inhibit
  rbf            : std_ulogic;                                   -- receiver buffer full
  tbf            : std_ulogic;                                   -- transmitter buffer full
  rcnt           : std_logic_vector(log2x(fifosize) downto 0);   -- fifo counter
  tcnt           : std_logic_vector(log2x(fifosize) downto 0);   -- fifo counter
  
  -- control reg
  rx_en          : std_ulogic;                                   -- receive enable
  tx_en          : std_ulogic;                                   -- transmit enable
  rx_irq_en      : std_ulogic;                                   -- keyboard interrupt enable
  tx_irq_en      : std_ulogic;                                   -- transmit interrupt enable
  
  -- others
  tx_act         : std_ulogic;                                   -- tx active
  rxdf           : std_logic_vector(4 downto 0);                 -- rx data filter
  rxcf           : std_logic_vector(4 downto 0);                 -- rx clock filter
  rx_irq         : std_ulogic;                                   -- keyboard interrupt
  tx_irq         : std_ulogic;                                   -- transmit interrupt
  rxfifo         : fifotype;                                     -- fifo with 16 bytes
  rraddr         : std_logic_vector(log2x(fifosize)-1 downto 0); -- fifo read address
  rwaddr         : std_logic_vector(log2x(fifosize)-1 downto 0); -- fifo write address
  rxstate        : rxstates;
  txfifo         : fifotype;                                     -- fifo with 16 bytes
  traddr         : std_logic_vector(log2x(fifosize)-1 downto 0); -- fifo read address
  twaddr         : std_logic_vector(log2x(fifosize)-1 downto 0); -- fifo write address
  txstate        : txstates;
  ps2_clk_syn    : std_ulogic;                                   -- ps2 clock synchronized
  ps2_data_syn   : std_ulogic;                                   -- ps2 data synchronized
  ps2_clk_fall   : std_ulogic;                                   -- ps2 clock falling edge detector
  rshift         : std_logic_vector(7 downto 0);                 -- shift register
  rpar           : std_ulogic;                                   -- parity check bit
  tshift         : std_logic_vector(9 downto 0);                 -- shift register
  tpar           : std_ulogic;                                   -- transmit parity bit
  ps2clk         : std_ulogic;                                   -- ps2 clock
  ps2data        : std_ulogic;                                   -- ps2 data
  ps2clkoe       : std_ulogic;                                   -- ps2 clock output enable
  ps2dataoe      : std_ulogic;                                   -- ps2 data output enable
  timer          : std_logic_vector(16 downto 0);                -- timer
  reload         : std_logic_vector(16 downto 0);                -- reload register
end record;

 constant rcntzero      : std_logic_vector(log2x(fifosize) downto 0) := (others => '0');
 constant REVISION      : integer := 2;
 constant pconfig       : apb_config_type := (
                        0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBPS2, 0, REVISION, pirq),
                        1 => apb_iobar(paddr, pmask),
2 => (others => '0'));

 constant OUTPUT : std_ulogic := conv_std_logic(oepol = 1);
 constant INPUT  : std_ulogic := conv_std_logic(oepol = 0);

 signal r, rin          : ps2_regs;
 signal ps2_clk, ps2_data : std_ulogic;

begin
  ps2_op : process(r, rst, ps2_clk, ps2_data,apbi)
    variable v  : ps2_regs;
    variable rdata : std_logic_vector(31 downto 0);
    variable irq : std_logic_vector(NAHBIRQ-1 downto 0);
  begin
    v := r;
    rdata := (others => '0'); v.data_ready := '0'; irq := (others => '0'); irq(pirq) := r.rx_irq or r.tx_irq;
    v.rx_irq := '0'; v.tx_irq := '0'; v.rbf := r.rcnt(log2x(fifosize)); v.tbf := r.tcnt(log2x(fifosize));

    if r.rcnt /= rcntzero then v.data_ready := '1'; end if;

    -- Synchronize and filter ps2 input
    v.rxdf(0) := ps2_data; v.rxdf(4 downto 1) := r.rxdf(3 downto 0);
    v.rxcf(0) := ps2_clk; v.rxcf(4 downto 1) := r.rxcf(3 downto 0);

    if (r.rxdf(4) & r.rxdf(4) & r.rxdf(4) & r.rxdf(4)) = r.rxdf(3 downto 0) then
      v.ps2_data_syn := r.rxdf(4);
    end if;

    if (r.rxcf(4) & r.rxcf(4) & r.rxcf(4) & r.rxcf(4)) = r.rxcf(3 downto 0) then
      v.ps2_clk_syn := r.rxcf(4);
    end if;

    if (v.ps2_clk_syn /= r.ps2_clk_syn) and (v.ps2_clk_syn = '0') then
      v.ps2_clk_fall := '1';
    else
      v.ps2_clk_fall := '0';
    end if;
    
    -- read registers
    case apbi.paddr(3 downto 2) is
      when "00" =>
	rdata(7 downto 0) := r.rxfifo(conv_integer(r.rraddr));
        if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
          if r.rcnt /= rcntzero then
            v.rxfifo(conv_integer(r.rraddr)) := (others => '0');
            v.rraddr := r.rraddr + 1; v.rcnt := r.rcnt - 1;
          end if;
        end if;
      when "01" =>
	rdata(27 + log2x(fifosize) downto 27) := r.rcnt;
        rdata(22 + log2x(fifosize) downto 22) := r.tcnt;
        rdata(5 downto 0) := r.tbf & r.rbf & r.kb_inh & r.frame_error & r.parity_error & r.data_ready;
      when "10" =>
	rdata(3 downto 0) := r.tx_irq_en & r.rx_irq_en & r.tx_en & r.rx_en;
      when others =>
	if fixed = 0 then rdata(r.reload'range) := r.reload; end if;
    end case;

    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
        when "00" =>
          if r.tcnt(log2x(fifosize)) = '0' then
            v.txfifo(conv_integer(r.twaddr)) := apbi.pwdata(7 downto 0);
            v.twaddr := r.twaddr + 1; v.tcnt := r.tcnt + 1;
          end if;
        when "01" =>
          v.kb_inh := apbi.pwdata(3);
          v.frame_error := apbi.pwdata(2);
          v.parity_error := apbi.pwdata(1);
        when "10" =>
          v.tx_irq_en := apbi.pwdata(3);
          v.rx_irq_en := apbi.pwdata(2);
          v.tx_en := apbi.pwdata(1);
          v.rx_en := apbi.pwdata(0);
        when "11" =>
          if fixed = 0 then
            v.reload := apbi.pwdata(r.reload'range);
          end if;
        when others =>
          null;
      end case;
    end if;

    case r.txstate is
    when idle =>
      if r.tx_en = '1' and r.tcnt /= rcntzero then
        v.ps2clk := '0'; v.ps2clkoe := OUTPUT; v.tx_act := '1';
        v.ps2data := '1'; v.ps2dataoe := OUTPUT; v.txstate := waitrequest;
        if fixed = 1 then v.timer := conv_std_logic_vector(fKHz/10,r.timer'length);
        else v.timer := r.reload; end if;
      end if;
    when waitrequest =>
      v.timer := r.timer - 1;
      if (v.timer(r.timer'left) and not r.timer(r.timer'left)) = '1' then
        v.ps2data := '0'; v.txstate := start;
      end if;
    when start  =>
      v.ps2clkoe := INPUT; v.ps2clk := '1';
      v.tshift := "10" & r.txfifo(conv_integer(r.traddr));
      v.traddr := r.traddr + 1; v.tcnt := r.tcnt - 1;
      v.tpar := '1';
      v.txstate := data;
    when data =>
      if r.ps2_clk_fall = '1' then
        v.ps2data := r.tshift(0);
        v.tpar := r.tpar xor r.tshift(0);
        v.tshift := '1' & r.tshift(9 downto 1);
        if v.tshift = "1111111110" then v.txstate := parity; end if;
      end if;
    when parity =>
      if r.ps2_clk_fall = '1' then
        v.ps2data := r.tpar; v.txstate := stop;
      end if;
    when stop =>
      if r.ps2_clk_fall = '1' then
        v.ps2data := '1'; v.txstate := ack;
      end if;
    when ack =>
      v.ps2dataoe := INPUT;
      if r.ps2_clk_fall = '1' and r.ps2_data_syn = '0'then
        v.ps2data := '1'; v.ps2dataoe := OUTPUT; v.tx_irq := r.tx_irq_en;
        v.txstate := idle; v.tx_act := '0';
      end if;
    end case;

    -- receiver state machine
    case r.rxstate is
    when idle =>
      if (r.rx_en and not r.tx_act) = '1' then
        v.rshift := (others => '1'); v.rxstate := start;
      end if;
    when start =>
      if r.ps2_clk_fall = '1' then
        if r.ps2_data_syn = '0' then
          v.rshift := r.ps2_data_syn & r.rshift(7 downto 1);
          v.rxstate := data; v.rpar := '0';
          v.parity_error := '0'; v.frame_error := '0';
        else v.rxstate := idle; end if;
      end if;
    when data =>
      if r.ps2_clk_fall = '1' then
        v.rshift := r.ps2_data_syn & r.rshift(7 downto 1);
        v.rpar := r.rpar xor r.ps2_data_syn;
        if r.rshift(0) = '0' then v.rxstate := parity; end if;
      end if;
    when parity =>
      if r.ps2_clk_fall = '1' then
        v.parity_error := r.rpar xor (not r.ps2_data_syn);
        v.rxstate := stop;
      end if;
    when stop =>
      if r.ps2_clk_fall = '1' then
        if r.ps2_data_syn = '1' then
          v.rx_irq := r.rx_irq_en; v.rxstate := idle;
          if (r.rbf or r.parity_error) = '0' then
            v.rxfifo(conv_integer(r.rwaddr)) := r.rshift(7 downto 0);
            v.rwaddr := r.rwaddr + 1; v.rcnt := r.rcnt + 1;
          end if;
        else v.frame_error := '1'; v.rxstate := idle; end if;
      end if;
    end case;

    -- keyboard inhibit / high impedance
    if v.tx_act = '0' then
      if r.rbf = '1' then
        v.kb_inh := '1'; v.ps2clk := '0'; v.ps2data := '1';
        v.ps2dataoe := OUTPUT; v.ps2clkoe := OUTPUT;
      else
        v.ps2clk := '1'; v.ps2data := '1'; v.ps2dataoe := INPUT;
        v.ps2clkoe := INPUT;
      end if;
    end if;

    if r.tx_act = '1' then
      v.rxstate := idle;
    end if;
    
    -- reset operations
    if rst = '0' then
      v.data_ready := '0'; v.kb_inh := '0'; v.parity_error := '0';
      v.frame_error := '0'; v.rx_en := '0'; v.tx_act := '0';
      v.tx_en := '0'; v.rx_irq := '0'; v.tx_irq := '0';
      v.ps2_clk_fall  := '0'; v.ps2_clk_syn  := '0'; v.ps2_data_syn := '0';
      v.rshift := (others => '0'); v.rxstate := idle; v.txstate := idle;
      v.rraddr := (others => '0'); v.rwaddr := (others => '0');
      v.rcnt := (others => '0'); v.traddr := (others => '0');
      v.twaddr := (others => '0'); v.tcnt := (others => '0');
      v.tshift := (others => '0'); v.tpar := '0';
      if fixed = 0 then
        v.reload := conv_std_logic_vector(fKHz/10,r.reload'length);
      end if;
    end if;
    
    if fixed = 1 then v.reload := (others => '0'); end if;

    -- update registers
    rin <= v;

    -- drive outputs
    apbo.prdata      <= rdata;
    apbo.pirq        <= irq;
    apbo.pindex      <= pindex;
    ps2o.ps2_clk_o   <= r.ps2clk;
    ps2o.ps2_clk_oe  <= r.ps2clkoe;
    ps2o.ps2_data_o  <= r.ps2data;
    ps2o.ps2_data_oe <= r.ps2dataoe;
  end process;

  apbo.pconfig <= pconfig;

  regs : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      ps2_data <= to_x01(ps2i.ps2_data_i);
      ps2_clk <= to_x01(ps2i.ps2_clk_i);
    end if;
  end process;

-- pragma translate_off
    bootmsg : report_version
    generic map ("apbps2_" & tost(pindex) & ": APB PS2 interface rev " &
                 tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end;

