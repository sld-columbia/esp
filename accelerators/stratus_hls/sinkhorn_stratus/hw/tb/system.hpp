// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include <iostream>
#include <string>

#include "sinkhorn_conf_info.hpp"
#include "sinkhorn_debug_info.hpp"
#include "sinkhorn.hpp"
//#include "sinkhorn_directives.hpp"
#include "datatypes.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = 205000 / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "sinkhorn_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    sinkhorn_wrapper *acc;
#else
    sinkhorn *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name,
             uint32_t p_rows,
             uint32_t q_cols,
             uint32_t m_rows,
             float gamma,
             uint32_t maxiter,
             uint32_t p2p_in,
             uint32_t p2p_out,
             uint32_t p2p_iter,
             uint32_t store_state)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
        , p_rows(p_rows)
        , q_cols(q_cols)
        , m_rows(m_rows)
        , gamma(gamma)
        , maxiter(maxiter)
        , p2p_in(p2p_in)
        , p2p_out(p2p_out)
        , p2p_iter(p2p_iter)
        , store_state(store_state)
    {
        // ACC
#ifdef CADENCE
        acc = new sinkhorn_wrapper("sinkhorn_wrapper");
#else
        acc = new sinkhorn("sinkhorn_wrapper");
#endif
        // Binding ACC
        acc->clk(clk);
        acc->rst(acc_rst);
        acc->dma_read_ctrl(dma_read_ctrl);
        acc->dma_write_ctrl(dma_write_ctrl);
        acc->dma_read_chnl(dma_read_chnl);
        acc->dma_write_chnl(dma_write_chnl);
        acc->conf_info(conf_info);
        acc->conf_done(conf_done);
        acc->acc_done(acc_done);
        acc->debug(debug);
    }

    // Processes

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data

    // Configuration parameters
    uint32_t p_rows; // output rows dimension and cols for input X
    uint32_t q_cols;   // output cols dimension and cols for input Y
    uint32_t m_rows;   // rows dimension for inputs X and Y
    float gamma; // float constant for computation of K matrix
    uint32_t maxiter; // number of iterations for kernel computing a and b vectors
    uint32_t p2p_in; // expect input in p2p mode
    uint32_t p2p_out; // expect output in p2p mode
    uint32_t p2p_iter; // number of iterations in p2p mode
    uint32_t store_state; // defines whoch store state the accelerator is in

    uint32_t inX_words_adj;
    uint32_t inY_words_adj;
    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t inX_size;
    uint32_t inY_size;
    uint32_t in_size;
    uint32_t out_size;
    FPDATA *inX;
    FPDATA *inY;
    FPDATA *in;
    FPDATA *out;
//    int32_t *gold;


    // Output
    float *P;
    float CP_sum;

    // Other Functions
};

#endif // __SYSTEM_HPP__
