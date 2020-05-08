#include "espacc.h"

#include "exp.h" // key expansion
#include "enc.h" // data encryption
#include "dec.h" // data decryption

void load_k(dma_word_t *in1,
    	    ap_uint<8> _keybuff[BLOCK_BYTES],
            dma_info_t *load_ctrl)
{
load_key:

    load_ctrl[0].size = SIZE_WORD_T;
    load_ctrl[0].length = WORDS_IN_CHUNK;
    load_ctrl[0].index = 0;

    for (unsigned i = 0; i < WORDS_IN_CHUNK; i++)
    {
        load_label0: for(unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
            _keybuff[i * VALUES_PER_WORD + j] = in1[i].word[j];
        }
    }
}

void load_d(dma_word_t *in1,
            uint32_t block,
            uint32_t ld_offset,
	        ap_uint<8> _inbuff[BLOCK_BYTES],
            dma_info_t *load_ctrl)
{
load_data:

    uint32_t base = WORDS_IN_CHUNK * block;

    load_ctrl[block].size = SIZE_WORD_T;
    load_ctrl[block].length = WORDS_IN_CHUNK;
    load_ctrl[block].index = ld_offset + base;

    for (unsigned i = 0; i < WORDS_IN_CHUNK; i++)
    {
        load_label1: for(unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
            _inbuff[i * VALUES_PER_WORD + j] = in1[base + i].word[j];
        }
    }
}

void store_d(dma_word_t *out,
             uint32_t block,
             uint32_t st_offset,
             ap_uint<8> _outbuff[BLOCK_BYTES],
	         dma_info_t *store_ctrl)
{
store_data:

    uint32_t base = WORDS_IN_CHUNK * block;

    store_ctrl[block].size = SIZE_WORD_T;
    store_ctrl[block].length = WORDS_IN_CHUNK;
    store_ctrl[block].index = st_offset + base;

    for (unsigned i = 0; i < WORDS_IN_CHUNK; i++)
    {
	    store_label1: for(unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
	        out[base + i].word[j] = _outbuff[i * VALUES_PER_WORD + j];
	    }
    }
}

#ifdef KEY_CHECK

void store_c(dma_word_t *out,
             uint32_t num_blocks,
             uint32_t st_offset,
	         dma_info_t *store_ctrl)
{
store_check:

    uint8_t val = (num_blocks > 1)? 0xFF : 0x00;
    uint32_t base = WORDS_IN_CHUNK * num_blocks;

    store_ctrl[num_blocks].size = SIZE_WORD_T;
    store_ctrl[num_blocks].length = WORDS_IN_CHUNK;
    store_ctrl[num_blocks].index = st_offset + base;

    for (unsigned i = 0; i < WORDS_IN_CHUNK; i++)
    {
        store_label2: for(unsigned j = 0; j < VALUES_PER_WORD; j++)
        {
            out[base + i].word[j] = val;
        }
    }
}

#endif // KEY_CHECK

void compute(uint32_t encryption,
			 ap_uint<32> key[EXP_KEY_SIZE],
             ap_uint<8> input[BLOCK_BYTES],
             ap_uint<8> output[BLOCK_BYTES])
{
	if (encryption == 0)
		aes_encrypt(input, output, key);
	else // encryption == 1
		aes_decrypt(input, output, key);
}

void top(dma_word_t *out,
         dma_word_t *in1,
         const uint32_t conf_info_encryption,
         const uint32_t conf_info_num_blocks,
	     dma_info_t *load_ctrl,
         dma_info_t *store_ctrl)
{
    ap_uint<8> _keybuff[KEY_BYTES];
    ap_uint<32> _keyexp[EXP_KEY_SIZE];
    const uint32_t ld_offset = 0;
    const uint32_t st_offset = WORDS_IN_CHUNK +
        conf_info_num_blocks * WORDS_IN_CHUNK;

	load_k(in1, _keybuff, load_ctrl);

	aes_expand(conf_info_encryption, _keybuff, _keyexp);

#ifdef KEY_CHECK
    store_c(out, conf_info_num_blocks, st_offset, store_ctrl);
#endif // KEY_CHECK

go:
    for (unsigned i = 0; i < conf_info_num_blocks; i++)
    {
	    ap_uint<8> _inbuff[BLOCK_BYTES];
	    ap_uint<8> _outbuff[BLOCK_BYTES];

        load_d(in1, i + 1, ld_offset, _inbuff, load_ctrl);

        compute(conf_info_encryption, _keyexp, _inbuff, _outbuff);

        store_d(out, i, st_offset, _outbuff, store_ctrl);
    }
}
