// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// // SPDX-License-Identifier: Apache-2.0

#ifndef __NIGHTVISION_HPP__
#define __NIGHTVISION_HPP__

#include "nightvision_conf_info.hpp"
#include "nightvision_debug_info.hpp"

#include "esp_templates.hpp"

#include "nightvision_directives.hpp"

#include "utils/esp_handshake.hpp"

class nightvision : public esp_accelerator_3P<DMA_WIDTH>
{
  public:
    // Output <-> Input
    handshake_t accel_ready;

    // Constructor
    SC_HAS_PROCESS(nightvision);
    nightvision(const sc_module_name &name)
        : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
        , accel_ready("accel_ready")
        , min_bin(0)
        , max_bin(0)
    {
        // Signal binding
        cfg.bind_with(*this);
        accel_ready.bind_with(*this);

        // Clock binding for memories
        HLS_MAP_mem_buff_1;
        HLS_MAP_mem_buff_2;
        HLS_MAP_mem_hist_1;
        HLS_MAP_mem_hist_2;
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Additional handshakes
    inline void store_load_handshake();
    inline void load_store_handshake();

    // Configure nightvision
    esp_config_proc cfg;

    // Functions
    void kernel_nf(uint32_t n_Rows, uint32_t n_Cols);
    void kernel_hist(uint32_t n_Rows, uint32_t n_Cols);
    void kernel_histEq(uint32_t n_Rows, uint32_t n_Cols);
    void kernel_dwt(uint32_t n_Rows, uint32_t n_Cols);
    void dwt_row_transpose(uint32_t n_Rows, uint32_t n_Cols, int16_t buff1[PLM_IMG_SIZE], int16_t buff2[PLM_IMG_SIZE]);
    void dwt_col_transpose(uint32_t n_Rows, uint32_t n_Cols);

    // -- Private local memories
    int16_t  mem_buff_1[PLM_IMG_SIZE];
    int16_t  mem_buff_2[PLM_IMG_SIZE];
    uint32_t mem_hist_1[PLM_HIST_SIZE];
    uint32_t mem_hist_2[PLM_HIST_SIZE];

    // -- Private state variables
    uint16_t min_bin;
    uint16_t max_bin;
};

inline void nightvision::store_load_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("store-load-handshake");

        accel_ready.req.req();
    }
}

inline void nightvision::load_store_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("load-store-handshake");

        accel_ready.ack.ack();
    }
}

#endif // __NIGHTVISION_HPP__
