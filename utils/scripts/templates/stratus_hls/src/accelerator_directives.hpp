// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __<ACCELERATOR_NAME>_DIRECTIVES_HPP__
#define __<ACCELERATOR_NAME>_DIRECTIVES_HPP__

#if defined(STRATUS_HLS)

#define HLS_MAP_plm(_mem)                       \
    HLS_MAP_TO_MEMORY(_mem, "plm_block_name")

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

#define HLS_MAP_plm(_mem)
#define HLS_PROTO(_s)
#define HLS_FLAT(_a)
#define HLS_BREAK_DEP(_a)
#define HLS_UNROLL_SIMPLE

#endif /* STRATUS_HLS */

#endif /* __<ACCELERATOR_NAME>_DIRECTIVES_HPP_ */
