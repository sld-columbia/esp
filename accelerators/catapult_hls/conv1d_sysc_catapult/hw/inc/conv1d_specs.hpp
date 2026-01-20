// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __ACCSPECS__
#define __ACCSPECS__

#include <mc_connections.h>
#include "nvhls_connections.h"
#include <nvhls_int.h>
#include <nvhls_types.h>
#include <nvhls_vector.h>
#include <sstream>
#include "auto_gen_port_info.h"
#include "conv1d_conf_info.hpp"
#include "esp_dma_info_sysc.hpp"
#include <ArbitratedScratchpadDP.h>

//#define MAX(a, b) ((a) > (b) ? (a) : (b))
//
///* <<--defines-->> */
//#define DATA_WIDTH 32
//#define DMA_SIZE SIZE_WORD
//#define PLM_OUT_WORD 8589934592
//#define PLM_IN_WORD 4294967296
//#define MEM_SIZE 105553116266496 / (DMA_WIDTH / 8)
//
//#define DMA_BEAT_PER_WORD MAX(1, (DATA_WIDTH / DMA_WIDTH))
//#define DMA_WORD_PER_BEAT (DMA_WIDTH / DATA_WIDTH)
//
//#define IN_BKS MAX(1,DMA_WORD_PER_BEAT)
//#define OUT_BKS MAX(1,DMA_WORD_PER_BEAT)
//
//const unsigned int inbks   = IN_BKS;
//const unsigned int outbks  = OUT_BKS;
//const unsigned int inebks  = PLM_IN_WORD / IN_BKS;
//const unsigned int outebks = PLM_OUT_WORD / OUT_BKS;

// DMA configuration
#define DMA_SIZE SIZE_DWORD
#define DATA_WIDTH 32
#ifndef DMA_WIDTH
#define DMA_WIDTH 32
#endif

// Fixed-point configuration
#define FPDATA_WL 32
#define FPDATA_IL 16

// Accelerator configuration
#define VEC_LEN 8
#define PLM_WORD 8192
#define MEM_SIZE (100663296 / (DMA_WIDTH / 8))

#if (DMA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 1
#define DMA_WORD_PER_BEAT 1
#elif (DMA_WIDTH == 64)
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 2
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 4
#endif
#elif (DMA_WIDTH == 128)
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 4
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 8
#endif
#elif (DMA_WIDTH == 256)
#if (DATA_WIDTH == 32)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 8
#elif (DATA_WIDTH == 16)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 16
#endif
#elif (DMA_WIDTH == 512)
#define DMA_BEAT_PER_WORD 0
#define DMA_WORD_PER_BEAT 16
#endif

#define VEC_DMA_RATIO (VEC_LEN / DMA_WORD_PER_BEAT)

// Memory configuration
const unsigned int bks = VEC_LEN;
const unsigned int ebks = PLM_WORD / VEC_LEN;

typedef NVINTW(DATA_WIDTH) DATA_TYPE;
typedef ac_fixed<FPDATA_WL, FPDATA_IL, true, AC_RND, AC_SAT> FPDATA;

// Define array_t helper
template<typename T, int N>
struct array_t {
    T data[N];

    AUTO_GEN_FIELD_METHODS(array_t, ( \
        data \
    ))

    inline bool operator==(const array_t<T,N> &other) const {
        for(int i=0; i<N; i++) {
            if(data[i] != other.data[i]) return false;
        }
        return true;
    }

    inline friend std::ostream &operator<<(std::ostream &os, const array_t<T,N> &v) {
        os << "[";
        for(int i=0; i<N; i++) os << v.data[i] << (i==N-1 ? "" : ", ");
        os << "]";
        return os;
    }

    inline friend void sc_trace(sc_trace_file *tf, const array_t<T,N> &v, const std::string &NAME) {
        for(int i=0; i<N; i++) {
            std::stringstream ss;
            ss << NAME << ".data_" << i;
            sc_trace(tf, v.data[i], ss.str());
        }
    }
};

#endif
