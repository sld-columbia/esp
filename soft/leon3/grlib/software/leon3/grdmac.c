#include "irqmp.h"

#ifndef NULL
#define NULL ((void*)0)
#endif

static volatile grdmacirq = 0;

void grdmac_irqhandler(int irq){
  grdmacirq += 1;
}

// GRDMA descriptor structure
  typedef struct desc {
    volatile struct desc *next_desc;
    volatile void *start_address;
    volatile unsigned int control;
  volatile unsigned int status;           // (Conditianal Mask)
  } desc;

  struct grdmac_register {
    volatile unsigned int control;          /* 0x00 */
    volatile unsigned int status;           /* 0x04 */
    volatile unsigned int interrupt_mask;   /* 0x08 */
    volatile unsigned int error;            /* 0x0C */
    volatile unsigned int **cvp;            /* 0x10 */
    volatile unsigned int empty;            /* 0x14 */
    volatile unsigned int capability;       /* 0x18 */
    volatile unsigned int irq_flag;         /* 0x1C */
    volatile desc m2b_desc;                 /* 0x20 */
    volatile desc b2m_desc;                 /* 0x30 */

  };

// Before calling configure irqmp_base variable from irqmp.h
grdmac_test(int paddr, int irq) {

  report_device(0x01095000);
  report_subtest(1);
  struct grdmac_register *grdmac_reg = (struct grdmac_register *) (paddr);

  unsigned int control;
  unsigned int transfer_size;

  volatile unsigned int source  = 0xFAFAFAFA;
  volatile unsigned int dest    = 0x0;

  transfer_size = sizeof(source);

  catch_interrupt(grdmac_irqhandler, irq);
  irqmp_base->irqmask = 1 << irq;	  /* unmask interrupt */
  enable_irq(irq);

  //setup simplified DMA channel
  grdmac_reg->control = 0x00000002; // reset

  grdmac_reg->interrupt_mask = 0xFFFFFFFF ;
  
  grdmac_reg->m2b_desc.next_desc      = 0x00000000;
  grdmac_reg->m2b_desc.start_address  = &source;
  grdmac_reg->m2b_desc.control        = (transfer_size << 16) | 0x1;

  grdmac_reg->b2m_desc.next_desc      = 0x00000000;
  grdmac_reg->b2m_desc.start_address  = &dest;
  grdmac_reg->b2m_desc.control        = (transfer_size << 16) | 0x5;

  // start DMA!
  grdmac_reg->control = 0x0001001d; // start in simplified mode!

  while (!grdmacirq);
  grdmacirq = 0; //clear

  if(dest != source) fail(0); 
}


/////////////////////////////////////////////////
//  DMA - UART Test                            //
/////////////////////////////////////////////////

//descriptor structure
struct uart_regs 
{
  volatile int data;
  volatile int status;
  volatile int control;
  volatile int scaler;
};

static unsigned int* volatile  cvp0[32]  __attribute__((aligned(128))) = { 0 }; // DMAC 0
static unsigned int* volatile  cvp1[32]  __attribute__((aligned(128))) = { 0 }; // DMAC 1
static volatile struct desc m2b0_desc[32] __attribute__((aligned(16)));
static volatile struct desc b2m0_desc[32] __attribute__((aligned(16)));
static volatile struct desc m2b1_desc[32] __attribute__((aligned(16)));
static volatile struct desc b2m1_desc[32] __attribute__((aligned(16)));
//static volatile struct desc m2b2_desc[8] __attribute__((aligned(16)));
//static volatile struct desc b2m2_desc[8] __attribute__((aligned(16)));
static volatile struct desc m2b_desc_arr[4][8] __attribute__((aligned(16)));
static volatile struct desc b2m_desc_arr[4][8] __attribute__((aligned(16)));
static volatile struct desc m2b_rdnack_desc[4] __attribute__((aligned(16)));
static volatile struct desc b2m_rdnack_desc[4] __attribute__((aligned(16)));


// Using two DMA controllers perform TX/RX on a APBUART interface
grdmac_apbuart_test(int dmac_paddr, int dmac_irq, int dmactx_paddr, int uart_paddr) {
  report_device(0x01095000);
  report_subtest(2);
  int i;

  volatile struct uart_regs *uart = (struct uart_regs *) uart_paddr;
  volatile struct grdmac_register *grdmac_reg = (struct grdmac_register *) (dmac_paddr);
  volatile struct grdmac_register *grdmactx_reg = (struct grdmac_register *) (dmactx_paddr);

  static volatile char   uart_rxdata[64];
  static volatile char   uart_txdata[64] =  {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF };

  unsigned int control;
  unsigned int transfer_size = 16;

  volatile unsigned int source  = 0x01234567;
  volatile unsigned int dest    = 0x0;

  uart->scaler = 1;
  uart->status = 0;
  uart->control = 0x83; //TX, RX and LoopBack

  catch_interrupt(grdmac_irqhandler, dmac_irq);
  irqmp_base->irqmask = 1 << dmac_irq;	  /* unmask interrupt */
//  enable_irq(dmac_irq);

  cvp0[0] = (unsigned int*) &m2b0_desc[0];
  cvp0[1] = (unsigned int*) &b2m0_desc[0]; 

  m2b0_desc[0].next_desc     = (desc*) (( (int) &m2b0_desc[1]) | 0x1); //conditional desc
  m2b0_desc[0].start_address = &(uart->status);    //address (UART status register address)
  m2b0_desc[0].control       = 0x00010FF9;         //control (poll every 256 cycles, get 1 Byte, use 2nd AMBA I/F)
  m2b0_desc[0].status        = 0x00000001;         //mask (only check “Receiver Data ready”)
  m2b0_desc[1].next_desc     = (desc*) (int) 0;
  m2b0_desc[1].start_address = (((char*) &uart->data)+3); //address (UART data register address)
  m2b0_desc[1].control       = (transfer_size << 16) | 0x11; //control (read from fixed address)
  m2b0_desc[1].status        = 0;                  //status (written by DMAC core)

  b2m0_desc[0].next_desc     = NULL;
  b2m0_desc[0].start_address = &uart_rxdata[0]; //address (DMA write address for UART data)
  b2m0_desc[0].control       = (transfer_size << 16) | 0x5; //control (generate interrupt on completeion)
  b2m0_desc[0].status        = 0;                  //status (written by DMAC core)

  // setup DMA channel (UART Receiver)
  grdmac_reg->control = 0x00000002;
  grdmac_reg->interrupt_mask = 0xFFFFFFFF;
  grdmac_reg->cvp =  (volatile unsigned int **)&cvp0[0];
  // start DMA!
  grdmac_reg->control = 0x0001000d; // interrupts enabled

/*  // Transmit data (SW implementation)
  int i;
  int txfull  = uart->status & 0x200;
  for(i = 0; i < transfer_size; i++){
    while (txfull){ txfull = uart->status & 0x200;} //check Tx Full
    uart->data = uart_txdata[i];
  }
*/  // END SW Implementation 

  // UART Transmit data (DMAC impl.)
  cvp1[0] = (int*) &m2b1_desc[0];
  cvp1[1] = (int*) &b2m1_desc[0];
  // Data Descriptor (Read)
  m2b1_desc[0].next_desc     = NULL;
  m2b1_desc[0].start_address = &uart_txdata[0]; //address (commands to write into I2CMST Tx and Command APB regs)
  m2b1_desc[0].control       = (transfer_size << 16) | 0x1; //control (read from address)
  m2b1_desc[0].status        = 0;
  // Conditional Descriptor
  b2m1_desc[0].next_desc     = (desc*) (( (int) &b2m1_desc[1]) | 0x1);
  b2m1_desc[0].start_address = &(uart->status);//address (IRQ number of the I2C Mst that is waited for)
  b2m1_desc[0].control       = 0x00010FF9;     //control (poll every 256 cycles, get 1 Byte, use 2nd AMBA I/F)
  b2m1_desc[0].status        = 0x00000002;     //mask (only check “Receiver Data ready”)
  // Data Descriptor
  b2m1_desc[1].next_desc     = NULL;
  b2m1_desc[1].start_address = ((char*) &uart->data)+3;      //address (UART data register address)
  b2m1_desc[1].control       = (transfer_size << 16) | 0x11; //control (read from fixed address)
  b2m1_desc[1].status        = 0;

  grdmactx_reg->control = 0x00000002;
  grdmactx_reg->interrupt_mask = 0x00000000 ;
  grdmactx_reg->cvp = (volatile unsigned int **)&cvp1;
  // start DMA!
  grdmactx_reg->control = 0x00010009; // interrupts disabled except errors
  // END HW impl.

  while (!grdmacirq); // wait for receiver DMA finish
  grdmacirq = 0; //clear

  // Check data
  for(i = 0; i < transfer_size; i++){
    if(uart_rxdata[i] != uart_txdata[i]) fail(0); 
  }
}



/////////////////////////////////////////////////
//  DMA - I2C Master Test                      //
/////////////////////////////////////////////////

// I2CSLV registers
struct i2cslv_regs {
   volatile unsigned int slvaddr;
   volatile unsigned int ctrl;
   volatile unsigned int sts;
   volatile unsigned int msk;
   volatile unsigned int rd;
   volatile unsigned int td;
};

// I2CMST registers
struct i2cmst_regs {
   volatile unsigned int prer; // Clock Prescale
   volatile unsigned int ctr;  // Control
   volatile unsigned int xr;   // Transmit/Receive
   volatile unsigned int csr;  // Command/Status
};

/* Control register */
#define I2CMST_CTR_EN   (1 << 7)   /* Enable core */
#define I2CMST_CTR_IEN  (1 << 6)   /* Interrupt enable */
/* Command register */
#define I2CMST_CR_STA   (1 << 7)   /* Generate start condition */
#define I2CMST_CR_STO   (1 << 6)   /* Generate stop condition */
#define I2CMST_CR_RD    (1 << 5)   /* Read from slave */
#define I2CMST_CR_WR    (1 << 4)   /* Write to slave */
#define I2CMST_CR_ACK   (1 << 3)   /* ACK, when a receiver send ACK (ACK = 0) or NACK (ACK = 1) */
#define I2CMST_CR_IACK  (1 << 0)   /* Interrupt acknowledge */
/* Status register */
#define I2CMST_SR_RXACK (1 << 7)   /* Receibed acknowledge from slave */
#define I2CMST_SR_BUSY  (1 << 6)   /* I2C bus busy */
#define I2CMST_SR_AL    (1 << 5)   /* Arbitration lost */
#define I2CMST_SR_TIP   (1 << 1)   /* Transfer in progress */
#define I2CMST_SR_IF    (1 << 0)   /* Interrupt flag */


#define PRESCALER   0x000A
#define SLAVE_ADDRESS 0x50  // i2c2ahb addr

// Test function performs a write and read over I2CMst and I2C2AHB
// using GRDMAC for data transfers.
grdmac_i2c_test(int dmac_paddr, int dmac_irq, int i2cm_paddr, int dmac_pirq) {
  report_device(0x01095000);
  report_subtest(3);
  int i,j;
  int idx = 0;

  volatile struct i2cmst_regs *i2cm = (struct i2cmst_regs *) i2cm_paddr;
  volatile struct grdmac_register *grdmac_reg = (struct grdmac_register *) (dmac_paddr);

  static volatile char rxdata[64];
  static volatile char txdata[64] =  {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF };

  // I2C write sequnce

  // wait for irq 50

  // test RxACK == 0 and I2CMST_SR_AL == 0
  volatile int testdata = 0xFEDCBA98;
  volatile const int *ahb_addr_target = &testdata; // adrres to which
  char * ahb_addr = (char*)(&ahb_addr_target);

  unsigned int control;
  unsigned int transfer_size = 4;

  // Initialize and enable I2CMST
  i2cm->prer = PRESCALER;

  // Enable core 
  i2cm->ctr = I2CMST_CTR_EN | I2CMST_CTR_IEN;
// CPU controled Write and Read over I2C Master
/*
  volatile unsigned int* const test = 0x00000010;
  for (i = 0; i < 15; i++) {
    switch(i) {
    case 0:
      // Address memory 
      i2cm->xr = SLAVE_ADDRESS << 1;
      i2cm->csr = I2CMST_CR_STA | I2CMST_CR_WR;
      break;
    case 1:
    case 2:
    case 3:
    case 4:
      // Select memory position
      i2cm->xr = ahb_addr[i-1];
      i2cm->csr = I2CMST_CR_WR;
      break;
    case 5:
    case 6:
    case 7:
      // Write data to position
      i2cm->xr = txdata[i-5];
      i2cm->csr = I2CMST_CR_WR;
      break;
    case 8:
      // Last write byte
      i2cm->xr = txdata[i-5];
      i2cm->csr = I2CMST_CR_WR | I2CMST_CR_STO;
    case 9:
      // Address memory Read
      i2cm->xr = SLAVE_ADDRESS << 1;
      i2cm->csr = I2CMST_CR_STA | I2CMST_CR_WR;
      break;
    case 10:
    case 11:
    case 12:
    case 13:
      // Select memory position
      i2cm->xr = ahb_addr[i-10];
      i2cm->csr = I2CMST_CR_WR;
      break;
    case 14:
      // Address memory for reading
      i2cm->xr = (SLAVE_ADDRESS << 1) | 1;
      i2cm->csr = I2CMST_CR_STA | I2CMST_CR_WR;
      break;
    default: 
      break;
    }

    while (i2cm->csr & I2CMST_SR_TIP);

    if (i2cm->csr & I2CMST_SR_RXACK) {
      fail(4+i);
    }
    if (i2cm->csr & I2CMST_SR_AL) {
      fail(9+i);
    }
  }

  // Read from memory and NAK
  for (i = 0; i < 4; i++) {
    if (i == 3) { i2cm->csr = I2CMST_CR_RD | I2CMST_CR_STO | I2CMST_CR_ACK; }
    else       { i2cm->csr = I2CMST_CR_RD; }

    while (i2cm->csr & I2CMST_SR_TIP);
    rxdata[i] = i2cm->xr & 0xFF; 
	*test = rxdata[i];
    if (rxdata[i] != txdata[i])
      fail(15);

  }*/

  catch_interrupt(grdmac_irqhandler, dmac_irq);
  irqmp_base->irqmask = 1 << dmac_irq;	  //unmask interrupt

  cvp0[0]  = (int*) &m2b0_desc[0];       // Ch0
  cvp0[1]  = (int*) &b2m0_desc[0];
  cvp0[2]  = (int*) &m2b_desc_arr[0][0]; // Ch1 Read byte 0. Channels >=1 used for I2C read
  cvp0[3]  = (int*) &b2m_desc_arr[0][0]; 
  cvp0[4]  = (int*) &m2b1_desc[0];       // Ch2 Request byte 1
  cvp0[5]  = (int*) &b2m1_desc[0];
  cvp0[6]  = (int*) &m2b_desc_arr[1][0]; // Ch3 Read byte 1
  cvp0[7]  = (int*) &b2m_desc_arr[1][0];
  cvp0[8]  = (int*) &m2b1_desc[0];       // Ch4 Request byte 2
  cvp0[9]  = (int*) &b2m1_desc[0];
  cvp0[10] = (int*) &m2b_desc_arr[2][0]; // Ch5 Read byte 2
  cvp0[11] = (int*) &b2m_desc_arr[2][0];
  cvp0[12] = (int*) &m2b_rdnack_desc[0]; // Ch6 Request byte 3
  cvp0[13] = (int*) &b2m_rdnack_desc[0];
  cvp0[14] = (int*) &m2b_desc_arr[3][0]; // Ch7 Read byte 3 and stop
  cvp0[15] = (int*) &b2m_desc_arr[3][0];

  // Constants for I2C commands placed in memory for DMAC usage
  static volatile int slvcmdstrt[2]    = {  (SLAVE_ADDRESS << 1), (I2CMST_CR_STA | I2CMST_CR_WR | I2CMST_CR_IACK)};
  static volatile int slvcmdstrt_rd[2] = { ((SLAVE_ADDRESS << 1) | 1) , (I2CMST_CR_STA | I2CMST_CR_WR | I2CMST_CR_IACK)};
  static volatile int slvread          = I2CMST_CR_RD | I2CMST_CR_IACK;
  static volatile int slvcmdrd_nackstop = I2CMST_CR_RD | I2CMST_CR_ACK | I2CMST_CR_STO | I2CMST_CR_IACK;
  static volatile int slvwrite         = I2CMST_CR_WR | I2CMST_CR_IACK;
  static volatile int slvcmdstop       = I2CMST_CR_WR | I2CMST_CR_STO | I2CMST_CR_IACK;

  static volatile int i2cmirq; i2cmirq = dmac_pirq;
  static volatile int zeroes = 0;

  ////////////////////////
  // I2C Write Command  //
  ////////////////////////

  // The Memory2Buffer descriptors are more advanced than necessary
  // and "assembles" the commands to the I2C Master. It is in possible to
  // just use one descriptor and 
  m2b0_desc[0].next_desc     = &m2b0_desc[1];
  m2b0_desc[0].start_address = &slvcmdstrt[0];      //address (START commands to write into I2CMST Tx and Command APB regs)
  m2b0_desc[0].control       = 0x00080001;          //control (fetch 8bytes of writecmd0)
  m2b0_desc[0].status        = 0;
  // 4 bytes of addr
  for (i=0; i<4; i++) {
    idx++;
    // First add zero PAD data because it is wanted to write the I2C APB reg with a
    // 32-bit word but we transmit only one byte of the target address at a time.
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &zeroes;
    m2b0_desc[idx].control       = 0x00030001;       //control (fetch 3bytes)
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &ahb_addr[i];     //address (AMBA target address for I2C write)
    m2b0_desc[idx].control       = 0x00010001;       //control (fetch 1bytes of AHB traget address)
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &slvwrite;        //address (to be writen into I2CMST Command APB reg)
    m2b0_desc[idx].control       = 0x00040001;       //control (fetch 1 word containing transmitt command)
    m2b0_desc[idx].status        = 0;
  }
  // 4 bytes of data
  for (i = 0; i < 4; i++) {
    idx++;
    // Add zero PAD data because it is wanted to write the I2C APB reg as a 32-bit word
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &zeroes;
    m2b0_desc[idx].control       = 0x00030001;
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &txdata[i];       //address (data to be writen into I2CMST Tx APB reg)
    m2b0_desc[idx].control       = 0x00010001;       //control (fetch 1 byte of data)
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &slvwrite;        //address (to be writen into I2CMST Command APB reg)
    m2b0_desc[idx].control       = 0x00040001;       //control (fetch 1 word containing transmitt command)
    m2b0_desc[idx].status        = 0;
    if (i==3) {
      // end of write
      m2b0_desc[idx].next_desc     = 0;
      m2b0_desc[idx].start_address = &slvcmdstop;    //address (to be writen into I2CMST Command APB reg)
    }
  }

  // Buffer to I2C Master //

  // START command
  b2m0_desc[0].next_desc     = &b2m0_desc[1];     
  b2m0_desc[0].start_address = &(i2cm->xr);         //address (write address of the I2C Mst Tx register)
  b2m0_desc[0].control       = (8 << 16) | 0x9;     //8 bytes (write to I2CMST, use AHB Master1)
  b2m0_desc[0].status        = 0;                 
  idx = 0;
  // In total write (4 target addr + 4 data) * 8 bytes into I2CMst Regs)
  // A long descriptor chain is requires since the fixed address DMAC
  // function does not allow to write across 2 APB registers.
  for (i = 0; i < 8; i++) {
    idx++; // Conditional Descriptor
    b2m0_desc[idx].next_desc     = (desc*) (( (int) &b2m0_desc[idx+1]) | 0x1);
    // Interrupt Option (2 lines below)
//    b2m0_desc[idx].start_address = i2cmirq;         //address (IRQ number of the I2C Mst that is waited for)
//    b2m0_desc[idx].control       = 0x00080003;      //control (write 8bytes after each IRQ to I2C Mst APB regs)
    // Bit poll Option (2 lines below)
    b2m0_desc[idx].start_address = &(i2cm->csr);    //address (poll address of the I2C Mst that is waited for)
    b2m0_desc[idx].control       = 0x00080FF9;      //control (write 8bytes when bit is set in I2C Mst APB regs, use AHB Master1)
    b2m0_desc[idx].status        = 0x00000001;      //mask (check interrupt flag if bit-polling)
    idx++; // Data Descriptor
    b2m0_desc[idx].next_desc     = &b2m0_desc[idx+1];
    b2m0_desc[idx].start_address = &(i2cm->xr);     //address (Write start address of the I2CMST Command APB reg)
    b2m0_desc[idx].control       = 0x00080009;      //control (2nd AHB Master)
    b2m0_desc[idx].status        = 0;
    if (i==7) {
      b2m0_desc[idx].next_desc   = 0;               //end of write
      b2m0_desc[idx].control    |= 0x4;             //generate IRQ on last
    }
  }


  //setup DMA channel
  grdmac_reg->control = 0x00000002; // reset 0x0001000C
  grdmac_reg->interrupt_mask = 0xFFFFFFFF ;
  grdmac_reg->cvp =  (volatile unsigned int **)&cvp0;

  grdmac_reg->control = 0x0001000D; // start DMAC
  while (!grdmacirq);               // wait for DAMC
  grdmacirq = 0;                    // clear counter

  ////////////////////////
  // I2C Read Command   //
  ////////////////////////
  idx = 0;
  // Write Read commands to I2C Master 
  m2b0_desc[0].next_desc     = &m2b0_desc[1];
  m2b0_desc[0].start_address = &slvcmdstrt[0];      //address (START commands to write into I2CMST Tx and Command APB regs)
  m2b0_desc[0].control       = 0x00080001;          //control (fetch 8bytes of writecmd0)
  m2b0_desc[0].status        = 0;
  for (i = 0; i < 4; i++) {
    idx++;
    // Zero PAD
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &zeroes;          
    m2b0_desc[idx].control       = 0x00030001;      //control (fetch 3 byte pad zeroes)
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &(ahb_addr[i]);  //address (AMBA traget address for I2C read)
    m2b0_desc[idx].control       = 0x00010001;      //control (fetch 1byte of AHB traget address)
    m2b0_desc[idx].status        = 0;
    idx++;
    m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
    m2b0_desc[idx].start_address = &slvwrite;       //address (to be writen into I2CMST Command APB reg)
    m2b0_desc[idx].control       = 0x00040001;      //control (fetch 1 word containing transmitt command)
    m2b0_desc[idx].status        = 0;
  }
  idx++; // Start condition again
  m2b0_desc[idx].next_desc     = &m2b0_desc[idx+1];
  m2b0_desc[idx].start_address = &slvcmdstrt_rd[0]; //address (START commands to write into I2CMST Tx and Command APB regs)
  m2b0_desc[idx].control       = 0x00080001;        //control (fetch 8bytes of writecmd0)
  m2b0_desc[idx].status        = 0;
  idx++;  // Set read command
  m2b0_desc[idx].next_desc     = 0;
  m2b0_desc[idx].start_address = &slvread;          //address (READ commands to write into I2CMST Tx and Command APB regs)
  m2b0_desc[idx].control       = 0x00040001;        //control (fetch 4bytes of writecmd0)
  m2b0_desc[idx].status        = 0;
  
  // Buffer to I2C Master
  b2m0_desc[0].next_desc     = &b2m0_desc[1];       // Send start condition + slave address.  
  b2m0_desc[0].start_address = &(i2cm->xr);         //address (address of the I2C Mst Tx register)
  b2m0_desc[0].control       = (8 << 16) | 0x9;     //8 bytes (write to I2CMST, use 2nd AHB Master)
  b2m0_desc[0].status        = 0;                 
  idx = 0;
  // In total write (4 target AHB addr) * 8 bytes into I2CMst Regs)
  for (i=0; i<4; i++) {
    idx++; // Conditional Descriptor
    b2m0_desc[idx].next_desc     = (desc*) (( (int) &b2m0_desc[idx+1]) | 0x1);
    // Interrupt Option (2 lines below)
//    b2m0_desc[idx].start_address = i2cmirq;        //address (IRQ number of the I2C Mst that is waited for)
//    b2m0_desc[idx].control       = 0x00080003;     //control (write 8bytes after each IRQ to I2C Mst APB regs)
    // Bit poll Option (2 lines below)
    b2m0_desc[idx].start_address = &(i2cm->csr);    //address (poll address of the I2C Mst that is waited for)
    b2m0_desc[idx].control       = 0x00080FF9;      //control (write 8bytes when bit is set in I2C Mst APB regs, use AHB Master1)
    b2m0_desc[idx].status        = 0x00000001;      //mask (check interrupt flag when bit-polling)
    idx++; // Data Descriptor
    b2m0_desc[idx].next_desc     = &b2m0_desc[idx+1];
    b2m0_desc[idx].start_address = &(i2cm->xr);     //address (Write start address of the I2CMST Command APB reg)
    b2m0_desc[idx].control       = 0x00080009;      //control (2nd AHB Master)
    b2m0_desc[idx].status        = 0;
  }
  idx++; // Conditional Descriptor
  b2m0_desc[idx].next_desc     = (desc*) (( (int) &b2m0_desc[idx+1]) | 0x1);
  b2m0_desc[idx].start_address = &(i2cm->csr);      //address (poll address of the I2C Mst that is waited for)
  b2m0_desc[idx].control       = 0x00080FF9;        //control (write 8bytes when bit is set in I2C Mst APB regs, use AHB Master1)
  b2m0_desc[idx].status        = 0x00000001;        //mask (check interrupt flag when bit-polling)
  idx++;  // Start condition again
  b2m0_desc[idx].next_desc     = &b2m0_desc[idx+1]; // Send start condition + slave address.  
  b2m0_desc[idx].start_address = &(i2cm->xr);       //address (write address of the I2C Mst Tx register)
  b2m0_desc[idx].control       = (8 << 16) | 0x9;   //control (write 8 bytes to I2CMST, use AHB Master1)
  b2m0_desc[idx].status        = 0;
  idx++; // Conditional Descriptor
  b2m0_desc[idx].next_desc     = (desc*) (( (int) &b2m0_desc[idx+1]) | 0x1);
  b2m0_desc[idx].start_address = &(i2cm->csr);      //address (IRQ number of the I2C Mst that is waited for)
  b2m0_desc[idx].control       = 0x00080FF9;        //control (write 8bytes when bit is set in I2C Mst APB regs, use AHB Master1)
  b2m0_desc[idx].status        = 0x00000001;        //mask (check interrupt flag when bit-polling)
  idx++;  // Set read command
  b2m0_desc[idx].next_desc     = 0;                 // Send start condition + slave address.  
  b2m0_desc[idx].start_address = &(i2cm->csr);      //address (write address of the I2C Mst Tx register)
  b2m0_desc[idx].control       = (4 << 16) | 0x9;   //control (write 4 bytes to I2CMST, use AHB Master1)
  b2m0_desc[idx].status        = 0;                 


  // Channel 1 receives byte 0. Ch3 receives byte 1. 
  // Ch5 receives byte 2. Ch7 receives byte 3 and stops. 
  for (i = 0; i < 4; i++) {
    // Conditional Descriptor
    m2b_desc_arr[i][0].next_desc     = (desc*) (( (int) &(m2b_desc_arr[i][1])) | 0x1);
    m2b_desc_arr[i][0].start_address = &(i2cm->csr);//address (IRQ number of the I2C Mst that is waited for)
    m2b_desc_arr[i][0].control       = 0x00013FF9;  //control (read 1 byte after IRQ flag set in I2C Mst APB regs)
    m2b_desc_arr[i][0].status        = 0x00000001;  //mask (check interrupt flag when bit-polling)
    // Data descriptor. Read data byte
    m2b_desc_arr[i][1].next_desc     = (desc*) 0;
    m2b_desc_arr[i][1].start_address = ((char*) &(i2cm->xr)) + 3; //address (I2C Mst Rx register )
    m2b_desc_arr[i][1].control       = (1 << 16) | 0x9; //control (read from fixed address)
    m2b_desc_arr[i][1].status        = 0;
    // Data descriptor. Write Rx data to memory
    b2m_desc_arr[i][0].next_desc     = 0;
    b2m_desc_arr[i][0].start_address = &(rxdata[i]);
    b2m_desc_arr[i][0].control       = 0x00010001;
    b2m_desc_arr[i][0].status        = 0;
  }
  b2m_desc_arr[3][0].control |= 0x4;                //Generate Interrupt on last descriptor after byte 3 read

  // Channel 2,4 Writes Read-command into I2C Mst APB reg to get next byte
  // Descriptors are reused for Channed 4 and 6.
  m2b1_desc[0].next_desc     = 0;
  m2b1_desc[0].start_address = &slvread;            //address (commands to write into I2CMST Tx and Command APB regs)
  m2b1_desc[0].control       = 0x00040001;          //control (fetch 8bytes of writecmd0)
  m2b1_desc[0].status        = 0;
  b2m1_desc[0].next_desc     = 0;                   // Send start condition + slave address.  
  b2m1_desc[0].start_address = &(i2cm->csr);        //address (I2C Mst Tx register)
  b2m1_desc[0].control       = (4 << 16) | 0x9;     //4 bytes (write to I2CMST, use AHB Master1)
  b2m1_desc[0].status        = 0;

  // Channel 6. Write Read Stop NACK command into I2C Mst APB reg to get last byte
  m2b_rdnack_desc[0].next_desc     = 0;
  m2b_rdnack_desc[0].start_address = &slvcmdrd_nackstop;  //address (commands to write into I2CMST Tx and Command APB regs)
  m2b_rdnack_desc[0].control       = 0x00040001;          //control (fetch 8bytes of writecmd0)
  m2b_rdnack_desc[0].status        = 0;
  b2m_rdnack_desc[0].next_desc     = 0;                   // Send start condition + slave address.  
  b2m_rdnack_desc[0].start_address = &(i2cm->csr);        //address (I2C Mst Tx register)
  b2m_rdnack_desc[0].control       = (4 << 16) | 0x9;     //4 bytes (write to I2CMST, use AHB Master1)
  b2m_rdnack_desc[0].status        = 0;

  // Setup DMA 
  grdmac_reg->control = 0x00000002;
  grdmac_reg->interrupt_mask = 0xFFFFFFFF ;
  grdmac_reg->cvp =  (volatile unsigned int **)&cvp0;
   // start DMAC channels 0 to 7
  grdmac_reg->control = 0x00FF000D;
  while (!grdmacirq);               // wait for interrupt
  grdmacirq = 0; // clear counter

  for(i = 0; i < transfer_size; i++){
    if(rxdata[i] != txdata[i]) fail(0); 
  }
}
