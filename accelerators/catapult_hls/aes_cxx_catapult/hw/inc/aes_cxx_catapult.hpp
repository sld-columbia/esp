// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __AES_CXX_CATAPULT_HPP__
#define __AES_CXX_CATAPULT_HPP__

#include "aes.h"
#include "data.hpp" // Fixed-point data types
#include "conf_info.hpp" // Configuration-port data type

#include <ac_channel.h> // Algorithmic C channel class
#include <ac_sync.h>


typedef ac_int<DMA_WIDTH, false> dma_data_t;

// PLM and data dimensions
#define PLM_WIDTH 32
#define PLM_KEY_SIZE (AES_MAX_KEY_WORDS)
#define PLM_IV_SIZE (AES_MAX_IV_WORDS)
#define PLM_IN_SIZE (AES_MAX_IN_WORDS)
#define PLM_OUT_SIZE (AES_MAX_IN_WORDS)
#define PLM_AAD_SIZE (AES_MAX_IN_WORDS)
#define PLM_TAG_SIZE (AES_MAX_IN_WORDS)

// Encapsulate the PLM array in a templated struct
template <class T, unsigned S>
struct plm_t {
public:
   T data[S];
};

// PLM typedefs
typedef plm_t<data_t, PLM_KEY_SIZE> plm_key_t;
typedef plm_t<data_t, PLM_IV_SIZE> plm_iv_t;
typedef plm_t<data_t, PLM_IN_SIZE> plm_in_t;
typedef plm_t<data_t, PLM_OUT_SIZE> plm_out_t;
typedef plm_t<data_t, PLM_AAD_SIZE> plm_aad_t;
typedef plm_t<data_t, PLM_TAG_SIZE> plm_tag_t;

// Accelerator top module
void aes_cxx_catapult(
        ac_channel<conf_info_t> &conf_info,
        ac_channel<dma_info_t> &dma_read_ctrl,
        ac_channel<dma_info_t> &dma_write_ctrl,
        ac_channel<dma_data_t> &dma_read_chnl,
        ac_channel<dma_data_t> &dma_write_chnl,
        ac_sync &acc_done);

#endif /* __AES_CXX_CATAPULT_HPP__ */
