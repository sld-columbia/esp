
extern struct irqmp *irqmp_base;


struct irqmp {
        volatile unsigned int irqlevel;    /* 0x00 */
        volatile unsigned int irqpend;	   /* 0x04 */
        volatile unsigned int irqforce;	   /* 0x08 */
        volatile unsigned int irqclear;	   /* 0x0C */
        volatile unsigned int mpstatus;	   /* 0x10 */
        volatile unsigned int broadcast;   /* 0x14 */
        volatile unsigned int dummy0;      /* 0x18 */
        volatile unsigned int wdogctrl;    /* 0x1C (IRQ(A)MP) */
        volatile unsigned int asmpctrl;    /* 0x20 (IRQ(A)MP) */
        volatile unsigned int icsel0;	   /* 0x24 (IRQ(A)MP) */
        volatile unsigned int icsel1; 	   /* 0x28 */
        volatile unsigned int dummy1[5];   /* 0x2c - 0x3C */
        volatile unsigned int irqmask;     /* 0x40 */
};


/* IRQ(A)MP timestamp register set */

struct irqmp_ts {
        volatile unsigned int cnt;         /* 0x100 + 0x10*n */
        volatile unsigned int ctrl;        /* 0x104 * 0x10*n */
        volatile unsigned int assert;      /* 0x108 * 0x10*n */
        volatile unsigned int ack;         /* 0x10C * 0x10*n */
};

/* TS control register fields */
#define IRQTSC_TSTAMP 27
#define IRQTSC_S1     (1 << 26)
#define IRQTSC_S2     (1 << 25)
#define IRQTSC_KS     (1 << 5)

/* Wdog control register fields */
#define IRQWDC_NWDOG 27
#define IRQWDC_WDOGIRQ 16
