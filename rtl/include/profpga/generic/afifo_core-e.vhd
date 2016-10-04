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
--  Module/Entity : afifo_core, gray2binary, wr_ptr_full, rd_ptr_empty, sync (Entity-Component/Package)
--  Author        : Dragan Dukaric
--  Contact       : dragan.dukaric@prodesign-europe.com
--  Description   :
--                  Core for dual clock FIFO (and submodules used).
--                  Implementation based on "Simulation and Synthesis Techniques for Asynchronous FIFO Design"
--                  by Clifford E. Cummings
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
    data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
    data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
  );
end entity gray2binary;

-- Write pointers and flags generation
library ieee;
  use ieee.std_logic_1164.all;
entity wr_ptr_full is
  generic (
    ADDR_WIDTH : integer := 8
   );
  port (
    clk         : in  std_ulogic;
    reset_n     : in  std_ulogic;
    wr_enable_i : in  std_ulogic;
    wr_rptr_i   : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_ptr_o    : out std_ulogic_vector(ADDR_WIDTH downto 0);
    wr_addr_o   : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);
    wr_full_o   : out std_ulogic;
    wr_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0)
);
end entity wr_ptr_full;

-- Read pointers and flags generation
library ieee;
  use ieee.std_logic_1164.all;
entity rd_ptr_empty is
  generic (
    ADDR_WIDTH : integer := 8;
    FIRST_WORD_FALLS_THROUGH : boolean := false
   );
  port (
    clk         : in  std_ulogic;
    reset_n     : in  std_ulogic;
    rd_enable_i : in  std_ulogic;
    rd_wptr_i   : in  std_ulogic_vector(ADDR_WIDTH downto 0);
    enb_o       : out std_ulogic;
    rd_ptr_o    : out std_ulogic_vector(ADDR_WIDTH downto 0);
    rd_addr_o   : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);
    rd_empty_o  : out std_ulogic;
    rd_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0)
);
end entity rd_ptr_empty;

-- Two register synchronizer
library ieee;
  use ieee.std_logic_1164.all;
entity synchronizer is
  generic (
    DATA_WIDTH : integer := 8
   );
  port (
    clk      : in  std_ulogic;
    reset_n  : in  std_ulogic;
    data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
    data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
);
end entity synchronizer;

-- afifo_core (top level of this package)
library ieee;
  use ieee.std_logic_1164.all;
entity afifo_core is
  generic (
    DATA_WIDTH : integer := 8;                                --! Input data width
    ADDR_WIDTH : integer := 8;                                --! Input address width
    FIRST_WORD_FALLS_THROUGH : boolean := false
   );
  port (
    --Write clock domain
    wr_clk      : in  std_ulogic;                                 --! Write port clock
    wr_reset_n  : in  std_ulogic;                                 --! Write port reset (active low)
    wr_enable_i : in  std_ulogic;                                 --! Write port enable
    wr_data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);   --! Write port input data
    wr_full_o   : out std_ulogic;                                 --! Write port full flag
    wr_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0);     --! Write port status

    -- Read clock domain
    rd_clk      : in  std_ulogic;                                 --! Read port clock
    rd_reset_n  : in  std_ulogic;                                 --! Read port reset (active low)
    rd_enable_i : in  std_ulogic;                                 --! Read port enable
    rd_data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0);   --! Read port output data
    rd_empty_o  : out std_ulogic;                                 --! Read port empty flag
    rd_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0);     --! Read port status

    -- Memory interface
    wea_o      : out std_ulogic;                                  --! Port A (write memory port) write enable signal
    addra_o    : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);    --! Port A (write memory port) address
    dataa_o    : out std_ulogic_vector(DATA_WIDTH-1 downto 0);    --! Port A (write memory port) output data
    enb_o      : out std_ulogic;                                  --! Port B (read memory port) enable signal
    addrb_o    : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);    --! Port B (read memory port) address
    datab_i    : in  std_ulogic_vector(DATA_WIDTH-1 downto 0)     --! Port B (read memory port) input data
);
end entity afifo_core;


-----------------------
-- Component/Package  --
------------------------
library ieee;
    use ieee.std_logic_1164.all;
package afifo_core_pkg is
  -- Gray to binary conversion
  component gray2binary is
    generic (
      DATA_WIDTH : integer := 8
    );
    port (
      data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
      data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
    );
    end component gray2binary;

  component wr_ptr_full is
    generic (
      ADDR_WIDTH : integer := 8
    );
    port (
      clk         : in   std_ulogic;
      reset_n     : in   std_ulogic;
      wr_enable_i : in   std_ulogic;
      wr_rptr_i   : in   std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_ptr_o    : out  std_ulogic_vector(ADDR_WIDTH downto 0);
      wr_addr_o   : out  std_ulogic_vector(ADDR_WIDTH-1 downto 0);
      wr_full_o   : out  std_ulogic;
      wr_diff_o   : out  std_ulogic_vector(ADDR_WIDTH downto 0)
    );
    end component wr_ptr_full;

  component rd_ptr_empty is
    generic (
      ADDR_WIDTH : integer := 8;
      FIRST_WORD_FALLS_THROUGH : boolean := false
    );
    port (
      clk         : in  std_ulogic;
      reset_n     : in  std_ulogic;
      rd_enable_i : in  std_ulogic;
      rd_wptr_i   : in  std_ulogic_vector(ADDR_WIDTH downto 0);
      enb_o       : out std_ulogic;
      rd_ptr_o    : out std_ulogic_vector(ADDR_WIDTH downto 0);
      rd_addr_o   : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);
      rd_empty_o  : out std_ulogic;
      rd_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0)
    );
    end component rd_ptr_empty;

    component synchronizer is
      generic (
        DATA_WIDTH : integer := 8
      );
      port (
        clk      : in  std_ulogic;
        reset_n  : in  std_ulogic;
        data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
        data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0)
    );
    end component synchronizer;

    component afifo_core is
      generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 8;
        FIRST_WORD_FALLS_THROUGH : boolean := false
      );
      port (
        wr_clk      : in  std_ulogic;
        wr_reset_n  : in  std_ulogic;
        wr_enable_i : in  std_ulogic;
        wr_data_i   : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
        wr_full_o   : out std_ulogic;
        wr_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0);
        rd_clk      : in  std_ulogic;
        rd_reset_n  : in  std_ulogic;
        rd_enable_i : in  std_ulogic;
        rd_data_o   : out std_ulogic_vector(DATA_WIDTH-1 downto 0);
        rd_empty_o  : out std_ulogic;
        rd_diff_o   : out std_ulogic_vector(ADDR_WIDTH downto 0);
        wea_o       : out std_ulogic;
        addra_o     : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);
        dataa_o     : out std_ulogic_vector(DATA_WIDTH-1 downto 0);
        enb_o       : out std_ulogic;
        addrb_o     : out std_ulogic_vector(ADDR_WIDTH-1 downto 0);
        datab_i     : in  std_ulogic_vector(DATA_WIDTH-1 downto 0)
      );
    end component afifo_core;

end package afifo_core_pkg;

-- =============================================================================
-- Revision history :
-- Version  Date        Description
-- -------  ----------  --------------------------------------------------------
-- 0.1      2011-05-16  First draft.
-- 0.2      2011-11-21  Added FIRST_WORD_FALLS_THROUGH option.
-- =============================================================================
