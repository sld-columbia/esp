// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// #include "DataPath.hpp"
#include "macfin2.hpp"
#include <mc_scverify.h>

void DataPath::compute()
{

    sync00.Reset();
    conf_info_in.Reset();

    in_rd_rsp.Reset();
    in_wr_req.Reset();

    wait();

    while (1) {

        sync00.Pop();
        conf_info_t conf = conf_info_in.Pop();

        /* <<--local-params-->> */
        uint32_t mac_n = conf.mac_n;
        uint32_t mac_vec = conf.mac_vec;
        uint32_t mac_len = conf.mac_len;

        // Batching
        for (uint16_t b = 0; b < mac_n; b++) {
            wait();

            uint32_t in_length = mac_vec*mac_len;

            // Chunking
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD) {

                uint32_t in_len = in_rem > PLM_IN_WORD ? PLM_IN_WORD : in_rem;

// Compute Kernel

                FPDATA acc_fx=0;
                uint32_t vec_indx=0;
                uint32_t vec_num=0;
                uint32_t vec_idx=0;

#pragma hls_pipeline_init_interval 2
#pragma pipeline_stall_mode flush
                for (uint32_t i=0; i < in_len; i+=2) {
                    // FPDATA_WORD op[2];
                    read_data op;
                    op = in_rd_rsp.Pop();


                    FPDATA op0_fx,op1_fx=0;
                    int2fx(op.data[0],op0_fx);
                    int2fx(op.data[1],op1_fx);
                    // Multiply and accumulate
                    acc_fx+=op0_fx * op1_fx;
                    vec_indx+=2;

                    // Write accumulated result
                    if (vec_indx == mac_len) {
                        FPDATA_WORD acc=0;
                        fx2int(acc_fx,acc);

                        in_wr_req.Push(acc);

                        vec_indx=0;
                        acc_fx=0;
                    }
                }
// End Compute kernel
            }
        }
    }
}
