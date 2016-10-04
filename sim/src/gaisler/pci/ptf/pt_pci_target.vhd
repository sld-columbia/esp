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
-- Entity:      pt_pci_target
-- File:        pt_pci_target.vhd
-- Author:      Nils-Johan Wessman, Aeroflex Gaisler
-- Description: PCI Target emulator.
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

use work.stdlib.all;
use work.pt_pkg.all;
--use work.pcilib.all;
--use work.ambatest.all;


library std;
use std.textio.all;


entity pt_pci_target is
  generic (
    slot : integer := 0;
    abits : integer := 10;
    bars : integer := 1;
    resptime : integer := 2;
    latency : integer := 0;
    rbuf : integer := 8;
    stopwd : boolean := true;
    tval : time := 7 ns;
    conf : config_header_type := config_init;
    dbglevel : integer := 1);
  port (
    -- PCI signals
    pciin     : in pci_type;
    pciout    : out pci_type;
    -- TB signals
    dbgi       : in  pt_pci_target_in_type;
    dbgo       : out  pt_pci_target_out_type
       );
end pt_pci_target;

architecture tb of pt_pci_target is

constant T_O : integer := 9;
constant word : std_logic_vector(2 downto 0) := "100";

type response_element_type;
type response_element_ptr is access response_element_type;
type response_element_type is record
  id   : integer;
  resp : pt_pci_response_type;
  nxt  : response_element_ptr;
end record;
signal resp : pt_pci_response_type;
constant non_resp : pt_pci_response_type := ((others => '0'), 0, 0, 0, 0, 0, 0, 0, true);
type resp_print_type is array (0 to 8) of string(1 to 5);
constant resp_print : resp_print_type := ("-----", "retry", "-----", "disw ", "diswo", "abort", "parer", "debug", "-----");

signal pci_core : pt_pci_target_in_type;
signal core_pci : pt_pci_target_out_type;


type mem_type is array(0 to ((2**abits)-1)) of std_logic_vector(31 downto 0);

type state_type is(idle,b_busy,respwait,tabort,write,read,latw,retry,dis);
type reg_type is record
  state         : state_type;
  pci           : pci_type;
  pcien         : std_logic;
  aden          : std_logic;
  paren         : std_logic;
  erren         : std_logic;
  write         : std_logic;
  waitcycles    : integer;
  latcnt        : integer;
  curword       : integer;
  first         : boolean;
  di            : std_logic_vector(31 downto 0);
  ad            : std_logic_vector(31 downto 0);
  comm          : std_logic_vector(3 downto 0);
  config        : config_header_type;
  cbe           : std_logic_vector(3 downto 0); -- *** sub-word write
  retrycnt      : std_logic_vector(7 downto 0);
  resp          : pt_pci_response_type;
  resp_addr     : std_logic_vector(31 downto 0);
  parerr        : std_logic;
  firstacc      : std_logic;
  perren        : std_logic_vector(1 downto 0);
  pcirad        : std_logic_vector(31 downto 0);
  pcircbe       : std_logic_vector(3 downto 0);
  sigperr       : std_logic_vector(2 downto 0);
end record;

signal r,rin : reg_type;
signal do : std_logic_vector(31 downto 0);

procedure readconf(ad : in std_logic_vector(5 downto 0); data : out std_logic_vector(31 downto 0)) is
begin
  case conv_integer(ad) is
  when 0 => data(31 downto 16) := (conv_std_logic_vector(slot,4) & r.config.devid(11 downto 0));
            data(15 downto 0) := r.config.vendid;
  when 1 => data(31 downto 16) := r.config.status; data(15 downto 0) := r.config.command;
  when 2 => data(31 downto 8) := r.config.class_code; data(7 downto 0) := r.config.revid;
  when 3 => data(31 downto 24) := r.config.bist; data(23 downto 16) := r.config.header_type;
            data(15 downto 8) := r.config.lat_timer; data(7 downto 0) := r.config.cache_lsize;
  when 4 => data := r.config.bar(0)(31 downto abits) & zero32(abits-1 downto 0);
  when 5 => if bars > 1 then data := r.config.bar(1)(31 downto 9) & zero32(8 downto 1) & '1';
            else data := (others => '0'); end if;
  when 6 => if bars > 2 then data := r.config.bar(2)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 7 => if bars > 3 then data := r.config.bar(3)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 8 => if bars > 4 then data := r.config.bar(4)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 9 => if bars > 5 then data := r.config.bar(5)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 10 => data := r.config.cis_p;
  when 11 => data(31 downto 16) := r.config.subid; data(15 downto 0) := r.config.subvendid;
  when 12 => data := r.config.exp_rom_ba;
  when 13 => data(31 downto 24) := r.config.max_lat; data(23 downto 16) := r.config.min_gnt;
             data(15 downto 8) := r.config.int_pin; data(7 downto 0) := r.config.int_line;
  when others =>
  end case;
end procedure;

procedure writeconf(ad : in std_logic_vector(5 downto 0);
                    data : in std_logic_vector(31 downto 0);
                    cbe  : in std_logic_vector(3 downto 0);
                    vconfig : out config_header_type) is
  variable new_data : std_logic_vector(31 downto 0);
begin
  readconf(ad,new_data);
  if cbe(3) = '0' then new_data(31 downto 24) := data(31 downto 24); end if;
  if cbe(2) = '0' then new_data(23 downto 16) := data(23 downto 16); end if;
  if cbe(1) = '0' then new_data(15 downto  8) := data(15 downto  8); end if;
  if cbe(0) = '0' then new_data( 7 downto  0) := data( 7 downto  0); end if;

  case conv_integer(ad) is
--  when 0 => vconfig.devid := new_data(31 downto 16); vconfig.vendid <= new_data(15 downto 0);
  when 1 => vconfig.status := new_data(31 downto 16); vconfig.command := new_data(15 downto 0);
  when 2 => vconfig.class_code := new_data(31 downto 8); vconfig.revid := new_data(7 downto 0);
  when 3 => vconfig.bist := new_data(31 downto 24); vconfig.header_type := new_data(23 downto 16);
            vconfig.lat_timer := new_data(15 downto 8); vconfig.cache_lsize := new_data(7 downto 0);
  when 4 => vconfig.bar(0) := new_data;
  when 5 => vconfig.bar(1) := new_data;
  when 6 => vconfig.bar(2) := new_data;
  when 7 => vconfig.bar(3) := new_data;
  when 8 => vconfig.bar(4) := new_data;
  when 9 => vconfig.bar(5) := new_data;
  when 10 => vconfig.cis_p := new_data;
  when 11 => vconfig.subid := new_data(31 downto 16); vconfig.subvendid := new_data(15 downto 0);
  when 12 => vconfig.exp_rom_ba := new_data;
  when 13 => vconfig.max_lat := new_data(31 downto 24); vconfig.min_gnt := new_data(23 downto 16);
             vconfig.int_pin := new_data(15 downto 8); vconfig.int_line := new_data(7 downto 0);
  when others =>
  end case;
end procedure;

function pci_hit(ad : std_logic_vector(31 downto 0);
                 c : std_logic_vector(3 downto 0);
                 idsel : std_logic;
                 con : config_header_type) return boolean is
variable hit : boolean;
begin
  hit := false;

  if ((c = CONF_READ or c = CONF_WRITE)
  and idsel = '1' and ad(1 downto 0) = "00")
  then hit := true;
  else
    for i in 0 to bars-1 loop
      if i = 1 then
        if ((c = IO_READ or c = IO_WRITE)
        and ad(31 downto abits) = con.bar(i)(31 downto abits))
        then hit := true; end if;
      else
        if ((c = MEM_READ or c = MEM_WRITE or c = MEM_R_MULT or c = MEM_R_LINE or c = MEM_W_INV)
        and ad(31 downto abits) = con.bar(i)(31 downto abits))
        then hit := true; end if;
      end if;
    end loop;
  end if;
  return(hit);
end function;

-- Description: Insert a response into the linked list of responses
procedure insert_resp (
  constant id        : in    integer;
  variable resp_root : inout response_element_ptr;
  signal   resp      : in    pt_pci_response_type) is
  variable elem : response_element_ptr;
begin  -- insert_resp
  elem := resp_root;
  if elem /= NULL then
    while elem.nxt /= NULL loop elem := elem.nxt; end loop;
    elem.nxt := new response_element_type'(id, resp, NULL);
  else
    resp_root := new response_element_type'(id, resp, NULL);
  end if;
end insert_resp;
  
-- Description: Searches the list for a response to a particular address.
-- If a response is found the response is returned via 'resp' and 'found'
-- is set to true, otherwise 'found' is set to false.
procedure get_resp (
  variable resp_root : inout response_element_ptr;
  signal   addr      : in    std_logic_vector(31 downto 0);
  signal   resp      : out   pt_pci_response_type;
  variable found     : out   boolean) is
  variable elem, prev : response_element_ptr;
  variable lfound : boolean := false;
begin  -- get_resp
  prev := resp_root;
  elem := resp_root;
  
  --print(tost(NOW/1 ns) & "ns get_resp: addr[" & tost(addr) & "]"); 
  while elem /= NULL and not lfound loop
    -- Check if response is a match for address 
    if addr(abits-1 downto 0) = elem.resp.addr(abits-1 downto 0) then
      resp <= elem.resp;
      lfound := true;
      resp.valid <= true;
      --if prev = resp_root then
      --  resp_root := elem.nxt;
      --else
      --  prev.nxt := elem.nxt;
      --end if;
      --deallocate(elem);
    end if;
    if not lfound then
      prev := elem;
      elem := elem.nxt;
    end if;
  end loop;
  --print(tost(NOW/1 ns) & "ns get_resp: found[" & tost(lfound) & "]"); 
  if lfound then found := true;
  else
    found := false; 
    resp.retry <= 0;
    resp.ws <= 0;
    resp.diswithout <= 0;
    resp.diswith <= 0;
    resp.parerr <= 0;
    resp.abort <= 0;
    resp.debug <= 0;
    resp.valid <= false;
  end if;
end get_resp;

-- Description: Searches the list for a response with a particular addr.
-- If a response is found the response is removed and the id
-- will match the input id. 
procedure rm_resp (
  variable resp_root : inout response_element_ptr;
  constant addr      : in    std_logic_vector(31 downto 0) )is
  variable elem, prev : response_element_ptr;
  variable lfound : boolean := false;
begin  -- rm_resp
  prev := resp_root;
  elem := resp_root;
  while elem /= NULL and not lfound loop
    if addr(abits-1 downto 0) = elem.resp.addr(abits-1 downto 0) then
      if prev = resp_root then
        resp_root := elem.nxt;
      else
        prev.nxt := elem.nxt;
      end if;
      deallocate(elem);
      lfound := true;
    else
      prev := elem;
      elem := elem.nxt;
    end if;
  end loop;
end rm_resp;

-- Description: Removes all responses in list
procedure rm_all_resp (
  variable resp_root : inout response_element_ptr) is
  variable elem, curr : response_element_ptr;
  variable lfound : boolean := false;
begin  -- rm_all_resp
  curr := resp_root;
  elem := resp_root;
  while elem /= NULL loop
    curr := elem;
    elem := elem.nxt;
    deallocate(curr);
  end loop;
  resp_root := NULL;
end rm_all_resp;

begin

  cont : process
  variable first : boolean := true;
  variable mem : mem_type;
  begin
    if first then
      for i in 0 to ((2**abits)-1) loop
        mem(i) := (others => '0');
      end loop;
      first := false;
    elsif r.ad(0) /= 'U' then
      do <= mem(conv_integer(to_x01(r.ad)));
      --if r.write = '1' then mem(conv_integer(to_x01(r.ad))) := r.di; end if; -- *** sub-word write
      if r.write = '1' then 
        case r.cbe is
        when "1110" =>
          mem(conv_integer(to_x01(r.ad)))(7 downto 0) := r.di(7 downto 0); 
        when "1101" =>
          mem(conv_integer(to_x01(r.ad)))(15 downto 8) := r.di(15 downto 8); 
        when "1011" =>
          mem(conv_integer(to_x01(r.ad)))(23 downto 16) := r.di(23 downto 16); 
        when "0111" =>
          mem(conv_integer(to_x01(r.ad)))(31 downto 24) := r.di(31 downto 24); 
        when "1100" =>
          mem(conv_integer(to_x01(r.ad)))(15 downto 0) := r.di(15 downto 0); 
        when "0011" =>
          mem(conv_integer(to_x01(r.ad)))(31 downto 16) := r.di(31 downto 16); 
        when others =>
          mem(conv_integer(to_x01(r.ad))) := r.di;
        end case;
      end if;
    end if;
    wait for 1 ns;
  end process;

  core_resp : process
  variable resp_root : response_element_ptr := NULL;
  variable found : boolean;
  begin
    if pci_core.req /= '1' and dbgi.req /= '1' then
      wait until pci_core.req = '1' or dbgi.req = '1'; 
    end if;

    if dbgi.req = '1' then
      if dbgi.insert = '1' then
        insert_resp(0, resp_root, dbgi.resp);
      elsif dbgi.remove = '1' then
        if dbgi.rmall = '1' then
          rm_all_resp(resp_root);
        else
          rm_resp(resp_root, dbgi.addr);
        end if;
      else
        dbgo.valid <= '0';
        get_resp(resp_root, pci_core.addr, dbgo.resp, found);
        if found = true then dbgo.valid <= '1'; end if;
      end if;

      dbgo.ack <= '1';
      wait until dbgi.req = '0';
      dbgo.ack <= '0';
    end if;
    
    if pci_core.req = '1' then
      if pci_core.insert = '1' then
        insert_resp(0, resp_root, pci_core.resp);
      else
        core_pci.valid <= '0';
        get_resp(resp_root, pci_core.addr, core_pci.resp, found);
        if found = true then core_pci.valid <= '1'; end if;
      end if;

      core_pci.ack <= '1';
      wait until pci_core.req = '0';
      core_pci.ack <= '0';
    end if;
  end process;

  --comb : process(pciin, do)
  comb : process
  variable v : reg_type;
  variable vpciin : pci_type;
  
  procedure sync_with_core is
  begin
    pci_core.req <= '1';
    wait until core_pci.ack = '1';
    pci_core.req <= '0';
    wait until core_pci.ack = '0';
  end sync_with_core;
  
  begin
    
    if pciin.syst.rst = '0' then
      v.state := idle;
      v.config := conf;
      v.waitcycles := 1;
      v.latcnt := latency;
      v.ad := (others => '0');
      v.di := (others => '0');
      v.retrycnt := (others => '0');
      v.resp.valid := false;
      v.perren := (others => '0');
      v.sigperr := (others => '0');
    elsif rising_edge(pciin.syst.clk) then
      v := r; v.write := '0';
      vpciin := pciin;
      v.pci.ad.par := xorv(r.pci.ad.ad & vpciin.ad.cbe);
      v.pci.ad.par := v.pci.ad.par xor r.parerr; -- Add par error
      v.paren := r.aden; v.erren := not (r.perren(1) or r.perren(0)); --v.erren := r.paren; 
      v.perren(1) := v.perren(0);
      v.pcirad := vpciin.ad.ad; v.pcircbe := vpciin.ad.cbe;
      v.pci.err.perr := not r.perren(0) or not (xorv(r.pcirad & r.pcircbe & vpciin.ad.par) or r.sigperr(1));-- or '1';  -- ... disable perr
      v.sigperr(1) := r.sigperr(0); v.sigperr(2) := r.sigperr(1); v.sigperr(0) := '0';
      case r.state is
      when idle =>
        v.perren(0) := '0';
        v.firstacc := '1';
        if (r.pci.ifc.trdy and r.pci.ifc.stop and r.pci.ifc.devsel) = '1' then v.pcien := '1'; end if;
        v.aden := '1'; v.waitcycles := 1; v.latcnt := latency; v.first := true;
        v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '1'; v.curword := 0;
        v.pci.ifc.devsel := '1'; --v.pci.err.perr := '1';
        if vpciin.ifc.frame = '0' then
          v.comm := vpciin.ad.cbe;
          if pci_hit(vpciin.ad.ad,vpciin.ad.cbe,vpciin.ifc.idsel(slot),v.config) then
            pci_core.addr <= zero32(31 downto abits) & vpciin.ad.ad(abits-1 downto 0); pci_core.insert <= '0';
            pci_core.resp.retry <= 0; pci_core.resp.ws <= 0; pci_core.resp.diswithout <= 0; pci_core.resp.diswith <= 0;
            sync_with_core;
            if core_pci.valid = '1' and r.resp.valid = false then 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp1: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
              v.resp := core_pci.resp;
              v.resp.valid := true;
              --if resptime > core_pci.resp.ws then v.resp.ws := resptime; end if; -- use resptime if grater, else use access waitstates
              --v.resp.ws := resptime; -- Always use resptime
            elsif r.resp.valid = false then
              v.resp := non_resp;
            end if;
            --if r.retrycnt /= x"00" then                                               -- retry response
            --  if r.retrycnt = x"ff" then v.retrycnt := x"02"; 
            --  else v.retrycnt := v.retrycnt - 1; end if;
            --  v.state := respwait;
            --else
            --  v.retrycnt := x"ff";
              v.ad := zero32(31 downto abits) & vpciin.ad.ad(abits-1 downto 0);
              --if r.waitcycles = resptime then
              if r.waitcycles = resptime and v.resp.retry = 0 then
              --if v.resp.ws = 0 and v.resp.retry = 0 then
                v.pci.ifc.devsel := '0'; v.pcien := '0';
                if vpciin.ad.cbe(0) = '1' then v.state := write; v.pci.ifc.trdy := '0';
            
                --if v.resp.abort = 1 then v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1'; end if;
                --if v.resp.abort = 1 then v.pci.ifc.trdy := '1'; end if;
                if v.resp.abort = 1 then 
                  v.state := tabort;
                  v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '1'; v.pci.ifc.devsel := '0'; 
                end if;
                if v.resp.parerr = 1 then v.sigperr(0) := '1'; end if;

                v.resp_addr := v.ad + "100"; pci_core.addr <= v.resp_addr; pci_core.insert <= '0'; sync_with_core;
                if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
                  if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp2: " & tost(core_pci.resp.addr) & ", " 
                    & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                    & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
                  end if;
                else v.resp := non_resp; end if;

                else v.state := read; v.aden := '0'; end if;
              else v.state := respwait; v.waitcycles := r.waitcycles+1; end if;
              --else v.state := respwait; if v.resp.ws /= 0 then v.resp.ws := v.resp.ws - 1; end if; end if;
            --end if;
          else
            v.state := b_busy;
          end if;
        end if;
      when b_busy =>
        if (vpciin.ifc.frame and vpciin.ifc.irdy) = '1' then
          v.state := idle;
        end if;
      when retry =>                                                                   -- retry response
        v.resp.ws := 0;
        if vpciin.ifc.frame = '1' then
          v.pci.ifc.devsel := '1'; v.pci.ifc.stop := '1'; v.pcien := '1'; 
          v.state := idle;
          if r.resp.retry /= 0 then v.resp.retry := r.resp.retry - 1; end if;
        end if;
      when respwait => -- Initial response time
        --if r.retrycnt /= x"ff" then
        if r.resp.valid = true and r.resp.retry /= 0 then
          v.pci.ifc.devsel := '0'; v.pci.ifc.stop := '0'; v.pcien := '0'; 
          v.state := retry;
        elsif r.waitcycles = resptime then
        --elsif r.resp.ws <= 1 then
          v.pci.ifc.devsel := '0'; v.pcien := '0';
          if r.comm(0) = '1' then v.state := write; v.pci.ifc.trdy := '0';
            
            --if r.resp.diswith = 1 or r.resp.diswithout = 1 then v.pci.ifc.stop := '0'; end if;
            --if r.resp.diswithout = 1 then v.pci.ifc.trdy := '1'; end if;
            if r.resp.parerr = 1 then v.sigperr(0) := '1'; end if;
            v.resp_addr := r.ad + "100"; pci_core.addr <= v.resp_addr; pci_core.insert <= '0'; sync_with_core;
            if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
            else v.resp := non_resp; end if;

          else v.state := read; v.aden := '0'; v.resp.ws := 0; end if;
          
          if r.resp.abort = 1 then 
            v.state := tabort;
            v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '1'; v.pci.ifc.devsel := '0'; 
          end if;
        else v.waitcycles := r.waitcycles+1; end if;
          --v.resp.ws := 0;
        --else v.resp.ws := r.resp.ws - 1; end if;
      when tabort => -- Target abort on first data phase
        v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0';  v.pci.ifc.devsel := '1'; 
        if vpciin.ifc.frame = '1' and vpciin.ifc.irdy = '0' and (r.pci.ifc.trdy and r.pci.ifc.stop) = '0' then
          v.state := idle;
          v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1'; v.pci.ifc.stop := '1';
          v.resp.valid := false;
        end if;
      when write => -- Write access
        v.perren(0) := '1';
        --if vpciin.ifc.irdy = '0' then
        if vpciin.ifc.irdy = '0' and r.pci.ifc.trdy = '0' then
          v.curword := r.curword+1;
          if r.comm = CONF_WRITE then writeconf(r.ad(7 downto 2),vpciin.ad.ad,vpciin.ad.cbe,v.config);
          --else v.di := vpciin.ad.ad; v.write := '1'; end if; -- *** sub-word write
          else v.di := vpciin.ad.ad; v.write := '1'; v.cbe := vpciin.ad.cbe; end if;
            
          if r.resp.ws = 0 then
            v.firstacc := '0';
            if r.resp.diswith = 1 or r.resp.diswithout = 1 then v.pci.ifc.stop := '0'; v.state := dis; end if;
            if r.resp.diswithout = 1 then v.pci.ifc.trdy := '1'; end if;
            if r.resp.abort = 1 then v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1'; end if;
            if r.resp.parerr = 1 then v.sigperr(0) := '1'; end if;
            v.resp_addr := r.resp_addr + "100"; pci_core.addr <= v.resp_addr; pci_core.insert <= '0'; sync_with_core;
            if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
            else v.resp := non_resp; end if;

          end if;
        --elsif r.resp.abort = 1 then  -- Target abort on first data phase
        --  v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1';
        end if;
        if r.write = '1' then v.ad := r.ad + "100"; end if;
        if vpciin.ifc.frame = '1' and vpciin.ifc.irdy = '0' and (r.pci.ifc.trdy and r.pci.ifc.stop) = '0' then
          v.state := idle;
          v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1'; v.pci.ifc.stop := '1';
          v.resp.valid := false;
        --elsif (r.latcnt > 0 and vpciin.ifc.irdy = '0') then v.state := latw; v.pci.ifc.trdy := '1'; v.latcnt := r.latcnt-1;
        elsif (r.resp.ws > 0 and vpciin.ifc.irdy = '0') then v.state := latw; v.pci.ifc.trdy := '1'; v.resp.ws := r.resp.ws-1;
        end if;
      when read => -- Read access
        v.perren(0) := '0';
        v.pci.ifc.trdy := '0';
        if (vpciin.ifc.irdy = '0' or r.first = true) then
          v.ad := r.ad + "100"; v.first := false;
          if r.comm = CONF_READ then readconf(r.ad(7 downto 2),v.pci.ad.ad);
          else v.pci.ad.ad := do; end if;
          if r.resp.parerr = 1 then v.parerr := '1'; else v.parerr := '0'; end if; -- Add par error
            
          if r.resp.ws = 0 then
            v.firstacc := '0';
            if r.firstacc = '0' and (r.resp.diswith = 1 or r.resp.diswithout = 1) then v.pci.ifc.stop := '0'; v.state := dis; end if;
            if r.firstacc = '0' and r.resp.diswithout = 1 then v.pci.ifc.trdy := '1'; end if;
            if r.resp.abort = 1 then v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1'; v.state := dis; end if;
            pci_core.addr <= v.ad; pci_core.insert <= '0'; sync_with_core;
            if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
            else v.resp := non_resp; end if;

          end if;
        end if;

        if (vpciin.ifc.trdy or vpciin.ifc.irdy) = '0' then v.curword := r.curword+1; end if;
        if (vpciin.ifc.frame and not (vpciin.ifc.trdy and vpciin.ifc.stop)) = '1' then
          v.state := idle; v.aden := '1';
          v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1';
          v.resp.valid := false;
        --elsif (r.latcnt > 0 and (vpciin.ifc.trdy or vpciin.ifc.irdy) = '0' and vpciin.ifc.stop = '1') then
        elsif (r.resp.ws > 0 and (vpciin.ifc.trdy or vpciin.ifc.irdy) = '0' and vpciin.ifc.stop = '1') then
          --v.state := latw; v.latcnt := r.latcnt-1; v.pci.ifc.trdy := '1';
          v.state := latw; v.resp.ws := r.resp.ws-1; v.pci.ifc.trdy := '1';
        end if;
      when latw => -- Latency between data phases
        v.pci.ifc.trdy := '1';
        if r.write = '1' then v.ad := r.ad + "100"; end if;
        --if (r.latcnt <= 1 and r.comm(0) = '0') then
        if (r.resp.ws <= 1 and r.comm(0) = '0') then
          --v.latcnt := latency;
          v.resp.ws := 0;
          v.state := read; v.aden := '0'; v.pci.ifc.trdy := '0';
        --elsif r.latcnt = 0 then
            
          if r.resp.diswith = 1 or r.resp.diswithout = 1 then v.pci.ifc.stop := '0'; v.state := dis; end if;
          if r.resp.diswithout = 1 then v.pci.ifc.trdy := '1'; end if;
          if r.resp.abort = 1 then v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1'; end if;
          pci_core.addr <= r.ad; pci_core.insert <= '0'; sync_with_core;
          if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
          else v.resp := non_resp; end if;

        elsif r.resp.ws  = 0 then
          --v.latcnt := latency;
          v.resp.ws := 0;
          v.state := write; v.pci.ifc.trdy := '0';
            
          if r.resp.diswith = 1 or r.resp.diswithout = 1 then v.pci.ifc.stop := '0'; v.state := dis; end if;
          if r.resp.diswithout = 1 then v.pci.ifc.trdy := '1'; end if;
          if r.resp.abort = 1 then v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '0'; v.pci.ifc.devsel := '1'; end if;
          v.resp_addr := r.resp_addr + "100"; pci_core.addr <= v.resp_addr; pci_core.insert <= '0'; sync_with_core;
          if core_pci.valid = '1' then v.resp := core_pci.resp; v.resp.valid := true; 
              if core_pci.resp.debug > 0 then print(tost(NOW/1 ns) & "ns Resp: " & tost(core_pci.resp.addr) & ", " 
                & resp_print(core_pci.resp.retry*1) & ", " & "ws:" & tost(core_pci.resp.ws) & ", " & resp_print(core_pci.resp.diswith*3+core_pci.resp.diswithout*4)  
                & ", " & resp_print(core_pci.resp.abort*5) & ", " & resp_print(core_pci.resp.parerr*6) & ", " & tost(core_pci.resp.valid)); 
              end if;
          else v.resp := non_resp; end if;

        --else v.latcnt := r.latcnt-1; end if;
        else v.resp.ws := r.resp.ws-1; end if;
        if (vpciin.ifc.frame and not r.pci.ifc.stop) = '1' then  -- done if disconnect ??? 
          v.state := idle; 
          v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1';
          v.resp.valid := false;
        end if;
      when dis =>
        v.perren(0) := '0';
        v.pci.ifc.stop := '0';
        if r.write = '1' then v.ad := r.ad + "100"; end if;
        if vpciin.ifc.irdy = '0' then
          v.pci.ifc.trdy := '1';
          if r.pci.ifc.trdy = '0' then
            if r.comm = CONF_WRITE then writeconf(r.ad(7 downto 2),vpciin.ad.ad,vpciin.ad.cbe,v.config);
            elsif r.comm(0) = '1' then v.di := vpciin.ad.ad; v.write := '1'; v.cbe := vpciin.ad.cbe; end if;
          end if;
        end if;
        if vpciin.ifc.frame = '1' then
          v.state := idle; 
          v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1'; v.pci.ifc.stop := '1';
          v.resp.valid := false;
        end if;
      when others =>
      end case;

      -- Disconnect type
      --if ((v.curword+1) >= rbuf) then
      --  if vpciin.ifc.frame = '1' then
      --    v.pci.ifc.stop := '1';
      --  elsif stopwd then
      --    if r.pci.ifc.stop = '1' then
      --      v.pci.ifc.stop := v.pci.ifc.trdy;
      --    else
      --      if vpciin.ifc.irdy = '0' then v.pci.ifc.trdy := '1'; end if;
      --      v.pci.ifc.stop := '0';
      --    end if;
      --  else
      --    v.pci.ifc.stop := '0';
      --    v.pci.ifc.trdy := '1';
      --  end if;
      --end if;
    

    end if;

      r <= v;
    --rin <= v;

    wait on pciin.syst.clk, pciin.syst.rst;

  end process;

  --clockreg : process(vpciin.syst)
  --begin
  --  if rising_edge(vpciin.syst.clk) then
  --    r <= rin;
  --  end if;
  --end process;

  pciout.ad.ad <= r.pci.ad.ad after tval when r.aden = '0' else (others => 'Z') after tval;
  pciout.ad.par <= r.pci.ad.par after tval when (r.paren = '0' and (r.pci.ad.par = '1' or r.pci.ad.par = '0')) else 'Z' after tval;
  pciout.ifc.trdy <= r.pci.ifc.trdy after tval when r.pcien = '0' else 'Z' after tval;
  pciout.ifc.stop <= r.pci.ifc.stop after tval when r.pcien = '0' else 'Z' after tval;
  pciout.ifc.devsel <= r.pci.ifc.devsel after tval when r.pcien = '0' else 'Z' after tval;
  pciout.err.perr <= r.pci.err.perr after tval when r.erren = '0' else 'Z' after tval;
  -- Unused signals
  pciout.ad.cbe <= (others => 'Z');
  pciout.ifc.frame <= 'Z';
  pciout.ifc.irdy <= 'Z';
  pciout.ifc.lock <= 'Z';
  pciout.ifc.idsel <= (others => 'Z');
  pciout.err.serr <= 'Z';
  pciout.arb <= arb_const;
  pciout.syst <= syst_const;
  pciout.ext64 <= ext64_const;
  pciout.cache <= cache_const;
  pciout.int <= (others => 'Z');
end;

-- pragma translate_on

