// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SHA1_CXX_CATAPULT_HPP__
#define __SHA1_CXX_CATAPULT_HPP__

#include "sha1.h"
#include "data.hpp" // Fixed-point data types
#include "conf_info.hpp" // Configuration-port data type

#include <ac_channel.h> // Algorithmic C channel class
#include <ac_sync.h>


typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define PLM_WIDTH 32
#define PLM_IN_SIZE SHA1_MAX_BLOCK_SIZE
// TODO: workaround, make PLM 1 word bigger 5 -> 6
#define PLM_OUT_SIZE (SHA1_DIGEST_WORDS+1)

// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// PLM typedefs
typedef plm_t<data_t, PLM_IN_SIZE> plm_in_t;
typedef plm_t<data_t, PLM_OUT_SIZE> plm_out_t;

// Accelerator top module
void sha1_cxx_catapult(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif /* __SHA1_CXX_CATAPULT_HPP__ */
