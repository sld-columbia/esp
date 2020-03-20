#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef /* <<--token-type-->> */ token_t;

/* <<--params-def-->> */

/* <<--params-->> */

#define NACC 1

#define INT_BITS /* <<--int_bits-->> */
#define fl2fx(A) float_to_fixed/* <<--data_width-->> */(A, INT_BITS)

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "<accelerator_name>.0",
		.type = <accelerator_name>,
		/* <<--descriptor-->> */
		.desc.<accelerator_name>_desc.src_offset = 0,
		.desc.<accelerator_name>_desc.dst_offset = 0,
		.desc.<accelerator_name>_desc.esp.coherence = ACC_COH_NONE,
		.desc.<accelerator_name>_desc.esp.p2p_store = 0,
		.desc.<accelerator_name>_desc.esp.p2p_nsrcs = 0,
		.desc.<accelerator_name>_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
