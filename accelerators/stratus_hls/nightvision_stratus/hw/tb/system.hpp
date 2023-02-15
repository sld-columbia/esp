// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include <iostream>
#include <string>

#include "nightvision_conf_info.hpp"
#include "nightvision_debug_info.hpp"
#include "nightvision.hpp"
#include "nightvision_directives.hpp"

#include "esp_templates.hpp"

// TODO right now it's oversized
const size_t MEM_SIZE = 5000000;

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
    #include "nightvision_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
  public:
    // ACC instance
#ifdef CADENCE
    nightvision_wrapper *acc;
#else
    nightvision *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);

    system_t(sc_module_name name, std::string image_A_path, std::string image_out_path, uint32_t n_Images,
             uint32_t n_Rows, uint32_t n_Cols, std::string image_gold_test_path, bool do_validation, bool do_dwt)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
        , image_A_path(image_A_path)
        , image_out_path(image_out_path)
        , image_gold_test_path(image_gold_test_path)
        , n_Images(n_Images)
        , n_Rows(n_Rows)
        , n_Cols(n_Cols)
        , do_validation(do_validation)
        , do_dwt(do_dwt)
    {
        // ACC
#ifdef CADENCE
        acc = new nightvision_wrapper("nightvision_wrapper");
#else
        acc = new nightvision("nightvision_wrapper");
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

    // Optionally free resources (arrays)
    void clean_up(void);

    // Accelerator-specific data

    // Configuration parameters
    uint32_t n_Images;      // number of input images
    uint32_t n_Rows;        // number of rows
    uint32_t n_Cols;        // number of columns
    uint32_t n_Invocations; // number of accelerator invocations

    // Path for the input images
    std::string image_A_path;

    // Path for the output images
    std::string image_out_path;

    // Path for the gold output image
    std::string image_gold_test_path;

    // For validate
    int *imgOut;

    // Test configuration
    bool do_validation;
    bool do_dwt;

    // Other Functions
};

#endif // __SYSTEM_HPP__
