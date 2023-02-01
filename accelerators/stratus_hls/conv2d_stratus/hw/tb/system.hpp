// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "conv2d_data.hpp"
#include "fpdata.hpp"
#include "conv2d_conf_info.hpp"
#include "conv2d_debug_info.hpp"
#include "conv2d.hpp"
#include "conv2d_directives.hpp"

// #include "conv_layer.hpp"
#include "golden.hpp"
#include "sizes.h"
#include "esp_templates.hpp"
#include "utils.hpp"

const size_t input_max_size = 3211264; // TODO: it should not be hardcoded
const size_t weights_max_size = 2359296; // TODO: it should not be hardcoded
const size_t bias_max_size = 29296; // TODO: it should not be hardcoded
const size_t output_max_size = 3211264; // TODO: it should not be hardcoded
// Hard-coded 8 because the data word will never be more than 8 bytes
const size_t MEM_SIZE = (input_max_size + weights_max_size + bias_max_size + output_max_size) * 8;

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "conv2d_wrap.h"
#endif


class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    conv2d_wrapper *acc;
#else
    conv2d *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new conv2d_wrapper("conv2d_wrapper");
#else
        acc = new conv2d("conv2d_wrapper");
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
    /* <<--params-->> */
    int32_t channels;
    int32_t height;
    int32_t width;
    int32_t num_filters;
    int32_t kernel_h;
    int32_t kernel_w;
    int32_t pad_h;
    int32_t pad_w;
    int32_t stride_h;
    int32_t stride_w;
    int32_t dilation_h;
    int32_t dilation_w;
    int32_t do_relu;
    int32_t pool_type;
    int32_t output_h;
    int32_t output_w;
    int32_t output_pool_h;
    int32_t output_pool_w;
    int32_t batch_size;
    
    uint32_t in_words_adj;
    uint32_t weights_words_adj;
    uint32_t bias_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t weights_size;
    uint32_t bias_size;
    uint32_t out_size;

    float* input;
    float* weights;
    float* bias;
    float* hw_output;
    float* sw_output;

    // Other Functions
};

#endif // __SYSTEM_HPP__
