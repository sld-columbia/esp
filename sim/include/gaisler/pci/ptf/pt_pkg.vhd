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
-------------------------------------------------------------------------------
-- Package:     pt_pkg
-- File:        pt_pkg.vhd
-- Author:      Nils-Johan Wessman, Aeroflex Gaisler
-- Description: PCI Test Framework - Main package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--use work.amba.all;
--use work.testlib.all;
use work.stdlib.all;

package pt_pkg is

  -----------------------------------------------------------------------------
  -- Constants and PCI signal
  -----------------------------------------------------------------------------
  -- Constants for PCI commands
  constant INT_ACK      : std_logic_vector(3 downto 0) := "0000";
  constant SPEC_CYCLE   : std_logic_vector(3 downto 0) := "0001";
  constant IO_READ      : std_logic_vector(3 downto 0) := "0010";
  constant IO_WRITE     : std_logic_vector(3 downto 0) := "0011";
  constant MEM_READ     : std_logic_vector(3 downto 0) := "0110";
  constant MEM_WRITE    : std_logic_vector(3 downto 0) := "0111";
  constant CONF_READ    : std_logic_vector(3 downto 0) := "1010";
  constant CONF_WRITE   : std_logic_vector(3 downto 0) := "1011";
  constant MEM_R_MULT   : std_logic_vector(3 downto 0) := "1100";
  constant DAC          : std_logic_vector(3 downto 0) := "1101";
  constant MEM_R_LINE   : std_logic_vector(3 downto 0) := "1110";
  constant MEM_W_INV    : std_logic_vector(3 downto 0) := "1111";

type bar_type is array(0 to 5) of std_logic_vector(31 downto 0);
constant bar_init : bar_type := ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
type config_header_type is record
  devid       : std_logic_vector(15 downto 0);
  vendid      : std_logic_vector(15 downto 0);
  status      : std_logic_vector(15 downto 0);
  command     : std_logic_vector(15 downto 0);
  class_code  : std_logic_vector(23 downto 0);
  revid       : std_logic_vector(7 downto 0);
  bist        : std_logic_vector(7 downto 0);
  header_type : std_logic_vector(7 downto 0);
  lat_timer   : std_logic_vector(7 downto 0);
  cache_lsize : std_logic_vector(7 downto 0);
  bar         : bar_type;
  cis_p       : std_logic_vector(31 downto 0);
  subid       : std_logic_vector(15 downto 0);
  subvendid   : std_logic_vector(15 downto 0);
  exp_rom_ba  : std_logic_vector(31 downto 0);
  max_lat     : std_logic_vector(7 downto 0);
  min_gnt     : std_logic_vector(7 downto 0);
  int_pin     : std_logic_vector(7 downto 0);
  int_line    : std_logic_vector(7 downto 0);
end record;

constant config_init : config_header_type := (
          devid => conv_std_logic_vector(16#0BAD#,16),
          vendid => conv_std_logic_vector(16#AFFE#,16),
          status => (others => '0'),
          command => (others => '0'),
          class_code => conv_std_logic_vector(16#050000#,24),
          revid => conv_std_logic_vector(16#01#,8),
          bist => (others => '0'),
          header_type => (others => '0'),
          lat_timer => (others => '0'),
          cache_lsize => (others => '0'),
          bar => bar_init,
          cis_p => (others => '0'),
          subid => (others => '0'),
          subvendid => (others => '0'),
          exp_rom_ba => (others => '0'),
          max_lat => (others => '0'),
          min_gnt => (others => '0'),
          int_pin => (others => '0'),
          int_line => (others => '0'));


-- These types defines the TB PCI bus
type pci_ad_type is record
  ad      : std_logic_vector(31 downto 0);
  cbe     : std_logic_vector(3 downto 0);
  par     : std_logic;
end record;
constant ad_const : pci_ad_type := (
          ad => (others => 'Z'),
          cbe => (others => 'Z'),
          par => 'Z');

type pci_ifc_type is record
  frame   : std_logic;
  irdy    : std_logic;
  trdy    : std_logic;
  stop    : std_logic;
  devsel  : std_logic;
  idsel   : std_logic_vector(20 downto 0);
  lock    : std_logic;
end record;
constant ifc_const : pci_ifc_type := (
          frame => 'H',
          irdy => 'H',
          trdy => 'H',
          stop => 'H',
          lock => 'H',
          idsel => (others => 'L'),
          devsel => 'H');

type pci_err_type is record
  perr    : std_logic;
  serr    : std_logic;
end record;
constant err_const : pci_err_type := (
          perr => 'H',
          serr => 'H');

type pci_arb_type is record
  req     : std_logic_vector(20 downto 0);
  gnt     : std_logic_vector(20 downto 0);
end record;
constant arb_const : pci_arb_type := (
          req => (others => 'H'),
          gnt => (others => 'H'));

type pci_syst_type is record
  clk     : std_logic;
  rst     : std_logic;
end record;
constant syst_const : pci_syst_type := (
          clk => 'H',
          rst => 'H');

type pci_ext64_type is record
  ad      : std_logic_vector(63 downto 32);
  cbe     : std_logic_vector(7 downto 4);
  par64   : std_logic;
  req64   : std_logic;
  ack64   : std_logic;
end record;
constant ext64_const : pci_ext64_type := (
          ad => (others => 'Z'),
          cbe => (others => 'Z'),
          par64 => 'Z',
          req64 => 'Z',
          ack64 => 'Z');

--type pci_int_type is record
--  inta    : std_logic;
--  intb    : std_logic;
--  intc    : std_logic;
--  intd    : std_logic;
--end record;
--constant int_const : pci_int_type := (
--          inta => 'H',
--          intb => 'H',
--          intc => 'H',
--          intd => 'H');
constant int_const : std_logic_vector(3 downto 0) := "HHHH";

type pci_cache_type is record
  sbo     : std_logic;
  sdone   : std_logic;
end record;

constant cache_const : pci_cache_type := (
          sbo => 'U',
          sdone => 'U');

type pci_type is record
  ad      : pci_ad_type;
  ifc     : pci_ifc_type;
  err     : pci_err_type;
  arb     : pci_arb_type;
  syst    : pci_syst_type;
  ext64   : pci_ext64_type;
  --int     : pci_int_type;
  int     : std_logic_vector(3 downto 0);
  cache   : pci_cache_type;
end record;

constant pci_idle : pci_type := ( ad_const, ifc_const, err_const, arb_const,
  syst_const, ext64_const, int_const, cache_const);
  
  -----------------------------------------------------------------------------
  -- Types for PCI master
  -----------------------------------------------------------------------------
  
  type pt_pci_access_type is record
    addr        : std_logic_vector(31 downto 0);
    cbe_cmd     : std_logic_vector(3 downto 0);
    data        : std_logic_vector(31 downto 0);
    cbe_data    : std_logic_vector(3 downto 0);
    ws          : integer;
    status      : integer range 0 to 3;
    id          : integer;
    debug       : integer range 0 to 3;
    last        : boolean;
    idle        : boolean;
    list_res    : boolean;
    valid       : boolean;
    parerr      : integer range 0 to 2;
    cod         : integer range 0 to 2; -- Cancel on disconnect
  end record;
  type pt_pci_master_in_type is record
    req     : std_logic;
    add     : boolean;
    remove  : boolean;
    rmall   : boolean;
    get_res : boolean;
    add_res : boolean;
    acc     : pt_pci_access_type;
  end record;
  type pt_pci_master_out_type is record
    ack       : std_logic;
    res_found : std_logic;
    acc       : pt_pci_access_type;
    valid     : boolean;
  end record;

  -----------------------------------------------------------------------------
  -- PCI master procedures
  -----------------------------------------------------------------------------

  procedure pt_pci_master_sync_with_core(
    signal dbgi  : out pt_pci_master_in_type;
    signal dbgo  : in pt_pci_master_out_type);

  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false);
  
  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false);
  
  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  cod       : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false);
  
  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type);
  
  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type);
  
  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  cod       : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type);
  
  procedure pt_add_idle_nb(
    constant  waits     : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false);
  
  procedure pt_add_idle(
    constant  waits     : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type);

  -----------------------------------------------------------------------------
  -- Types for PCI target
  -----------------------------------------------------------------------------

  type pt_pci_response_type is record
    addr        : std_logic_vector(31 downto 0);
    retry       : integer;
    ws          : integer;
    diswithout  : integer;
    diswith     : integer;
    abort       : integer;
    parerr      : integer;
    debug       : integer;
    valid       : boolean;
  end record;
  type pt_pci_target_in_type is record
    req   : std_logic;
    insert: std_logic;
    remove: std_logic;
    rmall : std_logic;
    addr  : std_logic_vector(31 downto 0);
    resp  : pt_pci_response_type;
  end record;
  type pt_pci_target_out_type is record
    ack   : std_logic;
    resp  : pt_pci_response_type;
    valid : std_logic;
  end record;
  
  -----------------------------------------------------------------------------
  -- PCI target procedures
  -----------------------------------------------------------------------------

  procedure pt_pci_target_sync_with_core(
    signal dbgi  : out pt_pci_target_in_type;
    signal dbgo  : in pt_pci_target_out_type);
  
  procedure pt_insert_resp(
    constant  addr  : std_logic_vector(31 downto 0);
    constant  retry : integer;
    constant  waits : integer;
    constant  discon: integer;
    constant  parerr: integer;
    constant  abort : integer;
    constant  debug : integer;
    signal    dbgi  : out pt_pci_target_in_type;
    signal    dbgo  : in pt_pci_target_out_type);
  
  procedure pt_remove_resp(
    constant  addr  : std_logic_vector(31 downto 0);
    constant  rmall : boolean;
    signal    dbgi  : out pt_pci_target_in_type;
    signal    dbgo  : in pt_pci_target_out_type);
  

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

  component pt_pci_master -- A PCI master that is accessed through a Testbench vector
    generic (
      slot : integer := 0; -- Slot number for this unit
      tval : time := 7 ns); -- Output delay for signals that are driven by this unit
    port (
      pciin     : in pci_type;
      pciout    : out pci_type;
      dbgi      : in  pt_pci_master_in_type;
      dbgo      : out pt_pci_master_out_type
      );
  end component;
  
  component pt_pci_target -- Represents a simple memory on the PCI bus
    generic (
      slot : integer := 0; -- Slot number for this unit
      abits : integer := 10; -- Memory size. Size is 2^abits 32-bit words
      bars : integer := 1; -- Number of bars for this target. Min 1, Max 6
      resptime : integer := 2; -- The initial response time in clks for this target
      latency : integer := 0; -- The latency in clks for every dataphase for a burst access
      rbuf : integer := 8; -- The maximum no of words this target can transfer in a continuous burst
      stopwd : boolean := true; -- Target disconnect type. true = disconnect WITH data, false = disconnect WITHOUT data
      tval : time := 7 ns; -- Output delay for signals that are driven by this unit
      conf : config_header_type := config_init; -- The reset condition of the configuration space of this target
      dbglevel : integer := 1); -- Debug level. Higher value means more debug information
    port (
      pciin     : in pci_type;
      pciout    : out pci_type;
      dbgi      : in  pt_pci_target_in_type;
      dbgo      : out  pt_pci_target_out_type
      );
  end component;
  
  component pt_pci_arb
    generic (
      slots : integer := 5; -- The number of slots in the test system
      tval : time := 7 ns); -- Output delay for signals that are driven by this unit
    port (
      systclk : in pci_syst_type;
      ifcin : in pci_ifc_type;
      arbin : in pci_arb_type;
      arbout : out pci_arb_type);
  end component;
  
  --component pt_pci_monitor is
  --  generic (dbglevel : integer := 1);  -- Debug level. Higher value means more debug information
  --  port (pciin     : in pci_type);
  --end component;

end package pt_pkg;


package body pt_pkg is
  -----------------------------------------------------------------------------
  -- PCI master procedures
  -----------------------------------------------------------------------------

  procedure pt_pci_master_sync_with_core(
    signal dbgi  : out pt_pci_master_in_type;
    signal dbgo  : in pt_pci_master_out_type) is
  begin
    dbgi.req <= '1';
    wait until dbgo.ack = '1';
    dbgi.req <= '0';
    wait until dbgo.ack = '0';
  end procedure pt_pci_master_sync_with_core;

  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false) is
  begin
    dbgi.add <= true;
    dbgi.remove <= false;
    dbgi.get_res <= false;
    dbgi.add_res <= false;
    dbgi.acc.id <= id; 
    dbgi.acc.addr <= addr; 
    dbgi.acc.cbe_cmd <= cbe_cmd; 
    dbgi.acc.data <= data; 
    dbgi.acc.cbe_data <= cbe_data; 
    dbgi.acc.ws <= waits; 
    dbgi.acc.last <= last; 
    dbgi.acc.idle <= false; 
    dbgi.acc.list_res <= list_res; 
    dbgi.acc.valid <= true; 
    dbgi.acc.debug <= debug; 
    dbgi.acc.cod <= 0;
    pt_pci_master_sync_with_core(dbgi, dbgo);
    dbgi.add <= false;
    dbgi.acc.valid <= false; 
  end procedure;
  
  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false) is
  begin
    dbgi.add <= true;
    dbgi.remove <= false;
    dbgi.get_res <= false;
    dbgi.add_res <= false;
    dbgi.acc.id <= id; 
    dbgi.acc.addr <= addr; 
    dbgi.acc.cbe_cmd <= cbe_cmd; 
    dbgi.acc.data <= data; 
    dbgi.acc.cbe_data <= cbe_data; 
    dbgi.acc.ws <= waits; 
    dbgi.acc.last <= last; 
    dbgi.acc.parerr <= parerr; 
    dbgi.acc.idle <= false; 
    dbgi.acc.list_res <= list_res; 
    dbgi.acc.valid <= true; 
    dbgi.acc.debug <= debug; 
    dbgi.acc.cod <= 0;
    pt_pci_master_sync_with_core(dbgi, dbgo);
    dbgi.add <= false;
    dbgi.acc.valid <= false; 
  end procedure;
  
  procedure pt_add_acc_nb(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  cod       : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false) is
  begin
    dbgi.add <= true;
    dbgi.remove <= false;
    dbgi.get_res <= false;
    dbgi.add_res <= false;
    dbgi.acc.id <= id; 
    dbgi.acc.addr <= addr; 
    dbgi.acc.cbe_cmd <= cbe_cmd; 
    dbgi.acc.data <= data; 
    dbgi.acc.cbe_data <= cbe_data; 
    dbgi.acc.ws <= waits; 
    dbgi.acc.last <= last; 
    dbgi.acc.parerr <= parerr; 
    dbgi.acc.idle <= false; 
    dbgi.acc.list_res <= list_res; 
    dbgi.acc.valid <= true; 
    dbgi.acc.debug <= debug; 
    dbgi.acc.cod <= cod;
    pt_pci_master_sync_with_core(dbgi, dbgo);
    dbgi.add <= false;
    dbgi.acc.valid <= false; 
  end procedure;
  
  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type) is
  begin
    pt_add_acc_nb(addr, cbe_cmd , data, cbe_data, waits, last, parerr, id, debug, dbgi, dbgo, true);
    
    while true loop
      dbgi.get_res <= true;
      dbgi.add <= false;
      dbgi.remove <= false;
      dbgi.add_res <= false;
      dbgi.acc.id <= id; 
      dbgi.acc.addr <= (others => '0'); 
      dbgi.acc.cbe_cmd <= (others => '0'); 
      dbgi.acc.data <= (others => '0'); 
      dbgi.acc.cbe_data <= (others => '0'); 
      dbgi.acc.ws <= 0; 
      dbgi.acc.idle <= false; 
      dbgi.acc.list_res <= false; 
      dbgi.acc.valid <= true; 
      dbgi.acc.debug <= debug; 
      dbgi.acc.cod <= 0;
      pt_pci_master_sync_with_core(dbgi, dbgo);
      dbgi.add <= false;
      dbgi.get_res <= false;
      dbgi.acc.valid <= false;
      if dbgo.valid = false then
        while dbgo.res_found /= '1' loop
          wait until dbgo.res_found = '1';
        end loop;
      else
        exit;
      end if;
    end loop;
  end procedure;

  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  parerr    : integer;
    constant  cod       : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type) is
  begin
    pt_add_acc_nb(addr, cbe_cmd , data, cbe_data, waits, last, parerr, cod, id, debug, dbgi, dbgo, true);
    
    while true loop
      dbgi.get_res <= true;
      dbgi.add <= false;
      dbgi.remove <= false;
      dbgi.add_res <= false;
      dbgi.acc.id <= id; 
      dbgi.acc.addr <= (others => '0'); 
      dbgi.acc.cbe_cmd <= (others => '0'); 
      dbgi.acc.data <= (others => '0'); 
      dbgi.acc.cbe_data <= (others => '0'); 
      dbgi.acc.ws <= 0; 
      dbgi.acc.idle <= false; 
      dbgi.acc.list_res <= false; 
      dbgi.acc.valid <= true; 
      dbgi.acc.debug <= debug; 
      dbgi.acc.cod <= 0;
      pt_pci_master_sync_with_core(dbgi, dbgo);
      dbgi.add <= false;
      dbgi.get_res <= false;
      dbgi.acc.valid <= false;
      if dbgo.valid = false then
        while dbgo.res_found /= '1' loop
          wait until dbgo.res_found = '1';
        end loop;
      else
        exit;
      end if;
    end loop;
  end procedure;

  procedure pt_add_acc(
    constant  addr      : std_logic_vector(31 downto 0);
    constant  cbe_cmd   : std_logic_vector(3 downto 0);
    constant  data      : std_logic_vector(31 downto 0);
    constant  cbe_data  : std_logic_vector(3 downto 0);
    constant  waits     : integer;
    constant  last      : boolean;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type) is
  begin
    pt_add_acc_nb(addr, cbe_cmd , data, cbe_data, waits, last, id, debug, dbgi, dbgo, true);
    
    while true loop
      dbgi.get_res <= true;
      dbgi.add <= false;
      dbgi.remove <= false;
      dbgi.add_res <= false;
      dbgi.acc.id <= id; 
      dbgi.acc.addr <= (others => '0'); 
      dbgi.acc.cbe_cmd <= (others => '0'); 
      dbgi.acc.data <= (others => '0'); 
      dbgi.acc.cbe_data <= (others => '0'); 
      dbgi.acc.ws <= 0; 
      dbgi.acc.idle <= false; 
      dbgi.acc.list_res <= false; 
      dbgi.acc.valid <= true; 
      dbgi.acc.debug <= debug; 
      dbgi.acc.cod <= 0;
      pt_pci_master_sync_with_core(dbgi, dbgo);
      dbgi.add <= false;
      dbgi.get_res <= false;
      dbgi.acc.valid <= false;
      if dbgo.valid = false then
        while dbgo.res_found /= '1' loop
          wait until dbgo.res_found = '1';
        end loop;
      else
        exit;
      end if;
    end loop;
  end procedure;
  
  procedure pt_add_idle_nb(
    constant  waits     : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type;
    constant  list_res  : boolean := false) is
  begin
    dbgi.add <= true;
    dbgi.remove <= false;
    dbgi.get_res <= false;
    dbgi.add_res <= false;
    dbgi.acc.id <= id; 
    dbgi.acc.addr <= (others => '0'); 
    dbgi.acc.cbe_cmd <= (others => '0'); 
    dbgi.acc.data <= (others => '0'); 
    dbgi.acc.cbe_data <= (others => '0'); 
    dbgi.acc.ws <= waits; 
    dbgi.acc.idle <= true; 
    dbgi.acc.list_res <= list_res; 
    dbgi.acc.valid <= true; 
    dbgi.acc.debug <= debug; 
    dbgi.acc.cod <= 0;
    pt_pci_master_sync_with_core(dbgi, dbgo);
    dbgi.add <= false;
    dbgi.acc.valid <= false; 
  end procedure;
  
  procedure pt_add_idle(
    constant  waits     : integer;
    constant  id        : integer;
    constant  debug     : integer;
    signal    dbgi      : out pt_pci_master_in_type;
    signal    dbgo      : in pt_pci_master_out_type) is
  begin
    
    -- Add acc
    pt_add_idle_nb(waits, id, debug, dbgi, dbgo, true);
    
    while true loop
      dbgi.get_res <= true;
      dbgi.add <= false;
      dbgi.remove <= false;
      dbgi.add_res <= false;
      dbgi.acc.id <= id; 
      dbgi.acc.addr <= (others => '0'); 
      dbgi.acc.cbe_cmd <= (others => '0'); 
      dbgi.acc.data <= (others => '0'); 
      dbgi.acc.cbe_data <= (others => '0'); 
      dbgi.acc.ws <= 0; 
      dbgi.acc.idle <= false; 
      dbgi.acc.list_res <= false; 
      dbgi.acc.valid <= true; 
      dbgi.acc.debug <= debug; 
      dbgi.acc.cod <= 0;
      pt_pci_master_sync_with_core(dbgi, dbgo);
      dbgi.add <= false;
      dbgi.get_res <= false;
      dbgi.acc.valid <= false;
      if dbgo.valid = false then
        while dbgo.res_found /= '1' loop
          wait until dbgo.res_found = '1';
        end loop;
      else
        exit;
      end if;
    end loop;
  end procedure;

  -----------------------------------------------------------------------------
  -- PCI target procedures
  -----------------------------------------------------------------------------

  procedure pt_pci_target_sync_with_core(
    signal dbgi  : out pt_pci_target_in_type;
    signal dbgo  : in pt_pci_target_out_type) is
  begin
    dbgi.req <= '1';
    wait until dbgo.ack = '1';
    dbgi.req <= '0';
    wait until dbgo.ack = '0';
  end procedure pt_pci_target_sync_with_core;
  
  procedure pt_insert_resp(
    constant  addr  : std_logic_vector(31 downto 0);
    constant  retry : integer;
    constant  waits : integer;
    constant  discon: integer;
    constant  parerr: integer;
    constant  abort : integer;
    constant  debug : integer;
    signal    dbgi  : out pt_pci_target_in_type;
    signal    dbgo  : in pt_pci_target_out_type) is
  begin
    dbgi.insert <= '1';
    dbgi.remove <= '0';
    dbgi.resp.addr <= addr; 
    dbgi.resp.retry <= retry; 
    dbgi.resp.ws <= waits; 
    dbgi.resp.parerr <= parerr; 
    dbgi.resp.abort <= abort; 
    dbgi.resp.debug <= debug; 
    if discon = 1 then
      dbgi.resp.diswith <= 1; 
    elsif discon = 2 then
      dbgi.resp.diswithout <= 1; 
    else
      dbgi.resp.diswith <= 0; 
      dbgi.resp.diswithout <= 0; 
    end if;
    pt_pci_target_sync_with_core(dbgi, dbgo);
    dbgi.insert <= '0';
  end procedure;
  
  procedure pt_remove_resp(
    constant  addr  : std_logic_vector(31 downto 0);
    constant  rmall : boolean;
    signal    dbgi  : out pt_pci_target_in_type;
    signal    dbgo  : in pt_pci_target_out_type) is
  begin
    dbgi.insert <= '0';
    dbgi.remove <= '1';
    if rmall = true then dbgi.rmall  <= '1'; 
    else dbgi.rmall <= '0'; end if;
    dbgi.addr <= addr;
    pt_pci_target_sync_with_core(dbgi, dbgo);
    dbgi.remove <= '0';
    dbgi.rmall  <= '0';
  end procedure;

end pt_pkg;

