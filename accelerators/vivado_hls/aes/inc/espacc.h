#ifndef INC_ESPACC_H
#define INC_ESPACC_H

#include <cstdio>
#include <cstring>

#include <ap_int.h>
#include <ap_fixed.h>
#include <hls_math.h>
#include <hls_stream.h>

#include "defines.h"
#include "espacc_config.h"

void top(dma_word_t *out,
         dma_word_t *in1,
         const unsigned conf_info_encryption,
         const unsigned conf_info_num_blocks,
	     dma_info_t *load_ctrl,
         dma_info_t *store_ctrl);

#endif
