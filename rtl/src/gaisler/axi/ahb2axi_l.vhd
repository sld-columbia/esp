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
-- Entity:      ahbm2axis
-- File:        ahbm2axis.vhd
-- Author:      Alen Bardizbanyan - Cobham Gaisler AB
-- Description: AMBA AHB master to AXI slave adapter (lite version)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

use work.config_types.all;
use work.config.all;
use work.stdlib.all;
use work.amba.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;


entity ahb2axi_l is
  generic (
    hindex    : integer               := 0;
    hconfig   : ahb_config_type;
    aximid    : integer range 0 to 15 := 0;  --AXI master transaction ID
    axisecure : boolean               := true;
    scantest  : integer               := 0);
  port (
    rst   : in  std_logic;
    clk   : in  std_logic;
    ahbsi : in  ahb_slv_in_type;
    ahbso : out ahb_slv_out_type;
    aximi : in  axi_somi_type;
    aximo : out axi_mosi_type);
end ahb2axi_l;


architecture rtl of ahb2axi_l is

  type ahb_to_axi_state is (idle, read, write, error_p);

  type ahb_slv_out_local_type is record
    hready : std_ulogic;
    hresp  : std_logic_vector(1 downto 0);
    hrdata : std_logic_vector(AHBDW-1 downto 0);
  end record;


  type reg_type is record
    state           : ahb_to_axi_state;
    ahbsout         : ahb_slv_out_local_type;
    aximout         : axi_mosi_type;
    addr_strb       : std_logic_vector(log2(AXIDW/8)-1 downto 0);
    read_error      : std_logic;
    read_validated  : std_logic;
    write_error     : std_logic;
    wr_word_valid   : std_logic;
    write_validated : std_logic;
  end record;


  constant rac_reset : axi_ar_mosi_type := (
    id     => (others => '0'),
    addr   => (others => '0'),
    len    => (others => '0'),
    size   => (others => '0'),
    burst  => (others => '0'),
    lock   => '0',
    cache  => (others => '0'),
    prot   => (others => '0'),
    qos    => (others => '0'),
    region => (others => '0'),
    user   => (others => '0'),
    valid  => '0');

  constant rdc_reset : axi_r_mosi_type := (
    ready => '0');

  constant wac_reset : axi_aw_mosi_type := (
    id     => (others => '0'),
    addr   => (others => '0'),
    len    => (others => '0'),
    size   => (others => '0'),
    burst  => (others => '0'),
    lock   => '0',
    cache  => (others => '0'),
    prot   => (others => '0'),
    qos    => (others => '0'),
    atop   => (others => '0'),
    region => (others => '0'),
    user   => (others => '0'),
    valid  => '0');

  constant wdc_reset : axi_w_mosi_type := (
    data  => (others => '0'),
    strb  => (others => '0'),
    last  => '0',
    user  => (others => '0'),
    valid => '0');

  constant wrc_reset : axi_b_mosi_type := (
    ready => '0');

  constant aximout_res_t : axi_mosi_type := (
    aw => wac_reset,
    w  => wdc_reset,
    b  => wrc_reset,
    ar => rac_reset,
    r  => rdc_reset);

  constant ahbsout_reset : ahb_slv_out_local_type := (
    hready => '1',
    hresp  => HRESP_OKAY,
    hrdata => (others => '0'));

  constant RES_T : reg_type := (
    state           => idle,
    ahbsout         => ahbsout_reset,
    aximout         => aximout_res_t,
    addr_strb       => (others => '0'),
    read_error      => '0',
    read_validated  => '0',
    write_error     => '0',
    wr_word_valid   => '0',
    write_validated => '0'
    );

  constant ASYNC_RESET : boolean := GRLIB_CONFIG_ARRAY(grlib_async_reset_enable) = 1;

  signal arst   : std_ulogic;
  signal r, rin : reg_type;

begin

  arst <= ahbsi.testrst when (ASYNC_RESET and scantest /= 0 and ahbsi.testen /= '0') else
          rst when ASYNC_RESET else
          '1';

  ahbso.hready <= r.ahbsout.hready;
  ahbso.hresp  <= r.ahbsout.hresp;
  ahbso.hrdata <= r.ahbsout.hrdata;
  ahbso.hsplit <= (others => '0');
  ahbso.hirq   <= (others => '0');
  ahbso.hindex <= hindex;

  aximo.ar <= r.aximout.ar;
  aximo.aw <= r.aximout.aw;
  aximo.b  <= r.aximout.b;
  aximo.r  <= r.aximout.r;
  aximo.w  <= r.aximout.w;

  comb : process(r, ahbsi, aximi)
    variable v : reg_type;
  begin

    v := r;

    if axisecure = true then
      v.aximout.ar.prot(1) := '0';
      v.aximout.aw.prot(1) := '0';
    else
      v.aximout.ar.prot(1) := '1';
      v.aximout.aw.prot(1) := '1';
    end if;

    --locked access disabled
    v.aximout.ar.lock := '0';
    v.aximout.aw.lock := '0';

    --read and write allocate currently disabled
    v.aximout.ar.cache(2) := '0';
    v.aximout.ar.cache(3) := '0';
    v.aximout.aw.cache(2) := '0';
    v.aximout.aw.cache(3) := '0';

    --AXI ID for write operations
    v.aximout.aw.id := std_logic_vector(to_unsigned(aximid, XID_WIDTH));
    --AXI ID for read operations
    v.aximout.ar.id := std_logic_vector(to_unsigned(aximid, XID_WIDTH));

    case r.state is

      when idle =>

        v.ahbsout.hready   := '1';
        v.ahbsout.hresp    := HRESP_OKAY;
        v.aximout.ar.valid := '0';
        v.aximout.r.ready  := '0';
        v.aximout.aw.valid := '0';
        v.aximout.w.valid  := '0';
        v.aximout.b.ready  := '0';

        if (ahbsi.hsel(hindex) = '1' and ahbsi.hready = '1') then
          if (ahbsi.htrans = HTRANS_NONSEQ) or (ahbsi.htrans = HTRANS_SEQ) then
            v.ahbsout.hready := '0';
            if ahbsi.hwrite = '0' then
              v.state               := read;
              v.read_error          := '0';
              v.read_validated      := '0';
              v.aximout.ar.valid    := '1';
              v.addr_strb           := ahbsi.haddr(log2(AXIDW/8)-1 downto 0);
              --sample for the read address channel
              v.aximout.ar.addr     := ahbsi.haddr;
              v.aximout.ar.size     := ahbsi.hsize;
              v.aximout.ar.len      := (others => '0');
              v.aximout.ar.burst    := "01";
              v.aximout.ar.prot(0)  := ahbsi.hprot(1);
              v.aximout.ar.prot(2)  := not(ahbsi.hprot(0));
              v.aximout.ar.cache(0) := ahbsi.hprot(2);
              v.aximout.ar.cache(1) := ahbsi.hprot(3);
            else
              v.state               := write;
              v.write_error         := '0';
              v.wr_word_valid       := '0';
              v.write_validated     := '0';
              v.aximout.aw.valid    := '1';
              v.addr_strb           := ahbsi.haddr(log2(AXIDW/8)-1 downto 0);
              --sample for the write address channel
              v.aximout.aw.addr     := ahbsi.haddr;
              v.aximout.aw.size     := ahbsi.hsize;
              v.aximout.aw.len      := (others => '0');
              v.aximout.aw.burst    := "01";
              v.aximout.aw.prot(0)  := ahbsi.hprot(1);
              v.aximout.aw.prot(2)  := not(ahbsi.hprot(0));
              v.aximout.aw.cache(0) := ahbsi.hprot(2);
              v.aximout.aw.cache(1) := ahbsi.hprot(3);
            end if;
          end if;
        end if;

      when read =>

        v.ahbsout.hready := '0';

        if r.aximout.ar.valid = '1' and aximi.ar.ready = '1' then
          v.aximout.ar.valid := '0';
        end if;

        if r.read_validated = '0' then
          v.aximout.r.ready := '1';
        end if;

        if aximi.r.valid = '1' and r.aximout.r.ready = '1' then
          v.aximout.r.ready                                    := '0';
          v.read_validated                                     := '1';
          v.ahbsout.hrdata := aximi.r.data;
          if (aximi.r.resp = XRESP_SLVERR or aximi.r.resp = XRESP_DECERR) then
            v.read_error := '1';
          end if;
        end if;

        --make sure the read transaction dependencies has been met
        if v.aximout.ar.valid = '0' and v.aximout.r.ready = '0' and v.read_validated = '1' then
          v.state := idle;
          if v.read_error = '0' then
            v.ahbsout.hready := '1';
          else
            --read error, start two cycle propagation
            v.ahbsout.hresp := HRESP_ERROR;
            v.state         := error_p;
          end if;
        end if;


      when write =>

        v.ahbsout.hready := '0';

        if r.aximout.aw.valid = '1' and aximi.aw.ready = '1' then
          v.aximout.aw.valid := '0';
        end if;

        if r.wr_word_valid = '0' then
          v.aximout.w.valid := '1';
          v.aximout.w.last  := '1';
          v.wr_word_valid   := '1';
          v.aximout.b.ready := '1';
          v.aximout.w.data  := ahbsi.hwdata;
          v.aximout.w.strb := (others => '1');
        end if;

        if r.aximout.w.valid = '1' and aximi.w.ready = '1' then
          v.aximout.w.valid := '0';
          v.aximout.w.last  := '0';
        end if;

        if r.aximout.b.ready = '1' and aximi.b.valid = '1' then
          v.aximout.b.ready := '0';
          v.write_validated := '1';
          if (aximi.b.resp = XRESP_SLVERR or aximi.b.resp = XRESP_DECERR) then
            v.write_error := '1';
          end if;
        end if;

        --make sure the write transaction dependencies has been met
        if v.aximout.aw.valid = '0' and v.aximout.w.valid = '0' and v.write_validated = '1' then
          v.state := idle;
          if v.write_error = '0' then
            v.ahbsout.hready := '1';
          else
            --error start two cycle propagation
            v.ahbsout.hresp := HRESP_ERROR;
            v.state         := error_p;
          end if;
        end if;

      when error_p =>
        v.ahbsout.hresp  := HRESP_ERROR;
        v.ahbsout.hready := '1';
        v.state          := idle;
        v.read_error     := '0';
        v.write_error    := '0';

    end case;

    rin <= v;

    -- slave configuration info
    ahbso.hconfig <= hconfig;

  end process;

  syncregs : if not ASYNC_RESET generate
    regs : process(clk)
    begin
      if rising_edge(clk) then
        r <= rin;
        if rst = '0' then
          r <= RES_T;
        end if;
      end if;
    end process;
  end generate;

  asyncregs : if ASYNC_RESET generate
    regs : process(arst, clk)
    begin
      if arst = '0' then
        r <= RES_T;
      elsif rising_edge(clk) then
        r <= rin;
      end if;
    end process;
  end generate;

end rtl;
