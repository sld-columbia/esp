#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int32_t token_t;

/* <<--params-def-->> */
#define SIZE 1024

/* <<--params-->> */
const int32_t readAddr = 0;
const int32_t writeAddr = 0;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "adderaccelerator.0",
		.type = adderaccelerator,
		/* <<--descriptor-->> */
		.desc.adderaccelerator_desc.size = SIZE,
		.desc.adderaccelerator_desc.readAddr = 0,
		.desc.adderaccelerator_desc.writeAddr = 0,
		.desc.adderaccelerator_desc.src_offset = 0,
		.desc.adderaccelerator_desc.dst_offset = 0,
		.desc.adderaccelerator_desc.esp.coherence = ACC_COH_NONE,
		.desc.adderaccelerator_desc.esp.p2p_store = 0,
		.desc.adderaccelerator_desc.esp.p2p_nsrcs = 0,
		.desc.adderaccelerator_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
