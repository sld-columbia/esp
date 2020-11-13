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
-- Entity:      various
-- File:        memory_unisim.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Memory generators for Xilinx RAMs
------------------------------------------------------------------------------

-- parametrisable sync ram generator using UNISIM RAMB16 block rams

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
library unisim;
use unisim.vcomponents.RAMB16_S36_S36;
use unisim.vcomponents.RAMB16_S36;
use unisim.vcomponents.RAMB16_S18;
use unisim.vcomponents.RAMB16_S9;
use unisim.vcomponents.RAMB16_S4;
use unisim.vcomponents.RAMB16_S2;
use unisim.vcomponents.RAMB16_S1;

entity unisim_syncram is
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end;

architecture behav of unisim_syncram is
  component generic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic);
  end component;

signal gnd : std_ulogic;
signal do, di : std_logic_vector(dbits+72 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin
  gnd <= '0'; dataout <= do(dbits-1 downto 0); di(dbits-1 downto 0) <= datain;
  di(dbits+72 downto dbits) <= (others => '0'); xa(abits-1 downto 0) <= address;
  xa(19 downto abits) <= (others => '0'); ya(abits-1 downto 0) <= address;
  ya(19 downto abits) <= (others => '1');

  a0 : if (abits <= 5) and (GRLIB_CONFIG_ARRAY(grlib_techmap_strict_ram) = 0) generate
    r0 : generic_syncram generic map (abits, dbits)
         port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

  a8 : if ((abits > 5 or GRLIB_CONFIG_ARRAY(grlib_techmap_strict_ram) /= 0) and
           (abits <= 8)) generate
    x : for i in 0 to ((dbits-1)/72) generate
      r0 : RAMB16_S36_S36
        generic map (SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do(i*72+36+31 downto i*72+36), do(i*72+31 downto i*72),
          do(i*72+36+32+3 downto i*72+36+32), do(i*72+32+3 downto i*72+32),
          xa(8 downto 0), ya(8 downto 0), clk, clk,
          di(i*72+36+31 downto i*72+36), di(i*72+31 downto i*72),
          di(i*72+36+32+3 downto i*72+36+32), di(i*72+32+3 downto i*72+32),
          enable, enable, gnd, gnd, write, write);
    end generate;
    do(dbits+72 downto 72*(((dbits-1)/72)+1)) <= (others => '0');
  end generate;
  a9 : if (abits = 9) generate
    x : for i in 0 to ((dbits-1)/36) generate
      r : RAMB16_S36 port map ( do(((i+1)*36)-5 downto i*36),
        do(((i+1)*36)-1 downto i*36+32), xa(8 downto 0), clk,
        di(((i+1)*36)-5 downto i*36), di(((i+1)*36)-1 downto i*36+32),
        enable, gnd, write);
    end generate;
    do(dbits+72 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
  end generate;
  a10 : if (abits = 10) generate
    x : for i in 0 to ((dbits-1)/18) generate
      r : RAMB16_S18 port map ( do(((i+1)*18)-3 downto i*18),
        do(((i+1)*18)-1 downto i*18+16), xa(9 downto 0), clk,
        di(((i+1)*18)-3 downto i*18), di(((i+1)*18)-1 downto i*18+16),
        enable, gnd, write);
    end generate;
    do(dbits+72 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
  end generate;
  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r : RAMB16_S9 port map ( do(((i+1)*9)-2 downto i*9),
        do(((i+1)*9)-1 downto i*9+8), xa(10 downto 0), clk,
        di(((i+1)*9)-2 downto i*9), di(((i+1)*9)-1 downto i*9+8),
        enable, gnd, write);
    end generate;
    do(dbits+72 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
  end generate;
  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r : RAMB16_S4 port map ( do(((i+1)*4)-1 downto i*4), xa(11 downto 0),
        clk, di(((i+1)*4)-1 downto i*4), enable, gnd, write);
    end generate;
    do(dbits+72 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
  end generate;
  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r : RAMB16_S2 port map ( do(((i+1)*2)-1 downto i*2), xa(12 downto 0),
        clk, di(((i+1)*2)-1 downto i*2), enable, gnd, write);
    end generate;
    do(dbits+72 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
  end generate;
  a14 : if abits = 14 generate
    x : for i in 0 to (dbits-1) generate
      r : RAMB16_S1 port map ( do((i+1)-1 downto i), xa(13 downto 0),
        clk, di((i+1)-1 downto i), enable, gnd, write);
    end generate;
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

  a15 : if abits > 14 generate
    x: generic_syncram generic map (abits, dbits)
      port map (clk, address, datain, do(dbits-1 downto 0), write);
    do(dbits+72 downto dbits) <= (others => '0');
  end generate;

-- pragma translate_off
--  a_to_high : if abits > 14 generate
--    x : process
--    begin
--      assert false
--      report  "Address depth larger than 14 not supported for unisim_syncram"
--      severity failure;
--      wait;
--    end process;
--  end generate;
-- pragma translate_on

end;

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.RAMB16_S36_S36;
use unisim.vcomponents.RAMB16_S18_S18;
use unisim.vcomponents.RAMB16_S9_S9;
use unisim.vcomponents.RAMB16_S4_S4;
use unisim.vcomponents.RAMB16_S2_S2;
use unisim.vcomponents.RAMB16_S1_S1;

entity unisim_syncram_dp is
  generic (
    abits : integer := 4; dbits : integer := 32
  );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic);
end;

architecture behav of unisim_syncram_dp is


signal gnd, vcc : std_ulogic;
signal do1, do2, di1, di2 : std_logic_vector(dbits+36 downto 0);
signal addr1, addr2 : std_logic_vector(19 downto 0);
signal ce1, ce2 : std_logic_vector(63 downto 0);
signal we1, we2 : std_logic_vector(63 downto 0);
signal ce1_idx, ce2_idx : integer range 63 downto 0;
signal ce1_idx_r, ce2_idx_r : integer range 63 downto 0;
type dout_vector_type is array (63 downto 0) of std_logic_vector(dbits+36 downto 0);
signal do1v, do2v : dout_vector_type;

subtype qword is std_logic_vector(dbits+36 downto 0);
type qqtype is array (0 to 3) of qword;
signal qq1 : qqtype;
signal qq2 : qqtype;
signal enable1_t, write1_t : std_logic_vector(3 downto 0);
signal enable2_t, write2_t : std_logic_vector(3 downto 0);
signal ra1, ra2 : std_logic_vector(15 downto 14);

begin
  gnd <= '0'; vcc <= '1';
  dataout1 <= do1(dbits-1 downto 0); dataout2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= datain1; di1(dbits+36 downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain2; di2(dbits+36 downto dbits) <= (others => '0');
  addr1(abits-1 downto 0) <= address1; addr1(19 downto abits) <= (others => '0');
  addr2(abits-1 downto 0) <= address2; addr2(19 downto abits) <= (others => '0');

  a9 : if abits <= 9 generate
    x : for i in 0 to ((dbits-1)/36) generate
      r0 : RAMB16_S36_S36
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*36)-5 downto i*36), do2(((i+1)*36)-5 downto i*36),
          do1(((i+1)*36)-1 downto i*36+32), do2(((i+1)*36)-1 downto i*36+32),
          addr1(8 downto 0), addr2(8 downto 0), clk1, clk2,
          di1(((i+1)*36)-5 downto i*36), di2(((i+1)*36)-5 downto i*36),
          di1(((i+1)*36)-1 downto i*36+32), di2(((i+1)*36)-1 downto i*36+32),
          enable1, enable2, gnd, gnd, write1, write2);
--          vcc, vcc, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
    do2(dbits+36 downto 36*(((dbits-1)/36)+1)) <= (others => '0');
  end generate;

  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/18) generate
      r0 : RAMB16_S18_S18
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*18)-3 downto i*18), do2(((i+1)*18)-3 downto i*18),
          do1(((i+1)*18)-1 downto i*18+16), do2(((i+1)*18)-1 downto i*18+16),
          addr1(9 downto 0), addr2(9 downto 0), clk1, clk2,
          di1(((i+1)*18)-3 downto i*18), di2(((i+1)*18)-3 downto i*18),
          di1(((i+1)*18)-1 downto i*18+16), di2(((i+1)*18)-1 downto i*18+16),
--          vcc, vcc, gnd, gnd, write1, write2);
          enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
    do2(dbits+36 downto 18*(((dbits-1)/18)+1)) <= (others => '0');
  end generate;

  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r0 : RAMB16_S9_S9
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*9)-2 downto i*9), do2(((i+1)*9)-2 downto i*9),
          do1(((i+1)*9)-1 downto i*9+8), do2(((i+1)*9)-1 downto i*9+8),
          addr1(10 downto 0), addr2(10 downto 0), clk1, clk2,
          di1(((i+1)*9)-2 downto i*9), di2(((i+1)*9)-2 downto i*9),
          di1(((i+1)*9)-1 downto i*9+8), di2(((i+1)*9)-1 downto i*9+8),
--          vcc, vcc, gnd, gnd, write1, write2);
          enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
    do2(dbits+36 downto 9*(((dbits-1)/9)+1)) <= (others => '0');
  end generate;

  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r0 : RAMB16_S4_S4
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*4)-1 downto i*4), do2(((i+1)*4)-1 downto i*4),
          addr1(11 downto 0), addr2(11 downto 0), clk1, clk2,
          di1(((i+1)*4)-1 downto i*4), di2(((i+1)*4)-1 downto i*4),
--          vcc, vcc, gnd, gnd, write1, write2);
          enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
    do2(dbits+36 downto 4*(((dbits-1)/4)+1)) <= (others => '0');
  end generate;

  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r0 : RAMB16_S2_S2
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*2)-1 downto i*2), do2(((i+1)*2)-1 downto i*2),
          addr1(12 downto 0), addr2(12 downto 0), clk1, clk2,
          di1(((i+1)*2)-1 downto i*2), di2(((i+1)*2)-1 downto i*2),
--          vcc, vcc, gnd, gnd, write1, write2);
          enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
    do2(dbits+36 downto 2*(((dbits-1)/2)+1)) <= (others => '0');
  end generate;

  a14 : if abits = 14 generate
    x : for i in 0 to ((dbits-1)/1) generate
      r0 : RAMB16_S1_S1
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
          do1(((i+1)*1)-1 downto i*1), do2(((i+1)*1)-1 downto i*1),
          addr1(13 downto 0), addr2(13 downto 0), clk1, clk2,
          di1(((i+1)*1)-1 downto i*1), di2(((i+1)*1)-1 downto i*1),
--          vcc, vcc, gnd, gnd, write1, write2);
          enable1, enable2, gnd, gnd, write1, write2);
    end generate;
    do1(dbits+36 downto dbits) <= (others => '0');
    do2(dbits+36 downto dbits) <= (others => '0');
  end generate;

  a15a16 : if abits >= 15 and abits <= 16 generate
    y : for j in 0 to (2**(abits-14))-1 generate
      enable1_t(j) <= '1' when ((enable1 = '1') and (conv_integer(addr1(15 downto 14)) = j)) else '0';
      write1_t(j)  <= '1' when ((write1 = '1') and (conv_integer(addr1(15 downto 14)) = j)) else '0';
      enable2_t(j) <= '1' when ((enable2 = '1') and (conv_integer(addr2(15 downto 14)) = j)) else '0';
      write2_t(j)  <= '1' when ((write2 = '1') and (conv_integer(addr2(15 downto 14)) = j)) else '0';
      x : for i in 0 to ((dbits-1)/1) generate
        r0 : RAMB16_S1_S1
          generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
          port map (
            qq1(j)(((i+1)*1)-1 downto i*1), qq2(j)(((i+1)*1)-1 downto i*1),
            addr1(13 downto 0), addr2(13 downto 0), clk1, clk2,
            di1(((i+1)*1)-1 downto i*1), di2(((i+1)*1)-1 downto i*1),
            enable1_t(j), enable2_t(j), gnd, gnd, write1_t(j), write2_t(j));
      end generate;
    end generate;
    do1(dbits-1 downto 0) <= qq1(conv_integer(ra1(15 downto 14)))(dbits-1 downto 0);
    do2(dbits-1 downto 0) <= qq2(conv_integer(ra2(15 downto 14)))(dbits-1 downto 0);
    regs1 : process(clk1)
    begin
      if rising_edge(clk1) then
        ra1(15 downto 14) <= addr1(15 downto 14);
      end if;
    end process;
    regs2 : process(clk2)
    begin
      if rising_edge(clk2) then
        ra2(15 downto 14) <= addr2(15 downto 14);
      end if;
    end process;
    do1(dbits+36 downto dbits) <= (others => '0');
    do2(dbits+36 downto dbits) <= (others => '0');
  end generate;

  agt16 : if abits > 16 generate
    ce1_r: process (clk1)
    begin  -- process ce1_r
      if clk1'event and clk1 = '1' then  -- rising clock edge
        ce1_idx_r <= ce1_idx;
      end if;
    end process ce1_r;
    ce2_r: process (clk2)
    begin  -- process ce2_r
      if clk2'event and clk2 = '1' then  -- rising clock edge
        ce2_idx_r <= ce2_idx;
      end if;
    end process ce2_r;

    do1 <= do1v(ce1_idx_r);
    do2 <= do2v(ce2_idx_r);

    out_mux: process (addr1, addr2, ce1, ce2, ce1_idx_r, ce2_idx_r)
    begin  -- process out_mus
      ce1_idx <= ce1_idx_r;
      ce2_idx <= ce2_idx_r;
      for j in 2**(abits-14)-1 downto 0 loop
        if ce1(j) = '1' then
          ce1_idx <= j;
        end if;
        if ce2(j) = '1' then
          ce2_idx <= j;
        end if;
      end loop;  -- j
    end process out_mux;

    no_ce : for j in 63 downto (2**(abits-14)) generate
      ce1(j) <= '0';
      ce2(j) <= '0';
      do1v(j) <= (others => '0');
      do2v(j) <= (others => '0');
    end generate;

    y : for j in (2**(abits-14)-1) downto 0 generate
      chip_enable: process (enable1, enable2, addr1, addr2)
      begin  -- process chip_enable
        if (conv_integer(addr1(abits-1 downto 14)) = j) then
          ce1(j) <= enable1;
        else
          ce1(j) <= '0';
        end if;
        if (conv_integer(addr2(abits-1 downto 14)) = j) then
          ce2(j) <= enable2;
        else
          ce2(j) <= '0';
        end if;
      end process chip_enable;

      x : for i in 0 to ((dbits-1)/1) generate
        r0 : RAMB16_S1_S1
          generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
          port map (
            do1v(j)(((i+1)*1)-1 downto i*1), do2v(j)(((i+1)*1)-1 downto i*1),
            addr1(13 downto 0), addr2(13 downto 0), clk1, clk2,
            di1(((i+1)*1)-1 downto i*1), di2(((i+1)*1)-1 downto i*1),
--	vcc, vcc, gnd, gnd, write1, write2);
            ce1(j), ce2(j), gnd, gnd, write1, write2);
      end generate;
      do1v(j)(dbits+36 downto dbits) <= (others => '0');
      do2v(j)(dbits+36 downto dbits) <= (others => '0');

    end generate;
  end generate;


-- pragma translate_off
  a_to_high : if abits > 20 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 20 not supported for unisim_syncram_dp"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;

entity unisim_syncram_2p is
  generic (abits : integer := 6; dbits : integer := 8; sepclk : integer := 0;
		 wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
end;

architecture behav of unisim_syncram_2p is

  component unisim_syncram_dp
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   ); 
  end component;

component generic_syncram_2p
  generic (abits : integer := 8; dbits : integer := 32; sepclk : integer := 0);
  port (
    rclk : in std_ulogic;
    wclk : in std_ulogic;
    rdaddress: in std_logic_vector (abits -1 downto 0);
    wraddress: in std_logic_vector (abits -1 downto 0);
    data: in std_logic_vector (dbits -1 downto 0);
    wren : in std_ulogic;
    q: out std_logic_vector (dbits -1 downto 0)
  );
end component;

signal write2, renable2 : std_ulogic;
signal datain2 : std_logic_vector((dbits-1) downto 0); 
begin

--    nowf: if wrfst = 0 generate 
      write2 <= '0'; renable2 <= renable; datain2 <= (others => '0');
--    end generate;
    
--    wf : if wrfst = 1 generate
--      write2 <= '0' when (waddress /= raddress) else write;
--      renable2 <= renable or write2; datain2 <= datain;
--    end generate;

    a0 : if abits <= 5 and GRLIB_CONFIG_ARRAY(grlib_techmap_strict_ram) = 0 generate
      x0 :  generic_syncram_2p generic map (abits, dbits, sepclk)
  	port map (rclk, wclk, raddress, waddress, datain, write, dataout);
    end generate;

    a6 : if abits > 5 or GRLIB_CONFIG_ARRAY(grlib_techmap_strict_ram) /= 0 generate
      x0 : unisim_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, datain2, dataout, renable2, write2);
    end generate;
end;

-- parametrisable sync ram generator using unisim block rams

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.RAMB16_S36_S36;

entity unisim_syncram64 is
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
end;

architecture behav of unisim_syncram64 is
component unisim_syncram
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end component;

signal gnd : std_logic_vector(3 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin

  gnd <= "0000"; 
  xa(abits-1 downto 0) <= address; xa(19 downto abits) <= (others => '0');
  ya(abits-1 downto 0) <= address; ya(19 downto abits) <= (others => '1');

  a8 : if abits <= 8 generate
    r0 : RAMB16_S36_S36
      generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
      port map (
	dataout(63 downto 32), dataout(31 downto 0), open, open,
	xa(8 downto 0), ya(8 downto 0), clk, clk,
	datain(63 downto 32), datain(31 downto 0), gnd, gnd,
	enable(1), enable(0), gnd(0), gnd(0), write(1), write(0));
  end generate;
  a9 : if abits > 8 generate
    x1 : unisim_syncram generic map ( abits, 32)
         port map (clk, address, datain(63 downto 32), dataout(63 downto 32),
	           enable(1), write(1));
    x2 : unisim_syncram generic map ( abits, 32)
         port map (clk, address, datain(31 downto 0), dataout(31 downto 0),
	           enable(0), write(0));
  end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity unisim_syncram128 is
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (3 downto 0);
    write   : in  std_logic_vector (3 downto 0)
  );
end;
architecture behav of unisim_syncram128 is
  component unisim_syncram64 is
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (63 downto 0);
    dataout : out std_logic_vector (63 downto 0);
    enable  : in  std_logic_vector (1 downto 0);
    write   : in  std_logic_vector (1 downto 0)
  );
  end component;
begin
    x0 : unisim_syncram64 generic map (abits)
         port map (clk, address, datain(127 downto 64), dataout(127 downto 64),
	           enable(3 downto 2), write(3 downto 2));
    x1 : unisim_syncram64 generic map (abits)
         port map (clk, address, datain(63 downto 0), dataout(63 downto 0),
	           enable(1 downto 0), write(1 downto 0));
end;

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.RAMB16_S9_S9;

entity unisim_syncram128bw is
  generic ( abits : integer := 9);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (127 downto 0);
    dataout : out std_logic_vector (127 downto 0);
    enable  : in  std_logic_vector (15 downto 0);
    write   : in  std_logic_vector (15 downto 0)
  );
end;

architecture behav of unisim_syncram128bw is
component unisim_syncram
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_ulogic;
    write   : in std_ulogic
  );
end component;

signal gnd : std_logic_vector(3 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin

  gnd <= "0000"; 
  xa(abits-1 downto 0) <= address; xa(19 downto abits) <= (others => '0');
  ya(abits-1 downto 0) <= address; ya(19 downto abits) <= (others => '1');

  a11 : if abits <= 10 generate
    x0 : for i in 0 to 7 generate
      r0 : RAMB16_S9_S9
        generic map(SIM_COLLISION_CHECK => "GENERATE_X_ONLY")
        port map (
	dataout(i*8+7+64 downto i*8+64), dataout(i*8+7 downto i*8), open, open,
	xa(10 downto 0), ya(10 downto 0), clk, clk,
	datain(i*8+7+64 downto i*8+64), datain(i*8+7 downto i*8), gnd(0 downto 0), gnd(0 downto 0),
	enable(i+8), enable(i), gnd(0), gnd(0), write(i+8), write(i));
    end generate;
  end generate;
  a12 : if abits > 10 generate
    x0 : for i in 0 to 15 generate
      x2 : unisim_syncram generic map ( abits, 8)
         port map (clk, address, datain(i*8+7 downto i*8),
	      dataout(i*8+7 downto i*8), enable(i), write(i));
    end generate;
  end generate;
end;

-------------------------
-- unisim_syncram with byte enable

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.config_types.all;
use work.config.all;
library unisim;
use unisim.vcomponents.RAMB16_S9_S9;

entity unisim_syncram_be is
  generic ( abits : integer := 9; dbits : integer := 32; tech : integer := 0);
  port (
    clk     : in std_ulogic;
    address : in std_logic_vector (abits -1 downto 0);
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_logic_vector (dbits/8-1 downto 0);
    write   : in std_logic_vector(dbits/8-1 downto 0)
  );
end;

architecture behav of unisim_syncram_be is

  component generic_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    write    : in std_ulogic);
  end component;

  component unisim_sram_b_6abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(5 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(5 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_6abits;

  component unisim_sram_b_7abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(6 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(6 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_7abits;

  component unisim_sram_b_8abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(7 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(7 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_8abits;

  component unisim_sram_b_9abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(8 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(8 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_9abits;

  component unisim_sram_b_10abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(9 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(9 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_10abits;

  component unisim_sram_b_11abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(10 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(10 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_11abits;

  component unisim_sram_b_12abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(11 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(11 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_12abits;

  component unisim_sram_b_13abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(12 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(12 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_13abits;

  component unisim_sram_b_14abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(13 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(13 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_14abits;

  component unisim_sram_b_15abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(14 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(14 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_15abits;

  component unisim_sram_b_16abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(15 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(15 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_16abits;

  component unisim_sram_b_17abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(16 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(16 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_17abits;

  component unisim_sram_b_18abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(17 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(17 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_18abits;

  component unisim_sram_b_19abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(18 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(18 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_19abits;

  component unisim_sram_b_20abits is
    port (
      CLK : in std_ulogic;
      CE0 : in std_ulogic;
      A0  : in std_logic_vector(19 downto 0);
      D0  : in std_logic_vector(7 downto 0);
      WE0 : in std_ulogic;
      WEM0 : in std_logic_vector(7 downto 0);
      CE1 : in std_ulogic;
      A1  : in std_logic_vector(19 downto 0);
      Q1  : out std_logic_vector(7 downto 0)
      );
  end component unisim_sram_b_20abits;

signal gnd : std_ulogic;
signal do, di : std_logic_vector(dbits+8 downto 0);
signal xa : std_logic_vector(19 downto 0);
signal xrden : std_logic_vector (dbits/8-1 downto 0);
signal xwren : std_logic_vector (dbits/8-1 downto 0);

begin
  gnd <= '0';
  dataout <= do(dbits-1 downto 0);
  di(dbits-1 downto 0) <= datain;
  di(dbits+8 downto dbits) <= (others => '0');

  a0 : if abits <= 5 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r : generic_syncram generic map (abits, 8)
        port map (clk, address, di(i*8+8-1 downto i*8), do(i*8+8-1 downto i*8), write(i));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  xa(19 downto abits) <= (others => '0');
  xa(abits-1 downto 0) <= address;
  xrden <= enable and (not write);
  xwren <= enable and write;

  a6 : if abits = 6 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_6abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(5 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(5 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a7 : if abits = 7 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_7abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(6 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(6 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a8 : if abits = 8 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_8abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(7 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(7 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a9 : if abits = 9 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_9abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(8 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(8 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_10abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(9 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(9 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_11abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(10 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(10 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_12abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(11 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(11 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_13abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(12 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(12 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a14 : if abits = 14 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_14abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(13 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(13 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a15 : if abits = 15 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_15abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(14 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(14 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a16 : if abits = 16 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_16abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(15 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(15 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a17 : if abits = 17 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_17abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(16 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(16 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a18 : if abits = 18 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_18abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(17 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(17 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a19 : if abits = 19 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_19abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(18 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(18 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;

  a20 : if abits = 20 generate
    x : for i in 0 to ((dbits-1)/8) generate
      r0 : unisim_sram_b_20abits
        port map (
          CLK  => clk,
          CE0  => xwren(i),
          A0   => xa(19 downto 0),
          D0   => di(i*8+8-1 downto i*8),
          WE0  => write(i),
          WEM0 => x"ff",
          CE1  => xrden(i),
          A1   => xa(19 downto 0),
          Q1   => do(i*8+8-1 downto i*8));
    end generate;
    do(dbits+8 downto 8*(((dbits-1)/8)+1)) <= (others => '0');
  end generate;



  -- pragma translate_off
  a_to_high : if abits > 20 generate
    x : process
    begin
      assert false
        report  "Address depth larger than 20 not supported for unisim_syncram_be"
        severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;
