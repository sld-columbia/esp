#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

/* User defined */

// Define data type (decomment the one needed)
// #define __UINT
// #define __INT
#define __FIXED
// #define __FLOAT

// Define bit width (decomment the one needed)
#ifndef __riscv
#define BITWIDTH 32
// #define BITWIDTH 64
#else
// #define BITWIDTH 32
#define BITWIDTH 64
#endif

/* End of user defined */

#ifdef __UINT
#if (BITWIDTH == 32)
typedef unsigned token_t;
#elif (BITWIDTH == 64)
typedef long long unsigned token_t;
#endif
#endif

#ifdef __INT
#if (BITWIDTH == 32)
typedef int token_t;
#elif (BITWIDTH == 64)
typedef long long token_t;
#endif
#endif

#ifdef __FIXED
#if (BITWIDTH == 32)
typedef int token_t;
#define fx2float fixed32_to_double
#define float2fx double_to_fixed32
#define FX_IL 16
#elif (BITWIDTH == 64)
typedef long long token_t;
#define fx2float fixed64_to_double
#define float2fx double_to_fixed64
#define FX_IL 32
#endif
#endif

#ifdef __FLOAT
#if (BITWIDTH == 32)
typedef float token_t;
#elif (BITWIDTH == 64)
typedef double token_t;
#endif
#endif

typedef double native_t;

#define MAX_PRINTED_ERRORS 10

/* <<--params-def-->> */
#define DO_RELU 0
#define TRANSPOSE 1
#define NINPUTS 2
#define D3 4
#define D2 4
#define D1 4
#define ST_OFFSET 64
#define LD_OFFSET1 0
#define LD_OFFSET2 32

/* <<--params-->> */
const int32_t do_relu = DO_RELU;
const int32_t transpose = TRANSPOSE;
const int32_t ninputs = NINPUTS;
const int32_t d3 = D3;
const int32_t d2 = D2;
const int32_t d1 = D1;
const int32_t st_offset = ST_OFFSET;
const int32_t ld_offset1 = LD_OFFSET1;
const int32_t ld_offset2 = LD_OFFSET2;

#define NACC 1

esp_thread_info_t cfg_000[] = {
	{
		.run = true,
		.devname = "gemm.0",
		.type = gemm,
		/* <<--descriptor-->> */
		.desc.gemm_desc.do_relu = DO_RELU,
		.desc.gemm_desc.transpose = TRANSPOSE,
		.desc.gemm_desc.ninputs = NINPUTS,
		.desc.gemm_desc.d3 = D3,
		.desc.gemm_desc.d2 = D2,
		.desc.gemm_desc.d1 = D1,
		.desc.gemm_desc.st_offset = ST_OFFSET,
		.desc.gemm_desc.ld_offset1 = LD_OFFSET1,
		.desc.gemm_desc.ld_offset2 = LD_OFFSET2,
		.desc.gemm_desc.src_offset = 0,
		.desc.gemm_desc.dst_offset = 0,
		.desc.gemm_desc.esp.coherence = ACC_COH_NONE,
		.desc.gemm_desc.esp.p2p_store = 0,
		.desc.gemm_desc.esp.p2p_nsrcs = 0,
		.desc.gemm_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

#endif /* __ESP_CFG_000_H__ */
