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
-- Entity:      grdmac
-- File:        grdmac.vhd
-- Author:      Andrea Gianarro - Cobham Gaisler AB
-- Description: AMBA DMA controller with dual master interface
--              Supports scatter gather on unaligned data through internal
--              re-alignment buffer and conditional descriptors
------------------------------------------------------------------------------ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gencomp.all;
use work.config_types.all;
use work.config.all;
use work.amba.all;
use work.stdlib.all;
use work.grdmac_pkg.all;
use work.devices.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on

entity grdmac is
  generic (
    hmindex         : integer := 0; -- AHB master index
    hirq            : integer := 0;
    pindex          : integer := 0; -- APB configuration slave index
    paddr           : integer := 1;
    pmask           : integer := 16#FF0#;
    en_ahbm1        : integer range 0 to 1 := 0;
    hmindex1        : integer := 1; -- AHB master 1 index
    ndmach          : integer range 1 to 16 := 1;   -- number of DMA channels --TODO: implement ndmach = 0
    bufsize         : integer range 4*AHBDW/8 to 64*1024:= 256; -- number of bytes in buffer (must be a multiple of 4*WORD_SIZE)
    burstbound      : integer range 4 to 1024 := 512;
    en_timer        : integer := 0;
    memtech         : integer := 0;
    testen          : integer := 0;
    ft              : integer range 0 to 2  := 0;
    wbmask          : integer := 0;
    busw            : integer := 64
    );
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbmi       : in  ahb_mst_in_type;
    ahbmo       : out ahb_mst_out_type;
    ahbmi1      : in  ahb_mst_in_type;
    ahbmo1      : out ahb_mst_out_type;
    apbi        : in  apb_slv_in_type;
    apbo        : out apb_slv_out_type;
    irq_trig    : in  std_logic_vector(63 downto 0)
  );
end;

architecture rtl of grdmac is

  type conf_type is record
    en                : std_logic;
    rst               : std_logic;
    irq_en            : std_logic;
    irq_err_en        : std_logic;
    cvp               : std_logic_vector(31 downto 0);
    direct_mode       : std_logic;
    ch_err            : integer range 0 to ndmach-1;
    cvp_err           : std_logic;
    desc_err          : std_logic;
    ahb_err           : std_logic;
    cond_err          : std_logic;
    to_err            : std_logic;
    err               : std_logic;
    trans_size_limit  : std_logic_vector(1 downto 0);
    timer_en            : std_logic;
    timer_rst           : std_logic_vector(31 downto 0);
  end record;

  type desc_type is record
    en                : std_logic;
    irq_en            : std_logic;
    nextdescp         : std_logic_vector(31 downto 0);
    addr              : std_logic_vector(31 downto 0);
    size              : std_logic_vector(15 downto 0);
    ahbm_num          : std_logic;
    status            : std_logic;
    complete          : std_logic;
    ahb_err           : std_logic;
    write_back        : std_logic;
    fixed_addr        : std_logic;

    cond_en           : std_logic;
    cond_irq_trig     : std_logic;
    cond_addr_irqn    : std_logic_vector(31 downto 0);
    cond_mask         : std_logic_vector(31 downto 0);
    cond_op           : std_logic;
    cond_tot_size     : std_logic_vector(15 downto 0);
    cond_rem_size     : std_logic_vector(15 downto 0);
    cond_ahbm_num     : std_logic;
    cond_outcome      : std_logic;
  end record;

  type channel_type is record
    en                : std_logic;
    irq_en            : std_logic;
    status            : std_logic;
    complete          : std_logic;
    irq_flag          : std_logic;
  end record;

  type channel_vector is array (0 to ndmach-1) of channel_type;

  constant abits : integer := log2ext(bufsize);

  constant burstbit : integer := log2ext(burstbound);

  constant apbmax : integer := 19;

  constant wtbl : std_logic_vector(15 downto 0) :=  conv_std_logic_vector(wbmask, 16);

  constant VERSION   : amba_version_type := 2;

  constant pconfig: apb_config_type :=
    ( 0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRDMAC, 0, VERSION, hirq),
      1 => apb_iobar(paddr, pmask));

  type dma_state_type is (idle,
                          control,
                          fetch_cvp_pointers,
                          descriptor_transfer,
                          AHB_transfer,
                          conditional_poll,
                          conditional_trigger,
                          stall);

  type reg_type is record
    dma_state           : dma_state_type;
    active_chan         : integer range 0 to ndmach-1;
    conf                : conf_type;
    chan_conf           : channel_vector;
    fifo_write_p        : std_logic_vector(abits downto 0); --pointer to single bytes
    fifo_read_p         : std_logic_vector(abits downto 0); --pointer to single bytes
    m2bdescp            : std_logic_vector(31 downto 0);
    m2bdesc             : desc_type;
    b2mdescp            : std_logic_vector(31 downto 0);
    b2mdesc             : desc_type;
    irq                 : std_logic;

    trans_size          : std_logic_vector(2 downto 0);
    operation_direction : std_logic; -- 0 M2B,  1 B2M
    desc_direction      : std_logic; -- 0 read  1 write
    desc_type           : std_logic; -- 0 data desc, 1 cond desc
    cond_counter        : std_logic_vector(11 downto 0);
    cond_counter_rst    : std_logic_vector(11 downto 0);
    cond_timer_start    : std_logic;

    init_descriptors    : std_logic;
    hready              : std_logic;
    htrans              : std_logic_vector(1 downto 0);
    active              : std_logic;
    apb_acc             : std_logic;
    timer               : std_logic_vector(31 downto 0);
  end record;

  constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;

  constant DESC_RES  : desc_type :=
    ( en                  => '0',
      irq_en              => '0',
      nextdescp           => (others => '0'),
      addr                => (others => '0'),
      size                => (others => '0'),
      ahbm_num            => '0',
      status              => '0',
      complete            => '0',
      ahb_err             => '0',
      write_back          => '0',
      fixed_addr          => '0',
      cond_en             => '0',
      cond_irq_trig       => '0',
      cond_addr_irqn      => (others => '0'),
      cond_mask           => (others => '0'),
      cond_op             => '0',
      cond_tot_size       => (others => '0'),
      cond_rem_size       => (others => '0'),
      cond_ahbm_num       => '0',
      cond_outcome        => '0');
  constant CHAN_RES  : channel_type :=
    ( en                  => '0',
      irq_en              => '0',
      status              => '0',
      complete            => '0',
      irq_flag            => '0');
  constant CONF_RES  : conf_type :=
    ( en                  => '0',
      rst                 => '0',
      irq_en              => '0',
      irq_err_en          => '0',
      cvp                 => (others => '0'),
      direct_mode         => '0',
      ch_err              => 0,
      cvp_err             => '0',
      desc_err            => '0',
      ahb_err             => '0',
      cond_err            => '0',
      to_err              => '0',
      err                 => '0',
      trans_size_limit    => (others => '0'),
      timer_en            => '0',
      timer_rst           => (others => '0'));
  constant RES : reg_type :=
    ( dma_state           => idle,
      active_chan         => 0,
      conf                => CONF_RES,
      chan_conf           => (others => CHAN_RES),
      fifo_write_p        => (others => '0'),
      fifo_read_p         => (others => '0'),
      m2bdescp            => (others => '0'),
      m2bdesc             => DESC_RES,
      b2mdescp            => (others => '0'),
      b2mdesc             => DESC_RES,
      irq                 => '0',
      trans_size          => (others => '0'),
      operation_direction => '0',
      desc_direction      => '0',
      desc_type           => '0',
      cond_counter        => (others => '0'),
      cond_counter_rst    => (others => '0'),
      cond_timer_start    => '0',
      init_descriptors    => '0',
      hready              => '0',
      htrans              => (others => '0'),
      active              => '0',
      apb_acc             => '0',
      timer               => (others => '0'));
  
  signal dmai         : grdmac_ahb_dma_in_type;
  signal dmai1        : grdmac_ahb_dma_in_type;
  signal dmao         : grdmac_ahb_dma_out_type;
  signal dmao1        : grdmac_ahb_dma_out_type;

  signal l_ahbmo      : ahb_mst_out_type;
  signal fifoout      : std_logic_vector(AHBDW-1 downto 0);

  signal r, rin       : reg_type;
  signal buf_en       : std_logic;
  signal buf_wr       : std_logic;
  signal buf_offset   : std_logic_vector(log2(AHBDW/8)-1 downto 0);
  signal buf_address  : std_logic_vector(abits-1 downto 0);
  signal buf_size     : std_logic_vector(2 downto 0);
  signal buf_wdata    : std_logic_vector(AHBDW-1 downto 0);
  signal buf_rdata    : std_logic_vector(AHBDW-1 downto 0);

  signal rdescp       : std_logic_vector(31 downto 0);
  signal rdesc        : desc_type;
  signal rfifo_p      : std_logic_vector(abits downto 0);

begin

  comb : process(dmao, dmao1, r, rst, apbi, l_ahbmo, buf_wdata, irq_trig)
    variable v              : reg_type;
    variable vdmai          : grdmac_ahb_dma_in_type;
    variable vdmao          : grdmac_ahb_dma_out_type;
    variable inc            : std_logic_vector(log2(AHBDW/8) downto 0);
    variable pointer        : std_logic_vector(abits downto 0);
    variable tot_size       : std_logic_vector(15 downto 0);
    variable enable         : std_logic;
    variable write          : std_logic;
    variable vprdata        : std_logic_vector(31 downto 0);
    variable irq            : std_logic_vector(NAHBIRQ-1 downto 0);
    variable vdescp         : std_logic_vector(31 downto 0);
    variable vdesc          : desc_type;
    variable vfifo_p        : std_logic_vector(abits downto 0);
    variable desc_wdata     : std_logic_vector(31 downto 0);
    variable dec_wbmask     : std_logic;
    variable temp_ahbm_num  : std_logic;
    variable read_data      : std_logic_vector(31 downto 0);
    variable hready         : std_logic;
    variable hresp          : std_logic_vector(1 downto 0);
    variable active         : std_logic;
    variable cond_rem_size  : std_logic_vector(15 downto 0);
    variable timeout_error  : std_logic;
  begin

    v                 := r;
    v.irq             := '0';
    v.apb_acc         := '0';
    inc               := (others => '0');
    tot_size          := (others => '0');
    enable            := '0';
    write             := '0';
    pointer           := (others => '0');
    desc_wdata        := (others => '0');
    dec_wbmask        := '0';
    timeout_error     := '0';
    -- B2M
    rdesc    <= r.b2mdesc;
    rdescp   <= r.b2mdescp;
    rfifo_p  <= r.fifo_read_p;
    if r.operation_direction = '0' then --M2B
      rdesc    <= r.m2bdesc;
      rdescp   <= r.m2bdescp;
      rfifo_p  <= r.fifo_write_p;
    end if;

    vdesc   := rdesc;
    vdescp  := rdescp;
    vfifo_p := rfifo_p;

    vdmai.address     := (others => '0');
    vdmai.size        := (others => '0');
    vdmai.start       := '0';
    vdmai.burst       := '0';
    vdmai.idle        := '0';
    vdmai.first_beat  := '0';
    vdmai.write       := '0';
    vdmai.busy        := '0';
    vdmai.irq         := '0';

    if en_ahbm1 /= 0 and (
      (r.dma_state = AHB_transfer     and rdesc.ahbm_num = '1') or 
      (r.dma_state = conditional_poll and rdesc.cond_ahbm_num = '1') ) then
    -- AHB 1 master selected
      vdmao := dmao1;
    else
    -- default master is AHB 0
      vdmao := dmao;
    end if;

    if conv_integer(r.timer) /= 0 then
      v.timer := r.timer - 1;
    end if;

    temp_ahbm_num := '0';

    read_data := (others => '0');
    irq       := (others => '0');
    irq(hirq) := r.irq and r.conf.irq_en;

    vprdata := (others => '0');

    -- APB slave
    -- write (check we are not accessing the internal address debug space: paddr(11) = 0)
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite and not apbi.paddr(11)) = '1' then
      case apbi.paddr(7 downto 2) is
        when "000000" => -- 0x00 CONTROL REG
          v.conf.en               := apbi.pwdata(0);
          v.conf.rst              := apbi.pwdata(1);
          v.conf.irq_en           := apbi.pwdata(2);
          v.conf.irq_err_en       := apbi.pwdata(3);
          v.conf.direct_mode      := apbi.pwdata(4);
          v.conf.timer_en         := apbi.pwdata(5);
          v.conf.trans_size_limit := apbi.pwdata(13 downto 12);
          for i in 0 to ndmach-1 loop
            v.chan_conf(i).en     := apbi.pwdata(i+16);
          end loop ;
        when "000010" => -- 0x08 INTERRUPT MASK
          for i in 0 to ndmach-1 loop
            v.chan_conf(i).irq_en := apbi.pwdata(i);
          end loop ;
        when "000011" => -- 0x0C ERROR REGISTER: CLEAR ON 1
          v.conf.err              := r.conf.err       and (not apbi.pwdata(0));
          v.conf.cvp_err          := r.conf.cvp_err   and (not apbi.pwdata(1));
          v.conf.desc_err         := r.conf.desc_err  and (not apbi.pwdata(2));
          v.conf.ahb_err          := r.conf.ahb_err   and (not apbi.pwdata(3));
          v.conf.cond_err         := r.conf.cond_err  and (not apbi.pwdata(4));
          v.conf.to_err           := r.conf.to_err    and (not apbi.pwdata(5));
        when "000100" => -- 0x10 CHANNEL VECTOR POINTER
          v.conf.cvp(31 downto 7) := apbi.pwdata(31 downto 7);
          v.conf.cvp(6 downto 0)  := (others => '0');
        when "000101" => -- 0x14 TIMER RST VALUE REGISTER
          v.conf.timer_rst(31 downto 0) := apbi.pwdata(31 downto 0);
        when "000111" => -- 0x1C INTERRUPT FLAG REGISTER: CLEAR ON 1
          for i in 0 to ndmach-1 loop
            v.chan_conf(i).irq_flag := r.chan_conf(i).irq_flag and (not apbi.pwdata(i));
          end loop ;
        -- DIRECT MODE DESCRIPTORS
        when "001001" => -- 0x24 M2B DESCRIPTOR : START_ADDRESS
          v.m2bdesc.addr          := apbi.pwdata(31 downto 0);
        when "001010" => -- 0x28 M2B DESCRIPTOR : DESC_CONTROL
          v.m2bdesc.en            := '1';
          v.m2bdesc.irq_en        := apbi.pwdata(2);
          if en_ahbm1 /= 0 then
            v.m2bdesc.ahbm_num := apbi.pwdata(3);
          else
            v.m2bdesc.ahbm_num := '0';
          end if;
          v.m2bdesc.fixed_addr    := apbi.pwdata(4);
          v.m2bdesc.size          := apbi.pwdata(31 downto 16);
        when "001101" => -- 0x34 B2M DESCRIPTOR : START_ADDRESS
          v.b2mdesc.addr          := apbi.pwdata(31 downto 0);
        when "001110" => -- 0x38 B2M DESCRIPTOR : DESC_CONTROL
          v.b2mdesc.en            := '1';
          v.b2mdesc.irq_en        := apbi.pwdata(2);
          if en_ahbm1 /= 0 then
            v.b2mdesc.ahbm_num := apbi.pwdata(3);
          else
            v.b2mdesc.ahbm_num := '0';
          end if;
          v.b2mdesc.fixed_addr    := apbi.pwdata(4);
          v.b2mdesc.size          := apbi.pwdata(31 downto 16);
        when others => null; 
      end case;
    end if;

    --read
    if (apbi.psel(pindex) and not apbi.pwrite and not apbi.paddr(11)) = '1' then
      case apbi.paddr(7 downto 2) is
        when "000000" => -- 0x00 CONTROL REG
          vprdata(0)            := r.conf.en;
          vprdata(1)            := r.conf.rst;
          vprdata(2)            := r.conf.irq_en;
          vprdata(3)            := r.conf.irq_err_en;
          vprdata(4)            := r.conf.direct_mode;
          vprdata(5)            := r.conf.timer_en;
          vprdata(13 downto 12) := r.conf.trans_size_limit;
          for i in 0 to ndmach-1 loop
            vprdata(i+16)       := r.chan_conf(i).en;
          end loop ;
        when "000001" => -- 0x04 STATUS REG
          for i in 0 to ndmach-1 loop
            vprdata(i)          := r.chan_conf(i).complete;
            vprdata(i+16)       := r.chan_conf(i).status;
          end loop ;
        when "000010" => -- 0x08 INTERRUPT MASK
          for i in 0 to ndmach-1 loop
            vprdata(i)          := r.chan_conf(i).irq_en;
          end loop;
        when "000011" => -- 0x0C ERROR REGISTER
          vprdata(0)            := r.conf.err;
          vprdata(1)            := r.conf.cvp_err;
          vprdata(2)            := r.conf.desc_err;
          vprdata(3)            := r.conf.ahb_err;
          vprdata(4)            := r.conf.cond_err;
          vprdata(5)            := r.conf.to_err;
          vprdata(19 downto 16) := conv_std_logic_vector(r.conf.ch_err, 4);
        when "000100" => -- 0x10 CHANNEL VECTOR POINTER
          vprdata(31 downto 7)  := r.conf.cvp(31 downto 7);
        when "000101" => -- 0x14 TIMER RST VALUE REGISTER
          vprdata(31 downto 0)  := r.conf.timer_rst(31 downto 0);
        when "000110" => -- 0x18 CAPABILITY REGISTER
          vprdata(3 downto 0)   := conv_std_logic_vector(VERSION, 4);
          vprdata(7 downto 4)   := conv_std_logic_vector(ndmach-1, 4);
          if en_ahbm1 = 0 then
            vprdata(8)            := '0';
          else
            vprdata(8)            := '1';
          end if;
          vprdata(10 downto 9)  := conv_std_logic_vector(ft, 2);
          if en_timer = 0 then
            vprdata(11)            := '0';
          else
            vprdata(11)            := '1';
          end if;
          vprdata(31 downto 16) := conv_std_logic_vector(abits, 16);
        when "000111" => -- 0x1C INTERRUPT FLAG REGISTER
          for i in 0 to ndmach-1 loop
            vprdata(i)          := r.chan_conf(i).irq_flag;
          end loop ;
        when "001000" => -- 0x20 M2B DESCRIPTOR : NEXT_POINTER
          vprdata               := r.m2bdesc.nextdescp(31 downto 4) & "0000";
        when "001001" => -- 0x24 M2B DESCRIPTOR : START_ADDRESS
          vprdata               := r.m2bdesc.addr;
        when "001010" => -- 0x28 M2B DESCRIPTOR : DESC_CONTROL
          vprdata(0)            := r.m2bdesc.en;
          vprdata(2)            := r.m2bdesc.irq_en;
          vprdata(3)            := r.m2bdesc.ahbm_num;
          vprdata(4)            := r.m2bdesc.fixed_addr;
          vprdata(31 downto 16) := r.m2bdesc.size;
        when "001011" => -- 0x2C M2B DESCRIPTOR : DESC_STATUS
          vprdata(0)            := r.m2bdesc.complete;
          vprdata(1)            := r.m2bdesc.status;
          vprdata(2)            := r.m2bdesc.ahb_err;
        when "001100" => -- 0x30 B2M DESCRIPTOR : NEXT_POINTER
          vprdata               := r.b2mdesc.nextdescp(31 downto 4) & "0000";
        when "001101" => -- 0x34 B2M DESCRIPTOR : START_ADDRESS
          vprdata               := r.b2mdesc.addr;
        when "001110" => -- 0x38 B2M DESCRIPTOR : DESC_CONTROL
          vprdata(0)            := r.b2mdesc.en;
          vprdata(2)            := r.b2mdesc.irq_en;
          vprdata(3)            := r.b2mdesc.ahbm_num;
          vprdata(4)            := r.b2mdesc.fixed_addr;
          vprdata(31 downto 16) := r.b2mdesc.size;
        when "001111" => -- 0x3C B2M DESCRIPTOR : DESC_STATUS
          vprdata(0)            := r.b2mdesc.complete;
          vprdata(1)            := r.b2mdesc.status;
          vprdata(2)            := r.b2mdesc.ahb_err;
        when "010000" => -- 0x40 INTERNAL DEBUG BYPASS POINTERS
          if abits < 16 then
            vprdata(31 downto 16) := zero32(15 downto abits) & r.fifo_read_p(abits-1 downto 0);
            vprdata(15 downto  0) := zero32(15 downto abits) & r.fifo_write_p(abits-1 downto 0);
          else
            vprdata(31 downto 16) := r.fifo_read_p(15 downto 0);
            vprdata(15 downto  0) := r.fifo_write_p(15 downto 0);
          end if;
        when others =>
      end case;
    elsif (apbi.psel(pindex) and not apbi.pwrite and apbi.paddr(11)) = '1' then -- debug read from internal buffer
      if r.dma_state = idle and r.conf.en = '0' then
        -- only access max 2 KiB of the internal buffer due to APB memory mapping constraints
        if abits > 10 then
          pointer(10 downto 0) := apbi.paddr(10 downto 0);
        else
          pointer(abits downto 0) := apbi.paddr(abits downto 0);
        end if;
        vdmai.size  := "010";
        v.apb_acc   := '1';
        enable := '1';
      end if;
    end if;
    -- DMA state machine
    case r.dma_state is
      when idle =>
        if r.conf.en = '1' and r.conf.err = '0' then
          if r.conf.direct_mode = '0' then -- normal operation mode
            if r.chan_conf(r.active_chan).en = '1' and r.chan_conf(r.active_chan).complete = '0' then
              v.dma_state := fetch_cvp_pointers;
              v.chan_conf(r.active_chan).status := '1'; -- running
            else
              if r.active_chan < ndmach - 1 then
                v.active_chan := r.active_chan + 1;
              end if;
            end if;
          else -- direct mode, single descriptor chains!
            if r.chan_conf(0).en = '1' and r.chan_conf(0).complete = '0' then
              v.m2bdesc.nextdescp := (others => '0');
              v.b2mdesc.nextdescp := (others => '0');
              v.dma_state := control;
              v.chan_conf(r.active_chan).status := '1'; -- running
            end if;
          end if;
        end if;
      when control => -- main sequencer
        if bufsize - conv_integer(r.fifo_write_p) /= 0 and conv_integer(r.m2bdesc.size) > 0 and r.m2bdesc.en = '1' then
          if r.m2bdesc.cond_en = '1' and r.m2bdesc.cond_outcome = '0' then -- executing a conditional descriptor
            if r.m2bdesc.cond_irq_trig = '0' then
              if r.cond_counter = r.cond_counter_rst then
                v.dma_state                         := conditional_poll;
              else
                v.cond_counter := r.cond_counter + 1;
              end if;
            else
              v.dma_state                         := conditional_trigger;
            end if;
            if r.cond_timer_start = '0' and r.conf.timer_en = '1' then
               v.timer := r.conf.timer_rst;
               v.cond_timer_start := '1';
            end if;
          else
            v.m2bdesc.cond_outcome              := '0';
            v.dma_state                         := AHB_transfer;
          end if;
          v.operation_direction                 := '0'; --M2B
          v.m2bdesc.status                      := '1';
        elsif bufsize - conv_integer(r.fifo_write_p) /= 0 and r.m2bdesc.nextdescp /= zero32 then
            v.dma_state                         := descriptor_transfer;
            v.m2bdescp                          := r.m2bdesc.nextdescp;
            v.desc_direction                    := '0'; --read
            v.operation_direction               := '0'; --M2B
        else
          if conv_integer(r.b2mdesc.size) > 0 and r.b2mdesc.en = '1' then
            if r.b2mdesc.cond_en = '1' and r.b2mdesc.cond_outcome = '0' then -- executing a conditional descriptor
              if r.b2mdesc.cond_irq_trig = '0' then
                if r.cond_counter = r.cond_counter_rst then
                  v.dma_state                       := conditional_poll;
                else
                  v.cond_counter := r.cond_counter + 1;
                end if;
              else
                v.dma_state                       := conditional_trigger;
              end if;
              if r.cond_timer_start = '0' and r.conf.timer_en = '1' then
                 v.timer := r.conf.timer_rst;
                 v.cond_timer_start := '1';
              end if;
            else
              v.b2mdesc.cond_outcome            := '0';
              v.dma_state                       := AHB_transfer;
            end if;
            v.operation_direction               := '1'; --B2M
            v.b2mdesc.status                    := '1';
          elsif r.b2mdesc.nextdescp /= zero32 then
            v.dma_state                         := descriptor_transfer;
            v.b2mdescp                          := r.b2mdesc.nextdescp;
            v.desc_direction                    := '0'; --read
            v.operation_direction               := '1'; --B2M
          else -- end channel
            if r.active_chan < ndmach - 1 then -- TODO see if it can be removed
              v.active_chan                     := r.active_chan + 1;
            end if;
            v.chan_conf(r.active_chan).complete := '1';
            v.chan_conf(r.active_chan).status   := '0'; -- not running anymore
            -- go to next channel
            v.dma_state                         := idle;
          end if;
        end if;
      when fetch_cvp_pointers =>
        if vdmao.active = '1' then
          vdmai.address := r.conf.cvp(31 downto 7) & (r.conf.cvp(6 downto 0) + "100");
        else
          vdmai.address := r.conf.cvp(31 downto 7) & conv_std_logic_vector(r.active_chan, 4) & "000";
        end if;

        if r.conf.cvp(2) = '1' and vdmao.active = '1' then -- idle last ctrl cycle
          vdmai.idle   := '1';
        end if;
          
        vdmai.start   := '1';
        vdmai.burst   := '1';
        vdmai.size    := "010";
        -- no 1kB boundary here
        if vdmao.active = '1' and vdmao.ready = '1' then
          if vdmao.mexc = '0' then
            v.conf.cvp  := vdmai.address;
            read_data   := ahbreadword(vdmao.rdata, r.conf.cvp(4 downto 2));
            case r.conf.cvp(2) is
              when '0' => -- M2B DESC pointer
                v.m2bdescp := read_data;
              when '1' => -- B2M DESC pointer
                v.b2mdescp := read_data;
              when others => 
            end case ;
            if vdmai.idle = '1' then
              v.dma_state := descriptor_transfer;
              v.operation_direction := '0'; --M2B
              v.init_descriptors := '1';
              v.desc_direction := '0'; -- read
            end if;
          else
            vdmai.idle                          := '1';
            v.irq                               := r.conf.irq_err_en;
            v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
            v.chan_conf(r.active_chan).status   := '0';
            v.conf.ch_err                       := r.active_chan;
            v.conf.err                          := '1';
            v.conf.cvp_err                      := '1';
            v.dma_state                         := idle;
          end if;
        end if;
      when conditional_poll => -- poll register and check for termination condition
        vdmai.address := rdesc.cond_addr_irqn;

        if vdmao.active = '1' then -- idle last ctrl cycle
          vdmai.idle   := '1';
        end if;
          
        vdmai.start   := '1';
        vdmai.burst   := '0';
        vdmai.size    := "010";
        -- time-out error when timer is started and timer is 0 
        timeout_error := r.cond_timer_start and not orv(r.timer);
        -- no 1kB boundary here
        if vdmao.active = '1' and vdmao.ready = '1' then
          if vdmao.mexc = '0' and timeout_error = '0' then
            read_data   := ahbreadword(vdmao.rdata, rdesc.cond_addr_irqn(4 downto 2));
            vdesc.cond_outcome := orv(read_data and rdesc.cond_mask);
            if vdesc.cond_outcome = vdesc.cond_op then
              v.cond_timer_start := '0';
            end if;
            if vdmai.idle = '1' then
              v.dma_state := control;
              vdesc.cond_rem_size := rdesc.cond_tot_size;
              v.cond_counter := (others => '0');
            end if;
          else
            vdmai.idle                          := '1';
            v.irq                               := r.conf.irq_err_en;
            v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
            v.chan_conf(r.active_chan).status   := '0';
            v.conf.ch_err                       := r.active_chan;
            v.conf.err                          := '1';
            v.conf.cond_err                     := '1';
            v.conf.to_err                       := timeout_error;
            v.dma_state                         := idle;
          end if;
        end if;

        if r.operation_direction = '0' then
          v.m2bdesc  := vdesc;
          v.m2bdescp := vdescp;
        else
          v.b2mdesc  := vdesc;
          v.b2mdescp := vdescp;
        end if;
      when conditional_trigger => -- wait for signal trigger
        -- time-out error when timer is started and timer is 0 
        timeout_error := r.cond_timer_start and not orv(r.timer);

        if timeout_error = '1' then
          v.irq                               := r.conf.irq_err_en;
          v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
          v.chan_conf(r.active_chan).status   := '0';
          v.conf.ch_err                       := r.active_chan;
          v.conf.err                          := '1';
          v.conf.cond_err                     := '1';
          v.conf.to_err                       := timeout_error;
          v.dma_state                         := idle;
        elsif irq_trig(conv_integer(rdesc.cond_addr_irqn(5 downto 0))) = '1' then
          vdesc.cond_outcome := '1';
          vdesc.cond_rem_size := rdesc.cond_tot_size;
          v.cond_timer_start := '0';
          v.dma_state := control;
        end if;

        if r.operation_direction = '0' then
          v.m2bdesc  := vdesc;
          v.m2bdescp := vdescp;
        else
          v.b2mdesc  := vdesc;
          v.b2mdescp := vdescp;
        end if;
      when descriptor_transfer => -- fetch M2B descriptor, 32-B aligned, 4- or 8-word read
        
        if vdmao.active = '1' then
          if r.desc_direction = '0' then
            vdmai.address := rdescp(31 downto 4) & (rdescp(3 downto 0) + "0100");
          else
            vdmai.address := rdescp(31 downto 4) & "0000";
          end if;
        else
          if r.desc_direction = '0' then
            vdmai.address := rdescp;
          else
            vdmai.address := rdescp(31 downto 4) & "1100";
          end if;
        end if;

        -- idle last ctrl cycle
        if  (r.desc_direction = '0' and
            ( (r.desc_type = '0' and rdescp(3 downto 2) = "10") or -- read up to 0x08
              (r.desc_type = '1' and rdescp(3 downto 2) = "11"))) or -- read up to 0x0C if conditional desc
            (r.desc_direction = '1' and vdmao.active = '1') then
          vdmai.idle   := '1';
        end if;
        
        vdmai.write := r.desc_direction;
        vdmai.start   := '1';
        vdmai.burst   := '1';
        vdmai.size    := "010";
        if vdmao.active = '1' and vdmao.ready = '1' then
          if vdmao.mexc = '0' then
            vdescp    := vdmai.address;
            read_data := ahbreadword(vdmao.rdata, rdescp(4 downto 2));
            if r.desc_direction = '1' then -- writing back descriptor
              -- status
              desc_wdata(0)   := rdesc.complete;
              desc_wdata(1)   := rdesc.status;
              desc_wdata(2)   := rdesc.ahb_err;
            else
              case rdescp(3 downto 2) is
                when "00" => -- next desc
                  vdesc.nextdescp := read_data(31 downto 4) & "0000";
                  v.desc_type     := read_data(0);
                when "01" => -- read addr
                  if r.desc_type = '0' then
                    vdesc.addr            := read_data;
                  else
                    vdesc.cond_addr_irqn  := read_data;
                  end if;
                when "10" => -- control
                  if  en_ahbm1 /= 0 then
                    temp_ahbm_num := read_data(3);
                  end if;
                  if r.desc_type = '0' then
                    vdesc.en                := read_data(0);
                    vdesc.write_back        := read_data(1);
                    vdesc.irq_en            := read_data(2);
                    vdesc.ahbm_num          := temp_ahbm_num;
                    vdesc.fixed_addr        := read_data(4);
                    vdesc.size              := read_data(31 downto 16);
                  else
                    vdesc.cond_en           := read_data(0);
                    vdesc.cond_irq_trig     := read_data(1);
                    vdesc.cond_op           := read_data(2);
                    vdesc.cond_ahbm_num     := temp_ahbm_num;
                    v.cond_counter_rst      := read_data(15 downto 4);
                    v.cond_timer_start      := '0';
                    vdesc.cond_tot_size     := read_data(31 downto 16);
                  end if;
                when "11" => -- cond.mask
                  vdesc.cond_mask   := read_data;
                when others => 
              end case ;
            end if;
            if vdmai.idle = '1' then
              if r.desc_type = '1' then -- fetch data descriptor after fetching the condition descriptor
                v.desc_type   := '0';
                vdescp := rdesc.nextdescp;
              elsif r.init_descriptors = '1' then -- initing the first two descriptors (M2B and B2M)
                v.operation_direction := '1'; --B2M
                v.init_descriptors := '0';
              elsif r.conf.err = '1' then
                if rdesc.write_back = '1' then --on error and desc wb, generate irq!
                  v.irq                               := r.conf.irq_err_en;
                  v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
                end if;
                v.dma_state := idle;
              else
                if rdesc.write_back = '1' and r.desc_direction = '1' and rdesc.complete = '1' then -- irq generation on completion after write back
                  v.irq := rdesc.irq_en and r.chan_conf(r.active_chan).irq_en;
                  v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
                end if;
                v.dma_state := control;
              end if;
            end if;
          else
            vdmai.idle                          := '1';
            v.irq                               := r.conf.irq_err_en;
            v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
            v.chan_conf(r.active_chan).status   := '0';
            v.conf.ch_err                       := r.active_chan;
            v.conf.err                          := '1';
            v.conf.desc_err                     := '1';
            v.dma_state                         := idle;
          end if;
        end if;

        if r.operation_direction = '0' then
          v.m2bdesc  := vdesc;
          v.m2bdescp := vdescp;
        else
          v.b2mdesc  := vdesc;
          v.b2mdescp := vdescp;
        end if;
      when AHB_transfer =>
        if vdmao.active = '1' then
          inc(conv_integer(r.trans_size(2 downto 0))) := '1';
          if rdesc.fixed_addr = '0' then
            vdmai.address := rdesc.addr + inc;
          else
            vdmai.address := rdesc.addr;
          end if;
        else
          vdmai.address := rdesc.addr;
        end if;
        
        vdmai.start   := '1';
        tot_size      := rdesc.size - inc;
        pointer       := rfifo_p + inc;
        cond_rem_size := rdesc.cond_rem_size - inc;

        dec_wbmask := wtbl(conv_integer(vdmai.address(31 downto 28)));

        -- unaligned access check, up to 128b word alignment
        if    AHBDW >= 128 and busw >= 128 and dec_wbmask = '1'
              and ( r.conf.trans_size_limit = "00" or r.conf.trans_size_limit >= "11" )
              and vdmai.address(3 downto 0) = "0000" and conv_integer(tot_size) >= 16
              and bufsize - conv_integer(pointer) >= 16
              and (rdesc.cond_en = '0' or conv_integer(cond_rem_size) >= 16) then --qword aligned
          vdmai.burst := '1' and not rdesc.fixed_addr;
          vdmai.size := "100";
        elsif AHBDW >= 64 and busw >= 64 and dec_wbmask = '1'
              and ( r.conf.trans_size_limit = "00" or r.conf.trans_size_limit >= "10" )
              and vdmai.address(2 downto 0) = "000" and conv_integer(tot_size) >= 8
              and bufsize - conv_integer(pointer) >= 8
              and (rdesc.cond_en = '0' or conv_integer(cond_rem_size) >= 8) then --dword aligned
          vdmai.burst := '1' and not rdesc.fixed_addr;
          vdmai.size := "011";
        elsif vdmai.address(1 downto 0) = "00" and conv_integer(tot_size) >= 4
              and bufsize - conv_integer(pointer) >= 4
              and (rdesc.cond_en = '0' or conv_integer(cond_rem_size) >= 4) then --word aligned
          vdmai.burst := '1' and not rdesc.fixed_addr;
          vdmai.size := "010";
        elsif vdmai.address(0) = '0' and conv_integer(tot_size) >= 2
              and bufsize - conv_integer(pointer) >= 2
              and (rdesc.cond_en = '0' or conv_integer(cond_rem_size) >= 2) then --half word aligned
          vdmai.burst := '0';
          vdmai.size := "001";
        else --if size = 1 or address(0) = '1' then --byte aligned
          vdmai.burst := '0';
          vdmai.size := "000";
        end if;

        if (rdesc.addr(1 downto 0) /= "00" and vdmai.address(1 downto 0) = "00") or -- starting 32bit aligned transfer
          (r.trans_size /= vdmai.size) then                                         -- starting new burst with different size
          vdmai.first_beat := '1'; -- burst initial transfer
        end if;

        if (rdesc.addr(burstbit) xor vdmai.address(burstbit)) = '1' then -- burst limitation
          vdmai.idle := '1';
        end if;

        if bufsize - conv_integer(pointer) = 0 or conv_integer(tot_size) = 0 then -- buffer empty/full or descriptor done
          vdmai.idle := '1';
        end if;

        if rdesc.cond_en = '1' and conv_integer(cond_rem_size) = 0 then
          vdmai.idle := '1';
        end if;

        if vdmao.active = '1' then
          if vdmao.ready = '1' then
            if vdmao.mexc = '0' then
              enable := '1';
              vdesc.addr := vdmai.address;
              vdesc.size := tot_size;
              vfifo_p := pointer;
              v.trans_size := vdmai.size;
              vdesc.cond_rem_size := cond_rem_size;
              if r.operation_direction = '0' then
                write :=  '1';
              else
                write :=  '0';
                if bufsize - conv_integer(pointer) = 0 then -- B2M emptied buffer
                  v.fifo_write_p  := (others => '0');
                  --v.fifo_read_p   := (others => '0');
                  vfifo_p         := (others => '0');
                end if;
              end if;
              if  bufsize - conv_integer(pointer) = 0                               -- buffer full/empty
                  or conv_integer(tot_size) = 0                                    -- descriptor completed
                  or (rdesc.cond_en = '1' and conv_integer(cond_rem_size) = 0) then -- condition size read/written
                v.dma_state := control;
                if conv_integer(tot_size) = 0 then
                  vdesc.status    := '0';
                  vdesc.complete  := '1';
                  vdesc.cond_en   := '0';
                  if rdesc.write_back = '1' then
                    v.dma_state := descriptor_transfer;
                    v.desc_direction := '1'; --write
                  else
                    v.irq := rdesc.irq_en and r.chan_conf(r.active_chan).irq_en;
                    v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
                  end if;
                end if;
              end if;
            else
              vdmai.idle                          := '1';
              v.conf.ch_err                       := r.active_chan;
              v.conf.err                          := '1';
              v.conf.ahb_err                      := '1';
              vdesc.ahb_err                       := '1';
              v.chan_conf(r.active_chan).status   := '0';
              if rdesc.write_back = '1' then
                v.dma_state                         := descriptor_transfer;
                v.desc_direction                    := '1'; --write
              else -- simplified mode is included in this case
                v.irq                               := r.conf.irq_err_en;
                v.chan_conf(r.active_chan).irq_flag := v.irq and r.conf.irq_en;
                v.dma_state := idle;
              end if;
            end if;
          end if;
        else -- dmao.active = '0'
          v.trans_size := vdmai.size;
          enable := '1'; --reading first data
        end if;

        if r.operation_direction = '0' then
          v.m2bdesc  := vdesc;
          v.m2bdescp := vdescp;
          v.fifo_write_p := vfifo_p;
          vdmai.write := '0';
        else
          v.b2mdesc  := vdesc;
          v.b2mdescp := vdescp;
          v.fifo_read_p := vfifo_p;
          vdmai.write := '1';
        end if;
      when others =>
    end case ;

    if en_timer = 0 then
      v.timer             := (others => '0');
      v.conf.timer_en     := '0';
      v.conf.timer_rst    := (others => '0');
      v.cond_timer_start  := '0';
    end if;

    -- IRQ routing and filtering
    ahbmo       <= l_ahbmo;
    ahbmo.hirq  <= irq; --overriding internal master IRQ, which is unused

    if (not RESET_ALL) and (rst = '0' or r.conf.rst = '1') then
      v.fifo_write_p              := (others => '0');
      v.fifo_read_p               := (others => '0');
      v.operation_direction       := '0';
      v.dma_state                 := idle;
      v.active_chan               := 0;
      v.init_descriptors          := '0';
      v.cond_counter              := (others => '0');
      v.timer                     := (others => '0');
      v.desc_type                 := '0';
      v.conf.rst                  := '0';
      v.conf.en                   := '0';
      v.conf.err                  := '0';
      v.conf.cvp_err              := '0';
      v.conf.desc_err             := '0';
      v.conf.ahb_err              := '0';
      v.conf.cond_err             := '0';
      v.conf.to_err               := '0';
      v.conf.timer_en             := '0';
      v.conf.timer_rst            := (others => '0');
      v.desc_direction            := '0';
      v.m2bdesc.complete          := '0';
      v.m2bdesc.status            := '0';
      v.m2bdesc.ahb_err           := '0';
      v.m2bdesc.cond_en           := '0';
      v.m2bdesc.cond_outcome      := '0';
      v.m2bdesc.cond_rem_size     := (others => '0');
      v.b2mdesc.complete          := '0';
      v.b2mdesc.status            := '0';
      v.b2mdesc.ahb_err           := '0';
      v.b2mdesc.cond_en           := '0';
      v.b2mdesc.cond_outcome      := '0';
      v.b2mdesc.cond_rem_size     := (others => '0');
      for i in 0 to ndmach-1 loop
        v.chan_conf(i).status     := '0';
        v.chan_conf(i).complete   := '0';
      end loop;
    end if;

    rin <= v;


    -- drive AHB 0 Master input
    dmai.address <= vdmai.address;
    dmai.size <= vdmai.size;
    dmai.start <= vdmai.start;
    dmai.burst <= vdmai.burst;
    dmai.first_beat <= vdmai.first_beat;
    dmai.idle <= vdmai.idle;
    dmai.write <= vdmai.write;
    dmai.busy <= vdmai.busy;
    dmai.irq <= vdmai.irq;
    
    dmai.wdata <= buf_wdata;
    if r.dma_state = descriptor_transfer then
      dmai.wdata <= ahbdrivedata(desc_wdata);
    end if;

    dmai1 <= grdmac_ahb_dma_in_none;

    if en_ahbm1 /= 0 and (
      (r.dma_state = AHB_transfer     and rdesc.ahbm_num = '1') or 
      (r.dma_state = conditional_poll and rdesc.cond_ahbm_num = '1') ) then
    -- AHB 1 master selected
      dmai1.address <= vdmai.address;
      dmai1.size <= vdmai.size;
      dmai1.start <= vdmai.start;
      dmai1.burst <= vdmai.burst;
      dmai1.first_beat <= vdmai.first_beat;
      dmai1.idle <= vdmai.idle;
      dmai1.write <= vdmai.write;
      dmai1.busy <= vdmai.busy;
      dmai1.irq <= vdmai.irq;
      dmai1.wdata <= buf_wdata;

      dmai <= grdmac_ahb_dma_in_none;
    end if;

    -- drive buffer inputs
    buf_offset  <= vdmai.address(log2(AHBDW/8)-1 downto 0);
    buf_address <= pointer(abits-1 downto 0);
    buf_size    <= vdmai.size;
    if r.operation_direction = '0' then
      buf_offset  <= r.m2bdesc.addr(log2(AHBDW/8)-1 downto 0);
      buf_address <= r.fifo_write_p(abits-1 downto 0);
      buf_size    <= r.trans_size;
    end if;

    buf_en <= enable;
    buf_wr <= write;
    buf_rdata <= vdmao.rdata;
    
    if r.apb_acc = '1' then
      vprdata := buf_wdata(31 downto 0);
    end if;

    -- drive APB outputs
    apbo <= ( prdata  => vprdata,
              pirq    => (others => '0'),
              pconfig => pconfig,
              pindex  => pindex);
  end process;


  reg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES;
      end if;
    end if;
  end process;

  -- AHB internal master
  dma_mst0: grdmac_ahbmst
    generic map (
      hindex  => hmindex,
      venid   => VENDOR_GAISLER,
      devid   => GAISLER_GRDMAC,
      version => VERSION,
      hirq    => hirq,
      chprot  => 3,
      incaddr => 0)
    port map (rst, clk, dmai, dmao, ahbmi, l_ahbmo);

  -- AHB second internal master
  dma_mst1_en: if en_ahbm1 /= 0 generate
    dma_mst1: grdmac_ahbmst
      generic map (
        hindex  => hmindex1,
        venid   => VENDOR_GAISLER,
        devid   => GAISLER_GRDMAC,
        version => VERSION,
        hirq    => hirq,
        chprot  => 3,
        incaddr => 0)
      port map (rst, clk, dmai1, dmao1, ahbmi1, ahbmo1);
  end generate;

  dma_mst1_dis: if en_ahbm1 = 0 generate
    dmao1  <= grdmac_ahb_dma_none;
    ahbmo1 <= ahbm_none;
  end generate;

  -- buffer with support for unaligned read/write
  ram: grdmac_alignram
    generic map (
      memtech => memtech,
      abits   => abits,
      dbits   => AHBDW,
      testen  => testen,
      ft      => ft)
    port map (
      clk         => clk,
      rst         => rst,
      enable      => buf_en,
      write       => buf_wr,
      address     => buf_address,
      size        => buf_size,
      dataout     => buf_wdata,
      datain      => buf_rdata,
      data_offset => buf_offset);

end architecture ; -- rtl
