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
----------------------------------------------------------------------------
-- Entity:      ahbctrl
-- File:        ahbctrl.vhd
-- Author:      Jiri Gaisler, Gaisler Research
-- Modified:    Edvin Catovic, Gaisler Research
-- Description: AMBA arbiter, decoder and multiplexer with plug&play support
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.stdlib.all;
use work.amba.all;
use work.config_types.all;
use work.config.all;
-- pragma translate_off
use work.devices.all;
use std.textio.all;
-- pragma translate_on

entity ahbctrl is
  generic (
    defmast     : integer := 0;         -- default master
    split       : integer := 0;         -- split support
    rrobin      : integer := 0;         -- round-robin arbitration
    timeout     : integer range 0 to 255 := 0;  -- HREADY timeout
    ioaddr      : ahb_addr_type := 16#fff#;  -- I/O area MSB address
    iomask      : ahb_addr_type := 16#fff#;  -- I/O area address mask
    cfgaddr     : ahb_addr_type := 16#ff0#;  -- config area MSB address
    cfgmask     : ahb_addr_type := 16#ff0#;  -- config area address mask
    nahbm       : integer range 1 to NAHBMST := NAHBMST; -- number of masters
    nahbs       : integer range 1 to NAHBSLV := NAHBSLV; -- number of slaves
    ioen        : integer range 0 to 15 := 1;    -- enable I/O area
    disirq      : integer range 0 to 1 := 0;     -- disable interrupt routing
    fixbrst     : integer range 0 to 1 := 0;     -- support fix-length bursts
    debug       : integer range 0 to 2 := 2;     -- report cores to console
    fpnpen      : integer range 0 to 1 := 0; -- full PnP configuration decoding
    icheck      : integer range 0 to 1 := 1;
    devid       : integer := 0;              -- unique device ID
    enbusmon    : integer range 0 to 1 := 0; --enable bus monitor
    assertwarn  : integer range 0 to 1 := 0; --enable assertions for warnings
    asserterr   : integer range 0 to 1 := 0; --enable assertions for errors
    hmstdisable : integer := 0; --disable master checks
    hslvdisable : integer := 0; --disable slave checks
    arbdisable  : integer := 0; --disable arbiter checks
    mprio       : integer := 0; --master with highest priority
    mcheck      : integer range 0 to 2 := 1; --check memory map for intersects
    ccheck      : integer range 0 to 1 := 1; --perform sanity checks on pnp config
    acdm        : integer := 0;  --AMBA compliant data muxing (for hsize > word)
    index       : integer := 0;  --Index for trace print-out
    ahbtrace    : integer := 0;  --AHB trace enable
    hwdebug     : integer := 0;  --Hardware debug
    fourgslv    : integer := 0   --1=Single slave with single 4 GB bar
  );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    msti    : out ahb_mst_in_type;
    msto    : in  ahb_mst_out_vector;
    slvi    : out ahb_slv_in_type;
    slvo    : in  ahb_slv_out_vector;
    testen  : in  std_ulogic := '0';
    testrst : in  std_ulogic := '1';
    scanen  : in  std_ulogic := '0';
    testoen : in  std_ulogic := '1';
    testsig : in  std_logic_vector(1+GRLIB_CONFIG_ARRAY(grlib_techmap_testin_extra) downto 0) := (others => '0')
  );
end;

architecture rtl of ahbctrl is

constant nahbmx : integer := 2**log2(nahbm);
type nmstarr is array (1 to 3) of integer range 0 to nahbmx-1;
type nvalarr is array (1 to 3) of boolean;

type reg_type is record
  hmaster      : integer range 0 to nahbmx -1;
  hmasterd     : integer range 0 to nahbmx -1;
  hslave       : integer range 0 to nahbs-1;
  hmasterlock  : std_ulogic;
  hmasterlockd : std_ulogic;
  hready       : std_ulogic;
  defslv       : std_ulogic;
  htrans       : std_logic_vector(1 downto 0);
  hsize        : std_logic_vector(2 downto 0);
  haddr        : std_logic_vector(15 downto 2);
  cfgsel       : std_ulogic;
  cfga11       : std_ulogic;
  hrdatam      : std_logic_vector(31 downto 0);
  hrdatas      : std_logic_vector(31 downto 0);
  beat         : std_logic_vector(3 downto 0);
  defmst       : std_ulogic;
  ldefmst      : std_ulogic;
  lsplmst      : integer range 0 to nahbmx-1;
end record;

constant RESET_ALL : boolean := GRLIB_CONFIG_ARRAY(grlib_sync_reset_enable_all) = 1;
constant RES_r : reg_type := (
  hmaster => 0, hmasterd => 0, hslave => 0, hmasterlock => '0',
  hmasterlockd => '0', hready => '1', defslv => '0',
  htrans => HTRANS_IDLE, hsize => (others => '0'),
  haddr => (others => '0'), cfgsel => '0', cfga11 => '0',
  hrdatam => (others => '0'),  hrdatas => (others => '0'),
  beat => (others => '0'), defmst => '0', ldefmst => '0',
  lsplmst => 0);
constant RES_split : std_logic_vector(0 to nahbmx-1) := (others => '0');


  constant primst : std_logic_vector(NAHBMST downto 0) := conv_std_logic_vector(mprio, NAHBMST+1);
  type l0_type is array (0 to 15) of std_logic_vector(2 downto 0);
  type l1_type is array (0 to 7) of std_logic_vector(3 downto 0);
  type l2_type is array (0 to 3) of std_logic_vector(4 downto 0);
  type l3_type is array (0 to 1) of std_logic_vector(5 downto 0);

  type tztab_type is array (0 to 15) of std_logic_vector(2 downto 0);


  --returns the index number of the highest priority request
  --signal in the two lsb bits when indexed with a 4-bit
  --request vector with the highest priority signal on the
  --lsb. the returned msb bit indicates if a request was
  --active ('1' = no request active corresponds to "0000")
  constant tztab : tztab_type := ("100", "000", "001", "000",
                                  "010", "000", "001", "000",
                                  "011", "000", "001", "000",
                                  "010", "000", "001", "000");


  --calculate the number of the highest priority request signal(up to 64
  --requests are supported) in vect_in using a divide and conquer
  --algorithm. The lower the index in the vector the higher the priority
  --of the signal. First 4-bit slices are indexed in tztab and the msb
  --indicates whether there is an active request or not. Then the resulting
  --3 bit vectors are compared in pairs (the one corresponding to (3:0) with
  --(7:4), (11:8) with (15:12) and so on). If the least significant of the two
  --contains an active signal a '0' is added to the msb side (the vector
  --becomes one bit wider at each level) to the next level to indicate that
  --there are active signals in the lower nibble of the two. Otherwise
  --the msb is removed from the vector corresponding to the higher nibble
  --and "10" is added if it does not contain active requests and "01" if
  --does contain active signals. Thus the msb still indicates if the new
  --slice contains active signals and a '1' is added if it is the higher
  --part. This results in a 6-bit vector containing the index number
  --of the highest priority master in 5:0 if bit 6 is '0' otherwise
  --no master requested the bus.
  function tz(vect_in : std_logic_vector) return std_logic_vector is
    variable vect : std_logic_vector(63 downto 0);
    variable l0 : l0_type;
    variable l1 : l1_type;
    variable l2 : l2_type;
    variable l3 : l3_type;
    variable l4 : std_logic_vector(6 downto 0);
    variable bci_lsb, bci_msb : std_logic_vector(3 downto 0);
    variable bco_lsb, bco_msb : std_logic_vector(2 downto 0);
    variable sel : std_logic;
  begin

    vect := (others => '1');
    vect(vect_in'length-1 downto 0) := vect_in;

    -- level 0
    for i in 0 to 7 loop
      bci_lsb := vect(8*i+3 downto 8*i);
      bci_msb := vect(8*i+7 downto 8*i+4);
      --lookup the highest priority request in each nibble
      bco_lsb := tztab(conv_integer(bci_lsb));
      bco_msb := tztab(conv_integer(bci_msb));
      --select which of two nibbles contain the highest priority ACTIVE
      --signal, and forward the corresponding vector to the next level
      sel := bco_lsb(2);
      if sel = '0' then l1(i) := '0' & bco_lsb;
      else l1(i) := bco_msb(2) & not bco_msb(2) & bco_msb(1 downto 0); end if;
    end loop;

    -- level 1
    for i in 0 to 3 loop
      sel := l1(2*i)(3);
      --select which of two 8-bit vectors contain the
      --highest priority ACTIVE signal. the msb set at the previous level
      --for each 8-bit slice determines this
      if sel = '0' then l2(i) := '0' & l1(2*i);
      else
        l2(i) := l1(2*i+1)(3) & not l1(2*i+1)(3) & l1(2*i+1)(2 downto 0);
      end if;
    end loop;

    -- level 2
    for i in 0 to 1 loop
      --16-bit vectors, the msb set at the previous level for each 16-bit
      --slice determines the higher priority slice
      sel := l2(2*i)(4);
      if sel = '0' then l3(i) := '0' & l2(2*i);
      else
        l3(i) := l2(2*i+1)(4) & not l2(2*i+1)(4) & l2(2*i+1)(3 downto 0);
      end if;
    end loop;

    --level 3
    --32-bit vectors, the msb set at the previous level for each 32-bit
    --slice determines the higher priority slice
    if l3(0)(5) = '0' then l4 := '0' & l3(0);
    else l4 := l3(1)(5) & not l3(1)(5) & l3(1)(4 downto 0); end if;

    return(l4);
  end;

  --invert the bit order of the hbusreq signals located in vect_in
  --since the highest hbusreq has the highest priority but the
  --algorithm in tz has the highest priority on lsb
  function lz(vect_in : std_logic_vector) return std_logic_vector is
    variable vect : std_logic_vector(vect_in'length-1 downto 0);
    variable vect2 : std_logic_vector(vect_in'length-1 downto 0);
  begin
    vect := vect_in;
    for i in vect'right to vect'left loop
      vect2(i) := vect(vect'left-i);
    end loop;
    return(tz(vect2));
  end;

-- Find next master:
--   * 2 arbitration policies: fixed priority or round-robin
--   * Fixed priority: priority is fixed, highest index has highest priority
--   * Round-robin: arbiter maintains circular queue of masters
--   * (master 0, master 1, ..., master (nahbmx-1)). First requesting master
--   * in the queue is granted access to the bus and moved to the end of the queue.
--   * splitted masters are not granted
--   * bus is re-arbited when current owner does not request the bus,
--     or when it performs non-burst accesses
--   * fix length burst transfers will not be interrupted
--   * incremental bursts should assert hbusreq until last access

  procedure selmast(r      : in reg_type;
                  msto   : in ahb_mst_out_vector;
                  rsplit : in std_logic_vector(0 to nahbmx-1);
                  mast   : out integer range 0 to nahbmx-1;
                  defmst : out std_ulogic) is
  variable nmst    : nmstarr;
  variable nvalid  : nvalarr;

  variable rrvec : std_logic_vector(nahbmx*2-1 downto 0);
  variable zcnt  : std_logic_vector(log2(nahbmx)+1 downto 0);
  variable hpvec : std_logic_vector(nahbmx-1 downto 0);
  variable zcnt2 : std_logic_vector(log2(nahbmx) downto 0);

  begin

    nvalid(1 to 3) := (others => false); nmst(1 to 3) := (others => 0);
    mast := r.hmaster;
    defmst := '0';

    if nahbm = 1 then
      mast := 0;
    elsif rrobin = 0 then
      hpvec := (others => '0');
      for i in 0 to nahbmx-1 loop
        --masters which have received split are not granted
        if ((rsplit(i) = '0') or (split = 0)) then
          hpvec(i) := msto(i).hbusreq;
        end if;
      end loop;
      --check if any bus requests are active (nvalid(2) set to true)
      --and determine the index (zcnt2) of the highest priority master
      zcnt2 := lz(hpvec)(log2(nahbmx) downto 0);
      if zcnt2(log2(nahbmx)) = '0' then nvalid(2) := true; end if;
      nmst(2) := conv_integer(not (zcnt2(log2(nahbmx)-1 downto 0)));
      --find the default master number
      for i in 0 to nahbmx-1 loop
        if not ((nmst(3) = defmast) and nvalid(3)) then
          nmst(3) := i; nvalid(3) := true;
        end if;
      end loop;
    else
      rrvec := (others => '0');
      --mask requests up to and including current master. Concatenate
      --an unmasked request vector above the masked vector. Otherwise
      --the rules are the same as for fixed priority
      for i in 0 to nahbmx-1 loop
        if ((rsplit(i) = '0') or (split = 0)) then
          if (i <= r.hmaster) then rrvec(i) := '0';
          else rrvec(i) := msto(i).hbusreq; end if;
          rrvec(nahbmx+i) := msto(i).hbusreq;
        end if;
      end loop;
      --find the next master uzing tz which gives priority to lower
      --indexes
      zcnt := tz(rrvec)(log2(nahbmx)+1 downto 0);
      --was there a master requesting the bus?
      if zcnt(log2(nahbmx)+1) = '0' then nvalid(2) := true; end if;
      nmst(2) := conv_integer(zcnt(log2(nahbmx)-1 downto 0));
      --if no other master is requesting the bus select the current one
      nmst(3) := r.hmaster; nvalid(3) := true;
      --check if any masters configured with higher priority are requesting
      --the bus
      if mprio /= 0 then
        for i in 0 to nahbm-1 loop
          if (((rsplit(i) = '0') or (split = 0)) and (primst(i) = '1')) then
            if msto(i).hbusreq = '1' then nmst(1) := i; nvalid(1) := true; end if;
          end if;
        end loop;
      end if;
    end if;

    --select the next master. If for round robin a high priority master
    --(mprio) requested the bus if nvalid(1) is true. Otherwise
    --if nvalid(2) is true at least one master was requesting the bus
    --and the one with highest priority was selected. If none of these
    --were true then the default master is selected (nvalid(3) true)
    for i in 1 to 3 loop
      if nvalid(i) then mast := nmst(i); exit; end if;
    end loop;

    --if no master was requesting the bus and split is enabled
    --then select builtin dummy master which only does
    --idle transfers
    if (not (nvalid(1) or nvalid(2))) and (split /= 0) then
      defmst := orv(rsplit);
    end if;

  end;

  constant MIMAX : integer := log2x(nahbmx) - 1;
  constant SIMAX : integer := log2x(nahbs) - 1;
  constant IOAREA : std_logic_vector(11 downto 0) :=
        conv_std_logic_vector(ioaddr, 12);
  constant IOMSK  : std_logic_vector(11 downto 0) :=
        conv_std_logic_vector(iomask, 12);
  constant CFGAREA : std_logic_vector(11 downto 0) :=
        conv_std_logic_vector(cfgaddr, 12);
  constant CFGMSK  : std_logic_vector(11 downto 0) :=
        conv_std_logic_vector(cfgmask, 12);
  constant FULLPNP : boolean := (fpnpen /= 0);

  signal r, rin : reg_type;
  signal rsplit, rsplitin : std_logic_vector(0 to nahbmx-1);

-- pragma translate_off
  signal lmsti : ahb_mst_in_type;
  signal lslvi : ahb_slv_in_type;
-- pragma translate_on

begin

  comb : process(rst, msto, slvo, r, rsplit, testen, testrst, scanen, testoen, testsig)
  variable v : reg_type;
  variable nhmaster: integer range 0 to nahbmx -1;
  variable hgrant  : std_logic_vector(0 to NAHBMST-1);   -- bus grant
  variable hsel    : std_logic_vector(0 to 31);   -- slave select
  variable hmbsel  : std_logic_vector(0 to NAHBAMR-1);
  variable nslave  : natural range 0 to 31;
  variable vsplit  : std_logic_vector(0 to nahbmx-1);
  variable bnslave : std_logic_vector(3 downto 0);
  variable area    : std_logic_vector(1 downto 0);
  variable hready  : std_ulogic;
  variable defslv  : std_ulogic;
  variable cfgsel  : std_ulogic;
  variable hresp   : std_logic_vector(1 downto 0);
  variable hrdata  : std_logic_vector(AHBDW-1 downto 0);
  variable haddr   : std_logic_vector(31 downto 0);
  variable hirq    : std_logic_vector(NAHBIRQ-1 downto 0);
  variable arb     : std_ulogic;
  variable hconfndx : integer range 0 to 7;
  variable vslvi   : ahb_slv_in_type;
  variable defmst   : std_ulogic;
  variable tmpv     : std_logic_vector(0 to nahbmx-1);

  begin

    v := r; hgrant := (others => '0'); defmst := '0';
    haddr := msto(r.hmaster).haddr;

    nhmaster := r.hmaster;

    --determine if bus should be rearbitrated. This is done if the current
    --master is not performing a locked transfer and if not in the middle
    --of burst
    arb := '0';
    if (r.hmasterlock or r.ldefmst) = '0' then
      case msto(r.hmaster).htrans is
        when HTRANS_IDLE => arb := '1';
        when HTRANS_NONSEQ =>
          case msto(r.hmaster).hburst is
            when HBURST_SINGLE => arb := '1';
            when HBURST_INCR => arb := not msto(r.hmaster).hbusreq;
            when others =>
          end case;
        when HTRANS_SEQ =>
          case msto(r.hmaster).hburst is
            when HBURST_WRAP4  | HBURST_INCR4  => if (fixbrst = 1) and (r.beat(1 downto 0) = "11")   then arb := '1'; end if;
            when HBURST_WRAP8  | HBURST_INCR8  => if (fixbrst = 1) and (r.beat(2 downto 0) = "111")  then arb := '1'; end if;
            when HBURST_WRAP16 | HBURST_INCR16 => if (fixbrst = 1) and (r.beat(3 downto 0) = "1111") then arb := '1'; end if;
            when HBURST_INCR => arb := not msto(r.hmaster).hbusreq;
            when others =>
          end case;
        when others => arb := '0';
      end case;
    end if;

    if (split /= 0) then
      for i in 0 to nahbmx-1 loop
        tmpv(i) := (msto(i).htrans(1) or (msto(i).hbusreq)) and not rsplit(i) and not r.ldefmst;
      end loop;
      if (r.defmst and orv(tmpv))  = '1' then arb := '1'; end if;
    end if;

    --rearbitrate bus with selmast. If not arbitrated one must
    --ensure that the dummy master is selected for locked splits.
    if (arb = '1') then
      selmast(r, msto, rsplit, nhmaster, defmst);
    elsif (split /= 0) then
      defmst := r.defmst;
    end if;

    -- slave decoding

    hsel := (others => '0'); hmbsel := (others => '0');

    if fourgslv = 0 then
      for i in 0 to nahbs-1 loop
        for j in NAHBIR to NAHBCFG-1 loop
          area := slvo(i).hconfig(j)(1 downto 0);
          case area is
            when "10" =>
              if ((ioen = 0) or ((IOAREA and IOMSK) /= (haddr(31 downto 20) and IOMSK))) and
                ((slvo(i).hconfig(j)(31 downto 20) and slvo(i).hconfig(j)(15 downto 4)) =
                 (haddr(31 downto 20) and slvo(i).hconfig(j)(15 downto 4))) and
                (slvo(i).hconfig(j)(15 downto 4) /= "000000000000")
              then hsel(i) := '1'; hmbsel(j-NAHBIR) := '1'; end if;
            when "11" =>
              if ((ioen /= 0) and ((IOAREA and IOMSK) = (haddr(31 downto 20) and IOMSK))) and
                ((slvo(i).hconfig(j)(31 downto 20) and slvo(i).hconfig(j)(15 downto 4)) =
                 (haddr(19 downto  8) and slvo(i).hconfig(j)(15 downto 4))) and
                (slvo(i).hconfig(j)(15 downto 4) /= "000000000000")
              then hsel(i) := '1'; hmbsel(j-NAHBIR) := '1'; end if;
            when others =>
          end case;
        end loop;
      end loop;
    else
      -- There is only one slave on the bus. The slave has only one bar, which
      -- maps 4 GB address space.
      hsel(0) := '1'; hmbsel(0) := '1';
    end if;

    if r.defmst = '1' then hsel := (others => '0'); end if;

    bnslave(0) := hsel(1) or hsel(3) or hsel(5) or hsel(7) or
                  hsel(9) or hsel(11) or hsel(13) or hsel(15);
    bnslave(1) := hsel(2) or hsel(3) or hsel(6) or hsel(7) or
                  hsel(10) or hsel(11) or hsel(14) or hsel(15);
    bnslave(2) := hsel(4) or hsel(5) or hsel(6) or hsel(7) or
                  hsel(12) or hsel(13) or hsel(14) or hsel(15);
    bnslave(3) := hsel(8) or hsel(9) or hsel(10) or hsel(11) or
                  hsel(12) or hsel(13) or hsel(14) or hsel(15);
    nslave := conv_integer(bnslave(SIMAX downto 0));

    if ((((IOAREA and IOMSK) = (haddr(31 downto 20) and IOMSK)) and (ioen /= 0))
      or ((IOAREA = haddr(31 downto 20)) and (ioen = 0))) and
       ((CFGAREA and CFGMSK) = (haddr(19 downto  8) and CFGMSK))
       and (cfgmask /= 0)
    then cfgsel := '1'; hsel := (others => '0');
    else cfgsel := '0'; end if;

    if (nslave = 0) and (hsel(0) = '0') and (cfgsel = '0') then defslv := '1';
    else defslv := '0'; end if;

    if r.defmst = '1' then
      cfgsel := '0'; defslv := '1';
    end if;

-- error response on undecoded area

    v.hready := '0';
    hready := slvo(r.hslave).hready; hresp := slvo(r.hslave).hresp;
    if r.defslv = '1' then
      -- default slave
      if (r.htrans = HTRANS_IDLE) or (r.htrans = HTRANS_BUSY) then
        hresp := HRESP_OKAY; hready := '1';
      else
        -- return two-cycle error in case of unimplemented slave access
        hresp := HRESP_ERROR; hready := r.hready; v.hready := not r.hready;
      end if;
    end if;

    if acdm = 0 then
      hrdata := slvo(r.hslave).hrdata;
    else
      hrdata := ahbselectdata(slvo(r.hslave).hrdata, r.haddr(4 downto 2), r.hsize);
    end if;

    if cfgmask /= 0 then
      -- plug&play information for masters
      if FULLPNP then hconfndx := conv_integer(r.haddr(4 downto 2)); else hconfndx := 0; end if;
      if (r.haddr(10 downto MIMAX+6) = zero32(10 downto MIMAX+6)) and (FULLPNP or (r.haddr(4 downto 2) = "000"))
      then v.hrdatam := msto(conv_integer(r.haddr(MIMAX+5 downto 5))).hconfig(hconfndx);
      else v.hrdatam := (others => '0'); end if;

      -- plug&play information for slaves
      if (r.haddr(10 downto SIMAX+6) = zero32(10 downto SIMAX+6)) and
        (FULLPNP or (r.haddr(4 downto 2) = "000") or (r.haddr(4) = '1'))
      then v.hrdatas := slvo(conv_integer(r.haddr(SIMAX+5 downto 5))).hconfig(conv_integer(r.haddr(4 downto 2)));
      else v.hrdatas := (others => '0'); end if;

      -- device ID, library build and potentially debug information
      if r.haddr(10 downto 4) = "1111111" then
        if hwdebug = 0 or r.haddr(3 downto 2) = "00" then
          v.hrdatas(15 downto 0) := conv_std_logic_vector(LIBVHDL_BUILD, 16);
          v.hrdatas(31 downto 16) := conv_std_logic_vector(devid, 16);
        elsif r.haddr(3 downto 2) = "01" then
          for i in 0 to nahbmx-1 loop v.hrdatas(i) := msto(i).hbusreq; end loop;
        else
          for i in 0 to nahbmx-1 loop v.hrdatas(i) := rsplit(i); end loop;
        end if;
      end if;

      if r.cfgsel = '1' then
        hrdata := (others => '0');
        -- default slave
        if (r.htrans = HTRANS_IDLE) or (r.htrans = HTRANS_BUSY) then
          hresp := HRESP_OKAY; hready := '1';
        else
          -- return two-cycle read/write respons
          hresp := HRESP_OKAY; hready := r.hready; v.hready := not r.hready;
        end if;
        if r.cfga11 = '0' then hrdata := ahbdrivedata(r.hrdatam);
        else hrdata := ahbdrivedata(r.hrdatas); end if;
      end if;
    end if;

    --degrant all masters when split occurs for locked access
    if (r.hmasterlockd = '1') then
      if (hresp = HRESP_RETRY) or ((split /= 0) and (hresp = HRESP_SPLIT)) then
        nhmaster := r.hmaster;
      end if;
      if split /= 0 then
        if hresp = HRESP_SPLIT then
          v.ldefmst := '1'; defmst := '1';
          v.lsplmst := nhmaster;
        end if;
      end if;
    end if;

    if split /= 0 and r.ldefmst = '1' then
      if rsplit(r.lsplmst) = '0' then
        v.ldefmst := '0'; defmst := '0';
      end if;
    end if;

    if (split = 0) or (defmst = '0') then hgrant(nhmaster) := '1'; end if;

    -- latch active master and slave
    if hready = '1' then
      v.hmaster := nhmaster; v.hmasterd := r.hmaster;
      v.hsize := msto(r.hmaster).hsize;
      v.hslave := nslave; v.defslv := defslv;
      v.hmasterlockd := r.hmasterlock;
      if (split = 0) or (r.defmst = '0') then v.htrans := msto(r.hmaster).htrans;
      else v.htrans := HTRANS_IDLE; end if;
      v.cfgsel := cfgsel;
      v.cfga11 := msto(r.hmaster).haddr(11);
      v.haddr := msto(r.hmaster).haddr(15 downto 2);
      if (msto(r.hmaster).htrans = HTRANS_NONSEQ) or (msto(r.hmaster).htrans = HTRANS_IDLE) then
        v.beat := "0001";
      elsif (msto(r.hmaster).htrans = HTRANS_SEQ) then
        if (fixbrst = 1) then v.beat := r.beat + 1; end if;
      end if;
      if (split /= 0) then v.defmst := defmst; end if;
    end if;

    --assign new hmasterlock, v.hmaster is used because if hready
    --then master can have changed, and when not hready then the
    --previous master will still be selected
    v.hmasterlock := msto(v.hmaster).hlock or (r.hmasterlock and not hready);
    --if the master asserting hlock received a SPLIT/RETRY response
    --to the previous access then disregard the current lock request.
    --the bus will otherwise be locked when the previous access is
    --retried instead of treating hlock as coupled to the next access.
    --use hmasterlockd to keep the bus locked for SPLIT/RETRY to locked
    --accesses.
    if v.hmaster = r.hmasterd and slvo(r.hslave).hresp(1) = '1' then
      if r.hmasterlockd = '0' then
        v.hmasterlock := '0'; v.hmasterlockd := '0';
      end if;
    end if;

    -- split support
    vsplit := (others => '0');
    if SPLIT /= 0 then
      vsplit := rsplit;
      if slvo(r.hslave).hresp = HRESP_SPLIT then vsplit(r.hmasterd) := '1'; end if;
      for i in 0 to nahbs-1 loop
        for j in 0 to nahbmx-1 loop
          vsplit(j) := vsplit(j) and not slvo(i).hsplit(j);
        end loop;
      end loop;
    end if;

    -- interrupt merging
    hirq := (others => '0');
    if disirq = 0 then
      for i in 0 to nahbs-1 loop hirq := hirq or slvo(i).hirq; end loop;
      for i in 0 to nahbm-1 loop hirq := hirq or msto(i).hirq; end loop;
    end if;

    if (split = 0) or (r.defmst = '0') then
      vslvi.haddr      := haddr;
      vslvi.htrans     := msto(r.hmaster).htrans;
      vslvi.hwrite     := msto(r.hmaster).hwrite;
      vslvi.hsize      := msto(r.hmaster).hsize;
      vslvi.hburst     := msto(r.hmaster).hburst;
      vslvi.hready     := hready;
      vslvi.hprot      := msto(r.hmaster).hprot;
--      vslvi.hmastlock  := msto(r.hmaster).hlock;
      vslvi.hmastlock  := r.hmasterlock;
      vslvi.hmaster    := conv_std_logic_vector(r.hmaster, 4);
      vslvi.hsel       := hsel(0 to NAHBSLV-1);
      vslvi.hmbsel     := hmbsel;
      vslvi.hirq       := hirq;
    else
      vslvi := ahbs_in_none;
      vslvi.hready := hready;
      vslvi.hirq   := hirq;
    end if;
    if acdm = 0 then
      vslvi.hwdata := msto(r.hmasterd).hwdata;
    else
      vslvi.hwdata := ahbselectdata(msto(r.hmasterd).hwdata, r.haddr(4 downto 2), r.hsize);
    end if;
    vslvi.testen  := testen;
    vslvi.testrst := testrst;
    vslvi.scanen  := scanen and testen;
    vslvi.testoen := testoen;
    vslvi.testin  := testen & (scanen and testen) & testsig;

    -- reset operation
    if (not RESET_ALL) and (rst = '0') then
      v.hmaster := RES_r.hmaster; v.hmasterlock := RES_r.hmasterlock;
      vsplit := (others => '0');
      v.htrans := RES_r.htrans;  v.defslv := RES_r.defslv;
      v.hslave := RES_r.hslave; v.cfgsel := RES_r.cfgsel;
      v.defmst := RES_r.defmst; v.ldefmst := RES_r.ldefmst;
    end if;

    -- drive master inputs
    msti.hgrant  <= hgrant;
    msti.hready  <= hready;
    msti.hresp   <= hresp;
    msti.hrdata  <= hrdata;
    msti.hirq    <= hirq;
    msti.testen  <= testen;
    msti.testrst <= testrst;
    msti.scanen  <= scanen and testen;
    msti.testoen <= testoen;
    msti.testin  <= testen & (scanen and testen) & testsig;

    -- drive slave inputs
    slvi     <= vslvi;

-- pragma translate_off
    --drive internal signals to bus monitor
    lslvi         <= vslvi;

    lmsti.hgrant  <= hgrant;
    lmsti.hready  <= hready;
    lmsti.hresp   <= hresp;
    lmsti.hrdata  <= hrdata;
    lmsti.hirq    <= hirq;
-- pragma translate_on

    if split = 0 then v.ldefmst := '0'; v.lsplmst := 0; end if;

    rin <= v; rsplitin <= vsplit;

  end process;


  reg0 : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
      if RESET_ALL and rst = '0' then
        r <= RES_r;
      end if;
    end if;
    if (split = 0) then r.defmst <= '0'; end if;
  end process;

  splitreg : if SPLIT /= 0 generate
    reg1 : process(clk)
    begin
      if rising_edge(clk) then
        rsplit <= rsplitin;
        if RESET_ALL and rst = '0' then
          rsplit <= RES_split;
        end if;
      end if;
    end process;
  end generate;

  nosplitreg : if SPLIT = 0 generate
    rsplit <= (others => '0');
  end generate;

-- pragma translate_off
  ahblog : if ahbtrace /= 0 generate
    log : process (clk)
    variable hwrite : std_logic;
    variable hsize : std_logic_vector(2 downto 0);
    variable htrans : std_logic_vector(1 downto 0);
    variable hmaster : std_logic_vector(3 downto 0);
    variable haddr : std_logic_vector(31 downto 0);
    variable hwdata, hrdata : std_logic_vector(127 downto 0);
    variable mbit, bitoffs : integer;
    variable t : integer;
    begin
      if rising_edge(clk) then
        if htrans(1)='1' and lmsti.hready='0' and (lmsti.hresp="01") then
          if hwrite = '1' then
            work.testlib.print("mst" & tost(hmaster) & ": " & tost(haddr) & "    write " & tost(mbit/8) & " bytes  [" & tost(lslvi.hwdata(mbit-1+bitoffs downto bitoffs)) & "] - ERROR!");
          else
            work.testlib.print("mst" & tost(hmaster) & ": " & tost(haddr) & "    read  " & tost(mbit/8) & " bytes  [" & tost(lmsti.hrdata(mbit-1+bitoffs downto bitoffs)) & "] - ERROR!");
          end if;
        end if;
        if ((htrans(1) and lmsti.hready) = '1') and (lmsti.hresp = "00") then
          mbit :=  2**conv_integer(hsize)*8;
          bitoffs := 0;
          if mbit < ahbdw then
            bitoffs := mbit * conv_integer(haddr(log2(ahbdw/8)-1 downto conv_integer(hsize)));
            bitoffs := lslvi.hwdata'length-mbit-bitoffs;
          end if;
          t := (now/1 ns);
          if hwrite = '1' then
            work.testlib.print("mst" & tost(hmaster) & ": " & tost(haddr) & "    write " & tost(mbit/8) & " bytes  [" & tost(lslvi.hwdata(mbit-1+bitoffs downto bitoffs)) & "]");
          else
            work.testlib.print("mst" & tost(hmaster) & ": " & tost(haddr) & "    read  " & tost(mbit/8) & " bytes  [" & tost(lmsti.hrdata(mbit-1+bitoffs downto bitoffs)) & "]");
          end if;
        end if;
        if lmsti.hready = '1' then
          hwrite := lslvi.hwrite;
          hsize := lslvi.hsize;
          haddr := lslvi.haddr;
          htrans := lslvi.htrans;
          hmaster := lslvi.hmaster;
        end if;
      end if;
    end process;
  end generate;

  mon0 : if enbusmon /= 0 generate
    mon : ahbmon
      generic map(
        asserterr   => asserterr,
        assertwarn  => assertwarn,
        hmstdisable => hmstdisable,
        hslvdisable => hslvdisable,
        arbdisable  => arbdisable,
        nahbm       => nahbm,
        nahbs       => nahbs)
      port map(
        rst         => rst,
        clk         => clk,
        ahbmi       => lmsti,
        ahbmo       => msto,
        ahbsi       => lslvi,
        ahbso       => slvo,
        err         => open);
  end generate;

  diag : process
  type ahbsbank_type is record
        start : std_logic_vector(31 downto 8);
        stop  : std_logic_vector(31 downto 8);
        io    : std_ulogic;
  end record;
  type ahbsbanks_type is array (0 to 3) of ahbsbank_type;
  type memmap_type is array (0 to nahbs-1) of ahbsbanks_type;
  variable k : integer;
  variable mask : std_logic_vector(11 downto 0);
  variable device : std_logic_vector(11 downto 0);
  variable devicei : integer;
  variable vendor : std_logic_vector( 7 downto 0);
  variable area : std_logic_vector( 1 downto 0);
  variable vendori : integer;
  variable iosize, tmp : integer;
  variable iounit : string(1 to 5) := " byte";
  variable memtype : string(1 to 9);
  variable iostart : std_logic_vector(11 downto 0) := IOAREA and IOMSK;
  variable cfgstart : std_logic_vector(11 downto 0) := CFGAREA and CFGMSK;
  variable L1 : line := new string'("");
  variable S1 : string(1 to 255);
  variable memmap : memmap_type;

  begin
    wait for 2 ns;
    if debug = 0 then wait; end if;
    if debug > 0 then
      k := 0; mask := IOMSK;
      while (k<12) and (mask(k) = '0') loop k := k+1; end loop;
      print("ahbctrl: AHB arbiter/multiplexer rev 1");
      if ioen /= 0 then
        print("ahbctrl: Common I/O area at " & tost(iostart) & "00000, " & tost(2**k) & " Mbyte");
      else
        print("ahbctrl: Common I/O area disabled");
      end if;
      print("ahbctrl: AHB masters: " & tost(nahbm) & ", AHB slaves: " & tost(nahbs));
      if cfgmask /= 0 then
        print("ahbctrl: Configuration area at " & tost(iostart & cfgstart) & "00, 4 kbyte");
      else
        print("ahbctrl: Configuration area disabled");
      end if;
    end if;
    for i in 0 to nahbm-1 loop
      vendor := msto(i).hconfig(0)(31 downto 24);
      vendori := conv_integer(vendor);
      if vendori /= 0 then
        if debug > 1 then
          device := msto(i).hconfig(0)(23 downto 12);
          devicei := conv_integer(device);
          print("ahbctrl: mst" & tost(i) & ": " & iptable(vendori).vendordesc &
                iptable(vendori).device_table(devicei));
        end if;
        for j in 1 to NAHBIR-1 loop
          assert (msto(i).hconfig(j) = zx or FULLPNP or ccheck = 0 or cfgmask = 0)
            report "AHB master " & tost(i) & " propagates non-zero user defined PnP data, " &
            "but AHBCTRL full PnP decoding has not been enabled (check fpnpen VHDL generic)"
            severity warning;
        end loop;
        assert (msto(i).hindex = i) or (icheck = 0)
        report "AHB master index error on master " & tost(i) &
          ". Detected index value " & tost(msto(i).hindex) severity failure;
      else
        for j in 0 to NAHBCFG-1 loop
          assert (msto(i).hconfig(j) = zx or ccheck = 0)
            report "AHB master " & tost(i) & " appears to be disabled, " &
            "but the master config record is not driven to zero " &
            "(check vendor ID or drive unused bus index with appropriate values)."
            severity warning;
        end loop;
      end if;
    end loop;
    if nahbm < NAHBMST then
      for i in nahbm to NAHBMST-1 loop
        for j in 0 to NAHBCFG-1 loop
          assert (msto(i).hconfig(j) = zx or ccheck = 0)
            report "AHB master " & tost(i) & " is outside the range of " &
            "decoded master indexes but the master config record is not driven to zero " &
            "(check nahbm VHDL generic)."
            severity warning;
        end loop;
      end loop;
    end if;
    for i in 0 to nahbs-1 loop
      vendor := slvo(i).hconfig(0)(31 downto 24);
      vendori := conv_integer(vendor);
      if vendori /= 0 then
        if debug > 1 then
          device := slvo(i).hconfig(0)(23 downto 12);
          devicei := conv_integer(device);
          std.textio.write(L1, "ahbctrl: slv" & tost(i) & ": " & iptable(vendori).vendordesc &
                           iptable(vendori).device_table(devicei));
          std.textio.writeline(OUTPUT, L1);
        end if;
        for j in 1 to NAHBIR-1 loop
          assert (slvo(i).hconfig(j) = zx or FULLPNP or ccheck = 0 or cfgmask = 0)
            report "AHB slave " & tost(i) & " propagates non-zero user defined PnP data, " &
            "but AHBCTRL full PnP decoding has not been enabled (check fpnpen VHDL generic)."
            severity warning;
        end loop;
        for j in NAHBIR to NAHBCFG-1 loop
          area := slvo(i).hconfig(j)(1 downto 0);
          mask := slvo(i).hconfig(j)(15 downto 4);
          memmap(i)(j mod NAHBIR).start := (others => '0');
          memmap(i)(j mod NAHBIR).stop := (others => '0');
          memmap(i)(j mod NAHBIR).io := slvo(i).hconfig(j)(0);
          if (mask /= "000000000000" or fourgslv = 1) then
            case area is
            when "01" =>
            when "10" =>
              k := 0;
              while (k<12) and (mask(k) = '0') loop k := k+1; end loop;
              if debug > 1 then
                std.textio.write(L1, "ahbctrl:       memory at " &
                tost(slvo(i).hconfig(j)(31 downto 20) and mask) &
                "00000, size "& tost(2**k) & " Mbyte");
                if slvo(i).hconfig(j)(16) = '1' then
                  std.textio.write(L1, string'(", cacheable"));
                end if;
                if slvo(i).hconfig(j)(17) = '1' then
                  std.textio.write(L1, string'(", prefetch"));
                end if;
                std.textio.writeline(OUTPUT, L1);
              end if;
              memmap(i)(j mod NAHBIR).start(31 downto 20) := slvo(i).hconfig(j)(31 downto 20);
              memmap(i)(j mod NAHBIR).start(31 downto 20) :=
                (slvo(i).hconfig(j)(31 downto 20) and mask);
              memmap(i)(j mod NAHBIR).start(19 downto 8) := (others => '0');
              memmap(i)(j mod NAHBIR).stop := memmap(i)(j mod NAHBIR).start + 2**(k+12) - 1;
              -- Be verbose if an address with bits set outside the area
              -- selected by the mask is encountered
              assert ((slvo(i).hconfig(j)(31 downto 20) and not mask) = zero32(11 downto 0)) report
                "AHB slave " & tost(i) & " may decode an area larger than intended. Bar " &
                tost(j mod NAHBIR) & " will have base address " &
                tost(slvo(i).hconfig(j)(31 downto 20) and mask) &
                "00000, the intended base address may have been " &
                tost(slvo(i).hconfig(j)(31 downto 20)) & "00000"
                severity warning;
            when "11" =>
              if ioen /= 0 then
                k := 0;
                while (k<12) and (mask(k) = '0') loop k := k+1; end loop;
                memmap(i)(j mod NAHBIR).start := iostart & (slvo(i).hconfig(j)(31 downto 20) and
                                                            slvo(i).hconfig(j)(15 downto 4));
                memmap(i)(j mod NAHBIR).stop := memmap(i)(j mod NAHBIR).start + 2**k - 1;
                if debug > 1 then
                  iosize := 256 * 2**k; iounit(1) := ' ';
                  if (iosize > 1023) then
                    iosize := iosize/1024; iounit(1) := 'k';
                  end if;
                  print("ahbctrl:       I/O port at " & tost(iostart &
                        ((slvo(i).hconfig(j)(31 downto 20)) and slvo(i).hconfig(j)(15 downto 4))) &
                        "00, size "& tost(iosize) & iounit);
                end if;
                assert ((slvo(i).hconfig(j)(31 downto 20) and not mask) = zero32(11 downto 0)) report
                  "AHB slave " & tost(i) & " may decode an I/O area larger than intended. Bar " &
                  tost(j mod NAHBIR) & " will have base address " &
                  tost(iostart & (slvo(i).hconfig(j)(31 downto 20) and mask)) &
                  "00, the intended base address may have been " &
                  tost(iostart & slvo(i).hconfig(j)(31 downto 20)) & "00"
                  severity warning;
              else
                assert false report
                  "AHB slave " & tost(i) & " maps bar " & tost(j mod NAHBIR) &
                  " to the IO area, but this AHBCTRL has been configured with VHDL generic ioen = 0"
                  severity warning;
              end if;
            when others =>
            end case;
          end if;
        end loop;
        assert (slvo(i).hindex = i) or (icheck = 0)
        report "AHB slave index error on slave " & tost(i) &
          ". Detected index value " & tost(slvo(i).hindex) severity failure;
        if mcheck /= 0 then
          for j in 0 to i loop
            for k in memmap(i)'range loop
              if memmap(i)(k).stop /= zero32(memmap(i)(k).stop'range) then
                for l in memmap(j)'range loop
                  assert ((memmap(i)(k).start >= memmap(j)(l).stop) or
                          (memmap(i)(k).stop <= memmap(j)(l).start) or
                          (mcheck /= 2 and (memmap(i)(k).io xor memmap(j)(l).io) = '1') or
                          (i = j and k = l))
                    report "AHB slave " & tost(i) & " bank " & tost(k) &
                    " intersects with AHB slave " & tost(j) & " bank " & tost(l)
                    severity failure;
                end loop;
              end if;
            end loop;
          end loop;
        end if;
      else
        for j in 0 to NAHBCFG-1 loop
          assert (slvo(i).hconfig(j) = zx or ccheck = 0)
            report "AHB slave " & tost(i) & " appears to be disabled, " &
            "but the slave config record is not driven to zero " &
            "(check vendor ID or drive unused bus index with appropriate values)."
            severity warning;
        end loop;
      end if;
    end loop;
    if nahbs < NAHBSLV then
      for i in nahbs to NAHBSLV-1 loop
        for j in 0 to NAHBCFG-1 loop
          assert (slvo(i).hconfig(j) = zx or ccheck = 0)
            report "AHB slave " & tost(i) & " is outside the range of " &
            "decoded slave indexes but the slave config record is not driven to zero " &
            "(check nahbs VHDL generic)."
            severity warning;
        end loop;
      end loop;
    end if;
    wait;
  end process;

-- pragma translate_on

end;

