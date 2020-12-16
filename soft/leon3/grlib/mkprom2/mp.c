extern unsigned int freqkhz;
extern unsigned int _mpstart, _mpirqsel0, _mpirqsel1;

/* avoid udiv reference */
static inline unsigned int int_div(unsigned int v, unsigned int d)
{
	unsigned int s = d, a = 1, r = 0, i;
	if (d == 0)
		return 0;
	for (i = 0; i < 32; i++) {
		if (s >= v)
			break;
		s = s << 1;
		a = a << 1;
	}
	while(s >= d) {
		while(s <= v) {
			v -= s;
			r += a;
		}
		s = s >> 1;
		a = a >> 1;
	}
	return r;
}

/* avoid umul reference */
static inline unsigned int int_mul(unsigned int v, unsigned int m)
{
	unsigned int r = 0, i;
	for (i = 0; i < 32; i++) {
		if (m & 1)
			r += v;
		m = m >> 1;
		v = v << 1;
	}
	return r;
}

typedef int (*amba_call)(unsigned int *, unsigned int, unsigned int, int, int, void *);

#define BYPASS_LOAD_PA(x)	    (*(unsigned long *)(x))
#define BYPASS_STORE_PA(x, v) *(unsigned long *)(x) = v;

#define VENDOR_GAISLER   1
#define GAISLER_L2CACHE      0x04b
#define GAISLER_AHB2AHB  0x020
/* GAISLER AHB2AHB Version 1 Bridge Definitions */
#define AHB2AHB_V1_FLAG_FFACT     0x0f0	/* Frequency factor against top bus */
#define AHB2AHB_V1_FLAG_FFACT_DIR 0x100	/* Factor direction, 0=down, 1=up */
#define AHB2AHB_V1_FLAG_MBUS      0x00c	/* Master bus number mask */
#define AHB2AHB_V1_FLAG_SBUS      0x003	/* Slave bus number mask */
#define GAISLER_APBMST   0x006
#define GAISLER_GPTIMER  0x011
#define GAISLER_APBUART  0x00C
#define GAISLER_IRQMP    0x00D

#define AMBA_MAXAPB_DEVS 64
#define AMBA_MAXAPB_DEVS_PERBUS 16
#define LEON3_AHB_CONF_WORDS 8
#define LEON3_APB_CONF_WORDS 2

#define LEON3_IO_AREA 0xfff00000
#define LEON3_CONF_AREA 0xff000
#define LEON3_AHB_SLAVE_CONF_AREA (1 << 11)
#define LEON3_AHB_SLAVES 16
#define LEON3_APB_SLAVES 16
#define APB_SLAVE 0
#define AHB_SLAVE 1
#define AHB_MASTER 1
#define LEON3_IRQMPSTATUS_CPUNR     28
#define LEON3_IRQMPSTATUS_BROADCAST 27

#define amba_vendor(x) (((x) >> 24) & 0xff)
#define amba_device(x) (((x) >> 12) & 0xfff)
#define amba_irq(conf) ((conf) & 0x1f)
#define amba_ver(conf) (((conf)>>5) & 0x1f)
#define amba_iobar_start(base, iobar) ((base) | ((((iobar) & 0xfff00000)>>12) & (((iobar) & 0xfff0)<<4)) )
#define amba_membar_mask(mbar) (((mbar) >> 4) & 0xfff)
#define amba_apb_mask(iobar) ((~(amba_membar_mask(iobar)<<8) & 0x000fffff) + 1)
#define amba_membar_start(mbar) (((mbar) & 0xfff00000) & (((mbar) & 0xfff0) << 16))
#define amba_membar_type(mbar) ((mbar) & 0xf)
#define amba_ahbio_adr(addr,base_ioarea) ((unsigned int)(base_ioarea) | ((addr) >> 12))

#define u32 unsigned long

struct leon3_chain {
  struct leon3_chain *n;
  u32 ioarea;
};

struct leon3_irqctrl_regs_map {
	u32 ilevel;
	u32 ipend;
	u32 iforce;
	u32 iclear;
	u32 mpstatus;
	u32 mpbroadcast;
	u32 notused02;
	u32 notused03;
	u32 ampctrl;
	u32 icsel[2];
	u32 notused13;
	u32 notused20;
	u32 notused21;
	u32 notused22;
	u32 notused23;
	u32 mask[16];
	u32 force[16];
	/* Extended IRQ registers */
	u32 intid[16];	/* 0xc0 */
	u32 unused[(0x1000-0x100)/4];
};

int mkprom_amba_scan(struct leon3_chain *c, unsigned int freq_khz, int *nextid, amba_call func, void *funcarg)
{
	unsigned int *cfg_area, *cfg_area_slv;
	unsigned int apbmst, mbar, conf, custom, userconf, ffact;
	int i, k, r = 0, dir;
	
	unsigned int ioarea = c->ioarea;
	
	cfg_area = (unsigned int *)(ioarea | LEON3_CONF_AREA);
 	cfg_area_slv = (unsigned int *)(ioarea | LEON3_CONF_AREA | LEON3_AHB_SLAVE_CONF_AREA);

	for (i = 0; i < LEON3_AHB_SLAVES && !r; i++) {
		
		if (BYPASS_LOAD_PA(cfg_area_slv)) {

			/*DBG_PRINTF_3("    SLV: %x:%x\n",amba_vendor(conf), amba_device(conf));*/
                    
			/* ------------- */
			if (func)
				r = func(cfg_area_slv, ioarea, freq_khz, *nextid, AHB_SLAVE, funcarg);
			(*nextid)++;
			/* ------------- */
			
			conf = BYPASS_LOAD_PA(cfg_area_slv+(0));
			mbar = BYPASS_LOAD_PA(cfg_area_slv+(4+0));

			
#ifdef NGMP_PRE_BUS
			if ((amba_vendor(conf) == VENDOR_GAISLER) &&
			    (amba_device(conf) == GAISLER_AHB2AHB )) {
#else
			if ((amba_vendor(conf) == VENDOR_GAISLER) &&
			    (amba_device(conf) == GAISLER_AHB2AHB || amba_device(conf) == GAISLER_L2CACHE)) {
#endif
				unsigned int freq_khz_new = freq_khz;
					
				/* Found AHB->AHB bus bridge custom config 1 contains ioarea. */
				custom = BYPASS_LOAD_PA(cfg_area_slv+(1+1));
				
				if ( amba_ver(conf) > 2 ) {
					/* todo */
				} else {
					userconf = BYPASS_LOAD_PA(cfg_area_slv+(1));
					ffact = (userconf & AHB2AHB_V1_FLAG_FFACT) >> 4;
					if (ffact > 1) {
						if ( (dir = (userconf & AHB2AHB_V1_FLAG_FFACT_DIR)) ) {
							freq_khz_new = int_mul(freq_khz,ffact);
						} else {
							freq_khz_new = int_div(freq_khz,ffact);
						}
					}
				}

				{
				  struct leon3_chain _c = { c, custom }, *pre = c;
				  while(pre) { 
				    if (pre->ioarea == custom)
				      goto already;
				    pre = pre->n;
				  }
				  r = mkprom_amba_scan(&_c, freq_khz_new, nextid, func, funcarg);
				already: do {} while(0);
                                }
			} else if ((amba_vendor(conf) == VENDOR_GAISLER) &&
				   (amba_device(conf) == GAISLER_APBMST)) {
				
				apbmst = amba_membar_start(mbar);
				cfg_area = (unsigned int *)(apbmst | LEON3_CONF_AREA);
				
				for (k = 0; k < AMBA_MAXAPB_DEVS_PERBUS && !r; k++) {
					
					unsigned int vendor, device;
					unsigned int apb_conf = BYPASS_LOAD_PA(cfg_area);
					/* unsigned int iobar = BYPASS_LOAD_PA(cfg_area + 1); */
					if ((vendor = amba_vendor(apb_conf)) && (device = amba_device(apb_conf))) {

						/*DBG_PRINTF_3("APB-SLV: %x:%x\n",amba_vendor(apb_conf), amba_device(apb_conf));*/
						
						/* ------------- */
						if (func)
							r = func(cfg_area, apbmst, freq_khz, *nextid, APB_SLAVE, funcarg);
						(*nextid)++;
						/* ------------- */
					}
					cfg_area += LEON3_APB_CONF_WORDS;
				}
			}
		}
		cfg_area_slv += LEON3_AHB_CONF_WORDS;
	}
	return r;
}

/* callback for _amba_scan: get freq and number of cores and init romstruct with it, baseaddress is still mapped 1-1 */
int leon_prom_amba_init(unsigned int a, unsigned int b, unsigned int f, int id, int typ, void *d) {
	unsigned int conf; unsigned int vendor, device;
	unsigned int iobar; struct leon3_irqctrl_regs_map *regs;
	conf = BYPASS_LOAD_PA(a);
	iobar = BYPASS_LOAD_PA(a + 4);
	vendor = amba_vendor(conf);
	device = amba_device(conf);
        if (typ == APB_SLAVE &&  vendor == VENDOR_GAISLER) {
            switch(device) {
            case GAISLER_IRQMP:
		regs = (struct leon3_irqctrl_regs_map *)amba_iobar_start(b, iobar);
                if ((regs)) {
                    /* quite irq */
                    BYPASS_STORE_PA(&regs->mask[0],0);
                    /* select controllers */
                    BYPASS_STORE_PA(&(regs->icsel[0]), _mpirqsel0);
                    BYPASS_STORE_PA(&(regs->icsel[1]), _mpirqsel1);
                    /* start processors */
                    BYPASS_STORE_PA(&(regs->mpstatus), _mpstart);
                }

                break;
                
            case GAISLER_GPTIMER:
            case GAISLER_APBUART:
            default:
                break;
                
            }
            
        }
	return 0;
}

/* defined also weak in prominit.S */
void _prom_mp(void) 
{
    int nextid = 0;
    struct leon3_chain c = { 0, LEON3_IO_AREA };
    mkprom_amba_scan(&c, freqkhz, &nextid,(amba_call)leon_prom_amba_init , 0);
}

    
