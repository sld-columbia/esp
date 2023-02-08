-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
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



entity apb2jtag is
  port (
    rst      : in  std_ulogic;
    tclk     : in  std_logic;
    main_clk : in  std_logic;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_type;
    apbreq   : in  std_logic;
    ack2apb  : out std_logic;
    req_flit : in  std_logic_vector(5 downto 0);
    empty_fifo : out std_logic_vector(5 downto 0);
    piso_c   : in  std_logic;
    piso_l   : in  std_logic;
    piso_en  : in  std_logic;
    load_invld : in std_logic;
    tdi      : out std_logic);
end apb2jtag;


architecture rtl of apb2jtag is

  constant reg_a2j_pindex : integer range 0 to NAPBSLV - 1 := 0;
  constant reg_a2j_paddr  : integer range 0 to 4095        := 16#100#;
  constant reg_a2j_pmask  : integer range 0 to 4095        := 16#FFF#;
  constant invld_flit : std_logic_vector(NOC_FLIT_SIZE+8 downto 0) := conv_std_logic_vector(5, NOC_FLIT_SIZE+8);
  signal this_paddr, this_pmask : integer range 0 to 4095;
  signal this_pirq              : integer range 0 to 15;

  signal this_pconfig : apb_config_type;

  type tracein_t is array(0 to 5) of std_logic_vector(74 downto 0);

  signal tracein, tracein1 : tracein_t;

  signal tdi_in : std_logic;

  signal full_fifo, en_fifo_in, ack : std_logic_vector(5 downto 0);
  signal trace_in, fifo_out, piso_in   : std_logic_vector(74 downto 0);

  attribute mark_debug : string;

  attribute mark_debug of trace_in : signal is "true";
  attribute mark_debug of en_fifo_in : signal is "true";

  attribute mark_debug of full_fifo : signal is "true";

  attribute mark_debug of tracein : signal is "true";
  attribute mark_debug of tracein1 : signal is "true";
  attribute mark_debug of fifo_out : signal is "true";

  attribute mark_debug of ack : signal is "true";

begin

  this_paddr <= reg_a2j_paddr;
  this_pmask <= reg_a2j_pmask;
  this_pirq  <= 0;

  this_pconfig(0) <= ahb_device_reg (VENDOR_SLD, 0, 0, 0, 0);
  this_pconfig(1) <= apb_iobar(this_paddr, this_pmask);
  this_pconfig(2) <= (others => '0');

  ack <= not(full_fifo);

  apb2jtag_reg_i : apb2jtag_reg
    generic map (
      pindex => 0)
    port map (
      clk     => main_clk,
      rstn    => rst,
      pconfig => this_pconfig,
      apbi    => apbi,
      apbo    => apbo,
      ack_w   => ack,
      ack2apb => ack2apb,
      apbreq  => apbreq,
      valid   => en_fifo_in,
      out_p   => trace_in
      );

  demux_i : demux_1to6_vs
    generic map (
      SZ => NOC_FLIT_SIZE+9)
    port map (
      data_in => trace_in,
      sel     => en_fifo_in,
      out1    => tracein(0),
      out2    => tracein(1),
      out3    => tracein(2),
      out4    => tracein(3),
      out5    => tracein(4),
      out6    => tracein(5)
      );





  GEN_FIFOS_apb2jtag : for i in 0 to 5 generate

    async_fifo_01 : inferred_async_fifo
      generic map (
        g_data_width => NOC_FLIT_SIZE+9,
        g_size       => 200)
      port map (
        rst_wr_n_i => rst,
        clk_wr_i   => main_clk,
        we_i       => en_fifo_in(i),
        d_i        => tracein(i),
        wr_full_o  => full_fifo(i),
        rst_rd_n_i => rst,
        clk_rd_i   => tclk,
        rd_i       => req_flit(i),
        q_o        => tracein1(i),
        rd_empty_o => empty_fifo(i));

  end generate GEN_FIFOS_apb2jtag;

  mux_6to1_1 : mux_6to1
    generic map(sz => NOC_FLIT_SIZE+9)
    port map(
      sel => req_flit,
      A   => tracein1(5),
      B   => tracein1(4),
      C   => tracein1(3),
      D   => tracein1(2),
      E   => tracein1(1),
      F   => tracein1(0),
      X   => fifo_out);

  piso_in <= fifo_out when load_invld = '0' else invld_flit;

  piso0 : piso_jtag
    generic map(sz        => NOC_FLIT_SIZE+9,
                shift_dir => 1)
    port map(
      rst      => rst,
      clk      => tclk,
      clear    => piso_c,
      load     => piso_l,
      A        => piso_in,
      shift_en => piso_en,
      Y        => tdi_in,
      done     => open);

  tdi <= tdi_in;


end;
