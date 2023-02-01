// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "../inc/espacc_config.h"
#include "../inc/espacc.h"
#include "hls_stream.h"
#include "hls_math.h"
#include <cstring>

void load(word_t _inbuff[SIZE_IN_CHUNK_DATA], dma_word_t *in1,
          /* <<--compute-params-->> */
	  dma_info_t &load_ctrl, int chunk, int batch)
{
load_data:

    const unsigned length = round_up(/* <<--data_in_size-->> */, VALUES_PER_WORD) / /* <<--chunking-factor-->> */;
    const unsigned index = length * (batch * /* <<--chunking-factor-->> */ + chunk);

    unsigned dma_length = length / VALUES_PER_WORD;
    unsigned dma_index = index / VALUES_PER_WORD;

    load_ctrl.index = dma_index;
    load_ctrl.length = dma_length;
    load_ctrl.size = SIZE_WORD_T;

    for (unsigned i = 0; i < dma_length; i++) {
    load_label0:for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    _inbuff[i * VALUES_PER_WORD + j] = in1[dma_index + i].word[j];
    	}
    }
}

void store(word_t _outbuff[SIZE_OUT_CHUNK_DATA], dma_word_t *out,
          /* <<--compute-params-->> */
	   dma_info_t &store_ctrl, int chunk, int batch)
{
store_data:

    const unsigned length = round_up(/* <<--data_out_size-->> */, VALUES_PER_WORD) / /* <<--chunking-factor-->> */;
    const unsigned store_offset = round_up(/* <<--data_in_size-->> */, VALUES_PER_WORD) * /* <<--number of transfers-->> */;
    const unsigned out_offset = /* <<--store-offset-->> */;
    const unsigned index = out_offset + length * (batch * /* <<--chunking-factor-->> */ + chunk);

    unsigned dma_length = length / VALUES_PER_WORD;
    unsigned dma_index = index / VALUES_PER_WORD;

    store_ctrl.index = dma_index;
    store_ctrl.length = dma_length;
    store_ctrl.size = SIZE_WORD_T;

    for (unsigned i = 0; i < dma_length; i++) {
    store_label1:for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    out[dma_index + i].word[j] = _outbuff[i * VALUES_PER_WORD + j];
	}
    }
}


void compute(word_t _inbuff[SIZE_IN_CHUNK_DATA],
             /* <<--compute-params-->> */
             word_t _outbuff[SIZE_OUT_CHUNK_DATA])
{

    // TODO implement compute functionality
    const unsigned length = round_up(/* <<--data_in_size-->> */, VALUES_PER_WORD) / /* <<--chunking-factor-->> */;

    for (int i = 0; i < length; i++)
        _outbuff[i] = _inbuff[i];
}


void top(dma_word_t *out, dma_word_t *in1,
         /* <<--params-->> */
	 dma_info_t &load_ctrl, dma_info_t &store_ctrl)
{

    /* <<--local-params-->> */

    // Batching
batching:
    for (unsigned b = 0; b < /* <<--number of transfers-->> */; b++)
    {
        // Chunking
    go:
        for (int c = 0; c < /* <<--chunking-factor-->> */; c++)
        {
            word_t _inbuff[SIZE_IN_CHUNK_DATA];
            word_t _outbuff[SIZE_OUT_CHUNK_DATA];

            load(_inbuff, in1,
                 /* <<--args-->> */
                 load_ctrl, c, b);
            compute(_inbuff,
                    /* <<--args-->> */
                    _outbuff);
            store(_outbuff, out,
                  /* <<--args-->> */
                  store_ctrl, c, b);
        }
    }
}
