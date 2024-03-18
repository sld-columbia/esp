-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.stdlib.all;
use work.amba.all;
use work.ariane_esp_pkg.all;


entity ariane_axi_wrap is
  generic (
    NMST             : integer                       := 2;
    NSLV             : integer                       := 6;
    ROMBase          : std_logic_vector(63 downto 0) := X"0000_0000_0001_0000";
    ROMLength        : std_logic_vector(63 downto 0) := X"0000_0000_0001_0000";
    APBBase          : std_logic_vector(63 downto 0) := X"0000_0000_6000_0000";
    APBLength        : std_logic_vector(63 downto 0) := X"0000_0000_1000_0000";
    CLINTBase        : std_logic_vector(63 downto 0) := X"0000_0000_0200_0000";
    CLINTLength      : std_logic_vector(63 downto 0) := X"0000_0000_000C_0000";
    SLMBase          : std_logic_vector(63 downto 0) := X"0000_0000_0400_0000";
    SLMLength        : std_logic_vector(63 downto 0) := X"0000_0000_0400_0000";
    SLMDDRBase       : std_logic_vector(63 downto 0) := X"0000_0000_C000_0000";
    SLMDDRLength     : std_logic_vector(63 downto 0) := X"0000_0000_4000_0000";
    DRAMBase         : std_logic_vector(63 downto 0) := X"0000_0000_8000_0000";
    DRAMLength       : std_logic_vector(63 downto 0) := X"0000_0000_2000_0000";
    DRAMCachedLength : std_logic_vector(63 downto 0) := X"0000_0000_2000_0000");
  port (
    clk         : in  std_logic;
    rstn        : in  std_logic;
    HART_ID     : in  std_logic_vector(63 downto 0);
    irq         : in  std_logic_vector(1 downto 0);
    timer_irq   : in  std_logic;
    ipi         : in  std_logic;
    romi        : out axi_mosi_type;
    romo        : in  axi_somi_type;
    drami       : out axi_mosi_type;
    dramo       : in  axi_somi_type;
    clinti      : out axi_mosi_type;
    clinto      : in  axi_somi_type;
    slmi        : out axi_mosi_type;
    slmo        : in  axi_somi_type;
    slmddri     : out axi_mosi_type;
    slmddro     : in  axi_somi_type;
    apbi        : out apb_slv_in_type;
    apbo        : in  apb_slv_out_vector;
    apb_req     : out std_ulogic;
    apb_ack     : in  std_ulogic;
    ace_req     : in  ace_req_type;
    ace_resp    : out ace_resp_type;
    fence_l2    : out std_logic_vector(1 downto 0);
    flush_l1    : in std_logic;
    flush_done  : out std_logic
    );

end ariane_axi_wrap;


architecture rtl of ariane_axi_wrap is

  component ariane_wrap is
    generic (
      NMST             : integer;
      NSLV             : integer;
      AXI_ID_WIDTH     : integer;
      AXI_ID_WIDTH_SLV : integer;
      AXI_ADDR_WIDTH   : integer;
      AXI_DATA_WIDTH   : integer;
      AXI_USER_WIDTH   : integer;
      AXI_STRB_WIDTH   : integer;
      USE_SPANDEX      : integer;
      ROMBase          : std_logic_vector(63 downto 0);
      ROMLength        : std_logic_vector(63 downto 0);
      APBBase          : std_logic_vector(63 downto 0);
      APBLength        : std_logic_vector(63 downto 0);
      CLINTBase        : std_logic_vector(63 downto 0);
      CLINTLength      : std_logic_vector(63 downto 0);
      SLMBase          : std_logic_vector(63 downto 0);
      SLMLength        : std_logic_vector(63 downto 0);
      SLMDDRBase       : std_logic_vector(63 downto 0);
      SLMDDRLength     : std_logic_vector(63 downto 0);
      DRAMBase         : std_logic_vector(63 downto 0);
      DRAMLength       : std_logic_vector(63 downto 0);
      DRAMCachedLength : std_logic_vector(63 downto 0));
    port (
      clk             : in  std_logic;
      rstn            : in  std_logic;
      HART_ID         : in  std_logic_vector(63 downto 0);
      irq             : in  std_logic_vector(1 downto 0);
      timer_irq       : in  std_logic;
      ipi             : in  std_logic;
      rom_aw_id       : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_aw_addr     : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      rom_aw_len      : out std_logic_vector(7 downto 0);
      rom_aw_size     : out std_logic_vector(2 downto 0);
      rom_aw_burst    : out std_logic_vector(1 downto 0);
      rom_aw_lock     : out std_logic;
      rom_aw_cache    : out std_logic_vector(3 downto 0);
      rom_aw_prot     : out std_logic_vector(2 downto 0);
      rom_aw_qos      : out std_logic_vector(3 downto 0);
      rom_aw_atop     : out std_logic_vector(5 downto 0);
      rom_aw_region   : out std_logic_vector(3 downto 0);
      rom_aw_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_aw_valid    : out std_logic;
      rom_aw_ready    : in  std_logic;
      rom_w_data      : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      rom_w_strb      : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      rom_w_last      : out std_logic;
      rom_w_user      : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_w_valid     : out std_logic;
      rom_w_ready     : in  std_logic;
      rom_b_id        : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_b_resp      : in  std_logic_vector(1 downto 0);
      rom_b_user      : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_b_valid     : in  std_logic;
      rom_b_ready     : out std_logic;
      rom_ar_id       : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_ar_addr     : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      rom_ar_len      : out std_logic_vector(7 downto 0);
      rom_ar_size     : out std_logic_vector(2 downto 0);
      rom_ar_burst    : out std_logic_vector(1 downto 0);
      rom_ar_lock     : out std_logic;
      rom_ar_cache    : out std_logic_vector(3 downto 0);
      rom_ar_prot     : out std_logic_vector(2 downto 0);
      rom_ar_qos      : out std_logic_vector(3 downto 0);
      rom_ar_region   : out std_logic_vector(3 downto 0);
      rom_ar_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_ar_valid    : out std_logic;
      rom_ar_ready    : in  std_logic;
      rom_r_id        : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      rom_r_data      : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      rom_r_resp      : in  std_logic_vector(1 downto 0);
      rom_r_last      : in  std_logic;
      rom_r_user      : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      rom_r_valid     : in  std_logic;
      rom_r_ready     : out std_logic;
      dram_aw_id      : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_aw_addr    : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      dram_aw_len     : out std_logic_vector(7 downto 0);
      dram_aw_size    : out std_logic_vector(2 downto 0);
      dram_aw_burst   : out std_logic_vector(1 downto 0);
      dram_aw_lock    : out std_logic;
      dram_aw_cache   : out std_logic_vector(3 downto 0);
      dram_aw_prot    : out std_logic_vector(2 downto 0);
      dram_aw_qos     : out std_logic_vector(3 downto 0);
      dram_aw_atop    : out std_logic_vector(5 downto 0);
      dram_aw_region  : out std_logic_vector(3 downto 0);
      dram_aw_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_aw_valid   : out std_logic;
      dram_aw_ready   : in  std_logic;
      dram_ac_addr    : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      dram_ac_prot    : in  std_logic_vector(2 downto 0);
      dram_ac_snoop   : in  std_logic_vector(3 downto 0);
      dram_ac_valid   : in  std_logic;
      dram_ac_ready   : out std_logic;
      dram_w_data     : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      dram_w_strb     : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      dram_w_last     : out std_logic;
      dram_w_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_w_valid    : out std_logic;
      dram_w_ready    : in  std_logic;
      dram_b_id       : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_b_resp     : in  std_logic_vector(1 downto 0);
      dram_b_user     : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_b_valid    : in  std_logic;
      dram_b_ready    : out std_logic;
      dram_ar_id      : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_ar_addr    : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      dram_ar_len     : out std_logic_vector(7 downto 0);
      dram_ar_size    : out std_logic_vector(2 downto 0);
      dram_ar_burst   : out std_logic_vector(1 downto 0);
      dram_ar_lock    : out std_logic;
      dram_ar_cache   : out std_logic_vector(3 downto 0);
      dram_ar_prot    : out std_logic_vector(2 downto 0);
      dram_ar_qos     : out std_logic_vector(3 downto 0);
      dram_ar_region  : out std_logic_vector(3 downto 0);
      dram_ar_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_ar_valid   : out std_logic;
      dram_ar_ready   : in  std_logic;
      dram_r_id       : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      dram_r_data     : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      dram_r_resp     : in  std_logic_vector(1 downto 0);
      dram_r_last     : in  std_logic;
      dram_r_user     : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      dram_r_valid    : in  std_logic;
      dram_r_ready    : out std_logic;
      clint_aw_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      clint_aw_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      clint_aw_len    : out std_logic_vector(7 downto 0);
      clint_aw_size   : out std_logic_vector(2 downto 0);
      clint_aw_burst  : out std_logic_vector(1 downto 0);
      clint_aw_lock   : out std_logic;
      clint_aw_cache  : out std_logic_vector(3 downto 0);
      clint_aw_prot   : out std_logic_vector(2 downto 0);
      clint_aw_qos    : out std_logic_vector(3 downto 0);
      clint_aw_atop   : out std_logic_vector(5 downto 0);
      clint_aw_region : out std_logic_vector(3 downto 0);
      clint_aw_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      clint_aw_valid  : out std_logic;
      clint_aw_ready  : in  std_logic;
      clint_w_data    : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      clint_w_strb    : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      clint_w_last    : out std_logic;
      clint_w_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      clint_w_valid   : out std_logic;
      clint_w_ready   : in  std_logic;
      clint_b_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      clint_b_resp    : in  std_logic_vector(1 downto 0);
      clint_b_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      clint_b_valid   : in  std_logic;
      clint_b_ready   : out std_logic;
      clint_ar_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      clint_ar_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      clint_ar_len    : out std_logic_vector(7 downto 0);
      clint_ar_size   : out std_logic_vector(2 downto 0);
      clint_ar_burst  : out std_logic_vector(1 downto 0);
      clint_ar_lock   : out std_logic;
      clint_ar_cache  : out std_logic_vector(3 downto 0);
      clint_ar_prot   : out std_logic_vector(2 downto 0);
      clint_ar_qos    : out std_logic_vector(3 downto 0);
      clint_ar_region : out std_logic_vector(3 downto 0);
      clint_ar_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      clint_ar_valid  : out std_logic;
      clint_ar_ready  : in  std_logic;
      clint_r_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      clint_r_data    : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      clint_r_resp    : in  std_logic_vector(1 downto 0);
      clint_r_last    : in  std_logic;
      clint_r_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      clint_r_valid   : in  std_logic;
      clint_r_ready   : out std_logic;
      slm_aw_id       : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slm_aw_addr     : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      slm_aw_len      : out std_logic_vector(7 downto 0);
      slm_aw_size     : out std_logic_vector(2 downto 0);
      slm_aw_burst    : out std_logic_vector(1 downto 0);
      slm_aw_lock     : out std_logic;
      slm_aw_cache    : out std_logic_vector(3 downto 0);
      slm_aw_prot     : out std_logic_vector(2 downto 0);
      slm_aw_qos      : out std_logic_vector(3 downto 0);
      slm_aw_atop     : out std_logic_vector(5 downto 0);
      slm_aw_region   : out std_logic_vector(3 downto 0);
      slm_aw_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slm_aw_valid    : out std_logic;
      slm_aw_ready    : in  std_logic;
      slm_w_data      : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      slm_w_strb      : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      slm_w_last      : out std_logic;
      slm_w_user      : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slm_w_valid     : out std_logic;
      slm_w_ready     : in  std_logic;
      slm_b_id        : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slm_b_resp      : in  std_logic_vector(1 downto 0);
      slm_b_user      : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slm_b_valid     : in  std_logic;
      slm_b_ready     : out std_logic;
      slm_ar_id       : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slm_ar_addr     : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      slm_ar_len      : out std_logic_vector(7 downto 0);
      slm_ar_size     : out std_logic_vector(2 downto 0);
      slm_ar_burst    : out std_logic_vector(1 downto 0);
      slm_ar_lock     : out std_logic;
      slm_ar_cache    : out std_logic_vector(3 downto 0);
      slm_ar_prot     : out std_logic_vector(2 downto 0);
      slm_ar_qos      : out std_logic_vector(3 downto 0);
      slm_ar_region   : out std_logic_vector(3 downto 0);
      slm_ar_user     : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slm_ar_valid    : out std_logic;
      slm_ar_ready    : in  std_logic;
      slm_r_id        : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slm_r_data      : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      slm_r_resp      : in  std_logic_vector(1 downto 0);
      slm_r_last      : in  std_logic;
      slm_r_user      : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slm_r_valid     : in  std_logic;
      slm_r_ready     : out std_logic;
      slmddr_aw_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slmddr_aw_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      slmddr_aw_len    : out std_logic_vector(7 downto 0);
      slmddr_aw_size   : out std_logic_vector(2 downto 0);
      slmddr_aw_burst  : out std_logic_vector(1 downto 0);
      slmddr_aw_lock   : out std_logic;
      slmddr_aw_cache  : out std_logic_vector(3 downto 0);
      slmddr_aw_prot   : out std_logic_vector(2 downto 0);
      slmddr_aw_qos    : out std_logic_vector(3 downto 0);
      slmddr_aw_atop   : out std_logic_vector(5 downto 0);
      slmddr_aw_region : out std_logic_vector(3 downto 0);
      slmddr_aw_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slmddr_aw_valid  : out std_logic;
      slmddr_aw_ready  : in  std_logic;
      slmddr_w_data    : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      slmddr_w_strb    : out std_logic_vector(AXI_STRB_WIDTH-1 downto 0);
      slmddr_w_last    : out std_logic;
      slmddr_w_user    : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slmddr_w_valid   : out std_logic;
      slmddr_w_ready   : in  std_logic;
      slmddr_b_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slmddr_b_resp    : in  std_logic_vector(1 downto 0);
      slmddr_b_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slmddr_b_valid   : in  std_logic;
      slmddr_b_ready   : out std_logic;
      slmddr_ar_id     : out std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slmddr_ar_addr   : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
      slmddr_ar_len    : out std_logic_vector(7 downto 0);
      slmddr_ar_size   : out std_logic_vector(2 downto 0);
      slmddr_ar_burst  : out std_logic_vector(1 downto 0);
      slmddr_ar_lock   : out std_logic;
      slmddr_ar_cache  : out std_logic_vector(3 downto 0);
      slmddr_ar_prot   : out std_logic_vector(2 downto 0);
      slmddr_ar_qos    : out std_logic_vector(3 downto 0);
      slmddr_ar_region : out std_logic_vector(3 downto 0);
      slmddr_ar_user   : out std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slmddr_ar_valid  : out std_logic;
      slmddr_ar_ready  : in  std_logic;
      slmddr_r_id      : in  std_logic_vector(AXI_ID_WIDTH_SLV-1 downto 0);
      slmddr_r_data    : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
      slmddr_r_resp    : in  std_logic_vector(1 downto 0);
      slmddr_r_last    : in  std_logic;
      slmddr_r_user    : in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
      slmddr_r_valid   : in  std_logic;
      slmddr_r_ready   : out std_logic;
      penable         : out std_logic;
      pwrite          : out std_logic;
      paddr           : out std_logic_vector(31 downto 0);
      psel            : out std_logic;
      pwdata          : out std_logic_vector(31 downto 0);
      prdata          : in  std_logic_vector(31 downto 0);
      pready          : in  std_logic;
      pslverr         : in  std_logic;
      fence_l2        : out std_logic_vector(1 downto 0);
      flush_l1        : in std_logic;
      flush_done      : out std_logic
      );
  end component ariane_wrap;

  signal penable      : std_logic;
  signal pwrite       : std_logic;
  signal paddr        : std_logic_vector(31 downto 0);
  signal psel         : std_logic;
  signal pwdata       : std_logic_vector(31 downto 0);
  signal prdata       : std_logic_vector(31 downto 0);
  signal psel_idx     : integer range 0 to NAPBSLV - 1;
  signal psel_idx_reg : integer range 0 to NAPBSLV - 1;
  signal psel_sig     : std_logic_vector(0 to NAPBSLV - 1);

  constant ARIANE_AXI_ID_WIDTH : integer := 4;
  constant ARIANE_AXI_ID_WIDTH_SLV : integer := ARIANE_AXI_ID_WIDTH + log2(NMST);

begin  -- architecture rtl

  ariane_wrap_1 : ariane_wrap
    generic map (
      NMST             => NMST,
      NSLV             => NSLV,
      AXI_ID_WIDTH     => ARIANE_AXI_ID_WIDTH,
      AXI_ID_WIDTH_SLV => ARIANE_AXI_ID_WIDTH_SLV,
      AXI_ADDR_WIDTH   => GLOB_PHYS_ADDR_BITS,
      AXI_DATA_WIDTH   => ARCH_BITS,
      AXI_USER_WIDTH   => XUSER_WIDTH,
      AXI_STRB_WIDTH   => ARCH_BITS / 8,
      USE_SPANDEX      => USE_SPANDEX,
      ROMBase          => ROMBase,
      ROMLength        => ROMLength,
      APBBase          => APBBase,
      APBLength        => APBLength,
      CLINTBase        => CLINTBase,
      CLINTLength      => CLINTLength,
      SLMBase          => SLMBase,
      SLMLength        => SLMLength,
      SLMDDRBase       => SLMDDRBase,
      SLMDDRLength     => SLMDDRLength,
      DRAMBase         => DRAMBase,
      DRAMLength       => DRAMLength,
      DRAMCachedLength => DRAMCachedLength)
    port map (
      clk             => clk,
      rstn            => rstn,
      HART_ID         => HART_ID,
      irq             => irq,
      timer_irq       => timer_irq,
      ipi             => ipi,
      rom_aw_id       => romi.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_aw_addr     => romi.aw.addr,
      rom_aw_len      => romi.aw.len,
      rom_aw_size     => romi.aw.size,
      rom_aw_burst    => romi.aw.burst,
      rom_aw_lock     => romi.aw.lock,
      rom_aw_cache    => romi.aw.cache,
      rom_aw_prot     => romi.aw.prot,
      rom_aw_qos      => romi.aw.qos,
      rom_aw_atop     => romi.aw.atop,
      rom_aw_region   => romi.aw.region,
      rom_aw_user     => romi.aw.user,
      rom_aw_valid    => romi.aw.valid,
      rom_aw_ready    => romo.aw.ready,
      rom_w_data      => romi.w.data,
      rom_w_strb      => romi.w.strb,
      rom_w_last      => romi.w.last,
      rom_w_user      => romi.w.user,
      rom_w_valid     => romi.w.valid,
      rom_w_ready     => romo.w.ready,
      rom_b_id        => romo.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_b_resp      => romo.b.resp,
      rom_b_user      => romo.b.user,
      rom_b_valid     => romo.b.valid,
      rom_b_ready     => romi.b.ready,
      rom_ar_id       => romi.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_ar_addr     => romi.ar.addr,
      rom_ar_len      => romi.ar.len,
      rom_ar_size     => romi.ar.size,
      rom_ar_burst    => romi.ar.burst,
      rom_ar_lock     => romi.ar.lock,
      rom_ar_cache    => romi.ar.cache,
      rom_ar_prot     => romi.ar.prot,
      rom_ar_qos      => romi.ar.qos,
      rom_ar_region   => romi.ar.region,
      rom_ar_user     => romi.ar.user,
      rom_ar_valid    => romi.ar.valid,
      rom_ar_ready    => romo.ar.ready,
      rom_r_id        => romo.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      rom_r_data      => romo.r.data,
      rom_r_resp      => romo.r.resp,
      rom_r_last      => romo.r.last,
      rom_r_user      => romo.r.user,
      rom_r_valid     => romo.r.valid,
      rom_r_ready     => romi.r.ready,
      dram_aw_id      => drami.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_aw_addr    => drami.aw.addr,
      dram_aw_len     => drami.aw.len,
      dram_aw_size    => drami.aw.size,
      dram_aw_burst   => drami.aw.burst,
      dram_aw_lock    => drami.aw.lock,
      dram_aw_cache   => drami.aw.cache,
      dram_aw_prot    => drami.aw.prot,
      dram_aw_qos     => drami.aw.qos,
      dram_aw_atop    => drami.aw.atop,
      dram_aw_region  => drami.aw.region,
      dram_aw_user    => drami.aw.user,
      dram_aw_valid   => drami.aw.valid,
      dram_aw_ready   => dramo.aw.ready,
      dram_ac_addr    => ace_req.ac.addr,
      dram_ac_prot    => ace_req.ac.prot,
      dram_ac_snoop   => ace_req.ac.snoop,
      dram_ac_valid   => ace_req.ac.valid,
      dram_ac_ready   => ace_resp.ac.ready,
      dram_w_data     => drami.w.data,
      dram_w_strb     => drami.w.strb,
      dram_w_last     => drami.w.last,
      dram_w_user     => drami.w.user,
      dram_w_valid    => drami.w.valid,
      dram_w_ready    => dramo.w.ready,
      dram_b_id       => dramo.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_b_resp     => dramo.b.resp,
      dram_b_user     => dramo.b.user,
      dram_b_valid    => dramo.b.valid,
      dram_b_ready    => drami.b.ready,
      dram_ar_id      => drami.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_ar_addr    => drami.ar.addr,
      dram_ar_len     => drami.ar.len,
      dram_ar_size    => drami.ar.size,
      dram_ar_burst   => drami.ar.burst,
      dram_ar_lock    => drami.ar.lock,
      dram_ar_cache   => drami.ar.cache,
      dram_ar_prot    => drami.ar.prot,
      dram_ar_qos     => drami.ar.qos,
      dram_ar_region  => drami.ar.region,
      dram_ar_user    => drami.ar.user,
      dram_ar_valid   => drami.ar.valid,
      dram_ar_ready   => dramo.ar.ready,
      dram_r_id       => dramo.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      dram_r_data     => dramo.r.data,
      dram_r_resp     => dramo.r.resp,
      dram_r_last     => dramo.r.last,
      dram_r_user     => dramo.r.user,
      dram_r_valid    => dramo.r.valid,
      dram_r_ready    => drami.r.ready,
      clint_aw_id     => clinti.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      clint_aw_addr   => clinti.aw.addr,
      clint_aw_len    => clinti.aw.len,
      clint_aw_size   => clinti.aw.size,
      clint_aw_burst  => clinti.aw.burst,
      clint_aw_lock   => clinti.aw.lock,
      clint_aw_cache  => clinti.aw.cache,
      clint_aw_prot   => clinti.aw.prot,
      clint_aw_qos    => clinti.aw.qos,
      clint_aw_atop   => clinti.aw.atop,
      clint_aw_region => clinti.aw.region,
      clint_aw_user   => clinti.aw.user,
      clint_aw_valid  => clinti.aw.valid,
      clint_aw_ready  => clinto.aw.ready,
      clint_w_data    => clinti.w.data,
      clint_w_strb    => clinti.w.strb,
      clint_w_last    => clinti.w.last,
      clint_w_user    => clinti.w.user,
      clint_w_valid   => clinti.w.valid,
      clint_w_ready   => clinto.w.ready,
      clint_b_id      => clinto.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      clint_b_resp    => clinto.b.resp,
      clint_b_user    => clinto.b.user,
      clint_b_valid   => clinto.b.valid,
      clint_b_ready   => clinti.b.ready,
      clint_ar_id     => clinti.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      clint_ar_addr   => clinti.ar.addr,
      clint_ar_len    => clinti.ar.len,
      clint_ar_size   => clinti.ar.size,
      clint_ar_burst  => clinti.ar.burst,
      clint_ar_lock   => clinti.ar.lock,
      clint_ar_cache  => clinti.ar.cache,
      clint_ar_prot   => clinti.ar.prot,
      clint_ar_qos    => clinti.ar.qos,
      clint_ar_region => clinti.ar.region,
      clint_ar_user   => clinti.ar.user,
      clint_ar_valid  => clinti.ar.valid,
      clint_ar_ready  => clinto.ar.ready,
      clint_r_id      => clinto.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      clint_r_data    => clinto.r.data,
      clint_r_resp    => clinto.r.resp,
      clint_r_last    => clinto.r.last,
      clint_r_user    => clinto.r.user,
      clint_r_valid   => clinto.r.valid,
      clint_r_ready   => clinti.r.ready,
      slm_aw_id       => slmi.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slm_aw_addr     => slmi.aw.addr,
      slm_aw_len      => slmi.aw.len,
      slm_aw_size     => slmi.aw.size,
      slm_aw_burst    => slmi.aw.burst,
      slm_aw_lock     => slmi.aw.lock,
      slm_aw_cache    => slmi.aw.cache,
      slm_aw_prot     => slmi.aw.prot,
      slm_aw_qos      => slmi.aw.qos,
      slm_aw_atop     => slmi.aw.atop,
      slm_aw_region   => slmi.aw.region,
      slm_aw_user     => slmi.aw.user,
      slm_aw_valid    => slmi.aw.valid,
      slm_aw_ready    => slmo.aw.ready,
      slm_w_data      => slmi.w.data,
      slm_w_strb      => slmi.w.strb,
      slm_w_last      => slmi.w.last,
      slm_w_user      => slmi.w.user,
      slm_w_valid     => slmi.w.valid,
      slm_w_ready     => slmo.w.ready,
      slm_b_id        => slmo.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slm_b_resp      => slmo.b.resp,
      slm_b_user      => slmo.b.user,
      slm_b_valid     => slmo.b.valid,
      slm_b_ready     => slmi.b.ready,
      slm_ar_id       => slmi.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slm_ar_addr     => slmi.ar.addr,
      slm_ar_len      => slmi.ar.len,
      slm_ar_size     => slmi.ar.size,
      slm_ar_burst    => slmi.ar.burst,
      slm_ar_lock     => slmi.ar.lock,
      slm_ar_cache    => slmi.ar.cache,
      slm_ar_prot     => slmi.ar.prot,
      slm_ar_qos      => slmi.ar.qos,
      slm_ar_region   => slmi.ar.region,
      slm_ar_user     => slmi.ar.user,
      slm_ar_valid    => slmi.ar.valid,
      slm_ar_ready    => slmo.ar.ready,
      slm_r_id        => slmo.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slm_r_data      => slmo.r.data,
      slm_r_resp      => slmo.r.resp,
      slm_r_last      => slmo.r.last,
      slm_r_user      => slmo.r.user,
      slm_r_valid     => slmo.r.valid,
      slm_r_ready     => slmi.r.ready,
      slmddr_aw_id     => slmddri.aw.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slmddr_aw_addr   => slmddri.aw.addr,
      slmddr_aw_len    => slmddri.aw.len,
      slmddr_aw_size   => slmddri.aw.size,
      slmddr_aw_burst  => slmddri.aw.burst,
      slmddr_aw_lock   => slmddri.aw.lock,
      slmddr_aw_cache  => slmddri.aw.cache,
      slmddr_aw_prot   => slmddri.aw.prot,
      slmddr_aw_qos    => slmddri.aw.qos,
      slmddr_aw_atop   => slmddri.aw.atop,
      slmddr_aw_region => slmddri.aw.region,
      slmddr_aw_user   => slmddri.aw.user,
      slmddr_aw_valid  => slmddri.aw.valid,
      slmddr_aw_ready  => slmddro.aw.ready,
      slmddr_w_data    => slmddri.w.data,
      slmddr_w_strb    => slmddri.w.strb,
      slmddr_w_last    => slmddri.w.last,
      slmddr_w_user    => slmddri.w.user,
      slmddr_w_valid   => slmddri.w.valid,
      slmddr_w_ready   => slmddro.w.ready,
      slmddr_b_id      => slmddro.b.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slmddr_b_resp    => slmddro.b.resp,
      slmddr_b_user    => slmddro.b.user,
      slmddr_b_valid   => slmddro.b.valid,
      slmddr_b_ready   => slmddri.b.ready,
      slmddr_ar_id     => slmddri.ar.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slmddr_ar_addr   => slmddri.ar.addr,
      slmddr_ar_len    => slmddri.ar.len,
      slmddr_ar_size   => slmddri.ar.size,
      slmddr_ar_burst  => slmddri.ar.burst,
      slmddr_ar_lock   => slmddri.ar.lock,
      slmddr_ar_cache  => slmddri.ar.cache,
      slmddr_ar_prot   => slmddri.ar.prot,
      slmddr_ar_qos    => slmddri.ar.qos,
      slmddr_ar_region => slmddri.ar.region,
      slmddr_ar_user   => slmddri.ar.user,
      slmddr_ar_valid  => slmddri.ar.valid,
      slmddr_ar_ready  => slmddro.ar.ready,
      slmddr_r_id      => slmddro.r.id(ARIANE_AXI_ID_WIDTH_SLV - 1 downto 0),
      slmddr_r_data    => slmddro.r.data,
      slmddr_r_resp    => slmddro.r.resp,
      slmddr_r_last    => slmddro.r.last,
      slmddr_r_user    => slmddro.r.user,
      slmddr_r_valid   => slmddro.r.valid,
      slmddr_r_ready   => slmddri.r.ready,
      penable         => penable,
      pwrite          => pwrite,
      paddr           => paddr,
      psel            => psel,
      pwdata          => pwdata,
      prdata          => prdata,
      pready          => apb_ack,
      pslverr         => '0',
      fence_l2        => fence_l2,
      flush_l1        => flush_l1,
      flush_done      => flush_done
      );

  -- Unused extended AXI ID
  romi.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  romi.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  drami.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV) <= (others => '0');
  drami.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV) <= (others => '0');
  clinti.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  clinti.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  slmi.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  slmi.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  slmddri.aw.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');
  slmddri.ar.id(XID_WIDTH - 1 downto ARIANE_AXI_ID_WIDTH_SLV)  <= (others => '0');

  -- Unused
  apbi.pirq    <= (others => '0');
  apbi.testen  <= '0';
  apbi.testrst <= '0';
  apbi.scanen  <= '0';
  apbi.testoen <= '0';
  apbi.testin  <= (others => '0');

  -- APB slave input
  apb_req <= psel and penable;

  psel_gen: for i in 0 to NAPBSLV - 1 generate
    psel_sig(i) <= apb_slv_decode(apbo(i).pconfig, paddr(19 downto  8), paddr(27 downto 20)) and psel;
  end generate psel_gen;

  psel_idx_gen: process (psel_sig) is
  begin  -- process psel_gen
    psel_idx <= 0;
    for i in 0 to NAPBSLV - 1 loop
      if psel_sig(i) = '1' then
        psel_idx <= i;
      end if;
    end loop;
  end process psel_idx_gen;

  apbi.penable <= penable;
  apbi.pwrite  <= pwrite;
  apbi.paddr   <= X"0fffffff" and paddr;
  apbi.pwdata  <= pwdata;
  apbi.psel    <= psel_sig;


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
