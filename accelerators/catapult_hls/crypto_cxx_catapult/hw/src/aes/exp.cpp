#include "exp.h"

void aes_expand(uint32 encryption,
                uint32 key_bytes,
                uint32 key[AES_MAX_KEY_WORDS],
                uint32 ekey[AES_EXP_KEY_SIZE])
{
    unsigned i, j;
#ifdef __MENTOR_CATAPULT_HLS__
    ac_int<32, false> temp;
    #define __range(x, y, z) x.slc<y-z+1>(z)
#else // VIVADO_HLS
    ap_uint<32> temp;
    #define __range(x, y, z) x.range(y, z)
#endif // __MENTOR_CATAPULT_HLS__

    #pragma HLS resource variable=Td0 core=ROM_nP_BRAM
    #pragma HLS resource variable=Td1 core=ROM_nP_BRAM
    #pragma HLS resource variable=Td2 core=ROM_nP_BRAM
    #pragma HLS resource variable=Td3 core=ROM_nP_BRAM
    #pragma HLS resource variable=Te0 core=ROM_nP_BRAM
    #pragma HLS resource variable=Te1 core=ROM_nP_BRAM
    #pragma HLS resource variable=Te2 core=ROM_nP_BRAM
    #pragma HLS resource variable=Te3 core=ROM_nP_BRAM
    #pragma HLS resource variable=rcon core=ROM_nP_BRAM

AES_EXPAND_L_1:
    for (unsigned k = 0; k < key_bytes >> 2; ++k)
    {
        #pragma HLS loop_tripcount min=4 max=8
        #pragma HLS pipeline II=1

        ekey[k] = key[k];
    }

AES_EXPAND_L_2:
    for (unsigned k = 0; k < AES_MAX_KEY_WORDS; ++k)
    {
        #pragma HLS unroll complete

        ekey[k] = AES_SWAP(ekey[k]);
    }

    if (key_bytes == 16)
    {
        i = 0;
AES_EXPAND_L_3:
        for (j = 0; j < 40; j += 4)
        {
			/* #pragma HLS unroll complete */
			/* #pragma HLS pipeline II=1 */

            temp = ekey[j + 3];
            ekey[j + 4] = ekey[j + 0] ^
                        (Te2[__range(temp, 23, 16)] & 0xff000000) ^
                        (Te3[__range(temp, 15,  8)] & 0x00ff0000) ^
                        (Te0[__range(temp,  7,  0)] & 0x0000ff00) ^
                        (Te1[__range(temp, 31, 24)] & 0x000000ff) ^ rcon[i++];
            ekey[j + 5] = ekey[j + 1] ^ ekey[j + 4];
            ekey[j + 6] = ekey[j + 2] ^ ekey[j + 5];
            ekey[j + 7] = temp        ^ ekey[j + 6];
        }
    }
    else if (key_bytes == 24)
    {
        i = 0;
AES_EXPAND_L_4:
        for (j = 0; j < 48; j += 6)
        {
			/* #pragma HLS unroll complete */
			/* #pragma HLS pipeline */

            temp = ekey[j + 5];
            ekey[j + 6] = ekey[j + 0] ^
                        (Te2[__range(temp, 23, 16)] & 0xff000000) ^
                        (Te3[__range(temp, 15,  8)] & 0x00ff0000) ^
                        (Te0[__range(temp,  7,  0)] & 0x0000ff00) ^
                        (Te1[__range(temp, 31, 24)] & 0x000000ff) ^ rcon[i++];
            ekey[j +  7] = ekey[j + 1] ^ ekey[j + 6];
            ekey[j +  8] = ekey[j + 2] ^ ekey[j + 7];
            ekey[j +  9] = ekey[j + 3] ^ ekey[j + 8];
            ekey[j + 10] = ekey[j + 4] ^ ekey[j + 9];
            ekey[j + 11] = ekey[j + 5] ^ ekey[j + 10];
        }
    }
    else if (key_bytes == 32)
    {
       i = 0;
AES_EXPAND_L_5:
       for (j = 0; j < 56; j += 8)
       {
			/* #pragma HLS unroll complete */
		    /* #pragma HLS pipeline */

            temp = ekey[j + 7];
            ekey[j + 8] = ekey[j + 0] ^
                          (Te2[__range(temp, 23, 16)] & 0xff000000) ^
                          (Te3[__range(temp, 15,  8)] & 0x00ff0000) ^
                          (Te0[__range(temp,  7,  0)] & 0x0000ff00) ^
                          (Te1[__range(temp, 31, 24)] & 0x000000ff) ^ rcon[i++];
            ekey[j +  9] = ekey[j + 1] ^ ekey[j +  8];
            ekey[j + 10] = ekey[j + 2] ^ ekey[j +  9];
            ekey[j + 11] = ekey[j + 3] ^ ekey[j + 10];

            if (j != 48)
            {
                temp = ekey[j + 11];
                ekey[j + 12] = ekey[j + 4] ^
                             (Te2[__range(temp, 31, 24)] & 0xff000000) ^
                             (Te3[__range(temp, 23, 16)] & 0x00ff0000) ^
                             (Te0[__range(temp, 15,  8)] & 0x0000ff00) ^
                             (Te1[__range(temp,  7,  0)] & 0x000000ff);
                ekey[j + 13] = ekey[j + 5] ^ ekey[j + 12];
                ekey[j + 14] = ekey[j + 6] ^ ekey[j + 13];
                ekey[j + 15] = ekey[j + 7] ^ ekey[j + 14];
            }
        }
    }

#define SWAP(var1, var2, tmp) \
    { tmp = var1; var1 = var2; var2 = tmp; }

    if (encryption == AES_DECRYPTION_MODE)
    {
        uint32 tmp1, tmp2, tmp3, tmp4;

        if (key_bytes == 16)
        {
AES_EXPAND_L_6:
            for (i = 0; i < 20; i += 4)
            {
                #pragma HLS unroll complete

                SWAP(ekey[i + 0], ekey[40 - i], tmp1);
                SWAP(ekey[i + 1], ekey[41 - i], tmp2);
                SWAP(ekey[i + 2], ekey[42 - i], tmp3);
                SWAP(ekey[i + 3], ekey[43 - i], tmp4);
            }

        }
        else if (key_bytes == 24)
        {
AES_EXPAND_L_7:
            for (i = 0; i < 24; i += 4)
            {
                #pragma HLS unroll complete

                SWAP(ekey[i + 0], ekey[48 - i], tmp1);
                SWAP(ekey[i + 1], ekey[49 - i], tmp2);
                SWAP(ekey[i + 2], ekey[50 - i], tmp3);
                SWAP(ekey[i + 3], ekey[51 - i], tmp4);
            }
        }
        else if (key_bytes == 32)
        {
AES_EXPAND_L_8:
            for (i = 0; i < 28; i += 4)
            {
                #pragma HLS unroll complete

                SWAP(ekey[i + 0], ekey[56 - i], tmp1);
                SWAP(ekey[i + 1], ekey[57 - i], tmp2);
                SWAP(ekey[i + 2], ekey[58 - i], tmp3);
                SWAP(ekey[i + 3], ekey[59 - i], tmp4);
            }
        }

AES_EXPAND_L_9:
        for (j = 4; j < 40; ++j)
        {
			#pragma HLS unroll complete

            ekey[j] = Td0[Te1[(ekey[j] >> 24) & 0xff] & 0xff] ^
                      Td1[Te1[(ekey[j] >> 16) & 0xff] & 0xff] ^
                      Td2[Te1[(ekey[j] >>  8) & 0xff] & 0xff] ^
                      Td3[Te1[(ekey[j] >>  0) & 0xff] & 0xff];
        }

        if (key_bytes >= 24)
        {
AES_EXPAND_L_10:
            for (j = 40; j < 48; ++j)
            {
				#pragma HLS unroll complete

                ekey[j] = Td0[Te1[(ekey[j] >> 24) & 0xff] & 0xff] ^
                          Td1[Te1[(ekey[j] >> 16) & 0xff] & 0xff] ^
                          Td2[Te1[(ekey[j] >>  8) & 0xff] & 0xff] ^
                          Td3[Te1[(ekey[j] >>  0) & 0xff] & 0xff];
            }
        }

        if (key_bytes >= 32)
        {
AES_EXPAND_L_11:
            for (j = 48; j < 56; ++j)
            {
				#pragma HLS unroll complete

                ekey[j] = Td0[Te1[(ekey[j] >> 24) & 0xff] & 0xff] ^
                          Td1[Te1[(ekey[j] >> 16) & 0xff] & 0xff] ^
                          Td2[Te1[(ekey[j] >>  8) & 0xff] & 0xff] ^
                          Td3[Te1[(ekey[j] >>  0) & 0xff] & 0xff];
            }
        }
    }
}
