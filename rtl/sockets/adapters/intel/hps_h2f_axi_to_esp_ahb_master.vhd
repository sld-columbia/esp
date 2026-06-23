
-- hps_h2f_axi_to_esp_ahb_master.vhd
-- AXI4 (single-beat) slave -> ESP/GRLIB AHB-Lite master bridge
--
-- What this version fixes:
--   * "Zeros moved around" was caused by toggling HTRANS while HREADY=0 (AHB violation).
--   * "Entries missing / shifted" is caused by assuming AW always handshakes BEFORE W.
--     AXI EDCL can present AW and W in the same cycle (or W one cycle earlier),
--     and the previous bridge only asserted AWREADY in IDLE and only asserted WREADY
--     in a later state. That lets an AW handshake happen without the matching W beat,
--     so the next W beat gets paired with the wrong address -> duplicated data + missing words.
--
-- This bridge therefore:
--   1) Adds 1-deep buffering for AW and W so they can arrive in any order, including same cycle.
--   2) Uses AHB HTRANS=NONSEQ for the address phase and HTRANS=IDLE after that
--      single accepted address phase, so ESP's AHB-to-NoC proxy does not sample
--      a phantom follow-up transfer while the write data phase completes.
--      HTRANS is never changed while the address phase is stalled.
--
-- Notes / limitations:
--   * single outstanding transaction (no AXI pipelining beyond 1-deep AW/W buffering)
--   * AWLEN/ARLEN ignored (expects single-beat; EDCL test traffic is single-beat)
--   * WSTRB ignored (AHB has no strobes here; assumes full-word writes)
--   * BRESP/RRESP always OKAY
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hps_h2f_axi_to_esp_ahb_master is
  generic (
    ADDR_WIDTH : integer := 32;
    AHB_DW     : integer := 32;
    AXI_DW     : integer := 32;
    AXI_ID_W   : integer := 4
  );
  port (
    h2f_axi_clk   : in  std_logic;
    h2f_axi_rst_n : in  std_logic;

    -- AXI write address
    h2f_AWID      : in  std_logic_vector(AXI_ID_W-1 downto 0);
    h2f_AWADDR    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    h2f_AWLEN     : in  std_logic_vector(7 downto 0);
    h2f_AWSIZE    : in  std_logic_vector(2 downto 0);
    h2f_AWBURST   : in  std_logic_vector(1 downto 0);
    h2f_AWLOCK    : in  std_logic;
    h2f_AWCACHE   : in  std_logic_vector(3 downto 0);
    h2f_AWPROT    : in  std_logic_vector(2 downto 0);
    h2f_AWVALID   : in  std_logic;
    h2f_AWREADY   : out std_logic;

    -- AXI write data
    h2f_WDATA     : in  std_logic_vector(AXI_DW-1 downto 0);
    h2f_WSTRB     : in  std_logic_vector((AXI_DW/8)-1 downto 0);
    h2f_WLAST     : in  std_logic;
    h2f_WVALID    : in  std_logic;
    h2f_WREADY    : out std_logic;

    -- AXI write response
    h2f_BID       : out std_logic_vector(AXI_ID_W-1 downto 0);
    h2f_BRESP     : out std_logic_vector(1 downto 0);
    h2f_BVALID    : out std_logic;
    h2f_BREADY    : in  std_logic;

    -- AXI read address
    h2f_ARID      : in  std_logic_vector(AXI_ID_W-1 downto 0);
    h2f_ARADDR    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    h2f_ARLEN     : in  std_logic_vector(7 downto 0);
    h2f_ARSIZE    : in  std_logic_vector(2 downto 0);
    h2f_ARBURST   : in  std_logic_vector(1 downto 0);
    h2f_ARLOCK    : in  std_logic;
    h2f_ARCACHE   : in  std_logic_vector(3 downto 0);
    h2f_ARPROT    : in  std_logic_vector(2 downto 0);
    h2f_ARVALID   : in  std_logic;
    h2f_ARREADY   : out std_logic;

    -- AXI read data
    h2f_RID       : out std_logic_vector(AXI_ID_W-1 downto 0);
    h2f_RDATA     : out std_logic_vector(AXI_DW-1 downto 0);
    h2f_RRESP     : out std_logic_vector(1 downto 0);
    h2f_RLAST     : out std_logic;
    h2f_RVALID    : out std_logic;
    h2f_RREADY    : in  std_logic;

    -- AHB-Lite master out
    mo_haddr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    mo_hwrite     : out std_logic;
    mo_hsize      : out std_logic_vector(2 downto 0);
    mo_hburst     : out std_logic_vector(2 downto 0);
    mo_htrans     : out std_logic_vector(1 downto 0);
    mo_hwdata     : out std_logic_vector(AHB_DW-1 downto 0);
    mo_hprot      : out std_logic_vector(3 downto 0);
    mo_hlock      : out std_logic;

    -- AHB-Lite master in
    mi_hrdata     : in  std_logic_vector(AHB_DW-1 downto 0);
    mi_hready     : in  std_logic;
    mi_hresp      : in  std_logic_vector(1 downto 0);
    mi_hgrant     : in  std_logic
  );
end entity;

architecture rtl of hps_h2f_axi_to_esp_ahb_master is

  type state_t is (
    IDLE,

    -- write path
    W_AHB_ADDR,
    W_AHB_DATA,
    W_RESP,

    -- read path
    R_AHB_ADDR,
    R_AHB_DATA,
    R_RESP
  );

  constant HTRANS_IDLE   : std_logic_vector(1 downto 0) := "00";
  constant HTRANS_NONSEQ : std_logic_vector(1 downto 0) := "10";

  signal state_r : state_t;

  -- 1-deep buffers for write address/data so AW/W can arrive in any order
  signal have_aw  : std_logic;
  signal have_w   : std_logic;

  signal awid_r   : std_logic_vector(AXI_ID_W-1 downto 0);
  signal awaddr_r : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal awsize_r : std_logic_vector(2 downto 0);

  signal wdata_r  : std_logic_vector(AHB_DW-1 downto 0);

  -- read address buffer
  signal arid_r   : std_logic_vector(AXI_ID_W-1 downto 0);
  signal araddr_r : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal arsize_r : std_logic_vector(2 downto 0);

  -- AXI outputs regs
  signal awready_r : std_logic;
  signal wready_r  : std_logic;
  signal arready_r : std_logic;

  signal bid_r    : std_logic_vector(AXI_ID_W-1 downto 0);
  signal bresp_r  : std_logic_vector(1 downto 0);
  signal bvalid_r : std_logic;

  signal rid_r    : std_logic_vector(AXI_ID_W-1 downto 0);
  signal rdata_r  : std_logic_vector(AXI_DW-1 downto 0);
  signal rresp_r  : std_logic_vector(1 downto 0);
  signal rlast_r  : std_logic;
  signal rvalid_r : std_logic;

  -- AHB regs
  signal haddr_r  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal hwrite_r : std_logic;
  signal hsize_r  : std_logic_vector(2 downto 0);
  signal hburst_r : std_logic_vector(2 downto 0);
  signal htrans_r : std_logic_vector(1 downto 0);
  signal hwdata_r : std_logic_vector(AHB_DW-1 downto 0);

begin

  -- AXI outputs
  h2f_AWREADY <= awready_r;
  h2f_WREADY  <= wready_r;
  h2f_BID     <= bid_r;
  h2f_BRESP   <= bresp_r;
  h2f_BVALID  <= bvalid_r;

  h2f_ARREADY <= arready_r;
  h2f_RID     <= rid_r;
  h2f_RDATA   <= rdata_r;
  h2f_RRESP   <= rresp_r;
  h2f_RLAST   <= rlast_r;
  h2f_RVALID  <= rvalid_r;

  -- AHB outputs
  mo_haddr   <= haddr_r;
  mo_hwrite  <= hwrite_r;
  mo_hsize   <= hsize_r;
  mo_hburst  <= hburst_r;
  mo_htrans  <= htrans_r;
  mo_hwdata  <= hwdata_r;
  mo_hprot   <= "0011";
  mo_hlock   <= '0';

  process (h2f_axi_clk, h2f_axi_rst_n)
    variable do_aw_hs : boolean;
    variable do_w_hs  : boolean;
    variable do_ar_hs : boolean;
  begin
    if h2f_axi_rst_n = '0' then
      state_r <= IDLE;

      have_aw <= '0';
      have_w  <= '0';

      awid_r   <= (others => '0');
      awaddr_r <= (others => '0');
      awsize_r <= "010";
      wdata_r  <= (others => '0');

      arid_r   <= (others => '0');
      araddr_r <= (others => '0');
      arsize_r <= "010";

      awready_r <= '0';
      wready_r  <= '0';
      arready_r <= '0';

      bid_r    <= (others => '0');
      bresp_r  <= (others => '0');
      bvalid_r <= '0';

      rid_r    <= (others => '0');
      rdata_r  <= (others => '0');
      rresp_r  <= (others => '0');
      rlast_r  <= '0';
      rvalid_r <= '0';

      haddr_r  <= (others => '0');
      hwrite_r <= '0';
      hsize_r  <= "010";
      hburst_r <= "000";
      htrans_r <= HTRANS_IDLE;
      hwdata_r <= (others => '0');

    elsif rising_edge(h2f_axi_clk) then
      -- default: drive ready depending on state + buffer fullness (level, not pulses)
      -- We only accept new commands in IDLE (single outstanding), but we accept AW/W
      -- in any order while IDLE until both are captured.
      awready_r <= '0';
      wready_r  <= '0';
      arready_r <= '0';

      do_aw_hs := false;
      do_w_hs  := false;
      do_ar_hs := false;

      if state_r = IDLE then
        -- prefer completing a write if we're already collecting AW/W
        -- otherwise allow read address if no write activity visible
        awready_r <= (not have_aw);
        wready_r  <= (not have_w);

        -- only allow AR when no pending write pieces and no write valids this cycle
        if (have_aw = '0') and (have_w = '0') and (h2f_AWVALID = '0') and (h2f_WVALID = '0') then
          arready_r <= '1';
        else
          arready_r <= '0';
        end if;

        do_aw_hs := (h2f_AWVALID = '1') and (awready_r = '1');
        do_w_hs  := (h2f_WVALID  = '1') and (wready_r  = '1');
        do_ar_hs := (h2f_ARVALID = '1') and (arready_r = '1');

        if do_aw_hs then
          awid_r   <= h2f_AWID;
          awaddr_r <= h2f_AWADDR;
          awsize_r <= h2f_AWSIZE;
          have_aw  <= '1';
        end if;

        if do_w_hs then
          wdata_r <= std_logic_vector(resize(unsigned(h2f_WDATA), AHB_DW));
          have_w  <= '1';
        end if;

        if do_ar_hs then
          arid_r   <= h2f_ARID;
          araddr_r <= h2f_ARADDR;
          arsize_r <= h2f_ARSIZE;

          -- launch AHB read address phase
          haddr_r  <= h2f_ARADDR;
          hwrite_r <= '0';
          hsize_r  <= h2f_ARSIZE;
          hburst_r <= "000";
          htrans_r <= HTRANS_NONSEQ;

          state_r  <= R_AHB_ADDR;
        elsif (have_aw = '1' and have_w = '1') or ((have_aw = '1' and do_w_hs) or (have_w = '1' and do_aw_hs)) then
          -- If the missing half of the AXI write arrives in this cycle, launch
          -- the AHB transfer with the just-captured value rather than the stale
          -- buffered value from the previous transaction.
          if have_aw = '1' then
            haddr_r <= awaddr_r;
            hsize_r <= awsize_r;
          else
            haddr_r <= h2f_AWADDR;
            hsize_r <= h2f_AWSIZE;
          end if;

          hwrite_r <= '1';
          hburst_r <= "000";
          htrans_r <= HTRANS_NONSEQ;

          if have_w = '1' then
            hwdata_r <= wdata_r;
          else
            hwdata_r <= std_logic_vector(resize(unsigned(h2f_WDATA), AHB_DW));
          end if;

          state_r  <= W_AHB_ADDR;
        else
          -- stay idle; no change
          htrans_r <= HTRANS_IDLE;
          -- keep bvalid/rvalid low in IDLE
          if bvalid_r = '1' and h2f_BREADY = '1' then
            bvalid_r <= '0';
          end if;
          if rvalid_r = '1' and h2f_RREADY = '1' then
            rvalid_r <= '0';
            rlast_r  <= '0';
          end if;
        end if;

      else
        -- not IDLE: deassert ready (single outstanding)
        awready_r <= '0';
        wready_r  <= '0';
        arready_r <= '0';
      end if;

      case state_r is

        when IDLE =>
          -- responses are held until accepted
          if (bvalid_r = '1') and (h2f_BREADY = '1') then
            bvalid_r <= '0';
          end if;
          if (rvalid_r = '1') and (h2f_RREADY = '1') then
            rvalid_r <= '0';
            rlast_r  <= '0';
          end if;

        -- --------------------------
        -- WRITE: AHB address phase
        -- --------------------------
        when W_AHB_ADDR =>
          -- Keep address/control stable while HREADY=0 (do not change HTRANS in stalls)
          -- The HPS bridge shares the AHB with the CPU once Ariane is running.
          -- Only treat the address phase as accepted when this master is
          -- actually granted the bus; otherwise we can incorrectly complete on
          -- another master's cycle and replay stale read data forever.
          if mi_hgrant = '1' and mi_hready = '1' then
            -- move to data phase; present IDLE to indicate "no next transfer"
            htrans_r <= HTRANS_IDLE;
            state_r  <= W_AHB_DATA;
          end if;

        -- --------------------------
        -- WRITE: AHB data phase
        -- --------------------------
        when W_AHB_DATA =>
          -- Hold IDLE constant through any wait states; do NOT start a new transfer
          if mi_hready = '1' then
            -- write completed
            htrans_r <= HTRANS_IDLE;

            bid_r    <= awid_r;
            bresp_r  <= "00";
            bvalid_r <= '1';

            -- clear buffered write pieces for next transaction
            have_aw  <= '0';
            have_w   <= '0';

            state_r  <= W_RESP;
          end if;

        when W_RESP =>
          if (bvalid_r = '1') and (h2f_BREADY = '1') then
            bvalid_r <= '0';
            state_r  <= IDLE;
          end if;

        -- --------------------------
        -- READ: AHB address phase
        -- --------------------------
        when R_AHB_ADDR =>
          if mi_hgrant = '1' and mi_hready = '1' then
            htrans_r <= HTRANS_IDLE; -- no next transfer during read data phase
            state_r  <= R_AHB_DATA;
          end if;

        -- --------------------------
        -- READ: AHB data phase
        -- --------------------------
        when R_AHB_DATA =>
          -- keep IDLE stable during stalls; capture when completes
          if mi_hready = '1' then
            htrans_r <= HTRANS_IDLE;

            rid_r    <= arid_r;
            rdata_r  <= std_logic_vector(resize(unsigned(mi_hrdata), AXI_DW));
            rresp_r  <= "00";
            rlast_r  <= '1';
            rvalid_r <= '1';

            state_r  <= R_RESP;
          end if;

        when R_RESP =>
          if (rvalid_r = '1') and (h2f_RREADY = '1') then
            rvalid_r <= '0';
            rlast_r  <= '0';
            state_r  <= IDLE;
          end if;

        when others =>
          state_r <= IDLE;

      end case;

    end if;
  end process;

end architecture rtl;
