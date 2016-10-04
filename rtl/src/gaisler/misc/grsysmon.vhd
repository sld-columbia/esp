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
-- Entity:      grsysmon
-- File:        grsysmon.vhd
-- Author:      Jan Andersson - Gaisler Research AB
-- Description: Provides GRLIB AMBA AHB slave interface to Xilinx SYSMON

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.devices.all;
use work.stdlib.all;
use work.misc.all;

use work.gencomp.all;

entity grsysmon is
  generic (
    -- GRLIB generics
    tech      : integer := DEFFABTECH;
    hindex    : integer := 0;             -- AHB slave index
    hirq      : integer := 0;             -- Interrupt line
    caddr     : integer := 16#000#;       -- Base address for configuration area
    cmask     : integer := 16#fff#;       -- Area mask
    saddr     : integer := 16#001#;       -- Base address for sysmon register area
    smask     : integer := 16#fff#;       -- Area mask
    split     : integer := 0;             -- Enable AMBA SPLIT support
    extconvst : integer := 0;             -- Use external CONVST signal
    wrdalign  : integer := 0;             -- Word align System Monitor registers
    -- Virtex 5 SYSMON generics
    INIT_40 : bit_vector := X"0000";
    INIT_41 : bit_vector := X"0000";
    INIT_42 : bit_vector := X"0800";
    INIT_43 : bit_vector := X"0000";
    INIT_44 : bit_vector := X"0000";
    INIT_45 : bit_vector := X"0000";
    INIT_46 : bit_vector := X"0000";
    INIT_47 : bit_vector := X"0000";
    INIT_48 : bit_vector := X"0000";
    INIT_49 : bit_vector := X"0000";
    INIT_4A : bit_vector := X"0000";
    INIT_4B : bit_vector := X"0000";
    INIT_4C : bit_vector := X"0000";
    INIT_4D : bit_vector := X"0000";
    INIT_4E : bit_vector := X"0000";
    INIT_4F : bit_vector := X"0000";
    INIT_50 : bit_vector := X"0000";
    INIT_51 : bit_vector := X"0000";
    INIT_52 : bit_vector := X"0000";
    INIT_53 : bit_vector := X"0000";
    INIT_54 : bit_vector := X"0000";
    INIT_55 : bit_vector := X"0000";
    INIT_56 : bit_vector := X"0000";
    INIT_57 : bit_vector := X"0000";
    SIM_MONITOR_FILE : string := "sysmon.txt");
  port (
    rstn    : in  std_ulogic;
    clk     : in  std_ulogic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    sysmoni : in  grsysmon_in_type;
    sysmono : out grsysmon_out_type
  );  
end grsysmon;

architecture rtl of grsysmon is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant REVISION : amba_version_type := 0;

  constant HCONFIG : ahb_config_type := (
    0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_GRSYSMON, 0, REVISION, hirq),
    4 => ahb_iobar(caddr, cmask), 5 => ahb_iobar(saddr, smask),
    others => zero32);

  -- BANKs
  constant CONF_BANK   : integer := 0;
  constant SYSMON_BANK : integer := 1;

  -- Registers
  constant CONF_REG_OFF : std_ulogic := '0';
  constant STAT_REG_OFF : std_ulogic := '1';
  
  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type sysmon_out_type is record
     alm          : std_logic_vector(2 downto 0);
     busy         : std_ulogic;
     channel      : std_logic_vector(4 downto 0);
     do           : std_logic_vector(15 downto 0);
     drdy         : std_ulogic;
     eoc          : std_ulogic;
     eos          : std_ulogic;
     jtagbusy     : std_ulogic;
     jtaglocked   : std_ulogic;
     jtagmodified : std_ulogic;
     ot           : std_ulogic;                      
  end record;

  type sysmon_in_type is record
     daddr    : std_logic_vector(6 downto 0);
     den      : std_ulogic; 
     di       : std_logic_vector(15 downto 0);
     dwe      : std_ulogic;
  end record;

  type grsysmon_conf_reg_type is record
     ot_ien   : std_ulogic;
     alm_ien  : std_logic_vector(2 downto 0);
     convst   : std_ulogic;
     eos_ien  : std_ulogic;
     eoc_ien  : std_ulogic;
     busy_ien : std_ulogic;
     jb_ien   : std_ulogic;
     jl_ien   : std_ulogic;
     jm_ien   : std_ulogic;
  end record;
  
  type grsysmon_reg_type is record
     cfgreg : grsysmon_conf_reg_type;
     -- SYSMON
     den       : std_ulogic;     -- System monitor data enable
     sma       : std_ulogic;     -- System monitor access
     smr       : std_ulogic;     -- System monitor access ready
     -- AHB
     insplit   : std_ulogic;     -- SPLIT response issued
     unsplit   : std_ulogic;     -- SPLIT complete not issued
     irq       : std_ulogic;     -- Interrupt request
     hwrite    : std_ulogic;
     hsel      : std_ulogic;
     hmbsel    : std_logic_vector(0 to 1);
     haddr     : std_logic_vector(6 downto 0);
     hready    : std_ulogic;
     srdata    : std_logic_vector(15 downto 0);  -- SYSMON response data
     rrdata    : std_logic_vector(12 downto 0);  -- Register response data
     hresp     : std_logic_vector(1 downto 0);
     splmst    : std_logic_vector(log2(NAHBMST)-1 downto 0);   -- SPLIT:ed master
     hsplit    : std_logic_vector(NAHBMST-1 downto 0);  -- Other SPLIT:ed masters
     ahbcancel : std_ulogic;     -- Locked access cancels ongoing SPLIT
                                 -- response
  end record;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal r, rin : grsysmon_reg_type;
  signal syso : sysmon_out_type;
  signal sysi : sysmon_in_type;
  signal sysmon_rst : std_ulogic;
  signal lconvst : std_ulogic;
  
begin  -- rtl

  sysmon_rst <= not rstn;

  convstint: if extconvst = 0 generate
    lconvst <= r.cfgreg.convst;
  end generate convstint;
  convstext: if extconvst /= 0 generate
    lconvst <= sysmoni.convst;
  end generate convstext;
  
  -----------------------------------------------------------------------------
  -- System monitor
  -----------------------------------------------------------------------------
  macro0 : system_monitor
    generic map (tech => tech,
                 INIT_40 => INIT_40, INIT_41 => INIT_41, INIT_42 => INIT_42,
                 INIT_43 => INIT_43, INIT_44 => INIT_44, INIT_45 => INIT_45,
                 INIT_46 => INIT_46, INIT_47 => INIT_47, INIT_48 => INIT_48,
                 INIT_49 => INIT_49, INIT_4A => INIT_4A, INIT_4B => INIT_4B,
                 INIT_4C => INIT_4C, INIT_4D => INIT_4D, INIT_4E => INIT_4E,
                 INIT_4F => INIT_4F, INIT_50 => INIT_50, INIT_51 => INIT_51,
                 INIT_52 => INIT_52, INIT_53 => INIT_53, INIT_54 => INIT_54,
                 INIT_55 => INIT_55, INIT_56 => INIT_56, INIT_57 => INIT_57,
                 SIM_MONITOR_FILE => SIM_MONITOR_FILE)
    port map (alm => syso.alm, busy => syso.busy, channel => syso.channel,
              do => syso.do, drdy => syso.drdy, eoc => syso.eoc,
              eos => syso.eos, jtagbusy => syso.jtagbusy,
              jtaglocked => syso.jtaglocked, jtagmodified => syso.jtagmodified,
              ot => syso.ot, convst => lconvst, convstclk => sysmoni.convstclk,
              daddr => sysi.daddr, dclk => clk, den => sysi.den,
              di => sysi.di, dwe => sysi.dwe, reset => sysmon_rst,
              vauxn => sysmoni.vauxn, vauxp => sysmoni.vauxp,
              vn => sysmoni.vn, vp => sysmoni.vp);

  -----------------------------------------------------------------------------
  -- AMBA and control i/f
  -----------------------------------------------------------------------------
  comb: process (r, rstn, ahbsi, syso)
    variable v       : grsysmon_reg_type;
    variable irq     : std_logic_vector((NAHBIRQ-1) downto 0);
    variable addr    : std_logic_vector(7 downto 0);
    variable hsplit  : std_logic_vector(NAHBMST-1 downto 0);
    variable regaddr : std_ulogic;
    variable hrdata  : std_logic_vector(31 downto 0);
    variable hwdata  : std_logic_vector(31 downto 0);
  begin  -- process comb
    v := r; v.irq := '0'; irq := (others => '0'); irq(hirq) := r.irq;
    v.hresp := HRESP_OKAY; v.hready := '1'; v.den := '0';
    regaddr := r.haddr(1-wrdalign); hsplit := (others => '0');
    v.cfgreg.convst := '0';
    hwdata := ahbreadword(ahbsi.hwdata, r.haddr(4 downto 2));
    
    -- AHB communication
    if ahbsi.hready = '1' then
      if (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1' then
        v.hmbsel := ahbsi.hmbsel(r.hmbsel'range);
        if split = 0 or (not r.sma or ahbsi.hmbsel(CONF_BANK) or
                           ahbsi.hmastlock) = '1' then
          v.hready := ahbsi.hmbsel(CONF_BANK) and ahbsi.hwrite;            
          v.hwrite := ahbsi.hwrite;
          v.haddr := ahbsi.haddr((7+wrdalign) downto (1+wrdalign));
          v.hsel := '1';
          if ahbsi.hmbsel(SYSMON_BANK) = '1' then
            v.den := not r.insplit; v.sma := '1';
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
          end if;
        else
          -- Core is busy, transfer is not locked and access was to sysmon
          -- registers. Respond with SPLIT or insert wait states
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
    
    -- Read access to conf registers
    if (r.hsel and r.hmbsel(CONF_BANK)) = '1' then
      v.rrdata := (others => '0');
      if r.hwrite = '0' then
        v.hready := '1';
        v.hsel := '0';
      end if;
      case regaddr is
        when CONF_REG_OFF =>
          v.rrdata(12) := r.cfgreg.ot_ien;
          v.rrdata(11 downto 9) := r.cfgreg.alm_ien;
          if extconvst = 0 then
            v.rrdata(6) := r.cfgreg.convst;
          end if;
          v.rrdata(5) := r.cfgreg.eos_ien;
          v.rrdata(4) := r.cfgreg.eoc_ien;
          v.rrdata(3) := r.cfgreg.busy_ien;
          v.rrdata(2) := r.cfgreg.jb_ien;
          v.rrdata(1) := r.cfgreg.jl_ien;
          v.rrdata(0) := r.cfgreg.jm_ien;
          if r.hwrite = '1' then
            v.cfgreg.ot_ien  := hwdata(12);
            v.cfgreg.alm_ien := hwdata(11 downto 9);
            if extconvst = 0 then
              v.cfgreg.convst  := hwdata(6);
            end if;
            v.cfgreg.eos_ien := hwdata(5);
            v.cfgreg.eoc_ien := hwdata(4);
            v.cfgreg.busy_ien := hwdata(3);
            v.cfgreg.jb_ien := hwdata(2);
            v.cfgreg.jl_ien := hwdata(1);
            v.cfgreg.jm_ien := hwdata(0);
          end if;
        when STAT_REG_OFF =>
          v.rrdata(12) := syso.ot;
          v.rrdata(11 downto 9) := syso.alm;
          v.rrdata(8 downto 4) := syso.channel;  
          v.rrdata(3) := syso.busy;
          v.rrdata(2) := syso.jtagbusy;
          v.rrdata(1) := syso.jtaglocked;
          v.rrdata(0) := syso.jtagmodified;
        when others => null;
      end case;
    end if;

    -- SYSMON access finished
    if syso.drdy = '1' then
      v.srdata := syso.do;
      v.smr := '1';
    end if;
    if (syso.drdy or r.smr) = '1' then
      if split /= 0 and r.unsplit = '1' then
        hsplit(conv_integer(r.splmst)) := '1';
        v.unsplit := '0';
      end if;
      if ((split = 0 or v.ahbcancel = '0') and
          (split = 0 or ahbsi.hmaster = r.splmst or r.insplit = '0') and
--          (((split = 0 or r.insplit = '0') and r.hmbsel(SYSMON_BANK) = '1') or
--           (split = 1 and ahbsi.hmbsel(SYSMON_BANK) = '1')) and
          (((ahbsi.hsel(hindex) and ahbsi.hready and ahbsi.htrans(1)) = '1') or
           ((split = 0 or r.insplit = '0') and r.hready = '0' and r.hresp = HRESP_OKAY))) then
        v.hresp := HRESP_OKAY;
        if split /= 0 then
          v.insplit := '0';
          v.hsplit := r.hsplit;
        end if;
        v.hready := '1';
        v.hsel := '0';
        v.smr := '0';
        v.sma := '0';
      elsif split /= 0 and v.ahbcancel = '1' then
        v.den := '1'; v.smr := '0';
        v.ahbcancel := '0';
      end if;
    end if;
    
    -- Interrupts
    if (syso.ot and v.cfgreg.ot_ien) = '1' then
      v.irq := '1';
      v.cfgreg.ot_ien := '0';
    end if;
    
    for i in r.cfgreg.alm_ien'range loop
      if (syso.alm(i) and r.cfgreg.alm_ien(i)) = '1'  then
        v.irq := '1';
        v.cfgreg.alm_ien(i) := '0';
      end if;
    end loop;  -- i

    if (syso.eos and v.cfgreg.eos_ien) = '1' then
      v.irq := '1';
      v.cfgreg.eos_ien := '0';
    end if;

    if (syso.eoc and v.cfgreg.eoc_ien) = '1' then
      v.irq := '1';
      v.cfgreg.eoc_ien := '0';
    end if;

    if (syso.busy and v.cfgreg.busy_ien) = '1' then
      v.irq := '1';
      v.cfgreg.busy_ien := '0';
    end if;

    if (syso.jtagbusy and v.cfgreg.jb_ien) = '1' then
      v.irq := '1';
      v.cfgreg.jb_ien := '0';
    end if;

    if (syso.jtaglocked and v.cfgreg.jl_ien) = '1' then
      v.irq := '1';
      v.cfgreg.jl_ien := '0';
    end if;
    
    if (syso.jtagmodified and v.cfgreg.jm_ien) = '1' then
      v.irq := '1';
      v.cfgreg.jm_ien := '0';
    end if;

    -- Reset
    if rstn = '0' then
      v.cfgreg.ot_ien   := '0';
      v.cfgreg.alm_ien  := (others => '0');
      v.cfgreg.eos_ien  := '0';
      v.cfgreg.eoc_ien  := '0';
      v.cfgreg.busy_ien := '0';
      v.cfgreg.jb_ien   := '0';
      v.cfgreg.jl_ien   := '0';
      v.cfgreg.jm_ien   := '0';
      v.sma             := '0';
      v.smr             := '0';
      v.insplit         := '0';
      v.unsplit         := '0';
      v.hready          := '1';
      v.hwrite          := '0';
      v.hsel            := '0';
      v.hmbsel          := (others => '0');
      v.ahbcancel       := '0';
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
    if r.hmbsel(CONF_BANK) = '1' then
      if wrdalign = 0 then hrdata := zero32(31 downto 13) & r.rrdata;
      else hrdata := '1' & zero32(30 downto 13) & r.rrdata; end if;
    else
      if wrdalign = 0 then hrdata := r.srdata & r.srdata;
      else hrdata := zero32(31 downto 16) & r.srdata;
      end if;
    end if;
    ahbso.hrdata  <= ahbdrivedata(hrdata);
    ahbso.hconfig <= HCONFIG;
    ahbso.hirq    <= irq;
    ahbso.hindex  <= hindex;
    ahbso.hsplit  <= hsplit;

    -- Signals to system monitor
    sysi.daddr    <= r.haddr;
    sysi.den      <= r.den;
    sysi.dwe      <= r.hwrite;
    if wrdalign = 0 then
      if r.haddr(0) = '0' then sysi.di <= hwdata(31 downto 16);
      else sysi.di <= hwdata(15 downto 0); end if;
    else
      sysi.di <= hwdata(15 downto 0);
    end if;
    
    -- Signals from system monitor to core outputs
    sysmono.alm   <= syso.alm;
    sysmono.ot    <= syso.ot;
    sysmono.eoc   <= syso.eoc;
    sysmono.eos   <= syso.eos;
    sysmono.channel <= syso.channel;
    
  end process comb;
  
  reg: process (clk)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process reg;
  
  -- Boot message
  -- pragma translate_off
  bootmsg : report_version 
    generic map (
      "grsysmon" & tost(hindex) & ": AMBA wrapper for System Monitor, rev " &
      tost(REVISION) & ", irq " & tost(hirq));
  -- pragma translate_on

end rtl;


