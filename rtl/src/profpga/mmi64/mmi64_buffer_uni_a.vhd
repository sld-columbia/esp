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
--!  @project      Module Message Interface 64
-- =============================================================================
--!  @file         mmi64_buffer_uni_a.vhd
--!  @author       Norman Nolte, Sebastian Fluegel
--!  @email        norman.nolte@prodesign-europe.com
--!                sebastian.fluegel@prodesign-europe.com
--!  @brief        Unidirectional MMI64 buffer (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mmi64_pkg.all;

--! implementation of mmi64_buffer_uni
architecture rtl of mmi64_buffer_uni is

  -- mmi64 bus output registers
  signal mmi64_d_r     : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data
  signal mmi64_valid_r : std_ulogic;                                      --! mmi64 data valid
  signal mmi64_start_r : std_ulogic;                                      --! mmi64 data packet start
  signal mmi64_stop_r  : std_ulogic;                                      --! mmi64 data packet end

  -- mmi64 bus buffer registers
  signal mmi64_d_buf_r     : std_ulogic_vector(MMI64_DATA_WIDTH-1 downto 0);  --! mmi64 data
  signal mmi64_valid_buf_r : std_ulogic;                                      --! mmi64 data valid
  signal mmi64_start_buf_r : std_ulogic;                                      --! mmi64 data packet start
  signal mmi64_stop_buf_r  : std_ulogic;                                      --! mmi64 data packet end

begin  -- rtl

  -- assign mmi64 output bus
  mmi64_d_o     <= mmi64_d_r;
  mmi64_valid_o <= mmi64_valid_r and enable_i;
  mmi64_start_o <= mmi64_start_r;
  mmi64_stop_o  <= mmi64_stop_r;

  -- accept incoming data as long as buffer holds no valid data
  mmi64_accept_o <= not mmi64_valid_buf_r;

  --! Sequential process implementing unidirectional MMI64 buffer.
  p_buffer : process(mmi64_clk)
  begin

    -- trigger on rising clock edge
    if rising_edge(mmi64_clk) then

      -- data in buffer is invalid?
      if mmi64_valid_buf_r = '0' then
        -- fill buffer with input data
        mmi64_d_buf_r     <= mmi64_d_i;
        mmi64_valid_buf_r <= mmi64_valid_i;
        mmi64_start_buf_r <= mmi64_start_i;
        mmi64_stop_buf_r  <= mmi64_stop_i;
      end if;

      -- output register is either empty or output data is accepted
      if mmi64_valid_r = '0' or (mmi64_accept_i = '1' and enable_i = '1') then

        -- buffer contains valid data?
        if mmi64_valid_buf_r = '1' then
          -- update output register from buffer
          mmi64_d_r     <= mmi64_d_buf_r;
          mmi64_valid_r <= mmi64_valid_buf_r;
          mmi64_start_r <= mmi64_start_buf_r;
          mmi64_stop_r  <= mmi64_stop_buf_r;
        else
          -- update output register from input data
          mmi64_d_r     <= mmi64_d_i;
          mmi64_valid_r <= mmi64_valid_i;
          mmi64_start_r <= mmi64_start_i;
          mmi64_stop_r  <= mmi64_stop_i;
        end if;

        -- invalidate buffer
        mmi64_valid_buf_r <= '0';
      end if;

      -- invalidate buffer and output register while in reset
      if mmi64_reset = '1' then
        mmi64_valid_r     <= '0';
        mmi64_valid_buf_r <= '0';
      end if;

    end if;
  end process p_buffer;
end rtl;
