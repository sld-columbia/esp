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
-- Entity:      ahb2avl_async_be
-- File:        ahb2avl_async_be.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Avalon clock domain part of ahb2avl_async
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.amba.all;
use work.stdlib.all;
use work.ddrpkg.all;
use work.ddrintpkg.all;

entity ahb2avl_async_be is
  generic (
    avldbits  : integer := 32;
    avlabits  : integer := 20;
    ahbbits   : integer := ahbdw;
    burstlen  : integer := 8;
    nosync    : integer := 0
    );
  port (
    rst : in std_ulogic;
    clk : in std_ulogic;
    avlsi : out ddravl_slv_in_type;
    avlso : in  ddravl_slv_out_type;
    request: in ddr_request_type;
    start_tog: in std_ulogic;
    response: out ddr_response_type;
    wbraddr  : out std_logic_vector(log2((32*burstlen)/avldbits) downto 0);
    wbrdata  : in std_logic_vector(avldbits-1 downto 0);
    rbwaddr  : out std_logic_vector(log2((32*burstlen)/avldbits)-1 downto 0);
    rbwdata  : out std_logic_vector(avldbits-1 downto 0);
    rbwrite  : out std_logic
    );
end;

architecture rtl of ahb2avl_async_be is

  constant avlbl: integer := (burstlen*32) / avldbits;
  constant onev: std_logic_vector(15 downto 0) := (others => '1');
  
  type be_state is (idle,acc1,acc2,rdwait);

  type be_regs is record
    req1,req2 : ddr_request_type;
    start1,start2: std_ulogic;
    resp: ddr_response_type;
    s: be_state;
    ramaddr: std_logic_vector(log2(avlbl)-1 downto 0);
    beginburst: std_ulogic;
    wr: std_ulogic;
    rd: std_ulogic;
    reading: std_ulogic;
    rdata_valid_prev: std_ulogic;
    wmaskmode: std_ulogic;
    rstarted: std_ulogic;
  end record;

  signal r,nr: be_regs;

begin

  comb: process(r,rst,request,start_tog,avlso,wbrdata)
    variable v: be_regs;
    variable vstart: std_logic;
    variable vreq: ddr_request_type;
    variable startmask,endmask,mask,mask16,mask8: std_logic_vector(avldbits/8-1 downto 0);
    variable ad32: std_logic_vector(3 downto 2);
    variable nwmaskmode: std_ulogic;
    variable rbw: std_ulogic;
    variable slvi: ddravl_slv_in_type;
    variable rddone: std_ulogic;
    variable inc_ramaddr: std_ulogic;
    variable aendaddr: std_logic_vector(9 downto 0);
  begin
    v := r;

    slvi := ddravl_slv_in_none;
    slvi.burstbegin := r.beginburst;
    slvi.addr(avlabits-1 downto log2(avlbl)) :=
      vreq.startaddr(avlabits-1-log2(avlbl)+log2(burstlen*4) downto log2(burstlen*4));
    slvi.addr(log2(avlbl)-1 downto 0) := r.ramaddr;
    slvi.wdata(avldbits-1 downto 0) := wbrdata;
    slvi.write_req := r.wr;
    slvi.size := std_logic_vector(to_unsigned(avlbl, slvi.size'length));

    -- fix for accesses wider than 32-b word
    aendaddr := request.endaddr; --(log2(4*burstlen)-1 downto 2);
    if request.hsize(1 downto 0)="11" and request.hio='0' then
      aendaddr(2):='1';
    end if;
    if ahbbits > 64 and request.hsize(2)='1' then
      aendaddr(3 downto 2) := "11";
      if ahbbits > 128 and request.hsize(0)='1' then
        aendaddr(4) := '1';
      end if;
    end if;

    v.req1 := request;
    v.req1.endaddr := aendaddr;
    v.req2 := r.req1;
    v.start1 := start_tog;
    v.start2 := r.start1;
    vstart:=r.start2; vreq:=r.req2;
    if nosync /= 0 then vstart:=start_tog; vreq:=r.req1; end if;

    startmask := (others => '1'); endmask := (others => '1');
    mask16 := (others => '1'); mask8 := (others => '1');
    case avldbits is
      when 32 =>
        if vreq.startaddr(1)='0' then mask16:="1100"; else mask16:="0011"; end if;
        if vreq.startaddr(0)='0' then  mask8:="1010"; else  mask8:="0101"; end if;
      when 64 =>
        if vreq.startaddr(2)='0' then startmask:="11111111";
        else                          startmask:="00001111";
        end if;
        if vreq.endaddr(2)='0' then endmask:="11110000";
        else                        endmask:="11111111";
        end if;
        if vreq.startaddr(1)='0' then mask16:="11001100"; else mask16:="00110011"; end if;
        if vreq.startaddr(0)='0' then  mask8:="10101010"; else  mask8:="01010101"; end if;
      when 128 =>
        ad32 := vreq.startaddr(3 downto 2);
        case ad32 is
          when "00" =>    startmask:="1111111111111111";
          when "01" =>    startmask:="0000111111111111";
          when "10" =>    startmask:="0000000011111111";
          when others =>  startmask:="0000000000001111";
        end case;
        ad32 := vreq.endaddr(3 downto 2);
        case ad32 is
          when "00" =>    endmask:="1111000000000000";
          when "01" =>    endmask:="1111111100000000";
          when "10" =>    endmask:="1111111111110000";
          when others =>  endmask:="1111111111111111";
        end case;
        if vreq.startaddr(1)='0' then mask16:="1100110011001100"; else mask16:="0011001100110011"; end if;
        if vreq.startaddr(0)='0' then  mask8:="1010101010101010"; else  mask8:="0101010101010101"; end if;
      when 256 =>
        case vreq.startaddr(4 downto 2) is
          when "000" =>    startmask:="11111111111111111111111111111111";
          when "001" =>    startmask:="00001111111111111111111111111111";
          when "010" =>    startmask:="00000000111111111111111111111111";
          when "011" =>    startmask:="00000000000011111111111111111111";
          when "100" =>    startmask:="00000000000000001111111111111111";
          when "101" =>    startmask:="00000000000000000000111111111111";
          when "110" =>    startmask:="00000000000000000000000011111111";
          when others =>   startmask:="00000000000000000000000000001111";
        end case;
        case vreq.endaddr(4 downto 2) is
          when "000" =>    endmask:="11110000000000000000000000000000";
          when "001" =>    endmask:="11111111000000000000000000000000";
          when "010" =>    endmask:="11111111111100000000000000000000";
          when "011" =>    endmask:="11111111111111110000000000000000";
          when "100" =>    endmask:="11111111111111111111000000000000";
          when "101" =>    endmask:="11111111111111111111111100000000";
          when "110" =>    endmask:="11111111111111111111111111110000";
          when others =>   endmask:="11111111111111111111111111111111";
        end case;
        if vreq.startaddr(1)='0' then mask16:="11001100110011001100110011001100"; else mask16:="00110011001100110011001100110011"; end if;
        if vreq.startaddr(0)='0' then  mask8:="10101010101010101010101010101010"; else  mask8:="01010101010101010101010101010101"; end if;
      when others =>
        --pragma translate_off
        assert false report "Unsupported data bus width" severity failure;
        --pragma translate_on
    end case;
    mask := (others => r.wmaskmode);
    nwmaskmode := r.wmaskmode;
    if r.wmaskmode='0' then
      if r.ramaddr=vreq.startaddr(log2(burstlen*4)-1 downto log2(avldbits/8)) then
        mask := startmask;
        nwmaskmode:='1';
        if r.reading='1' then v.rstarted := '1'; end if;
      end if;
    end if;
    if r.ramaddr=vreq.endaddr(log2(burstlen*4)-1 downto log2(avldbits/8)) then
      mask := mask and endmask;
      nwmaskmode:='0';
    end if;
    if vreq.hsize(2 downto 1)="00" then
      mask := mask and mask16;
      if vreq.hsize(0)='0' then
        mask := mask and mask8;
      end if;
    end if;

    rddone := '0';
    inc_ramaddr := '0';
    rbw := '0';

    if r.reading /= '0' then
      if avlso.rdata_valid='1' then
        rbw := '1';
        inc_ramaddr := '1';
        if v.rstarted='1' then
          v.resp.rctr_gray(log2(avlbl)-1 downto 0) := nextgray(r.resp.rctr_gray(log2(avlbl)-1 downto 0));
        end if;
        if r.ramaddr=(r.ramaddr'range => '1') then
          rddone:='1';
        end if;
      end if;
    else
      v.resp.rctr_gray := (others => '0');
    end if;
    
    v.beginburst := '0';
    case r.s is

      when idle =>
        if vstart /= r.resp.done_tog then
          v.s := acc1;
          v.beginburst := '1';
        end if;
        v.reading := '0';
        v.rstarted := '0';
        v.wmaskmode := '0';
        v.rd := '0';
        v.wr := '0';

      when acc1 =>
        v.wr := vreq.hwrite;
        v.rd := not vreq.hwrite;
        v.reading := not vreq.hwrite;
        if vreq.hwrite='1' then
          slvi.write_req := '1';
        end if;
        if vreq.hwrite/='0' then
          v.s := acc2;
        end if;
        if vreq.hwrite='0' and avlso.ready='1' then
          v.s := rdwait;
        end if;
        if vreq.hwrite = '0' then
          mask := (others => '1');
        end if;
        if avlso.ready='1' and vreq.hwrite/='0' then
          inc_ramaddr := '1';
        end if;

      when acc2 =>
        if avlso.ready='1' then
          inc_ramaddr := '1';
          if r.ramaddr=onev(r.ramaddr'length-1 downto 0) then
            v.wr := '0';
            v.resp.done_tog := not r.resp.done_tog;
            v.s := idle;
          end if;
        end if;

      when rdwait =>
        v.rd := '0';
        if rddone='1' then
          v.resp.done_tog := not r.resp.done_tog;
          v.s := idle;
        end if;
    end case;

    if inc_ramaddr/='0' then
      v.ramaddr := std_logic_vector(unsigned(r.ramaddr)+1);
      v.wmaskmode := nwmaskmode;
    end if;
    if v.s=idle then
      v.ramaddr := (others => '0');
    end if;

    slvi.read_req := v.rd;
    slvi.be(avldbits/8-1 downto 0) := mask;

    if rst='0' then
      v.s := idle;
      v.resp := ddr_response_none;
    end if;

    nr <= v;
    response <= r.resp;
    wbraddr <= r.resp.done_tog & v.ramaddr;
    rbwaddr <= r.ramaddr;
    rbwdata <= avlso.rdata(avldbits-1 downto 0);
    rbwrite <= rbw;
    avlsi <= slvi;
  end process;

  regs: process(clk)
  begin
    if rising_edge(clk) then
      r <= nr;
    end if;
  end process;

end;

