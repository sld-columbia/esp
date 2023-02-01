-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Testbench of the AHB adapter for the bsg_dmc
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.libdcom.all;
use work.sim.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.ahb2mig_7series_pkg.all;

use work.grlib_config.all;
use work.esp_global.all;
use work.socmap.all;
use work.pads_loc.all;

entity bsg_dmc_tb is

end;


architecture behav of bsg_dmc_tb is

  -- LPDDR
  component mobile_ddr is
    port (
      Clk   : in    std_logic;          -- std_logic
      Clk_n : in    std_logic;
      Cke   : in    std_logic;
      Cs_n  : in    std_logic;
      Ras_n : in    std_logic;
      Cas_n : in    std_logic;
      We_n  : in    std_logic;
      Addr  : in    std_logic_vector(13 downto 0);
      Ba    : in    std_logic_vector(1 downto 0);
      Dq    : inout std_logic_vector(15 downto 0);
      Dqs   : inout std_logic_vector(1 downto 0);
      Dm    : in    std_logic_vector(1 downto 0));
  end component mobile_ddr;

  component ahb2bsg_dmc is
    port (
      hindex          : in  integer;
      haddr           : in  integer;
      hmask           : in  integer;
      lpddr_ck_p      : out std_logic;
      lpddr_ck_n      : out std_logic;
      lpddr_cke       : out std_logic;
      lpddr_ba        : out std_logic_vector(2 downto 0);
      lpddr_addr      : out std_logic_vector(15 downto 0);
      lpddr_cs_n      : out std_logic;
      lpddr_ras_n     : out std_logic;
      lpddr_cas_n     : out std_logic;
      lpddr_we_n      : out std_logic;
      lpddr_reset_n   : out std_logic;
      lpddr_odt       : out std_logic;
      lpddr_dm_oen    : out std_logic_vector(3 downto 0);
      lpddr_dm        : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_p_i   : in  std_logic_vector(3 downto 0);
      lpddr_dqs_n_oen : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_ien : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_o   : out std_logic_vector(3 downto 0);
      lpddr_dqs_n_i   : in  std_logic_vector(3 downto 0);
      lpddr_dq_oen    : out std_logic_vector(31 downto 0);
      lpddr_dq_o      : out std_logic_vector(31 downto 0);
      lpddr_dq_i      : in  std_logic_vector(31 downto 0);
      ddr_cfg0        : in  std_logic_vector(31 downto 0);
      ddr_cfg1        : in  std_logic_vector(31 downto 0);
      ddr_cfg2        : in  std_logic_vector(31 downto 0);
      ahbso           : out ahb_slv_out_type;
      ahbsi           : in  ahb_slv_in_type;
      calib_done      : out std_logic;
      ui_clk          : in  std_logic;
      ui_rstn         : in  std_logic;
      phy_clk_1x      : in  std_logic;
      phy_clk_2x      : in  std_logic;
      phy_rstn        : in  std_logic);
  end component ahb2bsg_dmc;

  -- DDR_CFG0
  constant ddr_cfg0 : std_logic_vector(31 downto 0) :=
    X"2" &  X"A" &  X"F" &  X"1" & X"3FF" &   X"4";
  -- | 31-28 | 27-24 | 23-20 | 19-16 |  15-4  |    3-0    |
  -- |  trp  |  trc  |  trfc |  tmrd |  trefi | delay_sel |

  -- DDR_CFG1
  constant ddr_cfg1 : std_logic_vector(31 downto 0) :=
    X"B"   & X"3"  & X"A"  & X"7"  &  X"A" & X"2" & X"1" &  X"7";
  -- |   31-28   | 27-24 | 23-20 | 19-16 | 15-12 | 11-8 |  7-4 |  3-0 |
  -- | col_width | tcas  | trtp  | twtr  |  twr  | trcd | trrd | tras |

  -- DDR_CFG2
  constant ddr_cfg2 : std_logic_vector(31 downto 0) :=
    '0' &    X"9C4A"  &    "011"    & "011001" &    "10"    &    X"E";
  -- | 31 |     30-15   |    14-12    |   11-6   |     5-4    |    3-0    |
  -- | /  | init_cycles | dqs_sel_cal | bank_pos | bank_width | row_width |

  signal ahbsi : ahb_slv_in_type := ahbs_in_none;
  signal ahbso : ahb_slv_out_type;

  signal calib_done : std_logic;

  signal ui_rstn : std_logic := '0';
  signal ui_clk : std_ulogic;
  signal phy_clk_1x : std_logic := '0';
  signal phy_clk_2x : std_logic := '0';
  signal phy_rstn : std_logic := '0';

  signal lpddr_o_calib_done  : std_ulogic;
  signal lpddr_o_ck_p        : std_logic;
  signal lpddr_o_ck_n        : std_logic;
  signal lpddr_o_cke         : std_logic;
  signal lpddr_o_ba          : std_logic_vector(2 downto 0);
  signal lpddr_o_addr        : std_logic_vector(15 downto 0);
  signal lpddr_o_cs_n        : std_logic;
  signal lpddr_o_ras_n       : std_logic;
  signal lpddr_o_cas_n       : std_logic;
  signal lpddr_o_we_n        : std_logic;
  signal lpddr_o_reset_n     : std_logic;
  signal lpddr_o_odt         : std_logic;
  signal lpddr_o_dm_oen      : std_logic_vector(3 downto 0);
  signal lpddr_o_dm          : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_p_oen   : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_p_ien   : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_p_o     : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_n_oen   : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_n_ien   : std_logic_vector(3 downto 0);
  signal lpddr_o_dqs_n_o     : std_logic_vector(3 downto 0);
  signal lpddr_o_dq_oen      : std_logic_vector(31 downto 0);
  signal lpddr_o_dq_o        : std_logic_vector(31 downto 0);
  signal lpddr_i_dqs_p_i     : std_logic_vector(3 downto 0);
  signal lpddr_i_dqs_n_i     : std_logic_vector(3 downto 0);
  signal lpddr_i_dq_i        : std_logic_vector(31 downto 0);

  signal lpddr0_ck_p        :  std_logic;
  signal lpddr0_ck_n        :  std_logic;
  signal lpddr0_cke         :  std_logic;
  signal lpddr0_ba          :  std_logic_vector(2 downto 0);
  signal lpddr0_addr        :  std_logic_vector(15 downto 0);
  signal lpddr0_cs_n        :  std_logic;
  signal lpddr0_ras_n       :  std_logic;
  signal lpddr0_cas_n       :  std_logic;
  signal lpddr0_we_n        :  std_logic;
  signal lpddr0_reset_n     :  std_logic;
  signal lpddr0_odt         :  std_logic;
  signal lpddr0_dm          :  std_logic_vector(3 downto 0);
  signal lpddr0_dqs_p       :  std_logic_vector(3 downto 0);
  signal lpddr0_dqs_n       :  std_logic_vector(3 downto 0);
  signal lpddr0_dq          :  std_logic_vector(31 downto 0);

begin  -- architecture behav

  phy_rstn       <= '1'              after 2500 ns;
  ui_rstn        <= '1'              after 2500 ns;

  process
  begin
    phy_clk_2x <= '0';
    wait for 5 ns;
    while true loop
      phy_clk_2x <= not phy_clk_2x;
      wait for 1.25 ns;
    end loop;
  end process;

  process
  begin
    phy_clk_1x <= '0';
    while true loop
      phy_clk_1x <= not phy_clk_1x;
      wait for 2.5 ns;
    end loop;
  end process;

  process
  begin
    ui_clk <= '0';
    wait for 6.25 ns;
    while true loop
      ui_clk <= not ui_clk;
      wait for 2.5 ns;
    end loop;
  end process;


  lpddr0_ck_p_pad    : outpad    generic map (loc => lpddr0_ck_p_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                          port map (lpddr0_ck_p, lpddr_o_ck_p, X"00003");
  lpddr0_ck_n_pad    : outpad    generic map (loc => lpddr0_ck_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                          port map (lpddr0_ck_n, lpddr_o_ck_n, X"00003");
  lpddr0_cke_pad     : outpad    generic map (loc => lpddr0_cke_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                           port map (lpddr0_cke, lpddr_o_cke, X"00003");
  lpddr0_ba_pad      : outpadv   generic map (loc => lpddr0_ba_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 3)                port map (lpddr0_ba, lpddr_o_ba, X"00003");
  lpddr0_addr_pad    : outpadv   generic map (loc => lpddr0_addr_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 16)             port map (lpddr0_addr, lpddr_o_addr, X"00003");
  lpddr0_cs_n_pad    : outpad    generic map (loc => lpddr0_cs_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                          port map (lpddr0_cs_n, lpddr_o_cs_n, X"00003");
  lpddr0_ras_n_pad   : outpad    generic map (loc => lpddr0_ras_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                         port map (lpddr0_ras_n, lpddr_o_ras_n, X"00003");
  lpddr0_cas_n_pad   : outpad    generic map (loc => lpddr0_cas_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                         port map (lpddr0_cas_n, lpddr_o_cas_n, X"00003");
  lpddr0_we_n_pad    : outpad    generic map (loc => lpddr0_we_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                          port map (lpddr0_we_n, lpddr_o_we_n, X"00003");
  lpddr0_reset_n_pad : outpad    generic map (loc => lpddr0_reset_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                       port map (lpddr0_reset_n, lpddr_o_reset_n, X"00003");
  lpddr0_odt_pad     : outpad    generic map (loc => lpddr0_odt_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)                           port map (lpddr0_odt, lpddr_o_odt, X"00003");
  lpddr0_dm_pad      : iopadvv   generic map (loc => lpddr0_dm_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4, oepol => 0)    port map (lpddr0_dm, lpddr_o_dm, lpddr_o_dm_oen, open, X"00003");
  lpddr0_dqs_p_pad   : iopadienv generic map (loc => lpddr0_dqs_p_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4, oepol => 0) port map (lpddr0_dqs_p, lpddr_o_dqs_p_o, lpddr_o_dqs_p_oen, lpddr_i_dqs_p_i, lpddr_o_dqs_p_ien, X"00003");
  lpddr0_dqs_n_pad   : iopadienv generic map (loc => lpddr0_dqs_n_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 4, oepol => 0) port map (lpddr0_dqs_n, lpddr_o_dqs_n_o, lpddr_o_dqs_n_oen, lpddr_i_dqs_n_i, lpddr_o_dqs_n_ien, X"00003");
  lpddr0_dq_pad      : iopadvv   generic map (loc => lpddr0_dq_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => 32, oepol => 0)   port map (lpddr0_dq, lpddr_o_dq_o, lpddr_o_dq_oen, lpddr_i_dq_i, X"00003");


  ahb2bsg_dmc_1: ahb2bsg_dmc
    port map (
      hindex          => 0,
      haddr           => 16#000#,
      hmask           => 16#E00#,
      lpddr_ck_p      => lpddr_o_ck_p,
      lpddr_ck_n      => lpddr_o_ck_n,
      lpddr_cke       => lpddr_o_cke,
      lpddr_ba        => lpddr_o_ba,
      lpddr_addr      => lpddr_o_addr,
      lpddr_cs_n      => lpddr_o_cs_n,
      lpddr_ras_n     => lpddr_o_ras_n,
      lpddr_cas_n     => lpddr_o_cas_n,
      lpddr_we_n      => lpddr_o_we_n,
      lpddr_reset_n   => lpddr_o_reset_n,
      lpddr_odt       => lpddr_o_odt,
      lpddr_dm_oen    => lpddr_o_dm_oen,
      lpddr_dm        => lpddr_o_dm,
      lpddr_dqs_p_oen => lpddr_o_dqs_p_oen,
      lpddr_dqs_p_ien => lpddr_o_dqs_p_ien,
      lpddr_dqs_p_o   => lpddr_o_dqs_p_o,
      lpddr_dqs_p_i   => lpddr_i_dqs_p_i,
      lpddr_dqs_n_oen => lpddr_o_dqs_n_oen,
      lpddr_dqs_n_ien => lpddr_o_dqs_n_ien,
      lpddr_dqs_n_o   => lpddr_o_dqs_n_o,
      lpddr_dqs_n_i   => lpddr_i_dqs_n_i,
      lpddr_dq_oen    => lpddr_o_dq_oen,
      lpddr_dq_o      => lpddr_o_dq_o,
      lpddr_dq_i      => lpddr_i_dq_i,
      ddr_cfg0        => ddr_cfg0,
      ddr_cfg1        => ddr_cfg1,
      ddr_cfg2        => ddr_cfg2,
      ahbso           => ahbso,
      ahbsi           => ahbsi,
      calib_done      => calib_done,
      ui_clk          => ui_clk,
      ui_rstn         => ui_rstn,
      phy_clk_1x      => phy_clk_1x,
      phy_clk_2x      => phy_clk_2x,
      phy_rstn        => phy_rstn);

  x0 : mobile_ddr
    port map (
      Clk   => lpddr0_ck_p,
      Clk_n => lpddr0_ck_n,
      Cke   => lpddr0_cke,
      Cs_n  => lpddr0_cs_n,
      Ras_n => lpddr0_ras_n,
      Cas_n => lpddr0_cas_n,
      We_n  => lpddr0_we_n,
      Addr  => lpddr0_addr(13 downto 0),
      Ba    => lpddr0_ba(1 downto 0),
      Dq    => lpddr0_dq(16 * (0 + 1) - 1 downto 16 * 0),
      Dqs   => lpddr0_dqs_p(2 * (0 + 1) - 1 downto 2 * 0),
      Dm    => lpddr0_dm(2 * (0 + 1) - 1 downto 2 * 0));

  x1 : mobile_ddr
    port map (
      Clk   => lpddr0_ck_p,
      Clk_n => lpddr0_ck_n,
      Cke   => lpddr0_cke,
      Cs_n  => lpddr0_cs_n,
      Ras_n => lpddr0_ras_n,
      Cas_n => lpddr0_cas_n,
      We_n  => lpddr0_we_n,
      Addr  => lpddr0_addr(13 downto 0),
      Ba    => lpddr0_ba(1 downto 0),
      Dq    => lpddr0_dq(16 * (1 + 1) - 1 downto 16 * 1),
      Dqs   => lpddr0_dqs_p(2 * (1 + 1) - 1 downto 2 * 1),
      Dm    => lpddr0_dm(2 * (1 + 1) - 1 downto 2 * 1));

end architecture behav;
