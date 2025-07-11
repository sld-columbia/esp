#include "sha1.h"

#define ROTATE1(V)  ((V << 1) | (V >> 31))
#define ROTATE5(V)  ((V << 5) | (V >> 27))
#define ROTATE30(V) ((V << 30) | (V >> 2))

#define Xupdate(a, ix, ia, ib, ic, id) a = (ia ^ ib ^ ic ^ id), ix = (a) = ROTATE1((a))

#define BODY_00_15(xi)                          \
    T = E + 0x5a827999UL + (((C ^ D) & B) ^ D); \
    E = D, D = C, C = ROTATE30(B), B = A;       \
    A = ROTATE5(A) + T + xi;

#define BODY_16_19(xa, xb, xc, xd)               \
    Xupdate(T, xa, xa, xb, xc, xd);              \
    T += E + 0x5a827999UL + (((C ^ D) & B) ^ D); \
    E = D, D = C, C = ROTATE30(B), B = A;        \
    A = ROTATE5(A) + T;

#define BODY_20_39(xa, xb, xc, xd)        \
    Xupdate(T, xa, xa, xb, xc, xd);       \
    T += E + 0x6ed9eba1UL + (B ^ C ^ D);  \
    E = D, D = C, C = ROTATE30(B), B = A; \
    A = ROTATE5(A) + T;

#define BODY_40_59(xa, xb, xc, xd)                     \
    Xupdate(T, xa, xa, xb, xc, xd);                    \
    T += E + 0x8f1bbcdcUL + ((B & C) | ((B | C) & D)); \
    E = D, D = C, C = ROTATE30(B), B = A;              \
    A = ROTATE5(A) + T;

#define BODY_60_79(xa, xb, xc, xd)        \
    Xupdate(T, xa, xa, xb, xc, xd);       \
    T = E + 0xca62c1d6UL + (B ^ C ^ D);   \
    E = D, D = C, C = ROTATE30(B), B = A; \
    A = ROTATE5(A) + T + xa;

// Disable byte swapping
//#define SHA1_SWAP(x) \
//    (((x) >> 24) | (((x) & 0x00FF0000) >> 8) | \
//    (((x) & 0x0000FF00) << 8) | ((x) << 24))

#define SHA1_SWAP(x) (x)

#define SHA1_WORDS(x) (((x + 3) & ~0x3) >> 2)

void sha1_init(uint32 h[SHA1_HBLOCK_WORDS])
{
    h[0] = 0x67452301UL;
    h[1] = 0xefcdab89UL;
    h[2] = 0x98badcfeUL;
    h[3] = 0x10325476UL;
    h[4] = 0xc3d2e1f0UL;
}

void sha1_load(uint32 data[SHA1_CBLOCK_WORDS], uint32 in[SHA1_MAX_BLOCK_SIZE])
{
#pragma HLS inline off

    /* memcpy(data, in, SHA1_CBLOCK_BYTES); */

SHA1_L_1_1:
    for (unsigned i = 0; i < SHA1_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = in[i];
    }

SHA1_L_1_2:
    for (unsigned i = 0; i < SHA1_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = SHA1_SWAP(data[i]);
    }
}

void sha1_block(uint32 h[SHA1_HBLOCK_WORDS], uint32 X[SHA1_CBLOCK_WORDS])
{
    uint32 T;
    uint32 A = h[0];
    uint32 B = h[1];
    uint32 C = h[2];
    uint32 D = h[3];
    uint32 E = h[4];

#pragma HLS inline off
#pragma HLS loop_merge
#pragma HLS loop_flatten

SHA1_BLOCK_L_1:
    for (unsigned i = 0; i < 16; i++) {
#pragma HLS unroll complete

        BODY_00_15(X[i]);
    }

SHA1_BLOCK_L_2:
    for (unsigned i = 0; i < 4; i++) {
#pragma HLS unroll complete

        BODY_16_19(X[i], X[i + 2], X[i + 8], X[((i + 13) & 15)]);
    }

SHA1_BLOCK_L_3:
    for (unsigned i = 4; i < 24; i++) {
#pragma HLS unroll complete

        BODY_20_39(X[(i & 15)], X[((i + 2) & 15)], X[((i + 8) & 15)], X[((i + 13) & 15)]);
    }

SHA1_BLOCK_L_4:
    for (unsigned i = 0; i < 20; i++) {
#pragma HLS unroll complete

        BODY_40_59(X[((i + 8) & 15)], X[((i + 10) & 15)], X[(i & 15)], X[((i + 5) & 15)]);
    }

SHA1_BLOCK_L_5:
    for (unsigned i = 4; i < 24; i++) {
#pragma HLS unroll complete

        BODY_60_79(X[((i + 8) & 15)], X[((i + 10) & 15)], X[(i & 15)], X[((i + 5) & 15)]);
    }

    h[0] += A;
    h[1] += B;
    h[2] += C;
    h[3] += D;
    h[4] += E;
}

void sha1_process(uint32 h[SHA1_HBLOCK_WORDS], uint32 data[SHA1_CBLOCK_WORDS],
                  uint32 in[SHA1_MAX_BLOCK_SIZE], uint32 blocks)
{
#pragma HLS inline

SHA1_L_1:
    for (unsigned t = 0; t < blocks; t += SHA1_CBLOCK_BYTES) {
/* Considering an input of 65536 bytes. */
#pragma HLS loop_tripcount min = 1 max = 1024
#pragma HLS pipeline II                = 17 rewind

        sha1_load(data, &(in[t >> 2]));
        sha1_block(h, data);
    }
}

int sha1(uint32 in_bytes, uint32 in[SHA1_MAX_BLOCK_SIZE], uint32 out[SHA1_DIGEST_WORDS])
{
#pragma HLS INTERFACE s_axilite port = return
#pragma HLS INTERFACE s_axilite port = in_bytes
#pragma HLS INTERFACE m_axi depth = sha1_max_addr_mem port = in offset = slave
#pragma HLS INTERFACE m_axi depth = sha1_max_addr_mem port = out offset = slave

    uint32 bytes;
    uint32 blocks;
    uint32 h[SHA1_HBLOCK_WORDS];
    uint32 data[SHA1_CBLOCK_WORDS];
    int ret = 0;

#pragma HLS array_partition variable = h complete
#pragma HLS array_partition variable = data complete

    sha1_init(h);

    blocks = in_bytes & SHA1_CBLOCK_BYTES_MASK;
    bytes  = in_bytes - blocks;

    /* sha1_update(); */

    sha1_process(h, data, in, blocks);

SHA1_L_1_3:
    for (unsigned i = 0; i < SHA1_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = 0;
    }

SHA1_L_1_4:
    for (unsigned i = 0; i < SHA1_WORDS(bytes); ++i) {
#pragma HLS loop_tripcount min = 1 max = 16
#pragma HLS pipeline II                = 1

        data[i] = in[(blocks >> 2) + i];
    }

SHA1_L_1_5:
    for (unsigned i = 0; i < SHA1_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = SHA1_SWAP(data[i]);
    }

    /* sha1_final(); */

    data[bytes >> 2] |= (0x80U << (24 - ((bytes & 0x03) << 3)));

    if (++bytes > (SHA1_CBLOCK_BYTES - 8)) {
        sha1_block(h, data);
        data[0] = 0;
        bytes   = 0;
    }

SHA1_L_1_6:
    for (unsigned k = bytes + 1; k < SHA1_CBLOCK_WORDS - 2; ++k) {
#pragma HLS loop_tripcount min = 1 max = 13
#pragma HLS unroll factor              = 13

        data[k] = 0;
    }

    data[SHA1_CBLOCK_WORDS - 2] = (in_bytes >> 29);
    data[SHA1_CBLOCK_WORDS - 1] = (in_bytes << 3);
    sha1_block(h, data);

SHA1_L_1_7:
    for (unsigned k = 0; k<SHA1_DIGEST_LENGTH> > 2; ++k) {
#pragma HLS unroll complete

        h[k] = SHA1_SWAP(h[k]);
    }

SHA1_L_1_8:
    for (unsigned k = 0; k<SHA1_DIGEST_LENGTH> > 2; ++k) {
#pragma HLS pipeline II = 1

        out[k] = h[k];
    }

    return ret;
}
