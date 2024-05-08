-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- Entity:      svga2tfp410
-- File:        svga2tfp410.vhd
-- Author:      Paolo Mantovani @ Columbia University
--
-- Description: Converter inteneded to connect a SVGACTRL core to a TI TFP410
--              DVI transmitter. Assumes 80MHz input clock and generates 40MHz
--              output clock, compatiple with screen mode VESA 800x600 @ 60Hz
--              Ohter clocks could be generated but we prefer to save clock
--              FGPA clock resources for other purposes.
--
--              24-bits color scheme:
--              data[23:16] : R
--              data[15:8]  : G
--              data[7:0]   : B
--
-- This core assumes a 80 MHz input clock on the 'clk' input.
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use work.misc.all;
  use work.stdlib.all;
-- pragma translate_off

library unisim;
  use unisim.bufg;
  -- pragma translate_on
  use work.gencomp.all;
  use work.svga_pkg.all;

entity svga2tfp410 is
  generic (
    tech : integer := 0
  );
  port (
    clk         : in    std_ulogic;
    rstn        : in    std_ulogic;
    vgao        : in    apbvga_out_type;
    vgaclk_fb   : in    std_ulogic;
    vgaclk      : out   std_ulogic;
    idck_p      : out   std_ulogic;
    idck_n      : out   std_ulogic;
    data        : out   std_logic_vector(23 downto 0);
    hsync       : out   std_ulogic;
    vsync       : out   std_ulogic;
    de          : out   std_ulogic;
    dken        : out   std_ulogic;
    ctl1_a1_dk1 : out   std_ulogic;
    ctl2_a2_dk2 : out   std_ulogic;
    a3_dk3      : out   std_ulogic;
    isel        : out   std_ulogic;
    bsel        : out   std_ulogic;
    dsel        : out   std_ulogic;
    edge        : out   std_ulogic;
    npd         : out   std_ulogic
  );
end entity svga2tfp410;

architecture rtl of svga2tfp410 is

  component bufg is
    port (
      o : out   std_logic;
      i : in    std_logic
    );
  end component;

  signal red   : std_logic_vector(7 downto 0);
  signal green : std_logic_vector(7 downto 0);
  signal blue  : std_logic_vector(7 downto 0);

  signal clk40 : std_ulogic;

  signal vcc, gnd : std_logic;

begin  -- rtl

  vcc <= '1'; gnd <= '0';

  -----------------------------------------------------------------------------
  -- TFP410 constants when I2C interface is not active
  -----------------------------------------------------------------------------

  -- No deskew needed
  dken        <= '0';
  ctl1_a1_dk1 <= '0';
  ctl2_a2_dk2 <= '0';
  a3_dk3      <= '0';

  -- Disable I2C
  isel <= '0';

  -- 24-bits color schime single edge
  bsel <= '1';

  -- Single-ended clock
  dsel <= '0';

  -- sample at risign edge
  edge <= '1';

  -- normal operation (Use '0' for powerdown. Could be dynamically set from SVGA)
  npd <= '1';

  -----------------------------------------------------------------------------
  -- RGB data
  -----------------------------------------------------------------------------
  red   <= vgao.video_out_r;
  green <= vgao.video_out_g;
  blue  <= vgao.video_out_b;

  data <= red & green & blue;

  -----------------------------------------------------------------------------
  -- Sync signals
  -----------------------------------------------------------------------------

  process (vgaclk_fb) is
  begin  -- process

    if rising_edge(vgaclk_fb) then
      hsync <= vgao.hsync;
      vsync <= vgao.vsync;
      de    <= vgao.blank;
    end if;

  end process;

  -----------------------------------------------------------------------------
  -- Clock generation
  -----------------------------------------------------------------------------

  ddroreg_p : component ddr_oreg
    generic map (
tech
    )
    port map (
      q  => idck_p,
      c1 => vgaclk_fb,
      c2 => gnd,
      ce => vcc,
      d1 => vcc,
      d2 => gnd,
      r  => gnd,
      s  => gnd
    );

  -- Differential clock
  -- ddroreg_n : ddr_oreg generic map (tech)
  --  port map (q => idck_n, c1 => vgaclk_fb, c2 => gnd, ce => vcc,
  --            d1 => gnd, d2 => vcc, r => gnd, s => gnd);

  -- Single-ended clock
  idck_n <= '0';

  -- Clock selection is disabled: we only support 40MHz pixel clock to reduce
  -- clock resources usage.
  clkdiv : process (clk, rstn) is
  begin

    if (rstn = '0') then
      clk40 <= '0';
    elsif rising_edge(clk) then
      clk40 <= not clk40;
    end if;

  end process clkdiv;

  bufg0 : component bufg
    port map (
      i => clk40,
      o => vgaclk
    );

end architecture rtl;
