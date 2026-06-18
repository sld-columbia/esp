-- esp_ahb_slave_to_hps_f2sdram_axi.vhd
-- AHB-Lite Slave (from ESP) -> AXI4 Master (to HPS F2SDRAM0)
-- Single-beat transfers on AXI (AWLEN/ARLEN=0). Handles AHB sizes 1/2/4/8.
-- 2-process style; no multiple drivers; no variable part-selects.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity esp_ahb_slave_to_hps_f2sdram_axi is
  generic (
    ADDR_WIDTH : integer := 32;
    AHB_DW     : integer := 32;  -- 32 or 64
    AXI_DW     : integer := 64;  -- F2SDRAM0 typically 64
    AXI_ID_W   : integer := 4
  );
  port (
    -- F2SDRAM clock/reset
    f2sdram_clk   : in  std_logic;
    f2sdram_rst_n : in  std_logic;

    -- AHB-Lite SLAVE (toward ESP)
    si_hready     : in  std_logic;
    si_hsel       : in  std_logic;
    si_htrans     : in  std_logic_vector(1 downto 0);
    si_haddr      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    si_hwrite     : in  std_logic;
    si_hsize      : in  std_logic_vector(2 downto 0);
    si_hburst     : in  std_logic_vector(2 downto 0);
    si_hprot      : in  std_logic_vector(3 downto 0);
    si_hwdata     : in  std_logic_vector(AHB_DW-1 downto 0);

    so_hready     : out std_logic;
    so_hresp      : out std_logic_vector(1 downto 0);
    so_hrdata     : out std_logic_vector(AHB_DW-1 downto 0);

    -- AXI4-M (to F2SDRAM0)
    f2sdram0_AWID     : out std_logic_vector(AXI_ID_W-1 downto 0);
    f2sdram0_AWADDR   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    f2sdram0_AWLEN    : out std_logic_vector(7 downto 0);
    f2sdram0_AWSIZE   : out std_logic_vector(2 downto 0);
    f2sdram0_AWBURST  : out std_logic_vector(1 downto 0);
    f2sdram0_AWLOCK   : out std_logic;
    f2sdram0_AWCACHE  : out std_logic_vector(3 downto 0);
    f2sdram0_AWPROT   : out std_logic_vector(2 downto 0);
    f2sdram0_AWQOS    : out std_logic_vector(3 downto 0);
    f2sdram0_AWVALID  : out std_logic;
    f2sdram0_AWREADY  : in  std_logic;

    f2sdram0_WDATA    : out std_logic_vector(AXI_DW-1 downto 0);
    f2sdram0_WSTRB    : out std_logic_vector((AXI_DW/8)-1 downto 0);
    f2sdram0_WLAST    : out std_logic;
    f2sdram0_WVALID   : out std_logic;
    f2sdram0_WREADY   : in  std_logic;

    f2sdram0_BID      : in  std_logic_vector(AXI_ID_W-1 downto 0);
    f2sdram0_BRESP    : in  std_logic_vector(1 downto 0);
    f2sdram0_BVALID   : in  std_logic;
    f2sdram0_BREADY   : out std_logic;

    f2sdram0_ARID     : out std_logic_vector(AXI_ID_W-1 downto 0);
    f2sdram0_ARADDR   : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    f2sdram0_ARLEN    : out std_logic_vector(7 downto 0);
    f2sdram0_ARSIZE   : out std_logic_vector(2 downto 0);
    f2sdram0_ARBURST  : out std_logic_vector(1 downto 0);
    f2sdram0_ARLOCK   : out std_logic;
    f2sdram0_ARCACHE  : out std_logic_vector(3 downto 0);
    f2sdram0_ARPROT   : out std_logic_vector(2 downto 0);
    f2sdram0_ARQOS    : out std_logic_vector(3 downto 0);
    f2sdram0_ARVALID  : out std_logic;
    f2sdram0_ARREADY  : in  std_logic;

    f2sdram0_RID      : in  std_logic_vector(AXI_ID_W-1 downto 0);
    f2sdram0_RDATA    : in  std_logic_vector(AXI_DW-1 downto 0);
    f2sdram0_RRESP    : in  std_logic_vector(1 downto 0);
    f2sdram0_RLAST    : in  std_logic;
    f2sdram0_RVALID   : in  std_logic;
    f2sdram0_RREADY   : out std_logic
  );
end entity;

architecture rtl of esp_ahb_slave_to_hps_f2sdram_axi is
  -- State
  type ST_T is (IDLE, W_AW, W_W, W_B, R_AR, R_R);
  signal st_r, st_n : ST_T;

  -- AHB outputs (registered)
  signal so_hready_r, so_hready_n : std_logic;
  signal so_hresp_r,  so_hresp_n  : std_logic_vector(1 downto 0);
  signal so_hrdata_r, so_hrdata_n : std_logic_vector(AHB_DW-1 downto 0);

  -- AXI outs (registered)
  signal awvalid_r, awvalid_n : std_logic;
  signal awaddr_r,  awaddr_n  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal awsize_r,  awsize_n  : std_logic_vector(2 downto 0);
  signal awlen_r,   awlen_n   : std_logic_vector(7 downto 0);
  signal awburst_r, awburst_n : std_logic_vector(1 downto 0);

  signal wvalid_r,  wvalid_n  : std_logic;
  signal wdata_r,   wdata_n   : std_logic_vector(AXI_DW-1 downto 0);
  signal wstrb_r,   wstrb_n   : std_logic_vector((AXI_DW/8)-1 downto 0);
  signal wlast_r,   wlast_n   : std_logic;

  signal bready_r,  bready_n  : std_logic;

  signal arvalid_r, arvalid_n : std_logic;
  signal araddr_r,  araddr_n  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal arsize_r,  arsize_n  : std_logic_vector(2 downto 0);
  signal arlen_r,   arlen_n   : std_logic_vector(7 downto 0);
  signal arburst_r, arburst_n : std_logic_vector(1 downto 0);

  signal rready_r,  rready_n  : std_logic;

  -- Latched AHB address/control
  signal haddr_r,  haddr_n  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal hwrite_r, hwrite_n : std_logic;
  signal hsize_r,  hsize_n  : std_logic_vector(2 downto 0);

  -- Helpers
  constant AXI_BYTES : integer := AXI_DW/8;
  constant AHB_BYTES : integer := AHB_DW/8;

  function size_bytes(sz : std_logic_vector(2 downto 0)) return integer is
  begin
    case sz is
      when "000" => return 1;
      when "001" => return 2;
      when "010" => return 4;
      when "011" => return 8; -- only valid if bus supports it
      when others => return 4; -- default to word
    end case;
  end;

  -- Base byte index inside AXI data beat from address
  function base_index(addr : std_logic_vector) return integer is
  begin
    if AXI_DW = 64 then
      return to_integer(unsigned(addr(2 downto 0))); -- 0..7
    else
      return to_integer(unsigned(addr(1 downto 0))); -- 0..3
    end if;
  end;

  -- Build AXI WSTRB from AHB size + address (bit-by-bit, VHDL-93 safe)
  function make_wstrb(sz : std_logic_vector(2 downto 0);
                      addr : std_logic_vector) return std_logic_vector is
    variable m : std_logic_vector(AXI_BYTES-1 downto 0) := (others=>'0');
    variable low  : integer := base_index(addr);
    variable nbyt : integer := size_bytes(sz);
    variable p    : integer;
  begin
    -- VHDL-93: for-loop bounds must be static; iterate full AXI_BYTES
    for i in 0 to AXI_BYTES-1 loop
      if i < nbyt then
        p := low + i;
        if (p >= 0) and (p < AXI_BYTES) then
          m(p) := '1';
        end if;
      end if;
    end loop;
    return m;
  end;

  -- Place AHB write data bytes into AXI beat lanes per address (bit-by-bit)
  function place_wdata(hw : std_logic_vector; addr : std_logic_vector)
    return std_logic_vector is
    variable wd    : std_logic_vector(AXI_DW-1 downto 0) := (others=>'0');
    variable low   : integer := base_index(addr);
    variable bytes : integer := AHB_BYTES;
    variable src_b, dst_b : integer;
    variable bit   : integer;
  begin
    -- VHDL-93: for-loop bounds must be static; iterate full AHB_BYTES
    for k in 0 to AHB_BYTES-1 loop
      if k < bytes then
        dst_b := low + k;
        src_b := k;
        if (dst_b >= 0) and (dst_b < AXI_BYTES) then
          for bit in 0 to 7 loop
            wd(dst_b*8 + bit) := hw(src_b*8 + bit);
          end loop;
        end if;
      end if;
    end loop;
    return wd;
  end;

  -- Extract addressed bytes from AXI read beat and right-justify into AHB data
  function extract_rdata(rd : std_logic_vector;
                         addr : std_logic_vector;
                         sz   : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable hd    : std_logic_vector(AHB_DW-1 downto 0) := (others=>'0');
    variable low   : integer := base_index(addr);
    variable nbyt  : integer := size_bytes(sz);
    variable src_b, dst_b : integer;
    variable bit   : integer;
  begin
    -- VHDL-93: for-loop bounds must be static; iterate full AHB_BYTES
    for i in 0 to AHB_BYTES-1 loop
      if i < nbyt then
        src_b := low + i;
        dst_b := i;
        if (src_b >= 0) and (src_b < AXI_BYTES) and (dst_b < AHB_BYTES) then
          for bit in 0 to 7 loop
            hd(dst_b*8 + bit) := rd(src_b*8 + bit);
          end loop;
        end if;
      end if;
    end loop;
    return hd;
  end;

begin
  -- Port wiring (registered outs)
  so_hready <= so_hready_r;
  so_hresp  <= so_hresp_r;
  so_hrdata <= so_hrdata_r;

  f2sdram0_AWID    <= (others=>'0');
  f2sdram0_AWADDR  <= awaddr_r;
  f2sdram0_AWLEN   <= awlen_r;
  f2sdram0_AWSIZE  <= awsize_r;
  f2sdram0_AWBURST <= awburst_r;
  f2sdram0_AWLOCK  <= '0';
  f2sdram0_AWCACHE <= (others=>'0');
  f2sdram0_AWPROT  <= (others=>'0');
  f2sdram0_AWQOS   <= (others=>'0');
  f2sdram0_AWVALID <= awvalid_r;

  f2sdram0_WDATA   <= wdata_r;
  f2sdram0_WSTRB   <= wstrb_r;
  f2sdram0_WLAST   <= wlast_r;
  f2sdram0_WVALID  <= wvalid_r;

  f2sdram0_BREADY  <= bready_r;

  f2sdram0_ARID    <= (others=>'0');
  f2sdram0_ARADDR  <= araddr_r;
  f2sdram0_ARLEN   <= arlen_r;
  f2sdram0_ARSIZE  <= arsize_r;
  f2sdram0_ARBURST <= arburst_r;
  f2sdram0_ARLOCK  <= '0';
  f2sdram0_ARCACHE <= (others=>'0');
  f2sdram0_ARPROT  <= (others=>'0');
  f2sdram0_ARQOS   <= (others=>'0');
  f2sdram0_ARVALID <= arvalid_r;

  f2sdram0_RREADY  <= rready_r;

  -- Sequential
  process(f2sdram_clk)
  begin
    if rising_edge(f2sdram_clk) then
      if f2sdram_rst_n='0' then
        st_r         <= IDLE;

        so_hready_r  <= '1';
        so_hresp_r   <= "00";
        so_hrdata_r  <= (others=>'0');

        awvalid_r    <= '0';
        awaddr_r     <= (others=>'0');
        awsize_r     <= "010";
        awlen_r      <= (others=>'0');
        awburst_r    <= "01";

        wvalid_r     <= '0';
        wdata_r      <= (others=>'0');
        wstrb_r      <= (others=>'0');
        wlast_r      <= '0';

        bready_r     <= '0';

        arvalid_r    <= '0';
        araddr_r     <= (others=>'0');
        arsize_r     <= "010";
        arlen_r      <= (others=>'0');
        arburst_r    <= "01";

        rready_r     <= '0';

        haddr_r      <= (others=>'0');
        hwrite_r     <= '0';
        hsize_r      <= "010";
      else
        st_r         <= st_n;

        so_hready_r  <= so_hready_n;
        so_hresp_r   <= so_hresp_n;
        so_hrdata_r  <= so_hrdata_n;

        awvalid_r    <= awvalid_n;
        awaddr_r     <= awaddr_n;
        awsize_r     <= awsize_n;
        awlen_r      <= awlen_n;
        awburst_r    <= awburst_n;

        wvalid_r     <= wvalid_n;
        wdata_r      <= wdata_n;
        wstrb_r      <= wstrb_n;
        wlast_r      <= wlast_n;

        bready_r     <= bready_n;

        arvalid_r    <= arvalid_n;
        araddr_r     <= araddr_n;
        arsize_r     <= arsize_n;
        arlen_r      <= arlen_n;
        arburst_r    <= arburst_n;

        rready_r     <= rready_n;

        haddr_r      <= haddr_n;
        hwrite_r     <= hwrite_n;
        hsize_r      <= hsize_n;
      end if;
    end if;
  end process;

  -- Combinational
  process( st_r,
           si_hready, si_hsel, si_htrans, si_haddr, si_hwrite, si_hsize, si_hwdata,
           f2sdram0_AWREADY, f2sdram0_WREADY, f2sdram0_BVALID,
           f2sdram0_ARREADY, f2sdram0_RVALID, f2sdram0_RDATA )
  begin
    -- hold by default
    st_n        <= st_r;

    so_hready_n <= so_hready_r;
    so_hresp_n  <= "00";
    so_hrdata_n <= so_hrdata_r;

    awvalid_n   <= awvalid_r;
    awaddr_n    <= awaddr_r;
    awsize_n    <= awsize_r;
    awlen_n     <= awlen_r;
    awburst_n   <= awburst_r;

    wvalid_n    <= wvalid_r;
    wdata_n     <= wdata_r;
    wstrb_n     <= wstrb_r;
    wlast_n     <= wlast_r;

    bready_n    <= bready_r;

    arvalid_n   <= arvalid_r;
    araddr_n    <= araddr_r;
    arsize_n    <= arsize_r;
    arlen_n     <= arlen_r;
    arburst_n   <= arburst_r;

    rready_n    <= rready_r;

    haddr_n     <= haddr_r;
    hwrite_n    <= hwrite_r;
    hsize_n     <= hsize_r;

    case st_r is
      when IDLE =>
        -- release AHB until a valid NONSEQ/SEQ address arrives
        so_hready_n <= '1';

        -- clear outstanding AXI strobes
        awvalid_n <= '0';
        wvalid_n  <= '0';
        wlast_n   <= '0';
        bready_n  <= '0';
        arvalid_n <= '0';
        rready_n  <= '0';

        if (si_hsel='1' and si_hready='1' and si_htrans(1)='1') then
          -- latch AHB address/control
          haddr_n  <= si_haddr;
          hwrite_n <= si_hwrite;
          hsize_n  <= si_hsize;

          -- Stall AHB until AXI completes this single-beat
          so_hready_n <= '0';

          if si_hwrite='1' then
            -- WRITE: drive AW then W
            awaddr_n  <= si_haddr;
            awsize_n  <= si_hsize;
            awlen_n   <= (others=>'0'); -- single beat
            awburst_n <= "01";          -- INCR
            awvalid_n <= '1';

            -- prepare W
            wdata_n   <= place_wdata(si_hwdata, si_haddr);
            wstrb_n   <= make_wstrb(si_hsize, si_haddr);
            wlast_n   <= '0';
            wvalid_n  <= '0';
            bready_n  <= '0';

            st_n      <= W_AW;

          else
            -- READ: drive AR then wait for R
            araddr_n  <= si_haddr;
            arsize_n  <= si_hsize;
            arlen_n   <= (others=>'0'); -- single beat
            arburst_n <= "01";
            arvalid_n <= '1';
            rready_n  <= '0';
            st_n      <= R_AR;
          end if;
        end if;

      when W_AW =>
        -- wait for AW handshake, then push W
        if (awvalid_r='1' and f2sdram0_AWREADY='1') then
          awvalid_n <= '0';
          wvalid_n  <= '1';
          wlast_n   <= '1';
          st_n      <= W_W;
        end if;

      when W_W =>
        if (wvalid_r='1' and f2sdram0_WREADY='1') then
          wvalid_n  <= '0';
          wlast_n   <= '0';
          bready_n  <= '1';
          st_n      <= W_B;
        end if;

      when W_B =>
        if (f2sdram0_BVALID='1') then
          bready_n    <= '0';
          so_hready_n <= '1';      -- complete AHB cycle
          st_n        <= IDLE;
        end if;

      when R_AR =>
        if (arvalid_r='1' and f2sdram0_ARREADY='1') then
          arvalid_n <= '0';
          rready_n  <= '1';
          st_n      <= R_R;
        end if;

      when R_R =>
        if (f2sdram0_RVALID='1') then
          so_hrdata_n <= extract_rdata(f2sdram0_RDATA, haddr_r, hsize_r);
          rready_n    <= '0';
          so_hready_n <= '1';      -- complete AHB cycle
          st_n        <= IDLE;
        end if;
    end case;
  end process;

end architecture;
