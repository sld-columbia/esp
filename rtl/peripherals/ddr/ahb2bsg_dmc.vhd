-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- AHB interface for the Basejump DDR controller.
--
-- Note: the current implementation of bsg_dmc can only handle a fixed burst
-- size, hence we must set the parameter ui_burst_length_p it to 1, because we
-- cannot guarantee that all transactions on the AHB bus will be a burst with
-- fixed length.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.ahb2mig_7series_pkg.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.config_types.all;
use work.config.all;
library std;
use std.textio.all;

entity ahb2bsg_dmc is
  port(
    hindex : in integer;
    haddr : in integer range 0 to 4095;
    hmask : in integer range 0 to 4095;
    lpddr_ck_p : out std_logic;
    lpddr_ck_n : out std_logic;
    lpddr_cke : out std_logic;
    lpddr_ba : out std_logic_vector(2 downto 0);
    lpddr_addr : out std_logic_vector(15 downto 0);
    lpddr_cs_n : out std_logic;
    lpddr_ras_n : out std_logic;
    lpddr_cas_n : out std_logic;
    lpddr_we_n : out std_logic;
    lpddr_reset_n : out std_logic;
    lpddr_odt : out std_logic;
    lpddr_dm_oen : out std_logic_vector(3 downto 0);
    lpddr_dm : out std_logic_vector(3 downto 0);
    lpddr_dqs_p_oen : out std_logic_vector(3 downto 0);
    lpddr_dqs_p_ien : out std_logic_vector(3 downto 0);
    lpddr_dqs_p_o : out std_logic_vector(3 downto 0);
    lpddr_dqs_p_i : in std_logic_vector(3 downto 0);
    lpddr_dqs_n_oen : out std_logic_vector(3 downto 0);
    lpddr_dqs_n_ien : out std_logic_vector(3 downto 0);
    lpddr_dqs_n_o : out std_logic_vector(3 downto 0);
    lpddr_dqs_n_i : in std_logic_vector(3 downto 0);
    lpddr_dq_oen : out std_logic_vector(31 downto 0);
    lpddr_dq_o : out std_logic_vector(31 downto 0);
    lpddr_dq_i : in std_logic_vector(31 downto 0);
    ddr_cfg0 : in std_logic_vector(31 downto 0);
    ddr_cfg1 : in std_logic_vector(31 downto 0);
    ddr_cfg2 : in std_logic_vector(31 downto 0);
    ahbso : out ahb_slv_out_type;
    ahbsi : in ahb_slv_in_type;
    calib_done : out std_logic;
    ui_clk : in std_logic;
    ui_rstn : in std_logic;
    phy_clk_1x : in std_logic;
    phy_clk_2x : in std_logic;
    phy_rstn : in std_logic
    );
end;

architecture rtl of ahb2bsg_dmc is

  component bsg_dmc_wrap is
    generic (
      ui_addr_width_p : integer := 28;
      ui_data_width_p : integer := 64;
      ui_burst_length_p : integer := 8;
      dq_data_width_p : integer := 32;
      cmd_afifo_depth_p : integer := 4;
      cmd_sfifo_depth_p : integer := 4
      );
    port (
      -- User interface input signals
      app_addr : in std_logic_vector(ui_addr_width_p - 1 downto 0);
      app_cmd : in std_logic_vector(2 downto 0);
      app_en : in std_logic;
      app_wdf_data : in std_logic_vector(ui_data_width_p - 1 downto 0);
      app_wdf_end : in std_logic;
      app_wdf_mask : in std_logic_vector((ui_data_width_p / 8) - 1 downto 0);
      app_wdf_wren : in std_logic;
      -- User interface output signals
      app_rd_data : out std_logic_vector(ui_data_width_p - 1 downto 0);
      app_rd_data_end : out std_logic;
      app_rd_data_valid : out std_logic;
      app_rdy : out std_logic;
      app_wdf_rdy : out std_logic;
      -- Status signal
      init_calib_complete : out std_logic;
      -- Tile clock == DDR clock (200 MHz rotated 90 degrees) and tile synchronous reset
      ui_clk_i : in std_logic;
      ui_reset_i : in std_logic;
      -- PHY 2x clock (400 MHz) and 1x clock (200 MHz) with synchronous reset
      dfi_clk_2x_i : in std_logic;
      dfi_clk_1x_i : in std_logic;
      dfi_reset_i : in std_logic;
      -- Command and Address interface
      ddr_ck_p_o : out std_logic;
      ddr_ck_n_o : out std_logic;
      ddr_cke_o : out std_logic;
      ddr_ba_o : out std_logic_vector(2 downto 0);
      ddr_addr_o : out std_logic_vector(15 downto 0);
      ddr_cs_n_o : out std_logic;
      ddr_ras_n_o : out std_logic;
      ddr_cas_n_o : out std_logic;
      ddr_we_n_o : out std_logic;
      ddr_reset_n_o : out std_logic;
      ddr_odt_o : out std_logic;
      -- Data interface
      ddr_dm_oen_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dm_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_p_oen_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_p_ien_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_p_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_p_i : in std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_n_oen_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_n_ien_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_n_o : out std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dqs_n_i : in std_logic_vector((dq_data_width_p / 8) - 1 downto 0);
      ddr_dq_oen_o : out std_logic_vector(dq_data_width_p - 1 downto 0);
      ddr_dq_o : out std_logic_vector(dq_data_width_p - 1 downto 0);
      ddr_dq_i : in std_logic_vector(dq_data_width_p - 1 downto 0);
      -- Delay line configuration
      delay_sel_i : in std_logic_vector(3 downto 0);
      -- DDR controller configuration
      trefi_i : in std_logic_vector(12 downto 0);
      tmrd_i : in std_logic_vector(3 downto 0);
      trfc_i : in std_logic_vector(3 downto 0);
      trc_i : in std_logic_vector(3 downto 0);
      trp_i : in std_logic_vector(3 downto 0);
      tras_i : in std_logic_vector(3 downto 0);
      trrd_i : in std_logic_vector(3 downto 0);
      trcd_i : in std_logic_vector(3 downto 0);
      twr_i : in std_logic_vector(3 downto 0);
      twtr_i : in std_logic_vector(3 downto 0);
      trtp_i : in std_logic_vector(3 downto 0);
      tcas_i : in std_logic_vector(3 downto 0);
      col_width_i : in std_logic_vector(3 downto 0);
      row_width_i : in std_logic_vector(3 downto 0);
      bank_width_i : in std_logic_vector(1 downto 0);
      bank_pos_i : in std_logic_vector(5 downto 0);
      dqs_sel_cal_i : in std_logic_vector(2 downto 0);
      init_cycles_i : in std_logic_vector(15 downto 0)
      );
  end component bsg_dmc_wrap;

  -- Calibration complete flag synchronizer
  signal init_calib_complete : std_logic_vector(0 to 7);
  signal calib_done_delayed : std_ulogic;
  signal calib_done_count : std_logic_vector(4 downto 0);

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of init_calib_complete: signal is "TRUE";

  signal trefi_ext : std_logic_vector(12 downto 0);

  signal ui_rst : std_logic;
  signal phy_rst : std_logic;

  signal ddr_dqs_p_ien : std_logic_vector(3 downto 0);
  signal ddr_dqs_p_i : std_logic_vector(3 downto 0);
  signal ddr_dqs_n_ien : std_logic_vector(3 downto 0);
  signal ddr_dqs_n_i : std_logic_vector(3 downto 0);

  signal hconfig : ahb_config_type;

  type reg_type is record
    -- MIG inputs
    addr : std_logic_vector(27 downto 0);
    cmd : std_logic_vector(2 downto 0);
    en : std_logic;
    wdf_wren : std_logic;
    wdf_end : std_logic;
    wdf_data : std_Logic_vector(64 - 1 downto 0);
    wdf_mask : std_logic_vector(AHBDW/8 - 1 downto 0);
    -- AHB slv
    valid : std_logic;
    hwrite : std_logic;
    hready : std_logic;
    hrdata : std_logic_vector(AHBDW - 1 downto 0);
    haddr_offset : std_logic_vector(2 downto 0);
    hsize : std_logic_vector(2 downto 0);
  end record;

  constant REG_RESET : reg_type := (
    addr => (others => '0'),
    cmd => (others => '0'),
    en => '0',
    wdf_wren => '0',
    wdf_end => '0',
    wdf_data => (others => '0'),
    wdf_mask => (others => '0'),
    valid => '0',
    hwrite => '0',
    hready => '1',
    hrdata => (others => '0'),
    haddr_offset => (others => '0'),
    hsize => HSIZE_DWORD
    );

  type mig_in_type is record
    app_addr : std_logic_vector(27 downto 0);
    app_cmd : std_logic_vector(2 downto 0);
    app_en : std_logic;
    app_hi_pri : std_logic;
    app_wdf_data : std_logic_vector(64 - 1 downto 0);
    app_wdf_end : std_logic;
    app_wdf_mask : std_logic_vector(8 - 1 downto 0);
    app_wdf_wren : std_logic;
  end record;

  type mig_out_type is record
    app_rd_data : std_logic_vector(64 - 1 downto 0);
    app_rd_data_end : std_logic;
    app_rd_data_valid : std_logic;
    app_rdy : std_logic;
    app_wdf_rdy : std_logic;
  end record;

  type ahb_mig_state_type is (idle, read_wait);

  signal current_state, next_state : ahb_mig_state_type;
  signal rin, r, rnxt, rnxtin, rprev, rprevin : reg_type;
  signal migin : mig_in_type;
  signal migout : mig_out_type;

  function select_rd_data (
    signal data   : std_logic_vector(63 downto 0);
    signal offset : std_logic_vector(2 downto 0);
    signal hsize  : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable hrdata : std_logic_vector(AHBDW - 1 downto 0);
  begin
    hrdata := (others => '0');
    case hsize is
      when HSIZE_BYTE =>
        case offset is
          when "111" => hrdata := ahbdrivedata(data(7 downto 0));
          when "110" => hrdata := ahbdrivedata(data(15 downto 8));
          when "101" => hrdata := ahbdrivedata(data(23 downto 16));
          when "100" => hrdata := ahbdrivedata(data(31 downto 24));
          when "011" => hrdata := ahbdrivedata(data(39 downto 32));
          when "010" => hrdata := ahbdrivedata(data(47 downto 40));
          when "001" => hrdata := ahbdrivedata(data(55 downto 48));
          when "000" => hrdata := ahbdrivedata(data(63 downto 56));
          when others => hrdata := ahbdrivedata(data(7 downto 0));
        end case;
      when HSIZE_HWORD =>
        case offset(2 downto 1) is
          when "11" => hrdata := ahbdrivedata(data(15 downto 0));
          when "10" => hrdata := ahbdrivedata(data(31 downto 16));
          when "01" => hrdata := ahbdrivedata(data(47 downto 32));
          when "00" => hrdata := ahbdrivedata(data(63 downto 48));
          when others => hrdata := ahbdrivedata(data(15 downto 0));
        end case;
      when HSIZE_WORD =>
        case offset(2) is
          when '1' => hrdata := ahbdrivedata(data(31 downto 0));
          when '0' => hrdata := ahbdrivedata(data(63 downto 32));
          when others => hrdata := ahbdrivedata(data(32 downto 0));
        end case;
      when others => hrdata := ahbdrivedata(data);
    end case;
    return hrdata;
  end function;

  function set_wdf_data (
    signal hwdata : in std_logic_vector(AHBDW - 1 downto 0))
    return std_logic_vector is
    variable data : std_logic_vector(63 downto 0);
  begin
    if AHBDW = 32 then
      data(31 downto 0)  := hwdata(31 downto 0);
      data(63 downto 32) := data(31 downto 0);
    else
      data := hwdata;
    end if;
    return data;
  end function;

  function set_wdf_mask (
    signal offset : std_logic_vector(2 downto 0);
    signal hsize : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable mask : std_logic_vector(8 - 1 downto 0);
  begin
    mask := "00000000";
    case hsize is
      when HSIZE_BYTE =>
        case offset is
          when "111" => mask := "11111110";
          when "110" => mask := "11111101";
          when "101" => mask := "11111011";
          when "100" => mask := "11110111";
          when "011" => mask := "11101111";
          when "010" => mask := "11011111";
          when "001" => mask := "10111111";
          when "000" => mask := "01111111";
          when others => mask := "00000000";
        end case;
      when HSIZE_HWORD =>
        case offset(2 downto 1) is
          when "11" => mask := "11111100";
          when "10" => mask := "11110011";
          when "01" => mask := "11001111";
          when "00" => mask := "00111111";
          when others => mask := "00000000";
        end case;
      when HSIZE_WORD =>
        case offset(2) is
          when '1' => mask := "11110000";
          when '0' => mask := "00001111";
          when others => mask := "00000000";
        end case;
      when others => mask := "00000000";
    end case;
    return mask;
  end;

begin

  -- Resuing GAISLER_MIG_7SERIES as device ID.
  -- This ID is irrelevant from the perspective of functionality, because the
  -- adapter is transparent to software. However, the AHB bus controller from
  -- GRLIB requires a valid hconfig for every device.
  hconfig <= (
    0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_MIG_7SERIES, 0, 0, 0),
    4 => ahb_membar(haddr, '1', '1', hmask),
    others => zero32);

  comb : process(current_state, r, rnxt, rprev, ahbsi, migin, migout, hindex, calib_done_delayed)
    variable vprev : reg_type;
    variable vnxt : reg_type;
    variable v : reg_type;
    variable vready : std_logic_vector(1 downto 0);
    variable commit : std_logic;
  begin

    -- Default
    v          := r;
    vnxt       := rnxt;
    vprev      := rprev;
    next_state <= current_state;

    -- Wait 4K cycles after calibration is complete before serving any request
    if calib_done_delayed = '1' then

      -- We need three registers because we want to break the combinational path
      -- between MIG ready/valid flags and the AHB bus. This improves timing closure.
      --
      -- Write transaction:
      --
      -- hready  | MIG ready  | v                  | vnxt        | vprev
      --   1     |    1       | A(rnxt), D(ahbsi)  | A(ahbsi),/  | A(rnxt), D(ahbsi)
      --   0     |    1       | A(rprev), D(rprev) | A(rnxt),/   | A(rnxt), D(ahbsi)
      --   1     |    0       | A(r), D(r)         | A(ahbsi),/  | A(rnxt), D(ahbsi)
      --   0     |    0       | A(r), D(r)         | A(rnxt),/   | A(rprev), D(rprev)

      vready := ahbsi.hready & (migout.app_wdf_rdy and migout.app_rdy);

      -- Set vnxt --
      if ahbsi.hready = '0' then
        -- Save previous transaction
        vnxt := rnxt;
      elsif (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '1' then
        vnxt := rnxt;
        -- Mark as valid new transfer
        vnxt.valid := '1';
        vnxt.hwrite := ahbsi.hwrite;
        vnxt.cmd := "00" & not ahbsi.hwrite;
        -- Update address (Addressing 64-bit words)
        vnxt.addr         := ahbsi.haddr(29 downto 3) & "0";
        vnxt.haddr_offset := ahbsi.haddr(2 downto 0);
        vnxt.hsize        := ahbsi.hsize;
        vnxt.wdf_mask     := set_wdf_mask(ahbsi.haddr(2 downto 0), ahbsi.hsize);
      else
        vnxt := rnxt;
        -- Mark as BUSY, IDLE, or no transfer to MIG
        vnxt.valid := '0';
      end if;

      -- Set vprev --
      if vready /= "00" then
        vprev := rprev;
        -- Update address and data
        vprev.addr         := rnxt.addr;
        vprev.haddr_offset := rnxt.haddr_offset;
        vprev.hsize        := rnxt.hsize;
        vprev.wdf_mask     := rnxt.wdf_mask;
        vprev.wdf_data     := set_wdf_data(ahbsi.hwdata);
        vprev.hwrite       := rnxt.hwrite;
        vprev.cmd          := rnxt.cmd;
        -- Check if it was valid
        vprev.valid        := rnxt.valid;
      else
        vprev := rprev;
      end if;

      -- Set v --
      v := r;
      case vready is
        when "11" =>
          -- Data is read combinationally from AHB bus.
          -- Zero additional latency when bus and MIG are both ready.
          v.addr         := rnxt.addr;
          v.haddr_offset := rnxt.haddr_offset;
          v.hsize        := rnxt.hsize;
          v.wdf_mask     := rnxt.wdf_mask;
          v.wdf_data     := set_wdf_data(ahbsi.hwdata);
          v.hwrite       := rnxt.hwrite;
          v.cmd          := rnxt.cmd;
          v.valid        := rnxt.valid;

        when "01" =>
          v.addr         := rprev.addr;
          v.haddr_offset := rprev.haddr_offset;
          v.hsize        := rprev.hsize;
          v.wdf_mask     := rprev.wdf_mask;
          v.wdf_data     := rprev.wdf_data;
          v.hwrite       := rprev.hwrite;
          v.cmd          := rprev.cmd;
          v.valid        := rprev.valid;

        when others =>
          v := r;
      end case;

      if migin.app_en = '1' and migin.app_wdf_wren = '0' and migout.app_rdy = '1' and migout.app_wdf_rdy = '1' then
        v.valid := '0';
      end if;

      if ahbsi.hready = '1' and ahbsi.htrans = "11" then
         if ahbsi.hwrite = '0' then
            v.addr         := vnxt.addr;
            v.haddr_offset := vnxt.haddr_offset;
            v.hsize        := vnxt.hsize;
            v.wdf_mask     := vnxt.wdf_mask;
            v.wdf_data     := set_wdf_data(ahbsi.hwdata);
            v.hwrite       := vnxt.hwrite;
            v.cmd          := vnxt.cmd;
         elsif migin.app_en = '1' and migout.app_rdy = '1' and migout.app_wdf_rdy = '1' then
            v.addr         := rnxt.addr;
            v.haddr_offset := rnxt.haddr_offset;
            v.hsize        := rnxt.hsize;
            v.wdf_mask     := rnxt.wdf_mask;
            v.wdf_data     := set_wdf_data(ahbsi.hwdata);
            v.hwrite       := rnxt.hwrite;
            v.cmd          := rnxt.cmd;
            v.valid        := rnxt.valid;
        end if;
      end if;

      -- Special handling for reads --
      case current_state is
        when idle =>
          if (ahbsi.hready and ahbsi.hsel(hindex) and ahbsi.htrans(1) and (not ahbsi.hwrite)) = '1' then
            -- accepting read command from bus -> hold data transfer until MIG reply
            v.hready := '0';
            next_state <= read_wait;
          else
            -- propagate backpressure from MIG to bus
            v.hready := migout.app_rdy and migout.app_wdf_rdy;
          end if;

        when read_wait =>
          if migout.app_rd_data_valid = '1' then
            v.hrdata := select_rd_data(migout.app_rd_data, rnxt.haddr_offset, rnxt.hsize);
            v.hready := '1';
            next_state <= idle;
          else
            v.hready := '0';
          end if;

        when others =>
          next_state <= idle;
          v.hready := '0';

      end case;

      -- Do not send commands to MIG unless valid and ready
      v.en := v.valid;
      v.wdf_wren := v.valid and v.hwrite;
      v.wdf_end := v.valid and v.hwrite;

    else
      v.hready := '0';
    end if; -- calib_done_delayed = '1'

    -- Set registers input
    rin <= v;
    rnxtin <= vnxt;
    rprevin <= vprev;

  end process;

  ahbso.hready <= r.hready;
  ahbso.hresp <= "00";
  ahbso.hrdata <= r.hrdata;

  migin.app_addr <= r.addr;
  migin.app_cmd <= r.cmd;
  -- synchronize wdf write enable and command enable to ease AHB pipeline handling
  migin.app_en <= r.en when r.wdf_wren = '0' else r.en and migout.app_wdf_rdy;
  migin.app_hi_pri <= '0';

  migin.app_wdf_data <= r.wdf_data;
  migin.app_wdf_end <= r.wdf_end;
  migin.app_wdf_mask(AHBDW/8 - 1 downto 0) <= r.wdf_mask;
  broken_32bit_bus_gen : if (AHBDW = 32) generate
    -- TODO: supporting only 64-bit AHB bus
    migin.app_wdf_mask(8 - 1 downto 4) <= (others => '0');
  end generate broken_32bit_bus_gen;
  migin.app_wdf_wren <= r.wdf_wren and migout.app_rdy;

  ahbso.hconfig <= hconfig;
  ahbso.hirq <= (others => '0');
  ahbso.hindex <= hindex;
  ahbso.hsplit <= (others => '0');

  regs : process(ui_clk)
  begin
    if rising_edge(ui_clk) then
      if ui_rstn = '0' then
        r <= REG_RESET;
        rnxt <= REG_RESET;
        rprev <= REG_RESET;
        current_state <= idle;
      else
        r <= rin;
        rnxt <= rnxtin;
        rprev <= rprevin;
        current_state <= next_state;
      end if;
    end if;
  end process;

  -- bsg_dmc reset is active high
  ui_rst <= not ui_rstn;
  phy_rst <= not phy_rstn;

  ddr_dqs_inout_gen : for i in 0 to 3 generate
    lpddr_dqs_p_ien(i) <= ddr_dqs_p_ien(i);
    lpddr_dqs_n_ien(i) <= ddr_dqs_n_ien(i);

    ddr_dqs_p_i(i) <= lpddr_dqs_p_i(i) when ddr_dqs_p_ien(i) = '0' else '0';
    ddr_dqs_n_i(i) <= lpddr_dqs_n_i(i) when ddr_dqs_n_ien(i) = '0' else '1';
  end generate ddr_dqs_inout_gen;

  bsg_dmc_wrap_1 : bsg_dmc_wrap
    generic map (
      ui_addr_width_p => 28,
      ui_data_width_p => AHBDW,
      ui_burst_length_p => 1,
      dq_data_width_p => 32,
      cmd_afifo_depth_p => 4,
      cmd_sfifo_depth_p => 4)
    port map (
      app_addr => migin.app_addr,
      app_cmd => migin.app_cmd,
      app_en => migin.app_en,
      app_wdf_data => migin.app_wdf_data,
      app_wdf_end => migin.app_wdf_end,
      app_wdf_mask => migin.app_wdf_mask,
      app_wdf_wren => migin.app_wdf_wren,
      app_rd_data => migout.app_rd_data,
      app_rd_data_end => migout.app_rd_data_end,
      app_rd_data_valid => migout.app_rd_data_valid,
      app_rdy => migout.app_rdy,
      app_wdf_rdy => migout.app_wdf_rdy,
      init_calib_complete => init_calib_complete(0),
      ui_clk_i => ui_clk,
      ui_reset_i => ui_rst,
      dfi_clk_2x_i => phy_clk_2x,
      dfi_clk_1x_i => phy_clk_1x,
      dfi_reset_i => phy_rst,
      ddr_ck_p_o => lpddr_ck_p,
      ddr_ck_n_o => lpddr_ck_n,
      ddr_cke_o => lpddr_cke,
      ddr_ba_o => lpddr_ba,
      ddr_addr_o => lpddr_addr,
      ddr_cs_n_o => lpddr_cs_n,
      ddr_ras_n_o => lpddr_ras_n,
      ddr_cas_n_o => lpddr_cas_n,
      ddr_we_n_o => lpddr_we_n,
      ddr_reset_n_o => lpddr_reset_n,
      ddr_odt_o => lpddr_odt,
      ddr_dm_oen_o => lpddr_dm_oen,
      ddr_dm_o => lpddr_dm,
      ddr_dqs_p_oen_o => lpddr_dqs_p_oen,
      ddr_dqs_p_ien_o => ddr_dqs_p_ien,
      ddr_dqs_p_o => lpddr_dqs_p_o,
      ddr_dqs_p_i => ddr_dqs_p_i,
      ddr_dqs_n_oen_o => lpddr_dqs_n_oen,
      ddr_dqs_n_ien_o => ddr_dqs_n_ien,
      ddr_dqs_n_o => lpddr_dqs_n_o,
      ddr_dqs_n_i => ddr_dqs_n_i,
      ddr_dq_oen_o => lpddr_dq_oen,
      ddr_dq_o => lpddr_dq_o,
      ddr_dq_i => lpddr_dq_i,
      delay_sel_i => ddr_cfg0(3 downto 0),
      trefi_i => trefi_ext,
      tmrd_i => ddr_cfg0(19 downto 16),
      trfc_i => ddr_cfg0(23 downto 20),
      trc_i => ddr_cfg0(27 downto 24),
      trp_i => ddr_cfg0(31 downto 28),
      tras_i => ddr_cfg1(3 downto 0),
      trrd_i => ddr_cfg1(7 downto 4),
      trcd_i => ddr_cfg1(11 downto 8),
      twr_i => ddr_cfg1(15 downto 12),
      twtr_i => ddr_cfg1(19 downto 16),
      trtp_i => ddr_cfg1(23 downto 20),
      tcas_i => ddr_cfg1(27 downto 24),
      col_width_i => ddr_cfg1(31 downto 28),
      row_width_i => ddr_cfg2(3 downto 0),
      bank_width_i => ddr_cfg2(5 downto 4),
      bank_pos_i => ddr_cfg2(11 downto 6),
      dqs_sel_cal_i => ddr_cfg2(14 downto 12),
      init_cycles_i => ddr_cfg2(30 downto 15)
      );

  trefi_ext <= ddr_cfg2(31) & ddr_cfg0(15 downto 4);

  init_calib_sync_gen: for i in 1 to 7 generate
    process (ui_clk, ui_rstn) is
    begin  -- process
      if ui_rstn = '0' then
        init_calib_complete(i) <= '0';
      elsif rising_edge(ui_clk) then
        init_calib_complete(i) <= init_calib_complete(i - 1);
      end if;
    end process;
  end generate init_calib_sync_gen;

  process (ui_clk, ui_rstn) is
  begin  -- process
    if ui_rstn = '0' then
      calib_done_count <= (others => '0');
    elsif rising_edge(ui_clk) then
      if init_calib_complete(7) = '1' then
        if calib_done_count /= "11111" then
          calib_done_count <= calib_done_count + "00001";
        end if;
      end if;
    end if;
  end process;

  calib_done_delayed <= '1' when calib_done_count = "11111" else '0';
  calib_done <= calib_done_delayed;

end;
