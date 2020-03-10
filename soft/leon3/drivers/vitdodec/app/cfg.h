#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

typedef int8_t token_t;

/* <<--params-def-->> */
#define CBPS 48
#define NTRACEBACK 5
#define DATA_BITS 288

/* <<--params-->> */
const int32_t cbps = CBPS;
const int32_t ntraceback = NTRACEBACK;
const int32_t data_bits = DATA_BITS;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "vitdodec.0",
		.type = vitdodec,
		/* <<--descriptor-->> */
		.desc.vitdodec_desc.cbps = CBPS,
		.desc.vitdodec_desc.ntraceback = NTRACEBACK,
		.desc.vitdodec_desc.data_bits = DATA_BITS,
		.desc.vitdodec_desc.src_offset = 0,
		.desc.vitdodec_desc.dst_offset = 0,
		.desc.vitdodec_desc.esp.coherence = ACC_COH_NONE,
		.desc.vitdodec_desc.esp.p2p_store = 0,
		.desc.vitdodec_desc.esp.p2p_nsrcs = 0,
		.desc.vitdodec_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
