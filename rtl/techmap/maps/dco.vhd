-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.config.all;
use work.config_types.all;
use work.gencomp.all;
use work.misc.all;
use work.alldco.all;


entity dco is

  generic (
    tech : integer;
    enable_div2 : integer range 0 to 1 := 0;
    dlog : integer range 0 to 15 := 10);      -- log2(delay raw reset to lock)
  port (
    rstn     : in  std_ulogic;
    ext_clk  : in  std_logic;
    en       : in  std_ulogic;
    clk_sel  : in  std_ulogic;
    cc_sel   : in  std_logic_vector(5 downto 0);
    fc_sel   : in  std_logic_vector(5 downto 0);
    div_sel  : in  std_logic_vector(2 downto 0);
    freq_sel : in  std_logic_vector(1 downto 0);
    clk      : out std_logic;
    clk_div  : out std_logic;
    clk_div2 : out std_logic;
    clk_div2_90 : out std_logic;
    lock     : out std_ulogic);

end entity dco;

architecture rtl of dco is

  signal clk_int : std_ulogic;
  signal sync_rstn : std_ulogic;
  signal count : std_logic_vector(15 downto 0);

begin  -- architecture rtl


  -- Generate synchronous reset for lock counter
  rst0 : rstgen                         -- reset generator
    generic map (acthigh => 0, syncin => 0)
    port map (rstn, clk_int, '1', sync_rstn, open);


  -- generate lock output after 2^dlog cycles
  process (clk_int, sync_rstn) is
  begin  -- process
    if sync_rstn = '0' then                  -- asynchronous reset (active low)
      count <= (others => '0');
    elsif clk_int'event and clk_int = '1' then  -- rising clock edge
      if count(dlog) /= '1' then
        count <= count + X"0001";
      end if;
    end if;
  end process;

  gf12_gen : if (tech = gf12) generate

    x0 : gf12_dco
      generic map (
        enable_div2 => enable_div2)
      port map (
        RSTN     => rstn,
        EXT_CLK  => ext_clk,
        EN       => en,
        CLK_SEL  => clk_sel,
        CC_SEL   => cc_sel,
        FC_SEL   => fc_sel,
        DIV_SEL  => div_sel,
        FREQ_SEL => freq_sel,
        CLK      => clk_int,
        CLK_DIV2    => clk_div2,
        CLK_DIV2_90 => clk_div2_90,
        CLK_DIV  => clk_div);

    clk <= clk_int;
    lock <= count(dlog);

  end generate;

-- pragma translate_off
  noram : if has_dco(tech) = 0 generate
    x : process
    begin
      assert false report "dco: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end architecture rtl;
