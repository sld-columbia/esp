
//// Create Telemetry Transfer Frame with single Space Packet
//TMTF(
//   int SpacecraftID,
//   int VCID,
//   int OCFFlag,
//   int MCFrameCntr,
//   int VCFrameCntr,
//   int FSHFlag,
//   int SyncFlag,
//   int PktOrderFlag,
//   int SegmentID,
//   int FHP,
//   long int OCF,
//   int FECF,
//   long int SequenceCount,
//   int FrameLength,
//   unsigned char *data)
//{
//   int   VersionField = 0;
//   int   DataFieldLength = FrameLength-6-OCFFlag*4-FECF*2;
//
//   int   VersionId = 0;
//   int   TypeIdentifier = 0;
//   int   HeaderFlag = 0;
//   int   ApplicationId = VCID;
//   int   SegmentFlags = 3;
//   int   ErrorControl = 0;
//   int   PacketLength = DataFieldLength-6-ErrorControl*2;
//
//   int   Index = 0;
//
//   int   i;
//
//      // Transfer Frame Primary Header
//      data[Index]        = (VersionField<<6) | ((SpacecraftID & 0x3f0) >> 4);
//      Index++;
//      data[Index]        = ((SpacecraftID & 0xF)<<4) | (VCID <<1) | OCFFlag;
//      Index++;
//      data[Index]        = MCFrameCntr & 0xff;
//      Index++;
//      data[Index]        = VCFrameCntr & 0xff;
//      Index++;
//      data[Index]        = (FSHFlag<<7) | (SyncFlag << 6) | (PktOrderFlag<<5) | (SegmentID<<3) | ((FHP & 0x700)>>8);
//      Index++;
//      data[Index]        = FHP & 0xff;
//      Index++;
//
//      // Transfer Frame Secondary Header
//      // not supported
//
//      // Transfer Frame Data Field
//      // Space Packet Header
//      //    Packet Identification
//      data[Index] = (VersionId<<5) | (TypeIdentifier<<4) | (HeaderFlag<<3) | ((ApplicationId & 0x700)>>8);
//      Index++;
//      data[Index] = ApplicationId & 0xff;
//      Index++;
//
//      //    Packet Sequence Control
//      data[Index] = (SegmentFlags<<6) |  ((SequenceCount & 0x3F00)>>8);
//      Index++;
//      data[Index] = SequenceCount & 0xff;
//      Index++;
//
//      //    Packet Length
//      data[Index] = ((PacketLength-1) & 0xff00) >> 8;
//      Index++;
//      data[Index] = (PacketLength-1) & 0xff;
//      Index++;
//
//      //    Packet Data Field
//      for (i=0; i<PacketLength; i++) {
//         data[Index] = i & 0xff;
//         Index++;
//      };
//
//      //    Packet Error Control
//      // not supported
//
//      // Transfer Frame Trailer
//      // Operational Control Field
//      if (OCFFlag) {
//            data[Index]  = (OCF >> 8*3) & 0xff;
//            Index++;
//            data[Index]  = (OCF >> 8*2) & 0xff;
//            Index++;
//            data[Index]  = (OCF >> 8*1) & 0xff;
//            Index++;
//            data[Index]  = (OCF) & 0xff;
//            Index++;
//         };
//
//      // Frame Error Control Field
//      // only dummy date, assumes that FECF is overwritten by hardware
//      if (FECF=1) {
//         data[Index] =0; //    = CRC(Result(0 to Index-1))(0);
//         Index++;
//         data[Index] =0; //    = CRC(Result(0 to Index-2))(1);
//         Index++;
//      };
//};


grtc_test(int paddr, int buffersize)
   {

   // start of test
   report_device(0x01031000);

   // register structures
   struct grtc_reg {
      volatile unsigned long grr;            /* 0x00 */
      volatile unsigned long gcr;            /* 0x04 */
      volatile unsigned long pmr;            /* 0x08 */
      volatile unsigned long sir;            /* 0x0C */
      volatile unsigned long far;            /* 0x10 */
      volatile unsigned long clcwr1;         /* 0x14 */
      volatile unsigned long clcwr2;         /* 0x18 */
      volatile unsigned long phir;           /* 0x1C */
      volatile unsigned long cor ;           /* 0x20 */
      volatile unsigned long str;            /* 0x24 */
      volatile unsigned long asr;            /* 0x28 */
      volatile unsigned long rrp;            /* 0x2C */
      volatile unsigned long rwp;            /* 0x30 */
      volatile unsigned long dummy0;         /* 0x34 */
      volatile unsigned long dummy1;         /* 0x38 */
      volatile unsigned long dummy2;         /* 0x3C */
      volatile unsigned long dummy3;         /* 0x40 */
      volatile unsigned long dummy4;         /* 0x44 */
      volatile unsigned long dummy5;         /* 0x48 */
      volatile unsigned long dummy6;         /* 0x4C */
      volatile unsigned long dummy7;         /* 0x50 */
      volatile unsigned long dummy8;         /* 0x54 */
      volatile unsigned long dummy9;         /* 0x58 */
      volatile unsigned long dummy10;        /* 0x5C */
      volatile unsigned long pimsr;          /* 0x60 */
      volatile unsigned long pimr;           /* 0x64 */
      volatile unsigned long pisr;           /* 0x68 */
      volatile unsigned long pir;            /* 0x6C */
      volatile unsigned long imr;            /* 0x70 */
      volatile unsigned long picr;           /* 0x74 */
   };

   // local registers
   struct grtc_reg   *ltc =  (struct grtc_reg*) (paddr);

   // reset ccsds telecommand encoders -----------------------------------------
   report_subtest(0x0);

   // Global Reset Register (GRR)
   int SEB  = 0x55;
   int SRST = 1;
   ltc->grr = (SEB<<24) | (SRST);

   // Global Control Register (GCR)
   int PSS  = 0;
   int NRZM = 0;
   int PSR  = 0;
   ltc->gcr= (SEB<<24) | (PSS<<12) | (NRZM<<11) | (PSR<<10);

   // Physical Interface Mask Register (PMR)
   int MASK = 0;
   ltc->pmr= MASK;

   // Spacecraft Identifier Register (SIR)
//   int SCID = 0;
//   ltc->sir= SCID;

   // Frame Acceptance Report Register (FAR)
//   int SSD = 0;
//   int CAC = 0;
//   int CSEC = 0;
//   int SCI = 0;
//   ltc->far= (SSD<<31) | (CAC<<19) | (CSEC<<16) | (SCI<<11);

   // CLCW Register 1 (CLCWR1)
   int CWTY       = 0;
   int VNUM       = 0;
   int STAF       = 0;
   int CIE        = 0;
   int VCI        = 0;
   int NRFA       = 0;
   int NBLO       = 0;
   int LOUT       = 0;
   int WAIT       = 0;
   int RTMI       = 0;
   int FBCO       = 0;
   int RTYPE      = 0;
   int RVAL       = 0;
//   ltc->clcwr1= (CWTY<<31) | (VNUM<<29) | (STAF<<26) | (CIE<<24) |
//                (VCI<<18) | (NRFA<<15) | (NBLO<<14) | (LOUT<<13) |
//                (WAIT<<12) | (RTMI<<11) | (FBCO<<9) | (RTYPE<<8) | (RVAL<<0);

   // CLCW Register 2 (CLCWR2)
//   ltc->clcwr2= (CWTY<<31) | (VNUM<<29) | (STAF<<26) | (CIE<<24) |
//                (VCI<<18) | (NRFA<<15) | (NBLO<<14) | (LOUT<<13) |
//                (WAIT<<12) | (RTMI<<11) | (FBCO<<9) | (RTYPE<<8) | (RVAL<<0);

   // Physical Interface Register (PHIR)
//   int RFA = 0;
//   int BLO = 0;
//   ltc->phir= (RFA<<8) | (BLO);



   //-- setup dma --------------------------------------

   // allocate memory for frames
   volatile long int framememory[buffersize/4];

   // search for start of allocated memory
   long int framememorybase;
   framememorybase = (long int)&framememory[0];

   // search for 1k boundary within allocated memory, store as base
   framememorybase = framememorybase & 0xFFFFFC00;
   framememorybase = framememorybase + 0x400;
//
//   // dma descr
//   int BASE   = descmemorybase >> 10;
//   int INDEX  = 0;
//   ltc->descr= (BASE<<10) | (INDEX<<3);

   // Status Register (STR)
//   int RBF  = 0;
//   int RFF  = 0;
//   int OV   = 0;
//   int CR   = 0;
//   ltc->str= (RBF<<10) | (RFF<<7) | (OV<<4) | (CR);

   // Address Space Register (ASR)
   int BUFST = (framememorybase >> 10) & 0x003FFFFF;
   int RXLEN = (buffersize/1024 - 1) & 0x3FF;
   ltc->asr= (BUFST<<10) | (RXLEN);

//   // Receive Read Pointer Register (RRP)
//   int RXRDPR = framememorybase;
//   ltc->rrp= RXRDPR;

   // Receive Write Pointer Register (RWP)
//   int RXWRPR = 0;
//   ltc->rwp= RXRDPR;

   // Pending Interrupt Masked Status Register (PIMSR)
   int PCS  = 0;
   int POV  = 0;
   int PRBF = 0;
   int PCR  = 0;
   int PFAR = 0;
   int PBLO = 0;
   int PRFA = 0;
//   ltc->pimsr = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Pending Interrupt Masked Register (PIMR)
//   ltc->pimr = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Pending Interrupt Status Register (PISR)
//   ltc->pisr = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Pending Interrupt Register (PIR)
//   ltc->pir = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Interrupt Mask Register (IMR)
//   ltc->imr = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Pending Interrupt Clear Register (PICR)
//   ltc->picr = (PCS<<6) | (POV<<5) | (PRBF<<4) | (PCR<<3) | (PFAR<<2) | (PBLO<<1) | (PRFA);

   // Control Register (COR)
   int CRST = 0;
   int RE   = 1;
   ltc->cor= (SEB<<24) | (CRST<<9) | (RE);

   // tx ctrl - release reset to ccsds telecommand transmitter -----------------
   report_subtest(0x1);

   // request the first frame
   report_subtest(0x2);
   // wait for receiver interrupt
   while ((ltc->pir & 0x40) != 0x40) ;


   volatile int *memoryrx;
   memoryrx = (int*)framememorybase;

   // Transfer CLTU: 0
   if (0x10010500 != *memoryrx) fail(1); memoryrx++;
   if (0xC0000000 != *memoryrx) fail(1); memoryrx++;
   if (0x00000700 != *memoryrx) fail(1); memoryrx++;
   if (0x00000100 != *memoryrx) fail(1); memoryrx++;
   if (0x02000300 != *memoryrx) fail(1); memoryrx++;
   if (0x04000500 != *memoryrx) fail(1); memoryrx++;
   if (0x3700C500 != *memoryrx) fail(1); memoryrx++;
//   if (0x00020000 != *memoryrx) fail(18);

   // Global Control Register (GCR)
   NRZM = 1;
   PSR  = 0;
   ltc->gcr= (SEB<<24) | (PSS<<12) | (NRZM<<11) | (PSR<<10);
   // request the second frame
   report_subtest(0x3);
   // wait for receiver interrupt
   while ((ltc->pir & 0x40) != 0x40) ;

   // Transfer CLTU, with NRZ-Mark: 1
   if (0x00021001 != *memoryrx) fail(2); memoryrx++;
   if (0x0500C000 != *memoryrx) fail(2); memoryrx++;
   if (0x01000000 != *memoryrx) fail(2); memoryrx++;
   if (0x0E000000 != *memoryrx) fail(2); memoryrx++;
   if (0x01000200 != *memoryrx) fail(2); memoryrx++;
   if (0x03000400 != *memoryrx) fail(2); memoryrx++;
   if (0x05000600 != *memoryrx) fail(2); memoryrx++;
   if (0x07000800 != *memoryrx) fail(2); memoryrx++;
   if (0x09000A00 != *memoryrx) fail(2); memoryrx++;
   if (0x0B000C00 != *memoryrx) fail(2); memoryrx++;
   if (0xC7005F00 != *memoryrx) fail(2); memoryrx++;
//   if (0x00020000 != *memoryrx) fail(2);

   // Global Control Register (GCR)
   NRZM = 0;
   PSR  = 1;
   ltc->gcr= (SEB<<24) | (PSS<<12) | (NRZM<<11) | (PSR<<10);
   // request the third frame
   report_subtest(0x4);
   // wait for receiver interrupt
   while ((ltc->pir & 0x40) != 0x40) ;

   // Transfer CLTU, with Pseudo: 2
   if (0x00021001 != *memoryrx) fail(3); memoryrx++;
   if (0x0500C000 != *memoryrx) fail(3); memoryrx++;
   if (0x02000000 != *memoryrx) fail(3); memoryrx++;
   if (0x15000000 != *memoryrx) fail(3); memoryrx++;
   if (0x01000200 != *memoryrx) fail(3); memoryrx++;
   if (0x03000400 != *memoryrx) fail(3); memoryrx++;
   if (0x05000600 != *memoryrx) fail(3); memoryrx++;
   if (0x07000800 != *memoryrx) fail(3); memoryrx++;
   if (0x09000A00 != *memoryrx) fail(3); memoryrx++;
   if (0x0B000C00 != *memoryrx) fail(3); memoryrx++;
   if (0x0D000E00 != *memoryrx) fail(3); memoryrx++;
   if (0x0F001000 != *memoryrx) fail(3); memoryrx++;
   if (0x11001200 != *memoryrx) fail(3); memoryrx++;
   if (0x13007D00 != *memoryrx) fail(3); memoryrx++;
   if (0xBC000002 != *memoryrx) fail(3); memoryrx++;

   // Global Control Register (GCR)
   NRZM = 1;
   PSR  = 1;
   ltc->gcr= (SEB<<24) | (PSS<<12) | (NRZM<<11) | (PSR<<10);
   // request the fourth frame
   report_subtest(0x5);
   // wait for receiver interrupt
   while ((ltc->pir & 0x40) != 0x40) ;

   // Transfer CLTU, with NRZ-Mark and Pseudo: 3
   if (0x10010500 != *memoryrx) fail(4); memoryrx++;
   if (0xC0000300 != *memoryrx) fail(4); memoryrx++;
   if (0x00001C00 != *memoryrx) fail(4); memoryrx++;
   if (0x00000100 != *memoryrx) fail(4); memoryrx++;
   if (0x02000300 != *memoryrx) fail(4); memoryrx++;
   if (0x04000500 != *memoryrx) fail(4); memoryrx++;
   if (0x06000700 != *memoryrx) fail(4); memoryrx++;
   if (0x08000900 != *memoryrx) fail(4); memoryrx++;
   if (0x0A000B00 != *memoryrx) fail(4); memoryrx++;
   if (0x0C000D00 != *memoryrx) fail(4); memoryrx++;
   if (0x0E000F00 != *memoryrx) fail(4); memoryrx++;
   if (0x10001100 != *memoryrx) fail(4); memoryrx++;
   if (0x12001300 != *memoryrx) fail(4); memoryrx++;
   if (0x14001500 != *memoryrx) fail(4); memoryrx++;
   if (0x16001700 != *memoryrx) fail(4); memoryrx++;
   if (0x18001900 != *memoryrx) fail(4); memoryrx++;
   if (0x1A004B00 != *memoryrx) fail(4); memoryrx++;
   if (0x11000002 != *memoryrx) fail(4); memoryrx++;


   // Receive Write Pointer Register (RWP)
   int RXWRPR = (int)memoryrx;
   if (ltc->rwp != RXWRPR) fail(5);

   report_subtest(0x6);
}

////#   GRTC subtest action 2
//# Transfer CLTU: 0
//# EB
//# 90
//# 10
//# 05
//# C0
//# 00
//# 00
//# 07
//# 00
//# 92
//# 01
//# 02
//# 03
//# 04
//# 05
//# 37
//# C5
//# 40
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# 79
//#
//#   GRTC subtest action 3
//# Transfer CLTU, with NRZ-Mark: 1
//# EB
//# 90
//# 10
//# 05
//# C0
//# 01
//# 00
//# 0E
//# 00
//# 96
//# 01
//# 02
//# 03
//# 04
//# 05
//# 06
//# 07
//# 70
//# 08
//# 09
//# 0A
//# 0B
//# 0C
//# C7
//# 5F
//# 60
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# 79
//#
//#   GRTC subtest action 4
//# Transfer CLTU, with Pseudo: 2
//# EB
//# 90
//# 10
//# 05
//# C0
//# 02
//# 00
//# 15
//# 00
//# 9A
//# 01
//# 02
//# 03
//# 04
//# 05
//# 06
//# 07
//# 70
//# 08
//# 09
//# 0A
//# 0B
//# 0C
//# 0D
//# 0E
//# 1A
//# 0F
//# 10
//# 11
//# 12
//# 13
//# 7D
//# BC
//# A6
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# 79
//#
//#   GRTC subtest action 5
//# Transfer CLTU, with NRZ-Mark and Pseudo: 3
//# EB
//# 90
//# 10
//# 05
//# C0
//# 03
//# 00
//# 1C
//# 00
//# 9E
//# 01
//# 02
//# 03
//# 04
//# 05
//# 06
//# 07
//# 70
//# 08
//# 09
//# 0A
//# 0B
//# 0C
//# 0D
//# 0E
//# 1A
//# 0F
//# 10
//# 11
//# 12
//# 13
//# 14
//# 15
//# 2E
//# 16
//# 17
//# 18
//# 19
//# 1A
//# 4B
//# 11
//# 9A
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# C5
//# 79
//#
