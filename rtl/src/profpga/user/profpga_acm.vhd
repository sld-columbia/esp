-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--!  @project      proFPGA
-- =============================================================================
--!  @file         profpga_acm.vhd
--!  @author       Sebastian Fluegel
--!  @email        sebastian.fluegel@prodesign-europe.com
--!  @brief        proFPGA user fpga advanced clock management (ACM) module
--!                (Xilinx Virtex-7 implementation)
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.profpga_pkg.all;

entity profpga_acm is
  generic (
    ACM_CLOCKS      : natural := 0
  );
  port (
    -- FPGA input pins
    clk_p           : in  std_ulogic;
    clk_n           : in  std_ulogic;
    sync_p          : in  std_ulogic;
    sync_n          : in  std_ulogic;

    -- ACM configuration (connect with profpga_ctrl)
    mmi64_clk       : in  std_ulogic;
    mmi64_reset     : in  std_ulogic;
    cfg_dn_i        : in  std_ulogic_vector(19 downto 0);
    cfg_up_o        : out std_ulogic_vector(19 downto 0);

    -- ACM status
    locked_o        : out std_ulogic;

    -- ACM clock outputs: acm_clk(0) is the primary 1:1 clock output,
    --                    acm_clk(ACM_CLOCS...1) are derived clocks
    acm_clk_o       : out std_ulogic_vector(ACM_CLOCKS downto 0);
    acm_event_id_o  : out sync_event_vector(ACM_CLOCKS downto 0);
    acm_event_en_o  : out std_ulogic_vector(ACM_CLOCKS downto 0);
    acm_reset_o     : out std_ulogic_vector(ACM_CLOCKS downto 0);
    acm_strobe1_o   : out std_ulogic_vector(ACM_CLOCKS downto 0);
    acm_strobe2_o   : out std_ulogic_vector(ACM_CLOCKS downto 0);

    --local clock outputs (not synchronized with other FPGAs)
    local_clk_o     : out std_ulogic_vector(4 downto 0)
  );
end entity profpga_acm;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.profpga_pkg.all;

architecture rtl_7series of profpga_acm is
  -- bit index definitions for clkX_cfg vector
  --    downstream
  constant IDX_DN_DATA_LO       : integer := 0;   -- clkX_cfg_dn_o[15:0]  cfg_wdata
  constant IDX_DN_DATA_HI       : integer := 15;
  constant IDX_DN_ADDR_LO       : integer := 16;  -- clkX_cfg_dn_o[17:16] cfg_addr
  constant IDX_DN_ADDR_HI       : integer := 17;
  constant IDX_DN_EN            : integer := 18;  -- clkX_cfg_dn_o[18]    cfg_en
  constant IDX_DN_WE            : integer := 19;  -- clkX_cfg_dn_o[19]    cfg_we
  --    upstream
  constant IDX_UP_DATA_LO       : integer := 0;   -- clkX_cfg_up_i[15:0]  cfg_rdata
  constant IDX_UP_DATA_HI       : integer := 15;
  constant IDX_UP_ACCEPT        : integer := 16;  -- clkX_cfg_up_i[16]    cfg_accept
  constant IDX_UP_RVALID        : integer := 17;  -- clkX_cfg_up_i[17]    cfg_rvalid
  constant IDX_UP_IS_ACM        : integer := 18;  -- clkX_cfg_up_i[18]    is_acm (1=profpga_acm, 0=profpga_clocksync)
  constant IDX_UP_PRESENT       : integer := 19;  -- clkX_cfg_up_i[19]    present (1=yes, 0=port unused)


  constant EVENT_ID_ACMSYNC   : std_ulogic_vector(7 downto 0) := x"01";
  constant EVENT_ID_RESET_0   : std_ulogic_vector(7 downto 0) := x"02";
  constant EVENT_ID_RESET_1   : std_ulogic_vector(7 downto 0) := x"03";
  constant EVENT_ID_STROBE1_0 : std_ulogic_vector(7 downto 0) := x"04";
  constant EVENT_ID_STROBE1_1 : std_ulogic_vector(7 downto 0) := x"05";
  constant EVENT_ID_STROBE2_0 : std_ulogic_vector(7 downto 0) := x"06";
  constant EVENT_ID_STROBE2_1 : std_ulogic_vector(7 downto 0) := x"07";
  constant ACM_DIVIDE_W       : integer := 16;

  component profpga_acm_mmcm is
    port (
      -- clock from pad
      clk             : in  std_ulogic;
      rst             : in  std_ulogic;

      -- MMCM outputs
      locked_o        : out std_ulogic;
      mult_clk_o      : out std_ulogic;
      base_clk_o      : out std_ulogic;
      local_clk_o     : out std_ulogic_vector(4 downto 0);

      -- register configuration interface
      mmi64_clk       : in  std_ulogic;
      mmi64_reset     : in  std_ulogic;
      cfg_addr_i      : in  std_ulogic_vector(9 downto 0);
      cfg_read_i      : in  std_ulogic;
      cfg_write_i     : in  std_ulogic;
      cfg_wmask_i     : in  std_ulogic_vector(15 downto 0);
      cfg_wdata_i     : in  std_ulogic_vector(15 downto 0);
      cfg_accept_o    : out std_ulogic;
      cfg_rdata_o     : out std_ulogic_vector(15 downto 0);
      cfg_rvalid_o    : out std_ulogic
    );
  end component profpga_acm_mmcm;

  component profpga_acm_clkdiv is
    generic (
      DIVIDE_W  : integer
    );
    port (
      clkin     : in  std_ulogic;
      reset     : in  std_ulogic;
      divide    : in  std_ulogic_vector(DIVIDE_W-1 downto 0);
      phase     : in  std_ulogic_vector(DIVIDE_W-1 downto 0);
      sync      : in  std_ulogic;
      clkfall   : out std_ulogic;
      clkout    : out std_ulogic
    );
  end component profpga_acm_clkdiv;

  signal clkin            : std_ulogic;
  signal clkin_pad        : std_ulogic;

  -- configuration registers
  type cfg_cmd_t is (
    CFG_IDLE,
    CFG_WRITE,    -- perform WRITE operation to ACM_MMCM
    CFG_READCMD,  -- send READ command to ACM_MMCM
    CFG_READING   -- wait for READ data from ACM_MMCM
  );
  signal cfg_addr_r         : std_ulogic_vector(15 downto 0);
  signal cfg_mask_r         : std_ulogic_vector(15 downto 0);
  signal cfg_wdata_r        : std_ulogic_vector(15 downto 0);
  signal cfg_rdata_r        : std_ulogic_vector(15 downto 0);
  signal cfg_rvalid_r       : std_ulogic;
  signal cfg_cmd_r          : cfg_cmd_t;

  -- ACM MMCM reset logic
  signal acm_mmcm_locked    : std_ulogic;
  signal acm_mmcm_locked_r  : std_ulogic := '0';                                -- initial value: reset after loading bitfile
  signal acm_mmcm_rst_r     : std_ulogic_vector(15 downto 0) := (others=>'1');  -- initial value: reset after loading bitfile
  signal acm_mmcm_base_clk  : std_ulogic;
  signal acm_mmcm_cfg_read  : std_ulogic;
  signal acm_mmcm_cfg_write : std_ulogic;
  signal acm_mmcm_cfg_accept: std_ulogic;
  signal acm_mmcm_cfg_rdata : std_ulogic_vector(15 downto 0);
  signal acm_mmcm_cfg_rvalid: std_Ulogic;

  signal acm_mmcm_event_id  : std_ulogic_vector(7 downto 0);
  signal acm_mmcm_event_en  : std_ulogic;

  signal mult_clk           : std_ulogic;

  signal acm_clkfall        : std_ulogic_vector(ACM_CLOCKS      downto 1);
  signal acm_clk            : std_ulogic_vector(ACM_CLOCKS      downto 0);
  signal acm_event_id_r     : std_ulogic_vector(ACM_CLOCKS*8+7  downto 0);
  signal acm_event_en_r     : std_ulogic_vector(ACM_CLOCKS      downto 0);

  signal sync_reset         : std_ulogic;

  -- configuration registers (mmi64_clk domain)
  signal sync_delay_r       : std_ulogic_vector(5 downto 0)  := (others=>'0');
  signal acm_phase_r        : std_ulogic_vector(ACM_DIVIDE_W*ACM_CLOCKS-1 downto 0) := (others=>'0');
  signal acm_divide_r       : std_ulogic_vector(ACM_DIVIDE_W*ACM_CLOCKS-1 downto 0) := (others=>'0');

  -- ACM control signals (mult_clk domain)
  signal acm_event_id_rM    : std_ulogic_vector(7  downto 0);
  signal acm_event_en_rM    : std_ulogic;
  signal acm_event_en_r2M   : std_ulogic;
  signal acm_sync_rM        : std_ulogic;
  -- pass SYNC events over to other clock domains
  signal acm_event_wait_rM  : std_ulogic_vector(ACM_CLOCKS downto 0);
  signal acm_event_sched_rM : std_ulogic_vector(ACM_CLOCKS downto 0);
  signal acm_event_id_r2M   : std_ulogic_vector(7 downto 0);

  signal acm_reset_rM       : std_ulogic_vector(ACM_CLOCKS downto 0) := (others=>'1');
  signal acm_strobe1_rM     : std_ulogic_vector(ACM_CLOCKS downto 0) := (others=>'0');
  signal acm_strobe2_rM     : std_ulogic_vector(ACM_CLOCKS downto 0) := (others=>'0');
  
begin

  CLKINPAD : IBUFGDS
  generic map (
    DIFF_TERM => true,
    IBUF_LOW_PWR => false
   )
   port map (
     i=>clk_p,
     ib=>clk_n,
     o=>clkin_pad
   );
   
   CLKINBUF : BUFG port map (i=>clkin_pad, o=> clkin);

  -- maintain previous states to detect loss of lock
  acm_mmcm_locked_r <= acm_mmcm_locked when rising_edge(clkin);
  -- reset MMCMs on loss of lock

  p_acm_mmcm_rst: process (acm_mmcm_locked, acm_mmcm_locked_r, clkin)
  begin
    if acm_mmcm_locked='0' and acm_mmcm_locked_r='1' then
      acm_mmcm_rst_r <= (others=>'1');
    elsif rising_edge(clkin) then
      acm_mmcm_rst_r <= '0' & acm_mmcm_rst_r(acm_mmcm_rst_r'high downto 1);
    end if;
  end process p_acm_mmcm_rst;

  cfg_up_o(IDX_UP_DATA_HI downto IDX_UP_DATA_LO) <= cfg_rdata_r when cfg_rvalid_r='1' else acm_mmcm_cfg_rdata;
  cfg_up_o(IDX_UP_RVALID) <= cfg_rvalid_r or acm_mmcm_cfg_rvalid;
  cfg_up_o(IDX_UP_ACCEPT) <= '1' when cfg_cmd_r=CFG_IDLE else '0';
  cfg_up_o(IDX_UP_IS_ACM) <= '1';
  cfg_up_o(IDX_UP_PRESENT) <= '1';

  acm_event_en_o <= acm_event_en_r;
  
  REMAP_ACM_EVENTS : process(acm_event_id_r)
  begin
    for i in 0 to ACM_CLOCKS loop
      acm_event_id_o(i) <= acm_event_id_r(8*i+7 downto 8*i);
    end loop;
  end process REMAP_ACM_EVENTS;

  ACM_MMCM : profpga_acm_mmcm
  port map (
    -- clock from pad
    clk             => clkin_pad,
    rst             => acm_mmcm_rst_r(0),

    -- MMCM outputs
    locked_o        => acm_mmcm_locked,
    mult_clk_o      => mult_clk,
    base_clk_o      => acm_mmcm_base_clk,
    local_clk_o     => local_clk_o,

    -- register configuration interface
    mmi64_clk       => mmi64_clk,
    mmi64_reset     => mmi64_reset,
    cfg_addr_i      => cfg_addr_r(9 downto 0),
    cfg_read_i      => acm_mmcm_cfg_read,
    cfg_write_i     => acm_mmcm_cfg_write,
    cfg_wmask_i     => cfg_mask_r,
    cfg_wdata_i     => cfg_wdata_r,
    cfg_accept_o    => acm_mmcm_cfg_accept,
    cfg_rdata_o     => acm_mmcm_cfg_rdata,
    cfg_rvalid_o    => acm_mmcm_cfg_rvalid
  );

  acm_mmcm_cfg_read <= '1' when cfg_cmd_r=CFG_READCMD else '0';
  acm_mmcm_cfg_write <= '1' when cfg_cmd_r=CFG_WRITE else '0';



  -- sample SYNC events with 1:1 base clock from MMCM
  sync_reset <= not acm_mmcm_locked; -- reset while MMCM hasn't locked yet
  SYNCRX : profpga_sync_rx2
  generic map (
    CLK_CORE_COMPENSATION => "ZHOLD"
  ) port map (
    clk_pad       => clkin,
    clk_core      => acm_clk(0),
    rst           => sync_reset,
    sync_p_i      => sync_p,
    sync_n_i      => sync_n,
    sync_delay_i  => sync_delay_r,
    event_id_o    => acm_mmcm_event_id,
    event_en_o    => acm_mmcm_event_en
  );

  locked_o <= acm_mmcm_locked;

  CLK_0_BUFG : BUFG port map (i=>acm_mmcm_base_clk, o=> acm_clk(0));

  acm_clk_o <= acm_clk;
  -- sample EVENT with actual output clock
  acm_event_id_r(7 downto 0) <= acm_mmcm_event_id when rising_edge(acm_clk(0));
  acm_event_en_r(0) <= '0' when acm_mmcm_locked='0' else acm_mmcm_event_en when rising_edge(acm_clk(0));

  ACM_GEN : for i in 1 to ACM_CLOCKS generate -- Note: This range will be empty for ACM_CLOCKS=0.
    ACM_CLKDIV : profpga_acm_clkdiv
    generic map (
      DIVIDE_W => ACM_DIVIDE_W-1  -- using MSB as reset
    ) port map (
      clkin     => mult_clk,
      reset     => acm_divide_r(ACM_DIVIDE_W*i-1),    -- using MSB as reset
      divide    => acm_divide_r(ACM_DIVIDE_W*i-2 downto ACM_DIVIDE_W*(i-1)),
      phase     => acm_phase_r (ACM_DIVIDE_W*i-2 downto ACM_DIVIDE_W*(i-1)),
      sync      => acm_sync_rM,
      clkfall   => acm_clkfall(i), -- data strobe during falling clock edge
      clkout    => acm_clk(i)       -- clock (through BUFG)
    );

    acm_event_id_r(8*i+7 downto 8*i) <= acm_event_id_r2M when rising_edge(acm_clk(i));
    acm_event_en_r(i)                <= '0' when acm_mmcm_locked='0' else acm_event_sched_rM(i) when rising_edge(acm_clk(i));
  end generate;
  
  
  ACM_DECODE_GEN : for i in 0 to ACM_CLOCKS generate -- Note: This range will be empty for ACM_CLOCKS=0.
    EVENT_DECODE_FF : process(acm_clk(i))
    variable e : std_ulogic_vector(7 downto 0);
    begin
      if acm_mmcm_locked='0' then
        acm_reset_rM(i)   <= '1';
        acm_strobe1_rM(i) <= '0';
        acm_strobe2_rM(i) <= '0';
      elsif rising_edge(acm_clk(i)) then
        if acm_event_en_r(i)='1' then
          e := acm_event_id_r(8*i+7 downto 8*i);
          case e is
          when EVENT_ID_RESET_0   => acm_reset_rM(i)   <= '0';
          when EVENT_ID_RESET_1   => acm_reset_rM(i)   <= '1';
          when EVENT_ID_STROBE1_0 => acm_strobe1_rM(i) <= '0';
          when EVENT_ID_STROBE1_1 => acm_strobe1_rM(i) <= '1';
          when EVENT_ID_STROBE2_0 => acm_strobe2_rM(i) <= '0';
          when EVENT_ID_STROBE2_1 => acm_strobe2_rM(i) <= '1';
          when others => null;
          end case;
        end if;
      end if;
    end process EVENT_DECODE_FF;
  end generate;


  MULT_FF : process(mult_clk)
  begin
    if rising_edge(mult_clk) then
      -- sample event into mult_clk domain
      acm_event_en_rM <= acm_mmcm_event_en;
      acm_event_en_r2M <= acm_event_en_rM; -- 2nd register is for edge detection

      acm_event_id_rM <= acm_mmcm_event_id;
      if acm_event_en_rM='1' and acm_event_en_r2M='0' then
        acm_event_id_r2M <= acm_event_id_rM; -- store most recent event
      end if;

      -- trigger SYNC for ACM clocks

      -- Note: It's o.k. that acm_sync_r is high for multiple cycles.
      if acm_event_id_rM=EVENT_ID_ACMSYNC and acm_event_en_rM='1' then
        acm_sync_rM <= '1'; -- process ACMSYNC event
      else
        acm_sync_rM <= '0';
      end if;


      -- propagate existing events to target clock domain
      for i in 1 to ACM_CLOCKS loop
        if acm_clkfall(i)='1' then
          acm_event_sched_rM(i) <= acm_event_wait_rM(i);
          acm_event_wait_rM(i) <= '0';
        end if;
      end loop;

      -- schedule new events to clock domain
      if acm_event_id_rM/=EVENT_ID_ACMSYNC and acm_event_en_rM='1' and acm_event_en_r2M='0' then
        acm_event_wait_rM <= (others=>'1');
      end if;

    end if;
  end process MULT_FF;


  CFG_FF : process(mmi64_clk)
  constant REGID_MMCM_ADDR  : std_ulogic_vector(1 downto 0) := "00";
  constant REGID_MMCM_MASK  : std_ulogic_vector(1 downto 0) := "01";
  constant REGID_MMCM_DATA  : std_ulogic_vector(1 downto 0) := "10";
  constant REGID_SYNC_DELAY : std_ulogic_vector(1 downto 0) := "11";
  variable rdata_v : std_ulogic_vector(15 downto 0);
  begin
    if rising_edge(mmi64_clk) then
      cfg_rvalid_r <= '0';
      rdata_v := (others=>'0');
      if cfg_cmd_r=CFG_IDLE and cfg_dn_i(IDX_DN_EN)='1' then

        -- SYNC delay register
        if cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)=REGID_SYNC_DELAY then
          if cfg_dn_i(IDX_DN_WE)='1' then
            sync_delay_r <= cfg_dn_i(IDX_DN_DATA_LO+sync_delay_r'high downto IDX_DN_DATA_LO);
          else
            rdata_v(sync_delay_r'range) := rdata_v(sync_delay_r'range) or sync_delay_r;
            cfg_rvalid_r <= '1';
          end if;
        end if;

        -- MMCM address register
        if cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)=REGID_MMCM_ADDR then
          if cfg_dn_i(IDX_DN_WE)='1' then
            cfg_addr_r <= cfg_dn_i(IDX_DN_DATA_HI downto IDX_DN_DATA_LO);
          else
            rdata_v := rdata_v or cfg_addr_r;
            cfg_rvalid_r <= '1';
          end if;
        end if;

        -- MMCM bit write enable mask register
        if cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)=REGID_MMCM_MASK then
          if cfg_dn_i(IDX_DN_WE)='1' then
            cfg_mask_r <= cfg_dn_i(IDX_DN_DATA_HI downto IDX_DN_DATA_LO);
          else
            rdata_v := rdata_v or cfg_mask_r;
            cfg_rvalid_r <= '1';
          end if;
        end if;

        -- configuration access
        if cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)=REGID_MMCM_DATA -- data access
        and cfg_addr_r(10)='1'                                            -- configuration register access
        then
          if cfg_addr_r(9 downto 0)="0000000000" and cfg_dn_i(IDX_DN_WE)='0' then
            rdata_v := rdata_v or std_ulogic_vector(to_unsigned(ACM_CLOCKS, 16));
            cfg_rvalid_r <= '1';
          end if;
          for i in 1 to ACM_CLOCKS loop
            -- ACM DIVIDE register
            if unsigned(cfg_addr_r(9 downto 0))=2*i then
              if cfg_dn_i(IDX_DN_WE)='1' then
                acm_divide_r(ACM_DIVIDE_W*i-1 downto ACM_DIVIDE_W*(i-1)) <= cfg_dn_i(IDX_DN_DATA_LO+ACM_DIVIDE_W-1 downto IDX_DN_DATA_LO);
              else
                rdata_v(ACM_DIVIDE_W-1 downto 0) := rdata_v(ACM_DIVIDE_W-1 downto 0) or acm_divide_r(ACM_DIVIDE_W*i-1 downto ACM_DIVIDE_W*(i-1));
                cfg_rvalid_r <= '1';
              end if;
            end if;
            -- ACM PHASE register
            if unsigned(cfg_addr_r(9 downto 0))=2*i+1 then
              if cfg_dn_i(IDX_DN_WE)='1' then
                acm_phase_r(ACM_DIVIDE_W*i-1 downto ACM_DIVIDE_W*(i-1)) <= cfg_dn_i(IDX_DN_DATA_LO+ACM_DIVIDE_W-1 downto IDX_DN_DATA_LO);
              else
                rdata_v(ACM_DIVIDE_W-1 downto 0) := rdata_v(ACM_DIVIDE_W-1 downto 0) or acm_phase_r(ACM_DIVIDE_W*i-1 downto ACM_DIVIDE_W*(i-1));
                cfg_rvalid_r <= '1';
              end if;
            end if;
          end loop;
        end if;

        -- MMCM data access
        if cfg_dn_i(IDX_DN_ADDR_HI downto IDX_DN_ADDR_LO)=REGID_MMCM_DATA -- data access
        and cfg_addr_r(10)='0'                                            -- MMCM data register access
        then
          if cfg_dn_i(IDX_DN_WE)='1' then
            cfg_wdata_r <= cfg_dn_i(IDX_DN_DATA_HI downto IDX_DN_DATA_LO);
            cfg_cmd_r <= CFG_WRITE;
          else
            cfg_cmd_r <= CFG_READCMD;
          end if;
        end if;
      end if;

      cfg_rdata_r <= rdata_v;

      -- ACM MMCM operating states
      if cfg_cmd_r=CFG_WRITE and acm_mmcm_cfg_accept='1' then -- write command accepted
        cfg_cmd_r <= CFG_IDLE;
      end if;

      if cfg_cmd_r=CFG_READCMD and acm_mmcm_cfg_accept='1' then -- read command accepted
        if acm_mmcm_cfg_rvalid='1' then -- read data available
          cfg_cmd_r <= CFG_IDLE;
        else
          cfg_cmd_r <= CFG_READING; -- wait for read data
        end if;
      end if;

      if cfg_cmd_r=CFG_READING and acm_mmcm_cfg_rvalid='1' then -- read data available
        cfg_cmd_r <= CFG_IDLE;
      end if;

      -- reset
      if mmi64_reset='1' then
        cfg_cmd_r    <= CFG_IDLE;
        sync_delay_r <= (others=>'0');
        acm_divide_r <= (others=>'1');  -- minimum output frequency
      end if;
    end if;
  end process CFG_FF;

  acm_reset_o   <= acm_reset_rM;
  acm_strobe1_o <= acm_strobe1_rM;
  acm_strobe2_o <= acm_strobe2_rM;

end architecture rtl_7series;


library ieee;
use ieee.std_logic_1164.all;

entity profpga_acm_mmcm is
  port (
    -- clock from pad
    clk             : in  std_ulogic;
    rst             : in  std_ulogic;

    -- MMCM outputs
    locked_o        : out std_ulogic;
    mult_clk_o      : out std_ulogic;
    base_clk_o      : out std_ulogic;
    local_clk_o     : out std_ulogic_vector(4 downto 0);

    -- register configuration interface
    mmi64_clk       : in  std_ulogic;
    mmi64_reset     : in  std_ulogic;
    cfg_addr_i      : in  std_ulogic_vector(9 downto 0);
    cfg_read_i      : in  std_ulogic;
    cfg_write_i     : in  std_ulogic;
    cfg_wmask_i     : in  std_ulogic_vector(15 downto 0);
    cfg_wdata_i     : in  std_ulogic_vector(15 downto 0);
    cfg_accept_o    : out std_ulogic;
    cfg_rdata_o     : out std_ulogic_vector(15 downto 0);
    cfg_rvalid_o    : out std_ulogic
  );
end entity profpga_acm_mmcm;





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library unisim;
use unisim.vcomponents.all;
architecture rtl_7series of profpga_acm_mmcm is
  -- calculate default MMCM settings (required for automatic detection of synthesis constraints)
  constant CLKIN_PERIOD_NS  : real := 1000.0/300.0; -- 300 MHz (definitely overconstrained)
  constant MMCM_VCOFREQ_MHZ : real := 1200.0;       -- conservative, for speedgrade -1 to -3
  constant MULTIPLY         : integer := 4;

  signal mmcm_rst         : std_ulogic;
  signal mmcm_fbout       : std_ulogic;
  signal mmcm_fbin        : std_ulogic;
  signal mmcm_clkin_off   : std_ulogic;
  signal mmcm_locked      : std_ulogic;

  signal cfg_reset_r      : std_ulogic;
  signal cfg_read_r       : std_ulogic;
  signal cfg_bitwrite_r   : std_ulogic;
  signal cfg_daddr_r      : std_logic_vector(6 downto 0);
  signal cfg_wmask_r      : std_ulogic_vector(15 downto 0);
  signal cfg_wdata_r      : std_logic_vector(15 downto 0);
  signal cfg_rdata_r      : std_ulogic_vector(15 downto 0);
  signal cfg_rvalid_r     : std_ulogic;
  signal cfg_dwe_r        : std_ulogic;
  signal cfg_den_r        : std_ulogic;
  signal cfg_do           : std_logic_vector(15 downto 0);
  signal cfg_drdy         : std_ulogic;
  signal cfg_busy_r       : std_ulogic;

begin

  assert MULTIPLY mod 2 = 0
  report "CRITICAL: MULTIPLY must be an even value! profpga_acm will not work properly. Please change CLKIN_PERIOD_NS into a multiple of 2 ns."
  severity FAILURE;
  
  mmcm_rst <= rst or cfg_reset_r;

  -- create the MMCM
  --  clkout0 is the internal multiplied clock of the VCO
  --  clkout1 is phase synchronous to clk_pad
  --  clkout[2:6] are available to the user
  MMCM_inst : MMCME2_ADV
  generic map (
    BANDWIDTH         => "OPTIMIZED",
    CLKFBOUT_MULT_F   => real(MULTIPLY),
    CLKIN1_PERIOD     => CLKIN_PERIOD_NS,
    CLKOUT0_DIVIDE_F  => 2.0,       -- intermediate frequency: 500 MHz
    CLKOUT1_DIVIDE    => MULTIPLY,
    CLKOUT2_DIVIDE    => MULTIPLY,
    CLKOUT3_DIVIDE    => MULTIPLY,
    CLKOUT4_DIVIDE    => MULTIPLY,
    CLKOUT5_DIVIDE    => MULTIPLY,
    CLKOUT6_DIVIDE    => MULTIPLY,
    -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT2_DUTY_CYCLE => 0.5,
    CLKOUT3_DUTY_CYCLE => 0.5,
    CLKOUT4_DUTY_CYCLE => 0.5,
    CLKOUT5_DUTY_CYCLE => 0.5,
    CLKOUT6_DUTY_CYCLE => 0.5,
    -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
    CLKOUT0_PHASE     => 0.0,
    CLKOUT1_PHASE     => 0.0,
    CLKOUT2_PHASE     => 0.0,
    CLKOUT3_PHASE     => 0.0,
    CLKOUT4_PHASE     => 0.0,
    CLKOUT5_PHASE     => 0.0,
    CLKOUT6_PHASE     => 0.0,
    COMPENSATION      => "ZHOLD",
    DIVCLK_DIVIDE     => 1
  ) port map (
    -- synthetic clock outputs
    clkout0       => mult_clk_o,
    clkout1       => base_clk_o,
    clkout2       => local_clk_o(0),
    clkout3       => local_clk_o(1),
    clkout4       => local_clk_o(2),
    clkout5       => local_clk_o(3),
    clkout6       => local_clk_o(4),

    -- Dynamic Reconfiguration Port
    dclk          => mmi64_clk,
    daddr         => cfg_daddr_r,
    den           => cfg_den_r,
    di            => cfg_wdata_r,
    dwe           => cfg_dwe_r,
    drdy          => cfg_drdy,
    do            => cfg_do,

    -- Phase Shift port
    psclk         => mmi64_clk,
    psen          => '0',
    psincdec      => '0',

    -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
    clkfbout      => mmcm_fbout,
    clkfbin       => mmcm_fbin,
    clkinstopped  => mmcm_clkin_off,
    locked        => mmcm_locked,

    -- Clock Inputs: 1-bit (each) input: Clock inputs
    clkin1        => clk,
    clkin2        => '0',
    clkinsel      => '1',

    -- Control Ports: 1-bit (each) input: MMCM control ports
    pwrdwn        => '0',
    rst           => mmcm_rst
  );
  BUFG_FB :  BUFG port map ( i=>mmcm_fbout, o=>mmcm_fbin     );
  locked_o <= mmcm_locked;

  FF : process (mmi64_clk)
  variable rdata : std_ulogic_vector(15 downto 0);
  begin
    if rising_edge(mmi64_clk) then

      -- write and read command are valid only for a single cycle
      cfg_den_r <= '0';
      cfg_dwe_r <= '0';
      rdata := (others=>'0');
      cfg_rvalid_r <= '0';

      -- accept transfer when all DRP ports are idle
      if cfg_busy_r='0'
      and (cfg_read_i='1' or cfg_write_i='1')
      then
        if cfg_addr_i(9 downto 3)="0000000" then  -- register 0 --> my MMCM control register

          -- register port
          rdata(0)  := mmcm_locked;
          rdata(15) := cfg_reset_r;
          if cfg_write_i='1' then cfg_reset_r <= cfg_wdata_i(15); end if;
          if cfg_read_i='1' then cfg_rvalid_r <= '1'; end if;
        else
          cfg_daddr_r <= std_logic_vector(cfg_addr_i(9 downto 3));
          cfg_wmask_r <= cfg_wmask_i;
          cfg_wdata_r <= std_logic_vector(cfg_wdata_i);
          cfg_den_r   <= '1';
          cfg_busy_r  <= '1';

          -- decode write operation
          cfg_bitwrite_r <= '0';
          cfg_read_r <= cfg_read_i;
          cfg_dwe_r <= '0';
          if cfg_write_i='1' then
            if cfg_wmask_i=x"FFFF" then -- write all bits
              cfg_dwe_r <= '1';    -- write immediately
            else
              cfg_bitwrite_r <= '1'; -- first read current value, write later
            end if;
          end if;
        end if;
      end if;

      -- detect when DRP operation is done
      if cfg_busy_r='1' then -- use cfg_busy_r as MUX control (better timing)
        rdata := rdata or std_ulogic_vector(cfg_do);
      end if;

      if cfg_drdy='1' and cfg_bitwrite_r='0' then
        -- validata transfer as soon as MMCM is ready
        cfg_busy_r <= '0';
      end if;
      cfg_rdata_r <= rdata;

      if cfg_bitwrite_r='1' and cfg_drdy='1' then
        -- read cycle for bit write operation complete
        for i in 0 to 15 loop
          if cfg_wmask_r(i)='0' then -- do not modify this bit, i.e. keep old value
            cfg_wdata_r(i) <= rdata(i);
          end if;
        end loop;
        -- reissue the transfer, this time write
        cfg_den_r <= cfg_busy_r;
        cfg_dwe_r <= cfg_busy_r;
        cfg_bitwrite_r <= '0';
      end if;

      if cfg_read_r='1' and cfg_drdy='1' then
        cfg_rvalid_r <= '1';
        cfg_read_r <= '0';
      end if;

      -- reset
      if mmi64_reset='1' then
        -- initial clock selector: 50 MHz

        -- clear all MMIO bits
        cfg_read_r        <= '0';
        cfg_bitwrite_r    <= '0';
        cfg_daddr_r       <= (others=>'0');
        cfg_wmask_r       <= x"0000";
        cfg_wdata_r       <= x"0000";
        cfg_rdata_r       <= x"0000";
        cfg_dwe_r         <= '0';
        cfg_den_r         <= '0';
        cfg_rvalid_r      <= '0';
        cfg_busy_r        <= '0';
        cfg_reset_r       <= '0';
      end if;
    end if;
  end process FF;

  cfg_accept_o <= not cfg_busy_r;
  cfg_rdata_o  <= cfg_rdata_r;
  cfg_rvalid_o <= cfg_rvalid_r;

end architecture rtl_7series;



library ieee;
use ieee.std_logic_1164.all;

entity profpga_acm_clkdiv is
  generic (
    DIVIDE_W  : integer
  );
  port (
    clkin     : in  std_ulogic;
    reset     : in  std_ulogic;
    divide    : in  std_ulogic_vector(DIVIDE_W-1 downto 0);
    phase     : in  std_ulogic_vector(DIVIDE_W-1 downto 0);
    sync      : in  std_ulogic;
    clkfall   : out std_ulogic;
    clkout    : out std_ulogic
  );
end entity profpga_acm_clkdiv;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

architecture rtl_7series of profpga_acm_clkdiv is
  -- signals with explicite timing constraints
  signal acm_clkout_lut : std_ulogic := '1';
  signal acm_clkout_buf : std_ulogic := '1';
  signal acm_divide_r   : unsigned(DIVIDE_W-1 downto 0) := (others=>'0');
  
  attribute KEEP : string;
  attribute keep of acm_divide_r  : signal is "TRUE";
  attribute KEEP of ACM_LUTREG    : label  is "TRUE";
  attribute KEEP of ACM_CLKBUF    : label  is "TRUE";

  -- other signals
  signal acm_clkout_r   : std_ulogic_vector(3 downto 0) := (others=>'1'); -- add pipeline registers to simplify PAR
  signal last_clkout_r  : std_Ulogic := '1';
  signal dec_en_r       : std_ulogic := '0';
  signal preload_r      : unsigned(DIVIDE_W-1 downto 0) := (others=>'0');
  signal counter_r      : unsigned(DIVIDE_W-1 downto 0) := (others=>'0');
  signal acm_reset_r    : std_ulogic := '1';
  -- counting pattern:
  --  Divider | Preload | High Seq        | Low Seq          | High Time | Low Time
  -- ---------+---------+-----------------+------------------+-----------+-----------
  --    2     |    -1   | -1              | -1               |    1      |    1
  --    3     |    -1   | -1,-1           | -1               |    2      |    1
  --    4     |     0   | 0,-1            | 0,-1             |    2      |    2
  --    5     |     0   | 0,0,-1          | 0,-1             |    3      |    2
  --    6     |     1   | 1,0,-1          | 1,0,-1           |    3      |    3
  --    7     |     1   | 1,1,0,-1        | 1,0,-1           |    4      |    3
  --  1022    |   509   | 509,508,..,0,-1 | 509,508,...,0,-1 |   511     |   511
  --  1023    |   509   | 509,509,..,0,-1 | 509,508,...,0,-1 |   512     |   511

  -- Note: clkin is already divided by 2
begin

  FF : process(clkin)
  variable minus1_v : unsigned(DIVIDE_W-1 downto 0);
  begin
    if rising_edge(clkin) then
      -- divide is expected to be pseudo-static. This register is for timing closure.
      if sync='1' then
        acm_divide_r <= unsigned(phase);
      else
        acm_divide_r <= unsigned(divide);
      end if;
      acm_reset_r <= reset;

      preload_r    <= ('0' & acm_divide_r(DIVIDE_W-1 downto 1)) - 2;

      minus1_v := (others=>dec_en_r);

      dec_en_r  <= '1'; -- default: decrement by 1

      counter_r <= counter_r + minus1_v;
      -- Limited version for timing optimization: if counter_r(9)='1' then -- signed overflow
      if counter_r(DIVIDE_W-1)='1' and dec_en_r='1' then -- signed overflow
        counter_r <= preload_r;
        acm_clkout_r(0) <= not acm_clkout_r(0);
        acm_clkout_r(acm_clkout_r'high downto 1) <= acm_clkout_r(acm_clkout_r'high-1 downto 0);

        if acm_divide_r(0)='1' and acm_clkout_r(0)='0' then -- odd divider: extend clock by 1 cycle
          dec_en_r <= '0';
        end if;
      end if;

      -- notify of falling clock edge (required for SYNC signal)
      last_clkout_r <= acm_clkout_r(0);
      if acm_clkout_r(0)='0' and last_clkout_r='1' then
        clkfall <= '1';
      else
        clkfall <= '0';
      end if;

      -- force reload on ACM sync event
      if sync='1' then -- reset counter
        counter_r(DIVIDE_W-1) <= '1'; -- this will force a counter reload
        acm_clkout_r(0)       <= '0';
        last_clkout_r         <= '0';
        dec_en_r              <= '1';
      end if;
      
      -- freeze counter during reset
      if acm_reset_r='1' then
        dec_en_r <= '0';
      end if;
    end if;
  end process FF;


  ACM_LUTREG : FDCE port map (
    d   => acm_clkout_r(acm_clkout_r'high),
    ce  => '1',
    clr => '0',
    c   => clkin,
    q   => acm_clkout_lut );

  ACM_CLKBUF : BUFG port map (
    i   => acm_clkout_lut,
    o   => acm_clkout_buf );

  clkout <= acm_clkout_buf;
  
end architecture rtl_7series;
