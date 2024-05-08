-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
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
    rst        : in    std_ulogic;
    tclk       : in    std_logic;
    main_clk   : in    std_logic;
    apbi       : in    apb_slv_in_type;
    apbo       : out   apb_slv_out_type;
    apbreq     : in    std_logic;
    ack2apb    : out   std_logic;
    req_flit   : in    std_logic_vector(5 downto 0);
    empty_fifo : out   std_logic_vector(5 downto 0);
    piso_c     : in    std_logic;
    piso_l     : in    std_logic;
    piso_en    : in    std_logic;
    load_invld : in    std_logic;
    tdi        : out   std_logic
  );
end entity apb2jtag;

architecture rtl of apb2jtag is

  constant REG_A2J_PINDEX         : integer range 0 to NAPBSLV - 1                   := 0;
  constant REG_A2J_PADDR          : integer range 0 to 4095                          := 16#100#;
  constant REG_A2J_PMASK          : integer range 0 to 4095                          := 16#FFF#;
  constant INVLD_FLIT             : std_logic_vector(MAX_NOC_FLIT_SIZE + 8 downto 0) := conv_std_logic_vector(5, MAX_NOC_FLIT_SIZE + 9);
  signal   this_paddr, this_pmask : integer range 0 to 4095;
  signal   this_pirq              : integer range 0 to 15;

  signal this_pconfig : apb_config_type;

  type tracein_t is array(0 to 5) of std_logic_vector(74 downto 0);

  signal tracein,      tracein1 : tracein_t;

  signal tdi_in : std_logic;

  signal full_fifo  : std_logic_vector(5 downto 0);
  signal en_fifo_in : std_logic_vector(5 downto 0);
  signal ack        : std_logic_vector(5 downto 0);
  signal trace_in   : std_logic_vector(74 downto 0);
  signal fifo_out   : std_logic_vector(74 downto 0);
  signal piso_in    : std_logic_vector(74 downto 0);

  attribute mark_debug : string;

  attribute mark_debug of trace_in   : signal is "true";
  attribute mark_debug of en_fifo_in : signal is "true";

  attribute mark_debug of full_fifo : signal is "true";

  attribute mark_debug of tracein  : signal is "true";
  attribute mark_debug of tracein1 : signal is "true";
  attribute mark_debug of fifo_out : signal is "true";

  attribute mark_debug of ack : signal is "true";

begin

  this_paddr <= REG_A2J_PADDR;
  this_pmask <= REG_A2J_PMASK;
  this_pirq  <= 0;

  this_pconfig(0) <= ahb_device_reg (VENDOR_SLD, 0, 0, 0, 0);
  this_pconfig(1) <= apb_iobar(this_paddr, this_pmask);
  this_pconfig(2) <= (others => '0');

  ack <= not(full_fifo);

  apb2jtag_reg_i : component apb2jtag_reg
    generic map (
      pindex => 0
    )
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

  demux_i : component demux_1to6_vs
    generic map (
      sz => MAX_NOC_FLIT_SIZE + 9
    )
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

  gen_fifos_apb2jtag : for i in 0 to 5 generate

    async_fifo_01 : component inferred_async_fifo
      generic map (
        g_data_width => MAX_NOC_FLIT_SIZE + 9,
        g_size       => 200
      )
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
        rd_empty_o => empty_fifo(i)
      );

  end generate gen_fifos_apb2jtag;

  mux_6to1_1 : component mux_6to1
    generic map (
      sz => MAX_NOC_FLIT_SIZE + 9
    )
    port map (
      sel => req_flit,
      a   => tracein1(5),
      b   => tracein1(4),
      c   => tracein1(3),
      d   => tracein1(2),
      e   => tracein1(1),
      f   => tracein1(0),
      x   => fifo_out
    );

  piso_in <= fifo_out when load_invld = '0' else
             INVLD_FLIT;

  piso0 : component piso_jtag
    generic map (
      sz        => MAX_NOC_FLIT_SIZE + 9,
      shift_dir => 1
    )
    port map (
      rst      => rst,
      clk      => tclk,
      clear    => piso_c,
      load     => piso_l,
      a        => piso_in,
      shift_en => piso_en,
      y        => tdi_in,
      done     => open
    );

  tdi <= tdi_in;

end architecture rtl;
