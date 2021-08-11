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


entity fpga_proxy_jtag is
  port (
    rst   : in  std_ulogic;
    tdi   : out std_ulogic;
    tdo   : in  std_ulogic;
    tms   : in  std_ulogic;
    tclk  : in  std_ulogic;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type);

end;


architecture rtl of fpga_proxy_jtag is

  constant CFG_APBADDR_FP    : integer := 16#100#;
  constant ahb2apb_hmask_fp  : integer := 16#FFF#;
  constant ahb2apb_hindex_fp : integer := 0;

  constant apb_slv_mask : std_logic_vector(0 to NAPBSLV - 1) := (
    0      => '1',
    1      => '1',
    others => '0');

  type jtag_state_type is (idle, pop_fifo, check_type_extract,
                           extract_source, extract_flit, inject,
                           push_fifo);

  type jtag_ctrl_t is record
    state : jtag_state_type;
  end record jtag_ctrl_t;

  constant JTAG_CTRL_RESET : jtag_ctrl_t := (
    state => idle
    );


  signal r, rin : jtag_ctrl_t;


-- APB BUS
  signal apbi : apb_slv_in_type;
  signal apbo : apb_slv_out_vector;

  signal count : integer range 0 to 255;

  signal ack_r : std_logic;

  signal test_out : std_logic_vector(73 downto 0);

  signal source_sipo_en, testout_sipo_en : std_logic;

  signal testin_piso_clear, testin_piso_load : std_logic;
  signal testin_piso_en, count_clear, source_sipo_clear  : std_logic;
  signal testout_sipo_clear, count_en, ack2apb           : std_logic;
  signal ack2apb_r, apbreq                               : std_logic;
  signal sel_tdo                                         : std_logic_vector(1 downto 0);

  signal source_sipo_out, req_flit, wr_flit, ack : std_logic_vector(5 downto 0);

  attribute mark_debug : string;

  attribute mark_debug of apbi : signal is "true";
  attribute mark_debug of apbo : signal is "true";

  attribute mark_debug of r : signal is "true";

  attribute mark_debug of source_sipo_en : signal is "true";
  attribute mark_debug of source_sipo_clear : signal is "true";
  attribute mark_debug of source_sipo_out : signal is "true";

  attribute mark_debug of testout_sipo_en : signal is "true";
  attribute mark_debug of testout_sipo_clear : signal is "true";
  attribute mark_debug of test_out : signal is "true";

  attribute mark_debug of testin_piso_en : signal is "true";
  attribute mark_debug of testin_piso_clear : signal is "true";
  attribute mark_debug of testin_piso_load : signal is "true";


  attribute mark_debug of ack2apb_r : signal is "true";
  attribute mark_debug of ack2apb : signal is "true";
  attribute mark_debug of apb_req : signal is "true";
  attribute mark_debug of req_flit : signal is "true";
  attribute mark_debug of wr_flit : signal is "true";
  attribute mark_debug of ack : signal is "true";


  attribute mark_debug of count_clear : signal is "true";
  attribute mark_debug of count_en : signal is "true";


begin

  apb_ctrl_norm : patient_apbctrl       -- AHB/APB bridge
    generic map
    (hindex     => ahb2apb_hindex_fp,
     haddr      => CFG_APBADDR_FP,
     hmask      => ahb2apb_hmask_fp,
     nslaves    => NAPBSLV,
     remote_apb => apb_slv_mask)
    port map
    (rst,
     tclk,
     ahbsi,
     ahbso,
     apbi,
     apbo,
     apbreq,
     ack_r);


  process (apbi, ack2apb, ack2apb_r)
  begin
    if apbi.psel(0) = '1' then
      ack_r <= ack2apb;
    elsif apbi.psel(1) = '1' then
      ack_r <= ack2apb_r;
    else
      ack_r <= '0';
    end if;
  end process;


  apb2jtagdev : apb2jtag
    port map(
      rst      => rst,
      tclk     => tclk,
      apbi     => apbi,
      apbo     => apbo(0),
      ack_w    => ack,
      apbreq   => apbreq,
      ack2apb  => ack2apb,
      req_flit => req_flit,
      piso_c   => testin_piso_clear,
      piso_l   => testin_piso_load,
      piso_en  => testin_piso_en,
      tdi      => tdi);

  jtag2apbdev : jtag2apb
    port map (
      rst       => rst,
      tclk      => tclk,
      apbi      => apbi,
      apbo      => apbo(1),
      apbreq    => apbreq,
      ack2apb   => ack2apb_r,
      wr_flit   => wr_flit,
      sipo1_c   => source_sipo_clear,
      sipo1_en  => source_sipo_en,
      sipo2_c   => testout_sipo_clear,
      sipo2_en  => testout_sipo_en,
      tdo       => tdo,
      sel_tdo   => sel_tdo,
      sipo1_out => source_sipo_out,
      sipo2_out => test_out);

  CU_REG : process (tclk, rst)
  begin
    if rst = '0' then
      r <= JTAG_CTRL_RESET;
    elsif tclk'event and tclk = '1' then
      r <= rin;
    end if;
  end process CU_REG;


  NSL : process(r, tdo, tms, count, test_out, source_sipo_out)

    variable v : jtag_ctrl_t;

  begin
    -- Default assignments
    v := r;
    --

    testin_piso_clear <= '0';
    testin_piso_load  <= '0';
    testin_piso_en    <= '0';

    testout_sipo_en   <= '0';
    testout_sipo_clear <= '0';

    sel_tdo <= "00";

    count_en    <= '0';
    count_clear <= '0';

    req_flit <= (others => '0');
    wr_flit  <= (others => '0');

    source_sipo_clear <= '0';
    source_sipo_en <= '0';

    case r.state is

      when idle =>
        if tms = '1' and tdo = '1' then
          v.state := check_type_extract;
        end if;

      when check_type_extract =>
        if tdo = '1' then
          v.state := extract_source;
          sel_tdo <= "10";
        else
          v.state := extract_flit;
          sel_tdo <= "01";
        end if;
        count_en <= '1';

      when extract_source => sel_tdo <= "10";
                             source_sipo_en <= '1';
                             count_en          <= '1';
                             if count = 7 then
                               source_sipo_en <= '0';
                               count_clear       <= '1';
                               v.state           := pop_fifo;
                             end if;

      when pop_fifo => req_flit <= source_sipo_out;
                       testin_piso_load <= '1';
                       v.state          := inject;

      when inject => source_sipo_clear <= '1';
                     count_en       <= '1';
                     testin_piso_en <= '1';
                     if count = 75 then
                       count_clear       <= '1';
                       testin_piso_clear <= '1';
                       testin_piso_en    <= '0';
                       v.state           := idle;
                     end if;

      when extract_flit => sel_tdo <= "01";
                           testout_sipo_en <= '1';
                           count_en         <= '1';
                           if count = 74 then
                             wr_flit          <= test_out(5 downto 0);
                             count_clear      <= '1';
                             testout_sipo_en <= '0';
                             v.state          := push_fifo;
                           end if;

      when push_fifo => testout_sipo_clear <= '1';
                        v.state := idle;

    end case;

    rin <= v;

  end process NSL;



  counter_j0 : counter_jtag
    port map(
      clk    => tclk,
      clear  => count_clear,
      enable => count_en,
      co     => count);


end;

