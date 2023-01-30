// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "sinkhorn.hpp"
//#include "sinkhorn_directives.hpp"

// Functions

#include "sinkhorn_functions.hpp"

//Inputs: inputX[m*p], inputY[m*q], p, q, m, gamma, maxiter
//Outputs: P[p*q], CP_sum
//Memories: P[q*p], C[q*p], K[q*p], x_a[p], y_b[q], inputX[m*p], inputY[m*q]
//Config Registers: Inputs dimensions - rows, q_cols, m_rows
//                  Sinkhorn Algorithm constants - gamma, maxiter
//                  P2P feature support - p2p_in, p2p_out, p2p_iter, store_state

// Processes

void sinkhorn::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();
        accel_ready.ack.reset_ack();

        // User-defined reset code for the registers
        p_rows = 0;
        q_cols = 0;
        m_rows = 0;
        gamma = 0;
        maxiter = 0;
        p2p_in = 0; //Expect input to come directly from P2P
        p2p_out = 0; //Expect output to be sent in P2P
        p2p_iter = 1; //How many iterations of P2P
        store_state = 0;

        //The store_state configuration register is used to control executions
        //of the processes while using the P2P feature from ESP. As for the current
        //P2P feature (2021). Executions of the first and last iterations of the
        //algorithm require disabling P2P and sending/receiving data to/from
        //memory:
        //0 - accelerator expects regular source/destination interactions
        //1 - accelerator loads data from source in the first iteration, stops
        //    when norm check converges (or p2p_iter) - no final store to
        //    destination (used if N Sinkhorn x N SVD)
        //2 - if p2p_iter == 1 the accelrator only stores the data - allows to
        //    run only one iteration and then only store to memory/P2P
        //3 - accelerator doesn't load from source in the first iteration,
        //    doesn't stop on norm check (only when p2p_iter finishes), doesn't
        //    store in the last iteration of p2p_iter (used if N Sinkhorn x 1 SVD)

        wait();
    }

    // Config
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        p_rows = config.p_rows;
        q_cols = config.q_cols;
        m_rows = config.m_rows;
        gamma = config.gamma;
        maxiter = config.maxiter;
        p2p_in = config.p2p_in;
        p2p_out = config.p2p_out;
        p2p_iter = config.p2p_iter > 0 ? config.p2p_iter : 1;
        store_state = config.store_state;
        //wait();
    }

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Config done");
#endif

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

        //bool ping = true;
        uint32_t offset = 0;
        uint32_t length_X = p_rows * m_rows;
        uint32_t length_Y = q_cols * m_rows;

        // Batching
        for (uint16_t b = 0; b < p2p_iter; b++)
        {
            wait();

            if((store_state == 2 && p2p_iter == 1) || (store_state == 3 && b == 0))
            {
                //Do not load new data
                this->load_compute_handshake();
                this->load_compute_handshake();
            }
            else
            {

#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = length_X + length_Y;
            if(p2p_in == 1) length = length + 1;
#else
            // uint32_t length_X = round_up(p_rows * m_rows, DMA_WORD_PER_BEAT);
            // uint32_t length_Y = round_up(q_cols * m_rows, DMA_WORD_PER_BEAT);
            uint32_t length = round_up(length_X+length_Y, DMA_WORD_PER_BEAT);
            if(p2p_in == 1)length = round_up(length_X+length_Y+1, DMA_WORD_PER_BEAT);
#endif
            wait();
            offset = 0;
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_TOTAL_IN_WORD)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > PLM_TOTAL_IN_WORD ? PLM_TOTAL_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                // dma_info_t dma_info(offset >> LOG_DMA_WORD_PER_BEAT, len >> LOG_DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_read_ctrl.put(dma_info);

#ifndef STRATUS_HLS
                ESP_REPORT_INFO("DMA INFO LOAD: index = %d, length = %d, size = %d \n", dma_info.index, dma_info.length, DMA_SIZE.to_uint());
#endif

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    sc_dt::sc_bv<DATA_WIDTH> dataBv;

                   for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
                    {
                        dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.get();
                        wait();
                    }

                    // Write to PLM
                    if(i < length_X)
                        inputX[i] = dataBv.to_uint();
                    else
                        inputY[i] = dataBv.to_uint();
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    HLS_BREAK_DEP(inputX);
                    HLS_BREAK_DEP(inputY);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();

                    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if(i+k < length_X)
                        {
                            inputX[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_uint();
                            // inputX[i + k] = dataBv.range(((k+1) << LOG_DATA_WIDTH) - 1, k << LOG_DATA_WIDTH).to_uint();

#ifndef STRATUS_HLS
            FPDATA data_fp;
            FPDATA_WORD data_word = inputX[i+k];
            cynw_interpret(data_word, data_fp);
            float data_float;
            fp2native(data_fp, data_float);
            //ESP_REPORT_INFO("DMA read inputX = %.20f, offset is %d", data_float, i+k);
#endif

                        }
                        else
                        {
                            inputY[i + k - length_X] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_uint();
                            // inputY[i + k - length_X] = dataBv.range(((k+1) << LOG_DATA_WIDTH) - 1, k << LOG_DATA_WIDTH).to_uint();

                            // if(i + k - length_X == length_Y)
                            // {
                            //     FPDATA data_fp = 1.0;
                            //     FPDATA_WORD data_word;
                            //     cynw_interpret(data_fp, data_word);
                            //     inputY[i + k - length_X] = data_word;
                            // }

#ifndef STRATUS_HLS
            FPDATA data_fp;
            FPDATA_WORD data_word = inputY[i+k];
            cynw_interpret(data_word, data_fp);
            float data_float;
            fp2native(data_fp, data_float);
            //ESP_REPORT_INFO("DMA read inputY = %.20f, offset is %d", data_float, i+k);
#endif
                        }
                    }
                }
#endif
                wait();
            }

#ifndef STRATUS_HLS
            ESP_REPORT_INFO("DMA read inputX and inputY complete, offset is %d", offset);
#endif

            //Check if SVD accelerator signaled that norm check converged
            wait();
            FPDATA data_fp, tmp = 1.0;
            FPDATA_WORD data_word = inputY[length_Y];
            //wait();
            cynw_interpret(data_word, data_fp);
            //wait();
            if(p2p_in == 1 && data_fp == tmp && store_state != 3)
                b = p2p_iter - 1;//Finish if norm check succeeded

            this->load_compute_handshake(); // loaded input is ready
            this->load_compute_handshake(); // waiting for next compute
            }
        }
    }


#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Load is done");
#else
    printf("Load is done\n");
#endif

    // Conclude
    {
        HLS_PROTO("load-done");
        this->process_done();
    }
}


void sinkhorn::compute_kernel()
{

    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // // User-defined reset code
        // CP_sum = 0;
        // p_rows = 0;
        // q_cols = 0;
        // m_rows = 0;
        // gamma = 0;
        // maxiter = 0;
        //unsigned compute_iter = 1;

        wait();
    }

    // Config
    uint32_t p2p_iter;
    uint32_t p2p_in;
    uint32_t store_state;
    uint32_t m_rows;
    uint32_t p_rows;
    uint32_t q_cols;
    uint32_t maxiter;
    FPDATA_WORD gamma;

    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        p_rows = config.p_rows;
        q_cols = config.q_cols;
        m_rows = config.m_rows;
        gamma = config.gamma;
        maxiter = config.maxiter;
        p2p_in = config.p2p_in;
        p2p_iter = config.p2p_iter > 0 ? config.p2p_iter : 1;
        store_state = config.store_state;
        wait();
    }

    uint32_t length_Y = m_rows*q_cols;

    for(int b = 0; b < p2p_iter; b++)
    {

    this->compute_load_handshake();

    //Check if SVD accelerator signaled that norm check converged
    FPDATA data_fp, tmp = 1.0;
    FPDATA_WORD data_word = inputY[length_Y];
    cynw_interpret(data_word, data_fp);

    if(p2p_in == 1 && data_fp == tmp && store_state != 3)
        b = p2p_iter - 1;//Finish if norm check succeeded

    if((store_state == 2 && p2p_iter == 1) || (store_state == 3 && b == 0))
    {
        //Do nothing - P2P related
    }
    else
    {


    // Compute

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("START COMPUTING");
#else
    printf("START COMPUTING\n");
#endif

    compute_C(p_rows, q_cols, m_rows, gamma);

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Compute C is done");
#else
    printf("Compute C is done\n");
#endif

    compute_P(p_rows, q_cols, maxiter);
#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Compute K is done");
#else
    printf("Compute K is done\n");
#endif


    }
        this->compute_store_handshake();
        this->compute_store_handshake();
        this->compute_load_handshake();

    }

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Compute is done");
#else
    printf("Compute is done\n");
#endif

}

void sinkhorn::store_output()
{

    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();
        this->reset_store_computeP_output();

        // User-defined reset code

        wait();
    }

    // Config
    uint32_t q_cols;
    uint32_t m_rows;
    uint32_t p_rows;
    uint32_t p2p_in;
    uint32_t p2p_out;
    uint32_t p2p_iter;
    uint32_t store_state;

    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        p_rows = config.p_rows;
        q_cols = config.q_cols;
        m_rows = config.m_rows;
        p2p_in = config.p2p_in;
        p2p_out = config.p2p_out;
        p2p_iter = config.p2p_iter > 0 ? config.p2p_iter : 1;
        store_state = config.store_state;//0 - store, 1 - don't store on the last iteration if p2p_out
    }

    // Store
    {

        HLS_PROTO("store-dma");
        wait();

        uint32_t length_Y = m_rows*q_cols;
        uint32_t length_X = m_rows*p_rows;
        uint32_t length_P = p_rows*q_cols;

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = length_X+length_Y;
#else
        uint32_t store_offset = round_up(length_X+length_Y, DMA_WORD_PER_BEAT) * 1;
#endif
        uint32_t offset = store_offset;

        wait();

        // Batching
        for (uint16_t b = 0; b < p2p_iter; b++)
        {

            this->store_compute_handshake();
            this->store_computeP_handshake();

            wait();
            FPDATA data_fp, tmp = 1.0;
            FPDATA_WORD data_word = inputY[length_Y];
            cynw_interpret(data_word, data_fp);

            if(p2p_in == 1 && data_fp == tmp && store_state != 3)
                b = p2p_iter - 1;//Finish if norm check succeeded

            //When we are in the last iteration, don't store
            //the data if store state is 1 or 3
            if((store_state == 1 || store_state == 3) && b == p2p_iter - 1)
            {
                this->store_compute_handshake();
            }
            else
            {
                wait();
                bool pingpong = false;

#if (DMA_WORD_PER_BEAT == 0)
                uint32_t length = length_P + 1;
                offset = store_offset;
                if(p2p_out == 1)
                    length = length_P;
#else
                uint32_t length = round_up(length_P + 1, DMA_WORD_PER_BEAT);
                offset = store_offset;
                if(p2p_out == 1)
                    length = round_up(length_P, DMA_WORD_PER_BEAT);
#endif
                // Chunking
                for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
                {

#ifndef STRATUS_HLS
                    ESP_REPORT_INFO("DMA write start offset is %d", offset);
#endif
                    // Configure DMA transaction
                    uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                    // data word is wider than NoC links
                    dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                    dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                    // dma_info_t dma_info(offset >> LOG_DMA_WORD_PER_BEAT, len >> LOG_DMA_WORD_PER_BEAT, DMA_SIZE);
#endif

#ifndef STRATUS_HLS
                    ESP_REPORT_INFO("DMA INFO STORE: index = %d, length = %d, size = %d \n", dma_info.index, dma_info.length, DMA_SIZE.to_uint());
#endif
                    offset += len;

                    this->dma_write_ctrl.put(dma_info);

//     sc_bv<DMA_WIDTH> data;

//     // Load inputs X - Every DMA brings one 32 bit word
//     for (uint32_t i = plm_addr; i < /*PLM_OUTPUT_SIZE*/(plm_addr + p_rows * q_cols); i++) {
//         wait();
//         data = sc_bv<DMA_WIDTH>(P[i]);
//         wait();
//         this->dma_write_chnl.put(data);
// //        ESP_REPORT_INFO("Value sent to memory: %d : %d", i, P[i])
//     }


#if (DMA_WORD_PER_BEAT == 0)
                    // data word is wider than NoC links
                    for (uint16_t i = 0; i < len; i++)
                    {

                        // Read from PLM
                        sc_dt::sc_int<DATA_WIDTH> data;
                        wait();

                        data = P[i];

                        sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

                        uint16_t k = 0;
                        for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
                        {
                            this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                            wait();
                        }
                        // Last beat on the bus does not require wait(), which is
                        // placed before accessing the PLM
                        this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                    }
#else

                    //wait();
                    //compute_store_P(p_rows, q_cols);
                    uint16_t h = 0;
                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

#ifndef STRATUS_HLS
                    ESP_REPORT_INFO("len = %d, size = %d", len, len / DMA_WORD_PER_BEAT);
#endif

                    for (uint16_t i = 0; i < length_P; i += q_cols)
                    {

                        wait();

                        this->store_computeP_handshake();

                        for(uint16_t k = 0; k < q_cols; k++)
                        {

                            wait();

                            if(pingpong == false)
                            {
                                dataBv.range((h+1) * DATA_WIDTH - 1, h * DATA_WIDTH) = Ping[k];
                                // dataBv.range(((h+1) << LOG_DATA_WIDTH) - 1, h << LOG_DATA_WIDTH) = Ping[k];
                            }
                            //this->dma_write_chnl.put(dataBv_ping);
                            else
                            {
                                dataBv.range((h+1) * DATA_WIDTH - 1, h * DATA_WIDTH) = Pong[k];
                                // dataBv.range(((h+1) << LOG_DATA_WIDTH) - 1, h << LOG_DATA_WIDTH) = Pong[k];
                            }
                            //this->dma_write_chnl.put(dataBv_pong);

                            h = h + 1;
                            if(h == DMA_WORD_PER_BEAT)
                            {
                                h = 0;
                                this->dma_write_chnl.put(dataBv);
                            }

                        }

                        pingpong = !pingpong;

#ifndef STRATUS_HLS
                        //ESP_REPORT_INFO("store pingpong is %d", pingpong);
#endif
                    }

                    this->store_computeP_handshake();
                    wait();
                    //Store CP_sum
                    if(pingpong == false)
                    {
                        dataBv.range((h+1) * DATA_WIDTH - 1, h * DATA_WIDTH) = Ping[0];
                        // dataBv.range(((h+1) << LOG_DATA_WIDTH) - 1, h << LOG_DATA_WIDTH) = Ping[0];
                    }
                    //this->dma_write_chnl.put(dataBv_ping);
                    else
                    {
                        dataBv.range((h+1) * DATA_WIDTH - 1, h * DATA_WIDTH) = Pong[0];
                        // dataBv.range(((h+1) << LOG_DATA_WIDTH) - 1, h << LOG_DATA_WIDTH) = Pong[0];
                    }
                    //this->dma_write_chnl.put(dataBv_pong);

                    if(!(p2p_out == 1 && h == 0))
                        this->dma_write_chnl.put(dataBv);
                    pingpong = !pingpong;

                    //ESP_REPORT_INFO("counter = %d", counter)

#endif


                }


                this->store_compute_handshake(); // Store is done, compute next batch
            }
        }
    }

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("DMA write complete");
#endif



#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Store is done");
#else
    printf("Store is done\n");
#endif

    // Conclude
    {
        HLS_PROTO("store-done");
        this->accelerator_done();
        this->process_done();
    }
}


void sinkhorn::compute_store_P()
{

    // Reset
    {
        HLS_PROTO("computeP-reset");

        this->reset_computeP_output();

        // User-defined reset code

        wait();
    }

    uint32_t q_cols;
    uint32_t p_rows;
    uint32_t m_rows;
    uint32_t p2p_iter;
    uint32_t p2p_in;
    uint32_t store_state;
    //uint32_t gamma;
    //sc_dt::sc_bv<DMA_WIDTH> dataBv;

    {
        HLS_PROTO("computeP-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        p_rows = config.p_rows;
        q_cols = config.q_cols;
        m_rows = config.m_rows;
        //gamma = config.gamma;
        p2p_iter = config.p2p_iter > 0 ? config.p2p_iter : 1;
        p2p_in = config.p2p_in;
        store_state = config.store_state;
        wait();
    }

    //Compute P
    {

        //HLS_PROTO("computeP-dma");
        //wait();

#ifndef STRATUS_HLS
        float sum = 0;
#endif

        uint32_t length_Y = m_rows*q_cols;
        // FPDATA gamma_fp;
        // cynw_interpret(gamma, gamma_fp);
        // gamma_fp = 1 / gamma_fp;

        for (uint16_t b = 0; b < p2p_iter; b++)
        {
            //Handshake from store to start computing P
            this->computeP_store_handshake();
            // wait();

            ////wait();
            FPDATA data_fp, tmp = 1.0;
            FPDATA_WORD data_word = inputY[length_Y];
            cynw_interpret(data_word, data_fp);

            if(p2p_in == 1 && data_fp == tmp && store_state != 3)
                b = p2p_iter - 1;//Finish if norm check succeeded

            //The no-store states
            if((store_state == 1 || store_state == 3) && b == p2p_iter - 1){
                //Do nothing - Skip P computation
            }
            else
            {

                FPDATA_WORD CP_word;
                //sc_dt::sc_bv<FPDATA_WL> CP_bv;
                FPDATA CP_fp_total = 0;
                uint32_t i = 0, j = 0;
                //uint16_t h = 0;
                bool pingpong = false;

                //Create diagonal matrices from x_a and b_y and do P = x_a @ K @ b_y
                for(i = 0; i < P_MAX; i++)
                {
                    HLS_BREAK_DEP(x_a);
                    //wait();

                    if(i >= p_rows){}
                    else
                    {
                        FPDATA_WORD a_word = x_a[i];
                        FPDATA a_fp = 0;
                        //wait();
                        cynw_interpret(a_word, a_fp);

// #ifndef STRATUS_HLS
//     ESP_REPORT_INFO("i is %d", i);
// #endif
                        for(j = 0; j < Q_MAX; j++)
                        {
                            HLS_PIPELINE_LOOP(SOFT_STALL, 1, "store P loop");
                            HLS_BREAK_DEP(y_b);
                            HLS_BREAK_DEP(K);
                            HLS_BREAK_DEP(C);
                            HLS_BREAK_DEP(Ping);
                            HLS_BREAK_DEP(Pong);
                            //wait();

                            if(j >= q_cols){}
                            else
                            {
                                //wait();
                                FPDATA CP_fp;
                                FPDATA_WORD b_word = y_b[j];
                                FPDATA b_fp;
                                FPDATA_WORD K_word = K[i * q_cols + j];
                                FPDATA K_fp;
                                FPDATA_WORD P_word;
                                FPDATA P_fp;
                                FPDATA_WORD C_word = C[i * q_cols + j];
                                FPDATA C_fp;
                                //sc_dt::sc_bv<FPDATA_WL> P_bv;

                                //wait();

                                //cynw_interpret(C_word, C_fp);
                                //cynw_interpret(b_word, b_fp);
                                //K_fp = neg_exp(C_fp * gamma_fp);

                                cynw_interpret(b_word, b_fp);
                                cynw_interpret(K_word, K_fp);
                                //wait();
                                cynw_interpret(C_word, C_fp);

                                //P[i * q + j] = x_a[i] * K[i * q + j] * y_b[j];
                                P_fp = a_fp * K_fp * b_fp;

#ifndef STRATUS_HLS
                                sum += P_fp;
#endif
                                cynw_interpret(P_fp, P_word);

                                //wait();
                                if(pingpong == false)
                                    Ping[j] = P_word;
                                else
                                    Pong[j] = P_word;

                                ////wait();
                                CP_fp = C_fp * P_fp;
                                CP_fp_total += CP_fp;
                                //wait();
                            }
                        }

                        pingpong = !pingpong;
                        this->computeP_store_handshake();
                        //wait();

                    }
                }

                //wait();
                cynw_interpret(CP_fp_total, CP_word);

                if(pingpong == false)
                    Ping[0] = CP_word;
                else
                    Pong[0] = CP_word;
                pingpong = !pingpong;
                this->computeP_store_handshake();
                //wait();

#ifndef STRATUS_HLS
                float sum_CP = CP_fp_total;
                ESP_REPORT_INFO("P sum is %f", sum);
                ESP_REPORT_INFO("CP sum is %f", sum_CP);
                ESP_REPORT_INFO("Compute P finished");
                sum =0;
                sum_CP = 0;
#endif

            }
        }
    }

    // Conclude
    {
        HLS_PROTO("computeP-done");
        this->process_done();
    }

}

