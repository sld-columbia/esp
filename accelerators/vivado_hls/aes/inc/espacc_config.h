#ifndef INC_ESPACC_CONFIG_H
#define INC_ESPACC_CONFIG_H

#include <ap_int.h>

// 8-bit data type
#define SIZE_WORD_T 0

// AES KEY bytes
// - Do not change
#define KEY_BYTES 16
#define EXP_KEY_SIZE 80

// AES DATA BLOCK bytes
#define BLOCK_BYTES 16

typedef struct dma_info
{
    ap_uint<32> index;
    ap_uint<32> length;
    ap_uint<32> size;

} dma_info_t;

// Number of values in a DMA word
#define VALUES_PER_WORD (DMA_SIZE / DATA_BITWIDTH)

// Number of DMA words to read / write
#define WORDS_IN_CHUNK (BLOCK_BYTES / VALUES_PER_WORD)

typedef struct dma_word
{
    ap_uint<8> word[VALUES_PER_WORD];

} dma_word_t;

#endif // INC_ESPACC_CONFIG_H
