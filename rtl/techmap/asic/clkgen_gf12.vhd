-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
  use ieee.std_logic_1164.all;

entity gf12_dco is
  generic (
    enable_div2 : integer range 0 to 1 := 0
  );
  port (
    rstn        : in    std_ulogic;
    ext_clk     : in    std_logic;
    en          : in    std_ulogic;
    clk_sel     : in    std_ulogic;
    cc_sel      : in    std_logic_vector(5 downto 0);
    fc_sel      : in    std_logic_vector(5 downto 0);
    div_sel     : in    std_logic_vector(2 downto 0);
    freq_sel    : in    std_logic_vector(1 downto 0);
    clk         : out   std_logic;
    clk_div2    : out   std_logic;
    clk_div2_90 : out   std_logic;
    clk_div     : out   std_logic
  );
end entity gf12_dco;

architecture rtl of gf12_dco is

  component dco_gf12_c14 is
    port (
      rstn     : in    std_ulogic;
      ext_clk  : in    std_logic;
      en       : in    std_ulogic;
      clk_sel  : in    std_ulogic;
      cc_sel   : in    std_logic_vector(5 downto 0);
      fc_sel   : in    std_logic_vector(5 downto 0);
      div_sel  : in    std_logic_vector(2 downto 0);
      freq_sel : in    std_logic_vector(1 downto 0);
      clk      : out   std_logic;
      clk_div  : out   std_logic
    );
  end component dco_gf12_c14;

  component dco_lpddr_gf12_c14 is
    port (
      rstn        : in    std_ulogic;
      ext_clk     : in    std_logic;
      en          : in    std_ulogic;
      clk_sel     : in    std_ulogic;
      cc_sel      : in    std_logic_vector(5 downto 0);
      fc_sel      : in    std_logic_vector(5 downto 0);
      div_sel     : in    std_logic_vector(2 downto 0);
      freq_sel    : in    std_logic_vector(1 downto 0);
      clk         : out   std_logic;
      clk_div2    : out   std_logic;
      clk_div2_90 : out   std_logic;
      clk_div     : out   std_logic
    );
  end component dco_lpddr_gf12_c14;

begin  -- architecture rtl

  no_div2 : if enable_div2 = 0 generate

    dco_gf12_c14_1 : component dco_gf12_c14
      port map (
        rstn     => rstn,
        ext_clk  => ext_clk,
        en       => en,
        clk_sel  => clk_sel,
        cc_sel   => cc_sel,
        fc_sel   => fc_sel,
        div_sel  => div_sel,
        freq_sel => freq_sel,
        clk      => clk,
        clk_div  => clk_div
      );

    clk_div2    <= '0';
    clk_div2_90 <= '0';
  end generate no_div2;

  with_div2 : if enable_div2 /= 0 generate

    dco_lpddr_gf12_c14_1 : component dco_lpddr_gf12_c14
      port map (
        rstn        => rstn,
        ext_clk     => ext_clk,
        en          => en,
        clk_sel     => clk_sel,
        cc_sel      => cc_sel,
        fc_sel      => fc_sel,
        div_sel     => div_sel,
        freq_sel    => freq_sel,
        clk         => clk,
        clk_div2    => clk_div2,
        clk_div2_90 => clk_div2_90,
        clk_div     => clk_div
      );

  end generate with_div2;

end architecture rtl;
