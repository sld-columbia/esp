-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.sld_devices.all;
use work.gencomp.all;
use work.allclkgen.all;
use work.monitor_pkg.all;
use work.esp_noc_csr_pkg.all;
use work.nocpackage.all;

entity esp_noc_csr is

  generic (
    pindex       : integer range 0 to NAPBSLV -1 := 0;
    has_token_pm : integer range 0 to 1          := 0;
    has_ddr      : boolean                       := false);
  port (
    clk         : in  std_logic;
    rstn        : in  std_logic;
    pconfig     : in  apb_config_type;
    tile_config : out std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0);
    pm_config   : out pm_config_type;
    pm_status   : in  pm_status_type;
    apbi        : in  apb_slv_in_type;
    apbo        : out apb_slv_out_type
    );
end esp_noc_csr;

architecture rtl of esp_noc_csr is

  constant REGISTER_WIDTH : integer := 32;
  signal readdata         : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  signal wdata            : std_logic_vector(REGISTER_WIDTH-1 downto 0);

  -- CSRs
  signal config_r    : std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0);
  signal pm_config_r : pm_config_type;
  signal pm_status_r : pm_status_type;

  constant DEFAULT_DCO_NOC_CFG : std_logic_vector(18 downto 0) :=
    "11" & "100" & "000000" & "100101" & "0" & "1";
  -- FREQ_SEL    DIV_SEL    FC_SEL      CC_SEL    CLK_SEL   EN

  constant DEFAULT_DCO_CFG : std_logic_vector(23 downto 0) :=
    "0" & "0000" & "11" & "100" & "000000" & "100101" & "0" & "1";
  --  CC_SEL_MUX   reserved LPDDR   FREQ_SEL    DIV_SEL    FC_SEL      CC_SEL    CLK_SEL   EN

  constant DEFAULT_DCO_LPDDR_CFG : std_logic_vector(23 downto 0) :=
    "0" & "0111" & "00" & "100" & "000000" & "110001" & "0" & "1";
  -- CC_SEL_MUX   UI_CLK_DEL   FREQ_SEL    DIV_SEL    FC_SEL     CC_SEL    CLK_SEL    EN

  constant DEFAULT_LDO_CFG : std_logic_vector(8 downto 0) :=
    "0" & "00000000";
  --  RES_SEL_MUX   RES_SEL

  constant DEFAULT_PAD_CFG : std_logic_vector(2 downto 0) :=
    "0" & "11";
  -- Slew rate   Drive strength

  constant DEFAULT_MDC_SCALER_CFG : std_logic_vector(10 downto 0) := conv_std_logic_vector(490, 11);
  -- Assume default I/O tile DCO frequency is 490MHz

  constant DEFAULT_TILE_ID : std_logic_vector(7 downto 0) := (others => '0');

  -- DDR_CFG0
  constant DEFAULT_DDR_CFG0 : std_logic_vector(31 downto 0) :=
    X"2" & X"A" & X"F" & X"1" & X"3FF" & X"4";
  -- | 31-28 | 27-24 | 23-20 | 19-16 |  15-4  |    3-0    |
  -- |  trp  |  trc  |  trfc |  tmrd |  trefi | delay_sel |

  -- DDR_CFG1
  constant DEFAULT_DDR_CFG1 : std_logic_vector(31 downto 0) :=
    X"B" & X"3" & X"A" & X"7" & X"A" & X"2" & X"1" & X"7";
  -- |   31-28   | 27-24 | 23-20 | 19-16 | 15-12 | 11-8 |  7-4 |  3-0 |
  -- | col_width | tcas  | trtp  | twtr  |  twr  | trcd | trrd | tras |

  -- DDR_CFG2
  constant DEFAULT_DDR_CFG2 : std_logic_vector(31 downto 0) :=
    '0' & X"9C4A" & "011" & "011001" & "10" & X"E";
  -- | 31 |     30-15   |    14-12    |   11-6   |     5-4    |    3-0    |
  -- | /  | init_cycles | dqs_sel_cal | bank_pos | bank_width | row_width |

  function dco_reset_config
    return std_logic_vector is
  begin
    if has_ddr = false then
      -- Use default
      return DEFAULT_DCO_CFG;
    else
      -- Use config for ASIC DDR tiles
      return DEFAULT_DCO_LPDDR_CFG;
    end if;
  end function;

  constant RESET_DCO_CFG : std_logic_vector(23 downto 0) := dco_reset_config;

  constant DEFAULT_CONFIG : std_logic_vector(ESP_NOC_CSR_WIDTH - 1 downto 0) :=
    DEFAULT_DDR_CFG2 & DEFAULT_DDR_CFG1 & DEFAULT_DDR_CFG0 & DEFAULT_MDC_SCALER_CFG &
    DEFAULT_LDO_CFG & DEFAULT_DCO_NOC_CFG & RESET_DCO_CFG & DEFAULT_PAD_CFG & DEFAULT_TILE_ID;

  signal csr_addr : integer range 0 to 31;

begin

  apbo.prdata  <= readdata;
  apbo.pirq    <= (others => '0');
  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

  tile_config <= config_r;
  csr_addr    <= conv_integer(apbi.paddr(6 downto 2));

  no_token_pm_gen : if has_token_pm = 0 generate

    pm_config <= (others => (others => '0'));

    rd_registers : process(apbi, config_r, csr_addr)
      variable addr : integer range 0 to 127;
    begin
      addr     := conv_integer(apbi.paddr(8 downto 2));
      readdata <= (others => '0');

      wdata <= apbi.pwdata;

      if apbi.paddr(8 downto 7) = "11" then
        -- Config read access
        case csr_addr is
          when ESP_CSR_TILE_ID_NOC_ADDR =>
            readdata(ESP_CSR_TILE_ID_NOC_MSB - ESP_CSR_TILE_ID_NOC_LSB downto 0) <=
              config_r(ESP_CSR_TILE_ID_NOC_MSB downto ESP_CSR_TILE_ID_NOC_LSB);
          when ESP_CSR_PAD_CFG_ADDR =>
            readdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0) <=
              config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);
          when ESP_CSR_DCO_CFG_ADDR =>
            readdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0) <=
              config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB);
          when ESP_CSR_DCO_NOC_CFG_ADDR =>
            readdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0) <=
              config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB);
          when ESP_CSR_LDO_CFG_ADDR =>
            readdata(ESP_CSR_LDO_CFG_MSB - ESP_CSR_LDO_CFG_LSB downto 0) <=
              config_r(ESP_CSR_LDO_CFG_MSB downto ESP_CSR_LDO_CFG_LSB);
          when ESP_CSR_MDC_SCALER_CFG_ADDR =>
            readdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0) <=
              config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB);
          when ESP_CSR_DDR_CFG0_ADDR =>
            readdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB);
          when ESP_CSR_DDR_CFG1_ADDR =>
            readdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB);
          when ESP_CSR_DDR_CFG2_ADDR =>
            readdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB);

          when others =>
            readdata <= (others => '0');
        end case;
      end if;
    end process rd_registers;

    wr_registers : process(clk, rstn)
    begin
      if rstn = '0' then
        config_r <= DEFAULT_CONFIG;
      elsif clk'event and clk = '1' then
        -- Config write
        if apbi.paddr(8 downto 7) = "11" and (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
          case csr_addr is
            when ESP_CSR_TILE_ID_NOC_ADDR =>
              config_r(ESP_CSR_TILE_ID_NOC_MSB downto ESP_CSR_TILE_ID_NOC_LSB) <=
                apbi.pwdata(ESP_CSR_TILE_ID_NOC_MSB - ESP_CSR_TILE_ID_NOC_LSB downto 0);
            when ESP_CSR_PAD_CFG_ADDR =>
              config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
            when ESP_CSR_DCO_CFG_ADDR =>
              config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0);
            when ESP_CSR_DCO_NOC_CFG_ADDR =>
              config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0);
            when ESP_CSR_LDO_CFG_ADDR =>
              config_r(ESP_CSR_LDO_CFG_MSB downto ESP_CSR_LDO_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_LDO_CFG_MSB - ESP_CSR_LDO_CFG_LSB downto 0);
            when ESP_CSR_MDC_SCALER_CFG_ADDR =>
              config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0);
            when ESP_CSR_DDR_CFG0_ADDR =>
              config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0);
            when ESP_CSR_DDR_CFG1_ADDR =>
              config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0);
            when ESP_CSR_DDR_CFG2_ADDR =>
              config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0);

            when others => null;
          end case;
        end if;
      end if;
    end process wr_registers;

  end generate no_token_pm_gen;

  token_pm_gen : if has_token_pm /= 0 generate

    pm_config <= pm_config_r;

    pm_status_update : process(clk, rstn)
    begin  --process
      if rstn = '0' then
        for i in 0 to PM_REGNUM_STATUS - 1 loop
          pm_status_r(i) <= (others => '0');
        end loop;
      elsif clk'event and clk = '1' then
        for i in 0 to PM_REGNUM_STATUS - 1 loop
          pm_status_r(i) <= pm_status(i);
        end loop;
      end if;
    end process;

    rd_registers : process(apbi, config_r, csr_addr, pm_config_r, pm_status_r)
      variable addr : integer range 0 to 127;
    begin
      addr     := conv_integer(apbi.paddr(8 downto 2));
      readdata <= (others => '0');

      wdata <= apbi.pwdata;

      if apbi.paddr(8 downto 7) = "11" then
        -- Config read access
        case csr_addr is
          when ESP_CSR_TILE_ID_NOC_ADDR =>
            readdata(ESP_CSR_TILE_ID_NOC_MSB - ESP_CSR_TILE_ID_NOC_LSB downto 0) <=
              config_r(ESP_CSR_TILE_ID_NOC_MSB downto ESP_CSR_TILE_ID_NOC_LSB);
          when ESP_CSR_PAD_CFG_ADDR =>
            readdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0) <=
              config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);
          when ESP_CSR_DCO_CFG_ADDR =>
            readdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0) <=
              config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB);
          when ESP_CSR_DCO_NOC_CFG_ADDR =>
            readdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0) <=
              config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB);
          when ESP_CSR_LDO_CFG_ADDR =>
            readdata(ESP_CSR_LDO_CFG_MSB - ESP_CSR_LDO_CFG_LSB downto 0) <=
              config_r(ESP_CSR_LDO_CFG_MSB downto ESP_CSR_LDO_CFG_LSB);
          when ESP_CSR_MDC_SCALER_CFG_ADDR =>
            readdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0) <=
              config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB);
          when ESP_CSR_DDR_CFG0_ADDR =>
            readdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB);
          when ESP_CSR_DDR_CFG1_ADDR =>
            readdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB);
          when ESP_CSR_DDR_CFG2_ADDR =>
            readdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0) <=
              config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB);

          -- Power management
          when ESP_CSR_PM_MIN to ESP_CSR_PM_MIN + PM_REGNUM_CONFIG - 1 =>
            readdata(31 downto 0) <= pm_config_r(csr_addr - ESP_CSR_PM_MIN);

          when ESP_CSR_PM_MIN + PM_REGNUM_CONFIG to ESP_CSR_PM_MAX =>
            readdata(31 downto 0) <= pm_status_r(csr_addr - ESP_CSR_PM_MIN - PM_REGNUM_CONFIG);

          when others =>
            readdata <= (others => '0');
        end case;
      end if;
    end process rd_registers;

    wr_registers : process(clk, rstn)
    begin
      if rstn = '0' then
        config_r    <= DEFAULT_CONFIG;
        pm_config_r <= (others => (others => '0'));
      elsif clk'event and clk = '1' then
        -- Config write
        if apbi.paddr(8 downto 7) = "11" and (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
          case csr_addr is
            when ESP_CSR_TILE_ID_NOC_ADDR =>
              config_r(ESP_CSR_TILE_ID_NOC_MSB downto ESP_CSR_TILE_ID_NOC_LSB) <=
                apbi.pwdata(ESP_CSR_TILE_ID_NOC_MSB - ESP_CSR_TILE_ID_NOC_LSB downto 0);
            when ESP_CSR_PAD_CFG_ADDR =>
              config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
            when ESP_CSR_DCO_CFG_ADDR =>
              config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0);
            when ESP_CSR_DCO_NOC_CFG_ADDR =>
              config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0);
            when ESP_CSR_LDO_CFG_ADDR =>
              config_r(ESP_CSR_LDO_CFG_MSB downto ESP_CSR_LDO_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_LDO_CFG_MSB - ESP_CSR_LDO_CFG_LSB downto 0);
            when ESP_CSR_MDC_SCALER_CFG_ADDR =>
              config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0);
            when ESP_CSR_DDR_CFG0_ADDR =>
              config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0);
            when ESP_CSR_DDR_CFG1_ADDR =>
              config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0);
            when ESP_CSR_DDR_CFG2_ADDR =>
              config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB) <=
                apbi.pwdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0);

            -- Power management
            when ESP_CSR_PM_MIN to ESP_CSR_PM_MIN + PM_REGNUM_CONFIG - 1 =>
              pm_config_r(csr_addr - ESP_CSR_PM_MIN) <= apbi.pwdata(31 downto 0);

            when others => null;
          end case;
        end if;
      end if;
    end process wr_registers;

  end generate token_pm_gen;

end;
