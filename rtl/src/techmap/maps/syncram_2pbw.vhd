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
-- Entity: 	syncram_2pbw
-- File:	syncram_2pbw.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 2-port ram with tech selection and 8-bit write
--              strobes
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;
use work.config.all;
use work.config_types.all;
use work.stdlib.all;

entity syncram_2pbw is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0;
	words : integer := 0; custombits : integer := 1);
  port (
    rclk     : in std_ulogic;
    renable  : in std_logic_vector((dbits/8-1) downto 0);
    raddress : in std_logic_vector((abits-1) downto 0);
    dataout  : out std_logic_vector((dbits-1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_logic_vector((dbits/8-1) downto 0);
    waddress : in std_logic_vector((abits-1) downto 0);
    datain   : in std_logic_vector((dbits-1) downto 0);
    testin   : in std_logic_vector(TESTIN_WIDTH-1 downto 0) := testin_none
    );
end;

architecture rtl of syncram_2pbw is
  
  constant nctrl : integer := abits*2 + 2 + 2*dbits/8;
  
  signal dataoutx  : std_logic_vector((dbits -1) downto 0);
  signal databp, testdata : std_logic_vector((dbits -1) downto 0);
  signal renable2 : std_logic_vector((dbits/8-1) downto 0);
  constant SCANTESTBP : boolean := (testen = 1) and syncram_add_scan_bypass(tech)=1;
  constant iwrfst : integer := (1-syncram_2p_write_through(tech)) * wrfst;

  signal xrenable,xwrite : std_logic_vector(dbits/8-1 downto 0);
  signal custominx,customoutx: std_logic_vector(syncram_customif_maxwidth downto 0);

begin

  xrenable <= renable when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');
  xwrite <= write when testen=0 or testin(TESTIN_WIDTH-2)='0' else (others => '0');

  s2pbw : if has_sram_2pbw(tech) = 1 generate
    no_wrfst : if iwrfst = 0 generate
      scanbp : if SCANTESTBP generate
        comb : process (waddress, raddress, datain, renable, write, testin)
          variable tmp : std_logic_vector((dbits -1) downto 0);
          variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
        begin
          ctrlsigs := testin(1 downto 0) & write & renable & raddress & waddress;
          tmp := datain;
          for i in 0 to nctrl-1 loop
            tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
          end loop;
          testdata <= tmp;
        end process;
        reg : process(wclk) begin
          if rising_edge(wclk) then databp <= testdata; end if;
        end process;
        dmuxout : for i in 0 to dbits-1 generate
          x0 : grmux2 generic map (tech)
            port map (dataoutx(i), databp(i), testin(3), dataout(i));
        end generate;
      end generate;
      noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;
      -- Write contention check (if applicable)
      wcheck : for i in 0 to dbits/8-1 generate
        renable2(i) <= '0' when ((sepclk = 0 and syncram_2p_dest_rw_collision(tech) = 1) and
                                 (renable(i) and write(i)) = '1' and raddress = waddress) else renable(i);
      end generate;
    end generate;

    wrfst_gen : if iwrfst = 1 generate
      -- No risk for read/write contention. Register addresses and mux on comparator
      no_contention_check : if syncram_2p_dest_rw_collision(tech) = 0 generate
        wfrstblocknoc : block
          type wrfst_type is record
            raddr   : std_logic_vector((abits-1) downto 0);
            waddr   : std_logic_vector((abits-1) downto 0);
            datain  : std_logic_vector((dbits-1) downto 0);
            write   : std_logic_vector((dbits/8-1) downto 0);
            renable : std_logic_vector((dbits/8-1) downto 0);
          end record;
          signal r : wrfst_type;
        begin
          comb : process(r, dataoutx, testin) begin
            for i in 0 to dbits/8-1 loop
              if (SCANTESTBP and (testin(3) = '1')) or
                (((r.write(i) and r.renable(i)) = '1') and (r.raddr = r.waddr)) then
                dataout(i*8+7 downto i*8) <= r.datain(i*8+7 downto i*8);
              else dataout(i*8+7 downto i*8) <= dataoutx(i*8+7 downto i*8); end if;
            end loop;
          end process;
          reg : process(wclk) begin
            if rising_edge(wclk) then
              r.raddr <= raddress; r.waddr <= waddress;
              r.datain <= datain; r.write <= write;
              r.renable <= renable;
            end if;
          end process;
        end block wfrstblocknoc;
        renable2 <= renable;
      end generate;
      -- Risk of read/write contention. Use same comparator to gate read enable
      -- and mux data.
      contention_safe : if syncram_2p_dest_rw_collision(tech) /= 0 generate
        wfrstblockc : block
          signal col, mux : std_logic_vector((dbits/8-1) downto 0);
          signal rdatain : std_logic_vector((dbits-1) downto 0);
        begin
          comb : process(mux, renable, write, raddress, waddress, rdatain,
                         dataoutx, testin)
          begin
            for i in 0 to dbits/8-1 loop
              col(i) <= '0'; renable2(i) <= renable(i);
              if (write(i) and renable(i)) = '1' and raddress = waddress then
                col(i) <= '1'; renable2(i) <= '0';
              end if;
              if (SCANTESTBP and (testin(3) = '1')) or mux(i) = '1' then
                dataout(i*8+7 downto i*8) <= rdatain(i*8+7 downto i*8);
              else dataout(i*8+7 downto i*8) <= dataoutx(i*8+7 downto i*8); end if;
            end loop;
          end process;
          reg : process(wclk) begin
            if rising_edge(wclk) then
              rdatain <= datain; mux <= col;
            end if;
          end process;
        end block wfrstblockc;
      end generate;
    end generate wrfst_gen;
  
    custominx <= (others => '0');
    
  nocust: if has_sram_2pbw(tech)=0 or syncram_has_customif(tech)=0 generate
    customoutx <= (others => '0');
  end generate;

  n2x : if tech = easic45 generate
      x0 : n2x_syncram_2p_be generic map (abits, dbits, sepclk, iwrfst)
        port map (rclk, renable2, raddress, dataoutx, wclk,
                  write, waddress, datain);
    end generate;
-- pragma translate_off
    noram : if has_2pram(tech) = 0 generate
      x : process
      begin
        assert false report "synram_2pbw: technology " & tech_table(tech) &
          " not supported"
          severity failure;
        wait;
      end process;
    end generate;
    dmsg : if GRLIB_CONFIG_ARRAY(grlib_debug_level) >= 2 generate
      x : process
      begin
        assert false report "syncram_2pbw: " & tost(2**abits) & "x" & tost(dbits) &
          " (" & tech_table(tech) & ")"
          severity note;
        wait;
      end process;
    end generate;
    generic_check : process
    begin
      assert sepclk = 0 or wrfst = 0
        report "syncram_2pbw: Write-first not supported for RAM with separate clocks"
        severity failure;
      wait;
    end process;
-- pragma translate_on
  end generate;

  nos2pbw : if has_sram_2pbw(tech) /= 1 generate
    rx : for i in 0 to dbits/8-1 generate
      x0 : syncram_2p generic map (tech, abits, 8, sepclk, wrfst, testen, words, custombits)
        port map (rclk, renable(i), raddress, dataout(i*8+7 downto i*8), wclk, write(i),
                  waddress, datain(i*8+7 downto i*8), testin
                  );
    end generate;
  end generate;

end;

