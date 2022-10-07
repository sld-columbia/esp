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

      tclk_sim <= not tclk_sim after 5 ns;

      ahbsi<=ahbsi_sim;
      ahbso_sim<=ahbso;

      -- pragma translate_off
      PROC_SEQUENCER : process
        file text_file : text open read_mode is "jtag/stim.txt";
        file out_file1 : text open write_mode is "jtag/stim1_origin.txt";
        file out_file1f : text open write_mode is "jtag/stim1_fin.txt";
        file out_file2 : text open write_mode is "jtag/stim2_origin.txt";
        file out_file2f : text open write_mode is "jtag/stim2_fin.txt";
        file out_file3 : text open write_mode is "jtag/stim3_origin.txt";
        file out_file3f : text open write_mode is "jtag/stim3_fin.txt";
        file out_file4 : text open write_mode is "jtag/stim4_origin.txt";
        file out_file4f : text open write_mode is "jtag/stim4_fin.txt";
        file out_file5 : text open write_mode is "jtag/stim5_origin.txt";
        file out_file5f : text open write_mode is "jtag/stim5_fin.txt";
        file out_file6 : text open write_mode is "jtag/stim6_origin.txt";
        file out_file6f : text open write_mode is "jtag/stim6_fin.txt";
        variable text_line :line ;
        variable out_line :line;
        variable ok : boolean;
        variable testin1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testin3 : std_logic_vector(31 downto 0); --replace with sipo

        variable testout1 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout2 : std_logic_vector(31 downto 0); --replace with sipo
        variable testout3 : std_logic_vector(31 downto 0); --replace with sipo
        variable testfin : std_logic_vector(33 downto 0); --replace with sip
        variable testfin1 : std_logic_vector(65 downto 0); --replace with sipo

        constant ZERO_20 : std_logic_vector(19 downto 0) := (others => '0');
        constant ZERO_32 : std_logic_vector(31 downto 0) := (others => '0');
        variable testin_addr : std_logic_vector(31 downto 0); --replace
                                                              --with sipo
        -- variable flit66 : std_logic_vector(71 downto 0);--(103 downto 0);
        variable flit66 : std_logic_vector(75 downto 0);--(103 downto 0);
        variable flit34 : std_logic_vector(39 downto 0);--(71 downto 0);

        variable source : source_t ;
        variable addr,addr_r : addr_t;
        variable addr1,addr2,addr3 : std_logic_vector(31 downto 0);
        variable end_trace : std_logic_vector(1 to 6);
        variable end_strace : std_logic ;
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

        wait for 2600 ns;

        while true loop

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hwrite<='1';


          if not endfile(text_file) then
            readline(text_file, text_line);
            hread(text_line, flit66, ok);

            case flit66(3 downto 0) is
              when "0001" =>
                addr1:=addr(0);
                addr2:=addr(1);
                addr3:=addr(2);
                testin1 := X"00000" & '0' & flit66(NOC_FLIT_SIZE + 4 + 4 -1 downto 59+4);
                testin2 := flit66(58+4 downto 27+4);
                testin3 := flit66(26+4 downto 4+4) & source(1) & "0" & flit66(0+4) & "1";
                assert false report "write1" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file1,out_line);
                end if;
              when "0010" =>
                addr1:=addr(3);
                addr2:=addr(4);
                addr3:=addr(5);
                testin1 := X"00000" & '0' & flit66(NOC_FLIT_SIZE + 4 + 4 -1 downto 59+4);
                testin2 := flit66(58+4 downto 27+4);
                testin3 := flit66(26+4 downto 4+4) & source(1) & "0" & flit66(0+4) & "1";
                assert false report "write2" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file2,out_line);
                end if;
              when "0011" =>
                addr1:=addr(6);
                addr2:=addr(7);
                addr3:=addr(8);
                testin1 := X"00000" & '0' & flit66(NOC_FLIT_SIZE + 4 + 4 -1 downto 59+4);
                testin2 := flit66(58+4 downto 27+4);
                testin3 := flit66(26+4 downto 4+4) & source(1) & "0" & flit66(0+4) & "1";
                assert false report "write3" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file3,out_line);
                end if;
              when "0100" =>
                addr1:=addr(9);
                addr2:=addr(10);
                addr3:=addr(11);
                testin1 := X"00000" & '0' & flit66(NOC_FLIT_SIZE + 4 + 4 -1 downto 59+4);
                testin2 := flit66(58+4 downto 27+4);
                testin3 := flit66(26+4 downto 4+4) & source(1) & "0" & flit66(0+4) & "1";
                assert false report "write4" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file4,out_line);
                end if;
              when "0101" =>
                addr1:=addr(12);
                addr2:=addr(13);
                addr3:=addr(14);
                testin1 := ZERO_32;
                testin2 := X"00000" & "0" & flit66( MISC_NOC_FLIT_SIZE + 4 + 4 - 1 downto 27+4);
                testin3 := flit66(26+4 downto 4+4)& source(5) & "0" & flit66(0+4) & "1";
                assert false report "write5" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(MISC_NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file5,out_line);
                end if;
              when "0110" =>
                addr1:=addr(15);
                addr2:=addr(16);
                addr3:=addr(17);
                testin1 := X"00000" & '0' & flit66(NOC_FLIT_SIZE + 4 + 4 -1 downto 59+4);
                testin2 := flit66(58+4 downto 27+4);
                testin3 := flit66(26+4 downto 4+4) & source(1) & "0" & flit66(0+4) & "1";
                assert false report "write6" severity note;
                if flit66(0+4)='0' then
                  hwrite(out_line, flit66(NOC_FLIT_SIZE + 4 + 4  - 1 downto 4+4),right, 4);
                  hwrite(out_line, flit66(4 downto 4), right, 4);
                  writeline(out_file6,out_line);
                end if;

              when others => null;
            end case;

            -- WRITE FLIT1
            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr1;
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.hwdata <= ZERO_32 & testin1;

            if ahbso_sim.hready='0'  then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <= '1';
            else
              ahbsi_sim.hready <= '1';
            end if;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';


            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            -- WRITE FLIT2

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.haddr(31 downto 0)<= addr2;
            ahbsi_sim.hwdata <= ZERO_32 & testin2;

            if ahbso_sim.hready='0'  then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <= '1';
            else
              ahbsi_sim.hready <= '1';
            end if;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';


            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);


            -- WRITE FLIT3
            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.hwrite <='1';
            ahbsi_sim.haddr(31 downto 0)<= addr3;
            ahbsi_sim.hwdata <= ZERO_32 & testin3;

            if ahbso_sim.hready='0'  then
              wait until rising_edge(ahbso_sim.hready);
              ahbsi_sim.hready <= '1';
            else
              ahbsi_sim.hready <= '1';
            end if;

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hwrite <='0';
            ahbsi_sim.hready <='0';

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

          elsif end_strace /='1' then
            assert false report "end_trace" severity note;
            end_strace :='1';
          end if;

          wait until rising_edge(tclk_sim);

          ahbsi_sim.haddr(31 downto 0)<= (others=>'0');

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='1';
          ahbsi_sim.hready<='1';

          wait until rising_edge(tclk_sim);

          ahbsi_sim.hsel(0)<='0';
          ahbsi_sim.hready<='0';

          wait until rising_edge(tclk_sim);


          ahbsi_sim.hwrite <='0';

          for i in 1 to 6 loop

            -- READ FLIT1

            ahbsi_sim.hsel(0)<='1';
            ahbsi_sim.haddr(31 downto 0)<= addr_r((i-1)*3);
            ahbsi_sim.hready <='1';

            wait until rising_edge(tclk_sim);

            ahbsi_sim.hsel(0)<='0';
            ahbsi_sim.hready<='0';


            --
            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
            end if ;
            --
            -- wait until rising_edge(ahbso_sim.hready);

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

            --
            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
            end if ;
            --
            -- wait until rising_edge(ahbso_sim.hready);

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

            --
            if ahbso_sim.hready='0' then
              wait until rising_edge(ahbso_sim.hready);
            end if ;
            --
            -- wait until rising_edge(ahbso_sim.hready);
            testout3 := ahbso_sim.hrdata(31 downto 0);

            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);
            wait until rising_edge(tclk_sim);

            if testout1(6)='1'  then
              assert false report "********* mismatch ******** on NoC " & integer'image(i) severity note;
            end if;

            if i=1 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin1:=testout3(8 downto 0) & testout2(31 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin1, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file1f, out_line);
              end if;
            end if;
            if i=2 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin1:=testout3(8 downto 0) & testout2(31 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin1, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file2f, out_line);
              end if;
            end if;
            if i=3 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin1:=testout3(8 downto 0) & testout2(31 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin1, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file3f, out_line);
              end if;
            end if;

            if i=4 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin1:=testout3(8 downto 0) & testout2(31 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin1, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file4f, out_line);
              end if;
            end if;

            if i=5 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin:=testout2(8 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file5f, out_line);
              end if;
            end if;

            if i=6 then
              if testout1/=X"00000000" or testout2/=X"00000000" or testout3/=X"00000000" then
                testfin1:=testout3(8 downto 0) & testout2(31 downto 0) &  testout1(31 downto 7);
                hwrite(out_line, testfin1, right, 4);
                hwrite(out_line, testout1(6 downto 6), right, 4);
                writeline(out_file6f, out_line);
              end if;
            end if;

            --for i in 0 to 10 loop
            --  wait until rising_edge(tclk_sim);
            --end loop;

          end loop;

          ahbsi_sim.hwrite <='1';
          assert false report "iterate" severity note;

        end loop;
      end process;
      -- pragma translate_on

end architecture rtl;
