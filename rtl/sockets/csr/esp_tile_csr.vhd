-- Copyright (c) 2011-2022 Columbia University, System Level Design Group
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
use work.esp_csr_pkg.all;
use work.nocpackage.all;

entity esp_tile_csr is

  generic (
    pindex      : integer range 0 to NAPBSLV -1 := 0;
    dco_rst_cfg : std_logic_vector(30 downto 0) := (others => '0'));
  port (
    clk         : in std_logic;
    rstn        : in std_logic;
    pconfig     : in apb_config_type;
    mon_ddr     : in monitor_ddr_type;
    mon_mem     : in monitor_mem_type;
    mon_noc     : in monitor_noc_vector(1 to 6);
    mon_l2      : in monitor_cache_type;
    mon_llc     : in monitor_cache_type;
    mon_acc     : in monitor_acc_type;
    mon_dvfs    : in monitor_dvfs_type;
    tile_config : out std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);
    srst        : out std_ulogic;
    apbi        : in apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    prc_interrupt : in std_ulogic
  );
end esp_tile_csr;

architecture rtl of esp_tile_csr is
    --burst register is at offset 0 in APB region, monitors start right after
    constant BURST_REG_INDEX : integer := 0;
    constant MONITOR_APB_OFFSET : integer := 1;

    --offsets of each monitor type into monitor APB region
    constant MON_DDR_WORD_TRANSFER_INDEX    : integer := 0;
    constant MON_MEM_COH_REQ_INDEX          : integer := 1;
    constant MON_MEM_COH_FWD_INDEX          : integer := 2;
    constant MON_MEM_COH_RSP_RCV_INDEX      : integer := 3;
    constant MON_MEM_COH_RSP_SND_INDEX      : integer := 4;
    constant MON_MEM_DMA_REQ_INDEX          : integer := 5;
    constant MON_MEM_DMA_RSP_INDEX          : integer := 6;
    constant MON_MEM_COH_DMA_REQ_INDEX      : integer := 7;
    constant MON_MEM_COH_DMA_RSP_INDEX      : integer := 8;
    constant MON_L2_HIT_INDEX               : integer := 9;
    constant MON_L2_MISS_INDEX              : integer := 10;
    constant MON_LLC_HIT_INDEX              : integer := 11;
    constant MON_LLC_MISS_INDEX             : integer := 12;
    constant MON_ACC_TLB_INDEX              : integer := 13;
    constant MON_ACC_MEM_LO_INDEX           : integer := 14;
    constant MON_ACC_MEM_HI_INDEX           : integer := 15;
    constant MON_ACC_TOT_LO_INDEX           : integer := 16;
    constant MON_ACC_TOT_HI_INDEX           : integer := 17;

    constant MON_DVFS_BASE_INDEX            : integer := 18;
    constant VF_OP_POINTS                   : integer := 4;

    constant NOCS_NUM                       : integer := 6;
    constant NOC_QUEUES                     : integer := 5;
    constant MON_NOC_TILE_INJECT_BASE_INDEX : integer := MON_DVFS_BASE_INDEX + VF_OP_POINTS; --22
    constant MON_NOC_QUEUES_FULL_BASE_INDEX : integer := MON_NOC_TILE_INJECT_BASE_INDEX + NOCS_NUM; --28

    constant MONITOR_REG_COUNT : integer := MON_NOC_QUEUES_FULL_BASE_INDEX + NOCS_NUM * NOC_QUEUES; --58
    constant REGISTER_WIDTH : integer := 32;
     
    signal burst                  : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal readdata               : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal wdata                  : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal burst_sample           : std_ulogic;
    signal burst_start            : std_ulogic;
    signal burst_state            : std_ulogic;
    signal burst_state_next       : std_ulogic;

    type counter_type is array (0 to MONITOR_REG_COUNT-1) of std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal count : counter_type;
    signal count_value : counter_type;

    -- CSRs
    signal config_r : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

    -- DDR_CFG0
    constant DEFAULT_DDR_CFG0 : std_logic_vector(31 downto 0) :=
          X"2" &  X"A" &  X"F" &  X"1" & X"3FF" &   X"4";
    -- | 31-28 | 27-24 | 23-20 | 19-16 |  15-4  |    3-0    |
    -- |  trp  |  trc  |  trfc |  tmrd |  trefi | delay_sel |

    -- DDR_CFG1
    constant DEFAULT_DDR_CFG1 : std_logic_vector(31 downto 0) :=
            X"B"   & X"3"  & X"A"  & X"7"  &  X"A" & X"2" & X"1" &  X"7";
    -- |   31-28   | 27-24 | 23-20 | 19-16 | 15-12 | 11-8 |  7-4 |  3-0 |
    -- | col_width | tcas  | trtp  | twtr  |  twr  | trcd | trrd | tras |

    -- DDR_CFG2
    constant DEFAULT_DDR_CFG2 : std_logic_vector(31 downto 0) :=
        '0' &    X"9C4A"  &    "011"    & "011001" &    "10"    &    X"E";
    -- | 31 |     30-15   |    14-12    |   11-6   |     5-4    |    3-0    |
    -- | /  | init_cycles | dqs_sel_cal | bank_pos | bank_width | row_width |

    constant DEFAULT_CPU_LOC_OVR : std_logic_vector(CFG_NCPU_TILE * 2 * 3 downto 0) := (others => '0');
    -- CPU_Y(N-1) CPU_X(N-1) .... CPU_Y(0) CPU_X(0)    OVERWRITE DEFAULT FROM SOCMAP

    constant DEFAULT_ARIANE_HARTID : std_logic_vector(4 downto 0) :=
      "0000"    & "0";
    -- HART ID    OVERWRITE DEFAULT FROM SOCMAP

    constant DEFAULT_MDC_SCALER_CFG : std_logic_vector(10 downto 0) := conv_std_logic_vector(490, 11);
    -- Assume default I/O tile DCO frequency is 490MHz

    constant DEFAULT_DCO_NOC_CFG : std_logic_vector(18 downto 0) :=
       "00"     &  "100"   &  "000000" & "100101" & "0"     & "1";
    -- FREQ_SEL    DIV_SEL    FC_SEL      CC_SEL    CLK_SEL   EN

    constant DEFAULT_DCO_CFG : std_logic_vector(30 downto 0) :=
       "000000000000"          & "00"     &  "100"   &  "000000" & "100101" & "0"     & "1";
    --  reserved LPDDR   FREQ_SEL    DIV_SEL    FC_SEL      CC_SEL    CLK_SEL   EN

    constant DEFAULT_PAD_CFG : std_logic_vector(2 downto 0) :=
      "0"       &  "11";
    -- Slew rate   Drive strength

    constant DEFAULT_TILE_ID : std_logic_vector(7 downto 0) := (others => '0');

    constant DEFAULT_ACC_COH : std_logic_vector(1 downto 0) := (others => '0');

    constant DEFAULT_PRC_INTR_CFG : std_ulogic := '0';

    constant DEFAULT_DECOUP_CFG   :std_ulogic := '0';

    function dco_reset_config_ovr
      return std_logic_vector is
    begin
      if dco_rst_cfg = ("000" & X"0000000") then
        -- Use default
        return DEFAULT_DCO_CFG;
      else
        -- Use override value at reset (used for ASIC DDR tiles)
        return dco_rst_cfg;
      end if;
    end function;

    constant RESET_DCO_CFG : std_logic_vector(30 downto 0) := dco_reset_config_ovr;

    constant DEFAULT_CONFIG : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0) :=
        DEFAULT_DECOUP_CFG & DEFAULT_PRC_INTR_CFG & DEFAULT_ACC_COH & DEFAULT_DDR_CFG2 & DEFAULT_DDR_CFG1 & DEFAULT_DDR_CFG0 & DEFAULT_CPU_LOC_OVR & DEFAULT_ARIANE_HARTID &
        DEFAULT_MDC_SCALER_CFG & DEFAULT_DCO_NOC_CFG & RESET_DCO_CFG & DEFAULT_PAD_CFG & DEFAULT_TILE_ID & "0";

    signal csr_addr : integer range 0 to 31;

    begin

      apbo.prdata   <= readdata;
      apbo.pirq     <= (others => '0');
      apbo.pindex   <= pindex;
      apbo.pconfig  <= pconfig;

      tile_config <= config_r;
      csr_addr <= conv_integer(apbi.paddr(6 downto 2));

      rd_registers : process(apbi, count, count_value, burst, config_r, csr_addr)
        --TODO
        variable addr : integer range 0 to 127;
      begin
        addr := conv_integer(apbi.paddr(8 downto 2));
        readdata <= (others => '0');

        wdata <= apbi.pwdata;

        burst_sample <= '0';
        if addr = 0  then
            burst_sample <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
        end if;

        if apbi.paddr(8 downto 7) = "11" then
          -- Config read access
          case csr_addr is
            when ESP_CSR_VALID_ADDR =>
              readdata(ESP_CSR_VALID_MSB - ESP_CSR_VALID_LSB downto 0) <=
                config_r(ESP_CSR_VALID_MSB downto ESP_CSR_VALID_LSB);
            when ESP_CSR_TILE_ID_ADDR =>
              readdata(ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB downto 0) <=
                config_r(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB);
            when ESP_CSR_PAD_CFG_ADDR =>
              readdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0) <=
                config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB);
            when ESP_CSR_DCO_CFG_ADDR =>
              readdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0) <=
                config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB);
            when ESP_CSR_DCO_NOC_CFG_ADDR =>
              readdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0) <=
                config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB);
            when ESP_CSR_MDC_SCALER_CFG_ADDR =>
              readdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0) <=
                config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB);
            when ESP_CSR_ARIANE_HARTID_ADDR =>
              readdata(ESP_CSR_ARIANE_HARTID_MSB - ESP_CSR_ARIANE_HARTID_LSB downto 0) <=
                config_r(ESP_CSR_ARIANE_HARTID_MSB downto ESP_CSR_ARIANE_HARTID_LSB);
            when ESP_CSR_CPU_LOC_OVR_ADDR =>
              readdata(ESP_CSR_CPU_LOC_OVR_MSB - ESP_CSR_CPU_LOC_OVR_LSB downto 0) <=
                config_r(ESP_CSR_CPU_LOC_OVR_MSB downto ESP_CSR_CPU_LOC_OVR_LSB);
            when ESP_CSR_DDR_CFG0_ADDR =>
              readdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0) <=
                config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB);
            when ESP_CSR_DDR_CFG1_ADDR =>
              readdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0) <=
                config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB);
            when ESP_CSR_DDR_CFG2_ADDR =>
              readdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0) <= config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB);
            when ESP_CSR_ACC_COH_ADDR =>
              readdata(ESP_CSR_ACC_COH_MSB - ESP_CSR_ACC_COH_LSB downto 0) <= config_r(ESP_CSR_ACC_COH_MSB downto ESP_CSR_ACC_COH_LSB);
            when ESP_CSR_ACC_DECOUPLER_ADDR =>
              readdata(ESP_CSR_ACC_DECOUPLER_MSB - ESP_CSR_ACC_DECOUPLER_LSB downto 0) <= config_r(ESP_CSR_ACC_DECOUPLER_MSB downto ESP_CSR_ACC_DECOUPLER_LSB);
            when ESP_CSR_PRC_INTR_ADDR =>
              readdata(ESP_CSR_PRC_INTR_MSB - ESP_CSR_PRC_INTR_LSB downto 0) <= (0 =>  prc_interrupt, others => '0'); --config_r(ESP_CSR_PRC_INTR_MSB downto ESP_CSR_PRC_INTR_LSB);
            when others =>
              readdata <= (others => '0');
          end case;
        else
          -- Monitors read access
          if addr = 0 then
            readdata <= burst;
          elsif addr < MONITOR_REG_COUNT + MONITOR_APB_OFFSET then
            if burst_state = '0' then
                readdata <= count(addr - MONITOR_APB_OFFSET);
            else
                readdata <= count_value(addr - MONITOR_APB_OFFSET);
            end if;
          end if;
        end if;
      end process rd_registers;

      wr_registers : process(clk, rstn)
      begin
        if rstn =  '0' then
            burst <= (others => '0');
            config_r <= DEFAULT_CONFIG;
            srst <= '0';
        elsif clk'event and clk = '1' then
          -- Monitors
          if burst_sample = '1' then
            burst <= wdata;
          end if;
          -- Config write
          if apbi.paddr(8 downto 7) = "11" and (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case csr_addr is
              when ESP_CSR_VALID_ADDR =>
                config_r(ESP_CSR_VALID_MSB downto ESP_CSR_VALID_LSB) <= apbi.pwdata(ESP_CSR_VALID_MSB - ESP_CSR_VALID_LSB downto 0);
              when ESP_CSR_TILE_ID_ADDR =>
                config_r(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB) <= apbi.pwdata(ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB downto 0);
              when ESP_CSR_PAD_CFG_ADDR =>
                config_r(ESP_CSR_PAD_CFG_MSB downto ESP_CSR_PAD_CFG_LSB) <= apbi.pwdata(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
              when ESP_CSR_DCO_CFG_ADDR =>
                config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB) <= apbi.pwdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0);
              when ESP_CSR_DCO_NOC_CFG_ADDR =>
                config_r(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_LSB) <= apbi.pwdata(ESP_CSR_DCO_NOC_CFG_MSB - ESP_CSR_DCO_NOC_CFG_LSB downto 0);
              when ESP_CSR_MDC_SCALER_CFG_ADDR =>
                config_r(ESP_CSR_MDC_SCALER_CFG_MSB downto ESP_CSR_MDC_SCALER_CFG_LSB) <= apbi.pwdata(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0);
              when ESP_CSR_ARIANE_HARTID_ADDR =>
                config_r(ESP_CSR_ARIANE_HARTID_MSB downto ESP_CSR_ARIANE_HARTID_LSB) <= apbi.pwdata(ESP_CSR_ARIANE_HARTID_MSB - ESP_CSR_ARIANE_HARTID_LSB downto 0);
              when ESP_CSR_CPU_LOC_OVR_ADDR =>
                config_r(ESP_CSR_CPU_LOC_OVR_MSB downto ESP_CSR_CPU_LOC_OVR_LSB) <= apbi.pwdata(ESP_CSR_CPU_LOC_OVR_MSB - ESP_CSR_CPU_LOC_OVR_LSB downto 0);
              when ESP_CSR_DDR_CFG0_ADDR =>
                config_r(ESP_CSR_DDR_CFG0_MSB downto ESP_CSR_DDR_CFG0_LSB) <= apbi.pwdata(ESP_CSR_DDR_CFG0_MSB - ESP_CSR_DDR_CFG0_LSB downto 0);
              when ESP_CSR_DDR_CFG1_ADDR =>
                config_r(ESP_CSR_DDR_CFG1_MSB downto ESP_CSR_DDR_CFG1_LSB) <= apbi.pwdata(ESP_CSR_DDR_CFG1_MSB - ESP_CSR_DDR_CFG1_LSB downto 0);
              when ESP_CSR_DDR_CFG2_ADDR =>
                config_r(ESP_CSR_DDR_CFG2_MSB downto ESP_CSR_DDR_CFG2_LSB) <= apbi.pwdata(ESP_CSR_DDR_CFG2_MSB - ESP_CSR_DDR_CFG2_LSB downto 0);
              when ESP_CSR_ACC_COH_ADDR =>
                config_r(ESP_CSR_ACC_COH_MSB downto ESP_CSR_ACC_COH_LSB) <= apbi.pwdata(ESP_CSR_ACC_COH_MSB - ESP_CSR_ACC_COH_LSB downto 0);
              when ESP_CSR_ACC_DECOUPLER_ADDR =>
                config_r(ESP_CSR_ACC_DECOUPLER_MSB downto ESP_CSR_ACC_DECOUPLER_LSB) <= apbi.pwdata(ESP_CSR_ACC_DECOUPLER_MSB - ESP_CSR_ACC_DECOUPLER_LSB downto 0); 
              when ESP_CSR_SRST_ADDR =>
                srst <= wdata(0);
              when others => null;
            end case;
          end if;
        end if;
  end process wr_registers;

  --"burst" mode provides synchronization to all monitors in a tile
  --by sampling all counters to a different set of registers, while
  --the counters continue to increment. Any queries are served to this
  --second set of monitors until burst mode is cleared
  burst_state_reg : process(clk, rstn)
  begin
    if rstn = '0' then
        burst_state <= '0';
    elsif clk'event and clk = '1' then
        burst_state <= burst_state_next;
    end if;
  end process burst_state_reg;

  burst_fsm : process(burst, burst_state)
  begin
    burst_start <= '0';
    burst_state_next <= burst(0);
    if burst(0) = '1' and burst_state = '0' then
      burst_start <= '1';
    end if;
  end process burst_fsm;

  counters : process (clk, rstn)
    variable accelerator_mem_count : std_logic_vector(2*REGISTER_WIDTH-1 downto 0);
    variable accelerator_tot_count : std_logic_vector(2*REGISTER_WIDTH-1 downto 0);
    variable accelerator_tlb_count : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  begin
    if rstn = '0' then
      for R in 0 to MONITOR_REG_COUNT-1 loop
        count(R) <= (others => '0');
        count_value(R) <= (others => '0');
      end loop;
      accelerator_tlb_count := (others => '0');
      accelerator_mem_count := (others => '0');
      accelerator_tot_count := (others => '0');
    elsif clk'event and clk = '1' then
      --DDR
      if mon_ddr.word_transfer = '1' then
        count(MON_DDR_WORD_TRANSFER_INDEX) <= count(MON_DDR_WORD_TRANSFER_INDEX) + 1;
      end if;
      --MEM
      if mon_mem.coherent_req = '1' then
        count(MON_MEM_COH_REQ_INDEX) <= count(MON_MEM_COH_REQ_INDEX) + 1;
      end if;
      if mon_mem.coherent_fwd = '1' then
        count(MON_MEM_COH_FWD_INDEX) <= count(MON_MEM_COH_FWD_INDEX) + 1;
      end if;
      if mon_mem.coherent_rsp_rcv = '1' then
        count(MON_MEM_COH_RSP_RCV_INDEX) <= count(MON_MEM_COH_RSP_RCV_INDEX) + 1;
      end if;
      if mon_mem.coherent_rsp_snd = '1' then
        count(MON_MEM_COH_RSP_SND_INDEX) <= count(MON_MEM_COH_RSP_SND_INDEX) + 1;
      end if;
      if mon_mem.dma_req = '1' then
        count(MON_MEM_DMA_REQ_INDEX) <= count(MON_MEM_DMA_REQ_INDEX) + 1;
      end if;
      if mon_mem.dma_rsp = '1' then
        count(MON_MEM_DMA_RSP_INDEX) <= count(MON_MEM_DMA_RSP_INDEX) + 1;
      end if;
      if mon_mem.coherent_dma_req = '1' then
        count(MON_MEM_COH_DMA_REQ_INDEX) <= count(MON_MEM_COH_DMA_REQ_INDEX) + 1;
      end if;
      if mon_mem.coherent_dma_rsp = '1' then
        count(MON_MEM_COH_DMA_RSP_INDEX) <= count(MON_MEM_COH_DMA_RSP_INDEX) + 1;
      end if;
      --L2
      if mon_l2.hit = '1' then
        count(MON_L2_HIT_INDEX) <= count(MON_L2_HIT_INDEX) + 1;
      end if;
      if mon_l2.miss = '1' then
        count(MON_L2_MISS_INDEX) <= count(MON_L2_MISS_INDEX) + 1;
      end if;

      --LLC
      if mon_llc.hit = '1' then
        count(MON_LLC_HIT_INDEX) <= count(MON_LLC_HIT_INDEX) + 1;
      end if;
      if mon_llc.miss = '1' then
        count(MON_LLC_MISS_INDEX) <= count(MON_LLC_MISS_INDEX) + 1;
      end if;

      --ACC
      if mon_acc.done = '0' then
        if mon_acc.go = '1' and mon_acc.run = '0' then
          accelerator_tlb_count := accelerator_tlb_count + 1;
          count(MON_ACC_TLB_INDEX) <= accelerator_tlb_count;
        end if;
        if mon_acc.run = '1' or mon_acc.go = '1' then
          accelerator_tot_count := accelerator_tot_count + 1;
          count(MON_ACC_TOT_LO_INDEX) <= accelerator_tot_count(REGISTER_WIDTH-1 downto 0);
          count(MON_ACC_TOT_HI_INDEX) <= accelerator_tot_count(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH);
        end if;
        if mon_acc.run = '1' and mon_acc.burst = '1' then
          accelerator_mem_count := accelerator_mem_count + 1;
          count(MON_ACC_MEM_LO_INDEX) <= accelerator_mem_count(REGISTER_WIDTH-1 downto 0);
          count(MON_ACC_MEM_HI_INDEX) <= accelerator_mem_count(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH);
        end if;
      end if;

      --DVFS
      for V in 0 to VF_OP_POINTS - 1 loop
        if mon_dvfs.vf(V) = '1' then
            count(MON_DVFS_BASE_INDEX + V) <= count(MON_DVFS_BASE_INDEX + V) + 1;
        end if;
      end loop;

      --NoC
      for N in 1 to NOCS_NUM loop
        if mon_noc(N).tile_inject  = '1' then
          count(MON_NOC_TILE_INJECT_BASE_INDEX + (N-1)) <= count(MON_NOC_TILE_INJECT_BASE_INDEX + (N-1)) + 1;
        end if;

        for Q in 0 to NOC_QUEUES -1 loop
          if mon_noc(N).queue_full(Q)  = '1' then
            count(MON_NOC_QUEUES_FULL_BASE_INDEX + NOC_QUEUES*(N-1) + Q) <=
                count(MON_NOC_QUEUES_FULL_BASE_INDEX + NOC_QUEUES*(N-1) + Q) + 1;
          end if;
        end loop;
      end loop;

      if burst_start = '1' then
        for R in 0 to MONITOR_REG_COUNT - 1 loop
          count_value(R) <= count(R);
        end loop;
      end if;

    end if;
  end process counters;

end;
