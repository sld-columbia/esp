-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.sld_devices.all;
use work.gencomp.all;
use work.allclkgen.all;
use work.sldcommon.all;
use work.nocpackage.all;

entity esp_tile_csr is

  generic (
    pindex      : integer range 0 to NAPBSLV -1 := 0);
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
    config      : out std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);
    srst        : out std_ulogic;
    apbi        : in apb_slv_in_type;
    apbo        : out apb_slv_out_type
  );
end esp_tile_csr;

architecture rtl of esp_tile_csr is 
    constant MONITOR_APB_OFFSET : integer := 4;
  
    constant CRTL_RESET : integer := 0;
    constant CTRL_WINDOW_SIZE_OFFSET : integer := 1;
    constant CTRL_WINDOW_COUNT_LO_OFFSET : integer := 2;
    constant CTRL_WINDOW_COUNT_HI_OFFSET : integer := 3;
    
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
    constant DEFAULT_WINDOW : std_logic_vector(REGISTER_WIDTH-1 downto 0) := conv_std_logic_vector(65536, REGISTER_WIDTH);
    
    signal window_size  : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal time_counter : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal window_reset : std_logic;
    signal new_window   : std_logic;
    signal updated      : std_logic;
    signal window_count : std_logic_vector(63 downto 0); 
    signal ctrl_rst     : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal readdata     : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal wdata        : std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal ctrl_rst_sample         : std_ulogic;
    signal ctrl_window_size_sample : std_ulogic;

    type counter_type is array (0 to MONITOR_REG_COUNT-1) of std_logic_vector(REGISTER_WIDTH-1 downto 0);
    signal count : counter_type;
    signal count_value : counter_type;

    -- CSRs
    signal config_r : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);
    constant DEFAULT_CONFIG : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0) := (others => '0');

    signal csr_addr : integer range 0 to 31;

 begin

  apbo.prdata   <= readdata;
  apbo.pirq     <= (others => '0');
  apbo.pindex   <= pindex;
  apbo.pconfig  <= pconfig;

  config <= config_r;
  csr_addr <= conv_integer(apbi.paddr(6 downto 2));

  rd_registers : process(apbi, count_value, ctrl_rst, window_size, window_count, config_r, csr_addr)
    --TODO 
    variable addr : integer range 0 to 127;
  begin 
    addr := conv_integer(apbi.paddr(8 downto 2));
    readdata <= (others => '0');

    wdata <= apbi.pwdata;

    ctrl_rst_sample <= '0';
    ctrl_window_size_sample <= '0';
    if addr = 0  then
        ctrl_rst_sample <= apbi.psel(pindex) and apbi.penable and apbi.pwrite; 
    end if;
    if addr = 1 then
        ctrl_window_size_sample <= apbi.psel(pindex) and apbi.penable and apbi.pwrite;
    end if;

    if apbi.paddr(8 downto 7) = "11" then
      -- Config read access
      case csr_addr is
        when ESP_CSR_VALID_ADDR =>
          readdata(ESP_CSR_VALID_MSB - ESP_CSR_VALID_LSB downto 0) <= config_r(ESP_CSR_VALID_MSB downto ESP_CSR_VALID_LSB);
        when ESP_CSR_TILE_ID_ADDR =>
          readdata(ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB downto 0) <= config_r(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB);
        when others =>
          readdata <= (others => '0');
      end case;
    else
      -- Monitors read access
      if addr = 0 then
        readdata <= ctrl_rst;
      elsif addr = 1 then
        readdata <= window_size;
      elsif addr = 2 then 
        readdata <= window_count(REGISTER_WIDTH-1 downto 0);
      elsif addr = 3 then
        readdata <= window_count(2*REGISTER_WIDTH-1 downto REGISTER_WIDTH);
      elsif addr < MONITOR_REG_COUNT + MONITOR_APB_OFFSET then 
        readdata <= count_value(addr - MONITOR_APB_OFFSET);
      end if;
    end if;
  end process rd_registers;
  
  wr_registers : process(clk, rstn)
  begin
    if rstn =  '0' then
        ctrl_rst <= (others => '0');
        window_size <= DEFAULT_WINDOW;
        window_reset <= '0';
        config_r <= DEFAULT_CONFIG;
        srst <= '0';
    elsif clk'event and clk = '1' then 
        -- Monitors
        window_reset <= '0';
        ctrl_rst <= (others => '0');
        if ctrl_rst_sample = '1' then
            ctrl_rst <= wdata;
        end if; 
        if ctrl_window_size_sample = '1' then 
            window_size  <= wdata;
            window_reset <= '1';
        end if;
        -- Config write
        if apbi.paddr(8 downto 7) = "11" and (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
          case csr_addr is
            when ESP_CSR_VALID_ADDR =>
              config_r(ESP_CSR_VALID_MSB downto ESP_CSR_VALID_LSB) <= apbi.pwdata(ESP_CSR_VALID_MSB - ESP_CSR_VALID_LSB downto 0);
            when ESP_CSR_TILE_ID_ADDR =>
              config_r(ESP_CSR_TILE_ID_MSB downto ESP_CSR_TILE_ID_LSB) <= apbi.pwdata(ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB downto 0);
            when ESP_CSR_SRST_ADDR =>
              srst <= wdata(0);
            when others => null;
          end case;
        end if;
    end if;
  end process wr_registers;

  time_stamp_update: process (clk, rstn)
    variable new_window_setup : std_logic_vector(REGISTER_WIDTH-1 downto 0);
  begin -- process time_stamp_update
    if rstn = '0' then         -- asynchronous reset (active low)
      new_window <= '0';
      window_count <= (others => '0');
      time_counter <= (others => '0');
      new_window_setup := (others => '0');
    elsif clk'event and clk = '1' then -- rising clock edge
      new_window_setup := window_size - conv_std_logic_vector(64, REGISTER_WIDTH);
      -- Advance time
      time_counter <= time_counter + 1;
      -- Advance window count
      if time_counter = window_size or window_reset = '1' or ctrl_rst(0) = '1' then
        time_counter <= (others => '0');
        window_count <= window_count + 1;
        new_window <= '1';
      end if;

      if time_counter = conv_std_logic_vector(10, REGISTER_WIDTH) then
        -- hold new_window for 10 cycles to make sure perf. counters get the reset.
        new_window <= '0';
      end if;

    end if;
  end process time_stamp_update;

  update : process(clk, rstn)
  begin --process
      if rstn = '0' then 
        updated <= '0';
      elsif clk'event and clk = '1' then 
        if new_window = '1' and updated = '0' then
          updated <= '1';
        elsif new_window = '0' then 
          updated <= '0';
        end if;
      end if;
  end process;
  

  counters : process (clk, rstn)
    variable accelerator_mem_count : std_logic_vector(2*REGISTER_WIDTH-1 downto 0) := (others => '0');
    variable accelerator_tot_count : std_logic_vector(2*REGISTER_WIDTH-1 downto 0) := (others => '0');
    variable accelerator_tlb_count : std_logic_vector(REGISTER_WIDTH-1 downto 0) := (others => '0');
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
            count(MON_NOC_QUEUES_FULL_BASE_INDEX + NOC_QUEUES*(N-1) + Q) <= count(MON_NOC_QUEUES_FULL_BASE_INDEX + NOC_QUEUES*(N-1) + Q) + 1;   
          end if;
        end loop; 
      end loop;

      if new_window = '1' and updated = '0' then 
        for R in 0 to MONITOR_REG_COUNT - 1 loop
          count(R) <= (others => '0');
          count_value(R) <= count(R);
        end loop;
        accelerator_tlb_count := (others => '0');
        accelerator_mem_count := (others => '0');
        accelerator_tot_count := (others => '0');
      end if;
   
    end if;
  end process counters;
    
end;    
