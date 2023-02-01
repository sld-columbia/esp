-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.amba.all;
use work.ariane_esp_pkg.all;


entity riscv_clint_ahb_wrap is

  generic (
    hindex : integer := 0;
    hconfig : ahb_config_type;
    NHARTS : integer := 1);
  port (
    clk : in std_ulogic;
    rstn : in std_ulogic;
    -- Timer interrupt
    timer_irq : out std_logic_vector(NHARTS - 1 downto 0);
    -- Software interrupt
    ipi : out std_logic_vector(NHARTS - 1 downto 0);
    -- AHB
    ahbsi : in ahb_slv_in_type;
    ahbso : out ahb_slv_out_type);

end entity riscv_clint_ahb_wrap;


architecture rtl of riscv_clint_ahb_wrap is

  function fix_endian (
    le : std_logic_vector(ARCH_BITS - 1 downto 0))
    return std_logic_vector is
    variable be : std_logic_vector(ARCH_BITS - 1 downto 0);
  begin
    for i in 0 to (ARCH_BITS / 8) - 1 loop
      be(8 * (i + 1) - 1 downto 8 * i) := le(ARCH_BITS - 8 * i - 1 downto ARCH_BITS - 8 * (i + 1));
    end loop;  -- i
    return be;
  end fix_endian;

  component riscv_clint_wrap is
    generic (
      AXI_ADDR_WIDTH : integer;
      AXI_DATA_WIDTH : integer;
      AXI_ID_WIDTH_SLV : integer;
      AXI_USER_WIDTH : integer;
      AXI_STRB_WIDTH   : integer;
      NR_CORES : integer);
    port (
      clk : in std_logic;
      rstn : in std_logic;
      -- Timer interrupt
      timer_irq : out std_logic_vector(NR_CORES-1 downto 0);
      -- Software interrupt
      ipi : out std_logic_vector(NR_CORES-1 downto 0);
      -- AW
      aw_id : in std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      aw_addr : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      aw_len : in std_logic_vector(7 downto 0);
      aw_size : in std_logic_vector(2 downto 0);
      aw_burst : in std_logic_vector(1 downto 0);
      aw_lock : in std_logic;
      aw_cache : in std_logic_vector(3 downto 0);
      aw_prot : in std_logic_vector(2 downto 0);
      aw_qos : in std_logic_vector(3 downto 0);
      aw_atop : in std_logic_vector(5 downto 0);
      aw_region : in std_logic_vector(3 downto 0);
      aw_user : in std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      aw_valid : in std_logic;
      aw_ready : out std_logic;
      -- W
      w_data : in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      w_strb : in std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      w_last : in std_logic;
      w_user : in std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      w_valid : in std_logic;
      w_ready : out std_logic;
      -- B
      b_id : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      b_resp : out std_logic_vector(1 downto 0);
      b_user : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      b_valid : out std_logic;
      b_ready : in std_logic;
      -- AR
      ar_id : in std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      ar_addr : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      ar_len : in std_logic_vector(7 downto 0);
      ar_size : in std_logic_vector(2 downto 0);
      ar_burst : in std_logic_vector(1 downto 0);
      ar_lock : in std_logic;
      ar_cache : in std_logic_vector(3 downto 0);
      ar_prot : in std_logic_vector(2 downto 0);
      ar_qos : in std_logic_vector(3 downto 0);
      ar_region : in std_logic_vector(3 downto 0);
      ar_user : in std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      ar_valid : in std_logic;
      ar_ready : out std_logic;
      -- R
      r_id : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      r_data : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      r_resp : out std_logic_vector(1 downto 0);
      r_last : out std_logic;
      r_user : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      r_valid : out std_logic;
      r_ready : in std_logic);
  end component riscv_clint_wrap;

  signal aximi : axi_somi_type;
  signal aximo : axi_mosi_type;

  signal rdata : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal wdata : std_logic_vector(ARCH_BITS - 1 downto 0);

begin -- architecture rtl

  ahb2axi_l_1: ahb2axi_l
    generic map (
      hindex    => hindex,
      hconfig   => hconfig,
      aximid    => 0,
      axisecure => true,
      scantest  => 0)
    port map (
      rst   => rstn,
      clk   => clk,
      ahbsi => ahbsi,
      ahbso => ahbso,
      aximi => aximi,
      aximo => aximo);

  wdata <= fix_endian(aximo.w.data);
  aximi.r.data <= fix_endian(rdata);

  riscv_clint_wrap_1: riscv_clint_wrap
    generic map (
      AXI_ADDR_WIDTH   => GLOB_PHYS_ADDR_BITS,
      AXI_DATA_WIDTH   => ARCH_BITS,
      AXI_ID_WIDTH_SLV => XID_WIDTH,
      AXI_USER_WIDTH   => XUSER_WIDTH,
      AXI_STRB_WIDTH   => ARCH_BITS / 8,
      NR_CORES         => NHARTS)
    port map (
      clk       => clk,
      rstn      => rstn,
      timer_irq => timer_irq,
      ipi       => ipi,
      aw_id     => aximo.aw.id,
      aw_addr   => aximo.aw.addr,
      aw_len    => aximo.aw.len,
      aw_size   => aximo.aw.size,
      aw_burst  => aximo.aw.burst,
      aw_lock   => aximo.aw.lock,
      aw_cache  => aximo.aw.cache,
      aw_prot   => aximo.aw.prot,
      aw_qos    => aximo.aw.qos,
      aw_atop   => aximo.aw.atop,
      aw_region => aximo.aw.region,
      aw_user   => aximo.aw.user,
      aw_valid  => aximo.aw.valid,
      aw_ready  => aximi.aw.ready,
      w_data    => wdata,
      w_strb    => aximo.w.strb,
      w_last    => aximo.w.last,
      w_user    => aximo.w.user,
      w_valid   => aximo.w.valid,
      w_ready   => aximi.w.ready,
      b_id      => aximi.b.id,
      b_resp    => aximi.b.resp,
      b_user    => aximi.b.user,
      b_valid   => aximi.b.valid,
      b_ready   => aximo.b.ready,
      ar_id     => aximo.ar.id,
      ar_addr   => aximo.ar.addr,
      ar_len    => aximo.ar.len,
      ar_size   => aximo.ar.size,
      ar_burst  => aximo.ar.burst,
      ar_lock   => aximo.ar.lock,
      ar_cache  => aximo.ar.cache,
      ar_prot   => aximo.ar.prot,
      ar_qos    => aximo.ar.qos,
      ar_region => aximo.ar.region,
      ar_user   => aximo.ar.user,
      ar_valid  => aximo.ar.valid,
      ar_ready  => aximi.ar.ready,
      r_id      => aximi.r.id,
      r_data    => rdata,
      r_resp    => aximi.r.resp,
      r_last    => aximi.r.last,
      r_user    => aximi.r.user,
      r_valid   => aximi.r.valid,
      r_ready   => aximo.r.ready);

end architecture rtl;
