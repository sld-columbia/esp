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
-- Entity:      pt_pci_master
-- File:        pt_pci_master.vhd
-- Author:      Nils Johan Wessman, Aeroflex Gaisler
-- Description: PCI Testbench Master
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

use work.pt_pkg.all;

use work.stdlib.xorv;
use work.stdlib.tost;
use work.testlib.print;


entity pt_pci_master is
  generic (
    slot : integer := 0;
    tval : time := 7 ns);
  port (
    -- PCI signals
    pciin     : in pci_type;
    pciout    : out pci_type;
    -- Debug interface signals
    dbgi       : in  pt_pci_master_in_type;
    dbgo       : out pt_pci_master_out_type
       );
end pt_pci_master;

architecture behav of pt_pci_master is

-- NEW =>
type access_element_type;
type access_element_ptr is access access_element_type;
type access_element_type is record
  acc : pt_pci_access_type;
  nxt : access_element_ptr;
end record;
constant idle_acc : pt_pci_access_type := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), 
                                           0, 0, 0, 0, false, false, false, false, 0, 0);
signal pci_core : pt_pci_master_in_type;
signal core_pci : pt_pci_master_out_type;

-- Description: Insert a access at the "tail" of the linked list of accesses
procedure add_acc (
  variable acc_head : inout access_element_ptr;
  variable acc_tail : inout access_element_ptr;
  signal   acc      : in    pt_pci_access_type) is
  variable elem : access_element_ptr;
begin  -- insert_access
  elem := acc_tail;
  if elem /= NULL then
    elem.nxt := new access_element_type'(acc, NULL);
    acc_tail := elem.nxt;
  else
    acc_head := new access_element_type'(acc, NULL);
    acc_tail := acc_head;
  end if;
end add_acc;
  
-- Description: Get the access at the "head" of the linked list of accesses
-- and remove if from the list
procedure pop_acc (
  variable acc_head : inout access_element_ptr;
  variable acc_tail : inout access_element_ptr;
  signal   acc      : out   pt_pci_access_type;
  variable found    : out   boolean) is
  variable elem     : access_element_ptr;
begin  -- pop_access
  elem := acc_head;
  
  if elem /= NULL then
    found := true;
    acc <= elem.acc;
    if elem = acc_tail then
      acc_head := NULL;
      acc_tail := NULL;
    else
      acc_head := elem.nxt;
    end if;
    deallocate(elem);
  else
    found := false;
    acc <= idle_acc;
  end if;
end pop_acc;

-- Description: Searches the list for a result to a particular id.
procedure get_res (
  variable res_head   : inout access_element_ptr;
  variable res_tail   : inout access_element_ptr;
  signal   accin      : in    pt_pci_access_type;
  signal   acc        : out   pt_pci_access_type;
  variable found      : out   boolean) is
  variable elem, prev : access_element_ptr;
  variable lfound : boolean := false;
begin  -- get_result
  prev := res_head;
  elem := res_head;
  
  while elem /= NULL and not lfound loop
    -- Check if result is a match for id 
    if accin.id = elem.acc.id then
      acc <= elem.acc;
      lfound := true;
      if prev = res_head then
        res_head := elem.nxt;
      else
        prev.nxt := elem.nxt;
      end if;
      if elem = res_tail then
        res_tail := NULL;
      end if;
      deallocate(elem);
    end if;
    if not lfound then
      prev := elem;
      elem := elem.nxt;
    end if;
  end loop;
  
  if lfound then found := true;
  else found := false; acc <= idle_acc; end if;
end get_res;

-- Description: 
procedure rm_acc (
  variable acc_head : inout access_element_ptr;
  variable acc_tail : inout access_element_ptr;
  signal   acc      : in    pt_pci_access_type;
  constant rmall    : in    boolean )is
  variable elem, prev : access_element_ptr;
  variable lfound : boolean := false;
begin  -- rm_access
  prev := acc_head;
  elem := acc_head;
  while elem /= NULL and not lfound loop
    if rmall = true then
      prev := elem;
      elem := elem.nxt;
      deallocate(prev);
    else
      if acc.addr = elem.acc.addr then
        if prev = acc_head then
          acc_head := elem.nxt;
        else
          prev.nxt := elem.nxt;
        end if;
        if elem = acc_tail then
          acc_tail := NULL;
        end if;
        deallocate(elem);
        lfound := true;
      else
        prev := elem;
        elem := elem.nxt;
      end if;
    end if;
  end loop;
  if rmall = true then
    acc_head := NULL;
    acc_tail := NULL;
  end if;
end rm_acc;
-- <= NEW

type state_type is(idle, addr, data, turn, active, done);
type reg_type is record
  state         : state_type;
  pcien         : std_logic_vector(3 downto 0);
  perren        : std_logic_vector(1 downto 0);
  read          : std_logic;
  grant         : std_logic;
  perr_ad       : std_logic_vector(31 downto 0);
  perr_cbe      : std_logic_vector(3 downto 0);
  devsel_timeout  : integer range 0 to 3;
  pci           : pci_type;
  acc           : pt_pci_access_type;
  parerr        : std_logic;
end record;

signal r,rin : reg_type;

begin

-- NEW =>
  core_acc : process
  variable acc_head : access_element_ptr := NULL;
  variable acc_tail : access_element_ptr := NULL;
  variable res_head : access_element_ptr := NULL;
  variable res_tail : access_element_ptr := NULL;
  variable res_to_find : pt_pci_access_type := idle_acc;
  variable found : boolean;
  begin
    if pci_core.req /= '1' and dbgi.req /= '1' then
      wait until pci_core.req = '1' or dbgi.req = '1'; 
    end if;

    if dbgi.req = '1' then
      dbgo.res_found <= '0';
      if dbgi.add = true then
        add_acc(acc_head, acc_tail, dbgi.acc);
      elsif dbgi.remove = true then
        rm_acc(acc_head, acc_tail, dbgi.acc, dbgi.rmall);
      elsif dbgi.get_res = true then
        dbgo.valid <= false;
        get_res(res_head, res_tail, dbgi.acc, dbgo.acc, found);
        if found = true then dbgo.valid <= true; res_to_find := idle_acc;
        else res_to_find := dbgi.acc; end if;
      else
        dbgo.valid <= false;
        pop_acc(acc_head, acc_tail, dbgo.acc, found);
        if found = true then dbgo.valid <= true; end if;
      end if;

      dbgo.ack <= '1';
      wait until dbgi.req = '0';
      dbgo.ack <= '0';
    end if;
    
    if pci_core.req = '1' then
      if pci_core.add = true then
        add_acc(acc_head, acc_tail, pci_core.acc);
      elsif pci_core.add_res = true then
        add_acc(res_head, res_tail, pci_core.acc);
        if res_to_find.valid = true and  pci_core.acc.id = res_to_find.id then
          dbgo.res_found <= '1';
        end if;
      else
        core_pci.valid <= false;
        pop_acc(acc_head, acc_tail, core_pci.acc, found);
        if found = true then core_pci.valid <= true; end if;
      end if;

      core_pci.ack <= '1';
      wait until pci_core.req = '0';
      core_pci.ack <= '0';
    end if;
  end process;

-- <= NEW

  pt_pci_core : process
  
  procedure sync_with_core is
  begin
    pci_core.req <= '1';
    wait until core_pci.ack = '1';
    pci_core.req <= '0';
    wait until core_pci.ack = '0';
  end sync_with_core;
  
  function check_data(
    constant pci_data   : std_logic_vector(31 downto 0);
    constant comp_data  : std_logic_vector(31 downto 0);
    constant cbe        : std_logic_vector(3 downto 0))
    return boolean is
    variable res  : boolean := true;
    variable data : std_logic_vector(31 downto 0);
  begin
    
    data := comp_data;
    if cbe(0) = '1' then data(7 downto 0) := (others => '-'); end if;
    if cbe(1) = '1' then data(15 downto 8) := (others => '-'); end if;
    if cbe(2) = '1' then data(23 downto 16) := (others => '-'); end if;
    if cbe(3) = '1' then data(31 downto 24) := (others => '-'); end if;
    for i in 0 to 31 loop
      if pci_data(i) /= data(i) and data(i) /= '-' then res := false; end if; 
    end loop;
    return res;
  end check_data;

  variable v : reg_type;
  variable vpciin : pci_type;

  begin
    if to_x01(pciin.syst.rst) = '0' then
      v.state := idle;
      v.pcien := (others => '0');
      v.pci   := pci_idle;
      v.pci.ifc.frame := '1';
      v.pci.ifc.irdy := '1';
      v.read  := '0';
      v.perren := (others => '0');
      v.parerr := '0';
    elsif rising_edge(pciin.syst.clk) then
      v := r;
      vpciin := pciin;

      v.grant := to_x01(vpciin.ifc.frame) and to_x01(vpciin.ifc.irdy) and not r.pci.arb.req(slot) and not to_x01(vpciin.arb.gnt(slot));
      v.pcien(1) := r.pcien(0); v.pcien(2) := r.pcien(1);
      v.pci.ad.par := xorv(r.pci.ad.ad & r.pci.ad.cbe & r.parerr);
      v.perr_ad := vpciin.ad.ad; v.perr_cbe := vpciin.ad.cbe;
      v.pci.err.perr := (not xorv(r.perr_ad & r.perr_cbe & to_x01(vpciin.ad.par))) or not r.read;
      v.perren(1) := r.perren(0);

      case r.state is
        when idle =>
          if core_pci.valid = true then
            if r.acc.idle = false then
              v.pci.arb.req(slot) := '0';
              if v.grant = '1' then
                v.pcien(0) := '1'; 
                v.pci.ifc.frame := '0';
                v.pci.ad.ad := core_pci.acc.addr;
                v.pci.ad.cbe := core_pci.acc.cbe_cmd;
                if core_pci.acc.parerr = 2 then v.parerr := '1'; else v.parerr := '0'; end if;
                v.state := addr;
                v.read := '0';
                v.perren := (others => '0');
              end if;
            else      -- Idle cycle
              if r.acc.ws <= 0 then
                if r.acc.list_res = true then -- store result
                  pci_core.acc <= r.acc;
                  pci_core.add_res <= true; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                  wait for 1 ps;
                end if;
                pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                v.acc := core_pci.acc;
              else
                v.acc.ws := r.acc.ws - 1;
              end if;
            end if;
          else
            pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
            v.acc := core_pci.acc;
          end if;
        when addr =>
          if r.acc.last = true and r.acc.ws <= 0 then v.pci.ifc.frame := '1'; v.pci.arb.req(slot) := '1'; end if;
          if (r.acc.cbe_cmd = MEM_READ or r.acc.cbe_cmd = MEM_R_MULT or r.acc.cbe_cmd = MEM_R_LINE 
              or r.acc.cbe_cmd = IO_READ or r.acc.cbe_cmd = CONF_READ) then
            v.read := '1';
          end if;
          if r.acc.ws <= 0 then v.pci.ifc.irdy := '0'; v.pci.ad.ad := r.acc.data;
          else v.acc.ws := r.acc.ws - 1; v.pci.ad.ad := (others => '-'); end if;
          v.pci.ad.cbe := r.acc.cbe_data;
          if core_pci.acc.parerr = 1 then v.parerr := '1'; else v.parerr := '0'; end if;
          v.state := data;
          v.devsel_timeout := 0;
        when data =>
          if r.pci.ifc.irdy = '1' and r.acc.ws /= 0 then 
            v.acc.ws := r.acc.ws - 1;   
          else 
            v.pci.ifc.irdy := '0';
            v.pci.ad.ad := r.acc.data;
            if r.acc.last = true or to_x01(vpciin.ifc.stop) = '0' then v.pci.ifc.frame := '1'; v.pci.arb.req(slot) := '1'; end if;
          end if;

          if to_x01(vpciin.ifc.devsel) = '1' then
            if r.devsel_timeout < 3 then 
              v.devsel_timeout := r.devsel_timeout + 1; 
            else 
              v.pci.ifc.frame := '1'; 
              v.pci.ifc.irdy := '1'; 
              if r.pci.ifc.frame = '1' then
                v.pcien(0) := '0';
                v.state := idle;
                if r.acc.list_res = true then -- store result
                  pci_core.acc <= r.acc; -- should set Master abort status in this response
                  pci_core.add_res <= true; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                  wait for 1 ps;
                end if;
                pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                v.acc := core_pci.acc;
                if r.acc.debug >= 1 then
                  if r.read = '1' then
                    print("ERROR: PCITBM Read[" & tost(r.acc.addr) & "]: MASTER ABORT");
                  else
                    print("ERROR: PCITBM WRITE[" & tost(r.acc.addr) & "]: MASTER ABORT");
                  end if;
                end if;
              end if;
            end if;
          end if;

          --if to_x01(vpciin.ifc.trdy) = '0' and r.pci.ifc.irdy = '0' then
          if (to_x01(vpciin.ifc.trdy) = '0' or (r.acc.cod = 1 and to_x01(vpciin.ifc.stop) = '0')) and r.pci.ifc.irdy = '0' then
            if r.read = '1' then v.perren(0) := '1'; end if; -- only drive perr from read
            if r.pci.ifc.frame = '1' then -- done
              v.pcien(0) := '0'; v.pci.ifc.irdy := '1';
              if r.acc.list_res = true then -- store result
                pci_core.acc <= r.acc;
                if r.read = '1' then pci_core.acc.data <= vpciin.ad.ad; end if;
                pci_core.add_res <= true; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                wait for 1 ps;
              end if;
              pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
              v.acc := core_pci.acc;
              v.state := idle;
            else
              if r.acc.list_res = true then -- store result
                pci_core.acc <= r.acc;
                if r.read = '1' then pci_core.acc.data <= vpciin.ad.ad; end if;
                pci_core.add_res <= true; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                wait for 1 ps;
              end if;
              pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
              v.acc := core_pci.acc;
              if core_pci.valid = true then
                v.pci.ad.cbe := v.acc.cbe_data;
                if core_pci.acc.parerr = 1 then v.parerr := '1'; else v.parerr := '0'; end if;
                if v.acc.ws <= 0 then
                  v.pci.ad.ad := v.acc.data;
                  if v.acc.last = true or to_x01(vpciin.ifc.stop) = '0' then v.pci.ifc.frame := '1'; v.pci.arb.req(slot) := '1'; end if;
                else
                  v.pci.ad.ad := (others => '-');
                  if v.pci.ifc.frame = '0' then v.pci.ifc.irdy := '1'; end if; -- If frame => '1', do not add waitstates (irdey => '1')
                  v.acc.ws := v.acc.ws - 1;
                end if;
              else
                assert false
                report "No valid acces in list, access required! (no access is marked LAST)"
                severity FAILURE;
              end if;
            end if;
            if r.acc.debug >= 1 then
              if r.acc.cod = 1 and to_x01(vpciin.ifc.stop) = '0' and to_x01(vpciin.ifc.trdy) = '1' then
                if r.read = '1' then
                  print("PCITBM Read[" & tost(r.acc.addr) & "]: CANCELED ON DISCONNECT");
                else
                  print("PCITBM WRITE[" & tost(r.acc.addr) & "]: CANCELED ON DISCONNECT");
                end if;
              else
                if r.read = '1' then
                  if check_data(vpciin.ad.ad, r.pci.ad.ad, r.pci.ad.cbe) = false then
                    print("ERROR: PCITBM Read[" & tost(r.acc.addr) & "]: " & tost(vpciin.ad.ad) & " != " & tost(r.pci.ad.ad));
                  elsif r.acc.debug >= 2 then
                    print("PCITBM Read[" & tost(r.acc.addr) & "]: " & tost(vpciin.ad.ad));
                  end if;
                else
                  if r.acc.debug >= 2 then
                    print("PCITBM Write[" & tost(r.acc.addr) & "]: " & tost(vpciin.ad.ad));
                  end if;
                end if;
              end if;
            end if;
          elsif to_x01(vpciin.ifc.stop) = '0' and r.pci.ifc.frame = '1' then -- Disconnect
            v.pcien(0) := '0';
            v.pci.ifc.irdy := '1';
            v.state := idle;
            if to_x01(vpciin.ifc.devsel) = '1' then
              if r.acc.list_res = true then -- store result
                pci_core.acc <= r.acc; -- should set Master abort status in this response
                pci_core.add_res <= true; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
                wait for 1 ps;
              end if;
              pci_core.add_res <= false; pci_core.add <= false; pci_core.remove <= false; sync_with_core;
              v.acc := core_pci.acc;
              if r.acc.debug >= 1 then
                if r.read = '1' then
                  print("ERROR: PCITBM Read[" & tost(r.acc.addr) & "]: TARGET ABORT");
                else
                  print("ERROR: PCITBM WRITE[" & tost(r.acc.addr) & "]: TARGET ABORT");
                end if;
              end if;
            end if;
          end if;
        when turn =>
        when active =>
        when done =>
        when others =>
      end case;
    end if;

    r <= v;

    wait on pciin.syst.clk, pciin.syst.rst;

  end process;
  
  pciout.ad.ad <= r.pci.ad.ad after tval when (r.pcien(0) and not r.read) = '1' else (others => 'Z') after tval;
  pciout.ad.cbe <= r.pci.ad.cbe after tval when r.pcien(0) = '1' else (others => 'Z') after tval;
  pciout.ad.par <= r.pci.ad.par after tval when (r.pcien(1) = '1' and (r.read = '0' or r.pcien(3 downto 0) = "0011")) else 'Z' after tval;
  pciout.ifc.frame <= r.pci.ifc.frame after tval when r.pcien(0) = '1' else 'Z' after tval;
  pciout.ifc.irdy <= r.pci.ifc.irdy after tval when r.pcien(1) = '1' else 'Z' after tval;
  pciout.err.perr <= r.pci.err.perr after tval when (r.pcien(2) and r.perren(1)) = '1' else 'Z' after tval;
  pciout.err.serr <= r.pci.err.serr after tval when r.pcien(2) = '1' else 'Z' after tval;
  -- Unused signals
  pciout.arb <= arb_const;
  
  pciout.arb.req(slot) <= r.pci.arb.req(slot) after tval;
  
  -- Unused signals
  pciout.ifc.trdy <= 'Z';
  pciout.ifc.stop <= 'Z';
  pciout.ifc.devsel <= 'Z';
  pciout.ifc.lock <= 'Z';
  pciout.ifc.idsel <= (others => 'Z');
  pciout.err.serr <= 'Z';
  pciout.syst <= syst_const;
  pciout.ext64 <= ext64_const;
  pciout.cache <= cache_const;
  pciout.int <= (others => 'Z');

end;

-- pragma translate_on

