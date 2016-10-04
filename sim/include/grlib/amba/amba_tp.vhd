------------------------------------------------------------------------------
--  This file is a part of the WORK.VHDL IP LIBRARY
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
--============================================================================--
-- Design unit  : AMBA_TestPackage (Package and body declarations)
--
-- File name    : amba_tp.vhd
--
-- Purpose      : AMBA AHB and APB interface access procedures
--
-- Library      : {independent}
--
-- Authors      : Aeroflex Gaisler AB
--
-- Contact      : mailto:support@gaisler.com
--                http://www.aeroflex.com/gaisler
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--------------------------------------------------------------------------------
-- Version  Author   Date           Changes
-- 0.1      SH       15 Mar 2002    New package
-- 0.2      SH       17 Mar 2003    Updated most packages
-- 0.3      SH       20 May 2003    Memory based on Integer elements
-- 0.4      SH        1 Jul 2003    Name of package changed
--                                  Compare function improved
--                                  AHB 32 bit memory with preload added
--                                  AHB initialisation added
-- 0.5      SH       21 Jul 2003    AHB 32 memory with diagnostics added
-- 0.6      SH        1 Nov 2003    APB read access data sample made earlier
--                                  AHB 32 memory extended with byte/halfword
-- 0.7      SH       25 Jan 2004    AHB read access data output corrected
--                                  AHB 32 memory allows overlay addressing
-- 1.7      SH        1 Oct 2004    Ported to GRLIB
-- 1.8      SH        1 Jul 2005    Added configuration support for memories
--                                  Modified all procedure declarations
-- 1.9      SH       10 Nov 2005    AHB 32 responds with HREADY=0 when error
-- 1.11     SH       27 Dec 2004    Split support added, using HSPLIT element
--                                  Proper two-cycle error response implemented
-- 1.12     SH       15 Feb 2006    Added bank select to AHB bus accesses
-- 1.13     SH        1 May 2009    AHBQuite gave incorrect TP on error resps.
--------------------------------------------------------------------------------

library  Std;
use      Std.Standard.all;
use      Std.TextIO.all;

library  IEEE;
use      IEEE.Std_Logic_1164.all;

use      WORK.AMBA.all;
use      WORK.StdLib.all;
use      WORK.StdIO.all;

package AMBA_TestPackage is

   -----------------------------------------------------------------------------
   -- AMBA APB write access
   -----------------------------------------------------------------------------
   procedure APBInit(
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      constant InstancePath:  in    String  := "APBInit";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := True);

   -----------------------------------------------------------------------------
   -- AMBA APB write access
   -----------------------------------------------------------------------------
   procedure APBWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBRead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBRead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0);

   -----------------------------------------------------------------------------
   -- Initialise AMBA AHB interface
   -----------------------------------------------------------------------------
   procedure AHBInit(
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      constant InstancePath:  in    String  := "AHBInit";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := True);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure AHBWriteQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure AHBWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBRead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBRead";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0);

   -----------------------------------------------------------------------------
   -- Diagnstics types for behavioural model of memory with AHB interface
   -----------------------------------------------------------------------------
   type AHB_Diagnostics_In_Type is
   record
      HADDR:         Std_Logic_Vector(31 downto 0);
      HWRITE:        Std_ULogic;
      HWDATA:        Std_Logic_Vector(31 downto 0);
      HRESP:         Std_Logic_Vector(1  downto 0);      -- response type
      HSPLIT:        Std_Logic_Vector(NAHBMST-1 downto 0);      -- split completion
   end record AHB_Diagnostics_In_Type;

   type AHB_Diagnostics_Out_Type is
   record
      HRDATA:        Std_Logic_Vector(31 downto 0);
   end record AHB_Diagnostics_Out_Type;

   constant AHB_Diagnostics_Init: AHB_Diagnostics_In_Type :=
               (X"00000000", '0', X"00000000", HRESP_OKAY, zero32(NAHBMST-1 downto 0));

   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AHB interface, no wait states
   -----------------------------------------------------------------------------
   procedure AHBMemory(
      constant gAWidth:       in    Positive := 15;      -- address width
      constant gDWidth:       in    Positive :=  8;      -- data width
      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;
      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;
      constant InstancePath:  in    String   := "AHBMemory";
      constant ScreenOutput:  in    Boolean  := False;
      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#);

   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AMBA AHB interface, no wait states
   -----------------------------------------------------------------------------
   procedure AHBMemory32(
      constant gAWidth:       in    Positive := 18;      -- address width
      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;
      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;
      constant InstancePath:  in    String   := "AHBMemory32";
      constant ScreenOutput:  in    Boolean  := False;
      constant FileName:      in    String := "";        -- file name
      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#);

   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AHB interface, no wait states
   -- Supporting byte, halfword and word read/write accesses.
   -- Provices diagnostic support.
   -----------------------------------------------------------------------------
   procedure AHBMemory32(
      constant gAWidth:       in    Positive := 18;      -- address width
      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;
      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;
      signal   AHBInDiag:     in    AHB_Diagnostics_In_Type;
      signal   AHBOutDiag:    out   AHB_Diagnostics_Out_Type;
      constant InstancePath:  in    String   := "AHBMemory32";
      constant ScreenOutput:  in    Boolean  := False;
      constant FileName:      in    String   := "";      -- file name
      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#);

   -----------------------------------------------------------------------------
   -- Routine for writig data directly to AHB memory
   -----------------------------------------------------------------------------
   procedure WrAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      constant Data:       in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in    AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False);

   -----------------------------------------------------------------------------
   -- Routine for reading data directly from AHB memory
   -----------------------------------------------------------------------------
   procedure RdAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      variable Data:       out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in   AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False);

   -----------------------------------------------------------------------------
   -- Routine for reading data directly from AHB memory
   -----------------------------------------------------------------------------
   procedure RcAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      constant Expected:   in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in    AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False);

   -----------------------------------------------------------------------------
   -- Routine for generating a split ack from AHB memory
   -----------------------------------------------------------------------------
   procedure SplitAHBMem32(
      constant Split:      in    Integer range 0 to NAHBMST-1;
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in   AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False);

end AMBA_TestPackage;

--============================================================================--

package body AMBA_TestPackage is
   -----------------------------------------------------------------------------
   -- Compare function handling '-'
   -----------------------------------------------------------------------------
   function Compare(O, C: in Std_Logic_Vector) return Boolean is
      variable T:       Std_Logic_Vector(O'Range) := C;
      variable Result:  Boolean;
   begin
      Result := True;
      for i in O'Range loop
          if not (O(i)=T(i) or T(i)='-' or T(i)='U') then
            Result   := False;
          end if;
      end loop;
      return Result;
   end function Compare;

   -----------------------------------------------------------------------------
   -- Synchronisation with respect to clock and with output offset
   -----------------------------------------------------------------------------
   procedure Synchronise(
      signal   Clk:           in    Std_ULogic;
      constant Offset:        in    Time := 5 ns) is
   begin
      wait until CLK = '1';                              -- Synchronise
      wait for Offset;                                   -- output offset delay
   end procedure Synchronise;

   -----------------------------------------------------------------------------
   -- AMBA APB write access
   -----------------------------------------------------------------------------
   procedure APBInit(
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      constant InstancePath:  in    String  := "APBInit";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := True) is
      variable L:                   Line;
   begin
      if cBack2Back then
         Synchronise(PCLK);
      end if;
      APBIn.PSEL           <= (others => '0');
      APBIn.PENABLE        <= '0';
      APBIn.PADDR          <= (others => '0');
      APBIn.PWRITE         <= '0';
      APBIn.PWDATA         <= (others => '0');

      if ScreenOutput then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : APB initalised"));
         WriteLine(Output, L);
      end if;
   end procedure APBInit;

   -----------------------------------------------------------------------------
   -- AMBA APB write access
   -----------------------------------------------------------------------------
   procedure APBWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0) is
      variable L:                   Line;
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(PCLK);
      end if;

      APBIn.PSEL           <= (others => '0');
      APBIn.PSEL(PINDEX)   <= '1';                       -- first clock period
      APBIn.PENABLE        <= '0';
      APBIn.PADDR          <= Address;
      APBIn.PWRITE         <= '1';
      APBIn.PWDATA         <= Data;

      Synchronise(PCLK);                                 -- second clock period
      APBIn.PENABLE  <= '1';

      if ScreenOutput then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : APB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
      end if;

      Synchronise(PCLK);                                 -- end of access
      APBIn.PSEL           <= (others => '0');
      APBIn.PENABLE        <= '0';
      APBIn.PADDR          <= (others => '-');
      APBIn.PWRITE         <= '0';
      APBIn.PWDATA         <= (others => '-');
   end procedure APBWrite;

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0) is
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(PCLK);
      end if;

      APBIn.PSEL           <= (others => '0');
      APBIn.PSEL(PINDEX)   <= '1';                       -- first clock period
      APBIn.PENABLE        <= '0';
      APBIn.PADDR          <= Address;
      APBIn.PWRITE         <= '0';
      APBIn.PWDATA         <= (others => '-');

      Synchronise(PCLK);                                 -- second clock period
      APBIn.PENABLE  <= '1';

      wait for 5 ns;
      Data           := APBOut.PRDATA;

      Synchronise(PCLK);                                 -- end of access

      APBIn.PSEL           <= (others => '0');
      APBIn.PENABLE        <= '0';
      APBIn.PADDR          <= (others => '-');
   end procedure APBQuiet;

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBRead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBRead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0) is
      variable L:                   Line;
      variable Temp:                Std_Logic_Vector(31 downto 0);
   begin
      APBQuiet(Address, Temp, PCLK, APBIn, APBOut, TP, InstancePath, False, cBack2Back, PINDEX);
      Data := Temp;
      if ScreenOutput then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : APB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Temp);
         WriteLine(Output, L);
      end if;
   end procedure APBRead;

   -----------------------------------------------------------------------------
   -- AMBA APB read access
   -----------------------------------------------------------------------------
   procedure APBComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   PCLK:          in    Std_ULogic;
      signal   APBIn:         out   APB_Slv_In_Type;
      signal   APBOut:        in    APB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "APBComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant PINDEX:        in    Integer := 0) is
      variable L:                   Line;
      variable Data:                Std_Logic_Vector(31 downto 0);
   begin
      APBQuiet(Address, Data, PCLK, APBIn, APBOut, TP, InstancePath, False, cBack2Back, PINDEX);
      if not Compare(Data, CxData) then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Data);
         Write(L, String'(" : expected: "));
         HWrite(L, CxData);
         Write(L, String'(" # Error #"));
         WriteLine(Output, L);
         TP       := False;
      elsif ScreenOutput then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
      end if;
      RxData   := Data;
   end procedure APBComp;

   -----------------------------------------------------------------------------
   -- Initialise AHB interface
   -----------------------------------------------------------------------------
   procedure AHBInit(
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      constant InstancePath:  in    String  := "AHBInit";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := True) is
      variable L:                   Line;
   begin
      if cBack2Back then
         Synchronise(HCLK);
      end if;
      AHBIn.HSEL        <= (others => '0');
      AHBIn.HADDR       <= (others => '0');
      AHBIn.HWRITE      <= '0';
      AHBIn.HTRANS      <= HTRANS_IDLE;
      AHBIn.HSIZE       <= HSIZE_WORD;
      AHBIn.HBURST      <= HBURST_SINGLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HPROT       <= (others => '0');
      AHBIn.HREADY      <= '0';
      AHBIn.HMASTER     <= (others => '0');
      AHBIn.HMASTLOCK   <= '0';
      AHBIn.HMBSEL      <= (others => '0');

      if ScreenOutput then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB initalised"));
         WriteLine(Output, L);
      end if;
   end procedure AHBInit;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure AHBWriteQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0) is
      variable L:                   Line;
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);                              -- first clock period
      end if;

      AHBIn.HSEL        <= (others => '0');
      AHBIn.HSEL(HINDEX)<= '1';
      AHBIn.HADDR       <= Address;
      AHBIn.HWRITE      <= '1';
      AHBIn.HTRANS      <= HTRANS_NONSEQ;
      AHBIn.HSIZE       <= HSIZE_WORD;
      AHBIn.HBURST      <= HBURST_SINGLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HPROT       <= (others => '0');
      AHBIn.HREADY      <= '1';
      AHBIn.HMASTER     <= (others => '0');
      AHBIn.HMASTLOCK   <= '0';
      AHBIn.HMBSEL      <= (others => '0');
      AHBIn.HMBSEL(HMBINDEX)  <= '1';

      Synchronise(HCLK);                                 -- second clock period
      AHBIn.HSEL        <= (others => '0');
      AHBIn.HSEL(HINDEX)<= '1';
      AHBIn.HADDR       <= (others => '-');
      AHBIn.HWRITE      <= '0';
      AHBIn.HTRANS      <= HTRANS_IDLE;
      AHBIn.HWDATA      <= ahbdrivedata(Data);
      AHBIn.HREADY      <= AHBOut.HREADY;
      AHBIn.HMBSEL      <= (others => '0');
      AHBIn.HMBSEL(HMBINDEX)  <= '1';

      while AHBOut.HREADY='0' loop
         Synchronise(HCLK);
      end loop;

      if    AHBOut.HRESP=HRESP_ERROR then
         if ScreenOutput then
            Write (L, Now, Right, 15);
            Write (L, " : " & InstancePath);
            Write (L, String'(" : AHB write access, address: "));
            HWrite(L, Address);
            Write (L, String'("  ERROR response "));
            WriteLine(Output, L);
         end if;
         TP         := False;
      elsif AHBOut.HRESP=HRESP_RETRY then
         if ScreenOutput then
            Write (L, Now, Right, 15);
            Write (L, " : " & InstancePath);
            Write (L, String'(" : AHB write access, address: "));
            HWrite(L, Address);
            Write (L, String'("  RETRY response "));
            WriteLine(Output, L);
         end if;
         TP         := False;
      elsif AHBOut.HRESP=HRESP_SPLIT then
         if ScreenOutput then
            Write (L, Now, Right, 15);
            Write (L, " : " & InstancePath);
            Write (L, String'(" : AHB write access, address: "));
            HWrite(L, Address);
            Write (L, String'("  SPLIT response "));
            WriteLine(Output, L);
         end if;
         TP         := False;
      else
      end if;

      Synchronise(HCLK);                                 -- end of access
      AHBIn.HSEL        <= (others => '0');
      AHBIn.HADDR       <= (others => '-');
      AHBIn.HWRITE      <= '1';
      AHBIn.HTRANS      <= HTRANS_IDLE;
      AHBIn.HSIZE       <= HSIZE_WORD;
      AHBIn.HBURST      <= HBURST_SINGLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HPROT       <= (others => '0');
      AHBIn.HREADY      <= '1';
      AHBIn.HMASTER     <= (others => '0');
      AHBIn.HMASTLOCK   <= '0';
      AHBIn.HMBSEL      <= (others => '0');

   end procedure AHBWriteQuiet;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure AHBWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
   begin
      AHBWriteQuiet(Address, Data, HCLK, AHBIn, AHBOut, OK,
                    InstancePath, False, cBack2Back, HINDEX, HMBINDEX);
      if ScreenOutput and OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
      elsif not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP := False;
      end if;
   end procedure AHBWrite;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0) is

      variable L:                   Line;
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);
      end if;

      AHBIn.HSEL        <= (others => '0');
      AHBIn.HSEL(HINDEX)<= '1';
      AHBIn.HADDR       <= Address;
      AHBIn.HWRITE      <= '0';
      AHBIn.HTRANS      <= HTRANS_NONSEQ;
      AHBIn.HSIZE       <= HSIZE_WORD;
      AHBIn.HBURST      <= HBURST_SINGLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HPROT       <= (others => '0');
      AHBIn.HREADY      <= '1';
      AHBIn.HMASTER     <= (others => '0');
      AHBIn.HMASTLOCK   <= '0';
      AHBIn.HMBSEL      <= (others => '0');
      AHBIn.HMBSEL(HMBINDEX)  <= '1';

      Synchronise(HCLK);                                 -- second clock period
      AHBIn.HSEL        <= (others => '0');
      AHBIn.HSEL(HINDEX)<= '1';
      AHBIn.HADDR       <= (others => '-');
      AHBIn.HWRITE      <= '0';
      AHBIn.HTRANS      <= HTRANS_IDLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HREADY      <= AHBOut.HREADY;
      AHBIn.HMBSEL      <= (others => '0');
      AHBIn.HMBSEL(HMBINDEX)  <= '1';

      while AHBOut.HREADY='0' loop
         Synchronise(HCLK);
      end loop;

      Data              := AHBOut.HRDATA(31 downto 0);
      if    AHBOut.HRESP=HRESP_ERROR then
         if ScreenOutput then
            Write(L, Now, Right, 15);
            Write(L, " : " & InstancePath);
            Write(L, String'(" : AHB read  access, address: "));
            HWrite(L, Address);
            Write(L, String'("  ERROR response "));
            WriteLine(Output, L);
         end if;
         TP             := False;
      elsif AHBOut.HRESP=HRESP_RETRY then
         if ScreenOutput then
            Write(L, Now, Right, 15);
            Write(L, " : " & InstancePath);
            Write(L, String'(" : AHB read  access, address: "));
            HWrite(L, Address);
            Write(L, String'("  RETRY response "));
            WriteLine(Output, L);
         end if;
         TP             := False;
      elsif AHBOut.HRESP=HRESP_SPLIT then
         if ScreenOutput then
            Write(L, Now, Right, 15);
            Write(L, " : " & InstancePath);
            Write(L, String'(" : AHB read  access, address: "));
            HWrite(L, Address);
            Write(L, String'("  SPLIT response "));
            WriteLine(Output, L);
         end if;
         TP             := False;
      else
      end if;

      Synchronise(HCLK);                                 -- end of access
      AHBIn.HSEL        <= (others => '0');
      AHBIn.HADDR       <= (others => '-');
      AHBIn.HWRITE      <= '0';
      AHBIn.HTRANS      <= HTRANS_IDLE;
      AHBIn.HSIZE       <= HSIZE_WORD;
      AHBIn.HBURST      <= HBURST_SINGLE;
      AHBIn.HWDATA      <= (others => '-');
      AHBIn.HPROT       <= (others => '0');
      AHBIn.HREADY      <= '1';
      AHBIn.HMASTER     <= (others => '0');
      AHBIn.HMASTLOCK   <= '0';
      AHBIn.HMBSEL      <= (others => '0');
   end procedure AHBQuiet;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBRead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBRead";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Temp:                Std_Logic_Vector(31 downto 0);
   begin
      AHBQuiet(Address, Temp, HCLK, AHBIn, AHBOut, OK,
                   InstancePath, False, cBack2Back, HINDEX, HMBINDEX);
      if ScreenOutput and OK then
         Data := Temp;
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Temp);
         WriteLine(Output, L);
      elsif OK then
         Data := Temp;
      else
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         Data := (others => '-');
         TP   := False;
      end if;
   end procedure AHBRead;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure AHBComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   AHBIn:         out   AHB_Slv_In_Type;
      signal   AHBOut:        in    AHB_Slv_Out_Type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "AHBComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant HINDEX:        in    Integer := 0;
      constant HMBINDEX:      in    Integer := 0) is

      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Data:                Std_Logic_Vector(31 downto 0);
      variable Failed:              Boolean;
   begin
      AHBQuiet(Address, Data, HCLK, AHBIn, AHBOut, OK,
                   InstancePath, False, cBack2Back, HINDEX, HMBINDEX);
      if    not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP       := False;
         RxData   := (others => '-');
      elsif not Compare(Data, CxData) then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Data);
         Write(L, String'(" : expected: "));
         HWrite(L, CxData);
         Write(L, String'(" # Error #"));
         WriteLine(Output, L);
         TP       := False;
         RxData   := Data;
      elsif ScreenOutput then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
         RxData   := Data;
      else
         RxData   := Data;
      end if;
   end procedure AHBComp;

   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AHB interface, no wait states
   -----------------------------------------------------------------------------
   procedure AHBMemory(
      constant gAWidth:       in    Positive := 15;      -- address width
      constant gDWidth:       in    Positive :=  8;      -- data width
      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;
      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;
      constant InstancePath:  in    String   := "AHBMemory";
      constant ScreenOutput:  in    Boolean  := False;
      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#) is

      -- memory definition
      subtype  ARange         is    Natural range 0 to 2**gAWidth-1;
      subtype  DRange         is    Natural range 0 to gDWidth-1;
      type     MType          is    array (ARange) of Integer;

      -- memory initialisation
      function Init return MType is
         variable r: MType;
      begin
         for i in ARange loop
            r(i) := -1;
         end loop;
         return r;
      end function Init;

      variable M:       MType;
      variable A:       Std_Logic_Vector(gAWidth-1 downto 0);
      variable D:       Std_Logic_Vector(0 to gDWidth-1);
      variable W:       Std_Logic;

      -- reset values
      procedure Reset is
      begin
         AHBOut.HREADY     <= '1';
         AHBOut.HRESP      <= HRESP_OKAY;
         AHBOut.HRDATA     <= (others => '0');
         W                 := '0';
      end procedure Reset;

      -- plug&play configuration
      constant HCONFIG : ahb_config_type := (
         0        => ahb_device_reg (0, 0, 0, gAWidth, 0),
         4        => ahb_membar(HADDR, '1', '1', HMASK),
         others   => zero32);
      variable alow : std_logic_vector(1 downto 0);

   begin
      -- fixed AMBA AHB signals, etc.
      AHBOut.HSPLIT        <= (others => '0');
      AHBOut.HCONFIG       <= HCONFIG;
      loop
         if HRESETn='0' then                             -- asynchronous reset
            Reset;

         elsif HCLK'Event and HCLK='1' then              -- rising edge
            -- data phase
            if AHBIn.HREADY='1' then
               if W='1' then
                  alow := A(1 downto 0);
                  case alow is
                     when "00" =>
                        D  := AHBIn.HWDATA(31 downto 24);
                     when "01" =>
                        D  := AHBIn.HWDATA(23 downto 16);
                     when "10" =>
                        D  := AHBIn.HWDATA(15 downto  8);
                     when others =>
                        D  := AHBIn.HWDATA( 7 downto  0);
                  end case;
                  M(Conv_Integer(A)) := Conv_Integer(D);
                  W := '0';
               end if;
            end if;

            -- address phase
            if    AHBIn.HSEL(HINDEX)='1'         and
                  AHBIn.HREADY='1'               and
                  AHBIn.HSIZE=HSIZE_BYTE         and
                  (AHBIn.HTRANS=HTRANS_SEQ    or
                   AHBIn.HTRANS=HTRANS_NONSEQ)   and
                  AHBIn.HMASTLOCK='0'            then
               W              := AHBIn.HWRITE;
               A              := AHBIn.HADDR(gAWidth-1 downto 0);
               AHBOut.HREADY  <= '1';
               AHBOut.HRESP   <= HRESP_OKAY;
               D              := Conv_Std_Logic_Vector(
                                    M(Conv_Integer(A)), D'Length);
               case alow is
                  when "00" =>
                     AHBOut.HRDATA(31 downto 24) <= D;
                  when "01" =>
                     AHBOut.HRDATA(23 downto 16) <= D;
                  when "10" =>
                     AHBOut.HRDATA(15 downto  8) <= D;
                  when others =>
                     AHBOut.HRDATA( 7 downto  0) <= D;
               end case;
            else
               w :='0';
               AHBOut.HREADY  <= '1';
               AHBOut.HRESP   <= HRESP_OKAY;
            end if;
         end if;

         -- signal sensitivity
         wait on HCLK, HRESETn;
      end loop;
   end procedure AHBMemory;

   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AHB interface, no wait states
   -----------------------------------------------------------------------------
   procedure AHBMemory32(
      constant gAWidth:       in    Positive := 18;      -- address width
      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;
      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;
      constant InstancePath:  in    String   := "AHBMemory32";
      constant ScreenOutput:  in    Boolean  := False;
      constant FileName:      in    String := "";        -- File name
      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#) is

      -- memory definition
      type     MType          is    array (0 to 2**(gAWidth-2)-1) of
                                       Std_Logic_Vector(31 downto 0);

      --------------------------------------------------------------------------
      -- Load memory contents
      --------------------------------------------------------------------------
      -- ## Does not warn if there is insufficient data in a line.
      -- Address read from file is  always byte oriented, always 32 bit wide
      -- For 16 and 32 bit wide data, each data word read from file must be on a
      -- single line and without white space between the characters. For 8 bit
      -- wide date, no restrictions apply. Files generated for 32 bit wide data
      -- can always be read by 16 or 8 bit memories. The byte/halfwrod address
      -- is incremented internally.
      --------------------------------------------------------------------------
      -- -----------------------------------------------------------------------
      -- -- PROM Initialisation Example
      -- -----------------------------------------------------------------------
      -- -- Supports by 8, 16, 32 bit wide memories
      -- 00000000  00010203
      -- 00000004  04050607    08090A0B
      -- 0000000C  0C0D0E0F
      --
      -- -- Supported by 8, 16 bit wide memories
      -- 00000010  1011 1213
      -- 00000014  1415
      -- 00000016  1617 1819 1A1B 1C1D 1E1F 2021
      -- 00000022  2223 2425 2627 2829 2A2B 2C2D 2E2F
      --
      -- -- Supported by 8 bit wide memories
      -- 00000030  30 31  32 33 3435 3637 3839   3A3B 3C3D  3E3F
      -- 00000040  40
      -- 00000041  41
      -- 00000042  42   43
      -- 00000044  4445
      -- 00000046  46474849
      -- 0000004A  4A4B 4C4D4E4F
      --------------------------------------------------------------------------
      impure function Initialise(
         constant FileName:   in    String   := "";
         constant AWidth:     in    Natural;
         constant DWidth:     in    Natural)
         return                     MType is

         variable L:                Line;
         variable Address:          Std_Logic_Vector(31 downto 0);
         variable Data:             Std_Logic_Vector(31 downto 0);
         variable Byte:             Std_Logic_Vector( 7 downto 0);
         variable Addr:             Natural range 0 to 2**AWidth-1;
         file     ReadFile:         Text;
         variable Test:             Boolean;
         variable Result:           MType;
      begin
         -- initialse all data to all zeros
         Result  := (others => (others => 'U'));
         -- load contents from file only if a file name has been provided
         if FileName /= "" then
            File_Open(ReadFile, FileName, Read_Mode);
            -- read data from file
            while not EndFile(ReadFile) loop
               -- read line
               ReadLine(ReadFile, L);

               -- read address, always byte oriented, always 32 bit wide
               HRead(L, Address, Test);
               if Test then                              -- address read
                  -- check whether byte address aligned with data width
                  if Conv_Integer(Address) mod (DWidth/8) /= 0 then
                     report "Unaligned data in memory initalisation file: " &
                            FileName
                        severity Failure;
                     Test     := False;
                  else                                   -- convert address
                     -- adapt byte address to address corresponding to the data
                     -- width of the memory
                     Addr     := (Conv_Integer(Address)/(DWidth/8)) mod
                                 (2**AWidth);

                  end if;
               else                                      -- comment detected
                  null;
               end if;
               while Test loop
                  -- read data
                  HRead(L, Data(DWidth-1 downto 0), Test);
                  if Test then
                     -- initialize memory element
                     Result(Addr)   := Data(DWidth-1 downto 0);
                     -- increment address, with the memory width
                     Addr           := (Addr + 1) mod (2**AWidth);
                  end if;
               end loop;

            end loop;
            File_Close(ReadFile);
         end if;

         return Result;
      end function Initialise;

      -- memory contents
      variable M:       MType := Initialise(FileName, gAWidth-2, 32);
      variable A:       Std_Logic_Vector(gAWidth-1 downto 2);
      variable W:       Std_Logic;

      -- reset values
      procedure Reset is
      begin
         AHBOut.HREADY     <= '1';
         AHBOut.HRESP      <= HRESP_OKAY;
         AHBOut.HRDATA     <= (others => '0');
         W                 := '0';
      end procedure Reset;

      -- plug&play configuration
      constant HCONFIG : ahb_config_type := (
         0        => ahb_device_reg (0, 0, 0, gAWidth, 0),
         4        => ahb_membar(HADDR, '1', '1', HMASK),
         others   => zero32);

   begin
      -- fixed AMBA AHB signals, etc.
      AHBOut.HSPLIT        <= (others => '0');
      AHBOut.HCONFIG       <= HCONFIG;
      loop
         if HRESETn='0' then                             -- asynchronous reset
            Reset;

         elsif HCLK'Event and HCLK='1' then              -- rising edge
            -- data phase
            if AHBIn.HREADY='1' then
               if W='1' then
                  M(Conv_Integer(A)) := AHBIn.HWDATA(31 downto 0);
                  W := '0';
               end if;
            end if;

            -- address phase
            if    AHBIn.HSEL(HINDEX)='1'         and
                  AHBIn.HREADY='1'               and
                  AHBIn.HSIZE=HSIZE_WORD         and
                  (AHBIn.HTRANS=HTRANS_SEQ    or
                   AHBIn.HTRANS=HTRANS_NONSEQ)   and
                  AHBIn.HMASTLOCK='0'            then
               W              := AHBIn.HWRITE;
               A              := AHBIn.HADDR(gAWidth-1 downto 2);
               AHBOut.HREADY  <= '1';
               AHBOut.HRESP   <= HRESP_OKAY;
               AHBOut.HRDATA  <= ahbdrivedata(M(Conv_Integer(A)));
            else
               W :='0';
               AHBOut.HREADY  <= '1';
               AHBOut.HRESP   <= HRESP_OKAY;
            end if;
         end if;

         -- signal sensitivity
         wait on HCLK, HRESETn;
      end loop;
   end procedure AHBMemory32;


   -----------------------------------------------------------------------------
   -- Behavioural model of memory with AHB interface, no wait states
   -- Supporting byte, halfword and word read/write accesses.
   -- Provices diagnostic support.
   -----------------------------------------------------------------------------
   procedure AHBMemory32(
      constant gAWidth:       in    Positive := 18;      -- address width

      signal   HCLK:          in    Std_ULogic;
      signal   HRESETn:       in    Std_ULogic;

      signal   AHBIn:         in    AHB_Slv_In_Type;
      signal   AHBOut:        out   AHB_Slv_Out_Type;

      signal   AHBInDiag:     in    AHB_Diagnostics_In_Type;
      signal   AHBOutDiag:    out   AHB_Diagnostics_Out_Type;

      constant InstancePath:  in    String   := "AHBMemory32";
      constant ScreenOutput:  in    Boolean  := False;
      constant FileName:      in    String   := "";      -- File name

      constant HINDEX:        in    Integer  := 0;
      constant HADDR:         in    Integer  := 0;
      constant HMASK:         in    Integer  := 16#FFF#) is

      -- memory definition
      type     MType          is    array (0 to 2**(gAWidth-2)-1) of
                                       Std_Logic_Vector(31 downto 0);

      variable L:                   Line;
      constant Padding:             Std_ULogic_Vector(1 to
                                                 (4-((gAWidth-2) mod 4))) :=
                                    (others => '0');

      --------------------------------------------------------------------------
      -- Load memory contents
      --------------------------------------------------------------------------
      -- ## Does not warn if there is insufficient data in a line.
      -- Address read from file is  always byte oriented, always 32 bit wide
      -- For 16 and 32 bit wide data, each data word read from file must be on a
      -- single line and without white space between the characters. For 8 bit
      -- wide date, no restrictions apply. Files generated for 32 bit wide data
      -- can always be read by 16 or 8 bit memories. The byte/halfwrod address
      -- is incremented internally.
      --------------------------------------------------------------------------
      -- -----------------------------------------------------------------------
      -- -- PROM Initialisation Example
      -- -----------------------------------------------------------------------
      -- -- Supports by 8, 16, 32 bit wide memories
      -- 00000000  00010203
      -- 00000004  04050607    08090A0B
      -- 0000000C  0C0D0E0F
      --
      -- -- Supported by 8, 16 bit wide memories
      -- 00000010  1011 1213
      -- 00000014  1415
      -- 00000016  1617 1819 1A1B 1C1D 1E1F 2021
      -- 00000022  2223 2425 2627 2829 2A2B 2C2D 2E2F
      --
      -- -- Supported by 8 bit wide memories
      -- 00000030  30 31  32 33 3435 3637 3839   3A3B 3C3D  3E3F
      -- 00000040  40
      -- 00000041  41
      -- 00000042  42   43
      -- 00000044  4445
      -- 00000046  46474849
      -- 0000004A  4A4B 4C4D4E4F
      --------------------------------------------------------------------------
      impure function Initialise(
         constant FileName:   in    String   := "";
         constant AWidth:     in    Natural;
         constant DWidth:     in    Natural)
         return                     MType is

         variable L:                Line;
         variable Address:          Std_Logic_Vector(31 downto 0);
         variable Data:             Std_Logic_Vector(31 downto 0);
         variable Byte:             Std_Logic_Vector( 7 downto 0);
         variable Addr:             Natural range 0 to 2**AWidth-1;
         file     ReadFile:         Text;
         variable Test:             Boolean;
         variable Result:           MType;
      begin
         -- initialse all data to all zeros
         Result  := (others => (others => 'U'));
         -- load contents from file only if a file name has been provided
         if FileName /= "" then
            File_Open(ReadFile, FileName, Read_Mode);
            -- read data from file
            while not EndFile(ReadFile) loop
               -- read line
               ReadLine(ReadFile, L);
               -- read address, always byte oriented, always 32 bit wide
               HRead(L, Address, Test);
               if Test then                              -- address read
                  -- check whether byte address aligned with data width
                  if Conv_Integer(Address) mod (DWidth/8) /= 0 then
                     report "Unaligned data in memory initalisation file: " &
                            FileName
                        severity Failure;
                     Test     := False;
                  else                                   -- convert address
                     -- adapt byte address to address corresponding to the data
                     -- width of the memory
                     Addr     := (Conv_Integer(Address)/(DWidth/8)) mod
                                 (2**AWidth);
                  end if;
               else                                      -- comment detected
                  null;
               end if;
               while Test loop
                  -- read data
                  HRead(L, Data(DWidth-1 downto 0), Test);
                  if Test then
                     -- initialize memory element
                     Result(Addr)   := Data(DWidth-1 downto 0);
                     -- increment address, with the memory width
                     Addr           := (Addr + 1) mod (2**AWidth);
                  end if;
               end loop;

            end loop;
            File_Close(ReadFile);
         end if;

         return Result;
      end function Initialise;

      -- memory contents
      variable M:       MType := Initialise(FileName, gAWidth-2, 32);
      variable A:       Std_Logic_Vector(gAWidth-1 downto 2);
      variable B:       Std_Logic_Vector(1 downto 0);
      variable W:       Std_Logic;
      variable S:       Std_Logic_Vector(2 downto 0);
      variable D:       Std_Logic_Vector(31 downto 0);
      variable twocycle:Boolean := False;

      -- reset values
      procedure Reset is
      begin
         AHBOut.HREADY     <= '1';
         AHBOut.HRESP      <= HRESP_OKAY;
         AHBOut.HRDATA     <= (others => '0');
         W                 := '0';
         twocycle          := False;
      end procedure Reset;

      -- plug&play configuration
      constant HCONFIG : ahb_config_type := (
         0        => ahb_device_reg (0, 0, 0, gAWidth, 0),
         4        => ahb_membar(HADDR, '1', '1', HMASK),
         others   => zero32);

   begin
      -- fixed AMBA AHB signals, etc.
      AHBOut.HSPLIT        <= (others => '0');
      AHBOut.HCONFIG       <= HCONFIG;
      loop
         if HRESETn='0' then                             -- asynchronous reset
            Reset;

         elsif HCLK'Event and HCLK='1' then              -- rising edge
            -- data phase
            if AHBIn.HREADY='1' then
               if W='1' then
                  -- read back memory
                  D                    := M(Conv_Integer(A));
                  -- replace with new data
                  if    S="000" then                     -- byte
                     if    B(1 downto 0)="00" then
                        D              := AHBIn.HWDATA(31 downto 24) &
                                          D(23 downto 0);
                     elsif B(1 downto 0)="01" then
                        D              := D(31 downto 24) &
                                          AHBIn.HWDATA(23 downto 16) &
                                          D(15 downto 0);
                     elsif B(1 downto 0)="10" then
                        D              := D(31 downto 16) &
                                          AHBIn.HWDATA(15 downto 8) &
                                          D(7 downto 0);
                     elsif B(1 downto 0)="11" then
                        D              := D(31 downto 8) &
                                          AHBIn.HWDATA(7 downto 0);
                     end if;
                  elsif S="001" then                     -- halfword
                     if    B(1 downto 0)="00" then
                        D              := AHBIn.HWDATA(31 downto 16) &
                                          D(15 downto 0);
                     elsif B(1 downto 0)="10" then
                        D              := D(31 downto 16) &
                                          AHBIn.HWDATA(15 downto 0);
                     end if;
                  else
                        D              := AHBIn.HWDATA(31 downto 0);
                  end if;
                  -- write back memory
                  M(Conv_Integer(A))   := D;
                  W                    := '0';

                  -- comment
                  if ScreenOutput then
                     Write(L, Now, Right, 15);
                     Write(L, " : " & InstancePath & " Write acces to address :");
                     if Padding'Length > 0 and Padding'Length < 4 then
                        HWrite(L, Std_Logic_Vector(Padding) & Std_Logic_Vector(A));
                     else
                        HWrite(L, Std_Logic_Vector(A));
                     end if;
                     Write(L, String'(" data :"));
                     HWrite(L, D);
                     Write(L, String'(" data :"));
                     Write(L, To_BitVector(D));
                     Write(L, String'(" size :"));
                     HWrite(L, "0" & S);
                     WriteLine(Output, L);
                  end if;

               end if;
            end if;

            -- address phase
            if    AHBIn.HSEL(HINDEX)='1'         and
                  AHBIn.HREADY='1'               and
                  (AHBIn.HSIZE=HSIZE_BYTE  or
                   AHBIn.HSIZE=HSIZE_HWORD or
                   AHBIn.HSIZE=HSIZE_WORD)       and
                  (AHBIn.HTRANS=HTRANS_SEQ    or
                   AHBIn.HTRANS=HTRANS_NONSEQ)   and
                  AHBIn.HMASTLOCK='0'            then

               if    AHBInDiag.HRESP=HRESP_OKAY then
                  W              := AHBIn.HWRITE;
                  S              := AHBIn.HSIZE;
                  B              := AHBIn.HADDR(        1 downto 0);
                  A              := AHBIn.HADDR(gAWidth-1 downto 2);
                  AHBOut.HREADY  <= '1';
                  AHBOut.HRESP   <= HRESP_OKAY;
                  AHBOut.HRDATA  <= ahbdrivedata(M(Conv_Integer(A)));
               elsif AHBInDiag.HRESP=HRESP_RETRY then
                  W              :='0';
                  AHBOut.HREADY  <= '0';
                  AHBOut.HRESP   <= HRESP_RETRY;
                  AHBOut.HRDATA  <= (others => 'X');
                  twocycle       := True;
               elsif AHBInDiag.HRESP=HRESP_SPLIT then
                  W              :='0';
                  AHBOut.HREADY  <= '0';
                  AHBOut.HRESP   <= HRESP_SPLIT;
                  AHBOut.HRDATA  <= (others => 'X');
                  twocycle       := True;
               else
                  W              :='0';
                  AHBOut.HREADY  <= '0';
                  AHBOut.HRESP   <= HRESP_ERROR;
                  AHBOut.HRDATA  <= (others => 'X');
                  twocycle       := True;
               end if;
            else
               W :='0';
               AHBOut.HREADY     <= '1';
               if twocycle then
                  twocycle       := False;
               else
                  AHBOut.HRESP   <= HRESP_OKAY;
               end if;
            end if;
         end if;

         if HCLK'Event and HCLK='1' then                 -- rising edge
            -- diagnostics
            AHBOutDiag.HRData <= M((Conv_Integer(AHBInDiag.HAddr)/4) mod (2**(gAWidth-2)));
            if AHBInDiag.HWrite='1' then
               M((Conv_Integer(AHBInDiag.HAddr)/4) mod (2**(gAWidth-2))) := AHBInDiag.HWData;
--               Print("Diagnostic write to memory, address: " &
--                     Integer'Image(Conv_Integer(AHBInDiag.HAddr)) &
--                     " data: " &
--                     Integer'Image(Conv_Integer(AHBInDiag.HWData)));
            end if;
            AHBOut.HSPLIT     <= AHBInDiag.HSplit;
         end if;


         -- signal sensitivity
         wait on HCLK, HRESETn;
      end loop;
   end procedure AHBMemory32;

   -----------------------------------------------------------------------------
   -- Routine for writig data directly to AHB memory
   -----------------------------------------------------------------------------
   procedure WrAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      constant Data:       in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in    AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False) is
      variable L:                Line;
   begin
      Synchronise(HCLK);
      if Screen then
         Write(L, Now, Right, 15);
         Write(L, String'(" : WrAHBMem32: "));
         HWrite(L, Std_Logic_Vector(Addr));
         Write(L, String'(" : "));
         HWrite(L, Std_Logic_Vector(Data));
         if Comment /= "" then
            Write(L, " : " & Comment);
         end if;
         WriteLine(Output, L);
      end if;
      AHBInDiag.HAddr   <= Addr;
      AHBInDiag.HWData  <= Data;
      AHBInDiag.HWrite  <= '1';
      Synchronise(HCLK);
      AHBInDiag.HWrite  <= '0';
   end procedure WrAHBMem32;

   -----------------------------------------------------------------------------
   -- Routine for reading data directly from AHB memory
   -----------------------------------------------------------------------------
   procedure RdAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      variable Data:       out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in   AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False) is
      variable L:                Line;
   begin
      Synchronise(HCLK);
      AHBInDiag.HAddr   <= Addr;
      AHBInDiag.HWrite  <= '0';
      Synchronise(HCLK);
      Data        := AHBOutDiag.HRData;
      if Screen then
         Write(L, Now, Right, 15);
         Write(L, String'(" : RdAHBMem32: "));
         HWrite(L, Std_Logic_Vector(Addr));
         Write(L, String'(" : "));
         HWrite(L, Std_Logic_Vector(AHBOutDiag.HRData));
         if Comment /= "" then
            Write(L, " : " & Comment);
         end if;
         WriteLine(Output, L);
      end if;
   end procedure RdAHBMem32;

   -----------------------------------------------------------------------------
   -- Routine for reading data directly from AHB memory
   -----------------------------------------------------------------------------
   procedure RcAHBMem32(
      constant Addr:       in    Std_Logic_Vector(31 downto 0);
      constant Expected:   in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in    AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False) is
      variable Data:             Std_Logic_Vector(31 downto 0);
      variable L:                Line;
   begin
      Synchronise(HCLK);
      AHBInDiag.HAddr      <= Addr;
      AHBInDiag.HWrite     <= '0';
      Synchronise(HCLK);
      Data        := AHBOutDiag.HRData;
      if not Compare(Data, Expected) then
         Write(L, Now, Right, 15);
         Write(L, String'(" : RcAHBMem32: "));
         HWrite(L, Std_Logic_Vector(Addr));
         Write(L, String'(", value: "));
         HWrite(L, Std_Logic_Vector(Data));
         Write(L, String'(", expected: "));
         HWrite(L, Std_Logic_Vector(Expected));
         Write(L, String'(" # Error "));
         if Comment /= "" then
            Write(L, " : " & Comment);
         end if;
         WriteLine(Output, L);
         TP := False;
      elsif Screen then
         Write(L, Now, Right, 15);
         Write(L, String'(" : RcAHBMem32: "));
         HWrite(L, Std_Logic_Vector(Addr));
         Write(L, String'(" : "));
         HWrite(L, Std_Logic_Vector(Data));
         Write(L, String'(" : "));
         HWrite(L, Std_Logic_Vector(Expected));
         if Comment /= "" then
            Write(L, " : " & Comment);
         end if;
         WriteLine(Output, L);
      end if;
   end procedure RcAHBMem32;

   -----------------------------------------------------------------------------
   -- Routine for generating a split ack from AHB memory
   -----------------------------------------------------------------------------
   procedure SplitAHBMem32(
      constant Split:      in    Integer range 0 to NAHBMST-1;
      signal   HCLK:       in    Std_ULogic;
      signal   AHBInDiag:  out   AHB_Diagnostics_In_Type;
      signal   AHBOutDiag: in   AHB_Diagnostics_Out_Type;
      variable TP:         inout Boolean;
      constant Comment:    in    String   := "";
      constant Screen:     in    Boolean  := False) is
      variable L:                Line;
   begin
      Synchronise(HCLK);
      AHBInDiag.HSPLIT        <= (others => '0');
      AHBInDiag.HSPLIT(Split) <= '1';
      Synchronise(HCLK);
      AHBInDiag.HSPLIT        <= (others => '0');
      if Screen then
         Write(L, Now, Right, 15);
         Write(L, String'(" : SplitAHBMem32: split acknowledge to master: "));
         Write(L, Split);
         if Comment /= "" then
            Write(L, " : " & Comment);
         end if;
         WriteLine(Output, L);
      end if;
   end procedure SplitAHBMem32;
end package body AMBA_TestPackage; --=========================================--

