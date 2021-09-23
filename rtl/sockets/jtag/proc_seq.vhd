-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.jtag_pkg.all;



entity jtag_tb is

  port (
    ahbsi  : out ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_type);

end ;

architecture rtl of jtag_tb is

  type addr_t is array (17 downto 0) of std_logic_vector(31 downto 0);
  type source_t is array (1 to 6) of std_logic_vector(5 downto 0);

  signal tclk_sim : std_logic := '0';
  signal ahbsi_sim : ahb_slv_in_type;
  signal ahbso_sim : ahb_slv_out_type;

begin

      tclk_sim <= not tclk_sim after 10 ns;

      ahbsi<=ahbsi_sim;
      ahbso_sim<=ahbso;

      -- pragma translate_off
      PROC_SEQUENCER : process
        file text_file1 : text open read_mode is "stim1.txt";
        file text_file2 : text open read_mode is "stim2.txt";
        file text_file3 : text open read_mode is "stim3.txt";
        file text_file4 : text open read_mode is "stim4.txt";
        file text_file5 : text open read_mode is "stim5.txt";
        file text_file6 : text open read_mode is "stim6.txt";
        file out_file0 : text open write_mode is "stim5_origin.txt";
        file out_file1 : text open write_mode is "stim5_fin.txt";
        file out_file : text open write_mode is "test_out.txt";
        variable text_line :line ;
        variable out_line :line;
        variable ok : boolean;
        variable testin1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin3 : std_logic_vector(31 downto 0); --replace with sipo

        variable testout1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout3 : std_logic_vector(31 downto 0); --replace with sipo
        variable testfin : std_logic_vector(33 downto 0); --replace with sipo

        constant ZERO_20 : std_logic_vector(19 downto 0) := (others => '0');
        constant ZERO_32 : std_logic_vector(31 downto 0) := (others => '0');
        variable testin_addr : std_logic_vector(31 downto 0); --replace
                                                              --with sipo
        variable flit66 : std_logic_vector(71 downto 0);--(103 downto 0);
        variable flit34 : std_logic_vector(39 downto 0);--(71 downto 0);

        variable source : source_t ;
        variable addr,addr_r : addr_t;

        variable end_trace : std_logic_vector(1 to 6);
        variable testout : std_logic_vector(73 downto 0);

      begin

        ahbsi_sim.hsel       <= (others=>'0');
        ahbsi_sim.haddr      <= (others=>'0');
        ahbsi_sim.hwrite     <= '0';
        ahbsi_sim.htrans     <= HTRANS_NONSEQ;
        ahbsi_sim.hsize      <= (others=>'0');
        ahbsi_sim.hburst     <= (others=>'0');
        ahbsi_sim.hwdata     <= (others=>'0');
        ahbsi_sim.hprot      <= (others=>'0');
        ahbsi_sim.hready     <= '1';
        ahbsi_sim.hmaster    <= (others=>'0');
        ahbsi_sim.hmastlock  <= '0';
        ahbsi_sim.hmbsel     <= (others=>'0');
        ahbsi_sim.hirq       <= (others=>'0');
        ahbsi_sim.testen     <= '0';
        ahbsi_sim.testrst    <= '0';
        ahbsi_sim.scanen     <= '0';
        ahbsi_sim.testoen    <= '0';
        ahbsi_sim.testin     <= (others=>'0');

        source(1) := "100000";
        source(2) := "010000";
        source(3) := "001000";
        source(4) := "000100";
        source(5) := "000010";
        source(6) := "000001";

        addr(0):= std_logic_vector(to_unsigned(16#00010000#, 32));
        addr(1):= std_logic_vector(to_unsigned(16#00010004#, 32));
        addr(2):= std_logic_vector(to_unsigned(16#00010008#, 32));
        addr(3):= std_logic_vector(to_unsigned(16#00010010#, 32));
        addr(4):= std_logic_vector(to_unsigned(16#00010014#, 32));
        addr(5):= std_logic_vector(to_unsigned(16#00010018#, 32));
        addr(6):= std_logic_vector(to_unsigned(16#00010020#, 32));
        addr(7):= std_logic_vector(to_unsigned(16#00010024#, 32));
        addr(8):= std_logic_vector(to_unsigned(16#00010028#, 32));
        addr(9):= std_logic_vector(to_unsigned(16#00010030#, 32));
        addr(10):= std_logic_vector(to_unsigned(16#00010034#, 32));
        addr(11):= std_logic_vector(to_unsigned(16#00010038#, 32));
        addr(12):= std_logic_vector(to_unsigned(16#00010040#, 32));
        addr(13):= std_logic_vector(to_unsigned(16#00010044#, 32));
        addr(14):= std_logic_vector(to_unsigned(16#00010048#, 32));
        addr(15):= std_logic_vector(to_unsigned(16#00010050#, 32));
        addr(16):= std_logic_vector(to_unsigned(16#00010054#, 32));
        addr(17):= std_logic_vector(to_unsigned(16#00010058#, 32));

        addr_r(0):= std_logic_vector(to_unsigned(16#00010100#, 32));
        addr_r(1):= std_logic_vector(to_unsigned(16#00010104#, 32));
        addr_r(2):= std_logic_vector(to_unsigned(16#00010108#, 32));
        addr_r(3):= std_logic_vector(to_unsigned(16#00010110#, 32));
        addr_r(4):= std_logic_vector(to_unsigned(16#00010114#, 32));
        addr_r(5):= std_logic_vector(to_unsigned(16#00010118#, 32));
        addr_r(6):= std_logic_vector(to_unsigned(16#00010120#, 32));
        addr_r(7):= std_logic_vector(to_unsigned(16#00010124#, 32));
        addr_r(8):= std_logic_vector(to_unsigned(16#00010128#, 32));
        addr_r(9):= std_logic_vector(to_unsigned(16#00010130#, 32));
        addr_r(10):= std_logic_vector(to_unsigned(16#00010134#, 32));
        addr_r(11):= std_logic_vector(to_unsigned(16#00010138#, 32));
        addr_r(12):= std_logic_vector(to_unsigned(16#00010140#, 32));
        addr_r(13):= std_logic_vector(to_unsigned(16#00010144#, 32));
        addr_r(14):= std_logic_vector(to_unsigned(16#00010148#, 32));
        addr_r(15):= std_logic_vector(to_unsigned(16#00010150#, 32));
        addr_r(16):= std_logic_vector(to_unsigned(16#00010154#, 32));
        addr_r(17):= std_logic_vector(to_unsigned(16#00010158#, 32));



        testout := (others => '0');
        end_trace := (others => '0');

        wait for 2600 ns;

        while true loop

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hwrite<='1';


          if not endfile(text_file1) then
            readline(text_file1, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(1) & "0" & flit66(0) & "1" & ZERO_20;
            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(0);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(1);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3
            ahbsi_sim.haddr(31 downto 0)<= addr(2);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(1)/='1') then
            assert false report "end trace " & integer'image(1)  severity note;
            end_trace(1) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(0);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);
            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(1);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(2);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(1)  severity note;

          if not endfile(text_file2) then
            readline(text_file2, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(2) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(3);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(4);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(5);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
          elsif (end_trace(2)/='1') then
            assert false report "end trace " & integer'image(2)  severity note;
            end_trace(2) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(3);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(4);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;
            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(5);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(2)  severity note;
          if not endfile(text_file3) then
            readline(text_file3, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(2) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(6);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(7);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(8);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(3)/='1') then
            assert false report "end trace " & integer'image(3)  severity note;
            end_trace(3) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(6);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(7);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            -- --free the bus and wait for 4 clock cycles

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(8);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            -- --free the bus and wait for 4 clock cycles

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(3)  severity note;

          if not endfile(text_file4) then
            readline(text_file4, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(4) & "0" & flit66(0) & "1" & ZERO_20;

            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(9);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(10);
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.haddr(31 downto 0)<= addr(11);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(4)/='1') then
            assert false report "end trace " & integer'image(4)  severity note;
            end_trace(4) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(9);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(10);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(11);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(4)  severity note;

          if not endfile(text_file5) then
            readline(text_file5, text_line);
            hread(text_line, flit34, ok);
            testin1 := ZERO_32;
            testin2 := X"00000" & "0" & flit34( MISC_NOC_FLIT_SIZE + 4 - 1 downto 27);
            testin3 := flit34(26 downto 4)& source(5) & "0" & flit34(0) & "1";

            if flit34(0)='0' then

              hwrite(out_line, flit34(MISC_NOC_FLIT_SIZE + 4 - 1 downto 4),right, 4);
              hwrite(out_line, flit34(0 downto 0), right, 4);
              writeline(out_file0,out_line);

            end if;

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(12);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(13);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(14);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif (end_trace(5)/='1') then
            assert false report "end trace " & integer'image(5)  severity note;
            end_trace(5) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(12);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(13);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);


            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(14);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(5)  severity note;

          if not endfile(text_file6) then
            readline(text_file6, text_line);
            hread(text_line, flit66, ok);
            testin1 := flit66(NOC_FLIT_SIZE + 4 -1 downto 38);
            testin2 := flit66(37 downto 6);
            testin3 := flit66(6 downto 4) & source(6) & "0" & flit66(0) & "1" & ZERO_20;


            -- WRITE FLIT1

            ahbsi_sim.haddr(31 downto 0)<= addr(15);
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.haddr(31 downto 0)<= addr(16);

            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3


            ahbsi_sim.haddr(31 downto 0)<= addr(17);
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);


          elsif (end_trace(6)/='1') then
            assert false report "end trace " & integer'image(6)  severity note;
            end_trace(6) := '1';

            ---
            testin1 := ZERO_32;
            testin2 := ZERO_32;
            testin3 := X"0000000" & "0001";

            -- WRITE FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(15);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);
            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(16);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr(17);
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin3;
            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <='1';
            else
              ahbsi_sim.hready <='1';
            end if ;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          end if;
          assert false report "end trace " & integer'image(6)  severity note;

          wait until rising_edge(tclk_sim);

          ahbsi_sim.haddr(31 downto 0)<= (others=>'0');

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hready<='1';

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='0';
          ahbsi_sim.hready<='0';

          wait until rising_edge(tclk_sim);

          for i in 1 to 6 loop

            -- READ FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready);

            testout1 := ahbso_sim.hrdata(31 downto 0);



            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);


            -- READ FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+1);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready);

            testout2 := ahbso_sim.hrdata(31 downto 0);


            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- READ FLIT3

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+2);
            ahbsi_sim.hready <='1';

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3+2);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';

            wait until rising_edge(ahbso_sim.hready) ;
            testout3 := ahbso_sim.hrdata(31 downto 0);

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
              testfin:=testout2(8 downto 0) &  testout1(31 downto 7);
              hwrite(out_line, testfin, right, 4);
              hwrite(out_line, testout1(6 downto 6), right, 4);
              writeline(out_file1, out_line);
            end if;

          end loop;
        end loop;
      end process;
      -- pragma translate_on

end architecture rtl;
