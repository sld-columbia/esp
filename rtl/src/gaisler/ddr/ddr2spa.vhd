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
-- Entity:      ddr2spa
-- File:        ddr2spa.vhd
-- Author:      Nils-Johan Wessman - Gaisler Research
-- Description: 16-, 32- or 64-bit DDR2 memory controller module.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.ddrpkg.all;
use work.gencomp.all;

entity ddr2spa is
  generic (
    fabtech        :       integer := virtex4;
    memtech        :       integer := 0;
    rskew          :       integer := 0;
    hindex         :       integer := 0;
    haddr          :       integer := 0;
    hmask          :       integer := 16#f00#;
    ioaddr         :       integer := 16#000#;
    iomask         :       integer := 16#fff#;
    MHz            :       integer := 100;
    TRFC           :       integer := 130;
    clkmul         :       integer := 2;
    clkdiv         :       integer := 2;
    col            :       integer := 9;
    Mbyte          :       integer := 16;
    rstdel         :       integer := 200;
    pwron          :       integer := 0;
    oepol          :       integer := 0;
    ddrbits        :       integer := 16;
    ahbfreq        :       integer := 50;
    readdly        :       integer := 1;  -- 1 added read latency cycle
    ddelayb0       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb1       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb2       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb3       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb4       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb5       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb6       :       integer := 0;  -- Data delay value (0 - 63)
    ddelayb7       :       integer := 0;  -- Data delay value (0 - 63)
    cbdelayb0      :       integer := 0;  -- Data delay value (0 - 63)
    cbdelayb1      :       integer := 0;  -- Data delay value (0 - 63)
    cbdelayb2      :       integer := 0;  -- Data delay value (0 - 63)
    cbdelayb3      :       integer := 0;  -- Data delay value (0 - 63)    
    numidelctrl    :       integer := 4;
    norefclk       :       integer := 0;
    odten          :       integer := 0;
    octen          :       integer := 0;
    dqsgating      :       integer := 0;
    nosync         :       integer := 0;  -- Disable sync registers at CD crossings
    eightbanks     :       integer range 0 to 1 := 0;
    dqsse          :       integer range 0 to 1 := 0;  -- single ended DQS
    burstlen       :       integer range 4 to 128 := 8;
    ahbbits        :       integer := ahbdw;
    ft             :       integer range 0 to 1 := 0;
    ftbits         :       integer := 0;
    bigmem         :       integer range 0 to 1 := 0;
    raspipe        :       integer range 0 to 1 := 0;
    nclk           :       integer range 1 to 3 := 3;
    scantest       :       integer := 0;
    ncs            :       integer := 2;
    cke_rst        :       integer := 0;
    pipe_ctrl      :       integer := 0
    );
  port (
    rst_ddr        : in    std_ulogic;
    rst_ahb        : in    std_ulogic;
    clk_ddr        : in    std_ulogic;
    clk_ahb        : in    std_ulogic;
    clkref200      : in    std_logic;
    lock           : out   std_ulogic;  -- DCM locked
    clkddro        : out   std_ulogic;  -- DDR clock
    clkddri        : in    std_ulogic;
    ahbsi          : in    ahb_slv_in_type;
    ahbso          : out   ahb_slv_out_type;
    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(1 downto 0);
    ddr_csb        : out   std_logic_vector(1 downto 0);
    ddr_web        : out   std_ulogic;                              -- ddr write enable
    ddr_rasb       : out   std_ulogic;                              -- ddr ras
    ddr_casb       : out   std_ulogic;                              -- ddr cas
    ddr_dm         : out   std_logic_vector((ddrbits+ftbits)/8-1 downto 0);  -- ddr dm
    ddr_dqs        : inout std_logic_vector((ddrbits+ftbits)/8-1 downto 0);  -- ddr dqs
    ddr_dqsn       : inout std_logic_vector((ddrbits+ftbits)/8-1 downto 0);  -- ddr dqsn
    ddr_ad         : out   std_logic_vector(13 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector(1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector((ddrbits+ftbits)-1 downto 0);    -- ddr data
    ddr_odt        : out   std_logic_vector(1 downto 0);
    ce             : out   std_logic;   -- Corrected error (for FT)
    oct_rdn        : in    std_logic := '0';
    oct_rup        : in    std_logic := '0'
    );
end;

architecture rtl of ddr2spa is

constant DDR_FREQ : integer := (clkmul * MHz) / clkdiv;
signal sdi     : ddrctrl_in_type;
signal sdo     : ddrctrl_out_type;
--signal clkread  : std_ulogic;

-- Reset scheme:
-- 1. rst_ddr inport is a raw async reset brought in from the outside - goes to PHY/PLL:s
-- 2. lock signal from PHY/PLLs goes out through lock outport to external
--    ahb rstgen and internal ddr reset gen
-- 3. AMBA synchronous reset signal rst_ahb comes back in

-- DDR Clock scheme:
-- 1. clk_ddr (and clkref200) goes into PHY
-- 2. clkddro comes out from PHY and goes out through clkddro port
-- 3. clkddri comes back in and is used to clock DDR-side logic

signal ilock: std_ulogic;

signal ddr_rst: std_logic;
signal ddr_rst_gen: std_logic_vector(3 downto 0);

constant ddr_syncrst: integer := 0;

begin

  lock <= ilock;
  
  ddr_rst <= (ddr_rst_gen(3) and ddr_rst_gen(2) and ddr_rst_gen(1)); -- Reset signal in DDR clock domain

  ddrrstproc: process(clkddri, ilock)
  begin
    if rising_edge(clkddri) then
      ddr_rst_gen <= ddr_rst_gen(2 downto 0) & '1';
      if ddr_syncrst /= 0 and rst_ahb='0' then
        ddr_rst_gen <= "0000";
      end if;
    end if;
    if ddr_syncrst=0 and ilock='0' then
      ddr_rst_gen <= "0000";
    end if;
  end process;
      
  nftphy: if true generate
    ddr_phy0 : ddr2phy_wrap_cbd
      generic map (
        tech => fabtech, MHz => MHz,
        dbits => ddrbits, rstdelay => 0, clk_mul => clkmul,
        clk_div => clkdiv,
        ddelayb0 => ddelayb0, ddelayb1 => ddelayb1, ddelayb2 => ddelayb2,
        ddelayb3 => ddelayb3, ddelayb4 => ddelayb4, ddelayb5 => ddelayb5,
        ddelayb6 => ddelayb6, ddelayb7 => ddelayb7, cbdelayb0=> cbdelayb0,
        cbdelayb1=> cbdelayb1, cbdelayb2=> cbdelayb2,cbdelayb3=> cbdelayb3,
        numidelctrl => numidelctrl, norefclk => norefclk, rskew => rskew,
        eightbanks => eightbanks, dqsse => dqsse,
        chkbits => ftbits*ft, padbits => ftbits*(1-ft),
        ctrl2en => 0, resync => 0, custombits => 8,
        nclk => nclk, scantest => scantest, ncs => ncs )
      port map (
        rst_ddr, clk_ddr, clkref200, clkddro, clkddri, clkddri, ilock,
        ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
        ddr_cke(ncs-1 downto 0), ddr_csb(ncs-1 downto 0), ddr_web, ddr_rasb, ddr_casb,
        ddr_dm, ddr_dqs, ddr_dqsn,
        ddr_ad, ddr_ba, ddr_dq, ddr_odt(ncs-1 downto 0),
        open, open, open, open, open,
        sdi, sdo, clkddri, "00000000", open,
        ahbsi.testen, ahbsi.scanen, ahbsi.testrst, ahbsi.testoen,
        oct_rdn, oct_rup);
    ncs1: if ncs = 1 generate
        ddr_cke(1) <= '0';
        ddr_csb(1) <= '0';
        ddr_odt(1) <= '0';
    end generate;
  end generate;

    ddrc : ddr2spax generic map (memtech => memtech, phytech => fabtech, hindex => hindex, 
      haddr => haddr, hmask => hmask, ioaddr => ioaddr, iomask => iomask, ddrbits => ddrbits,
      pwron => pwron, MHz => DDR_FREQ, TRFC => TRFC, col => col, Mbyte => Mbyte,
      readdly => readdly, odten => odten, octen => octen, dqsgating => dqsgating,
      nosync => nosync, eightbanks => eightbanks, dqsse => dqsse, burstlen => burstlen, ahbbits => ahbbits,
      ft => ft, ddr_syncrst => ddr_syncrst, bigmem => bigmem, raspipe => raspipe, hwidthen => 0, rstdel => rstdel,
      cke_rst => cke_rst, pipe_ctrl => pipe_ctrl)
    port map (ddr_rst, rst_ahb, clkddri, clk_ahb, ahbsi, ahbso, sdi, sdo, '0');

  ce <= sdo.ce;
  
end;

