// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __AD03_CXX_CATAPULT_HPP__
#define __AD03_CXX_CATAPULT_HPP__

#include "fpdata.hpp"     // Fixed-point data types
#include "conf_info.hpp"  // Configuration-port data type

#include <ac_channel.h>   // Algorithmic C channel class
#include <ac_sync.h>

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define PLM_WIDTH 8
#define PLM_SIZE 128

#define BATCH_MAX 16

// Private Local Memory
// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// PLM typedefs
typedef plm_t<FPDATA_IN, PLM_SIZE> plm_in_t;
typedef plm_t<FPDATA_OUT, PLM_SIZE> plm_out_t;

typedef plm_t<weight2_t, 8192> plm_w2_t;
typedef plm_t<bias2_t, 64> plm_b2_t;

// Accelerator top module
void ad03_cxx_catapult(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif /* __AD03_CXX_CATAPULT_HPP__ */
