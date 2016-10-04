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
--!  @file         mmi64_buffer_a.vhd
--!  @author       Norman Nolte, Sebastian Fluegel
--!  @email        norman.nolte@prodesign-europe.com
--!                sebastian.fluegel@prodesign-europe.com
--!  @brief        Buffer for pipelining MMI64 bus (implementation).
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mmi64_pkg.all;
use work.mmi64_buffer_uni_comp.all;
use work.rtl_templates.all;

--! implementation of mmi64_buffer
architecture rtl of mmi64_buffer is

  signal dn_enable_counter_r : unsigned(Log2(DOWNSTREAM_BUFFER_ENABLE_HOLDOFF) downto 0);
  signal dn_enable           : std_ulogic;

  signal up_enable_counter_r : unsigned(Log2(UPSTREAM_BUFFER_ENABLE_HOLDOFF) downto 0);
  signal up_enable           : std_ulogic;


begin  -- rtl

  -- buffer for downstream direction (root to leaves)
  mmi64_buffer_uni_downstream_inst : mmi64_buffer_uni
    port map (
      mmi64_clk   => mmi64_clk,
      mmi64_reset => mmi64_reset,

      enable_i    => dn_enable,

      mmi64_d_i      => mmi64_h_dn_d_i,
      mmi64_valid_i  => mmi64_h_dn_valid_i,
      mmi64_accept_o => mmi64_h_dn_accept_o,
      mmi64_start_i  => mmi64_h_dn_start_i,
      mmi64_stop_i   => mmi64_h_dn_stop_i,

      mmi64_d_o      => mmi64_m_dn_d_o,
      mmi64_valid_o  => mmi64_m_dn_valid_o,
      mmi64_accept_i => mmi64_m_dn_accept_i,
      mmi64_start_o  => mmi64_m_dn_start_o,
      mmi64_stop_o   => mmi64_m_dn_stop_o);

  -- buffer for upstream direction (leaves to root)
  mmi64_buffer_uni_upstream_inst : mmi64_buffer_uni
    port map (
      mmi64_clk   => mmi64_clk,
      mmi64_reset => mmi64_reset,

      enable_i    => up_enable,

      mmi64_d_i      => mmi64_m_up_d_i,
      mmi64_valid_i  => mmi64_m_up_valid_i,
      mmi64_accept_o => mmi64_m_up_accept_o,
      mmi64_start_i  => mmi64_m_up_start_i,
      mmi64_stop_i   => mmi64_m_up_stop_i,

      mmi64_d_o      => mmi64_h_up_d_o,
      mmi64_valid_o  => mmi64_h_up_valid_o,
      mmi64_accept_i => mmi64_h_up_accept_i,
      mmi64_start_o  => mmi64_h_up_start_o,
      mmi64_stop_o   => mmi64_h_up_stop_o);

  p_enable : process (mmi64_clk)
  begin
    if rising_edge(mmi64_clk) then
      if mmi64_reset = '1' then
        dn_enable_counter_r <= (others => '0');
        up_enable_counter_r <= (others => '0');
        dn_enable           <= '0';
        up_enable           <= '0';
      else
        -- default assignment
        dn_enable_counter_r <= dn_enable_counter_r + 1;  -- increase counter
        dn_enable           <= '0';                      -- buffers are not enabled

        up_enable_counter_r <= up_enable_counter_r + 1;  -- increase counter
        up_enable           <= '0';                      -- buffers are not enabled

        -- enable downstream buffers if counter ran out
        if dn_enable_counter_r = to_unsigned(DOWNSTREAM_BUFFER_ENABLE_HOLDOFF, dn_enable_counter_r'length) then
          dn_enable_counter_r <= (others => '0');
          dn_enable           <= '1';
        end if;

        -- enable upstream buffers if counter ran out
        if up_enable_counter_r = to_unsigned(UPSTREAM_BUFFER_ENABLE_HOLDOFF, up_enable_counter_r'length) then
          up_enable_counter_r <= (others => '0');
          up_enable           <= '1';
        end if;
      end if;
    end if;

  end process;

end rtl;
