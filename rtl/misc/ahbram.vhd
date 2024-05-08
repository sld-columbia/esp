------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2018, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-----------------------------------------------------------------------------
-- Entity:   ahbram
-- File:  ahbram.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Modified:    Jan Andersson - Aeroflex Gaisler
-- Description:  AHB ram. 0-waitstate read, 0/1-waitstate write.
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use work.config_types.all;
  use work.config.all;
  use work.amba.all;
  use work.stdlib.all;
  use work.devices.all;
  use work.gencomp.all;

entity ahbram is
  generic (
    hindex      : integer := 0;
    tech        : integer := DEFMEMTECH;
    large_banks : integer := 0;
    kbytes      : integer := 1;
    pipe        : integer := 0;
    maccsz      : integer := AHBDW;
    scantest    : integer := 0;
    endianness  : integer := 0
  );
  port (
    rst   : in    std_ulogic;
    clk   : in    std_ulogic;
    haddr : in    integer range 0 to 4095;
    hmask : in    integer range 0 to 4095;
    ahbsi : in    ahb_slv_in_type;
    ahbso : out   ahb_slv_out_type
  );
end entity ahbram;

architecture rtl of ahbram is

  constant ABITS : integer := log2ext(kbytes) + 8 - maccsz / 64;

  constant DW : integer := maccsz;

  signal hconfig : ahb_config_type;

  type reg_type is record
    hwrite : std_ulogic;
    hready : std_ulogic;
    hsel   : std_ulogic;
    addr   : std_logic_vector(ABITS - 1 + log2(DW / 8) downto 0);
    size   : std_logic_vector(2 downto 0);
    prdata : std_logic_vector((DW - 1) * pipe downto 0);
    pwrite : std_ulogic;
    pready : std_ulogic;
  end record reg_type;

  constant RESET_ALL : boolean  := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant RES       : reg_type :=
  (
    hwrite   => '0',
    hready   => '1',
    hsel     => '0',
    addr     => (others => '0'),
    size   => (others => '0'),
    prdata   => (others => '0'),
    pwrite   => '0',
    pready => '1'
  );

  signal r, c    : reg_type;
  signal ramsel  : std_logic_vector(DW / 8 - 1 downto 0);
  signal write   : std_logic_vector(DW / 8 - 1 downto 0);
  signal ramaddr : std_logic_vector(ABITS - 1 downto 0);
  signal ramdata : std_logic_vector(DW - 1 downto 0);
  signal hwdata  : std_logic_vector(DW - 1 downto 0);

begin

  hconfig <=
  (
    0      => ahb_device_reg (VENDOR_GAISLER, GAISLER_AHBRAM, 0, ABITS + 2 + maccsz / 64, 0),
    4      => ahb_membar(haddr, '1', '1', hmask),
    others => zero32
  );

  comb : process (ahbsi, r, rst, ramdata) is

    variable bs      : std_logic_vector(DW / 8 - 1 downto 0);
    variable v       : reg_type;
    variable haddr   : std_logic_vector(ABITS - 1 downto 0);
    variable hrdata  : std_logic_vector(DW - 1 downto 0);
    variable wdata   : std_logic_vector(DW - 1 downto 0);
    variable seldata : std_logic_vector(DW - 1 downto 0);
    variable raddr   : std_logic_vector(3 downto 2);
    variable adsel   : std_logic;

    function reversedata (
      data : std_logic_vector;
      step : integer
    )
    return std_logic_vector is

      variable rdata : std_logic_vector(data'length-1 downto 0);

    begin

      for i in 0 to (data'length / step - 1) loop

        rdata(i * step + step - 1 downto i * step) := data(data'length-i * step - 1 downto data'length-i * step - step);

      end loop;

      return rdata;

    end function reversedata;

  begin

    v        := r; v.hready := '1'; bs := (others => '0');
    v.pready := r.hready;

    if (pipe=0) then
      adsel := r.hwrite or not r.hready;
    else
      adsel    := r.hwrite or r.pwrite;
      v.hready := r.hready or not r.pwrite;
    end if;

    if (adsel = '1') then
      haddr := r.addr(ABITS - 1 + log2(DW / 8) downto log2(DW / 8));
    else
      haddr := ahbsi.haddr(ABITS - 1 + log2(DW / 8) downto log2(DW / 8));
      bs    := (others => '0');
    end if;

    raddr := (others => '0');

    v.pwrite := '0';

    if (pipe/=0 and (r.hready='1' or r.pwrite='0')) then
      v.addr := ahbsi.haddr(ABITS - 1 + log2(DW / 8) downto 0);
    end if;

    if (ahbsi.hready = '1') then
      if (pipe=0) then
        v.addr := ahbsi.haddr(ABITS - 1 + log2(DW / 8) downto 0);
      end if;
      v.hsel   := ahbsi.hsel(hindex) and ahbsi.htrans(1);
      v.size   := ahbsi.hsize(2 downto 0);
      v.hwrite := ahbsi.hwrite and v.hsel;
      if (pipe = 1 and v.hsel = '1' and ahbsi.hwrite = '0' and (r.pready='1' or ahbsi.htrans(0)='0')) then
        v.hready := '0';
        v.pwrite := r.hwrite;
      end if;
    end if;

    if (r.hwrite = '1') then

      case r.size is

        when HSIZE_BYTE =>

          bs(bs'left - conv_integer(r.addr(log2(dw / 16) downto 0))) := '1';

        when HSIZE_HWORD =>

          for i in 0 to DW / 16 - 1 loop

            if (i = conv_integer(r.addr(log2(DW / 16) downto 1))) then
              bs(bs'left - i * 2 downto bs'left - i * 2 - 1) := (others => '1');
            end if;

          end loop;                                                                                        -- i

        when HSIZE_WORD =>

          if (DW = 32) then
            bs := (others => '1');
          else

            for i in 0 to DW / 32 - 1 loop

              if (i = conv_integer(r.addr(log2(DW / 8) - 1 downto 2))) then
                bs(bs'left - i * 4 downto bs'left - i * 4 - 3) := (others => '1');
              end if;

            end loop;                                                                                      -- i

          end if;

        when HSIZE_DWORD =>

          if (DW = 32) then
            null;
          elsif (DW = 64) then
            bs := (others => '1');
          else

            for i in 0 to DW / 64 - 1 loop

              if (i = conv_integer(r.addr(3))) then
                bs(bs'left - i * 8 downto bs'left - i * 8 - 7) := (others => '1');
              end if;

            end loop;                                                                                      -- i

          end if;

        when HSIZE_4WORD =>

          if (DW < 128) then
            null;
          elsif (DW = 128) then
            bs := (others => '1');
          else

            for i in 0 to DW / 64 - 1 loop

              if (i = conv_integer(r.addr(3))) then
                bs(bs'left - i * 8 downto bs'left - i * 8 - 7) := (others => '1');
              end if;

            end loop;                                                                                      -- i

          end if;

        when others =>                                                                                     -- HSIZE_8WORD

          if (DW < 256) then
            null;
          else
            bs := (others => '1');
          end if;

      end case;

      v.hready := not (v.hsel and not ahbsi.hwrite);
      v.hwrite := v.hwrite and v.hready;
    end if;

    -- Duplicate read data on word basis, unless CORE_ACDM is enabled
    if (CORE_ACDM = 0) then
      if (DW = 32) then
        seldata := ramdata;
      elsif (DW = 64) then
        if (r.size = HSIZE_DWORD) then
          seldata := ramdata;
        else
          if (r.addr(2) = '0') then
            seldata(dw / 2 - 1 downto 0) := ramdata(DW - 1 downto DW / 2);
          else
            seldata(dw / 2 - 1 downto 0) := ramdata(DW / 2 - 1 downto 0);
          end if;
          seldata(dw - 1 downto dw / 2) := seldata(DW / 2 - 1 downto 0);
        end if;
      elsif (DW = 128) then
        if (r.size = HSIZE_4WORD) then
          seldata := ramdata;
        elsif (r.size = HSIZE_DWORD) then
          if (r.addr(3) = '0') then
            seldata(dw / 2 - 1 downto 0) := ramdata(DW - 1 downto DW / 2);
          else
            seldata(dw / 2 - 1 downto 0) := ramdata(DW / 2 - 1 downto 0);
          end if;
          seldata(dw - 1 downto dw / 2) := seldata(DW / 2 - 1 downto 0);
        else
          raddr := r.addr(3 downto 2);

          case raddr is

            when "00" =>

              seldata(dw / 4 - 1 downto 0) := ramdata(4 * DW / 4 - 1 downto 3 * DW / 4);

            when "01" =>

              seldata(dw / 4 - 1 downto 0) := ramdata(3 * DW / 4 - 1 downto 2 * DW / 4);

            when "10" =>

              seldata(dw / 4 - 1 downto 0) := ramdata(2 * DW / 4 - 1 downto 1 * DW / 4);

            when others =>

              seldata(dw / 4 - 1 downto 0) := ramdata(DW / 4 - 1 downto 0);

          end case;

          seldata(dw - 1 downto dw / 4) := seldata(DW / 4 - 1 downto 0) &
                                           seldata(DW / 4 - 1 downto 0) &
                                           seldata(DW / 4 - 1 downto 0);
        end if;
      else
        seldata := ahbselectdata(ramdata, r.addr(4 downto 2), r.size);
      end if;
    else
      seldata := ramdata;
    end if;

    if (pipe = 0) then
      v.prdata := (others => '0');
      hrdata   := seldata;
    else
      v.prdata := seldata;
      hrdata   := r.prdata;
    end if;

    -- Endianness conversion
    wdata := ahbsi.hwdata;

    if (endianness = 1) then
      hrdata := reversedata(hrdata, 8);
      wdata  := reversedata(wdata, 8);
    end if;

    if ((not RESET_ALL) and (rst = '0')) then
      v.hwrite := RES.hwrite; v.hready := RES.hready;
    end if;

    write <= bs;

    for i in 0 to DW / 8 - 1 loop

      ramsel(i) <= v.hsel or r.hwrite;

    end loop;

    ramaddr <= haddr;
    c       <= v;

    ahbso.hrdata <= ahbdrivedata(hrdata);
    ahbso.hready <= r.hready;

    -- Select correct write data
    hwdata <= ahbreaddata(wdata, r.addr(4 downto 2), conv_std_logic_vector(log2(DW / 8), 3));

  end process comb;

  ahbso.hresp   <= "00";
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');
  ahbso.hconfig <= hconfig;
  ahbso.hindex  <= hindex;

  aram : component syncrambw
    generic map (
      tech        => tech,
      abits       => abits,
      dbits       => dw,
      testen      => scantest,
      custombits  => 1,
      large_banks => large_banks
    )
    port map (
      clk     => clk,
      address => ramaddr,
      datain  => hwdata,
      dataout => ramdata,
      enable  => ramsel,
      write   => write,
      testin  => ahbsi.testin
    );

  reg : process (clk) is
  begin

    if rising_edge(clk) then
      r <= c;
      if (RESET_ALL and rst = '0') then
        r <= RES;
      end if;
    end if;

  end process reg;

  -- pragma translate_off
  bootmsg : component report_version
    generic map (
"ahbram" & tost(hindex) &
    ": AHB SRAM Module rev 1, " & tost(kbytes) & " kbytes"
    );

-- pragma translate_on

end architecture rtl;

