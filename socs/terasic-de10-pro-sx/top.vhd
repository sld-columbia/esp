-- Copyright (c) 2011-2026 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
------------------------------------------------------------------------------
--  ESP - Terasic DE10-Pro SX
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.misc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on

entity top is
  generic (
    SIMULATION : boolean := false
    );
  port (
    reset            : in    std_ulogic;
    chip_refclk      : in    std_ulogic;  -- 50MHz
    uart_rxd         : in    std_ulogic;  -- UART1_RX (u1i.rxd)
    uart_txd         : out   std_ulogic;  -- UART1_TX (u1o.txd)
    uart_ctsn        : in    std_ulogic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn        : out   std_ulogic;  -- UART1_RTSN (u1o.rtsn)
    led              : out   std_logic_vector(6 downto 0);
    -- DDR AXI master interface (ESP -> HPS F2SDRAM0)
    ddr_awid         : out   std_logic_vector(3 downto 0);
    ddr_awaddr       : out   std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    ddr_awlen        : out   std_logic_vector(7 downto 0);
    ddr_awsize       : out   std_logic_vector(2 downto 0);
    ddr_awburst      : out   std_logic_vector(1 downto 0);
    ddr_awlock       : out   std_logic;
    ddr_awcache      : out   std_logic_vector(3 downto 0);
    ddr_awprot       : out   std_logic_vector(2 downto 0);
    ddr_awqos        : out   std_logic_vector(3 downto 0);
    ddr_awvalid      : out   std_logic;
    ddr_awready      : in    std_logic;
    ddr_wdata        : out   std_logic_vector(63 downto 0);
    ddr_wstrb        : out   std_logic_vector(7 downto 0);
    ddr_wlast        : out   std_logic;
    ddr_wvalid       : out   std_logic;
    ddr_wready       : in    std_logic;
    ddr_bid          : in    std_logic_vector(3 downto 0);
    ddr_bresp        : in    std_logic_vector(1 downto 0);
    ddr_bvalid       : in    std_logic;
    ddr_bready       : out   std_logic;
    ddr_arid         : out   std_logic_vector(3 downto 0);
    ddr_araddr       : out   std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    ddr_arlen        : out   std_logic_vector(7 downto 0);
    ddr_arsize       : out   std_logic_vector(2 downto 0);
    ddr_arburst      : out   std_logic_vector(1 downto 0);
    ddr_arlock       : out   std_logic;
    ddr_arcache      : out   std_logic_vector(3 downto 0);
    ddr_arprot       : out   std_logic_vector(2 downto 0);
    ddr_arqos        : out   std_logic_vector(3 downto 0);
    ddr_arvalid      : out   std_logic;
    ddr_arready      : in    std_logic;
    ddr_rid          : in    std_logic_vector(3 downto 0);
    ddr_rdata        : in    std_logic_vector(63 downto 0);
    ddr_rresp        : in    std_logic_vector(1 downto 0);
    ddr_rlast        : in    std_logic;
    ddr_rvalid       : in    std_logic;
    ddr_rready       : out   std_logic;
    -- AHB response channel back to the external h2f AXI-to-AHB bridge ("mi_*" at the bridge)
    mi_hready        : out   std_ulogic;  -- transfer done
    mi_hresp         : out   std_logic_vector(1 downto 0);  -- response type
    mi_hrdata        : out   std_logic_vector(31 downto 0);  -- read data bus
    mi_hgrant        : out   std_ulogic;  -- bus grant for master index 1
    -- AHB request channel driven into this wrapper by the external h2f AXI-to-AHB bridge ("mo_*" at the bridge)
    mo_hlock         : in    std_ulogic;  -- lock request
    mo_htrans        : in    std_logic_vector(1 downto 0);  -- transfer type
    mo_haddr         : in    std_logic_vector(31 downto 0);  -- address bus (byte)
    mo_hwrite        : in    std_ulogic;  -- read/write
    mo_hsize         : in    std_logic_vector(2 downto 0);  -- transfer size
    mo_hburst        : in    std_logic_vector(2 downto 0);  -- burst type
    mo_hprot         : in    std_logic_vector(3 downto 0);  -- protection control
    mo_hwdata        : in    std_logic_vector(31 downto 0)  -- write data bus
    );
end top;


architecture rtl of top is

constant CPU_FREQ : integer := 50000;  -- cpu frequency in KHz

  -- clock and reset
  signal rstn      : std_ulogic;
  signal lock  : std_ulogic;

  -- Memory controller DDR4
  signal ddr_axi_si       : axi_mosi_vector(0 to MEM_ID_RANGE_MSB);
  signal ddr_axi_so       : axi_somi_vector(0 to MEM_ID_RANGE_MSB);
  signal ddr_awready_i    : std_logic;
  signal ddr_wready_i     : std_logic;
  signal ddr_arready_i    : std_logic;
  signal ddr_aw_accept    : std_logic;
  signal ddr_w_accept     : std_logic;
  signal ddr_b_accept     : std_logic;
  signal ddr_ar_accept    : std_logic;
  signal ddr_r_accept     : std_logic;
  signal ddr_write_busy   : std_logic;
  signal ddr_write_data   : std_logic;
  signal ddr_read_busy    : std_logic;
  signal ddr_write_id     : std_logic_vector(XID_WIDTH - 1 downto 0);
  signal ddr_read_id      : std_logic_vector(XID_WIDTH - 1 downto 0);
  signal ddr_write_lane   : std_logic;
  signal ddr_read_lane    : std_logic;
  signal ddr_write_word   : std_logic;
  signal ddr_read_word    : std_logic;

  function hps_ddr_64_promote_narrow_read(size : std_logic_vector(2 downto 0))
    return boolean is
  begin
    return size = HSIZE_BYTE or size = HSIZE_HWORD;
  end function hps_ddr_64_promote_narrow_read;

  function hps_ddr_read_size(size : std_logic_vector(2 downto 0))
    return std_logic_vector is
  begin
    if AXIDW = 64 and hps_ddr_64_promote_narrow_read(size) then
      return XSIZE_WORD;
    end if;

    if AXIDW = 32 and GLOB_CPU_ARCH = leon3 and
       (size = HSIZE_BYTE or size = HSIZE_HWORD) then
      return XSIZE_WORD;
    end if;

    return size;
  end function hps_ddr_read_size;

  function hps_ddr_leon3_addr(
    addr : std_logic_vector(GLOB_PHYS_ADDR_BITS - 1 downto 0);
    size : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable translated : unsigned(GLOB_PHYS_ADDR_BITS - 1 downto 0);
  begin
    translated := unsigned(addr) + to_unsigned(16#40000000#, GLOB_PHYS_ADDR_BITS);

    if size = HSIZE_BYTE or size = HSIZE_HWORD then
      translated(1 downto 0) := (others => '0');
    end if;

    return std_logic_vector(translated);
  end function hps_ddr_leon3_addr;

  function hps_ddr_64_flip_read_lane(size : std_logic_vector(2 downto 0))
    return boolean is
  begin
    return hps_ddr_64_promote_narrow_read(size) or size = XSIZE_WORD;
  end function hps_ddr_64_flip_read_lane;

  -- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

  -- DVI (unused on this board)
  signal dvi_apbi  : apb_slv_in_type;
  signal dvi_apbo  : apb_slv_out_type;
  signal dvi_ahbmi : ahb_mst_in_type;
  signal dvi_ahbmo : ahb_mst_out_type;

  -- Ethernet (unused on this board)
  signal eth0_apbi   : apb_slv_in_type;
  signal eth0_apbo   : apb_slv_out_type;
  signal sgmii0_apbi : apb_slv_in_type;
  signal sgmii0_apbo : apb_slv_out_type;
  signal eth0_ahbmi  : ahb_mst_in_type;
  signal eth0_ahbmo  : ahb_mst_out_type;
  signal edcl_ahbmo  : ahb_mst_out_type;

  -- CPU flags
  signal cpuerr : std_ulogic;

  -- NOC
  signal sys_clk        : std_logic_vector(0 to 0);

  attribute keep                    : boolean;
  attribute syn_keep                : string;
  attribute keep of chip_refclk     : signal is true;
  attribute syn_keep of chip_refclk : signal is "true";

  constant edcl_hconfig : ahb_config_type := (
    0      => ahb_device_reg (VENDOR_GAISLER, GAISLER_EDCLMST, 0, 0, 0),
    others => zero32);

begin

  ----------------------------------------------------------------------
  --- FPGA Reset and Clock generation  ---------------------------------
  ----------------------------------------------------------------------

  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (reset, chip_refclk, lock, rstn, open);
  lock <= '1';

  -----------------------------------------------------------------------------
  -- LEDs
  -----------------------------------------------------------------------------

  -- From CPU 0
  led(0) <= cpuerr;
  --pragma translate_off
  process(chip_refclk, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
    led(1) <= ddr_awready or ddr_arready;

  -----------------------------------------------------------------------------
  -- UART pads
  -----------------------------------------------------------------------------

  uart_rxd_int <= uart_rxd;
  uart_txd <= uart_txd_int;
  uart_ctsn_int <= uart_ctsn;
  uart_rtsn <= uart_rtsn_int;

  ------------------------------------------------------------------------------
  -- Simulation DDR model
  ------------------------------------------------------------------------------
  -- RTL simulation should see the same native AXI memory model used by the
  -- Xilinx simulation flow. The fixed 64-bit HPS F2SDRAM shim below is a board
  -- integration detail and should not sit between the ESP core and the generic
  -- simulation RAM.
  -- pragma translate_off
  ddr_sim_model_gen : if SIMULATION = true generate
    ddr_model : axi_ram_sim
      generic map (
        kbytes          => 2048,
        DATA_WIDTH      => AXIDW,
        ADDR_WIDTH      => GLOB_PHYS_ADDR_BITS,
        STRB_WIDTH      => AW,
        ID_WIDTH        => 8,
        PIPELINE_OUTPUT => 0
        )
      port map (
        rst        => rstn,
        clk        => chip_refclk,
        ddr_axi_si => ddr_axi_si(0),
        ddr_axi_so => ddr_axi_so(0)
        );

    ddr_awid    <= (others => '0');
    ddr_awaddr  <= (others => '0');
    ddr_awlen   <= (others => '0');
    ddr_awsize  <= (others => '0');
    ddr_awburst <= (others => '0');
    ddr_awlock  <= '0';
    ddr_awcache <= (others => '0');
    ddr_awprot  <= (others => '0');
    ddr_awqos   <= (others => '0');
    ddr_awvalid <= '0';
    ddr_wdata   <= (others => '0');
    ddr_wstrb   <= (others => '0');
    ddr_wlast   <= '0';
    ddr_wvalid  <= '0';
    ddr_bready  <= '0';
    ddr_arid    <= (others => '0');
    ddr_araddr  <= (others => '0');
    ddr_arlen   <= (others => '0');
    ddr_arsize  <= (others => '0');
    ddr_arburst <= (others => '0');
    ddr_arlock  <= '0';
    ddr_arcache <= (others => '0');
    ddr_arprot  <= (others => '0');
    ddr_arqos   <= (others => '0');
    ddr_arvalid <= '0';
    ddr_rready  <= '0';
  end generate ddr_sim_model_gen;
  -- pragma translate_on

  ----------------------------------------------------------------------
  --- HPS-side DDR4 interface wired directly to the ESP AXI memory port
  ----------------------------------------------------------------------
  -- The Stratix 10 HPS DDR port exposes the base AXI channels only. Its
  -- F2SDRAM ID pins are fixed at 4 bits, while ESP can use wider IDs to
  -- distinguish merged CPU/cache masters. Serialize this boundary and restore
  -- the full ESP-side ID on responses so the upstream AXI fabric never sees
  -- truncated response IDs.
  ddr_hps_gen : if SIMULATION = false generate
    ddr_awready_i      <= ddr_awready and not ddr_write_busy;
    ddr_wready_i       <= ddr_wready and ddr_write_data;
    ddr_arready_i      <= ddr_arready and not ddr_read_busy;
    ddr_aw_accept      <= ddr_axi_si(0).aw.valid and ddr_awready_i;
    ddr_w_accept       <= ddr_axi_si(0).w.valid and ddr_wready_i;
    ddr_b_accept       <= ddr_bvalid and ddr_axi_si(0).b.ready;
    ddr_ar_accept      <= ddr_axi_si(0).ar.valid and ddr_arready_i;
    ddr_r_accept       <= ddr_rvalid and ddr_axi_si(0).r.ready;

    process(chip_refclk, reset)
    begin
      if reset = '1' then
        ddr_write_busy <= '0';
        ddr_write_data <= '0';
        ddr_read_busy  <= '0';
        ddr_write_id   <= (others => '0');
        ddr_read_id    <= (others => '0');
        ddr_write_lane <= '0';
        ddr_read_lane  <= '0';
        ddr_write_word <= '0';
        ddr_read_word  <= '0';
      elsif rising_edge(chip_refclk) then
        if ddr_aw_accept = '1' then
          ddr_write_busy <= '1';
          ddr_write_data <= '1';
          ddr_write_id   <= ddr_axi_si(0).aw.id;
          ddr_write_lane <= ddr_axi_si(0).aw.addr(2);
          if ddr_axi_si(0).aw.size = XSIZE_WORD then
            ddr_write_word <= '1';
          else
            ddr_write_word <= '0';
          end if;
        elsif ddr_b_accept = '1' then
          ddr_write_busy <= '0';
        end if;

        if ddr_w_accept = '1' and ddr_axi_si(0).w.last = '1' then
          ddr_write_data <= '0';
        end if;
        if ddr_w_accept = '1' and ddr_write_word = '1' then
          ddr_write_lane <= not ddr_write_lane;
        end if;

        if ddr_ar_accept = '1' then
          ddr_read_busy <= '1';
          ddr_read_id   <= ddr_axi_si(0).ar.id;
          -- Select the addressed 32-bit half of the 64-bit HPS beat for all
          -- 32-bit-path reads. Word bursts toggle this lane below; byte/halfword
          -- reads still need the initial lane from addr(2).
          ddr_read_lane <= ddr_axi_si(0).ar.addr(2);
          if ddr_axi_si(0).ar.size = XSIZE_WORD then
            -- Keep the HPS AXI address natural; split the returned 64-bit beat
            -- into 32-bit ESP words by selecting and toggling the addressed lane.
            ddr_read_word <= '1';
          else
            ddr_read_word <= '0';
          end if;
        elsif ddr_r_accept = '1' and ddr_rlast = '1' then
          ddr_read_busy <= '0';
        end if;
        if ddr_r_accept = '1' and ddr_read_word = '1' then
          ddr_read_lane <= not ddr_read_lane;
        end if;
      end if;
    end process;

    -- ESP's extra AXI sidebands (ATOP/REGION/USER) are not forwarded on this
    -- board path.
    ddr_awid           <= ddr_axi_si(0).aw.id(3 downto 0);
    ddr_awlen          <= ddr_axi_si(0).aw.len;
    ddr_awsize         <= ddr_axi_si(0).aw.size;
    ddr_awburst        <= ddr_axi_si(0).aw.burst;
    ddr_awlock         <= ddr_axi_si(0).aw.lock;
    ddr_awcache        <= ddr_axi_si(0).aw.cache;
    -- Stratix 10 HPS F2SDRAM is TrustZone-aware. When Linux is running at EL1/EL2,
    -- shared DDR accesses from the FPGA side must be tagged as non-secure privileged
    -- (AxPROT = 0b011) or the SDRAM firewall can raise an external error/SError.
    ddr_awprot         <= "011";
    ddr_awqos          <= ddr_axi_si(0).aw.qos;
    ddr_awvalid        <= ddr_axi_si(0).aw.valid and not ddr_write_busy;
    ddr_wlast          <= ddr_axi_si(0).w.last;
    ddr_wvalid         <= ddr_axi_si(0).w.valid and ddr_write_data;
    ddr_bready         <= ddr_axi_si(0).b.ready;
    ddr_arid           <= ddr_axi_si(0).ar.id(3 downto 0);
    ddr_arlen          <= ddr_axi_si(0).ar.len;
    ddr_arsize         <= hps_ddr_read_size(ddr_axi_si(0).ar.size);
    ddr_arburst        <= ddr_axi_si(0).ar.burst;
    ddr_arlock         <= ddr_axi_si(0).ar.lock;
    ddr_arcache        <= ddr_axi_si(0).ar.cache;
    ddr_arprot         <= "011";
    ddr_arqos          <= ddr_axi_si(0).ar.qos;
    ddr_arvalid        <= ddr_axi_si(0).ar.valid and not ddr_read_busy;
    ddr_rready         <= ddr_axi_si(0).r.ready;

    ddr_axi_so(0).aw.ready                   <= ddr_awready_i;
    ddr_axi_so(0).w.ready                    <= ddr_wready_i;
    ddr_axi_so(0).b.id                       <= ddr_write_id;
    ddr_axi_so(0).b.resp                     <= ddr_bresp;
    ddr_axi_so(0).b.user                     <= (others => '0');
    ddr_axi_so(0).b.valid                    <= ddr_bvalid;
    ddr_axi_so(0).ar.ready                   <= ddr_arready_i;
    ddr_axi_so(0).r.id                       <= ddr_read_id;
    ddr_axi_so(0).r.resp                     <= ddr_rresp;
    ddr_axi_so(0).r.last                     <= ddr_rlast;
    ddr_axi_so(0).r.user                     <= (others => '0');
    ddr_axi_so(0).r.valid                    <= ddr_rvalid;

    ddr_data_64_gen : if AXIDW = 64 generate
      -- Ariane's 64-bit path needs Stratix 10 F2SDRAM read-lane translation for
      -- sub-64-bit reads. Full cache-line/64-bit reads use the natural address;
      -- byte/halfword reads are promoted to aligned word reads, and word reads
      -- need the opposite 32-bit half of the HPS beat. The 32-bit CPU path below
      -- instead keeps the HPS address natural and selects/promotes the returned
      -- half-beat explicitly.
      ddr_awaddr <= ddr_axi_si(0).aw.addr;
      ddr_araddr(GLOB_PHYS_ADDR_BITS - 1 downto 3) <=
        ddr_axi_si(0).ar.addr(GLOB_PHYS_ADDR_BITS - 1 downto 3);
      ddr_araddr(2) <= not ddr_axi_si(0).ar.addr(2)
                       when hps_ddr_64_flip_read_lane(ddr_axi_si(0).ar.size) else
                       ddr_axi_si(0).ar.addr(2);
      ddr_araddr(1 downto 0) <= (others => '0')
                                when hps_ddr_64_promote_narrow_read(ddr_axi_si(0).ar.size) else
                                ddr_axi_si(0).ar.addr(1 downto 0);

      ddr_wdata <= ddr_axi_si(0).w.data;
      ddr_wstrb <= ddr_axi_si(0).w.strb;
      ddr_axi_so(0).r.data <= ddr_rdata;
    end generate ddr_data_64_gen;

    ddr_data_32_gen : if AXIDW = 32 generate
      ddr_32_native_addr_gen : if GLOB_CPU_ARCH /= leon3 generate
        ddr_awaddr <= ddr_axi_si(0).aw.addr;
        ddr_araddr <= ddr_axi_si(0).ar.addr;
      end generate ddr_32_native_addr_gen;

      ddr_32_leon3_addr_gen : if GLOB_CPU_ARCH = leon3 generate
        -- LEON3's ESP-local DDR ABI starts at 0x40000000, but the DE10-Pro HPS
        -- boot setup reserves/opens the high DDR window used by the RISC-V
        -- profiles. Keep the CPU-visible map unchanged and offset only the
        -- hardware F2SDRAM address so loader writes and LEON3 reads land in
        -- the backed HPS DDR aperture.
        ddr_awaddr <= std_logic_vector(unsigned(ddr_axi_si(0).aw.addr) +
                                       to_unsigned(16#40000000#, GLOB_PHYS_ADDR_BITS));
        -- LEON3 performs SPARC big-endian byte/halfword extraction after the
        -- memory system returns a 32-bit word. The 64-bit HPS F2SDRAM port
        -- returns lane-positioned data for byte/halfword AXI reads, so promote
        -- narrow LEON3 reads to aligned 32-bit reads at this board boundary.
        ddr_araddr <= hps_ddr_leon3_addr(ddr_axi_si(0).ar.addr, ddr_axi_si(0).ar.size);
      end generate ddr_32_leon3_addr_gen;

      -- The HPS F2SDRAM data bus is fixed at 64 bits even when ESP is built
      -- around a 32-bit AHB/AXI datapath. Drive and sample the addressed word
      -- lane explicitly instead of relying on mixed-language width truncation.
      ddr_wdata <= ddr_axi_si(0).w.data & X"00000000" when ddr_write_lane = '1' else
                   X"00000000" & ddr_axi_si(0).w.data;
      ddr_wstrb <= ddr_axi_si(0).w.strb & "0000" when ddr_write_lane = '1' else
                   "0000" & ddr_axi_si(0).w.strb;
      ddr_axi_so(0).r.data <= ddr_rdata(63 downto 32) when ddr_read_lane = '1' else
                              ddr_rdata(31 downto 0);
    end generate ddr_data_32_gen;
  end generate ddr_hps_gen;

  -----------------------------------------------------------------------------
  -- ETHERNET interface through AXI-to-AHB-L adapter
  -----------------------------------------------------------------------------
  edcl_ahbmo.hbusreq <= '0' when edcl_ahbmo.htrans = HTRANS_IDLE else '1';
  edcl_ahbmo.hlock   <= mo_hlock;
  edcl_ahbmo.htrans  <= mo_htrans;
  edcl_ahbmo.haddr   <= mo_haddr;
  edcl_ahbmo.hwrite  <= mo_hwrite;
  edcl_ahbmo.hsize   <= mo_hsize;
  edcl_ahbmo.hburst  <= mo_hburst;
  edcl_ahbmo.hprot   <= mo_hprot;
  edcl_ahbmo.hwdata  <= ahbdrivedata(mo_hwdata);
  edcl_ahbmo.hirq    <= (others => '0');
  edcl_ahbmo.hconfig <= edcl_hconfig;
  edcl_ahbmo.hindex  <= 1;

  mi_hready <= eth0_ahbmi.hready;
  mi_hresp  <= eth0_ahbmi.hresp;
  mi_hgrant <= eth0_ahbmi.hgrant(1);

  hps_read_data_64 : if AHBDW = 64 generate
    -- Ariane uses a 64-bit GRLIB AHB bus. A 32-bit HPS read at an
    -- 8-byte-aligned address is returned in the upper half of hrdata, while
    -- addr+4 is returned in the lower half. The HPS bridge is 32-bit, so
    -- select the word lane explicitly.
    mi_hrdata <= eth0_ahbmi.hrdata(63 downto 32) when mo_haddr(2) = '0' else
                 eth0_ahbmi.hrdata(31 downto 0);
  end generate hps_read_data_64;

  hps_read_data_32 : if AHBDW = 32 generate
    mi_hrdata <= eth0_ahbmi.hrdata(31 downto 0);
  end generate hps_read_data_32;

  -----------------------------------------------------------------------
  ---  ETHERNET ---------------------------------------------------------
  -----------------------------------------------------------------------

  eth0_apbo   <= apb_none;
  sgmii0_apbo <= apb_none;
  eth0_ahbmo  <= ahbm_none;

  ------------------------------------------------------------------------
  -- CHIP
  ------------------------------------------------------------------------
  sys_clk(0)     <= chip_refclk;

  esp_1 : esp
    generic map (
      SIMULATION => SIMULATION)
    port map (
      rst         => rstn,
      sys_clk     => sys_clk(0 to MEM_ID_RANGE_MSB),
      refclk      => chip_refclk,
      uart_rxd    => uart_rxd_int,
      uart_txd    => uart_txd_int,
      uart_ctsn   => uart_ctsn_int,
      uart_rtsn   => uart_rtsn_int,
      cpuerr      => cpuerr,
      ddr_axi_si  => ddr_axi_si,
      ddr_axi_so  => ddr_axi_so,
      eth0_ahbmi  => eth0_ahbmi,
      eth0_ahbmo  => eth0_ahbmo,
      edcl_ahbmo  => edcl_ahbmo,
      eth0_apbi   => eth0_apbi,
      eth0_apbo   => eth0_apbo,
      sgmii0_apbi => sgmii0_apbi,
      sgmii0_apbo => sgmii0_apbo,
      dvi_apbi    => dvi_apbi,
      dvi_apbo    => dvi_apbo,
      dvi_ahbmi   => dvi_ahbmi,
      dvi_ahbmo   => dvi_ahbmo);

end;
