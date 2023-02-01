-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;

entity ahbram_dp is
  generic (
    hindex1  : integer := 0;
    haddr1   : integer := 0;
    hindex2  : integer := 0;
    haddr2   : integer := 0;
    hmask    : integer := 16#fff#;
    tech     : integer := DEFMEMTECH;
    kbytes   : integer := 1;
    wordsz   : integer := AHBDW
    );
  port (
    rst      : in  std_ulogic;
    clk      : in  std_ulogic;
    ahbsi1   : in  ahb_slv_in_type;
    ahbso1   : out ahb_slv_out_type;
    ahbsi2   : in  ahb_slv_in_type;
    ahbso2   : out ahb_slv_out_type
    );
end;

architecture rtl of ahbram_dp is

  constant abits : integer := log2ext(kbytes) + 8 - wordsz/64;

  constant dw : integer := wordsz;

  constant hconfig1 : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_SLD, SLD_AHBRAM_DP, 0, abits+2+wordsz/64, 0),
    4 => ahb_membar(haddr1, '1', '1', hmask),
    others => zero32);

  constant hconfig2 : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_SLD, SLD_AHBRAM_DP, 0, abits+2+wordsz/64, 0),
    4 => ahb_membar(haddr2, '1', '1', hmask),
    others => zero32);

  type reg_type is record
    hwrite : std_ulogic;
    hsel   : std_ulogic;
    addr   : std_logic_vector(abits-1 downto 0);
  end record;

  constant RES : reg_type := (
    hwrite => '0',
    hsel   => '0',
    addr   => (others => '0'));

  signal r1, c1, r2, c2      : reg_type;
  signal ramsel1, ramsel2    : std_ulogic;
  signal write1, write2      : std_ulogic;
  signal ramaddr1, ramaddr2  : std_logic_vector(abits-1 downto 0);
  signal ramdata1, ramdata2  : std_logic_vector(dw-1 downto 0);
  signal hwdata1, hwdata2    : std_logic_vector(dw-1 downto 0);

begin

  comb1 : process (ahbsi1, r1, rst, ramdata1)
    variable v  : reg_type;
  begin
    v := r1;

    if ahbsi1.hready = '1' then
      v.addr := ahbsi1.haddr(abits-1+log2(dw/8) downto log2(dw/8));
      v.hsel := ahbsi1.hsel(hindex1) and ahbsi1.htrans(1);
      v.hwrite := ahbsi1.hwrite and v.hsel;
    end if;

    write1  <= r1.hwrite;
    if r1.hwrite = '1' then
      ramsel1 <= r1.hsel;
      ramaddr1 <= r1.addr;
    else
      ramsel1 <= v.hsel;
      ramaddr1 <= v.addr;
    end if;

    c1 <= v;

  end process;

  ahbso1.hresp   <= "00";
  ahbso1.hsplit  <= (others => '0');
  ahbso1.hirq    <= (others => '0');
  ahbso1.hconfig <= hconfig1;
  ahbso1.hindex  <= hindex1;
  ahbso1.hready  <= '1';
  ahbso1.hrdata <= ahbdrivedata(ramdata1);

  hwdata1 <= ahbsi1.hwdata(dw-1 downto 0);

  -- Disable write on interface 2
  comb2 : process (ahbsi2, r2, rst, ramdata2)
    variable v  : reg_type;
  begin
    v := r2;

    if ahbsi2.hready = '1' then
      v.addr := ahbsi2.haddr(abits-1+log2(dw/8) downto log2(dw/8));
      v.hsel := ahbsi2.hsel(hindex2) and ahbsi2.htrans(1);
      v.hwrite := '0';                  --ahbsi2.hwrite and v.hsel;
    end if;

    write2  <= r2.hwrite;
    if r2.hwrite = '1' then
      ramsel2 <= r2.hsel;
      ramaddr2 <= r2.addr;
    else
      ramsel2 <= v.hsel;
      ramaddr2 <= v.addr;
    end if;

    c2 <= v;

  end process;

  ahbso2.hresp   <= "00";
  ahbso2.hsplit  <= (others => '0');
  ahbso2.hirq    <= (others => '0');
  ahbso2.hconfig <= hconfig2;
  ahbso2.hindex  <= hindex2;
  ahbso2.hready  <= '1';                --(not write2) or c2.hwrite or (not c2.hsel);
  ahbso2.hrdata  <= ahbdrivedata(ramdata2);

  hwdata2 <= (others => '0');           --ahbsi2.hwdata(dw-1 downto 0);

  aram : syncram_dp generic map (tech, abits, dw) port map (
    clk, ramaddr1, hwdata1, ramdata1, ramsel1, write1,
    clk, ramaddr2, hwdata2, ramdata2, ramsel2, write2);

  reg : process (clk)
  begin
    if rising_edge(clk) then
      r1 <= c1;
      r2 <= c2;
      if rst = '0' then
        r1 <= RES;
        r2 <= RES;
      end if;
    end if;
  end process;

-- pragma translate_off
  bootmsg : report_version
    generic map ("ahbram_dp" & tost(hindex1) &
                 ": dual-port AHB SRAM Module rev 0, " & tost(kbytes) & " kbytes");
-- pragma translate_on
end;
