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



entity jtag2apb is
  port (
    rst     : in  std_ulogic;
    tclk    : in  std_logic;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    apbreq  : in  std_logic;
    ack2apb : out std_logic;
    wr_flit : in  std_logic_vector(5 downto 0);

    sipo1_c  : in std_logic;
    sipo1_en : in std_logic;
    sipo2_c  : in std_logic;
    sipo2_en : in std_logic;

    tdo     : in std_logic;
    sel_tdo : in std_logic_vector(1 downto 0);

    sipo1_out : out std_logic_vector(5 downto 0);
    sipo2_out : out std_logic_vector(73 downto 0));

end jtag2apb;


architecture rtl of jtag2apb is

  constant reg_j2a_pindex : integer range 0 to NAPBSLV - 1 := 0;
  constant reg_j2a_paddr  : integer range 0 to 4095        := 16#101#;
  constant reg_j2a_pmask  : integer range 0 to 4095        := 16#FFF#;

  constant ZERO_22 : std_logic_vector(21 downto 0) := (others => '0');

  signal sipo1out, fifo_c, req_fifo, req_fifo1, empty_fifo_out : std_logic_vector(5 downto 0);
  signal in_p                                                  : std_logic_vector(95 downto 0);

  signal test_out, fifo_out_d : std_logic_vector(73 downto 0);

  signal this_paddr, this_pmask : integer range 0 to 4095;
  signal this_pirq              : integer range 0 to 15;

  signal this_pconfig : apb_config_type;

  signal tdo1, tdo2 : std_logic;

  signal ack2apb_r : std_logic;

  type fifout_t is array(0 to 5) of std_logic_vector(73 downto 0);
  signal fifo_out_data : fifout_t;

begin

  sipo1_out <= sipo1out;
  sipo2_out <= test_out;
  ack2apb   <= ack2apb_r;

  GEN_FIFOS_jtag2apb : for i in 0 to 5 generate

    req_fifo1(i) <= req_fifo(5-i) and not(empty_fifo_out(i));

    fifo_out_ii : fifo0
      generic map (
        depth => 20,
        width => NOC_FLIT_SIZE+8)
      port map (
        clk      => tclk,
        rst      => rst,
        rdreq    => req_fifo1(i),
        wrreq    => wr_flit(5-i),
        data_in  => test_out,
        empty    => empty_fifo_out(i),
        full     => open,
        data_out => fifo_out_data(i)(73 downto 0));

  end generate GEN_FIFOS_jtag2apb;

  mux_6to1_2 : mux_6to1
    generic map(sz => NOC_FLIT_SIZE+8)
    port map(
      sel => req_fifo,
      A   => fifo_out_data(0),
      B   => fifo_out_data(1),
      C   => fifo_out_data(2),
      D   => fifo_out_data(3),
      E   => fifo_out_data(4),
      F   => fifo_out_data(5),
      X   => fifo_out_d);


  this_paddr <= reg_j2a_paddr;
  this_pmask <= reg_j2a_pmask;
  this_pirq  <= 0;

  this_pconfig(0) <= ahb_device_reg (VENDOR_SLD, 0, 0, 0, 0);
  this_pconfig(1) <= apb_iobar(this_paddr, this_pmask);
  this_pconfig(2) <= (others => '0');

  fifo_c <= not(empty_fifo_out);
  in_p   <= ZERO_22 & fifo_out_d;

  jtag2apb_reg_i : jtag2apb_reg
    generic map (
      pindex => 1)
    port map (
      clk     => tclk,
      rstn    => rst,
      pconfig => this_pconfig,
      apbi    => apbi,
      apbo    => apbo,
      fifo_c  => fifo_c,
      req     => req_fifo,
      ack2apb => ack2apb_r,
      apbreq  => apbreq,
      in_p    => in_p
      );


  demux_ii : demux_1to2
    port map (
      data_in => tdo,
      sel     => sel_tdo,
      out1    => tdo1,
      out2    => tdo2);

  sipo_1 : sipo_jtag
    generic map (DIM => 6)
    port map (
      rst       => rst,
      clk       => tclk,
      clear     => sipo1_c,
      en_in     => sipo1_en,
      serial_in => tdo1,
      test_comp => sipo1out,
      data_out  => open,
      op        => open,
      done      => open,
      end_trace => open);


  sipo_2 : sipo_jtag
    generic map (DIM       => NOC_FLIT_SIZE+8,
                 shift_dir => 1)
    port map (
      rst       => rst,
      clk       => tclk,
      clear     => sipo2_c,
      en_in     => sipo2_en,
      serial_in => tdo2,
      test_comp => test_out,
      data_out  => open,
      op        => open,
      done      => open,
      end_trace => open);

end;
