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
-- Entity:      jtagcom
-- File:        jtagcom.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Modified:    J. Gaisler, K. Glembo, J. Andersson - Aeroflex Gaisler
-- Description: JTAG Debug Interface with AHB master interface 
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.gencomp.all;
use work.libjtagcom.all;
use work.misc.all;

entity jtagcom is
  generic (
    isel   : integer range 0 to 1 := 0;
    nsync  : integer range 1 to 2 := 2;
    ainst  : integer range 0 to 255 := 2;
    dinst  : integer range 0 to 255 := 3;
    reread : integer range 0 to 1 := 0);
  port (
    rst  : in std_ulogic;
    clk  : in std_ulogic;
    tapo : in tap_out_type;
    tapi : out tap_in_type;
    dmao : in  ahb_dma_out_type;    
    dmai : out ahb_dma_in_type;
    tck  : in std_ulogic;
    trst : in std_ulogic
    );
  attribute sync_set_reset of rst : signal is "true";
end;


architecture rtl of jtagcom is

  constant ADDBITS : integer := 10;
  constant NOCMP : boolean := (isel /= 0);
  
  type state_type is (shft, ahb, nxt_shft);  
  
  type reg_type is record
    addr  : std_logic_vector(34 downto 0);
    data  : std_logic_vector(32 downto 0);
    state : state_type;
    tcktog: std_logic_vector(nsync-1 downto 0);
    tcktog2: std_ulogic;
    tdishft: std_ulogic;
    trst  : std_logic_vector(nsync-1 downto 0);
    tdi   : std_logic_vector(nsync-1 downto 0);
    shift : std_logic_vector(nsync-1 downto 0);
    shift2: std_ulogic;
    upd   : std_logic_vector(nsync-1 downto 0);
    upd2  : std_ulogic;
    asel  : std_logic_vector(nsync-1 downto 0);
    dsel  : std_logic_vector(nsync-1 downto 0);
    seq   : std_ulogic;
    holdn : std_ulogic;
  end record;

  type tckreg_type is record
    tcktog: std_ulogic;
    tdi: std_ulogic;
    tdor: std_ulogic;
  end record;

  signal nexttdo: std_ulogic;

  signal r, rin : reg_type;
  signal tr: tckreg_type;
  
begin  

  comb : process (rst, r, tapo, dmao, tr)
    variable v : reg_type;
    variable redge0 : std_ulogic;
    variable vdmai : ahb_dma_in_type;
    variable asel, dsel : std_ulogic;
    variable vtapi : tap_in_type;
    variable write, seq : std_ulogic;
    variable vnexttdo: std_ulogic;
  begin

    v := r;

    if NOCMP then
      asel := tapo.asel; dsel := tapo.dsel;      
    else
      if tapo.inst = conv_std_logic_vector(ainst, 8) then asel := '1'; else asel := '0'; end if;
      if tapo.inst = conv_std_logic_vector(dinst, 8) then dsel := '1'; else dsel := '0'; end if;
    end if;
    vtapi.en := asel or dsel;
    vnexttdo := '0';
    if asel='1' then
      if tapo.shift='1' then
        vnexttdo := r.addr(1);
      else
        vnexttdo := r.addr(0);
      end if;
    else
      if tapo.shift='1' then
        vnexttdo := r.data(1);
      else
        vnexttdo := r.data(0);
      end if;
      if reread /= 0 then vnexttdo := vnexttdo and r.holdn; end if;
    end if;
    nexttdo <= vnexttdo;
    vtapi.tdo := tr.tdor;

    write := r.addr(34); seq := r.seq;
    
    v.tcktog(0) := r.tcktog(nsync-1); v.tcktog(nsync-1) := tr.tcktog;
    v.tcktog2 := r.tcktog(0); v.shift2 := r.shift(0);
    v.trst(0) := r.trst(nsync-1); v.trst(nsync-1) := tapo.reset;
    v.tdi(0) := r.tdi(nsync-1); v.tdi(nsync-1) := tr.tdi;
    v.shift(0) := r.shift(nsync-1); v.shift(nsync-1) := tapo.shift;
    v.upd(0) := r.upd(nsync-1); v.upd(nsync-1) := tapo.upd;
    v.upd2 := r.upd(0);
    v.asel(0) := r.asel(nsync-1); v.asel(nsync-1) := asel;
    v.dsel(0) := r.dsel(nsync-1); v.dsel(nsync-1) := dsel;
    redge0 := r.tcktog2 xor r.tcktog(0);
    v.tdishft := '0';
    vdmai.address := r.addr(31 downto 0); vdmai.wdata := ahbdrivedata(r.data(31 downto 0));
    vdmai.start := '0'; vdmai.burst := '0'; vdmai.write := write;
    vdmai.busy := '0'; vdmai.irq := '0'; vdmai.size := '0' & r.addr(33 downto 32);


    case r.state is
      when shft =>
        if (r.asel(0) or r.dsel(0)) = '1' then
        if r.shift2 = '1' then
          if redge0 = '1' then
            if r.asel(0) = '1' then v.addr(33 downto 0) := r.addr(34 downto 1); end if;
            if r.dsel(0) = '1' then v.data(31 downto 0) := r.data(32 downto 1); end if;
            v.tdishft := '1'; -- Shift in TDI next AHB cycle
          end if;        
        elsif r.upd2 = '1' then
          if reread /= 0 then
            v.data(32) := '0';          -- Transfer not done
          end if;
          if (r.asel(0) and not write) = '1' then v.state := ahb; end if;
          if (r.dsel(0) and (write or (not write and seq))) = '1' then -- data register
            v.state := ahb;
            if (seq and not write) = '1' then 
              v.addr(ADDBITS-1 downto 2) := r.addr(ADDBITS-1 downto 2) + 1;
            end if;
          end if;
          end if;
        end if;
        if r.tdishft='1' then
          if r.asel(0)='1' then v.addr(34):=r.tdi(0); end if;
          if r.dsel(0)='1' then v.data(32):=r.tdi(0); v.seq:=r.tdi(0); end if;
        end if;
        if reread /= 0 then v.holdn := '1'; end if;
        vdmai.size := "000";
        
      when ahb =>
        if reread /= 0 and r.shift2 = '1' then v.holdn := '0'; end if;
        if dmao.active = '1' then
          if dmao.ready = '1' then
            v.data(31 downto 0) := ahbreadword(dmao.rdata);
            v.state := nxt_shft;
            if reread /= 0 then
              v.data(32) := '1';          -- Transfer done
            end if;
            if (write and seq) = '1' then
              v.addr(ADDBITS-1 downto 2) := r.addr(ADDBITS-1 downto 2) + 1;
            end if;
          end if;
        else
          vdmai.start := '1';
        end if;

      when nxt_shft =>
        if reread /= 0 then
          v.holdn := (r.holdn or r.upd2) and not r.shift2;
          if r.upd2 = '0' and r.shift2 = '0' and r.holdn = '1' then v.state := shft; end if;
        else
          if r.upd2 = '0' then v.state := shft; end if;
        end if;
      when others =>
        v.state := shft; v.addr := (others => '0'); v.seq := '0';
    end case;

    if (rst = '0') or (r.trst(0) = '1') then
      v.state := shft; v.addr := (others => '0'); v.seq := '0';
    end if;

    if reread = 0 then v.holdn := '0'; end if;
    
    rin <= v; dmai <= vdmai; tapi <= vtapi;
    
    
  end process;

  reg : process (clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;
  
  tckreg: process (tck,trst)
  begin
    if rising_edge(tck) then
      tr.tcktog <= not tr.tcktog;
      tr.tdi <= tapo.tdi;
      tr.tdor <= nexttdo;
    end if;
    if trst='0' then
      tr.tcktog <= '0';
      tr.tdi <= '0';
      tr.tdor <= '0';
    end if;
  end process;
end;  

