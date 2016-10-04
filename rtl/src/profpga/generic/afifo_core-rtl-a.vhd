-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2011, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : Braehler ICS (International Congress Service)
--  Module/Entity : afifo_core, gray2binary, wr_ptr_full, rd_ptr_empty, sync (Architecture)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Core for dual clock FIFO (and submodules used)
--                  Implementation based on
--                  "Simulation and Synthesis Techniques for Asynchronous FIFO Design" by Clifford E. Cummings
-- =============================================================================

-------------------------------
-- gray2binary Architecture  --
-------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

architecture rtl of gray2binary is
  function xor_reduce (gray_data : std_ulogic_vector ) return std_ulogic is
    variable data_v : std_ulogic;
  begin
    if gray_data'length > 1 then
      data_v := gray_data(gray_data'high);
      for i in gray_data'high-1 downto  gray_data'low loop
        data_v:= data_v xor gray_data(i);
      end loop;
      return data_v;
    else
      return gray_data(gray_data'high);
    end if;
  end function xor_reduce;

begin
  GRAY2BINARY_COMB: process(data_i)
    variable data_v : std_ulogic_vector(DATA_WIDTH-1 downto 0);
  begin
    for i in 0 to DATA_WIDTH-1 loop
      data_v(i) := xor_reduce(data_i(DATA_WIDTH-1 downto i));
    end loop;
    data_o <= data_v;
  end process GRAY2BINARY_COMB;

end architecture rtl;

-------------------------------
-- wr_ptr_full Architecture  --
-------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library work;
  use work.afifo_core_pkg.all;
architecture rtl of wr_ptr_full is
  signal wr_gray_next : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_bin_next  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_bin_r     : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_full      : std_ulogic;
  signal wr_full_r    : std_ulogic;
  signal wr_rptr_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_gray_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_rptr_inv  : std_ulogic_vector(ADDR_WIDTH downto 0);
begin
  GENERATE_OUTPUT:process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        wr_bin_r  <= (others=>'0');
        wr_ptr_o  <= (others=>'0');
        wr_full_r <= '0';
        wr_diff_o <= (others=>'0');
      else
        wr_bin_r  <= wr_bin_next;
        wr_ptr_o  <= wr_gray_next;
        wr_full_r <= wr_full;
        wr_diff_o <= std_ulogic_vector(unsigned(wr_bin_next) - unsigned(wr_rptr_bin));
      end if;
    end if;
  end process GENERATE_OUTPUT;
  wr_full_o <= wr_full_r;

  --! Incremennt write addres pointer only when new data is available and FULL flag is inactive
  wr_bin_next <= std_ulogic_vector(unsigned(wr_bin_r) + 1) when wr_full_r /= '1' and wr_enable_i = '1' else wr_bin_r;

  wr_gray_next <= ('0' & wr_bin_next(wr_bin_next'left downto 1)) xor wr_bin_next;

  wr_rptr_inv <=  not wr_rptr_i;

  wr_full <= '1' when ( wr_gray_next = (wr_rptr_inv(ADDR_WIDTH downto ADDR_WIDTH-1) &  wr_rptr_i(ADDR_WIDTH-2 downto 0))) else '0';

  wr_addr_o <= wr_bin_r(ADDR_WIDTH-1 downto 0);

  --! Gray to binary conversion
  u_g2b_gray : gray2binary
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    data_i   => wr_gray_next,
    data_o   => wr_gray_bin
  );

  --! Gray to binary conversion
  u_g2b_wr_rptr : gray2binary
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    data_i   => wr_rptr_i,
    data_o   => wr_rptr_bin
  );

end architecture rtl;

--------------------------------
-- rd_ptr_empty Architecture  --
--------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library work;
  use work.afifo_core_pkg.all;
architecture rtl of rd_ptr_empty is
  signal rd_gray_next      : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_bin_next       : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_bin_r          : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_empty          : std_ulogic;
  signal rd_empty_r        : std_ulogic;
  signal rd_wptr_bin       : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_gray_bin       : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal fwft_re           : std_ulogic;
  signal rd_empty_t1       : std_ulogic;
  signal rd_enable         : std_ulogic;
  signal dv_r              : std_ulogic := '0';

  signal rd_wptr_r         : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_diff_plain_r   : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_diff_fwft_r    : std_ulogic_vector(ADDR_WIDTH downto 0);
  
begin
  rd_diff_o <= rd_diff_fwft_r when FIRST_WORD_FALLS_THROUGH else rd_diff_plain_r;

  GENERATE_OUTPUT:process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        rd_bin_r      <= (others=>'0');
        rd_ptr_o      <= (others=>'0');
        rd_empty_r    <= '1';
        rd_empty_t1 <= '1';
        rd_diff_plain_r <= (others=>'0');
      else
        rd_bin_r      <= rd_bin_next;
        rd_ptr_o      <= rd_gray_next;
        rd_empty_r    <= rd_empty;
        rd_diff_plain_r <= std_ulogic_vector(unsigned(rd_wptr_bin) - unsigned(rd_gray_bin));
        rd_empty_t1 <= rd_empty_r;
      end if;
    end if;
  end process GENERATE_OUTPUT;

  --! Incremennt write addres pointer only when new data is available and FULL flag is inactive
  rd_bin_next <= std_ulogic_vector(unsigned(rd_bin_r) + 1) when rd_empty_r /= '1' and rd_enable = '1' else rd_bin_r;
  enb_o <= rd_enable when rd_empty_r /= '1' else '0';
  rd_addr_o <= rd_bin_r(ADDR_WIDTH-1 downto 0);

  -- SF: changed description to eliminate VSIM warning
  rd_enable <= rd_enable_i when FIRST_WORD_FALLS_THROUGH = false
            else (not rd_empty_r) and ((not dv_r) or rd_enable_i);
  rd_empty_o <= rd_empty_r when FIRST_WORD_FALLS_THROUGH = false
            else not dv_r;

  FWFT_BEH: if FIRST_WORD_FALLS_THROUGH = true generate
    FWFT_FF : process(clk)
    variable count_output_v : unsigned(ADDR_WIDTH downto 0);
    begin
      if rising_edge(clk) then
        if reset_n = '0' then
          dv_r            <= '0';
          rd_diff_fwft_r  <= (others=>'0');
          rd_wptr_r       <= (others=>'0');
        else
          rd_wptr_r <= rd_wptr_bin;
          
          count_output_v := (others=>'0');
          count_output_v(0) := dv_r and not rd_enable_i;
          rd_diff_fwft_r <= std_ulogic_vector(unsigned(rd_wptr_r) - unsigned(rd_bin_r)
                            + count_output_v); -- count the word in output buffer too
          if rd_enable = '1' then
            dv_r <= '1';
          elsif rd_enable_i = '1' then
            dv_r <= '0';
          end if;
        end if;
      end if;
    end process FWFT_FF;

  end generate FWFT_BEH;

  rd_gray_next <= ('0' & rd_bin_next(rd_bin_next'left downto 1)) xor rd_bin_next;
  rd_empty <= '1' when (rd_gray_next = rd_wptr_i) else '0';

  --! Gray to binary conversion
  u_g2b_gray : gray2binary
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    data_i   => rd_gray_next,
    data_o   => rd_gray_bin
  );

  --! Gray to binary conversion
  u_g2b_rd_rptr : gray2binary
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    data_i   => rd_wptr_i,
    data_o   => rd_wptr_bin
  );

end architecture rtl;

--------------------------------
-- synchronizer Architecture  --
--------------------------------
architecture rtl of synchronizer is
  signal data_meta_r :std_ulogic_vector(DATA_WIDTH-1 downto 0);
begin
  SYNCHRONIZE_FF:process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        data_meta_r <= (others=>'0');
        data_o      <= (others=>'0');
      else
        data_meta_r <= data_i;
        data_o      <= data_meta_r;
      end if;
    end if;
  end process SYNCHRONIZE_FF;
end architecture rtl;

--------------------------------
-- afifo_core Architecture    --
--------------------------------
library ieee;
  use ieee.std_logic_1164.all;
library work;
  use work.afifo_core_pkg.all;
architecture rtl of afifo_core is
  signal r2w_sync_ptr   : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal w2r_sync_ptr   : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_rptr        : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_wptr        : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal full           : std_ulogic;
  signal empty          : std_ulogic;
  signal w2r_reset_n_r  : std_Ulogic_vector(1 downto 0);
  signal r2w_reset_n_r  : std_Ulogic_vector(1 downto 0);
  signal wr_reset_int_n : std_Ulogic;
  signal rd_reset_int_n : std_Ulogic;
begin
  wr_full_o  <= full;
  rd_empty_o <= empty;

  wea_o <= wr_enable_i when full /= '1' else '0';

  dataa_o <= wr_data_i;
  rd_data_o <= datab_i;

  ------------------------------------------
  --synchronize resets with other side of the fifo
  ------------------------------------------
  RD_RESET_SYNC_FF : process (wr_clk)
  begin
    if rising_edge(wr_clk) then
      if rd_reset_n='0' then
        r2w_reset_n_r <= "00";
      else
        r2w_reset_n_r(0) <= r2w_reset_n_r(1);
        r2w_reset_n_r(1) <= '1';
      end if;
    end if;
  end process;
  
  WR_RESET_SYNC_FF : process (rd_clk)
  begin
    if rising_edge(rd_clk) then
      if wr_reset_n='0' then
        w2r_reset_n_r <= "00";
      else
        w2r_reset_n_r(0) <= w2r_reset_n_r(1);
        w2r_reset_n_r(1) <= '1';
      end if;
    end if;
  end process;

  wr_reset_int_n <= wr_reset_n and r2w_reset_n_r(0);
  rd_reset_int_n <= rd_reset_n and w2r_reset_n_r(0);
  
  -- Generate write flags and address
  u_wr_ptr_full : wr_ptr_full
  generic map(
    ADDR_WIDTH => ADDR_WIDTH
  ) port map (
    clk         => wr_clk,
    reset_n     => wr_reset_int_n,
    wr_enable_i => wr_enable_i,
    wr_rptr_i   => wr_rptr,
    wr_ptr_o    => w2r_sync_ptr,
    wr_addr_o   => addra_o,
    wr_full_o   => full,
    wr_diff_o   => wr_diff_o
  );

  -- Generate read flags and address
  u_rd_ptr_empty : rd_ptr_empty
  generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    FIRST_WORD_FALLS_THROUGH => FIRST_WORD_FALLS_THROUGH
  ) port map (
    clk         => rd_clk,
    reset_n     => rd_reset_int_n,
    rd_enable_i => rd_enable_i,
    enb_o       => enb_o,
    rd_wptr_i   => rd_wptr,
    rd_ptr_o    => r2w_sync_ptr,
    rd_addr_o   => addrb_o,
    rd_empty_o  => empty,
    rd_diff_o   => rd_diff_o
  );

  -- Sync to write domain
  u_sync_r2w : synchronizer
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    clk     => wr_clk,
    reset_n => wr_reset_int_n,
    data_i  => r2w_sync_ptr,
    data_o  => wr_rptr
  );

  -- Sync to read domain
  u_sync_w2r : synchronizer
  generic map(
    DATA_WIDTH => ADDR_WIDTH+1
  ) port map (
    clk     => rd_clk,
    reset_n => rd_reset_int_n,
    data_i  => w2r_sync_ptr,
    data_o  => rd_wptr
  );

end architecture rtl;


-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-05-16  First draft.
-- 0.2      2011-07-01  Reset state of empty changed.
-- 0.3      2011-11-21  Added FIRST_WORD_FALLS_THROUGH option.
-- 0.4      2012-01-18  bugfix in FIRST_WORD_FALLS_THROUGH area.
-- 0.5      2012-02-08  bugfix in FIRST_WORD_FALLS_THROUGH area.
-- 1.0      2016-03-07  Async resets removed. All resets are sync now
-- =============================================================================
