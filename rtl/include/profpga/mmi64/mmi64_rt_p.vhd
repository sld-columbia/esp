-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2012, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : MMI64 (Module Message Interface)
--  Module/Entity : mmi64_rt_pkg (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                 MMI64 Reliable Transmission package
-- =============================================================================

-------------
-- Entity  --
-------------

library ieee;
use ieee.std_logic_1164.all;
-- Gray to binary conversion
entity gray2binary is
  generic (
    DATA_WIDTH : integer := 8
    );
  port (
    data_i : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
    data_o : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
    );
end entity gray2binary;

-- Write pointers and flags generation
library ieee;
use ieee.std_logic_1164.all;
entity rt_wr_ptr_full is
  generic (
    ADDR_WIDTH : integer := 8
    );
  port (
    clk            : in  std_ulogic;
    reset_n        : in  std_ulogic;
    wr_addr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_addr_load_i : in  std_ulogic;
    wr_enable_i    : in  std_ulogic;
    wr_rptr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_ptr_o       : out std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_addr_o      : out std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_full_o      : out std_ulogic;
    wr_diff_o      : out std_ulogic_vector(ADDR_WIDTH downto 0)
    );
end entity rt_wr_ptr_full;

-- Read pointers and flags generation
library ieee;
use ieee.std_logic_1164.all;
entity rt_rd_ptr_empty is
  generic (
    ADDR_WIDTH               : integer := 8;
    FIRST_WORD_FALLS_THROUGH : boolean := false
    );
  port (
    clk            : in  std_ulogic;
    reset_n        : in  std_ulogic;
    rd_addr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    rd_addr_load_i : in  std_ulogic;
    rd_enable_i    : in  std_ulogic;
    rd_wptr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    enb_o          : out std_ulogic;
    rd_ptr_o       : out std_ulogic_vector(ADDR_WIDTH downto 0);
    rd_addr_o      : out std_ulogic_vector(ADDR_WIDTH downto 0);
    rd_empty_o     : out std_ulogic;
    rd_diff_o      : out std_ulogic_vector(ADDR_WIDTH downto 0)
    );
end entity rt_rd_ptr_empty;

-- Two register synchronizer
library ieee;
use ieee.std_logic_1164.all;
entity rt_synchronizer is
  generic (
    DATA_WIDTH : integer := 8
    );
  port (
    clk     : in  std_ulogic;
    reset_n : in  std_ulogic;
    data_i  : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
    data_o  : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
    );
end entity rt_synchronizer;


-----------------------
-- Component/Package  --
------------------------
library ieee;
use ieee.std_logic_1164.all;
package mmi64_rt_pkg is
  -- Gray to binary conversion
  component gray2binary is
    generic (
      DATA_WIDTH : integer := 8
      );
    port (
      data_i : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
      data_o : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
      );
  end component gray2binary;

  component rt_wr_ptr_full is
    generic (
      ADDR_WIDTH : integer := 8
      );
    port (
      clk            : in  std_ulogic;
      reset_n        : in  std_ulogic;
      wr_addr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_addr_load_i : in  std_ulogic;
      wr_enable_i    : in  std_ulogic;
      wr_rptr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_ptr_o       : out std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_addr_o      : out std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_full_o      : out std_ulogic;
      wr_diff_o      : out std_ulogic_vector(ADDR_WIDTH downto 0)
      );
  end component rt_wr_ptr_full;

  component rt_rd_ptr_empty is
    generic (
      ADDR_WIDTH               : integer := 8;
      FIRST_WORD_FALLS_THROUGH : boolean := false
      );
    port (
      clk            : in  std_ulogic;
      reset_n        : in  std_ulogic;
      rd_addr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
      rd_addr_load_i : in  std_ulogic;
      rd_enable_i    : in  std_ulogic;
      rd_wptr_i      : in  std_ulogic_vector(ADDR_WIDTH downto 0);
      enb_o          : out std_ulogic;
      rd_ptr_o       : out std_ulogic_vector(ADDR_WIDTH downto 0);
      rd_addr_o      : out std_ulogic_vector(ADDR_WIDTH downto 0);
      rd_empty_o     : out std_ulogic;
      rd_diff_o      : out std_ulogic_vector(ADDR_WIDTH downto 0)
      );
  end component rt_rd_ptr_empty;

  component rt_synchronizer is
    generic (
      DATA_WIDTH : integer := 8
      );
    port (
      clk     : in  std_ulogic;
      reset_n : in  std_ulogic;
      data_i  : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
      data_o  : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
      );
  end component rt_synchronizer;
end package mmi64_rt_pkg;

-------------------------------
-- gray2binary Architecture  --
-------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of gray2binary is
  function xor_reduce (gray_data : std_ulogic_vector) return std_ulogic is
    variable data_v : std_ulogic;
  begin
    if gray_data'length > 1 then
      data_v := gray_data(gray_data'high);
      for i in gray_data'high-1 downto gray_data'low loop
        data_v := data_v xor gray_data(i);
      end loop;
      return data_v;
    else
      return gray_data(gray_data'high);
    end if;
  end function xor_reduce;

begin
  GRAY2BINARY_COMB : process(data_i)
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
use work.mmi64_rt_pkg.all;
architecture rtl of rt_wr_ptr_full is
  signal wr_gray_next : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_bin_next  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_bin_r     : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_full      : std_ulogic;
  signal wr_full_r    : std_ulogic;
  signal wr_rptr_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_gray_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal wr_rptr_inv  : std_ulogic_vector(ADDR_WIDTH downto 0);
begin
  GENERATE_OUTPUT : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        wr_bin_r  <= (others => '0');
        wr_ptr_o  <= (others => '0');
        wr_full_r <= '0';
        wr_diff_o <= (others => '0');
      else
        if wr_addr_load_i = '1' then
          wr_bin_r <= wr_addr_i;
        else
          wr_bin_r <= wr_bin_next;
        end if;
        wr_ptr_o  <= wr_gray_next;
        wr_full_r <= wr_full;
        wr_diff_o <= std_ulogic_vector(unsigned(wr_gray_bin) - unsigned(wr_rptr_bin));
      end if;
    end if;
  end process GENERATE_OUTPUT;
  wr_full_o <= wr_full_r;

  --! Incremennt write addres pointer only when new data is available and FULL flag is inactive
  wr_bin_next <= std_ulogic_vector(unsigned(wr_bin_r) + 1) when wr_full_r /= '1' and wr_enable_i = '1' else wr_bin_r;

  wr_gray_next <= ('0' & wr_bin_next(wr_bin_next'left downto 1)) xor wr_bin_next;

  wr_rptr_inv <= not wr_rptr_i;

  wr_full <= '1' when (wr_gray_next = (wr_rptr_inv(ADDR_WIDTH downto ADDR_WIDTH-1) & wr_rptr_i(ADDR_WIDTH-2 downto 0))) else '0';

  wr_addr_o <= wr_bin_r;                --(ADDR_WIDTH-1 downto 0);

  --! Gray to binary conversion
  u_g2b_gray : gray2binary
    generic map(
      DATA_WIDTH => ADDR_WIDTH+1
      ) port map (
        data_i => wr_gray_next,
        data_o => wr_gray_bin
        );

  --! Gray to binary conversion
  u_g2b_wr_rptr : gray2binary
    generic map(
      DATA_WIDTH => ADDR_WIDTH+1
      ) port map (
        data_i => wr_rptr_i,
        data_o => wr_rptr_bin
        );

end architecture rtl;

--------------------------------
-- rd_ptr_empty Architecture  --
--------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mmi64_rt_pkg.all;
architecture rtl of rt_rd_ptr_empty is
  signal rd_gray_next : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_bin_next  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_bin_r     : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_empty     : std_ulogic;
  signal rd_empty_r   : std_ulogic;
  signal rd_wptr_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal rd_gray_bin  : std_ulogic_vector(ADDR_WIDTH downto 0);
  signal fwft_re      : std_ulogic;
  signal rd_empty_t1  : std_ulogic;
  signal rd_enable    : std_ulogic;
  signal dv_r         : std_ulogic := '0';

begin
  GENERATE_OUTPUT : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        rd_bin_r    <= (others => '0');
        rd_ptr_o    <= (others => '0');
        rd_empty_r  <= '1';
        rd_empty_t1 <= '1';
        rd_diff_o   <= (others => '0');
      else
        if rd_addr_load_i = '1' then
          rd_bin_r <= rd_addr_i;
        else
          rd_bin_r <= rd_bin_next;
        end if;
        rd_ptr_o    <= rd_gray_next;
        rd_empty_r  <= rd_empty;
        rd_diff_o   <= std_ulogic_vector(unsigned(rd_wptr_bin) - unsigned(rd_gray_bin));
        rd_empty_t1 <= rd_empty_r;
      end if;
    end if;
  end process GENERATE_OUTPUT;


  --! Incremennt write addres pointer only when new data is available and FULL flag is inactive
  rd_bin_next <= std_ulogic_vector(unsigned(rd_bin_r) + 1) when rd_empty_r /= '1' and rd_enable = '1' else rd_bin_r;
  enb_o       <= rd_enable                                 when rd_empty_r /= '1'                     else '0';
  rd_addr_o   <= rd_bin_r;              --(ADDR_WIDTH-1 downto 0);


  -- SF: changed description to eliminate VSIM warning
  rd_enable <= rd_enable_i when FIRST_WORD_FALLS_THROUGH = false
               else (not rd_empty_r) and ((not dv_r) or rd_enable_i);
  rd_empty_o <= rd_empty_r when FIRST_WORD_FALLS_THROUGH = false
                else not dv_r;


  FWFT_BEH : if FIRST_WORD_FALLS_THROUGH = true generate
    FWFT_FF : process(clk)
    begin
      if rising_edge(clk) then
        if reset_n = '0' then
          dv_r <= '0';
        else
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
  rd_empty     <= '1' when (rd_gray_next = rd_wptr_i) else '0';

  --! Gray to binary conversion
  u_g2b_gray : gray2binary
    generic map(
      DATA_WIDTH => ADDR_WIDTH+1
      ) port map (
        data_i => rd_gray_next,
        data_o => rd_gray_bin
        );

  --! Gray to binary conversion
  u_g2b_rd_rptr : gray2binary
    generic map(
      DATA_WIDTH => ADDR_WIDTH+1
      ) port map (
        data_i => rd_wptr_i,
        data_o => rd_wptr_bin
        );

end architecture rtl;

--------------------------------
-- synchronizer Architecture  --
--------------------------------
architecture rtl of rt_synchronizer is
  signal data_meta_r : std_ulogic_vector(DATA_WIDTH-1 downto 0);
begin
  SYNCHRONIZE_FF : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = '0' then
        -- Initialize all signals
        data_meta_r <= (others => '0');
        data_o      <= (others => '0');
      else
        data_meta_r <= data_i;
        data_o      <= data_meta_r;
      end if;
    end if;
  end process SYNCHRONIZE_FF;
end architecture rtl;
