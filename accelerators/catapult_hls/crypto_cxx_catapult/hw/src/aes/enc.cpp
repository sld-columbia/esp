#include "enc.h"

void aes_encrypt(uint32 key_bytes, uint32 in[AES_BLOCK_WORDS], uint32 out[AES_BLOCK_WORDS],
                 uint32 ekey[AES_EXP_KEY_SIZE])
{
#pragma HLS inline off
#pragma HLS pipeline II = 4

    int i = 0, j = 0;
#ifndef C_SIMULATION
    #ifdef __MENTOR_CATAPULT_HLS__
    ac_int<32, false> s0, s1, s2, s3;
    ac_int<32, false> t0, t1, t2, t3;
        #define __range(x, y, z) x.slc<y - z + 1>(z)
    #else // VIVADO_HLS
    ap_uint<32> s0, s1, s2, s3;
    ap_uint<32> t0, t1, t2, t3;
        #define __range(x, y, z) x.range(y, z)
    #endif // __MENTOR_CATAPULT_HLS__
#else      /* !C_SIMULATION */
    uint32 s0, s1, s2, s3;
    uint32 t0, t1, t2, t3;
    #define __range(x, y, z) ((x >> z) & 0xff)
#endif /* C_SIMULATION */

#pragma HLS resource variable = Te0 core = ROM_nP_BRAM
#pragma HLS resource variable = Te1 core = ROM_nP_BRAM
#pragma HLS resource variable = Te2 core = ROM_nP_BRAM
#pragma HLS resource variable = Te3 core = ROM_nP_BRAM

    s0 = in[0] ^ ekey[0];
    s1 = in[1] ^ ekey[1];
    s2 = in[2] ^ ekey[2];
    s3 = in[3] ^ ekey[3];

AES_ENCRYPT_L_1:
    for (i = 0; i < 5; i += 1) {
#pragma HLS unroll complete

        t0 = Te0[__range(s0, 31, 24)] ^ Te1[__range(s1, 23, 16)] ^ Te2[__range(s2, 15, 8)] ^
            Te3[__range(s3, 7, 0)] ^ ekey[j + 4];
        t1 = Te0[__range(s1, 31, 24)] ^ Te1[__range(s2, 23, 16)] ^ Te2[__range(s3, 15, 8)] ^
            Te3[__range(s0, 7, 0)] ^ ekey[j + 5];
        t2 = Te0[__range(s2, 31, 24)] ^ Te1[__range(s3, 23, 16)] ^ Te2[__range(s0, 15, 8)] ^
            Te3[__range(s1, 7, 0)] ^ ekey[j + 6];
        t3 = Te0[__range(s3, 31, 24)] ^ Te1[__range(s0, 23, 16)] ^ Te2[__range(s1, 15, 8)] ^
            Te3[__range(s2, 7, 0)] ^ ekey[j + 7];

        s0 = Te0[__range(t0, 31, 24)] ^ Te1[__range(t1, 23, 16)] ^ Te2[__range(t2, 15, 8)] ^
            Te3[__range(t3, 7, 0)] ^ ekey[j + 8];
        s1 = Te0[__range(t1, 31, 24)] ^ Te1[__range(t2, 23, 16)] ^ Te2[__range(t3, 15, 8)] ^
            Te3[__range(t0, 7, 0)] ^ ekey[j + 9];
        s2 = Te0[__range(t2, 31, 24)] ^ Te1[__range(t3, 23, 16)] ^ Te2[__range(t0, 15, 8)] ^
            Te3[__range(t1, 7, 0)] ^ ekey[j + 10];
        s3 = Te0[__range(t3, 31, 24)] ^ Te1[__range(t0, 23, 16)] ^ Te2[__range(t1, 15, 8)] ^
            Te3[__range(t2, 7, 0)] ^ ekey[j + 11];

        j += 8;
    }

    if (key_bytes >= 24) {
        t0 = Te0[__range(s0, 31, 24)] ^ Te1[__range(s1, 23, 16)] ^ Te2[__range(s2, 15, 8)] ^
            Te3[__range(s3, 7, 0)] ^ ekey[44];
        t1 = Te0[__range(s1, 31, 24)] ^ Te1[__range(s2, 23, 16)] ^ Te2[__range(s3, 15, 8)] ^
            Te3[__range(s0, 7, 0)] ^ ekey[45];
        t2 = Te0[__range(s2, 31, 24)] ^ Te1[__range(s3, 23, 16)] ^ Te2[__range(s0, 15, 8)] ^
            Te3[__range(s1, 7, 0)] ^ ekey[46];
        t3 = Te0[__range(s3, 31, 24)] ^ Te1[__range(s0, 23, 16)] ^ Te2[__range(s1, 15, 8)] ^
            Te3[__range(s2, 7, 0)] ^ ekey[47];

        s0 = Te0[__range(t0, 31, 24)] ^ Te1[__range(t1, 23, 16)] ^ Te2[__range(t2, 15, 8)] ^
            Te3[__range(t3, 7, 0)] ^ ekey[48];
        s1 = Te0[__range(t1, 31, 24)] ^ Te1[__range(t2, 23, 16)] ^ Te2[__range(t3, 15, 8)] ^
            Te3[__range(t0, 7, 0)] ^ ekey[49];
        s2 = Te0[__range(t2, 31, 24)] ^ Te1[__range(t3, 23, 16)] ^ Te2[__range(t0, 15, 8)] ^
            Te3[__range(t1, 7, 0)] ^ ekey[50];
        s3 = Te0[__range(t3, 31, 24)] ^ Te1[__range(t0, 23, 16)] ^ Te2[__range(t1, 15, 8)] ^
            Te3[__range(t2, 7, 0)] ^ ekey[51];

        j += 8;
    }

    if (key_bytes == 32) {
        t0 = Te0[__range(s0, 31, 24)] ^ Te1[__range(s1, 23, 16)] ^ Te2[__range(s2, 15, 8)] ^
            Te3[__range(s3, 7, 0)] ^ ekey[52];
        t1 = Te0[__range(s1, 31, 24)] ^ Te1[__range(s2, 23, 16)] ^ Te2[__range(s3, 15, 8)] ^
            Te3[__range(s0, 7, 0)] ^ ekey[53];
        t2 = Te0[__range(s2, 31, 24)] ^ Te1[__range(s3, 23, 16)] ^ Te2[__range(s0, 15, 8)] ^
            Te3[__range(s1, 7, 0)] ^ ekey[54];
        t3 = Te0[__range(s3, 31, 24)] ^ Te1[__range(s0, 23, 16)] ^ Te2[__range(s1, 15, 8)] ^
            Te3[__range(s2, 7, 0)] ^ ekey[55];

        s0 = Te0[__range(t0, 31, 24)] ^ Te1[__range(t1, 23, 16)] ^ Te2[__range(t2, 15, 8)] ^
            Te3[__range(t3, 7, 0)] ^ ekey[56];
        s1 = Te0[__range(t1, 31, 24)] ^ Te1[__range(t2, 23, 16)] ^ Te2[__range(t3, 15, 8)] ^
            Te3[__range(t0, 7, 0)] ^ ekey[57];
        s2 = Te0[__range(t2, 31, 24)] ^ Te1[__range(t3, 23, 16)] ^ Te2[__range(t0, 15, 8)] ^
            Te3[__range(t1, 7, 0)] ^ ekey[58];
        s3 = Te0[__range(t3, 31, 24)] ^ Te1[__range(t0, 23, 16)] ^ Te2[__range(t1, 15, 8)] ^
            Te3[__range(t2, 7, 0)] ^ ekey[59];

        j += 8;
    }

    s0 = (Te2[__range(t0, 31, 24)] & 0xff000000) ^ (Te3[__range(t1, 23, 16)] & 0x00ff0000) ^
        (Te0[__range(t2, 15, 8)] & 0x0000ff00) ^ (Te1[__range(t3, 7, 0)] & 0x000000ff) ^
        ekey[j + 0];
    s1 = (Te2[__range(t1, 31, 24)] & 0xff000000) ^ (Te3[__range(t2, 23, 16)] & 0x00ff0000) ^
        (Te0[__range(t3, 15, 8)] & 0x0000ff00) ^ (Te1[__range(t0, 7, 0)] & 0x000000ff) ^
        ekey[j + 1];
    s2 = (Te2[__range(t2, 31, 24)] & 0xff000000) ^ (Te3[__range(t3, 23, 16)] & 0x00ff0000) ^
        (Te0[__range(t0, 15, 8)] & 0x0000ff00) ^ (Te1[__range(t1, 7, 0)] & 0x000000ff) ^
        ekey[j + 2];
    s3 = (Te2[__range(t3, 31, 24)] & 0xff000000) ^ (Te3[__range(t0, 23, 16)] & 0x00ff0000) ^
        (Te0[__range(t1, 15, 8)] & 0x0000ff00) ^ (Te1[__range(t2, 7, 0)] & 0x000000ff) ^
        ekey[j + 3];

    out[0] = s0;
    out[1] = s1;
    out[2] = s2;
    out[3] = s3;
}

#undef __range
