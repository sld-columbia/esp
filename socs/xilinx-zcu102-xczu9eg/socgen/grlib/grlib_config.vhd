-----------------------------------------------------------------------------
-- LEON3 Demonstration design test bench configuration
-- Copyright (C) 2009 Aeroflex Gaisler
------------------------------------------------------------------------------
use work.gencomp.all;
package grlib_config is
-- Synthesis options
  constant CFG_NOASYNC : integer := 0;
  constant CFG_SCAN : integer := 0;
-- LEON3 processor core
  constant CFG_LEON3 : integer := 1;
  constant CFG_NWIN : integer := (8);
  constant CFG_V8 : integer := 2 + 4*0;
  constant CFG_MAC : integer := 0;
  constant CFG_BP : integer := 1;
  constant CFG_SVT : integer := 1;
  constant CFG_RSTADDR : integer := 16#00000#;
  constant CFG_LDDEL : integer := (1);
  constant CFG_NOTAG : integer := 0;
  constant CFG_NWP : integer := (2);
  constant CFG_PWD : integer := 1*2;
  constant CFG_FPU : integer := 7 + 16*0 + 32*0;
  constant CFG_GRFPUSH : integer := 0;
  constant CFG_ICEN : integer := 1;
  constant CFG_ISETS : integer := 2;
  constant CFG_ISETSZ : integer := 8;
  constant CFG_ILINE : integer := 4;
  constant CFG_IREPL : integer := 0;
  constant CFG_ILOCK : integer := 0;
  constant CFG_ILRAMEN : integer := 0;
  constant CFG_ILRAMADDR: integer := 16#8E#;
  constant CFG_ILRAMSZ : integer := 1;
  constant CFG_DCEN : integer := 1;
  constant CFG_DSETS : integer := 4;
  constant CFG_DSETSZ : integer := 4;
  constant CFG_DLINE : integer := 4;
  constant CFG_DREPL : integer := 0;
  constant CFG_DLOCK : integer := 0;
  constant CFG_DSNOOP : integer := 0 + 1*2 + 4*1;
  constant CFG_DFIXED : integer := 16#0#;
  constant CFG_DLRAMEN : integer := 0;
  constant CFG_DLRAMADDR: integer := 16#8F#;
  constant CFG_DLRAMSZ : integer := 1;
  constant CFG_MMUEN : integer := 1;
  constant CFG_ITLBNUM : integer := 8;
  constant CFG_DTLBNUM : integer := 8;
  constant CFG_TLB_TYPE : integer := 0 + 1*2;
  constant CFG_TLB_REP : integer := 0;
  constant CFG_MMU_PAGE : integer := 0;
  constant CFG_DSU : integer := 1;
  constant CFG_ITBSZ : integer := 0 + 64*0;
  constant CFG_ATBSZ : integer := 0;
  constant CFG_AHBPF : integer := 0;
  constant CFG_LEON3FT_EN : integer := 0;
  constant CFG_IUFT_EN : integer := 0;
  constant CFG_FPUFT_EN : integer := 0;
  constant CFG_RF_ERRINJ : integer := 0;
  constant CFG_CACHE_FT_EN : integer := 0;
  constant CFG_CACHE_ERRINJ : integer := 0;
  constant CFG_LEON3_NETLIST: integer := 0;
  constant CFG_DISAS : integer := 0 + 0;
  constant CFG_PCLOW : integer := 0;
  constant CFG_STAT_ENABLE : integer := 0;
  constant CFG_STAT_CNT : integer := 1;
  constant CFG_STAT_NMAX : integer := 0;
  constant CFG_STAT_DSUEN : integer := 0;
  constant CFG_NP_ASI : integer := 0;
  constant CFG_WRPSR : integer := 0;
  constant CFG_ALTWIN : integer := 0;
  constant CFG_REX : integer := 0;
-- AMBA settings
  constant CFG_DEFMST : integer := (0);
  constant CFG_RROBIN : integer := 1;
  constant CFG_SPLIT : integer := 0;
  constant CFG_FPNPEN : integer := 1;
  constant CFG_AHBIO : integer := 16#FFF#;
  constant CFG_AHB_MON : integer := 0;
  constant CFG_AHB_MONERR : integer := 0;
  constant CFG_AHB_MONWAR : integer := 0;
  constant CFG_AHB_DTRACE : integer := 0;
-- JTAG based DSU interface
  constant CFG_AHB_JTAG : integer := 0;
-- Ethernet DSU
  constant CFG_DSU_ETH : integer := 1 + 0 + 0;
  constant CFG_ETH_BUF : integer := 16;
  constant CFG_ETH_IPM : integer := 16#C0A8#;
  constant CFG_ETH_IPL : integer := 16#0107#;
  constant CFG_ETH_ENM : integer := 16#A6A7A0#;
  constant CFG_ETH_ENL : integer := 16#F8043D#;
-- LEON2 memory controller
  constant CFG_MCTRL_LEON2 : integer := 1;
  constant CFG_MCTRL_RAM8BIT : integer := 1;
  constant CFG_MCTRL_RAM16BIT : integer := 1;
  constant CFG_MCTRL_5CS : integer := 0;
  constant CFG_MCTRL_SDEN : integer := 0;
  constant CFG_MCTRL_SEPBUS : integer := 0;
  constant CFG_MCTRL_INVCLK : integer := 0;
  constant CFG_MCTRL_SD64 : integer := 0;
  constant CFG_MCTRL_PAGE : integer := 0 + 0;
-- Xilinx MIG 7-Series
  constant CFG_MIG_7SERIES_MODEL : integer := 1;
-- AHB status register
  constant CFG_AHBSTAT : integer := 0;
  constant CFG_AHBSTATN : integer := 1;
-- AHB ROM
  constant CFG_AHBROMEN : integer := 0;
  constant CFG_AHBROPIP : integer := 0;
  constant CFG_AHBRODDR : integer := 16#000#;
  constant CFG_ROMADDR : integer := 16#000#;
  constant CFG_ROMMASK : integer := 16#E00# + 16#000#;
-- AHB RAM
  constant CFG_AHBRAMEN : integer := 0;
  constant CFG_AHBRSZ : integer := 1;
  constant CFG_AHBRADDR : integer := 16#A00#;
  constant CFG_AHBRPIPE : integer := 0;
-- Gaisler Ethernet core
  constant CFG_GRETH : integer := 1;
  constant CFG_GRETH1G : integer := 0;
  constant CFG_ETH_FIFO : integer := 8;
  constant CFG_GRETH_FT : integer := 0;
  constant CFG_GRETH_EDCLFT : integer := 0;
-- UART 1
  constant CFG_UART1_ENABLE : integer := 1;
  constant CFG_UART1_FIFO : integer := 32;
  constant CFG_UART1_IRQ : integer := (2);
-- LEON3 interrupt controller
  constant CFG_IRQ3_ENABLE : integer := 1;
  constant CFG_IRQ3_NSEC : integer := 0;
-- Modular timer
  constant CFG_GPT_ENABLE : integer := 1;
  constant CFG_GPT_NTIM : integer := (2);
  constant CFG_GPT_SW : integer := (8);
  constant CFG_GPT_TW : integer := (32);
  constant CFG_GPT_IRQ : integer := (8);
  constant CFG_GPT_SEPIRQ : integer := 1;
  constant CFG_GPT_WDOGEN : integer := 0;
  constant CFG_GPT_WDOG : integer := 16#0#;
-- VGA and PS2/ interface
  constant CFG_KBD_ENABLE : integer := 0;
  constant CFG_VGA_ENABLE : integer := 0;
  constant CFG_SVGA_ENABLE : integer := 0;
  constant CFG_SVGA_MEMORY_HADDR : integer := 16#B01#;
-- GRLIB debugging
  constant CFG_DUART : integer := 1;
end;
