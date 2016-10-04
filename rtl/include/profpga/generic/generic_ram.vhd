-- =============================================================================
--  IMPORTANT: Pro Design Confidential (Internal Use Only)
--  COPYRIGHT (C) 2011-2013, Pro Design Electronic GmbH
--
--  THIS FILE MAY NOT BE MODIFIED, DISCLOSED, COPIED OR DISTRIBUTED WITHOUT THE
--  EXPRESSED WRITTEN CONSENT OF PRO DESIGN.
--
--  Pro Design Electronic GmbH           http://www.prodesign-europe.com
--  Albert-Mayer-Strasse 14-16           info@prodesign-europe.com
--  83052 Bruckmuehl                     +49 (0)8062 / 808 - 0
--  Germany
-- =============================================================================
--  Project       : ProDesign generic HDL components
--  Module/Entity : Generic memory package
--  Author        : Sebastian Flügel
--  Contact       : sebastian.fluegel@prodesign-europe.com
--  Description   :
--                  synthesizable functions
-- =============================================================================


library ieee;
    use ieee.std_logic_1164.all;
entity generic_spram is
  generic(
    ADDR_W : integer := 8;
    DATA_W : integer := 16
  );
  port (
    clk     : in  std_ulogic;
    ce      : in  std_ulogic;
    we      : in  std_ulogic;
    addr    : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata   : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata   : out std_ulogic_vector(DATA_W-1 downto 0)
  );
end entity generic_spram;




library ieee;
    use ieee.std_logic_1164.all;
entity generic_spram_bwe is
  generic(
    ADDR_W : integer := 8;
    DATA_W : integer := 16;
    WORD_W : integer := 8
  );
  port (
    clk     : in  std_ulogic;
    ce      : in  std_ulogic;
    bwe     : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
    addr    : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata   : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata   : out std_ulogic_vector(DATA_W-1 downto 0)
  );
end entity generic_spram_bwe;




library ieee;
    use ieee.std_logic_1164.all;
entity generic_dpram is
  generic(
    ADDR_W : integer := 8;
    DATA_W : integer := 16
  );
  port (
    clk1    : in  std_ulogic;
    ce1     : in  std_ulogic;
    we1     : in  std_ulogic;
    addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata1  : out std_ulogic_vector(DATA_W-1 downto 0);

    clk2    : in  std_ulogic;
    ce2     : in  std_ulogic;
    we2     : in  std_ulogic;
    addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata2  : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
  );
end entity generic_dpram;


library ieee;
    use ieee.std_logic_1164.all;
entity generic_dpram_separated_ports is
  generic(
    ADDR_W : integer := 8;
    DATA_W : integer := 16
  );
  port (
    clk1    : in  std_ulogic;
    ce1     : in  std_ulogic;
    we1     : in  std_ulogic;
    addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);

    clk2    : in  std_ulogic;
    ce2     : in  std_ulogic;
    addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
  );
end entity generic_dpram_separated_ports;




library ieee;
    use ieee.std_logic_1164.all;
entity generic_dpram_bwe is
  generic(
    ADDR_W : integer := 8;
    DATA_W : integer := 16;
    WORD_W : integer := 8
  );
  port (
    clk1    : in  std_ulogic;
    ce1     : in  std_ulogic;
    bwe1    : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
    addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata1  : out std_ulogic_vector(DATA_W-1 downto 0);

    clk2    : in  std_ulogic;
    ce2     : in  std_ulogic;
    bwe2    : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
    addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
    wdata2  : in  std_ulogic_vector(DATA_W-1 downto 0);
    rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
  );
end entity generic_dpram_bwe;




library ieee;
    use ieee.std_logic_1164.all;
package generic_ram_comp is

  component generic_spram is
    generic(
      ADDR_W : integer;
      DATA_W : integer
    );
    port (
      clk     : in  std_ulogic;
      ce      : in  std_ulogic;
      we      : in  std_ulogic;
      addr    : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata   : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata   : out std_ulogic_vector(DATA_W-1 downto 0)
    );
  end component generic_spram;


  component generic_spram_bwe is
    generic(
      ADDR_W : integer;
      DATA_W : integer;
      WORD_W : integer := 8
    );
    port (
      clk   : in  std_ulogic;
      ce    : in  std_ulogic;
      bwe   : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
      addr  : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata : out std_ulogic_vector(DATA_W-1 downto 0)
    );
  end component generic_spram_bwe;


  component generic_dpram is
    generic(
      ADDR_W : integer;
      DATA_W : integer
    );
    port (
      clk1    : in  std_ulogic;
      ce1     : in  std_ulogic;
      we1     : in  std_ulogic;
      addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata1  : out std_ulogic_vector(DATA_W-1 downto 0);

      clk2    : in  std_ulogic;
      ce2     : in  std_ulogic;
      we2     : in  std_ulogic;
      addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata2  : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
    );
  end component generic_dpram;

  component generic_dpram_separated_ports is
    generic(
      ADDR_W : integer;
      DATA_W : integer
    );
    port (
      clk1    : in  std_ulogic;
      ce1     : in  std_ulogic;
      we1     : in  std_ulogic;
      addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);

      clk2    : in  std_ulogic;
      ce2     : in  std_ulogic;
      addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
    );
  end component generic_dpram_separated_ports;


  component generic_dpram_bwe is
    generic(
      ADDR_W : integer;
      DATA_W : integer;
      WORD_W : integer := 8
    );
    port (
      clk1    : in  std_ulogic;
      ce1     : in  std_ulogic;
      bwe1    : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
      addr1   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata1  : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata1  : out std_ulogic_vector(DATA_W-1 downto 0);

      clk2    : in  std_ulogic;
      ce2     : in  std_ulogic;
      bwe2    : in  std_ulogic_vector(DATA_W/WORD_W-1 downto 0);
      addr2   : in  std_ulogic_vector(ADDR_W-1 downto 0);
      wdata2  : in  std_ulogic_vector(DATA_W-1 downto 0);
      rdata2  : out std_ulogic_vector(DATA_W-1 downto 0)
    );
  end component generic_dpram_bwe;

end package generic_ram_comp;




library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
architecture rtl of generic_spram is
  type ram_vector is array(natural range <>) of std_ulogic_vector(DATA_W-1 downto 0);
  signal ram    : ram_vector(2**ADDR_W-1 downto 0);
begin
  FF : process (clk)
  begin
    if rising_edge(clk) then
      if ce = '1' then
        if we  = '1' then ram(to_integer(unsigned(addr))) <= wdata; end if;
        rdata <= ram(to_integer(unsigned(addr)));
      end if;
    end if;
  end process;
end rtl;





library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
architecture rtl of generic_spram_bwe is
  type ram_vector is array(natural range <>) of std_ulogic_vector(DATA_W-1 downto 0);
  signal ram    : ram_vector(2**ADDR_W-1 downto 0);
begin
  FF : process (clk)
  variable ram_in : std_ulogic_vector(DATA_W-1 downto 0);
  begin
    if rising_edge(clk) then
      if ce = '1' then
        ram_in := ram(to_integer(unsigned(addr)));
        
        -- Xst limitation: only single-write statement
        for b in 0 to DATA_W/WORD_W-1 loop if bwe(b)='1' then
          ram_in((b+1)*WORD_W-1 downto b*WORD_W) := wdata((b+1)*WORD_W-1 downto b*WORD_W);
        end if; end loop;
        
        ram(to_integer(unsigned(addr))) <= ram_in;
        rdata <= ram_in;
      end if;
    end if;
  end process;
end rtl;


library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
architecture rtl of generic_dpram_separated_ports is
  type ram_vector is array (0 to 2**ADDR_W-1) of std_logic_vector(DATA_W-1 downto 0);
  signal ram : ram_vector:=(others=>std_logic_vector(to_unsigned(0,DATA_W)));
  signal addr2_r : std_ulogic_vector(addr2'range);
begin

  WRITE_PORT : process (clk1)
  begin
    if rising_edge(clk1) then
      if ce1 = '1' then
        if we1 = '1' then
          ram(to_integer(unsigned(addr1))) <= std_logic_vector(wdata1);
        end if;
      end if;
    end if;
  end process;

  READ_PORT : process (clk2)
  begin
    if rising_edge(clk2) then
      if ce2 = '1' then
        addr2_r <= addr2;
      end if;
    end if;
  end process;
  rdata2 <= std_ulogic_vector(ram(to_integer(unsigned(addr2_r))));

end rtl;





library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
architecture rtl of generic_dpram is
  type ram_vector is array (0 to 2**ADDR_W-1) of std_logic_vector(DATA_W-1 downto 0);
  shared variable ram : ram_vector;
begin

  PORT_1 : process (clk1)
  begin
    if rising_edge(clk1) then
      if ce1 = '1' then
        if we1 = '1' then
          ram(to_integer(unsigned(addr1))) := std_logic_vector(wdata1);
          rdata1 <= wdata1;
        else
          rdata1 <= std_ulogic_vector(ram(to_integer(unsigned(addr1))));
        end if;
      end if;
    end if;
  end process;

  PORT_2 : process (clk2)
  begin
    if rising_edge(clk2) then
      if ce2 = '1' then
        if we2 = '1' then
          ram(to_integer(unsigned(addr2))) := std_logic_vector(wdata2);
          rdata2 <= wdata2;
        else
          rdata2 <= std_ulogic_vector(ram(to_integer(unsigned(addr2))));
        end if;
      end if;
    end if;
  end process;

end rtl;





library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
architecture rtl of generic_dpram_bwe is
  type ram_vector is array (0 to 2**ADDR_W-1) of std_logic_vector(DATA_W-1 downto 0);
  shared variable ram : ram_vector;
begin

  PORT_1 : process (clk1)
  variable ram_in : std_logic_vector(DATA_W-1 downto 0);
  variable ram_we : std_logic;
  begin
    if rising_edge(clk1) then
      if ce1='1' then
        ram_in := ram(to_integer(unsigned(addr1)));
        ram_we := '0';
        
        -- Xst limitation: only single-write statement
        for b in 0 to DATA_W/WORD_W-1 loop if bwe1(b)='1' then
          ram_we := '1';
          ram_in((b+1)*WORD_W-1 downto b*WORD_W) := std_logic_vector(wdata1((b+1)*WORD_W-1 downto b*WORD_W));
        end if; end loop;

        ram(to_integer(unsigned(addr1))) := ram_in; 
        rdata1 <= std_ulogic_vector(ram_in);
      end if;
    end if;
  end process;

  PORT_2 : process (clk2)
  variable ram_in : std_logic_vector(DATA_W-1 downto 0);
  variable ram_we : std_logic;
  begin
    if rising_edge(clk2) then
      if ce2='1' then
        ram_in := ram(to_integer(unsigned(addr2)));
        ram_we := '0';
        
        -- Xst limitation: only single-write statement
        for b in 0 to DATA_W/WORD_W-1 loop if bwe2(b)='1' then
          ram_we := '1';
          ram_in((b+1)*WORD_W-1 downto b*WORD_W) := std_logic_vector(wdata2((b+1)*WORD_W-1 downto b*WORD_W));
        end if; end loop;
        
        ram(to_integer(unsigned(addr2))) := ram_in; 
        rdata2 <= std_ulogic_vector(ram_in);
      end if;
    end if;
  end process;

end architecture rtl;
