/************************************************************************/
/*   This file is a part of the mkprom3 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler AB                               */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/

#define	USR	4/4
#define TXA	0/4

#define	SECNAME	16

typedef struct sectype
{
    unsigned int paddr;
    unsigned int raddr;
    unsigned int len;
    unsigned int comp;
    unsigned char name[SECNAME];
} tt;

extern char filename[];
extern struct sectype sections[];
extern int prot;
extern volatile unsigned int *_uaddr;
extern int _iserc32;
extern int ERC32_MEC;
extern int _agga4;

unsigned int _prom_getpsr();

#define MEC_UARTA	0x0E0/4
#define MEC_UARTB	0x0E4/4
#define MEC_UART_CTRL	0x0E8/4

#define AGGA4_TXSAP 0
#define AGGA4_TXEAP 1
#define AGGA4_TXCAP 2

void
putsx (s)
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
		/* leon2/3 */
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


void __main (void)
{
}

extern int ramsize, etext, freq, bmsg, _stack;
void clean ();
void mmov (int *raddr, int *paddr, int len);
extern int Decode ();
extern char configmsg[];
extern int noinit;
extern int _entry;
extern int _mp;
extern void _prom_mp(void);

#ifndef RELEASE_VERSION
  #define RELEASE_VERSION_STRING "2.0"
#else
  #define str0(s) #s
  #define str1(s) str0(s)
  #define RELEASE_VERSION_STRING str1(RELEASE_VERSION)
#endif

int main (void)
{
    /* int *paddr, *raddr, len, secnum, err; */
    void (*prog) ();
    /*char pbuf[8192];*/

    prog = (void *) _entry;
    if (bmsg)
      {
	  putsx ("\n\n\r  MKPROM2 boot loader v" RELEASE_VERSION_STRING "\n\r");
	  putsx ("  Copyright Cobham Gaisler AB - all rights reserved\n\n\r");
	  putsx (configmsg);
	  putsx ("\n\r");
      }
    /* secnum = 0; */
    /* while (sections[secnum].paddr || sections[secnum].raddr) */
    /*   { */
    /* 	  paddr = (int *)sections[secnum].paddr; */
    /* 	  raddr = (int *)sections[secnum].raddr; */
    /* 	  len = sections[secnum].len; */
    /* 	  if (sections[secnum].comp) */
    /* 	    { */
    /* 		if (bmsg) */
    /* 		  { */
    /* 		      putsx ("  decompressing "); */
    /* 		      putsx (sections[secnum].name); */
    /* 		      putsx (" to 0x"); */
    /* 		      puthex(paddr); */
    /* 		      putsx ("\n\r"); */
    /* 		  } */
    /* 		if ((err = Decode (raddr, paddr))) */
    /* 		  { */
    /* 		      putsx ("  decompression failed ("); */
    /* 		      puthex(err); */
    /* 		      putsx (")\n\r"); */
    /* 		  } */

    /* 	    } */
    /* 	  else */
    /* 	    { */
    /* 		if (bmsg) */
    /* 		  { */
    /* 		      putsx ("  loading "); */
    /* 		      putsx (sections[secnum].name); */
    /* 		      putsx ("\n\r"); */
    /* 		  } */
    /* 		mmov (raddr, paddr, len); */
    /* 	    } */
    /* 	  secnum++; */
    /*   } */

    /* if (_iserc32) */
    /*     *((int *) (sections[0].paddr + 0x7e0)) = freq; */

    /* if (bmsg) */
    /*   { */
    /* 	  putsx ("\n\r  starting "); */
    /* 	  putsx (filename); */
    /* 	  putsx ("\n\n\r"); */
    /*   } */

    if (_mp)
	    _prom_mp();

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


  //prog ();
  return 0;
}

void
clean (paddr, len)
     double *paddr;
     int len;
{
    len >>= 3;
    while (len >= 0)
      {
	  paddr[len] = 0;
	  len--;
      }
}

void
mmov (raddr, paddr, len)
     int *raddr, *paddr;
     int len;
{
    len >>= 2;
    while (len >= 0)
      {
	  paddr[len] = raddr[len];
	  len--;
      }
}
