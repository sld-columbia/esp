
typedef struct sectype {
    unsigned int    paddr;
    unsigned int    raddr;
    unsigned int    len;
    unsigned int    comp;
    unsigned char   name[16];
}   tt;

extern struct sectype sections[];

void __main(void) { }

void clean(paddr,len)
double *paddr;
int len;
{
    len >>=3;
    while (len >= 0) {
    	paddr[len] = 0;
	len--;
    }
}

void mmov(raddr,paddr,len)
int *raddr, *paddr;
int len;
{
    len >>=2;
    while (len >= 0) {
    	paddr[len] = raddr[len];
	len--;
    }
}

unsigned int _prom_getpsr();

extern volatile unsigned int *_uaddr;
extern int _iserc32;
extern int ERC32_MEC;
extern int _agga4;

#define MEC_UARTA	0x0E0/4
#define MEC_UARTB	0x0E4/4
#define MEC_UART_CTRL	0x0E8/4

#define AGGA4_TXSAP 0
#define AGGA4_TXEAP 1
#define AGGA4_TXCAP 2

#define	USR	4/4
#define TXA	0/4

void putsx(s)
	unsigned char *s;
{
	volatile unsigned int *ubase;

	if (_iserc32) {
		/* erc32 */
		ubase = (unsigned int *) &ERC32_MEC;
		while (s[0] != 0) {
			while ((ubase[MEC_UART_CTRL] & 4) == 0) {
				;
			}
			ubase[MEC_UARTA] = *s;
			s++;
		}

	} else if (_agga4) {
		volatile unsigned char __attribute__((aligned(4))) buf[4];
		while (s[0] != 0) {
			ubase = _uaddr;
			buf[0] = *s++;
			ubase[AGGA4_TXSAP] = (unsigned int)&buf[0];
			ubase[AGGA4_TXEAP] = (unsigned int)&buf[0];
			while (ubase[AGGA4_TXCAP] <= (unsigned int)&buf[0]) {
				asm volatile ("nop;nop;nop;nop;nop");
			}
		}

	} else {
		if (((_prom_getpsr() >> 24) & 0x0f) != 3) {
			ubase = (unsigned int *) 0x80000070;
		} else {
			ubase = _uaddr;
		}
		while (s[0] != 0) {
			while ((ubase[USR] & 4) == 0) {
				;
			}
			ubase[TXA] = *s;
			s++;
		}
	}

}

void
puthex (h)
     unsigned int h;
{
  int i = 0;
  char b[9];
  for (i = 0;i < 8;i++,h<<=4) {
    char c = ((h & 0xf0000000) >> 28) & 0xf;
    if (c >= 10) {
      c += 'a' - 10;
    } else {
      c += '0';
    }
    b[i] = c;
  }
  b[8] = 0;
  putsx(b);
}

extern int ramsize, etext, freq, bmsg, _stack;

int main(void)
{
    int   secnum;
    void  (*prog) ();

    prog = (void *) sections[0].paddr;
    secnum = 0;
    while (sections[secnum].paddr) {
	if (sections[secnum].paddr != 0x800) {
	  if (bmsg)
	    {
	      putsx (" moving ");
	      putsx (sections[secnum].name);
	      putsx (" from 0x");
	      puthex(sections[secnum].raddr);
	      putsx (" to 0x");
	      puthex(sections[secnum].paddr);
	      putsx ("\n\r");
	    }

	  mmov(sections[secnum].raddr,
	       sections[secnum].paddr, sections[secnum].len);

	}
	secnum++;
    }
    /* reset cwp to 0 */
  __asm__ __volatile__(                                                   \
"        mov     %0,%%g1                                             \n\t"\
"        mov     %%sp,%%g2                                           \n\t"\
"        mov     %%fp,%%g3                                           \n\t"\
"        mov     %%psr,%%g4                                          \n\t"\
"        andn    %%g4,0x1f,%%g4                                      \n\t"\
"        wr      %%g4, 0x00, %%psr                                   \n\t"\
"        nop;nop;nop                                                 \n\t"\
"        set     2, %%g4                                             \n\t"\
"        wr      %%g4,0, %%wim                                       \n\t"\
"        nop;nop;nop                                                 \n\t"\
"        mov     %%g2,%%sp                                           \n\t"\
"        mov     %%g3,%%fp                                           \n\t"\
"        jmp     %%g1                                                \n\t"\
"        nop                                                         \n\t"\
: : /* %0 */ "r" (prog)
:       "g1", "g2", "g3", "g4"	\
	);

    prog();
    return 0;
}

