------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2016, Cobham Gaisler
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
-- Entity:      grdmac_alignram
-- File:        grdmac_alignram.vhd
-- Author:      Andrea Gianarro - Aeroflex Gaisler AB
-- Description: Synchronous RAM with support for big endian unaligned access
--              Writes and reads data synchronously on rising edge of clock
--              Data output is always big endian, and always aligned to the
--              MSb. To obtain proper output alignment according to AHB standards
--              use the data_offset input.
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.amba.all;
use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.devices.all;
use work.grdmac_pkg.all;

entity grdmac_alignram is
  generic (
    memtech  : integer := 0;
    abits    : integer := 6; -- number of BYTES in buffer
    dbits    : integer := 8;
    testen   : integer := 0;
    ft       : integer range 0 to 2  := 0);
  port (
    clk         : in std_ulogic;
    rst         : in std_logic;
    enable      : in std_logic;
    write       : in std_logic;
    address     : in std_logic_vector((abits-1) downto 0);
    size        : in std_logic_vector(2 downto 0); -- AHB HSIZE format
    dataout     : out std_logic_vector((dbits-1) downto 0);
    datain      : in std_logic_vector((dbits-1) downto 0);
    data_offset : in std_logic_vector((log2(dbits/8))-1 downto 0)); -- output offset in bytes
end;

architecture rtl of grdmac_alignram is
  
  type reg_type is record
    address     : std_logic_vector(abits-1 downto 0);
    data_offset : std_logic_vector(log2(dbits/8)-1 downto 0);
    size        : std_logic_vector(2 downto 0);
  end record;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
  constant RES : reg_type := (
                              address => (others => '0'),
                              data_offset => (others => '0'),
                              size => (others => '0'));

  type fifo_in_type is record
    idx_pointer  : std_logic_vector(abits-log2(dbits/8)-2 downto 0);
    write       : std_logic_vector((dbits/8-1) downto 0);
    enable      : std_logic_vector((dbits/8-1) downto 0);
    datain        : std_logic_vector(dbits-1 downto 0);
  end record;
  
  type fifo_out_type is record
    dataout       : std_logic_vector(dbits-1 downto 0);
  end record;

  signal fifoi_even : fifo_in_type;
  signal fifoi_odd  : fifo_in_type;
  signal fifoo_even : fifo_out_type;
  signal fifoo_odd  : fifo_out_type;

  signal r, rin : reg_type;

  -- size is anyway limited by our data width dbits
  -- 000    8    bits
  -- 001    16   bits
  -- 010    32   bits
  -- 111    1024 bits
  function create_align_mask(size : std_logic_vector(2 downto 0))
  return std_logic_vector is
    variable res  : std_logic_vector((dbits/8-1) downto 0);
    variable bits : integer range 1 to dbits/8; --limiting i according to max data width
  begin
    res   := (others => '0');
    if notx(size) then bits := 2**to_integer(unsigned(size)); end if;
    --res(dbits/8-1 downto dbits/8-bits) := ( others => '1'); -- <- not supported in some synthesizers
    for i in 1 to dbits/8 loop
      if i <= bits then
        res(dbits/8-i) := '1';
      end if;
    end loop ;

    -- case size is
    --   when "000" =>
    --     res := "1000";
    --   when "001" =>
    --     res := "1100";
    --   when "010" =>
    --     res := "1111";
    --   when others =>
    --     res := "0000";
    -- end case ;
    return(res);
  end;
begin

  comb : process(write, size, address, datain, data_offset, fifoo_even, fifoo_odd, enable, r, rst)
    --variable decoded_size : integer range 0 to dbits/8;
    --variable decoded_size_bits : integer;
    variable align_mask_in        : std_logic_vector(dbits*2/8-1 downto 0);
    variable align_mask_out       : std_logic_vector(dbits*2/8-1 downto 0);
    variable align_data_in        : std_logic_vector(dbits-1 downto 0);
    variable align_data_out       : std_logic_vector(dbits-1 downto 0);
    variable rotate_by_in         : std_logic_vector(log2(dbits/8)-1 downto 0);
    variable rotate_by_out        : std_logic_vector(log2(dbits/8)-1 downto 0);
    variable pad_data_offset_in   : std_logic_vector(6 downto 0);
    variable pad_data_offset_out  : std_logic_vector(6 downto 0);
    variable v                    : reg_type;
  begin
    v := r;
    pad_data_offset_in  := ( others => '0' );
    pad_data_offset_out := ( others => '0' );

    if enable = '1' then
      v.data_offset := data_offset;
      v.address := address;
      v.size := size;
    end if;
    
    align_mask_in := (others => '0');
    align_mask_in(dbits*2/8-1 downto dbits/8) := create_align_mask(size);
    -- WARNING address must be at least 2 words: abits = log2(dbits/8)+1
    align_mask_in := std_logic_vector(unsigned(align_mask_in) ror conv_integer(address(log2(dbits/8) downto 0)));
    
    -- we now align the data by rotating the byte lanes
    if CFG_AHB_ACDM = 1 then
      -- TODO if offset is not in agreemement with size, then problems might ensue
      rotate_by_in := address(log2(dbits/8)-1 downto 0) - data_offset;
      align_data_in := ror_byte_lanes(datain, conv_integer(rotate_by_in));
    else
      rotate_by_in := address(log2(dbits/8)-1 downto 0) - data_offset;
      pad_data_offset_in(log2(dbits/8)-1 downto 0) := data_offset;
      align_data_in := ror_byte_lanes(ahbselectdata(datain, pad_data_offset_in(4 downto 2), size), conv_integer(rotate_by_in));
    end if;

    align_mask_out := (others => '0');
    align_mask_out(dbits*2/8-1 downto dbits/8) := create_align_mask(r.size);
    align_mask_out := std_logic_vector(unsigned(align_mask_out) ror conv_integer(r.address(log2(dbits/8) downto 0)));
    
    align_data_out := mask_byte_lanes(fifoo_even.dataout, align_mask_out(dbits*2/8-1 downto dbits/8)) or
                        mask_byte_lanes(fifoo_odd.dataout, align_mask_out(dbits/8-1 downto 0));

    -- drive buffer outputs
    if CFG_AHB_ACDM = 1 then
      rotate_by_out := r.address(log2(dbits/8)-1 downto 0) - r.data_offset;
      dataout <= rol_byte_lanes(align_data_out, conv_integer(rotate_by_out));
    else
      rotate_by_out := r.address(log2(dbits/8)-1 downto 0) - r.data_offset;
      pad_data_offset_out(log2(dbits/8)-1 downto 0) := r.data_offset;
      dataout <= ahbselectdata(rol_byte_lanes(align_data_out, conv_integer(rotate_by_out)), pad_data_offset_out(4 downto 2), r.size);
    end if;

    -- drive FIFO inputs
    fifoi_even.enable <= align_mask_in(dbits*2/8-1 downto dbits/8);
    fifoi_odd.enable  <= align_mask_in(dbits/8-1 downto 0);
    
    fifoi_even.write <= (others => '0');
    fifoi_odd.write  <= (others => '0');
    if write = '1' then
      fifoi_even.write <= align_mask_in(dbits*2/8-1 downto dbits/8);
      fifoi_odd.write  <= align_mask_in(dbits/8-1 downto 0);
    end if;

    fifoi_even.datain  <= align_data_in;
    fifoi_odd.datain   <= align_data_in;

    fifoi_even.idx_pointer <= r.address(abits-1 downto log2(dbits/8)+1) + r.address(log2(dbits/8));
    fifoi_odd.idx_pointer  <= r.address(abits-1 downto log2(dbits/8)+1);
    if enable = '1' then
      fifoi_even.idx_pointer <= address(abits-1 downto log2(dbits/8)+1) + address(log2(dbits/8));
      fifoi_odd.idx_pointer  <= address(abits-1 downto log2(dbits/8)+1);
    end if;

    if (not RESET_ALL) and (rst = '0') then
      v.address := RES.address;
      v.data_offset := RES.data_offset;
      v.size := RES.size;
    end if;

    rin <= v;
  end process ; -- comb

  reg : process (clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

-- INTERNAL RAMS
  nft : if ft = 0 generate
    -- buffer with EVEN words
    ramEVEN : syncrambw
      generic map (
        tech    => memtech,
        abits   => abits-1-log2(dbits/8),
        dbits   => dbits,
        testen  => testen)
      port map (
        clk     => clk,
        address => fifoi_even.idx_pointer,
        datain  => fifoi_even.datain,
        dataout => fifoo_even.dataout,
        enable  => fifoi_even.enable,
        write   => fifoi_even.write);

    -- buffer with ODD words
    ramODD : syncrambw
      generic map (
        tech    => memtech,
        abits   => abits-1-log2(dbits/8),
        dbits   => dbits,
        testen  => testen)
      port map (
        clk     => clk,
        address => fifoi_odd.idx_pointer,
        datain  => fifoi_odd.datain,
        dataout => fifoo_odd.dataout,
        enable  => fifoi_odd.enable,
        write   => fifoi_odd.write);
  end generate;


end architecture;

