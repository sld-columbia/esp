#ifndef __EXP_H__
#define __EXP_H__

void aes_expand(uint32_t encryption,
                ap_uint<8> key[KEY_BYTES],
                ap_uint<32> ekey[EXP_KEY_SIZE])
{
    int i, j;
    ap_uint<32> temp;

    GET32(ekey[0], key + 0);
    GET32(ekey[1], key + 4);
    GET32(ekey[2], key + 8);
    GET32(ekey[3], key + 12);

    i = 0;
    for (j = 0; j < 40; j += 4)
    {
        /* #pragma HLS pipeline II=1 */
        temp = ekey[j + 3];
        ekey[j + 4] = ekey[j + 0] ^
                    (Te2[temp.range(23, 16)] & 0xff000000) ^
                    (Te3[temp.range(15,  8)] & 0x00ff0000) ^
                    (Te0[temp.range( 7,  0)] & 0x0000ff00) ^
                    (Te1[temp.range(31, 24)] & 0x000000ff) ^ rcon[i++];
        ekey[j + 5] = ekey[j + 1] ^ ekey[j + 4];
        ekey[j + 6] = ekey[j + 2] ^ ekey[j + 5];
        ekey[j + 7] = temp        ^ ekey[j + 6];
    }

#define SWAP(var1, var2, tmp) \
    { tmp = var1; var1 = var2; var2 = tmp; }

    if (encryption == 1)
    {
        uint32_t tmp1, tmp2, tmp3, tmp4;

        for (i = 0; i < 20; i += 4)
        {
            /* #pragma HLS pipeline II=1 */
            #pragma HLS unroll skip_exit_check

            SWAP(ekey[i + 0], ekey[40 - i], tmp1);
            SWAP(ekey[i + 1], ekey[41 - i], tmp2);
            SWAP(ekey[i + 2], ekey[42 - i], tmp3);
            SWAP(ekey[i + 3], ekey[43 - i], tmp4);
        }

        for (j = 4; j < 40; ++j)
        {
            #pragma HLS unroll skip_exit_check

            ekey[j] = Td0[Te1[(ekey[j] >> 24) & 0xff] & 0xff] ^
                      Td1[Te1[(ekey[j] >> 16) & 0xff] & 0xff] ^
                      Td2[Te1[(ekey[j] >>  8) & 0xff] & 0xff] ^
                      Td3[Te1[(ekey[j] >>  0) & 0xff] & 0xff];
        }
    }
}

#endif /* __EXP_H__ */
