#include "prominit_leon3_amba.h"
#include <stdio.h>
#include <string.h>

/*#define DEBUG_CONFIG */

#define _printk(p)
#ifndef NULL
#define NULL 0
#endif
/*printk p */
#define LEON3_BYPASS_LOAD_PA(x)	(*(unsigned long*)(x))


/*#ifdef DEBUG_CONFIG
#define DBG_printk(p) do { char b[1024]; sprintf p; console_print_LEON(b); } while (0)
#else
#define _printk(p) printk p
#define DBG_printk(p) 
#endif
*/

/* Structure containing address to devices found on the Amba Plug&Play bus */
amba_confarea_type amba_conf, amba_conf2;
int amba_is_init = 0;

void vendor_dev_string(unsigned long conf, char *vendorbuf, char *devbuf)
{
	int vendor = amba_vendor(conf);
	int dev = amba_device(conf);
	char *devstr;
	char *vendorstr;
	sprintf(vendorbuf, "Unknown vendor %2x", vendor);
	sprintf(devbuf, "Unknown device %2x", dev);
	vendorstr = vendor_id2str(vendor);
	if (vendorstr) {
		sprintf(vendorbuf, "%s", vendorstr);
	}
	devstr = device_id2str(vendor, dev);
	if (devstr) {
		sprintf(devbuf, "%s", devstr);
	}
}


void amba_print_config(amba_confarea_type *a_conf)
{
	char devbuf[128];
	char vendorbuf[128];
	unsigned int conf;
	int i = 0;
	int j = 0;
	unsigned int addr;
	unsigned int m;
	_printk(("               Vendor          Device\n"));
	_printk(("AHB masters:\n"));
	i = 0;
	while (i < a_conf->ahbmst.devnr) {
		conf = amba_get_confword(a_conf->ahbmst, i, 0);
		vendor_dev_string(conf, vendorbuf, devbuf);
		_printk(("%2i(%2x:%3x|%2i): %16s %16s \n", i, amba_vendor(conf),
			 amba_device(conf), amba_irq(conf), vendorbuf, devbuf));
		for (j = 0; j < 4; j++) {
			m = amba_ahb_get_membar(a_conf->ahbmst, i, j);
			if (m) {
				addr = amba_membar_start(m);
				_printk((" +%i: 0x%x \n", j, addr));
			}
		}
		i++;
	}
	_printk(("AHB slaves:\n"));
	i = 0;
	while (i < a_conf->ahbslv.devnr) {
		conf = amba_get_confword(a_conf->ahbslv, i, 0);
		vendor_dev_string(conf, vendorbuf, devbuf);
		_printk(("%2i(%2x:%3x|%2i): %16s %16s \n", i, amba_vendor(conf),
			 amba_device(conf), amba_irq(conf), vendorbuf, devbuf));

		
		for (j = 0; j < 4; j++) {
			m = amba_ahb_get_membar(a_conf->ahbslv, i, j);
			if (m) {
				addr = amba_membar_start(m);
				if (amba_membar_type(m) == AMBA_TYPE_AHBIO) {
					addr = AMBA_TYPE_AHBIO_ADDR(addr);
				} else if (amba_membar_type(m) ==
					   AMBA_TYPE_APBIO) {
					_printk(("Warning: apbio membar\n"));
				}
				_printk((" +%i: 0x%x (raw:0x%x)\n", j, addr, m));
			}
		}
		i++;
	}
	_printk(("APB slaves:\n"));
	i = 0;
	while (i < a_conf->apbslv.devnr) {

		conf = amba_get_confword(a_conf->apbslv, i, 0);
		vendor_dev_string(conf, vendorbuf, devbuf);
		_printk(("%2i(%2x:%3x|%2i): %16s %16s \n", i, amba_vendor(conf),
			 amba_device(conf), amba_irq(conf), vendorbuf, devbuf));

		m = amba_apb_get_membar(a_conf->apbslv, i);
		addr = amba_iobar_start(a_conf->apbslv.apbmst[i], m);
		_printk((" +%2i: 0x%x (raw:0x%x) \n", 0, addr, m));

		i++;

	}

}

void amba_prinf_config(void)
{
   int index = 0;
   amba_confarea_type *area;
   
   area = &amba_conf;

   while (area != NULL) {
      _printk(("--- AMBA bus %d ---\n", index));
      amba_print_config(area);
      area = area->next;
      index++;
   }
   _printk(("--- End of AMBA PnP ---\n"));
}

#define amba_insert_device(tab, address) \
{ \
  if (LEON3_BYPASS_LOAD_PA(address)) \
  { \
    (tab)->addr[(tab)->devnr] = (address); \
    (tab)->devnr ++; \
  } \
} while(0)

#define amba_insert_apb_device(tab, address, apbmst, idx)	\
{ \
  if (*(address)) \
  { \
    (tab)->addr[(tab)->devnr] = (address); \
    (tab)->apbmst[(tab)->devnr] = (apbmst);	\
    (tab)->apbmstidx[(tab)->devnr] = (idx);	\
    (tab)->devnr ++; \
  } \
} while(0)

/*
 *  Used to scan system bus. Probes for AHB masters, AHB slaves and 
 *  APB slaves. Addresses to configuration areas of the AHB masters,
 *  AHB slaves, APB slaves and APB master are stored in 
 *  amba_ahb_masters, amba_ahb_slaves and amba.
 */

void amba_scan(amba_confarea_type* a_conf, unsigned int ioarea)
{
        unsigned int *cfg_area;	/* address to configuration area */
	unsigned int mbar, conf, custom;
	int i, j, idx = 0; unsigned int apbmst;
        static int allocate_child = 1;

        memset(a_conf, 0, sizeof(amba_conf));
	//amba_conf.ahbmst.devnr = 0; amba_conf.ahbslv.devnr = 0; amba_conf.apbslv.devnr = 0;
     
        cfg_area = (unsigned int *)(ioarea | LEON3_CONF_AREA);


	for (i = 0; i < LEON3_AHB_MASTERS; i++) {
		amba_insert_device(&a_conf->ahbmst, cfg_area);
		cfg_area += LEON3_AHB_CONF_WORDS;
	}

	cfg_area =
	    (unsigned int *)(ioarea | LEON3_CONF_AREA |
			     LEON3_AHB_SLAVE_CONF_AREA);
	for (i = 0; i < LEON3_AHB_SLAVES; i++) {
		amba_insert_device(&a_conf->ahbslv, cfg_area);
		cfg_area += LEON3_AHB_CONF_WORDS;
	}

	for (i = 0; i < a_conf->ahbslv.devnr; i++) {
		conf = amba_get_confword(a_conf->ahbslv, i, 0);
		mbar = amba_ahb_get_membar(a_conf->ahbslv, i, 0);
                if ((amba_vendor(conf) == VENDOR_GAISLER) &&
                    (amba_device(conf) == GAISLER_AHB2AHB)) {
                        /* 
                         * Found AHB->AHB bus bridge
                         * Custom config 1 contains ioarea.
                         */
                        custom = amba_ahb_get_custom(a_conf->ahbslv,i,1);
                        /* 
                         * We only create one 'child bus' to each bus. More
                         * complex systems will need to adapt this code. 
                         */
                        if (allocate_child && a_conf->next == NULL) {
                           // Current implementation only allows for one extra bus
                           allocate_child = 0;
                           a_conf->next = &amba_conf2;
                           amba_scan(a_conf->next, custom);
                        }
                } else if ((amba_vendor(conf) == VENDOR_GAISLER)
		    && (amba_device(conf) == GAISLER_APBMST)) {
			int k;
			/*a_conf->apbmst = */apbmst = amba_membar_start(mbar);
			cfg_area =
			    (unsigned int *)(apbmst | LEON3_CONF_AREA);

#ifdef DEBUG_CONFIG
			_printk(("Found apbmst, cfg: 0x%x\n",
				 (unsigned int)cfg_area));
			
#endif
			
			for (j = a_conf->apbslv.devnr, k = 0; j < AMBA_MAXAPB_DEVS && k < AMBA_MAXAPB_DEVS_PERBUS;
			     j++,k++) {
				amba_insert_apb_device(&a_conf->apbslv, cfg_area, apbmst, idx);
        
				cfg_area += LEON3_APB_CONF_WORDS;
			}
			idx++;
		}
	}
}


/* Build PnP structure, find interrupt controller and timer */
void amba_init(void)
{
	if (amba_is_init)
	  return;

	amba_is_init = 1;
	
#ifdef DEBUG_CONFIG
	_printk(("Reading AMBA Plug&Play configuration area\n"));
#endif

        /* Probe for AHB masters, AHB slaves and APB slaves */
        amba_scan(&amba_conf, LEON3_IO_AREA);
	
}

unsigned long amba_find_apbslv_addr(unsigned long vendor, unsigned long device,
				    unsigned long *irq)
{
	unsigned int i, conf, iobar;
        amba_confarea_type *a_conf = &amba_conf;

	if (!amba_is_init)
	  return 0;

        while (a_conf != NULL) {
           for (i = 0; i < a_conf->apbslv.devnr; i++) {
              conf = amba_get_confword(a_conf->apbslv, i, 0);
              if ((amba_vendor(conf) == vendor)
                  && (amba_device(conf) == device)) {
                 if (irq) {
                    *irq = amba_irq(conf);
                 }
                 iobar = amba_apb_get_membar(a_conf->apbslv, i);
                 return amba_iobar_start(a_conf->apbslv.apbmst[i], iobar);
              }
           }
           a_conf = a_conf->next;
        }
	return 0;
}

