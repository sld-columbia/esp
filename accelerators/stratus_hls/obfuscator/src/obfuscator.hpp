/* Copyright 2018 Columbia University, SLD Group */

#ifndef __OBFUSCATOR_HPP__
#define __OBFUSCATOR_HPP__

#include "fpdata.hpp"

#include "obfuscator_conf_info.hpp"

#include "obfuscator_directives.hpp"

#include "esp_templates.hpp"

#define DMA_SIZE SIZE_WORD
#include A_MEMORY_HEADER
#include B_MEMORY_HEADER
#include C_MEMORY_HEADER

class obfuscator : public esp_accelerator_3P<DMA_WIDTH>
{
     public:

        // -- Instances

        // Config process
        esp_config_proc cfg;

        // Declaration of the accelerator PLMs (0)
        A_MEMORY_TYPE<FPDATA_WORD, A_MEMORY_SIZE> PLM_A0;
        A_MEMORY_TYPE<FPDATA_WORD, A_MEMORY_SIZE> PLM_A1;
        A_MEMORY_TYPE<FPDATA_WORD, A_MEMORY_SIZE> PLM_A2;
        A_MEMORY_TYPE<FPDATA_WORD, A_MEMORY_SIZE> PLM_A3;
        B_MEMORY_TYPE<FPDATA_WORD, B_MEMORY_SIZE> PLM_B0;
        B_MEMORY_TYPE<FPDATA_WORD, B_MEMORY_SIZE> PLM_B1;
        C_MEMORY_TYPE<FPDATA_WORD, C_MEMORY_SIZE> PLM_C0;

        // -- Module constructor

        SC_HAS_PROCESS(obfuscator);
        obfuscator(const sc_module_name &name)
            : esp_accelerator_3P<DMA_WIDTH>(name)
            , cfg("configuration_process")
        {
            // Signal binding with config
            cfg.bind_with<DMA_WIDTH>(*this);

            PLM_A0.clk(this->clk);
            PLM_A1.clk(this->clk);
            PLM_A2.clk(this->clk);
            PLM_A3.clk(this->clk);
            PLM_B0.clk(this->clk);
            PLM_B1.clk(this->clk);
            PLM_C0.clk(this->clk);
        }

        // -- Processes

        // Load input from memory
        void load_input();

        // Perform the computation
        void compute_kernel();

        // Store output in memory
        void store_output();

        // -- Kernels

        // Apply blurring from PLM_B to PLM_C
        void apply_blurring(bool pingpong, uint32_t length);

        // Apply sharpening from PLM_A to PLM_B
        void apply_sharpening(uint32_t circ_buffer, bool pingpong,
             uint32_t row, uint32_t chk, uint32_t num_rows,
             uint32_t chunks, uint32_t length);

        // -- Functions

        // Reset the PLM_C0 before applying blurring
        void reset_before_blurring(uint32_t length);

        // Calculate how many DMA iterations are needed
        void calc_chunks(uint32_t &chunks, uint32_t &rem,
           uint32_t dma_chunk, uint32_t num_cols);

        // Adjust the length and the index of DMA requests
        void adj_request(uint32_t &index, uint32_t &length,
           uint32_t chk, uint32_t chunks, uint32_t rem);

        // Load data by interacting with the DMA interface
        void load_data(uint8_t circ_buffer, uint32_t index,
                uint32_t length);

        // Store data by interacting with the DMA interface
        void store_blurred_data(uint32_t index, uint32_t length);
        void store_unblurred_data(bool pingpong, uint32_t index,
                uint32_t length);
};

#endif // __OBFUSCATOR_HPP__
