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
--!  @file         mmi64_regfifo.vhd
--!  @author       Norman Nolte
--!  @email        norman.nolte@prodesign-europe.com
--!  @brief        Small register based FIFO.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity mmi64_regfifo is
  generic (
    FIFO_WIDTH : positive := 8;      -- fifo data width
    FIFO_DEPTH : positive := 8       -- fifo data capacity (depth)
    );
  port (
    --! clock and reset inputs
    clk   : in std_ulogic;                                           --! clock input
    reset : in std_ulogic;                                           --! reset input

    --! write and read port
    reserve_i : in  std_ulogic;                                      --! reserve space in fifo (without actually writing data)

    we_i     : in  std_ulogic;                                       --! write enable
    wdata_i  : in  std_ulogic_vector(FIFO_WIDTH-1 downto 0);         --! write data (after reservation)

    re_i     : in  std_ulogic;                                       --! chip enable
    rdata_o  : out std_ulogic_vector(FIFO_WIDTH-1 downto 0);         --! read data

    --! fifo status
    clear_i   : in  std_ulogic;       --! set fifo to empty
    full_o    : out std_ulogic;       --! fifo is full (based on reservations)
    empty_o   : out std_ulogic        --! fifo is empty
    );
end mmi64_regfifo;

--

library ieee;
use ieee.std_logic_1164.all;

--! component declaration package for regfile
package mmi64_regfifo_comp is

  component mmi64_regfifo is
    generic (
      FIFO_WIDTH : natural := 8;      -- fifo data width
      FIFO_DEPTH : natural := 8       -- fifo data capacity (depth)
      );
    port (
      --! clock and reset inputs
      clk   : in std_ulogic;                                           --! clock input
      reset : in std_ulogic;                                           --! reset input

      --! write and read port
      reserve_i : in  std_ulogic;                                      --! reserve space in fifo (without actually writing data)

      we_i     : in  std_ulogic;                                       --! write enable
      wdata_i  : in  std_ulogic_vector(FIFO_WIDTH-1 downto 0);         --! write data (after reservation)

      re_i     : in  std_ulogic;                                       --! chip enable
      rdata_o  : out std_ulogic_vector(FIFO_WIDTH-1 downto 0);         --! read data

      --! fifo status
      clear_i   : in  std_ulogic;       --! set fifo to empty
      full_o    : out std_ulogic;       --! fifo is full (based on reservations)
      empty_o   : out std_ulogic        --! fifo is empty
      );
  end component mmi64_regfifo;

end package mmi64_regfifo_comp;
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of mmi64_regfifo is

  -- type of fifo for holding data
  type fifo_data_t  is array(1 to FIFO_DEPTH) of std_ulogic_vector(FIFO_WIDTH-1 downto 0);

  -- type of fifo level: every bit corresponds to a fifo level (LSB set means empty, LSB set means full)
  subtype fifo_level_t is unsigned(0 to FIFO_DEPTH);

  signal fifo_data_r      : fifo_data_t; --! fifo data (register)
  signal fifo_data_r_nxt  : fifo_data_t; --! fifo data (next)

  signal fifo_level_r     : fifo_level_t; --! fifo fill level (register)
  signal fifo_level_r_nxt : fifo_level_t; --! fifo fill level (next)

  signal fifo_reserve_r     : fifo_level_t; --! fifo fill level (register)
  signal fifo_reserve_r_nxt : fifo_level_t; --! fifo fill level (next)

begin


  p_fifo: process (clear_i, fifo_data_r, fifo_level_r, fifo_reserve_r, re_i, reserve_i, wdata_i, we_i)
    variable fifo_level_v : fifo_level_t;
    variable fifo_reserve_v : fifo_level_t;
  begin
    -- default assignments
    fifo_data_r_nxt      <= fifo_data_r;  -- hold data fifo content

    -- prepare fifo level to be updated combinatorically
    fifo_level_v := fifo_level_r;
    fifo_reserve_v := fifo_reserve_r;

    -- **
    -- *** fifo read port
    -- **

    -- fifo not empty?
    if fifo_level_v(0) = '0' then

      -- read request on fifo
      if re_i = '1' then

        -- readout: shift fifo content towards read port
        for read_idx in 1 to FIFO_DEPTH-1 loop
          fifo_data_r_nxt(read_idx)  <= fifo_data_r(read_idx+1);
        end loop;

        -- decrease fifo fill level by one (shift toward LSB)
        fifo_level_v := shift_left(fifo_level_v, 1);
        fifo_reserve_v := shift_left(fifo_reserve_v, 1);
       end if;
    end if;

    -- **
    -- *** fifo write port
    -- **

    -- fifo not full?
    if fifo_level_v(FIFO_DEPTH) = '0' then

      -- data available for writing?
      if we_i = '1' then
         -- increase fifo fill level by one (shift toward MSB)
         fifo_level_v := shift_right(fifo_level_v, 1);

         -- perform write access to fifo
         for write_idx in 1 to FIFO_DEPTH loop
           -- search write position and perform write
           if fifo_level_v(write_idx) = '1' then
             fifo_data_r_nxt(write_idx)  <= wdata_i;
           end if;
         end loop;
       end if;
    end if;

    if fifo_reserve_v(FIFO_DEPTH) = '0' then
      if reserve_i = '1' then
         -- increase fifo fill level by one (shift toward MSB)
         fifo_reserve_v := shift_right(fifo_reserve_v, 1);
      end if;
    end if;

    -- request to clean the fifo?
    if clear_i='1' then
      fifo_level_v      := (others=>'0');   -- mark fifo empty ...
      fifo_level_v(0)   :='1';              -- ... by settings lowest bit
      fifo_reserve_v      := (others=>'0');   -- mark fifo empty ...
      fifo_reserve_v(0)   :='1';              -- ... by settings lowest bit
    end if;

    -- update the fifo level indicator
    fifo_level_r_nxt <= fifo_level_v;
    fifo_reserve_r_nxt <= fifo_reserve_v;

  end process p_fifo;

  p_fifo_status: process (fifo_level_r, fifo_reserve_r)
  begin
    empty_o   <= '0';
    full_o    <= '0';

    -- generate empty flag
    if fifo_level_r(0) = '1' then
      empty_o    <= '1';
    end if;

    -- generate full flag based on fifo reservations
    if fifo_reserve_r(FIFO_DEPTH) = '1' then
      full_o <= '1';
    end if;
  end process;

  -- assign outputs
  rdata_o <= fifo_data_r(1);

  p_ff: process(clk)
  begin  -- process
    if rising_edge(clk) then
      assert not (we_i='1' and fifo_level_r(FIFO_DEPTH)='1')
      report "Trying to write into full FIFO"
      severity error;

      -- synchronous reset
      if reset='1' then
        fifo_level_r      <= (others=>'0');   -- mark fifo empty ...
        fifo_level_r(0)   <='1';              -- ... by settings lowest bit
        fifo_reserve_r      <= (others=>'0');   -- mark fifo empty ...
        fifo_reserve_r(0)   <='1';              -- ... by settings lowest bit
      else
        fifo_level_r      <= fifo_level_r_nxt;
        fifo_reserve_r      <= fifo_reserve_r_nxt;
      end if;
      fifo_data_r         <= fifo_data_r_nxt;
    end if;
  end process;

end rtl;
