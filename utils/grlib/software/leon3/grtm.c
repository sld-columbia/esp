
// Create Telemetry Transfer Frame with single Space Packet
TMTF(
    int SpacecraftID,
    int VCID,
    int OCFFlag,
    int MCFrameCntr,
    int VCFrameCntr,
    int FSHFlag,
    int SyncFlag,
    int PktOrderFlag,
    int SegmentID,
    int FHP,
    long int OCF,
    int FECF,
    long int SequenceCount,
    int FrameLength,
    unsigned char *data)
{
    int   VersionField = 0;
    int   DataFieldLength = FrameLength-6-OCFFlag*4-FECF*2;

    int   VersionId = 0;
    int   TypeIdentifier = 0;
    int   HeaderFlag = 0;
    int   ApplicationId = VCID;
    int   SegmentFlags = 3;
    int   ErrorControl = 0;
    int   PacketLength = DataFieldLength-6-ErrorControl*2;

    int   Index = 0;

    int   i;

    // Transfer Frame Primary Header
    data[Index]        = (VersionField<<6) | ((SpacecraftID & 0x3f0) >> 4);
    Index++;
    data[Index]        = ((SpacecraftID & 0xF)<<4) | (VCID <<1) | OCFFlag;
    Index++;
    data[Index]        = MCFrameCntr & 0xff;
    Index++;
    data[Index]        = VCFrameCntr & 0xff;
    Index++;
    data[Index]        = (FSHFlag<<7) | (SyncFlag << 6) | (PktOrderFlag<<5) | (SegmentID<<3) | ((FHP & 0x700)>>8);
    Index++;
    data[Index]        = FHP & 0xff;
    Index++;

    // Transfer Frame Secondary Header
    // not supported

    // Transfer Frame Data Field
    // Space Packet Header
    //    Packet Identification
    data[Index] = (VersionId<<5) | (TypeIdentifier<<4) | (HeaderFlag<<3) | ((ApplicationId & 0x700)>>8);
    Index++;
    data[Index] = ApplicationId & 0xff;
    Index++;

    //    Packet Sequence Control
    data[Index] = (SegmentFlags<<6) |  ((SequenceCount & 0x3F00)>>8);
    Index++;
    data[Index] = SequenceCount & 0xff;
    Index++;

    //    Packet Length
    data[Index] = ((PacketLength-1) & 0xff00) >> 8;
    Index++;
    data[Index] = (PacketLength-1) & 0xff;
    Index++;

    //    Packet Data Field
    for (i=0; i<PacketLength; i++) {
        data[Index] = i & 0xff;
        Index++;
    };

    //    Packet Error Control
    // not supported

    // Transfer Frame Trailer
    // Operational Control Field
    if (OCFFlag) {
        data[Index]  = (OCF >> 8*3) & 0xff;
        Index++;
        data[Index]  = (OCF >> 8*2) & 0xff;
        Index++;
        data[Index]  = (OCF >> 8*1) & 0xff;
        Index++;
        data[Index]  = (OCF) & 0xff;
        Index++;
    };

    // Frame Error Control Field
    // only dummy date, assumes that FECF is overwritten by hardware
    if (FECF=1) {
        data[Index] =0; //    = CRC(Result(0 to Index-1))(0);
        Index++;
        data[Index] =0; //    = CRC(Result(0 to Index-2))(1);
        Index++;
    };
};


grtm_test(int paddr, int descsize, int buffersize, int buffers, int rsdepth, int reed, int reed8, int pseudo, int conv, int mark, int split, int sub)
{

    // start of test
    report_device(0x01030000);

    // telemetry encoder register structures
    struct grtm_dma {
        volatile unsigned long ctrl;           /* 0x00 */
        volatile unsigned long stat;           /* 0x04 */
        volatile unsigned long len;            /* 0x08 */
        volatile unsigned long descr;          /* 0x0C */
        volatile unsigned long conf;           /* 0x10 */
        volatile unsigned long rev;            /* 0x14 */
    };

    struct grtm_tx {
        volatile unsigned long ctrl;           /* 0x80 */
        volatile unsigned long stat;           /* 0x84 */
        volatile unsigned long conf;           /* 0x88 */
        volatile unsigned long dummy0;         /* 0x8c */
        volatile unsigned long phy;            /* 0x90 */
        volatile unsigned long code;           /* 0x94 */
        volatile unsigned long aasm;            /* 0x98 */
        volatile unsigned long dummy1;         /* 0x9c */
        volatile unsigned long all;            /* 0xa0 */
        volatile unsigned long master;         /* 0xa4 */
        volatile unsigned long idle;           /* 0xa8 */
        volatile unsigned long dummy2;         /* 0xac */
        volatile unsigned long dummy3;         /* 0xb0 */
        volatile unsigned long dummy4;         /* 0xb4 */
        volatile unsigned long dummy5;         /* 0xb8 */
        volatile unsigned long dummy6;         /* 0xbc */
        volatile unsigned long fsh0;           /* 0xc0 */
        volatile unsigned long fsh1;           /* 0xc4 */
        volatile unsigned long fsh2;           /* 0xc8 */
        volatile unsigned long fsh3;           /* 0xcc */
        volatile unsigned long ocf;            /* 0xd0 */
    };

    // local registers
    struct grtm_dma   *ldma = (struct grtm_dma*) (paddr);
    struct grtm_tx    *ltx =  (struct grtm_tx *) (paddr+0x80);


   // reset ccsds telemetry decoders, configure decoders
   long int subtst = ((rsdepth-1)<<15) | (reed<<14) | (reed8<<13) | (pseudo<<12) | (mark<<11) | (conv<<10) | (split<<9) |(sub<<8);

   report_subtest(subtst);

   // dma rev
//   int TIRQ =
//   int REV =
//   int SUBREV =
//   ldma->rev = ((TIRQ)<<16) | ((REV)<<8) | (SUBREV);

   if ((ldma->rev & 0xff) < 3) fail(1);


   // dma control - reset all
   // int TXRDY   = 0;
   int TFIE    = 0;
   int RST     = 1;
   int TXRST   = 1;
   int IE      = 0;
   int EN      = 0;

   ldma->ctrl = (TFIE<<4) | (RST<<3) | (TXRST<<2) | (IE<<1) | (EN);

   // dma control - release reset to tx part
   RST     = 0;
   TXRST   = 0;
   EN      = 0;
   ldma->ctrl = (TFIE<<4) | (RST<<3) | (TXRST<<2) | (IE<<1) | (EN);

   // -- setup dma part ---------------------------------

   // dma length
   int LIMIT   = 32*2;
   int LENGTH  = rsdepth*(223+16*reed8);
   ldma->len = ((LIMIT-1)<<16) | (LENGTH-1);

   // -- setup tx part ----------------------------------

   // tx phy
   int SF         = 1;
   int SYMBOLRATE = 1;
   int SCF        = 0;
   int SUBRATE    = 1;
   ltx->phy= (SF<<31) | (SYMBOLRATE<<16) | (SCF<<15) | (SUBRATE);

   // tx code
   int CIF     = 0;
   int CSEL    = 0;
   int AASM    = 0;
   int RS      = reed;
   int RSDEPTH = rsdepth-1;
   int RS8     = reed8;
   int PSR     = pseudo;
   int NRZ     = mark;
   int CE      = conv;
   int CERATE  = 0;
   int SP      = split;
   int SC      = sub;
   ltx->code= (CIF<<19) | (CSEL<<17) | (AASM<<16) | (RS<<15) | (RSDEPTH<<12) |
       (RS8<<11) | (PSR<<7) | (NRZ<<6) | (CE<<5) | (CERATE<<2) | (SP<<1) | (SC);

   // tx asm
   long int SYNC = 0x352EF853;
   ltx->aasm= SYNC;

   // tx all frames
   int FSHLENGTH  = 0;
   int IZ         = 0;
   int FECF       = 1;
   int FHEC       = 0;
   int VER        = 0x0;
   ltx->all= (FSHLENGTH<<17) | (IZ<<16) | (FECF<<15) | (FHEC<<14) | (VER<<12);

   // tx master
   int MC         = 1;
   int FSH        = 0;
   int OCF        = 1;
   int OW         = 1;
   ltx->master= (MC<<3) | (FSH<<2) | (OCF<<1) | (OW);

   // tx idle
   int IDLE       = 1;
   int IDLE_OCF   = 1;
   int EVC        = 0;
   int IDLE_FSH   = 0;
   int VCC        = 0;
   int IDLE_MC    = 0;
   int VCID       = 0x7;
   int SCID       = 0x123;
   ltx->idle= (IDLE<<21) | (IDLE_OCF<<20) | (EVC<<19) | (IDLE_FSH<<18) |
              (VCC<<17) | (IDLE_MC<<16) | (VCID<<10) | (SCID);

   // tx ocf
   long int CLCW  = 0xFEEDBACC;
   ltx->ocf = CLCW;

//   // tx ctrl - start transmitter -----------------------
//   report_subtest(0x1);

   int TXTE   = 1;
   ltx->ctrl= (TXTE);

   // wait for tx part to become ready
   while ((ldma->stat & 0x40) != 0x40) ;


   ////////////////////////////////////////
   // TX ready -> Reset everything again //
   ////////////////////////////////////////

   // dma control - reset all
   // int TXRDY   = 0;
   TFIE    = 0;
   RST     = 1;
   TXRST   = 1;
   IE      = 0;
   EN      = 0;

   ldma->ctrl = (TFIE<<4) | (RST<<3) | (TXRST<<2) | (IE<<1) | (EN);

   // dma control - release reset to tx part
   RST     = 0;
   TXRST   = 0;
   EN      = 0;
   ldma->ctrl = (TFIE<<4) | (RST<<3) | (TXRST<<2) | (IE<<1) | (EN);

   // -- setup dma part ---------------------------------

   // dma length
   LIMIT   = 32*2;
   LENGTH  = rsdepth*(223+16*reed8);
   ldma->len = ((LIMIT-1)<<16) | (LENGTH-1);

   // -- setup tx part ----------------------------------

   // tx phy
   SF         = 1;
   SYMBOLRATE = 1;
   SCF        = 0;
   SUBRATE    = 1;
   ltx->phy= (SF<<31) | (SYMBOLRATE<<16) | (SCF<<15) | (SUBRATE);

   // tx code
   CIF     = 0;
   CSEL    = 0;
   AASM    = 0;
   RS      = reed;
   RSDEPTH = rsdepth-1;
   RS8     = reed8;
   PSR     = pseudo;
   NRZ     = mark;
   CE      = conv;
   CERATE  = 0;
   SP      = split;
   SC      = sub;
   ltx->code= (CIF<<19) | (CSEL<<17) | (AASM<<16) | (RS<<15) | (RSDEPTH<<12) |
       (RS8<<11) | (PSR<<7) | (NRZ<<6) | (CE<<5) | (CERATE<<2) | (SP<<1) | (SC);

   // tx asm
   SYNC = 0x352EF853;
   ltx->aasm= SYNC;

   // tx all frames
   FSHLENGTH  = 0;
   IZ         = 0;
   FECF       = 1;
   FHEC       = 0;
   VER        = 0x0;
   ltx->all= (FSHLENGTH<<17) | (IZ<<16) | (FECF<<15) | (FHEC<<14) | (VER<<12);

   // tx master
   MC         = 1;
   FSH        = 0;
   OCF        = 1;
   OW         = 1;
   ltx->master= (MC<<3) | (FSH<<2) | (OCF<<1) | (OW);

   // tx idle
   IDLE       = 1;
   IDLE_OCF   = 1;
   EVC        = 0;
   IDLE_FSH   = 0;
   VCC        = 0;
   IDLE_MC    = 0;
   VCID       = 0x7;
   SCID       = 0x123;
   ltx->idle= (IDLE<<21) | (IDLE_OCF<<20) | (EVC<<19) | (IDLE_FSH<<18) |
              (VCC<<17) | (IDLE_MC<<16) | (VCID<<10) | (SCID);

   // tx ocf
   CLCW  = 0xFEEDBACC;
   ltx->ocf = CLCW;

   // tx ctrl - start transmitter -----------------------
   report_subtest(0x1);

   TXTE   = 1;
   ltx->ctrl= (TXTE);

   // wait for tx part to become ready
   while ((ldma->stat & 0x40) != 0x40) ;


   //-- setup dma --------------------------------------

   // allocate memory for descriptors
   volatile long int descmemory[descsize/4];

   // search for start of allocated memory
   long int descmemorybase;
   descmemorybase = (long int)&descmemory[0];

   // search for 1k boundary within allocated memory, store as base
   descmemorybase = descmemorybase & 0xFFFFFC00;
   descmemorybase = descmemorybase + 0x400;

   // allocate memory for frames
   volatile long int framememory[buffersize*buffers/4];

   // search for start of allocated memory
   long int framememorybase;
   framememorybase = (long int)&framememory[0];

   // search for 1k boundary within allocated memory, store as base
   framememorybase = framememorybase & 0xFFFFFC00;
   framememorybase = framememorybase + 0x400;

   // dma descr
   int BASE   = descmemorybase >> 10;
   int INDEX  = 0;
   ldma->descr= (BASE<<10) | (INDEX<<3);

   // -- setup descriptors -----------------------------
   report_subtest(0x2);

   int UE      = 0;
   int TS      = 0;
   int VCE     = 0;
   int MCB     = 0;
   int FSHB    = 0;
   int OCFB    = 0;
   int FHECB   = 0;
   int IZB     = 0;
   int FECFB   = 0;
   int DESC_IE = 0;
   int WR      = 0;
   int DESC_EN = 1;
   int DESCRIPTOR = (UE<<15) | (TS<<14) | (VCE<<9) | (MCB<<8) | (FSHB<<7) |
                    (OCFB<<6) | (FHECB<<5) | (IZB<<4) | (FECFB<<3) |
                    (DESC_IE<<2) | (WR<<1) | (DESC_EN);

   volatile int *memorytx;
   memorytx = (int*)descmemorybase;

   int i;

   for (i=0; i<4; i++) {
      if (i==3) {
         WR = 1;
         DESCRIPTOR = (UE<<15) | (TS<<14) | (VCE<<9) | (MCB<<8) | (FSHB<<7) |
                      (OCFB<<6) | (FHECB<<5) | (IZB<<4) | (FECFB<<3) |
                      (DESC_IE<<2) | (WR<<1) | (DESC_EN);
         *memorytx = DESCRIPTOR;
      }
      else
         *memorytx = DESCRIPTOR;
      memorytx++;
      *memorytx = framememorybase+i*buffersize;
      memorytx++;
   };

   // -- setup frames -----------------------------------
   int VCFrameCntr =0;
   int MCFrameCntr =0;
   long int SequenceCount = 0;

   memorytx = (int*)framememorybase;
   TMTF(SCID, 6, OCF, MCFrameCntr, VCFrameCntr, 0, 0, 0, 3, 0, 0xBAADCAAD, 1, SequenceCount, rsdepth*(223+16*reed8), (char*)memorytx);
   MCFrameCntr++;
   VCFrameCntr++;
   SequenceCount++;

   memorytx = (int*)(framememorybase+buffersize);
   TMTF(SCID, 6, OCF, MCFrameCntr, VCFrameCntr, 0, 0, 0, 3, 0, 0xBAADCAAD, 1, SequenceCount, rsdepth*(223+16*reed8), (char*)memorytx);
   MCFrameCntr++;
   VCFrameCntr++;
   SequenceCount++;

   memorytx = (int*)(framememorybase+buffersize*2);
   TMTF(SCID, 6, OCF, MCFrameCntr, VCFrameCntr, 0, 0, 0, 3, 0, 0xBAADCAAD, 1, SequenceCount, rsdepth*(223+16*reed8), (char*)memorytx);
   MCFrameCntr++;
   VCFrameCntr++;
   SequenceCount++;

   memorytx = (int*)(framememorybase+buffersize*3);
   TMTF(SCID, 6, OCF, MCFrameCntr, VCFrameCntr, 0, 0, 0, 3, 0, 0xBAADCAAD, 1, SequenceCount, rsdepth*(223+16*reed8), (char*)memorytx);
   MCFrameCntr++;
   VCFrameCntr++;
   SequenceCount++;

   // -- start dma engine ------------------------------
   report_subtest(0x3);

   EN = 1;
   ldma->ctrl= (TFIE<<4) | (RST<<3) | (TXRST<<2) | (IE<<1) | (EN);

   // wait for four descriptors being sent
   while ((ldma->ctrl & 0x1) != 0x0) ;
   report_subtest(0x4);

   // wait for four frames being sent
   while ((ldma->stat & 0x20) != 0x20) ;
   report_subtest(0x5);

   // dma status


   // dma status
//   int TXSTAT  = 0;
//   int TXRDY   = 0;
   int TFO     = 0;
   int TFS     = 1;
   int TFF     = 1;
   int TA      = 1;
   int TI      = 1;
   int TERROR  = 1;
   ldma->stat = (TFO<<5) | (TFS<<4) | (TFF<<3) | (TA<<2) | (TI<<1) | (TERROR);

   // wait for extra frame
   while ((ldma->stat & 0x10) != 0x10) ;
   report_subtest(0x6);

   // dma status
   TFO     = 0;
   TFS     = 1;
   TFF     = 1;
   TA      = 1;
   TI      = 1;
   TERROR  = 1;
   ldma->stat = (TFO<<5) | (TFS<<4) | (TFF<<3) | (TA<<2) | (TI<<1) | (TERROR);

   // wait for extra frame
   while ((ldma->stat & 0x10) != 0x10) ;


   // reset ccsds telemetry decoders, configure decoders
   report_subtest(subtst);

   // end test
   report_subtest(0x7);
}
