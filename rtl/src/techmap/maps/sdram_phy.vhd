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
-- Entity:      sdram_phy
-- File:        sdram_phy.vhd
-- Author:      Jan Andersson - Aeroflex Gaisler
-- Description: SDRAM PHY with tech mapping, includes pads and can be
--              implemented with registers on all signals.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.stdlib.all;
use work.gencomp.all;
use work.allpads.all;

entity sdram_phy is
  generic (
    tech     : integer := spartan3;
    oepol    : integer := 0;
    level    : integer := 0;
    voltage  : integer := x33v;
    strength : integer := 12;
    aw       : integer := 15;               -- # address bits
    dw       : integer := 32;               -- # data bits
    ncs      : integer := 2;
    reg      : integer := 0);               -- 1: include registers on all signals
  port (
    -- SDRAM interface
    addr      : out   std_logic_vector(aw-1 downto 0);
    dq        : inout std_logic_vector(dw-1 downto 0);
    cke       : out   std_logic_vector(ncs-1 downto 0);
    sn        : out   std_logic_vector(ncs-1 downto 0);
    wen       : out   std_ulogic;
    rasn      : out   std_ulogic;
    casn      : out   std_ulogic;
    dqm       : out   std_logic_vector(dw/8-1 downto 0);

    -- Interface toward memory controller
    laddr     : in    std_logic_vector(aw-1 downto 0);
    ldq_din   : out   std_logic_vector(dw-1 downto 0);
    ldq_dout  : in    std_logic_vector(dw-1 downto 0);
    ldq_oen   : in    std_logic_vector(dw-1 downto 0);
    lcke      : in    std_logic_vector(ncs-1 downto 0);
    lsn       : in    std_logic_vector(ncs-1 downto 0);
    lwen      : in    std_ulogic;
    lrasn     : in    std_ulogic;
    lcasn     : in    std_ulogic;
    ldqm      : in    std_logic_vector(dw/8-1 downto 0);

    -- Only used when reg generic is non-zero
    rstn      : in  std_ulogic;         -- Registered pads reset
    clk       : in  std_ulogic;         -- SDRAM clock for registered pads

    -- Optional pad configuration inputs
    cfgi_cmd  : in std_logic_vector(19 downto 0) := "00000000000000000000"; -- CMD pads
    cfgi_dq   : in std_logic_vector(19 downto 0) := "00000000000000000000"  -- DQ pads
  );
end;

architecture rtl of sdram_phy is

  signal laddrx    : std_logic_vector(aw-1 downto 0);
  signal ldq_dinx  : std_logic_vector(dw-1 downto 0);
  signal ldq_doutx : std_logic_vector(dw-1 downto 0);
  signal ldq_oenx  : std_logic_vector(dw-1 downto 0);
  signal lckex     : std_logic_vector(ncs-1 downto 0);
  signal lsnx      : std_logic_vector(ncs-1 downto 0);
  signal lwenx     : std_ulogic;
  signal lrasnx    : std_ulogic;
  signal lcasnx    : std_ulogic;
  signal ldqmx     : std_logic_vector(dw/8-1 downto 0);

  signal oen       : std_ulogic;
  signal voen      : std_logic_vector(dw-1 downto 0);

  -- Determines if there is a customized phy available for target tech,
  -- otherwise a generic PHY will be built
  constant has_sdram_phy : tech_ability_type :=
    (easic45 => 1, others => 0);

  -- Determines if target tech has pads with built in registers (or rather if
  -- target technology requires special pad instantiations in order to get
  -- registers into pad ring).
  constant tech_has_padregs : tech_ability_type :=
    (easic45 => 1, others => 0);

begin

  oen <= not ldq_oen(0) when padoen_polarity(tech) /= oepol else ldq_oen(0);
  voen <= not ldq_oen when padoen_polarity(tech) /= oepol else ldq_oen;

  nopadregs : if (reg = 0) or (tech_has_padregs(tech) /= 0) generate
    laddrx    <= laddr;
    ldq_din   <= ldq_dinx;
    ldq_doutx <= ldq_dout;
    ldq_oenx  <= voen;
    lckex     <= lcke;
    lsnx      <= lsn;
    lwenx     <= lwen;
    lrasnx    <= lrasn;
    lcasnx    <= lcasn;
    ldqmx     <= ldqm;
  end generate;
  padregs : if (reg /= 0) and (tech_has_padregs(tech) = 0) generate
    regproc : process(clk, rstn)
    begin
      if rising_edge(clk) then
        laddrx    <= laddr;
        ldq_din   <= ldq_dinx;
        ldq_doutx <= ldq_dout;
        ldq_oenx  <= (others => oen);
        lckex     <= lcke;
        lsnx      <= lsn;
        lwenx     <= lwen;
        lrasnx    <= lrasn;
        lcasnx    <= lcasn;
        ldqmx     <= ldqm;
      end if;
      if rstn = '0' then
        lsnx <= (others => '1');
        for i in ldq_oenx'range loop
          ldq_oenx(i) <= conv_std_logic(padoen_polarity(tech) = 0);
        end loop;
      end if;
    end process;
  end generate;


  gen : if has_sdram_phy(tech) = 0 generate
    -- SDRAM address
    sa_pad : outpadv
      generic map (
        width    => aw,
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength)
      port map (addr, laddrx, cfgi_cmd);
    -- SDRAM data
    sd_pad : iopadvv
      generic map (
        width    => dw,
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength,
        oepol    => padoen_polarity(tech))
      port map (dq, ldq_doutx, ldq_oenx, ldq_dinx, cfgi_dq);
    -- SDRAM clock enable
    sdcke_pad : outpadv
      generic map (
        width    => ncs,
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength)
      port map (cke, lckex, cfgi_cmd);
    -- SDRAM write enable
    sdwen_pad : outpad generic map (
      tech     => tech,
      level    => level,
      voltage  => voltage,
      strength => strength)
      port map (wen, lwenx, cfgi_cmd);
    -- SDRAM chip select
    sdcsn_pad : outpadv
      generic map (
        width    => ncs,
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength)
      port map (sn, lsnx, cfgi_cmd);
    -- SDRAM ras
    sdras_pad : outpad
      generic map (
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength)
      port map (rasn, lrasnx, cfgi_cmd);
    -- SDRAM cas
    sdcas_pad : outpad
      generic map (
        tech     => tech,
        level    => level,
        voltage  => voltage,
        strength => strength)
      port map (casn, lcasnx, cfgi_cmd);
    -- SDRAM dqm
    sddqm_pad : outpadv
      generic map (
        width    => dw/8,
        level    => level,
        voltage  => voltage,
        tech     => tech,
        strength => strength)
      port map (dqm, ldqmx, cfgi_cmd);
  end generate;

  n2x : if (tech = easic45) generate
    phy0 : n2x_sdram_phy
      generic map (
        level => level, voltage => voltage, strength => strength,
        aw => aw, dw => dw, ncs => ncs, reg => reg)
      port map (
        addr, dq, cke, sn, wen, rasn, casn, dqm,
        laddrx, ldq_dinx, ldq_doutx, ldq_oenx, lckex,
        lsnx, lwenx, lrasnx, lcasnx, ldqmx,
        rstn, clk,
        cfgi_cmd, cfgi_dq);
  end generate;

end;

