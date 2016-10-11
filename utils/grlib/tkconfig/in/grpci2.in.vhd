-- GRPCI2 interface
  constant CFG_GRPCI2_MASTER    : integer := CFG_GRPCI2_MASTEREN;
  constant CFG_GRPCI2_TARGET    : integer := CFG_GRPCI2_TARGETEN;
  constant CFG_GRPCI2_DMA       : integer := CFG_GRPCI2_DMAEN;
  constant CFG_GRPCI2_VID       : integer := 16#CONFIG_GRPCI2_VENDORID#;
  constant CFG_GRPCI2_DID       : integer := 16#CONFIG_GRPCI2_DEVICEID#;
  constant CFG_GRPCI2_CLASS     : integer := 16#CONFIG_GRPCI2_CLASS#;
  constant CFG_GRPCI2_RID       : integer := 16#CONFIG_GRPCI2_REVID#;
  constant CFG_GRPCI2_CAP       : integer := 16#CONFIG_GRPCI2_CAPPOINT#;
  constant CFG_GRPCI2_NCAP      : integer := 16#CONFIG_GRPCI2_NEXTCAPPOINT#;
  constant CFG_GRPCI2_BAR0      : integer := CONFIG_GRPCI2_BAR0;
  constant CFG_GRPCI2_BAR1      : integer := CONFIG_GRPCI2_BAR1;
  constant CFG_GRPCI2_BAR2      : integer := CONFIG_GRPCI2_BAR2;
  constant CFG_GRPCI2_BAR3      : integer := CONFIG_GRPCI2_BAR3;
  constant CFG_GRPCI2_BAR4      : integer := CONFIG_GRPCI2_BAR4;
  constant CFG_GRPCI2_BAR5      : integer := CONFIG_GRPCI2_BAR5;
  constant CFG_GRPCI2_FDEPTH    : integer := CFG_GRPCI2_FIFO;
  constant CFG_GRPCI2_FCOUNT    : integer := CFG_GRPCI2_FIFOCNT;
  constant CFG_GRPCI2_ENDIAN    : integer := CFG_GRPCI2_LENDIAN;
  constant CFG_GRPCI2_DEVINT    : integer := CFG_GRPCI2_DINT;
  constant CFG_GRPCI2_DEVINTMSK : integer := 16#CONFIG_GRPCI2_DINTMASK#;
  constant CFG_GRPCI2_HOSTINT   : integer := CFG_GRPCI2_HINT;
  constant CFG_GRPCI2_HOSTINTMSK: integer := 16#CONFIG_GRPCI2_HINTMASK#;
  constant CFG_GRPCI2_TRACE     : integer := CFG_GRPCI2_TRACEDEPTH;
  constant CFG_GRPCI2_TRACEAPB  : integer := CONFIG_GRPCI2_TRACEAPB;
  constant CFG_GRPCI2_BYPASS    : integer := CFG_GRPCI2_INBYPASS;
  constant CFG_GRPCI2_EXTCFG    : integer := CONFIG_GRPCI2_EXTCFG;

