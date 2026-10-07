library ieee;
use ieee.std_logic_1164.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.misc.all;
use work.net.all;
library unisim;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on
use unisim.VCOMPONENTS.all;
use work.monitor_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;
use work.axi2mig_pkg.all;

entity axi_ram_sim is 
  generic (
	kbytes		: integer := 1;
    DATA_WIDTH 	: integer := 64;
    ADDR_WIDTH 	: integer := 32;
    STRB_WIDTH 	: integer := 8;
    ID_WIDTH	: integer := 8;
    PIPELINE_OUTPUT : integer := 0 
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    ddr_axi_si  : in axi_mosi_type;
    ddr_axi_so   : out axi_somi_type
  );
end;

  architecture rtl of axi_ram_sim is

  component axi_ram_sim_model is
    generic(
      kbytes          : integer := 1;
      DATA_WIDTH      : integer := 32;
      ADDR_WIDTH      : integer := 32;
      STRB_WIDTH      : integer := 4;
      ID_WIDTH        : integer := 8;
      PIPELINE_OUTPUT     : integer := 0
    );
    port(
      clk         : in std_logic;
      rst         : in std_logic;
      -- AW Channel
      s_axi_awid      : in std_logic_vector(7 downto 0);
      s_axi_awaddr    : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      s_axi_awlen     : in std_logic_vector(7 downto 0);
      s_axi_awsize    : in std_logic_vector(2 downto 0);
      s_axi_awburst   : in std_logic_vector(1 downto 0);
      s_axi_awlock    : in std_logic;
      s_axi_awcache   : in std_logic_vector(3 downto 0);
      s_axi_awprot    : in std_logic_vector(2 downto 0);
      s_axi_awvalid   : in std_logic;
      s_axi_awready   : out std_logic;
      -- W Channel
      s_axi_wdata     : in std_logic_vector(DATA_WIDTH-1 downto 0);
      s_axi_wstrb     : in std_logic_vector((DATA_WIDTH/8)-1 downto 0);
      s_axi_wlast     : in std_logic;
      s_axi_wvalid    : in std_logic;
      s_axi_wready    : out std_logic;
      -- B Channel
      s_axi_bid       : out std_logic_vector(7 downto 0);
      s_axi_bresp     : out std_logic_vector(1 downto 0);
      s_axi_bvalid    : out std_logic;
      s_axi_bready    : in std_logic;
      -- AR Channel
      s_axi_arid      : in std_logic_vector(7 downto 0);
      s_axi_araddr    : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      s_axi_arlen     : in std_logic_vector(7 downto 0);
      s_axi_arsize    : in std_logic_vector(2 downto 0);
      s_axi_arburst   : in std_logic_vector(1 downto 0);
      s_axi_arlock    : in std_logic;
      s_axi_arcache   : in std_logic_vector(3 downto 0);
      s_axi_arprot    : in std_logic_vector(2 downto 0);
      s_axi_arvalid   : in std_logic;
      s_axi_arready   : out std_logic;
      -- R Channel
      s_axi_rid       : out std_logic_vector(7 downto 0);
      s_axi_rdata     : out std_logic_vector(DATA_WIDTH-1 downto 0);
      s_axi_rresp     : out std_logic_vector(1 downto 0);
      s_axi_rlast     : out std_logic;
      s_axi_rvalid    : out std_logic;
      s_axi_rready    : in std_logic
    );
  end component axi_ram_sim_model;

  begin

    ddr_axi_so.b.user(9 downto 0) <= (others => '0');
    ddr_axi_so.r.user(9 downto 0) <= (others => '0');
    ddr_axi_so.b.id(9 downto 8) <= (others =>'0');
    ddr_axi_so.r.id(9 downto 8) <= (others =>'0');

	axiram : axi_ram_sim_model
      generic map (
        kbytes          => kbytes,
        DATA_WIDTH      => DATA_WIDTH,
        ADDR_WIDTH      => ADDR_WIDTH,
        STRB_WIDTH      => STRB_WIDTH,
        ID_WIDTH        => ID_WIDTH,
        PIPELINE_OUTPUT => PIPELINE_OUTPUT
        )
      port map(
        clk             => clk,
        rst             => rst,
        -- AW Channel
        s_axi_awid      => ddr_axi_si.aw.id(7 downto 0),
        s_axi_awaddr    => ddr_axi_si.aw.addr,
        s_axi_awlen     => ddr_axi_si.aw.len,
        s_axi_awsize    => ddr_axi_si.aw.size,
        s_axi_awburst   => ddr_axi_si.aw.burst,
        s_axi_awlock    => ddr_axi_si.aw.lock,
        s_axi_awcache   => ddr_axi_si.aw.cache,
        s_axi_awprot    => ddr_axi_si.aw.prot,
        s_axi_awvalid   => ddr_axi_si.aw.valid,
        s_axi_awready   => ddr_axi_so.aw.ready,
        -- W Channel
        s_axi_wdata     => ddr_axi_si.w.data,
        s_axi_wstrb     => ddr_axi_si.w.strb,
        s_axi_wlast     => ddr_axi_si.w.last,
        s_axi_wvalid    => ddr_axi_si.w.valid,
        s_axi_wready    => ddr_axi_so.w.ready,
        -- B Channel
        s_axi_bid       => ddr_axi_so.b.id(7 downto 0),
        s_axi_bresp     => ddr_axi_so.b.resp,
        s_axi_bvalid    => ddr_axi_so.b.valid,
        s_axi_bready    => ddr_axi_si.b.ready,
        -- AR Channel
        s_axi_arid      => ddr_axi_si.ar.id(7 downto 0),
        s_axi_araddr    => ddr_axi_si.ar.addr,
        s_axi_arlen     => ddr_axi_si.ar.len,
        s_axi_arsize    => ddr_axi_si.ar.size,
        s_axi_arburst   => ddr_axi_si.ar.burst,
        s_axi_arlock    => ddr_axi_si.ar.lock,
        s_axi_arcache   => ddr_axi_si.ar.cache,
        s_axi_arprot    => ddr_axi_si.ar.prot,
        s_axi_arvalid   => ddr_axi_si.ar.valid,
        s_axi_arready   => ddr_axi_so.ar.ready,
        -- R Channel
        s_axi_rid       => ddr_axi_so.r.id(7 downto 0),
        s_axi_rdata     => ddr_axi_so.r.data,
        s_axi_rresp     => ddr_axi_so.r.resp,
        s_axi_rlast     => ddr_axi_so.r.last,
        s_axi_rvalid    => ddr_axi_so.r.valid,
        s_axi_rready    => ddr_axi_si.r.ready
        );
end; 
