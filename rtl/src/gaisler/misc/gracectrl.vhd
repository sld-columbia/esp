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
-- Entity:      gracectrl
-- File:        gracectrl.vhd
-- Author:      Jan Andersson - Gaisler Research AB
-- Contact:     support@gaisler.com
-- Description: Provides a GRLIB AMBA AHB slave interface to Xilinx System ACE
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.devices.all;
use work.stdlib.all;
use work.misc.all;

entity gracectrl is
  generic (
    hindex  : integer := 0;               -- AHB slave index
    hirq    : integer := 0;               -- Interrupt line
    haddr   : integer := 16#000#;         -- Base address
    hmask   : integer := 16#fff#;         -- Area mask
    split   : integer range 0 to 1 := 0;  -- Enable AMBA SPLIT support
    swap    : integer range 0 to 1 := 0;
    oepol   : integer range 0 to 1 := 0;  -- Output enable polarity
    mode    : integer range 0 to 2 := 0   -- 0: 16-bit mode only
                                          -- 1: 8-bit mode only
                                          -- 2: 8-bit, emulate 16-bit 
    );
  port (
    rstn    : in  std_ulogic;
    clk     : in  std_ulogic;             -- System (AMBA) clock
    clkace  : in  std_ulogic;             -- System ACE clock
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    acei    : in  gracectrl_in_type;
    aceo    : out gracectrl_out_type
  );  
end gracectrl;

architecture rtl of gracectrl is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant REVISION : amba_version_type := 0;

  constant HCONFIG : ahb_config_type := (
    0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_GRACECTRL, 0, REVISION, hirq),
--    1 => conv_std_logic_vector(swap*4 + mode, 32),
    4 => ahb_iobar(haddr, hmask), others => zero32);

  constant OUTPUT : std_ulogic := conv_std_logic(oepol = 1);
  constant INPUT  : std_ulogic := not conv_std_logic(oepol = 1);

  constant ACEDW : integer := 16-8*(mode mod 2);
  
  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  -- purpose: swaps a hword if 'swap' is non-zero and mode is zero,
  --          otherwise just propagate data
  function condhswap (d : std_logic_vector)
    return std_logic_vector is
    variable dx : std_logic_vector(15 downto 0);
  begin  -- hswap
    dx(ACEDW-1 downto 0) := d;
    if swap /= 0 and mode = 0 then
      return dx(7 downto 0) & dx(15 downto 8);
    end if;
    return dx;
  end condhswap;

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------

  type sys_sync_type is record
     accdone   : std_logic_vector(1 downto 0);
     irq       : std_logic_vector(2 downto 0);
  end record;
  
  type sys_reg_type is record
     acc       : std_ulogic;     -- Perform access
     active    : std_ulogic;     -- Access active
     sync      : sys_sync_type;
     -- AHB
     insplit   : std_ulogic;     -- SPLIT response issued
     unsplit   : std_ulogic;     -- SPLIT complete not issued
     irq       : std_ulogic;     -- Interrupt request
     hwrite    : std_ulogic;
     hsel      : std_ulogic;
     hmbsel    : std_logic_vector(0 to 1);
     haddr     : std_logic_vector(6 downto 0);
     hready    : std_ulogic;
     wdata     : std_logic_vector(ACEDW-1 downto 0);
     hresp     : std_logic_vector(1 downto 0);
     splmst    : std_logic_vector(log2(NAHBMST)-1 downto 0);   -- SPLIT:ed master
     hsplit    : std_logic_vector(NAHBMST-1 downto 0);  -- Other SPLIT:ed masters
     ahbcancel : std_ulogic;     -- Locked access cancels ongoing SPLIT
                                 -- response
  end record;


  type ace_state_type is (idle, en, rd, done);

  type ace_sync_type is record
     acc     : std_logic_vector(1 downto 0);
     rstn    : std_logic_vector(1 downto 0);
     hwrite  : std_logic_vector(1 downto 0);
     dummy   : std_logic_vector(1 downto 0);
  end record;
  
  type ace_reg_type is record
     state     : ace_state_type;
     sync      : ace_sync_type;
     accdone   : std_ulogic;
     rdata     : std_logic_vector(ACEDW-1 downto 0);
     edone     : std_ulogic;
     aceo      : gracectrl_out_type;
  end record;
    
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal r, rin : sys_reg_type;
  signal s, sin : ace_reg_type;
    
begin  -- rtl

  -----------------------------------------------------------------------------
  -- System clock domain
  -----------------------------------------------------------------------------
  combsys: process (r, s, rstn, ahbsi, acei.irq)
    variable v       : sys_reg_type;
    variable irq     : std_logic_vector((NAHBIRQ-1) downto 0);
    variable hsplit  : std_logic_vector(NAHBMST-1 downto 0);
    variable hwdata  : std_logic_vector(31 downto 0);
  begin  -- process comb
    v := r; v.irq := '0'; irq := (others => '0'); irq(hirq) := r.irq;
    v.hresp := HRESP_OKAY; v.hready := '1'; hsplit := (others => '0');
    hwdata := ahbreadword(ahbsi.hwdata, r.haddr(4 downto 2)); 
    
    -- Sync
    v.sync.accdone := r.sync.accdone(0) & s.accdone;
    v.sync.irq     := r.sync.irq(1 downto 0) & acei.irq;
    
    -- AHB communication
    if ahbsi.hready = '1' then
      if (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1' then
        v.hmbsel := ahbsi.hmbsel(r.hmbsel'range);
        if split = 0 or (not (r.active or r.acc) or ahbsi.hmastlock) = '1' then
          v.hready := '0';
          v.hwrite := ahbsi.hwrite;
          v.haddr := ahbsi.haddr(6 downto 0);
          v.hsel := '1';
          if r.insplit = '0' then
            v.acc := '1';
          end if;
          if split /= 0 then
            if ahbsi.hmastlock = '0' then
              v.hresp := HRESP_SPLIT;
              v.splmst := ahbsi.hmaster;
              v.unsplit := '1';
            else
              v.ahbcancel := r.insplit;
            end if;
            v.insplit := not ahbsi.hmastlock;
          end if;
        else
          -- Core is busy, transfer is not locked respond with SPLIT
          v.hready := '0';
          if split /= 0 then
            v.hresp := HRESP_SPLIT;
            v.hsplit(conv_integer(ahbsi.hmaster)) := '1';
          end if;
        end if;
      else
        v.hsel := '0';
      end if;
    end if;

    if (r.hready = '0') then
      if (r.hresp = HRESP_OKAY) then v.hready := '0';
      else v.hresp := r.hresp; end if;
    end if;    

    if r.acc = '1' then
      -- Propagate data
      if r.active = '0' then
        if mode /= 1 then
          if r.haddr(1) = '0' then v.wdata := hwdata(ACEDW+15 downto 16);
          else v.wdata := hwdata(ACEDW-1 downto 0); end if;
        else
          case r.haddr(1 downto 0) is
            when "00" => v.wdata(7 downto 0) := hwdata(31 downto 24);
            when "01" => v.wdata(7 downto 0) := hwdata(23 downto 16);
            when "10" => v.wdata(7 downto 0) := hwdata(15 downto 8);
            when others => v.wdata(7 downto 0) := hwdata(7 downto 0);
          end case;
        end if;
        if mode = 2 then
          -- Override writes to busmode register
          if r.haddr(6 downto 1) = zero32(6 downto 1) then
            v.wdata := (others => '0');  -- Byte
          end if;
        end if;
      end if;
      -- Remove access signal when access is done
      if r.sync.accdone(1) = '1' then
        v.acc := '0';
      end if;
      v.active := '1';
    end if;

    -- AMBA response when access is complete
    if r.acc = '0' and r.sync.accdone(1) = '0' and r.active = '1' then
      if split /= 0 and r.unsplit = '1' then
        hsplit(conv_integer(r.splmst)) := '1';
        v.unsplit := '0';
      end if;
      if ((split = 0 or v.ahbcancel = '0') and
          (split = 0 or ahbsi.hmaster = r.splmst or r.insplit = '0') and
          (((ahbsi.hsel(hindex) and ahbsi.hready and ahbsi.htrans(1)) = '1') or
           ((split = 0 or r.insplit = '0') and r.hready = '0' and r.hresp = HRESP_OKAY))) then
        v.hresp := HRESP_OKAY;
        if split /= 0 then
          v.insplit := '0';
          v.hsplit := r.hsplit;
        end if;
        v.hready := '1';
        v.hsel := '0';
        v.active := '0';
      elsif split /= 0 and v.ahbcancel = '1' then
        v.acc := '1';
        v.ahbcancel := '0';
      end if;
    end if;

    -- Interrupt request, not filtered, pulsed
    if (not r.sync.irq(2) and r.sync.irq(1)) = '1' then
      v.irq := '1';
    end if;
    
    -- Reset
    if rstn = '0' then
      v.acc        := '0';
      v.active     := '0';
      --
      v.insplit    := '0';
      v.unsplit    := '0';
      v.hready     := '1';
      v.hwrite     := '0';
      v.hsel       := '0';
      v.hmbsel     := (others => '0');
      v.ahbcancel  := '0';
    end if;
    if split = 0 then
      v.insplit   := '0';
      v.unsplit   := '0';
      v.splmst    := (others => '0');
      v.hsplit    := (others => '0');
      v.ahbcancel := '0';
    end if;

    -- Update registers
    rin <= v;

    -- AHB slave output
    ahbso.hready  <= r.hready;
    ahbso.hresp   <= r.hresp;
    ahbso.hrdata  <= ahbdrivedata(s.rdata); -- Bad, but does not toggle much
    ahbso.hconfig <= HCONFIG;
    ahbso.hirq    <= irq;
    ahbso.hindex  <= hindex;
    ahbso.hsplit  <= hsplit;
    
  end process combsys;
  
  regsys: process (clk)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process regsys;

  -----------------------------------------------------------------------------
  -- System ACE clock domain
  -----------------------------------------------------------------------------
  combace: process (r, s, rstn, acei)
    variable v       : ace_reg_type;
  begin  -- process comb
    v := s;
    
    -- Synchronize inputs
    v.sync.acc := s.sync.acc(0) & r.acc;
    v.sync.rstn := s.sync.rstn(0) & rstn;
    v.sync.hwrite := s.sync.hwrite(0) & r.hwrite;
    if mode = 2 then
      -- Fake reads from BUSMODE register?
      v.sync.dummy := s.sync.dummy(0) & not orv(r.haddr(6 downto 1));
    else
      v.sync.dummy := (others => '0');
    end if;
    
    case s.state is
      when idle =>
        v.aceo.addr := r.haddr(6 downto 0);
        if mode = 2 then v.aceo.do(7 downto 0) := r.wdata(7 downto 0);
        else v.aceo.do(r.wdata'range) := condhswap(r.wdata); end if;
        if s.sync.acc(1) = '1' then
          v.aceo.cen := '0';
          v.aceo.doen := INPUT xor r.hwrite;
          v.state := en;
        end if;
        if mode = 2 then v.edone := '0'; end if;
        
      when en =>
        v.aceo.wen := not r.hwrite;
        if s.sync.hwrite(1) = '1' then
          v.state := done;
        else
          v.state := rd;
        end if;

      when rd => 
        v.aceo.oen := '0';
        v.state := done;
        
      when done =>
        v.aceo.oen := '1';
        v.aceo.wen := '1';
        if mode = 2 and s.edone = '0' then
          -- Keep 16-bit address map
          v.aceo.addr(0) := '1';
          v.aceo.do(7 downto 0) := r.wdata(ACEDW-1 downto ACEDW-8);
          v.rdata(7 downto 0) := acei.di(7 downto 0);
          v.edone := '1';
          v.state := en;
        else
          v.aceo.cen := '1';
          if s.accdone = '0' then
            if mode = 2 then
              v.rdata(ACEDW-1 downto ACEDW-8) := acei.di(7 downto 0);
              if s.sync.dummy(1) = '1' then -- Fake read
                v.rdata := (others => '0'); v.rdata(0) := '1';
              end if;
            else
              v.rdata := condhswap(acei.di)(s.rdata'range);
            end if;
            v.accdone := '1';
          else
            v.aceo.doen := INPUT;
          end if;
          if s.sync.acc(1) = '0' then
            v.state := idle;
            v.accdone := '0';
          end if;
        end if;
    end case;

    -- Reset
    if s.sync.rstn(1) = '0' then
      v.state     := idle;
      v.accdone   := '0';
      v.aceo.cen  := '1';
      v.aceo.wen  := '1';
      v.aceo.oen  := '1';
      v.aceo.doen := INPUT;
    end if;
    if mode = 1 then v.aceo.do(15 downto 8) := (others => '0'); end if;
    if mode /= 2 then v.edone := '0'; end if;
    
    -- Update registers
    sin <= v;

    -- Assign outputs to System ACE
    aceo <= s.aceo;
    
  end process combace;
    
  regace: process (clkace)
  begin  -- process reg
    if rising_edge(clkace) then
      s <= sin;
    end if;
  end process regace;
  
  -- Boot message
  -- pragma translate_off
  bootmsg : report_version 
    generic map (
      "gracectrl" & tost(hindex) & ": System ACE I/F Controller, rev " &
      tost(REVISION) & ", irq " & tost(hirq));
  -- pragma translate_on

end rtl;


