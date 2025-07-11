#include "cbc.h"

//#include "enc.cpp"
//#include "dec.cpp"

/* Cipher Block Chaining (CBC) */

int aes_cbc_cipher(uint32 encryption, uint32 key_bytes, uint32 input_bytes, uint32 iv_bytes,
                   uint32 ekey[AES_EXP_KEY_SIZE], uint32 iv[AES_MAX_IV_WORDS],
                   uint32 in[AES_MAX_IN_WORDS], uint32 out[AES_MAX_IN_WORDS])
{
#pragma HLS inline

    uint32 tmp_mem[AES_BLOCK_WORDS];
    uint32 out_mem[AES_BLOCK_WORDS];
    uint32 in_mem[AES_BLOCK_WORDS];
    unsigned input_words = input_bytes >> 2;

#pragma HLS array_partition variable = in_mem complete
#pragma HLS array_partition variable = out_mem complete
#pragma HLS array_partition variable = tmp_mem complete

AES_CBC_CIPHER_L_1:
    for (unsigned k = 0; k<iv_bytes> > 2; ++k) {
#pragma HLS loop_tripcount min = 4 max = 4
#pragma HLS pipeline II                = 1

        tmp_mem[k] = iv[k];
    }

    if (encryption == AES_ENCRYPTION_MODE) {
AES_CBC_CIPHER_L_2:
        for (unsigned i = 0; i < input_words; i += AES_BLOCK_WORDS) {
/* Considering an input of 65536 bytes. */
#pragma HLS loop_tripcount min = 1 max = 4096
#pragma HLS pipeline II                = 18

AES_CBC_CIPHER_L_2_1:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                in_mem[k] = in[i + k] ^ tmp_mem[k];
            }

AES_CBC_CIPHER_L_2_2:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                in_mem[k] = AES_SWAP(in_mem[k]);
            }

            aes_encrypt(key_bytes, in_mem, tmp_mem, ekey);

AES_CBC_CIPHER_L_2_3:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                tmp_mem[k] = AES_SWAP(tmp_mem[k]);
            }

AES_CBC_CIPHER_L_2_4:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                out[i + k] = tmp_mem[k];
            }
        }
    }
    else // if (encryption == DECRYPTION_MODE)
    {
AES_CBC_CIPHER_L_3:
        for (unsigned i = 0; i < input_words; i += AES_BLOCK_WORDS) {
/* Considering an input of 65536 bytes. */
#pragma HLS loop_tripcount min = 1 max = 4096
#pragma HLS pipeline II                = 4

AES_CBC_CIPHER_L_3_1:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                in_mem[k] = in[i + k];
            }

AES_CBC_CIPHER_L_3_2:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                in_mem[k] = AES_SWAP(in_mem[k]);
            }

            aes_decrypt(key_bytes, in_mem, out_mem, ekey);

AES_CBC_CIPHER_L_3_3:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                out_mem[k] = AES_SWAP(out_mem[k]);
            }

AES_CBC_CIPHER_L_3_4:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                out[i + k] = out_mem[k] ^ tmp_mem[k];
            }

AES_CBC_CIPHER_L_3_5:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k) {
#pragma HLS unroll complete

                tmp_mem[k] = AES_SWAP(in_mem[k]);
            }
        }
    }

    return 0;
}
