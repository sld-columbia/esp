// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CHOLESKY_HPP__
#define __CHOLESKY_HPP__

#include "cholesky_conf_info.hpp"
#include "cholesky_debug_info.hpp"

#include "esp_templates.hpp"

#include "cholesky_directives.hpp"
#include "fpdata.hpp"
#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DATA_WIDTH 32
#define DMA_SIZE SIZE_WORD
#define PLM_OUT_WORD 2048
#define PLM_IN_WORD 2048
class cholesky : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(cholesky);
    cholesky(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(plm_out_pong, PLM_OUT_NAME);
        HLS_MAP_plm(plm_out_ping, PLM_OUT_NAME);
        HLS_MAP_plm(plm_diag, PLM_IN_NAME);
        HLS_MAP_plm(plm_fetch_outdata_ping, PLM_IN_NAME);
        HLS_MAP_plm(plm_fetch_outdata_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_temp_ping, PLM_IN_NAME);
        HLS_MAP_plm(plm_temp_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_in_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_in_ping, PLM_IN_NAME);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure cholesky
    esp_config_proc cfg;

    // Functions

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm_in_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_in_pong[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_diag[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_fetch_outdata_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_fetch_outdata_pong[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_temp_ping[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_temp_pong[PLM_IN_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_out_ping[PLM_OUT_WORD];
    sc_dt::sc_int<DATA_WIDTH> plm_out_pong[PLM_OUT_WORD];
};

#endif /* __CHOLESKY_HPP__ */
