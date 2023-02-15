// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SINKHORN_HPP__
#define __SINKHORN_HPP__

#include "sinkhorn_conf_info.hpp"
#include "sinkhorn_debug_info.hpp"
#include "datatypes.hpp"
#include "sinkhorn_directives.hpp"

#include "esp_templates.hpp"

#include "utils/esp_handshake.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define P_MAX 230
#define Q_MAX 180
#define M_MAX 3

#define DATA_WIDTH 32
#define LOG_DATA_WIDTH 5
#define DMA_SIZE SIZE_WORD
#define PLM_OUT_WORD 40960
#define PLM_IN_X_WORD P_MAX*M_MAX
#define PLM_IN_Y_WORD Q_MAX*M_MAX
#define PLM_TOTAL_IN_WORD PLM_IN_X_WORD+PLM_IN_Y_WORD
#define PLM_INTERMED_WORD 256

#define PRECISION 5
#define READ_INPUT_WRITE_CK 2
//#define WRITE_OUTPUT 4 // equal to READ_INPUT
//#define READ_C_WRITE_K 8 // Multiple of 4
#define READ_A 8 // Multiple of 4
#define READ_B 8 // Multiple of 4
#define INIT_B 8
//#define WRITE_INTERMED 4 // equal to READ_INPUT
#define MAX_ITER 150

//#define PLM_INPUT_SIZE 102A4
//#define PLM_OUTPUT_SIZE 6A5536
//#define PLM_INTERMED_SIZE 256

class sinkhorn : public esp_accelerator_3P<DMA_WIDTH>
{
public:

    handshake_t accel_ready;

    // Store <-> Internal Computation
    handshake_t compute_ready;

    // Constructor
    SC_HAS_PROCESS(sinkhorn);
    sinkhorn(const sc_module_name& name)
        : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
        , accel_ready("accel_ready")
        , compute_ready("compute_ready")
        , CP_sum("CP_sum")
        , p_rows("p_rows")
        , q_cols("q_cols")
        , m_rows("m_rows")
        , gamma("gamma")
        , maxiter("maxiter")
    {
        SC_CTHREAD(compute_store_P, this->clk.pos());
        this->reset_signal_is(this->rst, false);

        // Signal binding
        cfg.bind_with(*this);
        accel_ready.bind_with(*this);
        compute_ready.bind_with(*this);

        //Binding memories
        HLS_MAP_inputx_plm(inputX);
        HLS_MAP_inputy_plm(inputY);
        HLS_MAP_intermed_plm(x_a);
        HLS_MAP_intermed_plm(y_b);
        HLS_MAP_intermed_plm(b_alt);
        HLS_MAP_intermed2_plm(Ping);
        HLS_MAP_intermed2_plm(Pong);
        HLS_MAP_output_plm(C);
        HLS_MAP_output2_plm(K);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Handshake callable by computeP_kernel
    inline void computeP_store_handshake();

    // Handshake callable by store_output
    inline void store_computeP_handshake();

    // Configure sinkhorn
    esp_config_proc cfg;

    // Functions
    void compute_C(uint32_t p, uint32_t q, uint32_t m, FPDATA_WORD gamma);
    void compute_P(uint32_t p, uint32_t q, uint32_t maxiter/*, FPDATA_WORD gamma*/);
    void compute_CP(uint32_t p, uint32_t q);
    FPDATA kernel_operation(uint32_t p, uint32_t q, bool a_or_b);
    //void kernel_op_alt(uint32_t p, uint32_t q, uint32_t iter);
    FPDATA neg_exp(FPDATA exponent);
    void compute_store_P();

    inline void reset_computeP_output();
    inline void reset_store_computeP_output();

    // Private local memories
    FPDATA_WORD inputX[PLM_IN_X_WORD];
    FPDATA_WORD inputY[PLM_IN_Y_WORD];
    FPDATA_WORD x_a[PLM_INTERMED_WORD];
    FPDATA_WORD y_b[PLM_INTERMED_WORD];
    FPDATA_WORD b_alt[PLM_INTERMED_WORD];
    FPDATA_WORD Ping[PLM_INTERMED_WORD];
    FPDATA_WORD Pong[PLM_INTERMED_WORD];
    FPDATA_WORD C[PLM_OUT_WORD];
    FPDATA_WORD K[PLM_OUT_WORD];

    //FPDATA precision_const[PRECISION];

    //Registers
    sc_signal<FPDATA_WORD> CP_sum;
    sc_signal<FPDATA_WORD> ping_val1;
    sc_signal<FPDATA_WORD> ping_val2;
    sc_signal<FPDATA_WORD> pong_val1;
    sc_signal<FPDATA_WORD> pong_val2;
    sc_signal<uint32_t> p_rows;
    sc_signal<uint32_t> q_cols;
    sc_signal<uint32_t> m_rows;
    sc_signal<FPDATA_WORD> gamma;
    sc_signal<uint32_t> maxiter;
    sc_signal<uint32_t> p2p_in;
    sc_signal<uint32_t> p2p_out;
    sc_signal<uint32_t> p2p_iter;
    sc_signal<uint32_t> store_state;
    sc_dt::sc_bv<DMA_WIDTH> dataBv_ping;
    sc_dt::sc_bv<DMA_WIDTH> dataBv_pong;

};


inline void sinkhorn::computeP_store_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("computeP-store-handshake");

        compute_ready.req.req();
    }
}

inline void sinkhorn::store_computeP_handshake()
{
    {
        HLS_DEFINE_PROTOCOL("store-computeP-handshake");

        compute_ready.ack.ack();
    }
}

inline void sinkhorn::reset_computeP_output()
{
    compute_ready.req.reset_req();
}

inline void sinkhorn::reset_store_computeP_output()
{
    compute_ready.ack.reset_ack();
}

#endif /* __SINKHORN_HPP__ */
