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
-- Entity:      gmii_to_mii
-- File:        gmii_to_mii.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: GMII to MII Ethernet bridge
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.net.all;

use work.stdlib.all;
use work.config_types.all;
use work.config.all;

entity gmii_to_mii is
  port (
    tx_rstn : in std_logic;
    rx_rstn : in std_logic;
    -- MAC SIDE
    gmiii   : out eth_in_type;
    gmiio   : in  eth_out_type;
    -- PHY SIDE
    miii    : in  eth_in_type;
    miio    : out eth_out_type
  ) ;
end entity ; -- gmii_to_mii

architecture rtl of gmii_to_mii is
  
  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) /= 0;

  type sgmii_10_100_state_type is (idle, running);

  type sgmii_10_100_rx_type is record
    state   : sgmii_10_100_state_type;
    count   : integer;
    rxd     : std_logic_vector(7 downto 0);
    rx_dv   : std_logic;
    rx_en   : std_logic;
    rx_er   : std_logic;
  end record; 

  type sgmii_10_100_tx_type is record
    state       : sgmii_10_100_state_type;
    count       : integer;
    txd_part    : std_logic_vector(3 downto 0);
    txd         : std_logic_vector(7 downto 0);
    tx_dv       : std_logic;
    tx_er       : std_logic;
    tx_er_part  : std_logic;
    tx_en       : std_logic;
  end record;

  constant RES_RX : sgmii_10_100_rx_type := (
    state   => idle,
    count   => 0,
    rxd     => (others => '0'),
    rx_dv   => '0',
    rx_en   => '0',
    rx_er   => '0'
    );

  constant RES_TX : sgmii_10_100_tx_type := (
    state       => idle,
    count       => 0,
    txd_part    => (others => '0'),
    txd         => (others => '0'),
    tx_dv       => '0',
    tx_er       => '0',
    tx_er_part  => '0',
    tx_en       => '0'
    );

  signal r_rx, rin_rx : sgmii_10_100_rx_type;
  signal r_tx, rin_tx : sgmii_10_100_tx_type;
  signal rx_dv_int, rx_er_int, rx_col_int, rx_crs_int, tx_en_int, tx_er_int, tx_dv_int, rx_en_int : std_logic;
  signal rxd_int, txd_int : std_logic_vector(7 downto 0);
begin

  tx_10_100 : process(tx_rstn, r_tx, gmiio)
    variable v_tx : sgmii_10_100_tx_type;
  begin
    v_tx := r_tx;
    v_tx.tx_dv := '0';
    tx_dv_int <= '1';

    case r_tx.state is
      when idle =>
        if gmiio.tx_en = '1' and gmiio.gbit = '0' then
          v_tx.state := running;
          v_tx.count := 0;
          tx_dv_int <= '0';
        end if;
      when running =>
       -- increment counter for 10/100 sampling
        if (r_tx.count >= 9 and gmiio.speed = '1') or (r_tx.count >= 99 and gmiio.speed = '0') then
          v_tx.count := 0;
        else
          v_tx.count := r_tx.count + 1;
        end if;

        -- sample appropriately according to 10/100 settings
        case r_tx.count is
          when 0 =>
            v_tx.txd_part := gmiio.txd(3 downto 0);
            v_tx.tx_er_part  := gmiio.tx_er;
            v_tx.tx_dv := gmiio.tx_en;
          when 5 =>
            if gmiio.speed = '1' then
              v_tx.txd := gmiio.txd(3 downto 0) & r_tx.txd_part;
              v_tx.tx_er := r_tx.tx_er_part or gmiio.tx_er;
              v_tx.tx_dv := gmiio.tx_en;
              v_tx.tx_en := gmiio.tx_en;
              -- exit condition
              if gmiio.tx_en = '0' then
                v_tx.state := idle;
                v_tx.tx_en := '0';
              end if;
            end if;
          when 50 =>
            if gmiio.speed = '0' then
              v_tx.txd := gmiio.txd(3 downto 0) & r_tx.txd_part;
              v_tx.tx_er := r_tx.tx_er_part or gmiio.tx_er;
              v_tx.tx_dv := gmiio.tx_en;
              v_tx.tx_en := gmiio.tx_en;
              -- exit condition
              if gmiio.tx_en = '0' then
                v_tx.state := idle;
                v_tx.tx_en := '0';
              end if;
            end if;
          when others =>
        end case ;

        tx_dv_int <= r_tx.tx_dv;
      when others =>
    end case ;

    -- reset operation
    if (not RESET_ALL) and (tx_rstn = '0') then
       v_tx := RES_TX;
    end if;

    rin_tx <= v_tx;
  end process ;

  tx_regs : process(miii.gtx_clk, tx_rstn)
  begin
    if rising_edge(miii.gtx_clk) then
      r_tx <= rin_tx;
      if RESET_ALL and tx_rstn = '0' then
         r_tx <= RES_TX;
      end if;
    end if;
  end process;
  
  miio.reset    <= gmiio.reset;
  miio.txd      <= gmiio.txd    when gmiio.gbit = '1' else r_tx.txd;
  miio.tx_en    <= gmiio.tx_en  when gmiio.gbit = '1' else r_tx.tx_en;
  miio.tx_er    <= gmiio.tx_er  when gmiio.gbit = '1' else r_tx.tx_er;
  miio.tx_clk   <= gmiio.tx_clk;
  miio.mdc      <= gmiio.mdc;
  miio.mdio_o   <= gmiio.mdio_o;
  miio.mdio_oe  <= gmiio.mdio_oe;
  miio.gbit     <= gmiio.gbit;
  miio.speed    <= gmiio.speed;

  process (rx_rstn, r_rx, miii, gmiio)
    variable v_rx  : sgmii_10_100_rx_type;
  begin
    v_rx := r_rx;
    v_rx.rx_en := '0';
    rx_en_int <= '1';

    case r_rx.state is
      when idle =>
        if miii.rx_dv = '1' and gmiio.gbit = '0' then
          v_rx.state := running;
          v_rx.count := 0;
          rx_en_int <= '0';
        end if;
      when running =>
        -- increment counter for 10/100 sampling
        if (r_rx.count >= 9 and gmiio.speed = '1') or (r_rx.count >= 99 and gmiio.speed = '0') then
          v_rx.count := 0;
        else
          v_rx.count := r_rx.count + 1;
        end if;

        -- sample appropriately according to 10/100 settings
        case r_rx.count is
          when 0 =>
            v_rx.rxd    := miii.rxd(3 downto 0) &  miii.rxd(3 downto 0);
            v_rx.rx_en  := miii.rx_dv;
            v_rx.rx_dv  := miii.rx_dv;
            v_rx.rx_er  := miii.rx_er;
            -- exit condition
            if miii.rx_dv = '0' then
              v_rx.state := idle;
              v_rx.rx_dv := '0';
            end if;
          when 5  =>
            if gmiio.speed = '1' then
              v_rx.rxd   := miii.rxd(7 downto 4) &  miii.rxd(7 downto 4);
              v_rx.rx_en := '1';
            end if;
          when 50 =>
            if gmiio.speed = '0' then
              v_rx.rxd   := miii.rxd(7 downto 4) &  miii.rxd(7 downto 4);
              v_rx.rx_en := '1';
            end if;
          when others =>
        end case ;
        rx_en_int <= r_rx.rx_en;
      when others =>
    end case ;

    -- reset operation
    if (not RESET_ALL) and (rx_rstn = '0') then
       v_rx := RES_RX;
    end if;

    -- update registers
    rin_rx <= v_rx;
  end process;


  rx_regs : process(miii.rx_clk, rx_rstn)
  begin
    if rising_edge(miii.rx_clk) then
      r_rx <= rin_rx;
      if RESET_ALL and rx_rstn = '0' then
        r_rx <= RES_RX;
      end if;
    end if;
  end process;

---- RX Mux Select


  gmiii.gtx_clk     <= miii.gtx_clk;
  gmiii.rmii_clk    <= miii.rmii_clk;
  gmiii.tx_clk      <= miii.tx_clk;
  gmiii.tx_clk_90   <= miii.tx_clk_90;
  gmiii.tx_dv       <= '1'          when gmiio.gbit = '1' else tx_dv_int;
  gmiii.rx_clk      <= miii.rx_clk;
  gmiii.rxd         <= miii.rxd     when gmiio.gbit = '1' else r_rx.rxd;
  gmiii.rx_dv       <= miii.rx_dv   when gmiio.gbit = '1' else r_rx.rx_dv;
  gmiii.rx_er       <= miii.rx_er   when gmiio.gbit = '1' else r_rx.rx_er;
  gmiii.rx_en       <= '1'          when gmiio.gbit = '1' else rx_en_int;
  gmiii.rx_col      <= miii.rx_col  when gmiio.gbit = '1' else r_rx.rx_dv and gmiio.tx_en; -- possible clock cross domain problem
  gmiii.rx_crs      <= miii.rx_crs  when gmiio.gbit = '1' else r_rx.rx_dv or  gmiio.tx_en;
  gmiii.mdio_i      <= miii.mdio_i;
  gmiii.mdint       <= miii.mdint;
  gmiii.phyrstaddr  <= miii.phyrstaddr;
  gmiii.edcladdr    <= miii.edcladdr;
  gmiii.edclsepahb  <= miii.edclsepahb;
  gmiii.edcldisable <= miii.edcldisable;
end architecture;
