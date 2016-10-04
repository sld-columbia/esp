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
-- Entity:      serdes
-- File:        serdes.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: SGMII Gigabit Ethernet PMA Physical Media Attachment
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.config.all;
use work.config_types.all;

entity serdes is
  generic (
    fabtech   : integer;
    transtech : integer
  );
  port (
    clk_125     : in std_logic;
    rst_125     : in std_logic;
    rx_in_p     : in std_logic;           -- SER IN
    rx_in_n     : in std_logic;           -- SER IN
    rx_out      : out std_logic_vector(9 downto 0); -- PAR OUT
    rx_clk      : out std_logic;
    rx_rstn     : out std_logic;
    rx_pll_clk  : out std_logic;
    rx_pll_rstn : out std_logic;
    tx_pll_clk  : out std_logic;
    tx_pll_rstn : out std_logic;
    tx_in       : in std_logic_vector(9 downto 0) ; -- PAR IN
    tx_out_p    : out std_logic;          -- SER OUT
    tx_out_n    : out std_logic;          -- SER OUT
    bitslip     : in std_logic;
    -- added for igloo2_serdes
    apbin       : in apb_in_serdes;
    apbout      : out apb_out_serdes;
    m2gl_padin  : in pad_in_serdes;
    m2gl_padout : out pad_out_serdes;
    serdes_clk125 : out std_logic;
    serdes_ready: out std_logic);
end;

architecture rtl of serdes is
  component serdes_stratixiii is
    port (
      clk_125   : in std_logic;
      rst_125   : in std_logic;
      rx_in     : in std_logic;           -- SER IN
      rx_out    : out std_logic_vector(9 downto 0); -- PAR OUT
      rx_clk    : out std_logic;
      rx_rstn   : out std_logic;
      rx_pll_clk  : out std_logic;
      rx_pll_rstn : out std_logic;
      tx_pll_clk  : out std_logic;
      tx_pll_rstn : out std_logic;
      tx_in   : in std_logic_vector(9 downto 0) ; -- PAR IN
      tx_out    : out std_logic;          -- SER OUT
      bitslip   : in std_logic
    );
  end component;

  component igloo2_serdes is
    generic(
      transtech : integer := m010);
    port(
      apb_in : in apb_in_serdes;
      apb_out : out apb_out_serdes;
      insig : in sigin_serdes_type;
      outsig : out sigout_serdes_type;
      padin : in pad_in_serdes;
      padout : out pad_out_serdes);
  end component;

  component rtg4_serdes is
    generic(
      transtech : integer := m010);
    port(
      apb_in : in apb_in_serdes;
      apb_out : out apb_out_serdes;
      insig : in sigin_serdes_type;
      outsig : out sigout_serdes_type;
      padin : in pad_in_serdes;
      padout : out pad_out_serdes);
  end component;

  component serdes_unisim is
    generic (
      transtech : integer
    );
    port (
      clk_125     : in std_logic;
      rst_125     : in std_logic;
      rx_in_p     : in std_logic;           -- SER IN
      rx_in_n     : in std_logic;           -- SER IN
      rx_out      : out std_logic_vector(9 downto 0); -- PAR OUT
      rx_clk      : out std_logic;
      rx_rstn     : out std_logic;
      rx_pll_clk  : out std_logic;
      rx_pll_rstn : out std_logic;
      tx_pll_clk  : out std_logic;
      tx_pll_rstn : out std_logic;
      tx_in       : in std_logic_vector(9 downto 0) ; -- PAR IN
      tx_out_p    : out std_logic;          -- SER OUT
      tx_out_n    : out std_logic;          -- SER OUT
      bitslip     : in std_logic
    );
  end component;

  signal rst_125n, rx_clk_serdes, rx_rstn_serdes, rx_val_serdes, tx_rstn_serdes, tx_clk_lock_serdes, tx_pll_clk_sig, rx_idle, ready_sig : std_logic;
  signal tx_out_p_int : std_logic;

  signal r0, r1 : std_logic_vector(4 downto 0);

begin

  str : if (fabtech = stratix3) or (fabtech = stratix4) generate
    str0 : serdes_stratixiii
      port map (clk_125, rst_125, rx_in_p, rx_out, rx_clk, rx_rstn, rx_pll_clk, rx_pll_rstn, tx_pll_clk, tx_pll_rstn, tx_in, tx_out_p_int, bitslip);
    apbout <= apb_out_serdes_none; m2gl_padout <= pad_out_serdes_none; serdes_clk125 <= '0'; serdes_ready <= '1'; -- not used
    tx_out_n <= not tx_out_p_int; -- not used
    tx_out_p <= tx_out_p_int;
  end generate;

  xilinx : if (fabtech = virtex5) or (fabtech = virtex6) generate
    xil0 : serdes_unisim
      generic map (transtech)
      port map (clk_125, rst_125, rx_in_p, rx_in_n, rx_out, rx_clk, rx_rstn, rx_pll_clk, rx_pll_rstn, tx_pll_clk, tx_pll_rstn, tx_in, tx_out_p, tx_out_n, bitslip);
    apbout <= apb_out_serdes_none; m2gl_padout <= pad_out_serdes_none; serdes_clk125 <= '0'; serdes_ready <= '1'; -- not used
  end generate;

  igl2 : if (fabtech = igloo2) generate

    rst_125n <= not(rst_125); -- used as SERDES macro reset
    
    rx_clk <= rx_clk_serdes;
    rx_pll_clk <= rx_clk_serdes;

    -- reset synchronizers
    rxrst0 : process (rx_clk_serdes, rx_rstn_serdes) begin
    if rising_edge(rx_clk_serdes) then 
      r0 <= r0(3 downto 0) & rx_val_serdes; 
      rx_rstn <= r0(4) and r0(3) and r0(2);
      rx_pll_rstn <= r0(4) and r0(3) and r0(2);
    end if;
    if (rx_rstn_serdes = '0') then r0 <= "00000"; rx_rstn <= '0'; rx_pll_rstn <= '0'; end if;
    end process;

    txrst : process (tx_pll_clk_sig, tx_rstn_serdes) begin
    if rising_edge(tx_pll_clk_sig) then 
      r1 <= r1(3 downto 0) & tx_clk_lock_serdes; 
      tx_pll_rstn <= r1(4) and r1(3) and r1(2);
    end if;
    if (tx_rstn_serdes = '0') then r1 <= "00000"; tx_pll_rstn <= '0'; end if;
    end process;

    tx_out_p <= '0'; -- not used
    tx_out_n <= '0'; -- not used
    tx_pll_clk <= tx_pll_clk_sig;
    
    igl20 : igloo2_serdes
      generic map (transtech)
      port map (
        apb_in => apbin,
        apb_out => apbout,
        padin => m2gl_padin,
        padout => m2gl_padout,
        insig.rstn => rst_125n,
        insig.tx_data => tx_in,
        outsig.ready => ready_sig,  -- not used
        outsig.rx_clk => rx_clk_serdes,
        outsig.rx_data => rx_out,
        outsig.rx_idle => rx_idle,  -- not used
        outsig.rx_rstn => rx_rstn_serdes,
        outsig.rx_val => rx_val_serdes,
        outsig.tx_clk => tx_pll_clk_sig,
        outsig.tx_clk_lock => tx_clk_lock_serdes,
        outsig.tx_rstn => tx_rstn_serdes,
        outsig.refclk => serdes_clk125);

     serdes_ready <= rx_val_serdes;
  end generate;

  rt4 : if (fabtech = rtg4) generate

    rst_125n <= not(rst_125); -- used as SERDES macro reset
    
    rx_clk <= rx_clk_serdes;
    rx_pll_clk <= rx_clk_serdes;

    -- reset synchronizers
    rxrst0 : process (rx_clk_serdes) begin
      if rising_edge(rx_clk_serdes) then 
        r0 <= r0(3 downto 0) & not(rx_idle); 
        rx_rstn <= r0(4) and r0(3) and r0(2);
        rx_pll_rstn <= r0(4) and r0(3) and r0(2);
        if (rx_rstn_serdes = '0') then r0 <= "00000"; rx_rstn <= '0'; rx_pll_rstn <= '0'; end if;
      end if;
    end process;

    txrst : process (tx_pll_clk_sig) begin
      if rising_edge(tx_pll_clk_sig) then 
        r1 <= r1(3 downto 0) & tx_clk_lock_serdes; 
        tx_pll_rstn <= r1(4) and r1(3) and r1(2);
        if (tx_rstn_serdes = '0') then r1 <= "00000"; tx_pll_rstn <= '0'; end if;
      end if;
    end process;

    tx_out_p <= '0'; -- not used
    tx_out_n <= '0'; -- not used
    tx_pll_clk <= tx_pll_clk_sig;
    
    rt40 : rtg4_serdes
      generic map (transtech)
      port map (
        apb_in => apbin,
        apb_out => apbout,
        padin => m2gl_padin,
        padout => m2gl_padout,
        insig.rstn => rst_125n,
        insig.tx_data => tx_in,
        outsig.ready => ready_sig,  -- not used
        outsig.rx_clk => rx_clk_serdes,
        outsig.rx_data => rx_out,
        outsig.rx_idle => rx_idle,
        outsig.rx_rstn => rx_rstn_serdes,
        outsig.rx_val => rx_val_serdes,
        outsig.tx_clk => tx_pll_clk_sig,
        outsig.tx_clk_lock => tx_clk_lock_serdes,
        outsig.tx_rstn => tx_rstn_serdes,
        outsig.refclk => serdes_clk125);

     serdes_ready <= rx_val_serdes;
  end generate;

-- pragma translate_off
  nofifo : if (has_transceivers(fabtech) = 0) generate
    x : process
    begin
      assert false report "serdes: technology " & tech_table(fabtech) &
  " not supported"
      severity failure;
      wait;
    end process;
  end generate;
  dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
    x : process
    begin
      assert false report "serdes: (" & tech_table(fabtech) & ")"
      severity note;
      wait;
    end process;
  end generate;
-- pragma translate_on
  
end;

