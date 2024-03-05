#include "ecb.h"

#include "enc.cpp"
#include "dec.cpp"

/* Electronic Codebook (ECB) */
/* Integer Counter Mode (CTR) */

int aes_ecb_ctr_cipher(uint32 oper_mode,
                       uint32 encryption,
                       uint32 key_bytes,
                       uint32 iv_bytes,
                       uint32 input_bytes,
                       uint32 ekey[AES_EXP_KEY_SIZE],
                       uint32 iv[AES_MAX_IV_WORDS],
                       uint32 in[AES_MAX_IN_WORDS],
                       uint32 out[AES_MAX_IN_WORDS])
{
    #pragma HLS inline

    uint32 in_mem[AES_BLOCK_WORDS];
    uint32 out_mem[AES_BLOCK_WORDS];
    unsigned input_words = input_bytes >> 2;

    #pragma HLS array_partition variable=in_mem complete
    #pragma HLS array_partition variable=out_mem complete

#ifdef SYN_AES_CTR
    uint32 tmp_mem[AES_BLOCK_WORDS];
    #pragma HLS array_partition variable=tmp_mem complete

    if (oper_mode == AES_CTR_OPERATION_MODE)
    {
AES_ECB_CTR_CIPHER_L_1:
        for (unsigned k = 0; k < iv_bytes >> 2; ++k)
        {
            #pragma HLS loop_tripcount min=4 max=4
            #pragma HLS pipeline II=1

            in_mem[k] = iv[k];
        }

AES_ECB_CTR_CIPHER_L_2:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            in_mem[k] = AES_SWAP(in_mem[k]);
        }
    }
#endif // SYN_AES_CTR

#ifdef SYN_AES_ECB
    if (oper_mode == AES_ECB_OPERATION_MODE)
    {
        if (encryption == AES_ENCRYPTION_MODE)
        {
AES_ECB_CTR_CIPHER_L_3:
            for (unsigned i = 0; i < input_words; i += AES_BLOCK_WORDS)
            {
                /* Considering an input of 65536 bytes. */
                #pragma HLS loop_tripcount min=1 max=4096
                #pragma HLS pipeline II=4

AES_ECB_CTR_CIPHER_L_3_1:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma HLS unroll complete

                    in_mem[k] = in[i + k];
                }

AES_ECB_CTR_CIPHER_L_3_2:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma HLS unroll complete

                    in_mem[k] = AES_SWAP(in_mem[k]);
                }

                aes_encrypt(key_bytes, in_mem, out_mem, ekey);

AES_ECB_CTR_CIPHER_L_3_3:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma HLS unroll complete

                    out[i + k] = AES_SWAP(out_mem[k]);
                }
            }
        }
        else // encryption == DECRYPTION_MODE
        {
AES_ECB_CTR_CIPHER_L_4:
            for (unsigned i = 0; i < input_words; i += AES_BLOCK_WORDS)
            {
                /* Considering an input of 65536 bytes. */
                #pragma HLS loop_tripcount min=1 max=4096
                #pragma HLS pipeline II=4

AES_ECB_CTR_CIPHER_L_4_1:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma hls unroll complete

                    in_mem[k] = in[i + k];
                }

AES_ECB_CTR_CIPHER_L_4_2:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma HLS unroll complete

                    in_mem[k] = AES_SWAP(in_mem[k]);
                }

                aes_decrypt(key_bytes, in_mem, out_mem, ekey);

AES_ECB_CTR_CIPHER_L_4_3:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                {
                    #pragma HLS unroll complete

                    out[i + k] = AES_SWAP(out_mem[k]);
                }
            }
        }
    }
#endif // SYN_AES_ECB

#ifdef SYN_AES_CTR
    if (oper_mode == AES_CTR_OPERATION_MODE)
    {
AES_ECB_CTR_CIPHER_L_5:
        for (unsigned i = 0; i < input_words; i += AES_BLOCK_WORDS)
        {
            /* Considering an input of 65536 bytes. */
            #pragma HLS loop_tripcount min=1 max=4096
            #pragma HLS pipeline II=4

AES_ECB_CTR_CIPHER_L_5_1:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
            {
                #pragma HLS unroll complete

                tmp_mem[k] = in[i + k];
            }

            aes_encrypt(key_bytes, in_mem, out_mem, ekey);

AES_ECB_CTR_CIPHER_L_5_2:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
            {
                #pragma HLS unroll complete

                out_mem[k] = AES_SWAP(out_mem[k]);
            }

AES_ECB_CTR_CIPHER_L_5_3:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
            {
                #pragma HLS unroll complete

                out[i + k] = out_mem[k] ^ tmp_mem[k];
            }

            incr(in_mem);
        }
    }
#endif // SYN_AES_CTR

    return 0;
}
