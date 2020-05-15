/* Copyright 2018 Columbia University, SLD Group */

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "data.h"
#include "pv_obfuscator.h"

#ifdef CADENCE
#ifdef ENABLE_DIFT_SUPPORT
#include "obfuscator_dift_wrap.h"
#include "esp_templates.hpp"
#include "esp_dift_templates.hpp"
#else // DISABLE_DIFT_SUPPORT
#include "obfuscator_wrap.h"
#include "esp_templates.hpp"
#endif // ENABLE_DIFT_SUPPORT
#endif // CADENCE

const size_t MEM_SIZE = 2048 * 2048 * 16;

#ifdef ENABLE_DIFT_SUPPORT
class system_t : public esp_dift_system<DMA_WIDTH, MEM_SIZE>
#else // DISABLE_DIFT_SUPPORT
class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
#endif // ENABLE_DIFT_SUPPORT
{
    public:

        // -- Modules

#ifdef CADENCE
#ifdef ENABLE_DIFT_SUPPORT
        obfuscator_dift_wrapper *acc;
#else // DISABLE_DIFT_SUPPORT
        obfuscator_wrapper *acc;
#endif // ENABLE_DIFT_SUPPORT
#else // !CADENCE
#ifdef ENABLE_DIFT_SUPPORT
        obfuscator_dift *acc;
#else // DISABLE_DIFT_SUPPORT
        obfuscator *acc;
#endif // ENABLE_DIFT_SUPPORT
#endif // CADENCE

        // -- Module constructor

        SC_HAS_PROCESS(system_t);
        system_t(sc_module_name name)
#ifdef ENABLE_DIFT_SUPPORT
            : esp_dift_system<DMA_WIDTH, MEM_SIZE>(name)
#else // DISABLE_DIFT_SUPPORT
            : esp_system<DMA_WIDTH, MEM_SIZE>(name)
#endif // ENABLE_DIFT_SUPPORT
        {
            // Instantiate the accelerator
#ifdef CADENCE
#ifdef ENABLE_DIFT_SUPPORT
            acc = new obfuscator_dift_wrapper("wrapper");
#else // DISABLE_DIFT_SUPPORT
            acc = new obfuscator_wrapper("wrapper");
#endif // ENABLE_DIFT_SUPPORT
#else // !CADENCE
#ifdef ENABLE_DIFT_SUPPORT
            acc = new obfuscator_dift("wrapper");
#else // DISABLE_DIFT_SUPPORT
            acc = new obfuscator("wrapper");
#endif // ENABLE_DIFT_SUPPORT
#endif // CADENCE

            // Bind the accelerator
            acc->clk(this->clk);
            acc->rst(this->rst);
            acc->dma_read_ctrl(this->dma_read_ctrl);
            acc->dma_write_ctrl(this->dma_write_ctrl);
            acc->dma_read_chnl(this->dma_read_chnl);
            acc->dma_write_chnl(this->dma_write_chnl);
            acc->conf_info(this->conf_info);
            acc->conf_done(this->conf_done);
            acc->acc_done(this->acc_done);
            acc->debug(this->debug);
        }

        // -- Processes

        // Configure accelerator
        void config_proc();

        // -- Functions

        // Load internal memory
        void load_memory();

        // Dump internal memory
        void dump_memory();

        // Validate results
        int validate();

        // -- Data

        // Number of rows
        uint32_t num_rows;

        // Number of cols
        uint32_t num_cols;

        // Start row blurring
        uint32_t i_row_blur;

        // Start col blurring
        uint32_t i_col_blur;

        // Stop row blurring
        uint32_t e_row_blur;

        // Stop col blurring
        uint32_t e_col_blur;

        // Mem index
        uint32_t index;

        // Input image
        image_t *in_image;

        // Output image (acc)
        image_t *out_image;

        // Output image (pvc)
        image_t *out_image_gold;

#ifdef ENABLE_DIFT_SUPPORT
        // Tag offset
        uint32_t tag_offset;
#endif // ENABLE_DIFT_SUPPORT
};

#endif // __SYSTEM_HPP__
