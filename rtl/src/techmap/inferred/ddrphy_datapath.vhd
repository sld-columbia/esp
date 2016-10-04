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
-- Entity:      ddrphy_datapath
-- File:        ddrphy_datapath.vhd
-- Author:      Magnus Hjorth - Aeroflex Gaisler
-- Description: Generic DDR/DDR2 PHY data path (digital part of phy)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity ddrphy_datapath is
  generic (
    regtech: integer := 0;
    dbits: integer;
    abits: integer;
    bankbits: integer range 2 to 3 := 2;
    ncs: integer;
    nclk: integer;
    -- Enable extra resync stage clocked by clkresync
    resync: integer range 0 to 2 := 0
    );
  port (
    clk0: in std_ulogic;
    clk90: in std_ulogic;
    clk180: in std_ulogic;
    clk270: in std_ulogic;
    clkresync: in std_ulogic;

    ddr_clk: out std_logic_vector(nclk-1 downto 0);    
    ddr_clkb: out std_logic_vector(nclk-1 downto 0);
    
    ddr_dq_in: in std_logic_vector(dbits-1 downto 0);
    ddr_dq_out: out std_logic_vector(dbits-1 downto 0);
    ddr_dq_oen: out std_logic_vector(dbits-1 downto 0);

    ddr_dqs_in90: in std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_in90n: in std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_out: out std_logic_vector(dbits/8-1 downto 0);
    ddr_dqs_oen: out std_logic_vector(dbits/8-1 downto 0);

    ddr_cke: out std_logic_vector(ncs-1 downto 0);
    ddr_csb: out std_logic_vector(ncs-1 downto 0);
    ddr_web: out std_ulogic;
    ddr_rasb: out std_ulogic;
    ddr_casb: out std_ulogic;
    ddr_ad: out std_logic_vector(abits-1 downto 0);
    ddr_ba: out std_logic_vector(bankbits-1 downto 0);
    ddr_dm: out std_logic_vector(dbits/8-1 downto 0);
    ddr_odt: out std_logic_vector(ncs-1 downto 0);

    -- Control signals synchronous to clk0
    dqin: out std_logic_vector(dbits*2-1 downto 0);
    dqout: in std_logic_vector(dbits*2-1 downto 0);
    addr        : in  std_logic_vector (abits-1 downto 0);
    ba          : in  std_logic_vector (bankbits-1 downto 0);
    dm          : in  std_logic_vector (dbits/4-1 downto 0);
    oen         : in  std_ulogic;
    rasn        : in  std_ulogic;
    casn        : in  std_ulogic;
    wen         : in  std_ulogic;
    csn         : in  std_logic_vector(ncs-1 downto 0);
    cke         : in  std_logic_vector(ncs-1 downto 0);  -- Clk enable control signal to memory
    odt         : in  std_logic_vector(ncs-1 downto 0);

    dqs_en      : in  std_ulogic;       -- Run dqs strobe (active low)
    dqs_oen     : in  std_ulogic;       -- DQS output enable (active low)
    
    ddrclk_en   : in  std_logic_vector(nclk-1 downto 0)  -- Enable/stop ddr_clk
    );
end;

architecture rtl of ddrphy_datapath is

  signal vcc,gnd: std_ulogic;
  signal dqs_en_inv,dqs_en_inv180: std_ulogic;
  signal dqcaptr,dqcaptf: std_logic_vector(dbits-1 downto 0);
  signal dqsyncr,dqsyncf: std_logic_vector(dbits-1 downto 0);
  
begin

  vcc <= '1';
  gnd <= '0';
  
  -----------------------------------------------------------------------------
  -- DDR interface clock signal
  -----------------------------------------------------------------------------
  -- 90 degree shifted relative to master clock, gated by ddrclk_en
  genclk: for x in 0 to nclk-1 generate
    clkreg: ddr_oreg 
      generic map (tech => regtech)
      port map (d1 => ddrclk_en(x), d2 => gnd, ce => vcc, 
                c1 => clk90, c2 => clk270, r => gnd, s => gnd,
                q => ddr_clk(x), testen => gnd, testrst => gnd);
    clkbreg: ddr_oreg 
      generic map (tech => regtech)
      port map (d1 => gnd, d2 => ddrclk_en(x), ce => vcc, 
                c1 => clk90, c2 => clk270, r => gnd, s => gnd,
                q => ddr_clkb(x), testen => gnd, testrst => gnd);
  end generate;
  
  -----------------------------------------------------------------------------
  -- Control signals RAS,CAS,WE,BA,ADDR,CS,ODT,CKE
  -----------------------------------------------------------------------------
  rasreg: grdff generic map (tech => regtech)
    port map (clk => clk0, d => rasn, q => ddr_rasb);
  
  casreg: grdff generic map (tech => regtech)
    port map (clk => clk0, d => casn, q => ddr_casb);
  
  wereg: grdff generic map (tech => regtech)
    port map (clk => clk0, d => wen, q => ddr_web);
  
  genba: for x in 0 to bankbits-1 generate
    bareg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => ba(x), q => ddr_ba(x));
  end generate;
  
  gencs: for x in 0 to ncs-1 generate
    csreg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => csn(x), q => ddr_csb(x));
    ckereg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => cke(x), q => ddr_cke(x));
    odtreg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => odt(x), q => ddr_odt(x));
  end generate;

  genaddr: for x in 0 to abits-1 generate
    addrreg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => addr(x), q => ddr_ad(x));
  end generate;

  -----------------------------------------------------------------------------
  -- Outgoing data, output enable, DQS, DQSOEN, DM
  -----------------------------------------------------------------------------
  gendqout: for x in 0 to dbits-1 generate
    dqoutreg: ddr_oreg
      generic map (tech => regtech)
      port map (d1 => dqout(x+dbits), d2 => dqout(x), ce => vcc, 
                c1 => clk0, c2 => clk180, r => gnd, s => gnd,
                q => ddr_dq_out(x), testen => gnd, testrst => gnd);
    dqoenreg: grdff
      generic map (tech => regtech)
      port map (clk => clk0, d => oen, q => ddr_dq_oen(x));
  end generate;

  -- dqs_en -> invert -> delay -> +90-deg DDR-regs -> dqs_out
  -- In total oen is delayed 5/4 cycles. We use 1/2 cycle delay
  -- instead of 1 cycle delay to get better timing margin to DDR regs.
  -- DQSOEN is delayed one cycle just like ctrl sigs

  dqs_en_inv <= not dqs_en;

  dqseninv180reg: grdff
    generic map (tech => regtech)
    port map (clk => clk180, d => dqs_en_inv, q => dqs_en_inv180);
  
  gendqsout: for x in 0 to dbits/8-1 generate
    dqsreg: ddr_oreg
      generic map (tech => regtech)
      port map (d1 => dqs_en_inv180, d2 => gnd, ce => vcc,
                c1 => clk90, c2 => clk270, r => gnd, s => gnd,
                q => ddr_dqs_out(x), testen => gnd, testrst => gnd);
    
    dqsoenreg: grdff generic map (tech => regtech)
      port map (clk => clk0, d => dqs_oen, q => ddr_dqs_oen(x));
  end generate;

  gendm: for x in 0 to dbits/8-1 generate
    dmreg: ddr_oreg
      generic map (tech => regtech)
      port map (d1 => dm(x+dbits/8), d2 => dm(x), ce => vcc,
                c1 => clk0, c2 => clk180, r => gnd, s => gnd,
                q => ddr_dm(x), testen => gnd, testrst => gnd);
  end generate;
  
  -----------------------------------------------------------------------------
  -- Incoming data
  -----------------------------------------------------------------------------

  gendqin: for x in 0 to dbits-1 generate
    -- capture using dqs+90
    -- Note: The ddr_ireg delivers both edges on c1 rising edge, therefore c1
    -- is connected to inverted clock (c1 rising edge == dqs falling edge)
    dqcaptreg: ddr_ireg generic map (tech => regtech)
      port map (d => ddr_dq_in(x),
                c1 => ddr_dqs_in90n(x/8), c2 => ddr_dqs_in90(x/8), ce => vcc, r => gnd, s => gnd,
                q1 => dqcaptf(x), q2 => dqcaptr(x), testen => gnd, testrst => gnd);
    
    -- optional extra resync stage
    ifresync: if resync=1 generate
      genresync: for x in 0 to dbits-1 generate
        dqsyncrreg: grdff generic map (tech => regtech)
          port map (clk => clkresync, d => dqcaptr(x), q => dqsyncr(x));
        dqsyncfreg: grdff generic map (tech => regtech)
          port map (clk => clkresync, d => dqcaptf(x), q => dqsyncf(x));
      end generate;
    end generate;    
    noresync: if resync/=1 generate
      dqsyncr <= dqcaptr;
      dqsyncf <= dqcaptf;
    end generate;
    -- sample in clk0 domain
    gensamp: if resync/=2 generate
      dqinregr: grdff generic map (tech => regtech)
        port map (clk => clk0, d => dqsyncr(x), q => dqin(x+dbits));
      dqinregf: grdff generic map (tech => regtech)
        port map (clk => clk0, d => dqsyncf(x), q => dqin(x));
    end generate;
    nosamp: if resync=2 generate
      dqin(x+dbits) <= dqsyncr(x);
      dqin(x) <= dqsyncf(x);
    end generate;
  end generate;


  
end;

