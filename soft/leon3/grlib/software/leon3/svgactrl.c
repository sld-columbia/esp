/*
 * SVGACTRL standalone demo. 
 *
 * Copyright (c) 2008, 2009 Aeroflex Gaisler AB
 *
 * This file can be compiled into a file suitable for simulation
 * or a file that draws a "real" screen. Drawing of a screen in a
 * normal resolution takes a long time and may not be desired when
 * running a system test in simulation. The choice is made by passing
 * arguments to the test function.
 *
 * Note that, even in "simulation" mode, this application requires a 
 * relatively long time to complete and it is normally not included
 * when running GRLIB tests.
 *
 * With 'real' set to a non-zero value:
 * This application has a number of supported formats that are listed 
 * in the "formats" array below. The core's pixelclocks are matched 
 * against the period required for each format. As soon as a match has
 * been found a framebuffer is allocated and cleared. The core is then 
 * enabled  and a testscreen is drawn in the framebuffer. 
 *
 * With 'real' set to zero:
 * The application choses the first available clock and draws a 
 * small screen.
 *
 */

#include <stdio.h>
#include <malloc.h>
#include "testmod.h"

/* Status register field positions */

#define SVGACTRL_CLKSEL 6
#define SVGACTRL_BDSEL  4
#define SVGACTRL_EN     0

struct svgactrlregs {
   volatile unsigned int stat;
   volatile unsigned int vidlen;
   volatile unsigned int fporch;
   volatile unsigned int synclen;
   volatile unsigned int linelen;
   volatile unsigned int framebuf;
   volatile unsigned int dclock[4];
   volatile unsigned int clut;
};

typedef struct {
   const char *name;
   int period; /* Clock period in ps */
   /* Horizontal (in Pixels) */
   int hactive_video;
   int hfporch;
   int hsync;
   int hbporch;
   /* Vertical (in lines) */
   int vactive_video;
   int vfporch;
   int vsync;
   int vbporch;
} format_s;

#define NUM_FORMATS 17
#define TEST_FORMAT 16

static format_s formats[NUM_FORMATS] = {
   /* 0 */
   { 
      .name = "480x272, ",
      .period = 111111,
      .hactive_video = 480,
      .hfporch = 2,
      .hsync = 1,
      .hbporch = 43,
      .vactive_video = 272,
      .vfporch = 2,
      .vsync = 1,
      .vbporch = 12,
   },
   /* 1 */
   { 
      .name = "480x240, ",
      .period = 120482,
      .hactive_video = 480,
      .hfporch = 20,
      .hsync = 1,
      .hbporch = 108,
      .vactive_video = 240,
      .vfporch = 2,
      .vsync = 1,
      .vbporch = 20,
   },
   /* 2 */
   { 
      .name = "640x480, 60 Hz",
      .period = 40000,
      .hactive_video = 640,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 48,
      .vactive_video = 480,
      .vfporch = 11,
      .vsync = 2,
      .vbporch = 31,
   },
   /* 3 */
   {
      .name =  "640x480, 72 Hz",
      .period = 31746,
      .hactive_video = 640,
      .hfporch = 24,
      .hsync = 40,
      .hbporch = 148,
      .vactive_video = 480,
      .vfporch = 9,
      .vsync = 3,
      .vbporch = 28,
   },
   /* 4 */
   {
      .name =  "640x480, 75 Hz",
      .period = 31746,
      .hactive_video = 640,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 48,
      .vactive_video = 480,
      .vfporch = 11,
      .vsync = 2,
      .vbporch = 32,
   },
   /* 5 */
   {
      .name =  "640x480, 85 Hz",
      .period = 27778,
      .hactive_video = 640,
      .hfporch = 32,
      .hsync = 48,
      .hbporch = 112,
      .vactive_video = 480,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 25,
   },
   /* 6 */
   { 
      .name = "800x480, ",
      .period = 30120,
      .hactive_video = 800,
      .hfporch = 40,
      .hsync = 1,
      .hbporch = 216,
      .vactive_video = 480,
      .vfporch = 10,
      .vsync = 1,
      .vbporch = 35,
   },
   /* 7 */
   {
      .name =  "800x600, 56 Hz",
      .period = 26247,
      .hactive_video = 800,
      .hfporch = 32,
      .hsync = 128,
      .hbporch = 128,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 4,
      .vbporch = 14,
   },
   /* 8 */
   {
      .name =  "800x600, 60 Hz",
      .period = 25000,
      .hactive_video = 800,
      .hfporch = 40,
      .hsync = 128,
      .hbporch = 88,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 4,
      .vbporch = 23,
   },
   /* 9 */
   {
      .name =  "800x600, 72 Hz",
      .period = 20000,
      .hactive_video = 800,
      .hfporch = 56,
      .hsync = 120,
      .hbporch = 64,
      .vactive_video = 600,
      .vfporch = 37,
      .vsync = 6,
      .vbporch = 23,
   },
   /* 10 */
   {
      .name =  "800x600, 75 Hz",
      .period = 20202,
      .hactive_video = 800,
      .hfporch = 16,
      .hsync = 80,
      .hbporch = 160,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 2,
      .vbporch = 21,
   },
   /* 11 */
   {
      .name =  "800x600, 85 Hz",
      .period = 17778,
      .hactive_video = 800,
      .hfporch = 32,
      .hsync = 64,
      .hbporch = 152,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 27,
   },
   /* 12 */
   {
      .name =   "1024x768, 60 Hz",
      .period = 15385,
      .hactive_video = 1024,
      .hfporch = 24,
      .hsync = 136,
      .hbporch = 160,
      .vactive_video = 768,
      .vfporch = 3,
      .vsync = 6,
      .vbporch = 29,
   },
   /* 13 */
   {
      .name =  "1024x768, 70 Hz",
      .period = 13333,
      .hactive_video = 1024,
      .hfporch = 24,
      .hsync = 136,
      .hbporch = 144,
      .vactive_video = 768,
      .vfporch = 3,
      .vsync = 6,
      .vbporch = 29,
   },
   /* 14 */
   {
      .name =  "1024x768, 75 Hz",
      .period = 12698,
      .hactive_video = 1024,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 176,
      .vactive_video = 768,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 28,
   },
   /* 15 */
   {
      .name =  "1024x768, 80 Hz",
      .period = 10582,
      .hactive_video = 1024,
      .hfporch = 48,
      .hsync = 96,
      .hbporch = 208,
      .vactive_video = 768,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 36,
   },
   /* 16 */
   {
      .name = "small", 
      .period = 40000,
      .hactive_video = 10,
      .hfporch = 1,
      .hsync = 1,
      .hbporch = 1,
      .vactive_video = 10,
      .vfporch = 1,
      .vsync = 1,
      .vbporch = 1, 
   }
};

#define RED   0xF100
#define GREEN 0x07E0
#define BLUE  0x001F

/*
 * svgactrl_test(...)
 *
 * Arguments:
 *
 * addr      - Address of core registers
 * real      - See description at top of file
 * alloc     - Allocate memory dynamically, otherwise fbaddress is used
 * fbaddress - Frame buffer address
 * format    - Selects format or -1 for autodetect
 * delay     - Counter that delays core disable, -1 to delay forever
 * blank     - Blank screen before core enable 
 *
 */
int svgactrl_test(unsigned int addr, unsigned int real, unsigned int alloc, 
                  unsigned int fbaddress, int format, int delay, int blank)
{
  int i, x, y, vec[3];
  int found = 0;
  int clock;
  unsigned int *fbase;

  format_s *f;

  struct svgactrlregs *regs;
  
  report_device(0x01063000);

  regs = (struct svgactrlregs*)(addr);

  regs->stat = 0;


  report_subtest(1); 

  if (real) {
     if (format == -1) {
        /* Scan available clocks */
        for (format = 0; format < NUM_FORMATS && !found; format++) {
           for (clock = 0; clock < 4; clock++) {
              if (formats[format].period == regs->dclock[clock]) {
                 found = 1;
                 break;
              }
           }
        }
     } else {
        /* Check if clock for format is available */
        for (clock = 0; clock < 4; clock++) {
           if (formats[format].period == regs->dclock[clock]) {
              found = 1;
              break;
           }
        }
     }
  } else {
     /* Must have a clock with period != 0 */
     format = TEST_FORMAT;
     for (clock = 0; clock < 4; clock++) {
        if (regs->dclock[clock]) {
           found = 1;
           break;
        }
     }
  }

  if (!found) {
     fail(0);
  }

  report_subtest(2); /* Draw screen */
  
  f = &formats[format];

  regs->vidlen = ((f->vactive_video-1) << 16)  | (f->hactive_video-1);
  regs->fporch = ((f->vfporch) << 16)  | (f->hfporch);
  regs->synclen = ((f->vsync) << 16)  | (f->hsync);
  regs->linelen = (((f->vactive_video-1 + f->vfporch + f->vsync + f->vbporch) << 16) |
                   (f->hactive_video-1 + f->hfporch + f->hsync + f->hbporch));
 
  if (alloc) {
     /* Allocate framebuffer */
     fbase = memalign(1024, 2*f->hactive_video*f->vactive_video);
     if (fbase == NULL) {
        fail(1);
     }
  } else {
     /* Use specific frame buffer base address */
     fbase = (int*)fbaddress;
  }
  regs->framebuf = (int)fbase;
  
  if (blank) {
     /* Blank screen */
     for (x = 0; x < f->hactive_video*f->vactive_video/2; x++) {
        fbase[x] = 0x00000000;
     }
  }

  /* Enable controller */
  regs->stat = ((clock << SVGACTRL_CLKSEL) | (2 << SVGACTRL_BDSEL) |
                (1 << SVGACTRL_EN));
   
  if (real) {
     /* Draw test screen */
     vec[0] = 0;
     vec[1] = f->vactive_video/2;
     vec[2] = f->vactive_video-1;
     
     for(y = 0; y <= 2; y++) {
        for(x = 0; x <  f->hactive_video/2; x++) {
           fbase[x+(vec[y]* f->hactive_video/2)] = 0xffffffff;
        }
     }
     
     for(y = 0; y < f->vactive_video; y++){
        fbase[0+(y*f->hactive_video/2)] |= 0xffff0000;
     }
     
     for(y = 0; y < f->vactive_video; y++){
        fbase[f->hactive_video/4 +(y*f->hactive_video/2)] |= 0xffff0000;
     }
     
     for(y = 0; y < f->vactive_video; y++){
        fbase[(f->hactive_video/2-1)+(y*f->hactive_video/2)] |= 0x0000ffff;
     }
  } else {
     /* Draw R, G and B pixels */
     for (x = 0; x < f->hactive_video*f->vactive_video/2; x++){
        switch (x % 3) {
        case 0: fbase[x] = (RED << 16) | GREEN; break;
        case 1: fbase[x] = (BLUE << 16) | RED; break;
        case 2: fbase[x] = (GREEN << 16) | BLUE; break;
        default: break;
        }
     }
  }

  if (delay != -1) {
     for (i = 0; i < delay; i++)
        ;
  } else {
     while(1)
        ;
  }

  /* Deactivate core */
  regs->stat = 0;

  free(fbase);

  return 0;
}
