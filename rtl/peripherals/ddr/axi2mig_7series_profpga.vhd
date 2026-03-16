-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.config_types.all;
use work.config.all;
library std;
use std.textio.all;

entity axi2mig_7series_profpga is
  generic(
    AXIDW           : integer := 64;
    NUM_MEM_TILE    : integer := 2
  );
  port(
    c0_sys_clk_p       : in    std_ulogic;  -- 200 MHz clock
    c0_sys_clk_n       : in    std_ulogic;  -- 200 MHz clock
    c1_sys_clk_p       : in    std_ulogic;  -- 200 MHz clock
    c1_sys_clk_n       : in    std_ulogic;  -- 200 MHz clock
    clk_ref_p          : in    std_ulogic;  -- 200 MHz clock
    clk_ref_n          : in    std_ulogic;  -- 200 MHz clock
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
end;

architecture rtl of axi2mig_7series_profpga is

component mig is
  Port ( 
    c0_ddr3_dq : inout STD_LOGIC_VECTOR ( AXIDW-1 downto 0 );
    c0_ddr3_dqs_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr3_dqs_p : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr3_addr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    c0_ddr3_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_ddr3_ras_n : out STD_LOGIC;
    c0_ddr3_cas_n : out STD_LOGIC;
    c0_ddr3_we_n : out STD_LOGIC;
    c0_ddr3_reset_n : out STD_LOGIC;
    c0_ddr3_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr3_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr3_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr3_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr3_dm : out STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr3_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_sys_clk_p : in STD_LOGIC;
    c0_sys_clk_n : in STD_LOGIC;
    clk_ref_p : in STD_LOGIC;
    clk_ref_n : in STD_LOGIC;
    c0_ui_clk : out STD_LOGIC;
    c0_ui_clk_sync_rst : out STD_LOGIC;
    c0_mmcm_locked : out STD_LOGIC;
    c0_aresetn : in STD_LOGIC;
    c0_app_sr_req : in STD_LOGIC;
    c0_app_ref_req : in STD_LOGIC;
    c0_app_zq_req : in STD_LOGIC;
    c0_app_sr_active : out STD_LOGIC;
    c0_app_ref_ack : out STD_LOGIC;
    c0_app_zq_ack : out STD_LOGIC;
    c0_s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_awaddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c0_s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_awvalid : in STD_LOGIC;
    c0_s_axi_awready : out STD_LOGIC;
    c0_s_axi_wdata : in STD_LOGIC_VECTOR ( AXIDW-1 downto 0 );
    c0_s_axi_wstrb : in STD_LOGIC_VECTOR ( (AXIDW/8)-1 downto 0 );
    c0_s_axi_wlast : in STD_LOGIC;
    c0_s_axi_wvalid : in STD_LOGIC;
    c0_s_axi_wready : out STD_LOGIC;
    c0_s_axi_bready : in STD_LOGIC;
    c0_s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_s_axi_bvalid : out STD_LOGIC;
    c0_s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_araddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c0_s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_arvalid : in STD_LOGIC;
    c0_s_axi_arready : out STD_LOGIC;
    c0_s_axi_rready : in STD_LOGIC;
    c0_s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_s_axi_rdata : out STD_LOGIC_VECTOR (AXIDW-1 downto 0 );
    c0_s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_s_axi_rlast : out STD_LOGIC;
    c0_s_axi_rvalid : out STD_LOGIC;
    c0_init_calib_complete : out STD_LOGIC;
    c0_device_temp : out STD_LOGIC_VECTOR ( 11 downto 0 );
    c1_ddr3_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
    c1_ddr3_dqs_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c1_ddr3_dqs_p : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c1_ddr3_addr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    c1_ddr3_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    c1_ddr3_ras_n : out STD_LOGIC;
    c1_ddr3_cas_n : out STD_LOGIC;
    c1_ddr3_we_n : out STD_LOGIC;
    c1_ddr3_reset_n : out STD_LOGIC;
    c1_ddr3_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    c1_ddr3_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c1_ddr3_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    c1_ddr3_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c1_ddr3_dm : out STD_LOGIC_VECTOR ( 7 downto 0 );
    c1_ddr3_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    c1_sys_clk_p : in STD_LOGIC;
    c1_sys_clk_n : in STD_LOGIC;
    c1_ui_clk : out STD_LOGIC;
    c1_ui_clk_sync_rst : out STD_LOGIC;
    c1_mmcm_locked : out STD_LOGIC;
    c1_aresetn : in STD_LOGIC;
    c1_app_sr_req : in STD_LOGIC;
    c1_app_ref_req : in STD_LOGIC;
    c1_app_zq_req : in STD_LOGIC;
    c1_app_sr_active : out STD_LOGIC;
    c1_app_ref_ack : out STD_LOGIC;
    c1_app_zq_ack : out STD_LOGIC;
    c1_s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_awaddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c1_s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c1_s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c1_s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c1_s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c1_s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c1_s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_awvalid : in STD_LOGIC;
    c1_s_axi_awready : out STD_LOGIC;
    c1_s_axi_wdata : in STD_LOGIC_VECTOR ( AXIDW-1 downto 0 );
    c1_s_axi_wstrb : in STD_LOGIC_VECTOR ( (AXIDW/8)-1 downto 0 );
    c1_s_axi_wlast : in STD_LOGIC;
    c1_s_axi_wvalid : in STD_LOGIC;
    c1_s_axi_wready : out STD_LOGIC;
    c1_s_axi_bready : in STD_LOGIC;
    c1_s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c1_s_axi_bvalid : out STD_LOGIC;
    c1_s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_araddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c1_s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c1_s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c1_s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c1_s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c1_s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c1_s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_arvalid : in STD_LOGIC;
    c1_s_axi_arready : out STD_LOGIC;
    c1_s_axi_rready : in STD_LOGIC;
    c1_s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    c1_s_axi_rdata : out STD_LOGIC_VECTOR ( AXIDW-1 downto 0 );
    c1_s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c1_s_axi_rlast : out STD_LOGIC;
    c1_s_axi_rvalid : out STD_LOGIC;
    c1_init_calib_complete : out STD_LOGIC;
    c1_device_temp : out STD_LOGIC_VECTOR ( 11 downto 0 );
    sys_rst : in STD_LOGIC
);
end component;

  signal c0_ddr4_s_axi_awlock  : std_logic_vector (0 downto 0);
  signal c0_ddr4_s_axi_arlock  : std_logic_vector (0 downto 0);
  signal c1_ddr4_s_axi_awlock  : std_logic_vector (0 downto 0);
  signal c1_ddr4_s_axi_arlock  : std_logic_vector (0 downto 0);
  signal ddr_axi_si_temp  : axi_mosi_vector(0 to 1);
  signal ddr_axi_so_temp  : axi_somi_vector(0 to 1);

begin

  c0_ddr4_s_axi_awlock(0)      <= ddr_axi_si(0).aw.lock;
  c0_ddr4_s_axi_arlock(0)      <= ddr_axi_si(0).ar.lock;
  --c1_ddr4_s_axi_awlock(0)      <= ddr_axi_si(1).aw.lock;
  --c1_ddr4_s_axi_arlock(0)      <= ddr_axi_si(1).ar.lock;

 gen_nmem1 : if NUM_MEM_TILE = 1 generate
   ddr_axi_si_temp(0) <= ddr_axi_si(0);
   ddr_axi_so(0)      <= ddr_axi_so_temp(0); 
   ddr_axi_si_temp(1) <= axi_mosi_none;
   ddr_axi_so_temp(1) <= axi_somi_none;
  end generate gen_nmem1;

 gen_nmem2 : if NUM_MEM_TILE = 2 generate
   ddr_axi_si_temp(0) <= ddr_axi_si(0);
   ddr_axi_so(0)      <= ddr_axi_so_temp(0);  
   ddr_axi_si_temp(1) <= ddr_axi_si(1);
   ddr_axi_so(1)      <= ddr_axi_so_temp(1);  
   c1_ddr4_s_axi_awlock(0)      <= ddr_axi_si(1).aw.lock;
   c1_ddr4_s_axi_arlock(0)      <= ddr_axi_si(1).ar.lock;
  end generate gen_nmem2;

  mig_inst : mig
    port map (
      c0_sys_clk_p            => c0_sys_clk_p,
      c0_sys_clk_n            => c0_sys_clk_n,
      c1_sys_clk_p            => c1_sys_clk_p,
      c1_sys_clk_n            => c1_sys_clk_n,
      clk_ref_p               => clk_ref_p,
      clk_ref_n               => clk_ref_n,
      c0_aresetn              => rst_n_syn,
      c0_ddr3_dq              => c0_ddr3_dq,
      c0_ddr3_dqs_p           => c0_ddr3_dqs_p,
      c0_ddr3_dqs_n           => c0_ddr3_dqs_n,
      c0_ddr3_addr            => c0_ddr3_addr,
      c0_ddr3_ba              => c0_ddr3_ba,
      c0_ddr3_ras_n           => c0_ddr3_ras_n,
      c0_ddr3_cas_n           => c0_ddr3_cas_n,
      c0_ddr3_we_n            => c0_ddr3_we_n,
      c0_ddr3_reset_n         => c0_ddr3_reset_n,
      c0_ddr3_ck_p            => c0_ddr3_ck_p,
      c0_ddr3_ck_n            => c0_ddr3_ck_n,
      c0_ddr3_cke             => c0_ddr3_cke,
      c0_ddr3_cs_n            => c0_ddr3_cs_n,
      c0_ddr3_dm              => c0_ddr3_dm,
      c0_ddr3_odt             => c0_ddr3_odt,
      c0_ui_clk               => c0_ui_clk,
      c0_ui_clk_sync_rst      => c0_ui_clk_sync_rst,
      c0_init_calib_complete  => c0_init_calib_complete,
      c0_device_temp          => open,
      c0_app_sr_req           => '0',
      c0_app_ref_req          => '0',
      c0_app_zq_req           => '0',
      c0_app_sr_active        => open,
      c0_app_ref_ack          => open,
      c0_app_zq_ack           => open,
      c0_mmcm_locked         => open,
      c0_s_axi_awid          => ddr_axi_si_temp(0).aw.id(3 downto 0),
      c0_s_axi_awaddr        => ddr_axi_si_temp(0).aw.addr(30 downto 0),
      c0_s_axi_awlen         => ddr_axi_si_temp(0).aw.len,
      c0_s_axi_awsize        => ddr_axi_si_temp(0).aw.size,
      c0_s_axi_awburst       => ddr_axi_si_temp(0).aw.burst,
      c0_s_axi_awlock        => c0_ddr4_s_axi_awlock, --ddr_axi_si_temp(0).aw.lock,
      c0_s_axi_awcache       => ddr_axi_si_temp(0).aw.cache,
      c0_s_axi_awprot        => ddr_axi_si_temp(0).aw.prot,
      c0_s_axi_awqos         => ddr_axi_si_temp(0).aw.qos,
      c0_s_axi_awvalid       => ddr_axi_si_temp(0).aw.valid,
      c0_s_axi_awready       => ddr_axi_so_temp(0).aw.ready,
      c0_s_axi_wdata         => ddr_axi_si_temp(0).w.data,
      c0_s_axi_wstrb         => ddr_axi_si_temp(0).w.strb,
      c0_s_axi_wlast         => ddr_axi_si_temp(0).w.last,
      c0_s_axi_wvalid        => ddr_axi_si_temp(0).w.valid,
      c0_s_axi_wready        => ddr_axi_so_temp(0).w.ready,
      c0_s_axi_bid           => ddr_axi_so_temp(0).b.id(3 downto 0),
      c0_s_axi_bresp         => ddr_axi_so_temp(0).b.resp,
      c0_s_axi_bvalid        => ddr_axi_so_temp(0).b.valid,
      c0_s_axi_bready        => ddr_axi_si_temp(0).b.ready,
      c0_s_axi_arid          => ddr_axi_si_temp(0).ar.id(3 downto 0),
      c0_s_axi_araddr        => ddr_axi_si_temp(0).ar.addr(30 downto 0),
      c0_s_axi_arlen         => ddr_axi_si_temp(0).ar.len,
      c0_s_axi_arsize        => ddr_axi_si_temp(0).ar.size,
      c0_s_axi_arburst       => ddr_axi_si_temp(0).ar.burst,
      c0_s_axi_arlock        => c0_ddr4_s_axi_arlock, --ddr_axi_si_temp(0).ar.lock,
      c0_s_axi_arcache       => ddr_axi_si_temp(0).ar.cache,
      c0_s_axi_arprot        => ddr_axi_si_temp(0).ar.prot,
      c0_s_axi_arqos         => ddr_axi_si_temp(0).ar.qos,
      c0_s_axi_arvalid       => ddr_axi_si_temp(0).ar.valid,
      c0_s_axi_arready       => ddr_axi_so_temp(0).ar.ready,
      c0_s_axi_rid           => ddr_axi_so_temp(0).r.id(3 downto 0),
      c0_s_axi_rdata         => ddr_axi_so_temp(0).r.data,
      c0_s_axi_rresp         => ddr_axi_so_temp(0).r.resp,
      c0_s_axi_rlast         => ddr_axi_so_temp(0).r.last,
      c0_s_axi_rvalid        => ddr_axi_so_temp(0).r.valid,
      c0_s_axi_rready        => ddr_axi_si_temp(0).r.ready,
      c1_aresetn             =>  rst_n_syn,
      c1_ddr3_dq              => c1_ddr3_dq,
      c1_ddr3_dqs_p           => c1_ddr3_dqs_p,
      c1_ddr3_dqs_n           => c1_ddr3_dqs_n,
      c1_ddr3_addr            => c1_ddr3_addr,
      c1_ddr3_ba              => c1_ddr3_ba,
      c1_ddr3_ras_n           => c1_ddr3_ras_n,
      c1_ddr3_cas_n           => c1_ddr3_cas_n,
      c1_ddr3_we_n            => c1_ddr3_we_n,
      c1_ddr3_reset_n         => c1_ddr3_reset_n,
      c1_ddr3_ck_p            => c1_ddr3_ck_p,
      c1_ddr3_ck_n            => c1_ddr3_ck_n,
      c1_ddr3_cke             => c1_ddr3_cke,
      c1_ddr3_cs_n            => c1_ddr3_cs_n,
      c1_ddr3_dm              => c1_ddr3_dm,
      c1_ddr3_odt             => c1_ddr3_odt,
      c1_ui_clk               => c1_ui_clk,
      c1_ui_clk_sync_rst      => c1_ui_clk_sync_rst,
      c1_init_calib_complete  => c1_init_calib_complete,
      c1_device_temp          => open,
      c1_app_sr_req           => '0',
      c1_app_ref_req          => '0',
      c1_app_zq_req           => '0',
      c1_app_sr_active        => open,
      c1_app_ref_ack          => open,
      c1_app_zq_ack           => open,
      c1_mmcm_locked         => open,
      c1_s_axi_awid          => ddr_axi_si_temp(1).aw.id(3 downto 0),
      c1_s_axi_awaddr        => ddr_axi_si_temp(1).aw.addr(30 downto 0),
      c1_s_axi_awlen         => ddr_axi_si_temp(1).aw.len,
      c1_s_axi_awsize        => ddr_axi_si_temp(1).aw.size,
      c1_s_axi_awburst       => ddr_axi_si_temp(1).aw.burst,
      c1_s_axi_awlock        => c1_ddr4_s_axi_awlock, --ddr_axi_si_temp(1).aw.lock,
      c1_s_axi_awcache       => ddr_axi_si_temp(1).aw.cache,
      c1_s_axi_awprot        => ddr_axi_si_temp(1).aw.prot,
      c1_s_axi_awqos         => ddr_axi_si_temp(1).aw.qos,
      c1_s_axi_awvalid       => ddr_axi_si_temp(1).aw.valid,
      c1_s_axi_awready       => ddr_axi_so_temp(1).aw.ready,
      c1_s_axi_wdata         => ddr_axi_si_temp(1).w.data,
      c1_s_axi_wstrb         => ddr_axi_si_temp(1).w.strb,
      c1_s_axi_wlast         => ddr_axi_si_temp(1).w.last,
      c1_s_axi_wvalid        => ddr_axi_si_temp(1).w.valid,
      c1_s_axi_wready        => ddr_axi_so_temp(1).w.ready,
      c1_s_axi_bid           => ddr_axi_so_temp(1).b.id(3 downto 0),
      c1_s_axi_bresp         => ddr_axi_so_temp(1).b.resp,
      c1_s_axi_bvalid        => ddr_axi_so_temp(1).b.valid,
      c1_s_axi_bready        => ddr_axi_si_temp(1).b.ready,
      c1_s_axi_arid          => ddr_axi_si_temp(1).ar.id(3 downto 0),
      c1_s_axi_araddr        => ddr_axi_si_temp(1).ar.addr(30 downto 0),
      c1_s_axi_arlen         => ddr_axi_si_temp(1).ar.len,
      c1_s_axi_arsize        => ddr_axi_si_temp(1).ar.size,
      c1_s_axi_arburst       => ddr_axi_si_temp(1).ar.burst,
      c1_s_axi_arlock        => c1_ddr4_s_axi_arlock, --ddr_axi_si_temp(1).ar.lock,
      c1_s_axi_arcache       => ddr_axi_si_temp(1).ar.cache,
      c1_s_axi_arprot        => ddr_axi_si_temp(1).ar.prot,
      c1_s_axi_arqos         => ddr_axi_si_temp(1).ar.qos,
      c1_s_axi_arvalid       => ddr_axi_si_temp(1).ar.valid,
      c1_s_axi_arready       => ddr_axi_so_temp(1).ar.ready,
      c1_s_axi_rid           => ddr_axi_so_temp(1).r.id(3 downto 0),
      c1_s_axi_rdata         => ddr_axi_so_temp(1).r.data,
      c1_s_axi_rresp         => ddr_axi_so_temp(1).r.resp,
      c1_s_axi_rlast         => ddr_axi_so_temp(1).r.last,
      c1_s_axi_rvalid        => ddr_axi_so_temp(1).r.valid,
      c1_s_axi_rready        => ddr_axi_si_temp(1).r.ready,
      sys_rst                => rst_n_asyn
    );
end;
