-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.amba.all;
use work.gencomp.all;

package axi2mig_pkg is 

component axi2mig_7series is
  generic(
    AXIDW                   : integer := 64;
    NUM_MEM_TILE    : integer := 2
  );
  port(
    ddr3_dq         : inout std_logic_vector(63 downto 0);
    ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    ddr3_addr       : out   std_logic_vector(13 downto 0);
    ddr3_ba         : out   std_logic_vector(2 downto 0);
    ddr3_ras_n      : out   std_logic;
    ddr3_cas_n      : out   std_logic;
    ddr3_we_n       : out   std_logic;
    ddr3_reset_n    : out   std_logic;
    ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    ddr3_cke        : out   std_logic_vector(0 downto 0);
    ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    ddr3_dm         : out   std_logic_vector(7 downto 0);
    ddr3_odt        : out   std_logic_vector(0 downto 0);
    calib_done      : out   std_logic;
    rst_n_syn       : in    std_logic;
    rst_n_async     : in    std_logic;
    sys_clk_p       : in    std_logic;
    sys_clk_n       : in    std_logic;
    clk_ref_i       : in    std_logic;
    ui_clk          : out   std_logic;
    ui_clk_sync_rst : out   std_logic;
    ddr_axi_si      : in    axi_mosi_type;
    ddr_axi_so      : out   axi_somi_type 
	);
end component; 

  component axi2mig_up is
    generic(
      AXIDW                   : integer := 64;
	  clamshell               : integer range 0 to 1
    );
    port(
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(0 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(0 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(0 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(63 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
      ddr_axi_si       : in    axi_mosi_type;
      ddr_axi_so       : out   axi_somi_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_slow      : out   std_logic;
      ui_clk_sync_rst  : out   std_logic
    );
end component;


  component axi2mig_ebddr4r5 is
    generic (
	  AXIDW  : integer := 64
      );
    port (
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
      ddr_axi_si       : in    axi_mosi_type;
      ddr_axi_so       : out   axi_somi_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      clk_amba         : out    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_sync_rst  : out   std_logic);
  end component axi2mig_ebddr4r5;


component axi2mig_7series_profpga is
  generic(
    AXIDW           : integer := 64;
    NUM_MEM_TILE    : integer := 2  
  );
  port(
    c0_sys_clk_p       : in    std_ulogic;
    c0_sys_clk_n       : in    std_ulogic;
    c1_sys_clk_p       : in    std_ulogic;
    c1_sys_clk_n       : in    std_ulogic;
    clk_ref_p          : in    std_ulogic;
    clk_ref_n          : in    std_ulogic;
    rst_n_syn          : in    std_logic;
    rst_n_asyn         : in    std_logic;
    c0_ddr3_dq         : inout std_logic_vector(63 downto 0);
    c0_ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    c0_ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    c0_ddr3_addr       : out   std_logic_vector(14 downto 0);
    c0_ddr3_ba         : out   std_logic_vector(2 downto 0);
    c0_ddr3_ras_n      : out   std_logic;
    c0_ddr3_cas_n      : out   std_logic;
    c0_ddr3_we_n       : out   std_logic;
    c0_ddr3_reset_n    : out   std_logic;
    c0_ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    c0_ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    c0_ddr3_cke        : out   std_logic_vector(0 downto 0);
    c0_ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    c0_ddr3_dm         : out   std_logic_vector(7 downto 0);
    c0_ddr3_odt        : out   std_logic_vector(0 downto 0);
    c1_ddr3_dq         : inout std_logic_vector(63 downto 0);
    c1_ddr3_dqs_p      : inout std_logic_vector(7 downto 0);
    c1_ddr3_dqs_n      : inout std_logic_vector(7 downto 0);
    c1_ddr3_addr       : out   std_logic_vector(14 downto 0);
    c1_ddr3_ba         : out   std_logic_vector(2 downto 0);
    c1_ddr3_ras_n      : out   std_logic;
    c1_ddr3_cas_n      : out   std_logic;
    c1_ddr3_we_n       : out   std_logic;
    c1_ddr3_reset_n    : out   std_logic;
    c1_ddr3_ck_p       : out   std_logic_vector(0 downto 0);
    c1_ddr3_ck_n       : out   std_logic_vector(0 downto 0);
    c1_ddr3_cke        : out   std_logic_vector(0 downto 0);
    c1_ddr3_cs_n       : out   std_logic_vector(0 downto 0);
    c1_ddr3_dm         : out   std_logic_vector(7 downto 0);
    c1_ddr3_odt        : out   std_logic_vector(0 downto 0);
    ddr_axi_si         : in    axi_mosi_vector(0 to NUM_MEM_TILE-1);
    ddr_axi_so         : out   axi_somi_vector(0 to NUM_MEM_TILE-1);
    c0_ui_clk               : out   std_logic;
    c0_ui_clk_sync_rst      : out   std_logic;
    c0_init_calib_complete  : out   std_logic;
    c0_device_temp          : out   std_logic_vector(11 downto 0);
    c1_ui_clk               : out   std_logic;
    c1_ui_clk_sync_rst      : out   std_logic;
    c1_init_calib_complete  : out   std_logic
  );
end component axi2mig_7series_profpga;


end axi2mig_pkg;
