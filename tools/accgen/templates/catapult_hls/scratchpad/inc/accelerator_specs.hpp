// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __ACCSPECS__
#define __ACCSPECS__

#include <mc_connections.h>
#include "nvhls_connections.h"
#include <nvhls_int.h>
#include <nvhls_types.h>
#include <nvhls_vector.h>
#include "accelerator_name_conf_info.hpp"
#include "esp_dma_info_sysc.hpp"
#include <ArbitratedScratchpadDP.h>

#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* <<--defines-->> */
#define MEM_SIZE /* <<--mem-footprint-->> */ / (DMA_WIDTH / 8)

#define DMA_BEAT_PER_WORD MAX(1, (DATA_WIDTH / DMA_WIDTH))
#define DMA_WORD_PER_BEAT (DMA_WIDTH / DATA_WIDTH)
#define PLM_IN_WP MAX(1, DMA_WORD_PER_BEAT)
#define PLM_OUT_RP MAX(1, DMA_WORD_PER_BEAT)

#define PLM_IN_RP  1
#define PLM_OUT_WP 1

#define IN_BKS MAX(PLM_IN_WP,PLM_IN_RP)
#define OUT_BKS MAX(PLM_OUT_WP,PLM_OUT_RP)

const unsigned int inwp    = PLM_IN_WP;
const unsigned int inrp    = PLM_IN_RP;
const unsigned int outwp   = PLM_OUT_WP;
const unsigned int outrp   = PLM_OUT_RP;
const unsigned int inbks   = IN_BKS;
const unsigned int outbks  = OUT_BKS;
const unsigned int inebks  = PLM_IN_WORD / IN_BKS;
const unsigned int outebks = PLM_OUT_WORD / OUT_BKS;
const unsigned int in_as   = nvhls::index_width<inbks * inebks>::val;
const unsigned int out_as  = nvhls::index_width<outbks * outebks>::val;

template <unsigned int kAddressSz> struct Address {
    typedef NVUINTW(kAddressSz) value;
};

typedef NVUINTW(DATA_WIDTH) DATA_TYPE;

template <unsigned int kAddressSz, unsigned int numports> class plm_WR : public nvhls_message {
  public:
    nvhls::nv_scvector<NVUINTW(kAddressSz), numports> indx;
    nvhls::nv_scvector<DATA_TYPE, numports> data;

    static const unsigned int width = nvhls::nv_scvector<NVUINTW(kAddressSz), numports>::width +
        nvhls::nv_scvector<DATA_TYPE, numports>::width;
    template <unsigned int Size> void Marshall(Marshaller<Size> &m)
    {
        m &indx;
        m &data;
    }
    plm_WR() { Reset(); }
    void Reset()
    {
        indx = 0;
        data = 0;
    }
};

template <unsigned int kAddressSz, unsigned int numports> class plm_RRq : public nvhls_message {
  public:
    nvhls::nv_scvector<NVUINTW(kAddressSz), numports> indx;

    static const unsigned int width = nvhls::nv_scvector<NVUINTW(kAddressSz), numports>::width;
    template <unsigned int Size> void Marshall(Marshaller<Size> &m) { m &indx; }

    plm_RRq() { Reset(); }
    void Reset() { indx = 0; }
};

template <unsigned int numports> class plm_RRs : public nvhls_message {
  public:
    nvhls::nv_scvector<DATA_TYPE, numports> data;
    static const unsigned int width = nvhls::nv_scvector<DATA_TYPE, numports>::width;
    template <unsigned int Size> void Marshall(Marshaller<Size> &m) { m &data; }

    plm_RRs() { Reset(); }
    void Reset() { data = 0; }
};

#endif
