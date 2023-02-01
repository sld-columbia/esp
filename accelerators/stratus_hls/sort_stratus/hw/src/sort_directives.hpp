// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SORT_DIRECTIVES_HPP__
#define __SORT_DIRECTIVES_HPP__

// Local memory size: number of elements
#define lgLEN 10
#define LEN (1<<lgLEN)
// Number of comparators per computational chain
#define lgNUM 5
#define NUM (1<<lgNUM)

#if (LEN / NUM > 32)
#error To keep register count low LEN / NUM cannot exceed 32
#endif

#if defined(STRATUS)

// Memory allocation

#if (DMA_WIDTH == 32)

#define HLS_MAP_A0					\
	HLS_MAP_TO_MEMORY(A0, "sort_plm_block_1w1r")
#define HLS_MAP_A1					\
	HLS_MAP_TO_MEMORY(A1, "sort_plm_block_1w1r")
#define HLS_MAP_B0					\
	HLS_MAP_TO_MEMORY(B0, "sort_plm_block_1w1r")
#define HLS_MAP_B1					\
	HLS_MAP_TO_MEMORY(B1, "sort_plm_block_1w1r")

#elif (DMA_WIDTH == 64)

#define HLS_MAP_A0					\
	HLS_MAP_TO_MEMORY(A0, "sort_plm_block_2w1r")
#define HLS_MAP_A1					\
	HLS_MAP_TO_MEMORY(A1, "sort_plm_block_2w1r")
#define HLS_MAP_B0					\
	HLS_MAP_TO_MEMORY(B0, "sort_plm_block_1w2r")
#define HLS_MAP_B1					\
	HLS_MAP_TO_MEMORY(B1, "sort_plm_block_1w2r")
#endif

#define HLS_MAP_C0					\
	HLS_MAP_TO_MEMORY(C0, "sort_plm_block_1w1r")
#define HLS_MAP_C1					\
	HLS_MAP_TO_MEMORY(C1, "sort_plm_block_1w1r")

#define HLS_LOAD_RESET				\
	HLS_DEFINE_PROTOCOL("load-reset")
#define HLS_LOAD_CONFIG				\
	HLS_DEFINE_PROTOCOL("load-config")
#define HLS_LOAD_DMA				\
	HLS_DEFINE_PROTOCOL("load-dma-conf")
#define HLS_LOAD_INPUT_BATCH_LOOP		\
	HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_LOOP			\
	HLS_UNROLL_LOOP(OFF)
#define HLS_LOAD_INPUT_PLM_WRITE					\
	HLS_CONSTRAIN_LATENCY(1, 1, "constraint-load-mem-access");	\
	HLS_BREAK_ARRAY_DEPENDENCY(A0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(A1)

#define HLS_STORE_RESET				\
	HLS_DEFINE_PROTOCOL("store-reset")
#define HLS_STORE_CONFIG			\
	HLS_DEFINE_PROTOCOL("store-config")
#define HLS_STORE_DMA				\
	HLS_DEFINE_PROTOCOL("store-dma-conf")
#define HLS_STORE_OUTPUT_BATCH_LOOP		\
	HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_LOOP			\
	HLS_UNROLL_LOOP(OFF)
#define HLS_STORE_OUTPUT_PLM_READ					\
	HLS_CONSTRAIN_LATENCY(1, 1, "constraint-store-mem-access");	\
	HLS_BREAK_ARRAY_DEPENDENCY(B0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(B1)

#define HLS_RB_RESET				\
	HLS_DEFINE_PROTOCOL("rb-reset")
#define HLS_RB_CONFIG				\
	HLS_DEFINE_PROTOCOL("rb-config")

#define HLS_MERGE_RESET				\
	HLS_DEFINE_PROTOCOL("merge-reset")
#define HLS_MERGE_CONFIG				\
	HLS_DEFINE_PROTOCOL("merge-config")


// Datapath micro-architecture

#if defined(HLS_DIRECTIVES_BASIC)

#define HLS_RB_SORT_LOOP			\
	HLS_UNROLL_LOOP(OFF)
#define HLS_RB_MAP_REGS				\
	HLS_FLATTEN_ARRAY(regs)
#define HLS_RB_MAIN				\
	HLS_UNROLL_LOOP(OFF)
#define HLS_RB_RW_CHUNK							\
	HLS_UNROLL_LOOP(OFF);						\
	HLS_CONSTRAIN_LATENCY(1, 1, "constraint-RB_RW_CHUNK-mem-access"); \
	HLS_BREAK_ARRAY_DEPENDENCY(A0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(A1);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C1)
#define HLS_RB_INSERTION_OUTER			\
	HLS_UNROLL_LOOP(OFF)
#define HLS_RB_INSERTION_EVEN						\
	HLS_UNROLL_LOOP(ON)
#define HLS_RB_INSERTION_ODD						\
	HLS_UNROLL_LOOP(ON)
#define HLS_RB_BREAK_FALSE_DEP					\
	HLS_DEFINE_PROTOCOL("protocol-RB_BREAK_FALSE_DEP");	\
	wait();
#define HLS_RB_W_LAST_CHUNKS_INNER					\
	HLS_UNROLL_LOOP(OFF);						\
	HLS_CONSTRAIN_LATENCY(1, 1, "constraint-RB_W_LAST_CHUNKS_INNER-mem-access"); \
	HLS_BREAK_ARRAY_DEPENDENCY(C0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C1)

#define HLS_MERGE_SORT_LOOP			\
	HLS_UNROLL_LOOP(OFF)
#define HLS_MERGE_SORT_MAP_REGS			\
	HLS_FLATTEN_ARRAY(head);		\
	HLS_FLATTEN_ARRAY(fidx);		\
	HLS_FLATTEN_ARRAY(regs);		\
	HLS_FLATTEN_ARRAY(regs_in);		\
	HLS_FLATTEN_ARRAY(shift_array);		\
	HLS_FLATTEN_ARRAY(pop_array)
#define HLS_MERGE_INIT_ZERO_FIDX					\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_RD_FIRST_ELEMENTS					\
	HLS_UNROLL_LOOP(OFF);						\
	HLS_CONSTRAIN_LATENCY(1, 1, "constraint-MERGE_RD_FIRST_ELEMENTS-mem-access"); \
	HLS_BREAK_ARRAY_DEPENDENCY(C0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C1)
#define HLS_MERGE_RD_NEXT_ELEMENT		\
	HLS_BREAK_ARRAY_DEPENDENCY(C0);		\
	HLS_BREAK_ARRAY_DEPENDENCY(C1)
#define HLS_MERGE_MAIN				\
	HLS_CONSTRAIN_LATENCY(2, 8, "constraint-MERGE_MAIN"); \
	HLS_UNROLL_LOOP(OFF)
#define HLS_MERGE_COMPARE			\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_SHIFT_ARRAY			\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_DEBRUIJN32			\
	HLS_FLATTEN_ARRAY(DeBruijn32)
#define HLS_MERGE_SHIFT_REV			\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_SHIFT				\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_POP_ARRAY			\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_SEQ				\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_WR_LAST_ELEMENTS					\
	HLS_BREAK_ARRAY_DEPENDENCY(B0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(B1)
#define HLS_MERGE_DO_POP						\
	HLS_BREAK_ARRAY_DEPENDENCY(C0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C1)
#define HLS_MERGE_ZERO			\
	HLS_UNROLL_LOOP(ON)
#define HLS_MERGE_NO_MERGE_OUTER					\
	HLS_UNROLL_LOOP(OFF)
#define HLS_MERGE_NO_MERGE_INNER					\
	HLS_PIPELINE_LOOP(HARD_STALL);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(C1);					\
	HLS_BREAK_ARRAY_DEPENDENCY(B0);					\
	HLS_BREAK_ARRAY_DEPENDENCY(B1)

#endif /* HLS_DIRECTIVES_BASIC */


#endif /* STRATUS */

#ifndef HLS_MAP_A0
#define HLS_MAP_A0
#endif
#ifndef HLS_MAP_A1
#define HLS_MAP_A1
#endif
#ifndef HLS_MAP_B0
#define HLS_MAP_B0
#endif
#ifndef HLS_MAP_B1
#define HLS_MAP_B1
#endif
#ifndef HLS_MAP_C0
#define HLS_MAP_C0
#endif
#ifndef HLS_MAP_C1
#define HLS_MAP_C1
#endif


#ifndef HLS_LOAD_RESET
#define HLS_LOAD_RESET
#endif
#ifndef HLS_LOAD_CONFIG
#define HLS_LOAD_CONFIG
#endif
#ifndef HLS_LOAD_DMA
#define HLS_LOAD_DMA
#endif
#ifndef HLS_LOAD_INPUT_BATCH_LOOP
#define HLS_LOAD_INPUT_BATCH_LOOP
#endif
#ifndef HLS_LOAD_INPUT_LOOP
#define HLS_LOAD_INPUT_LOOP
#endif
#ifndef HLS_LOAD_INPUT_PLM_WRITE
#define HLS_LOAD_INPUT_PLM_WRITE
#endif

#ifndef HLS_STORE_RESET
#define HLS_STORE_RESET
#endif
#ifndef HLS_STORE_CONFIG
#define HLS_STORE_CONFIG
#endif
#ifndef HLS_STORE_DMA
#define HLS_STORE_DMA
#endif
#ifndef HLS_STORE_OUTPUT_BATCH_LOOP
#define HLS_STORE_OUTPUT_BATCH_LOOP
#endif
#ifndef HLS_STORE_OUTPUT_LOOP
#define HLS_STORE_OUTPUT_LOOP
#endif
#ifndef HLS_STORE_OUTPUT_PLM_READ
#define HLS_STORE_OUTPUT_PLM_READ
#endif

#ifndef HLS_RB_RESET
#define HLS_RB_RESET
#endif
#ifndef HLS_RB_CONFIG
#define HLS_RB_CONFIG
#endif

#ifndef HLS_MERGE_RESET
#define HLS_MERGE_RESET
#endif
#ifndef HLS_MERGE_CONFIG
#define HLS_MERGE_CONFIG
#endif

#ifndef HLS_RB_SORT_LOOP
#define HLS_RB_SORT_LOOP
#endif
#ifndef HLS_RB_MAP_REGS
#define HLS_RB_MAP_REGS
#endif
#ifndef HLS_RB_MAIN
#define HLS_RB_MAIN
#endif
#ifndef HLS_RB_RW_CHUNK
#define HLS_RB_RW_CHUNK
#endif
#ifndef HLS_RB_INSERTION_OUTER
#define HLS_RB_INSERTION_OUTER
#endif
#ifndef HLS_RB_INSERTION_EVEN
#define HLS_RB_INSERTION_EVEN
#endif
#ifndef HLS_RB_INSERTION_ODD
#define HLS_RB_INSERTION_ODD
#endif
#ifndef HLS_RB_BREAK_FALSE_DEP
#define HLS_RB_BREAK_FALSE_DEP
#endif
#ifndef HLS_RB_W_LAST_CHUNKS_OUTER
#define HLS_RB_W_LAST_CHUNKS_OUTER
#endif
#ifndef HLS_RB_W_LAST_CHUNKS_INNER
#define HLS_RB_W_LAST_CHUNKS_INNER
#endif

#ifndef HLS_MERGE_SORT_LOOP
#define HLS_MERGE_SORT_LOOP
#endif
#ifndef HLS_MERGE_SORT_MAP_REGS
#define HLS_MERGE_SORT_MAP_REGS
#endif
#ifndef HLS_MERGE_INIT_ZERO_FIDX
#define HLS_MERGE_INIT_ZERO_FIDX
#endif
#ifndef HLS_MERGE_RD_FIRST_ELEMENTS
#define HLS_MERGE_RD_FIRST_ELEMENTS
#endif
#ifndef HLS_MERGE_RD_NEXT_ELEMENT
#define HLS_MERGE_RD_NEXT_ELEMENT
#endif
#ifndef HLS_MERGE_MAIN
#define HLS_MERGE_MAIN
#endif
#ifndef HLS_MERGE_COMPARE
#define HLS_MERGE_COMPARE
#endif
#ifndef HLS_MERGE_SHIFT_ARRAY
#define HLS_MERGE_SHIFT_ARRAY
#endif
#ifndef HLS_MERGE_POP_ARRAY
#define HLS_MERGE_POP_ARRAY
#endif
#ifndef HLS_MERGE_DEBRUIJN32
#define HLS_MERGE_DEBRUIJN32
#endif
#ifndef HLS_MERGE_SHIFT_REV
#define HLS_MERGE_SHIFT_REV
#endif
#ifndef HLS_MERGE_SHIFT
#define HLS_MERGE_SHIFT
#endif
#ifndef HLS_MERGE_SEQ
#define HLS_MERGE_SEQ
#endif
#ifndef HLS_MERGE_WR_LAST_ELEMENTS
#define HLS_MERGE_WR_LAST_ELEMENTS
#endif
#ifndef HLS_MERGE_DO_POP
#define HLS_MERGE_DO_POP
#endif
#ifndef HLS_MERGE_ZERO
#define HLS_MERGE_ZERO
#endif
#ifndef HLS_MERGE_NO_MERGE_OUTER
#define HLS_MERGE_NO_MERGE_OUTER
#endif
#ifndef HLS_MERGE_NO_MERGE_INNER
#define HLS_MERGE_NO_MERGE_INNER
#endif

#endif /* __SORT_DIRECTIVES_HPP__ */
