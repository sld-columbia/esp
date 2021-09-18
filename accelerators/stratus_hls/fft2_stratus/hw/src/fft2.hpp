// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __FFT2_HPP__
#define __FFT2_HPP__

#include "fpdata.hpp"
#include "fft2_conf_info.hpp"
#include "fft2_debug_info.hpp"

#include "esp_templates.hpp"

#include "fft2_directives.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define MAX_LOGN_SAMPLES 14
#define MAX_NUM_SAMPLES  (1 << MAX_LOGN_SAMPLES)
#define DATA_WIDTH FX_WIDTH

#if (FX_WIDTH == 64)
#define DMA_SIZE SIZE_DWORD
#elif (FX_WIDTH == 32)
#define DMA_SIZE SIZE_WORD
#endif // FX_WIDTH

#define PLM_IN_WORD  (MAX_NUM_SAMPLES << 1)
#define PLM_OUT_WORD (MAX_NUM_SAMPLES << 1)

class fft2 : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Handshake between store and load for auto-refills
    handshake_t store_to_load;

    // Constructor
    SC_HAS_PROCESS(fft2);
    fft2(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
        , store_to_load("store-to-load")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Clock and signal binding for additional handshake
        store_to_load.bind_with(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(A0, PLM_IN_NAME);
    }

    // Processes

    inline void reset_load_to_store()
    {
        this->store_to_load.req.reset_req();
    }

    inline void reset_store_to_load()
    {
        this->store_to_load.ack.reset_ack();
    }

    inline void load_to_store_handshake()
    {
        HLS_DEFINE_PROTOCOL("load-to-store-handshake");
        this->store_to_load.req.req();
    }

    inline void store_to_load_handshake()
    {
        HLS_DEFINE_PROTOCOL("store-to-load-handshake");
        this->store_to_load.ack.ack();
    }

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure fft2
    esp_config_proc cfg;

    // Functions
    void fft2_do_shift(unsigned int offset, unsigned int num_samples, unsigned int logn_samples);
    void fft2_bit_reverse(unsigned int offset, unsigned int n, unsigned int bits);

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> A0[PLM_IN_WORD];

};


#endif /* __FFT2_HPP__ */
