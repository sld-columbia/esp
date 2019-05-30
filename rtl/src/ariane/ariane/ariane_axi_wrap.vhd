-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: MIT

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.amba.all;
use work.ariane_esp_pkg.all;


entity ariane_axi_wrap is
  generic (
    HART_ID          : std_logic_vector(63 downto 0) := (others => '0');
    NMST             : integer                       := 2;
    NSLV             : integer                       := 5;
    NIRQ_SRCS        : integer                       := 1;
    ROMBase          : std_logic_vector(63 downto 0) := X"0000_0000_0001_0000";
    ROMLength        : std_logic_vector(63 downto 0) := X"0000_0000_0001_0000";
    APBBase          : std_logic_vector(63 downto 0) := X"0000_0000_6000_0000";
    APBLength        : std_logic_vector(63 downto 0) := X"0000_0000_1000_0000";
    CLINTBase        : std_logic_vector(63 downto 0) := X"0000_0000_0200_0000";
    CLINTLength      : std_logic_vector(63 downto 0) := X"0000_0000_000C_0000";
    PLICBase         : std_logic_vector(63 downto 0) := X"0000_0000_0C00_0000";
    PLICLength       : std_logic_vector(63 downto 0) := X"0000_0000_03FF_FFFF";
    DRAMBase         : std_logic_vector(63 downto 0) := X"0000_0000_8000_0000";
    DRAMLength       : std_logic_vector(63 downto 0) := X"0000_0000_2000_0000");
  port (
    clk         : in  std_logic;
    rstn        : in  std_logic;
    irq_sources : in  std_logic_vector(NIRQ_SRCS-1 downto 0);
    romi        : out axi_mosi_type;
    romo        : in  axi_somi_type;
    drami       : out axi_mosi_type;
    dramo       : in  axi_somi_type;
    apbi        : out apb_slv_in_type;
    apbo        : in  apb_slv_out_vector;
    apb_req     : out std_ulogic;
    apb_ack     : in  std_ulogic);

end ariane_axi_wrap;


architecture rtl of ariane_axi_wrap is

  component ariane_wrap is
    generic (
      HART_ID          : std_logic_vector(63 downto 0);
      NMST             : integer;
      NSLV             : integer;
      NIRQ_SRCS        : integer;
      AXI_ID_WIDTH     : integer;
      AXI_ID_WIDTH_SLV : integer;
      AXI_ADDR_WIDTH   : integer;
      AXI_DATA_WIDTH   : integer;
      AXI_USER_WIDTH   : integer;
      AXI_STRB_WIDTH   : integer;
      ROMBase          : std_logic_vector(63 downto 0);
      ROMLength        : std_logic_vector(63 downto 0);
      APBBase          : std_logic_vector(63 downto 0);
      APBLength        : std_logic_vector(63 downto 0);
      CLINTBase        : std_logic_vector(63 downto 0);
      CLINTLength      : std_logic_vector(63 downto 0);
      PLICBase         : std_logic_vector(63 downto 0);
      PLICLength       : std_logic_vector(63 downto 0);
      DRAMBase         : std_logic_vector(63 downto 0);
      DRAMLength       : std_logic_vector(63 downto 0));
    port (
      clk            : in  std_logic;
      rstn           : in  std_logic;
      irq_sources    : in  std_logic_vector(NIRQ_SRCS-1 downto 0);
      rom_aw_id      : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_aw_addr    : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      rom_aw_len     : out std_logic_vector(7 downto 0);
      rom_aw_size    : out std_logic_vector(2 downto 0);
      rom_aw_burst   : out std_logic_vector(1 downto 0);
      rom_aw_lock    : out std_logic;
      rom_aw_cache   : out std_logic_vector(3 downto 0);
      rom_aw_prot    : out std_logic_vector(2 downto 0);
      rom_aw_qos     : out std_logic_vector(3 downto 0);
      rom_aw_atop    : out std_logic_vector(5 downto 0);
      rom_aw_region  : out std_logic_vector(3 downto 0);
      rom_aw_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_aw_valid   : out std_logic;
      rom_aw_ready   : in  std_logic;
      rom_w_data     : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      rom_w_strb     : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      rom_w_last     : out std_logic;
      rom_w_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_w_valid    : out std_logic;
      rom_w_ready    : in  std_logic;
      rom_b_id       : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_b_resp     : in  std_logic_vector(1 downto 0);
      rom_b_user     : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_b_valid    : in  std_logic;
      rom_b_ready    : out std_logic;
      rom_ar_id      : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_ar_addr    : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      rom_ar_len     : out std_logic_vector(7 downto 0);
      rom_ar_size    : out std_logic_vector(2 downto 0);
      rom_ar_burst   : out std_logic_vector(1 downto 0);
      rom_ar_lock    : out std_logic;
      rom_ar_cache   : out std_logic_vector(3 downto 0);
      rom_ar_prot    : out std_logic_vector(2 downto 0);
      rom_ar_qos     : out std_logic_vector(3 downto 0);
      rom_ar_region  : out std_logic_vector(3 downto 0);
      rom_ar_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_ar_valid   : out std_logic;
      rom_ar_ready   : in  std_logic;
      rom_r_id       : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_r_data     : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      rom_r_resp     : in  std_logic_vector(1 downto 0);
      rom_r_last     : in  std_logic;
      rom_r_user     : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_r_valid    : in  std_logic;
      rom_r_ready    : out std_logic;
      dram_aw_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_aw_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      dram_aw_len    : out std_logic_vector(7 downto 0);
      dram_aw_size   : out std_logic_vector(2 downto 0);
      dram_aw_burst  : out std_logic_vector(1 downto 0);
      dram_aw_lock   : out std_logic;
      dram_aw_cache  : out std_logic_vector(3 downto 0);
      dram_aw_prot   : out std_logic_vector(2 downto 0);
      dram_aw_qos    : out std_logic_vector(3 downto 0);
      dram_aw_atop   : out std_logic_vector(5 downto 0);
      dram_aw_region : out std_logic_vector(3 downto 0);
      dram_aw_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_aw_valid  : out std_logic;
      dram_aw_ready  : in  std_logic;
      dram_w_data    : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      dram_w_strb    : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      dram_w_last    : out std_logic;
      dram_w_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_w_valid   : out std_logic;
      dram_w_ready   : in  std_logic;
      dram_b_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_b_resp    : in  std_logic_vector(1 downto 0);
      dram_b_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_b_valid   : in  std_logic;
      dram_b_ready   : out std_logic;
      dram_ar_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_ar_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      dram_ar_len    : out std_logic_vector(7 downto 0);
      dram_ar_size   : out std_logic_vector(2 downto 0);
      dram_ar_burst  : out std_logic_vector(1 downto 0);
      dram_ar_lock   : out std_logic;
      dram_ar_cache  : out std_logic_vector(3 downto 0);
      dram_ar_prot   : out std_logic_vector(2 downto 0);
      dram_ar_qos    : out std_logic_vector(3 downto 0);
      dram_ar_region : out std_logic_vector(3 downto 0);
      dram_ar_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_ar_valid  : out std_logic;
      dram_ar_ready  : in  std_logic;
      dram_r_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_r_data    : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      dram_r_resp    : in  std_logic_vector(1 downto 0);
      dram_r_last    : in  std_logic;
      dram_r_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_r_valid   : in  std_logic;
      dram_r_ready   : out std_logic;
      penable        : out std_logic;
      pwrite         : out std_logic;
      paddr          : out std_logic_vector(31 downto 0);
      psel           : out std_logic;
      pwdata         : out std_logic_vector(31 downto 0);
      prdata         : in  std_logic_vector(31 downto 0);
      pready         : in  std_logic;
      pslverr        : in  std_logic);
  end component ariane_wrap;

  signal penable      : std_logic;
  signal pwrite       : std_logic;
  signal paddr        : std_logic_vector(31 downto 0);
  signal psel         : std_logic;
  signal pwdata       : std_logic_vector(31 downto 0);
  signal prdata       : std_logic_vector(31 downto 0);
  signal psel_idx     : integer range 0 to NAPBSLV - 1;
  signal psel_idx_reg : integer range 0 to NAPBSLV - 1;

  constant ARIANE_AXI_ID_WIDTH : integer := 4;
  constant ARIANE_AXI_ID_WIDTH_SLV : integer := ARIANE_AXI_ID_WIDTH + log2(NMST);

begin  -- architecture rtl

  ariane_wrap_1 : ariane_wrap
    generic map (
      HART_ID          => HART_ID,
      NMST             => NMST,
      NSLV             => NSLV,
      NIRQ_SRCS        => NIRQ_SRCS,
      AXI_ID_WIDTH     => ARIANE_AXI_ID_WIDTH,
      AXI_ID_WIDTH_SLV => ARIANE_AXI_ID_WIDTH_SLV,
      AXI_ADDR_WIDTH   => GLOB_PHYS_ADDR_BITS,
      AXI_DATA_WIDTH   => ARCH_BITS,
      AXI_USER_WIDTH   => XUSER_WIDTH,
      AXI_STRB_WIDTH   => ARCH_BITS / 8,
      ROMBase          => ROMBase,
      ROMLength        => ROMLength,
      APBBase          => APBBase,
      APBLength        => APBLength,
      CLINTBase        => CLINTBase,
      CLINTLength      => CLINTLength,
      PLICBase         => PLICBase,
      PLICLength       => PLICLength,
      DRAMBase         => DRAMBase,
      DRAMLength       => DRAMLength)
    port map (
      clk            => clk,
      rstn           => rstn,
      irq_sources    => irq_sources,
      rom_aw_id      => romi.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_aw_addr    => romi.aw.addr,
      rom_aw_len     => romi.aw.len,
      rom_aw_size    => romi.aw.size,
      rom_aw_burst   => romi.aw.burst,
      rom_aw_lock    => romi.aw.lock,
      rom_aw_cache   => romi.aw.cache,
      rom_aw_prot    => romi.aw.prot,
      rom_aw_qos     => romi.aw.qos,
      rom_aw_atop    => romi.aw.atop,
      rom_aw_region  => romi.aw.region,
      rom_aw_user    => romi.aw.user,
      rom_aw_valid   => romi.aw.valid,
      rom_aw_ready   => romo.aw.ready,
      rom_w_data     => romi.w.data,
      rom_w_strb     => romi.w.strb,
      rom_w_last     => romi.w.last,
      rom_w_user     => romi.w.user,
      rom_w_valid    => romi.w.valid,
      rom_w_ready    => romo.w.ready,
      rom_b_id       => romo.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_b_resp     => romo.b.resp,
      rom_b_user     => romo.b.user,
      rom_b_valid    => romo.b.valid,
      rom_b_ready    => romi.b.ready,
      rom_ar_id      => romi.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_ar_addr    => romi.ar.addr,
      rom_ar_len     => romi.ar.len,
      rom_ar_size    => romi.ar.size,
      rom_ar_burst   => romi.ar.burst,
      rom_ar_lock    => romi.ar.lock,
      rom_ar_cache   => romi.ar.cache,
      rom_ar_prot    => romi.ar.prot,
      rom_ar_qos     => romi.ar.qos,
      rom_ar_region  => romi.ar.region,
      rom_ar_user    => romi.ar.user,
      rom_ar_valid   => romi.ar.valid,
      rom_ar_ready   => romo.ar.ready,
      rom_r_id       => romo.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_r_data     => romo.r.data,
      rom_r_resp     => romo.r.resp,
      rom_r_last     => romo.r.last,
      rom_r_user     => romo.r.user,
      rom_r_valid    => romo.r.valid,
      rom_r_ready    => romi.r.ready,
      dram_aw_id     => drami.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_aw_addr   => drami.aw.addr,
      dram_aw_len    => drami.aw.len,
      dram_aw_size   => drami.aw.size,
      dram_aw_burst  => drami.aw.burst,
      dram_aw_lock   => drami.aw.lock,
      dram_aw_cache  => drami.aw.cache,
      dram_aw_prot   => drami.aw.prot,
      dram_aw_qos    => drami.aw.qos,
      dram_aw_atop   => drami.aw.atop,
      dram_aw_region => drami.aw.region,
      dram_aw_user   => drami.aw.user,
      dram_aw_valid  => drami.aw.valid,
      dram_aw_ready  => dramo.aw.ready,
      dram_w_data    => drami.w.data,
      dram_w_strb    => drami.w.strb,
      dram_w_last    => drami.w.last,
      dram_w_user    => drami.w.user,
      dram_w_valid   => drami.w.valid,
      dram_w_ready   => dramo.w.ready,
      dram_b_id      => dramo.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_b_resp    => dramo.b.resp,
      dram_b_user    => dramo.b.user,
      dram_b_valid   => dramo.b.valid,
      dram_b_ready   => drami.b.ready,
      dram_ar_id     => drami.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_ar_addr   => drami.ar.addr,
      dram_ar_len    => drami.ar.len,
      dram_ar_size   => drami.ar.size,
      dram_ar_burst  => drami.ar.burst,
      dram_ar_lock   => drami.ar.lock,
      dram_ar_cache  => drami.ar.cache,
      dram_ar_prot   => drami.ar.prot,
      dram_ar_qos    => drami.ar.qos,
      dram_ar_region => drami.ar.region,
      dram_ar_user   => drami.ar.user,
      dram_ar_valid  => drami.ar.valid,
      dram_ar_ready  => dramo.ar.ready,
      dram_r_id      => dramo.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_r_data    => dramo.r.data,
      dram_r_resp    => dramo.r.resp,
      dram_r_last    => dramo.r.last,
      dram_r_user    => dramo.r.user,
      dram_r_valid   => dramo.r.valid,
      dram_r_ready   => drami.r.ready,
      penable        => penable,
      pwrite         => pwrite,
      paddr          => paddr,
      psel           => psel,
      pwdata         => pwdata,
      prdata         => prdata,
      pready         => apb_ack,
      pslverr        => '0');

  -- Unused extended AXI ID
  romi.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  romi.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  drami.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV) <= (others => '0');
  drami.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV) <= (others => '0');

  -- Unused
  apbi.pirq    <= (others => '0');
  apbi.testen  <= '0';
  apbi.testrst <= '0';
  apbi.scanen  <= '0';
  apbi.testoen <= '0';
  apbi.testin  <= (others => '0');

  -- APB slave input
  apb_req <= psel and penable;

  apbi.penable <= penable;
  apbi.pwrite  <= pwrite;
  apbi.paddr   <= X"000fffff" and paddr;
  apbi.pwdata  <= pwdata;

  psel_gen: process (psel, paddr, apbo) is
    variable psel_v : std_logic_vector(0 to NAPBSLV - 1);
  begin  -- process psel_gen
    psel_v := (others => '0');
    psel_idx <= 0;

    for i in 0 to NAPBSLV - 1 loop
      if ((apbo(i).pconfig(1)(1 downto 0) = "01") and
          ((apbo(i).pconfig(1)(31 downto 20) and apbo(i).pconfig(1)(15 downto 4)) =
           (paddr(19 downto  8) and apbo(i).pconfig(1)(15 downto 4)))) then

        psel_v(i) := psel;
        psel_idx <= i;

      end if;
    end loop;

    apbi.psel <= psel_v;
  end process psel_gen;

  psel_reg_gen: process (clk, rstn) is
  begin  -- process psel_reg_gen
    if rstn = '0' then                  -- asynchronous reset (active low)
      psel_idx_reg <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (psel and penable) = '1' then
        psel_idx_reg <= psel_idx;
      end if;
    end if;
  end process psel_reg_gen;

  prdata <= apbo(psel_idx_reg).prdata;

end architecture rtl;
