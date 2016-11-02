//#define GRGPIOADR 0x80000500;

int pcif_test(unsigned int base_addr, unsigned int conf_addr, unsigned int apb_addr) {
  volatile unsigned int *base   = (unsigned int *) base_addr; 
  volatile unsigned int *baseio = (unsigned int *) (conf_addr); 
  volatile unsigned int *conf   = (unsigned int *) (conf_addr + 0x10000); 
  volatile unsigned int *apb    = (unsigned int *) apb_addr; 
  int i, tmp;

  report_device(0x01075000);
  
  // Enable PCI master and mem access
  *(conf+1) = 0x00000146;
  *(conf+3) = 0x00004000;

  // test APB interface
  report_subtest(1);
  // PCI BAR => AHB 
  *(apb)   = 0xffffffff;
  *(apb+1) = 0xffffffff;
  if (*(apb)   != 0xf0000000) fail(1);
  if (*(apb+1) != 0xff800000) fail(1);
  *(apb)   = 0xa0000000;
  *(apb+1) = 0x80000000;
  if (*(apb)   != 0xa0000000) fail(2);
  if (*(apb+1) != 0x80000000) fail(2);

  // AHB master => PCI MEM
  *(apb+16) = 0xffffffff;
  *(apb+17) = 0xffffffff;
  *(apb+18) = 0xffffffff;
  *(apb+19) = 0xffffffff;
  if (*(apb+16) != 0xc0000000) fail(1);
  if (*(apb+17) != 0xc0000000) fail(1);
  if (*(apb+18) != 0xc0000000) fail(1);
  if (*(apb+19) != 0xc0000000) fail(1);
  *(apb+16) = 0xc0000000;
  if (*(apb+16) != 0xc0000000) fail(2);

  // AHB => PCI IO
  *(apb+5) = 0xffffffff;
  if (*(apb+5) != 0xffff0000) fail(1);
  *(apb+5) = 0x30000000;
  if (*(apb+5) != 0x30000000) fail(2);


  // test PCI configuration
  report_subtest(2);
  // self conf
  if (*(conf)   != 0x02061ac8) fail(1);
  if (*(conf+1) != 0x04100146) fail(1);
  if (*(conf+2) != 0x0b400000) fail(1);
  if (*(conf+3) != 0x00004000) fail(1);
  *(conf+4) = 0xffffffff;
  *(conf+5) = 0xffffffff;
  *(conf+6) = 0xffffffff;
  *(conf+7) = 0xffffffff;
  if (*(conf+4) != 0xfffff000) fail(2);
  if (*(conf+5) != 0xf0000000) fail(2);
  if (*(conf+6) != 0xff800000) fail(2);
  if (*(conf+7) != 0x00000000) fail(2);
  *(conf+4) = 0x10000000;
  *(conf+5) = 0x40000000;
  *(conf+6) = 0x50000000;
  if (*(conf+4) != 0x10000000) fail(3);
  if (*(conf+5) != 0x40000000) fail(3);
  if (*(conf+6) != 0x50000000) fail(3);
  // conf target
  *(conf+0x2a00+1) = 0x00000146;
  if (*(conf+0x2a00) != 0x3badaffe) fail(4);
  if ((*(apb+6) & 0x30000000) != 0) fail(5);
  *(conf+0x2a00+4) = 0xc0000000;
  *(conf+0x2a00+5) = 0x30000000;
  if (*(conf+0x2a00+4) != 0xc0000000) fail(6);
  if (*(conf+0x2a00+5) != 0x30000001) fail(6);
  if ((*(apb+6) & 0x30000000) != 0) fail(7);
  
  // test master abort
  tmp = *(conf+0x2000);
  if ((*(apb+6) & 0x30000000) != 0x20000000) fail(8);

  
  // test PCI mem-access
  report_subtest(3);
  for (i=0; i<16; i++){
    *(base+i) = ((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
               |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf));
  }

  for (i=0; i<16; i++){
    if (*(base+i) != (((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                    |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf)))) fail(1);
  }
  
  // test PCI io-access
  report_subtest(4);
  for (i=0; i<16; i++){
    *(baseio+i) = ((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                 |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf));
  }

  for (i=0; i<16; i++){
    if (*(baseio+i) != (((i&0xf)<<28) |((i&0xf)<<24) |((i&0xf)<<20) |((i&0xf)<<16) 
                      |((i&0xf)<<12) |((i&0xf)<<8)  |((i&0xf)<<4)  |((i&0xf)))) fail(1);
  }
  
}
