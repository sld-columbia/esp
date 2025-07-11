// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CRYPTO_CXX_CATAPULT_HPP__
#define __CRYPTO_CXX_CATAPULT_HPP__

#include "sha1.h"
#include "sha2.h"
#include "aes.h"
#include "data.hpp"      // Fixed-point data types
#include "conf_info.hpp" // Configuration-port data type

#include <ac_channel.h> // Algorithmic C channel class
#include <ac_sync.h>

typedef ac_int<DMA_WIDTH, false> dma_data_t;

// SHA1 PLM and data dimensions
#define SHA1_PLM_WIDTH   32
#define SHA1_PLM_IN_SIZE SHA1_MAX_BLOCK_SIZE
// TODO: workaround, make PLM 1 word bigger 5 -> 6
#define SHA1_PLM_OUT_SIZE (SHA1_DIGEST_WORDS + 1)

// SHA2 PLM and data dimensions
#define SHA2_PLM_WIDTH    32
#define SHA2_PLM_IN_SIZE  SHA2_MAX_BLOCK_SIZE
#define SHA2_PLM_OUT_SIZE (SHA2_MAX_DIGEST_WORDS)

// AES PLM and data dimensions
#define AES_PLM_WIDTH    32
#define AES_PLM_KEY_SIZE (AES_MAX_KEY_WORDS)
#define AES_PLM_IV_SIZE  (AES_MAX_IV_WORDS)
#define AES_PLM_IN_SIZE  (AES_MAX_IN_WORDS)
#define AES_PLM_OUT_SIZE (AES_MAX_IN_WORDS)
#define AES_PLM_AAD_SIZE (AES_MAX_IN_WORDS)
#define AES_PLM_TAG_SIZE (AES_MAX_IN_WORDS)

// Encapsulate the PLM array in a templated struct
template <class T, unsigned S> struct plm_t {
  public:
    T data[S];
};

// PLM typedefs
typedef plm_t<data_t, SHA1_PLM_IN_SIZE> sha1_plm_in_t;
typedef plm_t<data_t, SHA1_PLM_OUT_SIZE> sha1_plm_out_t;
typedef plm_t<data_t, SHA2_PLM_IN_SIZE> sha2_plm_in_t;
typedef plm_t<data_t, SHA2_PLM_OUT_SIZE> sha2_plm_out_t;
typedef plm_t<data_t, AES_PLM_KEY_SIZE> aes_plm_key_t;
typedef plm_t<data_t, AES_PLM_IV_SIZE> aes_plm_iv_t;
typedef plm_t<data_t, AES_PLM_IN_SIZE> aes_plm_in_t;
typedef plm_t<data_t, AES_PLM_OUT_SIZE> aes_plm_out_t;
typedef plm_t<data_t, AES_PLM_AAD_SIZE> aes_plm_aad_t;
typedef plm_t<data_t, AES_PLM_TAG_SIZE> aes_plm_tag_t;

// Accelerator top module
void crypto_cxx_catapult(ac_channel<conf_info_t> &conf_info, ac_channel<dma_info_t> &dma_read_ctrl,
                         ac_channel<dma_info_t> &dma_write_ctrl,
                         ac_channel<dma_data_t> &dma_read_chnl,
                         ac_channel<dma_data_t> &dma_write_chnl, ac_sync &acc_done);

#endif /* __CRYPTO_CXX_CATAPULT_HPP__ */
