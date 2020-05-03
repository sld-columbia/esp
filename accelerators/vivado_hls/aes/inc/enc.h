#ifndef __ENC_H__
#define __ENC_H__

void aes_encrypt(ap_uint<8> in[BLOCK_BYTES],
                 ap_uint<8> out[BLOCK_BYTES],
                 ap_uint<32> ekey[EXP_KEY_SIZE])
{
    #pragma HLS inline
    #pragma HLS pipeline

    int i = 0, j = 0;
    ap_uint<32> s0, s1, s2, s3;
    ap_uint<32> t0, t1, t2, t3;

    GET32(s0, in +  0) ^ ekey[0];
    GET32(s1, in +  4) ^ ekey[1];
    GET32(s2, in +  8) ^ ekey[2];
    GET32(s3, in + 12) ^ ekey[3];

    for (i = 0; i < 5; i += 1)
    {
        #pragma HLS unroll complete

        t0 = Te0[s0.range(31, 24)] ^
             Te1[s1.range(23, 16)] ^
             Te2[s2.range(15,  8)] ^
             Te3[s3.range( 7,  0)] ^ ekey[j + 4];
        t1 = Te0[s1.range(31, 24)] ^
             Te1[s2.range(23, 16)] ^
             Te2[s3.range(15,  8)] ^
             Te3[s0.range( 7,  0)] ^ ekey[j + 5];
        t2 = Te0[s2.range(31, 24)] ^
             Te1[s3.range(23, 16)] ^
             Te2[s0.range(15,  8)] ^
             Te3[s1.range( 7,  0)] ^ ekey[j + 6];
        t3 = Te0[s3.range(31, 24)] ^
             Te1[s0.range(23, 16)] ^
             Te2[s1.range(15,  8)] ^
             Te3[s2.range( 7,  0)] ^ ekey[j + 7];

        s0 = Te0[t0.range(31, 24)] ^
             Te1[t1.range(23, 16)] ^
             Te2[t2.range(15,  8)] ^
             Te3[t3.range( 7,  0)] ^ ekey[j + 8];
        s1 = Te0[t1.range(31, 24)] ^
             Te1[t2.range(23, 16)] ^
             Te2[t3.range(15,  8)] ^
             Te3[t0.range( 7,  0)] ^ ekey[j + 9];
        s2 = Te0[t2.range(31, 24)] ^
             Te1[t3.range(23, 16)] ^
             Te2[t0.range(15,  8)] ^
             Te3[t1.range( 7,  0)] ^ ekey[j + 10];
        s3 = Te0[t3.range(31, 24)] ^
             Te1[t0.range(23, 16)] ^
             Te2[t1.range(15,  8)] ^
             Te3[t2.range( 7,  0)] ^ ekey[j + 11];

        j += 8;
    }

    s0 = (Te2[t0.range(31, 24)] & 0xff000000) ^
         (Te3[t1.range(23, 16)] & 0x00ff0000) ^
         (Te0[t2.range(15,  8)] & 0x0000ff00) ^
         (Te1[t3.range( 7,  0)] & 0x000000ff) ^ ekey[j + 0];
    s1 = (Te2[t1.range(31, 24)] & 0xff000000) ^
         (Te3[t2.range(23, 16)] & 0x00ff0000) ^
         (Te0[t3.range(15,  8)] & 0x0000ff00) ^
         (Te1[t0.range( 7,  0)] & 0x000000ff) ^ ekey[j + 1];
    s2 = (Te2[t2.range(31, 24)] & 0xff000000) ^
         (Te3[t3.range(23, 16)] & 0x00ff0000) ^
         (Te0[t0.range(15,  8)] & 0x0000ff00) ^
         (Te1[t1.range( 7,  0)] & 0x000000ff) ^ ekey[j + 2];
    s3 = (Te2[t3.range(31, 24)] & 0xff000000) ^
         (Te3[t0.range(23, 16)] & 0x00ff0000) ^
         (Te0[t1.range(15,  8)] & 0x0000ff00) ^
         (Te1[t2.range( 7,  0)] & 0x000000ff) ^ ekey[j + 3];

    PUT32(out +  0, s0);
    PUT32(out +  4, s1);
    PUT32(out +  8, s2);
    PUT32(out + 12, s3);
}

#endif /* __ENC_H__ */
