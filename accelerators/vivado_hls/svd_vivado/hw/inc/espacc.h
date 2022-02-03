#ifndef INC_ESPACC_H
#define INC_ESPACC_H

#include "../inc/espacc_config.h"
#include <cstdio>

#include <ap_fixed.h>
#include <ap_int.h>
#include "hls_linear_algebra.h"
using namespace hls;

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

// Data types and constants
#define VALUES_PER_WORD (DMA_SIZE / DATA_BITWIDTH) // = 2
#if (VALUES_PER_WORD == 2)
#define LOG_VALUES_PER_WORD 1
#else
#define LOG_VALUES_PER_WORD 0
#endif
#if ((SIZE_IN_CHUNK_DATA % VALUES_PER_WORD) == 0)
#define SIZE_IN_CHUNK (SIZE_IN_CHUNK_DATA / VALUES_PER_WORD)
#else
#define SIZE_IN_CHUNK (SIZE_IN_CHUNK_DATA / VALUES_PER_WORD + 1)
#endif
#if ((SIZE_OUT_CHUNK_DATA % VALUES_PER_WORD) == 0)
#define SIZE_OUT_CHUNK (SIZE_OUT_CHUNK_DATA / VALUES_PER_WORD)
#else
#define SIZE_OUT_CHUNK (SIZE_OUT_CHUNK_DATA / VALUES_PER_WORD + 1)
#endif

// data word
#if (IS_TYPE_FIXED_POINT ==  1)
typedef ap_fixed<DATA_BITWIDTH,DATA_BITWIDTH-FRAC_BITS> word_t;
#elif (IS_TYPE_UINT == 1)
typedef ap_uint<DATA_BITWIDTH> word_t;
#elif (IS_TYPE_INT == 1)
typedef ap_int<DATA_BITWIDTH> word_t;
#elif (IS_TYPE_FLOAT == 1)
typedef float word_t;
#endif

#if (IS_TYPE_OUT_FIXED_POINT == 1)
typedef ap_fixed<DATA_BITWIDTH,DATA_BITWIDTH-FRAC_BITS> word_out_t;
#endif

typedef ap_fixed<DATA_BITWIDTH,DATA_BITWIDTH-FRAC_BITS> word_fixed_t;

typedef struct dma_word {
    word_t word[VALUES_PER_WORD];
} dma_word_t;

typedef word_t in_data_word;
typedef word_t out_data_word;

// Ctrl
typedef struct dma_info {
    ap_uint<32> index;
    ap_uint<32> length;
    ap_uint<32> size;
} dma_info_t;

// The 'size' variable of 'dma_info' indicates the bit-width of the words
// processed by the accelerator. Here are the encodings:
#define SIZE_BYTE   0
#define SIZE_HWORD  1
#define SIZE_WORD   2
#define SIZE_DWORD  3

#if (DATA_BITWIDTH == 8)
#define SIZE_WORD_T SIZE_BYTE
#elif (DATA_BITWIDTH == 16)
#define SIZE_WORD_T SIZE_HWORD
#elif (DATA_BITWIDTH == 32)
#define SIZE_WORD_T SIZE_WORD
#else // if (DATA_BITWIDTH == 64)
#define SIZE_WORD_T SIZE_DWORD
#endif

#define P_MAX 240 //230, 232, 240, 256
#define Q_MAX 180
#define M_MAX 3

void top(dma_word_t *out, dma_word_t *in1,
	/* <<--params-->> */
	 const unsigned conf_info_q,
	 const unsigned conf_info_p,
	 const unsigned conf_info_m,
	 const unsigned conf_info_p2p_out,
	 const unsigned conf_info_p2p_in,
	 const unsigned conf_info_p2p_iter,
	 const unsigned conf_info_load_state,
	 dma_info_t &load_ctrl, dma_info_t &store_ctrl);

void compute(word_t Q[P_MAX][Q_MAX], word_t X[P_MAX][M_MAX],
	word_t Y[Q_MAX][M_MAX], word_t T[M_MAX][M_MAX], word_t &P,
	const unsigned q,
	const unsigned p,
	const unsigned m,
	const unsigned p2p_out,
	const unsigned load_state,
	unsigned &b,
	const unsigned p2p_iter,
	word_t _outbuff[SIZE_OUT_CHUNK_DATA]);

void load(word_t Q[P_MAX][Q_MAX], word_t X[P_MAX][M_MAX],
	word_t Y[Q_MAX][M_MAX], word_t T[M_MAX][M_MAX], word_t &P, dma_word_t *in1,
	const unsigned q,
	const unsigned p,
	const unsigned m,
	const unsigned p2p_in,
	const unsigned b,
	const unsigned load_state,
	dma_info_t &load_ctrl);

void store(word_t _outbuff[SIZE_OUT_CHUNK_DATA], dma_word_t *out,
	const unsigned q,
	const unsigned p,
	const unsigned m,
	const unsigned p2p_out,
	const unsigned b,
	const unsigned load_state,
	dma_info_t &store_ctrl);

struct TRAITS_SVD:
	hls::svd_traits<M_MAX, M_MAX, float, float>{
	static const int NUM_SWEEPS = 6;
	static const int OFF_DIAG_II = 20;
	static const int DIAG_II = 32;
	static const int ALLOCATION = 1;
};

struct TRAITS_C:
hls::matrix_multiply_traits<hls::Transpose,hls::Transpose,Q_MAX,M_MAX,P_MAX,Q_MAX,word_t, word_t>{
	static const int ARCH = 2;
	//static const int INNER_II = 3;
	static const int UNROLL_FACTOR = 16;
};

struct TRAITS_A:
hls::matrix_multiply_traits<hls::NoTranspose,hls::NoTranspose,M_MAX,P_MAX,P_MAX,M_MAX,word_t, word_t>{
	static const int ARCH = 2;
	//static const int INNER_II = 9;
	//static const int UNROLL_FACTOR = 3;
};

struct TRAITS_A_F:
hls::matrix_multiply_traits<hls::NoTranspose,hls::ConjugateTranspose,M_MAX,M_MAX,M_MAX,M_MAX,float, float>{
	static const int ARCH = 3;
	//static const int INNER_II = 9;
	//static const int UNROLL_FACTOR = 3; Possible
};

struct TRAITS_X_SINK:
hls::matrix_multiply_traits<hls::NoTranspose,hls::Transpose,M_MAX,M_MAX,P_MAX,M_MAX,word_t, word_t>{
	static const int ARCH = 2;
	//static const int INNER_II = 16;
	//static const int UNROLL_FACTOR = 3;
};

#endif
