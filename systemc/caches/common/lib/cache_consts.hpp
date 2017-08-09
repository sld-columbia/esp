/* Copyright 2017 Columbia University, SLD Group */

#ifndef __CACHES_CONSTS_HPP__
#define __CACHES_CONSTS_HPP__


/*
 * System
 */

// System configuration
#define N_CPU	2

/*
 * Caches
 */

// Address bits breakdown: LSB to MSB
#define ADDR_BITS	32
#define BYTE_BITS	2
#define WORD_BITS	2
#define OFFSET_BITS	(BYTE_BITS + WORD_BITS)
#define SET_BITS	8
#define TAG_BITS	(ADDR_BITS - OFFSET_BITS - SET_BITS)

#define LINE_RANGE_HI	(ADDR_BITS - 1)
#define LINE_RANGE_LO	(ADDR_BITS - TAG_BITS - SET_BITS)
#define TAG_RANGE_HI	(ADDR_BITS - 1)
#define TAG_RANGE_LO	(ADDR_BITS - TAG_BITS)
#define SET_RANGE_HI	(ADDR_BITS - TAG_BITS - 1)
#define SET_RANGE_LO	(ADDR_BITS - TAG_BITS - SET_BITS)
#define OFF_RANGE_HI	(ADDR_BITS - TAG_BITS - SET_BITS - 1)
#define OFF_RANGE_LO	0
#define W_OFF_RANGE_HI	(ADDR_BITS - TAG_BITS - SET_BITS - 1)
#define W_OFF_RANGE_LO	(ADDR_BITS - TAG_BITS - SET_BITS - WORD_BITS)
#define B_OFF_RANGE_HI	(ADDR_BITS - TAG_BITS - SET_BITS - WORD_BITS - 1)
#define B_OFF_RANGE_LO	0

#define TAG_OFFSET	(1 << TAG_RANGE_LO)
#define SET_OFFSET	(1 << SET_RANGE_LO)
#define WORD_OFFSET	(1 << W_OFF_RANGE_LO)

// Cache sizes
#define BYTES_PER_WORD		(1 << BYTE_BITS)
#define BITS_PER_WORD		(BYTES_PER_WORD << 3)
#define BITS_PER_HALFWORD	(BITS_PER_WORD >> 1)
#define BITS_PER_LINE		(BITS_PER_WORD * WORDS_PER_LINE)
#define WORDS_PER_LINE		(1 << WORD_BITS)
#define SETS			(1 << SET_BITS)
#define L2_WAY_BITS		3
#define L2_WAYS			(1 << L2_WAY_BITS)
#define L3_WAYS			(N_CPU * L2_WAYS)
#define L2_LINES		(SETS*L2_WAYS)

// Cache data types width
#define CPU_MSG_TYPE_WIDTH	2
#define COH_MSG_TYPE_WIDTH	2
#define HSIZE_WIDTH		3
#define HPROT_WIDTH		4
#define INVACK_CNT_WIDTH	3	// TODO determines max CPUs
#define MAX_INVACK_CNT          7

// Ongoing transaction buffers
#define N_REQS		4	// affects REQS_BITS
#define REQS_BITS	2	// depends on N_REQS
#define N_EVICTS	4	// affects N_EVICTS
#define EVICTS_BITS	2	// depends on EVICTS_BITS

// L2 operation behavior
#define HIT		0
#define MISS		1
#define MISS_EVICT	2

/*
 * Coherence
 */

/* Protocol states */

// N bits to indicate the state
#define STABLE_STATE_BITS	2	// depends on # of stable states
#define UNSTABLE_STATE_BITS	4	// depends on # of unstable states
#define EVICT_STATE_BITS        2
// Stable states
#define INVALID			0
#define SHARED			1
#define EXCLUSIVE		2
#define MODIFIED		3
// Request unstable states
#define ISD			1
#define IMAD			2
#define IMADW			3
#define IMA			4
#define IMAW			5
#define SMAD			6
#define SMADW			7
#define SMA			8
#define SMAW			9
#define XMW			10
// Evict unstable states
#define IIA			1
#define SIA			2
#define MIA			3


/* Protocol messages */

// CPU requests (L1 to L2)
#define READ		0
#define READ_ATOMIC	1
#define WRITE		2
#define WRITE_ATOMIC	3

// requests (L2 to L3)
#define REQ_GETS	0
#define REQ_GETM	1
#define REQ_PUTS	2
#define REQ_PUTM	3

// forwards (L3 to L2)
#define FWD_GETS	0
#define FWD_GETM	1
#define FWD_INV		2

// response (L2 to L2, L2 to L3, L3 to L2)
#define RSP_DATA	0
#define RSP_EDATA	1
#define RSP_INVACK	2
#define RSP_PUTACK	3

/*
 * AMBA Bus
 */

// hsize
#define BYTE		0
#define HALFWORD	1
#define WORD		2
#define WORDS_4		4
#define WORDS_8		5

// hprot
#define DATA_OPCODE_MASK	1
#define PRIVILEGED_MASK		2
#define BUFFERABLE_MASK		4
#define CACHEABLE_MASK		8

#define NOT_CACHEABLE	0
#define CACHEABLE	1

#define DEFAULT_HPROT	4

/* 
 * Debug and report
 */

// debug
#define ASSERT_WIDTH 13
#define BOOKMARK_WIDTH	18

#define AS_REQS_MISS		(1 << 0)
#define AS_RSP_DATA_DEFAULT     (1 << 1)
#define	AS_RSP_DEFAULT		(1 << 2)
#define AS_HIT_WRITE_DEFAULT	(1 << 3)
#define AS_HIT_DEFAULT		(1 << 4)
#define AS_MISS_DEFAULT		(1 << 5)
#define AS_EVICT_DEFAULT	(1 << 6)
#define AS_WRONG_HSIZE    	(1 << 7)
#define AS_PUTACK_DEFAULT       (1 << 8)
#define AS_REQS_LOOKUP          (1 << 9)
#define AS_REQS_LOOKUP2         (1 << 10)
#define AS_INVACK_DEFAULT       (1 << 11)
#define AS_RSP_DATA_XMAD        (1 << 12)

#define BM_GET_RSP_IN		(1 << 0)
#define BM_GET_CPU_REQ		(1 << 1)
#define BM_TAG_LOOKUP		(1 << 2)
#define BM_REQS_LOOKUP		(1 << 3)
#define BM_RSP_DATA_ISD		(1 << 4)
#define BM_RSP_DATA_XMAD	(1 << 5)
#define BM_RSP_EDATA		(1 << 6)
#define BM_HIT_READ		(1 << 7)
#define BM_HIT_WRITE_S		(1 << 8)
#define BM_HIT_WRITE_EM		(1 << 9)
#define BM_MISS_READ		(1 << 10)
#define BM_MISS_WRITE		(1 << 11)
#define BM_SEND_REQ_OUT		(1 << 12)
#define BM_SEND_RD_RSP		(1 << 13)
#define BM_PUT_REQS		(1 << 14)
#define BM_GET_FLUSH		(1 << 15)
#define BM_FLUSH_READ_SET	(1 << 16)
#define BM_SEND_INVAL		(1 << 17)

// report
#define RPT_OFF 0
#define RPT_ON  1
#define RPT_TB  RPT_OFF
#define RPT_RTL RPT_OFF
#define RPT_BM  RPT_OFF
#define RPT_CU  RPT_OFF

#endif // __CACHES_CONSTS_HPP__
