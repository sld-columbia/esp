// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __<ACCELERATOR_NAME>_DIRECTIVES_HPP__
#define __<ACCELERATOR_NAME>_DIRECTIVES_HPP__

#if (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD /* <<--dbpw32-->> */
#define DMA_WORD_PER_BEAT /* <<--dwpb32-->> */
#define PLM_IN_NAME /* <<--plm_in_name32-->> */
#define PLM_OUT_NAME /* <<--plm_out_name32-->> */
#elif (DMA_WIDTH == 64)
#define DMA_BEAT_PER_WORD /* <<--dbpw64-->> */
#define DMA_WORD_PER_BEAT /* <<--dwpb64-->> */
#define PLM_IN_NAME /* <<--plm_in_name64-->> */
#define PLM_OUT_NAME /* <<--plm_out_name64-->> */
#endif


#if defined(STRATUS_HLS)

#define HLS_MAP_plm(_mem, _plm_block_name)      \
    HLS_MAP_TO_MEMORY(_mem, _plm_block_name)

#define HLS_PROTO(_s)                           \
    HLS_DEFINE_PROTOCOL(_s)

#define HLS_FLAT(_a)                            \
    HLS_FLATTEN_ARRAY(_a);

#define HLS_BREAK_DEP(_a)                       \
    HLS_BREAK_ARRAY_DEPENDENCY(_a)

#define HLS_UNROLL_SIMPLE                       \
    HLS_UNROLL_LOOP(ON)

#if defined(HLS_DIRECTIVES_BASIC)

#else

#error Unsupported or undefined HLS configuration

#endif /* HLS_DIRECTIVES_* */

#else /* !STRATUS_HLS */

#define HLS_MAP_plm(_mem, _plm_block_name)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __<ACCELERATOR_NAME>_DIRECTIVES_HPP_ */
