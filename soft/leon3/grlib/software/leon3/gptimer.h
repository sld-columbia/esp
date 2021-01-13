struct timerreg {
    volatile unsigned int counter;		/* 0x0 */
    volatile unsigned int reload;		/* 0x4 */
    volatile unsigned int control;		/* 0x8 */
    volatile unsigned int latch;		/* 0xC */
};

struct gptimer {
    volatile unsigned int scalercnt;		/* 0x00 */
    volatile unsigned int scalerload;		/* 0x04 */
    volatile unsigned int configreg;		/* 0x08 */
    volatile unsigned int latchconfig;		/* 0x0C */
    struct timerreg timer[7];
};

/* Timer n control register */
#define GPTIMER_DH 0x40
#define GPTIMER_CH 0x20
#define GPTIMER_IP 0x10
#define GPTIMER_IE 0x08
#define GPTIMER_LD 0x04
#define GPTIMER_RS 0x02
#define GPTIMER_EN 0x01

#define GPTIMER_ES 0x1000
#define GPTIMER_EL 0x0800

/* Configuration register */
#define CHAIN_TEST 8

/* Set gpiobase iff base != NULL. Returns previous base. */
void *gptimer_gpiobase(void *base);
/* Set spwtdpbase iff base != NULL. Returns previous base. */
void *gptimer_spwtdpbase(void *base);
