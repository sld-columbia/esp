// Copyright (c) 2011-2022 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SM_SENSOR_HPP__
#define __SM_SENSOR_HPP__

#include "sm_sensor_conf_info.hpp"
#include "sm_sensor_debug_info.hpp"

#include "esp_templates.hpp"

#include "sm_sensor_directives.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DATA_WIDTH 64
#define DMA_SIZE SIZE_DWORD
#define PLM_DATA_WORD 12 * 1024

#define NUM_CFG_REG 10

#define NEW_TASK 0
#define LOAD_STORE 1
#define RD_OP 2
#define RD_SIZE 3
#define RD_SP_OFFSET 4
#define SRC_OFFSET 5
#define WR_OP 6
#define WR_SIZE 7
#define WR_SP_OFFSET 8
#define DST_OFFSET 9

#define POLL_REQ 0
#define CFG_REQ 1
#define LOAD_DATA_REQ 2
#define UPDATE_REQ 0
#define STORE_DATA_REQ 1

class sm_sensor : public esp_accelerator_3P<DMA_WIDTH>
{
public:

    // Compute -> Load
    handshake_t load_ready;

    // Compute -> Store
    handshake_t store_ready;

    // Load -> Compute
    handshake_t load_done;

    // Store -> Compute
    handshake_t store_done;

    // Constructor
    SC_HAS_PROCESS(sm_sensor);
    sm_sensor(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
        , load_ready("load_ready")
        , store_ready("store_ready")
        , load_done("load_done")
        , store_done("store_done")
    {
        // Signal binding
        cfg.bind_with(*this);

        HLS_PRESERVE_SIGNAL(load_store_dbg, true);
        HLS_PRESERVE_SIGNAL(rd_op_dbg, true);
        HLS_PRESERVE_SIGNAL(rd_size_dbg, true);
        HLS_PRESERVE_SIGNAL(rd_sp_offset_dbg, true);
        HLS_PRESERVE_SIGNAL(src_offset_dbg, true);
        HLS_PRESERVE_SIGNAL(wr_op_dbg, true);
        HLS_PRESERVE_SIGNAL(wr_size_dbg, true);
        HLS_PRESERVE_SIGNAL(wr_sp_offset_dbg, true);
        HLS_PRESERVE_SIGNAL(dst_offset_dbg, true);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(plm_data, PLM_DATA_NAME);

        load_ready.bind_with(*this);
        store_ready.bind_with(*this);
        load_done.bind_with(*this);
        store_done.bind_with(*this);
    }

    sc_signal< sc_int<64> > load_store_dbg;
    sc_signal< sc_int<64> > rd_op_dbg;
    sc_signal< sc_int<64> > rd_size_dbg;
    sc_signal< sc_int<64> > rd_sp_offset_dbg;
    sc_signal< sc_int<64> > src_offset_dbg;
    sc_signal< sc_int<64> > wr_op_dbg;
    sc_signal< sc_int<64> > wr_size_dbg;
    sc_signal< sc_int<64> > wr_sp_offset_dbg;
    sc_signal< sc_int<64> > dst_offset_dbg;

    sc_int<64> load_state_req;
    sc_int<64> store_state_req;

    sc_int<64> cfg_registers[NUM_CFG_REG];

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure sm_sensor
    esp_config_proc cfg;

    // Functions

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm_data[PLM_DATA_WORD];

    // Handshakes
    inline void compute_load_ready_handshake();
    inline void load_compute_ready_handshake();
    inline void compute_store_ready_handshake();
    inline void store_compute_ready_handshake();
    inline void compute_load_done_handshake();
    inline void load_compute_done_handshake();
    inline void compute_store_done_handshake();
    inline void store_compute_done_handshake();
};


#endif /* __SM_SENSOR_HPP__ */
