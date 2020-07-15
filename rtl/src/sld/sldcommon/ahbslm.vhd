-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.sldcommon.all;
use work.devices.all;
use work.gencomp.all;
use work.allslm.all;

entity ahbslm is
  generic (
    hindex : integer := 0;
    tech   : integer := DEFMEMTECH;
    mbytes : integer := 1               -- valid values are 1, 2, 4
    );
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    haddr : in  integer range 0 to 4095;
    hmask : in  integer range 0 to 4095;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type
    );
end;

architecture rtl of ahbslm is

  -- 19 address bit allow up to 4MB banks.
  constant abits : integer := 19;

  -- DO NOT CHANGE dw. This code is meant to work w/ 64-bit data width
  constant dw : integer := 64;

  signal hconfig : ahb_config_type;

  type reg_type is record
    hwrite : std_ulogic;
    hsel   : std_ulogic;
    hsize  : std_logic_vector(2 downto 0);
    addr   : std_logic_vector(abits + log2(dw/8) - 1 downto 0);
    mask   : std_logic_vector(dw - 1 downto 0);
  end record;

  constant RES : reg_type := (
    hwrite => '0',
    hsel   => '0',
    hsize  => HSIZE_WORD,
    addr   => (others => '0'),
    mask   => (others => '0'));

  signal r, c     : reg_type;
  signal ce0, ce1 : std_ulogic;
  signal a0, a1   : std_logic_vector(abits - 1 downto 0);
  signal we0      : std_ulogic;
  signal wem0     : std_logic_vector(dw - 1 downto 0);
  signal d0       : std_logic_vector(dw - 1 downto 0);
  signal q1       : std_logic_vector(dw - 1 downto 0);

  function setmask (
    signal addr  : std_logic_vector(log2(dw/8) - 1 downto 0);
    signal hsize : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable mask : std_logic_vector(dw - 1 downto 0);
  begin
    mask := (others => '0');
    case hsize is
      when HSIZE_BYTE =>
        case addr(2 downto 0) is
          when "000" => mask(7 downto 0)   := (others => '1');
          when "001" => mask(15 downto 8)  := (others => '1');
          when "010" => mask(23 downto 16) := (others => '1');
          when "011" => mask(31 downto 24) := (others => '1');
          when "100" => mask(39 downto 32) := (others => '1');
          when "101" => mask(47 downto 40) := (others => '1');
          when "110" => mask(55 downto 48) := (others => '1');
          when others => mask(63 downto 56) := (others => '1');
        end case;

      when HSIZE_HWORD =>
        case addr(2 downto 1) is
          when "00" => mask(15 downto 0)  := (others => '1');
          when "01" => mask(31 downto 16) := (others => '1');
          when "10" => mask(47 downto 32) := (others => '1');
          when others => mask(63 downto 48) := (others => '1');
        end case;

      when HSIZE_WORD =>
        case addr(2) is
          when '0' => mask(31 downto 0)  := (others => '1');
          when others => mask(63 downto 32) := (others => '1');
        end case;

      when others => mask := (others => '1');
    end case;
    return mask;
  end setmask;

  function selectdata (
    signal data  : std_logic_vector(dw - 1 downto 0);
    signal addr  : std_logic_vector(log2(dw/8) - 1 downto 0);
    signal hsize : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable hrdata : std_logic_vector(AHBDW - 1 downto 0);
  begin
    hrdata(AHBDW - 1 downto 0) := data(AHBDW - 1 downto 0);

    case hsize is
      when HSIZE_WORD =>
        case addr(2) is
          when '0' => hrdata := ahbdrivedata(data(31 downto 0));
          when others => hrdata := ahbdrivedata(data(63 downto 32));
        end case;

      when HSIZE_HWORD =>
        case addr(2 downto 1) is
          when "00" => hrdata := ahbdrivedata(data(15 downto 0));
          when "01" => hrdata := ahbdrivedata(data(31 downto 16));
          when "10" => hrdata := ahbdrivedata(data(47 downto 32));
          when others => hrdata := ahbdrivedata(data(63 downto 48));
        end case;

      when HSIZE_BYTE =>
        case addr(2 downto 0) is
          when "000" => hrdata := ahbdrivedata(data(7 downto 0));
          when "001" => hrdata := ahbdrivedata(data(15 downto 8));
          when "010" => hrdata := ahbdrivedata(data(23 downto 16));
          when "011" => hrdata := ahbdrivedata(data(31 downto 24));
          when "100" => hrdata := ahbdrivedata(data(39 downto 32));
          when "101" => hrdata := ahbdrivedata(data(47 downto 40));
          when "110" => hrdata := ahbdrivedata(data(55 downto 48));
          when others => hrdata := ahbdrivedata(data(63 downto 56));
        end case;

      when others => hrdata(AHBDW - 1 downto 0) := data(AHBDW - 1 downto 0);
    end case;

    return hrdata;
  end selectdata;

begin

  hconfig <= (
    0      => ahb_device_reg (VENDOR_SLD, SLD_SLM, 0, 0, 0),
    4      => ahb_membar(haddr, '1', '1', hmask),
    others => zero32);

  -- FSM
  ahb_slv_fsm : process (ahbsi, r)
    variable v : reg_type;
  begin
    v := r;

    if ahbsi.hready = '1' then
      v.addr   := ahbsi.haddr(abits + log2(dw/8) - 1 downto 0);
      v.hsel   := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.hsize  := ahbsi.hsize;
      v.mask   := setmask(ahbsi.haddr(log2(dw/8) - 1 downto 0), ahbsi.hsize);
      v.hwrite := ahbsi.hwrite and v.hsel;
    end if;

    -- FSM state
    c <= v;

    -- bank read interface
    ce1 <= v.hsel and not v.hwrite;
    a1  <= v.addr(abits + log2(dw/8) - 1 downto log2(dw/8));

  end process;

  -- bank write interface
  ce0  <= r.hsel and r.hwrite;
  we0  <= r.hwrite;
  wem0 <= r.mask;
  a0   <= r.addr(abits + log2(dw/8) - 1 downto log2(dw/8));
  d0_gen : for i in 0 to (dw / AHBDW) - 1 generate
    d0((i+1) * AHBDW - 1 downto i * AHBDW) <= ahbsi.hwdata(AHBDW - 1 downto 0);
  end generate d0_gen;

  -- Bus slave output
  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;
  ahbso.hready  <= '1';
  ahbso.hrdata  <= selectdata(q1, r.addr(log2(dw/8) - 1 downto 0), r.hsize);

  -- FSM state update
  reg : process (clk)
  begin
    if rising_edge(clk) then
      r <= c;
      if rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

  -- Bank instances
  unisim_gen : if is_unisim(tech) = 1 generate

    slm_1mb_gen : if mbytes = 1 generate
      slm_bank_1mb_unisim_i : slm_bank_1mb_unisim
        port map (
          CLK  => clk,
          CE0  => ce0,
          A0   => a0(16 downto 0),
          D0   => d0,
          WE0  => we0,
          WEM0 => wem0,
          CE1  => ce1,
          A1   => a1(16 downto 0),
          Q1   => q1);
    end generate slm_1mb_gen;

    slm_2mb_gen : if mbytes = 2 generate
      slm_bank_2mb_unisim_i : slm_bank_2mb_unisim
        port map (
          CLK  => clk,
          CE0  => ce0,
          A0   => a0(17 downto 0),
          D0   => d0,
          WE0  => we0,
          WEM0 => wem0,
          CE1  => ce1,
          A1   => a1(17 downto 0),
          Q1   => q1);
    end generate slm_2mb_gen;

    slm_4mb_gen : if mbytes = 4 generate
      slm_bank_4mb_unisim_i : slm_bank_4mb_unisim
        port map (
          CLK  => clk,
          CE0  => ce0,
          A0   => a0(18 downto 0),
          D0   => d0,
          WE0  => we0,
          WEM0 => wem0,
          CE1  => ce1,
          A1   => a1(18 downto 0),
          Q1   => q1);
    end generate slm_4mb_gen;

  end generate unisim_gen;


-- pragma translate_off
  bootmsg : report_version
    generic map ("ahbslm" & tost(hindex) &
                 ": Shared-Local Memory on AHB rev 0, " & tost(mbytes) & " MB");
-- pragma translate_on
end;
