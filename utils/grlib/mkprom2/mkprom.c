/************************************************************************/
/*   This file is a part of the mkprom2 boot-prom utility               */
/*   Copyright (C) 2004 Cobham Gaisler AB                               */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/

/*
* This file is part of MKPROM.
* 
* MKPROM3, LEON boot-prom utility. 
* Copyright (C) 2004 Cobham Gaisler AB - all rights reserved.
* 
*/

#ifdef WIN32
#include <windows.h>
#include <winsock2.h>
#endif

#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define VAL(x)  parsevaluestr(x)
#define SECMAX  32
#define SECNAME 16

/* Macro for determining number of elements in an array. */
#define NELEM(x) ((int) ((sizeof (x)) / (sizeof (x[0]))))

/* MEC register addresses */

typedef struct sectype
{
    unsigned int paddr;
    unsigned int raddr;
    unsigned int len;
    unsigned int comp;
    char name[SECNAME];
}
tt;

static int ldaout(FILE *fp, FILE * dumpfile);
static int elf_load (char *fname);
static void appendbch8(char *post, int rev, int set, int pos);
unsigned int ldelf (FILE * fp, FILE * dumpfile);

struct sectype secarr[SECMAX];
char filename[128] = "a.out";
int romsize = 0x80000;
unsigned int romedacaddr = 0;
unsigned int romedacaddr_set = 0;
int romsize_given = 0;
int sparcleon0 = 0;
int sparcleon0rom = 0;
    
#ifndef TOOLBASE
#define TOOLBASE "/opt/mkprom2"
#endif
#ifndef RELEASE_VERSION
#define RELEASE_VERSION "2.0.50"
#endif

#if defined(__CYGWIN32__) || defined(__MINGW32__)
    char *OS_EXESUFFIX = ".exe";
#else
    char *OS_EXESUFFIX = "";
#endif

const char version[] = "v" RELEASE_VERSION;
int secnum = 0;
FILE *dumpfile;

FILE *flashld = 0;
char *flashldn = "dolinkromimg";
char *flashsections[128];
int flashsectionspos = 0;
int dodump = 0;
int verbose = 0;
int vverbose = 0;
int leon = 1;
double freq = 0;
int romres = 0;
int comp = 1;
int flash = 0;
int entry[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int entry0_set = 0;
/*int starta = 0;*/
unsigned int startaddr = 0;
int foffset = 0;
char ofile[128] = "prom.out";

enum {
    MULTIFLAG_FLAT  = 0x01,
    MULTIFLAG_SOFT  = 0x04
};
/*
 * multiflags: Bit mask with MULTIFLAG_x values
 * return: string describing multi-lib directory
 */
static const char *get_multidir(unsigned int multiflags);

char *ccprefix = "sparc-elf";
int ccprefixdo = 0;
char *prefix = TOOLBASE;
    
void usage(char *);

int searchforcc(char *p) {
    char cmd[1024];
#ifdef WIN32
    snprintf(cmd, 1024, "%s-gcc --version > NUL 2>&1", p);
#else
    snprintf(cmd, 1024, "%s-gcc --version > /dev/null 2>&1", p);
#endif
    if (!system(cmd)) {
	return 1;
    }
    return 0;
}

static unsigned int parsevaluestr(const char *valuestr)
{
    char *endptr;
    unsigned int result;
    char errmsg[256];

    errno = 0;
    result = strtoul(valuestr, &endptr, 0);

    if (errno == 0 && *valuestr != 0 && *endptr == 0)
        return result;

    snprintf(errmsg, 256, "Unable to parse value \"%s\"", valuestr);
    if (errno != 0)
        perror(errmsg);
    else
        fprintf(stderr, "%s!\n", errmsg);
    exit(1);
}

static inline void trysystem(const char *command)
{
  int ret;

  ret = system(command);
  if (0 == ret) {
    return;
  } else if (-1 == ret) {
    perror("MKPROM2 ERROR:");
    exit(1);
  } else {
    fprintf(stderr, "MKPROM2 ERROR: <%s> returned %d\n", command, ret);
    exit(2);
  }
}

int main (argc, argv)
     int argc;
     char **argv;

{

    int n;
    FILE *xfile;
    char lscriptpath[512], lscriptpathdel[512];
    char buf[1024];
    char cmd[1024];
    char msg[128];
    int baud = 19200;
    int dsubreak = 0;
    int i;
    unsigned int dsu_start = 0x90000000;
    int enable_trace = 0;
    int nopnp = 0, isddr = 0;
    unsigned int pnp = 0xFFFFF800;
    int ramcs = 1;
    int rambanks = 1;
    int romcs = 1;
    int rombanks = 1;
    unsigned int ramsize = 0x200000;
    int ramrws = 3;
    int ramwws = 3;
    int ramwidth = 32;
    int oramwidth = 32;
    int romwidth = 0;
    int rmw = 0;
    int romrws = 15;
    int romwws = 15;
    int stack[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    int stat = 1;
    int bmsg = 1;
    int bdinit = 0;
    int dump = 0;
    int iows = 7;
    int iowidth = 2;
    int tmp, tmp2;
    int sdramsz = 0;
    int nosram = 0;
    int noinit = 0;
    int sdrambanks = 1;
    int sdcas = 0;
    int trp = 20;
    int trfc = 66;
    int colsz = 1;
    int ddr_colsize = 1;
    int ddrramsz = 64;
    int ddrramsz_on = 0;
    double ddr_freq = 90.0;
    double ddr_refresh = 7.8;
    int ddrbanks = 1;
    double refresh = 7.8;
    double ftmp;
    int refr = 390;
    char flist[512] = "";
    char xlist[512] = "";
    unsigned int mpstart = 0, mpirqsel0 = 0, mpirqsel1 = 0;
    unsigned int entry[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    unsigned int uaddr[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    struct mpirqe { int cpu, sel; } mpirqsel[16] = {{0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}, {0,0}};
    unsigned int mpirqselcnt = 0;
    unsigned int memcaddr = 0x80000000;
    unsigned int gptaddr = 0x80000300;
    unsigned int irqmpaddr = 0x80000200;
    int ecos = 0;
    int mp = 0;
    int ncpu = 0;
    int uartnr = 0;
    int qsvt = 0;
    unsigned int multiflags = 0;
    int checksvt = 0;
    const char *multidir = NULL;
    char *promcore = "promcore.o";
    char *promcrt0 = "promcrt0.o";
    char *promload = "";
    char *promload_decomp = "";
    int leon3 = 1;
    int leon2 = 0;
    int erc32 = 0;
    int agga4 = 0;
    int edac = 0;
    int doft = 0;
    char *prominit = "prominit_leon3.o";
    int clean_ram0 = 0;
    int clean_ram0_size = 0;
    int clean_ram1 = 0;
    int clean_ram1_size = 0;
    char *mkpromhome = getenv( "MKPROM_HOME" );
    int memcfg1_on = 0;
    int memcfg2_on = 0;
    int memcfg3_on = 0;
    int sdmemcfg1_on = 0;
    int ftsdctrl64_cfg_on = 0;
    int ftsdctrl64_cfg = 0;
     int ftsdctrl64_pwr_on = 0;
    int ftsdctrl64_pwr = 0;
    int ftsdctrl64_edac_on = 0;
    int ftsdctrl64_edac = 0;
    int ftahbram_edac_on = 0;
    int ddr2spa_cfg1_cmd = 0;
    int ddr2spa_cfg3_cmd = 0;
    int ddr2spa_cfg4_cmd = 0;
    int ddrspa_cfg1_cmd = 0;
    int _ddr2spa_cfg1 = 0;
    int _ddr2spa_cfg3 = 0;
    int _ddr2spa_cfg4 = 0;
    int _ddrspa_cfg1 = 0;
    int memcfg1 = 0;
    int memcfg2 = 0;
    int memcfg3 = 0;
    int sdmemcfg1 = 0;
    int spimeas = 0;
    int dobch8 = 0;
    int dobch8q = 0;
    int tmp_ftsdctrl64_cfg = 0, tmp_ftsdctrl64_pwr = 0, tmp_ftsdctrl64_edac = 0;
    int edac_clean_on = 0;
    int edac_clean0 = 0;
    int edac_size0 = 0;
    int edac_clean1 = 0;
    int edac_size1 = 0;
    int prominit_done = 0;
#ifdef LYNXOS_TOOL
    char *lynxoshome = getenv( "ENV_PREFIX" );
    char lynxoshome_pre[1024];
#endif
    char *postfix = OS_EXESUFFIX;
    if (mkpromhome) {
	prefix = mkpromhome;
    }

#ifdef LYNXOS_TOOL
    if (!lynxoshome) {
	    lynxoshome = "/usr/lynos/4.2.6/sparc/";
    }
    sprintf(lynxoshome_pre,"%s/cdk/mkprom2/",lynxoshome);
    prefix = lynxoshome_pre;
#endif    
    
    printf ("MKPROM %s - boot image generator for LEON applications\n", version);
    printf ("Copyright Cobham Gaisler AB 2004-2017, all rights reserved.\n\n");
	if (argc < 2)
	{
		 usage(argv[0]);
		 exit(0);
	}
    if ((dumpfile = fopen ("xdump.s", "w+")) == NULL)
      {
	  printf ("Failed to open temporary file\n");
	  exit (1);
      }
    while (stat < argc)
      {
	  if (argv[stat][0] == '-')
	    {
		if (strcmp (argv[stat], "-nocomp") == 0) {
		    comp = 0;
		}
		else if (strcmp (argv[stat], "-agga4") == 0)
		  {
		      agga4 = 1;
		      leon3 = 0;
		      leon2 = 0;
		      erc32 = 0;
		      leon = 1;
		  }
		else if (strcmp (argv[stat], "-erc32") == 0)
		  {
		      erc32 = 1;
		      agga4 = 0;
		      leon2 = 0;
		      leon3 = 0;
		      leon = 0;
		  }
		else if (strcmp (argv[stat], "-leon3") == 0)
		  {
		      leon3 = 1;
		      leon2 = 0;
		      erc32 = 0;
		      agga4 = 0;
		      leon = 1;
		  }
		else if (strcmp (argv[stat], "-leon2") == 0)
		  {
		      leon2 = 1;
		      leon3 = 0;
		      erc32 = 0;
		      agga4 = 0;
		      leon = 1;
		  }
	    }
	  stat++;
      }
    stat = 1;
    
    while (stat < argc)
      {
	  if (argv[stat][0] == '-')
	    {
		if (strcmp (argv[stat], "-v") == 0)
		  {
		      verbose = 1;
		  }
		else if (strcmp (argv[stat], "-V") == 0)
		  {
		      verbose = 1;
		      vverbose = 1;
		  }
		else if (strcmp (argv[stat], "-agga4") == 0)
		  {
		      agga4 = 1;
		      leon3 = 0;
		      leon2 = 0;
		      erc32 = 0;
		      leon = 1;
		  }
		else if (strcmp (argv[stat], "-erc32") == 0)
		  {
		      erc32 = 1;
		      leon2 = 0;
		      leon3 = 0;
		      agga4 = 0;
		      leon = 0;
		  }
		else if (strcmp (argv[stat], "-leon3") == 0)
		  {
		      leon3 = 1;
		      leon2 = 0;
		      erc32 = 0;
		      agga4 = 0;
		      leon = 1;
		  }
		else if (strcmp (argv[stat], "-leon2") == 0)
		  {
		      leon2 = 1;
		      leon3 = 0;
		      erc32 = 0;
		      agga4 = 0;
		      leon = 1;
		  }
		else if (strcmp (argv[stat], "-bch8q") == 0)
		  {
		      dobch8q = 1;
		  }
		else if (strcmp (argv[stat], "-bch8") == 0)
		  {
		      dobch8 = 1;
		  }
		else if (strcmp (argv[stat], "-ddr2spa_cfg1") == 0)
		  {
		      ddr2spa_cfg1_cmd = 1; isddr = 1;
		      if ((stat + 1) < argc)
			  {
			      _ddr2spa_cfg1 = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-ddr2spa_cfg3") == 0)
		  {
		      ddr2spa_cfg3_cmd = 1; isddr = 1;
		      if ((stat + 1) < argc)
			  {
			      _ddr2spa_cfg3 = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-ddr2spa_cfg4") == 0)
		  {
		      ddr2spa_cfg4_cmd = 1; isddr = 1;
		      if ((stat + 1) < argc)
			  {
			      _ddr2spa_cfg4 = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-ddrspa_cfg1") == 0)
		  {
		      ddrspa_cfg1_cmd = 1; isddr = 1;
		      if ((stat + 1) < argc)
			  {
			      _ddrspa_cfg1 = (VAL (argv[++stat]));
			  }
		  }

		else if (
			strcmp(argv[stat], "-mcfg1") == 0 ||
			strcmp(argv[stat], "-memcfg1") == 0
		)
		  {
		      memcfg1_on = 1;
		      if ((stat + 1) < argc)
			  {
			      memcfg1 = (VAL (argv[++stat]));
			  }
		  }

		else if (
			strcmp(argv[stat], "-mcfg2") == 0 ||
			strcmp(argv[stat], "-memcfg2") == 0
		)
		  {
		      memcfg2_on = 1;
		      if ((stat + 1) < argc)
			  {
			      memcfg2 = (VAL (argv[++stat]));
			  }
		  }

		else if (
			strcmp(argv[stat], "-mcfg3") == 0 ||
			strcmp(argv[stat], "-memcfg3") == 0
		)
		  {
		      memcfg3_on = 1;
		      if ((stat + 1) < argc)
			  {
			      memcfg3 = (VAL (argv[++stat]));
			  }
		  }
		else if (
			strcmp(argv[stat], "-sdcfg1") == 0 ||
			strcmp(argv[stat], "-sdmemcfg1") == 0
		)
		  {
		      sdmemcfg1_on = 1;
		      if ((stat + 1) < argc)
			  {
			      sdmemcfg1 = (VAL (argv[++stat]));
			  }
		  }

                
		else if (strcmp (argv[stat], "-ftsdctrl64_cfg1") == 0)
		  {
		      ftsdctrl64_cfg_on = 1;
		      if ((stat + 1) < argc)
			  {
			      ftsdctrl64_cfg = (VAL (argv[++stat]));
			  }
		  }
               else if (strcmp (argv[stat], "-sdctrl64_cfg1") == 0)
                 {
                     ftsdctrl64_cfg_on = 1;
                     if ((stat + 1) < argc)
                         {
                             ftsdctrl64_cfg = (VAL (argv[++stat]));
                         }
                 }
		else if (strcmp (argv[stat], "-ftsdctrl64_cfg2") == 0)
		  {
		      ftsdctrl64_pwr_on = 1;
		      if ((stat + 1) < argc)
			  {
			      ftsdctrl64_pwr = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-ftsdctrl64_edac") == 0)
		  {
		      ftsdctrl64_edac_on = 1;
		      if ((stat + 1) < argc)
			  {
			      ftsdctrl64_edac = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-ftahbram_edac") == 0)
		  {
		      ftahbram_edac_on = 1;
		  }

		else if (strcmp (argv[stat], "-spimeas") == 0)
		  {
		      spimeas = 1;
		  }

		else if (strcmp (argv[stat], "-edac-clean") == 0)
		  {
		      if ((stat + 4) < argc)
			  {
                              edac_clean_on = 1;
			      edac_clean0 = (VAL (argv[++stat]));
			      edac_size0  = (VAL (argv[++stat]));
			      edac_clean1 = (VAL (argv[++stat]));
			      edac_size1  = (VAL (argv[++stat]));
			  }
		  }
		else if (strcmp (argv[stat], "-edac") == 0)
		  {
		      edac = 1;
		  }
		else if (strcmp (argv[stat], "-ft") == 0)
		  {
		      doft = 1;
		  }
		else if (strcmp (argv[stat], "-ecos") == 0)
		  {
		      ecos = 1;
		  }
		else if (strcmp (argv[stat], "-rstaddr") == 0)
		  {
		      if ((stat + 1) < argc)
			  startaddr = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-baud") == 0)
		  {
		      if ((stat + 1) < argc)
			  baud = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-dump") == 0)
		  {
		      dump = 1;
		      dodump = 1;
		  }
		else if (strcmp (argv[stat], "-nocomp") == 0)
		  {
		      comp = 0;
		  }
		else if (strcmp (argv[stat], "-nomsg") == 0)
		  {
		      bmsg = 0;
		  }
		else if (strcmp (argv[stat], "-bdinit") == 0)
		  {
		      bdinit = 1;
		  }
		else if (strcmp (argv[stat], "-mp") == 0)
		  {
		      mp = 1;
		  }
		else if (strcmp (argv[stat], "-ccprefix") == 0)
		  {
		      if ((stat + 1) < argc) {
			  ccprefix = argv[++stat];
			  ccprefixdo = 1;			  
		      }
		  }
		else if (strcmp (argv[stat], "-freq") == 0)
		  {
		      if ((stat + 1) < argc)
			  freq = atof (argv[++stat]);
		      freq *= 1E6;
		  }
		else if (strcmp (argv[stat], "-memc") == 0)
		  {
		      if ((stat + 1) < argc)
			  memcaddr = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-gpt") == 0)
		  {
		      if ((stat + 1) < argc)
			  gptaddr = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-irqmp") == 0)
		  {
		      if ((stat + 1) < argc)
			  irqmpaddr = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-col") == 0)
		  {
		      if ((stat + 1) < argc)
			  colsz = VAL (argv[++stat]) - 8;
		      if ((colsz < 0) || (colsz > 3))
			  colsz = 1;
		  }
		else if (strcmp (argv[stat], "-ddrcol") == 0)
		  {
		      if ((stat + 1) < argc)
			  ddr_colsize = VAL (argv[++stat]);
		      if (ddr_colsize == 512 ||
			  ddr_colsize == 1024 ||
			  ddr_colsize == 2048 ||
			  ddr_colsize == 4096) {
			  if (ddr_colsize == 512)
			      ddr_colsize = 0;
			  else if (ddr_colsize == 1024)
			      ddr_colsize = 1;    
			  else if (ddr_colsize == 2048)
			      ddr_colsize = 2;
			  else if (ddr_colsize == 4096) 
			      ddr_colsize = 3;
		      } else {
			  printf("Expecting -ddrcol <512|1024|2048|4096>\n");
			  exit(1);
		      }
		      if ((ddr_colsize < 0) || (ddr_colsize > 3))
			  ddr_colsize = 0;
		  }
		else if (strcmp (argv[stat], "-ddrfreq") == 0)
		  {
		      if ((stat + 1) < argc)
			  ddr_freq = atof (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-ddrrefresh") == 0)
		  {
		      if ((stat + 1) < argc)
			  ddr_refresh = atof (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-ddrram") == 0)
		  {
		      if ((stat + 1) < argc)
			  ddrramsz = VAL (argv[++stat]);
		      ddrramsz_on = 1;
		  }
		else if (strcmp (argv[stat], "-ddrbanks") == 0)
		  {
		      if ((stat + 1) < argc)
			  ddrbanks = VAL (argv[++stat]);
		      ddrramsz_on = 1;
		  }
		/*		
		else if (strcmp (argv[stat], "-start") == 0)
		  {
		      if ((stat + 1) < argc)
			  starta = VAL (argv[++stat]) & ~3;
		  }
		*/
		else if (strcmp (argv[stat], "-cas") == 0)
		  {
		      if ((stat + 1) < argc)
			  sdcas = VAL (argv[++stat]) - 2;
		      if ((sdcas < 0) || (sdcas > 1))
			  sdcas = 1;
		  }
		else if (strcmp (argv[stat], "-sdrambanks") == 0)
		  {
		      if ((stat + 1) < argc)
			  sdrambanks = VAL (argv[++stat]);
		      if ((sdrambanks < 1) || (sdrambanks > 4))
			  sdrambanks = 1;
		  }
		else if (strcmp (argv[stat], "-nosram") == 0)
		  {
		      nosram = 1;
		  }
		else if (strcmp (argv[stat], "-noinit") == 0)
		  {
		      noinit = 1;
		  }
		else if (strcmp (argv[stat], "-sdram") == 0)
		  {
		      if ((stat + 1) < argc)
			  sdramsz = VAL (argv[++stat]);
		      sdramsz *= 1024 * 1024;
		  }
		else if (strcmp (argv[stat], "-trfc") == 0)
		  {
		      if ((stat + 1) < argc)
			  trfc = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-trp") == 0)
		  {
		      if ((stat + 1) < argc)
			  trp = VAL (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-refresh") == 0)
		  {
		      if ((stat + 1) < argc)
			  refresh = atof (argv[++stat]);
		  }
		else if (strcmp (argv[stat], "-o") == 0)
		  {
		      strncpy (ofile, argv[++stat], 127);
		      ofile[127] = 0;
		  }
		else if (strcmp (argv[stat], "-ramsize") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    ramsize = (VAL (argv[++stat])) & 0x03ffff;
			    ramsize *= 1024;
			}
		  }
		else if (strcmp (argv[stat], "-romws") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    int romws;

			    romws = (VAL (argv[++stat])) & 0xf;
			    romrws = romwws = romws;
			}
		  }
		else if (strcmp (argv[stat], "-romsize") == 0)
		  {
		      romsize_given = 1;
			  
		      if ((stat + 1) < argc)
			{
			    romsize = (VAL (argv[++stat])) & 0x01ffff;
			    romsize *= 1024;
			}
		  }
		else if (strcmp (argv[stat], "-romwidth") == 0)
		  {
		      if ((stat + 1) < argc)
			  romwidth = (VAL (argv[++stat]));
		  }
		else if (strcmp (argv[stat], "-romwidth") == 0)
		  {
		      if ((stat + 1) < argc)
			  romwidth = (VAL (argv[++stat]));
		  }
		else if (strcmp (argv[stat], "-iowidth") == 0)
		  {
		      if ((stat + 1) < argc)
			  iowidth = (VAL (argv[++stat]));
		  }
		else if (strcmp (argv[stat], "-ramcs") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    rambanks = (VAL (argv[++stat])) & 0x0f;
			    if ((rambanks > 0) || (rambanks < 9))
				ramcs = rambanks;
			}
		  }
		else if (strcmp (argv[stat], "-romcs") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    rombanks = (VAL (argv[++stat])) & 0x0f;
			    if ((rombanks > 0) || (rombanks < 9))
				romcs = rombanks;
			}
		  }
                else if (strcmp (argv[stat], "-sparcleon0rom") == 0)
                  {
                      sparcleon0 = 1;
                      sparcleon0rom = 1;
                  }
		else if (strcmp (argv[stat], "-sparcleon0") == 0)
                  {
                      sparcleon0 = 1;
                  }
		else if (strcmp (argv[stat], "-entry") == 0)
		  {
		      if ((stat + 1) < argc)
		      {
			entry[0] = (VAL (argv[++stat])) & ~0x03;
			entry0_set = 1;
		      }
		  }
		else if (strcmp (argv[stat], "-mpentry") == 0)
		  {
		    i = 0; ncpu = 0;
		    if ((stat + 1) < argc) 
		      ncpu = VAL (argv[++stat]);
		    while (((stat + 1) < argc) && (i < ncpu))
		    {
		      entry[i] = (VAL (argv[++stat])) & ~0x03;
		      i++;
		    }
		  }
                else if (strcmp (argv[stat], "-mpstart") == 0)
		  {
		    if ((stat + 1) < argc) 
		      mpstart = VAL (argv[++stat]);
		  }
                
                else if (strcmp (argv[stat], "-mpirqsel") == 0)
		  {
                      if ((stat + 2) < argc) {
                          mpirqsel[mpirqselcnt].cpu = (VAL (argv[++stat])) & (0x16-1);
                          mpirqsel[mpirqselcnt].sel = (VAL (argv[++stat])) & 0xf;
                          mpirqselcnt++;
                      }
		  }

		else if (strcmp (argv[stat], "-stack") == 0)
		  {
		      if ((stat + 1) < argc)
		      {
			stack[0] = (VAL (argv[++stat])) & ~0x01f;
		      }
		  }

		else if (strcmp (argv[stat], "-dsustart") == 0)
		  {
		      if ((stat + 1) < argc)
		      {
			dsu_start = (VAL (argv[++stat])) ;
		      }
		  }

		else if (strcmp (argv[stat], "-dsutrace") == 0)
		  {
		      enable_trace = 1;
		  }
		else if (strcmp (argv[stat], "-dsubreak") == 0)
		  {
		      dsubreak = 1;
		  }
		else if (strcmp (argv[stat], "-nopnp") == 0)
		  {
		      nopnp = 1;
		  }
		else if (strcmp (argv[stat], "-pnp") == 0)
		  {
		      if ((stat + 1) < argc)
		      {
			pnp = (VAL (argv[++stat])) ;
		      }
		  }

		else if (strcmp (argv[stat], "-mpstack") == 0)
		  {
		    i = 0; ncpu = 0;
		    if ((stat + 1) < argc) 
		      ncpu = VAL (argv[++stat]);
		    while (((stat + 1) < argc) && (i < ncpu))
		    {
		      stack[i] = (VAL (argv[++stat])) & ~0x01f;
		      i++;
		    }
		  }
		else if (strcmp (argv[stat], "-iows") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    iows = (VAL (argv[++stat])) & 0xf;
			}
		  }
		else if (strcmp (argv[stat], "-ramws") == 0)
		  {
		      if ((stat + 1) < argc)
			{
			    int ramws;

			    ramws = (VAL (argv[++stat])) & 0x3;
			    ramrws = ramwws = ramws;
			}
		  }
		else if (strcmp (argv[stat], "-ramrws") == 0)
		  {
		      if ((stat + 1) < argc)
			  ramrws = (VAL (argv[++stat])) & 0x3;
		  }
		else if (strcmp (argv[stat], "-ramwws") == 0)
		  {
		      if ((stat + 1) < argc)
			  ramwws = (VAL (argv[++stat])) & 0x3;
		  }
		else if (strcmp (argv[stat], "-ramwidth") == 0)
		  {
		      if ((stat + 1) < argc)
			  ramwidth = (VAL (argv[++stat]));
		      oramwidth = ramwidth;
		  }
		else if (strcmp (argv[stat], "-rmw") == 0)
		  {
		      rmw = 1;
		  }
		else if (strcmp (argv[stat], "-uart") == 0)
		  {

		      if ((stat + 1) < argc) {
			  uartnr = 1;
			  uaddr[0] = VAL (argv[++stat]);
		      }
		  }
		else if (strcmp (argv[stat], "-mpuart") == 0)
		  {
		    i = 0; uartnr = 0;
		    if ((stat + 1) < argc) 
		      uartnr = VAL (argv[++stat]);
		    while (((stat + 1) < argc) && (i < uartnr))
		    {
		      uaddr[i] = VAL (argv[++stat]);
		      i++;
		    }		
		  }
		else if (strcmp (argv[stat], "-checksvt") == 0)
		  {
		      checksvt = 1;
		  }
		else if (strcmp (argv[stat], "-romres") == 0)
		  {
		      romres = 1;
		  }
		else if (strcmp (argv[stat], "-qsvt") == 0) {
		    qsvt = 1;
		    goto copyxlist;
		}
		else if (strcmp (argv[stat], "-mflat") == 0) {
            multiflags |= MULTIFLAG_FLAT;
		    goto copyxlist;
		}
		else if (strcmp (argv[stat], "-msoft-float") == 0) {
            multiflags |= MULTIFLAG_SOFT;
		    goto copyxlist;
		}

		else
		  {
		  copyxlist:		      
		    strcat (xlist, " ");
		    strcat (xlist, argv[stat]);
		    strcat (xlist, " ");
		  }
	    }
	  else
	    {
                char *fn = argv[stat];

		if (secnum == 0) {
		    strcpy (filename, fn);
		    strcat (flist, fn);
		    strcat (flist, " ");
		} else {
		    strcat (flist, " ");
		    strcat (flist, fn);
		    strcat (flist, " ");
		}
		if ((!mp) && !entry0_set) 
		  entry[0] = elf_load (fn);
		else
		  elf_load (fn);

		/* 
		else
		{
		  entry[endx] = elf_load (argv[stat]);
		  endx++;
		}
		*/

	    }
	  stat++;
      }

    if (strlen(flist) == 0) {
        fprintf(stderr, "No input files specified!\n");
        exit(1);
    }

    if (freq < 1) {
        fprintf(stderr, "ERROR: Missing mandatory option -freq <mhz>\n");
        exit(1);
    }

	/* Setup defualt UART address */
	if (!uartnr) {
		if (leon2) {
			uaddr[0] = 0x80000070;
		} else if (agga4) {
			uaddr[0] = 0x80000180;
		} else {
			uaddr[0] = 0x80000100;
		}
		uartnr++;
	}

    multidir = get_multidir(multiflags);
    if (NULL == multidir) {
        printf ("ERROR: Could not determine mkprom2 multi-lib dir: Check the GCC -m* options.\n");
        exit (1);
    }
    if (qsvt) {
	if (checksvt) {
	    promcore = "promcore_svt_vhdl.o";
	} else {
	    promcore = "promcore_svt.o";
	}
    }
    
    printf ("Creating ");
    if (leon3) {
	printf ("LEON3");
    }
    if (leon2) {
	printf ("LEON2");
    }
	if (agga4) {
		printf("AGGA-4");
	}
    if (erc32) {
	printf ("ERC32");
    }
    printf (" boot prom: %s\n", ofile);
    if (!flash) {
        fprintf (dumpfile, "\n\t.text\n");
        fprintf (dumpfile, "\n\t.global filename\n");
        fprintf (dumpfile, "filename:\n");
        fprintf (dumpfile, "\t.string\t\"%s\"\n", filename);
        fprintf (dumpfile, "\n\t.align 32\n");
        fprintf (dumpfile, "\t.global sections\n");
        fprintf (dumpfile, "sections:\n");
        for (i = 0; i < secnum; i++)
          {
/* 	      if (entry && (i == 0)) */
/* 	          fprintf (dumpfile, "\t.word\t0x%x\n", entry); */
/* 	      else */
	      fprintf (dumpfile, "\t.word\t0x%x\n", secarr[i].paddr); 
	      fprintf (dumpfile, "\t.word\t_section%d\n", i);
	      fprintf (dumpfile, "\t.word\t0x%x\n", secarr[i].len);
	      fprintf (dumpfile, "\t.word\t0x%x\n", secarr[i].comp);
	      if (strlen(secarr[i].name) > 14) {
		  char b[16];
                  memset(b,0,sizeof(b));
		  strncpy(b,secarr[i].name,12);
		  strcat(b,"...");
		  fprintf (dumpfile, "\t.string\t\"%s\"\n", b);
	      } else {
		  fprintf (dumpfile, "\t.string\t\"%s\"\n", secarr[i].name);
	      }
	      fprintf (dumpfile, "\n\t.align 32\n");
          }
        fprintf (dumpfile, "\t.word\t0\n");
        fprintf (dumpfile, "\t.word\t0\n");
    }

    fclose(dumpfile);

    if ((dumpfile = fopen ("dump.s", "w+")) == NULL)
      {
	  printf ("Failed to open temporary file\n");
	  exit (1);
      }
    /*if (leon)*/
      {
          fprintf (dumpfile, "\n\t.text\n");
	  fprintf (dumpfile,
		   "\n\t.global _memcfg1, _memcfg2, _memcfg3, _sdmemcfg1,  _memcaddr, _uart, _scaler,  _uaddr, _gptaddr, _irqmpaddr, _iserc32, _agga4, _doedac, _doft, _clean_ram0, _clean_ram0_size, _clean_ram1, _clean_ram1_size, _ddrspa_cfg1, _ddr2spa_cfg1, _ddr2spa_cfg3, _ddr2spa_cfg4, _dsustart, _dsutrace, _nopnp, _isddr, _pnp, _mp, _sdctrl_sdcfg, _spimcfg, _dsuctrl \n");
	  fprintf (dumpfile,"\n\t.global _uartnr, _sparcleon0, _mpstart, freqkhz\n");
	  fprintf (dumpfile,"\n\t.global _mpirqsel0, _mpirqsel1, ftsdctrl64_pwr, ftsdctrl64_cfg, ftsdctrl64_edac, ftahbram_cfg\n");
      }
    fprintf (dumpfile, "\n\t.global ramsize, _stack, _entry\n");
    fprintf (dumpfile, "\t.global freq, configmsg, bmsg, noinit\n");
    fprintf (dumpfile, "freq:\n");
    fprintf (dumpfile, "\t.word\t%d\n", (int) (freq / 1000000));
    fprintf (dumpfile, "freqkhz:\n");
    fprintf (dumpfile, "\t.word\t%d\n", (int) (freq / 1000));
    fprintf (dumpfile, "bmsg:\n");
    fprintf (dumpfile, "\t.word\t%d\n", bmsg);
    fprintf (dumpfile, "_iserc32:\n");
    fprintf (dumpfile, "\t.word\t%d\n", erc32);
    fprintf (dumpfile, "_agga4:\n");
    fprintf (dumpfile, "\t.word\t%d\n", agga4);
    fprintf (dumpfile, "_doedac:\n");
    fprintf (dumpfile, "\t.word\t%d\n", edac);
    fprintf (dumpfile, "_doft:\n");
    fprintf (dumpfile, "\t.word\t%d\n", doft);
    fprintf (dumpfile, "_sparcleon0:\n");
    fprintf (dumpfile, "\t.word\t%d\n", sparcleon0);
    fprintf (dumpfile, "_mpstart:\n");
    fprintf (dumpfile, "\t.word\t%d\n", mpstart);

    for (i = 0; (unsigned) i < mpirqselcnt; i++) {
        int cpu = mpirqsel[i].cpu;
        int sel = mpirqsel[i].sel;
        if (cpu < 8) {
            mpirqsel0 |= (sel << (cpu * 4));
        } else {
            mpirqsel1 |= (sel << ((cpu-8) * 4));
        }
    }
    
    fprintf (dumpfile, "_mpirqsel0:\n");
    fprintf (dumpfile, "\t.word\t0x%08x\n", mpirqsel0);
    fprintf (dumpfile, "_mpirqsel1:\n");
    fprintf (dumpfile, "\t.word\t0x%08x\n", mpirqsel1);
    
    fprintf (dumpfile, "_dsustart:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", dsu_start);
    fprintf (dumpfile, "_dsutrace:\n");
    fprintf (dumpfile, "\t.word\t%d\n", enable_trace);
    fprintf (dumpfile, "_nopnp:\n");
    fprintf (dumpfile, "\t.word\t%d\n", nopnp);
    fprintf (dumpfile, "_isddr:\n");
    fprintf (dumpfile, "\t.word\t%d\n", isddr);
    fprintf (dumpfile, "_pnp:\n");
    fprintf (dumpfile, "\t.word\t%d\n", pnp);
    fprintf (dumpfile, "_mp:\n");
    fprintf (dumpfile, "\t.word\t%d\n", mp);
    fprintf (dumpfile, "_dsuctrl:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", 0xcf | (dsubreak ? 0x20 : 0) );
    
    
    if (leon)
      {
	  if (dobch8 && romcs != 1) {
	    printf("Error: -bch8 needs \"-romcs 1\"\n");
	    exit(1);
	  }
	  
	  switch (iowidth)
	    {
	    case 8: iowidth = 0; break;
	    case 16: iowidth = 1; break;
	    case 32: iowidth = 2;
	    }
	  switch (romwidth)
	    {
	    case 8: romwidth = 0; break;
	    case 16: romwidth = 1; break;
	    case 32: romwidth = 2; break;
	    case 39: romwidth = 3; break;
	    }
	  tmp = romsize;
	  tmp >>= 14;
	  i = 0;
	  while (tmp)
	    {
		i++;
		tmp >>= 1;
	    }

	  switch(romcs) {
	  case 1: tmp2 = 0; break;
	  case 2: tmp2 = 1; break;
	  case 4: tmp2 = 2; break;
	  case 8: tmp2 = 3; break;
	  default: printf("Error: expecting 1,2,4,8 as -romcs parameter\n");
	      exit(1);
	  }
	  tmp2 = (tmp2 & 0x3) << 12; /* rom edacsz field, always use all banks */
	  romedacaddr = (romsize/4)*3;
	  
	  tmp = (i << 14) | romrws | (romwws << 4) | (romwidth << 8) | (1 << 19) |
	  	(iows << 20) | (iowidth << 27) | tmp2;
	  fprintf (dumpfile, "_memcfg1:\n");
	  if (memcfg1_on)
		  tmp = memcfg1;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp);
	  tmp = ramsize / ramcs;
	  tmp >>= 14;
	  i = 0;
	  while (tmp)
	    {
		i++;
		tmp >>= 1;
	    }
	  tmp = (i << 9) | ramrws | (ramwws << 2);
	  switch (ramwidth)
	    {
	    case 8: ramwidth = 0; break;
	    case 16: ramwidth = 1; break;
	    case 39: ramwidth = 3; break;
	    default: ramwidth = 2;
	    }
	  tmp |= ramwidth << 4;
	  tmp |= rmw << 6;

	  i = 0;
	  if (sdramsz)
	    {
		tmp2 = sdramsz;
		tmp2 /= (sdrambanks * 8 * 1024 * 1024);
		while (tmp2)
		  {
		      tmp2 >>= 1;
		      i++;
		  }
		tmp |= 0x80184000;
	    }
	  tmp = (tmp & ~(3 << 21)) | (colsz << 21);
	  tmp = (tmp & ~(7 << 23)) | (i << 23);
	  tmp = (tmp & ~(1 << 26)) | (sdcas << 26);
	  if ((2.0E9 / freq) < (double) trp)
	      trp = 1;
	  else
	      trp = 0;
	  ftmp = ((double) trfc) - (3E9 / freq);
	  if (ftmp > 0)
	      trfc = 1 + (ftmp * freq) / 1E9;
	  else
	      trfc = 0;
	  if (trfc > 7)
	      trfc = 7;
	  tmp = (tmp & ~(7 << 27)) | (trfc << 27);
	  tmp = (tmp & ~(1 << 30)) | (trp << 30);
	  refr = (freq * refresh) / 1E6;
	  if (refr > 0x7fff)
	      refr = 0x7fff;

	  if (edac) {
              if (edac_clean_on) {
                  clean_ram0 = edac_clean0;
                  clean_ram0_size = edac_size0;
                  clean_ram1 = edac_clean1;
                  clean_ram1_size = edac_size1;
              } else {
	      if (erc32) {
		  clean_ram0 = 0x2000000;
		  clean_ram0_size = ramsize;
	      } else {
		  if (nosram) {
		      clean_ram0 = 0x40000000;
		      clean_ram0_size = sdramsz;
		  } else {
		      clean_ram0 = 0x40000000;
		      /* if ftmctrl.edac and ramwidth 8 then use upper 1/4 as bch */
		      clean_ram0_size = (edac && oramwidth == 8) ? ((((unsigned int)ramsize)/4)*3) : ramsize;
		      clean_ram1 = 0x60000000;
		      clean_ram1_size = sdramsz;
		  }
	      }
              }
	  }
	  
	  if (nosram)
	    {
		ramsize = sdramsz;
		tmp |= 1 << 13;
	    }
	  fprintf (dumpfile, "_memcfg2:\n");
	  if (memcfg2_on)
		  tmp = memcfg2;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp);
          fprintf (dumpfile, "_sdmemcfg1:\n\t.word\t0x%x\n", sdmemcfg1_on ? sdmemcfg1 : tmp);

	  fprintf (dumpfile, "ftsdctrl64_cfg:\n");
	  if (ftsdctrl64_cfg_on)
		  tmp_ftsdctrl64_cfg = ftsdctrl64_cfg;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp_ftsdctrl64_cfg);
	  fprintf (dumpfile, "ftsdctrl64_pwr:\n");
	  if (ftsdctrl64_pwr_on)
		  tmp_ftsdctrl64_pwr = ftsdctrl64_pwr;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp_ftsdctrl64_pwr);
	  fprintf (dumpfile, "ftsdctrl64_edac:\n");
	  if (ftsdctrl64_edac_on)
		  tmp_ftsdctrl64_edac = ftsdctrl64_edac;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp_ftsdctrl64_edac);

/* ################# FTAHBRAM CFG ####################### */
	  fprintf (dumpfile, "ftahbram_cfg:\n\t.word\t0x%x\n", ftahbram_edac_on << 7);



/* ################# DDR2 CFG ####################### */
	  {
	      unsigned int ddr2spa_cfg1 = 0, ddr2spa_cfg3 = 0, ddr2spa_cfg4 = 0;
	      unsigned int ddr2_ref, ddr2_OCD, ddr2_EMR, ddr2_bsize, ddr2_cmd;
	      unsigned int ddr2_CE, ddr2_IN, ddr2_PR, ddr2_ref_val;
	      int ddr2_RD, ddr2_tWR, ddr2_tCD, ddr2_tRP, ddr2_tRFC, ddr2_colsize;
	      
/*       $ddr2_ref=1; */
	      ddr2_ref = 1;	      
/*       $ddr2_OCD=0; */
	      ddr2_OCD = 0;
/*       $ddr2_EMR=1; */
	      ddr2_EMR = 1;
	      
/*       $ddr2_bsize=$i-1; */
	      ddr2_bsize = 0;
	      if (ddrramsz) {
		  unsigned int tmp2 = ddrramsz;
		  unsigned int tmp3 = 8;
		  while (tmp3 != tmp2) {
		      tmp3 <<=1; ddr2_bsize++;
		  }
	      }
		  
		  
/*       $ddr2_colsize=$cfg_colsz-1; */
	      ddr2_colsize = ddr_colsize;
	      
/*       $ddr2_cmd=0; */
	      ddr2_cmd = 0;

		  
/*       $ddr2_CE=1; */
	      ddr2_CE = 1;
		  
/*       $ddr2_IN=0; */
	      ddr2_IN = 0;
		  
/*       $ddr2_PR=0; */
	      ddr2_PR = 0;

		  
/*       $ddr2_ref_val= int(($refresh*$cfg_ddr_freq)-0.5)-1; */
/*       $ddr2_ref_val = $ddr2_ref_val & 0x7fff; */
	      ddr2_ref_val = ((ddr_refresh *  ddr_freq) - 0.5) - 1;
	      ddr2_ref_val = ddr2_ref_val & 0x7fff;
		  
/*       $ddr2_RD=1; */
	      ddr2_RD = 1;

/*       $ddr2_tWR= 4 + ($cfg_ddr_freq / 100); */
/*       if ($ddr2_tWR < 0){ */
/*         $ddr2_tWR = 0; */
/*       } */
/*       if ($ddr2_tWR > 31){ */
/*         $ddr2_tWR = 31; */
/*       } */
	      ddr2_tWR= 4 + (ddr_freq / 100);
	      if (ddr2_tWR < 0){
		  ddr2_tWR = 0;
	      }
	      if (ddr2_tWR > 31){
		  ddr2_tWR = 31;
	      }
		  
		  
/*       if ( $cfg_ddr_freq > 130 ) { */
/*         $ddr2_tCD=1; */
/*         $ddr2_tRP=1; */
/*       }else{ */
/*         $ddr2_tCD=0; */
/*         $ddr2_tRP=0;       */
/*       } */
	      if (ddr_freq > 100) {
		  ddr2_tCD=1;
		  ddr2_tRP=1;
	      }else{
		  ddr2_tCD=0;
		  ddr2_tRP=0;
	      }

		  
/*       $ddr2_tRFC=1+((7*$cfg_ddr_freq)/100); */
/*       $ddr2_tRFC=$ddr2_tRFC - 2; */
/*       if ($ddr2_tRFC < 0){ */
/*         $ddr2_tRFC = 0; */
/*       } */
/*       if ($ddr2_tRFC > 31){ */
/*         $ddr2_tRFC = 31; */
/*       } */
	      ddr2_tRFC=1+((13*ddr_freq)/100);
	      ddr2_tRFC=ddr2_tRFC - 2;
	      if (ddr2_tRFC < 0){
		  ddr2_tRFC = 0;
	      } else if (ddr2_tRFC > 31){
		  ddr2_tRFC = 31;
	      }
	      
		  
/*       $ddr2spa_cfg1= ($ddr2_ref<<31) | ($ddr2_OCD<<30) | ($ddr2_EMR<<28) | */
/*                      (0<<27) | ($ddr2_tCD<<26) | ($ddr2_bsize<<23) | ($ddr2_colsize<<21) | */
/*                      ($ddr2_cmd<<18) | ($ddr2_PR<<17) | ($ddr2_IN<<16) | ($ddr2_CE<<15) | */
/*                      ($ddr2_ref_val<<0); */
      
/*       $ddr2spa_cfg3= ($ddr2_tRP<<28) | ($ddr2_tWR<<23) | ($ddr2_tRFC<<18) | ($ddr2_RD<<16); */
/*       printf ("ddrfreq :%dMHz\n", $cfg_ddr_freq); */
	      ddr2spa_cfg1= (ddr2_ref<<31) | (ddr2_OCD<<30) | (ddr2_EMR<<28) |
		  (0<<27) | (ddr2_tCD<<26) | (ddr2_bsize<<23) | (ddr2_colsize<<21) |
		  (ddr2_cmd<<18) | (ddr2_PR<<17) | (ddr2_IN<<16) | (ddr2_CE<<15) |
		  (ddr2_ref_val<<0);
	      
	      ddr2spa_cfg3= (ddr2_tRP<<28) | (ddr2_tWR<<23) | (ddr2_tRFC<<18) | (ddr2_RD<<16);

	      if (ddr2spa_cfg1_cmd) {
		      ddr2spa_cfg1 = _ddr2spa_cfg1;
	      }
	      if (ddr2spa_cfg3_cmd) {
		      ddr2spa_cfg3 = _ddr2spa_cfg3;
	      }
	      if (ddr2spa_cfg4_cmd) {
		      ddr2spa_cfg4 = _ddr2spa_cfg4;
	      }	      
	      
	      fprintf (dumpfile, "_ddr2spa_cfg1:\n");
	      fprintf (dumpfile, "\t.word\t0x%08x\n", ddr2spa_cfg1);
	      fprintf (dumpfile, "_ddr2spa_cfg3:\n");
	      fprintf (dumpfile, "\t.word\t0x%08x\n", ddr2spa_cfg3);
	      fprintf (dumpfile, "_ddr2spa_cfg4:\n");
	      fprintf (dumpfile, "\t.word\t0x%08x\n", ddr2spa_cfg4);
	  }

	  
/* 	  ################# DDR CFG ####################### */
	  {
/* 	  $ddr_ref=1; */
	      unsigned int ddr_ref = 1;
	      unsigned int ddr_cmd = 0,ddr_CE = 1, ddr_IN = 0, ddr_PR = 0;
	      int ddr_tCD, ddr_tRP, ddr_tRFC, ddrspa_cfg1;
	      int ddr_ref_val,ddr_bsize; unsigned long ddr_msize = 0;
	      
/*       $ddr_bsize=$i-1; */

	      ddr_bsize = 0;
	      if (ddrramsz) {
		  unsigned int tmp2 = ddrramsz;
		  unsigned int tmp3 = 8;
		  while (tmp3 != tmp2) {
		      tmp3 <<=1; ddr_bsize++;
		  }
		  ddr_msize = ddrbanks * ddrramsz * 1024 * 1024;
		  if (ddrramsz_on)
			  ramsize = ddr_msize;
	      }
	      
/*       $ddr_colsize=$cfg_colsz-1; */
	      
/*       $ddr_cmd=0; */
/*       $ddr_CE=1; */
/*       $ddr_IN=0; */
/*       $ddr_PR=0; */
	      ddr_cmd = 0;
	      ddr_CE = 1;
	      ddr_IN = 0;
	      ddr_PR = 0;
	      
/*       $ddr_ref_val= int(($refresh*$cfg_ddr_freq)-0.5)-1; */
	      ddr_ref_val = ((ddr_refresh *  ddr_freq) - 0.5) - 1;
	      
/*       $ddr_ref_val = $ddr_ref_val & 0x7fff; */
	      ddr_ref_val = ddr_ref_val & 0x7fff;
	      
/*       if ( $cfg_ddr_freq > 100 ) { */
/*         $ddr_tCD=1; */
/*         $ddr_tRP=1; */
/*       }else{ */
/*         $ddr_tCD=0; */
/*         $ddr_tRP=0; */
/*       } */
	      if (ddr_freq > 100) {
		  ddr_tCD=1;
		  ddr_tRP=1;
	      }else{
		  ddr_tCD=0;
		  ddr_tRP=0;
	      }
	      
/*       $ddr_tRFC=1+((7*$cfg_ddr_freq)/100); */
/*       $ddr_tRFC=$ddr_tRFC - 3; */
/*       if ($ddr_tRFC < 0){ */
/*         $ddr_tRFC = 0; */
/*       }elsif ($ddr_tRFC > 7){ */
/*         $ddr_tRFC = 7; */
/*       } */

	      ddr_tRFC=1+((7*ddr_freq)/100);
	      ddr_tRFC=ddr_tRFC - 3;
	      if (ddr_tRFC < 0){
		  ddr_tRFC = 0;
	      } else if (ddr_tRFC > 7){
		  ddr_tRFC = 7;
	      }
	      
/*       $ddrspa_cfg1 = ($ddr_ref<<31) | ($ddr_tRP<<30)   | ($ddr_tRFC<<27)    | */
/*                      ($ddr_tCD<<26) | ($ddr_bsize<<23) | ($ddr_colsize<<21) | */
/*                      ($ddr_cmd<<18) | ($ddr_PR<<17)    | ($ddr_IN<<16)      |  */
/* 					 ($ddr_CE<<15)  | ($ddr_ref_val<<0); */
      
	      ddrspa_cfg1 = (ddr_ref<<31) | (ddr_tRP<<30)   | (ddr_tRFC<<27)    |
		  (ddr_tCD<<26) | (ddr_bsize<<23) | (ddr_colsize<<21) |
		  (ddr_cmd<<18) | (ddr_PR<<17)    | (ddr_IN<<16)      |
		  (ddr_CE<<15)  | (ddr_ref_val<<0);

	      if (ddrspa_cfg1_cmd) {
		      ddrspa_cfg1 = _ddrspa_cfg1;
	      }
	      
	      fprintf (dumpfile, "_ddrspa_cfg1:\n");
	      fprintf (dumpfile, "\t.word\t0x%08x\n", ddrspa_cfg1);

	      
	  }

/* 	  ################# SDCTRL ####################### */
	  
	  {

		  unsigned int _sdctrl_sdcfg = 0;
		  
		  fprintf (dumpfile, "_sdctrl_sdcfg:\n");
		  fprintf (dumpfile, "\t.word\t0x%08x\n", _sdctrl_sdcfg);
	      
	  }

/* 	  ################# SPIMCTRL ####################### */

	  fprintf (dumpfile, "_spimcfg:\n");
	  fprintf (dumpfile, "\t.word\t0x%08x\n", spimeas << 2);

/* 	  ################# UART ####################### */
	  
	  tmp = (((10 * (long) freq) / (8 * baud)) - 5) / 10;
	  baud = freq / (8 * (tmp + 1));
	  fprintf (dumpfile, "_uart:\n");
	  fprintf (dumpfile, "\t.word\t0x%08x\n", tmp);
	  fprintf (dumpfile, "_uaddr:\n");
	  if (mp) 
	  {  
	    for (i = 0; i < uartnr; i++)
	      fprintf (dumpfile, "\t.word\t0x%08x\n", uaddr[i]);
	  }
	  else
	    fprintf (dumpfile, "\t.word\t0x%08x\n", uaddr[0]);
	  fprintf (dumpfile, "_uartnr:\n");
	  fprintf (dumpfile, "\t.word\t %d\n", uartnr);
	  tmp = 0;

	  /* if ftmctrl.edac and ramwidth 8 then use upper 1/4 as bch */
    if (!stack[0]) {
      unsigned long rambase;
      unsigned long sz;

      if (sparcleon0) {
        rambase = 0x00000000;
      } else if (erc32) {
        rambase = 0x02000000;
      } else {
        rambase = 0x40000000;
      }

      if (edac && oramwidth == 8) {
        /* Some address space is allocated to EDAC data when in 8-bit mode. */
        sz = (((unsigned long) ramsize) / 4) * 3;
      } else {
        sz = ramsize;
      }
      stack[0] = rambase + sz - 32;
    }

	  tmp = 0;
	  if (sdramsz)
	      tmp = (refr << 12);
	  fprintf (dumpfile, "_memcfg3:\n");
	  if (edac) tmp |= 0x200;  /* enable RAM EDAC */
	  if (memcfg3_on)
		  tmp = memcfg3;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp);
      } else {
	    
	  dobch8q = dobch8 = 0;
	    
	  tmp = romsize;
	  tmp >>= 17;
	  i = 0;
	  while (tmp)
	    {
		i++;
		tmp >>= 1;
	    }
	  tmp = ((i & 0x7) << 18);

	  
	  
	  tmp2 = ramsize / ramcs;
	  tmp2 >>= 18;
	  i = 0;
	  while (tmp2)
	    {
		i++;
		tmp2 >>= 1;
	    }

	  switch(ramcs) {
	  case 1: tmp2 = 0; break;
	  case 2: tmp2 = 1; break;
	  case 4: tmp2 = 2; break;
	  case 8: tmp2 = 3; break;
	  default: printf("expecting 1,2,4,8 as -rambanks  parameter for erc32 ");
	      exit(1);
	  }
	  
	  tmp |= ((i & 0x7) << 10) | (tmp2 & 0x3);

	  /* printf("Decoded memsz : 0x%x\n", (256 * 1024) << ((tmp >> 10) & 7)); */
	  
	  fprintf (dumpfile, "_memcfg1:\n");
	  if (memcfg1_on)
		  tmp = memcfg1;

	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp);
	  
	  tmp = (((10 * (long) freq) / (32 * baud)) - 5) / 10;
	  baud = freq / (32 * (tmp + 1));
	  
	  fprintf (dumpfile, "_uart:\n");
	  fprintf (dumpfile, "\t.word\t0x%08x\n", ((tmp & 0xff)<<24) | (1 << 19)); /* no prescalar */
	  fprintf (dumpfile, "_uaddr:\n");
	  if (mp) 
	  {  
	    for (i = 0; i < uartnr; i++)
	      fprintf (dumpfile, "\t.word\t0x%08x\n", uaddr[i]);
	  }
	  else
	    fprintf (dumpfile, "\t.word\t0x%08x\n", uaddr[0]);
	  fprintf (dumpfile, "_uartnr:\n");
	  fprintf (dumpfile, "\t.word\t %d\n", uartnr);

	  tmp = 0;
	  fprintf (dumpfile, "_memcfg3:\n");
	  if (memcfg3_on)
		  tmp = memcfg3;
	  fprintf (dumpfile, "\t.word\t0x%x\n", tmp);

	  /* if ftmctrl.edac and ramwidth 8 then use upper 1/4 as bch */
	    if (!stack[0])
	      stack[0] = (0x2000000) + ( (edac && oramwidth == 8) ? ((((unsigned int)ramsize)/4)*3) : ramsize) - 32;
      }
    
    fprintf (dumpfile, "noinit:\n");
    fprintf (dumpfile, "\t.word\t%d\n", noinit);
    
    fprintf (dumpfile, "_clean_ram0:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", clean_ram0);
    fprintf (dumpfile, "_clean_ram0_size:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", clean_ram0_size);
    fprintf (dumpfile, "_clean_ram1:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", clean_ram1);
    fprintf (dumpfile, "_clean_ram1_size:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", clean_ram1_size);
    

    /*if (starta)
    {
      entry[0] = starta;
      }*/
    fprintf (dumpfile, "_entry:\n");
    if (mp) 
    {  
      for (i = 0; i < ncpu; i++)
	fprintf (dumpfile, "\t.word\t0x%x\n", entry[i]);    
    }
    else
      fprintf (dumpfile, "\t.word\t0x%x\n", entry[0]);    
    fprintf (dumpfile, "ramsize:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", ramsize);
    fprintf (dumpfile, "_stack:\n");
    if (mp) 
    {  
      for (i = 0; i < ncpu; i++)    
	fprintf (dumpfile, "\t.word\t0x%x\n", stack[i]);
    }
    else
      fprintf (dumpfile, "\t.word\t0x%x\n", stack[0]);      
    fprintf (dumpfile, "_memcaddr:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", memcaddr);
    fprintf (dumpfile, "_gptaddr:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", gptaddr);
    fprintf (dumpfile, "_irqmpaddr:\n");
    fprintf (dumpfile, "\t.word\t0x%x\n", irqmpaddr);

    sprintf (cmd, "  system clock   : %3.1f MHz\\n\\r", freq / 1E6);
    sprintf (msg, "  baud rate      : %d baud\\n\\r", baud);
    strcat (cmd, msg);
    sprintf (msg, "  prom           : %d K, (%d/%d) ws (r/w)\\n\\r",
	     romsize >> 10, romrws, romwws);
    strcat (cmd, msg);
    if (!nosram)
      {
	  sprintf (msg, "  sram           : %d K, %d bank(s),",
		   ramsize >> 10, rambanks);
	  strcat (cmd, msg);
	  sprintf (msg, " %d/", ramrws);
	  strcat (cmd, msg);
	  sprintf (msg, "%d ws (r/w)\\n\\r", ramwws);
	  strcat (cmd, msg);
      }
    else
      {
	  sprintf (msg,
		   "  sdram          : %d M, %d bank(s), %d-bit column\\n\\r",
		   sdramsz >> 10, sdrambanks, colsz + 8);
	  strcat (cmd, msg);
	  sprintf (msg, "  sdram          : ");
	  strcat (cmd, msg);
	  sprintf (msg,
		   "cas: %d, trp: %2.0f ns, trfc: %2.0f ns, refresh %3.1f us\\n\\r",
		   sdcas + 2, (double) (trp + 2) * 1E9 / freq,
		   (double) (trfc + 3) * 1E9 / freq,
		   (double) (refr + 1) * 1E6 / freq);
	  strcat (cmd, msg);
      }

    if (!flash)
      {
	  fprintf (dumpfile, "configmsg:\n");
	  fprintf (dumpfile, "\t.string\t\"%s\"\n\n\t.align 32\n", cmd);
          xfile = fopen ("xdump.s", "rb");
	  if (xfile) {
		fprintf(xfile, "\n\n");
		while (!feof(xfile)) {
			n = fread(buf, 1, 1024, xfile);
			if (n>0) fwrite(buf, n, 1, dumpfile);
		}
    		fclose (xfile);
	  }
      }
    fclose (dumpfile);

    if (!flash) {
	if (!comp) {
	    promload = "promload_copyonly.o";
	} else {
	    promload = "promload.o";
	    promload_decomp = "promdecomp.o";
	}
    }

    prefix = strlen(prefix) ? prefix : "." ;
    
    if(!ccprefixdo) {
        static char ccprefixes[5][20] = {"sparc-elf", "sparc-gaisler-elf",
                                         "sparc-rtems", "sparc-rcc-rtems4.12",
                                         "sparc-linux"};
        int prefix_count = NELEM(ccprefixes);
        int i;

        for (i = 0; i < prefix_count; i++) {
            if (searchforcc(ccprefixes[i])) {
            ccprefix = ccprefixes[i];
            break;
            }
        }

        if ( i == prefix_count ) {
            printf("No suitable compiler found!\n");
            printf("Looked for the following compilers: \n");
            for (i = 0; i < prefix_count; i++)
                printf("\t%s-gcc\n", ccprefixes[i]);
            printf("\n");
            exit(1);
        }
    }

    /* for sparcleon0 and execute-in-rom  modify the rom and ram fields of the linkerscript */
    sprintf(lscriptpath, "%s/%s%s", 
            prefix, ecos ? "linkpromecos" : (erc32 ? "linkpromerc32" : "linkprom") , flash ? "flash" : "");
    lscriptpathdel[0] = 0;
    if (flash && sparcleon0) {
        FILE *file = 0, *file2 = 0;
        printf("Rewrite %s\n",lscriptpath);
	if ((file = fopen (lscriptpath, "rb"))) {
            char l[512], lscriptpath2[512];
            lscriptpath2[0] = 0;
            strcat(lscriptpath2,"sparcleon0.in.prom");
            if ((file2 = fopen (lscriptpath2, "w"))) {
                while(fgets(l, sizeof(l), file)) {
                    if (strstr(l,"rom") && strstr(l,"0x00000000") && strstr(l,"ORIGIN") && strstr(l,"LENGTH")) {
                        fprintf(file2, "  rom     : ORIGIN = 0x%08x, LENGTH = 1024M\n", startaddr);
                    } else if (strstr(l,"ram") && strstr(l,"0x40000000") && strstr(l,"ORIGIN") && strstr(l,"LENGTH")) {
                        fprintf(file2, "  ram     : ORIGIN = 0x00000000, LENGTH = 1024M\n");
                    } else {
                        fputs(l, file2);
                    }
                }
                lscriptpath[0] = 0;
                lscriptpathdel[0] = 0;
                strcat(lscriptpath, lscriptpath2);
                strcat(lscriptpathdel, lscriptpath2);
            }
        }
        if (file) fclose(file);
        if (file2) fclose(file2);
    }
    
    sprintf (cmd,
	     "%s-gcc%s -O2 -g -N -T%s -Ttext=0x%x  "
	     
	     ,
	     ccprefix,
	     postfix,
	     lscriptpath, startaddr
	     
	     );

    if (!flash) {
	if (strlen(promcore)) {
	    strcat (cmd, strlen(prefix) ? prefix : ".");
	    strcat (cmd, multidir);
	    strcat (cmd,"/");
	    strcat (cmd,promcore);
	    strcat (cmd," ");
	}

        /* prominit */
        strcat (cmd, strlen(prefix) ? prefix : ".");
        strcat (cmd, multidir);
        strcat (cmd,"/prominit.o ");
    
        if (leon3) {
            prominit = "/prominit_leon3.o ";
        } else if (leon2) {
            prominit = "/prominit_leon2.o ";
        } else if (erc32) {
            prominit = "/prominit_erc32.o ";
        } else if (agga4) {
            prominit = "/prominit_agga4.o ";
        }
    
    
        strcat (cmd, strlen(prefix) ? prefix : ".");
        strcat (cmd, multidir);
        strcat (cmd,prominit);
        prominit_done = 1;
        /* \prominit */

	if (strlen(promcrt0)) {
	    strcat (cmd, strlen(prefix) ? prefix : ".");
	    strcat (cmd, multidir);
	    strcat (cmd,"/");
	    strcat (cmd,promcrt0);
	    strcat (cmd," ");
	}
    
	if (strlen(promload)) {
	    strcat (cmd, strlen(prefix) ? prefix : ".");
	    strcat (cmd, multidir);
	    strcat (cmd,"/");
	    strcat (cmd,promload);
	    strcat (cmd," ");
	    
	}
	
	if (strlen(promload_decomp)) {
	    strcat (cmd, strlen(prefix) ? prefix : ".");
	    strcat (cmd, multidir);
	    strcat (cmd,"/");
	    strcat (cmd,promload_decomp);
	    strcat (cmd," ");
	    
	}	
	strcat (cmd, " -nostdlib ");
    } else {
	strcat (cmd, strlen(prefix) ? prefix : ".");
	strcat (cmd, multidir);
	if (qsvt) {
	    strcat (cmd,"/prominit_resident_svt.o");
	} else {
	    strcat (cmd,"/prominit_resident_mvt.o");
	}
	strcat (cmd," ");
    }

    if (edac ) {
	strcat (cmd, strlen(prefix) ? prefix : ".");
	strcat (cmd, multidir);
	if (leon3) {
	    strcat (cmd,"/promft_leon3.o ");
	} else if (leon2 || agga4) {
	    strcat (cmd,"/promft_leon2.o ");
	} else if (erc32) {
	    strcat (cmd,"/promft_erc32.o ");
	}
    }

    if (mp) {
	strcat (cmd, strlen(prefix) ? prefix : ".");
	strcat (cmd, multidir);
        strcat (cmd,"/mp.o ");
    }

    if (!(prominit_done)) {
        strcat (cmd, strlen(prefix) ? prefix : ".");
        strcat (cmd, multidir);
        strcat (cmd,"/prominit.o ");
    
        if (leon3) {
            prominit = "/prominit_leon3.o ";
        } else if (leon2) {
            prominit = "/prominit_leon2.o ";
        } else if (erc32) {
            prominit = "/prominit_erc32.o ";
        } else if (agga4) {
            prominit = "/prominit_agga4.o ";
        }
    
    
        strcat (cmd, strlen(prefix) ? prefix : ".");
        strcat (cmd, multidir);
        strcat (cmd,prominit);
    }
    
    
    strcat (cmd, strlen(prefix) ? prefix : ".");
    strcat (cmd, multidir);
    strcat (cmd,"/prombdinit.o ");
    
    if (vverbose)
      strcat (cmd, " -v -Wl,-verbose -Wl,-M ");
    if (flash) {
	/* if (ecos) { */
/* 	    strcat (cmd, " -lmkprom2ecos "); */
/* 	} else { */
/* 	    strcat (cmd, " -lmkprom2 "); */
/* 	} */
/*       strcat (cmd, " -lleonbare -qprom2 dump.s "); */
      strcat (cmd, " dump.s ");
      strcat (cmd, flist);
      strcat (cmd, " -e start ");
    }
    else if (mp)
/*       strcat (cmd, " -lmkprom3mp -lleonbare dump.s "); */
      strcat (cmd, " dump.s ");
    else
/*       strcat (cmd, " -lmkprom3 -lleonbare dump.s "); */
      strcat (cmd, " dump.s ");
    if (bdinit)
	strcat (cmd, "bdinit.o ");
    if (flash) {
/*       if (ecos) { */
/* 	strcat (cmd, " -qprom2ecos -qnocrtbegin -qnocrtn -lm -o "); */
/*       } else { */
	strcat (cmd, " -lm -o ");
/*       } */
    }
    else if (mp)
/*       strcat (cmd, " -lmkprom3mp -o "); */
      strcat (cmd, " -o ");
    else
/*       strcat (cmd, " -lmkprom3 -o "); */
      strcat (cmd, " -o ");
    strcat (cmd, ofile);
    strcat (cmd, xlist);
    if (verbose)
	printf ("\n%s \nmultidir:%s\n", cmd, multidir);
    fflush(stdout);
    trysystem (cmd);
    if (!dump)
    {
      fflush(stdout);
#ifdef __MINGW32__
      system("del dump.s");
#else
      system ("rm -f dump.s");
#endif
      if (strlen(lscriptpathdel)) {
          char c[512];
#ifdef __MINGW32__
          sprintf(c, "del %s", lscriptpathdel);
#else
          sprintf(c, "rm -f %s", lscriptpathdel);
#endif
          system(c);
      }
    }
    if (flash) {
        /* change rom load addresses of <ofile> */
        flash = 2;
        {
            /* implementaion using binary extraction */
            char *b;
#ifdef WIN32
            flashld = fopen (flashldn, "wb");
#else
            flashld = fopen (flashldn, "w");
#endif
            if (flashld) {
                fprintf(flashld,"OUTPUT_FORMAT(\"elf32-sparc\", \"elf32-sparc\", \"elf32-sparc\")\n");
                fprintf(flashld,"OUTPUT_ARCH(sparc)\n");
                
            }

            /* create a copy that holds the symbols */
#ifdef __MINGW32__
            sprintf(cmd, "copy %s %s.sym", ofile, ofile);
#else
            sprintf(cmd, "cp %s %s.sym", ofile, ofile);
#endif
            if (verbose)
              printf("%s\n", cmd);
            fflush(stdout);
            system (cmd);

            /* traverse into the image, extract all sections and append linkerscript line so <flashldn> */
            entry[0] = elf_load (ofile);

            /* close linkerscript */
            fprintf(flashld,"\n}\n");
            fclose(flashld);
            flashld = 0;
            if ((b = malloc(512*(flashsectionspos+1)))) {
                /* link everything together */
                sprintf(b,"%s-ld%s -o %s -T%s ",ccprefix,postfix,ofile,flashldn);
                for (i = 0; i < flashsectionspos; i++) {
                    strcat(b," ");
                    strcat(b,(const char *)flashsections[i]);
                }
                if (verbose) {
                  printf("%s\n", b);
                }
                fflush(stdout);
                trysystem (b);
                free(b);
                /* clear temporary files */
                if (!dump) {
                    for (i = 0; i < flashsectionspos; i++) {
                        
#ifdef __MINGW32__
                        sprintf(cmd,"del %s\n",flashsections[i]);
#else
                        sprintf(cmd,"rm -f %s\n",flashsections[i]);
#endif
                        if (verbose)
                          printf("%s\n", cmd);
                        fflush(stdout);
                        system (cmd);
                    }
                }
            }
        }
    }
    if (dobch8) {
	    appendbch8(".bch8",1, SEEK_END, startaddr + romsize);
    } else if (dobch8q) {

	    /* if user gives a explicit -memcfg1 value print warning if addr mismatch */
	    if (memcfg1_on) {
		    int rombsz =  ((memcfg1 >> 17) & 0xf);
		    int ebsz =  ((memcfg1 >> 12) & 0x3);
		    unsigned int size = 8*1024 * (1 << (rombsz + ebsz));
		    unsigned int edacarea = (size/4)*3;
		    printf("memcfg1: 0x%08x => edacromsize = 8k*2^(ROMBSZ)%d*2^(EBSZ)%d = 0x%08x\n", memcfg1, rombsz, ebsz, size);
		    printf("romcs  : %d, memcfg1.ebsz: %d\n",romcs,ebsz);
		    printf("bch8 start according to memcfg1 (3/4 edacromsize) : 0x%08x\n", edacarea);
		    printf("bch8 start according to -romsize (3/4 -romsize)   : 0x%08x\n", romedacaddr);
		    if (edacarea != romedacaddr) {
			    printf("### Warning: check your -memcfg1 and -romsize option. ###\n");
		    }
	    }

	    appendbch8(".bch8q", 0, SEEK_SET, romedacaddr);
    }
    
    printf("Success!\n");
    exit (0);
}

void usage (char *argv0)
{
	 printf("Usage: %s -freq <mhz> [options] input_files\n\n", argv0);

	 puts("Mkprom General Options");
	 puts("  -baud <baudrate>\tSet rate of UART A to baudrate. Default value is 19200.");
	 puts("  -bdinit\t\tCall the functions bdinit1() and bdinit2() in file\n\t\t\tbdinit.o during startup. See manual.");
/*	 puts("\tThe user can optionally call two user-defined routines, bdinit1() and bdinit2(), during  the boot process. bdinit1() is called after the LEON registers have been initialized but before the memory has been cleared. bdinit2() is called after the memory has been initialized but before the application is loaded. Note that when bdinit1() is called, the stack has not been setup meaning that bdinit1() must be a leaf routine and not allocate any stack space (no local variables). When -bdinit is used, a file called bdinit.o must exist in the current directory, containing the two routines.");
 */
	 puts("  -dump\t\t\tThe intermediate assembly code with the compressed\n\t\t\tapplication and the LEON register values is put in dump.s\n\t\t\t(only for debugging of mkprom).");
	 puts("  -freq <mhz>\t\tDefines the system clock in MHz. This value is used to\n\t\t\tcalculate the divider value for the baud rate generator\n\t\t\tand timers.");
	 puts("  -noinit\t\tSuppress all code which initializes on-chip peripherals\n\t\t\tsuch as uarts, timers and memory controllers. This option\n\t\t\trequires -bdinit to add custom initialisation code,\n\t\t\tor the boot process will fail.");
	 puts("  -nomsg\t\tSuppress the boot message.");
	 puts("  -romres\t\tCreate ROM resident image.");
	 puts("  -nocomp\t\tDon't compress application. Decreases loading time\n\t\t\ton the expense of rom size.");
	 puts("  -o <outfile>\t\tPut the resulting image in outfile,\n\t\t\trather then prom.out (default).");
	 puts("  -stack <addr>\t\tSets the initial stack pointer to addr.\n\t\t\tIf not specified, the stack starts at top-of-ram.");
	 puts("  -v\t\t\tBe verbose; reports compression statistics\n\t\t\tand compile commands");
	 puts("  -rstaddr <addr>\tSet the PROM start address. Default is 0x0.");

	 puts("  -leon3\t\tGenerate an image for LEON3/4. This is the default.");
	 puts("  -leon2\t\tGenerate an image for LEON2.");
	 puts("  -agga4\t\tGenerate an image for AGGA4.");
	 puts("  -erc32\t\tGenerate an image for ERC32.");

	 puts("\nMkprom options for the LEON2 memory controller");
	 puts("  -cas <delay>\t\tSet the SDRAM CAS delay. Allowed values are 2 and 3,\n\t\t\t2 is default.");
	 puts("  -col <bits>\t\tSet the number of SDRAM column bits.\n\t\t\tAllowed values are 8 - 11, 9 is default.");
	 puts("  -nosram\t\tDisables the static RAM and maps SDRAM at\n\t\t\taddress 0x40000000.");
	 puts("  -ramsize <size>\tDefines the total available RAM. Used to initialize\n\t\t\tmemory configuration register(s) and stack calculation.\n\t\t\tThe default value is 2048 (2 Mbyte).");
	 puts("  -ramcs <chip_selects>\tSet the number of ram banks to chip_selects.\n\t\t\tDefault is 1.");
	 puts("  -romws <ws>\t\tSet the PROM read and write wait states parameter. Default is 15.");
	 puts("  -ramws <ws>\t\tSet the SRAM read and write wait states parameter. Default is 3.");
	 puts("  -ramrws <ws>\t\tSet the SRAM  read wait states parameter. Default is 3.");
	 puts("  -ramwws <ws>\t\tSet the SRAM write wait states parameter. Default is 3.");
	 puts("  -ramwidth <width>\tSet the data bus width to 8, 16 or 32-bits, default is 32.\n\t\t\tThe prom width is set through the PIO[1:0] ports.");
	 puts("  -rmw\t\t\tPerform read-modify-write cycles during byte\n\t\t\tand halfword writes.");
	 puts("  -sdram <size>\t\tThe amount of attached SDRAM in Mbyte. 0 by default");
	 puts("  -sdrambanks <num_banks> Set the number of populated SDRAM banks.\n\t\t\tDefault is 1.");
	 puts("  -trfc <delay>\t\tSet the SDRAM tRFC parameter (in ns). Default is 66 ns.");
	 puts("  -trp <delay>\t\tSet the SDRAM tRP parameter (in ns). Default is 20 ns.");
	 puts("  -refresh <delay>\tSet the SDRAM refresh period (in us). Default is 7.8 us,\n\t\t\talthough many SDRAMS actually use 15.6 us.");
	 puts("  -mcfg1 <hex>\t\tSet memory configuration register 1. Overwrites calculated value");
	 puts("  -mcfg2 <hex>\t\tSet memory configuration register 2. Overwrites calculated value");
	 puts("  -mcfg3 <hex>\t\tSet memory configuration register 3. Overwrites calculated value");
	 
	 puts("\nMkprom options for the SPI memory controller");
	 puts("  -spimeas\t\tEnable alternate scaler for SPI clock early in the boot process.");

	 puts("\nMkprom options for LEON3");
	 puts("  -memc <addr>\tSet the address of the memory controller registers.\n\t\tDefault is 0x80000000.");
	 puts("  -gpt <addr>\tSet the address of the timer unit control registers.\n\t\tDefault is 0x80000300.");
	 puts("  -uart <addr>\tSet the address of the UART control registers.\n\t\tDefault is 0x80000100.");

	 puts("\nThe input files must be in aout or elf32 format.\nIf more than one file is specified, all files are loaded by the loader\nand control is transferred to the first segment of the first file.");
}


#define N   4096
#define F   18
#define THRESHOLD  2
#define NIL  N
#define MAGIC_NUMBER '\xaa'
#define EOP '\x55'
#ifndef SEEK_SET
#define SEEK_SET 0
#endif
#ifndef SEEK_CUR
#define SEEK_CUR 1
#endif
#ifndef SEEK_END
#define SEEK_END 2
#endif

unsigned char text_buf[N + F - 1];
int match_position, match_length, lson[N + 1], rson[N + 257], dad[N + 1];
unsigned long textsize = 0, codesize = 0, printcount = 0;
unsigned char CHECKSUM;

typedef struct
{
    char MAGIC;
    unsigned char PARAMS;
    unsigned char CHECKSUM;
    unsigned char dummy;
    unsigned char ENCODED_SIZE[4];
    unsigned char DECODED_SIZE[4];
}
packet_header;

#define PH_SIZE 12

int
PutPacketInfo (buf)
     char *buf;
{
    packet_header PH;

    PH.MAGIC = MAGIC_NUMBER;
    PH.PARAMS = (unsigned char) (((N >> 6) & 0xf0) |
				 ((((F / 18) % 3) << 2) & 0x0c) | (THRESHOLD -
								   1));
    PH.CHECKSUM = CHECKSUM;
    PH.ENCODED_SIZE[0] = (codesize >> 24);
    PH.ENCODED_SIZE[1] = (codesize >> 16);
    PH.ENCODED_SIZE[2] = (codesize >> 8);
    PH.ENCODED_SIZE[3] = codesize;
    PH.DECODED_SIZE[0] = textsize >> 24;
    PH.DECODED_SIZE[1] = textsize >> 16;
    PH.DECODED_SIZE[2] = textsize >> 8;
    PH.DECODED_SIZE[3] = textsize;
    memcpy (buf, &PH, sizeof (packet_header));
    return 0;
}

void
InitTree (void)
{
    int i;

    for (i = N + 1; i <= N + 256; i++)
	rson[i] = NIL;
    for (i = 0; i < N; i++)
	dad[i] = NIL;
}

void
InsertNode (int r)
{
    int i, p, cmp;
    unsigned char *key;

    cmp = 1;
    key = &text_buf[r];
    p = N + 1 + key[0];
    rson[r] = lson[r] = NIL;
    match_length = 0;
    for (;;)
      {
	  if (cmp >= 0)
	    {
		if (rson[p] != NIL)
		    p = rson[p];
		else
		  {
		      rson[p] = r;
		      dad[r] = p;
		      return;
		  }
	    }
	  else
	    {
		if (lson[p] != NIL)
		    p = lson[p];
		else
		  {
		      lson[p] = r;
		      dad[r] = p;
		      return;
		  }
	    }
	  for (i = 1; i < F; i++)
	      if ((cmp = key[i] - text_buf[p + i]) != 0)
		  break;
	  if (i > match_length)
	    {
		match_position = p;
		if ((match_length = i) >= F)
		    break;
	    }
      }
    dad[r] = dad[p];
    lson[r] = lson[p];
    rson[r] = rson[p];
    dad[lson[p]] = r;
    dad[rson[p]] = r;
    if (rson[dad[p]] == p)
	rson[dad[p]] = r;
    else
	lson[dad[p]] = r;
    dad[p] = NIL;
}

void
DeleteNode (int p)
{
    int q;

    if (dad[p] == NIL)
	return;
    if (rson[p] == NIL)
	q = lson[p];
    else if (lson[p] == NIL)
	q = rson[p];
    else
      {
	  q = lson[p];
	  if (rson[q] != NIL)
	    {
		do
		  {
		      q = rson[q];
		  }
		while (rson[q] != NIL);
		rson[dad[q]] = lson[q];
		dad[lson[q]] = dad[q];
		lson[q] = lson[p];
		dad[lson[p]] = q;
	    }
	  rson[q] = rson[p];
	  dad[rson[p]] = q;
      }
    dad[q] = dad[p];
    if (rson[dad[p]] == p)
	rson[dad[p]] = q;
    else
	lson[dad[p]] = q;
    dad[p] = NIL;
}

void
Encode (inbuf, outbuf, buflen, oindex)
     unsigned char *inbuf;
     unsigned char *outbuf;
     int buflen, oindex;
{
    int i, c, len, r, s, last_match_length, code_buf_ptr;
    unsigned char code_buf[17], mask;

    int lindex = 0;

    CHECKSUM = 0xff;
    InitTree ();
    code_buf[0] = 0;
    code_buf_ptr = mask = 1;
    s = 0;
    r = N - F;
    for (i = s; i < r; i++)
	text_buf[i] = ' ';
    for (len = 0; len < F && (lindex < buflen); len++)
      {
	  c = inbuf[lindex++];
	  CHECKSUM ^= c;
	  text_buf[r + len] = c;
      }
    if ((textsize = len) == 0)
	return;
    for (i = 1; i <= F; i++)
	InsertNode (r - i);
    InsertNode (r);
    do
      {
	  if (match_length > len)
	      match_length = len;
	  if (match_length <= THRESHOLD)
	    {
		match_length = 1;
		code_buf[0] |= mask;
		code_buf[code_buf_ptr++] = text_buf[r];
	    }
	  else
	    {
		code_buf[code_buf_ptr++] = (unsigned char) match_position;
		code_buf[code_buf_ptr++] = (unsigned char)
		    (((match_position >> 4) & 0xf0)
		     | (match_length - (THRESHOLD + 1)));
	    }
	  if ((mask <<= 1) == 0)
	    {
		memcpy (&outbuf[oindex], code_buf, code_buf_ptr);
		oindex += code_buf_ptr;
		codesize += code_buf_ptr;
		code_buf[0] = 0;
		code_buf_ptr = mask = 1;
	    }
	  last_match_length = match_length;
	  for (i = 0; i < last_match_length && (lindex < buflen); i++)
	    {
		c = inbuf[lindex++];
		CHECKSUM ^= c;
		DeleteNode (s);
		text_buf[s] = c;
		if (s < F - 1)
		    text_buf[s + N] = c;
		s = (s + 1) & (N - 1);
		r = (r + 1) & (N - 1);
		InsertNode (r);
	    }
	  if ((textsize += i) > printcount)
	    {
		printcount += 1024;
	    }
	  while (i++ < last_match_length)
	    {
		DeleteNode (s);
		s = (s + 1) & (N - 1);
		r = (r + 1) & (N - 1);
		if (--len)
		    InsertNode (r);
	    }
      }
    while (len > 0);
    if (code_buf_ptr > 1)
      {
	  memcpy (&outbuf[oindex], code_buf, code_buf_ptr);
	  oindex += code_buf_ptr;
	  codesize += code_buf_ptr;
      }
    outbuf[oindex++] = EOP;
    if (verbose)
      {
	  printf ("Uncoded stream length: %ld bytes\n", textsize);
	  printf ("Coded stream length: %ld bytes\n", codesize);
	  printf ("Compression Ratio: %.3f\n", (double) textsize / codesize);
      }
}

int
lzss (inbuf, outbuf, len, comp)
     char *inbuf;
     char *outbuf;
     int len;
     int comp;
{
    int index;

    textsize = 0;
    codesize = 0;
    printcount = 0;

    if (comp)
      {
	  index = sizeof (packet_header);
	  Encode (inbuf, outbuf, len, index);
	  if (PutPacketInfo (outbuf))
	    {
		printf ("Error:couldn't write packet header\n");
	    }
      }
    return (codesize);
}

#include <stdarg.h>

void
dump (buffer, count)
     unsigned char *buffer;
     int count;
{
    int i;

    for (i = 0; i < count; i += 4)
      {
	  fprintf (dumpfile, "\t.word\t0x%02x%02x%02x%02x\n",
		   buffer[i], buffer[i + 1], buffer[i + 2], buffer[i + 3]);
      }
}

int
elf_load (fname)
     char *fname;
{
    int tmp;
    FILE *xfile;
    char errmsg[256];

#ifdef WIN32
    xfile = fopen (fname, "rb");
#else
    xfile = fopen (fname, "r");
#endif

    if (xfile == NULL) {
        snprintf(errmsg, 256, "Unable to open %s", fname);
        perror(errmsg);
        exit(1);
    }

    tmp = ldelf (xfile, dumpfile);

    if (tmp == -1) {
        fprintf(stderr, "%s is a not a valid ELF file!\n", fname);
        exit(1);
    }

    if (tmp != -2)
        return tmp;

    tmp = ldaout (xfile, dumpfile);

    if (tmp == -1) {
        fprintf(stderr, "%s is a not a valid aout file!\n", fname);
        exit(1);
    }

    if (tmp == -2) {
        fprintf(stderr, "%s must be in SPARC elf32 or aout format!\n", fname);
        exit(1);
    }

    return (tmp);
}

int
dumpsec (char *buf, int section_address, int section_size,
	 char *section_name, FILE * dumpfile)
{
    char cmd[512];
    char *lzss_buf;
    char *postfix = OS_EXESUFFIX;

    if ((secnum == 0) && (section_address == 0) && !(sparcleon0 && !sparcleon0rom))
      {
        if (!romres) {
            fprintf(stderr, "WARNING: Unexpected section address 0. Use -romres to create ROM resident image.\n");
        }
	printf("Section in rom detected, switching off compression\n");
	  comp = 0;
	  flash = 1;
    } else if ((secnum == 0) && (section_address != 0)){
        if (romres) {
            fprintf(stderr, "WARNING: Option -romres expects section address 0.\n");
        }
    }
    if (flash) {
        if (flash == 2) {
                /* extract a section and convert to elf */
                /* 1: extract section to binary <f>.b */
                sprintf(cmd, "%s-objcopy%s --output-target=binary --only-section=%s %s %s%s.b",ccprefix,postfix,section_name, ofile, ofile, section_name);
                if (verbose) {
                  printf("%s\n", cmd);
                }
                fflush(stdout);
                trysystem (cmd);
                /* 2: convert binary <f>.b to elf <f>.b.elf.data with .data section */
                sprintf(cmd, "%s-ld%s -r -b binary %s%s.b -o %s%s.b.elf.data  ", ccprefix,postfix,ofile,section_name,ofile,section_name);
                if (verbose) {
                  printf("%s\n", cmd);
                }
                fflush(stdout);
                trysystem (cmd);
                /* 3: rename .data to .data.<sectioname> */
                sprintf(cmd, "%s-objcopy%s --rename-section .data=.data%s %s%s.b.elf.data %s%s.b.elf",ccprefix,postfix,section_name,ofile,section_name,ofile,section_name);
                if (verbose) {
                  printf("%s\n", cmd);
                }
                fflush(stdout);
                trysystem (cmd);
                
                if (!dodump) {
                    
#ifdef __MINGW32__
                    sprintf(cmd,"del %s%s.b\n",ofile, section_name);
#else
                    sprintf(cmd,"rm -f %s%s.b\n",ofile, section_name);
#endif
                    if (verbose)
                      printf("%s\n", cmd);
                    fflush(stdout);
                    system (cmd);
                }

                /* assume that .text always come first */
                if (strcmp(".text", section_name) == 0)
                    foffset = section_address;
                
                if (flashld) {
                    char b[512];
                    sprintf(b,"%s%s.b.elf",ofile,section_name);
                    if (strcmp(".text", section_name) == 0) {
                        fprintf(flashld,"ENTRY(start)\n");
                        fprintf(flashld,"SECTIONS \n{\n");
                        fprintf(flashld,". = 0x%x;\n",foffset);
                        fprintf(flashld,"start = .;\n");
                    } else {
                        fprintf(flashld,". = 0x%x;\n",foffset);
                    }
                    fprintf(flashld,"%s : { *(.data%s) }\n",section_name,section_name);
                    flashsections[flashsectionspos] = strdup((const char *)b);
                    flashsectionspos++;
                }
                foffset += section_size;
        }
        secnum++;
        return(0);
    } else {
        fprintf (dumpfile, "\t .text\n");
    }
    secarr[secnum].paddr = section_address;
    secarr[secnum].len = section_size;
    secarr[secnum].comp = comp;
    strncpy (secarr[secnum].name, section_name, sizeof(secarr[secnum].name)-1);
    secarr[secnum].name[sizeof(secarr[secnum].name)-1] = 0;

    fprintf (dumpfile, "\n\t.global _section%1d\n", secnum);
    fprintf (dumpfile, "_section%1d:\n", secnum);

    if (comp)
      {
	  lzss_buf = (char *) malloc (section_size + section_size / 2 + 256);
      }
    secnum++;
    if (comp)
      {
	  section_size = lzss (buf, lzss_buf, section_size, 1);
	  dump (lzss_buf, section_size + 13);
	  free (buf);
	  free (lzss_buf);
      }
    else
      {
	  dump (buf, section_size);
	  free (buf);
      }

    return (0);
}

#ifndef WIN32
#include <netinet/in.h>
#endif

#define EI_NIDENT       16

typedef unsigned int Elf32_Addr;
typedef unsigned int Elf32_Word;
typedef unsigned int Elf32_Off;
typedef unsigned short Elf32_Half;

typedef struct
{
    unsigned char e_ident[EI_NIDENT];
    Elf32_Half e_type;
    Elf32_Half e_machine;
    Elf32_Word e_version;
    Elf32_Addr e_entry;
    Elf32_Off e_phoff;
    Elf32_Off e_shoff;
    Elf32_Word e_flags;
    Elf32_Half e_ehsize;
    Elf32_Half e_phentsize;
    Elf32_Half e_phnum;
    Elf32_Half e_shentsize;
    Elf32_Half e_shnum;
    Elf32_Half e_shstrndx;
} Elf32_Ehdr;

#define EI_MAG0	0
#define EI_MAG1	1
#define EI_MAG2	2
#define EI_MAG3	3
#define EM_SPARC 2

typedef struct
{
    Elf32_Word sh_name;
    Elf32_Word sh_type;
    Elf32_Word sh_flags;
    Elf32_Addr sh_addr;
    Elf32_Off sh_offset;
    Elf32_Word sh_size;
    Elf32_Word sh_link;
    Elf32_Word sh_info;
    Elf32_Word sh_addralign;
    Elf32_Word sh_entsize;
} Elf32_Shdr;

typedef struct
{
    Elf32_Word p_type;
    Elf32_Off p_offset;
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;
    Elf32_Word p_filesz;
    Elf32_Word p_memsz;
    Elf32_Word p_flags;
    Elf32_Word p_align;
} Elf32_Phdr;

unsigned int
ldelf (FILE * fp, FILE * dumpfile)
{
    Elf32_Ehdr fh; 
    Elf32_Shdr sh, ssh;
    Elf32_Phdr *ph;
    char *strtab;
    char *mem;
    unsigned int i, k, vaddr;

    fseek (fp, 0, SEEK_SET);
    if (fread (&fh, sizeof (fh), 1, fp) != 1)
      {
	  return (-2);
      }

    if ((fh.e_ident[EI_MAG0] != 0x7f)
	|| (fh.e_ident[EI_MAG1] != 'E')
	|| (fh.e_ident[EI_MAG2] != 'L') || (fh.e_ident[EI_MAG3] != 'F'))
      {
	  return (-2);
      }
    fh.e_machine = ntohs (fh.e_machine);
    if (fh.e_machine != EM_SPARC)
      {
	  printf ("not a SPARC executable (%d)\n", fh.e_machine);
	  return (-2);
      }

    fh.e_entry = ntohl (fh.e_entry);
    fh.e_shoff = ntohl (fh.e_shoff);
    fh.e_phoff = ntohl (fh.e_phoff);
    fh.e_phnum = ntohs (fh.e_phnum);
    fh.e_shnum = ntohs (fh.e_shnum);
    fh.e_phentsize = ntohs (fh.e_phentsize);
    fh.e_shentsize = ntohs (fh.e_shentsize);
    fh.e_shstrndx = ntohs (fh.e_shstrndx);
    fseek (fp, fh.e_shoff + ((fh.e_shstrndx) * fh.e_shentsize), SEEK_SET);
    if (fread (&ssh, sizeof (ssh), 1, fp) != 1)
      {
	  printf ("header: file read error\n");
	  return (-1);
      }
    ssh.sh_name = ntohl (ssh.sh_name);
    ssh.sh_type = ntohl (ssh.sh_type);
    ssh.sh_offset = ntohl (ssh.sh_offset);
    ssh.sh_size = ntohl (ssh.sh_size);
    strtab = (char *) malloc (ssh.sh_size);
    fseek (fp, ssh.sh_offset, SEEK_SET);
    if (fread (strtab, ssh.sh_size, 1, fp) != 1)
      {
	  printf ("string tab: file read error\n");
	  return (-1);
      }
    
    ph = calloc(fh.e_phnum, sizeof(Elf32_Phdr));
    if (NULL == ph) {
        puts("pheader: memory allocation error");
        return (-1);
    }
    for (i=0;i<fh.e_phnum; i++) {
	  fseek(fp, fh.e_phoff+(i*fh.e_phentsize), SEEK_SET);
	  if (fread(&ph[i], fh.e_phentsize, 1, fp) != 1) {
		printf("pheader: file read error\n");
	        return(-1);
	  }
	  ph[i].p_type = ntohl(ph[i].p_type);
	  ph[i].p_offset = ntohl(ph[i].p_offset);
	  ph[i].p_vaddr = ntohl(ph[i].p_vaddr);
	  ph[i].p_paddr = ntohl(ph[i].p_paddr);
	  ph[i].p_filesz = ntohl(ph[i].p_filesz);
	  ph[i].p_memsz = ntohl(ph[i].p_memsz);
	  if (verbose) {
	    printf("phead%d: type: %x, off: %d, vaddr: %x, paddr: %x, fsize: %d, msize: %d\n", 
	    i, ph[i].p_type, ph[i].p_offset,ph[i].p_vaddr,ph[i].p_paddr,ph[i].p_filesz, ph[i].p_memsz);
	  }
	}
    
    for (i = 1; i < fh.e_shnum; i++)
      {
	  fseek (fp, fh.e_shoff + (i * fh.e_shentsize), SEEK_SET);
	  if (fread (&sh, sizeof (sh), 1, fp) != 1)
	    {
		printf ("section header: file read error\n");
		return (-1);
	    }
	  sh.sh_name = ntohl (sh.sh_name);
	  sh.sh_addr = ntohl (sh.sh_addr);
	  sh.sh_size = ntohl (sh.sh_size);
	  sh.sh_type = ntohl (sh.sh_type);
	  sh.sh_offset = ntohl (sh.sh_offset);
	  sh.sh_flags = ntohl (sh.sh_flags);
	  if ((sh.sh_type == 1) && (sh.sh_size > 0) && (sh.sh_flags & 2))
	    {
#define PT_LOAD		1		/* Loadable program segment */
		    for (k=0;k<fh.e_phnum; k++) {
		if ((ph[k].p_type == PT_LOAD) &&
		    (sh.sh_offset >= ph[k].p_offset) &&
		    ((sh.sh_offset + sh.sh_size) <= (ph[k].p_offset + ph[k].p_memsz)) &&
		    ((sh.sh_offset + sh.sh_size) <= (ph[k].p_offset + ph[k].p_filesz)))
		 {
/*
		if ((sh.sh_addr >= ph[k].p_vaddr) && 
			((sh.sh_addr+sh.sh_size) <= (ph[k].p_vaddr + ph[k].p_filesz))) {
*/
		    vaddr = sh.sh_addr;
/*		    sh.sh_addr = sh.sh_addr  - ph[k].p_vaddr + ph[k].p_paddr; */
		    sh.sh_addr = sh.sh_offset  - ph[k].p_offset + ph[k].p_paddr;
	            if ((verbose) && (vaddr != sh.sh_addr)) {
		      	printf( "relocating %s (%d): %08x -> %08x\n", &strtab[sh.sh_name], k, vaddr, sh.sh_addr); 
		    }
/*		    sprintf(tdebug, "%08x (%08x)\n", sh.sh_addr, ph[k].p_paddr; dprint(tdebug); */
		    break;
		}
	    }
		    
                if (verbose)
                  printf ("section: %s at 0x%x, size %d bytes\n",
			&strtab[sh.sh_name], sh.sh_addr, sh.sh_size);
		mem = (char *) malloc (sh.sh_size);
		if (mem != (char *) -1)
		  {
		      if (sh.sh_type == 1)
			{
			    fseek (fp, sh.sh_offset, SEEK_SET);
			    if (fread (mem, sh.sh_size, 1, fp) != 1)
				return -1;
			    dumpsec (mem, sh.sh_addr, sh.sh_size,
				     &strtab[sh.sh_name], dumpfile);
			}
		  }
		else
		  {
		      printf ("load address outside physical memory\n");
		      printf ("load aborted\n");
		      return (-1);
		  }
	    }
      }

    free (ph);
    free (strtab);
    return (fh.e_entry);
}

struct exec
{
   unsigned long a_info;         /* Use macros N_MAGIC, etc for access */
   unsigned a_text;              /* length of text, in bytes */
   unsigned a_data;              /* length of data, in bytes */
   unsigned a_bss;               /* length of uninitialized data area for file, i n bytes */
   unsigned a_syms;              /* length of symbol table data in file, in bytes */
   unsigned a_entry;             /* start address */
   unsigned a_trsize;            /* length of relocation info for text, in bytes */
   unsigned a_drsize;            /* length of relocation info for data, in bytes */
};                  

#define M_SPARC 3
#define N_MACHTYPE(exec) (((exec).a_info >> 16) & 0xff)

static int ldaout(FILE *fp, FILE * dumpfile)
{
	char *mem, *memtext, *memdata;

   struct exec fh;

   fseek(fp, 0, SEEK_SET);
   if (fread(&fh, sizeof(fh),1, fp) != 1) {
	   printf("file read error\n");
	   return(-1);
   }
   
   fh.a_info = ntohl(fh.a_info);
   if (N_MACHTYPE(fh) != M_SPARC) {
	   return(-2);
   }
   
   fh.a_text = ntohl(fh.a_text);
   fh.a_data = ntohl(fh.a_data);
   fh.a_bss  = ntohl(fh.a_bss);
   fh.a_entry = ntohl(fh.a_entry);

   if (verbose)
	   printf("section: .text at 0x%08x, size %d bytes\n", 
		  fh.a_entry, fh.a_text);
   if (verbose)
	   printf("section: .data at 0x%08x, size %d bytes\n", 
		  fh.a_entry + fh.a_text, fh.a_data);
   if (verbose)
	      printf("section: .bss  at 0x%08x, size %d bytes\n", 
		     fh.a_entry + fh.a_text + fh.a_data, fh.a_bss);
   
   mem = calloc((fh.a_text+fh.a_data)/4+1, 4);
   if (mem != NULL) 
   {
     if (fread(mem, fh.a_text+fh.a_data, 1, fp) != 1) {
	     if (verbose)
		     printf("file read error\n");
	     free(mem);
	     return(-1);
     }
     
     memtext = calloc((fh.a_text)/4+1, 4);
     memdata = calloc((fh.a_data)/4+1, 4);
     memcpy(memtext, mem, fh.a_text);
     memcpy(memdata, mem+fh.a_text, fh.a_data);
     
     dumpsec (memtext, fh.a_entry, fh.a_text,
	      ".text", dumpfile);
     dumpsec (memdata, fh.a_entry + fh.a_text, fh.a_data,
	       ".data", dumpfile);
     
     /*MemLoadFn(lib, fh.a_entry, mem, fh.a_text + fh.a_data, verify);*/
     free(mem);
     return(fh.a_entry);
   } 
   else 
	   {
		   if (verbose)
			   printf("not enough memory\n");
		   return (-1);
	   }
}

int bch8cmd(char *cmd) {
	if (verbose)
		printf("bch8-exec: %s\n",cmd);
	fflush(stdout);
	trysystem (cmd);
	return 0;
}

int bch (long int word);
void appendbch8(char *post, int rev, int set, int pos )
{
	char cmd[1024];
	char *ofn = "dump_obj.o";
	char *ofnw = "dump_obj.o.w";
	char *bfn = "dump_bch8.b";
	char *bfnw = "dump_bch8.b.w";
	char ofilebch8[256];
	char *postfix = OS_EXESUFFIX;
	
	FILE *file, *bfile;

	sprintf(ofilebch8,"%s%s",ofile,post);
	sprintf (cmd,"%s-objcopy%s -O binary  %s %s  ", ccprefix, postfix,ofile, ofn);
	bch8cmd(cmd);
	
#ifdef WIN32
	file = fopen (ofn, "rb");
#else
	file = fopen (ofn, "r");
#endif
	
	if (file) {
		unsigned int off;
		int align,blen,i,len; char *buf, *bchb;
		unsigned int rompos = 0;
		
		fseek(file,0,SEEK_END);
		off = ftell(file);
		len = (off + 3) & ~3;
		blen = len/4;
		buf = malloc(len);
		memset(buf, 0, len);
		bchb = malloc(blen + 8);
		memset(bchb, 0, blen + 8);
		
		fseek(file,0,SEEK_SET);
		if (fread(buf, 1, off, file) != off) {
			fprintf(stderr, "Unable to read %s!\n", ofn);
			exit(1);
		}
		fclose (file);

		if (rev) {
			for (i = 0; i < blen; i++) {
				bchb[blen-1-i] = bch(htonl(((unsigned int *)buf)[i]));
				/*printf("0x%08x 0x%02x\n", ((unsigned int *)buf)[i],bchb[blen-1-i] & 0xff);*/
			}
			if (set == SEEK_END) {
				align = (4 - (blen & 3)) & 3;
				if (align) {
					memmove(bchb+align,bchb,blen);
					memset(bchb,0,align);
					blen += align;
				}
			}
		} else {
			for (i = 0; i < blen; i++) {
				bchb[blen+i] = bch(htonl(((unsigned int *)buf)[i]));
				/*printf("0x%08x 0x%02x\n", ((unsigned int *)buf)[i],bchb[blen-1-i] & 0xff);*/
			}
			blen = (blen + 3) & ~3;
		}
		
		
#ifdef WIN32
		bfile = fopen (bfn, "wb");
#else
		bfile = fopen (bfn, "w");
#endif
		fwrite(bchb, 1, blen, bfile);
		fclose(bfile);

		rompos = 0;
		if (set == SEEK_END) {
			rompos = pos - blen;
		} else if (set == SEEK_SET) {
			rompos = pos;
		}
		
		printf("Create bch8-containing %s from %s at 0x%x (romsize:0x%x)\n",ofilebch8,ofile,rompos, romsize);

                    /* the bch section, wrap into a elf image with section .bch */
                    sprintf (cmd, "%s-ld%s -r -b binary %s -o %s  ", ccprefix,postfix,bfn, bfnw);
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.wrapped  ", bfnw, bfnw);
                        bch8cmd(cmd);
                    }
                    
                    sprintf (cmd, "%s-objcopy%s --remove-section .text %s %s  ", ccprefix,postfix,bfnw, bfnw);
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.wrapped.remove  ", bfnw, bfnw);
                        bch8cmd(cmd);
                    }
                    
                    
                    /* the original rom image, wrap into a elf image with section .text */
                    sprintf (cmd, "%s-ld%s -r -b binary %s -o %s  ", ccprefix,postfix,ofn, ofnw);
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.wrapped  ", ofnw, ofnw);
                        bch8cmd(cmd);
                    }
                    
                    sprintf (cmd, "%s-objcopy%s --remove-section .text --rename-section .data=.text %s %s  ", ccprefix,postfix,ofnw, ofnw);
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.wrapped.renamed  ", ofnw, ofnw);
                        bch8cmd(cmd);
                    }
                    
                    
                    /* link together */
                    sprintf (cmd,"%s-ld%s -T%s/%s -Ttext=0x%x -Tdata=0x%x -o %s %s %s ",ccprefix,postfix,prefix, "linkbch" , startaddr, rompos, ofilebch8, ofnw, bfnw  );
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.linked  ", ofilebch8, ofilebch8);
                        bch8cmd(cmd);
                    }
                    
                    /* rename .data to .bch */
                    sprintf (cmd, "%s-objcopy%s --rename-section .data=.bch %s %s  ", ccprefix,postfix, ofilebch8, ofilebch8);
                    bch8cmd(cmd);
                    if (dodump) {
                        sprintf (cmd, "cp %s %s.renamed  ", ofilebch8, ofilebch8);
                        bch8cmd(cmd);
                    }

                if (!dodump)
                    {
                        fflush(stdout);
#ifdef __MINGW32__
                        sprintf (cmd, "del %s", ofn);
                        system(cmd);
                        sprintf (cmd, "del %s", ofnw);
                        system(cmd);
                        sprintf (cmd, "del %s", bfn);
                        system(cmd);
                        sprintf (cmd, "del %s", bfnw);
                        system(cmd);
#else
                        sprintf (cmd, "rm -f %s", ofn);
                        system(cmd);
                        sprintf (cmd, "rm -f %s", ofnw);
                        system(cmd);
                        sprintf (cmd, "rm -f %s", bfn);
                        system(cmd);
                        sprintf (cmd, "rm -f %s", bfnw);
                        system(cmd);
#endif
                    }

                
	} else {
		printf("Error: cannot open %s for bch generation\n",ofn);
	}
}

/* BCH code */
int bch (long int word)
{
   int i, c=0;
   int cb[8], d[32];

   /* expand bit values from word */
   for (i=0; i <= 31; i++) d[i] = (word >> i) & 0x1;

   /* check sum */
   cb[0] = d[0] ^ d[4] ^ d[6] ^ d[7] ^ d[8] ^ d[9] ^ d[11] ^ d[14] ^ d[17] ^ d[18] ^ d[19] ^ d[21] ^ d[26] ^ d[28] ^ d[29] ^ d[31];
   cb[1] = d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[6] ^ d[8] ^ d[10] ^ d[12] ^ d[16] ^ d[17] ^ d[18] ^ d[20] ^ d[22] ^ d[24] ^ d[26] ^ d[28];
   cb[2] = ~(d[0] ^ d[3] ^ d[4] ^ d[7] ^ d[9] ^ d[10] ^ d[13] ^ d[15] ^ d[16] ^ d[19] ^ d[20] ^ d[23] ^ d[25] ^ d[26] ^ d[29] ^ d[31]);
   cb[3] = ~(d[0] ^ d[1] ^ d[5] ^ d[6] ^ d[7] ^ d[11] ^ d[12] ^ d[13] ^ d[16] ^ d[17] ^ d[21] ^ d[22] ^ d[23] ^ d[27] ^ d[28] ^ d[29]);
   cb[4] = d[2] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7] ^ d[14] ^ d[15] ^ d[18] ^ d[19] ^ d[20] ^ d[21] ^ d[22] ^ d[23] ^ d[30] ^ d[31];
   cb[5] = d[8] ^ d[9] ^ d[10] ^ d[11] ^ d[12] ^ d[13] ^ d[14] ^ d[15] ^ d[24] ^ d[25] ^ d[26] ^ d[27] ^ d[28] ^ d[29] ^ d[30] ^ d[31];
   cb[6] = d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7] ^ d[24] ^ d[25] ^ d[26] ^ d[27] ^ d[28] ^ d[29] ^ d[30] ^ d[31];

   /* compress bit values from byte */
   for (i=0; i < 7; i++) c |= ((cb[i] & 0x1) << i);

   return c;
}

struct multientry {
    unsigned int key;
    const char *value;
};

static const struct multientry multientries[] = {
    {0                                          , "/lib/ut699"},
    {MULTIFLAG_SOFT                             , "/lib/ut699_soft"},
    {                     MULTIFLAG_FLAT        , "/lib/ut699_flat"},
    {MULTIFLAG_SOFT     | MULTIFLAG_FLAT        , "/lib/ut699_soft_flat"},
};

static const char *get_multidir(unsigned int multiflags)
{
    int i;

    /* Find multi-lib directory based on GCC options. */
    for (i = 0; i < NELEM(multientries); i++) {
        unsigned int key = multientries[i].key;
        const char *value = multientries[i].value;

        if (multiflags == key) {
            return value;
        }
    }

    /* GCC code generation option combination not recognized. */
    return NULL;
}

