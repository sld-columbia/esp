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
-- Entity: 	rgmii
-- File:	rgmii.vhd
-- Author:	Fredrik Ringhage - Aeroflex Gaisler
-- Description: GMII to RGMII interface
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.net.all;
use work.misc.all;

use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.allclkgen.all;

use work.grethpkg.all;

entity rgmii is
  generic (
    pindex         : integer := 0;
    paddr          : integer := 0;
    pmask          : integer := 16#fff#;
    tech           : integer := 0;
    gmii           : integer := 0;
    debugmem       : integer := 0;
    abits          : integer := 8;
    no_clk_mux     : integer := 0;
    pirq           : integer := 0;
    use90degtxclk  : integer := 0;
    mode100        : integer := 0
    );
  port (
    rstn     : in  std_ulogic;
    gmiii    : out eth_in_type;
    gmiio    : in  eth_out_type;
    rgmiii   : in  eth_in_type;
    rgmiio   : out eth_out_type;
    -- APB Status bus
    apb_clk  : in    std_logic;
    apb_rstn : in    std_logic;
    apbi     : in    apb_slv_in_type;
    apbo     : out   apb_slv_out_type
    );
end ;

architecture rtl of rgmii is

  constant REVISION : integer := 1;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_RGMII, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask));

  type status_vector_type is array(1 downto 0) of std_logic_vector(15 downto 0);

  type rgmiiregs is record
    clk25_wrap          :  unsigned(5 downto 0);
    clk25_first_edge    :  unsigned(5 downto 0);
    clk25_second_edge   :  unsigned(5 downto 0);
    clk2_5_wrap         :  unsigned(5 downto 0);
    clk2_5_first_edge   :  unsigned(5 downto 0);
    clk2_5_second_edge  :  unsigned(5 downto 0);
    irq                 :  std_logic_vector(15 downto 0); -- interrupt
    mask                :  std_logic_vector(15 downto 0); -- interrupt enable
    clkedge             :  std_logic_vector(23 downto 0);
    rxctrl_q1_delay     :  std_logic_vector(1 downto 0);
    rxctrl_q2_delay     :  std_logic_vector(1 downto 0);
    rxctrl_q1_sel       :  std_logic;
    rxctrl_delay        :  std_logic;
    rxctrl_c_delay      :  std_logic;
    status_vector       :  status_vector_type;
  end record;

  -- Global signal
  signal vcc, gnd : std_ulogic;
  signal tx_en, tx_ctl : std_ulogic;
  signal txd : std_logic_vector(7 downto 0);
  signal rxd, rxd_pre, rxd_int, rxd_int0, rxd_int1, rxd_int2,rxd_q1,rxd_q2 : std_logic_vector(7 downto 0);
  signal rx_clk, nrx_clk : std_ulogic;
  signal rx_dv, rx_dv_pre, rx_dv_int, rx_dv0 , rx_ctl, rx_ctl_pre, rx_ctl_int, rx_ctl0, rx_error : std_logic;
  signal rx_dv_int0, rx_dv_int1, rx_dv_int2 : std_logic;
  signal rx_ctl_int0, rx_ctl_int1, rx_ctl_int2 : std_logic;
  signal clk50i, clk50d, clk25i, clk25ni, clk2_5i, clk2_5ni : std_ulogic;
  signal txp, txn, txp_sync, txn_sync, tx_clk_ddr, tx_clk, tx_clki, ntx_clk : std_ulogic;
  signal cnt2_5, cnt25 : unsigned(5 downto 0);
  signal rsttxclkn,rsttxclk,rsttxclk90n,rsttxclk90 : std_logic;

  -- RGMII Inband status signals
  signal inbandopt,inbandreq  : std_logic;
  signal link_status          : std_logic;
  signal clock_speed          : std_logic_vector(1 downto 0);
  signal duplex_status        : std_logic;
  signal false_carrier_ind    : std_logic;
  signal carrier_ext          : std_logic;
  signal carrier_ext_error    : std_logic;
  signal carrier_sense        : std_logic;

  -- Status signals and Clock domain crossing
  signal line_status_vector : std_logic_vector(3 downto 0);
  signal status_vector      : std_logic_vector(15 downto 0);
  signal status_vector_sync : std_logic_vector(15 downto 0);

  -- APB and RGMII control register
  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  --  notech default settings
  constant RES : rgmiiregs :=
  ( clk25_wrap  => to_unsigned(4,6),  clk25_first_edge  => to_unsigned(1,6),  clk25_second_edge  => to_unsigned(2,6),
    clk2_5_wrap => to_unsigned(49,6), clk2_5_first_edge => to_unsigned(23,6), clk2_5_second_edge => to_unsigned(24,6),
    irq => (others => '0'), mask => (others => '0'), clkedge => "000000100011100000111000",
    rxctrl_q1_delay => (others => '0'), rxctrl_q2_delay => (others => '0'), rxctrl_q1_sel => '0', rxctrl_delay => '0',
    rxctrl_c_delay => '0', status_vector => (others => (others => '0')) );

  --  Kintex7 settings for KC705 Dev Board
  constant RES_kintex7 : rgmiiregs :=
  ( clk25_wrap  => to_unsigned(4,6),  clk25_first_edge  => to_unsigned(1,6),  clk25_second_edge  => to_unsigned(2,6),
    clk2_5_wrap => to_unsigned(49,6), clk2_5_first_edge => to_unsigned(23,6), clk2_5_second_edge => to_unsigned(24,6),
    irq => (others => '0'), mask => (others => '0'), clkedge => "000000100011100000111000",
    rxctrl_q1_delay => (others => '0'), rxctrl_q2_delay => (others => '0'), rxctrl_q1_sel => '1', rxctrl_delay => '0',
    rxctrl_c_delay => '0', status_vector => (others => (others => '0')) );

  --  Spartan6 settings for GR-XC6 Dev Board
  constant RES_spartan6 : rgmiiregs :=
  ( clk25_wrap  => to_unsigned(4,6),  clk25_first_edge  => to_unsigned(1,6),  clk25_second_edge  => to_unsigned(2,6),
    clk2_5_wrap => to_unsigned(49,6), clk2_5_first_edge => to_unsigned(23,6), clk2_5_second_edge => to_unsigned(24,6),
    irq => (others => '0'), mask => (others => '0'), clkedge => "000000100011100000111000",
    rxctrl_q1_delay => (others => '0'), rxctrl_q2_delay => "01", rxctrl_q1_sel => '1', rxctrl_delay => '0',
    rxctrl_c_delay => '0', status_vector => (others => (others => '0')) );

  --  Artix7 settings for AC701 Dev Board
  constant RES_artix7 : rgmiiregs :=
  ( clk25_wrap  => to_unsigned(4,6),  clk25_first_edge  => to_unsigned(1,6),  clk25_second_edge  => to_unsigned(2,6),
    clk2_5_wrap => to_unsigned(49,6), clk2_5_first_edge => to_unsigned(23,6), clk2_5_second_edge => to_unsigned(24,6),
    irq => (others => '0'), mask => (others => '0'), clkedge => "000000100011100000111000",
    rxctrl_q1_delay => (others => '0'), rxctrl_q2_delay => (others => '0'), rxctrl_q1_sel => '1', rxctrl_delay => '0',
    rxctrl_c_delay => '1', status_vector => (others => (others => '0')) );

  signal r, rin : rgmiiregs;

  signal clk_tx_90_n          : std_logic;
  signal sync_gbit            : std_logic;
  signal sync_speed           : std_logic;
  signal cnt2_5_en, cnt25_en  : std_logic;
  signal clkedge_sync         : std_logic_vector(23 downto 0);
  signal sync_rxctrl_q1_delay : std_logic_vector(1 downto 0);
  signal sync_rxctrl_q2_delay : std_logic_vector(1 downto 0);
  signal sync_rxctrl_q1_sel   : std_logic;
  signal sync_rxctrl_delay    : std_logic;
  signal sync_rxctrl_c_delay  : std_logic;
  signal cnt_en               : std_logic;
  signal clk10_100            : std_logic;

  signal clk25_wrap_sync          :  unsigned(5 downto 0);
  signal clk25_first_edge_sync    :  unsigned(5 downto 0);
  signal clk25_second_edge_sync   :  unsigned(5 downto 0);
  signal clk2_5_wrap_sync         :  unsigned(5 downto 0);
  signal clk2_5_first_edge_sync   :  unsigned(5 downto 0);
  signal clk2_5_second_edge_sync  :  unsigned(5 downto 0);


  -- debug signal
  signal WMemRgmiioData       : std_logic_vector(15 downto 0);
  signal RMemRgmiioData       : std_logic_vector(15 downto 0);
  signal RMemRgmiioAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiioAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiioWrEn       : std_logic;
  signal WMemRgmiiiData       : std_logic_vector(15 downto 0);
  signal RMemRgmiiiData       : std_logic_vector(15 downto 0);
  signal RMemRgmiiiAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiiiAddr       : std_logic_vector(9 downto 0);
  signal WMemRgmiiiWrEn       : std_logic;
  signal RMemRgmiiiRead       : std_logic;
  signal RMemRgmiioRead       : std_logic;

signal clk25i_del          : std_logic;
signal clk2_5i_del          : std_logic;
signal clk10_100_del          : std_logic;
signal tx_clki_del          : std_logic;
signal tx_clk_del          : std_logic;
signal ntx_clk_del          : std_logic;


begin  -- rtl

  vcc <= '1'; gnd <= '0';

  ---------------------------------------------------------------------------------------
  -- MDIO path
  ---------------------------------------------------------------------------------------

  gmiii.mdint    <= rgmiii.mdint;
  gmiii.mdio_i   <= rgmiii.mdio_i;
  rgmiio.mdio_o  <= gmiio.mdio_o;
  rgmiio.mdio_oe <= gmiio.mdio_oe;
  rgmiio.mdc     <= gmiio.mdc;

  ---------------------------------------------------------------------------------------
  -- TX path
  ---------------------------------------------------------------------------------------

   useclkmux0 : if no_clk_mux = 0 generate


    usemode100 : if mode100 = 1 generate

      process (apb_clk)
      begin  -- process
        if rising_edge(apb_clk) then
          clk50i <= not clk50i;
          if apb_rstn = '0' then clk50i <= '0'; end if;
        end if;
      end process;

      process (apb_clk)
      begin  -- process
        if rising_edge(apb_clk) then
          clk50d <= clk50i;

          if (clk50d = '1' and clk50i = '0') then
            clk25i_del <= not clk25i_del;
          end if;
          
          if (clk50d = '0' and clk50i = '1') then
            clk25i <= not clk25i;
          
            if cnt2_5 = "001001" then 
              cnt2_5 <= "000000"; clk2_5i_del <= not clk2_5i_del;
            else 
              cnt2_5 <= cnt2_5 + 1; 
            end if;

            if cnt2_5 = "000111" then 
                clk2_5i <= not clk2_5i;
            end if;    

          end if;
          
          if apb_rstn = '0' then clk50d <= '0'; clk25i <= '0'; clk2_5i <= '0'; cnt2_5 <= "000000"; clk25i_del <= '0'; clk2_5i_del <= '0'; end if;
        end if;
      end process;

    end generate;

    usemodeAPB : if mode100 = 0 generate
      process (apb_clk)
      begin  -- process
        if rising_edge(apb_clk) then
          clk25i <= not clk25i;
          if cnt2_5 = "001001" then cnt2_5 <= "000000"; clk2_5i <= not clk2_5i;
          else cnt2_5 <= cnt2_5 + 1; end if;
          if apb_rstn = '0' then clk25i <= '0'; clk2_5i <= '0'; cnt2_5 <= "000000"; end if;
        end if;
      end process;
    end generate;
    
      notecclkmux : if (has_clkmux(tech) = 0) generate
         tx_clki <= rgmiii.gtx_clk when ((gmii = 1) and (gmiio.gbit = '1')) else
         clk25i when gmiio.speed = '1' else clk2_5i;
      end generate;

      tecclkmux : if (has_clkmux(tech) = 1) generate
        -- Select 2.5 or 25 Mhz clockL
        clkmux10_100 : clkmux generic map (tech => tech) port map (clk2_5i,clk25i,gmiio.speed,clk10_100);
        clkmux1000   : clkmux generic map (tech => tech) port map (clk10_100,rgmiii.gtx_clk,gmiio.gbit,tx_clki);

        clkmux10_100d : clkmux generic map (tech => tech) port map (clk2_5i_del,clk25i_del,gmiio.speed,clk10_100_del);
        clkmux1000d   : clkmux generic map (tech => tech) port map (clk10_100_del,rgmiii.gtx_clk,gmiio.gbit,tx_clki_del);


      end generate;

      clkbuf0: techbuf generic map (buftype => 2, tech => tech)
                       port map (i => tx_clki, o => tx_clk);
                       
      clkbuf01: techbuf generic map (buftype => 2, tech => tech)
                       port map (i => tx_clki_del, o => tx_clk_del);
                       
                       
   end generate;

   noclkmux0 : if no_clk_mux = 1 generate
      -- Generate transmit clocks.
      tx_clk <= rgmiii.gtx_clk;

      -- CDC
      syncreg7 : syncreg port map (tx_clk, gmiio.gbit , sync_gbit  );
      
      syncreg8 : syncreg port map (tx_clk, gmiio.speed, sync_speed );
      
      syncreg_clkedge : for i in 0 to r.clkedge'length-1 generate
         syncreg9 : syncreg port map (tx_clk, r.clkedge(i), clkedge_sync(i));
      end generate;

      syncreg_clk25_wrap_sync : for i in 0 to r.clk25_wrap'length-1 generate
         syncreg_clk25_wrap_sync : syncreg port map (tx_clk, r.clk25_wrap(i), clk25_wrap_sync(i));
      end generate;

      syncreg_clk25_first_edge : for i in 0 to r.clk25_first_edge'length-1 generate
         syncreg_clk25_first_edge : syncreg port map (tx_clk, r.clk25_first_edge(i), clk25_first_edge_sync(i));
      end generate;

      syncreg_clk25_second_edge : for i in 0 to r.clk25_second_edge'length-1 generate
         syncreg_clk25_second_edge : syncreg port map (tx_clk, r.clk25_second_edge(i), clk25_second_edge_sync(i));
      end generate;

      syncreg_clk2_5_wrap_sync : for i in 0 to r.clk2_5_wrap'length-1 generate
         syncreg_clk2_5_wrap_sync : syncreg port map (tx_clk, r.clk2_5_wrap(i), clk2_5_wrap_sync(i));
      end generate;

      syncreg_clk2_5_first_edge : for i in 0 to r.clk2_5_first_edge'length-1 generate
         syncreg_clk2_5_first_edge : syncreg port map (tx_clk, r.clk2_5_first_edge(i), clk2_5_first_edge_sync(i));
      end generate;

      syncreg_clk2_5_second_edge : for i in 0 to r.clk2_5_second_edge'length-1 generate
         syncreg_clk2_5_second_edge : syncreg port map (tx_clk, r.clk2_5_second_edge(i), clk2_5_second_edge_sync(i));
      end generate;

      process (tx_clk)
      begin  -- process
        if rising_edge(tx_clk) then

          if cnt25 >= clk25_wrap_sync then
            cnt25 <= to_unsigned(0,cnt25'length);
            cnt25_en <= '1';
          else
            cnt25_en <= '0';
            cnt25 <= cnt25 + 1;
          end if;

          if (cnt25 >= clk25_wrap_sync) then
             clk25ni  <= clkedge_sync(0);
             clk25i   <= clkedge_sync(1);
          elsif (cnt25 = clk25_first_edge_sync) then
             clk25ni  <= clkedge_sync(2);
             clk25i   <= clkedge_sync(3);
          elsif (cnt25 = clk25_second_edge_sync) then
             clk25ni  <= clkedge_sync(4);
             clk25i   <= clkedge_sync(5);
          end if;

          if cnt2_5 >= clk2_5_wrap_sync then
            cnt2_5 <= to_unsigned(0,cnt2_5'length);
            cnt2_5_en <= '1';
          else
            cnt2_5 <= cnt2_5 + 1;
            cnt2_5_en <= '0';
          end if;

          if (cnt2_5 >= clk2_5_wrap_sync) then
             clk2_5ni  <= clkedge_sync(8);
             clk2_5i   <= clkedge_sync(9);
          elsif (cnt25 = clk2_5_first_edge_sync) then
             clk2_5ni  <= clkedge_sync(10);
             clk2_5i   <= clkedge_sync(11);
          elsif (cnt2_5 = clk2_5_second_edge_sync) then
             clk2_5ni  <= clkedge_sync(12);
             clk2_5i   <= clkedge_sync(13);
          end if;

          if rsttxclkn = '0' then
             cnt2_5_en <= '0'; cnt25_en <= '0'; clk25i <= '0'; clk25ni <= '0';
             clk2_5i <= '0'; clk2_5ni <= '0'; cnt2_5 <= to_unsigned(0,cnt2_5'length);
             cnt25 <= to_unsigned(0,cnt25'length);
          end if;

        end if;
      end process;
   end generate;

  ntx_clk <= not tx_clk;
  ntx_clk_del <= not tx_clk_del;
  gmiii.gtx_clk <= tx_clk;
  gmiii.tx_clk <= tx_clk;

  noclkmux1 : if no_clk_mux = 1 generate
   cnt_en <= '1' when ((gmii = 1) and (sync_gbit = '1')) else
      cnt25_en when sync_speed = '1' else cnt2_5_en;
  end generate;

  useclkmux1 : if no_clk_mux = 0 generate
   cnt_en <= '1';
  end generate;

   gmiii.tx_dv <= cnt_en when gmiio.tx_en = '1' else '1';

  -- Generate RGMII control signal and check data rate
  process (tx_clk)
  begin  -- process
    if rising_edge(tx_clk) then
      if (gmii = 1) and (sync_gbit = '1') then
         txd(7 downto 0) <= gmiio.txd(7 downto 0);
      else
         txd(3 downto 0) <= gmiio.txd(3 downto 0);
         txd(7 downto 4) <= gmiio.txd(3 downto 0);
      end if;
      tx_en  <= gmiio.tx_en;
      tx_ctl <= gmiio.tx_en xor gmiio.tx_er;
    end if;

    if (gmii = 1) and (sync_gbit = '1') then
       txp <= clkedge_sync(17);
       txn <= clkedge_sync(16);
    else
       if sync_speed = '1' then
          txp <= clk25ni;
          txn <= clk25i;
       else
          txp <= clk2_5ni;
          txn <= clk2_5i;
       end if;
    end if;
  end process;

  clk_tx_rst : rstgen
  generic map(syncin => 1, syncrst => 1)
  port map(rstn, tx_clk, vcc, rsttxclkn, open);
  rsttxclk <= not rsttxclkn;

   -- DDR outputs
   rgmii_txd : for i in 0 to 3 generate
       ddr_oreg0 : ddr_oreg generic map (tech, arch => 1)
         port map (q => rgmiio.txd(i), c1 => tx_clk, c2 => ntx_clk, ce => vcc,
                   d1 => txd(i), d2 => txd(i+4), r => rsttxclk, s => gnd);
   end generate;
   rgmii_tx_ctl : ddr_oreg generic map (tech, arch => 1)
         port map (q => rgmiio.tx_en, c1 => tx_clk, c2 => ntx_clk, ce => vcc,
                   d1 => tx_en, d2 => tx_ctl, r => rsttxclk, s => gnd);

   no_clk_mux1 : if no_clk_mux = 1 generate
     use90degtxclk1 : if use90degtxclk = 1 generate

      clk_tx90_rst : rstgen
      generic map(syncin => 1, syncrst => 1)
      port map(rstn, rgmiii.tx_clk_90, vcc, rsttxclk90n, open);
      rsttxclk90 <= not rsttxclk90n;

       clk_tx_90_n <= not rgmiii.tx_clk_90;
       syncreg_txp : syncreg port map (rgmiii.tx_clk_90, txp, txp_sync);
       syncreg_txn : syncreg port map (rgmiii.tx_clk_90, txn, txn_sync);
       rgmii_tx_clk : ddr_oreg generic map (tech, arch => 1)
             port map (q => tx_clk_ddr, c1 => rgmiii.tx_clk_90, c2 => clk_tx_90_n, ce => vcc,
                       d1 => txp_sync, d2 => txn_sync, r => rsttxclk90, s => gnd);
     end generate;

     use90degtxclk0 : if use90degtxclk = 0 generate
       rgmii_tx_clk : ddr_oreg generic map (tech, arch => 1)
             port map (q => tx_clk_ddr, c1 => tx_clk, c2 => ntx_clk, ce => vcc,
                       d1 => txp, d2 => txn, r => rsttxclk, s => gnd);
     end generate;
   end generate;

   no_clk_mux0 : if no_clk_mux = 0 generate

     use90degtxclk00 : if mode100 = 1 generate
       rgmii_tx_clk : ddr_oreg generic map (tech, arch => 1)
            port map (q => tx_clk_ddr, c1 => tx_clk_del, c2 => ntx_clk_del, ce => vcc,
                     d1 => '1', d2 => '0', r => rsttxclk, s => gnd);
     end generate;


     use90degtxclk01 : if mode100 = 0 generate
       rgmii_tx_clk : ddr_oreg generic map (tech, arch => 1)
            port map (q => tx_clk_ddr, c1 => tx_clk, c2 => ntx_clk, ce => vcc,
                     d1 => '1', d2 => '0', r => rsttxclk, s => gnd);
     end generate;
   end generate;

  rgmiio.tx_er  <= '0';
  rgmiio.tx_clk <= tx_clk_ddr;
  rgmiio.reset  <= rstn;
  rgmiio.gbit   <= gmiio.gbit;
  rgmiio.speed  <= gmiio.speed when (gmii = 1) else '0';

  -- Not used in RGMII mode
  rgmiio.txd(7 downto 4) <= (others => '0');

  ---------------------------------------------------------------------------------------
  -- RX path
  ---------------------------------------------------------------------------------------

  -- CDC (RX Control signal)
  syncreg_q1_delay : for i in 0 to r.rxctrl_q1_delay'length-1 generate
     syncreg0 : syncreg port map (rx_clk, r.rxctrl_q1_delay(i), sync_rxctrl_q1_delay(i));
  end generate;
  syncreg_q2_delay : for i in 0 to r.rxctrl_q2_delay'length-1 generate
     syncreg1 : syncreg port map (rx_clk, r.rxctrl_q2_delay(i) , sync_rxctrl_q2_delay(i));
  end generate;
  syncreg_q1_sel : syncreg port map (rx_clk, r.rxctrl_q1_sel, sync_rxctrl_q1_sel);

  syncreg_delay_sel : syncreg port map (rx_clk, r.rxctrl_delay, sync_rxctrl_delay);

  syncreg_delay_c_sel : syncreg port map (rx_clk, r.rxctrl_c_delay, sync_rxctrl_c_delay);

  -- Rx Clocks
  rx_clk <= rgmiii.rx_clk;
  nrx_clk <= not rgmiii.rx_clk;

  -- DDR inputs
  rgmii_rxd : for i in 0 to 3 generate
      ddr_ireg0 : ddr_ireg generic map (tech, arch => 1)
        port map (q1 => rxd_pre(i), q2 => rxd_pre(i+4), c1 => rx_clk, c2 => nrx_clk,
                  ce => vcc, d => rgmiii.rxd(i), r => gnd, s => gnd);

       process (rx_clk)
       begin
         if rising_edge(rx_clk) then

           rxd_int <= rxd_pre;

           rxd_int0(i)   <= rxd_int(i);
           rxd_int0(i+4) <= rxd_int(i+4);
           rxd_int1(i)   <= rxd_int0(i);
           rxd_int1(i+4) <= rxd_int0(i+4);
           rxd_int2(i)   <= rxd_int1(i);
           rxd_int2(i+4) <= rxd_int1(i+4);
         end if;
       end process;

  end generate;

  rgmii_rxd0 : for i in 0 to 3 generate
       process (rx_clk)
       begin
         if (sync_rxctrl_q1_delay = "00") then
            if (sync_rxctrl_delay = '1') then
               rxd_q1(i) <= rxd_int(i+4);            
            else
               rxd_q1(i) <= rxd_int(i);
            end if;
         elsif (sync_rxctrl_q1_delay = "01") then
            rxd_q1(i) <= rxd_int0(i);
         elsif (sync_rxctrl_q1_delay = "10") then
            rxd_q1(i) <= rxd_int1(i);
         else
            rxd_q1(i) <= rxd_int2(i);
         end if;
       end process;
  end generate;

  rgmii_rxd1 : for i in 4 to 7 generate
       process (rx_clk)
       begin
         if (sync_rxctrl_q2_delay = "00") then
            if (sync_rxctrl_delay = '1') then
               rxd_q2(i) <= rxd_int0(i-4);            
            else
               rxd_q2(i) <= rxd_int(i);
            end if;
         elsif (sync_rxctrl_q2_delay = "01") then
            rxd_q2(i) <= rxd_int0(i);
         elsif (sync_rxctrl_q2_delay = "10") then
            rxd_q2(i) <= rxd_int1(i);
         else
            rxd_q2(i) <= rxd_int2(i);
         end if;
       end process;
  end generate;

  rxd(3 downto 0) <= rxd_q1(3 downto 0) when (sync_rxctrl_q1_sel = '0') else rxd_q2(7 downto 4);
  rxd(7 downto 4) <= rxd_q2(7 downto 4) when (sync_rxctrl_q1_sel = '0') else rxd_q1(3 downto 0);

  ddr_dv0 : ddr_ireg generic map (tech, arch => 1)
     port map (q1 => rx_dv_pre, q2 => rx_ctl_pre, c1 => rx_clk, c2 => nrx_clk,
               ce => vcc, d => rgmiii.rx_dv, r => gnd, s => gnd);

  process (rx_clk)
  begin
    if rising_edge(rx_clk) then
       rx_ctl_int <= rx_ctl_pre;
       rx_dv_int  <= rx_dv_pre;

       rx_ctl_int0 <= rx_ctl_int;
       rx_ctl_int1 <= rx_ctl_int0;
       rx_ctl_int2 <= rx_ctl_int1;
       rx_dv_int0 <= rx_dv_int;
       rx_dv_int1 <= rx_dv_int0;
       rx_dv_int2 <= rx_dv_int2;
    end if;
  end process;

  process (rx_clk)
  begin
    if (sync_rxctrl_q1_delay = "00") then
       --rx_dv0 <= rx_dv_int;
       if (sync_rxctrl_c_delay = '1') then
          rx_dv0 <= rx_ctl_int;           
       else
          rx_dv0 <= rx_dv_int;
       end if;
    elsif (sync_rxctrl_q1_delay = "01") then
       rx_dv0 <= rx_dv_int0;
    elsif (sync_rxctrl_q1_delay = "10") then
       rx_dv0 <= rx_dv_int1;
    else
       rx_dv0 <= rx_dv_int2;
    end if;

    if (sync_rxctrl_q2_delay = "00") then
       --rx_ctl0 <= rx_ctl_int;
       if (sync_rxctrl_c_delay = '1') then
          rx_ctl0 <= rx_dv_int0;           
       else
          rx_ctl0 <= rx_ctl_int;
       end if;
    elsif (sync_rxctrl_q2_delay = "01") then
       rx_ctl0 <= rx_ctl_int0;
    elsif (sync_rxctrl_q2_delay = "10") then
       rx_ctl0 <= rx_ctl_int1;
    else
       rx_ctl0 <= rx_ctl_int2;
    end if;
  end process;

  rx_dv  <= rx_dv0 when (sync_rxctrl_q1_sel = '0') else rx_ctl0;
  rx_ctl <= rx_ctl0 when (sync_rxctrl_q1_sel = '0') else rx_dv0;

  -- Decode GMII error signal
  rx_error <= rx_dv xor rx_ctl;

  -- Enable inband status registers during Interframe Gap
  inbandopt <= not ( rx_dv or rx_error );
  inbandreq <= rx_error and not rx_dv;

  -- Sample RGMII inband information
  process (rx_clk)
   begin
    if rising_edge(rx_clk) then
      if (inbandopt = '1') then
         link_status   <= rxd(0);
         clock_speed   <= rxd(2 downto 1);
         duplex_status <= rxd(3);
      end if;
      if (inbandreq = '1') then
         if (rxd = x"0E") then false_carrier_ind <= '1'; else false_carrier_ind <= '0'; end if;
         if (rxd = x"0F") then carrier_ext       <= '1'; else carrier_ext       <= '0'; end if;
         if (rxd = x"1F") then carrier_ext_error <= '1'; else carrier_ext_error <= '0'; end if;
         if (rxd = x"FF") then carrier_sense     <= '1'; else carrier_sense     <= '0'; end if;
      end if;
    end if;
  end process;

  -- GMII output
  gmiii.rxd      <= rxd;
  gmiii.rx_dv    <= rx_dv;
  gmiii.rx_er    <= rx_error;
  gmiii.rx_clk   <= rx_clk;
  gmiii.rx_col   <= '0';
  gmiii.rx_crs   <= rx_dv;
  gmiii.rmii_clk <= '0';
  gmiii.rx_en    <= '1';

  -- GMII output controlled via generics
  gmiii.edclsepahb  <= '0';
  gmiii.edcldisable <= '0';
  gmiii.phyrstaddr  <= (others => '0');
  gmiii.edcladdr    <= (others => '0');

  ---------------------------------------------------------------------------------------
  -- APB Section
  ---------------------------------------------------------------------------------------

  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  -- Status Register
  status_vector_sync(15) <= '1' when (no_clk_mux = 1) else '0';
  status_vector_sync(14) <= '1' when (debugmem = 1  ) else '0';
  status_vector_sync(13) <= '1' when (gmii = 1      ) else '0';
  status_vector_sync(12 downto 10) <= (others => '0');
  status_vector_sync(9) <= gmiio.gbit;
  status_vector_sync(8) <= gmiio.speed;
  status_vector_sync(7) <= carrier_sense;
  status_vector_sync(6) <= carrier_ext_error;
  status_vector_sync(5) <= carrier_ext;
  status_vector_sync(4) <= false_carrier_ind;
  status_vector_sync(3) <= duplex_status;
  status_vector_sync(2) <= clock_speed(1);
  status_vector_sync(1) <= clock_speed(0);
  status_vector_sync(0) <= link_status;

  -- CDC clock domain crossing
  syncreg_status : for i in 0 to status_vector'length-1 generate
     syncreg3 : syncreg port map (tx_clk, status_vector_sync(i), status_vector(i));
  end generate;

  rgmiiapb : process(apb_rstn, r, apbi, RMemRgmiiiData, RMemRgmiiiRead, RMemRgmiioRead, status_vector )
  variable rdata    : std_logic_vector(31 downto 0);
  variable paddress : std_logic_vector(7 downto 2);
  variable v        : rgmiiregs;
  begin

    v := r;
    paddress := (others => '0');
    paddress(abits-1 downto 2) := apbi.paddr(abits-1 downto 2);
    rdata := (others => '0');

    v.status_vector(1) := r.status_vector(0);
    v.status_vector(0) := status_vector;

    -- read/write registers

    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case paddress(7 downto 2) is
      when "000000" =>
        rdata(15 downto 0) := r.status_vector(0);
      when "000001" =>
        rdata(15 downto 0) := r.irq;
        v.irq := (others => '0');  -- Interrupt is clear on read
      when "000010" =>
        rdata(15 downto 0) := r.mask;
      when "000011" =>
        rdata(5 downto 0) := std_logic_vector(r.clk25_wrap);
      when "000100" =>
        rdata(5 downto 0) := std_logic_vector(r.clk25_first_edge);
      when "000101" =>
        rdata(5 downto 0) := std_logic_vector(r.clk25_second_edge);
      when "000110" =>
        rdata(5 downto 0) := std_logic_vector(r.clk2_5_wrap);
      when "000111" =>
        rdata(5 downto 0) := std_logic_vector(r.clk2_5_first_edge);
      when "001000" =>
        rdata(5 downto 0) := std_logic_vector(r.clk2_5_second_edge);
      when "001001" =>
       rdata(23 downto 0) := r.clkedge;
      when "001010" =>
         rdata(1 downto 0) := v.rxctrl_q2_delay;
      when "001011" =>
         rdata(1 downto 0) := v.rxctrl_q1_delay;
      when "001100" =>
         rdata(0) := v.rxctrl_q1_sel;
      when "001101" =>
         rdata(0) := v.rxctrl_delay;
      when "001110" =>
         rdata(0) := v.rxctrl_c_delay;
      when others =>
        null;
      end case;
    end if;

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case paddress(7 downto 2) is
      when "000000" =>
       null;
      when "000001" =>
         null;
      when "000010" =>
         v.mask := apbi.pwdata(15 downto 0);
      when "000011" =>
        v.clk25_wrap := unsigned(apbi.pwdata(5 downto 0));
      when "000100" =>
        v.clk25_first_edge := unsigned(apbi.pwdata(5 downto 0));
      when "000101" =>
        v.clk25_second_edge := unsigned(apbi.pwdata(5 downto 0));
      when "000110" =>
        v.clk2_5_wrap := unsigned(apbi.pwdata(5 downto 0));
      when "000111" =>
        v.clk2_5_first_edge := unsigned(apbi.pwdata(5 downto 0));
      when "001000" =>
        v.clk2_5_second_edge := unsigned(apbi.pwdata(5 downto 0));
      when "001001" =>
         v.clkedge := apbi.pwdata(23 downto 0);
      when "001010" =>
         v.rxctrl_q2_delay := apbi.pwdata(1 downto 0);
      when "001011" =>
         v.rxctrl_q1_delay := apbi.pwdata(1 downto 0);
      when "001100" =>
         v.rxctrl_q1_sel   := apbi.pwdata(0);
      when "001101" =>
         v.rxctrl_delay    := apbi.pwdata(0);
      when "001110" =>
         v.rxctrl_c_delay    := apbi.pwdata(0);
      when others =>
        null;
      end case;
    end if;

    -- Check interrupts
    for i in 0 to r.status_vector'length-1 loop
     if  ((r.status_vector(0)(i) xor r.status_vector(1)(i)) and r.mask(i)) = '1' then
       v.irq(i) :=  '1';
     end if;
    end loop;

    -- reset operation
    if (not RESET_ALL) and (apb_rstn = '0') then
      if (tech = kintex7) then
        v := RES_kintex7;
      elsif (tech = spartan6) then
        v := RES_spartan6;
      elsif (tech = artix7) then
        v := RES_artix7;
      else
        v := RES;
      end if;
    end if;

    -- update registers
    rin <= v;

    -- drive outputs
    if apbi.psel(pindex) = '0' then
     apbo.prdata  <= (others => '0');
    elsif RMemRgmiiiRead = '1' then
     apbo.prdata(31 downto 16)  <= (others => '0');
     apbo.prdata(15 downto 0)   <= RMemRgmiiiData;
    elsif RMemRgmiioRead = '1' then
     apbo.prdata(31 downto 16)  <= (others => '0');
     apbo.prdata(15 downto 0)   <= RMemRgmiioData;
    else
     apbo.prdata  <= rdata;
    end if;

    apbo.pirq <= (others => '0');
    apbo.pirq(pirq) <=  orv(v.irq);

  end process;

    regs : process(apb_clk)
    begin
      if rising_edge(apb_clk) then
        r <= rin;
        if RESET_ALL and apb_rstn = '0' then
          if (tech = kintex7) then
            r <= RES_kintex7;
          elsif (tech = spartan6) then
            r <= RES_spartan6;
          else
            r <= RES;
          end if;
        end if;
      end if;
    end process;

  ---------------------------------------------------------------------------------------
  --  Debug Mem
  ---------------------------------------------------------------------------------------

  debugmem1 : if (debugmem /= 0) generate

   -- Write GMII IN data
    process (tx_clk)
    begin  -- process
      if rising_edge(tx_clk) then
        WMemRgmiioData(15 downto 0) <= "000" & tx_en & "000" & tx_ctl & txd;
        if (tx_en = '1') and ((WMemRgmiioAddr < "0111111110") or (WMemRgmiioAddr = "1111111111")) then
           WMemRgmiioAddr <= WMemRgmiioAddr + 1;
           WMemRgmiioWrEn <= '1';
        else
           if (tx_en = '0') then
              WMemRgmiioAddr <= (others => '1');
           else
              WMemRgmiioAddr <= WMemRgmiioAddr;
           end if;
           WMemRgmiioWrEn <= '0';
        end if;
      end if;
    end process;

    -- Read
    RMemRgmiioRead <= apbi.paddr(10) and apbi.psel(pindex);
    RMemRgmiioAddr <= "00" & apbi.paddr(10-1 downto 2);

    gmiii0 : syncram_2p generic map (tech, 10, 16, 1, 0, 0) port map(
      apb_clk, RMemRgmiioRead, RMemRgmiioAddr, RMemRgmiioData,
      tx_clk, WMemRgmiioWrEn, WMemRgmiioAddr(10-1 downto 0), WMemRgmiioData);

    -- Write GMII IN data
    process (rx_clk)
    begin  -- process
      if rising_edge(rx_clk) then
        WMemRgmiiiData(15 downto 0) <= "000" & rx_dv & "000" & rx_ctl & rxd(7 downto 4) & rxd(3 downto 0);
        if ((rx_dv = '1') or (rx_ctl = '1')) and ((WMemRgmiiiAddr < "0111111110") or (WMemRgmiiiAddr = "1111111111")) then
           WMemRgmiiiAddr <= WMemRgmiiiAddr + 1;
           WMemRgmiiiWrEn <= '1';
        else
           if (rx_dv = '0') then
              WMemRgmiiiAddr <= (others => '1');
           else
              WMemRgmiiiAddr <= WMemRgmiiiAddr;
           end if;
           WMemRgmiiiWrEn <= '0';
        end if;
      end if;
    end process;

    -- Read
    RMemRgmiiiRead <= apbi.paddr(11) and apbi.psel(pindex);
    RMemRgmiiiAddr <= "00" & apbi.paddr(10-1 downto 2);

    rgmiii0 : syncram_2p generic map (tech, 10, 16, 1, 0, 0) port map(
      apb_clk, RMemRgmiiiRead, RMemRgmiiiAddr, RMemRgmiiiData,
      rx_clk, WMemRgmiiiWrEn, WMemRgmiiiAddr(10-1 downto 0), WMemRgmiiiData);

  end generate;

-- pragma translate_off
    bootmsg : report_version
    generic map ("rgmii" & tost(pindex) &
        ": RGMII rev " & tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end rtl;

