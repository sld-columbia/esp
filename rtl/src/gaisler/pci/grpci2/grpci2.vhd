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
-- Entity:  grpci2
-- File:    grpci2.vhd
-- Author:  Nils-Johan Wessman - Aeroflex Gaisler
-- Description: PCI master and target interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.dftlib.all;
use work.gencomp.all;
use work.pci.all;

use work.pcilib2.all;


entity grpci2 is
  generic (
    memtech     : integer := DEFMEMTECH;
    tbmemtech   : integer := DEFMEMTECH;  -- For trace buffers
    oepol       : integer := 0;
    hmindex     : integer := 0;
    hdmindex    : integer := 0;
    hsindex     : integer := 0;
    haddr       : integer := 0;
    hmask       : integer := 0;
    ioaddr      : integer := 0;
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#FFF#;
    irq         : integer := 0;
    irqmode     : integer range 0 to 3 := 0;
    master      : integer range 0 to 1 := 1;
    target      : integer range 0 to 1 := 1;
    dma         : integer range 0 to 1 := 1;
    tracebuffer : integer range 0 to 16384 := 0;
    confspace   : integer range 0 to 1 := 1;
    vendorid    : integer := 16#0000#;
    deviceid    : integer := 16#0000#;
    classcode   : integer := 16#000000#;
    revisionid  : integer := 16#00#;
    cap_pointer : integer := 16#40#;
    ext_cap_pointer : integer := 16#00#;
    iobase      : integer := 16#FFF#;
    extcfg      : integer := 16#0000000#;
    bar0        : integer range 0 to 31 := 28;
    bar1        : integer range 0 to 31 := 0;
    bar2        : integer range 0 to 31 := 0;
    bar3        : integer range 0 to 31 := 0;
    bar4        : integer range 0 to 31 := 0;
    bar5        : integer range 0 to 31 := 0;
    bar0_map    : integer := 16#000000#;
    bar1_map    : integer := 16#000000#;
    bar2_map    : integer := 16#000000#;
    bar3_map    : integer := 16#000000#;
    bar4_map    : integer := 16#000000#;
    bar5_map    : integer := 16#000000#;
    bartype     : integer range 0 to 65535 := 16#0000#;
    barminsize  : integer range 5 to 31 := 12;
    fifo_depth  : integer range 3 to 7 := 3;
    fifo_count  : integer range 2 to 4 := 2;
    conv_endian : integer range 0 to 1 := 1; -- 1: little (PCI) <~> big (AHB), 0: big (PCI) <=> big (AHB)   
    deviceirq   : integer range 0 to 1 := 1;
    deviceirqmask : integer range 0 to 15 := 16#0#;
    hostirq     : integer range 0 to 1 := 1;
    hostirqmask : integer range 0 to 15 := 16#0#;
    nsync       : integer range 0 to 2 := 2; -- with nsync = 0, wrfst needed on syncram...
    hostrst     : integer range 0 to 2 := 0; -- 0: PCI reset is never driven, 1: PCI reset is driven from AHB reset if host, 2: PCI reset is always driven from AHB reset
    bypass      : integer range 0 to 1 := 1;
    ft          : integer range 0 to 1 := 0;
    scantest    : integer range 0 to 1 := 0;
    debug       : integer range 0 to 1 := 0;
    tbapben     : integer range 0 to 1 := 0;
    tbpindex    : integer := 0;
    tbpaddr     : integer := 0;
    tbpmask     : integer := 16#F00#;
    netlist     : integer range 0 to 1 := 0;  -- Use PHY netlist
    
    multifunc   : integer range 0 to 1 := 0; -- Enables Multi-function support
    multiint    : integer range 0 to 1 := 0;
    masters     : integer := 16#FFFF#;
    mf1_deviceid        : integer := 16#0000#;
    mf1_classcode       : integer := 16#000000#;
    mf1_revisionid      : integer := 16#00#;
    mf1_bar0            : integer range 0 to 31 := 0;
    mf1_bar1            : integer range 0 to 31 := 0;
    mf1_bar2            : integer range 0 to 31 := 0;
    mf1_bar3            : integer range 0 to 31 := 0;
    mf1_bar4            : integer range 0 to 31 := 0;
    mf1_bar5            : integer range 0 to 31 := 0;
    mf1_bartype         : integer range 0 to 65535 := 16#0000#;
    mf1_bar0_map        : integer := 16#000000#;
    mf1_bar1_map        : integer := 16#000000#;
    mf1_bar2_map        : integer := 16#000000#;
    mf1_bar3_map        : integer := 16#000000#;
    mf1_bar4_map        : integer := 16#000000#;
    mf1_bar5_map        : integer := 16#000000#;
    mf1_cap_pointer     : integer := 16#40#;
    mf1_ext_cap_pointer : integer := 16#00#;
    mf1_extcfg          : integer := 16#0000000#;
    mf1_masters         : integer := 16#0000#;
    iotest              : integer := 0
  ); 
  port(
      rst       : in std_logic;
      clk       : in std_logic;
      pciclk    : in std_logic;
      dirq      : in  std_logic_vector(3 downto 0);
      pcii      : in  pci_in_type;
      pcio      : out pci_out_type;
      apbi      : in apb_slv_in_type;
      apbo      : out apb_slv_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ahbso     : out ahb_slv_out_type;
      ahbmi     : in  ahb_mst_in_type;
      ahbmo     : out ahb_mst_out_type;
      ahbdmi    : in  ahb_mst_in_type;
      ahbdmo    : out ahb_mst_out_type;
      ptarst    : out std_logic;
      tbapbi    : in apb_slv_in_type := apb_slv_in_none;
      tbapbo    : out apb_slv_out_type;
      debugo    : out std_logic_vector(debug*255 downto 0)
);
end;

architecture rtl of grpci2 is
-- PHY =>
signal phyi : grpci2_phy_in_type;
signal phyo : grpci2_phy_out_type;
signal sig_m_request, sig_m_mabort, sig_t_abort, sig_t_ready, sig_t_retry : std_logic;
signal sig_pr_conf_comm_serren, sig_pr_conf_comm_perren : std_logic;
signal sig_soft_rst : std_logic_vector(2 downto 0);
-- PHY <=

constant PT_DEPTH : integer := 5 + log2(tracebuffer/32);
constant HIOMASK : integer := 16#E00# - 16#200#*conv_integer(conv_std_logic(tracebuffer/=0));
constant MST_ACC_CNT : integer := fifo_count - 1;
constant RAM_LATENCY : integer := 1 + ram_raw_latency(memtech); -- Delay FIFO readout one extra write clock cycle for some technologies

type pci_bars_type is array (0 to 5) of std_logic_vector(31 downto 0);
constant pci_bars_none : pci_bars_type := (others => (others => '0'));
type pci_config_space_type is record
  bar         : pci_bars_type;
  comm        : pci_config_command_type;
  stat        : pci_config_status_type;
  ltimer      : std_logic_vector(7 downto 0);
  iline       : std_logic_vector(7 downto 0);

  pta_map     : pci_bars_type;                -- PCI to AHB mapping for each PCI bar
  bar_mask    : pci_bars_type;                -- PCI bar mask (bar size)
  cfg_map     : std_logic_vector(31 downto 0);-- Map extended PCI configuration space to AHB address
end record;
constant pci_config_space_none : pci_config_space_type := (pci_bars_none, pci_config_command_none, pci_config_status_none, (others => '0'), (others => '0'), pci_bars_none, pci_bars_none, (others => '0'));
type pci_config_space_multi_type is array (0 to multifunc) of pci_config_space_type;

type pci_fifo_out_type is record
  data  : std_logic_vector(31 downto 0);
  err   : std_logic_vector(3 downto 0);
end record;
constant pci_fifo_out_none : pci_fifo_out_type := ((others => '0'), (others => '0'));
type pci_fifo_in_type is record
  en    : std_logic;                                -- Read/write enable for fifo
  addr  : std_logic_vector((FIFO_DEPTH+log2(FIFO_COUNT))-1 downto 0);  -- Fifo address
  data  : std_logic_vector(31 downto 0);            -- Fifo input data
end record;
constant pci_fifo_in_none : pci_fifo_in_type := ('0', zero32((FIFO_DEPTH+log2(FIFO_COUNT))-1 downto 0), (others => '0'));

type pci_g_acc_trans_type is record
  pending   : std_logic;                      -- Access pending (valid)
  addr      : std_logic_vector(31 downto 0);  -- Access start address
  acctype   : std_logic_vector(3 downto 0);   -- Access type (conf_read/write, io_read/write, data_read/write)
  accmode   : std_logic_vector(2 downto 0);   -- Access mode (use cancel, use length, burst)
  size      : std_logic_vector(2 downto 0);   -- Access size 
  offset    : std_logic_vector(1 downto 0);   -- Access byte offset 
  index     : integer range 0 to FIFO_COUNT-1;-- FIFO index for first data
  length    : std_logic_vector(15 downto 0);  -- Access length
  func      : std_logic_vector(2 downto 0);   -- The master belongs to this PCI function
  --
  cbe       : std_logic_vector(3 downto 0);   -- Byte enable (size and offset)
  endianess : std_logic;                      -- PCI bus endianess
end record;
constant pci_g_acc_trans_none : pci_g_acc_trans_type := ('0', (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), 0, (others => '0'), (others => '0'), (others => '0'), '0');
type pci_g_acc_status_trans_type is record
  done    : std_logic;                    -- Access done
  status  : std_logic_vector(3 downto 0); -- Access status
  count   : std_logic_vector(15 downto 0);-- Access transfer count
end record;
constant pci_g_acc_status_trans_none : pci_g_acc_status_trans_type := ('0', (others => '0'), (others => '0'));
type pci_g_acc_status_trans_multi_type is array (0 to 1) of pci_g_acc_status_trans_type;
constant pci_g_acc_status_trans_multi_none : pci_g_acc_status_trans_multi_type := (others => pci_g_acc_status_trans_none);
type pci_g_fifo_trans_type is record
  pending   : std_logic_vector(2 downto 0);           -- FIFO pending (valid)
  start     : std_logic_vector(FIFO_DEPTH-1 downto 0);-- FIFO start address (first valid data)
  stop      : std_logic_vector(FIFO_DEPTH-1 downto 0);-- FIFO stop address (last valid data)
  firstf    : std_logic;                              -- First FIFO 
  lastf     : std_logic;                              -- Last FIFO
  status    : std_logic_vector(3 downto 0);           -- Error status
  --
  last_cbe  : std_logic_vector(3 downto 0);           -- Byte enable of last data   
end record;
constant pci_g_fifo_trans_none : pci_g_fifo_trans_type := ((others => '0'), zero32(FIFO_DEPTH-1 downto 0), zero32(FIFO_DEPTH-1 downto 0), '0', '0', (others => '0'), (others => '0'));
type pci_g_acc_trans_multi_type is array (0 to 1) of pci_g_acc_trans_type;
constant pci_g_acc_trans_multi_none : pci_g_acc_trans_multi_type := (others => pci_g_acc_trans_none);
type pci_g_acc_trans_vector_type is array (0 to 3) of pci_g_acc_trans_type;
constant pci_g_acc_trans_vector_none : pci_g_acc_trans_vector_type := (others => pci_g_acc_trans_none);
type pci_g_acc_trans_vector_multi_type is array (0 to 1) of pci_g_acc_trans_vector_type;
constant pci_g_acc_trans_vector_multi_none : pci_g_acc_trans_vector_multi_type := (others => pci_g_acc_trans_vector_none);
type pci_g_fifo_trans_vector_type is array (0 to FIFO_COUNT-1) of pci_g_fifo_trans_type;
constant pci_g_fifo_trans_vector_none: pci_g_fifo_trans_vector_type := (others => pci_g_fifo_trans_none);
type pci_g_fifo_trans_vector_multi_type is array (0 to 1) of pci_g_fifo_trans_vector_type;
constant pci_g_fifo_trans_vector_multi_none : pci_g_fifo_trans_vector_multi_type := (others => pci_g_fifo_trans_vector_none);
subtype pci_g_fifo_ack_trans_vector_type is std_logic_vector(FIFO_COUNT-1 downto 0);
constant pci_g_fifo_ack_trans_vector_none : pci_g_fifo_ack_trans_vector_type := (others => '0');
type pci_g_fifo_ack_trans_vector_multi_type is array (0 to 1) of pci_g_fifo_ack_trans_vector_type;
constant pci_g_fifo_ack_trans_vector_multi_none : pci_g_fifo_ack_trans_vector_multi_type := (others => pci_g_fifo_ack_trans_vector_none);
type pci_master_acc_type is record
  pending     : std_logic;                      -- Access valid 
  addr        : std_logic_vector(31 downto 0);  -- Access start address
  cmd         : std_logic_vector(3 downto 0);   -- Access type (conf_read/write, io_read/write, data_read/write)
  cbe         : std_logic_vector(3 downto 0);   -- Byte enable (size and offset)
  endianess   : std_logic;                      -- PCI bus endianess
  mode        : std_logic_vector(2 downto 0);   -- Mode[use length, burst] 
  length      : std_logic_vector(15 downto 0);  -- Access length
  active      : std_logic_vector(1 downto 0);   -- [1]: access has data to transfer, [0]: access active
  done        : std_logic_vector(2 downto 0);   -- [2]: access terminated by error, [1]:(PCI master write: all pending fifos acked), [0]: access done
  status      : std_logic_vector(2 downto 0);   -- Error status
  first       : std_logic;                      -- First data in access
  func        : integer range 0 to multifunc;   -- PCI function accessed
  --
  fifo_index  : integer range 0 to FIFO_COUNT-1;-- FIFO index for first data
  fifo_addr   : std_logic_vector(FIFO_DEPTH-1 downto 0);  -- Fifo address
  fifo_wen    : std_logic;                      -- FIFO write enable
  fifo_ren    : std_logic;                      -- FIFO read enable
end record;
constant pci_master_acc_none : pci_master_acc_type := ('0', (others => '0'), (others => '0'), (others => '0'), '0', (others => '0'),
                                            (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0', 0, 0, zero32(FIFO_DEPTH-1 downto 0), '0', '0');
type pci_master_acc_multi_type is array (0 to 1) of pci_master_acc_type;
constant pci_master_acc_multi_none : pci_master_acc_multi_type := (pci_master_acc_none, pci_master_acc_none);

constant acc_sel_ahb : integer := 0;
constant acc_sel_dma : integer := 1;
type ahb_master_acc_type is record
  pending     : std_logic;                      -- Access valid 
  addr        : std_logic_vector(31 downto 0);  -- Access start address
  cbe         : std_logic_vector(3 downto 0);   -- Access byte enable (size and offset)
  endianess   : std_logic;                      -- PCI bus endianess
  acctype     : std_logic_vector(3 downto 0);   -- 
  mode        : std_logic_vector(2 downto 0);   -- Mode[use length, burst] 
  length      : std_logic_vector(15 downto 0);  -- Access length
  burst       : std_logic;                      -- Same as accmode(0);
  --
  fifo_index  : integer range 0 to FIFO_COUNT-1;-- FIFO index for first data
  fifo_addr   : std_logic_vector((FIFO_DEPTH+log2(FIFO_COUNT))-1 downto 0);  -- Fifo address
  fifo_wen    : std_logic;                      -- FIFO write enable
  fifo_ren    : std_logic;                      -- FIFO read enable
  fifo_wdata  : std_logic_vector(31 downto 0);
end record;
constant ahb_master_acc_none : ahb_master_acc_type := ('0', (others => '0'), (others => '0'), '0', (others => '0'), (others => '0'),
                                            (others => '0'), '0', 0, (others => '0'), '0', '0', (others => '0'));

type pci_fifo_type is record
  index : integer range 0 to FIFO_COUNT-1;-- FIFO index
  ctrl  : pci_fifo_in_type;               -- FIFO RAM control signal
end record;
constant pci_fifo_none : pci_fifo_type := (0, pci_fifo_in_none);

type pci_access_type is record 
  addr    : std_logic_vector(31 downto 0);  -- Access address
  ready   : std_logic;                      -- Data ready
  pending : std_logic;                      -- Access saved and pending
  read    : std_logic;                      -- Target read / write access
  burst   : std_logic;                      -- Burst access
  retry   : std_logic;                      -- Access terminated with retry
  acc_type: std_logic_vector(1 downto 0);   -- Access type: 00: memory, 10: configuration space, 11: mapping registers, 01: ext conf space mapped to AHB
  bar     : std_logic_vector(5 downto 0);   -- PCI bar accessed
  func    : integer range 0 to multifunc;   -- PCI function accessed
  match   : std_logic;                      -- Access matching pending access
  continue: std_logic;                      -- Burst may continue
  newacc  : std_logic;                      -- New access, discard old data
  oldburst: std_logic;                      -- When "new access" store last burst
  impcfgreg: std_logic;                     -- Indicates if the current Configuration Space register is implemented
end record;
constant pci_access_none : pci_access_type := ((others => '0'), '0', '0', '0', '0', '0', (others => '0'), (others => '0'), 0, '0', '0', '0', '0', '1');
type pci_access_vector_type is array (0 to 1) of pci_access_type;
constant pci_access_vector_none : pci_access_vector_type := (others => pci_access_none);

type pci_target_type is record
  state           : pci_target_state_type;
  fstate          : pci_target_fifo_state_type;
  cfifo           : pci_core_fifo_vector_type;    -- Core FIFO
  atp             : pci_fifo_type;                -- AMBA to PCI FIFO
  pta             : pci_fifo_type;                -- PCI to AMBA FIFO
  addr            : std_logic_vector(31 downto 0);-- Used as FIFO address during write
  cur_acc         : pci_access_vector_type;              -- Current PCI access
  lcount          : std_logic_vector(2 downto 0); -- Target latency counter 8 clocks (initial latency should 16 clocks)
  preload         : std_logic;                    -- Preload the internal FIFO
  preload_count   : std_logic_vector(1 downto 0); -- Counter used when preloading the internal FIFO
  stop            : std_logic;
  stoped          : std_logic;
  hold            : std_logic_vector(0 downto 0);
  hold_fifo       : std_logic;
  hold_reset      : std_logic;
  hold_write      : std_logic;                     
  first           : std_logic_vector(1 downto 0); -- Used to mark first fifo. bit[1]: first fifo in transfer, bit[0]: first word in fifo 
  conf_addr       : std_logic_vector(3 downto 0);
  first_word      : std_logic;                    -- Indicate first word in access
  diswithout      : std_logic;                    -- Disconnect without data
  addr_perr       : std_logic;                    -- Address Parity Error detected
  abort           : std_logic;                    -- Target abort
  retry           : std_logic;
  discard         : std_logic;
  accbuf          : pci_g_acc_trans_vector_type;  -- PCI target to AHB master access buffer
  blen            : std_logic_vector(15 downto 0);-- PCI target burst length boundary 
  blenmask        : std_logic_vector(15 downto 0);-- PCI target burst length boundary mask
  saverfifo       : std_logic;                    -- Save prefetched FIFO until next PCI access in case of target termination (disconnect without data)
  discardtimeren  : std_logic;                    -- Enable/Disable discard timer
  discardtimer    : std_logic_vector(15 downto 0);-- Discard prefetched data after 2^15 PCI clock cycles
end record;
constant pci_target_none : pci_target_type := (
 pt_idle, ptf_idle, pci_core_fifo_vector_none, pci_fifo_none, pci_fifo_none,
 (others => '0'), pci_access_vector_none, (others => '0'), '0', (others => '0'), '0', '0', 
 (others => '0'), '0', '0', '0', (others => '0'), (others => '0'), 
 '0', '0', '0', '0', '0', '0', pci_g_acc_trans_vector_none, (others => '0'), 
 (others => '0'), '0', '0', (others => '0'));

type pci_master_type is record
  state           : pci_master_state_type;
  fstate          : pci_master_fifo_state_type;
  cfifo           : pci_core_fifo_vector_type;    -- Core FIFO
  abort           : std_logic_vector(1 downto 0); -- Master/Target abort  [0]: master or target abort; [1]: 1 = target abort, 0 = master abort
  ltimer          : std_logic_vector(7 downto 0); -- PCI master latency timer
  framedel        : std_logic;                    -- Delayed frame
  devsel_tout     : std_logic_vector(2 downto 0); -- Devsel time out conter;
  devsel_asserted : std_logic;                    -- Devsel asserted;
  addr            : std_logic_vector(31 downto 0);-- PCI state address
  cbe_data        : std_logic_vector(3 downto 0);            
  cbe_cmd         : std_logic_vector(3 downto 0);            
  hold            : std_logic_vector(1 downto 0); -- Hold transfer due to no available fifo
  hold_fifo       : std_logic;                    -- Hold FIFO due to no available fifo
  done_fifo       : std_logic;                    -- No more FIFO Available 
  done_trans      : std_logic;                    -- No more data in FIFO (transfer done)
  term            : std_logic_vector(1 downto 0); -- Terminate transfer
  done            : std_logic;                    -- Transfer done
  first           : std_logic_vector(1 downto 0); -- First word in current access
  last            : std_logic_vector(1 downto 0); -- Last word in transfer
  preload         : std_logic;
  preload_count   : std_logic_vector(1 downto 0);
  afull           : std_logic;                    -- FIFO almost full on read
  afullcnt        : std_logic_vector(1 downto 0); -- Counter for the three last word in FIFO on read
  burst           : std_logic;                    -- Read burst access => signle accecc or preload
  perren          : std_logic_vector(1 downto 0); -- bit[0]: Drive output enable for Parity error, bit[1] delayed bit[0]
  detectperr      : std_logic_vector(1 downto 0); -- bit[2] = 1: Detect Parity error on write
  twist           : std_logic;                    -- On for PCI configuration space access, otherwise = pr.pta_trans.ca_twist
  first_word      : std_logic;                    -- Indicate first word in access
  waitonstop      : std_logic;
  acc             : pci_master_acc_multi_type;  -- DMA/AHB slave => PCI master accesses
  acc_sel         : integer range 0 to 1;       -- Active access, 0 = AHB slave; 1 = DMA
  acc_cnt         : integer range 0 to MST_ACC_CNT; -- Access transfer count (FIFO), for switching DMA/AHB-slave
  acc_switch      : std_logic;                  -- Access switching DMA/AHB-slave
  fifo_addr       : std_logic_vector((FIFO_DEPTH+log2(FIFO_COUNT))-1 downto 0);  -- Fifo address
  fifo_wdata      : std_logic_vector(31 downto 0);
  fifo_switch     : std_logic;
end record;
constant pci_master_none : pci_master_type := (
  pm_idle, pmf_idle, pci_core_fifo_vector_none, (others => '0'), (others => '0'), '0', 
  (others => '0'), '0', (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0', 
  '0', '0', (others => '0'), '0', (others => '0'), (others => '0'), '0', (others => '0'), '0', 
  (others => '0'), '0', (others => '0'), (others => '0'), '0', '0', '0', pci_master_acc_multi_none,
  0, 0, '0', zero32((FIFO_DEPTH+log2(FIFO_COUNT))-1 downto 0), (others => '0'), '0'); 

type pci_trace_to_apb_trans_type is record
  enable    : std_logic;
  armed     : std_logic;
  wrap      : std_logic;
  taddr     : std_logic_vector(PT_DEPTH-1 downto 0);
  start_ack : std_logic;
  stop_ack  : std_logic;
  --
  dbg_ad      : std_logic_vector(31 downto 0);
  dbg_sig     : std_logic_vector(16 downto 0);
  dbg_cur_ad  : std_logic_vector(31 downto 0);
  dbg_cur_acc : std_logic_vector(8 downto 0);
end record;
constant pci_trace_to_apb_trans_none : pci_trace_to_apb_trans_type := ('0', '0', '0', zero32(PT_DEPTH-1 downto 0), '0', '0',
  (others => '0'), (others => '0'), (others => '0'), (others => '0'));

type apb_to_pci_trace_trans_type is record
  start   : std_logic;
  stop    : std_logic;
  mode    : std_logic_vector(3 downto 0);
  count   : std_logic_vector(PT_DEPTH-1 downto 0);
  tcount  : std_logic_vector(7 downto 0); 
  ad      : std_logic_vector(31 downto 0);
  admask  : std_logic_vector(31 downto 0);
  sig     : std_logic_vector(16 downto 0);
  sigmask : std_logic_vector(16 downto 0);
end record;
constant apb_to_pci_trace_trans_none : apb_to_pci_trace_trans_type := ('0', '0', (others => '0'), zero32(PT_DEPTH-1 downto 0), 
  (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
type pci_trace_type is record
  addr      : std_logic_vector(PT_DEPTH-1 downto 0);
  count     : std_logic_vector(PT_DEPTH-1 downto 0);
  tcount    : std_logic_vector(7 downto 0); 
end record;
constant pci_trace_none : pci_trace_type := (zero32(PT_DEPTH-1 downto 0), zero32(PT_DEPTH-1 downto 0), (others => '0'));

type pci_msd_acc_cancel_acc_multi_type is array (0 to 1) of std_logic_vector(2 downto 0);

type pci_to_ahb_trans_type is record
  -- PCI target <=> AHB master
  tm_acc           : pci_g_acc_trans_type;             -- AHB master access (read/write) [PCI target]
  tm_acc_cancel    : std_logic;                        -- Cancel access [PCI target]
  tm_acc_done_ack  : std_logic;                        -- Ack access done [PCI target]
  tm_fifo          : pci_g_fifo_trans_vector_type;     -- PCI target => AHB master FIFO
  tm_fifo_ack      : pci_g_fifo_ack_trans_vector_type; -- AHB master => PCI target FIFO ack
  -- PCI master <=> AHB slave / DMA
  msd_acc_ack         : std_logic_vector(0 to 1);                     -- PCI master access ack [AHB/DMA]
  --msd_acc_cancel_ack  : std_logic_vector(0 to 1);                     -- Cancel access ack [AHB/DMA]
  msd_acc_cancel_ack  : pci_msd_acc_cancel_acc_multi_type;            -- Cancel access ack [AHB/DMA]
  msd_acc_done        : pci_g_acc_status_trans_multi_type;            -- Access status [AHB/DMA]
  msd_fifo            : pci_g_fifo_trans_vector_multi_type;           -- PCI master => AHB/DMA slave FIFO
  msd_fifo_ack        : pci_g_fifo_ack_trans_vector_multi_type;       -- AHB/DMA slave => PCI master FIFO ack
  -- PCI config space <=> AHB
  ca_host     : std_logic;
  ca_pcimsten : std_logic_vector(0 to multifunc);
  ca_twist    : std_logic;                     -- 1: byte twisting litle (PCI) <~> big (AHB), 0: big (PCI) <=> big (AHB)
  -- PCI system 
  pa_serr       : std_logic;
  pa_discardtout: std_logic;
  rst_ack       : std_logic_vector(2 downto 0);
end record;

type ahb_to_pci_trans_type is record
  -- PCI target <=> AHB master
  tm_acc_ack         : std_logic;                         -- AHB master access ack [PCI target]
  tm_acc_cancel_ack  : std_logic_vector(2 downto 0);      -- Cancel access ack [PCI target]
  tm_acc_done        : pci_g_acc_status_trans_type;       -- Access status [PCI target]
  tm_fifo            : pci_g_fifo_trans_vector_type;      -- AHB master => PCI target FIFO
  tm_fifo_ack        : pci_g_fifo_ack_trans_vector_type;  -- PCI target => AHB master FIFO ack
  -- PCI master <=> AHB slave / DMA
  msd_acc           : pci_g_acc_trans_multi_type;             -- PCI master access (read/write) [AHB/DMA]
  msd_acc_cancel    : std_logic_vector(1 downto 0);           -- Cancel access [AHB/DMA]
  msd_acc_done_ack  : std_logic_vector(1 downto 0);           -- Ack access done [AHB/DMA]
  msd_fifo          : pci_g_fifo_trans_vector_multi_type;     -- AHB/DMA slave => PCI master FIFO
  msd_fifo_ack      : pci_g_fifo_ack_trans_vector_multi_type; -- PCI master => AHB/DMA slave FIFO ack
  -- PCI system
  pa_serr_rst       : std_logic;
  pa_discardtout_rst: std_logic;
  rst               : std_logic_vector(2 downto 0);
  mstswdis          : std_logic;
end record;

type pci_sync_type is array (1 to 2) of ahb_to_pci_trans_type;
type ahb_sync_type is array (1 to 2) of pci_to_ahb_trans_type;
type pci_trace_sync_type is array (1 to 2) of apb_to_pci_trace_trans_type;
type apb_sync_type is array (1 to 2) of pci_trace_to_apb_trans_type;
type ahb_to_pci_map_type is array (0 to 15) of std_logic_vector(31 downto 0);
constant ahb_to_pci_map_none : ahb_to_pci_map_type := (others => (others => '0'));

-- Calculate AADDR_WIDTH for HMASK
function calc_aaddr_width(di : in integer) return integer is
    variable bits : integer;
begin
    if di = 16#800# then bits := 31;
    elsif di = 16#c00# then bits := 30;
    elsif di = 16#e00# then bits := 29;
    elsif di = 16#f00# then bits := 28;
    elsif di = 16#f80# then bits := 27;
    elsif di = 16#fc0# then bits := 26;
    elsif di = 16#fe0# then bits := 25;
    elsif di = 16#ff0# then bits := 24;
    elsif di = 16#ff8# then bits := 23;
    elsif di = 16#ffc# then bits := 22;
    elsif di = 16#ffe# then bits := 21;
    elsif di = 16#fff# then bits := 20; 
    else bits := 4; end if;
    return bits;
end function;
constant AADDR_WIDTH : integer := calc_aaddr_width(hmask);

type pci_reg_type is record
  conf      : pci_config_space_multi_type;-- Configuration Space
  po        : pci_reg_out_type;     -- PCI output signals
  m         : pci_master_type;      -- PCI Master
  t         : pci_target_type;      -- PCI Target
  pta_trans : pci_to_ahb_trans_type;-- Signals between PCI clock domain and AHB clock domain (need synchronisation)
  sync      : pci_sync_type;
  pt        : pci_trace_type;
  ptta_trans: pci_trace_to_apb_trans_type;
  pt_sync   : pci_trace_sync_type;   
  pciinten  : std_logic_vector(3 downto 0); -- Drives output enable for INTA..D
  pci66     : std_logic_vector(1 downto 0);
  debug     : std_logic_vector(31 downto 0);
end record;

subtype AHB_FIFO_BITS is natural range FIFO_DEPTH + 1 downto 2;
type amba_master_state_type is (am_idle, am_read, am_write, am_error);
type amba_master_type is record
  state     : amba_master_state_type;
  first     : std_logic_vector(2 downto 0);                    -- First data in access (mark starting fifo)
  done      : std_logic_vector(2 downto 0);
  stop      : std_logic;
  dmai0     : dma_ahb_in_type;
  dma_hold  : std_logic;
  active    : std_logic;
  retry     : std_logic;
  retry_blen: std_logic_vector(15 downto 0);
  retry_size: std_logic_vector(1 downto 0);
  retry_offset: std_logic_vector(1 downto 0);
  acc       : ahb_master_acc_type;  -- PCI target => AHB master accesses
  hold      : std_logic_vector(2 downto 0); 
  last      : std_logic_vector(2 downto 0);
  faddr     : std_logic_vector(AHB_FIFO_BITS);
  blen      : std_logic_vector(15 downto 0);
end record;
constant amba_master_none : amba_master_type := (
  am_idle, (others => '0'), (others => '0'), '0', dma_ahb_in_none, '0', '0', '0', (others => '0'), (others => '0'),
  (others => '0'), ahb_master_acc_none, (others => '0'), (others => '0'), (others => '0'), (others => '0')); 

type amba_slave_state_type is (as_idle, as_checkpcimst, as_read, as_write, as_pcitrace);
type amba_slave_type is record
  state     : amba_slave_state_type;
  atp       : pci_fifo_type;
  pta       : pci_fifo_type;
  hready    : std_logic;
  hwrite    : std_logic;
  hsel      : std_logic;
  hmbsel    : std_logic_vector(0 to 2);
  hresp     : std_logic_vector(1 downto 0);            
  htrans    : std_logic_vector(1 downto 0);             
  hsize     : std_logic_vector(2 downto 0);
  hmaster   : std_logic_vector(3 downto 0);
  hburst    : std_logic;
  haddr     : std_logic_vector(31 downto 0);
  retry     : std_logic;
  first     : std_logic;                      -- First access in transfer
  firstf    : std_logic;                      -- First fifo
  pending   : std_logic_vector(1 downto 0);
  addr      : std_logic_vector(31 downto 0);
  offset    : std_logic_vector(1 downto 0);
  master    : std_logic_vector(3 downto 0);
  write     : std_logic;
  oneword   : std_logic;
  burst     : std_logic;
  config    : std_logic;
  io        : std_logic;
  size      : std_logic_vector(2 downto 0);
  start     : std_logic;
  hrdata    : std_logic_vector(31 downto 0);
  continue  : std_logic;
  discard   : std_logic;
  atp_map   : ahb_to_pci_map_type;
  io_map    : std_logic_vector(31 downto 16);
  cfg_bus   : std_logic_vector(23 downto 16);
  cfg_status: std_logic_vector(1 downto 0);
  io_cfg_burst : std_logic_vector(1 downto 0);  -- Alow burst on PCI IO / CONF
  erren     : std_logic;                        -- Enables AHB error response for Master/Target abort
  parerren  : std_logic;                        -- Enables AHB error response for PAR error
  accbuf    : pci_g_acc_trans_vector_type;      -- AHB slave to PCI master access buffer
  blen      : std_logic_vector(7 downto 0);     -- AHB slave prefetch burst length
  blenmask  : std_logic_vector(15 downto 0);    -- AHB slave prefetch length AHB master mask
  done_fifo : std_logic_vector(1 downto 0); 
  tb_ren    : std_logic;                        -- PCI trace buffer read enable
  fakehost  : std_logic;                        -- Fake device in system slot (HOST)
  stoppciacc: std_logic;
end record;
constant amba_slave_none : amba_slave_type := (
  as_idle, pci_fifo_none, pci_fifo_none, '1', '0', '0', (others => '0'), (others => '0'),
  (others => '0'), (others => '0'), (others => '0'), '0', (others => '0'), '0', '0', '0', 
  (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0', '0', '0', '0', '0',
  (others => '0'), '0', (others => '0'), '0', '0', ahb_to_pci_map_none, (others => '0'),
  (others => '0'), (others => '0'), (others => '0'), '0', '0', pci_g_acc_trans_vector_none,
  (others => '0'), (others => '0'), (others => '0'), '0', '0', '0'); 

type irq_reg_type is record
  device_mask  : std_logic_vector(3 downto 0);
  device_force : std_logic;
  host_mask    : std_logic_vector(3 downto 0);
  host_status  : std_logic_vector(3 downto 0);
  host_pirq_vl : std_logic_vector(3 downto 0);
  host_pirq_l  : std_logic;
  access_en    : std_logic; -- Enables IRQ for Master/Target abort and PAR error
  access_status: std_logic_vector(2 downto 0);
  access_pirq  : std_logic;
  access_pirq_l: std_logic;
  system_en    : std_logic; -- Enables IRQ for System error
  system_status: std_logic_vector(1 downto 0);
  system_pirq  : std_logic;
  system_pirq_l: std_logic;
  dma_pirq_l   : std_logic;
  irqen        : std_logic;
end record;
constant irq_reg_none : irq_reg_type := (
  (others => '0'), '0', (others => '0'), (others => '0'), (others => '0'),
  '0', '0', (others => '0'), '0', '0', '0', (others => '0'), '0', '0', '0', '0'); 

type dma_state_type is (dma_idle, dma_read_desc, dma_next_channel, dma_write_status, dma_read, dma_write, dma_error);
type dma_desc_type is record
  en      : std_logic;
  irqen   : std_logic;
  write   : std_logic;
  tw      : std_logic;
  desctype: std_logic_vector(1 downto 0);
  cio     : std_logic_vector(1 downto 0);
  len     : std_logic_vector(15 downto 0);
  ch      : std_logic_vector(31 downto 0);
  nextch  : std_logic_vector(31 downto 0);
  addr    : std_logic_vector(31 downto 0);
  nextdesc: std_logic_vector(31 downto 0);
  cnt     : std_logic_vector(15 downto 0);
  emptych : std_logic;
  chcnt   : std_logic_vector(2 downto 0);
  paddr   : std_logic_vector(31 downto 0);
  aaddr   : std_logic_vector(31 downto 0);
  acctype : std_logic_vector(3 downto 0);
  chid    : std_logic_vector(2 downto 0);
end record;
constant dma_desc_none : dma_desc_type := (
  '0', '0', '0', '0', (others => '0'), (others => '0'), (others => '0'), (others => '0'),
  (others => '0'), (others => '0'), (others => '0'), (others => '0'), '0',
  (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0')); 
type dma_reg_type is record
  state     : dma_state_type;
  dmai1     : dma_ahb_in_type;
  desc      : dma_desc_type;
  dtp       : pci_fifo_type;
  ptd       : pci_fifo_type;
  rcnt      : std_logic_vector(1 downto 0);
  en        : std_logic;
  err       : std_logic_vector(2 downto 0);
  errlen    : std_logic_vector(15 downto 0);
  numch     : std_logic_vector(2 downto 0);
  dma_hold  : std_logic_vector(2 downto 0);
  dma_last  : std_logic_vector(2 downto 0);
  newfifo   : std_logic;
  active    : std_logic;
  done      : std_logic_vector(1 downto 0);
  faddr     : std_logic_vector(AHB_FIFO_BITS);
  first     : std_logic_vector(2 downto 0);
  retry     : std_logic;
  retry_len : std_logic_vector(15 downto 0);
  addr      : std_logic_vector(31 downto 0);
  irq       : std_logic;
  irqen     : std_logic;
  irqstatus : std_logic_vector(1 downto 0);
  len       : std_logic_vector(15 downto 0);
  errstatus : std_logic_vector(4 downto 0);   -- DMA error status
  irqch     : std_logic_vector(7 downto 0);   -- DMA Channel irq status
  running   : std_logic;                      -- DMA is running
end record;
constant dma_reg_none : dma_reg_type := (
  dma_idle, dma_ahb_in_none, dma_desc_none, pci_fifo_none, pci_fifo_none,
  (others => '0'), '0', (others => '0'), (others => '0'), (others => '0'),
  (others => '0'), (others => '0'), '0', '0', (others => '0'), zero32(AHB_FIFO_BITS),
  (others => '0'), '0', (others => '0'), (others => '0'), '0', '0', (others => '0'),
  (others => '0'), (others => '0'), (others => '0'), '0'); 

type amba_reg_type is record
  m         : amba_master_type;
  atp_trans : ahb_to_pci_trans_type;
  sync      : ahb_sync_type;
  s         : amba_slave_type;
  irq       : irq_reg_type;
  dma       : dma_reg_type;
  atpt_trans: apb_to_pci_trace_trans_type;
  apb_sync  : apb_sync_type;
  apb_pt_stat : std_logic_vector(31 downto 0);
  apb_pr_conf_0_pta_map : pci_bars_type;                -- PCI to AHB mapping for each PCI bar (read only)
  debug     : std_logic_vector(31 downto 0);
  debug_pr  : std_logic_vector(31 downto 0);
  debuga    : std_logic_vector(31 downto 0);
end record;

constant REVISION : amba_version_type := 1;
constant pconfig : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRPCI2, 0, REVISION, irq),
    1 => apb_iobar(paddr, pmask));

-- APB DEBUG
constant tbpconfig : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRPCI2_TB, 0, REVISION, 0),
    1 => apb_iobar(tbpaddr, tbpmask));

constant hconfig : ahb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GRPCI2, 0, REVISION, 0),
    4 => ahb_membar(haddr, '0', '0', hmask),
    5 => ahb_iobar (ioaddr, HIOMASK),
    others => zero32);

constant oeon : std_logic := conv_std_logic_vector(oepol,1)(0);
constant oeoff : std_logic := not conv_std_logic_vector(oepol,1)(0);
constant ones32 : std_logic_vector(31 downto 0) := (others => '1');

signal pr, prin   : pci_reg_type;
signal pi, piin   : pci_in_type;  -- Registered PCI signals.
signal pcirstout   : std_logic;    -- PCI reset
signal pciasyncrst, pciasyncrst_comb : std_logic;    -- PCI asynchronous reset
signal pcirst : std_logic_vector(2 downto 0);    -- PCI reset
signal pciinten,pciinten_pad   : std_logic_vector(3 downto 0);
signal pcisig : std_logic_vector(16 downto 0);
signal po, poin, po_keep  : pci_reg_out_type;     -- PCI output signals (to drive pads)
signal poin_keep    : std_logic_vector(90 downto 0);
signal raden, rinaden, rinaden_tmp : std_logic_vector(31 downto 0);
signal pr_pta_trans_gated : pci_to_ahb_trans_type; -- PCI Target => AHB Master pending gated with pcirst

signal tm_fifoo_atp  : pci_fifo_out_type; -- FIFO output data
signal ms_fifoo_atp  : pci_fifo_out_type; -- FIFO output data
signal tm_fifoo_pta  : pci_fifo_out_type;
signal ms_fifoo_pta  : pci_fifo_out_type;
signal md_fifoo_dtp  : pci_fifo_out_type; -- DMA FIFO output data
signal md_fifoo_ptd  : pci_fifo_out_type;
signal pt_fifoo_ad   : pci_fifo_out_type; -- PCI trace output data
signal pt_fifoo_sig  : pci_fifo_out_type;

-- Scan test support
signal scanen                               : std_logic;
signal testin                               : std_logic_vector(TESTIN_WIDTH-1 downto 0);
signal scan_prin_t_atp_ctrl_en              : std_logic;
signal scan_ar_m_acc_fifo_wen               : std_logic;
signal scan_arin_m_acc_fifo_ren             : std_logic;
signal scan_pr_t_pta_ctrl_en                : std_logic;
signal scan_prin_m_acc_acc_sel_ahb_fifo_ren : std_logic;
signal scan_ar_s_atp_ctrl_en                : std_logic;
signal scan_arin_s_pta_ctrl_en              : std_logic;
signal scan_pr_m_acc_acc_sel_ahb_fifo_wen   : std_logic;
signal scan_prin_m_acc_acc_sel_dma_fifo_ren : std_logic;
signal scan_ar_dma_dtp_ctrl_en              : std_logic;
signal scan_arin_dma_ptd_ctrl_en            : std_logic;
signal scan_pr_m_acc_acc_sel_dma_fifo_wen   : std_logic;
signal scan_tb_ren                          : std_logic;
signal scan_pr_ptta_trans_enable            : std_logic;

signal tb_addr     : std_logic_vector(31 downto 0); -- Trace Buffer address
signal tb_ren      : std_logic;                     -- Trace Buffer read enable

signal ar, arin : amba_reg_type;
signal dmao0, dmao1  : dma_ahb_out_type;
signal disabled_dmai : dma_ahb_in_type;
signal ahbmo_con : ahb_mst_out_type; -- Connect AHB-master to ahbmo

signal lpcim_rst, lpcit_rst, lpci_rst: std_ulogic;
signal lahbm_rst, lahbs_rst, lahb_rst: std_ulogic;


signal iotmdin: std_logic_vector(45 downto 0);
signal iotmdout: std_logic_vector(44 downto 0);
signal iotmact, iotmoe: std_ulogic;

attribute sync_set_reset of lpcim_rst : signal is "true";
attribute sync_set_reset of lpcit_rst : signal is "true";
attribute sync_set_reset of lpci_rst : signal is "true";
attribute sync_set_reset of pcirst : signal is "true";

--attribute sync_set_reset of rst : signal is "true";
attribute sync_set_reset of lahbm_rst : signal is "true";
attribute sync_set_reset of lahbs_rst : signal is "true";
attribute sync_set_reset of lahb_rst : signal is "true";

type bar_size_type is array (0 to 5) of integer range 0 to 31;
constant func0_bar_size : bar_size_type := (bar0, bar1, bar2, bar3, bar4, bar5);
constant func1_bar_size : bar_size_type := (mf1_bar0, mf1_bar1, mf1_bar2, mf1_bar3, mf1_bar4, mf1_bar5);
constant none_bar_size : bar_size_type := (0, 0, 0, 0, 0, 0);
type bar_size_vector_type is array (0 to 7) of bar_size_type;
constant bar_size : bar_size_vector_type := (func0_bar_size, func1_bar_size, none_bar_size, none_bar_size, 
                                              none_bar_size, none_bar_size, none_bar_size, none_bar_size);
constant func0_bar_type : std_logic_vector(15 downto 0) := conv_std_logic_vector(bartype,16);
constant func1_bar_type : std_logic_vector(15 downto 0) := conv_std_logic_vector(mf1_bartype,16);
constant func0_bar_prefetch : std_logic_vector(5 downto 0) := func0_bar_type(5 downto 0);
constant func1_bar_prefetch : std_logic_vector(5 downto 0) := func1_bar_type(5 downto 0);
type bar_prefetch_vector_type is array (0 to 7) of std_logic_vector(5 downto 0);
constant bar_prefetch : bar_prefetch_vector_type := (func0_bar_prefetch, func1_bar_prefetch, (others => '0'), (others => '0'), 
                                                     (others => '0'), (others => '0'), (others => '0'), (others => '0'));
constant func0_bar_io : std_logic_vector(5 downto 0) := func0_bar_type(13 downto 8);
constant func1_bar_io : std_logic_vector(5 downto 0) := func1_bar_type(13 downto 8);
constant bar_io : bar_prefetch_vector_type := (func0_bar_io, func1_bar_io, (others => '0'), (others => '0'), 
                                                     (others => '0'), (others => '0'), (others => '0'), (others => '0'));
type conf_int_vector_type is array (0 to 7) of integer;
constant deviceid_vector : conf_int_vector_type := (deviceid, mf1_deviceid, 0, 0, 0, 0, 0, 0);
constant classcode_vector : conf_int_vector_type := (classcode, mf1_classcode, 0, 0, 0, 0, 0, 0);
constant revisionid_vector : conf_int_vector_type := (revisionid, mf1_revisionid, 0, 0, 0, 0, 0, 0);
constant cap_pointer_vector : conf_int_vector_type := (cap_pointer, mf1_cap_pointer, 0, 0, 0, 0, 0, 0);
constant ext_cap_pointer_vector : conf_int_vector_type := (ext_cap_pointer, mf1_ext_cap_pointer, 0, 0, 0, 0, 0, 0);
constant extcfg_vector : conf_int_vector_type := (extcfg, mf1_extcfg, 0, 0, 0, 0, 0, 0);
type conf_vector16_vector_type is array (0 to 7) of std_logic_vector(15 downto 0);
constant masters_vector : conf_vector16_vector_type := (conv_std_logic_vector(masters, 16), conv_std_logic_vector(mf1_masters, 16), 
                                                                            x"0000", x"0000", x"0000", x"0000", x"0000", x"0000");
constant deviceirq_vector : conf_int_vector_type := (1*deviceirq, (1+1*multiint)*deviceirq, (1+2*multiint)*deviceirq, (1+3*multiint)*deviceirq, 
                                                     1*deviceirq, (1+1*multiint)*deviceirq, (1+2*multiint)*deviceirq, (1+3*multiint)*deviceirq); 
type default_bar_map_type is array (0 to 7) of pci_bars_type;
constant default_bar_map : default_bar_map_type := ((conv_std_logic_vector(bar0_map, 24)&x"00", conv_std_logic_vector(bar1_map, 24)&x"00", 
                                                     conv_std_logic_vector(bar2_map, 24)&x"00", conv_std_logic_vector(bar3_map, 24)&x"00",
                                                     conv_std_logic_vector(bar4_map, 24)&x"00", conv_std_logic_vector(bar5_map, 24)&x"00"),
                                                    (conv_std_logic_vector(mf1_bar0_map, 24)&x"00", conv_std_logic_vector(mf1_bar1_map, 24)&x"00", 
                                                     conv_std_logic_vector(mf1_bar2_map, 24)&x"00", conv_std_logic_vector(mf1_bar3_map, 24)&x"00",
                                                     conv_std_logic_vector(mf1_bar4_map, 24)&x"00", conv_std_logic_vector(mf1_bar5_map, 24)&x"00"),
                                                    pci_bars_none, pci_bars_none, pci_bars_none, pci_bars_none, pci_bars_none, pci_bars_none);

function blenmask_size(barminsize : in  integer)
                          return integer is
  variable res : integer;
begin
  res := 16;
  if barminsize < 16 then res := barminsize; end if;
  return (res - 1);
end function;

function set_pta_addr(paddr   : in std_logic_vector(31 downto 0); 
                      pta_map : in pci_bars_type; 
                      bar     : in std_logic_vector(5 downto 0); 
                      bar_mask: in pci_bars_type;
                      barminsize : in integer) 
                      return std_logic_vector is
  variable res : std_logic_vector(31 downto 0);
begin
  res := paddr;
  for i in 0 to 5 loop
    if bar(i) = '1' then
      res(31 downto barminsize) := (pta_map(i)(31 downto barminsize) and bar_mask(i)(31 downto barminsize)) or
                                   (paddr(31 downto barminsize) and not bar_mask(i)(31 downto barminsize));
    end if;
  end loop;
  return res;
end function;

function byte_twist(di : in std_logic_vector(31 downto 0); twist : in std_logic) return std_logic_vector is
  variable do : std_logic_vector(31 downto 0);
begin
  if twist = '1' then
    for i in 0 to 3 loop
      do(31-i*8 downto 24-i*8) := di(31-(3-i)*8 downto 24-(3-i)*8);
    end loop;
  else
    do := di;
  end if;
  return do; 
end function;

function set_size_from_cbe(cbe  : in std_logic_vector(3 downto 0))
                           return std_logic_vector is
variable res : std_logic_vector(1 downto 0);
begin
  case cbe is                       
    when "0111" => res := "00";
    when "1011" => res := "00";
    when "1101" => res := "00";
    when "1110" => res := "00";
    when "0011" => res := "01";
    when "1100" => res := "01";
    when others => res := "10";
  end case;
  return res;
end function;

function set_addr_from_cbe(cbe  : in std_logic_vector(3 downto 0);
                           twist: in std_logic)
                           return std_logic_vector is
variable res : std_logic_vector(1 downto 0);
begin
  if twist = '1' then -- Little (PCI) to big (AHB) endian
    case cbe is
      when "0111" => res := "11";
      when "1011" => res := "10";
      when "1101" => res := "01";
      when "1110" => res := "00";
      when "0011" => res := "10";
      when "1100" => res := "00";
      when others => res := "00";
    end case;
  else                -- Big (PCI) to big (AHB) endian
    case cbe is
      when "0111" => res := "00";
      when "1011" => res := "01";
      when "1101" => res := "10";
      when "1110" => res := "11";
      when "0011" => res := "00";
      when "1100" => res := "10";
      when others => res := "00";
    end case;
  end if;
  return res;
end function;

function set_cbe_from_size_addr(size  : in std_logic_vector(2 downto 0);
                                addr  : in std_logic_vector(1 downto 0);
                                twist : in std_logic)
                           return std_logic_vector is
variable res : std_logic_vector(3 downto 0);
begin
  if twist = '1' then
    if size = "000" then     -- byte 
      case addr is 
        when "11" => res := "0111";
        when "10" => res := "1011";
        when "01" => res := "1101";
        when others => res := "1110";
      end case;
    elsif size = "001" then  -- half word
      case addr is
        when "10" => res := "0011";
        when others => res := "1100";
      end case;
    else
      res := "0000";
    end if;
  else
    if size = "000" then     -- byte 
      case addr is 
        when "11" => res := "1110";
        when "10" => res := "1101";
        when "01" => res := "1011";
        when others => res := "0111";
      end case;
    elsif size = "001" then  -- half word
      case addr is
        when "10" => res := "1100";
        when others => res := "0011";
      end case;
    else
      res := "0000";
    end if;
  end if;
  return res;
end function;

function set_atp_addr(haddr   : in std_logic_vector(31 downto 0); 
                      atp_map : in ahb_to_pci_map_type; 
                      hmaster : in std_logic_vector(3 downto 0); 
                      size    : in integer) 
                      return std_logic_vector is
  variable res : std_logic_vector(31 downto 0);
  variable i : integer;
begin
  i := conv_integer(hmaster);
  res := haddr;
  if AADDR_WIDTH /= 4 then
    res(31 downto size) := atp_map(i)(31 downto size);
  end if;
  return res;
end function;

function set_pci_conf_addr(addr     : in std_logic_vector(31 downto 0);
                           cfg_bus  : in std_logic_vector(23 downto 16))
                           return std_logic_vector is
variable res : std_logic_vector(31 downto 0);
variable i   : integer range 0 to 21;
begin
  res := (others => '0');
  i := conv_integer(addr(15 downto 11));
  
  if cfg_bus = zero32(23 downto 16) then  -- Type 0 config
    if i /= 0 then
      res(10 + i) := '1';
    end if;
    res(10 downto 2) := addr(10 downto 2); -- Function number [10:8], Register address [7:2]
    res(0) := '0'; -- Type 
  else                    -- Type 1 config
    res(23 downto 16) := cfg_bus;
    res(15 downto 2) := addr(15 downto 2); -- Function number [10:8], Register address [7:2]
    res(0) := '1'; -- Type 
  end if;

  return res;
end function;

function set_pci_io_addr(addr   : in std_logic_vector(31 downto 0);
                         io_map : in std_logic_vector(31 downto 16))
                           return std_logic_vector is
variable res : std_logic_vector(31 downto 0);
begin
  res := io_map & addr(15 downto 0);
  return res;
end function;

function set_pci_io_byte_addr(addr      : in std_logic_vector(1 downto 0);
                              size      : in std_logic_vector(2 downto 0);
                              twist     : in std_logic)
                             return std_logic_vector is
variable res : std_logic_vector(1 downto 0);
begin
  if twist = '1' then
    res := addr;
  else
    if size = "010" then
      res := "00";
    elsif size = "001" then
      case addr is
        when "00"   => res := "10";
        when others => res := "00";
      end case;
    else
      case addr is
        when "00" => res := "11";
        when "01" => res := "10";
        when "10" => res := "01";
        when "11" => res := "00";
        when others => res := "00";
      end case;
    end if;
  end if;
  return res;
end function;

begin

  -- PHY =>
  pciphy0 : grpci2_phy_wrapper 
  generic map(tech => memtech, oepol => oepol, 
              bypass => bypass, netlist => netlist,
              scantest => scantest, iotest => iotest)
  port map(
    pciclk  => pciclk,
    pcii    => pcii,
    phyi    => phyi,
    pcio    => pcio,
    phyo    => phyo,
    iotmact => iotmact,
    iotmoe  => iotmoe,
    iotdout => iotmdout,
    iotdin  => iotmdin
  );
    phyi.pciasyncrst         <= pciasyncrst;
    phyi.pcisoftrst          <= sig_soft_rst;
    phyi.pcirstout           <= pcirstout;
    phyi.pciinten            <= pciinten_pad;
    phyi.m_request           <= sig_m_request; 
    phyi.m_mabort            <= sig_m_mabort; 
    phyi.pr_m_fstate         <= pr.m.fstate; 
    phyi.pr_m_cfifo          <= pr.m.cfifo; 
    phyi.pv_m_cfifo          <= prin.m.cfifo; 
    phyi.pr_m_addr           <= pr.m.addr; 
    phyi.pr_m_cbe_data       <= pr.m.cbe_data; 
    phyi.pr_m_cbe_cmd        <= pr.m.cbe_cmd; 
    phyi.pr_m_first          <= pr.m.first(1 downto 0); 
    phyi.pv_m_term           <= prin.m.term(1 downto 0); 
    phyi.pr_m_ltimer         <= pr.m.ltimer;
    phyi.pr_m_burst          <= pr.m.burst;
    phyi.pr_m_abort          <= pr.m.abort(0 downto 0); 
    phyi.pr_m_perren         <= pr.m.perren(0 downto 0); 
    phyi.pr_m_done_fifo      <= pr.m.done_fifo;
    phyi.t_abort             <= sig_t_abort; 
    phyi.t_ready             <= sig_t_ready; 
    phyi.t_retry             <= sig_t_retry; 
    phyi.pr_t_state          <= pr.t.state; 
    phyi.pv_t_state          <= prin.t.state; 
    phyi.pr_t_fstate         <= pr.t.fstate; 
    phyi.pr_t_cfifo          <= pr.t.cfifo; 
    phyi.pv_t_diswithout     <= prin.t.diswithout; 
    phyi.pr_t_stoped         <= pr.t.stoped; 
    phyi.pr_t_lcount         <= pr.t.lcount; 
    phyi.pr_t_first_word     <= pr.t.first_word; 
    phyi.pr_t_cur_acc_0_read <= pr.t.cur_acc(0).read;
    phyi.pv_t_hold_write     <= prin.t.hold_write;
    phyi.pv_t_hold_reset     <= prin.t.hold_reset;
    phyi.pr_conf_comm_perren <= sig_pr_conf_comm_perren;
    phyi.pr_conf_comm_serren <= sig_pr_conf_comm_serren; -- SERR# only asserted for address parity error
    phyi.testen              <= ahbsi.testen when scantest=1 else '0';
    phyi.testoen             <= ahbsi.testoen;
    phyi.testrst             <= ahbsi.testrst;
  
    pcirst <= (others => phyo.pcirsto(0));
    pi <= phyo.pio;
    po <= phyo.poo;
  -- PHY <=

disabled_dmai <= ('0', '0', (others => '0'), (others => '0'), (others => '0'), '0', '0');

scanen <= (ahbsi.testen and ahbsi.scanen) when (scantest = 1) else '0';
testin <= ahbsi.testen & "0" & ahbsi.testin(TESTIN_WIDTH-3 downto 0);

pciasyncrst <= ahbsi.testrst when (scantest = 1) and (ahbsi.testen = '1') else pcii.rst;
pciasyncrst_comb <= pcii.rst;           -- Version used in comb logic, don't mux in testrst

hostrst2 : if hostrst = 2 generate
    pcirstout <= rst and not ar.atp_trans.rst(2);
end generate;
hostrst1 : if hostrst = 1 generate
    pcirstout <= rst and not ar.atp_trans.rst(2) when pcii.host = '0' else '1';
end generate;
hostrst0 : if hostrst = 0 generate
    pcirstout <= '1';
end generate;
    
-- Propagate PCI reset to AMBA for peripheral devices
ptarst <= pcii.rst when pcii.host = '1' and hostrst /= 2 else '1';

-- PCI trace signal
pcisig <= pi.cbe & 
          pi.frame & pi.irdy & pi.trdy & pi.stop & 
          pi.devsel & pi.par & pi.perr & pi.serr & 
          pi.idsel & pr.po.req & pi.gnt & pi.lock & 
          pi.rst; -- & "000";
  
pcomb : process(pr, pi, pcirst(0), pcii, ar.atp_trans, tm_fifoo_atp, ms_fifoo_atp, md_fifoo_dtp, pcirstout, pciinten, pcisig, ar.atpt_trans,
               phyo, pciasyncrst_comb, lpcim_rst, lpcit_rst, lpci_rst, iotmact)
variable pv         : pci_reg_type;
variable atp_trans  : ahb_to_pci_trans_type;
variable pci        : pci_in_type;
variable t_hit      : std_logic;  -- Target bar address match
variable t_chit     : std_logic;  -- Target configuration space hit
variable t_bar      : std_logic_vector(5 downto 0); -- PCI bar with hit
variable t_func     : integer range 0 to multifunc;
variable t_ready    : std_logic;  -- Backend ready to send/receive data
variable t_abort    : std_logic;  -- Stop PCI access
variable t_retry    : std_logic;  -- Stop PCI access
variable t_index    : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable t_cad      : std_logic_vector(31 downto 0);  -- Data from PCI Configuration Space Header
variable conf_func  : integer range 0 to 7;
variable all_func_serren : std_logic;
variable t_acc_type : std_logic_vector(1 downto 0);
variable t_acc_impcfgreg: std_logic;
variable t_acc_burst: std_logic;
variable t_acc_read : std_logic;
variable tm_acc_pending   : std_logic;
variable tm_acc_cancel    : std_logic;
variable tm_acc_done      : std_logic;
variable tm_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable tm_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable tm_fifo          : pci_g_fifo_trans_vector_type;
variable accbufindex      : integer range 0 to 3;
-- PCI master
variable m_request  : std_logic;
variable m_ready    : std_logic;
variable m_mabort   : std_logic;  -- Master abort
variable m_tabort   : std_logic;  -- Target abort
variable m_index    : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable m_func     : integer range 0 to multifunc;
variable acc          : pci_master_acc_type;
variable accdone      : std_logic; -- Renamed to be synthesized with XST
variable acc_cancel   : std_logic;
variable acc_switch   : std_logic;
variable fifo         : pci_g_fifo_trans_vector_type;
variable fifo_pending : std_logic_vector(FIFO_COUNT-1 downto 0);
variable fifo_empty   : std_logic_vector(FIFO_COUNT-1 downto 0);
variable fifo_nindex  : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable msd_acc          : pci_g_acc_trans_multi_type;
variable ms_acc_pending   : std_logic; 
variable ms_acc_done      : std_logic;
variable ms_acc_cancel    : std_logic;
variable ms_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable ms_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable ms_fifo          : pci_g_fifo_trans_vector_type;
variable md_acc_pending   : std_logic; 
variable md_acc_done      : std_logic;
variable md_acc_cancel    : std_logic;
variable md_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable md_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable md_fifo          : pci_g_fifo_trans_vector_type;
-- PCI trace
variable pt_start : std_logic;
variable pt_stop  : std_logic;
variable atpt_trans : apb_to_pci_trace_trans_type;
variable pt_setup : apb_to_pci_trace_trans_type;
constant z : std_logic_vector(48 downto 0) := (others => '0');
-- Soft reset
variable pci_target_rst : std_logic;
variable pci_master_rst : std_logic;
variable pci_hard_rst   : std_logic;
begin
  -- --------------------------------------------------------------------------------
  -- Global defaults
  -- --------------------------------------------------------------------------------

  -- Defaults
  pv := pr; 

  pv.pta_trans.ca_host := pcii.host;
  pv.pci66(0) := pcii.pci66; pv.pci66(1) := pr.pci66(0);

  -- FIFO and PCI<=>AHB sync
  pv.sync(1) := ar.atp_trans; pv.sync(2) := pr.sync(1);
  if nsync = 0 then atp_trans := ar.atp_trans;
  else atp_trans := pr.sync(nsync); end if;
  
  -- PCI soft reset
  pv.pta_trans.rst_ack(0) := atp_trans.rst(0);
  pv.pta_trans.rst_ack(1) := atp_trans.rst(1);
  pci_target_rst := not pr.pta_trans.rst_ack(0) and (pr.pta_trans.rst_ack(0) xor atp_trans.rst(0)); 
  pci_master_rst := not pr.pta_trans.rst_ack(1) and (pr.pta_trans.rst_ack(1) xor atp_trans.rst(1)); 
  pci_hard_rst := atp_trans.rst(2); 

  pci := phyo.pciv;
  
  
  if (pr.po.perr = '0'                                                                                          -- Parity Error detected
      and (pr.m.perren /= "00")) then                                                                       -- During master read
    pv.conf(pr.m.acc(pr.m.acc_sel).func).stat.dpe := '1';
  end if;
  if (pr.po.perr = '0'                                                                                          -- Parity Error detected
     and ((pr.t.state = pt_s_data or pr.t.state = pt_turn_ar) and pr.t.cur_acc(0).read = '0'))                  -- Write to target
     or (pr.t.addr_perr = '1') then                                                                             -- Parity Error in Address phase
    pv.conf(pr.t.cur_acc(0).func).stat.dpe := '1';
  end if;
  
  -- Signaled System Error
  for j in 0 to multifunc loop
    if pr.conf(j).comm.perren = '1' and pr.conf(j).comm.serren = '1' and pr.po.serren = oeon then
      pv.conf(j).stat.sse := '1';
    end if;
  end loop;

  -- SERR to AHB
  if atp_trans.pa_serr_rst = '1' then
    pv.pta_trans.pa_serr := '1';
  elsif pi.serr = '0' then
    pv.pta_trans.pa_serr := '0';
  end if;

  -- --------------------------------------------------------------------------------
  -- PCI master defaults
  -- --------------------------------------------------------------------------------
  
  -- Default
  m_request := '0';
  m_ready := '0';
  m_ready := '1'; 

  pv.m.fifo_switch := '0';
  pv.m.acc(0).fifo_ren := '0'; -- read enable [AHB]
  pv.m.acc(0).fifo_wen := '0'; -- write enable [AHB]
  pv.m.acc(1).fifo_ren := '0'; -- read enable [DMA]
  pv.m.acc(1).fifo_wen := '0'; -- write enable [DMA]
  pv.m.fifo_wdata := byte_twist(pi.ad, pr.m.twist);

  pv.m.framedel := pr.po.frame;
  
  ms_acc_pending := atp_trans.msd_acc(0).pending xor pr.pta_trans.msd_acc_ack(0);
  ms_acc_done := atp_trans.msd_acc_done_ack(0) xor pr.pta_trans.msd_acc_done(0).done;
  ms_acc_cancel := atp_trans.msd_acc_cancel(0) xor pr.pta_trans.msd_acc_cancel_ack(0)(0);
  -- Stop_ack also needs to be delayed when pending is delayed
  pv.pta_trans.msd_acc_cancel_ack(0)(1) := pr.pta_trans.msd_acc_cancel_ack(0)(0);
  pv.pta_trans.msd_acc_cancel_ack(0)(2) := pr.pta_trans.msd_acc_cancel_ack(0)(1);
  for i in 0 to FIFO_COUNT-1 loop
    ms_fifo_pending(i) := atp_trans.msd_fifo(0)(i).pending(RAM_LATENCY) xor pr.pta_trans.msd_fifo_ack(0)(i);
    ms_fifo_empty(i) := not (pr.pta_trans.msd_fifo(0)(i).pending(0) xor atp_trans.msd_fifo_ack(0)(i));
    -- To set pending when data is stored in fifo, with this stop_ack also needs to be delayed
    pv.pta_trans.msd_fifo(0)(i).pending(1) := pr.pta_trans.msd_fifo(0)(i).pending(0);
    pv.pta_trans.msd_fifo(0)(i).pending(2) := pr.pta_trans.msd_fifo(0)(i).pending(1);
  end loop;
  ms_fifo := ar.atp_trans.msd_fifo(0);
  msd_acc(0) := ar.atp_trans.msd_acc(0);

  md_acc_pending := atp_trans.msd_acc(1).pending xor pr.pta_trans.msd_acc_ack(1);
  md_acc_done := atp_trans.msd_acc_done_ack(1) xor pr.pta_trans.msd_acc_done(1).done;
  md_acc_cancel := atp_trans.msd_acc_cancel(1) xor pr.pta_trans.msd_acc_cancel_ack(1)(0);
  -- Stop_ack also needs to be delayed when pending is delayed
  pv.pta_trans.msd_acc_cancel_ack(1)(1) := pr.pta_trans.msd_acc_cancel_ack(1)(0);
  pv.pta_trans.msd_acc_cancel_ack(1)(2) := pr.pta_trans.msd_acc_cancel_ack(1)(1);
  for i in 0 to FIFO_COUNT-1 loop
    md_fifo_pending(i) := atp_trans.msd_fifo(1)(i).pending(RAM_LATENCY) xor pr.pta_trans.msd_fifo_ack(1)(i);
    md_fifo_empty(i) := not (pr.pta_trans.msd_fifo(1)(i).pending(0) xor atp_trans.msd_fifo_ack(1)(i));
    -- To set pending when data is stored in fifo, with this stop_ack also needs to be delayed
    pv.pta_trans.msd_fifo(1)(i).pending(1) := pr.pta_trans.msd_fifo(1)(i).pending(0);
    pv.pta_trans.msd_fifo(1)(i).pending(2) := pr.pta_trans.msd_fifo(1)(i).pending(1);
  end loop;
  md_fifo := ar.atp_trans.msd_fifo(1);
  msd_acc(1) := ar.atp_trans.msd_acc(1);

  -- PCI master function
  m_func := pr.m.acc(pr.m.acc_sel).func;


  -- --------------------------------------------------------------------------------
  -- PCI master core
  -- --------------------------------------------------------------------------------

  if master /= 0 or dma /= 0 then -- PCI master enabled
    -- First
    if pr.m.state = pm_idle or pr.m.state = pm_turn_ar or pr.m.state = pm_dr_bus then
      pv.m.first(0) := '1'; 
    else
      pv.m.first(0) := '0';
    end if;
    pv.m.first(1) := pr.m.first(0);

    -- Master Data Parity Error
    if pr.m.state = pm_m_data then
      if pr.m.fstate = pmf_read then
        pv.m.perren(0) := '1';
      elsif pr.m.fstate = pmf_fifo then
        pv.m.detectperr(0) := '1';
      end if;
    else
      pv.m.perren(0) := '0';
      pv.m.detectperr(0) := '0';
    end if;
    pv.m.perren(1) := pr.m.perren(0);
    pv.m.detectperr(1) := pr.m.detectperr(0); 

    if pr.conf(m_func).comm.perren = '1' and                          -- Parity error response bit[6] = 1 
    ((pr.m.perren /= "00" and pr.po.perr = '0')               -- Parity error is signaled by master on read
        or (pr.m.detectperr(1) = '1' and pci.perr = '0')) then-- Parity error is signaled by target on write 
      pv.conf(m_func).stat.mdpe := '1';
      pv.m.acc(pr.m.acc_sel).status(0) := '1';
    end if;
    
    -- PCI master latency timer
    if (pr.m.framedel and not pr.po.frame) = '1' then 
      pv.m.ltimer := pr.conf(m_func).ltimer;
    elsif pr.m.ltimer /= x"00" and pr.po.frame = '0' then 
      pv.m.ltimer := pr.m.ltimer - 1; 
    end if;

    -- Devsel time out counter (and master abort signaling)
    if pci.devsel = '0' then pv.m.devsel_asserted := '1'; end if;
    if (pr.m.framedel and not pr.po.frame) = '1' then 
      pv.m.devsel_tout := "100"; 
      pv.m.devsel_asserted := '0';
    elsif pr.m.devsel_asserted = '1' then
      pv.m.devsel_tout := "100"; 
    elsif pr.m.devsel_tout /= "000" then 
      pv.m.devsel_tout := pr.m.devsel_tout - 1; 
    end if;
    if (pr.m.devsel_tout = "000" and pr.m.devsel_asserted = '0') and pi.devsel = '1' and pr.m.state = pm_m_data then m_mabort := '1'; pv.conf(m_func).stat.rma := '1'; else m_mabort := '0'; end if; -- Master abort -- delayed mabort one cycle (to reduce pci.devsel timing path)
    if pi.devsel = '1' and pi.stop = '0' and pr.m.state = pm_s_tar then m_tabort := '1'; pv.conf(m_func).stat.rta := '1'; else m_tabort := '0'; end if; -- Target abort
    if (pr.m.state = pm_m_data and m_mabort = '1') or (pr.m.state = pm_s_tar and m_tabort = '1') then
      pv.m.abort(0) := '1'; 
      pv.m.abort(1) := m_tabort;
    elsif pr.m.state = pm_s_tar or pr.m.state = pm_idle or pr.m.state = pm_dr_bus then
      pv.m.abort := (others => '0');
    end if;
    if pr.m.abort(0) = '1' then pv.m.abort(0) := '0'; end if;

    -- Access acknowledge and arbitration [AHB/DMA]
    for i in 0 to 1*dma loop
      if ((ms_acc_pending = '1' and i = acc_sel_ahb) or (md_acc_pending = '1' and i = acc_sel_dma)) and pr.m.acc(i).pending = '0' then
        pv.pta_trans.msd_acc_ack(i) := atp_trans.msd_acc(i).pending;
        
        pv.m.acc(i).pending := '1'; 
        pv.m.acc(i).active := (others => '0');
        pv.m.acc(i).done := (others => '0');
        pv.m.acc(i).status := (others => '0');
        pv.m.acc(i).first := '1';

        pv.m.acc(i).addr := msd_acc(i).addr(31 downto 2) & "00";
        pv.m.acc(i).func := conv_integer(msd_acc(i).func);
        pv.m.acc(i).cmd := msd_acc(i).acctype; 
        pv.m.acc(i).mode := msd_acc(i).accmode;
        pv.m.acc(i).fifo_index := msd_acc(i).index;
        
        if msd_acc(i).acctype(0) = '1' then
          pv.m.acc(i).length := (others => '0');
        else
          pv.m.acc(i).length := msd_acc(i).length;
        end if;
        
        if msd_acc(i).acctype = CONF_READ or msd_acc(i).acctype = CONF_WRITE then -- Config
          if i = acc_sel_ahb then pv.m.acc(i).endianess := '1';                   -- Endianess is not set for AHB slave
          else pv.m.acc(i).endianess := msd_acc(i).endianess; end if;             -- Endianess is set for DMA 
          pv.m.acc(i).addr := msd_acc(i).addr;                                    -- PCI CONF address set in AHB slave
          pv.m.acc(i).cbe := set_cbe_from_size_addr(msd_acc(i).size, msd_acc(i).offset(1 downto 0), '1'); -- Set CBE depending on AHB size and address
        elsif msd_acc(i).acctype = IO_READ or msd_acc(i).acctype = IO_WRITE then  -- IO
          if i = acc_sel_ahb then pv.m.acc(i).endianess := pr.pta_trans.ca_twist; -- Endianess is not set for AHB slave
          else pv.m.acc(i).endianess := msd_acc(i).endianess; end if;             -- Endianess is set for DMA 
          pv.m.acc(i).addr(1 downto 0) := set_pci_io_byte_addr(msd_acc(i).offset(1 downto 0), msd_acc(i).size, pr.pta_trans.ca_twist);  -- PCI IO used byte address
          pv.m.acc(i).cbe := set_cbe_from_size_addr(msd_acc(i).size, msd_acc(i).offset(1 downto 0), pr.pta_trans.ca_twist); -- Set CBE depending on AHB size and address
        else                                                                                  -- Mem  
          if i = acc_sel_ahb then pv.m.acc(i).endianess := pr.pta_trans.ca_twist; -- Endianess is not set for AHB slave
          else pv.m.acc(i).endianess := msd_acc(i).endianess; end if;             -- Endianess is set for DMA 
          pv.m.acc(i).cbe := set_cbe_from_size_addr(msd_acc(i).size, msd_acc(i).offset(1 downto 0), pr.pta_trans.ca_twist); -- Set CBE depending on AHB size and address
        end if;
      end if;
      
      if pr.m.acc(i).pending = '1' and pr.m.acc(i).active(1) = '0' and pr.m.acc(i).done(0) = '1' and pr.m.acc(i).cmd(0) = '1' then -- Status pending
        if pr.m.acc(i).done(2 downto 1) = "10" then
          if (i = acc_sel_ahb and ms_fifo_pending(pr.m.acc(i).fifo_index) = '1') or (i = acc_sel_dma and md_fifo_pending(pr.m.acc(i).fifo_index) = '1') then
            if pr.m.acc(i).fifo_index /= FIFO_COUNT-1 then pv.m.acc(i).fifo_index := pr.m.acc(i).fifo_index + 1;
            else pv.m.acc(i).fifo_index := 0; end if;
            pv.pta_trans.msd_fifo_ack(i)(pr.m.acc(i).fifo_index) := not pv.pta_trans.msd_fifo_ack(i)(pr.m.acc(i).fifo_index);
            if (i = acc_sel_ahb and ms_fifo(pr.m.acc(i).fifo_index).lastf = '1') or (i = acc_sel_dma and md_fifo(pr.m.acc(i).fifo_index).lastf = '1') then
              pv.m.acc(i).done(1) := '1';
            end if;
          end if;
        elsif ((ms_acc_done = '0' and i = acc_sel_ahb) or (md_acc_done = '0' and i = acc_sel_dma)) then
          pv.pta_trans.msd_acc_done(i).done := not pr.pta_trans.msd_acc_done(i).done;
          pv.pta_trans.msd_acc_done(i).status(2 downto 0) := pr.m.acc(i).status;
          if pr.m.acc(i).cmd = CONF_WRITE then pv.pta_trans.msd_acc_done(i).status(3) := '1'; -- Status(3) indicates CONF_WRITE
          else pv.pta_trans.msd_acc_done(i).status(3) := '0'; end if;
          pv.pta_trans.msd_acc_done(i).count := pr.m.acc(i).length;
          pv.m.acc(i).pending := '0';
        end if;
      end if;
      
      -- Access canceled
      if pr.m.acc(i).pending = '1' and pr.m.acc(i).active = "10" and pr.m.acc(i).cmd(0) = '0' then
        if ((ms_acc_cancel = '1' and i = acc_sel_ahb) or (md_acc_cancel = '1' and i = acc_sel_dma)) then
          pv.m.acc(i).done(0) := '1';
          pv.m.acc(i).active(1) := '0';
        end if;
      end if;
      
      if pr.m.acc(i).pending = '1' and pr.m.acc(i).active(1) = '0' and pr.m.acc(i).done(0) = '1' and pr.m.acc(i).cmd(0) = '0' then -- Status pending
        if pr.m.acc(i).done(1 downto 0) = "01" then
          if ((ms_acc_cancel = '1' and i = acc_sel_ahb) or (md_acc_cancel = '1' and i = acc_sel_dma)) then
            pv.m.acc(pr.m.acc_sel).done(1) := '1';
            for j in 0 to FIFO_COUNT-1 loop
              if (i = acc_sel_ahb and  ms_fifo_empty(j) = '0') or (i = acc_sel_dma and  md_fifo_empty(j) = '0') then
                pv.pta_trans.msd_fifo(i)(j).pending(0) := not pr.pta_trans.msd_fifo(i)(j).pending(0);
              else
                pv.pta_trans.msd_fifo(i)(j).pending(0) := pr.pta_trans.msd_fifo(i)(j).pending(0);
              end if;
            end loop;
          end if;
        else
          pv.pta_trans.msd_acc_cancel_ack(i)(0) := atp_trans.msd_acc_cancel(i);
          pv.m.acc(i).pending := '0';
        end if;
      end if;
    end loop;

    -- control access switching
    if atp_trans.mstswdis = '0' then
      if (pr.m.acc_sel = acc_sel_dma and pr.m.acc(0).pending = '1' and pr.m.acc(0).done(0) = '0' 
          and ((pr.m.acc(0).cmd(0) and ms_fifo_pending(pr.m.acc(0).fifo_index)) 
               or (not pr.m.acc(0).cmd(0) and ms_fifo_empty(pr.m.acc(0).fifo_index))) = '1')
         or
         (pr.m.acc_sel = acc_sel_ahb and pr.m.acc(1).pending = '1' and pr.m.acc(1).done(0) = '0'
          and ((pr.m.acc(1).cmd(0) and md_fifo_pending(pr.m.acc(1).fifo_index)) 
               or (not pr.m.acc(1).cmd(0) and md_fifo_empty(pr.m.acc(1).fifo_index))) = '1') 
        then
          if pr.m.acc_cnt = MST_ACC_CNT then
            pv.m.acc_switch := '1';
          end if;
      end if;
    else
      pv.m.acc_switch := '0';
    end if;

    acc_switch := pv.m.acc_switch;

    if ((pr.m.acc(0).pending = '1' and pr.m.acc(0).done(0) = '0' 
         and ms_acc_cancel = '0' and pr.m.acc(1).active(0) = '0'
         and ((pr.m.acc(0).cmd(0) and ms_fifo_pending(pr.m.acc(0).fifo_index)) 
              or (not pr.m.acc(0).cmd(0) and ms_fifo_empty(pr.m.acc(0).fifo_index))) = '1')
        and not (pr.m.acc_switch = '1' and pr.m.acc_sel = acc_sel_ahb))
       or pr.m.acc(0).active(0) = '1' then 
      acc := pr.m.acc(0);
      accdone := ms_acc_done;
      acc_cancel := ms_acc_cancel;
      pv.m.acc_sel := acc_sel_ahb;
      fifo_pending := ms_fifo_pending;
      fifo_empty := ms_fifo_empty;
      fifo := ms_fifo;
      if pr.m.acc_sel = acc_sel_dma then 
        pv.m.acc_cnt := 0;
        pv.m.acc_switch := '0';
      end if;
    elsif (pr.m.acc(1).pending = '1' and pr.m.acc(1).done(0) = '0' 
        and md_acc_cancel = '0' and pr.m.acc(0).active(0) = '0'
        and ((pr.m.acc(1).cmd(0) and md_fifo_pending(pr.m.acc(1).fifo_index)) 
             or (not pr.m.acc(1).cmd(0) and md_fifo_empty(pr.m.acc(1).fifo_index))) = '1')
       or pr.m.acc(1).active(0) = '1' then 
      acc := pr.m.acc(1);
      accdone := md_acc_done;
      acc_cancel := md_acc_cancel;
      pv.m.acc_sel := acc_sel_dma;
      fifo_pending := md_fifo_pending;
      fifo_empty := md_fifo_empty;
      fifo := md_fifo;
      if pr.m.acc_sel = acc_sel_ahb then 
        pv.m.acc_cnt := 0;
        pv.m.acc_switch := '0';
      end if;
    else 
      acc := pci_master_acc_none; 
      accdone := '0';
      acc_cancel := '0';
      pv.m.acc_sel := acc_sel_ahb;
      fifo_pending := (others => '0');
      fifo_empty := (others => '0');
      fifo :=  ms_fifo;
      pv.m.acc_cnt := 0;
      pv.m.acc_switch := '0';
    end if;
    
    if acc.fifo_index /= FIFO_COUNT-1 then fifo_nindex := (acc.fifo_index + 1);
    else fifo_nindex := 0; end if;
    
    -- FIFO state machine
    case pr.m.fstate is
      when pmf_idle =>
        pv.m.waitonstop := '0';
        pv.m.done := '0';
        pv.m.done_fifo := '0';
        pv.m.done_trans := '0';
        pv.m.term := (others => '0');
        pv.m.preload := '0';
        pv.m.preload_count := (others => '0');
        pv.m.afull := '0';
        pv.m.afullcnt := (others => '0');
        if acc.pending = '1' then
          pv.m.addr := acc.addr;
          pv.m.twist := acc.endianess;
          pv.m.cbe_cmd := acc.cmd;
          pv.m.cbe_data := acc.cbe;
          pv.m.burst := acc.mode(0);
          pv.m.acc_cnt := 0;
          if acc.cmd(0) = '1' then -- Write access
            pv.m.fstate := pmf_fifo;
            pv.m.fifo_addr := conv_std_logic_vector(acc.fifo_index, log2(FIFO_COUNT)) & fifo(acc.fifo_index).start; -- Set fifo start address
          else                     -- Read access
            pv.m.fstate := pmf_read;
          end if;
          pv.m.acc(pv.m.acc_sel).active := "11";
        end if;
      when pmf_fifo =>
        pv.m.acc(pr.m.acc_sel).fifo_ren := fifo_pending(acc.fifo_index);
    
        if pr.m.term = "00" and pr.m.last(0) = '0' and pr.m.done = '0' and (pr.m.cfifo(0).valid = '1' or pr.m.hold(0) = '1') 
           and m_mabort = '0' and pr.m.abort(0) = '0' then -- request bus if not: latency timer count out; last data phase; transfer done
          m_request := '1';
        end if;
        
        if (fifo_pending(acc.fifo_index) = '1') and pr.m.done = '0' then -- preload data 
          pv.m.preload := '1';
          pv.m.hold_fifo := '0';
        end if;

        if ((pi.trdy or pi.irdy) = '0' and (pr.m.state = pm_m_data or pr.m.state = pm_turn_ar or pr.m.state = pm_s_tar)) or pr.m.preload = '1' or (pr.m.abort(0)) = '1' then
          
          if ((pi.trdy or pi.irdy) = '0' and (pr.m.state = pm_m_data or pr.m.state = pm_turn_ar or pr.m.state = pm_s_tar)) or (pr.m.abort(0)) = '1' then 
            pv.m.cfifo(0) := pr.m.cfifo(1); pv.m.cfifo(1) := pr.m.cfifo(2); -- Preload master core fifo
          elsif pr.m.preload = '1' then
            if pr.m.cfifo(0).valid = '0' then
              pv.m.cfifo(0) := pr.m.cfifo(1); pv.m.cfifo(1) := pr.m.cfifo(2); -- Preload master core fifo
            elsif pr.m.cfifo(0).valid = '1' and pr.m.cfifo(1).valid = '0' then
              pv.m.cfifo(1) := pr.m.cfifo(2); -- Preload master core fifo
            end if;
          end if;

          if pr.m.acc(0).active(0) = '1' then
            pv.m.cfifo(2).data := byte_twist(ms_fifoo_atp.data, acc.endianess); -- shifting in data from backend fifo
          elsif pr.m.acc(1).active(0) = '1' then
            pv.m.cfifo(2).data := byte_twist(md_fifoo_dtp.data, acc.endianess); -- shifting in data from DMA fifo
          end if;

          if pr.m.done_fifo = '0' and fifo_pending(acc.fifo_index) = '1' then
            if pr.m.fifo_addr(FIFO_DEPTH-1 downto 0) = fifo(acc.fifo_index).stop then -- Mark last word

              if pr.m.acc_cnt /= MST_ACC_CNT then pv.m.acc_cnt := pr.m.acc_cnt + 1; end if; -- Switch DAM/AHB-slave after MST_ACC_CNT FIFOs
              pv.m.fifo_switch := '1';
              pv.m.acc(pr.m.acc_sel).fifo_index := fifo_nindex;
              pv.pta_trans.msd_fifo_ack(pr.m.acc_sel)(acc.fifo_index) := fifo(acc.fifo_index).pending(RAM_LATENCY); -- Ack the fifo (done using this data)
              
              pv.m.fifo_addr := conv_std_logic_vector(fifo_nindex, log2(FIFO_COUNT)) & zero32(FIFO_DEPTH-1 downto 0); -- New fifo address (should be ok with [index & zero] or & fifo(fifo_nindex).start) 
              
              if fifo_pending(fifo_nindex) = '0' or acc_switch = '1' then -- If no fifo pending => idle
                pv.m.cfifo(2).last := '1';
                pv.m.done_fifo := '1';
              else
                pv.m.cfifo(2).hold := '0'; 
                pv.m.cfifo(2).last := '0';
              end if;

              if fifo(acc.fifo_index).lastf = '1' then -- Last fifo, transfer is done
                pv.m.cfifo(2).last := '1';
                pv.m.done_fifo := '1';
                pv.m.done_trans := '1';
              end if;

            else
              pv.m.cfifo(2).hold := '0';
              pv.m.cfifo(2).last := '0';
            
              if pr.m.done_fifo = '0' and fifo_pending(acc.fifo_index) = '1' then
                pv.m.fifo_addr(FIFO_DEPTH-1 downto 0) := pr.m.fifo_addr(FIFO_DEPTH-1 downto 0) + 1; -- inc backend fifo address
              end if;
            end if;
          else
            pv.m.cfifo(2).hold := '0';
            pv.m.cfifo(2).last := '0';
          end if;
          
          pv.m.cfifo(2).stlast := '0';

          if fifo_pending(acc.fifo_index) = '1' and pr.m.done_fifo = '0' then  -- Adding valid data to CFIFO
            pv.m.cfifo(2).valid := '1';
          else
            pv.m.cfifo(2).valid := '0';
            pv.m.cfifo(2).last := '0';
            pv.m.cfifo(2).stlast := '0';
            pv.m.cfifo(2).hold := '0';
          end if;

        end if;
        
        if (pv.m.cfifo(0).valid = '1' and pv.m.cfifo(1).valid = '1' and pv.m.cfifo(2).valid = '1')
           or (pv.m.cfifo(0).valid = '1' and pr.m.done_fifo = '1' and not (pv.m.cfifo(1).valid = '0' and pv.m.cfifo(2).valid = '1')) then
          pv.m.preload := '0'; 
          if pr.m.cfifo(0).hold = '1' and pv.m.cfifo(1).valid = '1' then pv.m.cfifo(0).hold := '0'; end if;
          if pr.m.cfifo(1).hold = '1' and pv.m.cfifo(2).valid = '1' then pv.m.cfifo(1).hold := '0'; end if;
        end if;

        if pr.m.abort(0) = '1' then -- Empty core FIFO on master/target abort 
          for i in 0 to 2 loop
            pv.m.cfifo(i).valid := '0';
          end loop;
        end if;

        if ((pi.trdy or pi.irdy) = '0' and (pr.m.state = pm_m_data or pr.m.state = pm_turn_ar or pr.m.state = pm_s_tar)) or (pr.m.abort(0)) = '1' then
          pv.m.addr := pr.m.addr + 4;
          
          if acc.mode(1) = '1' and pr.m.abort(0) = '0' then -- Use acc.length
            pv.m.acc(pr.m.acc_sel).length := pr.m.acc(pr.m.acc_sel).length + 1;
          end if;
        
          if pr.m.last(1) = '1' or pr.m.abort(0) = '1' then pv.m.done := '1'; end if; -- Last data phase is done => transfer done
          

          -- Signal ERROR to AHB
          if pr.m.abort(0) = '1' then
            pv.m.acc(pr.m.acc_sel).done(2) := '1'; -- Error
            pv.m.acc(pr.m.acc_sel).status(2 downto 1) := (not pr.m.abort(1) or m_mabort) & (pr.m.abort(1) or m_tabort); -- Error type: Master abort, Target abort, (PAR error)
          end if;

        end if;
          

        if (pr.m.state = pm_s_tar or pr.m.state = pm_turn_ar) then 
          pv.m.term := (others => '0'); m_request := '0'; 
        end if;

        if pr.m.done = '1' then
          pv.m.fstate := pmf_idle;
          pv.m.acc(pr.m.acc_sel).active(0) := '0';
          pv.m.acc(pr.m.acc_sel).addr := pr.m.addr;
          if pr.m.done_trans = '1' or acc.done(2) = '1' then
            pv.m.acc(pr.m.acc_sel).active(1) := '0';
            pv.m.acc(pr.m.acc_sel).done(0) := '1';
            if pr.m.done_trans = '1' then pv.m.acc(pr.m.acc_sel).done(1) := '1'; end if;
            if accdone = '0' and pr.m.done_trans = '1' then
              pv.pta_trans.msd_acc_done(pr.m.acc_sel).done := not pr.pta_trans.msd_acc_done(pr.m.acc_sel).done;
              pv.pta_trans.msd_acc_done(pr.m.acc_sel).status(2 downto 0) := pv.m.acc(pr.m.acc_sel).status; -- use pv.. (par error detection)
              if pr.m.acc(pr.m.acc_sel).cmd = CONF_WRITE then pv.pta_trans.msd_acc_done(pr.m.acc_sel).status(3) := '1'; -- Status(3) indicates CONF_WRITE
              else pv.pta_trans.msd_acc_done(pr.m.acc_sel).status(3) := '0'; end if;
              pv.pta_trans.msd_acc_done(pr.m.acc_sel).count := pr.m.acc(pr.m.acc_sel).length;
              pv.m.acc(pr.m.acc_sel).pending := '0';
            end if;
          end if;
        end if;
          
        if pi.stop = '0' and pr.m.state /= pm_idle then m_request := '0'; end if;  -- Second deasserted req cycle


      when pmf_read => 
        if pr.m.term(0) = '0' and m_mabort = '0' and pr.m.abort(0) = '0' and (pi.stop = '1' or pr.m.first(0) = '1') and pr.m.waitonstop = '0' then -- request bus if not: latency timer count out; no empty fifo to fill
          m_request := '1'; -- request should be deasserted earlier
        end if;

        if pr.m.burst = '0' then  -- Single access, only one data phase
          if pr.po.frame = '0' then
            pv.m.term(0) := '1';
          elsif (pi.trdy and not pi.stop) = '1' then -- retry
            pv.m.term := (others => '0');
          end if;
        end if;
        
        if (pi.irdy or pi.trdy) = '0' and (pr.m.state = pm_m_data or pr.m.state = pm_s_tar or pr.m.state = pm_turn_ar)then
          pv.m.addr := pr.m.addr + 4;
          if acc.mode(1) = '1' then -- Use acc.length
            pv.m.acc(pr.m.acc_sel).length := pr.m.acc(pr.m.acc_sel).length - 1;
          end if;

          if pr.m.addr(AHB_FIFO_BITS) = ones32(FIFO_DEPTH-1 downto 0) or pr.m.burst = '0' or (acc.mode(1) = '1' and acc.length = x"0000") then
            
            if pr.m.acc_cnt /= MST_ACC_CNT then pv.m.acc_cnt := pr.m.acc_cnt + 1; end if; -- Switch DMA/AHB-slave after MST_ACC_CNT FIFOs
            pv.m.fifo_switch := '1';
            pv.m.acc(pr.m.acc_sel).fifo_index := fifo_nindex;
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).pending(0) := not pr.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).pending(0);
            pv.m.acc(pr.m.acc_sel).first := '0';
            
            if acc.first = '1' then 
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).firstf := '1';
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).start := acc.addr(AHB_FIFO_BITS);
            else 
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).firstf := '0';
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).start := (others => '0'); 
            end if;

            if (acc.mode(1) = '1' and acc.length = x"0000") or pr.m.burst = '0' then
              pv.m.acc(pr.m.acc_sel).done(0) := '1';
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).lastf := '1';
            else
              pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).lastf := '0';
            end if;
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).status := (others => '0');
          end if;

          pv.m.acc(pr.m.acc_sel).fifo_wen := '1';
          pv.m.fifo_addr := conv_std_logic_vector(acc.fifo_index, log2(FIFO_COUNT)) & pr.m.addr(AHB_FIFO_BITS);
          pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).stop := pv.m.fifo_addr(FIFO_DEPTH-1 downto 0);
        
          if ((fifo_empty(fifo_nindex) = '0' or acc_switch = '1') and pr.m.fifo_addr(FIFO_DEPTH-1 downto 0) = conv_std_logic_vector((conv_integer(ones32(FIFO_DEPTH-1 downto 0)) - 3), FIFO_DEPTH)) -- terminate access when 3 words left to store in FIFO or 3 word left i transfer
             or (acc.mode(1) = '1' and acc.length = x"0002") then
            pv.m.term(0) := '1';
            pv.m.afull := '1';      -- almost full 
            pv.m.afullcnt := "00";  -- reset full counter
          end if;

          if pr.m.afull = '1' then  -- when transfer is terminated, count data phases (1 - 3)
            if pr.m.afullcnt = "01" then
              pv.m.afullcnt := (others => '0');
              pv.m.afull := '0';
            else
              pv.m.afullcnt := pr.m.afullcnt + 1;
            end if;
          end if;

        end if;

        if (pr.m.afull = '1' and pr.m.afullcnt = "01" and pr.m.first(0) = '1' and pr.m.state = pm_addr)
           or (pr.m.afull = '1' and pr.m.afullcnt = "00" and pr.m.state = pm_m_data)  -- terminate first or second data phase depending on space left in fifo
           or (acc.mode(1) = '1' and ((acc.length = x"0000" and pr.m.state = pm_addr) or (acc.length = x"0001" and pr.m.state = pm_m_data)))then pv.m.term(0) := '1'; end if; -- DMA 1 or 2 word to complete transfer

        if pr.m.term(0) = '1' and fifo_empty(acc.fifo_index) = '1' and (pr.m.state = pm_idle or pr.m.state = pm_dr_bus) then
          pv.m.term := (others => '0'); -- Start new access when a fifo becomes empty
        end if;

        if pr.m.state = pm_s_tar and fifo_empty(acc.fifo_index) = '1' and pv.m.fifo_switch = '0' then pv.m.term(0) := '0'; end if; -- If disconnected, rerequest the bus if fifo is available (but not if fifo switch)

        if (pr.m.state = pm_m_data or pr.m.state = pm_turn_ar or pr.m.state = pm_s_tar) and pi.irdy = '0' and (pi.trdy = '0' or (pi.stop = '0' and pi.devsel = '1')) then pv.m.first_word := '0'; end if; 
        
        if (acc.done(0) = '1' and (pv.m.first_word = '0' or acc.done(2) = '1')) 
           or ((pr.m.acc_switch = '1' or fifo_empty(acc.fifo_index) = '0') and pr.m.fifo_switch = '1') then -- Transfer read is done (or no empty fifo), cancelled or access arbitration
          m_request := '0';
          pv.m.term(0) := '1';
          if ((pi.frame and pi.irdy) = '1' and (pr.m.state = pm_idle or pr.m.state = pm_dr_bus)) then
            pv.m.fstate := pmf_idle;
            pv.m.term := (others => '0');
            pv.m.acc(pr.m.acc_sel).active(0) := '0';
            pv.m.acc(pr.m.acc_sel).addr := pr.m.addr;
            if acc.done(0) = '1' then
              pv.m.acc(pr.m.acc_sel).active(1) := '0';
              if acc.mode(2) = '0' or acc.mode(0) = '0' then
                pv.m.acc(pr.m.acc_sel).pending := '0';
                pv.m.acc(pr.m.acc_sel).done(1) := '1';
              else
                pv.m.acc(pr.m.acc_sel).done(1) := '0';
              end if;
            end if;
          end if;
        end if;
        
        -- Access canceled
        if acc_cancel = '1' then
          pv.m.acc(pr.m.acc_sel).done(0) := '1';
        end if;

        -- Access aborted by PCI error
        if pr.m.abort(0) = '1' and pr.m.acc(pr.m.acc_sel).done(2) = '0' then
          pv.m.acc(pr.m.acc_sel).done(0) := '1';
          pv.m.acc(pr.m.acc_sel).done(2) := '1'; -- error
          
          pv.m.acc(pr.m.acc_sel).fifo_index := fifo_nindex;
          pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).pending(0) := not pr.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).pending(0);
          pv.m.acc(pr.m.acc_sel).first := '0';
          
          if acc.first = '1' then 
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).firstf := '1';
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).start := acc.addr(AHB_FIFO_BITS);
          else 
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).firstf := '0';
            pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).start := (others => '0'); 
          end if;

          pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).lastf := '1';
          pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).status := '0' & (not pr.m.abort(1) or m_mabort) & (pr.m.abort(1) or m_tabort) & '0'; -- Error type: Master abort, Target abort, (PAR error)
          pv.pta_trans.msd_fifo(pr.m.acc_sel)(acc.fifo_index).stop := pr.m.addr(AHB_FIFO_BITS);
        end if;

        -- Set PAR error status
        if pr.m.fifo_switch = '1' then
          pv.pta_trans.msd_fifo(pr.m.acc_sel)(conv_integer(pr.m.fifo_addr(pr.m.fifo_addr'left downto FIFO_DEPTH))).status(0) := pv.m.acc(pr.m.acc_sel).status(0); 
          pv.m.acc(pr.m.acc_sel).status(0) := '0';
        end if;
      when others =>
    end case;

    -- New (Master state machine is moed to PHY)
    if pr.m.state = pm_addr then pv.m.first_word := '1'; end if;
  end if; -- PCI master enabled


  -- --------------------------------------------------------------------------------
  -- PCI target defaults
  -- --------------------------------------------------------------------------------
  
  -- Defaults
  t_hit := '0'; t_chit := '0';
  pv.t.cur_acc(0).newacc := '0';
  pv.t.hold_reset := '1'; 
  t_cad := (others => '0');
  pv.t.first_word := '0';
  t_ready := '0'; t_retry := '0';
  t_abort := pr.t.stop;
  t_acc_read := '1';
  t_acc_burst := '1';
  t_acc_type := "00";
  t_acc_impcfgreg := '1';
  
  -- FIFO (Block RAM enable(read)/write)
  pv.t.atp.ctrl.en := '0';  -- read enable
  pv.t.pta.ctrl.en := '0';  -- write enable
  pv.t.pta.ctrl.data := byte_twist(pi.ad, pr.pta_trans.ca_twist);
  
  tm_acc_pending := pr.pta_trans.tm_acc.pending xor atp_trans.tm_acc_ack;
  tm_acc_cancel := pr.pta_trans.tm_acc_cancel xor atp_trans.tm_acc_cancel_ack(RAM_LATENCY);
  tm_acc_done := pr.pta_trans.tm_acc_done_ack xor atp_trans.tm_acc_done.done;
  for i in 0 to FIFO_COUNT-1 loop
    tm_fifo_pending(i) := atp_trans.tm_fifo(i).pending(RAM_LATENCY) xor pr.pta_trans.tm_fifo_ack(i);
    tm_fifo_empty(i) := not (pr.pta_trans.tm_fifo(i).pending(0) xor atp_trans.tm_fifo_ack(i));
    pv.pta_trans.tm_fifo(i).pending(1) := pr.pta_trans.tm_fifo(i).pending(0);
    pv.pta_trans.tm_fifo(i).pending(2) := pr.pta_trans.tm_fifo(i).pending(1);
  end loop;
  tm_fifo := ar.atp_trans.tm_fifo;

  accbufindex := 0;

  -- Not used
  if tm_acc_done = '1' then
    pv.pta_trans.tm_acc_done_ack := atp_trans.tm_acc_done.done;
  end if;


  -- --------------------------------------------------------------------------------
  -- PCI target core
  -- --------------------------------------------------------------------------------
  
  if target /= 0 then -- PCI target enabled
    -- Target latency counter
    if pv.t.state = pt_s_data and pr.po.trdy = '1' and pr.t.lcount /= "111" then
      pv.t.lcount := pr.t.lcount + 1;
    elsif pr.po.trdy = '0' then
      pv.t.lcount := (others => '0');
    end if;
    
    -- select next fifo
    if pr.t.cur_acc(0).read = '1' then
      if pr.t.atp.index /= FIFO_COUNT-1 then t_index := (pr.t.atp.index + 1);
      else t_index := 0; end if;
    else
      if pr.t.pta.index /= FIFO_COUNT-1 then t_index := (pr.t.pta.index + 1);
      else t_index := 0; end if;
    end if;

    -- PCI BAR address matching
    t_bar := (others => '0'); t_func := 0;
    for j in 0 to multifunc loop
      for i in 0 to 5 loop
        if (pi.ad(31 downto barminsize) and pr.conf(j).bar_mask(i)(31 downto barminsize)) = 
           (pr.conf(j).bar(i)(31 downto barminsize) and pr.conf(j).bar_mask(i)(31 downto barminsize)) and 
           pr.conf(j).bar_mask(i)(31) = '1' then
             if pr.conf(j).bar_mask(i)(0) = '0' and (pi.cbe = MEM_READ or pi.cbe = MEM_R_MULT or pi.cbe = MEM_R_LINE 
                                                     or pi.cbe = MEM_WRITE or pi.cbe = MEM_W_INV) then
          t_hit := pr.conf(j).comm.memen; -- Only hit if memory access is enabled 
          t_bar(i) := '1';
          t_func := j;
            elsif pr.conf(j).bar_mask(i)(0) = '1' and (pi.cbe = IO_READ or pi.cbe = IO_WRITE) then
              t_hit := pr.conf(j).comm.ioen; -- Only hit if io access is enabled 
              t_bar(i) := '1';
              t_func := j;
            end if;
        end if;
      end loop;
    end loop;

    -- Configuration hit when IDSEL or self config (AD[31:11]=0 => no IDSEL) and in host slot 
    if ((pi.idsel = '1' or (pi.ad(31 downto 11) = zero32(31 downto 11) and pi.host = '0'))  -- IDSEL asserted
        and (pi.cbe = CONF_READ or pi.cbe = CONF_WRITE)) and pi.ad(1 downto 0) = "00"       -- Command = config read or write, Type = 0
        and pi.ad(10 downto 8) <= conv_std_logic_vector(multifunc, 3) then                  -- Respond to implemented function
      t_chit := '1';
    end if;

    -- Read prefetch discard timer
    if atp_trans.pa_discardtout_rst = '1' then
      pv.pta_trans.pa_discardtout := '0';
    end if;
    if pr.t.cur_acc(0).pending = '1' and pr.t.discardtimeren = '1' then
      if pr.t.discardtimer = x"0000" then
        if pr.t.state = pt_idle then  
          pv.pta_trans.pa_discardtout := '1';
          pv.t.cur_acc(0).pending := '0';
          pv.t.cur_acc(0).newacc := '1';
          pv.t.cur_acc(0).oldburst := pr.t.cur_acc(0).burst;
        end if;
      else
        pv.t.discardtimer := pr.t.discardtimer - 1;
      end if;
    end if;

    -- Access buffer
    if tm_acc_pending = '0' and pr.t.accbuf(0).pending = '1' then
      pv.pta_trans.tm_acc := pr.t.accbuf(0);
      pv.pta_trans.tm_acc.pending := not pr.pta_trans.tm_acc.pending;
      pv.t.accbuf(0) := pr.t.accbuf(1);
      pv.t.accbuf(1) := pr.t.accbuf(2);
      pv.t.accbuf(2) := pr.t.accbuf(3);
      pv.t.accbuf(3).pending := '0';
    end if;

    pv.pciinten := (others => oeoff);
    for i in 0 to 3 loop
      if i <= multifunc then
        pv.conf(i).stat.intsta := conv_std_logic(pciinten(i) /= oeoff);
        if pr.conf(i).comm.intdis = '0' then
          pv.pciinten(i) := pciinten(i); 
        end if;
      else
        pv.conf(0).stat.intsta := conv_std_logic(pciinten(i) /= oeoff);
        if pr.conf(0).comm.intdis = '0' then
          pv.pciinten(i) := pciinten(i); 
        end if;
      end if;
    end loop;

    if multiint = 0 then
      if oeoff = '1' then
        pciinten_pad(0) <= andv(pr.pciinten);
      else
        pciinten_pad(0) <= orv(pr.pciinten);
      end if;
      pciinten_pad(3 downto 1) <= (others => oeoff);
    else
        pciinten_pad <= pr.pciinten;
    end if;
    
  
    -- PCI Configuration Space Header
    conf_func := 0; 
    if conv_integer(pr.t.cur_acc(0).addr(10 downto 8)) <= multifunc then
      conf_func := conv_integer(pr.t.cur_acc(0).addr(10 downto 8)); 
    end if;
    -- read
    if pr.t.cur_acc(0).impcfgreg = '1' then
      if pr.t.cur_acc(0).acc_type(0) = '0' then
        case pr.t.conf_addr is
          when "0000" =>  -- Device and Vendor ID
            t_cad := conv_std_logic_vector(deviceid_vector(conf_func),16) & conv_std_logic_vector(vendorid,16);
          when "0001" =>  -- Status and Command
            t_cad := pr.conf(conf_func).stat.dpe & pr.conf(conf_func).stat.sse & pr.conf(conf_func).stat.rma & pr.conf(conf_func).stat.rta & 
                   pr.conf(conf_func).stat.sta & "01" & pr.conf(conf_func).stat.mdpe & "00"& pr.pci66(1) & 
                   "1"& pr.conf(conf_func).stat.intsta &"000" &
                   "00000" & pr.conf(conf_func).comm.intdis & "0" & pr.conf(conf_func).comm.serren & "0" & pr.conf(conf_func).comm.perren & "0" &
                   pr.conf(conf_func).comm.mwien & "0" & pr.conf(conf_func).comm.msten & pr.conf(conf_func).comm.memen & pr.conf(conf_func).comm.ioen;
          when "0010" =>  -- Class Code and Revision ID
            t_cad := conv_std_logic_vector(classcode_vector(conf_func),24) & conv_std_logic_vector(revisionid_vector(conf_func),8);
          when "0011" =>  -- BIST, Header Type, Latency Timer and Cache Line Size
            t_cad := "00000000" & conv_std_logic(multifunc /= 0) & "0000000" & pr.conf(conf_func).ltimer & "00000000";
          when "0100" =>  -- BAR0
            t_cad := pr.conf(conf_func).bar(0);
            --t_cad(3) := bar_prefetch(0);
            t_cad(3) := pr.conf(conf_func).bar_mask(0)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(0)(0);
          when "0101" =>  -- BAR1
            t_cad := pr.conf(conf_func).bar(1);
            --t_cad(3) := bar_prefetch(1);
            t_cad(3) := pr.conf(conf_func).bar_mask(1)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(1)(0);
          when "0110" =>  -- BAR2
            t_cad := pr.conf(conf_func).bar(2);
            --t_cad(3) := bar_prefetch(2);
            t_cad(3) := pr.conf(conf_func).bar_mask(2)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(2)(0);
          when "0111" =>  -- BAR3
            t_cad := pr.conf(conf_func).bar(3);
            --t_cad(3) := bar_prefetch(3);
            t_cad(3) := pr.conf(conf_func).bar_mask(3)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(3)(0);
          when "1000" =>  -- BAR4
            t_cad := pr.conf(conf_func).bar(4);
            --t_cad(3) := bar_prefetch(4);
            t_cad(3) := pr.conf(conf_func).bar_mask(4)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(4)(0);
          when "1001" =>  -- BAR5
            t_cad := pr.conf(conf_func).bar(5);
            --t_cad(3) := bar_prefetch(5);
            t_cad(3) := pr.conf(conf_func).bar_mask(5)(3);
            t_cad(0) := pr.conf(conf_func).bar_mask(5)(0);
          when "1010" =>  -- Cardbus CIS Pointer
            t_cad := (others => '0');
          when "1011" =>  -- Subsystem ID and Subsystem Vendor ID
            t_cad := (others => '0');
          when "1100" =>  -- Expansion ROM Base Address
            t_cad := (others => '0');
          when "1101" =>  -- Reserved and Capabillities Pointer
            t_cad := (others => '0');
            t_cad(7 downto 0) := conv_std_logic_vector(cap_pointer_vector(conf_func), 8);
          when "1110" =>  -- Reserved
            t_cad := (others => '0');
          when "1111" =>  -- Max_Lat, Min_Gnt, Interrupt Pin and Interrupt Line
            t_cad := x"00" & x"00" & (x"0"&"0"&conv_std_logic_vector(deviceirq_vector(conf_func), 3)) & pr.conf(conf_func).iline;
          when others =>
            t_cad := (others => '0');
        end case;
      else                                                -- Mapping register
        case pr.t.conf_addr is
          when "0000" => 
            t_cad := x"0040" & conv_std_logic_vector(ext_cap_pointer_vector(conf_func), 8) & x"09";
          when "0001" => 
            t_cad := pr.conf(conf_func).pta_map(0);
          when "0010" => 
            t_cad := pr.conf(conf_func).pta_map(1);
          when "0011" => 
            t_cad := pr.conf(conf_func).pta_map(2);
          when "0100" => 
            t_cad := pr.conf(conf_func).pta_map(3);
          when "0101" => 
            t_cad := pr.conf(conf_func).pta_map(4);
          when "0110" => 
            t_cad := pr.conf(conf_func).pta_map(5);
          when "0111" =>
            t_cad := pr.conf(conf_func).cfg_map;
          when "1000" =>
            t_cad := conv_std_logic_vector(iobase, 12) & x"0000"&"00"&pr.t.discardtimeren&pr.pta_trans.ca_twist; -- AHB IO base address (used to find P&P information) and byte twisting
          when "1001" => 
            t_cad := pr.conf(conf_func).bar_mask(0);
          when "1010" => 
            t_cad := pr.conf(conf_func).bar_mask(1);
          when "1011" => 
            t_cad := pr.conf(conf_func).bar_mask(2);
          when "1100" => 
            t_cad := pr.conf(conf_func).bar_mask(3);
          when "1101" => 
            t_cad := pr.conf(conf_func).bar_mask(4);
          when "1110" => 
            t_cad := pr.conf(conf_func).bar_mask(5);
          when "1111" =>
            t_cad := pr.t.saverfifo & "000" & x"000" & pr.t.blenmask; -- Burst lenght boundary mask
          when others =>
            t_cad := (others => '0');
        end case;
      end if;
    end if;
    
    -- write
    if (pi.irdy or pi.trdy) = '0' and pr.t.cur_acc(0).acc_type(1) = '1' and pr.t.cur_acc(0).impcfgreg = '1' and
       pr.t.cur_acc(0).read = '0' and pr.t.fstate = ptf_cwrite then 
      -- Support for all CBE combinations
      if pi.cbe(3) = '0' then t_cad(31 downto 24) := pi.ad(31 downto 24); end if;
      if pi.cbe(2) = '0' then t_cad(23 downto 16) := pi.ad(23 downto 16); end if;
      if pi.cbe(1) = '0' then t_cad(15 downto  8) := pi.ad(15 downto  8); end if;
      if pi.cbe(0) = '0' then t_cad( 7 downto  0) := pi.ad( 7 downto  0); end if;

      if pr.t.cur_acc(0).acc_type(0) = '0'then
        case pr.t.conf_addr is
          --when "0000" =>  -- Device and Vendor ID
          when "0001" =>  -- Status and Command
            -- Command register
            pv.conf(conf_func).comm.ioen := t_cad(0);
            pv.conf(conf_func).comm.memen := t_cad(1);
            if MASTER = 1 then 
              pv.conf(conf_func).comm.msten := t_cad(2); 
              pv.pta_trans.ca_pcimsten(conf_func) := pv.conf(conf_func).comm.msten;
            end if;
            pv.conf(conf_func).comm.mwien := t_cad(4);
            pv.conf(conf_func).comm.perren := t_cad(6);
            pv.conf(conf_func).comm.serren := t_cad(8);
            pv.conf(conf_func).comm.intdis := t_cad(10);
            
            -- Status register, sticky bits
            pv.conf(conf_func).stat.mdpe := pr.conf(conf_func).stat.mdpe and not t_cad(24);
            pv.conf(conf_func).stat.sta  := pr.conf(conf_func).stat.sta  and not t_cad(27); 
            pv.conf(conf_func).stat.rta  := pr.conf(conf_func).stat.rta  and not t_cad(28); 
            pv.conf(conf_func).stat.rma  := pr.conf(conf_func).stat.rma  and not t_cad(29); 
            pv.conf(conf_func).stat.sse  := pr.conf(conf_func).stat.sse  and not t_cad(30); 
            pv.conf(conf_func).stat.dpe  := pr.conf(conf_func).stat.dpe  and not t_cad(31);
          --when "0010" =>  -- Class Code and Revision ID
          when "0011" =>  -- BIST, Header Type, Latency Timer and Cache Line Size
            pv.conf(conf_func).ltimer := t_cad(15 downto 8);
          when "0100" =>  -- BAR0
            if bar_size(conf_func)(0) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(0);
              pv.conf(conf_func).bar(0)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0101" =>  -- BAR1
            if bar_size(conf_func)(1) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(1);
              pv.conf(conf_func).bar(1)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0110" =>  -- BAR2
            if bar_size(conf_func)(2) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(2);
              pv.conf(conf_func).bar(2)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0111" =>  -- BAR3
            if bar_size(conf_func)(3) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(3);
              pv.conf(conf_func).bar(3)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "1000" =>  -- BAR4
            if bar_size(conf_func)(4) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(4);
              pv.conf(conf_func).bar(4)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "1001" =>  -- BAR5
            if bar_size(conf_func)(5) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(5);
              pv.conf(conf_func).bar(5)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          --when "1010" =>  -- Cardbus CIS Pointer
          --when "1011" =>  -- Subsystem ID and Subsystem Vendor ID
          --when "1100" =>  -- Expansion ROM Base Address
          --when "1101" =>  -- Reserved and Capabillities Pointer
          --when "1110" =>  -- Reserved
          when "1111" =>  -- Max_Lat, Min_Gnt, Interrupt Pin and Interrupt Line
            pv.conf(conf_func).iline := t_cad(7 downto 0);
          when others =>
        end case;
      else                                              -- Mapping registers
        case pr.t.conf_addr is
          when "0001" => 
            if bar_size(conf_func)(0) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(0);
              pv.conf(conf_func).pta_map(0)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0010" => 
            if bar_size(conf_func)(1) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(1);
              pv.conf(conf_func).pta_map(1)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0011" => 
            if bar_size(conf_func)(2) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(2);
              pv.conf(conf_func).pta_map(2)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0100" => 
            if bar_size(conf_func)(3) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(3);
              pv.conf(conf_func).pta_map(3)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0101" => 
            if bar_size(conf_func)(4) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(4);
              pv.conf(conf_func).pta_map(4)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0110" => 
            if bar_size(conf_func)(5) /= 0 then 
              t_cad := t_cad and pr.conf(conf_func).bar_mask(5);
              pv.conf(conf_func).pta_map(5)(31 downto barminsize) := t_cad(31 downto barminsize);
            end if;
          when "0111" =>
            pv.conf(conf_func).cfg_map(31 downto 8) := t_cad(31 downto 8);
          when "1000" => 
            pv.t.discardtimeren := t_cad(1);
            pv.pta_trans.ca_twist := t_cad(0);
          when "1001" => 
            if bar_size(conf_func)(0) /= 0 then 
              pv.conf(conf_func).bar_mask(0)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(0)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(0)(0) := t_cad(0);
            end if;
          when "1010" => 
            if bar_size(conf_func)(1) /= 0 then 
              pv.conf(conf_func).bar_mask(1)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(1)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(1)(0) := t_cad(0);
            end if;
          when "1011" => 
            if bar_size(conf_func)(2) /= 0 then 
              pv.conf(conf_func).bar_mask(2)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(2)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(2)(0) := t_cad(0);
            end if;
          when "1100" => 
            if bar_size(conf_func)(3) /= 0 then 
              pv.conf(conf_func).bar_mask(3)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(3)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(3)(0) := t_cad(0);
            end if;
          when "1101" => 
            if bar_size(conf_func)(4) /= 0 then 
              pv.conf(conf_func).bar_mask(4)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(4)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(4)(0) := t_cad(0);
            end if;
          when "1110" => 
            if bar_size(conf_func)(5) /= 0 then 
              pv.conf(conf_func).bar_mask(5)(31 downto barminsize) := t_cad(31 downto barminsize);
              pv.conf(conf_func).bar_mask(5)(3) := t_cad(3);
              pv.conf(conf_func).bar_mask(5)(0) := t_cad(0);
            end if;
          when "1111" => 
            pv.t.blenmask(blenmask_size(barminsize) downto FIFO_DEPTH) := t_cad(blenmask_size(barminsize) downto FIFO_DEPTH);
            pv.t.saverfifo := t_cad(31);
          when others =>
        end case;
      end if;
    end if;
 
    -- FIFO State machine
    case pr.t.fstate is
      when ptf_idle =>
        pv.t.first := (others => '1');
        pv.t.preload := '0';
        pv.t.preload_count := (others => '0');
        pv.t.diswithout := '0';
        if pr.t.cur_acc(0).pending = '1' then
          if pr.t.cur_acc(0).read = '1' then  -- Memory and Config read
            pv.t.fstate := ptf_fifo;
            pv.t.atp.ctrl.addr := conv_std_logic_vector(pr.t.atp.index, log2(FIFO_COUNT)) & pr.t.cur_acc(0).addr(FIFO_DEPTH+1 downto 2);
          else                            
            if pr.t.cur_acc(0).acc_type(1) = '1' then    -- Config write 
              pv.t.fstate := ptf_cwrite;
              pv.t.conf_addr := pr.t.cur_acc(0).addr(5 downto 2);
              t_ready := '1';
            elsif tm_fifo_empty(pr.t.pta.index) = '1' then -- Memory write
              -- Burst length (only burst up to this boundary)
              pv.t.blen := ((not pr.t.cur_acc(0).addr(17 downto 2)) and pr.t.blenmask);
              pv.t.fstate := ptf_write;
              t_ready := '1';
              pv.t.pta.ctrl.addr := conv_std_logic_vector(pr.t.pta.index, log2(FIFO_COUNT)) & pr.t.cur_acc(0).addr(FIFO_DEPTH+1 downto 2);
              if pr.t.cur_acc(0).acc_type(0) = '0' then -- memory access
                pv.t.addr := set_pta_addr(pr.t.cur_acc(0).addr, pr.conf(pr.t.cur_acc(0).func).pta_map, pr.t.cur_acc(0).bar, pr.conf(pr.t.cur_acc(0).func).bar_mask, barminsize);
              else
                pv.t.addr := pr.conf(conf_func).cfg_map(31 downto 8) & pr.t.cur_acc(0).addr(7 downto 0);
              end if;
            else
              t_retry := '1';
              pv.t.fstate := ptf_idle;
              pv.t.cur_acc(0).pending := '0';
            end if;
          end if;

          if pr.t.cur_acc(0).acc_type(1) = '0' and                                          -- Access to AHB  
             (   (pr.t.cur_acc(0).read = '1')                        -- Read
              or (pr.t.cur_acc(0).read = '0' and tm_fifo_empty(pr.t.pta.index) = '1')) then -- Write

            if tm_acc_pending = '0' and pr.t.accbuf(0).pending = '0' then
              pv.pta_trans.tm_acc.pending := not pr.pta_trans.tm_acc.pending;
              if pr.t.cur_acc(0).acc_type(0) = '0' then -- memory access
                pv.pta_trans.tm_acc.addr := set_pta_addr(pr.t.cur_acc(0).addr, pr.conf(pr.t.cur_acc(0).func).pta_map, pr.t.cur_acc(0).bar, pr.conf(pr.t.cur_acc(0).func).bar_mask, barminsize);
              else
                pv.pta_trans.tm_acc.addr := pr.conf(conf_func).cfg_map(31 downto 8) & pr.t.cur_acc(0).addr(7 downto 0);
              end if;
              
              pv.pta_trans.tm_acc.acctype := "000" & not pr.t.cur_acc(0).read; -- acctype(0) = write
              pv.pta_trans.tm_acc.accmode := "00" & pr.t.cur_acc(0).burst; 
              pv.pta_trans.tm_acc.size := (others => '0');    -- not used
              pv.pta_trans.tm_acc.offset := (others => '0');  -- not used
              if pr.t.cur_acc(0).read = '1' then pv.pta_trans.tm_acc.index := pr.t.atp.index;
              else pv.pta_trans.tm_acc.index := pr.t.pta.index; end if;
              pv.pta_trans.tm_acc.length := ((not pr.t.cur_acc(0).addr(17 downto 2)) and pr.t.blenmask);
              pv.pta_trans.tm_acc.cbe := pi.cbe;
              pv.pta_trans.tm_acc.endianess := pr.pta_trans.ca_twist;
            else
              accbufindex := 0;
              for i in 3 downto 0 loop
                if pv.t.accbuf(i).pending = '0' then accbufindex := i; end if;
              end loop;
              pv.t.accbuf(accbufindex).pending := '1';
              if pr.t.cur_acc(0).acc_type(0) = '0' then -- memory access
                pv.t.accbuf(accbufindex).addr := set_pta_addr(pr.t.cur_acc(0).addr, pr.conf(pr.t.cur_acc(0).func).pta_map, pr.t.cur_acc(0).bar, pr.conf(pr.t.cur_acc(0).func).bar_mask, barminsize);
              else
                pv.t.accbuf(accbufindex).addr := pr.conf(conf_func).cfg_map(31 downto 8) & pr.t.cur_acc(0).addr(7 downto 0);
              end if;
                                                                                                                 
              pv.t.accbuf(accbufindex).acctype := "000" & not pr.t.cur_acc(0).read; -- acctype(0) = write
              pv.t.accbuf(accbufindex).accmode := "00" & pr.t.cur_acc(0).burst; 
              pv.t.accbuf(accbufindex).size := (others => '0');    -- not used
              pv.t.accbuf(accbufindex).offset := (others => '0');  -- not used
              if pr.t.cur_acc(0).read = '1' then pv.t.accbuf(accbufindex).index := pr.t.atp.index;
              else pv.t.accbuf(accbufindex).index := pr.t.pta.index; end if;
              pv.t.accbuf(accbufindex).length := ((not pr.t.cur_acc(0).addr(17 downto 2)) and pr.t.blenmask);
              pv.t.accbuf(accbufindex).cbe := pi.cbe;
              pv.t.accbuf(accbufindex).endianess := pr.pta_trans.ca_twist;
            end if;
          end if;

        end if;
      when ptf_fifo =>
        pv.t.atp.ctrl.en := tm_fifo_pending(pr.t.atp.index);
        
        if (pr.t.hold(0) = '0' or pr.t.first_word = '1') and pr.t.cfifo(0).valid = '1' then
          t_ready := '1';
        end if;
        
        if pr.t.cur_acc(0).newacc = '1' or 
           (tm_acc_cancel = '1' and pr.t.cur_acc(0).acc_type(1) = '0') or
           pr.t.cur_acc(0).read = '0' then
          t_ready := '0';
        end if;
        

        if (tm_acc_cancel = '0' and tm_fifo_pending(pr.t.atp.index) = '1') or pr.t.preload = '1' or pr.t.cur_acc(0).acc_type(1) = '1' then  -- FIFO pending or Config access
          pv.t.preload := '1';
          if pr.t.preload = '0' then pv.t.hold_fifo := '0'; end if;
        end if;
      
        if ((pi.trdy or pi.irdy) = '0' and pr.t.state = pt_s_data) or pr.t.preload = '1' then
          
          if (pi.trdy or pi.irdy) = '0' and pr.t.state = pt_s_data then
            pv.t.cfifo(0) := pr.t.cfifo(1); pv.t.cfifo(1) := pr.t.cfifo(2); -- Preload target core fifo
            pv.t.cur_acc(0).addr := pr.t.cur_acc(0).addr + 4;
          elsif pr.t.preload = '1' then
            if pr.t.cfifo(0).valid = '0' then
              pv.t.cfifo(0) := pr.t.cfifo(1); pv.t.cfifo(1) := pr.t.cfifo(2); -- Preload target core fifo
            elsif pr.t.cfifo(0).valid = '1' and pr.t.cfifo(1).valid = '0' then
              pv.t.cfifo(1) := pr.t.cfifo(2); -- Preload target core fifo
            end if;
          end if;


          if pr.t.cur_acc(0).acc_type(1) = '0' then  -- Memory access
            pv.t.cfifo(2).data := byte_twist(tm_fifoo_atp.data, pr.pta_trans.ca_twist); -- shifting in data from backend fifo
          else
            pv.t.cfifo(2).data := t_cad;            -- Configuration access
          end if;
        
          if pr.t.cur_acc(0).acc_type(1) = '0' then  -- Memory access
            
            if tm_fifo_pending(pr.t.atp.index) = '1' then
              if pr.t.atp.ctrl.addr(FIFO_DEPTH-1 downto 0) = tm_fifo(pr.t.atp.index).stop and pr.t.hold_fifo = '0' then -- Mark last word
                pv.t.atp.index := t_index;
                pv.t.atp.ctrl.addr := conv_std_logic_vector(pv.t.atp.index, log2(FIFO_COUNT)) & zero32(FIFO_DEPTH-1 downto 0); -- Reset backend fifo address
                pv.pta_trans.tm_fifo_ack(pr.t.atp.index) := tm_fifo(pr.t.atp.index).pending(RAM_LATENCY); -- Ack the fifo (done using this data)
                
                if tm_fifo_pending(t_index) = '1' then
                  pv.t.cfifo(2).hold := '0';
                else
                  pv.t.cfifo(2).hold := '1';
                  pv.t.hold_fifo := '1';
                  -- Disconnect on last fifo
                  if tm_fifo(pr.t.atp.index).lastf = '1' then pv.t.cfifo(2).stlast := '1'; end if;
                  -- Disable fifo read
                  pv.t.atp.ctrl.en := '0';
                end if;

              else
                pv.t.cfifo(2).hold := '0';
              
                if pr.t.hold_fifo = '0' then
                  pv.t.atp.ctrl.addr := conv_std_logic_vector(pv.t.atp.index, log2(FIFO_COUNT)) & pr.t.atp.ctrl.addr(FIFO_DEPTH-1 downto 0) + 1; -- inc backend fifo address
                end if;
              end if;

              if pr.t.atp.ctrl.addr(FIFO_DEPTH-1 downto 0) = tm_fifo(pr.t.atp.index).stop and tm_fifo(pr.t.atp.index).status /= "0000" then
                pv.t.cfifo(2).err := '1';
              else
                pv.t.cfifo(2).err := '0';
              end if;
            end if;

          else                                    -- Configuration access
            
            if  pr.t.conf_addr = "1110" then
              pv.t.cfifo(2).stlast := '1';
            else
              pv.t.cfifo(2).stlast := '0';
            end if;

            if  pr.t.conf_addr = "1111" then
              pv.t.cfifo(2).hold := '1';
              if pr.t.preload_count = "00" then pv.t.cfifo(2).stlast := '1'; end if;
            else
              pv.t.cfifo(2).hold := '0';
              pv.t.conf_addr := pr.t.conf_addr + 1; -- inc backend fifo address
            end if;
         
            pv.t.cfifo(2).err := '0';
          end if;

          if (tm_fifo_pending(pr.t.atp.index) = '1' or pr.t.cur_acc(0).acc_type(1) = '1') and pr.t.hold_fifo = '0' then
            pv.t.cfifo(2).valid := '1';
          else
            pv.t.cfifo(2).valid := '0';
          end if;
          
        end if;

        if (pv.t.cfifo(0).valid = '1' and pv.t.cfifo(1).valid = '1' and pv.t.cfifo(2).valid = '1')
           or (pv.t.cfifo(0).valid = '1' and pr.t.cfifo(0).valid = '0') 
           or (pv.t.cfifo(0).valid = '1' and pr.t.cfifo(0).hold = '1' and pv.t.cfifo(1).valid = '1') then
          pv.t.preload := '0'; 
          if pr.t.preload = '1' or (pr.t.hold_fifo = '1' and pv.t.hold_fifo = '0') then
            pv.t.hold_reset := '0';
            if pr.t.cfifo(0).hold = '1' and pv.t.cfifo(1).valid = '1' then pv.t.cfifo(0).hold := '0'; end if;
            if pr.t.cfifo(1).hold = '1' and pv.t.cfifo(2).valid = '1' then pv.t.cfifo(1).hold := '0'; end if;
            if pr.t.cfifo(2).hold = '1' and tm_fifo_pending(pr.t.atp.index) = '1' then pv.t.cfifo(2).hold := '0'; end if;
          end if;
        end if;

        if (pr.t.state = pt_turn_ar and pr.t.cur_acc(0).pending = '0' and pr.t.cur_acc(0).continue = '0') 
           or (pr.t.cur_acc(0).newacc = '1')
           or ((pr.t.abort = '1' or pr.t.diswithout = '1') and (pr.t.state = pt_backoff or pr.t.state = pt_turn_ar))
           then 
          if pr.t.cur_acc(0).burst = '1' and pr.t.abort = '0' then
            if pr.t.cur_acc(0).acc_type(1) = '0' or pr.t.cur_acc(0).read = '0' or pr.t.cur_acc(0).pending = '0' then 
              pv.t.fstate := ptf_idle;
            end if;
          else
            pv.t.fstate := ptf_idle;
            if pr.t.abort = '1' then pv.t.cur_acc(0).pending := '0'; end if;
            if pr.t.cur_acc(0).burst = '1' then pv.pta_trans.tm_acc_cancel := not pr.pta_trans.tm_acc_cancel; end if;
          end if;
          pv.t.hold_reset := '0';  
          for i in 0 to 2 loop
            pv.t.cfifo(i).valid := '0';
            pv.t.cfifo(i).hold := '0';
            pv.t.cfifo(i).stlast := '0';
            pv.t.cfifo(i).last := '0';
            pv.t.cfifo(i).err := '0';
          end loop;
          if (pr.t.cur_acc(0).pending = '0' and pr.t.cur_acc(0).acc_type(1) = '0' and pr.t.cur_acc(0).burst = '1') or
             (pr.t.cur_acc(0).newacc = '1' and pr.t.cur_acc(0).oldburst = '1') then
            pv.pta_trans.tm_acc_cancel := not pr.pta_trans.tm_acc_cancel;
          end if;
        end if;
      when ptf_cwrite =>
        if pr.t.hold(0) = '0' then -- can maybe be optimized
          t_ready := '1';
        end if;
        if pr.t.state = pt_turn_ar then
          pv.t.fstate := ptf_idle;
          pv.t.hold_reset := '0';  
        end if;
        
        if (pi.trdy or pi.irdy) = '0' then
          if pr.t.conf_addr /= "1111" then -- Config access
            pv.t.conf_addr := pr.t.conf_addr + 1; -- inc backend fifo address
          end if; 
        end if;
      when ptf_write =>
        if pr.t.hold(0) = '0' then -- can maybe be optimized
          t_ready := '1';
        elsif tm_fifo_empty(pr.t.pta.index) = '1' and pr.t.hold_write = '0' then
          t_ready := '1';
          pv.t.hold_reset := '0';
        end if;

        if (pr.t.addr(AHB_FIFO_BITS) = ones32(FIFO_DEPTH-1 downto 0) and pr.t.first(0) = '1' and 
           (tm_fifo_empty(t_index) = '0' or pr.t.blen = x"0000")) or 
           ((pi.trdy or pi.irdy) = '0' and pr.t.blen = x"0001") or
           pr.t.cur_acc(0).burst = '0' then 
          pv.t.diswithout := '1'; 
        end if;

        if pr.t.state = pt_turn_ar then
          pv.t.fstate := ptf_idle;
          pv.t.hold_reset := '0';  
        end if;
              
        if (pi.trdy or pi.irdy) = '0' then
          pv.t.pta.ctrl.en := '1';
          pv.t.pta.ctrl.addr := conv_std_logic_vector(pr.t.pta.index, log2(FIFO_COUNT)) & pr.t.addr(AHB_FIFO_BITS);
          
          if pi.cbe /= ones32(3 downto 0) or pr.t.first(0) = '1' then
            pv.t.first(0) := '0';
            pv.pta_trans.tm_fifo(pr.t.pta.index).stop := pr.t.addr(AHB_FIFO_BITS);
            pv.pta_trans.tm_fifo(pr.t.pta.index).last_cbe := pi.cbe;
          end if;

          if pr.t.first(0) = '1' then  -- First data in this fifo
            pv.pta_trans.tm_fifo(pr.t.pta.index).start := pr.t.addr(AHB_FIFO_BITS);
          end if;
    
          pv.t.addr := pr.t.addr + 4; -- inc backend fifo address
          if pr.t.blen /= zero32(15 downto 0) then
            pv.t.blen := pr.t.blen - 1;
          end if;
          
          if pr.t.addr(AHB_FIFO_BITS) /= ones32(FIFO_DEPTH-1 downto 0) and pi.frame = '0' and pr.t.diswithout = '0' and pi.stop = '1' then
            
            if pr.t.addr(AHB_FIFO_BITS) = conv_std_logic_vector((conv_integer(ones32(FIFO_DEPTH-1 downto 0)) - 1), FIFO_DEPTH) then
              if tm_fifo_empty(t_index) = '0' then
                pv.t.hold_write := '1';
                t_ready := '0';
                pv.t.diswithout := '1';
              end if;
            end if;
          else
            pv.t.first(0) := '1';
            pv.t.first(1) := '0';
            pv.t.hold_write := '0';
            pv.t.pta.index := t_index;
            pv.pta_trans.tm_fifo(pr.t.pta.index).pending(0) := not pr.pta_trans.tm_fifo(pr.t.pta.index).pending(0);
            pv.pta_trans.tm_fifo(pr.t.pta.index).status := (others => '0');
            if pr.t.first(1) = '1' then pv.pta_trans.tm_fifo(pr.t.pta.index).firstf := '1';
            else pv.pta_trans.tm_fifo(pr.t.pta.index).firstf := '0'; end if;
            if pi.frame = '1' or pr.t.diswithout = '1' then pv.pta_trans.tm_fifo(pr.t.pta.index).lastf := '1'; -- Mark last fifo
            else pv.pta_trans.tm_fifo(pr.t.pta.index).lastf := '0'; end if;
          end if;
        end if;
      when others =>
    end case;


    -- PCI State machine
    case pr.t.state is
      when pt_idle =>    -- The bus is in idle state
        pv.t.hold_write := '0';
        pv.t.lcount := (others => '0'); -- reset latency counter
        pv.t.stoped := '0';
        pv.t.retry := '0';
        if pi.frame = '0' then
          if t_hit = '1' or t_chit = '1' then
            pv.t.state := pt_s_data;
            pv.t.first_word := '1';
            case pi.cbe is
              when CONF_READ =>
                t_acc_read := '1';
                t_acc_burst := '1';
                t_acc_type := "10";
                pv.t.conf_addr := pi.ad(5 downto 2);
                if pi.ad(7 downto 4) >= "0100" then
                  if ext_cap_pointer_vector(conf_func) /= 16#00# then
                    t_acc_type := "01";
                  else
                    t_acc_impcfgreg := '0';
                  end if;
                  if pi.ad(7 downto 4) >= conv_std_logic_vector(cap_pointer, 8)(7 downto 4) 
                     and pi.ad(7 downto 4) < conv_std_logic_vector(cap_pointer + 16#40#, 8)(7 downto 4) then
                    t_acc_type := "11";
                    t_acc_impcfgreg := '1';
                  end if;
                end if;
              when CONF_WRITE =>
                t_acc_read := '0';
                t_acc_burst := '1';
                t_acc_type := "10";
                pv.t.conf_addr := pi.ad(5 downto 2);
                if pi.ad(7 downto 4) >= "0100" then
                  if ext_cap_pointer_vector(conf_func) /= 16#00# then
                    t_acc_type := "01";
                  else
                    t_acc_impcfgreg := '0';
                  end if;
                  if pi.ad(7 downto 4) >= conv_std_logic_vector(cap_pointer, 8)(7 downto 4) 
                     and pi.ad(7 downto 4) < conv_std_logic_vector(cap_pointer + 16#40#, 8)(7 downto 4) then
                    t_acc_type := "11";
                    t_acc_impcfgreg := '1';
                  end if;
                end if;
              when MEM_READ =>
                t_acc_read := '1';
                t_acc_burst := '0';
                t_acc_type := "00";
              when MEM_WRITE | MEM_W_INV =>
                t_acc_read := '0';
                 -- Burst ordering: Linear Incrementing
                if pi.ad(1 downto 0) = "00" then t_acc_burst := '1';
                else t_acc_burst := '0'; end if;
                t_acc_type := "00";
              when IO_READ =>
                t_acc_read := '1';
                t_acc_burst := '0';
                t_acc_type := "00";
              when IO_WRITE => 
                t_acc_read := '0';
                t_acc_burst := '0';
                t_acc_type := "00";
              when MEM_R_MULT | MEM_R_LINE => 
                t_acc_read := '1';
                 -- Burst ordering: Linear Incrementing
                if pi.ad(1 downto 0) = "00" then t_acc_burst := '1';
                else t_acc_burst := '0'; end if;
                t_acc_type := "00";
              when others =>
                t_acc_read := '1';
                t_acc_burst := '1';
                t_acc_type := "00";
            end case;

            if (pr.t.cur_acc(0).pending = '1' or pr.t.cur_acc(0).continue = '1') and pr.t.cur_acc(0).addr = pi.ad 
               and t_acc_read = '1' and pr.t.cur_acc(0).acc_type(1) = '0' then
              pv.t.cur_acc(0).match := '1';
              pv.t.cur_acc(0).pending := '1';
              pv.t.discardtimer := (others => '1');
            elsif pr.t.cur_acc(0).pending = '0' then -- Save new access
              pv.t.cur_acc(0).addr := pi.ad;
              pv.t.cur_acc(0).pending := '1';
              pv.t.cur_acc(0).retry := '0';
              pv.t.cur_acc(0).read := t_acc_read;
              pv.t.cur_acc(0).burst := t_acc_burst;
              pv.t.cur_acc(0).acc_type := t_acc_type;
              pv.t.cur_acc(0).impcfgreg := t_acc_impcfgreg;
              pv.t.cur_acc(0).bar := t_bar;
              pv.t.cur_acc(0).func := t_func;
              pv.t.cur_acc(0).match := '0';
              pv.t.discardtimer := (others => '1');
              if pr.t.cur_acc(0).continue = '1' then
                pv.t.cur_acc(0).newacc := '1';
                pv.t.cur_acc(0).oldburst := pr.t.cur_acc(0).burst;
              end if;
            else
              pv.t.cur_acc(0).match := '0'; 
            end if;
            pv.t.cur_acc(0).continue := '0';
          else
            pv.t.state := pt_b_busy;
          end if;
        end if;
      when pt_b_busy =>  -- Wait for the current transaction to complete and bus return 
                      -- to idle sate
        if (pi.frame and pi.irdy) = '1' then
          pv.t.state := pt_idle;
        end if;
      when pt_s_data =>  -- Target is transfering data
        if (pi.frame and not pi.irdy and ( not pi.trdy or not pi.stop)) = '1' then
          pv.t.state := pt_turn_ar;
          pv.t.retry := '0';
          if pr.t.cur_acc(0).pending = '0' and pr.t.cur_acc(0).acc_type(1) = '0' and 
             pr.t.cur_acc(0).read = '1' and pi.trdy = '1' and pi.stop = '0' and pr.t.stop = '0' and
             pr.t.cur_acc(0).burst = '1' and pr.t.discardtimer /= x"0000" then
            if pr.t.saverfifo = '1' then -- FIFO is saved until next access (disconnect without data). 
                                         -- If the next access is not the read continuing, the prefetched data is discarded.
              pv.t.cur_acc(0).continue := '1';
            end if;
          end if;
        elsif (not pi.frame and not pi.stop) = '1' then
          pv.t.state := pt_backoff;
          pv.t.retry := '0';
          if pr.t.cur_acc(0).pending = '0' and pr.t.cur_acc(0).acc_type(1) = '0' and 
             pr.t.cur_acc(0).read = '1' and pr.t.stop = '0' and pr.t.stop = '0' and
             pr.t.cur_acc(0).burst = '1' and pr.t.discardtimer /= x"0000" then
            if pr.t.saverfifo = '1' then -- FIFO is saved until next access (disconnect without data). 
                                         -- If the next access is not the read continuing, the prefetched data is discarded.
              pv.t.cur_acc(0).continue := '1';
            end if;
          end if;
        end if;
        
        if (not pi.irdy and not pi.trdy) = '1' then pv.t.cur_acc(0).pending := '0'; end if; -- Data transfered, reset pending
        
        -- can maybe be optimized
        if ((pr.t.cfifo(0).valid = '0' or pr.t.cur_acc(0).match = '0') and 
           pr.t.cur_acc(0).pending = '1' and pr.t.cur_acc(0).acc_type(1) = '0' and pr.t.cur_acc(0).read = '1') or 
           pr.t.retry = '1' then t_retry := '1'; pv.t.retry := '1'; end if;
        
        -- CFIFO valid again after FIFO switch (First word in continued access), to reassert trdy
        if pr.t.fstate = ptf_fifo and pr.t.preload = '1' and pr.t.first_word = '0' and 
           pr.t.cfifo(0).valid = '0' and pr.t.cfifo(1).valid = '1' then
          pv.t.first_word := '1';
        end if;
        
        -- When FIFO is saved until next access (disconnect without data)
        -- the first_word signal needs to be set one extra cycle to be valid the cycle before 
        -- FIFO state-machine moves to FIFO write state
        if pr.t.fstate = ptf_fifo and pr.t.first_word = '1' and
           pr.t.cur_acc(0).pending = '1' and pr.t.cur_acc(0).newacc = '1' and 
           pr.t.cur_acc(0).read = '0' then
          if pr.t.saverfifo = '1' then  
            pv.t.first_word := '1';
          end if;
        end if;


      when pt_backoff => -- STOP# is asserted, waiting on deasserted FRAME#
        if pi.frame = '1' then
          pv.t.state := pt_turn_ar;
        end if;
      when pt_turn_ar => -- Deassert active signals before tri-state
        
        -- from idle
        pv.t.hold_write := '0';
        pv.t.lcount := (others => '0'); -- reset latency counter
        pv.t.stoped := '0';
        pv.t.retry := '0';
        
        if pi.frame = '1' then
          pv.t.state := pt_idle;
        elsif pi.frame = '0' then


          if t_hit = '1' or t_chit = '1' then
            pv.t.state := pt_s_data;
            pv.t.first_word := '1';
            case pi.cbe is
              when CONF_READ =>
                t_acc_read := '1';
                t_acc_burst := '1';
                t_acc_type := "10";
                pv.t.conf_addr := pi.ad(5 downto 2);
                if pi.ad(7 downto 4) >= "0100" then
                  if ext_cap_pointer_vector(conf_func) /= 16#00# then
                    t_acc_type := "01";
                  else
                    t_acc_impcfgreg := '0';
                  end if;
                  if pi.ad(7 downto 4) >= conv_std_logic_vector(cap_pointer, 8)(7 downto 4) 
                     and pi.ad(7 downto 4) < conv_std_logic_vector(cap_pointer + 16#40#, 8)(7 downto 4) then
                    t_acc_type := "11";
                    t_acc_impcfgreg := '1';
                  end if;
                end if;
              when CONF_WRITE =>
                t_acc_read := '0';
                t_acc_burst := '1';
                t_acc_type := "10";
                pv.t.conf_addr := pi.ad(5 downto 2);
                if pi.ad(7 downto 4) >= "0100" then
                  if ext_cap_pointer_vector(conf_func) /= 16#00# then
                    t_acc_type := "01";
                  else
                    t_acc_impcfgreg := '0';
                  end if;
                  if pi.ad(7 downto 4) >= conv_std_logic_vector(cap_pointer, 8)(7 downto 4) 
                     and pi.ad(7 downto 4) < conv_std_logic_vector(cap_pointer + 16#40#, 8)(7 downto 4) then
                    t_acc_type := "11";
                    t_acc_impcfgreg := '1';
                  end if;
                end if;
              when MEM_READ =>
                t_acc_read := '1';
                t_acc_burst := '0';
                t_acc_type := "00";
              when MEM_WRITE | MEM_W_INV =>
                t_acc_read := '0';
                 -- Burst ordering: Linear Incrementing
                if pi.ad(1 downto 0) = "00" then t_acc_burst := '1';
                else t_acc_burst := '0'; end if;
                t_acc_type := "00";
              when IO_READ =>
                t_acc_read := '1';
                t_acc_burst := '0';
                t_acc_type := "00";
              when IO_WRITE =>
                t_acc_read := '0';
                t_acc_burst := '0';
                t_acc_type := "00";
              when MEM_R_MULT | MEM_R_LINE => 
                t_acc_read := '1';
                 -- Burst ordering: Linear Incrementing
                if pi.ad(1 downto 0) = "00" then t_acc_burst := '1';
                else t_acc_burst := '0'; end if;
                t_acc_type := "00";
              when others => 
                t_acc_read := '1';
                t_acc_burst := '1';
                t_acc_type := "00";
            end case;

            if (pr.t.cur_acc(0).pending = '1' or pr.t.cur_acc(0).continue = '1') and pr.t.cur_acc(0).addr = pi.ad and t_acc_read = '1' and pr.t.cur_acc(0).acc_type(1) = '0' then
              pv.t.cur_acc(0).match := '1';
              pv.t.cur_acc(0).pending := '1';
              pv.t.discardtimer := (others => '1');
            elsif pr.t.cur_acc(0).pending = '0' then -- Save new access
              pv.t.cur_acc(0).addr := pi.ad;
              pv.t.cur_acc(0).pending := '1';
              pv.t.cur_acc(0).retry := '0';
              pv.t.cur_acc(0).read := t_acc_read;
              pv.t.cur_acc(0).burst := t_acc_burst;
              pv.t.cur_acc(0).acc_type := t_acc_type;
              pv.t.cur_acc(0).impcfgreg := t_acc_impcfgreg;
              pv.t.cur_acc(0).bar := t_bar;
              pv.t.cur_acc(0).func := t_func;
              pv.t.cur_acc(0).match := '0';
              pv.t.discardtimer := (others => '1');
              if pr.t.cur_acc(0).continue = '1' then
                pv.t.cur_acc(0).newacc := '1';
                pv.t.cur_acc(0).oldburst := pr.t.cur_acc(0).burst;
              end if;
            else
              pv.t.cur_acc(0).match := '0'; 
            end if;
            pv.t.cur_acc(0).continue := '0';
          else
            pv.t.state := pt_b_busy;
          end if;
        end if;
      when others =>
    end case;

    if pr.t.fstate = ptf_idle then pv.t.hold_reset := '0'; end if;

    if pr.po.stop = '0' then pv.t.stoped := '1'; end if;
  end if; -- PCI target enabled

  
  -- --------------------------------------------------------------------------------
  -- PCI trace
  -- --------------------------------------------------------------------------------
  -- sync
  pv.pt_sync(1) := ar.atpt_trans; pv.pt_sync(2) := pr.pt_sync(1);
  if nsync = 0 then atpt_trans := ar.atpt_trans;
  else atpt_trans := pr.pt_sync(nsync); end if;

  pt_setup := ar.atpt_trans;
  
  pv.ptta_trans.start_ack := atpt_trans.start;
  pv.ptta_trans.stop_ack := atpt_trans.stop;
  
  pt_start := not pr.ptta_trans.start_ack and (pr.ptta_trans.start_ack xor atpt_trans.start); 
  pt_stop := not pr.ptta_trans.stop_ack and (pr.ptta_trans.stop_ack xor atpt_trans.stop); 

  if tracebuffer /= 0 then -- PCI trace buffer enabled
    if pr.ptta_trans.enable = '1' then -- PCI tracing
      pv.pt.addr := pr.pt.addr + 1;

      if pr.ptta_trans.armed = '1' then -- Check for match
        if ((((pi.ad & pcisig) xor (pt_setup.ad & pt_setup.sig)) and (pt_setup.admask & pt_setup.sigmask)) = z) then
          if pr.pt.tcount = x"00" then 
            pv.ptta_trans.armed := '0'; -- Start saving trace
            pv.ptta_trans.taddr := pr.pt.addr;
          else pv.pt.tcount := pr.pt.tcount - 1; end if;
        end if;
        if pr.pt.addr = pr.ptta_trans.taddr then pv.ptta_trans.wrap := '1'; end if;
      else
        if pr.pt.count = zero32(PT_DEPTH-1 downto 0) then pv.ptta_trans.enable := '0'; -- Trace done 
        else pv.pt.count := pr.pt.count - 1; end if;
      end if;
    end if;
    
    if pt_stop = '1' then  -- Start PCI tracing
      pv.ptta_trans.enable := '0';
      if pr.ptta_trans.enable = '1' then
        pv.ptta_trans.taddr := pr.pt.addr;
      end if;
    end if;

    if pt_start = '1' then  -- Start PCI tracing
      pv.ptta_trans.enable := '1';
      pv.ptta_trans.armed := '1';
      pv.ptta_trans.wrap := '0';
      pv.pt.count := pt_setup.count;
      pv.pt.tcount := pt_setup.tcount;
    end if;

    -- 
    pv.ptta_trans.dbg_ad      := pi.ad;
    pv.ptta_trans.dbg_sig     := pcisig;
    pv.ptta_trans.dbg_cur_ad  := pr.t.cur_acc(0).addr;
    pv.ptta_trans.dbg_cur_acc := pr.t.cur_acc(0).oldburst &                        
                                 pr.t.cur_acc(0).acc_type &                        
                                 pr.t.cur_acc(0).read &
                                 pr.t.cur_acc(0).continue &
                                 pr.t.cur_acc(0).burst &
                                 pr.t.cur_acc(0).newacc &
                                 pr.t.cur_acc(0).match &
                                 pr.t.cur_acc(0).pending;
  end if; -- PCI trace buffer enabled

  -- --------------------------------------------------------------------------------
  -- PCI debug
  -- --------------------------------------------------------------------------------

  --[31:30] ms_fifo_pending
  --[29:28] ms_fifo_empty
  --[37:36] tm_fifo_pending
  --[25:24] tm_fifo_empty
  --[  :23] ms_acc_pending;
  --[  :22] ms_acc_cancel;
  --[  :21] ms_acc_done;
  --[  :20] md_acc_pending;
  --[  :19] md_acc_cancel;
  --[  :18] md_acc_done;
  --[  :17] tm_acc_pending;
  --[  :16] tm_acc_cancel;
  --[  :15] tm_acc_done;
  --[14:12] t.state
  --[11: 8] t.fstate
  --[ 7: 4] m.state
  --[ 3: 0] m.fstate

  pv.debug(31 downto 30) := ms_fifo_pending(1 downto 0);
  pv.debug(29 downto 28) := ms_fifo_empty(1 downto 0);
  pv.debug(27 downto 26) := tm_fifo_pending(1 downto 0);
  pv.debug(25 downto 24) := tm_fifo_empty(1 downto 0);

  pv.debug(          23) := ms_acc_pending;
  pv.debug(          22) := ms_acc_cancel;
  pv.debug(          21) := ms_acc_done;
  pv.debug(          20) := md_acc_pending;
  pv.debug(          19) := md_acc_cancel;
  pv.debug(          18) := md_acc_done;
  pv.debug(          17) := tm_acc_pending;
  pv.debug(          16) := tm_acc_cancel;
  pv.debug(          15) := tm_acc_done;
  
  case pr.t.state is 
    when pt_idle =>    pv.debug(14 downto 12) := "000";
    when pt_b_busy =>  pv.debug(14 downto 12) := "001";
    when pt_s_data =>  pv.debug(14 downto 12) := "010";
    when pt_backoff => pv.debug(14 downto 12) := "011";
    when pt_turn_ar => pv.debug(14 downto 12) := "100";
    when others =>  pv.debug(14 downto 12) := "111";
  end case;
  
  case pr.t.fstate is 
    when ptf_idle =>    pv.debug(11 downto 8) := "0000";
    when ptf_fifo =>    pv.debug(11 downto 8) := "0001";
    when ptf_cwrite =>  pv.debug(11 downto 8) := "0010";
    when ptf_write =>   pv.debug(11 downto 8) := "0011";
    when others =>  pv.debug(11 downto 8) := "1111";
  end case;

  case pr.m.state is 
    when pm_idle =>    pv.debug(7 downto 4) := "0000";
    when pm_addr =>    pv.debug(7 downto 4) := "0001";
    when pm_m_data =>  pv.debug(7 downto 4) := "0010";
    when pm_turn_ar => pv.debug(7 downto 4) := "0011";
    when pm_s_tar =>   pv.debug(7 downto 4) := "0100";
    when pm_dr_bus =>  pv.debug(7 downto 4) := "0101";
    when others =>  pv.debug(7 downto 4) := "1111";
  end case;

  case pr.m.fstate is 
    when pmf_idle =>    pv.debug(3 downto 0) := "0000";
    when pmf_fifo =>    pv.debug(3 downto 0) := "0001";
    when pmf_read =>    pv.debug(3 downto 0) := "0010";
    when others =>  pv.debug(3 downto 0) := "1111";
  end case;

  debugo <= (others => '0');

  -- --------------------------------------------------------------------------------
  -- PCI reset
  -- --------------------------------------------------------------------------------
  
  -- PCI master
  lpcim_rst <= pcirst(0) and not pci_master_rst and not pci_hard_rst;
  if lpcim_rst = '0' then
    
    -- state
    pv.m.fstate := pmf_idle;
    
    for i in 0 to 2 loop
      pv.m.cfifo(i).last := '0';
      pv.m.cfifo(i).stlast := '0';
      pv.m.cfifo(i).hold := '0';
      pv.m.cfifo(i).valid := '0';
      pv.m.cfifo(i).err := '0';
    end loop;
    
    -- core
    pv.m.devsel_asserted := '1';
    pv.m.abort := (others => '0');
    pv.m.hold := (others => '0');
    pv.m.hold_fifo := '0';
    pv.m.term := (others => '0');
    pv.m.acc_cnt := 0;
    pv.m.acc_switch := '0';
    for i in 0 to 1 loop
      pv.m.acc(i).pending := '0';
      pv.m.acc(i).active := (others => '0');
      pv.m.acc(i).fifo_index := 0;
    end loop;
    pv.m.fifo_addr := (others => '0');
    pv.m.addr := (others => '0');       -- X-prop fix
    
    -- trans
    for i in 0 to 1 loop
      pv.pta_trans.msd_acc_ack(i) := '0';
      pv.pta_trans.msd_acc_cancel_ack(i) := (others => '0');
      pv.pta_trans.msd_acc_done(i).done := '0';
      for j in 0 to FIFO_COUNT-1 loop
        pv.pta_trans.msd_fifo(i)(j).pending := (others => '0');
      end loop;
      pv.pta_trans.msd_fifo_ack(i) := (others => '0');
    end loop;
  end if;
  
  -- PCI target
  lpcit_rst <= pcirst(0) and not pci_target_rst and not pci_hard_rst;
  if lpcit_rst = '0' then
    
    -- state
    pv.t.fstate := ptf_idle;
    
    for i in 0 to 2 loop
      pv.t.cfifo(i).last := '0';
      pv.t.cfifo(i).stlast := '0';
      pv.t.cfifo(i).hold := '0';
      pv.t.cfifo(i).valid := '0';
      pv.t.cfifo(i).err := '0';
    end loop;
    pv.t.cfifo(0).data := (others => '0');  -- X-prop fix
    pv.t.cfifo(1).data := (others => '0');  -- X-prop fix
    pv.t.atp.ctrl.addr := (others => '0');  -- X-prop fix
    pv.t.cur_acc(0).addr(31) := '0';        -- X-prop fix
    
    -- core
    pv.t.discardtimeren := '1';
    pv.t.hold := (others => '0');
    pv.t.hold_fifo := '0'; 
    pv.t.stop := '0'; 
    pv.t.addr_perr := '0';
    pv.t.cur_acc(0).pending := '0';
    pv.t.cur_acc(0).continue := '0';
    pv.t.cur_acc(0).read := '0';
    pv.t.cur_acc(0).impcfgreg := '1';
    pv.t.atp.index := 0;
    pv.t.pta.index := 0;
    pv.t.blenmask := (others => '0');
    pv.t.blenmask(blenmask_size(barminsize) downto 0) := (others => '1');
    pv.t.saverfifo := '0';
    for i in 0 to 3 loop
      pv.t.accbuf(i).pending := '0';
    end loop;
    
    -- trans
    for i in 0 to FIFO_COUNT-1 loop
      pv.pta_trans.tm_fifo(i).pending := (others => '0');
    end loop;
    pv.pta_trans.tm_fifo_ack := (others => '0');
    pv.pta_trans.tm_acc.pending := '0';
    pv.pta_trans.tm_acc_cancel := '0';
    pv.pta_trans.tm_acc_done_ack := '0';

  end if;

  -- PCI reset
  lpci_rst <= pcirst(0) and not pci_hard_rst;
  if lpci_rst = '0' then
    
    -- Master state
    pv.m.state := pm_idle;
    
    -- Target state
    pv.t.state := pt_idle;

    -- PCI signals
    pv.po.frame := '1'; pv.po.irdy := '1'; pv.po.req := '1';
    pv.po.trdy := '1'; pv.po.stop := '1';
    pv.po.perr := '1'; pv.po.devsel := '1'; 

    -- PCI system
    pv.pta_trans.pa_serr := '1';
    pv.pta_trans.pa_discardtout := '0';

    -- Configuration space
    for j in 0 to multifunc loop
      pv.conf(j).comm.ioen := '0';
      pv.conf(j).comm.memen := '0';
      pv.conf(j).comm.msten := '0';
      pv.conf(j).comm.mwien := '0';
      pv.conf(j).comm.perren := '0';
      pv.conf(j).comm.serren := '0';
      pv.conf(j).comm.intdis := '0';
      pv.conf(j).stat.intsta := '0';
      pv.conf(j).stat.mdpe := '0';
      pv.conf(j).stat.sta := '0';
      pv.conf(j).stat.rta := '0';
      pv.conf(j).stat.rma := '0';
      pv.conf(j).stat.sse := '0';
      pv.conf(j).stat.dpe := '0';
      --pv.conf.clsize := (others => '0');
      pv.conf(j).ltimer := (others => '0');
      pv.conf(j).iline := (others => '0');
      for i in 0 to 5 loop
        pv.conf(j).bar(i) := (others => '0');
        pv.conf(j).pta_map(i) := default_bar_map(j)(i);
        pv.conf(j).bar_mask(i) := (others => '0');
        pv.conf(j).bar_mask(i)(31 downto bar_size(j)(i)) := ones32(31 downto bar_size(j)(i));
        pv.conf(j).bar_mask(i)(3) := bar_prefetch(j)(i);
        pv.conf(j).bar_mask(i)(0) := bar_io(j)(i);
        if bar_size(j)(i) <= 1 then pv.conf(j).bar_mask(i) := (others => '0'); end if;
      end loop;
      pv.conf(j).cfg_map := conv_std_logic_vector(extcfg_vector(j),28) & "0000";
    end loop;
    pv.pta_trans.ca_pcimsten := (others => '0');
    pv.pta_trans.ca_twist := conv_std_logic_vector(conv_endian, 1)(0);

    -- PCI trace
    pv.ptta_trans.enable := '0';
    pv.ptta_trans.armed := '0';
    pv.ptta_trans.start_ack := '0';
    pv.ptta_trans.stop_ack := '0';
    pv.pt.addr := (others => '0');
  end if;

  if pcirst(0) = '0' then
    pv.pta_trans.rst_ack := (others => '0');
  end if;
  

  -- Disabled parts
  if target = 0 then      -- PCI targer disabled
    pv.t := pci_target_none;
    pv.pta_trans.tm_acc := pci_g_acc_trans_none;
    pv.pta_trans.tm_acc_cancel := '0';
    pv.pta_trans.tm_acc_done_ack :=  '0';
    pv.pta_trans.tm_fifo := pci_g_fifo_trans_vector_none;
    pv.pta_trans.tm_fifo_ack := pci_g_fifo_ack_trans_vector_none;
    pv.po.trdy := '1'; pv.po.trdyen := oeoff; pv.po.stop := '1'; pv.po.stopen := oeoff; 
    pv.po.devsel := '1'; pv.po.devsel := oeoff;  
    for j in 0 to multifunc loop
      pv.conf(j).comm.memen := '0';
      pv.conf(j).stat.sta := '0';
      for i in 0 to 5 loop
        pv.conf(j).bar(i) := (others => '0');
      end loop;
      if master /= 0 and confspace = 0 then -- No Configuration Space but PCI master => master enabled
        pv.conf(j).comm.msten := '1'; pv.pta_trans.ca_pcimsten := (others => '1');
      end if;
    end loop;
  end if;

  if master = 0 and dma = 0 then      -- PCI master disabled
    pv.m := pci_master_none;
    pv.pta_trans.msd_acc_ack(0) := '0';
    pv.pta_trans.msd_acc_cancel_ack(0) := (others => '0');
    pv.pta_trans.msd_acc_done(0) := pci_g_acc_status_trans_none;
    pv.pta_trans.msd_fifo(0) := pci_g_fifo_trans_vector_none;
    pv.pta_trans.msd_fifo_ack(0) := pci_g_fifo_ack_trans_vector_none;
    pv.po.irdy := '1'; pv.po.irdyen := oeoff; pv.po.frame := '1'; pv.po.frameen := oeoff; 
    pv.po.req := '1'; pv.po.reqen := oeoff; 
    pv.po.cbe := (others => '0'); pv.po.cbeen := (others => oeoff);
    for j in 0 to multifunc loop
      pv.conf(j).comm.msten := '0'; pv.pta_trans.ca_pcimsten := (others => '0');
      pv.conf(j).comm.mwien := '0';
      pv.conf(j).stat.mdpe := '0';
      pv.conf(j).stat.rta := '0';
      pv.conf(j).stat.rma := '0';
    end loop;
  end if;

  if dma = 0 then         -- DMA disabled
    pv.m.acc(1) := pci_master_acc_none;
    pv.pta_trans.msd_acc_ack(1) := '0';
    pv.pta_trans.msd_acc_cancel_ack(1) := (others => '0');
    pv.pta_trans.msd_acc_done(1) := pci_g_acc_status_trans_none;
    pv.pta_trans.msd_fifo(1) := pci_g_fifo_trans_vector_none;
    pv.pta_trans.msd_fifo_ack(1) := pci_g_fifo_ack_trans_vector_none;
  end if;
  
  if tracebuffer = 0 then -- PCI trace buffer disabled
    pv.pt := pci_trace_none; 
    pv.ptta_trans := pci_trace_to_apb_trans_none;
  end if;

  if dma = 0 and master = 0 and target = 0 then
    pv.po.par := '1'; pv.po.paren := oeoff; pv.po.perr := '1'; pv.po.perren := oeoff; 
    pv.po.serren := oeoff; pv.po.inten := oeoff; pv.po.vinten := (others => oeoff); 
    pv.po.ad := (others => '0'); pv.po.aden := (others => oeoff);
    for j in 0 to multifunc loop
      pv.conf(j).stat.sse := '0';
      pv.conf(j).stat.dpe := '0';
      pv.conf(j).comm.perren := '0';
      pv.conf(j).comm.serren := '0';
    end loop;
  end if;
  -- --------------

  prin <= pv;
 
  
  -- PHY =>
  sig_m_request <= m_request; 
  sig_m_mabort  <= m_mabort; 
  sig_t_abort   <= t_abort;  
  sig_t_ready   <= t_ready;  
  sig_t_retry   <= t_retry;  
  sig_soft_rst  <= pci_hard_rst & pci_master_rst & pci_target_rst;

  all_func_serren := '0';
  for j in 0 to multifunc loop
    all_func_serren := all_func_serren or pr.conf(j).comm.serren;
  end loop;
  sig_pr_conf_comm_serren <= all_func_serren;

  if pr.m.perren /= "00" then
    sig_pr_conf_comm_perren <= pr.conf(pr.m.acc(pr.m.acc_sel).func).comm.perren;
  else
    sig_pr_conf_comm_perren <= pr.conf(pr.t.cur_acc(0).func).comm.perren;
  end if;
  -- PHY <=

  -- Gate PCI target => AHB master pending with pcirst
  pr_pta_trans_gated <= pr.pta_trans;
  pr_pta_trans_gated.tm_acc.pending <= pr.pta_trans.tm_acc.pending and pciasyncrst_comb;

  
end process;
  


acomb : process(ar, rst, pr_pta_trans_gated, dmao0, dmao1, tm_fifoo_pta, ms_fifoo_pta, md_fifoo_ptd, ahbsi, apbi, dirq, pcii.int, pt_fifoo_ad, pt_fifoo_sig, pr.ptta_trans, pcisig, lahbm_rst, lahbs_rst, lahb_rst, iotmact)
variable av       : amba_reg_type;
variable pta_trans: pci_to_ahb_trans_type;
variable first    : std_logic;
variable tm_nindex   : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable tm_acc           : pci_g_acc_trans_type;
variable tm_acc_pending   : std_logic; 
variable tm_acc_done      : std_logic;
variable tm_acc_cancel    : std_logic;
variable tm_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable tm_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable tm_fifo          : pci_g_fifo_trans_vector_type;
-- AHB slave
variable slv_access : std_logic;
variable tb_access  : std_logic;
variable ms_index    : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable blen       : std_logic_vector(15 downto 0);
variable ms_acc_pending   : std_logic;
variable ms_acc_cancel    : std_logic;
variable ms_acc_done      : std_logic;
variable ms_acc_done_status : pci_g_acc_status_trans_type;
variable ms_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable ms_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable ms_fifo          : pci_g_fifo_trans_vector_type;
variable accbufindex      : integer range 0 to 3;
variable ms_func          : std_logic_vector(2 downto 0);
variable ms_vifunc        : integer range 0 to multifunc;
-- APB slave
variable apbaddr    : std_logic_vector(6 downto 2);
variable prdata     : std_logic_vector(31 downto 0);
variable pirq       : std_logic_vector(NAHBIRQ-1 downto 0);
variable c_blenmask_update : std_logic;
variable ptta_trans : pci_trace_to_apb_trans_type;
variable pt_status  : pci_trace_to_apb_trans_type;
-- DMA
variable md_index    : integer range 0 to FIFO_COUNT-1;-- FIFO index
variable md_acc_pending   : std_logic;
variable md_acc_cancel    : std_logic;
variable md_acc_done      : std_logic;
variable md_acc_done_status : pci_g_acc_status_trans_type;
variable md_fifo_pending  : std_logic_vector(FIFO_COUNT-1 downto 0);
variable md_fifo_empty    : std_logic_vector(FIFO_COUNT-1 downto 0);
variable md_fifo          : pci_g_fifo_trans_vector_type;

-- Soft reset
variable pci_master_rst : std_logic;
variable pci_target_rst : std_logic;
variable pci_hard_rst   : std_logic;

-- APB DEBUG
variable tbapbaddr    : std_logic_vector(6 downto 2);
variable tbprdata     : std_logic_vector(31 downto 0);
variable tbpirq       : std_logic_vector(NAHBIRQ-1 downto 0);

begin
  -- --------------------------------------------------------------------------------
  -- AHB global defaults
  -- --------------------------------------------------------------------------------
  
  -- defaults
  av := ar;

  av.irq.access_pirq := '0';
  av.irq.system_pirq := '0';

  -- FIFO and AHB<=>PCI sync
  av.sync(1) := pr_pta_trans_gated; av.sync(2) := ar.sync(1);
  if nsync = 0 then pta_trans := pr_pta_trans_gated;
  else pta_trans := ar.sync(nsync); end if;
  
  -- PCI trace <=> APB sync
  av.apb_sync(1) := pr.ptta_trans; av.apb_sync(2) := ar.apb_sync(1);
  if nsync = 0 then ptta_trans := pr.ptta_trans;
  else ptta_trans := ar.apb_sync(nsync); end if;
  pt_status := pr.ptta_trans;

  if tracebuffer = 0 then  -- PCI trace buffer disabled
    av.atpt_trans.start := '0'; av.atpt_trans.stop := '0'; av.atpt_trans.mode := (others => '0');
    av.atpt_trans.count := (others => '0'); av.atpt_trans.tcount := (others => '0');
    av.atpt_trans.ad := (others => '0'); av.atpt_trans.admask := (others => '0');
    av.atpt_trans.sig := (others => '0'); av.atpt_trans.sigmask := (others => '0');
  else
    if ptta_trans.start_ack = '1' then av.atpt_trans.start := '0'; end if;
    if ptta_trans.stop_ack = '1' then av.atpt_trans.stop := '0'; end if;
  end if;

  -- Soft reset
  if pta_trans.rst_ack(0) = '1' then av.atp_trans.rst(0) := '0'; end if; -- PCI-target/AHB-master reset
  if pta_trans.rst_ack(1) = '1' then av.atp_trans.rst(1) := '0'; end if; -- PCI-master/AHB-slave reset

  pci_target_rst := pta_trans.rst_ack(0) or ar.atp_trans.rst(0);
  pci_master_rst := pta_trans.rst_ack(1) or ar.atp_trans.rst(1);
  pci_hard_rst := ar.atp_trans.rst(2);

  -- --------------------------------------------------------------------------------
  -- AHB master defaults
  -- --------------------------------------------------------------------------------
  
  -- FIFO enable(read)/write
  av.m.acc.fifo_ren := '0';
  av.m.acc.fifo_wen := '0';
  av.m.acc.fifo_wdata := dmao0.data;
  
  av.m.dmai0.noreq := '0';
  
  tm_acc_pending := pta_trans.tm_acc.pending xor ar.atp_trans.tm_acc_ack;
  tm_acc_done := pta_trans.tm_acc_done_ack xor ar.atp_trans.tm_acc_done.done;
  tm_acc_cancel := pta_trans.tm_acc_cancel xor ar.atp_trans.tm_acc_cancel_ack(0);
  -- Stop_ack also needs to be delayed when pending is delayed
  av.atp_trans.tm_acc_cancel_ack(1) := ar.atp_trans.tm_acc_cancel_ack(0);
  av.atp_trans.tm_acc_cancel_ack(2) := ar.atp_trans.tm_acc_cancel_ack(1);
  for i in 0 to FIFO_COUNT-1 loop
    tm_fifo_pending(i) := pta_trans.tm_fifo(i).pending(RAM_LATENCY) xor ar.atp_trans.tm_fifo_ack(i);
    tm_fifo_empty(i) := not (ar.atp_trans.tm_fifo(i).pending(0) xor pta_trans.tm_fifo_ack(i));
    -- To set pending when data is stored in fifo, with this stop_ack also needs to be delayed
    av.atp_trans.tm_fifo(i).pending(1) := ar.atp_trans.tm_fifo(i).pending(0);
    av.atp_trans.tm_fifo(i).pending(2) := ar.atp_trans.tm_fifo(i).pending(1);
  end loop;
  tm_fifo := pr_pta_trans_gated.tm_fifo;
  tm_acc := pr_pta_trans_gated.tm_acc;

  -- --------------------------------------------------------------------------------
  -- AHB master core
  -- --------------------------------------------------------------------------------
  
  if target /= 0 then -- PCI target enabled
    -- Select next fifo
    if ar.m.acc.fifo_index /= FIFO_COUNT-1 then tm_nindex := ar.m.acc.fifo_index + 1;
    else tm_nindex := 0; end if;

    -- latch PCI target access
    if tm_acc_pending = '1' and ar.m.acc.pending = '0' then
      av.atp_trans.tm_acc_ack := pta_trans.tm_acc.pending;
      av.m.acc.pending := '1';
      av.m.acc.addr := tm_acc.addr;
      av.m.acc.mode := tm_acc.accmode;
      av.m.acc.burst := tm_acc.accmode(0);
      av.m.acc.cbe := tm_acc.cbe;
      av.m.acc.endianess := tm_acc.endianess;
      av.m.acc.length := tm_acc.length; 
      av.m.acc.fifo_index := tm_acc.index; 
      av.m.acc.acctype := tm_acc.acctype;
    end if;
    
    -- AHB master state machine
    case ar.m.state is
      when am_idle =>
        av.m.done := (others => '0');
        av.m.stop := '0';
        av.m.dmai0.req := '0';
        av.m.dmai0.burst := '1';
        av.m.dma_hold := '0';
        av.m.active := '0';
        av.m.retry := '0';
        if ar.m.acc.pending = '1' then
          av.m.dmai0.addr := ar.m.acc.addr;
          av.m.dmai0.size := set_size_from_cbe(ar.m.acc.cbe);
          av.m.dmai0.addr(1 downto 0) := set_addr_from_cbe(ar.m.acc.cbe, ar.m.acc.endianess);
          -- Burst length (only burst up to this boundary)
          av.m.blen := ar.m.acc.length; 
          if ar.m.acc.acctype(0) = '1' then  -- Write
            av.m.state := am_write;
            av.m.first := "010";
            av.m.hold := (others => '1');
          elsif ar.m.acc.acctype(0) = '0' then                                    -- Read
            av.m.state := am_read;
            av.m.first := "001";
            av.m.hold := (others => '0');
            av.m.dmai0.write := '0';
            av.m.dmai0.req := '1';

            av.m.acc.fifo_addr := conv_std_logic_vector(ar.m.acc.fifo_index, log2(FIFO_COUNT)) & ar.m.acc.addr(AHB_FIFO_BITS); -- Set fifo start address
            av.m.faddr := av.m.acc.addr(AHB_FIFO_BITS); 
            if ar.m.acc.burst = '0' then
              av.m.dmai0.size := set_size_from_cbe(ar.m.acc.cbe);
              av.m.dmai0.addr(1 downto 0) := set_addr_from_cbe(ar.m.acc.cbe, ar.m.acc.endianess);
              av.m.dmai0.burst := '0'; -- sinlge access
            else
              av.m.dmai0.size := "10";
              av.m.dmai0.addr(1 downto 0) := "00";
            end if;
          end if;
        end if;

        if tm_acc_cancel = '1' then
          av.atp_trans.tm_acc_cancel_ack(0) := pta_trans.tm_acc_cancel;
        end if;
      when am_read =>
        if tm_fifo_empty(ar.m.acc.fifo_index) = '1' and ar.m.hold(0) = '1' and ar.m.done(0) = '0' and ar.m.active = '0' then
          av.m.dmai0.req := '1';
          av.m.hold := (others => '0');
        end if;

        if tm_acc_cancel = '1' then
          av.m.done(2) := '1';
        end if;

        if dmao0.grant = '1' then
          av.m.active := '1';
          av.m.dmai0.addr := ar.m.dmai0.addr + 4;
          if ar.m.blen /= zero32(15 downto 0) then
            av.m.blen := ar.m.blen - 1;
          end if;

          if ar.m.dmai0.addr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) or ar.m.done(2) = '1' or ar.m.acc.burst = '0' then
            if tm_fifo_empty(tm_nindex) = '0' then
              av.m.dmai0.req := '0';
              av.m.hold(0) := '1';
            end if;
            if ar.m.done(2) = '1' or ar.m.acc.burst = '0' or ar.m.blen = zero32(15 downto 0) then
              av.m.dmai0.req := '0';
              av.m.done(1) := '1';
            end if;
          end if;
          
          -- Retry save & restore
          av.m.retry := '0';
          -- Save len for retry
          av.m.retry_blen := ar.m.blen;
          -- Restore len for retry
          if ar.m.retry = '1' then
            av.m.blen := ar.m.retry_blen;
          end if;
        elsif dmao0.retry = '1' then
          av.m.dmai0.req := '1';
          av.m.dmai0.addr := ar.m.dmai0.addr - 4; 
          --av.m.blen := ar.m.blen + 1;
          av.m.done(1) := '0';
          
          -- Retry save & restore
          av.m.retry := '1';
          -- Save len for retry
          av.m.retry_blen := ar.m.blen;
          -- Restore len for retry
          av.m.blen := ar.m.retry_blen;
        end if;
        
        if dmao0.ready = '1' then 
          if dmao0.grant = '0' then av.m.active := '0'; end if;

          if ar.m.faddr(AHB_FIFO_BITS) /= ones32(AHB_FIFO_BITS) and ar.m.done(1) = '0' then
            av.m.faddr(AHB_FIFO_BITS) := ar.m.faddr(AHB_FIFO_BITS) + 1;
          else                                                        -- Last word in fifo
            av.m.faddr(AHB_FIFO_BITS) := (others => '0');
            av.m.acc.fifo_index := tm_nindex; -- Go to next fifo

            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).pending(0) := not ar.atp_trans.tm_fifo(ar.m.acc.fifo_index).pending(0);
            
            if ar.m.first(0) = '1' then  -- Mark first fifo in transfer
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).firstf := '1';
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).start := ar.m.acc.addr(AHB_FIFO_BITS);
              av.m.first(0) := '0';
            else
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).start := (others => '0');
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).firstf := '0';
            end if;
            
            if ar.m.done(1) = '1' then  -- Mark last fifo in transfer
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).lastf := '1';
              av.m.done(0) := '1';
            else
              av.atp_trans.tm_fifo(ar.m.acc.fifo_index).lastf := '0';
            end if;
            
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).stop := ar.m.faddr(AHB_FIFO_BITS);
            
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).status := (others => '0'); -- Not used
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).last_cbe := (others => '0'); -- Not used
          end if;
          av.m.acc.fifo_wen := '1';
          av.m.acc.fifo_addr := conv_std_logic_vector(ar.m.acc.fifo_index, log2(FIFO_COUNT)) & ar.m.faddr(AHB_FIFO_BITS);
        elsif dmao0.error = '1' then
          av.m.active := '0';
          av.m.dmai0.req := '0';
          av.m.done(0) := '1';
          av.m.acc.fifo_index := tm_nindex; -- Go to next fifo

          if ar.m.first(0) = '1' then  -- Mark first fifo in transfer
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).firstf := '1';
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).start := ar.m.acc.addr(AHB_FIFO_BITS);
            av.m.first(0) := '0';
          else
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).firstf := '0';
            av.atp_trans.tm_fifo(ar.m.acc.fifo_index).start := (others => '0');
          end if;
          av.atp_trans.tm_fifo(ar.m.acc.fifo_index).lastf := '1';
          av.atp_trans.tm_fifo(ar.m.acc.fifo_index).stop := ar.m.faddr(AHB_FIFO_BITS);
          av.atp_trans.tm_fifo(ar.m.acc.fifo_index).pending(0) := not ar.atp_trans.tm_fifo(ar.m.acc.fifo_index).pending(0);
            
          av.atp_trans.tm_fifo(ar.m.acc.fifo_index).status(0) := '1';  -- AHB error

          av.m.acc.fifo_wen := '1';
          av.m.acc.fifo_addr := conv_std_logic_vector(ar.m.acc.fifo_index, log2(FIFO_COUNT)) & ar.m.faddr(AHB_FIFO_BITS);
        end if;
         
        -- to deassert req on last address phase 
        if av.m.dmai0.addr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) then av.m.dmai0.noreq := '1'; end if;

        if ar.m.done(2) = '1' and ar.m.active = '0' and dmao0.grant = '0' then
          av.m.dmai0.req := '0';
          av.m.done := (others => '1');
        end if;

        if ar.m.done(0) = '1' then
          av.m.dmai0.req := '0';
          if ar.m.done(2) = '1' or ar.m.acc.burst = '0' then 
            if ar.m.done(2) = '1' then
              for i in 0 to FIFO_COUNT-1 loop
                if tm_fifo_empty(i) = '0' then
                  av.atp_trans.tm_fifo(i).pending(0) := not ar.atp_trans.tm_fifo(i).pending(0);
                else
                  av.atp_trans.tm_fifo(i).pending(0) := ar.atp_trans.tm_fifo(i).pending(0);
                end if;
              end loop;
            end if;
            av.m.state := am_idle;
            av.m.acc.pending := '0';
          end if;
        end if;
      when am_write =>
        av.m.acc.fifo_ren := tm_fifo_pending(ar.m.acc.fifo_index);
        av.m.dmai0.write := '1';
        av.m.first(0) := '0';

        if tm_fifo_pending(ar.m.acc.fifo_index) = '1' and ar.m.hold(0) = '1' and ar.m.active = '0' and ar.m.done(0) = '0' and ar.m.first(2) = '0' then
          av.m.first(0) := '1';
          av.m.first(2) := '1';
          av.m.hold := "000";
          av.m.last := "000";
            
          av.m.acc.fifo_addr := conv_std_logic_vector(ar.m.acc.fifo_index, log2(FIFO_COUNT)) & tm_fifo(ar.m.acc.fifo_index).start; -- Set fifo start address
          av.m.faddr := tm_fifo(ar.m.acc.fifo_index).start; -- Set fifo start address

          if ar.m.first(1) = '1' then
            av.m.first(1) := '0';
          end if;
          
          -- Last access is non-word or first/last is no-data
          if tm_fifo(ar.m.acc.fifo_index).start = tm_fifo(ar.m.acc.fifo_index).stop then
            if ar.m.acc.cbe = ones32(3 downto 0) then
              av.m.done(0) := '1';
              av.m.first(0) := '0';
              av.m.dmai0.req := '0';
              av.m.acc.fifo_index := tm_nindex; -- Go to next fifo
              av.atp_trans.tm_fifo_ack(ar.m.acc.fifo_index) := pta_trans.tm_fifo(ar.m.acc.fifo_index).pending(RAM_LATENCY);
            elsif tm_fifo(ar.m.acc.fifo_index).last_cbe /= ar.m.acc.cbe then
              av.m.dmai0.size := set_size_from_cbe(tm_fifo(ar.m.acc.fifo_index).last_cbe);
              av.m.dmai0.addr(1 downto 0) := set_addr_from_cbe(tm_fifo(ar.m.acc.fifo_index).last_cbe, ar.m.acc.endianess);
              av.m.dmai0.burst := '0';
            end if;
          elsif ar.m.acc.cbe = ones32(3 downto 0) then
            av.m.dmai0.addr := ar.m.dmai0.addr + 4;
            av.m.acc.fifo_addr := conv_std_logic_vector(ar.m.acc.fifo_index, log2(FIFO_COUNT)) & (tm_fifo(ar.m.acc.fifo_index).start + 1); -- Set fifo start address
            av.m.faddr := (tm_fifo(ar.m.acc.fifo_index).start + 1); -- Set fifo start address
          end if;

        end if;

        if ar.m.first(0) = '1' then -- Latch first word in fifo
          av.m.dmai0.req := '1';
          if ar.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) /= tm_fifo(ar.m.acc.fifo_index).stop then
            av.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) :=  ar.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) + 1; 
          else
            av.m.hold(0) := '1';
            if tm_fifo(ar.m.acc.fifo_index).lastf = '1' then 
              av.m.last(0) := '1'; 
              
              if tm_fifo(ar.m.acc.fifo_index).status /= "0000" then
                av.m.done(0) := '1';
                av.m.dmai0.req := '0';
                av.m.acc.fifo_index := tm_nindex; -- Go to next fifo
                av.atp_trans.tm_fifo_ack(ar.m.acc.fifo_index) := pta_trans.tm_fifo(ar.m.acc.fifo_index).pending(RAM_LATENCY);
              end if;
            end if;
          end if;
          av.m.dmai0.data := tm_fifoo_pta.data;
        end if;

        if dmao0.grant = '1' then
          av.m.active := '1';
          av.m.dmai0.addr := ar.m.dmai0.addr + 4;
          av.m.faddr := ar.m.faddr + 1;
          av.m.retry := '0';
          if (ar.m.active = '1' and ar.m.faddr = tm_fifo(ar.m.acc.fifo_index).stop) or ar.m.hold(1 downto 0) /= "00" or ar.m.done(0) = '1' then 
            if (ar.m.active = '1' and (tm_fifo_pending(tm_nindex) = '0' or tm_fifo(ar.m.acc.fifo_index).lastf = '1')) or ar.m.hold(1 downto 0) /= "00" or ar.m.done(0) = '1' then
              av.m.dmai0.req := '0';
              av.m.hold(0) := '1';
              if tm_fifo(ar.m.acc.fifo_index).lastf = '1' then av.m.last(0) := '1'; end if;
            end if;
            if tm_fifo_pending(tm_nindex) = '1' then
              if tm_fifo(tm_nindex).start = tm_fifo(tm_nindex).stop and tm_fifo(tm_nindex).last_cbe = ones32(3 downto 0) then
                av.m.dmai0.req := '0';
                av.m.hold(0) := '1';
              end if;
            end if;
          end if;
       

          -- Last access is non-word
          if av.m.faddr(AHB_FIFO_BITS) = tm_fifo(ar.m.acc.fifo_index).stop and tm_fifo(ar.m.acc.fifo_index).last_cbe /= ar.m.acc.cbe then
            av.m.dmai0.size := set_size_from_cbe(tm_fifo(ar.m.acc.fifo_index).last_cbe);
            av.m.dmai0.addr(1 downto 0) := set_addr_from_cbe(tm_fifo(ar.m.acc.fifo_index).last_cbe, ar.m.acc.endianess);
            av.m.dmai0.burst := '0';
          elsif (tm_fifo(ar.m.acc.fifo_index).lastf = '0' and tm_fifo_pending(tm_nindex) = '1' and
                 av.m.faddr(AHB_FIFO_BITS) = zero32(AHB_FIFO_BITS) and tm_fifo(tm_nindex).stop = zero32(AHB_FIFO_BITS) and 
                 tm_fifo(tm_nindex).last_cbe /= ar.m.acc.cbe) then
            av.m.dmai0.size := set_size_from_cbe(tm_fifo(tm_nindex).last_cbe);
            av.m.dmai0.addr(1 downto 0) := set_addr_from_cbe(tm_fifo(tm_nindex).last_cbe, ar.m.acc.endianess);
            av.m.dmai0.burst := '0';
          end if;
          
          -- Save size and offset for retry
          av.m.retry_size := ar.m.dmai0.size;
          av.m.retry_offset := ar.m.dmai0.addr(1 downto 0);
          
          -- Restore size and offset for retry
          if ar.m.retry = '1' then
            av.m.dmai0.size := ar.m.retry_size;
            av.m.dmai0.addr(1 downto 0) := ar.m.retry_offset;
          end if;
        elsif dmao0.retry = '1' then
          av.m.dmai0.req := '1';
          av.m.dmai0.addr := ar.m.dmai0.addr - 4; 
          av.m.faddr := ar.m.faddr - 1;
          av.m.retry := '1';
          
          -- Save size and offset for retry
          av.m.retry_size := ar.m.dmai0.size;
          av.m.retry_offset := ar.m.dmai0.addr(1 downto 0);
          
          -- Restore size and offset for retry
          av.m.dmai0.size := ar.m.retry_size;
          av.m.dmai0.addr(1 downto 0) := ar.m.retry_offset;
        end if;

        if dmao0.ready = '1' then 
          av.m.first(2) := '0';
          if dmao0.grant = '0' and ar.m.dmai0.req = '0' then av.m.active := '0'; end if;
                
          if ar.m.hold(1 downto 0) = "00" then
            av.m.dmai0.data := tm_fifoo_pta.data;
            av.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) :=  ar.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) + 1; 
          end if;

          if tm_fifo_pending(ar.m.acc.fifo_index) = '1' and ar.m.acc.fifo_addr(FIFO_DEPTH-1 downto 0) = tm_fifo(ar.m.acc.fifo_index).stop and 
             ar.m.hold(1 downto 0) /= "11" and ar.m.done(0) = '0' then
            av.m.acc.fifo_index := tm_nindex; -- Go to next fifo
            av.atp_trans.tm_fifo_ack(ar.m.acc.fifo_index) := pta_trans.tm_fifo(ar.m.acc.fifo_index).pending(RAM_LATENCY);
            av.m.acc.fifo_addr := conv_std_logic_vector(av.m.acc.fifo_index, log2(FIFO_COUNT)) &  tm_fifo(tm_nindex).start; -- Set fifo start address
            
            if tm_fifo_pending(tm_nindex) = '0' or ar.m.hold(0) = '1' then
              av.m.hold(1) := '1';
            end if;
            
            if tm_fifo(ar.m.acc.fifo_index).lastf = '1' or ar.m.last(1 downto 0) /= "00" then  -- Transfer done
              av.m.done(0) := '1'; 
            end if;
          end if;

        elsif dmao0.error = '1' then 
          av.m.active := '0';
          av.m.dmai0.req := '0';
          if ar.m.done(0) = '0' then
            if tm_fifo_pending(ar.m.acc.fifo_index) = '1' and tm_fifo(ar.m.acc.fifo_index).lastf = '1' then
              av.m.acc.fifo_index := tm_nindex; -- Go to next fifo
              av.atp_trans.tm_fifo_ack(ar.m.acc.fifo_index) := pta_trans.tm_fifo(ar.m.acc.fifo_index).pending(RAM_LATENCY);
              av.m.done(0) := '1';
            else
              av.m.state := am_error;
            end if;
          end if;
        end if;

        if ar.m.done(0) = '1' and ar.m.active = '0' then
          av.m.state := am_idle;
          av.m.acc.pending := '0';
        end if;

        if av.m.dmai0.addr(AHB_FIFO_BITS) = tm_fifo(ar.m.acc.fifo_index).stop or ar.m.done(0) = '1' then av.m.dmai0.noreq := '1'; end if; -- to deassert req on last address phase
      when am_error =>
        if tm_fifo_pending(ar.m.acc.fifo_index) = '1' and ar.m.done(0) = '0' then 
          if tm_fifo(ar.m.acc.fifo_index).lastf = '1' then
            av.m.done(0) := '1';
          end if;
          av.m.acc.fifo_index := tm_nindex; -- Go to next fifo
          av.atp_trans.tm_fifo_ack(ar.m.acc.fifo_index) := pta_trans.tm_fifo(ar.m.acc.fifo_index).pending(RAM_LATENCY);
        end if;
        
        if ar.m.done(0) = '1' then
          av.m.state := am_idle;
          av.m.acc.pending := '0';
        end if;
      when others =>
    end case;
  end if; -- PCI target enabled
  
  -- --------------------------------------------------------------------------------
  -- AHB slave defaults
  -- --------------------------------------------------------------------------------
  
  -- Default
  av.s.hready := '1'; slv_access := '0'; tb_access := '0'; av.s.hresp := HRESP_OKAY;
  av.s.retry := '0';
  av.s.atp.ctrl.en := '0';
  av.s.atp.ctrl.data := ahbreadword(ahbsi.hwdata);
  av.s.pta.ctrl.en := '0';
  av.s.stoppciacc := '0';

  ms_acc_pending := ar.atp_trans.msd_acc(0).pending xor pta_trans.msd_acc_ack(0);
  ms_acc_cancel := ar.atp_trans.msd_acc_cancel(0) xor pta_trans.msd_acc_cancel_ack(0)(RAM_LATENCY);
  ms_acc_done := ar.atp_trans.msd_acc_done_ack(0) xor pta_trans.msd_acc_done(0).done;
  for i in 0 to FIFO_COUNT-1 loop
    ms_fifo_pending(i) := pta_trans.msd_fifo(0)(i).pending(RAM_LATENCY) xor ar.atp_trans.msd_fifo_ack(0)(i);
    ms_fifo_empty(i) := not (ar.atp_trans.msd_fifo(0)(i).pending(0) xor pta_trans.msd_fifo_ack(0)(i));
    av.atp_trans.msd_fifo(0)(i).pending(1) := ar.atp_trans.msd_fifo(0)(i).pending(0);
    av.atp_trans.msd_fifo(0)(i).pending(2) := ar.atp_trans.msd_fifo(0)(i).pending(1);
  end loop;
  ms_fifo := pr_pta_trans_gated.msd_fifo(0);
  ms_acc_done_status := pr_pta_trans_gated.msd_acc_done(0);

  accbufindex := 0;

  -- PCI function number
  ms_func := ar.s.atp_map(conv_integer(ar.s.hmaster))(2 downto 0);
  ms_vifunc := conv_integer(ar.s.atp_map(conv_integer(av.s.hmaster))(2 downto 0));
  if multifunc = 0 then ms_func := (others => '0'); ms_vifunc := 0; end if;

  -- --------------------------------------------------------------------------------
  -- AHB slave core
  -- --------------------------------------------------------------------------------

  if master /= 0 then -- PCI master enabled
    if ms_acc_done = '1' then -- Handle PCI error on AHB to PCI write 
      av.atp_trans.msd_acc_done_ack(0) := pta_trans.msd_acc_done(0).done;
      if ms_acc_done_status.status(3) = '1' then -- PCI configuration access done
        av.s.cfg_status(1) := '1';
        if ms_acc_done_status.status(2 downto 0) /= "000" then av.s.cfg_status(0) := '1'; end if;
      else
        if ar.irq.access_en = '1' and ms_acc_done_status.status(2 downto 0) /= "000" then av.irq.access_pirq := '1'; end if;
        av.irq.access_status := ar.irq.access_status or ms_acc_done_status.status(2 downto 0);
      end if;
    end if;

    -- Select next fifo
    if ar.s.state = as_write then
      if ar.s.atp.index /= FIFO_COUNT-1 then ms_index := ar.s.atp.index + 1;
      else ms_index := 0; end if;
    else
      if ar.s.pta.index /= FIFO_COUNT-1 then ms_index := ar.s.pta.index + 1;
      else ms_index := 0; end if;
    end if;

    -- Access buffer
    if ms_acc_pending = '0' and ar.s.accbuf(0).pending = '1' then
      av.atp_trans.msd_acc(0) := ar.s.accbuf(0);
      av.atp_trans.msd_acc(0).pending := not ar.atp_trans.msd_acc(0).pending;
      av.s.accbuf(0) := ar.s.accbuf(1);
      av.s.accbuf(1) := ar.s.accbuf(2);
      av.s.accbuf(2) := ar.s.accbuf(3);
      av.s.accbuf(3).pending := '0';
    end if;

    -- Set prefetch burst length
    blen := x"00" & ar.s.blen;

    -- AHB access latchning
    if (ahbsi.hready and ahbsi.hsel(hsindex) and ahbsi.htrans(1)) = '1' then
        slv_access := '1';
        av.s.haddr := ahbsi.haddr; av.s.hwrite := ahbsi.hwrite; 
        av.s.hsel := ahbsi.hsel(hsindex); av.s.hmbsel := ahbsi.hmbsel(0 to 2);
        av.s.htrans := ahbsi.htrans; av.s.hsize := ahbsi.hsize;
        av.s.hburst := ahbsi.hburst(0);
        av.s.hmaster := ahbsi.hmaster;
    end if;
    -- PCI trace buffer access
    if tracebuffer /= 0 then
      if (ahbsi.hsel(hsindex) and ahbsi.hmbsel(1) and ahbsi.haddr(17) and ahbsi.htrans(1)) = '1' then
        tb_access := '1';
      end if;
    end if;


    -- Second retry/error cycle
    if ar.s.retry = '1' then 
      if ar.s.hresp = HRESP_ERROR then
        av.s.hresp := HRESP_ERROR; 
      else
        av.s.hresp := HRESP_RETRY; 
        if ar.s.pending = "00" and ar.s.hwrite = '0' and ar.s.start = '0' and ar.s.stoppciacc = '0' then 
          av.s.pending := "01";
          av.s.addr := ar.s.haddr;
          av.s.write := ar.s.hwrite;
          av.s.master := ar.s.hmaster;
          av.s.burst := ar.s.hburst;
          av.s.size := ar.s.hsize;
          av.s.config := (not ar.s.hmbsel(0) and ar.s.haddr(16));
          av.s.io := (not ar.s.hmbsel(0) and not ar.s.haddr(16));
          av.s.pta.ctrl.addr := conv_std_logic_vector(ar.s.pta.index, log2(FIFO_COUNT)) & ar.s.haddr(AHB_FIFO_BITS);

          -- Change to sigle access on PCI IO and PCI CONF
          if ar.s.io_cfg_burst(0) = '0' and av.s.config = '1' then av.s.burst := '0'; end if;
          if ar.s.io_cfg_burst(1) = '0' and av.s.io = '1' then av.s.burst := '0'; end if;
          
          -- Use blen if less than 1k limit and AHB-master is unmasked, else use 1k limit
          if (not av.s.addr(9 downto 2)) < ar.s.blen(7 downto 0) or ar.s.blenmask(conv_integer(av.s.master)) = '0' then blen(7 downto 0) := (not av.s.addr(9 downto 2)); end if;

          if ar.s.continue = '0' then
            if ar.s.hmbsel(0) = '0' then  -- config access and io access 
              if ar.s.haddr(16) = '1' then
                av.s.addr := set_pci_conf_addr(ar.s.haddr, ar.s.cfg_bus);
              else av.s.addr := set_pci_io_addr(ar.s.haddr, ar.s.io_map); end if;
            else
              av.s.addr := set_atp_addr(ar.s.haddr, ar.s.atp_map, ar.s.hmaster, AADDR_WIDTH);
            end if;
            
            if ms_acc_pending = '0' and ar.s.accbuf(0).pending = '0' then
              av.atp_trans.msd_acc(0).pending := not ar.atp_trans.msd_acc(0).pending;
              av.atp_trans.msd_acc(0).addr := av.s.addr;
              av.atp_trans.msd_acc(0).func := ms_func; -- set PCI function
              if av.s.config = '1' then av.atp_trans.msd_acc(0).acctype := CONF_READ;
              elsif av.s.io = '1' then av.atp_trans.msd_acc(0).acctype := IO_READ;
              else 
                if av.s.burst = '1' then av.atp_trans.msd_acc(0).acctype := MEM_R_MULT;
                else  av.atp_trans.msd_acc(0).acctype := MEM_READ; end if;
              end if;
              av.atp_trans.msd_acc(0).accmode := av.s.burst & '1' & av.s.burst; 
              av.atp_trans.msd_acc(0).size := av.s.size;
              av.atp_trans.msd_acc(0).offset := ar.s.haddr(1 downto 0);
              av.atp_trans.msd_acc(0).index := ar.s.pta.index;
              av.atp_trans.msd_acc(0).length := blen;
              av.atp_trans.msd_acc(0).cbe := (others => '0'); -- not used
              av.atp_trans.msd_acc(0).endianess := '0'; -- not used
            else
              accbufindex := 0;
              for i in 3 downto 0 loop
                if av.s.accbuf(i).pending = '0' then accbufindex := i; end if;
              end loop;
              av.s.accbuf(accbufindex).pending := '1';
              av.s.accbuf(accbufindex).addr := av.s.addr;
              av.s.accbuf(accbufindex).func := ms_func; -- set PCI function
              if av.s.config = '1' then av.s.accbuf(accbufindex).acctype := CONF_READ;
              elsif av.s.io = '1' then av.s.accbuf(accbufindex).acctype := IO_READ;
              else 
                if av.s.burst = '1' then av.s.accbuf(accbufindex).acctype := MEM_R_MULT;
                else av.s.accbuf(accbufindex).acctype := MEM_READ; end if;
              end if;
              av.s.accbuf(accbufindex).accmode := av.s.burst & '1' & av.s.burst; 
              av.s.accbuf(accbufindex).size := av.s.size;
              av.s.accbuf(accbufindex).offset := ar.s.haddr(1 downto 0);
              av.s.accbuf(accbufindex).index := ar.s.pta.index;
              av.s.accbuf(accbufindex).length := blen;
              av.s.accbuf(accbufindex).cbe := (others => '0'); -- not used
              av.s.accbuf(accbufindex).endianess := '0'; -- not used
            end if;
          end if;
        end if;
      end if;
    end if;

    if ms_fifo_pending(ar.s.pta.index) = '1' and ar.s.pending = "01" and ar.s.discard = '0' then
      av.s.done_fifo := (others => '0');
      av.s.pending := "10";
      av.s.pta.ctrl.addr := conv_std_logic_vector(ar.s.pta.index, log2(FIFO_COUNT)) & ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0); 
    elsif ar.s.pending = "10" then
      av.s.pending := "11";
      av.s.pta.ctrl.addr := conv_std_logic_vector(ar.s.pta.index, log2(FIFO_COUNT)) &  (ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0) + 1);  
      av.s.hrdata := ms_fifoo_pta.data;
      if ms_fifo(ar.s.pta.index).start = ms_fifo(ar.s.pta.index).stop then 
        av.s.oneword := '1'; 
        av.s.pta.ctrl.addr := conv_std_logic_vector(ar.s.pta.index, log2(FIFO_COUNT)) & ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0); 
        if ms_fifo_pending(ms_index) = '0' then av.s.done_fifo(0) := '1'; end if;
        if ms_fifo(ar.s.pta.index).lastf = '1' then av.s.done_fifo(1) := '1'; end if;
      else av.s.oneword := '0'; end if;
    end if;

    -- FIFO read enable
    av.s.pta.ctrl.en := ms_fifo_pending(ar.s.pta.index);

    -- Discard unused fifo data
    if ar.s.discard = '1' then
      if ms_acc_cancel = '0' then 
        -- moved to PCI master
        av.s.discard := '0';
      end if;
    end if;

    -- AHB slave state machine
    case ar.s.state is
      when as_idle =>
        av.s.continue := '0';
        av.s.first := '1';
        av.s.firstf := '1';
        av.s.tb_ren := '0';
        if slv_access = '1' then
          if tb_access = '1' then -- PCI trace
            av.s.hready := '0';
            av.s.state := as_pcitrace;
            av.s.tb_ren := '1';
          else
            if av.s.hwrite = '1' and ms_fifo_empty(ar.s.atp.index) = '1' and 
               pta_trans.ca_pcimsten(ms_vifunc) = '1' and (pci_hard_rst or pci_master_rst) = '0' then -- Write
              av.s.state := as_write;
            elsif ar.s.pending(1) = '1' and ar.s.master = ahbsi.hmaster and 
                  (pci_hard_rst or pci_master_rst) = '0' then                                  -- Read
              if (ms_fifo(ar.s.pta.index).status(2 downto 1) /= "00" and 
                  ms_fifo(ar.s.pta.index).start = ms_fifo(ar.s.pta.index).stop) or  -- Master/Target abort
                 (ms_fifo(ar.s.pta.index).status(0) = '1') then                     -- PAR error
                if ar.s.config = '1' then           -- Master/target abort during PCI config access
                  av.s.state := as_read;
                  av.s.cfg_status := "11";
                else
                  if ar.s.erren = '1' and ms_fifo(ar.s.pta.index).status(2 downto 1) /= "00" and 
                     ms_fifo(ar.s.pta.index).start = ms_fifo(ar.s.pta.index).stop then
                    av.s.hready := '0';
                    av.s.hresp := HRESP_ERROR;
                    av.s.retry := '1';
                  end if;
                  if ar.s.parerren = '1' and ms_fifo(ar.s.pta.index).status(0) = '1' then
                    av.s.hready := '0';
                    av.s.hresp := HRESP_ERROR;
                    av.s.retry := '1';
                  end if;
                  if ar.s.burst = '1' then
                    av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
                    av.s.discard := '1';
                  else
                    av.s.pta.index := ms_index; -- Go to next fifo
                    av.atp_trans.msd_fifo_ack(0)(ar.s.pta.index) := pta_trans.msd_fifo(0)(ar.s.pta.index).pending(RAM_LATENCY);
                  end if;
                  av.s.pending := (others => '0');
                  if ar.irq.access_en = '1' then av.irq.access_pirq := '1'; end if; -- If enabled, generate irq on error
                  av.irq.access_status := ar.irq.access_status or ms_fifo(ar.s.pta.index).status(2 downto 0); -- Update irq status
                end if;
              else 
                if ar.s.config = '1' then av.s.cfg_status(1) := '1'; end if;
                av.s.state := as_read;
              end if;
            elsif ms_fifo_empty(ar.s.atp.index) = '1' and pta_trans.ca_pcimsten(ms_vifunc) = '0' and 
                  (pci_hard_rst or pci_master_rst) = '0' then
              av.s.state := as_checkpcimst;
              av.s.hready := '0';
            elsif (pci_hard_rst or pci_master_rst) = '1' then           -- Error during reset
              av.s.hresp := HRESP_ERROR;
              av.s.hready := '0';
              av.s.retry := '1';
            else                                                        -- Retry
              av.s.hresp := HRESP_RETRY;
              av.s.hready := '0';
              av.s.retry := '1';
            end if;
          end if;
        end if;
      when as_checkpcimst =>
        if ar.s.hmbsel(0) = '0' and ar.s.haddr(16) = '1' and 
           ((ar.s.haddr(15 downto 11) = zero32(15 downto 11) and pta_trans.ca_host = '0') or ar.s.fakehost = '1') then
          if ar.s.hwrite = '1' then
            av.s.state := as_write;
          else
            av.s.hresp := HRESP_RETRY;
            av.s.hready := '0';
            av.s.retry := '1';
            av.s.state := as_idle;
          end if;
        else
          av.s.hresp := HRESP_ERROR;
          av.s.hready := '0';
          av.s.retry := '1';
          av.s.state := as_idle;
        end if;
      when as_read =>
        av.s.pending := (others => '0');
        if ar.s.hready = '1' then

          if ar.s.htrans(1) = '1' then
            if ms_fifo_pending(ar.s.pta.index) = '1' then
              if ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0) = ms_fifo(ar.s.pta.index).stop or ar.s.burst = '0' or ar.s.oneword = '1' then
                av.s.pta.index := ms_index; -- Go to next fifo
                av.atp_trans.msd_fifo_ack(0)(ar.s.pta.index) := pta_trans.msd_fifo(0)(ar.s.pta.index).pending(RAM_LATENCY);
                if ms_fifo_pending(ms_index) = '0' then av.s.done_fifo(0) := '1'; end if;
                if ms_fifo(ar.s.pta.index).lastf = '1' then av.s.done_fifo(1) := '1'; end if;
              end if;
            end if;
            av.s.hrdata := ms_fifoo_pta.data;
            av.s.pta.ctrl.addr := conv_std_logic_vector(av.s.pta.index, log2(FIFO_COUNT)) &  (ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0) + 1); 
          end if;

          if ahbsi.htrans(1) = '1' and ahbsi.hsel(hsindex) = '1' then
            if ahbsi.htrans(0) = '0' then 
              if ahbsi.hwrite = '1' and ms_fifo_empty(ar.s.atp.index) = '1' then      -- new write access
                av.s.state := as_write;
                if ar.s.burst = '1' then
                  av.s.discard := '1';
                  av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
                end if;
              else                                                              -- retry
                av.s.hready := '0';
                av.s.hresp := HRESP_RETRY;
                av.s.retry := '1';
                av.s.state := as_idle;
                if ar.s.burst = '1' then
                  av.s.discard := '1';
                  av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
                end if;
              end if;
            end if;

            if ms_fifo_pending(ar.s.pta.index) = '1' and 
               ((ms_fifo(ar.s.pta.index).status(2 downto 1) /= "00" and                       -- Master/Target abort
                 ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0) = ms_fifo(ar.s.pta.index).stop) or
                 (ms_fifo(ar.s.pta.index).status(0) = '1')) then                              -- PAR error
              if ar.s.config = '1' then -- No AHB error for PCI Config Space
                av.s.cfg_status := "11";
                av.s.hready := '0';
                av.s.hresp := HRESP_RETRY;
                av.s.retry := '1';
              else
                if ar.s.erren = '1' and ms_fifo(ar.s.pta.index).status(2 downto 1) /= "00" and 
                   ar.s.pta.ctrl.addr(FIFO_DEPTH-1 downto 0) = ms_fifo(ar.s.pta.index).stop then
                  av.s.hready := '0';
                  av.s.hresp := HRESP_ERROR;
                  av.s.retry := '1';
                end if;
                if ar.s.parerren = '1' and ms_fifo(ar.s.pta.index).status(0) = '1' then
                  av.s.hready := '0';
                  av.s.hresp := HRESP_ERROR;
                  av.s.retry := '1';
                end if;
                av.irq.access_status := ar.irq.access_status or ms_fifo(ar.s.pta.index).status(2 downto 0); -- Update irq status
                if ar.irq.access_en = '1' then av.irq.access_pirq := '1'; end if; -- If enabled, generate irq on error
              end if;
              av.s.state := as_idle;
              if ar.s.burst = '1' then
                av.s.discard := '1';
                av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
              end if;
            elsif (ahbsi.hwrite = '0' and ar.s.done_fifo(0) = '1') or ar.s.burst = '0' or ar.s.oneword = '1' then -- no pending fifo => retry
              av.s.hready := '0';
              av.s.hresp := HRESP_RETRY;
              av.s.retry := '1';
              av.s.stoppciacc := not pta_trans.ca_pcimsten(ms_vifunc);
              if ar.s.burst = '1' and ahbsi.htrans(0) = '1'  then 
                if ar.s.done_fifo(1) = '1' then
                  av.s.discard := '1';
                  av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
                else
                  av.s.continue := '1'; -- Only for continuing  bursts
                end if;
              end if;
              av.s.state := as_idle;
            end if;

          elsif ahbsi.hsel(hsindex) = '0' or ahbsi.htrans(0) = '0' then -- idle
            av.s.state := as_idle;
            if ar.s.burst = '1' then
              av.s.discard := '1';
              av.atp_trans.msd_acc_cancel(0) := not ar.atp_trans.msd_acc_cancel(0);
            end if;
          end if;

        end if;
      when as_write =>
        av.s.first := '0';
        if ar.s.first = '1' then -- Store fifo start address
          if ar.s.hmbsel(0) = '0' then  -- mem/io/config access  
            if ar.s.haddr(16) = '1' then 
              av.s.addr := set_pci_conf_addr(ar.s.haddr, ar.s.cfg_bus);
              av.s.offset := ar.s.haddr(1 downto 0);
            else av.s.addr := set_pci_io_addr(ar.s.haddr, ar.s.io_map); end if;
          else
            av.s.addr := set_atp_addr(ar.s.haddr, ar.s.atp_map, ar.s.hmaster, AADDR_WIDTH);
          end if;
          av.s.size := ar.s.hsize;
          av.s.config := (not ar.s.hmbsel(0) and ar.s.haddr(16));
          av.s.io := (not ar.s.hmbsel(0) and not ar.s.haddr(16));
          if ms_acc_pending = '0' and ar.s.accbuf(0).pending = '0' then
            av.atp_trans.msd_acc(0).pending := not ar.atp_trans.msd_acc(0).pending;
            av.atp_trans.msd_acc(0).addr := av.s.addr;
            av.atp_trans.msd_acc(0).func := ms_func; -- set PCI function
            if av.s.config = '1' then av.atp_trans.msd_acc(0).acctype := CONF_WRITE;
            elsif av.s.io = '1' then av.atp_trans.msd_acc(0).acctype := IO_WRITE;
            else av.atp_trans.msd_acc(0).acctype := MEM_WRITE; end if;
            av.atp_trans.msd_acc(0).accmode := "00" & ar.s.hburst; 
            av.atp_trans.msd_acc(0).size := av.s.size;
            av.atp_trans.msd_acc(0).offset := ar.s.haddr(1 downto 0);
            av.atp_trans.msd_acc(0).index := ar.s.atp.index;
            av.atp_trans.msd_acc(0).length := (others => '0'); -- not used
            av.atp_trans.msd_acc(0).cbe := (others => '0'); -- not used
            av.atp_trans.msd_acc(0).endianess := '0'; -- not used
          else
            accbufindex := 0;
            for i in 3 downto 0 loop
              if av.s.accbuf(i).pending = '0' then accbufindex := i; end if;
            end loop;
            av.s.accbuf(accbufindex).pending := '1';
            av.s.accbuf(accbufindex).addr := av.s.addr;
            av.s.accbuf(accbufindex).func := ms_func; -- set PCI function
            if av.s.config = '1' then av.s.accbuf(accbufindex).acctype := CONF_WRITE;
            elsif av.s.io = '1' then av.s.accbuf(accbufindex).acctype := IO_WRITE;
            else av.s.accbuf(accbufindex).acctype := MEM_WRITE; end if;
            av.s.accbuf(accbufindex).accmode := "00" & ar.s.hburst; 
            av.s.accbuf(accbufindex).size := av.s.size;
            av.s.accbuf(accbufindex).offset := ar.s.haddr(1 downto 0);
            av.s.accbuf(accbufindex).index := ar.s.atp.index;
            av.s.accbuf(accbufindex).length := (others => '0'); -- not used
            av.s.accbuf(accbufindex).cbe := (others => '0'); -- not used
            av.s.accbuf(accbufindex).endianess := '0'; -- not used
          end if;

        end if;
        if ar.s.hready = '1' then
          if ar.s.htrans(1) = '1' then
            if ar.s.haddr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) or ahbsi.htrans(0) = '0' then
              av.s.firstf := '0';
              av.s.atp.index := ms_index; -- Go to next fifo
              av.atp_trans.msd_fifo(0)(ar.s.atp.index).pending(0) := not ar.atp_trans.msd_fifo(0)(ar.s.atp.index).pending(0);
              if ar.s.firstf = '1' then
                av.atp_trans.msd_fifo(0)(ar.s.atp.index).start := av.s.addr(AHB_FIFO_BITS);
                av.atp_trans.msd_fifo(0)(ar.s.atp.index).firstf := '1';
              else
                av.atp_trans.msd_fifo(0)(ar.s.atp.index).start := (others => '0');
                av.atp_trans.msd_fifo(0)(ar.s.atp.index).firstf := '0';
              end if;
              av.atp_trans.msd_fifo(0)(ar.s.atp.index).stop := ar.s.haddr(AHB_FIFO_BITS);
              av.atp_trans.msd_fifo(0)(ar.s.atp.index).lastf := not ahbsi.htrans(0) or not ms_fifo_empty(ms_index);
              av.atp_trans.msd_fifo(0)(ar.s.atp.index).status := (others => '0'); -- Not used
              av.atp_trans.msd_fifo(0)(ar.s.atp.index).last_cbe := (others => '0'); -- Not used
            end if;

            av.s.atp.ctrl.en := '1';
            av.s.atp.ctrl.addr := conv_std_logic_vector(ar.s.atp.index, log2(FIFO_COUNT)) & ar.s.haddr(AHB_FIFO_BITS);
          end if;
          
          if ahbsi.htrans(1) = '1' and ahbsi.hsel(hsindex) = '1' then
            if ahbsi.htrans(0) = '0' then 
              if ahbsi.hwrite = '1' and ms_fifo_empty(ms_index) = '1' then             -- new write access
                av.s.first := '1';
                av.s.firstf := '1';
              else                                                              -- retry
                av.s.hready := '0';
                av.s.hresp := HRESP_RETRY;
                av.s.retry := '1';
                av.s.state := as_idle;
              end if;
            end if;
            if ahbsi.hwrite = '1' and ar.s.haddr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) and ms_fifo_empty(ms_index) = '0' then -- no empty fifo => retry
              av.s.hready := '0';
              av.s.hresp := HRESP_RETRY;
              av.s.retry := '1';
              av.s.state := as_idle;
            end if;
          elsif ahbsi.hsel(hsindex) = '0' or ahbsi.htrans(0) = '0' then -- idle
            av.s.state := as_idle;
          end if;
        end if;
      when as_pcitrace =>
        if ar.s.hready = '1' then
          if tb_access = '1' then
            av.s.hready := '0';
            av.s.tb_ren := '1';
          else
            av.s.state := as_idle;
            if ahbsi.htrans(1) = '1' and ahbsi.hsel(hsindex) = '1' then
              av.s.hready := '0';
              av.s.retry := '1';
              av.s.hresp := HRESP_RETRY;
            end if;
          end if;
        else
          av.s.tb_ren := '0';
          if ar.s.tb_ren = '0' then
            av.s.hready := '1';
            if ar.s.haddr(16) = '0' then 
              av.s.hrdata := pt_fifoo_ad.data;
            else
              av.s.hrdata := zero32(31 downto 20) & pt_fifoo_sig.data(16 downto 0) & "000";
            end if;
          else
            av.s.hready := '0';
          end if;
        end if;
      when others =>
    end case;
  end if; -- PCI master enabled

  -- --------------------------------------------------------------------------------
  -- DMA defaults
  -- --------------------------------------------------------------------------------
  av.dma.irq := '0';
  -- FIFO enable(read)/write
  av.dma.ptd.ctrl.en := '0';
  av.dma.dtp.ctrl.en := '0';
  av.dma.dtp.ctrl.data := dmao1.data;
  
  av.dma.dmai1.noreq := '0';
  
  av.dma.desc.addr(3 downto 0) := (others => '0');  
  
  md_acc_pending := ar.atp_trans.msd_acc(1).pending xor pta_trans.msd_acc_ack(1);
  md_acc_cancel := ar.atp_trans.msd_acc_cancel(1) xor pta_trans.msd_acc_cancel_ack(1)(RAM_LATENCY);
  md_acc_done := ar.atp_trans.msd_acc_done_ack(1) xor pta_trans.msd_acc_done(1).done;
  for i in 0 to FIFO_COUNT-1 loop
    md_fifo_pending(i) := pta_trans.msd_fifo(1)(i).pending(RAM_LATENCY) xor ar.atp_trans.msd_fifo_ack(1)(i);
    md_fifo_empty(i) := not (ar.atp_trans.msd_fifo(1)(i).pending(0) xor pta_trans.msd_fifo_ack(1)(i));
    av.atp_trans.msd_fifo(1)(i).pending(1) := ar.atp_trans.msd_fifo(1)(i).pending(0);
    av.atp_trans.msd_fifo(1)(i).pending(2) := ar.atp_trans.msd_fifo(1)(i).pending(1);
  end loop;
  md_fifo := pr_pta_trans_gated.msd_fifo(1);
  md_acc_done_status := pr_pta_trans_gated.msd_acc_done(1);

  -- --------------------------------------------------------------------------------
  -- DMA core
  -- --------------------------------------------------------------------------------
  
  if dma /= 0 then -- DMA enabled
    -- Select next fifo
    if ar.dma.state = dma_read then
      if ar.dma.dtp.index /= FIFO_COUNT-1 then md_index := ar.dma.dtp.index + 1;
      else md_index := 0; end if;
    else
      if ar.dma.ptd.index /= FIFO_COUNT-1 then md_index := ar.dma.ptd.index + 1;
      else md_index := 0; end if;
    end if;

    case ar.dma.state is
      when dma_idle =>
        av.dma.err := (others => '0');
        av.dma.running := '0';
        av.dma.dmai1.req := '0';
        av.dma.dmai1.write := '0';
        av.dma.dmai1.burst := '1';
        av.dma.dmai1.addr := ar.dma.desc.addr;
        av.dma.desc.chcnt := ar.dma.numch;
        if ar.dma.errstatus /= "00000" then
          av.dma.en := '0';
        elsif ar.dma.en = '1' then
          av.dma.state := dma_read_desc;
          av.dma.rcnt := (others => '0');
          av.dma.dmai1.req := '1';
          av.dma.dmai1.size := "10";
          av.dma.running := '1';
        end if;
      when dma_read_desc =>
        av.dma.active := '0';
        av.dma.dma_hold := (others => '0');
        av.dma.done := (others => '0');
        av.dma.first(0) := '1';
        av.dma.retry := '0';

        if ar.dma.rcnt = "11" and ar.dma.desc.desctype /= "01" 
           and (ar.dma.desc.emptych = '0' or ar.dma.desc.chcnt = "000") then av.dma.dmai1.req := '0';
        else av.dma.dmai1.req := '1'; end if;
        av.dma.dmai1.burst := '1';
        if dmao1.grant = '1' then
          av.dma.dmai1.addr := ar.dma.dmai1.addr + 4;
          if ar.dma.dmai1.addr(3 downto 2) = "11" then
            if ar.dma.desc.desctype = "01" then
              av.dma.dmai1.addr := dmao1.data;
            elsif ar.dma.desc.emptych = '1' then
              av.dma.desc.addr := ar.dma.desc.nextch;
              av.dma.dmai1.addr := ar.dma.desc.nextch;
              if ar.dma.desc.chcnt = "000" then
                av.dma.dmai1.req := '0';
              end if;
            else
              av.dma.dmai1.req := '0';
            end if;
          end if;
        elsif dmao1.retry = '1' then
          av.dma.dmai1.addr := ar.dma.dmai1.addr - 4; 
        end if;

        if av.dma.dmai1.addr(3 downto 2) = "11" then av.dma.dmai1.noreq := '1'; end if;

        if dmao1.ready = '1' then
          av.dma.err := (others => '0');
          av.dma.rcnt := ar.dma.rcnt + 1;
          case ar.dma.rcnt is
            when "00" =>  -- Ctrl
              av.dma.desc.en := dmao1.data(31);
              av.dma.desc.irqen := dmao1.data(30);
              av.dma.desc.write := dmao1.data(29);
              av.dma.desc.tw := dmao1.data(28);
              av.dma.desc.cio := dmao1.data(27 downto 26);
              av.dma.desc.acctype := dmao1.data(25 downto 22);
              av.dma.desc.desctype := dmao1.data(21 downto 20);
              -- dmao1.data(19) = err
              av.dma.desc.len := dmao1.data(15 downto 0); 
            when "01" =>  -- PCI address / Next DMA CH
              if ar.dma.desc.desctype = "01" then
                av.dma.desc.ch := ar.dma.desc.addr;
                av.dma.desc.nextch := dmao1.data;
                av.dma.desc.cnt := ar.dma.desc.len; 
                av.dma.desc.chid := ar.dma.desc.acctype(2 downto 0);
                av.dma.desc.emptych := '1';
              else
                if ar.dma.desc.en = '1' then
                  av.dma.desc.emptych := '0';
                end if;
                av.dma.desc.paddr := dmao1.data; 
              end if;
            when "10" =>  -- AHB address / Next desc
              if ar.dma.desc.desctype = "01" then
                av.dma.desc.addr := dmao1.data;
              else
                av.dma.desc.aaddr := dmao1.data; 
              end if;
            when "11" =>  -- Next desc / ----
              if ar.dma.desc.en = '1' then
                if ar.dma.desc.desctype = "00" then
                  av.dma.desc.chcnt := ar.dma.numch;
                  av.dma.desc.nextdesc := dmao1.data;
                  if ar.dma.desc.write = '1' then -- AHB read => PCI write
                    av.dma.state := dma_read;
                    av.dma.dmai1.req := '1';
                    av.dma.dmai1.write := '0';
                    av.dma.dmai1.addr := ar.dma.desc.aaddr;
                    if ar.dma.desc.len /= x"0000" then av.dma.dmai1.burst := '1'; 
                    else av.dma.dmai1.burst := '0'; end if;
                    av.dma.dmai1.size := "10"; -- 32-bit access -- add support for unaligned accesses
                    av.dma.dtp.ctrl.addr := conv_std_logic_vector(ar.dma.dtp.index, log2(FIFO_COUNT)) & ar.dma.desc.aaddr(AHB_FIFO_BITS); -- Set fifo start address
                    av.dma.faddr := ar.dma.desc.aaddr(AHB_FIFO_BITS);
                    av.dma.len := (others => '0');
                    av.dma.errlen := (others => '0');
                  else                            -- PCI read => AHB write 
                    av.dma.state := dma_write;
                    av.dma.first := "010";
                    av.dma.dma_hold := "111";
                    av.dma.addr := ar.dma.desc.aaddr;
                    av.dma.len := (others => '0');
                    av.dma.errlen := (others => '0');
                  end if;
                  -- Setup access [Read and Write]
                    av.atp_trans.msd_acc(1).pending := not ar.atp_trans.msd_acc(1).pending;
                    av.atp_trans.msd_acc(1).addr := ar.dma.desc.paddr;
                    av.atp_trans.msd_acc(1).func := "000"; -- DMA uses PCI function 0
                    if ar.dma.desc.write = '1' then -- AHB read => PCI write
                      av.atp_trans.msd_acc(1).index := ar.dma.dtp.index;
                      if ar.dma.desc.cio = "01" then    -- PCI IO access
                        av.atp_trans.msd_acc(1).acctype := IO_WRITE;
                      elsif ar.dma.desc.cio = "01" then -- PCI Configuration access
                        av.atp_trans.msd_acc(1).acctype := CONF_WRITE;
                      else                              -- PCI Memory access
                        av.atp_trans.msd_acc(1).acctype := MEM_WRITE;
                      end if;
                    else
                      av.atp_trans.msd_acc(1).index := ar.dma.ptd.index;
                      if ar.dma.desc.cio = "01" then    -- PCI IO access
                        av.atp_trans.msd_acc(1).acctype := IO_READ;
                      elsif ar.dma.desc.cio = "01" then -- PCI Configuration access
                        av.atp_trans.msd_acc(1).acctype := CONF_READ;
                      else                              -- PCI Memory access
                        if ar.dma.desc.len /= x"0000" then
                          av.atp_trans.msd_acc(1).acctype := MEM_R_MULT;
                        else
                          av.atp_trans.msd_acc(1).acctype := MEM_READ;
                        end if;
                      end if;
                    end if;
                    if ar.dma.desc.len /= x"0000" then
                      av.atp_trans.msd_acc(1).accmode := "011"; 
                    else
                      av.atp_trans.msd_acc(1).accmode := "010"; 
                    end if;
                    av.atp_trans.msd_acc(1).size := "010"; -- add size support
                    av.atp_trans.msd_acc(1).offset := ar.dma.desc.paddr(1 downto 0);
                    av.atp_trans.msd_acc(1).length := ar.dma.desc.len;
                    av.atp_trans.msd_acc(1).cbe := (others => '0'); -- not used
                    av.atp_trans.msd_acc(1).endianess := av.dma.desc.tw;
                end if;
              else  
                if ar.dma.desc.emptych = '0' then
                  av.dma.state := dma_next_channel;
                  av.dma.dmai1.req := '1';
                  av.dma.dmai1.write := '1';
                  av.dma.dmai1.burst := '0';
                  av.dma.dmai1.addr := ar.dma.desc.ch + 8;
                  av.dma.dmai1.data := ar.dma.desc.nextdesc;
                else
                  if ar.dma.desc.chcnt = "000" then
                    av.dma.en := '0';
                    av.dma.state := dma_idle;
                  else
                    av.dma.desc.chcnt := ar.dma.desc.chcnt - 1;
                  end if;

                end if;
              end if;
            when others =>
          end case;
        elsif dmao1.error = '1' then
          av.dma.en := '0';
          av.dma.state := dma_idle;
          av.dma.dmai1.req := '0';
          av.dma.irq := '1'; av.dma.irqstatus(0) := '1';
          av.dma.errstatus(0) := '1';
        end if;

      when dma_next_channel =>
        if dmao1.grant = '1' then
          av.dma.dmai1.req := '0';
        elsif dmao1.retry = '1' then
          av.dma.dmai1.req := '1';
        end if;

        if dmao1.ready = '1' then
            av.dma.state := dma_read_desc;
            av.dma.dmai1.req := '1';
            av.dma.dmai1.write := '0';
            av.dma.dmai1.burst := '1';
            av.dma.desc.addr := ar.dma.desc.nextch;
            av.dma.dmai1.addr := ar.dma.desc.nextch;
        elsif dmao1.error = '1' then
          av.dma.en := '0';
          av.dma.state := dma_idle;
          av.dma.dmai1.req := '0';
          av.dma.irq := '1'; av.dma.irqstatus(0) := '1';
        end if;

      when dma_write_status =>
        if dmao1.grant = '1' then
          if ar.dma.desc.cnt = x"0001" then -- Next Channel
            av.dma.dmai1.addr := ar.dma.desc.ch + 8;
          else
            av.dma.dmai1.req := '0';
          end if;
        elsif dmao1.retry = '1' then
            av.dma.dmai1.req := '1';
            av.dma.dmai1.addr := ar.dma.desc.addr;
        end if;

        if dmao1.ready = '1' then
          if ar.dma.err /= "000" then
            av.dma.en := '0';
            av.dma.state := dma_idle;
            av.dma.irq := '1'; av.dma.irqstatus(0) := '1';
          else
            if ar.dma.desc.irqen = '1' then 
              av.dma.irq := '1'; 
              av.dma.irqstatus(1) := '1';
              av.dma.irqch(conv_integer(ar.dma.desc.chid)) := '1';
            end if;
            if ar.dma.en = '0' then -- DMA disabled
              av.dma.state := dma_idle;
              av.dma.desc.addr := ar.dma.desc.nextdesc;
            else
              if ar.dma.desc.cnt = x"0001" then -- Next Channel
                av.dma.state := dma_next_channel;
                av.dma.dmai1.req := '1';
                av.dma.dmai1.write := '1';
                av.dma.dmai1.burst := '0';
                av.dma.dmai1.data := ar.dma.desc.nextdesc;
              else                              -- Next Desc
                if ar.dma.desc.cnt /= x"0000" then
                  av.dma.desc.cnt := av.dma.desc.cnt - 1; 
                end if;
                av.dma.state := dma_read_desc;
                av.dma.dmai1.req := '1';
                av.dma.dmai1.write := '0';
                av.dma.dmai1.burst := '1';
                av.dma.desc.addr := ar.dma.desc.nextdesc;
                av.dma.dmai1.addr := ar.dma.desc.nextdesc;
              end if;
            end if;
          end if;
        elsif dmao1.error = '1' then
          av.dma.en := '0';
          av.dma.state := dma_idle;
          av.dma.dmai1.req := '0';
          av.dma.irq := '1'; av.dma.irqstatus(0) := '1';
          av.dma.errstatus(0) := '1';
        end if;

      when dma_read => -- AHB read => PCI write 
        
        if md_fifo_empty(ar.dma.dtp.index) = '1' and ar.dma.dma_hold(0) = '1' and ar.dma.done(0) = '0' and ar.dma.active = '0' then
          av.dma.dmai1.req := '1';
          av.dma.dma_hold(1 downto 0) := "00";
        end if;

        if dmao1.grant = '1' then
          av.dma.active := '1';
          av.dma.dmai1.addr := ar.dma.dmai1.addr + 4;
          if ar.dma.len /= ar.dma.desc.len then
            av.dma.len := ar.dma.len + 1;
          end if;

          if ar.dma.dmai1.addr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) or ar.dma.len = ar.dma.desc.len then
            if md_fifo_empty(md_index) = '0' then
              av.dma.dmai1.req := '0';
              av.dma.dma_hold(0) := '1';
            end if;
            if ar.dma.len = ar.dma.desc.len then
              av.dma.dmai1.req := '0';
              av.dma.done(1) := '1';
            end if;
          end if;
          
          -- Retry save & restore
          av.dma.retry := '0';
          -- Save len for retry
          av.dma.retry_len := ar.dma.len;
          -- Restore len for retry
          if ar.dma.retry = '1' then
            av.dma.len := ar.dma.retry_len;
          end if;
        elsif dmao1.retry = '1' then
          av.dma.dmai1.req := '1';
          av.dma.dmai1.addr := ar.dma.dmai1.addr - 4; 
          --av.dma.len := ar.dma.len - 1;
          av.dma.done(1) := '0';
          
          -- Retry save & restore
          av.dma.retry := '1';
          -- Save len for retry
          av.dma.retry_len := ar.dma.len;
          -- Restore len for retry
          av.dma.len := ar.dma.retry_len;
        end if;

        if dmao1.ready = '1' then 
          if ar.dma.errlen /= ar.dma.desc.len then
            av.dma.errlen := ar.dma.errlen + 1;
          end if;
          if dmao1.grant = '0' then av.dma.active := '0'; end if;
          if ar.dma.faddr(AHB_FIFO_BITS) /= ones32(AHB_FIFO_BITS) and ar.dma.done(1) = '0' then   -- Store data in fifo
            av.dma.faddr(AHB_FIFO_BITS) := ar.dma.faddr(AHB_FIFO_BITS) + 1;
          else                                                        -- Last word in fifo
            av.dma.faddr(AHB_FIFO_BITS) := (others => '0');
            av.dma.dtp.index := md_index; -- Go to next fifo

            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).pending(0) := not ar.atp_trans.msd_fifo(1)(ar.dma.dtp.index).pending(0);
            
            if ar.dma.first(0) = '1' then  -- Mark first fifo in transfer
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).firstf := '1';
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).start := ar.dma.desc.aaddr(AHB_FIFO_BITS);
              av.dma.first(0) := '0';
            else
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).start := (others => '0');
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).firstf := '0';
            end if;
            
            if ar.dma.done(1) = '1' then  -- Mark last fifo in transfer
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).lastf := '1';
              av.dma.done(0) := '1';
            else
              av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).lastf := '0';
            end if;
            
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).stop := ar.dma.faddr(AHB_FIFO_BITS);
            
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).status := (others => '0'); -- Not used
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).last_cbe := (others => '0'); -- Not used
          end if;
          av.dma.dtp.ctrl.en := '1';
          av.dma.dtp.ctrl.addr := conv_std_logic_vector(ar.dma.dtp.index, log2(FIFO_COUNT)) & ar.dma.faddr(AHB_FIFO_BITS);
        elsif dmao1.error = '1' then
          av.dma.active := '0';
          av.dma.dmai1.req := '0';
          av.dma.done(0) := '1';
          av.dma.err(0) := '1';
          av.dma.dtp.index := md_index; -- Go to next fifo

          if ar.dma.first(0) = '1' then  -- Mark first fifo in transfer
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).firstf := '1';
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).start := ar.dma.desc.aaddr(AHB_FIFO_BITS);
            av.dma.first(0) := '0';
          else
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).firstf := '0';
            av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).start := (others => '0');
          end if;
          av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).lastf := '1';
          av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).stop := ar.dma.faddr(AHB_FIFO_BITS);
          av.atp_trans.msd_fifo(1)(ar.dma.dtp.index).pending(0) := not ar.atp_trans.msd_fifo(1)(ar.dma.dtp.index).pending(0);

          av.dma.dtp.ctrl.en := '1';
          av.dma.dtp.ctrl.addr := conv_std_logic_vector(ar.dma.dtp.index, log2(FIFO_COUNT)) & ar.dma.faddr(AHB_FIFO_BITS);
        end if;
         
       
        if av.dma.dmai1.addr(AHB_FIFO_BITS) = ones32(AHB_FIFO_BITS) or av.dma.len = ar.dma.desc.len then av.dma.dmai1.noreq := '1'; end if; -- to deassert req on last address phase
        
        if ar.dma.done(0) = '1' then
          av.dma.dmai1.req := '0';
          if md_acc_done = '1' then
            av.atp_trans.msd_acc_done_ack(1) := not ar.atp_trans.msd_acc_done_ack(1);
            av.dma.state := dma_write_status;
            av.dma.dmai1.req := '1';
            av.dma.dmai1.write := '1';
            av.dma.dmai1.burst := '0';
            av.dma.dmai1.addr := ar.dma.desc.addr;
            av.dma.dmai1.data := (others => '0');
            av.dma.dmai1.data(30) := ar.dma.desc.irqen;
            av.dma.dmai1.data(29) := ar.dma.desc.write;
            av.dma.dmai1.data(28) := ar.dma.desc.tw;
            av.dma.dmai1.data(21 downto 20) := ar.dma.desc.desctype;
            if ar.dma.err(0) = '1' then
              av.dma.dmai1.data(19) := '1';
              av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
              av.dma.errstatus(1) := '1';
            elsif md_acc_done_status.status /= "0000" then
              av.dma.err(2) := '1';
              av.dma.dmai1.data(19) := '1';
              av.dma.dmai1.data(15 downto 0) := md_acc_done_status.count;
              av.dma.errstatus(4 downto 2) := md_acc_done_status.status(2 downto 0);
            else
              av.dma.dmai1.data(19) := '0';
              av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
            end if;
          end if;
        end if;

      when dma_write => -- PCI read => AHB write
        av.dma.ptd.ctrl.en := md_fifo_pending(ar.dma.ptd.index);
        av.dma.dmai1.write := '1';
        av.dma.first(0) := '0';

        if md_fifo_pending(ar.dma.ptd.index) = '1' and ar.dma.dma_hold(0) = '1' and ar.dma.active = '0' and ar.dma.done(0) = '0' and ar.dma.first(2) = '0' then
          av.dma.first(0) := '1';
          av.dma.first(2) := '1';
          av.dma.dma_hold := "000";
          av.dma.dma_last := "000";
          av.dma.newfifo := '0';
            
          av.dma.ptd.ctrl.addr := conv_std_logic_vector(ar.dma.ptd.index, log2(FIFO_COUNT)) & md_fifo(ar.dma.ptd.index).start; -- Set fifo start address
          av.dma.faddr := md_fifo(ar.dma.ptd.index).start; -- Set fifo start address

          if ar.dma.first(1) = '1' then
            av.dma.first(1) := '0';
            av.dma.dmai1.addr := ar.dma.addr;
            av.dma.dmai1.size := "10"; 
            av.dma.dmai1.addr(1 downto 0) := "00"; 
          end if;
        end if;

        if ar.dma.first(0) = '1' then -- Latch first word in fifo
          av.dma.dmai1.req := '1';
          if ar.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) /= md_fifo(ar.dma.ptd.index).stop then
            av.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) :=  ar.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) + 1; 
          else
            av.dma.dma_hold(0) := '1';
            if md_fifo(ar.dma.ptd.index).lastf = '1' then 
              av.dma.dma_last(0) := '1'; 
              
              if md_fifo(ar.dma.ptd.index).status /= "0000" then
                av.dma.done(0) := '1';
                av.dma.dmai1.req := '0';
                av.dma.err(2) := '1'; -- PCI error
                av.dma.errlen := ar.dma.errlen;
                av.dma.ptd.index := md_index; -- Go to next fifo
                av.atp_trans.msd_fifo_ack(1)(ar.dma.ptd.index) := pta_trans.msd_fifo(1)(ar.dma.ptd.index).pending(RAM_LATENCY);
                av.dma.errstatus(4 downto 2) := md_fifo(ar.dma.ptd.index).status(2 downto 0);
              end if;
            end if;
          end if;
          av.dma.dmai1.data := md_fifoo_ptd.data;
        end if;

        if dmao1.grant = '1' then
          av.dma.active := '1';
          av.dma.newfifo := '0';
          av.dma.dmai1.addr := ar.dma.dmai1.addr + 4;
          av.dma.faddr := ar.dma.faddr + 1;
          if (ar.dma.active = '1' and ar.dma.faddr = md_fifo(ar.dma.ptd.index).stop) or ar.dma.dma_hold(1 downto 0) /= "00" or ar.dma.done(0) = '1' then 
            if (ar.dma.active = '1' and md_fifo_pending(md_index) = '0') or ar.dma.dma_hold(1 downto 0) /= "00" or ar.dma.done(0) = '1' then
              av.dma.dmai1.req := '0';
              av.dma.dma_hold(0) := '1';
            end if;
          end if;
        elsif dmao1.retry = '1' then
          av.dma.dmai1.req := '1';
          av.dma.dmai1.addr := ar.dma.dmai1.addr - 4; 
          av.dma.faddr := ar.dma.faddr - 1;
        end if;

        if dmao1.ready = '1' then 
          av.dma.first(2) := '0';
          if ar.dma.errlen /= ar.dma.desc.len then
            av.dma.errlen := ar.dma.errlen + 1;
          end if;
          
          if dmao1.grant = '0' and ar.dma.dmai1.req = '0' then av.dma.active := '0'; end if;
                
          if ar.dma.dma_hold(1 downto 0) = "00" then
            av.dma.dmai1.data := md_fifoo_ptd.data;
            av.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) :=  ar.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) + 1; 
          end if;

          if md_fifo_pending(ar.dma.ptd.index) = '1' and ar.dma.ptd.ctrl.addr(FIFO_DEPTH-1 downto 0) = md_fifo(ar.dma.ptd.index).stop and 
             ar.dma.dma_hold(1 downto 0) /= "11" and ar.dma.done(0) = '0' then
            av.dma.ptd.index := md_index; -- Go to next fifo
            av.atp_trans.msd_fifo_ack(1)(ar.dma.ptd.index) := pta_trans.msd_fifo(1)(ar.dma.ptd.index).pending(RAM_LATENCY);
            av.dma.ptd.ctrl.addr := conv_std_logic_vector(av.dma.ptd.index, log2(FIFO_COUNT)) &  md_fifo(md_index).start; -- Set fifo start address
            
            if md_fifo_pending(md_index) = '0' or ar.dma.dma_hold(0) = '1' then
              av.dma.dma_hold(1) := '1';
            end if;
            
            if md_fifo(ar.dma.ptd.index).lastf = '1' or ar.dma.dma_last(1 downto 0) /= "00" then  -- Transfer done
              av.dma.done(0) := '1'; 
              if md_fifo(ar.dma.ptd.index).status /= "0000" then
                av.dma.err(2) := '1'; -- PCI error
                av.dma.errlen := ar.dma.errlen;
                av.dma.errstatus(4 downto 2) := md_fifo(ar.dma.ptd.index).status(2 downto 0);
              end if;
            end if;
          end if;

        elsif dmao1.error = '1' then 
          av.dma.err(0) := '1';
          av.dma.errstatus(1) := '1';
          av.dma.active := '0';
          av.dma.dmai1.req := '0';
          if ar.dma.done(0) = '0' then
            if md_fifo_pending(ar.dma.ptd.index) = '1' and md_fifo(ar.dma.ptd.index).lastf = '1' then
              av.dma.ptd.index := md_index; -- Go to next fifo
              av.atp_trans.msd_fifo_ack(1)(ar.dma.ptd.index) := pta_trans.msd_fifo(1)(ar.dma.ptd.index).pending(RAM_LATENCY);
              av.dma.done(0) := '1';
            else
              av.dma.state := dma_error;
            end if;
          end if;
        end if;

        if ar.dma.done(0) = '1' and ar.dma.active = '0' then
          av.dma.state := dma_write_status;
          av.dma.dmai1.req := '1';
          av.dma.dmai1.write := '1';
          av.dma.dmai1.burst := '0';
          av.dma.dmai1.addr := ar.dma.desc.addr;
          av.dma.dmai1.data := (others => '0');
          av.dma.dmai1.data(30) := ar.dma.desc.irqen;
          av.dma.dmai1.data(29) := ar.dma.desc.write;
          av.dma.dmai1.data(28) := ar.dma.desc.tw;
          av.dma.dmai1.data(21 downto 20) := ar.dma.desc.desctype;
          if ar.dma.err(0) = '1' or ar.dma.err(2) = '1' then
            av.dma.dmai1.data(19) := '1';
            av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
          else
            av.dma.dmai1.data(19) := '0';
            av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
          end if;
        end if;

        if av.dma.dmai1.addr(AHB_FIFO_BITS) = md_fifo(ar.dma.ptd.index).stop or ar.dma.done(0) = '1' then av.dma.dmai1.noreq := '1'; end if; -- to deassert req on last address phase

      when dma_error => -- Wait for last fifo
        if md_fifo_pending(ar.dma.ptd.index) = '1' and ar.dma.done(0) = '0' then 
          if md_fifo(ar.dma.ptd.index).lastf = '1' then
            av.dma.done(0) := '1';
          end if;
          av.dma.ptd.index := md_index; -- Go to next fifo
          av.atp_trans.msd_fifo_ack(1)(ar.dma.ptd.index) := pta_trans.msd_fifo(1)(ar.dma.ptd.index).pending(RAM_LATENCY);
        end if;
        
        if ar.dma.done(0) = '1' then
          av.dma.state := dma_write_status;
          av.dma.dmai1.req := '1';
          av.dma.dmai1.write := '1';
          av.dma.dmai1.burst := '0';
          av.dma.dmai1.addr := ar.dma.desc.addr;
          av.dma.dmai1.data := (others => '0');
          av.dma.dmai1.data(30) := ar.dma.desc.irqen;
          av.dma.dmai1.data(29) := ar.dma.desc.write;
          av.dma.dmai1.data(28) := ar.dma.desc.tw;
          av.dma.dmai1.data(21 downto 20) := ar.dma.desc.desctype;
          if ar.dma.err(0) = '1' or ar.dma.err(2) = '1' then
            av.dma.dmai1.data(19) := '1';
            av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
          else
            av.dma.dmai1.data(19) := '0';
            av.dma.dmai1.data(15 downto 0) := ar.dma.errlen;
          end if;
        end if;
      when others =>
    end case;
  end if; -- DMA enabled
  
  -- --------------------------------------------------------------------------------
  -- IRQ
  -- --------------------------------------------------------------------------------
  pirq := (others => '0');
  
  -- PCI device driving PCI INTA
  if deviceirq = 1 then
    pciinten(0) <= oeoff xor (ar.irq.device_mask(0) and (ar.irq.device_force or dirq(0)));
    pciinten(1) <= oeoff xor (ar.irq.device_mask(1) and (ar.irq.device_force or dirq(1)));
    pciinten(2) <= oeoff xor (ar.irq.device_mask(2) and (ar.irq.device_force or dirq(2)));
    pciinten(3) <= oeoff xor (ar.irq.device_mask(3) and (ar.irq.device_force or dirq(3)));
  else
    av.irq.device_mask  := (others => '0');
    av.irq.device_force := '0';
    pciinten <= (others => oeoff); 
  end if;

  -- PCI host sampling PCI INTA..D
  if hostirq = 1 then
    av.irq.host_pirq_vl :=   (pcii.int(3) or not ar.irq.host_mask(3)) 
                           & (pcii.int(2) or not ar.irq.host_mask(2))
                           & (pcii.int(1) or not ar.irq.host_mask(1))
                           & (pcii.int(0) or not ar.irq.host_mask(0));
    av.irq.host_pirq_l := not (    av.irq.host_pirq_vl(0) and av.irq.host_pirq_vl(1)
                               and av.irq.host_pirq_vl(2) and av.irq.host_pirq_vl(3));
    av.irq.host_status :=   pcii.int(3) 
                          & pcii.int(2)
                          & pcii.int(1)
                          & pcii.int(0);
  else
    av.irq.host_mask   := (others => '0');
    av.irq.host_status := (others => '0');
    av.irq.host_pirq_vl:= (others => '0');
    av.irq.host_pirq_l := '0';
  end if;

  -- System error irq (SERR)
  if pta_trans.pa_serr = '1' and ar.atp_trans.pa_serr_rst = '1' then
    av.irq.system_status(0) := '0';
    av.atp_trans.pa_serr_rst := '0';
  elsif pta_trans.pa_serr = '0' then
    av.irq.system_status(0) := '1';
    if ar.irq.system_en = '1' and ar.irq.system_status(0) = '0' then
      av.irq.system_pirq := '1';
    end if;
  end if;
  -- System error irq (Discard time out)
  if pta_trans.pa_discardtout = '0' and ar.atp_trans.pa_discardtout_rst = '1' then
    av.irq.system_status(1) := '0';
    av.atp_trans.pa_discardtout_rst := '0';
  elsif pta_trans.pa_discardtout = '1' then
    av.irq.system_status(1) := '1';
    if ar.irq.system_en = '1' and ar.irq.system_status(1) = '0' then
      av.irq.system_pirq := '1';
    end if;
  end if;

  -- Level IRQ
  av.irq.system_pirq_l := ar.irq.system_en and orv(ar.irq.system_status);
  av.irq.access_pirq_l := ar.irq.access_en and orv(ar.irq.access_status);
  av.irq.dma_pirq_l := ar.dma.irqen and orv(ar.dma.irqstatus);

  if irqmode = 0 then     -- PCI INTA..D, Error irq and DMA irq on the same interrupt
    pirq(irq) := ar.irq.host_pirq_l or ar.irq.access_pirq_l or ar.irq.dma_pirq_l or ar.irq.system_pirq_l; -- All level irq 
  elsif irqmode = 1 then  -- PCI INTA..D and Error irq on the same interrupt. DMA irq no next interrupt
    pirq(irq) := ar.irq.host_pirq_l or ar.irq.access_pirq_l or ar.irq.system_pirq_l;
    pirq(irq+1) := (ar.dma.irqen and ar.dma.irq);                                           
  elsif irqmode = 2 then  -- PCI INTA..D on separate interrupt, Error irq and DMA irq on first interrupt
    pirq(irq) := not ar.irq.host_pirq_vl(0) or ar.irq.access_pirq_l or ar.irq.dma_pirq_l or ar.irq.system_pirq_l;
    pirq(irq+1) := not ar.irq.host_pirq_vl(1);
    pirq(irq+2) := not ar.irq.host_pirq_vl(2);
    pirq(irq+3) := not ar.irq.host_pirq_vl(3);
  else --if irqmode = 3 then  -- PCI INTA..D on separate interrupt, Error irq on first interrupt, DMA irq on interrupt after PCI INTD
    pirq(irq) := not ar.irq.host_pirq_vl(0) or ar.irq.access_pirq_l or ar.irq.system_pirq_l;
    pirq(irq+1) := not ar.irq.host_pirq_vl(1);
    pirq(irq+2) := not ar.irq.host_pirq_vl(2);
    pirq(irq+3) := not ar.irq.host_pirq_vl(3);
    pirq(irq+4) := (ar.dma.irqen and ar.dma.irq);
  end if;

  -- --------------------------------------------------------------------------------
  -- APB Slave
  -- --------------------------------------------------------------------------------
  av.apb_pt_stat := zero32(15 downto PT_DEPTH) & pt_status.taddr 
                    & pt_status.armed & ptta_trans.enable & pt_status.wrap & "0" 
                    & conv_std_logic_vector(PT_DEPTH, 8)  
                    & "00" & ar.atpt_trans.stop & ar.atpt_trans.start;
  av.debug_pr := pr.debug;
  av.apb_pr_conf_0_pta_map := pr.conf(0).pta_map;

  prdata := (others => '0');
  apbaddr := apbi.paddr(6 downto 2);
  if iotest/=0 and iotmact='0' then av.debuga(5 downto 0) := "000000"; end if;
  if (apbi.psel(pindex) and apbi.penable) = '1' then
    if apbi.paddr(7) = '0' then -- PCI core and DMA
      case apbaddr is
        when "00000" => -- 0x00 Control
          prdata(31 downto 29) := ar.atp_trans.rst(2 downto 0);
          prdata(          28) := '0';
          prdata(          27) := ar.irq.system_en;
          prdata(          26) := ar.s.parerren;
          prdata(          25) := ar.s.erren;
          prdata(          24) := ar.irq.access_en;
          prdata(23 downto 16) := ar.s.cfg_bus;
          prdata(15 downto 12) := (others => '0'); -- RESERVED
          prdata(          11) := ar.atp_trans.mstswdis;
          prdata(10 downto  9) := ar.s.io_cfg_burst;
          prdata(           8) := ar.irq.device_force;
          prdata( 7 downto  4) := ar.irq.device_mask;
          prdata( 3 downto  0) := ar.irq.host_mask;
          if apbi.pwrite = '1' then
             av.atp_trans.rst(2)  := apbi.pwdata(31);
             av.atp_trans.rst(1 downto 0) := ar.atp_trans.rst(1 downto 0) or apbi.pwdata(30 downto 29);
             av.irq.system_en     := apbi.pwdata(          27);
             av.s.parerren        := apbi.pwdata(          26);
             av.s.erren           := apbi.pwdata(          25);
             av.irq.access_en     := apbi.pwdata(          24);
             av.s.cfg_bus         := apbi.pwdata(23 downto 16);
             --                     := apbi.pwdata(15 downto  12);
             av.atp_trans.mstswdis:= apbi.pwdata(          11);
             av.s.io_cfg_burst    := apbi.pwdata(10 downto  9);
             av.irq.device_force  := apbi.pwdata(           8);
             av.irq.device_mask   := apbi.pwdata( 7 downto  4);
             av.irq.host_mask     := apbi.pwdata( 3 downto  0);
          end if;
        when "00001" => -- 0x04 Status
          prdata(31) := (pta_trans.ca_host and not ar.s.fakehost);
          prdata(30) := conv_std_logic(master/=0);
          prdata(29) := conv_std_logic(target/=0);
          prdata(28) := conv_std_logic(dma/=0);
          prdata(27) := conv_std_logic(deviceirq/=0);
          prdata(26) := conv_std_logic(hostirq/=0);
          prdata(25 downto 24) := conv_std_logic_vector(irqmode, 2);
          prdata(23) := conv_std_logic(tracebuffer/=0);
          prdata(22 downto 22) := (others => '0'); -- RESERVED
          prdata(          21) := ar.s.fakehost;
          prdata(20 downto 19) := ar.s.cfg_status;
          prdata(18 downto 17) := ar.irq.system_status;
          prdata(16 downto 12) := ar.dma.irqstatus & ar.irq.access_status;
          prdata(11 downto  8) := ar.irq.host_status;
          prdata( 7 downto  5) := (others => '0');-- conv_std_logic_vector(dma_fifo_depth, 2);
          prdata( 4 downto  2) := conv_std_logic_vector(fifo_depth, 3);
          prdata( 1 downto  0) := conv_std_logic_vector(fifo_count, 2);
          if apbi.pwrite = '1' then
             av.s.fakehost := ar.s.fakehost xor apbi.pwdata(21);
             av.s.cfg_status(0) := ar.s.cfg_status(0) and not (apbi.pwdata(20) or apbi.pwdata(19)); -- Clear cfg_status
             av.s.cfg_status(1) := ar.s.cfg_status(1) and not (apbi.pwdata(20) or apbi.pwdata(19)); -- Clear cfg_status
             av.atp_trans.pa_discardtout_rst := ar.atp_trans.pa_discardtout_rst or apbi.pwdata(18);
             av.atp_trans.pa_serr_rst := ar.atp_trans.pa_serr_rst or apbi.pwdata(17);
             av.dma.irqstatus := ar.dma.irqstatus and not apbi.pwdata(16 downto 15);
             av.irq.access_status := ar.irq.access_status and not apbi.pwdata(14 downto 12);
          end if;
        when "00010" => -- 0x08 AHB slave burst lenght and AHB-master mask
          if apbi.pwrite = '1' then
            av.s.blen := apbi.pwdata(7 downto 0);
            av.s.blenmask := apbi.pwdata(31 downto 16);
          end if;
          prdata(31 downto 0) := ar.s.blenmask & zero32(15 downto 8) & ar.s.blen;
        when "00011" => -- 0x0c AHB to PCI IO map
          if apbi.pwrite = '1' then
            av.s.io_map := apbi.pwdata(31 downto 16);
          end if;
          prdata(31 downto 0) := ar.s.io_map & zero32(15 downto 0);
        when "00100" => -- 0x10 DMA Control
          if apbi.pwrite = '1' then
            av.dma.irqch := ar.dma.irqch and not apbi.pwdata(19 downto 12);
            av.dma.errstatus := ar.dma.errstatus and not apbi.pwdata(11 downto 7);
            if apbi.pwdata(31) = '1' then -- Safety guard for update of control fields
              av.dma.numch := apbi.pwdata(6 downto 4);
              av.dma.irqen := apbi.pwdata(1);
            end if;
            av.dma.en := (ar.dma.en and not apbi.pwdata(2)) or apbi.pwdata(0); -- bit[2] = disable/stop bit[0] = enable/start
          end if;
          prdata(31) := '1'; 
          prdata(30 downto 0) := (others => '0'); 
          prdata(19 downto 12) := ar.dma.irqch;
          prdata(11 downto 7) := ar.dma.errstatus;
          prdata(6 downto 4) := ar.dma.numch;
          prdata(3) := ar.dma.running;
          prdata(2) := '0';
          prdata(1) := ar.dma.irqen;
          prdata(0) := ar.dma.en;
        when "00101" => -- 0x14 DMA Data desc
          if apbi.pwrite = '1' then
            av.dma.desc.addr(31 downto 4) := apbi.pwdata(31 downto 4);
          end if;
          prdata(31 downto 0) := ar.dma.desc.addr; 
        when "00110" => -- 0x18 DMA Channel desc
          prdata(31 downto 0) := ar.dma.desc.ch; 
        when "00111" => -- 0x1c Reserved
          prdata(31 downto 0) := ar.debuga; 
          if apbi.pwrite = '1' then
            av.debuga := apbi.pwdata;
          end if;
        when "01000" => -- 0x20 PCI BAR0 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(0);
        when "01001" => -- 0x24 PCI BAR1 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(1);
        when "01010" => -- 0x28 PCI BAR2 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(2);
        when "01011" => -- 0x2c PCI BAR3 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(3);
        when "01100" => -- 0x30 PCI BAR4 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(4);
        when "01101" => -- 0x34 PCI BAR5 to AHB map (read only)
          prdata(31 downto 0) := ar.apb_pr_conf_0_pta_map(5);
        when "01110" => -- 0x38 Reserved 
          --prdata(31 downto 0) := (others => '0'); 
          prdata := ar.debug;
        when "01111" => -- 0x3c Reserved
          --prdata(31 downto 0) := (others => '0'); 
          prdata := ar.debug_pr;
        when "10000" => -- 0x40 AHB master00 to PCI map 
          if apbi.pwrite = '1' then
            av.s.atp_map(0)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(0)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(0);
        when "10001" => -- 0x44 AHB master01 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(1)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(1)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(1);
        when "10010" => -- 0x48 AHB master02 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(2)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(2)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(2);
        when "10011" => -- 0x4c AHB master03 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(3)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(3)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(3);
        when "10100" => -- 0x50 AHB master04 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(4)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(4)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(4);
        when "10101" => -- 0x54 AHB master05 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(5)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(5)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(5);
        when "10110" => -- 0x58 AHB master06 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(6)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(6)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(6);
        when "10111" => -- 0x5c AHB master07 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(7)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(7)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(7);
        when "11000" => -- 0x60 AHB master08 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(8)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(8)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(8);
        when "11001" => -- 0x64 AHB master09 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(9)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(9)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(9);
        when "11010" => -- 0x68 AHB master10 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(10)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(10)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(10);
        when "11011" => -- 0x6c AHB master11 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(11)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(11)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(11);
        when "11100" => -- 0x70 AHB master12 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(12)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(12)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(12);
        when "11101" => -- 0x74 AHB master13 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(13)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(13)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(13);
        when "11110" => -- 0x78 AHB master14 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(14)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(14)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(14);
        when "11111" => -- 0x7c AHB master15 to PCI map
          if apbi.pwrite = '1' then
            av.s.atp_map(15)(31 downto 3) := (others => '0');
            if AADDR_WIDTH /= 4 then
              av.s.atp_map(15)(31 downto AADDR_WIDTH) := apbi.pwdata(31 downto AADDR_WIDTH);
            end if;
          end if;
          prdata(31 downto 0) := ar.s.atp_map(15);
        when others =>
          prdata(31 downto 0) := (others => '0'); 
      end case;
    elsif tracebuffer /= 0 then  -- PCI trace buffer enabled
      case apbaddr is
        when "00000" => -- 0x80 PCI trace control & status
          if apbi.pwrite = '1' then
            av.atpt_trans.start := ar.atpt_trans.start or apbi.pwdata(0);
            av.atpt_trans.stop := ar.atpt_trans.stop or apbi.pwdata(1);
          end if;
          prdata(31 downto 0) := ar.apb_pt_stat;
        when "00001" => -- 0x84 PCI trace count & mode
          if apbi.pwrite = '1' then
            av.atpt_trans.mode := apbi.pwdata(27 downto 24);
            av.atpt_trans.tcount := apbi.pwdata(23 downto 16);
            av.atpt_trans.count := apbi.pwdata(PT_DEPTH-1 downto 0);
          end if;
          prdata(31 downto 0) := x"0" & ar.atpt_trans.mode & ar.atpt_trans.tcount & zero32(15 downto PT_DEPTH) & ar.atpt_trans.count;
        when "00010" => -- 0x88 PCI trace AD pattern
          if apbi.pwrite = '1' then
            av.atpt_trans.ad := apbi.pwdata;
          end if;
          prdata(31 downto 0) := ar.atpt_trans.ad;
        when "00011" => -- 0x8c PCI trace AD mask
          if apbi.pwrite = '1' then
            av.atpt_trans.admask := apbi.pwdata;
          end if;
          prdata(31 downto 0) := ar.atpt_trans.admask;
        when "00100" => -- 0x90 PCI trace Signal pattern
          if apbi.pwrite = '1' then
            av.atpt_trans.sig := apbi.pwdata(19 downto 3);
          end if;
          prdata(31 downto 0) := x"000" & ar.atpt_trans.sig & "000";
        when "00101" => -- 0x94 PCI trace Signal mask
          if apbi.pwrite = '1' then
            av.atpt_trans.sigmask := apbi.pwdata(19 downto 3);
          end if;
          prdata(31 downto 0) := x"000" & ar.atpt_trans.sigmask & "000";
        when "00110" => -- 0x98 PCI AD
          prdata(31 downto 0) := ptta_trans.dbg_ad;
        when "00111" => -- 0x9c PCI Ctrl signal
          prdata(19 downto 0) := ptta_trans.dbg_sig & "000";
          prdata(31 downto 16) := (others => '0');
        when "01000" => -- 0xA0 tmp target cur addr
          prdata(31 downto 0) := ptta_trans.dbg_cur_ad;
        when "01001" => -- 0xA4 tmp target cur state
          prdata(31 downto 8) := (others => '0');
          prdata(8 downto 0) := ptta_trans.dbg_cur_acc;
        when others =>
          prdata(31 downto 0) := (others => '0');
      end case;
    end if;
  end if;

  apbo.pirq <= pirq;
  apbo.prdata <= prdata;
  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;

  -- --------------------------------------------------------------------------------
  -- APB DEBUG Slave
  -- --------------------------------------------------------------------------------
  tb_ren <= ar.s.tb_ren; 
  tb_addr <= ar.s.haddr;
  
  tbpirq := (others => '0');
  tbprdata := (others => '0');
  tbapbaddr := tbapbi.paddr(6 downto 2);
  
  if tbapben = 1 then
    if (tbapbi.psel(tbpindex) and tbapbi.paddr(17)) = '1' then
        tb_ren <= '1'; tb_addr <= tbapbi.paddr;
    end if;

    if (tbapbi.psel(tbpindex) and tbapbi.penable) = '1' then
      if tbapbi.paddr(17) = '1' then
        if tbapbi.paddr(16) = '0' then 
          tbprdata := pt_fifoo_ad.data;
         else
          tbprdata := zero32(31 downto 20) & pt_fifoo_sig.data(16 downto 0) & "000";
         end if;
      else
        if tbapbi.paddr(7) = '0' then -- PCI core and DMA
          case tbapbaddr is
            when "01110" => -- 0x38 Reserved 
              --prdata(31 downto 0) := (others => '0'); 
              tbprdata := ar.debug;
            when "01111" => -- 0x3c Reserved
              --prdata(31 downto 0) := (others => '0'); 
              tbprdata := ar.debug_pr;
            when others =>
              tbprdata(31 downto 0) := (others => '0'); 
          end case;
        elsif tracebuffer /= 0 then  -- PCI trace buffer enabled
          case tbapbaddr is
            when "00000" => -- 0x80 PCI trace control & status
              if tbapbi.pwrite = '1' then
                av.atpt_trans.start := ar.atpt_trans.start or tbapbi.pwdata(0);
                av.atpt_trans.stop := ar.atpt_trans.stop or tbapbi.pwdata(1);
              end if;
              tbprdata(31 downto 0) := ar.apb_pt_stat;
            when "00001" => -- 0x84 PCI trace count & mode
              if tbapbi.pwrite = '1' then
                av.atpt_trans.mode := tbapbi.pwdata(27 downto 24);
                av.atpt_trans.tcount := tbapbi.pwdata(23 downto 16);
                av.atpt_trans.count := tbapbi.pwdata(PT_DEPTH-1 downto 0);
              end if;
              tbprdata(31 downto 0) := x"0" & ar.atpt_trans.mode & ar.atpt_trans.tcount & zero32(15 downto PT_DEPTH) & ar.atpt_trans.count;
            when "00010" => -- 0x88 PCI trace AD pattern
              if tbapbi.pwrite = '1' then
                av.atpt_trans.ad := tbapbi.pwdata;
              end if;
              tbprdata(31 downto 0) := ar.atpt_trans.ad;
            when "00011" => -- 0x8c PCI trace AD mask
              if tbapbi.pwrite = '1' then
                av.atpt_trans.admask := tbapbi.pwdata;
              end if;
              tbprdata(31 downto 0) := ar.atpt_trans.admask;
            when "00100" => -- 0x90 PCI trace Signal pattern
              if tbapbi.pwrite = '1' then
                av.atpt_trans.sig := tbapbi.pwdata(19 downto 3);
              end if;
              tbprdata(31 downto 0) := x"000" & ar.atpt_trans.sig & "000";
            when "00101" => -- 0x94 PCI trace Signal mask
              if tbapbi.pwrite = '1' then
                av.atpt_trans.sigmask := tbapbi.pwdata(19 downto 3);
              end if;
              tbprdata(31 downto 0) := x"000" & ar.atpt_trans.sigmask & "000";
            when "00110" => -- 0x98 PCI AD
              tbprdata(31 downto 0) := ptta_trans.dbg_ad;
            when "00111" => -- 0x9c PCI Ctrl signal
              tbprdata(19 downto 0) := ptta_trans.dbg_sig & "000";
              tbprdata(31 downto 16) := (others => '0');
            when "01000" => -- 0xA0 tmp target cur addr
              tbprdata(31 downto 0) := ptta_trans.dbg_cur_ad;
            when "01001" => -- 0xA4 tmp target cur state
              tbprdata(31 downto 8) := (others => '0');
              tbprdata(8 downto 0) := ptta_trans.dbg_cur_acc;
            when others =>
              tbprdata(31 downto 0) := (others => '0');
          end case;
        end if;
      end if;
    end if;

    tbapbo.pirq <= tbpirq;
    tbapbo.prdata <= tbprdata;
    tbapbo.pconfig <= tbpconfig;
    tbapbo.pindex <= tbpindex;
  else
    tbapbo <= apb_none;
  end if;

  -- --------------------------------------------------------------------------------
  -- AHB global signal assignments
  -- --------------------------------------------------------------------------------
    
  ahbso.hready <= ar.s.hready;
  ahbso.hresp <= ar.s.hresp;
  ahbso.hrdata <= ahbdrivedata(ar.s.hrdata);

  ahbso.hindex <= hsindex;
  ahbso.hconfig <= hconfig;
  ahbso.hsplit  <= (others => '0');
  ahbso.hirq    <= (others => '0');

  if master = 0 then
    ahbso <= ahbs_none;
  end if;

  -- --------------------------------------------------------------------------------
  -- AHB debug
  -- --------------------------------------------------------------------------------

  --[31:30] s_pending
  --[29:28] s_empty
  --[27:26] tm_pending
  --[25:24] tm_empty
  --[  :23] ms_acc_pending
  --[  :22] ms_acc_cancel
  --[  :21] ms_acc_done
  --[  :20] tm_acc_pending
  --[  :19] tm_acc_cancel
  --[  :18] tm_acc_done
  --[  :17] md_acc_pending
  --[  :16] md_acc_cancel
  --[  :15] md_acc_done
  --[  :14] ..
  --[13:12] dma_done
  --[11:10] s_pending
  --[ 9: 7] m_done
  --[ 6: 4] dma.state
  --[ 3: 2] m.state
  --[ 1: 0] s.state

  av.debug(31 downto 30) := ms_fifo_pending(1 downto 0);
  av.debug(29 downto 28) := ms_fifo_empty(1 downto 0);
  av.debug(27 downto 26) := tm_fifo_pending(1 downto 0);
  av.debug(25 downto 24) := tm_fifo_empty(1 downto 0);

  av.debug(          23) := ms_acc_pending;
  av.debug(          22) := ms_acc_cancel;
  av.debug(          21) := ms_acc_done;
  av.debug(          20) := tm_acc_pending;
  av.debug(          19) := tm_acc_cancel;
  av.debug(          18) := tm_acc_done;
  av.debug(          17) := md_acc_pending;
  av.debug(          16) := md_acc_cancel;
  av.debug(          15) := md_acc_done;

  av.debug(          14) := '0';
  
  av.debug(13 downto 12) := ar.dma.done;
  av.debug(11 downto 10) := ar.s.pending;
  av.debug( 9 downto  7) := ar.m.done;

  case ar.dma.state is
    when dma_idle =>          av.debug(6 downto 4) := "000";
    when dma_read_desc =>     av.debug(6 downto 4) := "001";
    when dma_next_channel =>  av.debug(6 downto 4) := "010";
    when dma_write_status =>  av.debug(6 downto 4) := "011";
    when dma_read =>          av.debug(6 downto 4) := "100";
    when dma_write =>         av.debug(6 downto 4) := "101";
    when dma_error =>         av.debug(6 downto 4) := "110";
  end case;

  case ar.m.state is 
    when am_idle =>   av.debug(3 downto 2) := "00";
    when am_read =>   av.debug(3 downto 2) := "01";
    when am_write =>  av.debug(3 downto 2) := "10";
    when am_error =>  av.debug(3 downto 2) := "11";
    when others =>    av.debug(3 downto 2) := "00";
  end case;

  case ar.s.state is
    when as_idle =>         av.debug(1 downto 0) := "00";
    when as_checkpcimst =>  av.debug(1 downto 0) := "01";
    when as_read =>         av.debug(1 downto 0) := "10";
    when as_write =>        av.debug(1 downto 0) := "11";
    when others =>          av.debug(1 downto 0) := "00";
  end case;
  
  -- --------------------------------------------------------------------------------
  -- AHB reset
  -- --------------------------------------------------------------------------------
  
  -- AHB master
  lahbm_rst <= rst and not pci_target_rst and not pci_hard_rst;
  if lahbm_rst = '0' then
    av.m.state      := am_idle;
    av.m.acc.fifo_index := 0;
    av.m.acc.pending := '0';
    av.m.retry := '0';
    av.m.dmai0.addr := (others => '0');
    av.atp_trans.mstswdis := '0';
    av.atp_trans.tm_acc_ack := '0';
    av.atp_trans.tm_acc_cancel_ack := (others => '0');
    av.atp_trans.tm_acc_done.done := '0';
    for i in 0 to FIFO_COUNT-1 loop
      av.atp_trans.tm_fifo(i).pending := (others => '0');
    end loop;
    av.atp_trans.tm_fifo_ack := (others => '0');
  end if;

  -- AHB slave
  lahbs_rst <= rst and not pci_master_rst and not pci_hard_rst;
  if lahbs_rst = '0' then
    av.s.state      := as_idle;
    av.s.atp.index  := 0;
    av.s.pta.index  := 0;
    av.s.pending    := (others => '0');
    av.s.discard    := '0';
    av.s.start      := '0';
    av.s.cfg_bus    := (others => '0');
    av.s.cfg_status := (others => '0');
    av.s.parerren   := '0';
    av.s.erren      := '0';
    av.s.blen       := (others => '1');
    av.s.blenmask   := (others => '0');
    av.s.io_cfg_burst := (others => '0');
    av.s.fakehost   := '0';
    for i in 0 to 3 loop
      av.s.accbuf(i).pending := '0';
    end loop;
    
    for j in 0 to FIFO_COUNT-1 loop
      av.atp_trans.msd_fifo(0)(j).pending := (others => '0');
    end loop;
    av.atp_trans.msd_fifo_ack(0) := (others => '0');
    av.atp_trans.msd_acc(0).pending := '0';
    av.atp_trans.msd_acc_cancel(0) := '0';
    av.atp_trans.msd_acc_done_ack(0) := '0';

    for i in 0 to 15 loop
      if multifunc = 0 then
        av.s.atp_map(i)(2 downto 0) := "000";
      else
        for j in 0 to multifunc loop
          if masters_vector(j)(i) = '1' then
            av.s.atp_map(i)(2 downto 0) := conv_std_logic_vector(j, 3);
          end if;
        end loop;
      end if;
    end loop;
  end if;

  -- DMA
  if lahbs_rst = '0' then
    av.dma.state := dma_idle;
    av.dma.en := '0';
    av.dma.irq := '0';
    av.dma.irqen := '0';
    av.dma.irqstatus := (others => '0');
    av.dma.errstatus := (others => '0');
    av.dma.irqch := (others => '0');
    av.dma.desc.chid := (others => '0');
    av.dma.dtp.index  := 0;
    av.dma.ptd.index  := 0;
    for j in 0 to FIFO_COUNT-1 loop
      av.atp_trans.msd_fifo(1)(j).pending := (others => '0');
    end loop;
    av.atp_trans.msd_fifo_ack(1) := (others => '0');
    av.atp_trans.msd_acc(1).pending := '0';
    av.atp_trans.msd_acc_cancel(1) := '0';
    av.atp_trans.msd_acc_done_ack(1) := '0';
  end if;

  -- AHB reset
  lahb_rst <= rst and not pci_hard_rst;
  if lahb_rst = '0' then
    if deviceirq = 1 then
      av.irq.device_mask := conv_std_logic_vector(deviceirqmask, 4);
      av.irq.device_force := '0';
    end if;
    if hostirq = 1 then
      av.irq.host_mask := conv_std_logic_vector(hostirqmask, 4);
      av.irq.host_status := (others => '0');
      av.irq.host_pirq_vl := (others => '0');
    end if;
    av.irq.irqen     := '0';
    av.irq.access_en := '0';
    av.irq.access_status := (others => '0');    
    av.irq.system_en := '0';
    av.irq.system_status := (others => '0');

    av.atp_trans.pa_serr_rst := '0';
    av.atp_trans.pa_discardtout_rst := '0';

    -- APB (PCI trace)
    av.atpt_trans.start := '0';
    av.atpt_trans.stop := '1';

    -- Soft reset
    av.atp_trans.rst(1 downto 0) := (others => '0');
  end if;
    
  if rst = '0' then
    -- Hard reset
    av.atp_trans.rst(2) := '0';

    if iotest /= 0 then
      av.debuga(5 downto 0) := "000000";
    end if;
  end if;

  -- Disabled parts
  if target = 0 then      -- PCI targer disabled
    av.m := amba_master_none; 
    av.atp_trans.tm_acc_ack := '0';
    av.atp_trans.tm_acc_cancel_ack := (others => '0');
    av.atp_trans.tm_acc_done := pci_g_acc_status_trans_none;
    av.atp_trans.tm_fifo := pci_g_fifo_trans_vector_none;
    av.atp_trans.tm_fifo_ack := pci_g_fifo_ack_trans_vector_none;
  end if;

  if master = 0 then      -- PCI master disabled
    av.s := amba_slave_none;
    av.atp_trans.msd_acc(0) := pci_g_acc_trans_none;
    av.atp_trans.msd_acc_cancel(0) := '0';
    av.atp_trans.msd_acc_done_ack(0) := '0';
    av.atp_trans.msd_fifo(0) := pci_g_fifo_trans_vector_none;
    av.atp_trans.msd_fifo_ack(0) := pci_g_fifo_ack_trans_vector_none;
  end if;

  if dma = 0 then         -- DMA disabled
    av.dma := dma_reg_none;
    av.atp_trans.msd_acc(1) := pci_g_acc_trans_none;
    av.atp_trans.msd_acc_cancel(1) := '0';
    av.atp_trans.msd_acc_done_ack(1) := '0';
    av.atp_trans.msd_fifo(1) := pci_g_fifo_trans_vector_none;
    av.atp_trans.msd_fifo_ack(1) := pci_g_fifo_ack_trans_vector_none;
  end if;
  
  if tracebuffer = 0 then -- PCI trace buffer disabled
    av.atpt_trans := apb_to_pci_trace_trans_none;
  end if;
  -- --------------

  arin <= av;
end process;



preg : process(pciclk, phyo)
begin
  if rising_edge(pciclk) then
    pr <= prin;
  end if;
  -- PHY => 
  pr.po <= phyo.pr_po;
  pr.m.state <= phyo.pr_m_state;
  pr.m.last <= phyo.pr_m_last;
  pr.m.hold <= phyo.pr_m_hold;
  pr.m.term <= phyo.pr_m_term;
  pr.t.hold <= phyo.pr_t_hold;
  pr.t.stop <= phyo.pr_t_stop;
  pr.t.abort <= phyo.pr_t_abort;
  pr.t.diswithout <= phyo.pr_t_diswithout;
  pr.t.addr_perr <= phyo.pr_t_addr_perr;
  -- PHY <=
end process;


areg : process(clk)
begin
  if rising_edge(clk) then ar <= arin; end if;
end process;

-- AHB master
target_ahbm0 : if target /= 0 generate
  ahbm0 : grpci2_ahb_mst  generic map (hindex => hmindex, devid => GAISLER_GRPCI2, version => REVISION)
            port map (rst, clk, ahbmi, ahbmo_con, ar.m.dmai0, dmao0, disabled_dmai, open);
  ahbmo <= ahbmo_con;
end generate;
no_target_ahbm0 : if target = 0 generate
  ahbmo <= ahbm_none;
end generate;

dma_ahbm0 : if dma /= 0 generate
  ahbm1 : grpci2_ahb_mst  generic map (hindex => hdmindex, devid => GAISLER_GRPCI2_DMA, version => REVISION)
            port map (rst, clk, ahbdmi, ahbdmo, ar.dma.dmai1, dmao1, disabled_dmai, open);
end generate;
no_dma_ahbm0 : if dma = 0 generate
  ahbdmo <= ahbm_none;
end generate;

target_fifo0 : if target /= 0 generate
  scan_prin_t_atp_ctrl_en   <= (prin.t.atp.ctrl.en and not scanen); 
  scan_ar_m_acc_fifo_wen    <= (ar.m.acc.fifo_wen and not scanen);
  scan_arin_m_acc_fifo_ren  <= (arin.m.acc.fifo_ren and not scanen);
  scan_pr_t_pta_ctrl_en     <= (pr.t.pta.ctrl.en and not scanen); 

  ft0 : if ft /= 0 generate
    -- AHB master to PCI target FIFO
    atp_fifo0 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (pciclk, scan_prin_t_atp_ctrl_en, prin.t.atp.ctrl.addr, tm_fifoo_atp.data, 
                            clk, scan_ar_m_acc_fifo_wen, ar.m.acc.fifo_addr, ar.m.acc.fifo_wdata,
                            tm_fifoo_atp.err, testin
                            );
    -- PCI target to AHB master FIFO                                                                                                 
    pta_fifo0 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (clk, scan_arin_m_acc_fifo_ren, arin.m.acc.fifo_addr, tm_fifoo_pta.data, 
                            pciclk, scan_pr_t_pta_ctrl_en, pr.t.pta.ctrl.addr, pr.t.pta.ctrl.data,
                            tm_fifoo_pta.err, testin
                            );
    -- AHB master to PCI target FIFO
  end generate;
  noft0 : if ft = 0 generate
    atp_fifo0 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0, testen => scantest,
                                        custombits => memtest_vlen)
                  port map (pciclk, scan_prin_t_atp_ctrl_en, prin.t.atp.ctrl.addr, tm_fifoo_atp.data, 
                            clk, scan_ar_m_acc_fifo_wen, ar.m.acc.fifo_addr, ar.m.acc.fifo_wdata,
                            testin
                            );
    -- PCI target to AHB master FIFO                                                                                                 
    pta_fifo0 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0, testen => scantest,
                                        custombits => memtest_vlen) 
                  port map (clk, scan_arin_m_acc_fifo_ren, arin.m.acc.fifo_addr, tm_fifoo_pta.data, 
                            pciclk, scan_pr_t_pta_ctrl_en, pr.t.pta.ctrl.addr, pr.t.pta.ctrl.data, 
                            testin
                            );
  end generate;
end generate;

master_fifo0 : if master /= 0 generate
  scan_prin_m_acc_acc_sel_ahb_fifo_ren  <= (prin.m.acc(acc_sel_ahb).fifo_ren and not scanen);
  scan_ar_s_atp_ctrl_en                 <= (ar.s.atp.ctrl.en and not scanen);
  scan_arin_s_pta_ctrl_en               <= (arin.s.pta.ctrl.en and not scanen);
  scan_pr_m_acc_acc_sel_ahb_fifo_wen    <= (pr.m.acc(acc_sel_ahb).fifo_wen and not scanen);

  ft0 : if ft /= 0 generate
    -- AHB slave to PCI master FIFO
    atp_fifo1 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (pciclk, scan_prin_m_acc_acc_sel_ahb_fifo_ren, prin.m.fifo_addr, ms_fifoo_atp.data, 
                            clk, scan_ar_s_atp_ctrl_en, ar.s.atp.ctrl.addr, ar.s.atp.ctrl.data,
                            ms_fifoo_atp.err
                            );
    -- PCI master to AHB slave FIFO                                                                                                 
    pta_fifo1 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (clk, scan_arin_s_pta_ctrl_en, arin.s.pta.ctrl.addr, ms_fifoo_pta.data, 
                            pciclk, scan_pr_m_acc_acc_sel_ahb_fifo_wen, pr.m.fifo_addr, pr.m.fifo_wdata,
                            ms_fifoo_pta.err
                            );
  end generate;
  noft0 : if ft = 0 generate
    -- AHB slave to PCI master FIFO
    atp_fifo1 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0,
                                        testen => scantest, custombits => memtest_vlen)
                  port map (pciclk, scan_prin_m_acc_acc_sel_ahb_fifo_ren, prin.m.fifo_addr, ms_fifoo_atp.data, 
                            clk, scan_ar_s_atp_ctrl_en, ar.s.atp.ctrl.addr, ar.s.atp.ctrl.data,
                            testin
                            );
    -- PCI master to AHB slave FIFO                                                                                                 
    pta_fifo1 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0,
                                        testen => scantest, custombits => memtest_vlen)
                  port map (clk, scan_arin_s_pta_ctrl_en, arin.s.pta.ctrl.addr, ms_fifoo_pta.data, 
                            pciclk, scan_pr_m_acc_acc_sel_ahb_fifo_wen, pr.m.fifo_addr, pr.m.fifo_wdata,
                            testin
                            );
  end generate;
end generate;

dma_fifo0 : if dma /= 0 generate
  scan_prin_m_acc_acc_sel_dma_fifo_ren  <= (prin.m.acc(acc_sel_dma).fifo_ren and not scanen);
  scan_ar_dma_dtp_ctrl_en               <= (ar.dma.dtp.ctrl.en and not scanen);
  scan_arin_dma_ptd_ctrl_en             <= (arin.dma.ptd.ctrl.en and not scanen);
  scan_pr_m_acc_acc_sel_dma_fifo_wen    <= (pr.m.acc(acc_sel_dma).fifo_wen and not scanen);

  ft0 : if ft /= 0 generate
    -- DMA to PCI master FIFO
    dtp_fifo2 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (pciclk, scan_prin_m_acc_acc_sel_dma_fifo_ren, prin.m.fifo_addr, md_fifoo_dtp.data, 
                            clk, scan_ar_dma_dtp_ctrl_en, ar.dma.dtp.ctrl.addr, ar.dma.dtp.ctrl.data,
                            md_fifoo_dtp.err, testin
                           );
    -- PCI master to DMA                                                                                                           
    ptd_fifo2 : syncram_2pft generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                          dbits => 32, sepclk => 1, wrfst => 0, ft => ft,
                                          testen => scantest, custombits => memtest_vlen)
                  port map (clk, scan_arin_dma_ptd_ctrl_en, arin.dma.ptd.ctrl.addr, md_fifoo_ptd.data, 
                            pciclk, scan_pr_m_acc_acc_sel_dma_fifo_wen, pr.m.fifo_addr, pr.m.fifo_wdata,
                            md_fifoo_dtp.err, testin
                            );
  end generate;
  noft0 : if ft = 0 generate
    -- DMA to PCI master FIFO
    dtp_fifo2 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0,
                                        testen => scantest, custombits => memtest_vlen)
                  port map (pciclk, scan_prin_m_acc_acc_sel_dma_fifo_ren, prin.m.fifo_addr, md_fifoo_dtp.data, 
                            clk, scan_ar_dma_dtp_ctrl_en, ar.dma.dtp.ctrl.addr, ar.dma.dtp.ctrl.data,
                            testin
                            );
    -- PCI master to DMA                                                                                                           
    ptd_fifo2 : syncram_2p generic map (tech => memtech, abits => FIFO_DEPTH+log2(FIFO_COUNT), 
                                        dbits => 32, sepclk => 1, wrfst => 0,
                                        testen => scantest, custombits => memtest_vlen)
                  port map (clk, scan_arin_dma_ptd_ctrl_en, arin.dma.ptd.ctrl.addr, md_fifoo_ptd.data, 
                            pciclk, scan_pr_m_acc_acc_sel_dma_fifo_wen, pr.m.fifo_addr, pr.m.fifo_wdata,
                            testin
                            );
  end generate;
  
end generate;

-- PCI trace                                                                                               
trace_fifo0 : if tracebuffer /= 0 generate
  scan_tb_ren               <= (tb_ren and not scanen);
  scan_pr_ptta_trans_enable <= (pr.ptta_trans.enable and not scanen);

  pt_fifo0 : syncram_2p generic map (tech => tbmemtech, abits => PT_DEPTH, dbits => 32, sepclk => 1, wrfst => 0,
                                     testen => scantest, custombits => memtest_vlen) 
               port map (clk, scan_tb_ren, tb_addr(PT_DEPTH+1 downto 2), pt_fifoo_ad.data, 
                         pciclk, scan_pr_ptta_trans_enable, pr.pt.addr, pi.ad,
                         testin
                         );
  pt_fifoo_ad.err <= (others => '0');
  pt_fifo1 : syncram_2p generic map (tech => tbmemtech, abits => PT_DEPTH, dbits => 17, sepclk => 1, wrfst => 0, 
                                     testen => scantest, custombits => memtest_vlen) 
               port map (clk, scan_tb_ren, tb_addr(PT_DEPTH+1 downto 2), pt_fifoo_sig.data(16 downto 0), 
                         pciclk, scan_pr_ptta_trans_enable, pr.pt.addr, pcisig,
                         testin
                         );
  pt_fifoo_sig.err <= (others => '0');
end generate;

-- IO test module
iotgen : if iotest /= 0 generate
  iotm : synciotest
    generic map (ninputs => 2, noutputs => 1, nbidir => 44)
    port map (
      clk => pciclk,
      rstn => pcii.rst,
      datain => iotmdin,
      dataout => iotmdout,
      tmode => ar.debuga(5 downto 0),
      tmodeact => iotmact,
      tmodeoe => iotmoe
      );
end generate;

iotngen : if iotest = 0 generate
  iotmdout <= (others => '0');
  iotmact <= '0';
  iotmoe <= '0';
end generate;

--pragma translate_off
 bootmsg : report_version
   generic map ("grpci2" & tost(hmindex) &
                ": 32-bit PCI/AHB bridge  rev, " & tost(REVISION) &
                ", " & tost(2**FIFO_DEPTH) & "-word FIFOs" & ", PCI trace: " & tost(((2**PT_DEPTH)*conv_integer(conv_std_logic(tracebuffer/=0)))));
--pragma translate_on
end;

