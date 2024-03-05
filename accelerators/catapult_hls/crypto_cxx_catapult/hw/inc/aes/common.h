#ifndef __AES_COMMON_H__
#define __AES_COMMON_H__

#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef C_SIMULATION
#ifndef __MENTOR_CATAPULT_HLS__
#include <ap_int.h>
#include <hls_stream.h>
#endif // __MENTOR_CATAPULT_HLS__
#endif // C_SIMULATION

#define BIT(x) (1 << (x))

#ifdef C_SIMULATION

#define MAX_VALUE ((uint64_t) 0xFFFFFFFF)

#define incr(block)                             \
{                                               \
    uint64_t tmp;                               \
    bool carry = 1;                             \
                                                \
    for (int k = BLOCK_WORDS - 1; k >= 0; --k)  \
    {                                           \
        tmp = block[k] + carry;                 \
        block[k] = (tmp & MAX_VALUE);           \
        carry = (tmp > MAX_VALUE);              \
        if (carry == 0) break;                  \
    }                                           \
}

#define shiftr(block)                           \
{                                               \
	uint32 prevcarry = 0x00;                  \
	uint32 currcarry = 0x00;                  \
                                                \
	for (int i = 0; i < BLOCK_WORDS; i++)       \
	{                                           \
		prevcarry = currcarry;                  \
                                                \
		if (block[i] & 0x01)                    \
			currcarry = 0x80000000;             \
		else                                    \
			currcarry = 0x00;                   \
                                                \
		block[i] >>= 0x01;                      \
		block[i] += prevcarry;                  \
	}                                           \
}

#else /* !C_SIMULATION */

#ifdef __MENTOR_CATAPULT_HLS__
#include <ac_int.h>
#define incr(block)                                \
{                                                  \
    ac_int<128, false> tmp;                        \
    tmp.set_slc(0, ac_int<32, false>(block[3]));   \
    tmp.set_slc(32, ac_int<32, false>(block[2]));  \
    tmp.set_slc(64, ac_int<32, false>(block[1]));  \
    tmp.set_slc(96, ac_int<32, false>(block[0]));  \
    tmp += 1; /* incr block */                     \
    block[3] = tmp.slc<32>(0).to_uint();           \
    block[2] = tmp.slc<32>(32).to_uint();          \
    block[1] = tmp.slc<32>(64).to_uint();          \
    block[0] = tmp.slc<32>(96).to_uint();          \
}
#else // VIVADO_HLS
#include <ap_int.h>
#define incr(block)                             \
{                                               \
    ap_uint<128> tmp;                           \
    tmp.range( 31, 0)  = block[3];              \
    tmp.range( 63, 32) = block[2];              \
    tmp.range( 95, 64) = block[1];              \
    tmp.range(127, 96) = block[0];              \
    tmp += 1; /* incr block */                  \
    block[3] = tmp.range( 31, 0);               \
    block[2] = tmp.range( 63, 32);              \
    block[1] = tmp.range( 95, 64);              \
    block[0] = tmp.range(127, 96);              \
}
#endif // __MENTOR_CATAPULT_HLS__
#endif /* C_SIMULATION */

// Disable byte swapping
//#define AES_SWAP(x) \
//    (((x) >> 24) | (((x) & 0x00FF0000) >> 8) | \
//    (((x) & 0x0000FF00) << 8) | ((x) << 24))

#define AES_SWAP(x) (x)

#define AES_WORDS(x) (((x + 3) & ~0x3) >> 2)

#endif /* __COMMON_H__ */
