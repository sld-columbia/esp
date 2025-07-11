#include "sha2.h"
#include "sha2_256.h"
#include "sha2_512.h"

#if 0
static const uint32 K256[64] = {
    0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL,
    0x3956c25bUL, 0x59f111f1UL, 0x923f82a4UL, 0xab1c5ed5UL,
    0xd807aa98UL, 0x12835b01UL, 0x243185beUL, 0x550c7dc3UL,
    0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL, 0xc19bf174UL,
    0xe49b69c1UL, 0xefbe4786UL, 0x0fc19dc6UL, 0x240ca1ccUL,
    0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL,
    0x983e5152UL, 0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL,
    0xc6e00bf3UL, 0xd5a79147UL, 0x06ca6351UL, 0x14292967UL,
    0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL, 0x53380d13UL,
    0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL,
    0xa2bfe8a1UL, 0xa81a664bUL, 0xc24b8b70UL, 0xc76c51a3UL,
    0xd192e819UL, 0xd6990624UL, 0xf40e3585UL, 0x106aa070UL,
    0x19a4c116UL, 0x1e376c08UL, 0x2748774cUL, 0x34b0bcb5UL,
    0x391c0cb3UL, 0x4ed8aa4aUL, 0x5b9cca4fUL, 0x682e6ff3UL,
    0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL,
    0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL };
#endif

#define SHA256_SHR(bits, word) ((word) >> (bits))

#define SHA256_ROTR(bits, word) (((word) >> (bits)) | ((word) << (32 - (bits))))

#define SHA256_SIGMA0(word) (SHA256_ROTR(2, word) ^ SHA256_ROTR(13, word) ^ SHA256_ROTR(22, word))

#define SHA256_SIGMA1(word) (SHA256_ROTR(6, word) ^ SHA256_ROTR(11, word) ^ SHA256_ROTR(25, word))

#define SHA256_sigma0(word) (SHA256_ROTR(7, word) ^ SHA256_ROTR(18, word) ^ SHA256_SHR(3, word))

#define SHA256_sigma1(word) (SHA256_ROTR(17, word) ^ SHA256_ROTR(19, word) ^ SHA256_SHR(10, word))

#define SHA256_Maj(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA256_Ch(x, y, z) (((x) & (y)) ^ ((~(x)) & (z)))

// Disable byte swapping
//#define SHA256_SWAP(x) \
//    (((x) >> 24) | (((x) & 0x00FF0000) >> 8) | \
//    (((x) & 0x0000FF00) << 8) | ((x) << 24))

#define SHA256_SWAP(x) (x)

#define SHA256_WORDS(x) (((x + 3) & ~0x3) >> 2)

void sha256_init(uint32 h[SHA256_HBLOCK_WORDS], uint32 out_bytes)
{
    if (out_bytes == SHA224_DIGEST_LENGTH) {
        h[0] = 0xc1059ed8UL;
        h[1] = 0x367cd507UL;
        h[2] = 0x3070dd17UL;
        h[3] = 0xf70e5939UL;
        h[4] = 0xffc00b31UL;
        h[5] = 0x68581511UL;
        h[6] = 0x64f98fa7UL;
        h[7] = 0xbefa4fa4UL;
    }
    else if (out_bytes == SHA256_DIGEST_LENGTH) {
        h[0] = 0x6a09e667UL;
        h[1] = 0xbb67ae85UL;
        h[2] = 0x3c6ef372UL;
        h[3] = 0xa54ff53aUL;
        h[4] = 0x510e527fUL;
        h[5] = 0x9b05688cUL;
        h[6] = 0x1f83d9abUL;
        h[7] = 0x5be0cd19UL;
    }
}

void sha256_load(uint32 data[SHA256_CBLOCK_WORDS], uint32 in[SHA2_MAX_BLOCK_SIZE])
{
#pragma HLS inline off

    /* memcpy(data, in, SHA256_CBLOCK_BYTES); */

SHA256_L_1_1:
    for (unsigned i = 0; i < SHA256_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = in[i];
    }

SHA256_L_1_2:
    for (unsigned i = 0; i < SHA256_CBLOCK_WORDS; ++i) {
#pragma HLS unroll complete

        data[i] = SHA256_SWAP(data[i]);
    }
}

void sha256_block(uint32 h[SHA256_HBLOCK_WORDS], uint32 X[SHA256_CBLOCK_WORDS])
{
    uint32 tmp[8];
    uint32 s0, s1, T1, T2;

    uint32 K256[64] = {
        0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL, 0x3956c25bUL, 0x59f111f1UL,
        0x923f82a4UL, 0xab1c5ed5UL, 0xd807aa98UL, 0x12835b01UL, 0x243185beUL, 0x550c7dc3UL,
        0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL, 0xc19bf174UL, 0xe49b69c1UL, 0xefbe4786UL,
        0x0fc19dc6UL, 0x240ca1ccUL, 0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL,
        0x983e5152UL, 0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL, 0xc6e00bf3UL, 0xd5a79147UL,
        0x06ca6351UL, 0x14292967UL, 0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL, 0x53380d13UL,
        0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL, 0xa2bfe8a1UL, 0xa81a664bUL,
        0xc24b8b70UL, 0xc76c51a3UL, 0xd192e819UL, 0xd6990624UL, 0xf40e3585UL, 0x106aa070UL,
        0x19a4c116UL, 0x1e376c08UL, 0x2748774cUL, 0x34b0bcb5UL, 0x391c0cb3UL, 0x4ed8aa4aUL,
        0x5b9cca4fUL, 0x682e6ff3UL, 0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL,
        0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL};

#pragma HLS array_partition variable = tmp complete
#pragma HLS resource variable = K256 core = ROM_nP_BRAM

SHA256_BLOCK_L_1:
    for (unsigned t = 0; t < 8; ++t) {
#pragma HLS unroll complete

        tmp[t] = h[t];
    }

SHA256_BLOCK_L_2:
    for (unsigned i = 0; i < 16; i++) {
#pragma HLS unroll complete

        T1 = X[i] + tmp[7] + SHA256_SIGMA1(tmp[4]) + SHA256_Ch(tmp[4], tmp[5], tmp[6]) + K256[i];

        T2 = SHA256_SIGMA0(tmp[0]) + SHA256_Maj(tmp[0], tmp[1], tmp[2]);

SHA256_BLOCK_L_2_1:
        for (unsigned t = 7; t >= 1; --t) {
#pragma HLS unroll complete
            tmp[t] = tmp[t - 1];
        }

        tmp[0] = T1 + T2;
        tmp[4] += T1;
    }

SHA256_BLOCK_L_3:
    for (unsigned i = 16; i < 64; i++) {
#pragma HLS unroll complete

        s0 = X[((i + 1) & 0x0f)];
        s0 = SHA256_sigma0(s0);

        s1 = X[((i + 14) & 0x0f)];
        s1 = SHA256_sigma1(s1);

        X[(i & 0xf)] += s0 + s1 + X[((i + 9) & 0xf)];

        T1 = X[(i & 0xf)] + tmp[7] + SHA256_SIGMA1(tmp[4]) + SHA256_Ch(tmp[4], tmp[5], tmp[6]) +
            K256[i];

        T2 = SHA256_SIGMA0(tmp[0]) + SHA256_Maj(tmp[0], tmp[1], tmp[2]);

SHA256_BLOCK_L_3_1:
        for (unsigned t = 7; t >= 1; --t) {
#pragma HLS unroll complete

            tmp[t] = tmp[t - 1];
        }

        tmp[0] = T1 + T2;
        tmp[4] += T1;
    }

SHA256_BLOCK_L_4:
    for (unsigned t = 0; t < 8; ++t) {
#pragma HLS unroll complete

        h[t] += tmp[t];
    }
}

void sha256_process(uint32 h[SHA256_HBLOCK_WORDS], uint32 data[SHA256_CBLOCK_WORDS],
                    uint32 in[SHA2_MAX_BLOCK_SIZE], uint32 blocks)
{
#pragma HLS inline

SHA256_L_1:
    for (unsigned t = 0; t < blocks; t += SHA256_CBLOCK_BYTES) {
/* Considering an input of 65536 bytes. */
#pragma HLS loop_tripcount min = 1 max = 1024
#pragma HLS pipeline II                = 50 rewind

        sha256_load(data, &(in[t >> 2]));
        sha256_block(h, data);
    }
}

static const uint64_t K512[80] = {
    0x428a2f98d728ae22ULL, 0x7137449123ef65cdULL, 0xb5c0fbcfec4d3b2fULL, 0xe9b5dba58189dbbcULL,
    0x3956c25bf348b538ULL, 0x59f111f1b605d019ULL, 0x923f82a4af194f9bULL, 0xab1c5ed5da6d8118ULL,
    0xd807aa98a3030242ULL, 0x12835b0145706fbeULL, 0x243185be4ee4b28cULL, 0x550c7dc3d5ffb4e2ULL,
    0x72be5d74f27b896fULL, 0x80deb1fe3b1696b1ULL, 0x9bdc06a725c71235ULL, 0xc19bf174cf692694ULL,
    0xe49b69c19ef14ad2ULL, 0xefbe4786384f25e3ULL, 0x0fc19dc68b8cd5b5ULL, 0x240ca1cc77ac9c65ULL,
    0x2de92c6f592b0275ULL, 0x4a7484aa6ea6e483ULL, 0x5cb0a9dcbd41fbd4ULL, 0x76f988da831153b5ULL,
    0x983e5152ee66dfabULL, 0xa831c66d2db43210ULL, 0xb00327c898fb213fULL, 0xbf597fc7beef0ee4ULL,
    0xc6e00bf33da88fc2ULL, 0xd5a79147930aa725ULL, 0x06ca6351e003826fULL, 0x142929670a0e6e70ULL,
    0x27b70a8546d22ffcULL, 0x2e1b21385c26c926ULL, 0x4d2c6dfc5ac42aedULL, 0x53380d139d95b3dfULL,
    0x650a73548baf63deULL, 0x766a0abb3c77b2a8ULL, 0x81c2c92e47edaee6ULL, 0x92722c851482353bULL,
    0xa2bfe8a14cf10364ULL, 0xa81a664bbc423001ULL, 0xc24b8b70d0f89791ULL, 0xc76c51a30654be30ULL,
    0xd192e819d6ef5218ULL, 0xd69906245565a910ULL, 0xf40e35855771202aULL, 0x106aa07032bbd1b8ULL,
    0x19a4c116b8d2d0c8ULL, 0x1e376c085141ab53ULL, 0x2748774cdf8eeb99ULL, 0x34b0bcb5e19b48a8ULL,
    0x391c0cb3c5c95a63ULL, 0x4ed8aa4ae3418acbULL, 0x5b9cca4f7763e373ULL, 0x682e6ff3d6b2b8a3ULL,
    0x748f82ee5defb2fcULL, 0x78a5636f43172f60ULL, 0x84c87814a1f0ab72ULL, 0x8cc702081a6439ecULL,
    0x90befffa23631e28ULL, 0xa4506cebde82bde9ULL, 0xbef9a3f7b2c67915ULL, 0xc67178f2e372532bULL,
    0xca273eceea26619cULL, 0xd186b8c721c0c207ULL, 0xeada7dd6cde0eb1eULL, 0xf57d4f7fee6ed178ULL,
    0x06f067aa72176fbaULL, 0x0a637dc5a2c898a6ULL, 0x113f9804bef90daeULL, 0x1b710b35131c471bULL,
    0x28db77f523047d84ULL, 0x32caab7b40c72493ULL, 0x3c9ebe0a15c9bebcULL, 0x431d67c49c100d4cULL,
    0x4cc5d4becb3e42b6ULL, 0x597f299cfc657e2aULL, 0x5fcb6fab3ad6faecULL, 0x6c44198c4a475817ULL};

#define SHA512_SHR(bits, word) (((uint64_t)(word)) >> (bits))

#define SHA512_ROTR(bits, word) \
    ((((uint64_t)(word)) >> (bits)) | (((uint64_t)(word)) << (64 - (bits))))

#define SHA512_SIGMA0(word) (SHA512_ROTR(28, word) ^ SHA512_ROTR(34, word) ^ SHA512_ROTR(39, word))

#define SHA512_SIGMA1(word) (SHA512_ROTR(14, word) ^ SHA512_ROTR(18, word) ^ SHA512_ROTR(41, word))

#define SHA512_sigma0(word) (SHA512_ROTR(1, word) ^ SHA512_ROTR(8, word) ^ SHA512_SHR(7, word))

#define SHA512_sigma1(word) (SHA512_ROTR(19, word) ^ SHA512_ROTR(61, word) ^ SHA512_SHR(6, word))

#define SHA512_Maj(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA512_Ch(x, y, z) (((x) & (y)) ^ ((~(x)) & (z)))

// Disable byte swapping
//#define SHA512_SWAP(x) \
//    (((x) >> 24) | (((x) & 0x00FF0000) >> 8) | \
//    (((x) & 0x0000FF00) << 8) | ((x) << 24))

#define SHA512_SWAP(x) (x)

#define SHA512_WORDS(x) (((x + 3) & ~0x3) >> 2)

void sha512_init(uint64_t h[SHA512_HBLOCK_WORDS], uint32 out_bytes)
{
    if (out_bytes == SHA384_DIGEST_LENGTH) {
        h[0] = 0xcbbb9d5dc1059ed8ULL;
        h[1] = 0x629a292a367cd507ULL;
        h[2] = 0x9159015a3070dd17ULL;
        h[3] = 0x152fecd8f70e5939ULL;
        h[4] = 0x67332667ffc00b31ULL;
        h[5] = 0x8eb44a8768581511ULL;
        h[6] = 0xdb0c2e0d64f98fa7ULL;
        h[7] = 0x47b5481dbefa4fa4ULL;
    }
    else if (out_bytes == SHA512_DIGEST_LENGTH) {
        h[0] = 0x6a09e667f3bcc908ULL;
        h[1] = 0xbb67ae8584caa73bULL;
        h[2] = 0x3c6ef372fe94f82bULL;
        h[3] = 0xa54ff53a5f1d36f1ULL;
        h[4] = 0x510e527fade682d1ULL;
        h[5] = 0x9b05688c2b3e6c1fULL;
        h[6] = 0x1f83d9abfb41bd6bULL;
        h[7] = 0x5be0cd19137e2179ULL;
    }
}

void sha512_load(uint32 data[SHA512_CBLOCK_WORDS], uint32 in[SHA2_MAX_BLOCK_SIZE])
{
#pragma HLS inline off

    /* memcpy(data, in, SHA512_CBLOCK_BYTES); */

SHA512_L_1_1:
    for (unsigned k = 0; k < SHA512_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = in[k];
    }

SHA512_L_1_2:
    for (unsigned k = 0; k < SHA512_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = SHA512_SWAP(data[k]);
    }
}

void sha512_block(uint64_t h[SHA512_HBLOCK_WORDS], uint32 T[SHA512_CBLOCK_WORDS])
{
    uint64_t A, E;
    uint64_t T1, T2;
    uint64_t X[9 + 80];

    A = h[0];
    E = h[4];

#pragma HLS resource variable = K512 core = ROM_nP_BRAM
#pragma HLS resource variable = X core = RAM_2P_BRAM

SHA512_BLOCK_L_1:
    for (unsigned t = 1; t < 8; ++t) {
#pragma HLS unroll complete

        X[80 + t] = h[t];
    }

SHA512_BLOCK_L_2:
    for (unsigned i = 0; i < 16; i++) {
#pragma HLS unroll complete

        T1 = (((uint64_t)T[(i << 1) + 0]) << 32) | (((uint64_t)T[(i << 1) + 1]) << 0);

        X[80 - i] = A;
        X[84 - i] = E;
        X[88 - i] = T1;

        T1 += X[87 - i] + SHA512_SIGMA1(E) + SHA512_Ch(E, X[85 - i], X[86 - i]) + K512[i];

        A = T1 + SHA512_SIGMA0(A) + SHA512_Maj(A, X[81 - i], X[82 - i]);
        E = T1 + X[83 - i];
    }

SHA512_BLOCK_L_3:
    for (unsigned i = 0; i < 64; i++) {
#pragma HLS unroll complete

        T2 = SHA512_sigma0(X[87 - i]);
        T2 += SHA512_sigma1(X[74 - i]);
        T2 += X[88 - i] + X[79 - i];

        X[64 - i] = A;
        X[68 - i] = E;
        X[72 - i] = T2;

        T2 += X[71 - i] + SHA512_SIGMA1(E) + SHA512_Ch(E, X[69 - i], X[70 - i]) + K512[i + 16];

        A = T2 + SHA512_SIGMA0(A) + SHA512_Maj(A, X[65 - i], X[66 - i]);
        E = T2 + X[67 - i];
    }

    h[1] += X[1];
    h[2] += X[2];
    h[3] += X[3];
    h[5] += X[5];
    h[6] += X[6];
    h[7] += X[7];
    h[0] += A;
    h[4] += E;
}

void sha512_process(uint64_t h[SHA512_HBLOCK_WORDS], uint32 data[SHA512_CBLOCK_WORDS],
                    uint32 in[SHA2_MAX_BLOCK_SIZE], uint32 blocks)
{
#pragma HLS inline

SHA512_L_1:
    for (unsigned t = 0; t < blocks; t += SHA512_CBLOCK_BYTES) {
/* Considering an input of 65536 bytes. */
#pragma HLS loop_tripcount min = 1 max = 1024
#pragma HLS pipeline II                = 83 rewind

        sha512_load(data, &(in[t >> 2]));
        sha512_block(h, data);
    }
}

void sha512(uint32 in_bytes, uint32 out_bytes, uint32 in[SHA2_MAX_BLOCK_SIZE],
            uint32 out[SHA2_MAX_DIGEST_WORDS])
{
    uint32 bytes;
    uint32 blocks;
    uint64_t h[SHA512_HBLOCK_WORDS];
    uint32 data[SHA512_CBLOCK_WORDS];
    uint64_t Nl = ((uint64_t)in_bytes << 3);
    uint64_t Nh = ((uint64_t)in_bytes >> 61);

#pragma HLS array_partition variable = h complete
#pragma HLS array_partition variable = data complete

    sha512_init(h, out_bytes);

    blocks = in_bytes & SHA512_CBLOCK_BYTES_MASK;
    bytes  = in_bytes - blocks;

    /* sha512_update(); */

    sha512_process(h, data, in, blocks);

SHA512_L_2:
    for (unsigned k = 0; k < SHA512_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = 0;
    }

SHA512_L_3:
    for (unsigned k = 0; k < SHA512_WORDS(bytes); ++k) {
#pragma HLS loop_tripcount min = 1 max = 32
#pragma HLS pipeline II                = 1

        data[k] = in[(blocks >> 2) + k];
    }

SHA512_L_4:
    for (unsigned k = 0; k < SHA512_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = SHA512_SWAP(data[k]);
    }

    /* sha512_final(); */

    data[bytes >> 2] |= (0x80U << (24 - ((bytes & 0x03) << 3)));

    if (++bytes > (SHA512_CBLOCK_BYTES - 16)) {
        sha512_block(h, data);
        data[0] = 0;
        bytes   = 0;
    }

SHA512_L_5:
    for (unsigned k = bytes + 1; k < SHA512_CBLOCK_WORDS - 4; ++k) {
#pragma HLS loop_tripcount min = 1 max = 27
#pragma HLS unroll factor              = 27

        data[k] = 0;
    }

    data[SHA512_CBLOCK_WORDS - 4] = (Nh >> 32);
    data[SHA512_CBLOCK_WORDS - 3] = (Nh >> 0);
    data[SHA512_CBLOCK_WORDS - 2] = (Nl >> 32);
    data[SHA512_CBLOCK_WORDS - 1] = (Nl >> 0);
    sha512_block(h, data);

SHA512_L_6:
    for (unsigned k = 0; k < SHA512_HBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        uint32 tmp0 = h[k] >> 32;
        uint32 tmp1 = h[k] >> 0;

        tmp0 = SHA512_SWAP(tmp0);
        tmp1 = SHA512_SWAP(tmp1);

        h[k] = ((uint64_t)tmp0 << 32) | tmp1;
    }

    /* memcpy(out, h, out_bytes); */

SHA512_L_7:
    for (unsigned k = 0; k<out_bytes> > 2; k += 2) {
#pragma HLS loop_tripcount min = 7 max = 8
#pragma HLS pipeline II                = 2

        out[k + 0] = h[k >> 1] >> 32;
        out[k + 1] = h[k >> 1] >> 0;
    }
}

void sha256(uint32 in_bytes, uint32 out_bytes, uint32 in[SHA2_MAX_BLOCK_SIZE],
            uint32 out[SHA2_MAX_DIGEST_WORDS])
{
    uint32 bytes;
    uint32 blocks;
    uint32 h[SHA256_HBLOCK_WORDS];
    uint32 data[SHA256_CBLOCK_WORDS];

#pragma HLS array_partition variable = h complete
#pragma HLS array_partition variable = data complete

    sha256_init(h, out_bytes);

    blocks = in_bytes & SHA256_CBLOCK_BYTES_MASK;
    bytes  = in_bytes - blocks;

    /* sha256_update(); */

    sha256_process(h, data, in, blocks);

SHA256_L_2:
    for (unsigned k = 0; k < SHA256_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = 0;
    }

SHA256_L_3:
    for (unsigned k = 0; k < SHA256_WORDS(bytes); ++k) {
#pragma HLS loop_tripcount min = 1 max = 16
#pragma HLS pipeline II                = 1

        data[k] = in[(blocks >> 2) + k];
    }

SHA256_L_4:
    for (unsigned k = 0; k < SHA256_CBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        data[k] = SHA256_SWAP(data[k]);
    }

    /* sha256_final(); */

    data[bytes >> 2] |= (0x80U << (24 - ((bytes & 0x03) << 3)));

    if (++bytes > (SHA256_CBLOCK_BYTES - 8)) {
        sha256_block(h, data);
        data[0] = 0;
        bytes   = 0;
    }

SHA256_L_5:
    for (unsigned k = bytes + 1; k < SHA256_CBLOCK_WORDS - 2; ++k) {
#pragma HLS loop_tripcount min = 1 max = 13
#pragma HLS unroll factor              = 13

        data[k] = 0;
    }

    data[SHA256_CBLOCK_WORDS - 2] = (in_bytes >> 29);
    data[SHA256_CBLOCK_WORDS - 1] = (in_bytes << 3);
    sha256_block(h, data);

SHA256_L_6:
    for (unsigned k = 0; k < SHA256_HBLOCK_WORDS; ++k) {
#pragma HLS unroll complete

        h[k] = SHA256_SWAP(h[k]);
    }

    /* memcpy(out, h, out_bytes); */

SHA256_L_7:
    for (unsigned k = 0; k<out_bytes> > 2; ++k) {
#pragma HLS loop_tripcount min = 7 max = 8
#pragma HLS pipeline II                = 1
        out[k] = h[k];
    }
}

int sha2(uint32 in_bytes, uint32 out_bytes, uint32 in[SHA2_MAX_BLOCK_SIZE],
         uint32 out[SHA2_MAX_DIGEST_WORDS])
{
#pragma HLS INTERFACE s_axilite port = return
#pragma HLS INTERFACE s_axilite port = in_bytes
#pragma HLS INTERFACE s_axilite port = out_bytes
#pragma HLS INTERFACE m_axi depth = sha2_max_addr_mem port = in offset = slave latency = 64
#pragma HLS INTERFACE m_axi depth = sha2_max_addr_mem port = out offset = slave latency = 64

    int ret = 0;

    switch (out_bytes) {
#ifdef SYN_SHA256
        case SHA224_DIGEST_LENGTH:
        case SHA256_DIGEST_LENGTH: sha256(in_bytes, out_bytes, in, out); break;
#endif // SYN_SHA256

#ifdef SYN_SHA512
        case SHA384_DIGEST_LENGTH:
        case SHA512_DIGEST_LENGTH: sha512(in_bytes, out_bytes, in, out); break;
#endif // SYN_SHA512
    }

    return ret;
}
