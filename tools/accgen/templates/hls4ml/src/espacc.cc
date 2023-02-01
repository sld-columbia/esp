// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "espacc_config.h"
#include "espacc.h"
#include "hls_stream.h"
#include "hls_math.h"
#include <cstring>

#include "myproject.h"

void load(input_t _inbuff[SIZE_IN_CHUNK_DATA], dma_word_t *in1, unsigned chunk,
	  dma_info_t &load_ctrl, int base_index)
{
load_data:

    unsigned base = SIZE_IN_CHUNK * chunk;

    load_ctrl.index = base;
    load_ctrl.length = SIZE_IN_CHUNK;
    load_ctrl.size = SIZE_WORD_T;

    for (unsigned i = 0; i < SIZE_IN_CHUNK; i++) {
    	load_label0:for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    int index = i * VALUES_PER_WORD + j;
	    if (index < SIZE_IN_CHUNK_DATA)
		_inbuff[i * VALUES_PER_WORD + j] = (input_t) in1[base + i].word[j];
    	}
    }
}

void store(result_t _outbuff[SIZE_OUT_CHUNK_DATA], dma_word_t *out, unsigned chunk,
	   dma_info_t &store_ctrl, int base_index)
{
store_data:

    unsigned base = SIZE_OUT_CHUNK * chunk;

    store_ctrl.index = base + base_index;
    store_ctrl.length = SIZE_OUT_CHUNK;
    store_ctrl.size = SIZE_WORD_T;

    for (unsigned i = 0; i < SIZE_OUT_CHUNK; i++) {
	store_label1:for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    int index = i * VALUES_PER_WORD + j;
	    if (index < SIZE_OUT_CHUNK_DATA)
		out[base + i].word[j] = (word_t) _outbuff[i * VALUES_PER_WORD + j];
	    else
	    	out[base + i].word[j] = 0;
	}
    }
}

void compute(input_t _inbuff[SIZE_IN_CHUNK_DATA], result_t _outbuff[SIZE_OUT_CHUNK_DATA])
{
    // computation
    unsigned short size_in1, size_out1;
    myproject(_inbuff, _outbuff, size_in1, size_out1);
}

void top(dma_word_t *out, dma_word_t *in1, const unsigned conf_info_nbursts,
	 dma_info_t &load_ctrl, dma_info_t &store_ctrl)
{

go:
    for (unsigned i = 0; i < conf_info_nbursts; i++)
    {
	input_t _inbuff[SIZE_IN_CHUNK_DATA];
	result_t _outbuff[SIZE_OUT_CHUNK_DATA];

        load(_inbuff, in1, i, load_ctrl, 0);
        compute(_inbuff, _outbuff);
        store( _outbuff, out, i, store_ctrl, conf_info_nbursts * SIZE_IN_CHUNK);
    }
}
